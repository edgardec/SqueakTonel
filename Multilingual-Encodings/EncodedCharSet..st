"
An abstract superclasss of the classes that represent encoded character sets.  In the old implementation, the charsets had more important role.  However, in the current implementation, the subclasses are used only for keeping the backward compatibility.

	The other confusion comes from the name of ""Latin1"" class.  It used to mean the Latin-1 (ISO-8859-1) character set, but now it primarily means that the ""Western European languages that are covered by the characters in Latin-1 character set.

"
Class {
	#name : #EncodedCharSet,
	#superclass : #Object,
	#classVars : [
		'EncodedCharSets'
	],
	#classInstVars : [
		'CompoundTextSequence'
	],
	#category : #'Multilingual-Encodings'
}

{ #category : #'character classification' }
EncodedCharSet class >> canBeGlobalVarInitial: char [

	| leadingChar |
	leadingChar := char leadingChar.

	leadingChar = 0 ifTrue: [^ self isUppercase: char].
	^ self isLetter: char.

]

{ #category : #'character classification' }
EncodedCharSet class >> canBeNonGlobalVarInitial: char [

	| leadingChar |
	leadingChar := char leadingChar.

	leadingChar = 0 ifTrue: [^ self isLowercase: char].
	^ self isLetter: char.

]

{ #category : #'class methods' }
EncodedCharSet class >> charFromUnicode: unicode [

	| table index |
	unicode < 128 ifTrue: [^ Character value: unicode].

	table := self ucsTable.
	index := table indexOf: unicode.
	index = 0 ifTrue: [
		^ nil.
	].

	^ Character leadingChar: self leadingChar code: index - 1.


]

{ #category : #'class methods' }
EncodedCharSet class >> charsetAt: encoding [
"Find  the char set encoding that matches 'encoding'; return a decent default rather than nil"
	^ (EncodedCharSets at: encoding + 1 ifAbsent: [nil]) ifNil: [Unicode].
]

{ #category : #'class methods' }
EncodedCharSet class >> charsetClass [
	^self
]

{ #category : #'class methods' }
EncodedCharSet class >> convertToUnicode: aCode [
	"Translate aCode in our encoding, into equivalent unicode encoding"
	| table v |
	(table := self ucsTable) ifNil: [^ 16rFFFD].
	(v := table at: 1 + aCode) = -1 ifTrue: [^ 16rFFFD].
	^ v
]

{ #category : #'class methods' }
EncodedCharSet class >> digitValueOf: char [
	"Answer 0-9 if the receiver is $0-$9, 10-35 if it is $A-$Z, and < 0 
	otherwise. This is used to parse literal numbers of radix 2-36."

	| value |
	value := char charCode.
	value <= $9 asciiValue ifTrue:
		[^value - $0 asciiValue].
	value >= $A asciiValue ifTrue:
		[value <= $Z asciiValue ifTrue: [^value - $A asciiValue + 10].
		 (value >= $a asciiValue and: [value <= $z asciiValue]) ifTrue:
			[^value - $a asciiValue + 10]].
	^ -1

]

{ #category : #'class methods' }
EncodedCharSet class >> initialize [
"
	self initialize
"
	self allSubclassesDo: [:each | each initialize].

	EncodedCharSets := Array new: 256.

	EncodedCharSets at: 0+1 put: Unicode "Latin1Environment".
	EncodedCharSets at: 1+1 put: JISX0208.
	EncodedCharSets at: 2+1 put: GB2312.
	EncodedCharSets at: 3+1 put: KSX1001.
	EncodedCharSets at: 4+1 put: JISX0208.
	EncodedCharSets at: 5+1 put: JapaneseEnvironment.
	EncodedCharSets at: 6+1 put: SimplifiedChineseEnvironment.
	EncodedCharSets at: 7+1 put: KoreanEnvironment.
	EncodedCharSets at: 8+1 put: GB2312.
	"EncodedCharSets at: 9+1 put: UnicodeTraditionalChinese."
	"EncodedCharSets at: 10+1 put: UnicodeVietnamese."
	EncodedCharSets at: 12+1 put: KSX1001.
	"EncodedCharSets at: 13+1 put: GreekEnvironment."
	"EncodedCharSets at: 14+1 put: Latin2Environment."
	"EncodedCharSets at: 15+1 put: RussianEnvironment."
	EncodedCharSets at: 256 put: Unicode.

]

{ #category : #'character classification' }
EncodedCharSet class >> isAlphaNumeric: char [
	"Answer whether char has the code of a letter or a digit in this encoding."

	^self isAlphaNumericCode: char charCode

]

{ #category : #'character classification' }
EncodedCharSet class >> isAlphaNumericCode: anInteger [
	"Answer whether anInteger is the code of a letter or a digit."

	^(self isLetterCode: anInteger) or: [ self isDigitCode: anInteger ]

]

{ #category : #'accessing - displaying' }
EncodedCharSet class >> isBreakableAt: index in: text [

	^false
]

{ #category : #'character classification' }
EncodedCharSet class >> isDigit: char [
	"Answer whether char has the code of a digit in this encoding."
	^self isDigitCode: char charCode

]

{ #category : #'character classification' }
EncodedCharSet class >> isDigitCode: anInteger [
	"Answer whether anInteger is the code of a digit."

	^ anInteger >= 48 and: [anInteger <= 57].

]

{ #category : #'character classification' }
EncodedCharSet class >> isLetter: char [ 
	"Answer whether char has the code of a letter in this encoding."
	^self isLetterCode: char charCode
]

{ #category : #'character classification' }
EncodedCharSet class >> isLetterCode: anInteger [
	"Answer whether anInteger is the code of a letter."

	^ (8r141 <= anInteger and: [anInteger <= 8r172]) or: [8r101 <= anInteger and: [anInteger <= 8r132]].

]

{ #category : #'character classification' }
EncodedCharSet class >> isLowercase: char [ 
	"Answer whether char has the code of a lowercase letter in this encoding."
	^self isLowercaseCode: char charCode
]

{ #category : #'character classification' }
EncodedCharSet class >> isLowercaseCode: anInteger [
	"Answer whether anInteger is the code of a lowercase letter."

	^ 8r141 <= anInteger and: [anInteger <= 8r172].

]

{ #category : #'character classification' }
EncodedCharSet class >> isUppercase: char [ 
	"Answer whether char has the code of an uppercase letter in this encoding."
	^self isUppercaseCode: char charCode
]

{ #category : #'character classification' }
EncodedCharSet class >> isUppercaseCode: anInteger [
	"Answer whether anInteger is the code of an uppercase letter."

	^ 8r101 <= anInteger and: [anInteger <= 8r132].

]

{ #category : #'class methods' }
EncodedCharSet class >> leadingChar [

	self subclassResponsibility.

]

{ #category : #'class methods' }
EncodedCharSet class >> nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

	self subclassResponsibility.

]

{ #category : #'accessing - displaying' }
EncodedCharSet class >> printingDirection [

	self subclassResponsibility.

]

{ #category : #'accessing - displaying' }
EncodedCharSet class >> scanMultibyteCharactersFrom: startIndex to: stopIndex in: aWideString with: aCharacterScanner rightX: rightX font: aFont [
	"the default for scanning multibyte characters- other more specific encodings may do something else"
	^aFont scanMultibyteCharactersFrom: startIndex to: stopIndex in: aWideString with: aCharacterScanner rightX: rightX
]

{ #category : #'class methods' }
EncodedCharSet class >> ucsTable [

	^ UCSTable latin1Table.

]

{ #category : #'class methods' }
EncodedCharSet class >> unicodeLeadingChar [
	^Unicode leadingChar
]
