"
A network connection that passes objects instead of bytes.  The objects are encoded with SmartRefStreams.


"
Class {
	#name : #ArbitraryObjectSocket,
	#superclass : #ObjectSocket,
	#instVars : [
		'encodingOfLastEncodedObject',
		'lastEncodedObject'
	],
	#category : #'Nebraska-Network-ObjectSocket'
}

{ #category : #private }
ArbitraryObjectSocket >> encodeObject: object  into: buffer  startingAt: startIndex [
	"encode the given object into the given buffer"
	| encoded |
	encoded := self smartRefStreamEncode: object.
	buffer putInteger32: encoded size at: startIndex.
	buffer replaceFrom: startIndex+4 to: startIndex+4+(encoded size)-1 with: encoded.

]

{ #category : #private }
ArbitraryObjectSocket >> inBufSize [

	inBuf ifNil: [^0].
	^inBufLastIndex - inBufIndex + 1
]

{ #category : #private }
ArbitraryObjectSocket >> nextObjectLength [
	"read the next object length from inBuf.  Returns nil if less than 4 bytes are available in inBuf"
	self inBufSize < 4 ifTrue: [ ^nil ].

	^inBuf getInteger32: inBufIndex
]

{ #category : #private }
ArbitraryObjectSocket >> processInput [
	"recieve some data"
	| inObjectData |

	[ socket dataAvailable ] whileTrue: [
		"read as much data as possible"
		self addToInBuf: socket receiveAvailableData.


		"decode as many objects as possible"
		[self nextObjectLength ~~ nil and: [ self nextObjectLength <= (self inBufSize + 4) ]] whileTrue: [
			"a new object has arrived"
			inObjectData := inBuf copyFrom: (inBufIndex + 4) to: (inBufIndex + 3 + self 	nextObjectLength).
			inBufIndex := inBufIndex + 4 + self nextObjectLength.
	
			inObjects addLast: (RWBinaryOrTextStream with: inObjectData) reset fileInObjectAndCode ].

		self shrinkInBuf. ].
]

{ #category : #private }
ArbitraryObjectSocket >> smartRefStreamEncode: anObject [
	| encodingStream |
	"encode an object using SmartRefStream"

	anObject == lastEncodedObject ifTrue: [
		^encodingOfLastEncodedObject ].


	encodingStream := RWBinaryOrTextStream on: ''.
	encodingStream reset.
	(SmartRefStream on: encodingStream) nextPut: anObject.
	
	lastEncodedObject := anObject.
	encodingOfLastEncodedObject := encodingStream contents.

	^encodingOfLastEncodedObject
]

{ #category : #private }
ArbitraryObjectSocket >> spaceToEncode: anObject [
	"return the number of characters needed to encode the given object"
	^ 4 + (self smartRefStreamEncode: anObject) size
]
