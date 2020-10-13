"
This class holds the entry points for the utility functions around characters.

"
Class {
	#name : #Unicode,
	#superclass : #EncodedCharSet,
	#classVars : [
		'Cc',
		'Cf',
		'Cn',
		'Co',
		'Compositions',
		'Cs',
		'DecimalProperty',
		'Decompositions',
		'GeneralCategory',
		'Ll',
		'Lm',
		'Lo',
		'Lt',
		'Lu',
		'Mc',
		'Me',
		'Mn',
		'Nd',
		'Nl',
		'No',
		'Pc',
		'Pd',
		'Pe',
		'Pf',
		'Pi',
		'Po',
		'Ps',
		'Sc',
		'Sk',
		'Sm',
		'So',
		'ToCasefold',
		'ToLower',
		'ToUpper',
		'Zl',
		'Zp',
		'Zs'
	],
	#category : #'Multilingual-Encodings'
}

{ #category : #comments }
Unicode class >> blocks320Comment [

"# Blocks-3.2.0.txt
# Correlated with Unicode 3.2
# Start Code..End Code; Block Name
0000..007F; Basic Latin
0080..00FF; Latin-1 Supplement
0100..017F; Latin Extended-A
0180..024F; Latin Extended-B
0250..02AF; IPA Extensions
02B0..02FF; Spacing Modifier Letters
0300..036F; Combining Diacritical Marks
0370..03FF; Greek and Coptic
0400..04FF; Cyrillic
0500..052F; Cyrillic Supplementary
0530..058F; Armenian
0590..05FF; Hebrew
0600..06FF; Arabic
0700..074F; Syriac
0780..07BF; Thaana
0900..097F; Devanagari
0980..09FF; Bengali
0A00..0A7F; Gurmukhi
0A80..0AFF; Gujarati
0B00..0B7F; Oriya
0B80..0BFF; Tamil
0C00..0C7F; Telugu
0C80..0CFF; Kannada
0D00..0D7F; Malayalam
0D80..0DFF; Sinhala
0E00..0E7F; Thai
0E80..0EFF; Lao
0F00..0FFF; Tibetan
1000..109F; Myanmar
10A0..10FF; Georgian
1100..11FF; Hangul Jamo
1200..137F; Ethiopic
13A0..13FF; Cherokee
1400..167F; Unified Canadian Aboriginal Syllabics
1680..169F; Ogham
16A0..16FF; Runic
1700..171F; Tagalog
1720..173F; Hanunoo
1740..175F; Buhid
1760..177F; Tagbanwa
1780..17FF; Khmer
1800..18AF; Mongolian
1E00..1EFF; Latin Extended Additional
1F00..1FFF; Greek Extended
2000..206F; General Punctuation
2070..209F; Superscripts and Subscripts
20A0..20CF; Currency Symbols
20D0..20FF; Combining Diacritical Marks for Symbols
2100..214F; Letterlike Symbols
2150..218F; Number Forms
2190..21FF; Arrows
2200..22FF; Mathematical Operators
2300..23FF; Miscellaneous Technical
2400..243F; Control Pictures
2440..245F; Optical Character Recognition
2460..24FF; Enclosed Alphanumerics
2500..257F; Box Drawing
2580..259F; Block Elements
25A0..25FF; Geometric Shapes
2600..26FF; Miscellaneous Symbols
2700..27BF; Dingbats
27C0..27EF; Miscellaneous Mathematical Symbols-A
27F0..27FF; Supplemental Arrows-A
2800..28FF; Braille Patterns
2900..297F; Supplemental Arrows-B
2980..29FF; Miscellaneous Mathematical Symbols-B
2A00..2AFF; Supplemental Mathematical Operators
2E80..2EFF; CJK Radicals Supplement
2F00..2FDF; Kangxi Radicals
2FF0..2FFF; Ideographic Description Characters
3000..303F; CJK Symbols and Punctuation
3040..309F; Hiragana
30A0..30FF; Katakana
3100..312F; Bopomofo
3130..318F; Hangul Compatibility Jamo
3190..319F; Kanbun
31A0..31BF; Bopomofo Extended
31F0..31FF; Katakana Phonetic Extensions
3200..32FF; Enclosed CJK Letters and Months
3300..33FF; CJK Compatibility
3400..4DBF; CJK Unified Ideographs Extension A
4E00..9FFF; CJK Unified Ideographs
A000..A48F; Yi Syllables
A490..A4CF; Yi Radicals
AC00..D7AF; Hangul Syllables
D800..DB7F; High Surrogates
DB80..DBFF; High Private Use Surrogates
DC00..DFFF; Low Surrogates
E000..F8FF; Private Use Area
F900..FAFF; CJK Compatibility Ideographs
FB00..FB4F; Alphabetic Presentation Forms
FB50..FDFF; Arabic Presentation Forms-A
FE00..FE0F; Variation Selectors
FE20..FE2F; Combining Half Marks
FE30..FE4F; CJK Compatibility Forms
FE50..FE6F; Small Form Variants
FE70..FEFF; Arabic Presentation Forms-B
FF00..FFEF; Halfwidth and Fullwidth Forms
FFF0..FFFF; Specials
10300..1032F; Old Italic
10330..1034F; Gothic
10400..1044F; Deseret
1D000..1D0FF; Byzantine Musical Symbols
1D100..1D1FF; Musical Symbols
1D400..1D7FF; Mathematical Alphanumeric Symbols
20000..2A6DF; CJK Unified Ideographs Extension B
2F800..2FA1F; CJK Compatibility Ideographs Supplement
E0000..E007F; Tags
F0000..FFFFF; Supplementary Private Use Area-A
100000..10FFFF; Supplementary Private Use Area-B


"
]

{ #category : #comments }
Unicode class >> blocks320Comment2 [

"# Blocks-3.2.0.txt
# Correlated with Unicode 3.2
# Start Code..End Code; Block Name
0000..007F; Basic Latin
0080..00FF; Latin-1 Supplement

 => Latin 1

0100..017F; Latin Extended-A
0180..024F; Latin Extended-B
0250..02AF; IPA Extensions

  => LatinExtended1

02B0..02FF; Spacing Modifier Letters
0300..036F; Combining Diacritical Marks

  => Modifiers

0370..03FF; Greek and Coptic
0400..04FF; Cyrillic
0500..052F; Cyrillic Supplementary
0530..058F; Armenian

   => EuropeanAlphabetic1

0590..05FF; Hebrew
0600..06FF; Arabic
0700..074F; Syriac
0780..07BF; Thaana

   => MiddleEastern

0900..097F; Devanagari
0980..09FF; Bengali
0A00..0A7F; Gurmukhi
0A80..0AFF; Gujarati
0B00..0B7F; Oriya
0B80..0BFF; Tamil
0C00..0C7F; Telugu
0C80..0CFF; Kannada
0D00..0D7F; Malayalam
0D80..0DFF; Sinhala

  => South Asian1


0E00..0E7F; Thai
0E80..0EFF; Lao

 => Southeastern 1

0F00..0FFF; Tibetan

  => South Asian1

1000..109F; Myanmar

 => Southeastern 1


10A0..10FF; Georgian

   => European Alphabetic 2

1100..11FF; Hangul Jamo

   => Korean

1200..137F; Ethiopic
13A0..13FF; Cherokee
1400..167F; Unified Canadian Aboriginal Syllabics

  => Additional1

1680..169F; Ogham
16A0..16FF; Runic

  => European Alphabetic 3

1700..171F; Tagalog
1720..173F; Hanunoo
1740..175F; Buhid
1760..177F; Tagbanwa
1780..17FF; Khmer

  => Southeastern2

1800..18AF; Mongolian

  => Additional2

1E00..1EFF; Latin Extended Additional
1F00..1FFF; Greek Extended

  => EuropeanAlphabetic4

2000..206F; General Punctuation
2070..209F; Superscripts and Subscripts
20A0..20CF; Currency Symbols
20D0..20FF; Combining Diacritical Marks for Symbols
2100..214F; Letterlike Symbols
2150..218F; Number Forms
2190..21FF; Arrows
2200..22FF; Mathematical Operators
2300..23FF; Miscellaneous Technical
2400..243F; Control Pictures
2440..245F; Optical Character Recognition
2460..24FF; Enclosed Alphanumerics
2500..257F; Box Drawing
2580..259F; Block Elements
25A0..25FF; Geometric Shapes
2600..26FF; Miscellaneous Symbols
2700..27BF; Dingbats
27C0..27EF; Miscellaneous Mathematical Symbols-A
27F0..27FF; Supplemental Arrows-A
2800..28FF; Braille Patterns
2900..297F; Supplemental Arrows-B
2980..29FF; Miscellaneous Mathematical Symbols-B
2A00..2AFF; Supplemental Mathematical Operators

  => Symbols2

2E80..2EFF; CJK Radicals Supplement
2F00..2FDF; Kangxi Radicals
2FF0..2FFF; Ideographic Description Characters
3000..303F; CJK Symbols and Punctuation
3040..309F; Hiragana
30A0..30FF; Katakana
3100..312F; Bopomofo
3130..318F; Hangul Compatibility Jamo
3190..319F; Kanbun
31A0..31BF; Bopomofo Extended
31F0..31FF; Katakana Phonetic Extensions
3200..32FF; Enclosed CJK Letters and Months
3300..33FF; CJK Compatibility
3400..4DBF; CJK Unified Ideographs Extension A
4E00..9FFF; CJK Unified Ideographs
A000..A48F; Yi Syllables
A490..A4CF; Yi Radicals

  => CJK

AC00..D7AF; Hangul Syllables

  => Korean

D800..DB7F; High Surrogates
DB80..DBFF; High Private Use Surrogates
DC00..DFFF; Low Surrogates
E000..F8FF; Private Use Area

F900..FAFF; CJK Compatibility Ideographs

  => CJK

FB00..FB4F; Alphabetic Presentation Forms
FB50..FDFF; Arabic Presentation Forms-A

  => Middle Eastern 2

FE00..FE0F; Variation Selectors
FE20..FE2F; Combining Half Marks

FE30..FE4F; CJK Compatibility Forms

  => CJK

FE50..FE6F; Small Form Variants

 => Symbol3

FE70..FEFF; Arabic Presentation Forms-B

  => Middle Eastern 3

FF00..FFEF; Halfwidth and Fullwidth Forms
FFF0..FFFF; Specials

  => Specials

10300..1032F; Old Italic
10330..1034F; Gothic
10400..1044F; Deseret

   => European

1D000..1D0FF; Byzantine Musical Symbols
1D100..1D1FF; Musical Symbols
1D400..1D7FF; Mathematical Alphanumeric Symbols

  => Symbols

20000..2A6DF; CJK Unified Ideographs Extension B
2F800..2FA1F; CJK Compatibility Ideographs Supplement

  => CJK

E0000..E007F; Tags
F0000..FFFFF; Supplementary Private Use Area-A
100000..10FFFF; Supplementary Private Use Area-B

  => Special

"
]

{ #category : #'unicode data' }
Unicode class >> caseFoldingData [
	
	 ^ self fetch: 'CaseFolding Unicode data' fromUnicodeData: 'CaseFolding.txt'

]

{ #category : #'instance creation' }
Unicode class >> charFromUnicode: uniCode [

	^ Character leadingChar: self leadingChar code: uniCode

]

{ #category : #composing }
Unicode class >> compose: baseChar with: compositionChar [
	"Answers the composition of baseChar and compositionChar if such a combination exists.
	Answers nil if the combination does not exist."
	^Character value: 
		((Compositions at: baseChar asInteger ifAbsent:[^nil])
			at: compositionChar asInteger ifAbsent:[^nil])
]

{ #category : #'class methods' }
Unicode class >> compoundTextFinalChar [

	self shouldNotImplement.

]

{ #category : #'class methods' }
Unicode class >> compoundTextSequence [

	self subclassResponsibility.

]

{ #category : #'class methods' }
Unicode class >> convertToUnicode: aCode [
	^aCode
]

{ #category : #composing }
Unicode class >> decompose: aCharacter [
	"Answers the decomposed sequence for the given character if such a sequence
	exists. If there is no decomposition for the character, answer nil."
	^String withAll: ((Decompositions at: aCharacter asInteger ifAbsent:[^nil]) 
		collect:[:v| Character value: v]).
]

{ #category : #'class methods' }
Unicode class >> digitValueOf: char [
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

	value > (DecimalProperty size - 1) ifTrue: [^ -1].
	^ (DecimalProperty at: value+1)

]

{ #category : #'unicode data' }
Unicode class >> fetch: what fromUnicodeData: fileName [
	| unicodeLocation |
	unicodeLocation := 'https://www.unicode.org/Public/UCD/latest/ucd/'.
	UIManager default informUser: 'Downloading ', what  during: 
		[ | response|
		response := (Smalltalk at: #WebClient) httpGet: unicodeLocation, fileName.
		^ response isSuccess
			ifFalse: [self error: 'Download failed']
			ifTrue: [response content]].
		
		 
]

{ #category : #'unicode data' }
Unicode class >> generalCategory [

	^ GeneralCategory.


]

{ #category : #'unicode data' }
Unicode class >> generalCategoryComment [
"
Lu Letter, Uppercase 
Ll Letter, Lowercase 
Lt Letter, Titlecase 
Lm Letter, Modifier 
Lo Letter, Other 
Mn Mark, Non-Spacing 
Mc Mark, Spacing Combining 
Me Mark, Enclosing 
Nd Number, Decimal 
Nl Number, Letter 
No Number, Other 
Pc Punctuation, Connector 
Pd Punctuation, Dash 
Ps Punctuation, Open 
Pe Punctuation, Close 
Pi Punctuation, Initial quote (may behave like Ps or Pe depending on usage) 
Pf Punctuation, Final quote (may behave like Ps or Pe depending on usage) 
Po Punctuation, Other 
Sm Symbol, Math 
Sc Symbol, Currency 
Sk Symbol, Modifier 
So Symbol, Other 
Zs Separator, Space 
Zl Separator, Line 
Zp Separator, Paragraph 
Cc Other, Control 
Cf Other, Format 
Cs Other, Surrogate 
Co Other, Private Use 
Cn Other, Not Assigned (no characters in the file have this property) 
"
]

{ #category : #'character classification' }
Unicode class >> generalCategoryOf: aCharacterCode [

	| index |
	(index := aCharacterCode + 1) > GeneralCategory size ifTrue: [ ^nil ].
	^GeneralCategory at: index

]

{ #category : #'class initialization' }
Unicode class >> initialize [
	" Unicode initialize "
	self initializeTagConstants.
	Compositions isEmptyOrNil ifTrue:[self initializeCompositionMappings].
]

{ #category : #casing }
Unicode class >> initializeCaseFolding [
	" self initializeCaseFolding "
	
	self parseCaseFoldingFrom: self caseFoldingData
]

{ #category : #composing }
Unicode class >> initializeCompositionMappings [
	" self initializeCompositionMappings "

	self parseCompositionMappingFrom: self unicodeData
]

{ #category : #'class initialization' }
Unicode class >> initializeTagConstants [
	"Initialize the Unicode tag constants"
	Cn := 0.
 	Cc := 1.
 	Cf := 2.
 	Co := 3.
 	Cs := 4.
 	Ll := 5.
 	Lm := 6.
 	Lo := 7.
 	Lt := 8.
 	Lu := 9.
 	Mc := 10.
 	Me := 11.
 	Mn := 12.
 	Nd := 13.
 	Nl := 14.
 	No := 15.
 	Pc := 16.
 	Pd := 17.
 	Pe := 18.
 	Pf := 19.
 	Pi := 20.
 	Po := 21.
 	Ps := 22.
 	Sc := 23.
 	Sk := 24.
 	Sm := 25.
 	So := 26.
 	Zl := 27.
 	Zp := 28.
 	Zs := 29.
]

{ #category : #'character classification' }
Unicode class >> isAlphaNumericCode: charCode [ 
	
	| codeCategory |
	(codeCategory := self generalCategoryOf: charCode) < Ll ifTrue: [ ^false ].
	codeCategory <= Lu ifTrue: [ ^true ].
	^codeCategory = Nd

]

{ #category : #'character classification' }
Unicode class >> isComposable: aCharacter [
	"Answers true if the given character has any composition sequences"
	^Compositions includesKey: aCharacter asInteger
]

{ #category : #'character classification' }
Unicode class >> isComposed: aCharacter [
	"Answers true if the given character can be decomposed into a Unicode sequence."
	^Decompositions includesKey: aCharacter asInteger
]

{ #category : #'character classification' }
Unicode class >> isComposition: aCharacter [

	^(self generalCategoryOf: aCharacter charCode) = Mn
]

{ #category : #'character classification' }
Unicode class >> isDigitCode: charCode [

	^(self generalCategoryOf: charCode) = Nd
]

{ #category : #subencodings }
Unicode class >> isJapanese: code [

	^ code > 255 and: [(JISX0208 charFromUnicode: code) notNil].

]

{ #category : #subencodings }
Unicode class >> isKorean: code [

	^ code > 255 and: [(KSX1001 charFromUnicode: code) notNil]


]

{ #category : #'character classification' }
Unicode class >> isLetterCode: charCode [ 
	
	| codeCategory |
	(codeCategory := self generalCategoryOf: charCode) < Ll ifTrue: [ ^false ].
	^codeCategory <= Lu
]

{ #category : #'character classification' }
Unicode class >> isLowercaseCode: charCode [ 

	^(self generalCategoryOf: charCode) = Ll
]

{ #category : #subencodings }
Unicode class >> isSimplifiedChinese: code [

	^ code > 255 and: [(GB2312 charFromUnicode: code) notNil]



]

{ #category : #subencodings }
Unicode class >> isTraditionalChinese: code [

	^ false.

]

{ #category : #subencodings }
Unicode class >> isUnifiedKanji: code [

	^ ((((16r2E80 <= code and: [code <= 16rA4CF])
		or: [16rF900 <= code and: [code <= 16rFAFF]])
			or: [16rFE30 <= code and: [code <= 16rFE4F]])
				or: [16rFF00 <= code and: [code <= 16rFFEF]])
					or: [16r20000 <= code and: [code <= 16r2FA1F]].

]

{ #category : #'character classification' }
Unicode class >> isUppercaseCode: charCode [ 
	
	^(self generalCategoryOf: charCode) = Lu
]

{ #category : #'class methods' }
Unicode class >> leadingChar [
	^ 0
]

{ #category : #'class methods' }
Unicode class >> nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

	self subclassResponsibility.

]

{ #category : #casing }
Unicode class >> parseCaseFoldingFrom: caseFoldingData [
	"Parse the Unicode casing mappings from the given string."

	| newToCasefold |
	newToCasefold := PluggableDictionary integerDictionary.

	"Filter the mappings (Simple and Common) to newToCasefold."
	caseFoldingData linesDo: [ :line |
		| lineWithoutComment fields sourceCode destinationCode |
		lineWithoutComment := line copyUpTo: $#.
		fields := lineWithoutComment findTokens: '; '.
		(fields size > 2 and: [ #('C' 'S') includes: (fields at: 2) ]) ifTrue: [
			sourceCode := Integer readFrom: (fields at: 1) base: 16.
			destinationCode := Integer readFrom: (fields at: 3) base: 16.
			newToCasefold at: sourceCode put: destinationCode ] ].

	"Compact and save."
	ToCasefold := newToCasefold compact
	
]

{ #category : #composing }
Unicode class >> parseCompositionMappingFrom: unicodeData [
	"Parse the Unicode composition mappings from the given stream"
	"
		Unicode initializeCompositionMappings.
	"
	| newCompositions newDecompositions newToUpper newToLower toNumber |

	toNumber := [:quad | quad inject: 0 into:[:sum :ch| sum * 16 + ch digitValue]].

	newCompositions := PluggableDictionary integerDictionary.
	newDecompositions := PluggableDictionary integerDictionary.
	newToUpper := PluggableDictionary integerDictionary.
	newToLower := PluggableDictionary integerDictionary.

	unicodeData linesDo: [ :line |
		| fields |
		(fields := line splitBy: ';') size > 13 ifTrue: [
			| codePoint lowercaseCodePoint uppercaseCodePoint decomposed baseChar compChar |
			codePoint := toNumber value: (fields at: 1).
			uppercaseCodePoint := (fields at: 13) ifEmpty: [ codePoint ] ifNotEmpty: toNumber.
			codePoint = uppercaseCodePoint ifFalse: [ newToUpper at: codePoint put: uppercaseCodePoint ].
			lowercaseCodePoint := (fields at: 14) ifEmpty: [ codePoint ] ifNotEmpty: toNumber.
			codePoint = lowercaseCodePoint ifFalse: [ newToLower at: codePoint put: lowercaseCodePoint ].
			decomposed := (fields at: 6) findTokens: ' '.
			(decomposed size = 2 and:[decomposed first first ~= $<]) ifTrue:[
				decomposed replace: toNumber.
				baseChar := decomposed first.		"base character"
				compChar := decomposed second.	"composition character"
				newDecompositions at: codePoint put: { baseChar. compChar }.
				(newCompositions at: baseChar ifAbsentPut: [  PluggableDictionary integerDictionary ])
					at: compChar put: codePoint ] ] ].

	"Compact the new dictionaries."
	newCompositions compact.
	newCompositions valuesDo: [ :each | each compact ].
	newDecompositions compact.
	newToUpper compact.
	newToLower compact.
	"Save atomically."
	Compositions := newCompositions.
	Decompositions := newDecompositions.
	ToUpper := newToUpper.
	ToLower := newToLower.

]

{ #category : #'unicode data' }
Unicode class >> parseUnicodeDataFrom: stream [
"
	self halt.
	self parseUnicodeDataFile
"

	| line fieldEnd point fieldStart toNumber generalCategory decimalProperty |

	toNumber := [:quad | ('16r', quad) asNumber].

	GeneralCategory := SparseLargeTable new: 16rE0080 chunkSize: 1024 arrayClass: Array base: 1 defaultValue:  'Cn'.
	DecimalProperty := SparseLargeTable new: 16rE0080 chunkSize: 32 arrayClass: Array base: 1 defaultValue: -1.

	16r3400 to: 16r4DB5 do: [:i | GeneralCategory at: i+1 put: 'Lo'].
	16r4E00 to: 16r9FA5 do: [:i | GeneralCategory at: i+1 put: 'Lo'].
	16rAC00 to: 16rD7FF do: [:i | GeneralCategory at: i+1 put: 'Lo'].

	[(line := stream nextLine) size > 0] whileTrue: [
		fieldEnd := line indexOf: $; startingAt: 1.
		point := toNumber value: (line copyFrom: 1 to: fieldEnd - 1).
		point > 16rE007F ifTrue: [
			GeneralCategory zapDefaultOnlyEntries.
			DecimalProperty zapDefaultOnlyEntries.
			^ self].
		2 to: 3 do: [:i |
			fieldStart := fieldEnd + 1.
			fieldEnd := line indexOf: $; startingAt: fieldStart.
		].
		generalCategory := line copyFrom: fieldStart to: fieldEnd - 1.
		GeneralCategory at: point+1 put: generalCategory.
		generalCategory = 'Nd' ifTrue: [
			4 to: 7 do: [:i |
				fieldStart := fieldEnd + 1.
				fieldEnd := line indexOf: $; startingAt: fieldStart.
			].
			decimalProperty :=  line copyFrom: fieldStart to: fieldEnd - 1.
			DecimalProperty at: point+1 put: decimalProperty asNumber.
		].
	].
	GeneralCategory zapDefaultOnlyEntries.
	DecimalProperty zapDefaultOnlyEntries.

]

{ #category : #recompilation }
Unicode class >> postRecompileAction [
	"ToUpper et al are PluggableDictionary integerDictionarys that reference blocks.
	 Reinitialize them to ensure blocks reference freshly recompiled methods.
	 Don't rebuild to avoid having to go to the internet; just slam in new hashBlocks."

	{Compositions. Decompositions. ToCasefold. ToUpper. ToLower} do:
		[:pluggableDictionary|
		pluggableDictionary hashBlock: PluggableDictionary integerDictionary hashBlock]
]

{ #category : #'accessing - displaying' }
Unicode class >> printingDirection [

	self subclassResponsibility.

]

{ #category : #casing }
Unicode class >> toCasefold: aWideString [
	"Transform a Wide String into fold case.
	This is to enable case insensitive conversion."
	
	^aWideString collect: [:e |
		(ToCasefold at: e charCode ifAbsent: [nil])
			ifNil: [e]
			ifNotNil: [:low | self value: low]]
]

{ #category : #casing }
Unicode class >> toLowercase: aWideString [
	"Transform a Wide String into lowercase.
	This does not handle special cases where number of characters could change.
	The algorithm would work for ByteString, however it's far from the most efficient."
	
	^aWideString collect: [:e |
		(ToLower at: e charCode ifAbsent: [nil])
			ifNil: [e]
			ifNotNil: [:low | self value: low]]
]

{ #category : #casing }
Unicode class >> toLowercaseCode: anInteger [
	"Answer corresponding lower case code for a Character code.
	This does not handle special cases where several codes would be required."
	
	^ToLower at: anInteger ifAbsent: [anInteger]
]

{ #category : #casing }
Unicode class >> toUppercase: aWideString [
	"Transform a Wide String into uppercase.
	This does not handle special cases where number of characters could change.
	The algorithm would work for ByteString, however it's far from the most efficient."
	
	^aWideString collect: [:e |
		(ToUpper at: e charCode ifAbsent: [nil])
			ifNil: [e]
			ifNotNil: [:up | self value: up]]
]

{ #category : #casing }
Unicode class >> toUppercaseCode: anInteger [
	"Answer corresponding upper case code for a Character code.
	This does not handle special cases where several codes would be required."
	
	^ToUpper at: anInteger ifAbsent: [anInteger]
]

{ #category : #'class methods' }
Unicode class >> ucsTable [

	^ UCSTable latin1Table.

]

{ #category : #'unicode data' }
Unicode class >> unicodeData [
	
	^ self fetch: 'Unicode Data' fromUnicodeData: 'UnicodeData.txt'

]

{ #category : #'instance creation' }
Unicode class >> value: code [

	| l |
	code < 256 ifTrue: [^ Character value: code].
	l := Locale currentPlatform languageEnvironment leadingChar.
	^ Character leadingChar: l code: code.

]
