// Specifies the information my prompt has to import from a corp codebase.

package sbpgo

// Any method can return nil if the system doesn't support it.
type CorpContext interface {
	// Command for getting the commit log of a Mercurial repository.
	HgLogCommand() *string

	// Extracts a WorkspaceStatus from the output of the HgLogCommand.
	HgLog(output []byte) (*WorkspaceStatus, error)
}
