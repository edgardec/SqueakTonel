"
A String is an indexed collection of Characters. Class String provides the abstract super class for ByteString (that represents an array of 8-bit Characters) and WideString (that represents an array of  32-bit characters).  In the similar manner of LargeInteger and SmallInteger, those subclasses are chosen accordingly for a string; namely as long as the system can figure out so, the String is used to represent the given string.

Strings support a vast array of useful methods, which can best be learned by browsing and trying out examples as you find them in the code.

Here are a few useful methods to look at...
	String match:
	String contractTo:

String also inherits many useful methods from its hierarchy, such as
	SequenceableCollection ,
	SequenceableCollection copyReplaceAll:with:

"
Class {
	#name : #String,
	#superclass : #ArrayedCollection,
	#classVars : [
		'AsciiOrder',
		'CSMacroCharacters',
		'CaseInsensitiveOrder',
		'CaseSensitiveOrder',
		'CrLfExchangeTable',
		'FormatCharacterSet',
		'HtmlEntities',
		'LowercasingTable',
		'Tokenish',
		'UppercasingTable'
	],
	#category : #'Collections-Strings'
}

{ #category : #primitives }
String class >> compare: string1 with: string2 collated: order [
	"Return 1, 2 or 3, if string1 is <, =, or > string2, with the collating order of characters given by the order array."

	| c1 c2 length1 length2 |
	length1 := string1 size.
	length2 := string2 size.
	(order == nil or: [ order == AsciiOrder ]) ifTrue: [ "AsciiOrder is the identity function"
		1 to: (length1 min: length2) do: [ :i |
			(c1 := string1 basicAt: i) = (c2 := string2 basicAt: i) ifFalse: [
				c1 < c2
					ifTrue: [ ^1 ]
					ifFalse: [ ^3 ] ] ].
		length1 = length2 ifTrue: [ ^2 ].
		length1 < length2
			ifTrue: [ ^1 ]
			ifFalse: [ ^3 ] ].
	1 to: (length1 min: length2) do: [ :i |
		(c1 := string1 basicAt: i) < 256 ifTrue: [ c1 := order at: c1 + 1 ].
		(c2 := string2 basicAt: i) < 256 ifTrue: [ c2 := order at: c2 + 1 ].
		c1 = c2 ifFalse:[
			c1 < c2 
				ifTrue: [ ^1 ]
				ifFalse: [ ^3 ] ] ].
	length1 = length2 ifTrue: [ ^2 ].
	length1 < length2
		ifTrue: [ ^1 ]
		ifFalse: [ ^3 ].
]

{ #category : #'instance creation' }
String class >> cr [
	"Answer a string containing a single carriage return character."

	^ self with: Character cr

]

{ #category : #accessing }
String class >> crLfExchangeTable [

	^CrLfExchangeTable
]

{ #category : #'instance creation' }
String class >> crlf [
	"Answer a string containing a carriage return and a linefeed."

	^ self with: Character cr with: Character lf

]

{ #category : #'instance creation' }
String class >> crlfcrlf [
	^self crlf , self crlf.

]

{ #category : #'instance creation' }
String class >> empty [
	"A canonicalized empty String instance."
	^ ''
]

{ #category : #examples }
String class >> example [
	"To see the string displayed at the cursor point, execute this expression
	and select a point by pressing a mouse button."

	'this is some text' displayOn: Display at: Sensor waitButton
]

{ #category : #formatting }
String class >> expandMacro: macroType argument: argument withExpansions: expansions [ 
	macroType = $s ifTrue: [^expansions at: argument].
	macroType = $p ifTrue: [^(expansions at: argument) printString].
	macroType = $n ifTrue: [^String cr].
	macroType = $t ifTrue: [^String tab].
	self error: 'unknown expansion type'
]

{ #category : #primitives }
String class >> findFirstInString: aString inSet: inclusionMap startingAt: start [
	"Trivial, non-primitive version"
	
	| i stringSize ascii |
	inclusionMap size ~= 256 ifTrue: [ ^0 ].
	stringSize := aString size.
	i := start - 1.
	[ (i := i + 1) <= stringSize ] whileTrue: [
		(ascii := aString basicAt: i) < 256 ifTrue: [
			(inclusionMap at: ascii + 1) = 0 ifFalse: [ ^i ] ] ].
	^0
]

{ #category : #'instance creation' }
String class >> fromByteArray: aByteArray [

	^ aByteArray asString

]

{ #category : #'instance creation' }
String class >> fromPacked: aLong [
	"Convert from a longinteger to a String of length 4."

	| s |
	s := self new: 4.
	s at: 1 put: (aLong digitAt: 4) asCharacter.
	s at: 2 put: (aLong digitAt: 3) asCharacter.
	s at: 3 put: (aLong digitAt: 2) asCharacter.
	s at: 4 put: (aLong digitAt: 1) asCharacter.
	^s

"String fromPacked: 'TEXT' asPacked"

]

{ #category : #'instance creation' }
String class >> fromString: aString [ 
	"Answer an instance of me that is a copy of the argument, aString."
	
	^ aString copyFrom: 1 to: aString size
]

{ #category : #accessing }
String class >> htmlEntities [
	
	^ HtmlEntities
]

{ #category : #primitives }
String class >> indexOfAscii: anInteger inString: aString startingAt: start [
	"Trivial, non-primitive version"

	start to: aString size do: [ :index |
		(aString basicAt: index) = anInteger ifTrue: [ ^index ] ].
	^0

]

{ #category : #initialization }
String class >> initialize [   "self initialize"

	| order |
	AsciiOrder := (0 to: 255) as: ByteArray.

	CaseInsensitiveOrder := AsciiOrder copy.
	($a to: $z) do:
		[:c | CaseInsensitiveOrder at: c asciiValue + 1
				put: (CaseInsensitiveOrder at: c asUppercase asciiValue +1)].

	"Case-sensitive compare sorts space, digits, letters, all the rest..."
	CaseSensitiveOrder := ByteArray new: 256 withAll: 255.
	order := -1.
	' 0123456789' do:  "0..10"
		[:c | CaseSensitiveOrder at: c asciiValue + 1 put: (order := order+1)].
	($a to: $z) do:     "11-64"
		[:c | CaseSensitiveOrder at: c asUppercase asciiValue + 1 put: (order := order+1).
		CaseSensitiveOrder at: c asciiValue + 1 put: (order := order+1)].
	1 to: CaseSensitiveOrder size do:
		[:i | (CaseSensitiveOrder at: i) = 255 ifTrue:
			[CaseSensitiveOrder at: i put: (order := order+1)]].
	order = 255 ifFalse: [self error: 'order problem'].

	"a table for translating to lower case"
	LowercasingTable := String withAll: (Character allByteCharacters collect: [:c | c asLowercase]).

	"a table for translating to upper case"
	UppercasingTable := String withAll: (Character allByteCharacters collect: [:c | c asUppercase]).

	"a table for testing tokenish (for fast numArgs)"
	Tokenish := String withAll: (Character allByteCharacters collect:
									[:c | c tokenish ifTrue: [c] ifFalse: [$~]]).
 
	"% and < for #expandMacros*"
	CSMacroCharacters := CharacterSet newFrom: '%<'.

	"{\ used by #format:"
	FormatCharacterSet := CharacterSet newFrom: '{\'.
	
	"a table for exchanging cr with lf and vica versa"
	CrLfExchangeTable := Character allByteCharacters collect: [ :each |
		each
			caseOf: {
				[ Character cr ] -> [ Character lf ].
				[ Character lf ] -> [ Character cr ] }
			otherwise: [ each ] ]
]

{ #category : #initialization }
String class >> initializeHtmlEntities [
	"self initializeHtmlEntities"

	HtmlEntities := (Dictionary new: 128)
		at: 'amp'	put: $&;
		at: 'lt'		put: $<;
		at: 'gt'		put: $>;
		at: 'quot'	put: $";
		at: 'euro'	put: Character euro;
		yourself.
	#('nbsp' 'iexcl' 'cent' 'pound' 'curren' 'yen' 'brvbar' 'sect' 'uml' 'copy' 'ordf' 'laquo' 'not' 'shy' 'reg' 'hibar' 'deg' 'plusmn' 'sup2' 'sup3' 'acute' 'micro' 'para' 'middot' 'cedil' 'sup1' 'ordm' 'raquo' 'frac14' 'frac12' 'frac34' 'iquest' 'Agrave' 'Aacute' 'Acirc' 'Atilde' 'Auml' 'Aring' 'AElig' 'Ccedil' 'Egrave' 'Eacute' 'Ecirc' 'Euml' 'Igrave' 'Iacute' 'Icirc' 'Iuml' 'ETH' 'Ntilde' 'Ograve' 'Oacute' 'Ocirc' 'Otilde' 'Ouml' 'times' 'Oslash' 'Ugrave' 'Uacute' 'Ucirc' 'Uuml' 'Yacute' 'THORN' 'szlig' 'agrave' 'aacute' 'acirc' 'atilde' 'auml' 'aring' 'aelig' 'ccedil' 'egrave' 'eacute' 'ecirc' 'euml' 'igrave' 'iacute' 'icirc' 'iuml' 'eth' 'ntilde' 'ograve' 'oacute' 'ocirc' 'otilde' 'ouml' 'divide' 'oslash' 'ugrave' 'uacute' 'ucirc' 'uuml' 'yacute' 'thorn' 'yuml' ) withIndexDo: [:each :index | HtmlEntities at: each put: (index + 159) asCharacter]
]

{ #category : #'instance creation' }
String class >> lf [
	"Answer a string containing a single carriage return character."

	^ self with: Character lf
]

{ #category : #'instance creation' }
String class >> new: sizeRequested [ 
	"Answer an instance of this class with the number of indexable
	variables specified by the argument, sizeRequested."
	self == String 
		ifTrue:[^ByteString new: sizeRequested]
		ifFalse:[^self basicNew: sizeRequested].
]

{ #category : #'instance creation' }
String class >> readFrom: inStream [
	"Answer an instance of me that is determined by reading the stream, 
	inStream. Embedded double quotes become the quote Character."

	| outStream char done |
	outStream := WriteStream on: (self new: 16).
	"go to first quote"
	inStream skipTo: $'.
	done := false.
	[done or: [inStream atEnd]]
		whileFalse: 
			[char := inStream next.
			char = $'
				ifTrue: 
					[char := inStream next.
					char = $'
						ifTrue: [outStream nextPut: char]
						ifFalse: [done := true]]
				ifFalse: [outStream nextPut: char]].
	^outStream contents
]

{ #category : #'instance creation' }
String class >> space [
	"Answer a string containing a single space character."

	^ self with: Character space

]

{ #category : #primitives }
String class >> stringHash: aString initialHash: speciesHash [
	"Answer the hash of a byte-indexed string, using speciesHash as the initial value.
	 See SmallInteger>>hashMultiply."
	| hash |
	hash := speciesHash bitAnd: 16r0FFFFFFF.
	1 to: aString size do:
		[:pos |
		hash := (hash + (aString basicAt: pos)) hashMultiply].
	^hash
]

{ #category : #'instance creation' }
String class >> tab [
	"Answer a string containing a single tab character."

	^ self with: Character tab

]

{ #category : #primitives }
String class >> translate: aString from: start  to: stop  table: table [
	"Trivial, non-primitive version"

	start to: stop do: [ :i |
		| char |
		(char := aString basicAt: i) < 256 ifTrue: [
			aString at: i put: (table at: char+1) ] ].

]

{ #category : #'instance creation' }
String class >> value: anInteger [

	^ self with: (Character value: anInteger).

]

{ #category : #'instance creation' }
String class >> with: aCharacter [
	| newCollection |
	aCharacter asInteger < 256
		ifTrue:[newCollection := ByteString new: 1]
		ifFalse:[newCollection := WideString new: 1].
	newCollection at: 1 put: aCharacter.
	^newCollection
]

{ #category : #arithmetic }
String >> * arg [

	^ arg adaptToString: self andSend: #*
]

{ #category : #arithmetic }
String >> + arg [

	^ arg adaptToString: self andSend: #+
]

{ #category : #converting }
String >> , anObject [
	"Concatenate the argument to the receiver.
		Transcript cr; show: 'The value is: ', 3.
	"
	^ self copyReplaceFrom: self size + 1
		  to: self size
		  with: anObject asString
]

{ #category : #arithmetic }
String >> - arg [

	^ arg adaptToString: self andSend: #-
]

{ #category : #arithmetic }
String >> / arg [

	^ arg adaptToString: self andSend: #/
]

{ #category : #arithmetic }
String >> // arg [

	^ arg adaptToString: self andSend: #//
]

{ #category : #comparing }
String >> < aString [ 
	"Answer whether the receiver sorts before aString.
	The collation order is simple ascii (with case differences)."

	^(self compareWith: aString) < 0
]

{ #category : #comparing }
String >> <= aString [ 
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is simple ascii (with case differences)."
	
	^(self compareWith: aString) <= 0
]

{ #category : #sorting }
String >> <=> aCharacterArray [
	"Return a collation order of -1, 0, or 1, indicating whether I should be collated before the receiver, am equal, or after.
	See also:  http://en.wikipedia.org/wiki/Spaceship_operator"

	aCharacterArray isString ifTrue: [ ^(self compare: aCharacterArray) - 2 ].
	self = aCharacterArray 	ifTrue: [ ^0 ].
	self < aCharacterArray 	ifTrue: [ ^-1 ].
	^1
]

{ #category : #comparing }
String >> = aString [ 
	"Answer whether the receiver sorts equally as aString.
	The collation order is simple ascii (with case differences)."
	
	self == aString ifTrue: [ ^true ].
	aString isString ifFalse: [ ^false ].
	self size = aString size ifFalse: [ ^false ].
	^ (self compareWith: aString) = 0
]

{ #category : #comparing }
String >> > aString [ 
	"Answer whether the receiver sorts after aString.
	The collation order is simple ascii (with case differences)."

	^(self compareWith: aString) > 0
]

{ #category : #comparing }
String >> >= aString [ 
	"Answer whether the receiver sorts after or equal to aString.
	The collation order is simple ascii (with case differences)."

	^(self compareWith: aString) >= 0
]

{ #category : #arithmetic }
String >> \\ arg [

	^ arg adaptToString: self andSend: #\\
]

{ #category : #converting }
String >> adaptToCollection: rcvr andSend: selector [
	"If I am involved in arithmetic with a collection, convert me to a number."

	^ rcvr perform: selector with: self asNumber
]

{ #category : #converting }
String >> adaptToNumber: rcvr andSend: selector [
	"If I am involved in arithmetic with a number, convert me to a number."

	^ rcvr perform: selector with: self asNumber
]

{ #category : #converting }
String >> adaptToPoint: rcvr andSend: selector [
	"If I am involved in arithmetic with a point, convert me to a number."

	^ rcvr perform: selector with: self asNumber
]

{ #category : #converting }
String >> adaptToString: rcvr andSend: selector [
	"If I am involved in arithmetic with a string, convert us both to
	numbers, and return the printString of the result."

	^ (rcvr asNumber perform: selector with: self asNumber) printString
]

{ #category : #comparing }
String >> alike: aString [ 
	"Answer some indication of how alike the receiver is to the argument,  0 is no match, twice aString size is best score.  Case is ignored."

	| i j k minSize bonus |
	minSize := (j := self size) min: (k := aString size).
	bonus := (j - k) abs < 2 ifTrue: [ 1 ] ifFalse: [ 0 ].
	i := 1.
	[(i <= minSize) and: [((self basicAt: i) bitAnd: 16rDF)  = ((aString basicAt: i) bitAnd: 16rDF)]]
		whileTrue: [ i := i + 1 ].
	[(j > 0) and: [(k > 0) and:
		[((self basicAt: j) bitAnd: 16rDF) = ((aString basicAt: k) bitAnd: 16rDF)]]]
			whileTrue: [ j := j - 1.  k := k - 1. ].
	^ i - 1 + self size - j + bonus. 
]

{ #category : #accessing }
String >> applyLanguageInformation: languageEnvironment [
	
	| leadingChar |
	leadingChar := languageEnvironment leadingChar.
	self withIndexDo: [:each :idx |
		each asciiValue > 255
			ifTrue: [self at: idx put: (Character leadingChar: leadingChar code: each asUnicode)]]
]

{ #category : #converting }
String >> asAscii [
	^ self select: [ : each | each isAscii ]
]

{ #category : #converting }
String >> asByteArray [
	"Convert to a ByteArray with the ascii values of the string."
	| b |
	b := ByteArray new: self byteSize.
	1 to: self size * 4 do: [:i |
		b at: i put: (self byteAt: i).
	].
	^ b.

]

{ #category : #converting }
String >> asByteString [
	"Convert the receiver into a ByteString"
	^self asOctetString
]

{ #category : #converting }
String >> asCamelCase [
	"Convert to CamelCase. Can be convenient 
	in conjunction with #asLegalSelector 
	'A man, a plan, a canal, panama' asCamelCase.
	'A man, a plan, a canal, panama' asCamelCase asLegalSelector.
	'Here 123should % be 6 the name6 of the method' asCamelCase.
	'Here 123should % be 6 the name6 of the method' asCamelCase asLegalSelector."
	
	^ self class streamContents: [:stream | 
		self substrings do: [:sub |
			stream nextPutAll: sub capitalized]]
]

{ #category : #converting }
String >> asCharacter [
	"Answer the receiver's first character, or '*' if none.  Idiosyncratic, provisional."

	^ self size > 0 ifTrue: [self first] ifFalse:[$·]
]

{ #category : #converting }
String >> asDecomposedUnicode [
	"Convert the receiver into a decomposed Unicode representation.
	Optimized for the common case that no decomposition needs to take place."
	| lastIndex nextIndex out decomposed |
	lastIndex := 1.
	nextIndex := 0.
	[(nextIndex := nextIndex+1) <= self size] whileTrue:[
		decomposed := Unicode decompose: (self at: nextIndex).
		decomposed ifNotNil:[
			lastIndex = 1 ifTrue:[out := WriteStream on: (String new: self size)].
			out nextPutAll: (self copyFrom: lastIndex to: nextIndex-1).
			out nextPutAll: decomposed.
			lastIndex := nextIndex+1.
		].
	].
	^out ifNil:[self] ifNotNil:[
		out nextPutAll: (self copyFrom: lastIndex to: self size).
		out contents]
]

{ #category : #converting }
String >> asDisplayText [
	"Answer a DisplayText whose text string is the receiver."

	^DisplayText text: self asText
]

{ #category : #'user interface' }
String >> asExplorerString [

	^ self printString
]

{ #category : #converting }
String >> asFileName [
	"Answer a String made up from the receiver that is an acceptable file base
	name. Does not produce corrected fulll paths if the directory separator etc are included"

	| string checkedString |
	string := FileDirectory checkName: self fixErrors: true.
	checkedString := (FilePath pathName: string) asVmPathName.
	^ (FilePath pathName: checkedString isEncoded: true) asSqueakPathName.

]

{ #category : #converting }
String >> asFourCode [

	| result |
	self size = 4 ifFalse: [^self error: 'must be exactly four characters'].
	result := self inject: 0 into: [:val :each | 256 * val + each asciiValue].
	(result bitAnd: 16r80000000) = 0 
		ifFalse: [self error: 'cannot resolve fourcode'].
	(result bitAnd: 16r40000000) = 0 ifFalse: [^result - 16r80000000].
	^ result

]

{ #category : #converting }
String >> asHex [
	| stream |
	stream := WriteStream on: (String new: self size * 4).
	self do: [ :ch | stream nextPutAll: ch hex ].
	^stream contents
]

{ #category : #converting }
String >> asHtml [
	"Do the basic character conversion for HTML.  Leave all original return 
	and tabs in place, so can conver back by simply removing bracked 
	things. 4/4/96 tk"
	| temp |
	temp := self copyReplaceAll: '&' with: '&amp;'.
	HtmlEntities keysAndValuesDo:
		[:entity :char |
		char = $& ifFalse:
			[temp := temp copyReplaceAll: char asString with: '&' , entity , ';']].
	temp := temp copyReplaceAll: '	' with: '	<IMG SRC="tab.gif" ALT="    ">'.
	temp := temp copyReplaceAll: '
' with: '
<BR>'.
	^ temp

"
	'A<&>B' asHtml
"
]

{ #category : #converting }
String >> asIdentifier: shouldBeCapitalized [
	"Return a legal identifier, with first character in upper case if shouldBeCapitalized is true, else lower case.  This will always return a legal identifier, even for an empty string"

	| aString firstChar firstLetterPosition |
	aString := self select: [:el | el isAlphaNumeric].
	firstLetterPosition := aString findFirst: [:ch | ch isLetter].
	aString := firstLetterPosition = 0
		ifFalse:
			[aString copyFrom: firstLetterPosition to: aString size]
		ifTrue:
			['a', aString].
	firstChar := shouldBeCapitalized ifTrue: [aString first asUppercase] ifFalse: [aString first asLowercase].

	^ firstChar asString, (aString copyFrom: 2 to: aString size)
"
'234Fred987' asIdentifier: false
'235Fred987' asIdentifier: true
'' asIdentifier: true
'()87234' asIdentifier: false
'())z>=PPve889  U >' asIdentifier: false

"
]

{ #category : #converting }
String >> asInteger [ 
	
	^self asIntegerSigned: true

]

{ #category : #converting }
String >> asIntegerSigned: signed [
	"Return the first decimal integer I can find or nil."

	| index character size result negative |
	index := 0.
	size := self size.
	"Find the first character between $0 and $9."
	[ (index := index + 1) > size or: [ (self at: index) isDigit ] ] whileFalse.
	index > size ifTrue: [ ^nil ].
	negative := signed and: [ index > 1 and: [ (self at: index - 1) == $- ] ].
	"Parse the number."
	size - index > 15 ifTrue: [
		negative ifTrue: [ index := index - 1 ].
		^Integer readFrom: (
			ReadStream
				on: self
				from: index
				to: size) ].
	result := (self at: index) digitValue.
	[ (index := index + 1) <= size
		and: [ (character := self at: index) isDigit ] ]  whileTrue: [
		result := result * 10 + character digitValue ].
	negative ifTrue: [ ^result negated ].
	^result
]

{ #category : #converting }
String >> asLegalSelector [
	| toUse |
	toUse := self select: [:char | char isAlphaNumeric].
	(toUse size = 0 or: [toUse first isLetter not])
		ifTrue: [toUse := 'v', toUse].
	^ toUse withFirstCharacterDownshifted
]

{ #category : #converting }
String >> asLowercase [
	"Answer a String made up from the receiver whose characters are all 
	lowercase."

	^ self copy asString translateToLowercase
]

{ #category : #converting }
String >> asNumber [ 
	"Answer the Number created by interpreting the receiver as the string 
	representation of a number."

	^Number readFromString: self
]

{ #category : #converting }
String >> asOctetString [
	"Convert the receiver into an octet string if possible. The resulting string will contain 
	only bytes if all characters fit into bytes. If there is any character > 255 the resulting
	string will be a WideString instead."
	| string |
	string := String new: self size.
	1 to: self size do: [:i | string at: i put: (self at: i)].
	^string
]

{ #category : #converting }
String >> asPacked [
	"Convert to a longinteger that describes the string"

	^ self inject: 0 into: [ :pack :next | pack * 256 + next asInteger ].
]

{ #category : #converting }
String >> asPluralBasedOn: aNumberOrCollection [
	"Append an 's' to this string based on whether aNumberOrCollection is 1 or of size 1."

	^ (aNumberOrCollection = 1 or:
		[aNumberOrCollection isCollection and: [aNumberOrCollection size = 1]])
			ifTrue: [self]
			ifFalse: [self, 's']

]

{ #category : #converting }
String >> asPrecomposedUnicode [
	"Convert the receiver into a precomposed Unicode representation.
	Optimized for the common case that no composition needs to take place."
	| lastIndex nextIndex composed out |
	lastIndex := 1.
	nextIndex := 0.
	[(nextIndex := nextIndex+1) < self size] whileTrue:[
		composed := Unicode compose: (self at: nextIndex) with: (self at: nextIndex+1).
		composed ifNotNil:[
			lastIndex = 1 ifTrue:[out := WriteStream on: (String new: self size)].
			out nextPutAll: (self copyFrom: lastIndex to: nextIndex-1).
			out nextPut: composed.
			nextIndex := nextIndex+1.
			lastIndex := nextIndex+1.
		].
	].
	^out ifNil:[self] ifNotNil:[
		out nextPutAll: (self copyFrom: lastIndex to: self size).
		out contents]
]

{ #category : #converting }
String >> asSignedInteger [
	"Return the first signed integer I can find or nil."
	
	^self asIntegerSigned: true
]

{ #category : #converting }
String >> asSmalltalkComment [
	"return this string, munged so that it can be treated as a comment in Smalltalk code.  Quote marks are added to the beginning and end of the string, and whenever a solitary quote mark appears within the string, it is doubled"

	^String streamContents:  [ :str |
		| quoteCount first |

		str nextPut: $".
	
		quoteCount := 0.
		first := true.
		self do: [ :char |
			char = $"
				ifTrue: [
					first ifFalse: [
						str nextPut: char.
						quoteCount := quoteCount + 1 ] ]
				ifFalse: [
					quoteCount odd ifTrue: [
						"add a quote to even the number of quotes in a row"
						str nextPut: $" ].
					quoteCount := 0.
					str nextPut: char ].
			first := false ]. 

		quoteCount odd ifTrue: [
			"check at the end"
			str nextPut: $". ].

		str nextPut: $".
	].
	
]

{ #category : #converting }
String >> asSqueakPathName [

	^ self.

]

{ #category : #converting }
String >> asString [
	"Answer this string."

	^ self

]

{ #category : #converting }
String >> asStringOrText [
	"Answer this string."

	^ self

]

{ #category : #converting }
String >> asSymbol [
	"Answer the unique Symbol whose characters are the characters of the 
	string."
	^Symbol intern: self
]

{ #category : #converting }
String >> asText [
	"Answer a Text whose string is the receiver."

	^Text fromString: self
]

{ #category : #converting }
String >> asTextFromHtml [
	"Answer a Text by interpreting the receiver as HTML."

	^ (HtmlReadWriter on: self readStream) nextText
]

{ #category : #converting }
String >> asTime [
	"Many allowed forms, see Time>>readFrom:"

	^ Time fromString: self.
]

{ #category : #converting }
String >> asTimeStamp [
	"Convert from obsolete TimeStamp format"

	^ TimeStamp fromString: self
]

{ #category : #converting }
String >> asUnHtml [
	"Strip out all Html stuff (commands in angle brackets <>) and convert
the characters &<> back to their real value.  Leave actual cr and tab as
they were in text."
	| in out char rest |
	in := ReadStream on: self.
	out := WriteStream on: (String new: self size).
	[in atEnd] whileFalse:
		[in peek = $<
			ifTrue: [in unCommand] 	"Absorb <...><...>"
			ifFalse: [(char := in next) = $&
						ifTrue: [rest := in upTo: $;.
								out nextPut: (HtmlEntities
									at: rest
									ifAbsent: [
										(rest beginsWith: '#')
											ifTrue: [Character value: rest allButFirst asInteger]
											ifFalse: [Character space]])]
						ifFalse: [out nextPut: char]].
		].
	^ out contents
]

{ #category : #converting }
String >> asUnsignedInteger [ 
	"Returns the first unsigned integer I can find or nil."

	^self asIntegerSigned: false
]

{ #category : #converting }
String >> asUppercase [
	"Answer a String made up from the receiver whose characters are all 
	uppercase."

	^self copy asString translateToUppercase
]

{ #category : #converting }
String >> asVmPathName [

	^ (FilePath pathName: self) asVmPathName.

]

{ #category : #converting }
String >> asWideString [ 
	self isWideString
		ifTrue:[^self]
		ifFalse:[^WideString from: self]
]

{ #category : #converting }
String >> ascii85Decoded [
	"Decode the receiver from Ascii85"
	"'<~87cURD]i,""Ebo7~>' ascii85Decoded"

	^ self ascii85DecodedAs: self class

]

{ #category : #converting }
String >> ascii85DecodedAs: aClass [
	"Decode the receiver from Ascii85"
	"'<~87cURD]i,""Ebo7~>' ascii85DecodedAs: String"

	^ Ascii85Converter decode: self as: aClass
]

{ #category : #converting }
String >> ascii85Encoded [
	"Encode the receiver as Ascii85"
	"'Hello World' ascii85Encoded"

	^ (Ascii85Converter encode: self readStream) contents

]

{ #category : #converting }
String >> askIfAddStyle: priorMethod req: requestor [
	^ self   "we are a string with no text style"
]

{ #category : #converting }
String >> base64Decoded [
	"Decode the receiver from base 64"
	"'SGVsbG8gV29ybGQ=' base64Decoded"
	^(Base64MimeConverter mimeDecode: self as: self class)
]

{ #category : #converting }
String >> base64Encoded [
	"Encode the receiver as base64"
	"'Hello World' base64Encoded"

	^(Base64MimeConverter
		mimeEncode: (ReadStream on: self)
		multiLine: false) contents
]

{ #category : #testing }
String >> beginsWith: sequence [
	"Answer true if the receiver starts with the argument collection. The comparison is case-sensitive. Overridden for better performance."

	| index sequenceSize |
	sequence isString ifFalse: [ ^super beginsWith: sequence ].
	((sequenceSize := sequence size) = 0 or: [ self size < sequenceSize ]) ifTrue: [ ^false ].
	index := 0.
	[ (index := index + 1) <= sequenceSize ] whileTrue: [
		(sequence at: index) == (self at: index) ifFalse: [ ^false ] ].
	^true
]

{ #category : #accessing }
String >> byteAt: index [
	^self subclassResponsibility
]

{ #category : #accessing }
String >> byteAt: index put: value [
	^self subclassResponsibility
]

{ #category : #'filter streaming' }
String >> byteEncode:aStream [

	^aStream writeString: self.

]

{ #category : #accessing }
String >> byteSize [
	^self subclassResponsibility
]

{ #category : #testing }
String >> canBeToken [
	"Extracted from #numArgs to allow specialization by subclasses"
	
	^ self allSatisfy: [:c | c tokenish]
]

{ #category : #converting }
String >> capitalized [
	"Return a copy with the first letter capitalized"
	| cap |
	self isEmpty ifTrue: [ ^self copy ].
	cap := self copy.
	cap at: 1 put: (cap at: 1) asUppercase.
	^ cap
]

{ #category : #comparing }
String >> caseInsensitiveLessOrEqual: aString [ 
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is case insensitive."
	^(self compare: aString caseSensitive: false) <= 2
]

{ #category : #comparing }
String >> caseSensitiveLessOrEqual: aString [ 
	"Answer whether the receiver sorts before or equal to aString.
	The collation order is case sensitive."
	^(self compare: aString caseSensitive: true) <= 2
]

{ #category : #comparing }
String >> charactersExactlyMatching: aString [
	"Do a character-by-character comparison between the receiver and aString.  Return the index of the final character that matched exactly."

	| count |
	count := self size min: aString size.
	1 to: count do: [:i | 
		(self at: i) = (aString at: i) ifFalse: [
			^ i - 1]].
	^ count
]

{ #category : #enumerating }
String >> combinations: kk atATimeDo: aBlock [
	"Gather the combinations into a String rather than an Array"
	
	" 'abcde' combinations: 3 atATimeDo: [:each | Transcript cr; show: each printString]"

	| aCollection |
	aCollection := String new: kk.
	self combinationsAt: 1 in: aCollection after: 0 do: aBlock
]

{ #category : #comparing }
String >> compare: aString [ 
	"Answer a comparison code telling how the receiver sorts relative to aString:
		1 - before
		2 - equal
		3 - after.
	The collation sequence is ascii with case differences ignored.
	To get the effect of a <= b, but ignoring case, use (a compare: b) <= 2."
	^self compare: aString caseSensitive: false
]

{ #category : #comparing }
String >> compare: aString caseSensitive: aBool [
	"Answer a comparison code telling how the receiver sorts relative to aString:
		1 - before
		2 - equal
		3 - after.
	"
	| map result |
	map := aBool ifTrue:[CaseSensitiveOrder] ifFalse:[CaseInsensitiveOrder].
	result := self compareWith: aString collated: map.
	result = 0 ifTrue: [ ^2 ].
	^result > 0
		ifTrue: [ 3 ]
		ifFalse: [ 1 ]
]

{ #category : #comparing }
String >> compare: string1 with: string2 collated: order [

	(string1 isByteString and: [string2 isByteString]) ifTrue: [
		^ ByteString compare: string1 with: string2 collated: order
	].
     "Primitive does not fail properly right now"
      ^ String compare: string1 with: string2 collated: order

"
self assert: 'abc' = 'abc' asWideString.
self assert: 'abc' asWideString = 'abc'.
self assert: ((ByteArray with: 97 with: 0 with: 0 with: 0) asString ~= 'a000' asWideString).
self assert: ('a000' asWideString ~= (ByteArray with: 97 with: 0 with: 0 with: 0) asString).

self assert: ('abc' sameAs: 'aBc' asWideString).
self assert: ('aBc' asWideString sameAs: 'abc').
self assert: ((ByteArray with: 97 with: 0 with: 0 with: 0) asString sameAs: 'Abcd' asWideString) not.
self assert: ('a000' asWideString sameAs: (ByteArray with: 97 with: 0 with: 0 with: 0) asString) not.

"
]

{ #category : #comparing }
String >> compareWith: aString [

	"<primitive: 158>"
	^self compareWith: aString collated: AsciiOrder
]

{ #category : #comparing }
String >> compareWith: aString collated: collation [

	<primitive: 158>
	^(self compare: self with: aString collated: collation) - 2
]

{ #category : #converting }
String >> compressWithTable: tokens [
	"Return a string with all substrings that occur in tokens replaced
	by a character with ascii code = 127 + token index.
	This will work best if tokens are sorted by size.
	Assumes this string contains no characters > 127, or that they
	are intentionally there and will not interfere with this process."
	| str null finalSize result ri c |
	null := Character null.
	str := self copyFrom: 1 to: self size.  "Working string will get altered"
	finalSize := str size.
	tokens doWithIndex:
		[:token :tIndex |
		| start ts |
		start := 1.
		[(start := str findString: token startingAt: start) > 0]
			whileTrue:
			[ts := token size.
			((start + ts) <= str size
				and: [(str at: start + ts) = $  and: [tIndex*2 <= 128]])
				ifTrue: [ts := token size + 1.  "include training blank"
						str at: start put: (Character value: tIndex*2 + 127)]
				ifFalse: [str at: start put: (Character value: tIndex + 127)].
			str at: start put: (Character value: tIndex + 127).
			1 to: ts-1 do: [:i | str at: start+i put: null].
			finalSize := finalSize - (ts - 1).
			start := start + ts]].
	result := String new: finalSize.
	ri := 0.
	1 to: str size do:
		[:i | (c := str at: i) = null ifFalse: [result at: (ri := ri+1) put: c]].
	^ result
]

{ #category : #converting }
String >> condensedIntoOneLine [
	"Return a copy of the receiver with all separators converted to spaces, and with no consecutive spaces.  A formatting tool."
	^ String streamContents:
		[ : stream | | prior |
		prior := $X.  "some non-separator"
		self do:
			[ : char | char isSeparator ifTrue: [ prior isSeparator ifFalse: [stream space]] ifFalse: [ stream nextPut: char ].
			prior := char ] ]
]

{ #category : #converting }
String >> contractTo: smallSize [
	"return myself or a copy shortened by ellipsis to smallSize"
	| leftSize |
	self size <= smallSize
		ifTrue: [^ self].  "short enough"
	smallSize < 5
		ifTrue: [^ self copyFrom: 1 to: smallSize].    "First N characters"
	leftSize := smallSize-2//2.
	^ self copyReplaceFrom: leftSize+1		"First N/2 ... last N/2"
		to: self size - (smallSize - leftSize - 3)
		with: '...'
"
	'A clear but rather long-winded summary' contractTo: 18
"
]

{ #category : #converting }
String >> convertFromEncoding: encodingName [
	^self convertFromWithConverter: (TextConverter newForEncoding: encodingName)
]

{ #category : #converting }
String >> convertFromSuperSwikiServerString [
	^self convertFromEncoding: 'shift_jis'
]

{ #category : #converting }
String >> convertFromWithConverter: converter [

	^(converter ifNil: [ ^self]) decodeString: self
]

{ #category : #converting }
String >> convertToEncoding: encodingName [
	^self convertToWithConverter: (TextConverter newForEncoding: encodingName).
]

{ #category : #converting }
String >> convertToSuperSwikiServerString [
	^self convertToEncoding: 'shift_jis'
]

{ #category : #converting }
String >> convertToSystemString [
	^self convertToWithConverter: LanguageEnvironment defaultSystemConverter
]

{ #category : #converting }
String >> convertToWithConverter: converter [ 

	^(converter ifNil: [ ^self]) encodeString: self
]

{ #category : #copying }
String >> copyReplaceTokens: oldSubstring with: newSubstring [ 
	"Replace all occurrences of oldSubstring that are surrounded
	by non-alphanumeric characters"
	^ self copyReplaceAll: oldSubstring with: newSubstring asTokens: true
	"'File asFile Files File''s File' copyReplaceTokens: 'File' with: 'Snick'"
]

{ #category : #converting }
String >> correctAgainst: wordList [
	"Correct the receiver: assume it is a misspelled word and return the (maximum of five) nearest words in the wordList.  Depends on the scoring scheme of alike:"
	| results |
	results := self correctAgainst: wordList continuedFrom: nil.
	results := self correctAgainst: nil continuedFrom: results.
	^ results
]

{ #category : #converting }
String >> correctAgainst: wordList continuedFrom: oldCollection [
	"Like correctAgainst:.  Use when you want to correct against several lists, give nil as the first oldCollection, and nil as the last wordList."

	^self
		correctAgainstEnumerator: (
			wordList ifNotNil: [ 
				[ :action | wordList do: action without: nil ] ])
		continuedFrom: oldCollection
]

{ #category : #converting }
String >> correctAgainstDictionary: wordDict continuedFrom: oldCollection [
	"Like correctAgainst:continuedFrom:.  Use when you want to correct against a dictionary."

	^self
		correctAgainstEnumerator: (
			wordDict ifNotNil: [
				[ :action | wordDict keysDo: action ] ])
		continuedFrom: oldCollection
]

{ #category : #private }
String >> correctAgainstEnumerator: wordBlock continuedFrom: oldCollection [
	"The guts of correction, instead of a wordList, there is a block that should take another block and enumerate over some list with it."

	| choices results maxChoices scoreMin |
	scoreMin := self size // 2 min: 3.
	maxChoices := 10.
	choices := oldCollection ifNil: [
		SortedCollection sortBlock: [ :x :y | x value > y value ] ].
	wordBlock
		ifNil: [ 
			results := OrderedCollection new.
			1 to: (maxChoices min: choices size) do: [ :i | results add: (choices at: i) key ] ]
		ifNotNil: [ 
			wordBlock
				value: [ :word | 
					| score |
					(score := self alike: word) >= scoreMin
						ifTrue: [ 
							choices add: (Association key: word value: score).
							choices size >= maxChoices
								ifTrue: [ scoreMin := (choices at: maxChoices) value ] ] ].
			results := choices ].
	^ results
]

{ #category : #comparing }
String >> crc16 [
	"Compute a 16 bit cyclic redundancy check."

	| crc |
	crc := 0.
	1 to: self byteSize do: [:i |
		crc := (crc bitShift: -8) bitXor: (
		 #(	16r0000	16rC0C1	16rC181	16r0140	16rC301	16r03C0	16r0280	16rC241
			16rC601	16r06C0	16r0780	16rC741	16r0500	16rC5C1	16rC481	16r0440
			16rCC01	16r0CC0	16r0D80	16rCD41	16r0F00	16rCFC1	16rCE81	16r0E40
			16r0A00	16rCAC1	16rCB81	16r0B40	16rC901	16r09C0	16r0880	16rC841
			16rD801	16r18C0	16r1980	16rD941	16r1B00	16rDBC1	16rDA81	16r1A40
			16r1E00	16rDEC1	16rDF81	16r1F40	16rDD01	16r1DC0	16r1C80	16rDC41
			16r1400	16rD4C1	16rD581	16r1540	16rD701	16r17C0	16r1680	16rD641
			16rD201	16r12C0	16r1380	16rD341	16r1100	16rD1C1	16rD081	16r1040
			16rF001	16r30C0	16r3180	16rF141	16r3300	16rF3C1	16rF281	16r3240
			16r3600	16rF6C1	16rF781	16r3740	16rF501	16r35C0	16r3480	16rF441
			16r3C00	16rFCC1	16rFD81	16r3D40	16rFF01	16r3FC0	16r3E80	16rFE41
			16rFA01	16r3AC0	16r3B80	16rFB41	16r3900	16rF9C1	16rF881	16r3840
			16r2800	16rE8C1	16rE981	16r2940	16rEB01	16r2BC0	16r2A80	16rEA41
			16rEE01	16r2EC0	16r2F80	16rEF41	16r2D00	16rEDC1	16rEC81	16r2C40
			16rE401	16r24C0	16r2580	16rE541	16r2700	16rE7C1	16rE681	16r2640
			16r2200	16rE2C1	16rE381	16r2340	16rE101	16r21C0	16r2080	16rE041
			16rA001	16r60C0	16r6180	16rA141	16r6300	16rA3C1	16rA281	16r6240
			16r6600	16rA6C1	16rA781	16r6740	16rA501	16r65C0	16r6480	16rA441
			16r6C00	16rACC1	16rAD81	16r6D40	16rAF01	16r6FC0	16r6E80	16rAE41
			16rAA01	16r6AC0	16r6B80	16rAB41	16r6900	16rA9C1	16rA881	16r6840
			16r7800	16rB8C1	16rB981	16r7940	16rBB01	16r7BC0	16r7A80	16rBA41
			16rBE01	16r7EC0	16r7F80	16rBF41	16r7D00	16rBDC1	16rBC81	16r7C40
			16rB401	16r74C0	16r7580	16rB541	16r7700	16rB7C1	16rB681	16r7640
			16r7200	16rB2C1	16rB381	16r7340	16rB101	16r71C0	16r7080	16rB041
			16r5000	16r90C1	16r9181	16r5140	16r9301	16r53C0	16r5280	16r9241
			16r9601	16r56C0	16r5780	16r9741	16r5500	16r95C1	16r9481	16r5440
			16r9C01	16r5CC0	16r5D80	16r9D41	16r5F00	16r9FC1	16r9E81	16r5E40
			16r5A00	16r9AC1	16r9B81	16r5B40	16r9901	16r59C0	16r5880	16r9841
			16r8801	16r48C0	16r4980	16r8941	16r4B00	16r8BC1	16r8A81	16r4A40
			16r4E00	16r8EC1	16r8F81	16r4F40	16r8D01	16r4DC0	16r4C80	16r8C41
			16r4400	16r84C1	16r8581	16r4540	16r8701	16r47C0	16r4680	16r8641
			16r8201	16r42C0	16r4380	16r8341	16r4100	16r81C1	16r8081	16r4040)
			 at: ((crc bitXor: (self byteAt: i)) bitAnd: 16rFF) + 1) ].
	^crc
]

{ #category : #internet }
String >> decodeMimeHeader [
	"See RFC 2047, MIME Part Three: Message Header Extension for Non-ASCII  
	Text and RFC 1342. Text containing non-ASCII characters is encoded by the sequence  
	=?character-set?encoding?encoded-text?=  
	Encoding is Q (quoted printable) or B (Base64), handled by  
	Base64MimeConverter / QEncodingMimeConverter.

	Thanks to Yokokawa-san, it works in m17n package.  Try the following:

	'=?ISO-2022-JP?B?U1dJS0lQT1AvGyRCPUJDKyVpJXMlQRsoQi8=?= =?ISO-2022-JP?B?GyRCJVElRiUjJSobKEIoUGF0aW8p?=' decodeMimeHeader.
"
	| input output temp charset decoder encodedStream encoding pos |
	input := ReadStream on: self.
	output := WriteStream on: String new.
	[output
		nextPutAll: (input upTo: $=).
	"ASCII Text"
	input atEnd]
		whileFalse: [(temp := input next) = $?
				ifTrue: [charset := input upTo: $?.
					encoding := (input upTo: $?) asUppercase.
					temp := input upTo: $?.
					input next.
					"Skip final ="
					(charset isNil or: [charset size = 0]) ifTrue: [charset := 'LATIN-1'].
					encodedStream := WriteStream on: String new.
					decoder := encoding = 'B'
								ifTrue: [Base64MimeConverter new]
								ifFalse: [QEncodingMimeConverter new].
					decoder
						mimeStream: (ReadStream on: temp);
						 dataStream: encodedStream;
						 mimeDecode.
					
					output nextPutAll: (MultiByteBinaryOrTextStream with: encodedStream contents encoding: charset) contents.
					pos := input position.
					input skipSeparators.
					"Delete spaces if followed by ="
					input peek = $=
						ifFalse: [input position: pos]]
				ifFalse: [output nextPut: $=;
						 nextPut: temp]].
	^ output contents
]

{ #category : #internet }
String >> decodeQuotedPrintable [
	"Assume receiver is in MIME 'quoted-printable' encoding, and decode it."
  
	^QuotedPrintableMimeConverter mimeDecode: self as: self class
]

{ #category : #copying }
String >> deepCopy [
	"DeepCopy would otherwise mean make a copy of the character;  since 
	characters are unique, just return a shallowCopy."

	^self shallowCopy
]

{ #category : #displaying }
String >> displayAt: aPoint [ 
	"Display the receiver as a DisplayText at aPoint on the display screen."

	self displayOn: Display at: aPoint
]

{ #category : #displaying }
String >> displayOn: aDisplayMedium [
	"Display the receiver on the given DisplayMedium.  5/16/96 sw"

	self displayOn: aDisplayMedium at: 0 @ 0
]

{ #category : #displaying }
String >> displayOn: aDisplayMedium at: aPoint [ 
	"Show a representation of the receiver as a DisplayText at location aPoint on aDisplayMedium, using black-colored text."

	self displayOn: aDisplayMedium at: aPoint textColor: Color black
]

{ #category : #displaying }
String >> displayOn: aDisplayMedium at: aPoint textColor: aColor [
	"Show a representation of the receiver as a DisplayText at location aPoint on aDisplayMedium, rendering the text in the designated color"

	(self asDisplayText foregroundColor: (aColor ifNil: [Color black]) backgroundColor: Color white)
		displayOn: aDisplayMedium at: aPoint
]

{ #category : #accessing }
String >> do: aBlock toFieldNumber: aNumber [
	"Considering the receiver as a holder of tab-delimited fields, evaluate aBlock on behalf of a field in this string"

	| start end index |
	start := 1.
	index := 1.
	[start <= self size] whileTrue: 
		[end := self indexOf: Character tab startingAt: start ifAbsent: [self size + 1].
		end := end - 1.
		aNumber = index ifTrue:
			[aBlock value: (self copyFrom: start  to: end).
			^ self].
		index := index + 1.
		start := end + 2]

"
1 to: 6 do:
	[:aNumber |
		'fred	charlie	elmo		wimpy	friml' do:
			[:aField | Transcript cr; show: aField] toFieldNumber: aNumber]
"
]

{ #category : #printing }
String >> encodeDoublingQuoteOn: aStream [ 
	"Print inside string quotes, doubling inbedded quotes."
	| x |
	aStream print: $'.
	1 to: self size do:
		[:i |
		aStream print: (x := self at: i).
		x = $' ifTrue: [aStream print: x]].
	aStream print: $'
]

{ #category : #converting }
String >> encodeForHTTP [
	"change dangerous characters to their %XX form, for use in HTTP transactions"

	^ self encodeForHTTPWithTextEncoding: 'utf-8' conditionBlock: [:c | c isSafeForHTTP].

]

{ #category : #converting }
String >> encodeForHTTPWithTextEncoding: encodingName [

	^ self encodeForHTTPWithTextEncoding: encodingName conditionBlock: [:c | c isSafeForHTTP].

]

{ #category : #converting }
String >> encodeForHTTPWithTextEncoding: encodingName conditionBlock: conditionBlock [
	"change dangerous characters to their %XX form, for use in HTTP transactions"

	| httpSafeStream encodedStream |
	httpSafeStream := WriteStream on: (String new).
	encodedStream := MultiByteBinaryOrTextStream on: (String new: 6).
	encodedStream converter: (TextConverter newForEncoding: encodingName).
	self do: [:c | | cont |
		(conditionBlock value: c)
			ifTrue: [httpSafeStream nextPut: (Character value: c charCode)]
			ifFalse: [
				encodedStream text; resetToStart.
				encodedStream nextPut: c.
				encodedStream position: 0.
				encodedStream binary.
				cont := encodedStream contents.
				cont do: [:byte |
					httpSafeStream nextPut: $%.
					httpSafeStream nextPut: (byte // 16) asHexDigit.
					httpSafeStream nextPut: (byte \\ 16) asHexDigit.
				].
			].
	].
	^ httpSafeStream contents.

]

{ #category : #testing }
String >> endsWith: sequence [
	"Answer true if the receiver ends with the argument collection. The comparison is case-sensitive."
	
	| index sequenceSize offset |
	sequence isString ifFalse: [ ^super endsWith: sequence ].
	(sequenceSize := sequence size) = 0 ifTrue: [ ^false ]. "old convention"
	(offset := self size - sequenceSize) < 0 ifTrue: [ ^false ].
	index := 0.
	[ (index := index + 1) <= sequenceSize ] whileTrue: [
		(sequence at: index) == (self at: index + offset) ifFalse: [ ^false ] ].
	^true
]

{ #category : #testing }
String >> endsWithAColon [ 
	"Answer whether the final character of the receiver is a colon"

	^ self size > 0 and: [self last == $:]

"
#fred: endsWithAColon
'fred' endsWithAColon
"
]

{ #category : #testing }
String >> endsWithAnyOf: aCollection [
	aCollection do:[:suffix|
		(self endsWith: suffix) ifTrue:[^true].
	].
	^false
]

{ #category : #testing }
String >> endsWithDigit [
	"Answer whether the receiver's final character represents a digit.  3/11/96 sw"

	^ self size > 0 and: [self last isDigit]
]

{ #category : #formatting }
String >> expandMacros [
	^self expandMacrosWithArguments: #()
]

{ #category : #formatting }
String >> expandMacrosWith: anObject [ 
	^self expandMacrosWithArguments: (Array with: anObject)
]

{ #category : #formatting }
String >> expandMacrosWith: anObject with: anotherObject [ 
	^self 
		expandMacrosWithArguments: (Array with: anObject with: anotherObject)
]

{ #category : #formatting }
String >> expandMacrosWith: anObject with: anotherObject with: thirdObject [ 
	^self expandMacrosWithArguments: (Array 
				with: anObject
				with: anotherObject
				with: thirdObject)
]

{ #category : #formatting }
String >> expandMacrosWith: anObject with: anotherObject with: thirdObject with: fourthObject [ 
	^self expandMacrosWithArguments: (Array 
				with: anObject
				with: anotherObject
				with: thirdObject
				with: fourthObject)
]

{ #category : #formatting }
String >> expandMacrosWithArguments: anArray [ 
	
	^self class new: self size streamContents: [ :output |
		| lastIndex nextIndex |
		lastIndex := 1.
		[ (nextIndex := self indexOfAnyOf: CSMacroCharacters startingAt: lastIndex) = 0 ] whileFalse: [
			nextIndex = lastIndex ifFalse: [
				output next: nextIndex - lastIndex putAll: self startingAt: lastIndex ].
			(self at: nextIndex) == $% 
				ifTrue: [ output nextPut: (self at: (nextIndex := nextIndex + 1)) ]
				ifFalse: [ 
					| nextCharacter argumentIndex |
					nextCharacter := (self at: (nextIndex := nextIndex + 1)) asUppercase.
					nextCharacter == $N ifTrue: [ output cr ].
					nextCharacter == $T ifTrue: [ output tab ].
					(nextCharacter between: $0 and: $9) ifTrue: [
						argumentIndex := nextCharacter digitValue.
						[ (nextIndex := nextIndex + 1) <= self size and: [
							(nextCharacter := self at: nextIndex) between: $0 and: $9 ] ] whileTrue: [
								argumentIndex := argumentIndex * 10 + nextCharacter digitValue ].
						nextCharacter := nextCharacter asUppercase ].
					nextCharacter == $P ifTrue: [ output print: (anArray at: argumentIndex) ].
					nextCharacter == $S ifTrue: [ output nextPutAll: (anArray at: argumentIndex) ].
					nextCharacter == $? ifTrue: [ 
						| trueEnd falseEnd |
						trueEnd := self indexOf: $: startingAt: nextIndex + 1.
						falseEnd := self indexOf: $> startingAt: trueEnd + 1.
						(anArray at: argumentIndex)
							ifTrue: [ output next: trueEnd - nextIndex - 1 putAll: self startingAt: nextIndex + 1 ]
							ifFalse: [ output next: falseEnd - trueEnd - 1 putAll: self startingAt: trueEnd + 1 ].
						nextIndex := falseEnd - 1 ].
					(self at: (nextIndex := nextIndex + 1)) == $> ifFalse: [
						self error: '> expected' ] ].
			lastIndex := nextIndex + 1 ].
		lastIndex <= self size ifTrue: [
			output next: self size - lastIndex + 1 putAll: self startingAt: lastIndex ] ]
]

{ #category : #accessing }
String >> findAnySubStr: delimiters startingAt: start [ 
	"Answer the index of the character within the receiver, starting at start, that begins a substring matching one of the delimiters.  delimiters is an Array of Strings (Characters are permitted also).  If the receiver does not contain any of the delimiters, answer size + 1."

	^delimiters inject: 1 + self size into: [:min :delim |
		"delim may be a char, a string of length 1, or a substring"
		| ind |
		ind := delim isCharacter 
			ifTrue: [self indexOf: delim
						startingAt: start ifAbsent: [min]]
			ifFalse: [self indexOfSubCollection: delim 
						startingAt: start ifAbsent: [min]].
		min min: ind]
]

{ #category : #accessing }
String >> findBetweenSubStrs: delimiters [
	"Answer the collection of String tokens that result from parsing self.  Tokens are separated by 'delimiters', which can be a collection of Strings, or a collection of Characters.  Several delimiters in a row are considered as just one separation."

	| tokens keyStart keyStop |
	tokens := OrderedCollection new.
	keyStop := 1.
	[keyStop <= self size] whileTrue:
		[keyStart := self skipAnySubStr: delimiters startingAt: keyStop.
		keyStop := self findAnySubStr: delimiters startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [tokens add: (self copyFrom: keyStart to: (keyStop - 1))]].
	^tokens
]

{ #category : #accessing }
String >> findCloseParenthesisFor: startIndex [
	"assume (self at: startIndex) is $(.  Find the matching $), allowing parentheses to nest."
	" '(1+(2-3))-3.14159' findCloseParenthesisFor: 1 "
	" '(1+(2-3))-3.14159' findCloseParenthesisFor: 4 "
	| pos nestLevel |
	pos := startIndex+1.
	nestLevel := 1.
	[ pos <= self size ] whileTrue: [
		(self at: pos) = $( ifTrue: [ nestLevel := nestLevel + 1 ].
		(self at: pos) = $) ifTrue: [ nestLevel := nestLevel - 1 ].
		nestLevel = 0 ifTrue: [ ^pos ].
		pos := pos + 1.
	].
	^self size + 1
]

{ #category : #accessing }
String >> findDelimiters: delimiters startingAt: start [ 
	"Answer the index of the character within the receiver, starting at start, that matches one of the delimiters. If the receiver does not contain any of the delimiters, answer size + 1."

	delimiters size = 1 ifTrue: [ ^self indexOf: delimiters anyOne startingAt: start ifAbsent: self size + 1 ].
	^self indexOfAnyOf: delimiters startingAt: start ifAbsent: self size + 1
]

{ #category : #'accessing - features' }
String >> findFeatureIndicesDo: aBlock [
	"Support for simple analysis of natural language in source code.
	
	In addition to whitespace separation like #findTokens:, also separate features using higher-level rules:
		(1) 'camelCase' -> #('camel' 'Case'),
		(2) 'UPPERCase' -> #('UPPER' 'Case'),
		(3) integer numbers such as 'MyModel55' -> #('My' 'Model' '55'), and 
		(4) operators such as '5 <= 4' -> #('5' '<=' '4').
	Other kinds of characters are tokenized as operators: '[state := 2]' -> #('[' 'state' ':=' '2' ']').
	
	This method works like #lineIndicesDo: and provides start/stop indices of tokens to the given aBlock to, for example, extract and normalize features (or tokens)."
		
	| last state char |
	state := 0. "0 = start, 1 = a, 2 = A, 3 = AA, 4 = num, 5 = op"
	last := 1. "last character index"
	
	1 to: self size do: [ :index |
		char := self at: index.
		
		char isLowercase
			ifTrue: [ "a"
				state < 3 ifTrue: [state := 1]. "*a -> a"
				state = 3 ifTrue: [
					"AAa -> A + Aa (camel case follows uppercase)"
					aBlock value: last value: index - 2.
					last := index - 1.
					state := 2].
				state > 3 ifTrue: [
					"+a -> + | a (letter follows non-letter)" 
					aBlock value: last value: index - 1.
					last := index.
					state := 1]] 
			ifFalse: [
				char isUppercase
					ifTrue: [ "A"
						state = 0
							ifTrue: [state := 2] "start -> A"
							ifFalse: [
								(state < 2) | (state > 3) ifTrue: [
									"*A -> * | A (uppercase begins, flush before)"
									aBlock value: last value: index - 1.
									last := index.
									state := 2] ifFalse: [
										"AA -> AA (uppercase continues)"
										state := 3]]]
					ifFalse: [	
						char isSeparator
							ifTrue: [ " "
								"skip whitespace"
								state > 0 ifTrue: [
									aBlock value: last value: index - 1.
									state := 0].
								last := index + 1]
							ifFalse: [
								
								char isDigit
									ifTrue: [ "num"
										state = 0
											ifTrue: [state := 4]
											ifFalse: [
											state ~= 4 ifTrue: [
												aBlock value: last value: index - 1.
												last := index.
												state := 4]]]
									ifFalse: [ "op"
										state = 0
											ifTrue: [state := 5]
											ifFalse: [
												state < 5 ifTrue: [
													aBlock value: last value: index - 1.
													last := index.
													state := 5]] ] ] ] ] ].
	last <= self size ifTrue: [
		aBlock value: last value: self size]
]

{ #category : #'accessing - features' }
String >> findFeatures [
	
	^ Array streamContents: [:features |
		self findFeaturesDo: [:feature | features nextPut: feature]]
]

{ #category : #'accessing - features' }
String >> findFeaturesDo: aBlock [
	"Simple analysis of natural language in source code. Select all features that are letters only, normalize them as lowercase. No support for word stemming.
	
	Example:
		'Transcript show: 123 asString; cr; show: #HelloWorld.'
			-> #('transcript' 'show' 'as' 'string' 'cr' 'show' 'hello' 'world')
	"

	self findFeatureIndicesDo: [:start :end |
		(self at: start) isLetter ifTrue: [
			aBlock value: (self copyFrom: start to: end) asLowercase]].
]

{ #category : #accessing }
String >> findLastOccurrenceOfString: subString startingAt: start [ 
	"Answer the index of the last occurrence of subString within the receiver, starting at start. If 
	the receiver does not contain subString, answer 0.  Case-sensitive match used."

	| last now |
	last := self findString: subString startingAt: start.
	last = 0 ifTrue: [^ 0].
	[last > 0] whileTrue:
		[now := last.
		last := self findString: subString startingAt: last + 1].

	^ now

]

{ #category : #converting }
String >> findLiteral [
	"Scan the receiver for tokens that represent Smalltalk code literals. Return the first token or nil if non were found."
	
	| tokens |
	tokens := Scanner new typedScanTokens: self.
	^tokens isEmpty ifFalse: [tokens first]
]

{ #category : #converting }
String >> findSelector [
	"Dan's code for hunting down selectors with keyword parts; while this doesn't give a true parse, in most cases it does what we want, in where it doesn't, we're none the worse for it."
	| sel possibleParens |
	sel := self withBlanksTrimmed.
	(sel includes: $:)
		ifTrue:
			[sel := sel copyWithRegex: '''[^'']*''' matchesReplacedWith: '''a string'''.
			sel := sel copyWithRegex: '#[^\[\(\s\.$]*' matchesReplacedWith: '#aSymbol'.
			sel := sel copyWithRegex: '\$.' matchesReplacedWith: '$x'. "handle $( $[ and $:"
			sel := sel copyWithRegex: '\:(?!=)' matchesReplacedWith: ': '.	"for the style (aa max:bb) with no space"
			sel := sel copyReplaceAll: '[:' with: '[ :'.    "for the style ([:a) with no space"  
			possibleParens := sel substrings.
			sel := self class streamContents:
				[:s | | level |
				level := 0.
				possibleParens do:
					[:token |
					(level = 0 and: [token endsWith: ':'])
						ifTrue: [s nextPutAll: token]
						ifFalse: [level := level
								+ (token occurrencesOf: $() - (token occurrencesOf: $))
								+ (token occurrencesOf: $[) - (token occurrencesOf: $])
								+ (token occurrencesOf: ${) - (token occurrencesOf: $})]]]]
		ifFalse:
			[sel := self substrings ifNotEmpty: [:tokens | tokens last]].
	sel ifEmpty: [^ nil].
	sel first = $# ifTrue:
		[sel := sel allButFirst.
		sel ifEmpty: [^ nil]].
	sel isOctetString ifTrue: [sel := sel asOctetString].
	^ Symbol lookup: sel
]

{ #category : #accessing }
String >> findString: subString [
	"Answer the index of subString within the receiver, starting at start. If 
	the receiver does not contain subString, answer 0."
	^self findString: subString startingAt: 1.
]

{ #category : #accessing }
String >> findString: subString startingAt: start [ 
	"Answer the index of subString within the receiver, starting at start. If 
	the receiver does not contain subString, answer 0."

	^self findString: subString startingAt: start caseSensitive: true
]

{ #category : #accessing }
String >> findString: key startingAt: start caseSensitive: caseSensitive [ 
	"Answer the index in this String at which the substring key first occurs,
	at or beyond start. The match can be case-sensitive or not. If no match
	is found, zero will be returned."
	
	"IMPLEMENTATION NOTE: do not use CaseSensitiveOrder because it is broken for WideString
	This is a temporary work around until Wide CaseSensitiveOrder search is fixed
	Code should revert to:
	caseSensitive
		ifTrue: [^ self findSubstring: key in: self startingAt: start matchTable: CaseSensitiveOrder]
		ifFalse: [^ self findSubstring: key in: self startingAt: start matchTable: CaseInsensitiveOrder]"
		
	^caseSensitive
		ifTrue: [
			(self class isBytes and: [key class isBytes])
				ifTrue: [self
						findSubstring: key
						in: self
						startingAt: start
						matchTable: CaseSensitiveOrder]
				ifFalse: [WideString new
						findSubstring: key
						in: self
						startingAt: start
						matchTable: nil]]
		ifFalse: [
			(self class isBytes and: [key class isBytes])
				ifTrue: [self
						findSubstring: key
						in: self
						startingAt: start
						matchTable: CaseInsensitiveOrder]
				ifFalse: [WideString new
						findSubstring: key
						in: self
						startingAt: start
						matchTable: CaseInsensitiveOrder]]
]

{ #category : #accessing }
String >> findSubstring: key in: body startingAt: start matchTable: matchTable [
	"Answer the index in the string body at which the substring key first occurs, at or beyond start.  The match is determined using matchTable, which can be used to effect, eg, case-insensitive matches.  If no match is found, zero will be returned."

	| index c1 c2 keySize matchTableSize |
	(keySize := key size) = 0 ifTrue: [ ^0 ].
	matchTable ifNil: [
		start to: body size - keySize + 1 do: [ :startIndex |
			index := 0.
			[ (body at: startIndex + index) == (key at: (index := index + 1)) ] whileTrue: [
				index = keySize ifTrue: [ ^startIndex ] ] ].
		^0 ].
	matchTableSize := matchTable size.
	start to: body size - keySize + 1 do: [ :startIndex |
		index := 0.
		[
			(c1 := (body basicAt: startIndex + index) + 1) <= matchTableSize ifTrue: [
				c1 := matchTable at: c1 ].
			(c2 := (key basicAt: (index := index + 1)) + 1) <= matchTableSize ifTrue: [
				c2 := matchTable at: c2 ].
			c1 = c2 ]
			whileTrue: [
				index = keySize ifTrue: [ ^startIndex ] ] ].
	^0
]

{ #category : #converting }
String >> findSymbol [
	"Return the currently selected symbol, or nil if none.  Spaces, tabs and returns are ignored. Note that we do never return the empty symbol."
	
	| aString |
	aString := self copyWithoutAll: CharacterSet separators.
	aString size = 0 ifTrue: [^ nil].
	^ Symbol lookup: aString
]

{ #category : #'accessing - tokens' }
String >> findTokens [

	^ self findTokens: Character separators
]

{ #category : #accessing }
String >> findTokens: delimiters [
	"Answer the collection of tokens between delimiters, which results from parsing self."
	
	| tokens |
	tokens := OrderedCollection new.
	self
		findTokens: delimiters
		do: [:token | tokens addLast: token].
	^ tokens
]

{ #category : #'accessing - tokens' }
String >> findTokens: delimiters do: aBlock [
	
	self
		findTokens: delimiters
		indicesDo: [:start :end | aBlock value: (self copyFrom: start to: end)].
]

{ #category : #accessing }
String >> findTokens: delimiters escapedBy: quoteDelimiters [
	"Answer a collection of Strings separated by the delimiters, where  
	delimiters is a Character or collection of characters. Two delimiters in a  
	row produce an empty string (compare this to #findTokens, which  
	treats sequential delimiters as one).  
	 
	The characters in quoteDelimiters are treated as quote characters, such  
	that any delimiter within a pair of matching quoteDelimiter characters  
	is treated literally, rather than as a delimiter.  
	 
	The quoteDelimiter characters may be escaped within a quoted string.  
	Two sequential quote characters within a quoted string are treated as  
	a single character.  
	 
	This method is useful for parsing comma separated variable strings for  
	spreadsheet import and export."

	| tokens rs activeEscapeCharacter ts char token delimiterChars quoteChars |
	delimiterChars := (delimiters ifNil: [ '' ]) asString.
	quoteChars := (quoteDelimiters ifNil: [ '' ]) asString.
	tokens := OrderedCollection new.
	rs := ReadStream on: self.
	activeEscapeCharacter := nil.
	ts := WriteStream on: ''.
	[ rs atEnd ]
		whileFalse: [ 
			char := rs next.
			activeEscapeCharacter
				ifNil: [ 
					(quoteChars includes: char)
						ifTrue: [ activeEscapeCharacter := char ]
						ifFalse: [ 
							(delimiterChars includes: char)
								ifTrue: [ 
									token := ts contents.
									tokens add: token.
									ts := WriteStream on: '' ]
								ifFalse: [ ts nextPut: char ] ] ]
				ifNotNil: [ 
					char == activeEscapeCharacter
						ifTrue: [ 
							rs peek == activeEscapeCharacter
								ifTrue: [ ts nextPut: rs next ]
								ifFalse: [ activeEscapeCharacter := nil ] ]
						ifFalse: [ ts nextPut: char ] ] ].
	token := ts contents.
	(tokens isEmpty and: [ token isEmpty ])
		ifFalse: [ tokens add: token ].
	^ tokens
]

{ #category : #accessing }
String >> findTokens: delimiters includes: subString [
	"Divide self into pieces using delimiters.  Return the piece that includes subString anywhere in it.  Is case sensitive (say asLowercase to everything beforehand to make insensitive)."

^ (self findTokens: delimiters) 
	detect: [:str | (str includesSubstring: subString)] 
	ifNone: [nil]
]

{ #category : #'accessing - tokens' }
String >> findTokens: oneOrMoreCharacters indicesDo: aBlock [
	"Parse self to find tokens between delimiters. Any character in the Collection delimiters marks a border.  Several delimiters in a row are considered as just one separation. The interface is similar to #lineIndicesDo:."
	
	| keyStart keyStop separators size |
	size := self size.
	separators := oneOrMoreCharacters isCharacter 
		ifTrue: [{oneOrMoreCharacters}]
		ifFalse: [oneOrMoreCharacters].
	keyStop := 1.
	[keyStop <= size] whileTrue: [
		keyStart := self skipDelimiters: separators startingAt: keyStop.
		keyStop := self findDelimiters: separators startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [aBlock value: keyStart value: keyStop - 1]].
]

{ #category : #accessing }
String >> findTokens: delimiters keep: keepers [
	"Answer the collection of tokens that result from parsing self.  The tokens are seperated by delimiters, any of a string of characters.  If a delimiter is also in keepers, make a token for it.  (Very useful for carriage return.  A sole return ends a line, but is also saved as a token so you can see where the line breaks were.)"

	| tokens keyStart keyStop |
	tokens := OrderedCollection new.
	keyStop := 1.
	[keyStop <= self size] whileTrue:
		[keyStart := self skipDelimiters: delimiters startingAt: keyStop.
		keyStop to: keyStart-1 do: [:ii | 
			(keepers includes: (self at: ii)) ifTrue: [
				tokens add: (self copyFrom: ii to: ii)]].	"Make this keeper be a token"
		keyStop := self findDelimiters: delimiters startingAt: keyStart.
		keyStart < keyStop
			ifTrue: [tokens add: (self copyFrom: keyStart to: (keyStop - 1))]].
	^tokens
]

{ #category : #accessing }
String >> findWordStart: key startingAt: start [
	| ind |
	"HyperCard style searching.  Answer the index in self of the substring key, when that key is preceeded by a separator character.  Must occur at or beyond start.  The match is case-insensitive.  If no match is found, zero will be returned."

	ind := start.
	[ind := self findString: key startingAt: ind caseSensitive: false.
	ind = 0 ifTrue: [^ 0].	"not found"
	ind = 1 ifTrue: [^ 1].	"First char is the start of a word"
	(self at: ind-1) isSeparator] whileFalse: [ind := ind + 1].
	^ ind	"is a word start"
]

{ #category : #formatting }
String >> format: aCollection [ 
	"format the receiver with aCollection  
	 
	simplest example:  
	'foo {1} bar' format: {Date today}.
	 
	complete example:  
	'\{ \} \\ foo {1} bar {2}' format: {12. 'string'}. 
	"
	^self class new: self size * 11 // 10 "+10%" streamContents: [ :output |
		| lastIndex nextIndex |
		lastIndex := 1.
		[ (nextIndex := self indexOfAnyOf: FormatCharacterSet startingAt: lastIndex) = 0 ] whileFalse: [
			nextIndex = lastIndex ifFalse: [
				output next: nextIndex - lastIndex putAll: self startingAt: lastIndex ].
			(self at: nextIndex) == $\
				ifTrue: [ output nextPut: (self at: (nextIndex := nextIndex + 1)) ]
				ifFalse: [ "${"
					"Parse the index - a positive integer in base 10."
					| digitValue collectionIndex |
					collectionIndex := 0.
					[ (digitValue := self basicAt: (nextIndex := nextIndex + 1)) between: 48 "$0 asciiValue" and: 57 "$9 asciiValue" ] whileTrue: [
						collectionIndex := collectionIndex * 10 + digitValue - 48. "$0 asciiValue" ].
					digitValue =  125 "$} asciiValue" ifFalse: [ self error: '$} expected' ].
					output nextPutAll: (aCollection at: collectionIndex) asString ].
			lastIndex := nextIndex + 1 ].
		lastIndex <= self size ifTrue: [
			output next: self size - lastIndex + 1 putAll: self startingAt: lastIndex ] ]
]

{ #category : #comparing }
String >> hash [
	"#hash is implemented, because #= is implemented"
	"ar 4/10/2005: I had to change this to use ByteString hash as initial 
	hash in order to avoid having to rehash everything and yet compute
	the same hash for ByteString and WideString.
	md 16/10/2006: use identityHash as initialHash, as behavior hash will 
	use String hash (name) to have a better hash soon.
	eem 4/17/2017 it's not possible to use String hash (name) for the
	initial hash because that would be recursive."
	^self hashWithInitialHash: ByteString identityHash
]

{ #category : #private }
String >> hashWithInitialHash: speciesHash [
	"Answer the hash of a byte-indexed string, using speciesHash as the initial value.
	 See SmallInteger>>hashMultiply."
	| hash |
	hash := speciesHash bitAnd: 16r0FFFFFFF.
	1 to: self size do:
		[:pos |
		hash := (hash + (self basicAt: pos)) hashMultiply].
	^hash
]

{ #category : #comparing }
String >> howManyMatch: string [ 
	"Count the number of characters that match up in self and aString."
	| count shorterLength |
	
	count  :=  0 .
	shorterLength  :=  ((self size ) min: (string size ) ) .
	(1 to: shorterLength  do: [:index |
		 (((self at: index ) = (string at: index )  ) ifTrue: [count  :=  (count + 1 ) .
			]   ).
		]   ).
	^  count 
	
	
]

{ #category : #testing }
String >> includesSubstring: aString [

	^(self findString: aString startingAt: 1) > 0
]

{ #category : #testing }
String >> includesSubstring: aString caseSensitive: caseSensitive [
	
	^ (self findString: aString startingAt: 1 caseSensitive: caseSensitive) > 0
]

{ #category : #testing }
String >> includesUnifiedCharacter [
	^false
]

{ #category : #'paragraph support' }
String >> indentationIfBlank: aBlock [
	"Answer the number of leading tabs in the receiver.  If there are
	 no visible characters, pass the number of tabs to aBlock and return its value."

	| leadingTabs nonTab nonTabIndex nonSepIndex lineEndIndex |
	nonTab := (CharacterSet with: Character tab) complement.
	nonTabIndex := self indexOfAnyOf: nonTab startingAt: 1.
	nonTabIndex = 0 ifTrue: [
		"Only made of tabs or empty"
		^aBlock value: self size].
	leadingTabs := nonTabIndex - 1.
	nonSepIndex := self indexOfAnyOf: CharacterSet nonSeparators startingAt: 1.
	nonSepIndex = 0 ifTrue: [
		"Only made of separators"
		^aBlock value: leadingTabs].
	lineEndIndex := self indexOfAnyOf: CharacterSet crlf startingAt: 1.
	(lineEndIndex between: 1 and: nonSepIndex) ifTrue: [
		"Only made of separators up to a line end"
		^aBlock value: leadingTabs].
	^leadingTabs
]

{ #category : #accessing }
String >> indexOf: aCharacter startingAt: start [

	(aCharacter isCharacter) ifFalse: [^ 0].
	^ self class indexOfAscii: aCharacter asciiValue inString: self startingAt: start
]

{ #category : #accessing }
String >> indexOfSubCollection: subCollection startingAt: start [

	subCollection isString ifFalse: [ ^super indexOfSubCollection: subCollection startingAt: start ].
	^self findString: subCollection startingAt: start caseSensitive: true
]

{ #category : #converting }
String >> initialIntegerOrNil [
	"Answer the integer represented by the leading digits of the receiver, or nil if the receiver does not begin with a digit"
	| firstNonDigit |
	(self size = 0 or: [self first isDigit not]) ifTrue: [^ nil].
	firstNonDigit := (self findFirst: [:m | m isDigit not]).
	firstNonDigit = 0 ifTrue: [firstNonDigit := self size + 1].
	^ (self copyFrom: 1  to: (firstNonDigit - 1)) asNumber
"
'234Whoopie' initialIntegerOrNil
'wimpy' initialIntegerOrNil
'234' initialIntegerOrNil
'2N' initialIntegerOrNil
'2' initialIntegerOrNil
'  89Ten ' initialIntegerOrNil
'78 92' initialIntegerOrNil
"

]

{ #category : #testing }
String >> isAllDigits [
	"whether the receiver is composed entirely of digits"
	
	^self allSatisfy: [ :character | character isDigit ]
]

{ #category : #testing }
String >> isAllSeparators [
	"whether the receiver is composed entirely of separators"
	self do: [ :c | c isSeparator ifFalse: [ ^false ] ].
	^true
]

{ #category : #testing }
String >> isAsciiString [

	^self allSatisfy: [ :each | each asciiValue <= 127 ]
]

{ #category : #testing }
String >> isByteString [
	"Answer whether the receiver is a ByteString"
	^false
]

{ #category : #testing }
String >> isLiteral [
	"Answer whether the receiver is a valid Smalltalk literal."

	^ true
]

{ #category : #testing }
String >> isOctetString [
	"Answer whether the receiver can be represented as a byte string. 
	This is different from asking whether the receiver *is* a ByteString 
	(i.e., #isByteString)"
	1 to: self size do: [:pos |
		(self basicAt: pos) >= 256 ifTrue: [^ false].
	].
	^ true.

]

{ #category : #testing }
String >> isString [
	^ true
]

{ #category : #testing }
String >> isWideString [
	"Answer whether the receiver is a WideString"
	^false
]

{ #category : #internet }
String >> isoToSqueak [
	^self "no longer needed"
]

{ #category : #internet }
String >> isoToUtf8 [
	"Convert ISO 8559-1 to UTF-8"
	| s |
	s := WriteStream on: (String new: self size).
	self do: [:c |
		| v |
		v := c asciiValue.
		(v > 128)
			ifFalse: [s nextPut: c]
			ifTrue: [
				s nextPut: (192+(v >> 6)) asCharacter.
				s nextPut: (128+(v bitAnd: 63)) asCharacter]].
	^s contents. 

]

{ #category : #converting }
String >> keywords [
	"Answer an array of the keywords that compose the receiver."
	| keywords |
	keywords := Array streamContents:
		[:kwds |
		| kwd |
		kwd := WriteStream on: (String new: 16).
		1 to: self size do:
			[:i |
			| char |
			kwd nextPut: (char := self at: i).
			char = $: ifTrue: 
					[kwds nextPut: kwd contents.
					kwd reset]].
		(kwd position = 0) ifFalse: [kwds nextPut: kwd contents]].
	(keywords size >= 1 and: [(keywords at: 1) = ':']) ifTrue:
		["Has an initial keyword, as in #:if:then:else:"
		keywords := keywords allButFirst].
	(keywords size >= 2 and: [(keywords at: keywords size - 1) = ':']) ifTrue:
		["Has a final keyword, as in #nextPut::andCR"
		keywords := keywords copyReplaceFrom: keywords size - 1
								to: keywords size with: {':' , keywords last}].
	^ keywords
]

{ #category : #accessing }
String >> lastSpacePosition [
	"Answer the character position of the final space or other separator character in the receiver, and 0 if none"
	self size to: 1 by: -1 do:
		[:i | ((self at: i) isSeparator) ifTrue: [^ i]].
	^ 0

"
'fred the bear' lastSpacePosition
'ziggie' lastSpacePosition
'elvis ' lastSpacePosition
'wimpy  ' lastSpacePosition
'' lastSpacePosition
"
]

{ #category : #accessing }
String >> leadingCharRunLengthAt: index [

	| leadingChar |
	leadingChar := (self at: index) leadingChar.
	index to: self size do: [:i |
		(self at: i) leadingChar ~= leadingChar ifTrue: [^ i - index].
	].
	^ self size - index + 1.

]

{ #category : #accessing }
String >> lineCorrespondingToIndex: anIndex [
	"Answer a string containing the line at the given character position."

	self lineIndicesDo: [:start :endWithoutDelimiters :end |
		anIndex <= end ifTrue: [^self copyFrom: start to: endWithoutDelimiters]].
	^''
]

{ #category : #accessing }
String >> lineCount [
	"Answer the number of lines represented by the receiver, where every line delimiter CR, LF or CRLF pair adds one line."

	| lineCount |
	lineCount := 0.
	self lineIndicesDo: [:start :endWithoutDelimiters :end |
		lineCount := lineCount + 1].
	^lineCount
]

{ #category : #accessing }
String >> lineIndicesDo: aBlock [
	"execute aBlock with 3 arguments for each line:
	- start index of line
	- end index of line without line delimiter
	- end index of line including line delimiter(s) CR, LF or CRLF"
	
	| cr lf start sz nextLF nextCR |
	start := 1.
	sz := self size.
	cr := Character cr.
	nextCR := self indexOf: cr startingAt: 1.
	lf := Character lf.
	nextLF := self indexOf: lf startingAt: 1.
	[ start <= sz ] whileTrue: [
		(nextLF = 0 and: [ nextCR = 0 ])
			ifTrue: [ "No more CR, nor LF, the string is over"
					aBlock value: start value: sz value: sz.
					^self ].
		(nextCR = 0 or: [ 0 < nextLF and: [ nextLF < nextCR ] ])
			ifTrue: [ "Found a LF"
					aBlock value: start value: nextLF - 1 value: nextLF.
					start := 1 + nextLF.
					nextLF := self indexOf: lf startingAt: start ]
			ifFalse: [ 1 + nextCR = nextLF
				ifTrue: [ "Found a CR-LF pair"
					aBlock value: start value: nextCR - 1 value: nextLF.
					start := 1 + nextLF.
					nextCR := self indexOf: cr startingAt: start.
					nextLF := self indexOf: lf startingAt: start ]
				ifFalse: [ "Found a CR"
					aBlock value: start value: nextCR - 1 value: nextCR.
					start := 1 + nextCR.
					nextCR := self indexOf: cr startingAt: start ]]]
]

{ #category : #accessing }
String >> lineNumber: anIndex [
	"Answer a string containing the characters in the given line number."

	| lineCount |
	lineCount := 0.
	self lineIndicesDo: [:start :endWithoutDelimiters :end |
		(lineCount := lineCount + 1) = anIndex ifTrue: [^self copyFrom: start to: endWithoutDelimiters]].
	^nil
]

{ #category : #accessing }
String >> lines [
	"Answer an array of lines composing this receiver without the line ending delimiters."

	^Array new: (self size // 60 max: 16) streamContents: [:lines |
		self linesDo: [:aLine | lines nextPut: aLine]]
]

{ #category : #accessing }
String >> linesDo: aBlock [
	"Execute aBlock with each line in this string. The terminating line delimiters CR, LF or CRLF pairs are not included in what is passed to aBlock"

	self lineIndicesDo: [:start :endWithoutDelimiters :end |
		aBlock value: (self copyFrom: start to: endWithoutDelimiters)]
]

{ #category : #internet }
String >> macToSqueak [
	"Convert the receiver from MacRoman to Squeak encoding"
	^ self collect: [:each | each macToSqueak]
]

{ #category : #comparing }
String >> match: text [
	"Answer whether text matches the pattern in this string.
	Matching ignores upper/lower case differences.
	Where this string contains #, text may contain any character.
	Where this string contains *, text may contain any sequence of characters."

	^ self startingAt: 1 match: text startingAt: 1
"
	'*'			match: 'zort' true
	'*baz'		match: 'mobaz' true
	'*baz'		match: 'mobazo' false
	'*baz*'		match: 'mobazo' true
	'*baz*'		match: 'mozo' false
	'foo*'		match: 'foozo' true
	'foo*'		match: 'bozo' false
	'foo*baz'	match: 'foo23baz' true
	'foo*baz'	match: 'foobaz' true
	'foo*baz'	match: 'foo23bazo' false
	'foo'		match: 'Foo' true
	'foo*baz*zort' match: 'foobazort' false
	'foo*baz*zort' match: 'foobazzort' true
	'*foo#zort'	match: 'afoo3zortthenfoo3zort' true
	'*foo*zort'	match: 'afoodezortorfoo3zort' true
"
]

{ #category : #accessing }
String >> numArgs [ 
	"Answer either the number of arguments that the receiver would take if considered a selector.  Answer -1 if it couldn't be a selector. It is intended mostly for the assistance of spelling correction."

	| numColons index size c |
	(size := self size) = 0 ifTrue: [ ^-1 ].
	index := 1.
	(self at: index) isSpecial ifTrue: [
		2 to: size do: [ :i | (self at: i) isSpecial ifFalse: [ ^-1 ] ].
		^1 ].
	self canBeToken ifFalse: [ ^-1 ].
	"Fast colon count"
	numColons := 0.
	[ 
		((c := self at: index) isLetter
		 or: [ c = $_ and: [ Scanner prefAllowUnderscoreSelectors ] ]) ifFalse:
			[ ^-1 ].
		(index := (self indexOf: $: startingAt: index) + 1) > 1 ifFalse:
			[ numColons = 0 ifTrue: [ ^0 ].
			 ^-1 ].
		numColons := numColons + 1.
		index <= size ] whileTrue.
	^numColons
]

{ #category : #converting }
String >> numericSuffix [
	^ self stemAndNumericSuffix last

"
'abc98' numericSuffix
'98abc' numericSuffix
"
]

{ #category : #enumerating }
String >> occurrencesOf: anObject [ 
	"Answer how many of the receiver's elements are equal to anObject. Optimized version."

	| tally |
	anObject isCharacter ifFalse: [ ^0 ].
	tally := 0.
	1 to: self size do: [ :index |
		(self at: index) == anObject ifTrue: [ tally := tally + 1 ] ].
	^tally
]

{ #category : #converting }
String >> onlyLetters [
	"answer the receiver with only letters"
	^ self select:[:each | each isLetter]
]

{ #category : #copying }
String >> padded: leftOrRight to: length with: aCharacter [

	| result paddingLength |
	(paddingLength := length - self size) <= 0 ifTrue: [ ^self ].
	result := self species new: length.
	leftOrRight = #left ifTrue: [
		^result
			from: 1
				to: paddingLength
				put: aCharacter;
			replaceFrom: paddingLength + 1
				to: length
				with: self
				startingAt: 1;
			yourself ].
	leftOrRight = #right ifTrue: [
		^result
			replaceFrom: 1
				to: self size
				with: self
				startingAt: 1;
			from: self size + 1
				to: length
				put: aCharacter;
			yourself ]
]

{ #category : #printing }
String >> printAsLiteralOn: aStream [
	"Print inside string quotes, doubling embedded quotes."
	self storeOn: aStream
]

{ #category : #printing }
String >> printOn: aStream [
	"Print inside string quotes, doubling embedded quotes."
 
	self storeOn: aStream
]

{ #category : #'filter streaming' }
String >> putOn:aStream [

	^aStream nextPutAll: self.

]

{ #category : #private }
String >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	super replaceFrom: start to: stop with: replacement startingAt: repStart
]

{ #category : #converting }
String >> romanNumber [
	| value v1 v2 |
	value := v1 := v2 := 0.
	self reverseDo:
		[:each |
		v1 := #(1 5 10 50 100 500 1000) at: ('IVXLCDM' indexOf: each).
		v1 >= v2
			ifTrue: [value := value + v1]
			ifFalse: [value := value - v1].
		v2 := v1].
	^ value
]

{ #category : #comparing }
String >> sameAs: aString [ 
	"Answer whether the receiver sorts equal to aString. The 
	collation sequence is ascii with case differences ignored."
	self == aString ifTrue: [ ^true ].
	^(self compare: aString caseSensitive: false) = 2
]

{ #category : #converting }
String >> sansPeriodSuffix [
	"Return a copy of the receiver up to, but not including, the first period.  If the receiver's *first* character is a period, then just return the entire receiver. "

	| likely |
	likely := self copyUpTo: $..
	^ likely size = 0
		ifTrue:	[self]
		ifFalse:	[likely]
]

{ #category : #accessing }
String >> skipAnySubStr: delimiters startingAt: start [ 
	"Answer the index of the last character within the receiver, starting at start, that does NOT match one of the delimiters. delimiters is a Array of substrings (Characters also allowed).  If the receiver is all delimiters, answer size + 1."

	| any this ind ii |
	ii := start-1.
	[(ii := ii + 1) <= self size] whileTrue: [ "look for char that does not match"
		any := false.
		delimiters do: [:delim |
			delim isCharacter 
				ifTrue: [(self at: ii) == delim ifTrue: [any := true]]
				ifFalse: ["a substring"
					delim size > (self size - ii + 1) ifFalse: "Here's where the one-off error was."
						[ind := 0.
						this := true.
						delim do: [:dd | 
							dd == (self at: ii+ind) ifFalse: [this := false].
							ind := ind + 1].
						this ifTrue: [ii := ii + delim size - 1.  any := true]]
							ifTrue: [any := false] "if the delim is too big, it can't match"]].
		any ifFalse: [^ ii]].
	^ self size + 1
]

{ #category : #accessing }
String >> skipDelimiters: delimiters startingAt: start [ 
	"Answer the index of the character within the receiver, starting at start, that does NOT match one of the delimiters. If the receiver does not contain any of the delimiters, answer size + 1.  Assumes the delimiters to be a non-empty string."

	start to: self size do: [:i |
		(delimiters includes: (self at: i)) ifFalse: [ ^i ] ].
	^self size + 1
]

{ #category : #converting }
String >> splitInteger [
	"Answer an array that is a splitting of self into a string and an integer.
	'43Sam' ==> #(43 'Sam').  'Try90' ==> #('Try' 90)
	BUT NOTE: 'Sam' ==> #('Sam' 0), and '90' ==> #('' 90)  ie, (<string> <integer>)."

	| pos |
	(pos := self findFirst: [:d | d isDigit not]) = 0 ifTrue: [^ Array with: '' with: self asNumber].
	self first isDigit ifTrue: [
		^ Array with: (self copyFrom: 1 to: pos - 1) asNumber 
				with: (self copyFrom: pos to: self size)].
	(pos := self findFirst: [:d | d isDigit]) = 0 ifTrue: [^ Array with: self with: 0].
	^ Array with: (self copyFrom: 1 to: pos - 1)
			with: (self copyFrom: pos to: self size) asNumber
]

{ #category : #internet }
String >> squeakToIso [
	^self "no longer needed"
]

{ #category : #internet }
String >> squeakToMac [
	"Convert the receiver from Squeak to MacRoman encoding"
	^ self collect: [:each | each squeakToMac]
]

{ #category : #converting }
String >> squeakToUtf8 [
	"Convert the receiver into a UTF8-encoded string"
	
	^self convertToWithConverter: UTF8TextConverter new.
]

{ #category : #comparing }
String >> startingAt: keyStart match: text startingAt: textStart [
	"Answer whether text matches the pattern in this string.
	Matching ignores upper/lower case differences.
	Where this string contains #, text may contain any character.
	Where this string contains *, text may contain any sequence of characters."
	
	| anyMatch matchStart matchEnd i matchStr j ii jj |
	i := keyStart.
	j := textStart.
	
	"Process consecutive *s and #s at the beginning."
	anyMatch := false.
	[ i <= self size and: [
		(self at: i)
			caseOf: {
				[ $* ] -> [ 
					anyMatch := true.
					i := i + 1.
					true ].
				[ $# ] -> [
					i := i + 1.
					j := j + 1.
					true ] }
			otherwise: [ false ] ] ] whileTrue.
	i > self size ifTrue: [
		^j - 1 = text size or: [ "We reached the end by matching the character with a #."
			anyMatch and: [ j <= text size ] "Or there was a * before the end." ] ].
	matchStart := i.

	"Now determine the match string"
	matchEnd := self size.
	(ii := self indexOf: $* startingAt: matchStart) > 0 ifTrue: [ matchEnd := ii-1 ].
	(ii := self indexOf: $# startingAt: matchStart) > 0 ifTrue: [ matchEnd := matchEnd min: ii-1 ].
	matchStr := self copyFrom: matchStart to: matchEnd.

	"Now look for the match string"
	[jj := text findString: matchStr startingAt: j caseSensitive: false.
	anyMatch ifTrue: [jj > 0] ifFalse: [jj = j]]
		whileTrue:
		["Found matchStr at jj.  See if the rest matches..."
		(self startingAt: matchEnd+1 match: text startingAt: jj + matchStr size) ifTrue:
			[^ true "the rest matches -- success"].
		"The rest did not match."
		anyMatch ifFalse: [^ false].
		"Preceded by * -- try for a later match"
		j := j+1].
	^ false "Failed to find the match string"
]

{ #category : #testing }
String >> startsWithDigit [
	"Answer whether the receiver's first character represents a digit"

	^ self size > 0 and: [self first isDigit]
]

{ #category : #converting }
String >> stemAndNumericSuffix [
	"Parse the receiver into a string-valued stem and a numeric-valued suffix.  6/7/96 sw"

	| stem suffix position |

	stem := self.
	suffix := 0.
	position := 1.
	[stem endsWithDigit and: [stem size > 1]] whileTrue:
		[suffix :=  stem last digitValue * position + suffix.
		position := position * 10.
		stem := stem copyFrom: 1 to: stem size - 1].
	^ Array with: stem with: suffix

"'Fred2305' stemAndNumericSuffix"
]

{ #category : #printing }
String >> storeOn: aStream [
	"Print inside string quotes, doubling embedded quotes."
	| x |
	aStream nextPut: $'.
	1 to: self size do:
		[:i |
		aStream nextPut: (x := self at: i).
		x = $' ifTrue: [aStream nextPut: x]].
	aStream nextPut: $'
]

{ #category : #converting }
String >> string [
	^self
]

{ #category : #printing }
String >> stringRepresentation [
	"Answer a string that represents the receiver.  For most objects this is simply its printString, but for strings themselves, it's themselves, to avoid the superfluous extra pair of quotes.  6/12/96 sw"

	^ self 
]

{ #category : #private }
String >> stringhash [

	^ self hash.

]

{ #category : #converting }
String >> subStrings [
	"Answer an array of the substrings that compose the receiver."
	#Collectn.
	"Added 2000/04/08 For ANSI <readableString> protocol."
	^ self substrings
]

{ #category : #converting }
String >> subStrings: separators [ 
	"Answer an array containing the substrings in the receiver separated 
	by the elements of separators."
	| char result sourceStream subString |
	#Collectn.
	"Changed 2000/04/08 For ANSI <readableString> protocol."
	(separators isString or:[separators allSatisfy: [:element | element isCharacter]]) ifFalse:
		[^ self error: 'separators must be Characters.'].
	sourceStream := ReadStream on: self.
	result := OrderedCollection new.
	subString := String new.
	[sourceStream atEnd]
		whileFalse: 
			[char := sourceStream next.
			(separators includes: char)
				ifTrue: [subString notEmpty
						ifTrue: 
							[result add: subString copy.
							subString := String new]]
				ifFalse: [subString := subString , (String with: char)]].
	subString notEmpty ifTrue: [result add: subString copy].
	^ result asArray
]

{ #category : #converting }
String >> substrings [
	"Answer an array of the substrings that compose the receiver."
	| result end beginning |
	result := WriteStream on: (Array new: 10).
	end := 0.
	"find one substring each time through this loop"
	[ "find the beginning of the next substring"
	beginning := end+1.
	[beginning <= self size and:[(self at: beginning) isSeparator]]
		whileTrue:[beginning := beginning + 1].
	beginning <= self size] whileTrue: [
		"find the end"
		end := beginning.
		[end <= self size and:[(self at: end) isSeparator not]]
			whileTrue:[end := end + 1].
		end := end - 1.
		result nextPut: (self copyFrom: beginning to: end).
	].
	^result contents
]

{ #category : #converting }
String >> surroundedBySingleQuotes [
	"Answer the receiver with leading and trailing quotes.  "

	^ $' asString, self, $' asString
]

{ #category : #accessing }
String >> tabDelimitedFieldsDo: aBlock [
	"Considering the receiver as a holder of tab-delimited fields, evaluate execute aBlock with each field in this string.  The separatilng tabs are not included in what is passed to aBlock"

	| start end |
	"No senders but was useful enough in earlier work that it's retained for the moment."
	start := 1.
	[start <= self size] whileTrue: 
		[end := self indexOf: Character tab startingAt: start ifAbsent: [self size + 1].
		end := end - 1.
		aBlock value: (self copyFrom: start  to: end).
		start := end + 2]

"
'fred	charlie	elmo		2' tabDelimitedFieldsDo: [:aField | Transcript cr; show: aField]
"
]

{ #category : #converting }
String >> translateFrom: start  to: stop  table: table [
	"translate the characters in the string by the given table, in place"
	self class translate: self from: start to: stop table: table
]

{ #category : #converting }
String >> translateToLowercase [
	"Translate all characters to lowercase, in place"

	self translateWith: LowercasingTable
]

{ #category : #converting }
String >> translateToUppercase [
	"Translate all characters to uppercase, in place"

	self translateWith: UppercasingTable
]

{ #category : #converting }
String >> translateWith: table [
	"translate the characters in the string by the given table, in place"
	^ self translateFrom: 1 to: self size table: table
]

{ #category : #converting }
String >> truncateTo: smallSize [
	"return myself or a copy shortened to smallSize.  1/18/96 sw"

	^ self size <= smallSize
		ifTrue:
			[self]
		ifFalse:
			[self copyFrom: 1 to: smallSize]
]

{ #category : #converting }
String >> truncateWithElipsisTo: maxLength [
	"Return myself or a copy suitably shortened but with elipsis added"

	^ self size <= maxLength
		ifTrue:
			[self]
		ifFalse:
			[(self copyFrom: 1 to: (maxLength - 3)), '...']


	"'truncateWithElipsisTo:' truncateWithElipsisTo: 20"
]

{ #category : #converting }
String >> unescapePercents [
	"decode %xx form.  This is the opposite of #encodeForHTTP. Assume UTF-8 encoding by default."
	
	| unescaped |
	unescaped := self unescapePercentsRaw.
	^[ unescaped utf8ToSqueak ]
		on: Error
		do: [ unescaped ]
]

{ #category : #converting }
String >> unescapePercentsRaw [
	"Decode myself if I'm percent-encoded, also replace + with space. Return self if the encoding is not valid."
	
	^String new: self size streamContents: [ :stream |
		| value1 value2 specialChars startIndex endIndex |
		specialChars := '+%' asCharacterSet.
		startIndex := 1.
		[ (endIndex := self indexOfAnyOf: specialChars startingAt: startIndex) > 0 ] whileTrue: [
			stream 	next: endIndex - startIndex putAll: self startingAt: startIndex.
			(self at: endIndex) == $%
				ifTrue: [
					endIndex + 2 <= self size ifFalse: [ ^self ].
					value1 := (self at: endIndex + 1) asUppercase digitValue.
					(value1 < 0 or: [ value1 > 15 ]) ifTrue: [ ^self ].
					value2 := (self at: endIndex + 2) asUppercase digitValue.
					(value2 < 0 or: [ value2 > 15 ]) ifTrue: [ ^self ].
					stream nextPut: (Character value: value1 * 16 + value2).
					startIndex := endIndex + 3 ]
				ifFalse: [ "$+"
					stream nextPut: Character space.
					startIndex := endIndex + 1 ] ].
		startIndex <= self size ifTrue: [
			stream next: self size + 1 - startIndex putAll: self startingAt: startIndex ] ]
]

{ #category : #converting }
String >> unescapePercentsWithTextConverter: aTextConverter [
	"decode string including %XX form"

	| unescaped |
	unescaped := self unescapePercentsRaw.
	^[ unescaped convertFromWithConverter: aTextConverter ]
		on: Error
		do: ["the contents may be squeak-encoded"
			unescaped ]
]

{ #category : #converting }
String >> unescapePercentsWithTextEncoding: encodingName [ 
	"decode string including %XX form"
	
	| converter |
	converter := (TextConverter newForEncoding: encodingName)
		ifNil: [ TextConverter newForEncoding: nil ].
	^self unescapePercentsWithTextConverter: converter
]

{ #category : #converting }
String >> unparenthetically [
	"If the receiver starts with (..( and ends with matching )..), strip them"

	| curr |
	curr := self.
	[((curr first = $() and: [curr last = $)])] whileTrue:
		[curr := curr copyFrom: 2 to: (curr size - 1)].

	^ curr

"

'((fred the bear))' unparenthetically

"
		
]

{ #category : #internet }
String >> utf8ToIso [
	"Only UTF-8 characters that maps to 8-bit ISO-8559-1 values are converted. Others raises an error"
	| s i c v c2 v2 |
	s := WriteStream on: (String new: self size).
	
	i := 1.
	[i <= self size] whileTrue: [
		c := self at: i. i:=i+1.
		v := c asciiValue.
		(v > 128)
			ifFalse: [ s nextPut: c ]
			ifTrue: [((v bitAnd: 252) = 192)
				ifFalse: [self error: 'illegal UTF-8 ISO character']
				ifTrue: [
					(i > self size) ifTrue: [ self error: 'illegal end-of-string, expected 2nd byte of UTF-8'].
					c2 := self at: i. i:=i+1.
					v2 := c2 asciiValue.
					((v2 bitAnd: 192) = 128) ifFalse: [self error: 'illegal 2nd UTF-8 char']. 
					s nextPut: ((v2 bitAnd: 63) bitOr: ((v << 6) bitAnd: 192)) asCharacter]]].
	^s contents. 

]

{ #category : #converting }
String >> utf8ToSqueak [
	"Convert the receiver from a UTF8-encoded string"
	
	^self convertFromWithConverter: UTF8TextConverter new.
]

{ #category : #converting }
String >> vmPathToSqueakPath [
	"convert a file path string received from the vm to a Squeak String"

	^ (FilePath pathName: self isEncoded: true) asSqueakPathName
]

{ #category : #converting }
String >> withBlanksCondensed [
	"Return a copy of the receiver with leading/trailing blanks removed
	 and consecutive white spaces condensed."

	^String streamContents: [:stream |
		| trimmed lastBlank |
		trimmed := self withBlanksTrimmed.
		lastBlank := false.
		trimmed do: [:c | (c isSeparator and: [lastBlank]) ifFalse: [stream nextPut: c].
			lastBlank := c isSeparator]].

	" ' abc  d   ' withBlanksCondensed"

]

{ #category : #converting }
String >> withBlanksTrimmed [
	"Return a copy of the receiver from which leading and trailing blanks have been trimmed."

	| first last |
	first := self indexOfAnyOf: CharacterSet nonSeparators startingAt: 1.
	first = 0 ifTrue: [ ^'' ].  "no non-separator character"
	last := self lastIndexOfAnyOf: CharacterSet nonSeparators startingAt: self size ifAbsent: [self size].
	(first = 1 and: [ last = self size ]) ifTrue: [ ^self copy ].
	^self
		copyFrom: first
		to: last

]

{ #category : #formatting }
String >> withCRs [
	"Return a copy of the receiver in which backslash (\) characters have been replaced with carriage returns."

	^ self collect: [ :c | c = $\ ifTrue: [ Character cr ] ifFalse: [ c ]].
]

{ #category : #converting }
String >> withFirstCharacterDownshifted [
	"Return a copy with the first letter downShifted"
	
	| answer |
	
	self ifEmpty: [^ self copy].
	answer := self copy.
	answer at: 1 put: (answer at: 1) asLowercase.
	^ answer. 
]

{ #category : #internet }
String >> withInternetLineEndings [
	"change line endings from CR's and LF's to CRLF's.  This is probably in prepration for sending a string over the Internet"
	
	^self withLineEndings: String crlf
]

{ #category : #internet }
String >> withLineEndings: lineEndingString [

	| stream |
	stream := nil.
	self lineIndicesDo: [ :start :endWithoutDelimiters :end |
		(stream isNil and: [ endWithoutDelimiters ~= end ]) ifTrue: [
			(self copyFrom: endWithoutDelimiters + 1 to: end) = lineEndingString ifFalse: [
				stream := WriteStream with: self copy.
				stream position: start - 1 ] ].
		stream ifNotNil: [
			stream next: endWithoutDelimiters - start + 1 putAll: self startingAt: start.
			endWithoutDelimiters = end ifFalse: [
				stream nextPutAll: lineEndingString ] ] ].
	^stream
		ifNil: [ self ]
		ifNotNil: [ 
			stream position = self size
				ifTrue: [ stream originalContents ]
				ifFalse: [ stream contents ] ]
]

{ #category : #converting }
String >> withNoLineLongerThan: aNumber [
	"Answer a string with the same content as receiver, but rewrapped so that no line has more characters than the given number"
	aNumber isNumber not | (aNumber < 1) ifTrue: [self error: 'too narrow'].
	^self class
		new: self size * (aNumber + 1) // aNumber "provision for supplementary line breaks"
		streamContents: [ :stream |
			self lineIndicesDo: [ :start :endWithoutDelimiters :end |
				| pastEnd lineStart |
				pastEnd := endWithoutDelimiters + 1.
				"eliminate spaces at beginning of line"
				lineStart := (self indexOfAnyOf: CharacterSet nonSeparators startingAt: start ifAbsent: [pastEnd]) min: pastEnd.
				[| lineStop lineEnd spacePosition |
				lineEnd := lineStop  := lineStart + aNumber min: pastEnd..
				spacePosition := lineStart.
				[spacePosition < lineStop] whileTrue: [
					spacePosition := self indexOfAnyOf: CharacterSet separators startingAt: spacePosition + 1 ifAbsent: [pastEnd].
					spacePosition <= lineStop ifTrue: [lineEnd := spacePosition].
				].
				"split before space or before lineStop if no space"
				stream nextPutAll: (self copyFrom: lineStart to: lineEnd - 1).
				"eliminate spaces at beginning of next line"
				lineStart := self indexOfAnyOf: CharacterSet nonSeparators startingAt: lineEnd ifAbsent: [pastEnd].
				lineStart <= endWithoutDelimiters ]
					whileTrue: [stream cr].
				stream nextPutAll: (self copyFrom: pastEnd to: end) ] ]
]

{ #category : #converting }
String >> withSeparatorsCompacted [
	"replace each sequences of whitespace by a single space character"
	"' test ' withSeparatorsCompacted = ' test '"
	"' test test' withSeparatorsCompacted = ' test test'"
	"'test test		' withSeparatorsCompacted = 'test test '"

	| out in next isSeparator |
	self isEmpty ifTrue: [^ self].

	out := WriteStream on: (String new: self size).
	in := self readStream.
	isSeparator := [:char | char asciiValue < 256
				and: [CharacterSet separators includes: char]].
	[in atEnd] whileFalse: [
		next := in next.
		(isSeparator value: next)
			ifTrue: [
				out nextPut: $ .
				[in atEnd or:
					[next := in next.
					(isSeparator value: next)
						ifTrue: [false]
						ifFalse: [out nextPut: next. true]]] whileFalse]
			ifFalse: [out nextPut: next]].
	^ out contents
]

{ #category : #internet }
String >> withSqueakLineEndings [
	"Assume the string is textual, and that CR, LF, and CRLF are all valid line endings.
	Replace each occurence with a single CR."

	(self includes: Character lf) ifFalse: [ ^self ].
	(self includes: Character cr) ifFalse: [
		^self copy translateWith: String crLfExchangeTable ].
	^self withLineEndings: String cr
]

{ #category : #internet }
String >> withUnixLineEndings [
	"Assume the string is textual, and that CR, LF, and CRLF are all valid line endings.
	Replace each occurence with a single LF."

	(self includes: Character cr) ifFalse: [ ^self ].
	(self includes: Character lf) ifFalse: [
		^self copy translateWith: String crLfExchangeTable ].
	^self withLineEndings: String lf
]

{ #category : #converting }
String >> withoutJustTrailingDigits [
	"Answer the portion of the receiver that precedes any trailing series of digits.  If the receiver consists entirely of digits and blanks, return an empty string"
	| firstDigit |
	firstDigit := (self findFirst: [:m | m isDigit]).
	^ firstDigit > 0
		ifTrue:
			[(self copyFrom: 1 to: firstDigit-1) withoutTrailingBlanks]
		ifFalse:
			[self]

"
'Wh oopi e234' withoutJustTrailingDigits
'Wh oopi e 234' withoutJustTrailingDigits
"

]

{ #category : #converting }
String >> withoutLeadingBlanks [
	
	"Return a copy of the receiver from which leading blanks have been
trimmed."

	
	| first |
	
	first := self findFirst: [:c | c isSeparator not ].

	first = 0 ifTrue: [^ ''].  
	
	"no non-separator character"
	
	^ self copyFrom: first to: self size

	
		
	" '    abc  d' withoutLeadingBlanks"

]

{ #category : #converting }
String >> withoutLeadingDigits [
	"Answer the portion of the receiver that follows any leading series of digits and blanks.  If the receiver consists entirely of digits and blanks, return an empty string"
	| firstNonDigit |
	firstNonDigit := (self findFirst: [:m | m isDigit not and: [m ~= $ ]]).
	^ firstNonDigit > 0
		ifTrue:
			[self copyFrom: firstNonDigit  to: self size]
		ifFalse:
			['']

"
'234Whoopie' withoutLeadingDigits
' 4321 BlastOff!' withoutLeadingDigits
'wimpy' withoutLeadingDigits
'  89Ten ' withoutLeadingDigits
'78 92' withoutLeadingDigits
"

]

{ #category : #converting }
String >> withoutLineEndings [

	^self withLineEndings: ' '
]

{ #category : #internet }
String >> withoutQuoting [
	"remove the initial and final quote marks, if present"
	"'''h''' withoutQuoting"
	| quote |
	self size < 2 ifTrue: [ ^self ].
	quote := self first.
	(quote = self last and: [ quote = $' or: [ quote = $" ] ])
		ifTrue: [ ^self copyFrom: 2 to: self size - 1 ]
		ifFalse: [ ^self ].
]

{ #category : #converting }
String >> withoutTrailingBlanks [
	"Return a copy of the receiver from which trailing blanks have been trimmed."

	| last |
	last := self findLast: [:c | c isSeparator not].
	last = 0 ifTrue: [^ ''].  "no non-separator character"
	^ self copyFrom: 1 to: last

	" ' abc  d   ' withoutTrailingBlanks"

]

{ #category : #converting }
String >> withoutTrailingDigits [
	"Answer the portion of the receiver that precedes any trailing series of digits and blanks.  If the receiver consists entirely of digits and blanks, return an empty string"
	| i |
	i := self size.
	[i > 0] whileTrue: [ 
		((self at: i) isDigit or: [ (self at: i) = $ ]) ifFalse: [
			^ self copyFrom: 1 to: i
		].
		i := i - 1.
	].
	^ ''
	

"
'Whoopie234' withoutTrailingDigits
'Lucida Grande 15' withoutTrailingDigits
' 4321 BlastOff!' withoutLeadingDigits
'wimpy' withoutLeadingDigits
'  89Ten ' withoutLeadingDigits
'78 92' withoutLeadingDigits
"

]

{ #category : #encoding }
String >> writeLeadingCharRunsOn: stream [

	| runLength runValues runStart leadingChar |
	self isEmpty ifTrue: [^ self].

	runLength := OrderedCollection new.
	runValues := OrderedCollection new.
	runStart := 1.
	leadingChar := (self at: runStart) leadingChar.
	2 to: self size do: [:index |
		(self at: index) leadingChar = leadingChar ifFalse: [
			runValues add: leadingChar.
			runLength add: (index - runStart).
			leadingChar := (self at: index) leadingChar.
			runStart := index.
		].
	].
	runValues add: (self last) leadingChar.
	runLength add: self size + 1 -  runStart.

	stream nextPut: $(.
	runLength do: [:rr | rr printOn: stream. stream space].
	stream skip: -1; nextPut: $).
	runValues do: [:vv | vv printOn: stream. stream nextPut: $,].
	stream skip: -1.

]
