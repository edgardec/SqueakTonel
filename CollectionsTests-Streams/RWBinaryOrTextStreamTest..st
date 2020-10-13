Class {
	#name : #RWBinaryOrTextStreamTest,
	#superclass : #TestCase,
	#category : #'CollectionsTests-Streams'
}

{ #category : #failures }
RWBinaryOrTextStreamTest >> expectedFailures [

	^#(
		testExisting "This is more like a request for new behavior than a bug."
	)
]

{ #category : #tests }
RWBinaryOrTextStreamTest >> testExisting [

	| string stream |
	
	string := 'hello'.
	
	stream := RWBinaryOrTextStream on: string.
	self assert: stream contents = string.

	stream := RWBinaryOrTextStream on: string.
	stream setToEnd.
	self assert: stream position = string size.

]

{ #category : #tests }
RWBinaryOrTextStreamTest >> testNextPutAll [
	
	| stream |
	stream := RWBinaryOrTextStream on: String new.
	stream nextPutAll: 'hello'.
	self assert: stream contents = 'hello'.

	stream := RWBinaryOrTextStream on: String new.
	stream nextPutAll: 'hello' asArray.
	self assert: stream contents = 'hello'.

	stream := RWBinaryOrTextStream on: String new.
	stream nextPutAll: 'hello' asByteArray.
	self assert: stream contents = 'hello'

]

{ #category : #tests }
RWBinaryOrTextStreamTest >> testPeekBack [
	
	| stream |
	stream := RWBinaryOrTextStream on: String new.
	stream nextPutAll: 'world'.
	self assert: $l equals: stream peekBack.
	stream binary.
	stream nextPutAll: #[98 105 110 97 114 121]..
	self assert: 114 equals: stream peekBack.
]

{ #category : #tests }
RWBinaryOrTextStreamTest >> testPeekLast [
	
	| stream |
	stream := RWBinaryOrTextStream on: String new.
	stream nextPutAll: 'world'.
	self assert: $d equals: stream peekLast.
	stream binary.
	stream nextPutAll: #[98 105 110 97 114 121].
	self assert: 121 equals: stream peekLast.
	stream reset.
	self assert: nil equals: stream peekLast.
]

{ #category : #tests }
RWBinaryOrTextStreamTest >> testUpTo [

	| stream |
	stream := RWBinaryOrTextStream on: String new.
	stream nextPutAll: 'world'; reset.
	self assert: (stream upTo: $r) = 'wo'.
	self assert: stream next = $l.
	
	stream := RWBinaryOrTextStream on: String new.
	stream nextPutAll: 'hello'; reset.
	self assert: (stream upTo: $x) = 'hello'.
	self assert: stream atEnd.
	
	stream := RWBinaryOrTextStream on: String new.
	stream binary.
	stream nextPutAll: 'world'; reset.
	self assert: (stream upTo: $r asciiValue) = 'wo' asByteArray.
	self assert: stream next = $l asciiValue.
	
	stream := RWBinaryOrTextStream on: String new.
	stream binary.
	stream nextPutAll: 'hello'; reset.
	self assert: (stream upTo: $x asciiValue) = 'hello' asByteArray.
	self assert: stream atEnd.

]

{ #category : #tests }
RWBinaryOrTextStreamTest >> testUpToEnd [
	
	| stream |
	stream := RWBinaryOrTextStream on: String new.
	stream nextPutAll: 'world'; reset.
	self assert: stream upToEnd = 'world'.
	self assert: stream atEnd.

	self assert: stream upToEnd = ''.
	self assert: stream atEnd.
	
	stream reset.
	stream upTo: $r.
	self assert: stream upToEnd = 'ld'.
	self assert: stream atEnd.
	
	stream := RWBinaryOrTextStream on: String new.
	stream binary.
	stream nextPutAll: 'world'; reset.
	self assert: stream upToEnd = 'world' asByteArray.
	self assert: stream atEnd.

	self assert: stream upToEnd = ByteArray new.
	self assert: stream atEnd.
	
	stream reset.
	stream upTo: $r asciiValue.
	self assert: stream upToEnd = 'ld' asByteArray.
	self assert: stream atEnd
]
