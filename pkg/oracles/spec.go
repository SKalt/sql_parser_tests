package oracles

type Prediction struct {
	Language string
	Version  string
	// may be nil in case of ambiguous oracle output.
	Valid   *bool
	Message string
	Error   string
}

// an oracle is something that takes some text and predicts whether
// the statement is valid for a given sql-like dialect version.
type Oracle interface {
	Name() string
	Predict(statement string, language string) (*Prediction, error)
}

// TODO: ability to read statements from db?
