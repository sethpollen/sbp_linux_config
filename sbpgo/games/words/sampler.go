package words

import (
	"log"
	"math/rand"
)

func checkSampleArgs(list *WordList, n int) {
	if n > len(list.Words) {
		log.Fatalf(
			"Requested sample size (%v) exceeds population size (%v)\n",
			n, len(list.Words))
	}
}

type weightingFunc func(*Word) int64

// Allows efficient weighted random sampling of a WordList. The index is
// stored as a binary tree, where the leaves correspond 1:1 woth Words in
// 'list'.
type indexNode struct {
	// The total weight of all Words pointed to by nodes in the subtree rooted
	// at this node.
	Weight int64
	// Children of this node. If the node has only one child, 'right' will be
	// nil.
	Left  *indexNode
	Right *indexNode
	// Only set for leaf nodes, where 'left' and 'right' are both nil.
	Word *Word
}

func buildIndex(list *WordList, getWeight weightingFunc) *indexNode {
	// Build the lowest level of the index tree.
	level := make([]*indexNode, list.Len())
	for i := range list.Words {
		word := &list.Words[i]
		level[i] = &indexNode{getWeight(word), nil, nil, word}
	}

	// Build the internal levels of the tree.
	for len(level) > 1 {
		newLevel := make([]*indexNode, (len(level)+1)/2)
		for i := range newLevel {
			left := level[2*i]
			weight := left.Weight
			var right *indexNode = nil
			if 2*i+1 < len(level) {
				right = level[2*i+1]
				weight += right.Weight
			}
			newLevel[i] = &indexNode{weight, left, right, nil}
		}
		level = newLevel
	}

	return level[0]
}

func (self *indexNode) LookUp(weight int64) *Word {
	if self.Word != nil {
		return self.Word
	}
	if weight < self.Left.Weight {
		return self.Left.LookUp(weight)
	}
	return self.Right.LookUp(weight - self.Left.Weight)
}

// Flexible sampling function. Sampling is weighted by occurrence count, but
// every word's occurence count is biased upwards by 'baseOccurrences'.
func Sample(list *WordList, n int, baseOccurrences int64) *WordList {
	checkSampleArgs(list, n)
	index := buildIndex(list, func(word *Word) int64 {
		return word.Occurrences + baseOccurrences
	})
	totalOccurrences := list.TotalOccurrences +
		(int64(list.Len()) * baseOccurrences)
	used := make(map[*Word]bool)
	result := NewWordList()

	for result.Len() < n {
		word := index.LookUp(rand.Int63n(totalOccurrences))
		if used[word] {
			continue
		}
		used[word] = true
		result.AddWord(*word)
	}
	return result
}
