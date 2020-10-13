Class {
	#name : #WriteStreamTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Streams'
}

{ #category : #'tests - character writing' }
WriteStreamTest >> testCr [
	"self debug: #testCr"
	
	| stream |
	stream := WriteStream on: 'stream' copy.
	stream cr.
	self assert: stream last = Character cr.
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testCrLf [
	"self debug: #testCrLf"
	
	| stream |
	stream := WriteStream on: 'stream' copy.
	stream crlf.
	self assert: (stream contents last: 2) = String crlf.
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testCrTab [
	"self debug: #testCrTab"
	
	| stream |
	stream := WriteStream on: 'stream' copy.
	stream crtab.
	self assert: (stream contents last: 2) = (String with: Character cr with: Character tab)
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testCrTabs [
	"self debug: #testCrTabs"
	
	| stream |
	stream := WriteStream on: 'stream' copy.
	stream crtab: 2.
	self assert: (stream contents last: 3) = (String with: Character cr with: Character tab with: Character tab)
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testEnsureASpace [
	"self debug: #testEnsureASpace"
	| stream |
	stream := WriteStream on: String new.
	stream nextPutAll: 'this is a test'.
	stream ensureASpace.
	stream nextPutAll: 'for WriteStreamTest'.
	self assert: stream contents = 'this is a test for WriteStreamTest'.
	
	"Manually put a space and verify there are no 2 consecutive spaces"
	stream := WriteStream on: String new.
	stream nextPutAll: 'this is a test '.
	stream ensureASpace.
	stream nextPutAll: 'for WriteStreamTest'.
	self assert: stream contents = 'this is a test for WriteStreamTest'.
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testEnsureASpace2 [
	"self debug: #testEnsureASpace2"
	| stream |
	stream := WriteStream on: String new.
	stream ensureASpace.
	self assert: stream contents = ' '.
	
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testEnsureNoSpace [
	"self debug: #testEnsureNoSpace"
	
	| stream |

	stream := WriteStream with: 'stream'.
	stream ensureNoSpace.
	self assert: stream contents = 'stream'.
	
	stream := WriteStream with: 'stream '.
	stream ensureNoSpace.
	self assert: stream contents = 'stream'.
	
	stream := WriteStream with: ' '.
	stream ensureNoSpace.
	self assert: stream contents = ''.
]

{ #category : #'tests - instance creation' }
WriteStreamTest >> testInstanciationUsingOn [
	"self debug: #testInstanciationUsingOn"
	| stream |
	stream := WriteStream on: #(1 2) copy.
	stream nextPut: 3.
	self assert: stream contents = #(3)
]

{ #category : #'tests - instance creation' }
WriteStreamTest >> testInstanciationUsingWith [
	"self debug: #testInstanciationUsingWith"
	| stream |
	stream := WriteStream with: #(1 2).
	stream nextPut: 3.
	self assert: stream contents = #(1 2 3)
]

{ #category : #'tests - testing' }
WriteStreamTest >> testIsEmpty [
	| stream |
	stream := WriteStream on: String new.
	self assert: stream isEmpty.
	stream nextPut: $a.
	self deny: stream isEmpty.
	stream reset.
	self deny: stream isEmpty.
]

{ #category : #'tests - testing' }
WriteStreamTest >> testIsEmpty2 [
    self assert: (WriteStream on: (String new: 100)) isEmpty
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testLf [
	"self debug: #testLf"
	
	| stream |
	stream := WriteStream on: 'stream' copy.
	stream lf.
	self assert: stream last = Character lf.
]

{ #category : #'tests - instance creation' }
WriteStreamTest >> testNew [

	self should: [WriteStream new] raise: Error. 
]

{ #category : #'tests - accessing' }
WriteStreamTest >> testNextPut [
	"self debug: #testNextPut"
	| stream |
	stream := WriteStream on: String new.
	stream
		nextPut: $t;
		nextPut: $e;
		nextPut: $s;
		nextPut: $t.
	self assert: stream contents = 'test'
]

{ #category : #'tests - accessing' }
WriteStreamTest >> testNextPut2 [
	"self debug: #testNextPut2"
	| stream |
	stream := WriteStream with: 'test'.
	stream nextPut: $s.
	self assert: stream contents = 'tests'
]

{ #category : #'tests - accessing' }
WriteStreamTest >> testNextPutAll [
	"self debug: #testNextPutAll"
	| stream |
	stream := WriteStream on: String new.
	stream
		nextPutAll: #($t $e $s $t).
	self assert: stream contents = 'test'
]

{ #category : #'tests - instance creation' }
WriteStreamTest >> testNextPutAllDifferentFromNextPuts [
	"self debug: #testNextPutAllDifferentFromNextPuts"
	
	"When a stream is created on a collection, it tries to keep using that collection instead of copying. See thread with title 'Very strange bug on Streams and probably compiler' (Feb 14 2007) on the squeak-dev mailing list."
	
	"nextPutAll verifies the size of the parameter and directly grows the underlying collection of the required size."
	|string stream|
	
	string := String withAll: 'z'.
	stream := WriteStream on: string.
	stream nextPutAll: 'abc'.
	self assert: string = 'z'. "string hasn't been modified because #nextPutAll: detects that 'abc' is bigger than the underlying collection. Thus, it starts by creating a new collection and doesn't modify our variable."
	
	string := String withAll: 'z'.
	stream := WriteStream on: string.
	stream nextPut: $a; nextPut: $b; nextPut: $c.
	self assert: string = 'a'. "The first #nextPut: has no problem and replaces $z by $a in the string. Others will detect that string is too small."
]

{ #category : #'tests - accessing' }
WriteStreamTest >> testOnFromTo [
	| aToZ |
	aToZ := String withAll: ($A to: $Z).
	self assert: ((WriteStream
						on: (String withAll: ((0 to: 255) collect: [:n| n asCharacter]))
						from: $A asInteger + 1
						to: $Z asInteger + 1)
					nextPutAll: aToZ;
					contents)
		equals: aToZ
]

{ #category : #'tests - positioning' }
WriteStreamTest >> testPosition [
	"self debug: #testPosition"
	
	| stream |
	stream := WriteStream with: 'an elephant' copy.
	stream position: 6.
	self assert: stream contents = 'an ele'.

	stream nextPutAll: 'vator'.
	stream assert: stream contents = 'an elevator'
]

{ #category : #'tests - positioning' }
WriteStreamTest >> testPositionFailsOutsideStreamBounds [
	"self debug: #testPosition2"
	
	| stream |

	stream := WriteStream with: ''.
	self should: [stream position: 2] raise: Error.
	self should: [stream position: -2] raise: Error.

	stream := WriteStream with: 'a test'.
	self should: [stream position: 7] raise: Error.
	self should: [stream position: -2] raise: Error.
]

{ #category : #'tests - positioning' }
WriteStreamTest >> testReset [
	"self debug: #testReset"
	|stream stream2|
	stream := WriteStream with: 'a test ' copy.
	stream reset.
	stream nextPutAll: 'to test'.
	self assert: stream contents = 'to test'.

	stream2 := WriteStream with: 'a test ' copy.
	stream2 nextPutAll: 'to test'.
	self assert: stream2 contents = 'a test to test'
]

{ #category : #'tests - accessing' }
WriteStreamTest >> testSetToEnd [

	| string stream |
	string := 'hello'.
	stream := WriteStream with: ''.
	stream nextPutAll: string.
	self assert: stream position = string size.
	stream setToEnd.
	self assert: stream position = string size.
	self assert: stream contents = string
]

{ #category : #'tests - accessing' }
WriteStreamTest >> testSize [
	"self debug: #testSize"

	| string streamEmpty streamFull |
	string := 'a string'.
	streamEmpty := WriteStream on: string copy.
	streamFull := WriteStream with: string copy.
	
	self assert: streamEmpty size = 0.
	self assert: streamFull size = 8.
	
	streamEmpty nextPut: $..
	streamFull nextPut: $..
	self assert: streamEmpty size = 1.
	self assert: streamFull size = (string size + 1).
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testSpace [
	"self debug: #testSpace"
	
	| stream |
	stream := WriteStream on: 'stream' copy.
	stream space.
	self assert: stream last = Character space.
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testSpaces [
	"self debug: #testSpaces"
	
	| stream |
	stream := WriteStream on: 'stream' copy.
	stream space: 3.
	self assert: (stream contents last: 3) = '   '
]

{ #category : #'tests - instance creation' }
WriteStreamTest >> testStreamAlwaysUseGivenCollection [
	"self debug: #testStreamUseGivenCollection"
	
	"When a stream is created on a collection, it tries to keep using that collection instead of copying,
	even in the case of mutation of the original collection."
	
	"To implement this WriteStream>>#nextPut: might want to use becomeForward for replacing the original
	string with the new widestring object. Another option might be to throw an exception --pre"
	
	|string stream|
	
	string := String withAll: 'xy'.
	stream := WriteStream on: string.
	
	stream nextPut: $a.
	stream nextPut: (Character codePoint: 269). "wide."
	self assert: string = (String with: $a with: (Character codePoint: 269)).
]

{ #category : #'tests - positioning' }
WriteStreamTest >> testStreamContentsPositioning [
	"String class>>new:streamContents: optimizes performance by answering the
	originalCollection in the case of a stream positioned to the size of the original
	collection. Verify that the optimization is performed if and only if the result string
	is the original stream colllection. In particular, ensure that positioning the stream
	backwards to the original collection size prooduces the expected result."

	"(OrderedCollectionTest selector: #testStreamContentsPositioning) debug"

	| s s1 s2 |
	s := String new: 10 streamContents: [ :strm |
			strm nextPutAll: 'XXXXX'.
			self assert: 'XXXXX' equals: strm contents.
			strm nextPut: $X.
			self assert: 'XXXXXX' equals: strm contents.
			strm position: strm position - 1.
			self assert: 'XXXXX' equals: strm contents.
			strm nextPutAll: 'XXXXX'.
			self assert: 'XXXXXXXXXX' equals: strm contents.
			strm nextPut: $X.
			self assert: 'XXXXXXXXXXX' equals: strm contents.
			strm position: strm position - 1.
			self assert: 'XXXXXXXXXX' equals: strm contents.
		].
	self assert: 10 equals: s size.
	self assert: 'XXXXXXXXXX' equals: s.

	"Verify that the performance optimization in #new:streamContents: is happening"
	s2 := String new: s size streamContents: [ :strm |
		s1 := strm originalContents.
		strm nextPutAll: s ].
	self assert: s equals: s2.
	self assert: s equals: s1.
	self assert: s1 == s2. "answer the original collection in this case only"

	s2 := String new: s size - 1 streamContents: [ :strm |
		s1 := strm originalContents.
		strm nextPutAll: s ].
	self assert: s equals: s2.
	self deny: s1 == s2. "normal case, contents not matching original stream collection"

	s2 := String new: s size - 2 streamContents: [ :strm |
		s1 := strm originalContents.
		strm nextPutAll: s ].
	self assert: s equals: s2.
	self deny: s1 == s2. "normal case, contents not matching original stream collection"
	
]

{ #category : #'tests - instance creation' }
WriteStreamTest >> testStreamUseGivenCollection [
	"self debug: #testStreamUseGivenCollection"
	
	"When a stream is created on a collection, it tries to keep using that collection instead of copying. See thread with title 'Very strange bug on Streams and probably compiler' (Feb 14 2007) on the squeak-dev mailing list."
	
	|string stream|
	
	string := String withAll: 'erased'.
	stream := WriteStream on: string.
	self assert: string = 'erased'.
	
	stream nextPutAll: 'test'.
	self assert: string = 'tested'. "Begining of 'erased' has been replaced by 'test'".
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testTab [
	"self debug: #testTab"
	
	| stream |
	stream := WriteStream on: 'stream' copy.
	stream tab.
	self assert: (stream contents last) = Character tab
]

{ #category : #'tests - character writing' }
WriteStreamTest >> testTabs [
	"self debug: #testTabs"
	
	| stream |
	stream := WriteStream on: 'stream' copy.
	stream tab: 3.
	self assert: (stream contents last: 3) = (String with: Character tab with: Character tab with: Character tab)
]
