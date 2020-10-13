"
This is the unit test for the class String. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #WideStringTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Text'
}

{ #category : #'tests - converting' }
WideStringTest >> testAsInteger [

	#(
		'' nil nil nil
		'1796exportFixes-tkMX' 1796 1796 1796
		'donald' nil nil nil
		'abc234def567' 234 234 234
		'-94' -94 -94 94
		'foo-bar-92' -92 -92 92
	) groupsDo: [ :inputString :asIntegerExpectedValue :asSignedIntegerExpectedValue :asUnsignedIntegerExpectedValue |
		| wideString |
		wideString := inputString asWideString.
		self
			assert: asIntegerExpectedValue equals: wideString asInteger;
			assert: asSignedIntegerExpectedValue equals: wideString asSignedInteger;
			assert: asUnsignedIntegerExpectedValue equals: wideString asUnsignedInteger ]
]

{ #category : #'tests - converting' }
WideStringTest >> testAsIntegerSigned [

	#(
		'' nil nil
		'1796exportFixes-tkMX' 1796 1796
		'donald' nil nil
		'abc234def567' 234 234
		'-94' -94 94
		'foo-bar-92' -92 92
		'1234567890' 1234567890 1234567890
		'--1234567890--' -1234567890 1234567890
		'--1234567890123456789012345678901234567890--' -1234567890123456789012345678901234567890 1234567890123456789012345678901234567890
	) groupsDo: [ :inputString :expectedSignedValue :expectedUnsignedValue |
		self
			assert: expectedSignedValue equals: (inputString asIntegerSigned: true);
			assert: expectedUnsignedValue equals: (inputString asIntegerSigned: false) ]
]

{ #category : #'tests - converting' }
WideStringTest >> testAsIntegerSignedUsingRandomNumbers [

	| random digitCharactersByValue |
	random := Random seed: 36rSqueak.
	digitCharactersByValue := (((0 to: 65535) collect: #asCharacter as: String) select: #isDigit)
		groupBy: #digitValue.
	1 to: 100 do: [ :digitLength |
		50 timesRepeat: [
			| number inputString |
			number := ((2 atRandom: random) = 1
				ifTrue: [ LargePositiveInteger ]
				ifFalse: [ LargeNegativeInteger ])
					new: digitLength.
			1 to: digitLength do: [ :index | number at: index put: (256 atRandom: random) - 1 ].
			number := number normalize.
			inputString := number asString asWideString.
			inputString replace: [ :each |
				each == $-
					ifTrue: [ each ]
					ifFalse: [ (digitCharactersByValue at: each digitValue) atRandom: random ] ].
			self
				assert: number equals: (inputString asIntegerSigned: true);
				assert: number abs equals: (inputString asIntegerSigned: false) ] ]
]

{ #category : #'tests - converting' }
WideStringTest >> testAsOctetString [

	| testString |
	testString := 'abcd€'.
	self 
		assert: testString equals: testString asOctetString;
		assert: testString class equals: testString asOctetString class

]

{ #category : #'tests - accessing' }
WideStringTest >> testAtPut [
	"Non regression test for http://bugs.squeak.org/view.php?id=6998"
	
	| w1 |
	w1 := WideString with: (Unicode value: 402) with: $a with: (Unicode value: 400) with: $b.
	self assert: (w1 at: 2 put: $b) = $b description: 'at:put: should return the put-object'

]

{ #category : #'tests - beginsWith' }
WideStringTest >> testBeginsWith [
	"from johnmci at http://bugs.squeak.org/view.php?id=5331"
	
	| w1 w2 |
	self assert: ('abc' beginsWith: 'ab').
	self assert: ('abc' beginsWith: 'ab' asWideString).
	self assert: ('abc' asWideString beginsWith: 'ab').
	self assert: ('abc' beginsWith: 'aX') not .
	self assert: ('abc' beginsWith: 'AB') not.
	self assert: ('abc' beginsWith: 'AB' asWideString) not .
	self assert: ('ABC' asWideString beginsWith: 'ab') not.

	w1 := WideString with: (Unicode value: 402) with: $a with: (Unicode value: 400) with: $b.
	w2 := WideString with: (Unicode value: 402).
	w1 beginsWith: w2.

]

{ #category : #'tests - match' }
WideStringTest >> testCharactersExactlyMatching [
	"from johnmci at http://bugs.squeak.org/view.php?id=5331"
	
	self assert: ('abc' charactersExactlyMatching: 'abc') = 3.
	self assert: ('abd' charactersExactlyMatching: 'abc') = 2.
	self assert: ('abc' charactersExactlyMatching: 'abc' asWideString) = 3.
	self assert: ('abd' charactersExactlyMatching: 'abc' asWideString) = 2.
	self assert: ('abc' asWideString charactersExactlyMatching: 'abc') = 3.
	self assert: ('abd' asWideString charactersExactlyMatching: 'abc') = 2.
	self assert: ('abc' asWideString charactersExactlyMatching: 'abc' asWideString) = 3.
	self assert: ('abd' asWideString charactersExactlyMatching: 'abc' asWideString)= 2.
	self assert: ('abc' charactersExactlyMatching: 'ABC') = 0.


]

{ #category : #'tests - compare' }
WideStringTest >> testCompare [
	"from johnmci at http://bugs.squeak.org/view.php?id=5331"
	
	self assert: ('abc' compare: 'abc') = 2.
	self assert: ('abc' compare: 'abd') = 1.
	self assert: ('abd' compare: 'abc') = 3.
	self assert: ('abc' compare: 'abC') = 2.
	self assert: ('abc' compare: 'abD') = 1.
	self assert: ('abd' compare: 'abC') = 3.
	self assert: ('aBc' compare: 'abC') = 2.
	self assert: ('aBc' compare: 'abD') = 1.
	self assert: ('aDd' compare: 'abC') = 3.
	
	
	self assert: ('abc' compare: 'abc' asWideString) = 2.
	self assert: ('abc' compare: 'abd' asWideString) = 1.
	self assert: ('abd' compare: 'abc' asWideString) = 3.
	self assert: ('abc' compare: 'abC' asWideString) = 2.
	self assert: ('abc' compare: 'abD' asWideString) = 1.
	self assert: ('abd' compare: 'abC' asWideString) = 3.
	self assert: ('aBc' compare: 'abC' asWideString) = 2.
	self assert: ('aBc' compare: 'abD' asWideString) = 1.
	self assert: ('aDd' compare: 'abC' asWideString) = 3.
	
	self assert: ('abc' asWideString compare: 'abc') = 2.
	self assert: ('abc' asWideString compare: 'abd') = 1.
	self assert: ('abd' asWideString compare: 'abc') = 3.
	self assert: ('abc' asWideString compare: 'abC') = 2.
	self assert: ('abc' asWideString compare: 'abD') = 1.
	self assert: ('abd' asWideString compare: 'abC') = 3.
	self assert: ('aBc' asWideString compare: 'abC') = 2.
	self assert: ('aBc' asWideString compare: 'abD') = 1.
	self assert: ('aDd' asWideString compare: 'abC') = 3.
	
	self assert: ('abc' asWideString compare: 'abc' asWideString) = 2.
	self assert: ('abc' asWideString compare: 'abd' asWideString) = 1.
	self assert: ('abd' asWideString compare: 'abc' asWideString) = 3.
	self assert: ('abc' asWideString compare: 'abC' asWideString) = 2.
	self assert: ('abc' asWideString compare: 'abD' asWideString) = 1.
	self assert: ('abd' asWideString compare: 'abC' asWideString) = 3.
	self assert: ('aBc' asWideString compare: 'abC' asWideString) = 2.
	self assert: ('aBc' asWideString compare: 'abD' asWideString) = 1.
	self assert: ('aDd' asWideString compare: 'abC' asWideString) = 3.
	
	self assert: ('abc' compare: 'abc' caseSensitive: true) = 2.
	self assert: ('abc' compare: 'abC' caseSensitive: false) = 2.
	self assert: ('abc' compare: 'abc' asWideString caseSensitive: true) = 2.
	self assert: ('abc' compare: 'abC' asWideString caseSensitive: false) = 2.
	self assert: ('abc' asWideString compare: 'abc' caseSensitive: true) = 2.
	self assert: ('abc' asWideString compare: 'abC' caseSensitive: false) = 2.
	self assert: ('abc' asWideString compare: 'abc' asWideString caseSensitive: true) = 2.
	self assert: ('abc' asWideString compare: 'abC' asWideString caseSensitive: false) = 2.
]

{ #category : #'tests - endsWith' }
WideStringTest >> testEndsWith [
	"Mix of tests from http://bugs.squeak.org/view.php?id=6366
	#endsWith: was broken because using broken findSubstring
	and tests from johnmci at http://bugs.squeak.org/view.php?id=5331"

	| ws |	
	
	self assert: ('abc' endsWith: 'bc').
	self assert: ('abc' endsWith: 'bc' asWideString).
	self assert: ('abc' asWideString endsWith: 'bc').
	self assert: ('abc' endsWith: 'bX') not.
	self assert: ('abc' endsWith: 'BC') not.
	self assert: ('abc' endsWith: 'BC' asWideString) not.
	self assert: ('ABC' asWideString endsWith: 'bc') not.
	
	self assert: ('Elvis' endsWith: 'vis').
	self assert: ('Elvis' asWideString endsWith: 'vis').
	self assert: ((WideString with: (Unicode value: 530)) , 'Elvis' endsWith: 'vis').
	
	self deny: ('Elvis' endsWith: 'Vis').
	self deny: ('Elvis' asWideString endsWith: 'vIs').
	self deny: ((WideString with: (Unicode value: 530)) , 'Elvis' endsWith: 'viS').
	
	ws := 'vis' , (WideString with: (Unicode value: 530)).
	self deny: ('Elvis' endsWith: ws).
	self assert: ('Elvis' , ws endsWith: ws).
	self deny: ((WideString with: (Unicode value: 530)) , 'Elvis' endsWith: ws).


]

{ #category : #'tests - compare' }
WideStringTest >> testEqual [
	"from johnmci at http://bugs.squeak.org/view.php?id=5331"
	
	self assert: 'abc' = 'abc'.
	self assert: 'abc' = 'abc' asWideString.
	self assert: 'abc' asWideString = 'abc'.
	self assert: 'abc' asWideString = 'abc' asWideString.
	self assert: ('abc' = 'ABC') not.
	self assert: ('abc' = 'ABC' asWideString) not.
	self assert: ('abc' asWideString = 'ABC') not.
	self assert: ('abc' asWideString = 'abc' asWideString).
	self assert: (#[ 97 0 0 0 ] asString ~= 'a000' asWideString).
	self assert: ('a000' asWideString ~= #[ 97 0 0 0 ] asString).
]

{ #category : #'tests - substrings' }
WideStringTest >> testFindSubstring [
	"This is related to http://bugs.squeak.org/view.php?id=6366
	finding substring in a WideString was broken because matchTable are byte-wise"
	
	| ws1 ws2 |
	
	self assert: ('abcd' findString: 'bc' startingAt: 1) = 2.
	self assert: ('abcd' asWideString findString: 'bc' startingAt: 1) = 2.
	self assert: ('abcd' findString: 'bc' asWideString startingAt: 1) = 2.
	self assert: ('abcd' asWideString findString: 'bc' asWideString startingAt: 1) = 2.
	
	ws1 := 'A' , (WideString with: (Unicode value: 530)) , 'BCD'.
	self assert: (ws1 findString: 'bc' startingAt: 1 caseSensitive: true) = 0.
	self assert: (ws1 findString: 'bc' startingAt: 1 caseSensitive: false) = 3.
	
	ws2 := (WideString with: (Unicode value: 530)) , 'b'.
	self assert: (ws1 findString: ws2 startingAt: 1 caseSensitive: true) = 0.
	self assert: (ws1 findString: ws2 startingAt: 1 caseSensitive: false) = 2.
	
	self assert: ('abc' findString: ws2 startingAt: 1 caseSensitive: true) = 0.
	self assert: ('abc' findString: ws2 startingAt: 1 caseSensitive: false) = 0.
]

{ #category : #'tests - match' }
WideStringTest >> testMatch [
	"from johnmci at http://bugs.squeak.org/view.php?id=5331"
	
	self assert: ('*baz' match: 'mobaz' ).
	self assert: ('*foo#zort' match: 'afoo3zortthenfoo3zort' ).
	self assert: ('*baz' match: 'mobaz' ).
	self assert: ('*foo#zort' match: 'afoo3zortthenfoo3zort' ).
	
	self assert: ('*baz' match: 'mobaz' asWideString).
	self assert: ('*foo#zort' match: 'afoo3zortthenfoo3zort' asWideString).
	self assert: ('*baz' match: 'mobaz' asWideString).
	self assert: ('*foo#zort' match: 'afoo3zortthenfoo3zort' asWideString).
	
	self assert: ('*baz' asWideString match: 'mobaz' ).
	self assert: ('*foo#zort' asWideString match: 'afoo3zortthenfoo3zort' ).
	self assert: ('*baz' asWideString match: 'mobaz' ).
	self assert: ('*foo#zort' asWideString match: 'afoo3zortthenfoo3zort' ).
	
	self assert: ('*baz' asWideString match: 'mobaz' asWideString).
	self assert: ('*foo#zort' asWideString match: 'afoo3zortthenfoo3zort' asWideString).
	self assert: ('*baz' asWideString match: 'mobaz' asWideString).
	self assert: ('*foo#zort' asWideString match: 'afoo3zortthenfoo3zort' asWideString).
]

{ #category : #'tests - relation order' }
WideStringTest >> testRelationOrder [
	"from johnmci at http://bugs.squeak.org/view.php?id=5331"

	self assert: ('aa' < 'ab').
	self assert: ('aa' <= 'ab').
	self assert: ('aa' <= 'aa').
	self assert: ('ab' > 'aa').
	self assert: ('ab' >= 'aa').
	self assert: ('aa' >= 'aa').
	
	self assert: ('aa' < 'ab' asWideString).
	self assert: ('aa' <= 'ab' asWideString).
	self assert: ('aa' <= 'aa' asWideString).
	self assert: ('ab' > 'aa' asWideString).
	self assert: ('ab' >= 'aa' asWideString).
	self assert: ('aa' >= 'aa' asWideString).
	
	self assert: ('aa' asWideString < 'ab').
	self assert: ('aa' asWideString <= 'ab').
	self assert: ('aa' asWideString <= 'aa').
	self assert: ('ab' asWideString > 'aa').
	self assert: ('ab' asWideString >= 'aa').
	self assert: ('aa' asWideString >= 'aa').
	
	self assert: ('aa' asWideString< 'ab' asWideString).
	self assert: ('aa' asWideString<= 'ab' asWideString).
	self assert: ('aa' asWideString<= 'aa' asWideString).
	self assert: ('ab' asWideString> 'aa' asWideString).
	self assert: ('ab' asWideString >= 'aa' asWideString).
	self assert: ('aa' asWideString>= 'aa' asWideString).
]

{ #category : #'tests - relation order' }
WideStringTest >> testRelationOrderWithCase [
	"from johnmci at http://bugs.squeak.org/view.php?id=5331"
		
	self assert: ('ABC' caseInsensitiveLessOrEqual: 'abc').
	self assert: ('ABC' caseInsensitiveLessOrEqual: 'abd').
	self assert: ('ABD' caseInsensitiveLessOrEqual: 'abc') not.
	self assert: ('ABC' caseInsensitiveLessOrEqual: 'abc' asWideString).
	self assert: ('ABC' caseInsensitiveLessOrEqual: 'abd' asWideString).
	self assert: ('ABD' caseInsensitiveLessOrEqual: 'abc' asWideString) not.
	self assert: ('ABC' asWideString caseInsensitiveLessOrEqual: 'abc').
	self assert: ('ABC' asWideString caseInsensitiveLessOrEqual: 'abd').
	self assert: ('ABD' asWideString caseInsensitiveLessOrEqual: 'abc') not.
	self assert: ('ABC' asWideString caseInsensitiveLessOrEqual: 'abc' asWideString).
	self assert: ('ABC' asWideString caseInsensitiveLessOrEqual: 'abd' asWideString).
	self assert: ('ABD' asWideString caseInsensitiveLessOrEqual: 'abc' asWideString) not.
	
	
	self assert: ('abc' caseSensitiveLessOrEqual: 'abc').
	self assert: ('abc' caseSensitiveLessOrEqual: 'abd').
	self assert: ('abd' caseSensitiveLessOrEqual: 'abc') not.
	self assert: ('abc' caseSensitiveLessOrEqual: 'abc' asWideString).
	self assert: ('abc' caseSensitiveLessOrEqual: 'abd' asWideString).
	self assert: ('abd' caseSensitiveLessOrEqual: 'abc' asWideString) not.
	self assert: ('abc' asWideString caseSensitiveLessOrEqual: 'abc').
	self assert: ('abc' asWideString caseSensitiveLessOrEqual: 'abd').
	self assert: ('abd' asWideString caseSensitiveLessOrEqual: 'abc') not.
	self assert: ('abc' caseSensitiveLessOrEqual: 'ABC') not.
	
]

{ #category : #'tests - compare' }
WideStringTest >> testSameAs [
	"from johnmci at http://bugs.squeak.org/view.php?id=5331"

	self assert: ('abc' sameAs: 'aBc' asWideString).
	self assert: ('aBc' asWideString sameAs: 'abc').
	self assert: (#[ 97 0 0 0 ] asString sameAs: 'Abcd' asWideString) not.
	self assert: ('a000' asWideString sameAs: #[ 97 0 0 0 ] asString) not.
	
]

{ #category : #'tests - substrings' }
WideStringTest >> testSubstrings [
	"this is related to http://bugs.squeak.org/view.php?id=6367"
	
	| w1 w2 |
	w1 := WideString with: 401 asCharacter with: $a with: 402 asCharacter with: $b.
	w2 := WideString with: 403 asCharacter with: 404 asCharacter.

	self assert: w1 substrings first = w1.
	self assert: (w1 , ' ' , w2) substrings size = 2.
	self assert: (w1 , ' ' , w2) substrings last = w2.
]
