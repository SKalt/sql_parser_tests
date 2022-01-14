package psql

import (
	"fmt"
	"log"
	"os/exec"
	"strings"

	"github.com/skalt/pg_sql_tests/pkg/oracles"
	"github.com/skalt/pg_sql_tests/pkg/oracles/postgres/container"
)

type Oracle struct {
	version string
	service *container.Service
}

func Init(version string) *Oracle {
	service := container.InitService(version)
	if err := service.Start(); err != nil {
		log.Panic(err)
	}
	oracle := Oracle{version, service}
	return &oracle
}

func (psql *Oracle) Close() {
	if err := psql.service.Close(); err != nil {
		log.Panic(err)
	}
}

func (psql *Oracle) Name() string {
	return fmt.Sprintf("psql %s", psql.version)
}

// crude parsers for error messages

func startsWith(str string, prefix string) bool {
	return len(str) >= len(prefix) && str[:len(prefix)] == prefix
}

const invalidCommand = "invalid command"

func isInvalidCommand(stderr string) bool {
	return startsWith(stderr, invalidCommand)
}

const unrecognizedValue = "unrecognized value"

func hasUnrecognizedValue(stderr string) bool {
	return startsWith(stderr, unrecognizedValue)
}

func hasSqlishSyntaxError(stderr string) bool {
	if !startsWith(stderr, "ERROR:") {
		return false
	}
	stderr = strings.TrimLeft(stderr[len("ERROR:"):], " \t")
	return startsWith(stderr, "syntax error")
}

// there are more ways to parse psql's stderr, e.g. "ERROR:  invalid input syntax"
// but that is better done by consenting adults as queries on the resulting corpus database
// ERROR:  syntax error

func (psql *Oracle) Predict(statement string, language string) (*oracles.Prediction, error) {
	if language != "psql" {
		return nil, fmt.Errorf("only accepts psql, not %s", language)
	}
	prediction := oracles.Prediction{
		Language: "psql",
		Version:  psql.version,
		Valid:    nil,
	}
	cmd := exec.Command("docker-compose", "exec", "-T", "psql", "--set=ON_ERROR_STOP=on")
	// -T: don't allocate a pseudo-TTY            ^^^^
	cmd.Stdin = strings.NewReader(statement)
	// ^ required for handling `COPY FROM STDIN`
	// also see https://www.postgresql.org/docs/current/app-psql.html#R1-APP-PSQL-3
	// for reasons why passing the statement as via the `--command` flag won't work

	message, err := cmd.Output() // TODO: add timeout in case of long-running psql commands
	if err == nil {
		// the command miraculously worked
		prediction.Error = ""
		// I'm not confident enough to mark not-erroring syntax as valid; no error
		// is at least factual.
		// For example,
		// the following will pass the test:
		// ```psql
		// \if false
		//    completely invalid syntax
		// \endif
		// ```
		// would pass with no error, but is completely invalid, while
		// `select * from foo \g` would fail with a "relation does not exist"
		prediction.Message = string(message)
	} else {
		// this is where the fun begins. Most of our psql commands will exit
		// nonzero since (1) we set ON_ERROR_STOP=on and (2) most queries will
		// use nonexistent database objects
		stderr := err.Error()
		prediction.Error = stderr
		// definitelyInvalid meta-commands are reached before non-existent database objects
		definitelyInvalid := isInvalidCommand(stderr) ||
			hasUnrecognizedValue(stderr) ||
			hasSqlishSyntaxError(stderr)
		if definitelyInvalid {
			valid := false
			prediction.Valid = &valid
		}
	}
	return &prediction, nil
}