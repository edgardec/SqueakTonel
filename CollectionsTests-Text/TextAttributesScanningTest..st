"
A TextAttributesTest verifies storing and reading text attributes in file out chunk format.

"
Class {
	#name : #TextAttributesScanningTest,
	#superclass : #TestCase,
	#category : #'CollectionsTests-Text'
}

{ #category : #tests }
TextAttributesScanningTest >> doTestTextFontReferenceSerializationFor: font [

	| att att3 fontReferenceString stream |
	att := TextFontReference toFont: font.
	stream := self streamWithAttribute: att.
	fontReferenceString := self testScanAttribute: att fromStream: stream encodedWithCharacter: $F decodedWithBlock: [:strm | strm upToEnd].
	self assert: font familyName, '#', font height equals: fontReferenceString.
	stream reset.
	att3 := TextAttribute newFrom: stream.
	self assert: att equals: att3.
]

{ #category : #tests }
TextAttributesScanningTest >> doTestTextFontReferenceTTCFor: font [

	| att att3 fontReferenceString stream |
	att := TextFontReference toFont: font.
	stream := self streamWithAttribute: att.
	fontReferenceString := self testScanAttribute: att fromStream: stream encodedWithCharacter: $F decodedWithBlock: [:strm | strm upToEnd].
	self assert: font familyName, '#', font height equals: fontReferenceString.
	stream reset.
	att3 := TextAttribute newFrom: stream.
	"test font height only, see comment above"
	self assert: att font height equals: att3 font height.
	"we really want an exact match, which probably requires different implentation of TextFontReference"
	self assert: att equals: att3.

]

{ #category : #failures }
TextAttributesScanningTest >> expectedFailures [
	"Tests for text attributes that are apparently unused, and that may be candidates
	for removal from the image"
	^#(
		testTextIndent
		testTextMessageLink
		testTextPlusJumpStart
		testTextPlusJumpEnd
		
		"Actually failing tests which document bugs to be fixed (pre)"
		testTextAnchor "Is actually used but does not have a writeScanOn: implementation"
		testTextFontReferenceForBoldFont
		testTextFontReferenceTTCForBoldFont
		)
]

{ #category : #tests }
TextAttributesScanningTest >> streamWithAttribute: att [
	"Encode a TextAttribute on a Stream, and return a readStream on it"
	| strm |
	strm := (String new: 16) writeStream.
	att writeScanOn: strm.
	^strm readStream
]

{ #category : #tests }
TextAttributesScanningTest >> testPluggableTextAttribute [
	| att strm |
	att := PluggableTextAttribute evalBlock: [ #foo ].
	strm := WriteStream on: ''.
	self assert: (att respondsTo: #writeScanOn:).
	self
		should: [att writeScanOn: strm]
		raise: Error
		description: 'PluggableTextAttribute are not intended to be serialized'.

]

{ #category : #tests }
TextAttributesScanningTest >> testRunArrayScan [
	| ra ra2 strm |
	ra := RunArray scanFrom: (ReadStream on: '(14 50 312)f1,f1b,f1LInteger +;i').
	strm := WriteStream on: ''.
	ra writeScanOn: strm.
	
	ra2 := RunArray scanFrom: strm readStream.
	self assert: ra equals: ra2

]

{ #category : #tests }
TextAttributesScanningTest >> testScanAttribute: att encodedWithCharacter: aCharacter [
	^self testScanAttribute: att encodedWithCharacter: aCharacter decodedWithBlock: [:strm | att]

]

{ #category : #tests }
TextAttributesScanningTest >> testScanAttribute: att encodedWithCharacter: aCharacter decodedWithBlock: aBlock [
	"Test official encoding API, internal encoding details, and official decoding API for a specific TextAttribute"
	| stream att2 att3 |
	"First encode the TextAttribute on a Stream"
	stream := self streamWithAttribute: att.
	"Then test internal encoding"
	att2 := self testScanAttribute: att fromStream: stream encodedWithCharacter: aCharacter decodedWithBlock: aBlock.
	self assert: att equals: att2.
	"Then test normal decoding API"
	stream reset.
	att3 := TextAttribute newFrom: stream.
	self assert: att equals: att3.

]

{ #category : #tests }
TextAttributesScanningTest >> testScanAttribute: att fromStream: strm encodedWithCharacter: aCharacter decodedWithBlock: aBlock [
	"This is intended to test internal encoding of a TextAttribute.
	The first char is decoded by this method, the optional parameters by aBlock"
	| identifierCharacter att2 |
	identifierCharacter := strm next.
	self assert: aCharacter equals: identifierCharacter.
	self assert: att class equals: (TextAttribute classFor: aCharacter).
	att2 := aBlock value: strm.
	self assert: strm atEnd.
	^att2

]

{ #category : #tests }
TextAttributesScanningTest >> testTextAction [
	self assert: true
		description: 'TextAction is abstract and does not need to support text filein and fileout'.

]

{ #category : #tests }
TextAttributesScanningTest >> testTextAlignment [
	#(leftFlush rightFlush centered justified) do: [:alignment |
		| att |
		att := TextAlignment perform: alignment.
		self testScanAttribute: att encodedWithCharacter: $a decodedWithBlock: [:strm |
			TextAlignment new alignment: (Integer readFrom: strm ifFail: [-1])].
		self testScanAttribute: att encodedWithCharacter: $a decodedWithBlock: [:strm |
			TextAlignment scanFrom: strm]].
]

{ #category : #tests }
TextAttributesScanningTest >> testTextAnchor [
	| att strm |
	att := TextAnchor new anchoredMorph: RectangleMorph new initialize.
	strm := WriteStream on: ''.
	self assert: (att respondsTo: #writeScanOn:).
	att writeScanOn: strm.
	self assert: strm contents notEmpty.
]

{ #category : #tests }
TextAttributesScanningTest >> testTextAttributeClassFor [
	"Verify class identifiers as used in RunArray class>>scanFrom:"

	self assert: TextAlignment equals: (TextAttribute classFor: $a).
	self assert: TextFontChange equals: (TextAttribute classFor: $f).
	self assert: TextFontReference equals: (TextAttribute classFor: $F).
	self assert: TextEmphasis equals: (TextAttribute classFor: $b).
	self assert: TextEmphasis equals: (TextAttribute classFor: $i).
	self assert: TextEmphasis equals: (TextAttribute classFor: $u).
	self assert: TextEmphasis equals: (TextAttribute classFor: $=).
	self assert: TextEmphasis equals: (TextAttribute classFor: $n).
	self assert: TextKern equals: (TextAttribute classFor: $-).
	self assert: TextKern equals: (TextAttribute classFor: $+).
	self assert: TextColor equals: (TextAttribute classFor: $c).
	self assert: TextLink equals: (TextAttribute classFor: $L).
	self assert: TextURL equals: (TextAttribute classFor: $R).
	self assert: TextSqkPageLink equals: (TextAttribute classFor: $q).
	self assert: TextSqkProjectLink equals: (TextAttribute classFor: $p).
	self assert: TextPrintIt equals: (TextAttribute classFor: $P).
	self assert: TextDoIt equals: (TextAttribute classFor: $d).

]

{ #category : #tests }
TextAttributesScanningTest >> testTextColor [
	| att |
	att := TextColor color: Color red.
	self testScanAttribute: att encodedWithCharacter: $c decodedWithBlock: [:strm | TextColor scanFrom: strm]
]

{ #category : #tests }
TextAttributesScanningTest >> testTextDoIt [
	| att |
	att := TextDoIt evalString: 'foo'.
	self testScanAttribute: att encodedWithCharacter: $d decodedWithBlock: [:strm | TextDoIt scanFrom: strm]
]

{ #category : #tests }
TextAttributesScanningTest >> testTextEmphasisBold [
	self testScanAttribute: TextEmphasis bold encodedWithCharacter: $b

]

{ #category : #tests }
TextAttributesScanningTest >> testTextEmphasisItalic [
	self testScanAttribute: TextEmphasis italic encodedWithCharacter: $i
]

{ #category : #tests }
TextAttributesScanningTest >> testTextEmphasisNormal [
	self testScanAttribute: TextEmphasis normal encodedWithCharacter: $n
]

{ #category : #tests }
TextAttributesScanningTest >> testTextEmphasisStruckOut [
	self testScanAttribute: TextEmphasis struckOut encodedWithCharacter: $=
]

{ #category : #tests }
TextAttributesScanningTest >> testTextEmphasisUnderlined [
	self testScanAttribute: TextEmphasis underlined encodedWithCharacter: $u
]

{ #category : #tests }
TextAttributesScanningTest >> testTextFontChange [
	| att |
	att := TextFontChange font3.
	self testScanAttribute: att encodedWithCharacter: $f decodedWithBlock: [:strm | TextFontChange new fontNumber: (Integer readFrom: strm ifFail: [0])]
]

{ #category : #tests }
TextAttributesScanningTest >> testTextFontReference [
	"Test TextFontReference with a StrikeFont"
	| font |
	font := TTCFont familyName: 'BitstreamVeraSans' pointSize: 9 emphasis: 0.
	self doTestTextFontReferenceSerializationFor: font.

]

{ #category : #tests }
TextAttributesScanningTest >> testTextFontReferenceForBoldFont [
	"Test TextFontReference with a StrikeFont"
	| font |
	font := TTCFont familyName: 'BitstreamVeraSans' pointSize: 9 emphasis: 1.
	self doTestTextFontReferenceSerializationFor: font.

]

{ #category : #tests }
TextAttributesScanningTest >> testTextFontReferenceTTC [
	"n.b. A TextFontReference specifies font height only, which is not sufficient
	to identify a unique TTCFont. Here we test only that the font height of the
	selected font matches the TextFontReference specification."

	"(self selector: #testTextFontReferenceTTC) debug"

	"Test TextFontReference with a TTCFont"
	| font |
	font := TTCFont familyName: 'BitstreamVeraSans' pointSize: 9 emphasis: 0.
	self doTestTextFontReferenceTTCFor: font.
]

{ #category : #tests }
TextAttributesScanningTest >> testTextFontReferenceTTCForBoldFont [
	"n.b. A TextFontReference specifies font height only, which is not sufficient
	to identify a unique TTCFont. Here we test only that the font height of the
	selected font matches the TextFontReference specification."

	"(self selector: #testTextFontReferenceTTC) debug"

	"Test TextFontReference with a TTCFont"
	| font |
	font := TTCFont familyName: 'BitstreamVeraSans' pointSize: 9 emphasis: 1.
	self doTestTextFontReferenceTTCFor: font.
]

{ #category : #tests }
TextAttributesScanningTest >> testTextIndent [
	"TextIndent is unused and does not have in implemention to support text
	filein and fileout. See TextAlignment for its likely replacement."
	self fail: 'TextIndent is apparently unused'
]

{ #category : #tests }
TextAttributesScanningTest >> testTextKern [
	| att |

	att := TextKern kern: 5.
	self testScanAttribute: att encodedWithCharacter: $+ decodedWithBlock: [:strm |
		strm skip: -1.	"The first $+ was consumed by the encoding letter test"
		5 timesRepeat: [self assert: $+ equals: strm next].
		att].
	
	att := TextKern kern: -5.
	self testScanAttribute: att encodedWithCharacter: $- decodedWithBlock: [:strm |
		strm skip: -1.
		5 timesRepeat: [self assert: $- equals: strm next].
		att].
]

{ #category : #tests }
TextAttributesScanningTest >> testTextLink [
	| att |
	att := TextLink new classAndMethod: 'class and method string'.
	self testScanAttribute: att encodedWithCharacter: $L decodedWithBlock: [:strm | TextLink scanFrom: strm].
]

{ #category : #tests }
TextAttributesScanningTest >> testTextMessageLink [
	| att strm |
	att := TextMessageLink message: Message someInstance.
	strm := WriteStream on: ''.
	self assert: (att respondsTo: #writeScanOn:).
	att writeScanOn: strm. "FIXME - is TextMessageLink used for anything?"
	self assert: strm contents notEmpty.

]

{ #category : #tests }
TextAttributesScanningTest >> testTextPlusJumpEnd [
	| att strm |
	att := TextPlusJumpEnd new jumpLabel: 'this is a jump label'.
	strm := WriteStream on: ''.
	self assert: (att respondsTo: #writeScanOn:).
	att writeScanOn: strm. "FIXME - is TextPlusJumpEnd used for anything?"
	self assert: strm contents notEmpty.
]

{ #category : #tests }
TextAttributesScanningTest >> testTextPlusJumpStart [
	| att strm |
	att := TextPlusJumpStart new jumpLabel: 'this is a jump label'.
	strm := WriteStream on: ''.
	self assert: (att respondsTo: #writeScanOn:).
	att writeScanOn: strm. "FIXME - is TextPlusJumpStart used for anything?"
	self assert: strm contents notEmpty.

]

{ #category : #tests }
TextAttributesScanningTest >> testTextPrintIt [
	| att |
	att := TextPrintIt evalString: 'foo'.
	self testScanAttribute: att encodedWithCharacter: $P decodedWithBlock: [:strm | TextPrintIt scanFrom: strm]
]

{ #category : #tests }
TextAttributesScanningTest >> testTextSqkPageLink [
	| att |
	att := TextSqkPageLink new url: 'a URL string'.
	self testScanAttribute: att encodedWithCharacter: $q decodedWithBlock: [:strm | TextSqkPageLink scanFrom: strm]
]

{ #category : #tests }
TextAttributesScanningTest >> testTextSqkProjectLink [
	| att |
	att := TextSqkProjectLink new url: 'a URL string'.
	self testScanAttribute: att encodedWithCharacter: $p decodedWithBlock: [:strm | TextSqkProjectLink scanFrom: strm]
]

{ #category : #tests }
TextAttributesScanningTest >> testTextURL [
	| att |
	att := TextURL new url: 'a URL string'.
	self testScanAttribute: att encodedWithCharacter: $R decodedWithBlock: [:strm | TextURL scanFrom: strm]
]
