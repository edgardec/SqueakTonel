"
I'm useful to avoid the creation of several read-only copies of the source files. Use me instead of SourceFiles in your code when you need a read-only copy, like here:

CurrentReadOnlySourceFiles at: 1.

To reuse the source files, surround your code the following way:

CurrentReadOnlySourceFiles cacheDuring: [
	<your code here using CurrentReadOnlySourceFiles> ]

Note that it's still better performance wise to store the source files in a variable in your code if you need them more than once, than throwing many exceptions.
"
Class {
	#name : #CurrentReadOnlySourceFiles,
	#superclass : #Exception,
	#category : #'Files-System'
}

{ #category : #'act like SourceFiles' }
CurrentReadOnlySourceFiles class >> at: sourceFileIndex [

	^self signal at: sourceFileIndex
]

{ #category : #caching }
CurrentReadOnlySourceFiles class >> cacheDuring: aBlock [
	"Cache the read only source files on the first request and use them on subsequent requests during the evaluation of aBlock."
	
	| currentReadOnlySouceFiles |
	currentReadOnlySouceFiles := nil.
	^aBlock
		on: self
		do: [ :exception |
			exception resume: (currentReadOnlySouceFiles ifNil: [
				currentReadOnlySouceFiles := exception defaultAction ]) ]
]

{ #category : #handling }
CurrentReadOnlySourceFiles >> defaultAction [
	"Return a read-only copy of SourceFiles."

	^SourceFiles collect: [ :each |
		each ifNotNil: [
			[ each readOnlyCopy ]
				on: FileDoesNotExistException
				do: [ :ex | nil "file does not exist happens in secure mode" ] ] ]
]
