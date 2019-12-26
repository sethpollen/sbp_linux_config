// Specifies the information my prompt has to import from a corp codebase.

package sbpgo

type CorpContext interface {
	// Directory which contains all p4 repositories as children.
	P4Root() string
}
