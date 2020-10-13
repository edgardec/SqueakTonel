"
This is a variation on StandardSourceFileArray that provides a larger maximum changes file size.

The available address space for source pointers in a traditional CompiledMethod is 16r1000000 through 16r4FFFFFF. StandardSourceFileArray maps positions in the sources file to address range 16r1000000 through 16r1FFFFFF and 16r3000000 through 16r3FFFFFF, and positions in the changes file to address range 16r2000000 through 16r2FFFFFF and 16r4000000 through 16r4FFFFFF. This permits a maximum file size of 16r2000000 (32MB) for both the sources file and the changes file. 

This implementation extends the source pointer address space using bit 25 of the source pointer to identify the external sources and changes files, with the remaining high order bits treated as address extension. This limits the number of external file references to two (the traditional sources and changes files). If additional external file references are needed in the future, some higher order bits in the source pointer address space should be allocated for that purpose.

The use of bit 25 of the source pointer for file references permits backward compatibility with StandardSourceFileArray, with essentially unlimited address space expansion for the sources and changes files.

"
Class {
	#name : #ExpandedSourceFileArray,
	#superclass : #SourceFileArray,
	#instVars : [
		'files'
	],
	#category : #'Files-System'
}

{ #category : #'initialize-release' }
ExpandedSourceFileArray class >> new: nFiles [
	^self new initialize: nFiles.
]

{ #category : #accessing }
ExpandedSourceFileArray >> at: index [
	^files at: index
]

{ #category : #accessing }
ExpandedSourceFileArray >> at: index put: aFile [
	^files at: index put: aFile
]

{ #category : #'sourcePointer conversion' }
ExpandedSourceFileArray >> checkOKToAdd: size at: filePosition [
	"No check is required"

	^ self
]

{ #category : #'sourcePointer conversion' }
ExpandedSourceFileArray >> fileIndexFromSourcePointer: anInteger [
	"Return the index of the source file which contains the source chunk addressed by anInteger"

	(anInteger bitAnd: 16r1000000) ~= 0
		ifTrue: [^1 "sources file"]
		ifFalse: [anInteger >= 16r1000000
			ifTrue: [^2 "changes file"]
			ifFalse: [^0 "compatibility with StandardSourceFileArray"]]
]

{ #category : #'sourcePointer conversion' }
ExpandedSourceFileArray >> filePositionFromSourcePointer: anInteger [ 
	"Return the position of the source chunk addressed by anInteger"

	| hi lo |
	hi := anInteger // 33554432.
	lo := anInteger \\ 16777216.
	((anInteger bitAnd: 16777216) ~= 0
			or: [anInteger < 16777216 "compatibility with StandardSourceFileArray"])
		ifTrue: [^ hi * 16777216 + lo"sources file"]
		ifFalse: [^ hi - 1 * 16777216 + lo"changes file"]
]

{ #category : #'initialize-release' }
ExpandedSourceFileArray >> initialize [
	files := Array new: 2.
	files at: 1 put: (SourceFiles at: 1).
	files at: 2 put: (SourceFiles at: 2)
]

{ #category : #'initialize-release' }
ExpandedSourceFileArray >> initialize: nFiles [
	files := Array new: nFiles
]

{ #category : #accessing }
ExpandedSourceFileArray >> size [
	^files size
]

{ #category : #'sourcePointer conversion' }
ExpandedSourceFileArray >> sourcePointerFromFileIndex: index andPosition: position [
	"Return a sourcePointer encoding the given file index and position"

	| hi lo |
	(index = 1 or: [index = 2])
		ifFalse: [self error: 'invalid source file index'].
	position < 0 ifTrue: [self error: 'invalid source code pointer'].
	hi := position // 16r1000000 *2 + index.
	lo := position \\ 16r1000000.
	^ hi * 16r1000000 + lo

]
