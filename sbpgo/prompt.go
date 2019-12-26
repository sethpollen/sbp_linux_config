// Coordinates construction of a PromptEnv.
package sbpgo

// A functor which calls through to Futurize.
type Futurizer func(map[string]string) (map[string][]byte, error)
