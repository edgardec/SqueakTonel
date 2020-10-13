"
I represent a character by storing its associated Unicode as an unsigned 30-bit value.  Characters are created uniquely, so that all instances of a particular Unicode are identical.  My instances are encoded in tagged pointers in the VM, so called immediates, and therefore are pure immutable values.

	The code point is based on Unicode.  Since Unicode is 21-bit wide character set, we have several bits available for other information.  As the Unicode Standard  states, a Unicode code point doesn't carry the language information.  This is going to be a problem with the languages so called CJK (Chinese, Japanese, Korean.  Or often CJKV including Vietnamese).  Since the characters of those languages are unified and given the same code point, it is impossible to display a bare Unicode code point in an inspector or such tools.  To utilize the extra available bits, we use them for identifying the languages.  Since the old implementation uses the bits to identify the character encoding, the bits are sometimes called ""encoding tag"" or neutrally ""leading char"", but the bits rigidly denotes the concept of languages.

	The other languages can have the language tag if you like.  This will help to break the large default font (font set) into separately loadable chunk of fonts.  However, it is open to the each native speakers and writers to decide how to define the character equality, since the same Unicode code point may have different language tag thus simple #= comparison may return false.
"
Class {
	#name : #Character,
	#superclass : #Magnitude,
	#type : #immediate,
	#classVars : [
		'AlphaNumericMask',
		'ClassificationTable',
		'DigitBit',
		'DigitValues',
		'LetterMask',
		'LowercaseBit',
		'UppercaseBit'
	],
	#category : #'Collections-Strings'
}

{ #category : #'instance creation' }
Character class >> allByteCharacters [
	"Answer all the characters that can be encoded in a byte"
	^ (0 to: 255) collect: [:v | Character value: v] as: String

]

{ #category : #'instance creation' }
Character class >> allCharacters [
	"This name is obsolete since only the characters that will fit in a byte can be queried"
	^self allByteCharacters
	

]

{ #category : #constants }
Character class >> alphabet [
	"($a to: $z) as: String"

	^ 'abcdefghijklmnopqrstuvwxyz' copy
]

{ #category : #'accessing untypeable characters' }
Character class >> arrowDown [
	^ self value: 31
]

{ #category : #'accessing untypeable characters' }
Character class >> arrowLeft [
	^ self value: 28
]

{ #category : #'accessing untypeable characters' }
Character class >> arrowRight [
	^ self value: 29
]

{ #category : #'accessing untypeable characters' }
Character class >> arrowUp [
	^ self value: 30
]

{ #category : #'accessing untypeable characters' }
Character class >> backspace [
	"Answer the Character representing a backspace."

	^self value: 8
]

{ #category : #'accessing untypeable characters' }
Character class >> characterForColumnBreak [
"use a newPage to split columns in character scanners"
	^self newPage
]

{ #category : #'instance creation' }
Character class >> codePoint: integer [ 
	"Return a character whose encoding value is integer.
	For ansi compability."
	^self value: integer
]

{ #category : #private }
Character class >> constantNameFor: aCharacter [
	^ self constantNames
		detect: [ :each | (self perform: each) = aCharacter ]
		ifNone: [ nil ].
]

{ #category : #private }
Character class >> constantNames [
	^ #( backspace cr delete escape lf null newPage space tab ).
]

{ #category : #'accessing untypeable characters' }
Character class >> cr [
	"Answer the Character representing a carriage return."

	^self value: 13
]

{ #category : #'accessing untypeable characters' }
Character class >> delete [
	^ self value: 127
]

{ #category : #'instance creation' }
Character class >> digitValue: x [ 
	"Answer the Character whose digit value is x. For example,
	 answer $9 for x=9, $0 for x=0, $A for x=10, $Z for x=35."

	| n |
	n := x asInteger.
	^self value: (n < 10 ifTrue: [n + 48] ifFalse: [n + 55])
]

{ #category : #'accessing untypeable characters' }
Character class >> end [
	^ self value: 4
]

{ #category : #'accessing untypeable characters' }
Character class >> enter [
	"Answer the Character representing enter."

	^self value: 3
]

{ #category : #'accessing untypeable characters' }
Character class >> escape [
	"Answer the ASCII ESC character"

	^self value: 27
]

{ #category : #'accessing untypeable characters' }
Character class >> euro [
	"The Euro currency sign, that E with two dashes. The code point is a official unicode ISO/IEC-10646-1"

	^self value: 16r20AC
]

{ #category : #'accessing untypeable characters' }
Character class >> home [
	^ self value: 1
]

{ #category : #'class initialization' }
Character class >> initialize [
	"Character initialize"
	
	self
		initializeClassificationTable;
		initializeDigitValues
]

{ #category : #'class initialization' }
Character class >> initializeClassificationTable [
	"Initialize the classification table.
	The classification table is a compact encoding of upper and lower cases and digits of characters with
		- bits 0-7: The lower case value of this character or 0, if its greater than 255.
		- bits 8-15: The upper case value of this character or 0, if its greater than 255.
		- bit 16: lowercase bit (isLowercase == true)
		- bit 17: uppercase bit (isUppercase == true)
		- bit 18: digit bit (isDigit == true)"
	" self initializeClassificationTable "

	| encodedCharSet newClassificationTable |
	"Base the table on the EncodedCharset of these characters' leadingChar - 0."
	encodedCharSet := EncodedCharSet charsetAt: 0.

	LowercaseBit := 1 bitShift: 16.
	UppercaseBit := 1 bitShift: 17.
	DigitBit := 1 bitShift: 18.

	"Initialize the letter mask (e.g., isLetter == true)"
	LetterMask := LowercaseBit bitOr: UppercaseBit.

	"Initialize the alphanumeric mask (e.g. isAlphaNumeric == true)"
	AlphaNumericMask := LetterMask bitOr: DigitBit.

	"Initialize the table based on encodedCharSet."
	newClassificationTable := WordArray new: 256.
	0 to: 255 do: [ :code |
		| isLowercase isUppercase isDigit lowercaseCode uppercaseCode value |
		isLowercase := encodedCharSet isLowercaseCode: code.
		isUppercase := encodedCharSet isUppercaseCode: code.
		isDigit := encodedCharSet isDigitCode: code.
		lowercaseCode := encodedCharSet toLowercaseCode: code.
		lowercaseCode > 255 ifTrue: [ lowercaseCode := 0 ].
		uppercaseCode := encodedCharSet toUppercaseCode: code.
		uppercaseCode > 255 ifTrue: [ uppercaseCode := 0 ].
		value := (uppercaseCode bitShift: 8) + lowercaseCode.
		isLowercase ifTrue: [ value := value bitOr: LowercaseBit ].
		isUppercase ifTrue: [ value := value bitOr: UppercaseBit ].
		isDigit ifTrue: [ value := value bitOr: DigitBit ].
		newClassificationTable at: code + 1 put: value ].
	ClassificationTable := newClassificationTable
]

{ #category : #'class initialization' }
Character class >> initializeDigitValues [
	"Initialize the well known digit value of ascii characters.
	Note that the DigitValues table is 1-based while ascii values are 0-based, thus the offset +1."
	
	| newDigitValues |
	newDigitValues := Array new: 256 withAll: -1.
	"the digits"
	0 to: 9 do: [:i | newDigitValues at: 48 + i + 1 put: i].
	"the uppercase letters"
	10 to: 35 do: [:i | newDigitValues at: 55 + i + 1 put: i].
	"the lowercase letters"
	10 to: 35 do: [:i | newDigitValues at: 87 + i + 1 put: i].
	DigitValues := newDigitValues
]

{ #category : #'accessing untypeable characters' }
Character class >> insert [
	^ self value: 5
]

{ #category : #'instance creation' }
Character class >> leadingChar: leadChar code: code [

	code >= 16r400000 ifTrue: [
		self error: 'code is out of range'.
	].
	leadChar >= 256 ifTrue: [
		self error: 'lead is out of range'.
	].
	code < 256 ifTrue: [ ^self value: code ].
	^self value: (leadChar bitShift: 22) + code.
]

{ #category : #'accessing untypeable characters' }
Character class >> lf [
	"Answer the Character representing a linefeed."

	^self value: 10
]

{ #category : #'accessing untypeable characters' }
Character class >> linefeed [
	"Answer the Character representing a linefeed."

	^self value: 10
]

{ #category : #'accessing untypeable characters' }
Character class >> nbsp [
	"non-breakable space"

	^self value: 160
]

{ #category : #'instance creation' }
Character class >> new [
	"Creating new characters is not allowed."

	self error: 'cannot create new characters'
]

{ #category : #'accessing untypeable characters' }
Character class >> newPage [
	"Answer the Character representing a form feed."

	^self value: 12
]

{ #category : #'accessing untypeable characters' }
Character class >> null [
	^ self value: 0
]

{ #category : #'accessing untypeable characters' }
Character class >> pageDown [
	^ self value: 12
]

{ #category : #'accessing untypeable characters' }
Character class >> pageUp [
	^ self value: 11
]

{ #category : #'instance creation' }
Character class >> separators [
	"Answer a collection of the standard ASCII separator characters."

	^ #(32 "space"
		13 "cr"
		9 "tab"
		10 "line feed"
		12 "form feed")
		collect: [:v | Character value: v] as: String
]

{ #category : #'accessing untypeable characters' }
Character class >> space [
	"Answer the Character representing a space."

	^self value: 32
]

{ #category : #'accessing untypeable characters' }
Character class >> startOfHeader [

	^ self value: 1 
]

{ #category : #'accessing untypeable characters' }
Character class >> tab [
	"Answer the Character representing a tab."

	^self value: 9
]

{ #category : #'instance creation' }
Character class >> value: anInteger [
	"Answer the Character whose value is anInteger."
	<primitive: 170>
	^self primitiveFailed
]

{ #category : #comparing }
Character >> < aCharacter [ 
	"Answer true if the receiver's value < aCharacter's value."

	^self asInteger < aCharacter asInteger
]

{ #category : #comparing }
Character >> <= aCharacter [ 
	"Answer true if the receiver's value <= aCharacter's value."

	^self asInteger <= aCharacter asInteger
]

{ #category : #comparing }
Character >> = aCharacter [ 
	"Primitive. Answer if the receiver and the argument are the
	 same object (have the same object pointer). Optional. See
	 Object documentation whatIsAPrimitive."
	<primitive: 110>
	^self == aCharacter
]

{ #category : #comparing }
Character >> > aCharacter [ 
	"Answer true if the receiver's value > aCharacter's value."

	^self asInteger > aCharacter asInteger
]

{ #category : #comparing }
Character >> >= aCharacter [ 
	"Answer true if the receiver's value >= aCharacter's value."

	^self asInteger >= aCharacter asInteger
]

{ #category : #converting }
Character >> adaptToNumber: rcvr andSend: selector [
	"If I am involved in arithmetic with a number, convert me to an integer."

	^ rcvr perform: selector with: self asInteger
]

{ #category : #converting }
Character >> asCharacter [
	"Answer the receiver itself."

	^self
]

{ #category : #converting }
Character >> asInteger [
	"Answer the receiver's character code."
	<primitive: 171>
	^self primitiveFailed
]

{ #category : #converting }
Character >> asLowercase [
	"Answer the receiver's matching lowercase Character."
	
	| integerValue |
	(integerValue := self asInteger) > 255 ifFalse: [ 
		| result |
		(result := (ClassificationTable at: integerValue + 1) bitAnd: 16rFF) > 0
			ifTrue: [ ^self class value: result ] ].
	^self class value: (self encodedCharSet toLowercaseCode: integerValue)
]

{ #category : #converting }
Character >> asString [
	^ String with: self
]

{ #category : #converting }
Character >> asSymbol [ 
	"Answer a Symbol consisting of the receiver as the only element."

	^Symbol intern: self asString
]

{ #category : #converting }
Character >> asText [
	^ self asString asText
]

{ #category : #converting }
Character >> asUnicode [
	"Answer the unicode encoding of the receiver"
	
	| integerValue |
	(integerValue := self asInteger) <= 16r3FFFFF ifTrue: [ ^integerValue ].
	^self encodedCharSet charsetClass convertToUnicode: (integerValue bitAnd: 16r3FFFFF)

]

{ #category : #converting }
Character >> asUppercase [
	"Answer the receiver's matching uppercase Character."
	
	| integerValue |
	(integerValue := self asInteger) > 255 ifFalse: [ 
		| result |
		(result := ((ClassificationTable at: integerValue + 1) bitShift: -8) bitAnd: 16rFF) > 0
			ifTrue: [ ^self class value: result ] ].
	^self class value: (self encodedCharSet toUppercaseCode: integerValue)
]

{ #category : #accessing }
Character >> asciiValue [
	"Answer the receiver's character code.
	 This will be ascii for characters with value <= 127,
	 and Unicode for those with higher values."
	<primitive: 171>
	^self primitiveFailed
]

{ #category : #testing }
Character >> canBeGlobalVarInitial [

	^self encodedCharSet canBeGlobalVarInitial: self
]

{ #category : #testing }
Character >> canBeIdentifierInitial [
	^ self == $_ or: [self isLetter]
]

{ #category : #testing }
Character >> canBeNonGlobalVarInitial [

	^self encodedCharSet canBeNonGlobalVarInitial: self

]

{ #category : #accessing }
Character >> charCode [

	^ (self asInteger bitAnd: 16r3FFFFF).

]

{ #category : #accessing }
Character >> codePoint [
	"Return the encoding value of the receiver."
	#Fundmntl.

	^self asInteger
]

{ #category : #copying }
Character >> deepCopy [
	"Answer the receiver, because Characters are unique."
	^self
]

{ #category : #accessing }
Character >> digitValue [
	"Answer 0-9 if the receiver is $0-$9, 10-35 if it is $A-$Z, and < 0 
	otherwise. This is used to parse literal numbers of radix 2-36."

	| integerValue |
	(integerValue := self asInteger) > 16rFF ifTrue: [^self encodedCharSet digitValueOf: self].
	^DigitValues at: integerValue + 1
]

{ #category : #accessing }
Character >> encodedCharSet [
	
	self asInteger < 16r400000 ifTrue: [ ^Unicode ]. "Shortcut"
	^EncodedCharSet charsetAt: self leadingChar

]

{ #category : #comparing }
Character >> hash [
	"Hash is reimplemented because = is implemented.
	 Answer the receiver's character code."
	<primitive: 171>
	^self primitiveFailed
]

{ #category : #printing }
Character >> hex [
	^self asInteger printStringBase: 16
]

{ #category : #comparing }
Character >> identityHash [
	"Answer the receiver's character code."
	<primitive: 171>
	^self primitiveFailed
]

{ #category : #testing }
Character >> isAlphaNumeric [
	"Answer whether the receiver is a letter or a digit."

	| integerValue |
	(integerValue := self asInteger) > 255 ifFalse: [ 
		^((ClassificationTable at: integerValue + 1) bitAnd: AlphaNumericMask) > 0 ].
	^self encodedCharSet isAlphaNumeric: self
]

{ #category : #testing }
Character >> isAscii [

	^self asInteger < 128
]

{ #category : #testing }
Character >> isCharacter [

	^ true.

]

{ #category : #testing }
Character >> isDigit [

	| integerValue |
	(integerValue := self asInteger) > 255 ifFalse: [
		^((ClassificationTable at: integerValue + 1) bitAnd: DigitBit) > 0 ].
	^self encodedCharSet isDigit: self.

]

{ #category : #testing }
Character >> isLetter [

	| integerValue |
	(integerValue := self asInteger) > 255 ifFalse: [
		^((ClassificationTable at: integerValue + 1) bitAnd: LetterMask) > 0 ].
	^self encodedCharSet isLetter: self
]

{ #category : #testing }
Character >> isLiteral [

	^true
]

{ #category : #testing }
Character >> isLowercase [

	| integerValue |
	(integerValue := self asInteger) > 255 ifFalse: [
		^((ClassificationTable at: integerValue + 1) bitAnd: LowercaseBit) > 0 ].
	^self encodedCharSet isLowercase: self.

]

{ #category : #testing }
Character >> isOctetCharacter [

	^ self asInteger < 256.

]

{ #category : #testing }
Character >> isSafeForHTTP [
	"whether a character is 'safe', or needs to be escaped when used, eg, in a URL"
	"[GG]  See http://www.faqs.org/rfcs/rfc1738.html. ~ is unsafe and has been removed"
	^ self charCode < 128
		and: [self isAlphaNumeric
				or: ['.-_' includes: (Character value: self charCode)]]
]

{ #category : #testing }
Character >> isSeparator [
	"Answer whether the receiver is one of the separator characters--space, 
	cr, tab, line feed, or form feed."

	| integerValue |
	(integerValue := self asInteger) > 32 ifTrue: [ ^false ].
	integerValue
		caseOf: {
			[ 32 "space" ] -> [ ^true ].
			[ 9 "tab" ] -> [ ^true ].
			[ 13 "cr"] -> [ ^true ].
			[ 10 "line feed" ] -> [ ^true ].
			[ 12 "form feed"] -> [ ^true ] }
		otherwise: [ ^false  ]
]

{ #category : #testing }
Character >> isSpecial [
	"Answer whether the receiver is one of the special characters"

	^'+-/\*~<>=@,%|&?!' includes: self
]

{ #category : #testing }
Character >> isTraditionalDomestic [
	"Yoshiki's note about #isUnicode says:
		[This method] is for the backward compatibility when we had domestic
		traditional encodings for CJK languages.  To support loading the
		projects in traditional domestic encodings (From Nihongo4), and load
		some changesets.  Once we decided to get rid of classes like JISX0208
		from the EncodedCharSet table, the need for isUnicode will not be
		necessary.
	I (Andreas) decided to change the name from isUnicode to #isTraditionalDomestic
	since I found isUnicode to be horribly confusing (how could the character *not*
	be Unicode after all?). But still, we should remove this method in due time."
	^ (self encodedCharSet isKindOf: LanguageEnvironment class) not
]

{ #category : #testing }
Character >> isUppercase [

	| integerValue |
	(integerValue := self asInteger) > 255 ifFalse: [
		^((ClassificationTable at: integerValue + 1) bitAnd: UppercaseBit) > 0 ].
	^self encodedCharSet isUppercase: self.

]

{ #category : #testing }
Character >> isVowel [
	"Answer whether the receiver is one of the vowels, AEIOU, in upper or 
	lower case."

	^'AEIOU' includes: self asUppercase
]

{ #category : #converting }
Character >> isoToSqueak [ 
	^self "no longer needed"
]

{ #category : #accessing }
Character >> leadingChar [
	"Answer the value of the 8 highest bits which is used to identify the language.
	This is mostly used for east asian languages CJKV as a workaround against unicode han-unification."
	^ self asInteger bitShift: -22
]

{ #category : #converting }
Character >> macToSqueak [
	"Convert the receiver from MacRoman to Squeak encoding"
	| asciiValue |
	self asInteger < 128 ifTrue: [^ self].
	self asInteger > 255 ifTrue: [^ self].
	asciiValue := #[
		196 197 199 201 209 214 220 225 224 226 228 227 229 231 233 232	"80-8F"
		234 235 237 236 238 239 241 243 242 244 246 245 250 249 251 252	"90-9F"
		134 176 162 163 167 149 182 223 174 169 153 180 168 128 198 216	"A0-AF"
		129 177 138 141 165 181 142 143 144 154 157 170 186 158 230 248	"B0-BF"
		191 161 172 166 131 173 178 171 187 133 160 192 195 213 140 156	"C0-CF"
		150 151 147 148 145 146 247 179 255 159 185 164 139 155 188 189	"D0-DF"
		135 183 130 132 137 194 202 193 203 200 205 206 207 204 211 212	"E0-EF"
		190 210 218 219 217 208 136 152 175 215 221 222 184 240 253 254 ]	"F0-FF"
			at: self asInteger - 127.
	^ Character value: asciiValue.
]

{ #category : #'system primitives' }
Character >> nextObject [
	"Characters are immediate objects, and, as such, do not have successors in object memory."

	self shouldNotImplement 
]

{ #category : #'object fileIn' }
Character >> objectForDataStream: refStrm [
	"I am being collected for inclusion in a segment.  Do not include Characters!  Let them be in outPointers."

	refStrm insideASegment
		ifFalse: ["Normal use" ^ self]
		ifTrue: ["recording objects to go into an ImageSegment"			
			"remove it from references.  Do not trace."
			refStrm references removeKey: self ifAbsent: [].
			^ nil]

]

{ #category : #printing }
Character >> printAsLiteralOn: aStream [
	aStream nextPut: $$; nextPut: self
]

{ #category : #printing }
Character >> printOn: aStream [
	| integerValue |
	((integerValue := self asInteger) > 32 and: [integerValue ~= 127]) ifTrue:
		[^self printAsLiteralOn: aStream].
	(self class constantNameFor: self)
		ifNotNil: [ :name | aStream nextPutAll: self class name; space; nextPutAll: name ]
		ifNil: [ aStream nextPutAll: self class name; nextPutAll: ' value: '; print: integerValue ]
]

{ #category : #comparing }
Character >> sameAs: aCharacter [ 
	"Answer whether the receiver is equal to aCharacter, ignoring case"
	
	self == aCharacter ifTrue: [ ^true ].
	^self asLowercase == aCharacter asLowercase
]

{ #category : #copying }
Character >> shallowCopy [
	"Answer the receiver, because Characters are unique."
	^self
]

{ #category : #testing }
Character >> shouldBePrintedAsLiteral [

	| integerValue |
	(integerValue := self asInteger) < 33 ifTrue: [ ^false ].
	255 < integerValue ifTrue: [ ^false ].
	^integerValue ~= 127
]

{ #category : #testing }
Character >> shouldBePrintedAsLiteralVisiting: aSet [

	^self shouldBePrintedAsLiteral
]

{ #category : #converting }
Character >> squeakToIso [
	^self "no longer needed"
]

{ #category : #converting }
Character >> squeakToMac [
	"Convert the receiver from Squeak to MacRoman encoding."
	self asInteger < 128 ifTrue: [^ self].
	self asInteger > 255 ifTrue: [^ self].
	^ Character value: (#[
		173 176 226 196 227 201 160 224 246 228 178 220 206 179 182 183	"80-8F"
		184 212 213 210 211 165 208 209 247 170 185 221 207 186 189 217	"90-9F"
		202 193 162 163 219 180 195 164 172 169 187 199 194 197 168 248	"A0-AF"
		161 177 198 215 171 181 166 225 252 218 188 200 222 223 240 192 	"B0-BF"
		203 231 229 204 128 129 174 130 233 131 230 232 237 234 235 236 	"C0-CF"
		245 132 241 238 239 205 133 249 175 244 242 243 134 250 251 167	"D0-DF"
		136 135 137 139 138 140 190 141 143 142 144 145 147 146 148 149	"E0-EF"
		253 150 152 151 153 155 154 214 191 157 156 158 159 254 255 216	"F0-FF"
	] at: self asInteger - 127)

]

{ #category : #printing }
Character >> storeBinaryOn: aStream [
	"Store the receiver on a binary (file) stream"
	
	| integerValue |
	(integerValue := self asInteger) < 256 
		ifTrue: [ aStream basicNextPut: self ]
		ifFalse: [ aStream nextInt32Put: integerValue ]
]

{ #category : #'object fileIn' }
Character >> storeDataOn: aDataStream [
	" Store characters in reference-like way, with value like instvar.
	This is compatible with various Squeak Memory Systems"

	aDataStream
		beginInstance: self class
			size: 1;
		nextPut: self asInteger
]

{ #category : #printing }
Character >> storeOn: aStream [
	"Common character literals are preceded by '$', however special need to be encoded differently: for some this might be done by using one of the shortcut constructor methods for the rest we have to create them by ascii-value."

	self shouldBePrintedAsLiteral ifTrue:
		[^self printAsLiteralOn: aStream].
	(self class constantNameFor: self) ifNotNil: [ :name |
		aStream nextPutAll: self class name; space; nextPutAll: name.
		^self ].
	aStream 
		nextPut: $(; nextPutAll: self class name; 
		nextPutAll: ' value: '; print: self asInteger; nextPut: $)
]

{ #category : #converting }
Character >> to: other [
	"Answer with a collection in ascii order -- $a to: $z"
	^ (self asInteger to: other asciiValue)
		collect:	[:ascii | Character value: ascii]
		as: String
]

{ #category : #testing }
Character >> tokenish [
	"Answer whether the receiver is a valid token-character--letter, digit, or colon."

	self == $_ ifTrue: [ ^Scanner prefAllowUnderscoreSelectors ].
	^self == $: or: [ self isAlphaNumeric ]
]

{ #category : #copying }
Character >> veryDeepCopyWith: deepCopier [
	"Answer the receiver, because Characters are unique."
	^self
]
