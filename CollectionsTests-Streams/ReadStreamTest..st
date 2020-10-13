"
I am an SUnit test for ReadStream.
I have no test fixtures.
"
Class {
	#name : #ReadStreamTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Streams'
}

{ #category : #accessing }
ReadStreamTest >> classUnderTest [
	^ ReadStream
]

{ #category : #'accessing - defaults' }
ReadStreamTest >> emptyStream [
	^ ReadStream on: String new.
]

{ #category : #helpers }
ReadStreamTest >> streamOn: aCollection [
	^ self classUnderTest on: aCollection
]

{ #category : #helpers }
ReadStreamTest >> streamOn: collection upToAll: subcollection [

	^ (self streamOn: collection) upToAll: subcollection
]

{ #category : #helpers }
ReadStreamTest >> streamOn: collection upToAll: subcollection1 upToAll: subcollection2 [

	^(self streamOn: collection)
		upToAll: subcollection1;
		upToAll: subcollection2
]

{ #category : #'accessing - defaults' }
ReadStreamTest >> streamOnArray [
	^ ReadStream on: (Array with: 1 with: #(a b c) with: false).
]

{ #category : #'accessing - defaults' }
ReadStreamTest >> streamOnString [
	^ ReadStream on: 'abcde'.
]

{ #category : #'tests - testing' }
ReadStreamTest >> testAtEnd [
	| stream |
	self assert: self emptyStream atEnd.

	stream := self streamOnArray.
	self deny: stream atEnd.
	stream next: 3.
	self assert: stream atEnd.
]

{ #category : #'tests - back' }
ReadStreamTest >> testBack [
	"Test the new implemtation of the method back."
	|stream|
	stream := self streamOn: 'abc'.
	stream next: 2.
	self assert: stream back = $b.
]

{ #category : #'tests - back' }
ReadStreamTest >> testBackOnPosition1 [
	"Test the new implemtation of the method back."
	|stream|
	stream := self streamOn: 'abc'.
	stream next.
	self assert: stream back = $a.
]

{ #category : #'tests - positioning' }
ReadStreamTest >> testBackUpTo1 [
	|stream|
	stream := ReadStream on: 'abcdabg'.
	stream setToEnd.
	self assert: (stream backUpTo: 'ab').
	self assert: stream peek = $g
]

{ #category : #'tests - positioning' }
ReadStreamTest >> testBackUpToEmptyPattern1 [
	"This test represents the current behavior which is not clearly defined and could be revised."
	|stream|
	stream := ReadStream on: 'abcdabg'.
	stream setToEnd.
	self should: [stream backUpTo: ''] raise: Error.
]

{ #category : #'tests - positioning' }
ReadStreamTest >> testBackUpToPatternNotFound1 [
	|stream|
	stream := ReadStream on: 'abcdabg'.
	stream setToEnd.
	self deny: (stream backUpTo: 'zz').
	self assert: stream position = 0
]

{ #category : #'tests - enumerating' }
ReadStreamTest >> testCollect [
	
	| stream |
	stream := (self streamOn: #(1 2 3 4)) collect: [:num | 2 * num].
	self
		assert: (stream next: 4) asArray = #(2 4 6 8);
		assert: stream atEnd;
		assert: stream next isNil.
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testContents [
	| stream |
	self assert: self emptyStream contents = ''.
	
	stream := self streamOnArray.
	self assert: stream contents = #(1 #(a b c) false).
	stream position: 3.
	self assert: stream contents = #(1 #(a b c) false).
	
	stream := self streamOnString.
	self assert: stream contents = 'abcde'.
	stream setToEnd.
	self assert: stream contents = 'abcde'.
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testContents2 [
	"From ANSI Smalltalk Standard draft 1.9: 
	
		it is unspecified whether or not the returned collection [using #contents] is the same object as the backing store collection. However, if the returned collection is not the same object as the stream backing store collection then the class of the returned collection is the same class as would be returned if the message #select: was sent to the backing store collection."
		
	"In Squeak, there is #species to know what class should be used on copy, selection..."
	| interval stream streamContents |
	interval := 1 to: 32.
	stream := self streamOn: interval.
	streamContents := stream contents.
	
	(streamContents == interval)
		ifFalse: [self assert: streamContents class = Interval new species]
]

{ #category : #'tests - enumerating' }
ReadStreamTest >> testDo [
	self emptyStream do: [:value | self fail]
]

{ #category : #'tests - enumerating' }
ReadStreamTest >> testDo2 [
	| stream string |
	stream := self streamOnArray.
	string := String new.
	
	stream do: [:value | string := string, ' ', value asString].
	
	self assert: string = (' ', 1 asString, ' ', #(a b c) asString, ' ', false asString)
]

{ #category : #'tests - enumerating' }
ReadStreamTest >> testFlatten [
	
	| stream |
	stream := (self streamOn: {3 .4 .{2 .4 .{'hi'} .'ho'}}) flatten.
	self assert: (stream next: 6) asArray = {3 .4 .2 .4 .'hi' .'ho'}.
]

{ #category : #'tests - enumerating' }
ReadStreamTest >> testFlatten2 [
	
	| stream |
	stream := (self streamOn: {3 .4 . self streamOn: {2 .4 .{'hi'} .'ho'} }) flatten.
	self assert: (stream next: 6) asArray = {3 .4 .2 .4 .'hi' .'ho'}.
]

{ #category : #'tests - enumerating' }
ReadStreamTest >> testGather [
	
	| stream |
	stream := (self streamOn: #(1 2 3 4)) gather: [:num | 1 to: num].
	self assert: stream upToEnd asArray = #(1 1 2 1 2 3 1 2 3 4).
]

{ #category : #'tests - testing' }
ReadStreamTest >> testIsEmpty [
	| stream |
	self assert: self emptyStream isEmpty.
	
	stream := self streamOnArray.
	self deny: stream isEmpty.
	stream skip: 3.
	self deny: stream isEmpty.
	
	stream := self streamOnString.
	self deny: stream isEmpty.
	stream next;next;next.
	self deny: stream isEmpty.
	stream setToEnd.
	self deny: stream isEmpty.
]

{ #category : #'tests - testing' }
ReadStreamTest >> testMatch [

	| stream |
	stream := ReadStream on: 'foobarbaz'.
	self assert: (stream match: 'foo').
	self assert: stream position = 3.
	self assert: (stream match: 'baz').
	self assert: stream position = 9.
	self assert: stream atEnd.
	self assert: (stream match: '').
	self deny: (stream match: 'foo').
	stream reset.
	self deny: (stream match: '1').
	self assert: stream atEnd
]

{ #category : #'tests - instance creation' }
ReadStreamTest >> testNew [
	self should: [self classUnderTest new] raise: Error.
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testNext [
	|stream|

	stream := self streamOnArray.
	self assert: stream next = 1.
	self assert: stream next = #(a b c).
	self assert: stream next = false.
	
	stream := self streamOnString.
	self assert: stream next = $a.
	self assert: stream next = $b.
	self assert: stream next = $c.
	self assert: stream next = $d.
	self assert: stream next = $e.
	
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testNextLine [
	| lines text stream |
	lines := #('line 1' ' and line 2' '' 'fourth').
	text := lines first , String cr , lines second , String crlf , lines third , String lf , lines fourth.
	stream := text readStream.
	lines do: [:e |
		self assert: stream nextLine = e].
	self assert: stream nextLine = nil
]

{ #category : #'tests - testing' }
ReadStreamTest >> testNextMatchFor [
	| stream |
	stream := self streamOnArray.
	self assert: (stream nextMatchFor: 1).
	self assert: (stream nextMatchFor: #(a b c)).
	self assert: (stream nextMatchFor: false).
	
	stream := self streamOnArray.
	self deny: (stream nextMatchFor: false).
	self assert: (stream nextMatchFor: #(a b c)).
	self assert: (stream nextMatchFor: false).

]

{ #category : #'tests - accessing' }
ReadStreamTest >> testNextSatisfy [

	| stream |
	stream := self streamOn: #(1 2 3 4).
	self assert: 2 = (stream nextSatisfy: [:ea | ea even]).
	self assert: 4 = (stream nextSatisfy: [:ea | ea even]).
	self should: [stream nextSatisfy: [:ea | ea even]] raise: Error.
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testNexts [
	self assert: (self emptyStream next: 0) isEmpty.
	self assert: (self streamOnArray next: 0) isEmpty.
	self assert: (self streamOnArray next: 1) = #(1).
	self assert: (self streamOnArray next: 2) = #(1 #(a b c)).
	self assert: (self streamOnArray next: 3) = #(1 #(a b c) false).
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testNexts2 [

	| stream |
	stream := self streamOnArray.
	self assert: (stream next: 2) = #(1 #(a b c)).
	self assert: (stream next: 1) = #(false).
]

{ #category : #'tests - instance creation' }
ReadStreamTest >> testOn [
	self assert: (self streamOn: '  ') position isZero.
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testOnFromTo [
	self assert: (ReadStream
						on: (String withAll: ((0 to: 255) collect: [:n| n asCharacter]))
						from: $A asInteger + 1
						to: $Z asInteger + 1)
					contents
		equals: (String withAll: ($A to: $Z))
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testPeek [
	| stream |
	stream := self streamOnArray.
	
	self assert: stream peek = 1.
	self deny: stream peek = #(a b c).
	self deny: stream peek = false.
	
	stream next.
	
	self deny: stream peek = 1.
	self assert: stream peek = #(a b c).
	self deny: stream peek = false.
	
	stream next.
	
	self deny: stream peek = 1.
	self deny: stream peek = #(a b c).
	self assert: stream peek = false.
	
	stream next.
	
	"In ANSI Smalltalk Standard Draft, it is said that nil will return nil at the end when using #peek."
	self assert: stream peek isNil.
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testPeek2 [
	| stream |
	stream := self streamOn: #(nil nil nil).
	
	self assert: stream peek isNil.
	stream next.
	self assert: stream peek isNil.
	stream next.
	self assert: stream peek isNil.
	stream next.
	
	"Yes, #peek answers nil when there is no more element to read."
	self assert: stream peek isNil.
]

{ #category : #'tests - testing' }
ReadStreamTest >> testPeekFor [
	| stream |

	stream := self streamOnArray.
	self assert: (stream peekFor: 1).
	self assert: (stream peekFor: #(a b c)).
	self assert: (stream peekFor: false).

	stream := self streamOnArray.
	self deny: (stream peekFor: #(a b c)).
	self deny: (stream peekFor: false).
	self assert: (stream peekFor: 1).

	self deny: (stream peekFor: 1).
	self deny: (stream peekFor: false).
	self assert: (stream peekFor: #(a b c)).
	
	self deny: (stream peekFor: 1).
	self deny: (stream peekFor: #(a b c)).
	self assert: (stream peekFor: false).
	
	self assert: (stream atEnd).
	self deny: (stream peekFor: nil).
	self deny: (stream peekFor: 1).
	self deny: (stream peekFor: #(a b c)).
	self deny: (stream peekFor: false).
]

{ #category : #'tests - testing' }
ReadStreamTest >> testPeekFor2 [
	| stream negative number |

	stream := self streamOn: '- 145'.
	negative := stream peekFor: $-.
	stream peekFor: Character space.
	number := stream next: 3.
	self assert: negative.
	self assert: number = '145'.

	stream := self streamOn: '-145'.
	negative := stream peekFor: $-.
	stream peekFor: Character space.
	number := stream next: 3.
	self assert: negative.
	self assert: number = '145'.
	
	stream := self streamOn: ' 145'.
	negative := stream peekFor: $-.
	stream peekFor: Character space.
	number := stream next: 3.
	self deny: negative.
	self assert: number = '145'.
	
	stream := self streamOn: '145'.
	negative := stream peekFor: $-.
	stream peekFor: Character space.
	number := stream next: 3.
	self deny: negative.
	self assert: number = '145'.
]

{ #category : #'tests - positioning' }
ReadStreamTest >> testPosition [
	| stream |
	self assert: self emptyStream position isZero.
	
	stream := self streamOnArray.
	self assert: stream position = 0.
	stream next.
	self assert: stream position = 1.
	stream next.
	self assert: stream position = 2.
	stream next.
	self assert: stream position = 3.
	stream next.
	self assert: stream position = 3.
	stream next.
	self assert: stream position = 3.
]

{ #category : #'tests - positioning' }
ReadStreamTest >> testPositionOfSubCollection [

	| stream |
	stream := self streamOn: 'xyz'.
	#(
		'' 1
		'q' 0
		'x' 1
		'y' 2
		'z' 3
		'xz' 0
		'xy' 1
		'yz' 2
		'xyz' 1) pairsDo: [ :pattern :expectedPosition |
			self
				assert: expectedPosition equals: (stream positionOfSubCollection: pattern);
				assert: 0 equals: stream position ]
]

{ #category : #'tests - enumerating' }
ReadStreamTest >> testReject [
	
	| stream |
	stream := (self streamOn: #(1 2 3 4)) reject: [:num | num even].
	self assert: (stream next: 2) asArray = #(1 3).
]

{ #category : #'tests - positioning' }
ReadStreamTest >> testReset [
	| stream |

	stream := self emptyStream.
	stream reset.
	self assert: stream position = 0.
	
	stream := self streamOnArray.
	stream reset.
	self assert: stream position = 0.
	self deny: stream atEnd.
	stream position: 3.
	self assert: stream atEnd.
	stream reset.
	self assert: stream position = 0.
]

{ #category : #'tests - enumerating' }
ReadStreamTest >> testSelect [
	
	| stream |
	stream := (self streamOn: #(1 2 3 4)) select: [:num | num even].
	self assert: (stream next: 2) asArray = #(2 4).
]

{ #category : #'tests - enumerating' }
ReadStreamTest >> testSelectCollect [

	| stream |
	stream := ((self streamOn: #(1 2 3 4))
		select: [:num | num even])
		collect: [:num | 2 * num].
	self assert: (stream next: 2) asArray = #(4 8).
]

{ #category : #'tests - enumerating' }
ReadStreamTest >> testSelectThenCollect [

	| stream |
	stream := (self streamOn: #(1 2 3 4))
		select: [:num | num even]
		thenCollect: [:num | 2 * num].
	self assert: (stream next: 2) asArray = #(4 8).
]

{ #category : #'tests - positioning' }
ReadStreamTest >> testSetPosition [
	| stream |

	stream := self emptyStream.
	self should: [stream position: -2] raise: Error.
	stream position: 0 "should not fail".

	stream := self streamOnArray.
	self should: [stream position: -1] raise: Error.
	"We can iterate over valid positions in the stream."
	stream position: 0.
	stream position: 1.
	stream position: 2.

	"According to ANSI Smalltalk Standard 1.9 Draft, the following should be tested too:
	self should: [stream position: 3] raise: Error.
	
	However, I don't see the point of raising an error when positioning at the end.
	
	I prefer testing the absence of error:
	"
	stream position: 3.
	self should: [stream position: 4] raise: Error.
]

{ #category : #'tests - positioning' }
ReadStreamTest >> testSetToEnd [
	| stream |

	stream := self emptyStream.
	stream setToEnd.
	self assert: stream atEnd.
	
	stream := self streamOnArray.
	stream setToEnd.
	self assert: stream atEnd.
	stream position: 1.
	self deny: stream atEnd.
	stream setToEnd.
	self assert: stream atEnd.
]

{ #category : #'tests - positionning' }
ReadStreamTest >> testSkipTo [
	| stream |
	stream := self emptyStream.
	self deny: (stream skipTo: nil).
	
	stream := self streamOnArray.
	self deny: stream atEnd.
	self deny: (stream skipTo: nil).
	self assert: stream atEnd.
	
	stream := self streamOnArray.
	self assert: stream peek = 1.
	self assert: (stream skipTo: #(a b c)).
	self assert: stream peek = false.
	self assert: (stream skipTo: false).
	self assert: stream atEnd.
]

{ #category : #'tests - positionning' }
ReadStreamTest >> testSkipTo2 [
	| stream |
	
	stream := self streamOnString.
	self assert: (stream skipTo: $b).
	self assert: stream peek = $c.
	self assert: (stream skipTo: $d).
	self assert: stream peek = $e.
	self assert: (stream skipTo: $e).
	self assert: stream atEnd.
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testUpTo [
	| returnValue stream |
	returnValue := (self emptyStream upTo: nil).
	self assert: returnValue isCollection.
	self assert: returnValue isEmpty.
	
	stream := self streamOnArray.
	returnValue := stream upTo: #(a b c).
	self assert: returnValue = #(1).
	self assert: stream peek = false.
	
	stream := self streamOnArray.
	returnValue := stream upTo: true.
	self assert: returnValue = #(1 #(a b c) false).
	self assert: stream atEnd.
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testUpTo2 [
	| returnValue stream |

	stream := self streamOnString.
	returnValue := stream upTo: $d.
	self assert: returnValue = 'abc'.
	self assert: stream peek = $e.
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testUpTo3 [
	| stream string |
	string := 'XYZabcdUVW'.
	stream := ReadStream on: string from: (string indexOf: $a) to: (string indexOf: $d).
	self assert: stream upToEnd = 'abcd'.
	self assert: stream atEnd.
	stream := ReadStream on: string from: (string indexOf: $a) to: (string indexOf: $d).
	self assert: (stream upTo: $c) = 'ab'.
	self assert: stream next = $d.
	stream := ReadStream on: string from: (string indexOf: $a) to: (string indexOf: $d).
	self assert: (stream upTo: $e) = 'abcd'.
	self assert: stream atEnd.
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testUpToAll [

	self assert: (self streamOn: 'abcdefgh' upToAll: 'cd') = 'ab'.
	self assert: (self streamOn: 'abcdefgh' upToAll: 'cd' upToAll: 'gh') = 'ef'.

	self assert: (self streamOn: '' upToAll: '') = ''.

	self assert: (self streamOn: 'a' upToAll: '') = ''.
	self assert: (self streamOn: 'a' upToAll: 'a') = ''.
	self assert: (self streamOn: 'a' upToAll: 'b') = 'a'.

	self assert: (self streamOn: 'ab' upToAll: '') = ''.
	self assert: (self streamOn: 'ab' upToAll: 'a') = ''.
	self assert: (self streamOn: 'ab' upToAll: 'b') = 'a'.
	self assert: (self streamOn: 'ab' upToAll: 'c') = 'ab'.
	self assert: (self streamOn: 'ab' upToAll: 'ab') = ''.

	self assert: (self streamOn: 'abc' upToAll: '') = ''.
	self assert: (self streamOn: 'abc' upToAll: 'a') = ''.
	self assert: (self streamOn: 'abc' upToAll: 'b') = 'a'.
	self assert: (self streamOn: 'abc' upToAll: 'c') = 'ab'.
	self assert: (self streamOn: 'abc' upToAll: 'd') = 'abc'.
	self assert: (self streamOn: 'abc' upToAll: 'ab') = ''.
	self assert: (self streamOn: 'abc' upToAll: 'bc') = 'a'.
	self assert: (self streamOn: 'abc' upToAll: 'cd') = 'abc'.

]

{ #category : #'tests - accessing' }
ReadStreamTest >> testUpToAll2 [
	| string stream array |
	string := 'aababcabcd'.
	stream := self streamOn: string.
	self assert: (stream upToAll: 'a') = ''.
	self assert: (stream upToEnd) = 'ababcabcd'.
	stream := self streamOn: string.
	self assert: (stream upToAll: 'ab') = 'a'.
	self assert: (stream upToEnd) = 'abcabcd'.
	stream := self streamOn: string.
	self assert: (stream upToAll: 'abc') = 'aab'.
	self assert: (stream upToEnd) = 'abcd'.
	stream := self streamOn: string.
	self assert: (stream upToAll: 'abcd') = 'aababc'.
	self assert: (stream upToEnd) = ''.
	stream := self streamOn: string.
	self assert: (stream upToAll: 'abe') = 'aababcabcd'.
	self assert: (stream upToEnd) = ''.
	
	array := #(1 1 2 1 2 3 nil 1 2 3 4).
	stream := self streamOn: array.
	self assert: (stream upToAll: #(1)) = #().
	self assert: (stream upToEnd) = #(1 2 1 2 3 nil 1 2 3 4).
	stream := self streamOn: array.
	self assert: (stream upToAll: #(1 2)) = #(1).
	self assert: (stream upToEnd) = #(1 2 3 nil 1 2 3 4).
	stream := self streamOn: array.
	self assert: (stream upToAll: #(1 2 3)) = #(1 1 2).
	self assert: (stream upToEnd) = #(nil 1 2 3 4).
	stream := self streamOn: array.
	self assert: (stream upToAll: #(1 2 3 4)) = #(1 1 2 1 2 3 nil).
	self assert: (stream upToEnd) = #().
	stream := self streamOn: array.
	self assert: (stream upToAll: #(1 2 5)) = array.
	self assert: (stream upToEnd) = #().
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testUpToAnyOf [
	| stream |
	stream := 'abcde' readStream.
	self assert: (stream upToAnyOf: String crlf) = 'abcde'.
	self assert: stream atEnd.
	
	stream := 'abcde' readStream.
	self assert: (stream upToAnyOf: 'dc') = 'ab'.
	self assert: stream upToEnd = 'de'.
	
	stream := #( 1 2 nil true false 10 ) readStream.
	self assert: (stream upToAnyOf: #(100 1000)) = #( 1 2 nil true false 10 ).
	self assert: stream atEnd.
	
	stream := #( 1 2 nil true false 10 ) readStream.
	self assert: (stream upToAnyOf: #( true false )) = #( 1 2 nil ).
	self assert: stream upToEnd = #( false 10 ).
]

{ #category : #'tests - accessing' }
ReadStreamTest >> testUpToAnyOfDo [
	| stream found |
	found := false.
	stream := 'abcde' readStream.
	self assert: (stream upToAnyOf: String crlf do: [:char | found := true]) = 'abcde'.
	self assert: stream atEnd.
	self deny: found.
	
	found := Object new.
	stream := 'abcde' readStream.
	self assert: (stream upToAnyOf: 'dc' do: [:char | found := char]) = 'ab'.
	self assert: found = $c.
	self assert: stream upToEnd = 'de'.
	
	found := false.
	stream := #( 1 2 nil true false 10 ) readStream.
	self assert: (stream upToAnyOf: #(100 1000) do: [:anObject | found := true]) = #( 1 2 nil true false 10 ).
	self deny: found.
	self assert: stream atEnd.
	
	found := Object new.
	stream := #( 1 2 nil true false 10 ) readStream.
	self assert: (stream upToAnyOf: #( true false ) do: [:anObject | found := anObject]) = #( 1 2 nil ).
	self assert: found = true.
	self assert: stream upToEnd = #( false 10 ).
]
