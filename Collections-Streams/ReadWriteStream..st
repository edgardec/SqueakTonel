"
I represent an accessor for a sequence of objects. My instances can both read and store objects.
"
Class {
	#name : #ReadWriteStream,
	#superclass : #WriteStream,
	#category : #'Collections-Streams'
}

{ #category : #testing }
ReadWriteStream >> = other [

	(self class == ReadWriteStream and: [other class == ReadWriteStream]) ifFalse: [
		^ super = other].	"does an identity test.  Don't read contents of FileStream"
	^ self position = other position and: [self contents = other contents]
]

{ #category : #'file status' }
ReadWriteStream >> close [
	"Presumably sets the status of the receiver to be closed. This message does 
	nothing at this level, but is included for FileStream compatibility."

	^self
]

{ #category : #'file status' }
ReadWriteStream >> closed [
	"If you have close (for FileStream compatibility), you must respond to closed.  The result in nonsense here.  TK 29 May 96"

	^ false
]

{ #category : #accessing }
ReadWriteStream >> contents [
	"Answer with a copy of my collection from the start to readLimit."

	readLimit := readLimit max: position.
	^collection copyFrom: (initialPositionOrNil ifNil: [1]) to: readLimit
]

{ #category : #testing }
ReadWriteStream >> hash [

	self class == ReadWriteStream ifFalse: [^ super hash].
	^ (self position + readLimit + 53) hash
]

{ #category : #accessing }
ReadWriteStream >> name [
	^ 'a stream'   "for fileIn compatibility"
]

{ #category : #accessing }
ReadWriteStream >> next [
	"Primitive. Return the next object in the Stream represented by the
	receiver. Fail if the collection of this stream is not an Array or a String.
	Fail if the stream is positioned at its end, or if the position is out of
	bounds in the collection. Optional. See Object documentation
	whatIsAPrimitive."

	<primitive: 65>
	"treat me as a FIFO"
	position >= readLimit
		ifTrue: [^nil]
		ifFalse: [^collection at: (position := position + 1)]
]

{ #category : #accessing }
ReadWriteStream >> next: anInteger [ 
	"Answer the next anInteger elements of my collection.  overriden for efficiency"

	| ans endPosition |
	readLimit := readLimit max: position.

	endPosition := position + anInteger  min:  readLimit.
	ans := collection copyFrom: position+1 to: endPosition.
	position := endPosition.
	^ans

]

{ #category : #converting }
ReadWriteStream >> readStream [
	"polymorphic with SequenceableCollection.  Return self"

	^ self
]
