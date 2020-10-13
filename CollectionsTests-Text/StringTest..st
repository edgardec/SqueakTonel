"
This is the unit test for the class String. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #StringTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'string'
	],
	#category : #'CollectionsTests-Text'
}

{ #category : #running }
StringTest >> setUp [
	string := 'Hi, I am a String'
]

{ #category : #'tests - converting' }
StringTest >> testAsCamelCase [
	self assert: 'CamelCase' equals: 'camel case' asCamelCase.
	self assert: 'CamelCase' equals: 'Camel Case' asCamelCase.
	self assert: 'CamelCase' equals: 'CamelCase' asCamelCase.
	self assert: 'CamelCase' equals: 'camelCase' asCamelCase.
	self assert:  'AMan,APlan,ACanal,Panama' equals: 'A man, a plan, a canal, panama' asCamelCase.
	self assert:  'Here123should%Be6TheName6OfTheMethod' equals: 'Here 123should % be 6 the name6 of the method' asCamelCase.
]

{ #category : #'tests - converting' }
StringTest >> testAsDecomposedUnicode [
	"Test the behavior of #asDecomposedUnicode"
	| composed decomposed |

	"Tests single character"
	composed := String with: (Character value: 353).
	decomposed := String with: (Character value: 115) with: (Character value: 780).
	self assert: composed asDecomposedUnicode = decomposed.

	"Test character at end of text"
	composed := 'Hello', (String with: (Character value: 353)).
	decomposed := 'Hello', (String with: (Character value: 115) with: (Character value: 780)).
	self assert: composed asDecomposedUnicode = decomposed.

	"Test character in the midst of text"
	composed := 'Hello', (String with: (Character value: 353)), 'World'.
	decomposed := 'Hello', (String with: (Character value: 115) with: (Character value: 780)), 'World'.
	self assert: composed asDecomposedUnicode = decomposed.

	"Test character in the end of text"
	composed := (String with: (Character value: 353)), 'World'.
	decomposed := (String with: (Character value: 115) with: (Character value: 780)), 'World'.
	self assert: composed asDecomposedUnicode = decomposed.

	"Test string full of characters"
	"Test character in the end of text"
	composed := (String with: (Character value: 353)).
	decomposed := (String with: (Character value: 115) with: (Character value: 780)).
	self assert: (composed, composed, composed) asDecomposedUnicode = (decomposed, decomposed, decomposed).

]

{ #category : #'tests - converting' }
StringTest >> testAsInteger [

	#(
		'' nil nil nil
		'1796exportFixes-tkMX' 1796 1796 1796
		'donald' nil nil nil
		'abc234def567' 234 234 234
		'-94' -94 -94 94
		'foo-bar-92' -92 -92 92
	) groupsDo: [ :inputString :asIntegerExpectedValue :asSignedIntegerExpectedValue :asUnsignedIntegerExpectedValue |
		self
			assert: asIntegerExpectedValue equals: inputString asInteger;
			assert: asSignedIntegerExpectedValue equals: inputString asSignedInteger;
			assert: asUnsignedIntegerExpectedValue equals: inputString asUnsignedInteger ]
]

{ #category : #'tests - converting' }
StringTest >> testAsIntegerSigned [

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
StringTest >> testAsIntegerSignedUsingRandomNumbers [

	| random |
	random := Random seed: 36rSqueak.
	1 to: 100 do: [ :digitLength |
		50 timesRepeat: [
			| number inputString |
			number := ((2 atRandom: random) = 1
				ifTrue: [ LargePositiveInteger ]
				ifFalse: [ LargeNegativeInteger ])
					new: digitLength.
			1 to: digitLength do: [ :index | number at: index put: (256 atRandom: random) - 1 ].
			number := number normalize.
			inputString := number asString.
			self
				assert: number equals: (inputString asIntegerSigned: true);
				assert: number abs equals: (inputString asIntegerSigned: false) ] ]
]

{ #category : #'tests - converting' }
StringTest >> testAsOctetString [
	
	| testString |
	testString := 'abcd' asWideString.
	self assert: testString equals: testString asOctetString.
	self deny: testString class equals: testString asOctetString class.
]

{ #category : #'tests - converting' }
StringTest >> testAsPrecomposedUnicode [
	"Test the behavior of #asPrecomposedUnicode"
	| composed decomposed |

	"Tests single character"
	composed := String with: (Character value: 353).
	decomposed := String with: (Character value: 115) with: (Character value: 780).
	self assert: decomposed asPrecomposedUnicode = composed.

	"Test character at end of text"
	composed := 'Hello', (String with: (Character value: 353)).
	decomposed := 'Hello', (String with: (Character value: 115) with: (Character value: 780)).
	self assert: decomposed asPrecomposedUnicode = composed.

	"Test character in the midst of text"
	composed := 'Hello', (String with: (Character value: 353)), 'World'.
	decomposed := 'Hello', (String with: (Character value: 115) with: (Character value: 780)), 'World'.
	self assert: decomposed asPrecomposedUnicode = composed.

	"Test character in the end of text"
	composed := (String with: (Character value: 353)), 'World'.
	decomposed := (String with: (Character value: 115) with: (Character value: 780)), 'World'.
	self assert: decomposed asPrecomposedUnicode = composed.

	"Test string full of characters"
	"Test character in the end of text"
	composed := (String with: (Character value: 353)).
	decomposed := (String with: (Character value: 115) with: (Character value: 780)).
	self assert: (decomposed, decomposed, decomposed) asPrecomposedUnicode = (composed, composed, composed).

]

{ #category : #'tests - converting' }
StringTest >> testAsSmalltalkComment [

	| exampleStrings  |
	exampleStrings := #(
		''
		' '
		'"'
		'""'
		'"""'
		'abc"abc'
		'abc""abc'
		'abc"hello"abc'
		'abc"'
		'"abc' ).

	"check that the result of scanning the comment is empty"
	exampleStrings do: [ :s |
		| tokens  |
		tokens :=  Scanner new scanTokens: s asSmalltalkComment.
		self assert: (tokens isEmpty) ].

	"check that the result has the same non-quote characters as the original"
	exampleStrings do: [ :s |
		self assert: ( (s copyWithout: $") = (s asSmalltalkComment copyWithout: $"))].

	"finnaly, test for some common kinds of inputs"
	self assert: ( 'abc' asSmalltalkComment = '"abc"').
	self assert: ( 'abc"abc' asSmalltalkComment = '"abc""abc"').
	self assert: ('abc""abc' asSmalltalkComment = '"abc""abc"' ).
		
]

{ #category : #'tests - accessing' }
StringTest >> testAt [

	self assert: (string at: 1) = $H.
]

{ #category : #'tests - converting' }
StringTest >> testBase64 [

	self 
		assert: 'SGVsbG8gV29ybGQ=' base64Decoded = 'Hello World';
		assert: 'Hello World' base64Encoded = 'SGVsbG8gV29ybGQ=';
		assert: (String new: 100 withAll: $x) base64Encoded  = 'eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eA=='
]

{ #category : #'tests - finding' }
StringTest >> testBeginsWith [

	self assert: ('Elvis' beginsWith: 'Elv').
	self assert: ('Elvis' beginsWith: 'Elvis').
	self assert: ('Elvis' beginsWith: 'E').
	self deny: ('Elvis' beginsWith: 'e').
	self deny: ('Elvis' beginsWith: 'Elvis ').
	self deny: ('' beginsWith: '').
	self deny: ('abc' beginsWith: '')
]

{ #category : #'tests - converting' }
StringTest >> testCapitalized [

	| uc lc empty |		
	uc := 'MElViN'.
	lc := 'mElViN'.
	empty := ' '.
	self assert:  lc capitalized = uc.
	self assert: uc capitalized = uc.
	"the string gets copied"
	self deny: uc capitalized == uc.
	self deny: empty capitalized == empty.
]

{ #category : #'tests - comparing' }
StringTest >> testComparing [
	self assert: 'foo' < 'foo:'.
	self assert: 'foo' < 'fooBar'.
	self assert: 'foo' <= 'foo:'.
	self assert: 'foo' <= 'fooBar'.
	self assert: 'foo:' > 'foo'.
	self assert: 'fooBar' > 'foo'.
	self assert: 'foo:' >= 'foo'.
	self assert: 'fooBar' >= 'foo'
]

{ #category : #'tests - converting' }
StringTest >> testCondensedIntoOneLine [
	self assert: ' abc  d   ' condensedIntoOneLine = ' abc d '.
	self assert: '
		(2
	 		to:         10
 			by:     2) 
' condensedIntoOneLine = ' (2 to: 10 by: 2) '.
	"all blanks"
	self assert:
		(((0 to: 255)
			collect: [ : each | each asCharacter ]
			thenSelect: [ : each | each isSeparator ]) as: String) condensedIntoOneLine = String space.
	"no blanks"
	self assert: 'abcd' condensedIntoOneLine = 'abcd'.
	"Ensure every 'abcd' in this CompiledMethod is the same one for validity of next assertion."
	self assert: 'abcd' == 'abcd'.
	"supposed to always copy no matter what"
	self assert: 'abcd' condensedIntoOneLine ~~ 'abcd'
]

{ #category : #'tests - internet' }
StringTest >> testDecodeMimeHeader [

	self 
		assert: 'Schöne Grüße'
		equals: '=?utf-8?Q?Sch=C3=B6ne_Gr=C3=BC=C3=9Fe?=' decodeMimeHeader
]

{ #category : #'tests - testing' }
StringTest >> testEmpty [

	self
		assert: 0
		equals: String empty size
		description: 'The empty String should be empty indeed';
		
		assert: String new species
		equals: String empty species
		description: 'The empty String should be a String';
		
		assert: String empty
		identical: String empty 
		description: 'The empty String should be canonical';
		
		yourself
		
		

]

{ #category : #'tests - converting' }
StringTest >> testEncodeForHTTP [

	self assert: 'aa aa éé aa aa' encodeForHTTP = 'aa%20aa%20%C3%A9%C3%A9%20aa%20aa'
]

{ #category : #'tests - finding' }
StringTest >> testEndsWith [

	self assert: ('Elvis' endsWith: 'vis').
	self assert: ('Elvis' endsWith: 'Elvis').
	self assert: ('Elvis' endsWith: 's').
	self deny: ('Elvis' endsWith: 'S').
	self deny: ('Elvis' endsWith: ' Elvis').
	self deny: ('' endsWith: '').
	self deny: ('abc' endsWith: '')
]

{ #category : #'tests - comparing' }
StringTest >> testEquality [

	self assert: 'abc' = 'abc' asWideString.
	self assert: 'abc' asWideString = 'abc'.
	self assert: (#[ 97 0 0 0 ] asString ~= 'a000' asWideString).
	self assert: ('a000' asWideString ~= #[ 97 0 0 0 ] asString).

	self assert: ('abc' sameAs: 'aBc' asWideString).
	self assert: ('aBc' asWideString sameAs: 'abc').
	self assert: (#[ 97 0 0 0 ] asString 
						sameAs: 'Abcd' asWideString) not.
	self assert: ('a000' asWideString sameAs: 
					#[ 97 0 0 0 ] asString) not.
]

{ #category : #'tests - formatting' }
StringTest >> testExpandMacrosWithArguments [

	| patterns |
	patterns := {
		"Input - Expected output"
		#('' '').
		#('foo' 'foo').
		{ '<N>'. String cr }.
		{ '<T>'. String tab }.
		{ '<n>'. String cr }.
		{ '<t>'. String tab }.
		#('%>' '>').
		#('%<' '<').
		#('%%' '%').
		#('%a' 'a').
		#('%A' 'A').
		#('<1S>' 'foo').
		#('<1s>' 'foo').
		#('<10S>' '10').
		#('<10s>' '10').
		#('<2P>' '1').
		#('<3p>' 'true').
		#('<10P>' '''10''').
		#('<11p>' '11').
		#('<3?ab:cde>' 'ab').
		#('<4?ab:cde>' 'cde') }.
	"Test all possible 3 long sequences of the above patterns. Since the patterns include
	the empty string, all 1 and 2 long sequences will be tested too."
	patterns do: [ :first |
		patterns do: [ :second |
			patterns do: [ :third |
				| result |
				result := first first, second first, third first expandMacrosWithArguments: #('foo' 1 true false 5 6 7 8 9 '10' 11).
				self assert: first second, second second, third second equals: result ] ] ].
	"Test some malformed inputs too."
	#('%' '<' '<N' '<T' '<1T' '<>' '<N><' '<1st' '<A' '<1Phello>' '<1?abcd>' '<?a:b>') do: [ :each |
		self should: [ each expandMacrosWithArguments: #() ] raise: Error ]
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindFeatures [

	{
		"input . expected features"
		'camelCase' . #('camel' 'Case').
		'UPPERCase' . #('UPPER' 'Case').
		'MyModel55' . #('My' 'Model' '55'). 
		'5 <= 4' . #('5' '<=' '4').
		'[state := 2]' . #('[' 'state' ':=' '2' ']').
	} pairsDo: [:input :features |
		| output |
		output := features readStream.
		input findFeatureIndicesDo: [:start :end |
			self
				assert: output next
				equals: (input copyFrom: start to: end)]].
]

{ #category : #'tests - accessing' }
StringTest >> testFindLastOccurenceOfStringStartingAt [

	self assert: ('Smalltalk' findLastOccurrenceOfString: 'al' startingAt: 2) = 7.
	self assert: ('aaa' findLastOccurrenceOfString: 'aa' startingAt: 1) = 2.
	self assert: ('Smalltalk' asWideString findLastOccurrenceOfString: 'al' startingAt: 2) = 7.
	self assert: ('Smalltalk' asWideString findLastOccurrenceOfString: 'al' asWideString startingAt: 2) = 7.
	self assert: (('Smalltalk' copyWith: 835 asCharacter) findLastOccurrenceOfString: 'al' asWideString startingAt: 2) = 7.
]

{ #category : #'tests - finding' }
StringTest >> testFindLiteral [

	#(
		nil '' "empty string"
		nil '"Comment."' "comment literal"
				
		42 '42' "integer literal"
		2r1001 '2r1001'
		-42 '-42' "negative integer literal"
		-2r1001 '-2r1001'
		
		2.34 '2.34' "float literal"
		2.34e2 '2.34e2'
		2.34e-2 '2.34e-2'
		
		1e20 '1e20' "large positive integer"
		-1e20 '-1e20' "large negative integer"
		
		#() '#()' "empty literal array"
		#(a 5 'c') '#(a 5 ''c'')' "literal array"
		
		'Hello' '''Hello''' "string literal"
		'drawOn:' 'drawOn:' "identifier or message send"
		#drawOn: '#drawOn:' "symbol literal"

		${ '{}' "opening bracket of empty object literal"
		${ '{1. 2}' "opening bracket of empty object literal"
		
		42 '42 23' "first literal only"
		
	) pairsDo: [:literal :string |
		self assert: (literal literalEqual: string findLiteral)].
]

{ #category : #'tests - finding' }
StringTest >> testFindSelector [

	#(
		#negated 'negated' "Simplest case."
		#negated '#negated' "Ignore leading #"
		#negated '   negated' "Ignore leading whitespace"

		nil 'shouldnotexist42' "Do not intern new symbols."
		nil '' "No empty symbols."

		#copy 'self copy' "Ignore leading receiver."
		#copyWithout: 'self copyWithout: 42' "Ignore leading receiver."
		#negated 'self copy negated' "Choose last selector if several."
	
		#drawOn: 'drawOn:'
		nil 'drawOn' "Do not add colons."
		#drawOn: 'drawOn: aCanvas' "Ignore argument"
		
		#at:put: 'at: 42 put: nil' "Ignore arguments"
		#at:put: 'at: #drawOn: put: 42' "Ignore colons in arguments."
		#at:put: 'at:42 put:43' "Scarce whitepsace"
		#at:put: 'at: ''key:'' put: nil' "Ignore : inside String literal"
		#at:put: 'at: #(foo bar baz:) put:43' "handle literal array"
		#at:put: 'at: $( put:$: asInteger' "Ignore : in Character literal"
		
		#ifTrue: 'ifTrue: [self open]'
		#ifTrue:ifFalse: 'ifTrue: [] ifFalse: [self close]'
		#ifNotEmpty: 'ifNotEmpty: [:all | all sum]'
		
		#+ '+'
		#+ '1 +'
		nil '+ 2'
		nil '1 + 2'
		
	) pairsDo: [:selector :string |
		self assert: selector equals: string findSelector].
]

{ #category : #'tests - finding' }
StringTest >> testFindStringStartingAt [
	"Run the tests with both String's and ByteString's method"

	{
		"text pattern startIndex expectedResult"
		#('Smalltalk' 'al' 2 3).
		{ (Character value: 12345) asString, 'foo'. 'foo'. 1. 2 }.
		{ (Character value: 12345) asString, 'foo'. (Character value: 12345) asString, 'foo'. 1. 1 }.
		{ 'foo', (Character value: 12345) asString. (Character value: 12345) asString. 1. 4 }.
		#('ababab' 'ab' 2 3).
		#('abc' 'a' 2 0) } do: [ :input |
			#(
				(yourself yourself)
				"the (yourself asWideString) pair would sometimes result 0 
				(like here: 'Smalltalk' findString: 'al' asWideString startingAt: 1)
				if the text is a ByteString, because of the optimized version,
				but normally ByteStrings never ''contain'' WideStrings"
				(asWideString yourself)
				(asWideString asWideString)) do: [ :modifiers |
					| text pattern startIndex expectedResult result |
					text := input first perform: modifiers first.
					pattern := input second perform: modifiers second.
					startIndex := input third.
					expectedResult := input fourth.
					self assert: (result := text findString: pattern startingAt: startIndex) = expectedResult ] ]
]

{ #category : #'tests - finding' }
StringTest >> testFindSubstringInStartingAtMatchTable [

	| str tbl cm |
	str := 'hello '.
	tbl := String classPool at: #CaseSensitiveOrder.
	self assert: (str findSubstring: ' ' in: str startingAt: 1 matchTable: tbl) = 6.
	self assert: (str findSubstring: 'q' in: str startingAt: 1 matchTable: tbl) = 0.
	self assert: (str findSubstring: 'q' in: str startingAt: -1 matchTable: tbl) = 0.
	self assert: (str findSubstring: ' ' in: str startingAt: -1 matchTable: tbl) = 6.

	
	"The next test ensures that the fallback code works just as well"
	cm := (ByteString >> #findSubstring:in:startingAt:matchTable:) withoutPrimitive.
	self assert: (cm valueWithReceiver: str arguments: {' '. str. 1. tbl}) = 6.
	self assert: (cm valueWithReceiver: str arguments: {'q'. str. 1. tbl}) = 0.
	self assert: (cm valueWithReceiver: str arguments: {'q'. str. -1. tbl}) = 0.
	self assert: (cm valueWithReceiver: str arguments: {' '. str. -1. tbl}) = 6.

]

{ #category : #'tests - finding' }
StringTest >> testFindSymbol [

	#(
		#negated 'negated' "Simplest case."
		#drawOn: 'drawOn:'
		#String 'String' "class name or other global variables"

		nil '#negated' "No string modification"
		nil 'shouldnotexist42' "Do not intern new symbols."
		nil '' "No empty symbols."
		nil 'drawOn' "Do not add colons."
		nil '#(a b c)'

		"Ignore whitespace"
		#negated '   negated'
		#at:put: 'at: put: ' 
		#+ '+  '
		#** '*     *'		
	) pairsDo: [:selector :string |
		self assert: selector equals: string findSymbol].
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokens [

	#("receiver (argument expectedResult argument expectedResult ...) ..."
		'' ('' () $a () 'a' () 'ab' () 'aaa' ())
		'a' ('' ('a') $a () 'a' () 'ab' () 'aaa' () $b ('a') 'b' ('a') 'bc' ('a'))
		'aa' ('' ('aa') $a () 'a' () 'ab' () 'aaa' () $b ('aa') 'b' ('aa') 'bc' ('aa'))
		'ab' ('' ('ab') $a ('b') 'a' ('b') 'ab' () 'aaa' ('b') $b ('a') 'b' ('a') 'bc' ('a'))
		'ababa' ('' ('ababa') $a ('b' 'b') 'a' ('b' 'b') 'ab' () 'aaa' ('b' 'b') $b ('a' 'a' 'a') 'b' ('a' 'a' 'a') 'bc' ('a' 'a' 'a'))
		'abbccba' ('' ('abbccba') $a ('bbccb') 'a' ('bbccb') 'ab' ('cc') 'aaa' ('bbccb') $b ('a' 'cc' 'a') 'b' ('a' 'cc' 'a') 'bc' ('a' 'a')))
		pairsDo: [ :receiver :argumentsAndExpectedResults |
			argumentsAndExpectedResults pairsDo: [ :argument :expectedResult |
				self assert: expectedResult asOrderedCollection equals: (
					receiver findTokens: argument) ] ]

]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy01 [

	| tokens |
	string := 'this, is, "a, test"'.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens size = 3
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy02 [

	| tokens |
	string := ''.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens isEmpty
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy03 [

	| tokens |
	string := 'this, is, a, test'.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens size = 4
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy04 [

	| tokens |
	string := 'this, is, a"," test'.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens size = 3.
	self assert: tokens third = ' a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy05 [

	| tokens |
	string := 'this, /is, a"," test/'.
	tokens := string findTokens: ',#' escapedBy: '"/'.
	self assert: tokens size = 2.
	self assert: tokens first = 'this'.
	self assert: tokens second = ' is, a"," test'.
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy06 [

	| tokens |
	string := 'this, is, "a, test'.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens size = 3.
	self assert: tokens third = ' a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy07 [

	| tokens |
	string := 'a:b::c'.
	tokens := string findTokens: ':' escapedBy: '"'.
	self assert: tokens size = 4.
	self assert: tokens first = 'a'.
	self assert: tokens second = 'b'.
	self assert: tokens third = ''.
	self assert: tokens fourth = 'c'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy08 [

	| tokens |
	string := 'this, is, ##a, test'.
	tokens := string findTokens: ',' escapedBy: '#'.
	self assert: tokens size = 4.
	self assert: tokens third = ' a'.
	self assert: tokens fourth = ' test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy09 [

	| tokens |
	string := 'this, is, ###a, test#'.
	tokens := string findTokens: ',' escapedBy: '#'.
	self assert: tokens size = 3.
	self assert: tokens third = ' #a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy10 [

	| tokens |
	string := 'this, is, ###a, test'.
	tokens := string findTokens: ',' escapedBy: '#'.
	self assert: tokens size = 3.
	self assert: tokens third = ' #a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy11 [

	| tokens |
	string := 'this, is, """a, test"'.
	tokens := string findTokens: ',' escapedBy: '"'.
	self assert: tokens size = 3.
	self assert: tokens third = ' "a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy12 [

	| tokens |
	string := 'one, two# three; four. five'.
	tokens := string findTokens: ',#;.' escapedBy: '"'.
	self assert: tokens size = 5.
	self assert: tokens third = ' three'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy13 [

	| tokens |
	string := 'one, two# three; four. five'.
	tokens := string findTokens: ',#;.' escapedBy: nil.
	self assert: tokens size = 5.
	self assert: tokens third = ' three'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy14 [

	| tokens |
	string := 'one, "two# three"; &four. five&'.
	tokens := string findTokens: ',#;.' escapedBy: '"&'.
	self assert: tokens size = 3.
	self assert: tokens second = ' two# three'.
	self assert: tokens third = ' four. five'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy15 [

	| tokens |
	string := 'one, "two# three"; &four. five&'.
	tokens := string findTokens: nil escapedBy: '"&'.
	self assert: tokens size = 1.
	self assert: tokens first = 'one, two# three; four. five'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy16 [

	| tokens |
	string := 'one, "two# three"; &four. five&'.
	tokens := string findTokens: nil escapedBy: nil.
	self assert: tokens size = 1.
	self assert: tokens first = string
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy21 [

	| tokens |
	string := 'this, is, "a, test"'.
	tokens := string findTokens: $, escapedBy: $".
	self assert: tokens size = 3
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy22 [

	| tokens |
	string := ''.
	tokens := string findTokens: $, escapedBy: $".
	self assert: tokens size = 0
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy23 [

	| tokens |
	string := 'this, is, a, test'.
	tokens := string findTokens: $, escapedBy: $".
	self assert: tokens size = 4
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy24 [

	| tokens |
	string := 'this, is, a"," test'.
	tokens := string findTokens: $, escapedBy: $".
	self assert: tokens size = 3.
	self assert: tokens third = ' a, test'
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy25 [

	| tokens |
	string := 'this, /is, a"," test/'.
	tokens := string findTokens: $, escapedBy: $/.
	self assert: tokens size = 2.
	self assert: tokens first = 'this'.
	self assert: tokens second = ' is, a"," test'.
]

{ #category : #'tests - tokenizing' }
StringTest >> testFindTokensEscapedBy26 [

	| tokens |
	string := 'this, is, "a, test'.
	tokens := string findTokens: $, escapedBy: $".
	self assert: tokens size = 3.
	self assert: tokens third = ' a, test'
]

{ #category : #'tests - formatting' }
StringTest >> testFormat [

	#(
		'\{ \} \\ foo {1} bar {2}' #(12 'string') '{ } \ foo 12 bar string'
		'\{ \} \\ foo {2} bar {1}' #('string' 12) '{ } \ foo 12 bar string'
		'\{1}' #() '{1}'
		'\{1}{1}' #($a) '{1}a'
		'foo' #() 'foo'
	) groupsDo: [ :receiver :argument :expectedResult |
		self assert: expectedResult equals: (receiver format: argument) ].
	#(
		'{1 }'
		'{1abc}'
		'{ 1}'
		'{ 1.0 }'
		'{1'
		'{1 foo'
		'{2}'
		'{0}'
		'{-0}'
		'{-1}'
	) do: [ :each |
		self should: [ each format: { 'x' } ] raise: Error ]
]

{ #category : #'tests - indexOf' }
StringTest >> testIndexOf [
	
	"test for http://bugs.impara.de/view.php?id=3574"
	self assert: ('abc-' asWideString indexOfAnyOf: (CharacterSet newFrom: ' -0123456789')) = 4.
	self assert: ('ab7' asWideString indexOfAnyOf: (CharacterSet newFrom: ' -0123456789')) = 3.
	self assert: ('a2c' asWideString indexOfAnyOf: (CharacterSet newFrom: ' -0123456789')) = 2.
	self assert: ('3bc' asWideString indexOfAnyOf: (CharacterSet newFrom: ' -0123456789')) = 1.
	self assert: ('abc' asWideString indexOfAnyOf: (CharacterSet newFrom: ' -0123456789')) = 0.
	
	"extension to wide characters"
	self assert: ((String with: 803 asCharacter with: 811 asCharacter) indexOfAnyOf: (CharacterSet newFrom: (String with: 811 asCharacter with: 812 asCharacter))) = 2.
	
	self assert: ('abc' indexOfAnyOf: (CharacterSet newFrom: (String with: 811 asCharacter with: 812 asCharacter))) = 0.
	
	self assert: ('abc' indexOfAnyOf: (CharacterSet newFrom: (String with: 811 asCharacter with: $c))) = 3.
	
	"make sure start index is used in wide string algorithm"
	self assert: ('ab bcd abc' copyWith: 811 asCharacter) substrings = {'ab'. 'bcd'. 'abc' copyWith: 811 asCharacter}.
]

{ #category : #'tests - testing' }
StringTest >> testIsAllDigits [
	self assert: '0123456789' isAllDigits.
	self assert: '0123456789' asWideString isAllDigits.
	self assert: '1' isAllDigits.
	self assert: '1' asWideString isAllDigits.
	self assert: '' isAllDigits.
	self assert: '' asWideString isAllDigits.
	self deny: '012345 6789' isAllDigits.
	self deny: '012345 6789' asWideString isAllDigits.
	self deny: ('12345', String cr) isAllDigits.
	self deny: ('12345', String cr) asWideString isAllDigits.

]

{ #category : #'tests - testing' }
StringTest >> testIsAllSeparators [
	self assert: ('', Character cr, Character tab, Character space) isAllSeparators.
	self assert: ('', Character cr, Character tab, Character space) asWideString isAllSeparators.
	self assert: '      ' isAllSeparators.
	self assert: '      ' asWideString isAllSeparators.
	self assert: '' isAllSeparators.
	self assert: '' asWideString isAllSeparators.
	self deny: '1 2'  isAllSeparators.
	self deny: '1 2'  asWideString isAllSeparators.
	self deny: '  X  ' isAllSeparators.
	self deny: '  X  ' asWideString isAllSeparators.


]

{ #category : #'tests - testing' }
StringTest >> testIsAsciiString [
	self assert: 'this is a string' isAsciiString.
	self assert: 'this is a string' asWideString isAsciiString.
	self assert: '' isAsciiString.
	self assert: '' asWideString isAsciiString.
	self deny: ('this is', (Character value: 256), 'a string') isAsciiString.
	self deny: ('this is', (Character value: 128), 'a string') isAsciiString.
	self assert: ('this is', (Character value: 127), 'a string') isAsciiString.

]

{ #category : #'tests - testing' }
StringTest >> testIsOctetString [
	self assert: 'this is a string' isOctetString.
	self assert: 'this is a string' asWideString isOctetString.
	self assert: '' isOctetString.
	self assert: '' asWideString isOctetString.
	self deny: ('this is', (Character value: 256), 'a string') isOctetString.

]

{ #category : #'tests - lines' }
StringTest >> testLineCorrespondingToIndex [
	| sampleCRString sampleLFString sampleCRLFString anIndex |
	sampleCRString := 'Fred', String cr , 'the' , String cr , 'Bear'.
	sampleLFString := 'Fred', String lf , 'the' , String lf , 'Bear'.
	sampleCRLFString := 'Fred', String crlf , 'the' , String crlf , 'Bear'.
	
	anIndex := sampleCRString indexOf: $h.
	self assert: (sampleCRString lineCorrespondingToIndex: anIndex) = 'the'.
	anIndex := sampleLFString indexOf: $h.
	self assert: (sampleLFString lineCorrespondingToIndex: anIndex) = 'the'.
	anIndex := sampleCRLFString indexOf: $h.
	self assert: (sampleCRLFString lineCorrespondingToIndex: anIndex) = 'the'.
	
	anIndex := sampleCRString indexOf: $B.
	self assert: (sampleCRString lineCorrespondingToIndex: anIndex) = 'Bear'.
	anIndex := sampleLFString indexOf: $B.
	self assert: (sampleLFString lineCorrespondingToIndex: anIndex) = 'Bear'.
	anIndex := sampleCRLFString indexOf: $B.
	self assert: (sampleCRLFString lineCorrespondingToIndex: anIndex) = 'Bear'.
	
	anIndex := sampleCRString indexOf: $d.
	self assert: (sampleCRString lineCorrespondingToIndex: anIndex) = 'Fred'.
	anIndex := sampleLFString indexOf: $d.
	self assert: (sampleLFString lineCorrespondingToIndex: anIndex) = 'Fred'.
	anIndex := sampleCRLFString indexOf: $d.
	self assert: (sampleCRLFString lineCorrespondingToIndex: anIndex) = 'Fred'.
]

{ #category : #'tests - lines' }
StringTest >> testLineCount [
	| sampleCRString sampleLFString sampleCRLFString |
	sampleCRString := 'Fred', String cr , 'the' , String cr , 'Bear'.
	sampleLFString := 'Fred', String lf , 'the' , String lf , 'Bear'.
	sampleCRLFString := 'Fred', String crlf , 'the' , String crlf , 'Bear'.
	
	self assert: sampleCRString lineCount = 3.
	self assert: sampleLFString lineCount = 3.
	self assert: sampleCRLFString lineCount = 3.
]

{ #category : #'tests - lines' }
StringTest >> testLineNumber [
	| sampleCRString sampleLFString sampleCRLFString |
	sampleCRString := 'Fred', String cr , 'the' , String cr , 'Bear'.
	sampleLFString := 'Fred', String lf , 'the' , String lf , 'Bear'.
	sampleCRLFString := 'Fred', String crlf , 'the' , String crlf , 'Bear'.
	
	self assert: (sampleCRString lineNumber: 2) = 'the'.
	self assert: (sampleLFString lineNumber: 2) = 'the'.
	self assert: (sampleCRLFString lineNumber: 2) = 'the'.
]

{ #category : #'tests - lines' }
StringTest >> testLinesDo [
	| sampleCRString sampleLFString sampleCRLFString lines |
	sampleCRString := 'Fred', String cr , 'the' , String cr , 'Bear'.
	sampleLFString := 'Fred', String lf , 'the' , String lf , 'Bear'.
	sampleCRLFString := 'Fred', String crlf , 'the' , String crlf , 'Bear'.
	
	lines := OrderedCollection new.
	sampleCRString linesDo: [:aLine |
		self deny: (aLine includes: Character cr).
		self deny: (aLine includes: Character lf).
		lines add: aLine].
	self assert: lines asArray = #('Fred' 'the' 'Bear').
	
	lines := OrderedCollection new.
	sampleLFString linesDo: [:aLine |
		self deny: (aLine includes: Character cr).
		self deny: (aLine includes: Character lf).
		lines add: aLine].
	self assert: lines asArray = #('Fred' 'the' 'Bear').

	lines := OrderedCollection new.
	sampleCRLFString linesDo: [:aLine |
		self deny: (aLine includes: Character cr).
		self deny: (aLine includes: Character lf).
		lines add: aLine].
	self assert: lines asArray = #('Fred' 'the' 'Bear').


]

{ #category : #'tests - comparing' }
StringTest >> testMatch [

	#('**' 'f**'  'f**o' 'f*' '*f*' 'f#*' 'f##' '*oo' '#oo' '*o*' '#o#' '#o*' '*o#' 'fo*' 'fo#' '*foo*' '###' '*#'  'f*#' 'f*#o')
		do: [ :each | self assert: (each match: 'foo') ].
	#('bar' 'foo#' '#foo' '*foo#' '#foo*' '*bar*') do: [ :each |
		self deny: (each match: 'foo') ]
]

{ #category : #'tests - accessing' }
StringTest >> testNumArgs [

	| binary punctuation |
	binary := '+-*/<=>&|,?\~@'.
	1 to: 3 do: [:length | binary combinations: length atATimeDo: [:each | self assert: each numArgs = 1]].
	
	self assert: 'foo' numArgs = 0.
	self assert: 'bar:' numArgs = 1.
	self assert: 'foo:bar:' numArgs = 2.
	self assert: 'foo2:bar1:' numArgs = 2.
	
	self assert: '::' numArgs = -1 description: 'empty keywords are forbidden'.
	
	punctuation := '.;()[]{}"`''#$'.
	punctuation , Character separators do: [:letter | self assert: ('foo' copyWith: letter) numArgs = -1 description: 'Smalltalk punctuation and separators are illegal in a selector'].
	
	self assert: 'nextPut:andCR' numArgs = -1 description: 'terminal colon is missing'.
	self assert: 'a0:1:' numArgs = -1 description: 'a keyword cannot begin with a digit'.
	self assert: '123' numArgs = -1.
	self assert: '' numArgs = -1.
]

{ #category : #'tests - converting' }
StringTest >> testPercentEncodingJa [
	| leading hiraA hiraO hiraAO encodedHiraA encodedHiraO encodedHiraAO |

    "Make Japanese String from unicode. see http://www.unicode.org/charts/PDF/U3040.pdf"
     leading := JapaneseEnvironment leadingChar.
	hiraA := (Character leadingChar: leading code: 16r3042) asString.  "HIRAGANA LETTER A"
	hiraO := (Character leadingChar: leading code: 16r304A) asString.  "HIRAGANA LETTER O"
	hiraAO := hiraA, hiraO.

	"Percent Encoded Japanese String"
	encodedHiraA := hiraA encodeForHTTP.
	self assert: encodedHiraA = '%E3%81%82'.
	encodedHiraO := hiraO encodeForHTTP.
	self assert: encodedHiraO = '%E3%81%8A'.
	encodedHiraAO := hiraAO encodeForHTTP.
	self assert: encodedHiraAO =  '%E3%81%82%E3%81%8A'.

     "without percent encoded string"
	self assert: '' unescapePercents = ''.
	self assert: 'abc' unescapePercents = 'abc'.	"latin1 character"
	self assert: hiraAO unescapePercents = hiraAO.  "multibyte character"

	"encoded latin1 string"
	self assert: '%61' unescapePercents = 'a'.
	self assert: '%61%62%63' unescapePercents = 'abc'.

	"encoded multibyte string"
	Locale currentPlatform: (Locale isoLanguage: 'ja') during: [ 
		self assert: encodedHiraA unescapePercents = hiraA.
		self assert: encodedHiraAO unescapePercents = hiraAO].

	"mixed string"
	Locale currentPlatform: (Locale isoLanguage: 'ja') during: [ 
		self assert: (encodedHiraAO,'a') unescapePercents = (hiraAO, 'a').
		self assert: ('a', encodedHiraA) unescapePercents = ('a', hiraA).
		self assert: ('a', encodedHiraA, 'b')  unescapePercents = ('a', hiraA, 'b').
		self assert: ('a', encodedHiraA, 'b', encodedHiraO) unescapePercents = ('a', hiraA, 'b', hiraO).
		self assert: (encodedHiraA, encodedHiraO, 'b', encodedHiraA) unescapePercents = (hiraA, hiraO, 'b', hiraA)].


	"for Seaside"
	Locale currentPlatform: (Locale isoLanguage: 'ja') during: [ 
		self assert: (encodedHiraA, '+', encodedHiraO) unescapePercents = (hiraA, ' ', hiraO)].


]

{ #category : #'tests - instance creation' }
StringTest >> testSpace [
	"self debug: #testSpace"
	
	string := String new.
	self assert: string size = 0. "instead of #isEmpty to be consistent with the following test"
	
	string := String space.
	self assert: string size = 1.
	self assert: string = ' '
]

{ #category : #'tests - converting' }
StringTest >> testSubStrings [

	#("receiver (argument expectedResult argument expectedResult ...) ..."
		'' ('' () ($a) () 'a' () 'ab' () 'aaa' ())
		'a' ('' ('a') ($a) () 'a' () 'ab' () 'aaa' () ($b) ('a') 'b' ('a') 'bc' ('a'))
		'aa' ('' ('aa') ($a) () 'a' () 'ab' () 'aaa' () ($b) ('aa') 'b' ('aa') 'bc' ('aa'))
		'ab' ('' ('ab') ($a) ('b') 'a' ('b') 'ab' () 'aaa' ('b') ($b) ('a') 'b' ('a') 'bc' ('a'))
		'ababa' ('' ('ababa') ($a) ('b' 'b') 'a' ('b' 'b') 'ab' () 'aaa' ('b' 'b') ($b) ('a' 'a' 'a') 'b' ('a' 'a' 'a') 'bc' ('a' 'a' 'a'))
		'abbccba' ('' ('abbccba') ($a) ('bbccb') 'a' ('bbccb') 'ab' ('cc') 'aaa' ('bbccb') ($b) ('a' 'cc' 'a') 'b' ('a' 'cc' 'a') 'bc' ('a' 'a')))
		pairsDo: [ :receiver :argumentsAndExpectedResults |
			argumentsAndExpectedResults pairsDo: [ :argument :expectedResult |
				self assert: expectedResult equals: (
					receiver subStrings: argument) ] ]

]

{ #category : #'tests - converting' }
StringTest >> testUnescapePercents [

	#(
		''	''
		'x'	'x'
		'+'	' '
		'x+'	'x '
		'+x'	' x'
		'x+x'	'x x'
		'%'	'%'
		'%3'	'%3'
		'%3C'	'<'
		'%3C%'	'%3C%'
		'%3C%3'	'%3C%3'
		'%3C%3C'	'<<'
		'%0G'	'%0G'
		'%3C%0G'	'%3C%0G'
		'+%3'	'+%3'
		'%3C+%'	'%3C+%'
		'%3C%+'	'%3C%+'
		'%3Cx%3E4%3C%2Fx%3E' '<x>4</x>'
		'!@#$%25%5E&*()%7B%7D%5B%5D=:/;?+''%22'	'!@#$%^&*(){}[]=:/;? ''"'
		'!%40%23%24%25%5E%26*()%7B%7D%5B%5D%3D%3A%2F%3B%3F%2B''%22'	'!@#$%^&*(){}[]=:/;?+''"'
		'%21@%23%24%25%5E%26*%28%29%7B%7D%5B%5D%3D%3A/%3B%3F+%27%22'	'!@#$%^&*(){}[]=:/;? ''"'
	) pairsDo: [ :from :to |
		self assert: to equals: from unescapePercents ]
]

{ #category : #'tests - converting' }
StringTest >> testUnescapePercentsWithTextEncoding [
	| leading kataTe kataSu kataTo |
	leading := JapaneseEnvironment leadingChar.
	"Katakana letter Te"
	kataTe := (Character leadingChar: leading code: 12486) asString.
	"Katakana letter Su"
	kataSu := (Character leadingChar: leading code: 12473) asString.
	"Katakana letter To"
	kataTo := (Character leadingChar: leading code: 12488) asString.
	self assert: ('%83e%83X%83g' unescapePercentsWithTextEncoding: 'shift_jis')
			= (kataTe , kataSu , kataTo).
	self assert: ('%83e%83X%83g%20and%20%83e%83X%83g' unescapePercentsWithTextEncoding: 'shift_jis')
			= (kataTe , kataSu , kataTo , ' and ' , kataTe , kataSu , kataTo)
]

{ #category : #'tests - converting' }
StringTest >> testUpTo [
	"self debug: #testUpTo"
	self assert: #up:to: keywords = #(up: to:).
	self assert: #copy:from:to: keywords = #(copy: from: to:).
	self assert: #up keywords = #(up).
	self assert: #at: keywords = #(at:).
	
]

{ #category : #'tests - converting' }
StringTest >> testUtf8ToSqueakByteOrderMark [
	"Ensure that utf8ToSqueak ignores Byte order mark (BOM) just like UTF8TextConverter does"

	{
		#('ï»¿' '').
		#('ï»¿abc' 'abc').
		"Make sure that we remove inner BOMs for maximal compatibility with UTF8TextConverter"
		#('abcï»¿' 'abc').
		{ 'abï»¿cÓ'. 'abc', (Unicode value: 1234) asString }
	} do: [ :each |
		self assert: each first utf8ToSqueak = each second ]
]

{ #category : #'tests - converting' }
StringTest >> testUtf8ToSqueakLeadingChar [
	"Ensure utf8ToSqueak inserts the leading char just like UTF8TextConverter does"
	| data |
	data := #[ 227 129 130 227 129 132 227 129 134 227 129 136 227 129 138 ] asString "aiueo in Japanese".
	self assert: data utf8ToSqueak = (data convertFromEncoding: #utf8)


]

{ #category : #'tests - converting' }
StringTest >> testWithBlanksTrimmed [

	| s |
	self assert: ' abc  d   ' withBlanksTrimmed = 'abc  d'.
	self assert: 'abc  d   ' withBlanksTrimmed = 'abc  d'.
	self assert: ' abc  d' withBlanksTrimmed = 'abc  d'.
	self assert: (((0 to: 255) collect: [ :each | each asCharacter ] thenSelect: [ :each | each isSeparator ]) as: String) withBlanksTrimmed = ''.
	s := 'abcd'.
	self assert: s withBlanksTrimmed = s.
	self assert: s withBlanksTrimmed ~~ s.
]

{ #category : #'tests - converting' }
StringTest >> testWithFirstCharacterDownshifted [

	| uc lc empty |		
	uc := 'MElViN'.
	lc := 'mElViN'.
	empty := ' '.
	self assert:  uc withFirstCharacterDownshifted = lc.
	self assert: lc withFirstCharacterDownshifted = lc.
	"the string gets copied"
	self deny: lc withFirstCharacterDownshifted == lc.
	self deny: empty withFirstCharacterDownshifted == empty.
]

{ #category : #'tests - internet' }
StringTest >> testWithInternetLineEndings [

	{
		'abc' -> 'abc'.
		'abc', String cr -> ('abc', String crlf).
		'abc', String lf -> ('abc', String crlf).
		'abc', String crlf -> ('abc', String crlf).
		String cr, 'abc' -> (String crlf, 'abc').
		String lf, 'abc' -> (String crlf, 'abc').
		String crlf, 'abc' -> (String crlf, 'abc').
		'abc', String cr, String cr, 'abc' -> ('abc', String crlf, String crlf, 'abc').
		'abc', String lf, String lf, 'abc' -> ('abc', String crlf, String crlf, 'abc').
		'abc', String crlf, String crlf, 'abc' -> ('abc', String crlf, String crlf, 'abc').
		String cr, 'abc', String cr, String crlf, 'abc', String lf -> (String crlf, 'abc', String crlf, String crlf, 'abc', String crlf).
		String lf, 'abc', String lf, String crlf, 'abc', String cr -> (String crlf, 'abc', String crlf, String crlf, 'abc', String crlf).
	} do: [ :each |
		self assert: each key withInternetLineEndings = each value ]
]

{ #category : #'tests - converting' }
StringTest >> testWithNoLineLongerThan [
	"self run: #testWithNoLineLongerThan"
	self assert: ('Hello', String cr, 'World') equals: ('Hello World' withNoLineLongerThan: 5).

	self assert: String crlf equals: (String crlf withNoLineLongerThan: 5).
	self assert: 'Hello\\World' withCRs equals: (('Hello', String cr, String cr,'World') withNoLineLongerThan: 5).

	self
		assert: ('Sample text to line break at', String cr, 'some point')
		equals: ('Sample text to line break at some point' withNoLineLongerThan:  28).
	self
		assert: ('Sample text', String cr, 'to line break', String cr, 'at some point')
		equals: ('Sample text', String cr, 'to line break', String cr, 'at some point' withNoLineLongerThan:  28).

]

{ #category : #'tests - internet' }
StringTest >> testWithSqueakLineEndings [

	{
		'abc' -> 'abc'.
		'abc', String cr -> ('abc', String cr).
		'abc', String lf -> ('abc', String cr).
		'abc', String crlf -> ('abc', String cr).
		String cr, 'abc' -> (String cr, 'abc').
		String lf, 'abc' -> (String cr, 'abc').
		String crlf, 'abc' -> (String cr, 'abc').
		'abc', String cr, String cr, 'abc' -> ('abc', String cr, String cr, 'abc').
		'abc', String lf, String lf, 'abc' -> ('abc', String cr, String cr, 'abc').
		'abc', String crlf, String crlf, 'abc' -> ('abc', String cr, String cr, 'abc').
		String cr, 'abc', String cr, String crlf, 'abc', String lf -> (String cr, 'abc', String cr, String cr, 'abc', String cr).
		String lf, 'abc', String lf, String crlf, 'abc', String cr -> (String cr, 'abc', String cr, String cr, 'abc', String cr).
	} do: [ :each |
		self assert: each key withSqueakLineEndings = each value ]
]

{ #category : #'tests - internet' }
StringTest >> testWithUnixLineEndings [

	{
		'abc' -> 'abc'.
		'abc', String cr -> ('abc', String lf).
		'abc', String lf -> ('abc', String lf).
		'abc', String crlf -> ('abc', String lf).
		String cr, 'abc' -> (String lf, 'abc').
		String lf, 'abc' -> (String lf, 'abc').
		String crlf, 'abc' -> (String lf, 'abc').
		'abc', String cr, String cr, 'abc' -> ('abc', String lf, String lf, 'abc').
		'abc', String lf, String lf, 'abc' -> ('abc', String lf, String lf, 'abc').
		'abc', String crlf, String crlf, 'abc' -> ('abc', String lf, String lf, 'abc').
		String cr, 'abc', String cr, String crlf, 'abc', String lf -> (String lf, 'abc', String lf, String lf, 'abc', String lf).
		String lf, 'abc', String lf, String crlf, 'abc', String cr -> (String lf, 'abc', String lf, String lf, 'abc', String lf).
	} do: [ :each |
		self assert: each key withUnixLineEndings = each value ]
]

{ #category : #'tests - internet' }
StringTest >> testWithoutQuoting [

	#(
		'"foo"' 'foo'
		'''foo''' 'foo'
		'"foo''' '"foo'''
		'''foo"' '''foo"'
		'"foo' '"foo'
		'foo"' 'foo"'
		'foo' 'foo') pairsDo: [ :before :after |
			self assert: before withoutQuoting = after ]
]

{ #category : #'tests - lines' }
StringTest >> testWthNoLineLongerThan [
	| phrases |
	phrases := {
		'Fred the bear went down to the brook to read his book in silence'.
		'Fred the bear went down' , String cr , ' to the brook to ' , String cr , 'read his book in silence'.
		'Fred the bear went down' , String lf , '  to the brook to ' , String lf , 'read his book in silence'.
		'Fred the bear went down' , String crlf , '  to the brook to ' , String crlf , 'read his book in silence'.
		}.
	#(5 7 9) do: [:length |
		phrases do: [:phrase |
			| split |
			split := phrase withNoLineLongerThan: length.
			self
				assert: (split copyWithoutAll: CharacterSet separators) = (phrase copyWithoutAll: CharacterSet separators)
				description: 'no information should be lost'.
			split linesDo: [:line |
				self assert: line size <= length description: 'lines should not be longer than prescribed'].
			phrase lineCount = 1 ifTrue: [| lastLineSize |
				lastLineSize := length.
				split linesDo: [:line |
					line isEmpty ifFalse: [| firstWordSize |
						firstWordSize := line indexOfAnyOf: CharacterSet separators startingAt: 1 ifAbsent: [line size + 1].
						self assert: (lastLineSize + firstWordSize) > length description: 'split was too short'.
						lastLineSize := line size]]]]]
]

{ #category : #'tests - converting' }
StringTest >> testZipped [
	| compressed |
	
	compressed := 'hello' zipped.
	self assert: (compressed unzipped = 'hello').
]
