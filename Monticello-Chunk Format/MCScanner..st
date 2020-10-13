Class {
	#name : #MCScanner,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Monticello-Chunk Format'
}

{ #category : #'instance creation' }
MCScanner class >> scan: aStream [
	^ (self new stream: aStream) next
]

{ #category : #'instance creation' }
MCScanner class >> scanTokens: aString [
	"compatibility"
	^{ self scan: aString readStream }
]

{ #category : #scanning }
MCScanner >> next [
	| c |
	stream skipSeparators.
	(c := stream peek) == $# ifTrue: [c := stream next; peek].
	c == $' ifTrue: [^ self nextString].
	c == $( ifTrue: [^ self nextArray].
	c isAlphaNumeric ifTrue: [^ self nextSymbol].
	self error: 'Unknown token type'
]

{ #category : #scanning }
MCScanner >> nextArray [
	stream next. "("
	^ Array streamContents:
		[:s |
		[stream skipSeparators.
		(stream peek == $)) or: [stream atEnd]] whileFalse: [s nextPut: self next].
		stream next == $) ifFalse: [self error: 'Unclosed array']]
]

{ #category : #scanning }
MCScanner >> nextString [
	^ stream nextDelimited: $'
]

{ #category : #scanning }
MCScanner >> nextSymbol [
	^ (String streamContents:
		[:s |
		[stream peek isAlphaNumeric] whileTrue: [s nextPut: stream next]]) asSymbol
			
]

{ #category : #accessing }
MCScanner >> stream: aStream [
	stream := aStream
]
