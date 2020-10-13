"
A simulation of a FileStream, but living totally in memory.  Hold the contents of a file or web page from the network.  Can then fileIn like a normal FileStream.

Need to be able to switch between binary and text, as a FileStream does, without recopying the whole collection.  Convert to binary upon input and output.  Always keep as text internally.
"
Class {
	#name : #RWBinaryOrTextStream,
	#superclass : #ReadWriteStream,
	#instVars : [
		'isBinary'
	],
	#category : #'Collections-Streams'
}

{ #category : #converting }
RWBinaryOrTextStream >> asBinaryOrTextStream [

	^ self
]

{ #category : #accessing }
RWBinaryOrTextStream >> ascii [
	isBinary := false
]

{ #category : #accessing }
RWBinaryOrTextStream >> binary [
	isBinary := true
]

{ #category : #accessing }
RWBinaryOrTextStream >> contents [
	"Answer with a copy of my collection from 1 to readLimit."

	| newArray |
	isBinary ifFalse: [^ super contents].	"String"
	readLimit := readLimit max: position.
	newArray := ByteArray new: readLimit.
	^ newArray replaceFrom: 1
		to: readLimit
		with: collection
		startingAt: 1.
]

{ #category : #accessing }
RWBinaryOrTextStream >> contentsOfEntireFile [
	"For compatibility with file streams."

	^ self contents
]

{ #category : #testing }
RWBinaryOrTextStream >> isBinary [
	^ isBinary
]

{ #category : #accessing }
RWBinaryOrTextStream >> next [

	isBinary ifFalse: [ ^super next ].
	^super next ifNotNil: [ :character | character asInteger ]
]

{ #category : #accessing }
RWBinaryOrTextStream >> next: anInteger [ 
	"Answer the next anInteger elements of my collection. Must override to get class right."

	| newArray |
	newArray := (isBinary ifTrue: [ByteArray] ifFalse: [ByteString]) new: anInteger.
	^ self nextInto: newArray
]

{ #category : #accessing }
RWBinaryOrTextStream >> next: n into: aCollection startingAt: startIndex [
	"Read n objects into the given collection. 
	Return aCollection or a partial copy if less than n elements have been read."
	"Overriden for efficiency"
	| max |
	max := (readLimit - position) min: n.
	aCollection 
		replaceFrom: startIndex 
		to: startIndex+max-1
		with: collection
		startingAt: position+1.
	position := position + max.
	max = n
		ifTrue:[^aCollection]
		ifFalse:[^aCollection copyFrom: 1 to: startIndex+max-1]
]

{ #category : #writing }
RWBinaryOrTextStream >> next: anInteger putAll: aCollection startingAt: startIndex [
	"Optimized for ByteArrays"
	aCollection class == ByteArray 
		ifTrue:[^super next: anInteger putAll: aCollection asString startingAt: startIndex].
	^super next: anInteger putAll: aCollection startingAt: startIndex
]

{ #category : #accessing }
RWBinaryOrTextStream >> nextPut: charOrByte [

	^super nextPut: charOrByte asCharacter
]

{ #category : #writing }
RWBinaryOrTextStream >> nextPutAll: aCollection [
	"Optimized for ByteArrays"
	aCollection class == ByteArray 
		ifTrue:[^super nextPutAll: aCollection asString].
	^super nextPutAll: aCollection
]

{ #category : #accessing }
RWBinaryOrTextStream >> peekLast [
	"Return that item just put at the end of the stream"

	^ position > 0 
		ifTrue: [self isBinary
			ifTrue: [(collection at: position) asInteger]
			ifFalse: [(collection at: position) asCharacter]]
		ifFalse: [nil]
]

{ #category : #accessing }
RWBinaryOrTextStream >> readInto: aCollection startingAt: startIndex count: n [
	"Read n objects into the given collection. 
	Return number of elements that have been read."
	"Overriden for efficiency"
	| max |
	max := (readLimit - position) min: n.
	aCollection 
		replaceFrom: startIndex 
		to: startIndex+max-1
		with: collection
		startingAt: position+1.
	position := position + max.
	^max
]

{ #category : #positioning }
RWBinaryOrTextStream >> reset [
	"Set the receiver's position to the beginning of the sequence of objects."

	super reset.
	isBinary ifNil: [isBinary := false].
	collection class == ByteArray ifTrue: ["Store as String and convert as needed."
		collection := collection asString.
		isBinary := true].

]

{ #category : #'properties-setting' }
RWBinaryOrTextStream >> setFileTypeToObject [
	"do nothing.  We don't have a file type"
]

{ #category : #accessing }
RWBinaryOrTextStream >> text [
	isBinary := false
]

{ #category : #accessing }
RWBinaryOrTextStream >> upTo: anObject [
	"fast version using indexOf:"

	| start end |
	isBinary
		ifTrue: [ anObject isInteger ifFalse: [ ^self upToEnd ] ]
		ifFalse: [ anObject isCharacter ifFalse: [ ^self upToEnd ] ].
	start := position + 1.
	end := collection indexOf: anObject asCharacter startingAt: start.
	"not present--return rest of the collection"	
	(end = 0 or: [end > readLimit]) ifTrue: [ ^self upToEnd ].
	"skip to the end and return the data passed over"
	position := end.
	^((isBinary ifTrue: [ ByteArray ] ifFalse: [ String ]) new: end - start)
		replaceFrom: 1
		to: end - start
		with: collection
		startingAt: start
]

{ #category : #accessing }
RWBinaryOrTextStream >> upToEnd [
	"Must override to get class right."
	| newArray |
	newArray := (isBinary ifTrue: [ByteArray] ifFalse: [ByteString]) new: self size - self position.
	^ self nextInto: newArray
]
