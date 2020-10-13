"
This is a socket which exchanges medium-level packets instead of low-level bytes.  This class is abstract; see the subclasses for particular kinds of medium-level packets which can be used.
"
Class {
	#name : #ObjectSocket,
	#superclass : #Stream,
	#instVars : [
		'socket',
		'outBuf',
		'outBufIndex',
		'outBufSize',
		'inBuf',
		'inBufIndex',
		'inBufLastIndex',
		'outObjects',
		'inObjects'
	],
	#category : #'Nebraska-Network-ObjectSocket'
}

{ #category : #'as yet unclassified' }
ObjectSocket class >> on: aSocket [

	^self basicNew initialize: aSocket
]

{ #category : #'encoding\/decoding' }
ObjectSocket >> addToInBuf: aString [

	| newAlloc |
	newAlloc := aString size * 2 max: 8000.
	inBuf ifNil: [
		inBuf := String new: newAlloc.
		inBufIndex := 1.
		inBufLastIndex := 0.
	].
	aString size > (inBuf size - inBufLastIndex) ifTrue: [
		inBuf := inBuf , (String new: newAlloc)
	].
	inBuf 
		replaceFrom: inBufLastIndex + 1 
		to: inBufLastIndex + aString size
		with: aString 
		startingAt: 1.
	inBufLastIndex := inBufLastIndex + aString size.

]

{ #category : #'as yet unclassified' }
ObjectSocket >> destroy [
	socket destroy.
	socket := nil.
]

{ #category : #'private-initialization' }
ObjectSocket >> initialize: aSocket [
	socket := aSocket.
	inBuf := String new: 1000.
	inBufIndex := 1.
	inBufLastIndex := 0.

	outBuf := nil.

	inObjects := OrderedCollection new.
	outObjects := OrderedCollection new.

]

{ #category : #'as yet unclassified' }
ObjectSocket >> isConnected [

	^socket notNil and: [socket isConnected]
]

{ #category : #'stream protocol' }
ObjectSocket >> next [
	^inObjects removeFirst	
]

{ #category : #'stream protocol' }
ObjectSocket >> nextOrNil [
	inObjects isEmpty
		ifTrue: [ ^nil ]
		ifFalse: [ ^inObjects removeFirst ]
]

{ #category : #'stream protocol' }
ObjectSocket >> nextPut: anObject [
	^outObjects addLast: anObject
]

{ #category : #'as yet unclassified' }
ObjectSocket >> processIO [
	"do some as much network IO as possible"

	self processOutput.
	self processInput.
]

{ #category : #'encoding\/decoding' }
ObjectSocket >> processOutput [
	"loop sending data as long as there is data to send, and the socket is ready to receive more data"
	[ socket sendDone and: [ outBuf notNil or: [ outObjects isEmpty not ] ] ] whileTrue: [
		| amountSent |

		outBuf isNil ifTrue: [
			| nextSize |
			"no data in the current buffer; make a new buffer and encode some more"
			outBuf := String new: ((self spaceToEncode: outObjects first) max: 8000).
			outBufIndex := 1.
			outBufSize := 0.

			[	outObjects isEmpty not and: [
					nextSize := self spaceToEncode: outObjects first.
					nextSize <= (outBuf size - outBufSize + 1) ]
			] whileTrue: [
				self encodeObject: outObjects first into: outBuf startingAt: outBufSize+1.
				outBufSize := outBufSize + nextSize.
				outObjects removeFirst ] ].

		"at this point, the buffer definitely has data in it to send.  Send some"
		amountSent := socket sendSomeData: outBuf startIndex: outBufIndex count: (outBufSize - outBufIndex + 1).
		outBufIndex := outBufIndex + amountSent.
		outBufIndex > outBufSize ifTrue: [ outBuf := nil ]  ].


]

{ #category : #'as yet unclassified' }
ObjectSocket >> remoteAddress [

	self isConnected ifFalse: [^nil].
	^socket remoteAddress
]

{ #category : #'encoding\/decoding' }
ObjectSocket >> shrinkInBuf [

	inBuf ifNil: [^self].
	inBufLastIndex < inBufIndex ifTrue: [
		inBufLastIndex := 0.
		inBufIndex := 1.
		inBuf size > 20000 ifTrue: [inBuf := nil].	"if really big, kill it"
		^self
	].
	inBuf := inBuf copyFrom: inBufIndex to: inBufLastIndex.
	inBufLastIndex := inBuf size.
	inBufIndex := 1.


]
