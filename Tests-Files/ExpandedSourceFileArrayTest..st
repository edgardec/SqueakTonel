"
This test documents the source pointer address conversion methods for ExpandedSourceFileArray.

The available address space for source pointers in a traditional CompiledMethod is 16r1000000 through 16r4FFFFFF. StandardSourceFileArray maps positions in the sources file to address range 16r1000000 through 16r1FFFFFF and 16r3000000 through 16r3FFFFFF, and positions in the changes file to address range 16r2000000 through 16r2FFFFFF and 16r4000000 through 16r4FFFFFF. This permits a maximum file size of 16r2000000 (32MB) for both the sources file and the changes file. 

ExpandedSourceFileArray extends the source pointer address space using bit 25 of the source pointer to identify the external sources and changes files, with the remaining high order bits treated as address extension. This limits the number of external file references to two (the traditional sources and changes files). If additional external file references are needed in the future, some higher order bits in the source pointer address space should be allocated for that purpose.

The use of bit 25 of the source pointer for file references permits backward compatibility with StandardSourceFileArray, with essentially unlimited address space expansion for the sources and changes files.

"
Class {
	#name : #ExpandedSourceFileArrayTest,
	#superclass : #TestCase,
	#category : #'Tests-Files'
}

{ #category : #tests }
ExpandedSourceFileArrayTest >> testAddressRange [
	"Test source pointer to file position address translation across a wide address range"
	
	| sf i p a |
	sf := ExpandedSourceFileArray new.
	16r1000000 to: 16r10000000 by: 4093 do: [:e |
		i := sf fileIndexFromSourcePointer: e.
		p := sf filePositionFromSourcePointer: e.
		a := sf sourcePointerFromFileIndex: i andPosition: p.
		self assert: a = e]

]

{ #category : #tests }
ExpandedSourceFileArrayTest >> testChangesFileAddressRange [
	"Test file position to source pointer address translation for the changes file"
	
	| sf i p a a2 |
	sf := ExpandedSourceFileArray new.
	0 to: 16r1FFFFFFF by: 4093 do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		i := sf fileIndexFromSourcePointer: a.
		self assert: i = 2.
		p := sf filePositionFromSourcePointer: a.
		self assert: p = e.
		a2 := sf sourcePointerFromFileIndex: 2 andPosition: p.
		self assert: a2 = a].
	0 to: 16rFFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		self assert: (a between: 16r2000000 and: 16r2FFFFFF)].
	16r1000000 to: 16r1FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		self assert: (a between: 16r4000000 and: 16r4FFFFFF)].
	16r2000000 to: 16r2FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		self assert: (a between: 16r6000000 and: 16r6FFFFFF)].
	16r3000000 to: 16r3FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		self assert: (a between: 16r8000000 and: 16r8FFFFFF)].
	16r4000000 to: 16r4FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		self assert: (a between: 16rA000000 and: 16rAFFFFFF)].
	16r5000000 to: 16r5FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		self assert: (a between: 16rC000000 and: 16rCFFFFFF)].
	16r6000000 to: 16r6FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		self assert: (a between: 16rE000000 and: 16rEFFFFFF)].
	16r7000000 to: 16r7FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 2 andPosition: e.
		self assert: (a between: 16r10000000 and: 16r10FFFFFF)]




]

{ #category : #tests }
ExpandedSourceFileArrayTest >> testCompatibilityWithStandardSourceFileArray [
	"Test compatibility with StandardSourceFileArray across the address range of
	StandardSourceFileArray, including the unused address space below 16r1000000"
	
	| ssf esf i1 i2 p1 p2 a1 a2 |
	ssf := StandardSourceFileArray new.
	esf := ExpandedSourceFileArray new.
	0 to: 16rFFFFFF by: 811 do: [:e |
		i1 := ssf fileIndexFromSourcePointer: e.
		i2 := esf fileIndexFromSourcePointer: e.
		self assert: i1 = i2.
		self assert: i1 = 0. "This is unused address space"
		p1 := ssf filePositionFromSourcePointer: e.
		p2 := esf filePositionFromSourcePointer: e.
		self assert: p1 = p2].
	16r4FFFFFF to: 16r4FFFFFF by: 811 do: [:e |
		i1 := ssf fileIndexFromSourcePointer: e.
		i2 := esf fileIndexFromSourcePointer: e.
		self assert: i1 = i2.
		p1 := ssf filePositionFromSourcePointer: e.
		p2 := esf filePositionFromSourcePointer: e.
		self assert: p1 = p2.
		a1 := ssf sourcePointerFromFileIndex: i1 andPosition: p1.
		a2 := esf sourcePointerFromFileIndex: i2 andPosition: p2.
		self assert: a1 = a2.
		self assert: a1= e]


]

{ #category : #tests }
ExpandedSourceFileArrayTest >> testFileIndexFromSourcePointer [
	"Test derivation of file index for sources or changes file from source pointers"

	| sf |
	sf := ExpandedSourceFileArray new.
	"sources file mapping"
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r1000000).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r1000013).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r1FFFFFF).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r3000000).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r3000013).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r3FFFFFF).

	self assert: 1 = (sf fileIndexFromSourcePointer: 16r5000000).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r5000013).
	self assert: 1 = (sf fileIndexFromSourcePointer: 16r5FFFFFF).

	(16r1000000 to: 16r1FFFFFF by: 811) do: [:e | self assert: 1 = (sf fileIndexFromSourcePointer: e)].
	(16r3000000 to: 16r3FFFFFF by: 811) do: [:e | self assert: 1 = (sf fileIndexFromSourcePointer: e)].
	"changes file mapping"
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r2000000).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r2000013).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r2FFFFFF).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r4000000).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r4000013).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r4FFFFFF).

	self assert: 2 = (sf fileIndexFromSourcePointer: 16r6000000).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r6000013).
	self assert: 2 = (sf fileIndexFromSourcePointer: 16r6FFFFFF).

	(16r2000000 to: 16r2FFFFFF by: 811) do: [:e | self assert: 2 = (sf fileIndexFromSourcePointer: e)].
	(16r4000000 to: 16r4FFFFFF by: 811) do: [:e | self assert: 2 = (sf fileIndexFromSourcePointer: e)].

	"the following numeric ranges are unused but currently produces results as follows"
	self assert: 0 = (sf fileIndexFromSourcePointer: 16r0000000).
	self assert: 0 = (sf fileIndexFromSourcePointer: 16r0000013).
	self assert: 0 = (sf fileIndexFromSourcePointer: 16r0FFFFFF)


]

{ #category : #tests }
ExpandedSourceFileArrayTest >> testFilePositionFromSourcePointer [
	"Test derivation of file position for sources or changes file from source pointers"

	| sf |
	sf := ExpandedSourceFileArray new.
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
ExpandedSourceFileArrayTest >> testSourcePointerFromFileIndexAndPosition [
	"Test valid input ranges"

	| sf |
	sf := ExpandedSourceFileArray new.
	
	self should: [sf sourcePointerFromFileIndex: 0 andPosition: 0] raise: Error.
	self should: [sf sourcePointerFromFileIndex: 0 andPosition: 3] raise: Error.
	self should: [sf sourcePointerFromFileIndex: 1 andPosition: -1] raise: Error.
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
	self assert: 16r5000000 equals: (sf sourcePointerFromFileIndex: 1 andPosition: 16r2000000).
]

{ #category : #tests }
ExpandedSourceFileArrayTest >> testSourcesFileAddressRange [
	"Test file position to source pointer address translation for the sources file"
	
	| sf i p a a2 |
	sf := ExpandedSourceFileArray new.
	0 to: 16r1FFFFFFF by: 4093 do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		i := sf fileIndexFromSourcePointer: a.
		self assert: i = 1.
		p := sf filePositionFromSourcePointer: a.
		self assert: p = e.
		a2 := sf sourcePointerFromFileIndex: 1 andPosition: p.
		self assert: a2 = a].
	0 to: 16rFFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		self assert: (a between: 16r1000000 and: 16r1FFFFFF)].
	16r1000000 to: 16r1FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		self assert: (a between: 16r3000000 and: 16r3FFFFFF)].

	16r2000000 to: 16r2FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		self assert: (a between: 16r5000000 and: 16r5FFFFFF)].
	16r3000000 to: 16r3FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		self assert: (a between: 16r7000000 and: 16r7FFFFFF)].
	16r4000000 to: 16r4FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		self assert: (a between: 16r9000000 and: 16r9FFFFFF)].
	16r5000000 to: 16r5FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		self assert: (a between: 16rB000000 and: 16rBFFFFFF)].
	16r6000000 to: 16r6FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		self assert: (a between: 16rD000000 and: 16rDFFFFFF)].
	16r7000000 to: 16r7FFFFFF by: 811 do: [:e |
		a := sf sourcePointerFromFileIndex: 1 andPosition: e.
		self assert: (a between: 16rF000000 and: 16rFFFFFFF)]

]
