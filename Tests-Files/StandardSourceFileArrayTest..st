"
This test documents the source pointer address conversion methods for StandardSourceFileArray.

The available address space for source pointers in CompiledMethod is 16r1000000 through 16r4FFFFFF. StandardSourceFileArray maps positions in the sources file to address range 16r1000000 through 16r1FFFFFF and 16r3000000 through 16r3FFFFFF, and positions in the changes file to address range 16r2000000 through 16r2FFFFFF and 16r4000000 through 16r4FFFFFF. This permits a maximum file size of 16r2000000 (32MB) for both the sources file and the changes file. 

"
Class {
	#name : #StandardSourceFileArrayTest,
	#superclass : #TestCase,
	#category : #'Tests-Files'
}

{ #category : #tests }
StandardSourceFileArrayTest >> testAddressRange [
	"Test source pointer to file position address translation across the full address range"
	
	| sf |
	sf := StandardSourceFileArray new.
	(16r1000000 to: 16r4FFFFFF by: 811) do: [:e | | i a p |
		i := sf fileIndexFromSourcePointer: e.
		p := sf filePositionFromSourcePointer: e.
		a := sf sourcePointerFromFileIndex: i andPosition: p.
		self assert: a = e]

]

{ #category : #tests }
StandardSourceFileArrayTest >> testChangesFileAddressRange [
	"Test file position to source pointer address translation for the changes file"
	
	| sf a |
	sf := StandardSourceFileArray new.
	(0 to: 16r1FFFFFF by: 811) do: [:e | | a2 i p |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		i := sf fileIndexFromSourcePointer: a.
		self assert: i = 2.
		p := sf filePositionFromSourcePointer: a.
		self assert: p = e.
		a2 := sf sourcePointerFromFileIndex: 2 andPosition: p.
		self assert: a2 = a].
	(0 to: 16rFFFFFF by: 811) do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		self assert: (a between: 16r2000000 and: 16r2FFFFFF)].
	(16r1000000 to: 16r1FFFFFF by: 811) do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		self assert: (a between: 16r4000000 and: 16r4FFFFFF)]



]

{ #category : #tests }
StandardSourceFileArrayTest >> testFileIndexFromSourcePointer [
	"Test derivation of file index for sources or changes file from source pointers"

	| sf |
	sf := StandardSourceFileArray new.
	"sources file mapping"
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r1000000).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r1000013).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r1FFFFFF).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r3000000).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r3000013).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r3FFFFFF).
	(16r1000000 to: 16r1FFFFFF by: 811) do: [:e | self assert: 1 = (sf fileIndexFromSourcePointer: e)].
	(16r3000000 to: 16r3FFFFFF by: 811) do: [:e | self assert: 1 = (sf fileIndexFromSourcePointer: e)].
	"changes file mapping"
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r2000000).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r2000013).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r2FFFFFF).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r4000000).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r4000013).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r4FFFFFF).
	(16r2000000 to: 16r2FFFFFF by: 811) do: [:e | self assert: 2 = (sf fileIndexFromSourcePointer: e)].
	(16r4000000 to: 16r4FFFFFF by: 811) do: [:e | self assert: 2 = (sf fileIndexFromSourcePointer: e)].
	"the following numeric ranges are unused but currently produces results as follows"
	self assert: 0 = (sf fileIndexFromSourcePointer: 16r0000000).
	self assert: 0 = (sf fileIndexFromSourcePointer: 16r0000013).
	self assert: 0 = (sf fileIndexFromSourcePointer: 16r0FFFFFF)



]

{ #category : #tests }
StandardSourceFileArrayTest >> testFilePositionFromSourcePointer [
	"Test derivation of file position for sources or changes file from source pointers"

	| sf |
	sf := StandardSourceFileArray new.
	"sources file"
	self assert: 0 = (sf filePositionFromSourcePointer: 16r1000000).
	self assert: 16r13 = (sf filePositionFromSourcePointer: 16r1000013).
	self assert: 16rFFFFFF = (sf filePositionFromSourcePointer: 16r1FFFFFF).
	self assert: 16r1000000 = (sf filePositionFromSourcePointer: 16r3000000).
	self assert: 16r1000013 = (sf filePositionFromSourcePointer: 16r3000013).
	self assert: 16r1FFFFFF = (sf filePositionFromSourcePointer: 16r3FFFFFF).
	"changes file"
	self assert: 0 = (sf filePositionFromSourcePointer: 16r2000000).
	self assert: 16r13 = (sf filePositionFromSourcePointer: 16r2000013).
	self assert: 16rFFFFFF = (sf filePositionFromSourcePointer: 16r2FFFFFF).
	self assert: 16r1000000 = (sf filePositionFromSourcePointer: 16r4000000).
	self assert: 16r1000013 = (sf filePositionFromSourcePointer: 16r4000013).
	self assert: 16r1FFFFFF = (sf filePositionFromSourcePointer: 16r4FFFFFF).
	"the following numeric ranges are unused but currently produces results as follows"
	self assert: 0 = (sf filePositionFromSourcePointer: 16r0000000).
	self assert: 16r13 = (sf filePositionFromSourcePointer: 16r0000013).
	self assert: 16rFFFFFF = (sf filePositionFromSourcePointer: 16r0FFFFFF)

]

{ #category : #tests }
StandardSourceFileArrayTest >> testSourcePointerFromFileIndexAndPosition [
	"Test valid input ranges"

	| sf |
	sf := StandardSourceFileArray new.
	self should: [sf sourcePointerFromFileIndex: 0 andPosition: 0] raise: Error.
	self should: [sf sourcePointerFromFileIndex: 0 andPosition: 3] raise: Error.
	self should: [sf sourcePointerFromFileIndex: 1 andPosition: -1] raise: Error.
	self should: [sf sourcePointerFromFileIndex: 1 andPosition: 16r2000000] raise: Error.
	self should: [sf sourcePointerFromFileIndex: 3 andPosition: 0] raise: Error.
	self should: [sf sourcePointerFromFileIndex: 4 andPosition: 0] raise: Error.
	
	self assert: 16r1000000 equals: (sf sourcePointerFromFileIndex: 1 andPosition: 0).
	self assert: 16r1000013 equals: (sf sourcePointerFromFileIndex: 1 andPosition: 16r13).
	self assert: 16r1FFFFFF equals: (sf sourcePointerFromFileIndex: 1 andPosition: 16rFFFFFF).
	self assert: 16r2000000 equals: (sf sourcePointerFromFileIndex: 2 andPosition: 0).
	self assert: 16r2000013 equals: (sf sourcePointerFromFileIndex: 2 andPosition: 16r13).
	self assert: 16r2FFFFFF equals: (sf sourcePointerFromFileIndex: 2 andPosition: 16rFFFFFF).
	self assert: 16r3000000 equals: (sf sourcePointerFromFileIndex: 1 andPosition: 16r1000000).
	self assert: 16r3000013 equals: (sf sourcePointerFromFileIndex: 1 andPosition: 16r1000013).
	self assert: 16r3FFFFFF equals: (sf sourcePointerFromFileIndex: 1 andPosition: 16r1FFFFFF).
	self assert: 16r4000000 equals: (sf sourcePointerFromFileIndex: 2 andPosition: 16r1000000).
	self assert: 16r4000013 equals: (sf sourcePointerFromFileIndex: 2 andPosition: 16r1000013).
	self assert: 16r4FFFFFF equals: (sf sourcePointerFromFileIndex: 2 andPosition: 16r1FFFFFF).
]

{ #category : #tests }
StandardSourceFileArrayTest >> testSourcesFileAddressRange [
	"Test file position to source pointer address translation for the sources file"
	
	| sf a |
	sf := StandardSourceFileArray new.
	(0 to: 16r1FFFFFF by: 811) do: [:e | | a2 p i |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		i := sf fileIndexFromSourcePointer: a.
		self assert: i = 1.
		p := sf filePositionFromSourcePointer: a.
		self assert: p = e.
		a2 := sf sourcePointerFromFileIndex: 1 andPosition: p.
		self assert: a2 = a].
	(0 to: 16rFFFFFF by: 811) do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		self assert: (a between: 16r1000000 and: 16r1FFFFFF)].
	(16r1000000 to: 16r1FFFFFF by: 811) do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		self assert: (a between: 16r3000000 and: 16r3FFFFFF)]


]
