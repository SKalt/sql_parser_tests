package corpus

import (
	"database/sql"
	"log"

	_ "github.com/mattn/go-sqlite3"
	"github.com/skalt/pg_sql_tests/pkg/languages"
)

// TODO: use a sqlite connector

//go:embed ./sql/get_statements_by_language.sql
var getStatementsByLanguage string

type Statement struct {
	Id   uint64
	Text string
}

func GetStatementsByLanguage(db *sql.DB, language string) (results []*Statement) {
	rows, err := db.Query(getStatementsByLanguage, language)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()
	for rows.Next() {
		var row Statement
		if err := rows.Scan(&row.Id, &row.Text); err != nil {
			results = append(results, &row)
		}
	}
	return results
}

func LookupLanguageId(language string) int {
	if id, ok := languages.Languages[language]; ok {
		return id
	} else {
		// other
		return -1
	}
}
