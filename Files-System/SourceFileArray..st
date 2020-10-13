"
This class is an abstract superclass for source code access mechanisms. It defines the messages that need to be understood by those subclasses that store and retrieve source chunks on files, over the network or in databases.
The first concrete subclass, StandardSourceFileArray, supports access to the traditional sources and changes files. Other subclasses might implement multiple source files for different applications, or access to a network source server.
"
Class {
	#name : #SourceFileArray,
	#superclass : #SequenceableCollection,
	#category : #'Files-System'
}

{ #category : #'initialize-release' }
SourceFileArray class >> concreteClass [

	^ ExpandedSourceFileArray
]

{ #category : #'initialize-release' }
SourceFileArray class >> install [
	"Replace SourceFiles by an instance of me with the standard sources and changes files.
	This only works if SourceFiles is either an Array or an instance of this class"

	"SourceFileArray install"

	^ SourceFiles := self concreteClass new
]

{ #category : #accessing }
SourceFileArray >> at: index [
	self subclassResponsibility
]

{ #category : #accessing }
SourceFileArray >> at: index put: aFileStream [
	self subclassResponsibility
]

{ #category : #'sourcePointer conversion' }
SourceFileArray >> checkOKToAdd: size at: filePosition [
	"Issue several warnings as the end of the changes file approaches its limit,
	and finally halt with an error when the end is reached."

	^ self subclassResponsibility
]

{ #category : #'sourcePointer conversion' }
SourceFileArray >> fileIndexAndPositionFromSourcePointer: sourcePointer do: aBlock [

	^aBlock
		value: (self fileIndexFromSourcePointer: sourcePointer)
		value: (self filePositionFromSourcePointer: sourcePointer)
]

{ #category : #'sourcePointer conversion' }
SourceFileArray >> fileIndexFromSourcePointer: anInteger [
	"Return the index of a source file corresponding to the given source pointer."
	self subclassResponsibility
]

{ #category : #'sourcePointer conversion' }
SourceFileArray >> filePositionFromSourcePointer: anInteger [
	"Return the position within a source file for the given source pointer."
	self subclassResponsibility
]

{ #category : #'sourcePointer conversion' }
SourceFileArray >> sourcePointerFromFileIndex: index andPosition: position [
	"Return a sourcePointer encoding the given file index and position"
	self subclassResponsibility
]
