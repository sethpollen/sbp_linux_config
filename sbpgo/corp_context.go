// Specifies the information my prompt has to import from a corp codebase.

package sbpgo

type CorpContext interface {
  // Directory which contains all g4 repositories as children.
  G4Root() string
}
