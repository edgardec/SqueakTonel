Class {
	#name : #MockSocketStream,
	#superclass : #Stream,
	#instVars : [
		'binary',
		'atEnd',
		'inStream',
		'outStream'
	],
	#category : #'NetworkTests-Kernel'
}

{ #category : #'instance creation' }
MockSocketStream class >> on: socket [
	^self basicNew initialize
]

{ #category : #configuration }
MockSocketStream >> ascii [

	binary := false.
	self refreshStreams.
]

{ #category : #testing }
MockSocketStream >> atEnd [
	^self inStream atEnd.
]

{ #category : #accessing }
MockSocketStream >> atEnd: aBoolean [
	atEnd := aBoolean.
]

{ #category : #configuration }
MockSocketStream >> binary [

	binary := true.
	self refreshStreams.
]

{ #category : #'stream out' }
MockSocketStream >> cr [
	self nextPutAll: String cr
]

{ #category : #'stream out' }
MockSocketStream >> crlf [
	self nextPutAll: String crlf
]

{ #category : #accessing }
MockSocketStream >> inStream [
	^inStream
]

{ #category : #'initialize-release' }
MockSocketStream >> initialize [
	binary := false.
	self resetInStream.
	self resetOutStream.
]

{ #category : #'stream out' }
MockSocketStream >> next: n putAll: aCollection startingAt: startIndex [

	^ self outStream next: n putAll: aCollection startingAt: startIndex

]

{ #category : #'stream in' }
MockSocketStream >> nextLine [
	^self nextLineCrLf
]

{ #category : #'stream in' }
MockSocketStream >> nextLineCrLf [
	^(self upToAll: String crlf).
]

{ #category : #'stream out' }
MockSocketStream >> nextPut: anObject [

	^ self outStream nextPut: anObject
]

{ #category : #'stream out' }
MockSocketStream >> nextPutAll: aCollection [ 
	^ self outStream nextPutAll: aCollection.
]

{ #category : #'stream out' }
MockSocketStream >> nextPutAllFlush: aCollection [ 
	^ self outStream nextPutAll: aCollection.
]

{ #category : #accessing }
MockSocketStream >> outStream [
	^outStream
]

{ #category : #'initialize-release' }
MockSocketStream >> refreshStreams [

	binary = self inStream isBinary ifFalse: [self resetInStream].
	binary = self outStream isBinary ifFalse: [self resetOutStream].

]

{ #category : #'stream in' }
MockSocketStream >> resetInStream [
	inStream := self streamSpecies new writeStream.
]

{ #category : #'stream out' }
MockSocketStream >> resetOutStream [
	outStream := self streamSpecies new writeStream.
]

{ #category : #'stream out' }
MockSocketStream >> sendCommand: aString [
	self outStream
		nextPutAll: aString;
		nextPutAll: String crlf.
]

{ #category : #'stream out' }
MockSocketStream >> space [
	self nextPut: Character space
]

{ #category : #'initialize-release' }
MockSocketStream >> streamSpecies [

	^ binary ifTrue: [ByteArray] ifFalse: [ByteString].

]

{ #category : #'stream in' }
MockSocketStream >> upToAll: delims [
	^self inStream upToAll: delims.
]
