Class {
	#name : #TextAnchorTest,
	#superclass : #TestCase,
	#instVars : [
		'anchoredMorph',
		'anchorAttribute',
		'text',
		'textMorph'
	],
	#category : #'MorphicTests-Text Support'
}

{ #category : #utility }
TextAnchorTest >> after: aBlock paddingChangesTo: assertBlock [

	anchoredMorph := TextAnchorTestMorph new.
	anchorAttribute anchoredMorph: anchoredMorph.
	aBlock value.
	self prepareTextMorph.
	assertBlock value: (textMorph paragraph lines first).	
]

{ #category : #failures }
TextAnchorTest >> expectedFailures [

	^ #(testResizeAnchoredMorph)
]

{ #category : #utility }
TextAnchorTest >> prepareTextMorph [

	textMorph := text asMorph.
	self refreshTextMorph.
]

{ #category : #utility }
TextAnchorTest >> refreshTextMorph [

	textMorph imageForm.
	"textMorph fullBounds. --- not yet working."
]

{ #category : #running }
TextAnchorTest >> setUp [

	super setUp.
	anchoredMorph := TextAnchorTestMorph new.
	anchorAttribute := TextAnchor new anchoredMorph: anchoredMorph. 
	text := Text streamContents: [:stream | 
		stream
			nextPutAll: 'Here is a contrived example ';
			nextPutAll: (Text
				string: Character startOfHeader asString
				attributes: {
					anchorAttribute. 
					TextColor color: Color transparent});
			nextPutAll: ' whose morph is in the center.' ].
	self prepareTextMorph.
]

{ #category : #tests }
TextAnchorTest >> testBeginWithAnAnchor [
	
	text := Text streamContents: [:stream | 
		stream 
			nextPutAll: (Text
				string: Character startOfHeader asString
				attributes: {
					anchorAttribute. 
					TextColor color: Color transparent}) ;
			nextPutAll: ' should be able to begin with an embedded object. '].
	self prepareTextMorph.
	self 
		assert: (anchoredMorph ownerChain includes: textMorph);
		assert: anchoredMorph topLeft >= textMorph topLeft.
]

{ #category : #tests }
TextAnchorTest >> testHavingADocumentAnchorAndRelativeTextAnchorPosition [
	
	anchoredMorph := Morph new.
	anchoredMorph textAnchorProperties 
		positionInDocument: 20 @ 10;
		anchorLayout: #document.
	anchorAttribute anchoredMorph: anchoredMorph.
	self prepareTextMorph.
	
	self
		assert: (anchoredMorph ownerChain includes: textMorph);
		 assert: anchoredMorph topLeft >= textMorph topLeft;
		 assert: anchoredMorph top > textMorph top
]

{ #category : #tests }
TextAnchorTest >> testHavingADocumentAnchorShouldNotAffectTheLineHeight [
	
	| firstLine |
	anchoredMorph := Morph new.
	anchoredMorph height: 50.
	anchoredMorph textAnchorProperties 
		positionInDocument: 20 @ 10;
		anchorLayout: #document.
	anchorAttribute anchoredMorph: anchoredMorph.
	self prepareTextMorph.
	 
	firstLine := textMorph paragraph lines first.
	self	
		assert: (firstLine bottom - firstLine top) < 25 
		description: '#document layouted anchor should not affect line height'.
	
]

{ #category : #tests }
TextAnchorTest >> testHavingAMultilineDocumentAnchorAndRelativeTextAnchorPosition [
	
	| secondLine |
	text := Text streamContents: [ :stream | 
		stream
			nextPutAll: 'Example with more than one line.
Here is an example ';
			nextPutAll: (Text
				string: Character startOfHeader asString
				attributes: {anchorAttribute});
			nextPutAll: ' without a morph in the center.' ].
	anchoredMorph := Morph new
		height: 50;
		yourself.
	anchoredMorph textAnchorProperties 
		positionInDocument: 20 @ 10;
		anchorLayout: #document.
	anchorAttribute anchoredMorph: anchoredMorph.
	self prepareTextMorph.

	secondLine := textMorph paragraph lines second.
	self
		assert: (anchoredMorph ownerChain includes: textMorph);
		assert: anchoredMorph topLeft >= textMorph topLeft;
		assert: anchoredMorph top > textMorph top;
		assert: anchoredMorph top > secondLine top.
]

{ #category : #tests }
TextAnchorTest >> testHavingAnAnchorCanBeAlignedDifferently [

	| line |
	anchoredMorph textAnchorProperties verticalAlignment: #(top baseline).
	anchoredMorph textAnchorProperties padding. 1.
	self prepareTextMorph.
	line := textMorph paragraph lines first.
	self assert: anchoredMorph top = (line top + line baseline).
]

{ #category : #tests }
TextAnchorTest >> testHavingAnAnchorInTheCenter [
	
	self 
		assert: (anchoredMorph ownerChain includes: textMorph);
		assert: anchoredMorph topLeft > textMorph topLeft
]

{ #category : #tests }
TextAnchorTest >> testHavingAnAnchorInTheCenterWithHorizontalPadding [

	anchoredMorph textAnchorProperties padding. 30@0.
	
	self 
		assert: (anchoredMorph ownerChain includes: textMorph);
		assert: (anchoredMorph topLeft > textMorph topLeft)
]

{ #category : #tests }
TextAnchorTest >> testHavingAnInlineAnchorAndRelativeTextAnchorPosition [
	
	| positionWithRelativePosition positionWithoutRelativePosition |
	anchoredMorph textAnchorProperties 
		positionInDocument: 20@10;
		anchorLayout: #inline.  
	self refreshTextMorph.
	positionWithRelativePosition := anchoredMorph topLeft.
	
	anchoredMorph textAnchorProperties positionInDocument: nil.  
	self refreshTextMorph.
	positionWithoutRelativePosition := anchoredMorph topLeft.
	
	self	assert: positionWithRelativePosition = positionWithoutRelativePosition
]

{ #category : #tests }
TextAnchorTest >> testLayoutingSetsTheMorphPosition [
	
	anchoredMorph := Morph new.
	anchoredMorph textAnchorProperties
		anchorLayout: #inline.
	anchorAttribute anchoredMorph: anchoredMorph.
	self prepareTextMorph.
	
	textMorph position: 100@100.
	
	self assert: anchoredMorph position > (100@100).
]

{ #category : #'tests-padding' }
TextAnchorTest >> testPaddingBottom [

	self 
		after: [
			anchoredMorph height: 20.
			anchoredMorph textAnchorProperties verticalAlignment: #(bottom baseline).
			anchoredMorph textAnchorProperties padding: (anchoredMorph textAnchorProperties padding bottom: 10)]
		paddingChangesTo: [:line | 
			self assert: anchoredMorph bottom + 10 = line baseline ]
]

{ #category : #'tests-padding' }
TextAnchorTest >> testPaddingBottomAndBottom [

	self 
		after: [
			anchoredMorph height: 20.
			anchoredMorph textAnchorProperties verticalAlignment: #(bottom bottom).
			anchoredMorph textAnchorProperties padding: (anchoredMorph textAnchorProperties padding bottom: 10)]
		paddingChangesTo: [:line | 
			self assert: anchoredMorph bottom + 10 = line bottom ]
]

{ #category : #'tests-padding' }
TextAnchorTest >> testPaddingBottomAndBottomWithConvenienceAlignment [

	self 
		after: [
			anchoredMorph height: 20.
			anchoredMorph textAnchorProperties verticalAlignment: #bottom.
			anchoredMorph textAnchorProperties padding: (anchoredMorph textAnchorProperties padding bottom: 10)]
		paddingChangesTo: [:line | 
			self assert: anchoredMorph bottom + 10 = line bottom ]
]

{ #category : #'tests-padding' }
TextAnchorTest >> testPaddingTop [

	self
		after: [
			anchoredMorph height: 20.
			anchoredMorph textAnchorProperties verticalAlignment: #(top baseline).
			anchoredMorph textAnchorProperties padding: (anchoredMorph textAnchorProperties padding top: 10)]
		paddingChangesTo: [:line | | anchoredMorphTop |
 			anchoredMorphTop := anchoredMorph top - textMorph top.
 			self assert: anchoredMorphTop - 10 = line baseline ]
]

{ #category : #'tests-padding' }
TextAnchorTest >> testPaddingTopAndBottom [
	
	self
		after: [
			anchoredMorph height: 30.
			anchoredMorph textAnchorProperties verticalAlignment: #(#bottom #bottom).
			anchoredMorph textAnchorProperties padding: (anchoredMorph textAnchorProperties padding bottom: 10).
			anchoredMorph textAnchorProperties padding: (anchoredMorph textAnchorProperties padding top: 10).]
		paddingChangesTo: [:line | 
			self assert: anchoredMorph bottom + 10 = line bottom.
			self deny: anchoredMorph top - 10= line top description: 'We only apply padding to the morph position'.]
]

{ #category : #'tests-padding' }
TextAnchorTest >> testPaddingTopAndTop [

	self
		after: [
			anchoredMorph height: 20.
			anchoredMorph textAnchorProperties verticalAlignment: #(top baseline).
			anchoredMorph textAnchorProperties padding: (anchoredMorph textAnchorProperties padding top: 10)]
		paddingChangesTo: [:line | | anchoredMorphTop |
 			anchoredMorphTop := anchoredMorph top - textMorph top.
 			self assert: anchoredMorphTop - 10 = line baseline ]
]

{ #category : #tests }
TextAnchorTest >> testResizeAnchoredMorph [
	
	| anchoredMorph priorExtent |
	anchoredMorph := EllipseMorph new.
	anchoredMorph extent: 50@50.
	
	text := 'Hello, World!\-> X <-\Hello, World!' withCRs asText
		copyReplaceTokens: 'X'
		with: (Text string: Character startOfHeader asString attribute: (TextAnchor new anchoredMorph: anchoredMorph)).
	self prepareTextMorph.	
	
	"Height is easy because morph is higher than the font."
	priorExtent := textMorph extent.
	anchoredMorph height: anchoredMorph height + 15.
	self refreshTextMorph.
	self assert: priorExtent y + 15 equals: textMorph height.
	
	"Width must be at least the text width."
	anchoredMorph width: textMorph width.
	self refreshTextMorph.
	
	priorExtent := textMorph extent.
	anchoredMorph width: anchoredMorph width + 15.
	self refreshTextMorph.
	self assert: priorExtent x + 15 equals: textMorph width.
]

{ #category : #tests }
TextAnchorTest >> testTextAnchorWithAForm [

	anchorAttribute anchoredMorph: (Form dotOfSize: 60).
	self prepareTextMorph.
	
	self 
		assert: textMorph paragraph lines first baseline > 20;
		assert: textMorph submorphs isEmpty
]

{ #category : #tests }
TextAnchorTest >> testTextAnchorWithMorphDefiningItsOwnBaseline [

	self
		after: [
			anchoredMorph textAnchorProperties 
				morphBaselineGetter: #myBaseline;
				verticalAlignment: #(baseline baseline).
			anchoredMorph height: 20]
		paddingChangesTo: [:line |
 			self assert: anchoredMorph top + 5 = line baseline ]
]

{ #category : #tests }
TextAnchorTest >> testTextAnchorsDoNotBreakNormalRendering [
	
	text := Text streamContents: [ :stream | 
		stream
			nextPutAll: 'Here is an example ';
			nextPutAll: (Text
				string: Character startOfHeader asString
				attributes: {});
			nextPutAll: ' without a morph in the center. ' ].
	
	[self 
		shouldnt: [
			self prepareTextMorph.
			textMorph openInWorld] 
		raise: Error] ensure: [ textMorph delete ]
]

{ #category : #tests }
TextAnchorTest >> testTwoTextAnchorsOneWithNestedInterval [

	| anchorAttribute2 anchoredMorph2 |
	anchoredMorph2 := RectangleMorph new.
	anchoredMorph height: 40.
	anchoredMorph2 height: 40.
	anchorAttribute2 := TextAnchor new anchoredMorph: anchoredMorph2. 
	text := Text streamContents: [:stream | 
		stream
			nextPutAll: 'contrived ';
			nextPutAll: Character startOfHeader asString asText;
			nextPutAll: ' whose morph is in the center.';
			nextPutAll: Character startOfHeader asString asText;
			nextPutAll: 'and some more text!'].
	text addAttribute: anchorAttribute from: 11 to: 61.
	text addAttribute: anchorAttribute2 from: 42 to: 48.
	textMorph hResizing: #shrinkWrap.
	self prepareTextMorph.
	
	self assert: textMorph paragraph lines first lineHeight < 50.
	self assert: anchoredMorph right < anchoredMorph2 left
]
