"
This class implements the source file management behavior of traditional Squeak, with a sources file and a changes file. File positions are mapped such that those files can be up to 32MBytes in size.

Structure:
 files		Array -- storing the actual source files

"
Class {
	#name : #StandardSourceFileArray,
	#superclass : #SourceFileArray,
	#instVars : [
		'files'
	],
	#category : #'Files-System'
}

{ #category : #'initialize-release' }
StandardSourceFileArray class >> new: nFiles [
	^self new initialize: nFiles.
]

{ #category : #accessing }
StandardSourceFileArray >> at: index [
	^files at: index
]

{ #category : #accessing }
StandardSourceFileArray >> at: index put: aFile [
	^files at: index put: aFile
]

{ #category : #'sourcePointer conversion' }
StandardSourceFileArray >> checkOKToAdd: size at: filePosition [
	"Issue several warnings as the end of the changes file approaches its limit,
	and finally halt with an error when the end is reached."

	| fileSizeLimit margin |
	fileSizeLimit := 16r2000000.
	3 to: 1 by: -1 do:
		[:i | margin := i*100000.
		(filePosition + size + margin) > fileSizeLimit
			ifTrue: [(filePosition + margin) > fileSizeLimit ifFalse:
						[self inform: 'WARNING: your changes file is within
' , margin printString , ' characters of its size limit.
You should take action soon to reduce its size.
You may proceed.']]
			ifFalse: [^ self]].
	(filePosition + size > fileSizeLimit) ifFalse: [^ self].
	self error: 'You have reached the size limit of the changes file.
You must take action now to reduce it.
Close this error.  Do not attempt to proceed.'
]

{ #category : #'sourcePointer conversion' }
StandardSourceFileArray >> fileIndexFromSourcePointer: anInteger [
	"Return the index of the source file which contains the source chunk addressed by anInteger"
	"This implements the recent 32M source file algorithm"

	| hi |
	hi := anInteger // 16r1000000.
	^hi < 3
		ifTrue: [hi]
		ifFalse: [hi - 2]
]

{ #category : #'sourcePointer conversion' }
StandardSourceFileArray >> filePositionFromSourcePointer: anInteger [
	"Return the position of the source chunk addressed by anInteger"
	"This implements the recent 32M source file algorithm"

	| hi lo |
	hi := anInteger // 16r1000000.
	lo := anInteger \\ 16r1000000.
	^hi < 3
		ifTrue: [lo]
		ifFalse: [lo + 16r1000000]
]

{ #category : #'initialize-release' }
StandardSourceFileArray >> initialize [
	files := Array new: 2.
	files at: 1 put: (SourceFiles at: 1).
	files at: 2 put: (SourceFiles at: 2)
]

{ #category : #'initialize-release' }
StandardSourceFileArray >> initialize: nFiles [
	files := Array new: nFiles
]

{ #category : #accessing }
StandardSourceFileArray >> size [
	^files size
]

{ #category : #'sourcePointer conversion' }
StandardSourceFileArray >> sourcePointerFromFileIndex: index andPosition: position [
	| hi lo |
	"Return a source pointer according to the new 32M algorithm"
	((index between: 1 and: 2) and: [position between: 0 and: 16r1FFFFFF])
		ifFalse: [self error: 'invalid source code pointer'].
	hi := index.
	lo := position.
	lo >= 16r1000000 ifTrue: [
		hi := hi+2.
		lo := lo - 16r1000000].
	^hi * 16r1000000 + lo
]
