// Provides programmatic access to the contents of a Wiktionary page.

package wiktionary

import (
	"bufio"
	"bytes"
	"io"
	"strings"
)

type PageNode struct {
	Text     string
	Children map[string]*PageNode
}

type Page struct {
	RootNode *PageNode
}

// Used for building up PageNode trees during parsing.
type tempPageNode struct {
	// The number of equals signs used in the declaration of this node.
	HeaderLevel int
	Text        bytes.Buffer
	Children    map[string]*tempPageNode
}

func newTempPageNode(headerLevel int) *tempPageNode {
	return &tempPageNode{headerLevel, bytes.Buffer{},
		make(map[string]*tempPageNode)}
}

func (self *tempPageNode) toPageNode() *PageNode {
	result := &PageNode{self.Text.String(), make(map[string]*PageNode)}
	for name, child := range self.Children {
		result.Children[name] = child.toPageNode()
	}
	return result
}

// Parses the Wiktionary page whose markup is contained in 'file'.
func ParsePage(file io.Reader) (*Page, error) {
	scanner := bufio.NewScanner(file)
	scanner.Split(bufio.ScanLines)
	rootNode := newTempPageNode(0)

	// We build up the PageNode tree by parsing lines which start with "=",
	// as the equals sign indicates a header line in MediaWiki markup. This
	// slice holds the path from the root to the current node.
	path := []*tempPageNode{rootNode}

	for scanner.Scan() {
		line := scanner.Text()
		curNode := path[len(path)-1]

		if !strings.HasPrefix(line, "=") {
			// This is a plain old text line; just add it to the current node.
			curNode.Text.WriteString(line)
			continue
		}

		headerLevel := 0
		for _, char := range line {
			if char == '=' {
				headerLevel++
			} else {
				break
			}
		}

		// Work your way back up the tree until you find a node which can be
		// this node's parent.
		for curNode.HeaderLevel >= headerLevel {
			path = path[0 : len(path)-1]
			curNode = path[len(path)-1]
		}

		// Now add the new node as a child of curNode.
		newName := line[headerLevel : len(line)-headerLevel]
		newChild := newTempPageNode(headerLevel)
		curNode.Children[newName] = newChild
		path = append(path, newChild)
	}

	return &Page{rootNode.toPageNode()}, nil
}

func (self *Page) DebugString() string {
	var str bytes.Buffer
	english, ok := self.RootNode.Children["English"]
	if ok {
		// Elide everything but the English section.
		str.WriteString("English\n")
		english.DebugString("  ", &str)
	} else {
		// Just dump the whole thing.
		self.RootNode.DebugString("", &str)
	}
	return str.String()
}

func (self *PageNode) DebugString(indent string, dest *bytes.Buffer) {
	nextIndent := indent + "  "
	for name, child := range self.Children {
		dest.WriteString(indent)
		dest.WriteString(name)
		dest.WriteString("\n")
		child.DebugString(nextIndent, dest)
	}
}
