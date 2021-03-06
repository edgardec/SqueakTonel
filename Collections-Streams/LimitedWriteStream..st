"
A LimitedWriteStream is a specialized WriteStream that has a maximum size of the collection it streams over. When this limit is reached a special limitBlock is executed. This can for example be used to ""bail out"" of lengthy streaming operations before they have finished.  For a simple example take a look at the universal Object printString.

The message SequenceableCollection class streamContents:limitedTo: creates a LimitedWriteStream. In this case it prevents very large (or possibly recursive) object structures to ""overdo"" their textual representation. 
"
Class {
	#name : #LimitedWriteStream,
	#superclass : #WriteStream,
	#instVars : [
		'limit',
		'limitBlock'
	],
	#category : #'Collections-Streams'
}

{ #category : #accessing }
LimitedWriteStream >> nextPut: anObject [ 
	"Ensure that the limit is not exceeded"

	position >= limit
		ifTrue:
			[ limitBlock value.
			^anObject ].
    ^super nextPut: anObject

]

{ #category : #writing }
LimitedWriteStream >> nextPutAll: aCollection [

	| newEnd |
	collection class == aCollection class ifFalse:
		[^ super nextPutAll: aCollection ].

	newEnd := position + aCollection size.
	newEnd > limit ifTrue: [
		super nextPutAll: (aCollection copyFrom: 1 to: (limit - position max: 0)).
		limitBlock value.
		^aCollection
	].
	newEnd > writeLimit ifTrue: [
		self growTo: newEnd + 10
	].

	collection replaceFrom: position+1 to: newEnd  with: aCollection startingAt: 1.
	position := newEnd.
	^aCollection
]

{ #category : #private }
LimitedWriteStream >> pastEndPut: anObject [
	collection size >= limit ifTrue: [limitBlock value].  "Exceptional return"
	^ super pastEndPut: anObject
]

{ #category : #'initialize-release' }
LimitedWriteStream >> setLimit: sizeLimit limitBlock: aBlock [
	"Limit the numer of elements this stream will write..."
	limit := sizeLimit.
	"Execute this (typically ^ contents) when that limit is exceded"
	limitBlock := aBlock
]
