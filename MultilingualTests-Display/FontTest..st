"
I am mainly a test for fallback font.
FontTest buildSuite run
"
Class {
	#name : #FontTest,
	#superclass : #TestCase,
	#category : #'MultilingualTests-Display'
}

{ #category : #tests }
FontTest >> testDisplay [
	"self debug: #testDisplay"
	| text font bb destPoint width |
	text := 'test' asText.
	font := TextStyle default fontOfSize: 21.
	text addAttribute: (TextFontReference toFont: font).
	bb := (Form extent: 100 @ 30) getCanvas privatePort.
	bb combinationRule: Form paint.

	font installOn: bb foregroundColor: Color black backgroundColor: Color white.
	destPoint := font displayString: text asString on: bb from: 1 to: 4 at: 0@0 kern: 1.

	width := text inject: 0 into: [:max :char | max + (font widthOf: char)].
	self assert: destPoint x = (width + 4).
	"bb destForm asMorph openInHand."

]

{ #category : #tests }
FontTest >> testFallback [
	"self debug: #testFallback"
	| text font bb destPoint |
	text := (Character value: 257) asString asText.
	font := TextStyle default fontOfSize: 21.
	text addAttribute: (TextFontReference toFont: font).
	bb := (Form extent: 100 @ 30) getCanvas privatePort.
	bb combinationRule: Form paint.

	font installOn: bb foregroundColor: Color black backgroundColor: Color white.
	destPoint := font displayString: text asString on: bb from: 1 to: 1 at: 0@0 kern: 1.

	"bb destForm asMorph openInHand."
	self assert: destPoint x = ((font widthOf: $?) + 1).

]

{ #category : #tests }
FontTest >> testMultistringFallbackFont [
	"self debug: #testMultistringFallbackFont"
	| text p style height width |
	[(TextStyle default fontArray at: JapaneseEnvironment leadingChar)
		ifNil: [^ self]]
		ifError: [:err :rcvr | ^ self].
	text := ((#(20983874 20983876 20983878 )
				collect: [:e | e asCharacter])
				as: String) asText.
	p := NewParagraph new.
	style := TextStyle new leading: 0; newFontArray: {Preferences standardFlapFont}.
	p
		compose: text
		style: style
		from: 1
		in: (0 @ 0 corner: 100 @ 100).
	"See CompositionScanner>>setActualFont: &  
	CompositionScanner>>composeFrom:inRectangle:firstLine:leftSide:rightSide:"
	height := style defaultFont height + style leading.
	width := p caretWidth + (text
				inject: 0
				into: [:tally :next | tally
						+ (style defaultFont widthOf: next)]).
	p adjustRightX.
	self assert: p extent = (width @ height).
	"Display getCanvas
		paragraph: p
		bounds: (10 @ 10 extent: 100 @ 100)
		color: Color black"
]

{ #category : #tests }
FontTest >> testMultistringFont [
	"self debug: #testMultistringFont"
	| text p style height width |
	[(TextStyle default fontArray at: JapaneseEnvironment leadingChar)
		ifNil: [^ self]]
		ifError: [:err :rcvr | ^ self].
	text := ((#(20983874 20983876 20983878 )
				collect: [:e | e asCharacter])
				as: String) asText.
	p := NewParagraph new.
	style := TextStyle default.
	p
		compose: text
		style: style
		from: 1
		in: (0 @ 0 corner: 100 @ 100).
	"See CompositionScanner>>setActualFont: &  
	CompositionScanner>>composeFrom:inRectangle:firstLine:leftSide:rightSide:"
	height := style defaultFont height + style leading.
	width := p caretWidth + (text
				inject: 0
				into: [:tally :next | tally
						+ (style defaultFont widthOf: next)]).
	p adjustRightX.
	self assert: p extent = (width @ height).
	"Display getCanvas
		paragraph: p
		bounds: (10 @ 10 extent: 100 @ 100)
		color: Color black"
]

{ #category : #tests }
FontTest >> testParagraph [
	"self debug: #testParagraph"
	| text p style height width |
	text := 'test' asText.
	p := NewParagraph new.
	style := TextStyle default.
	p
		compose: text
		style: style
		from: 1
		in: (0 @ 0 corner: 100 @ 100).
	"See CompositionScanner>>setActualFont: &  
	CompositionScanner>>composeFrom:inRectangle:firstLine:leftSide:rightSide:"
	height := style defaultFont height + style leading.
	width := (text
				inject: 0
				into: [:tally :next | tally
						+ (style defaultFont widthOf: next)]) + p caretWidth. "because it is added by the paragraph formatting"
	p adjustRightX.
	self assert: p extent = (width @ height)
]

{ #category : #tests }
FontTest >> testParagraphFallback [
	"self debug: #testParagraphFallback"
	| text p style height width e expect |
	e := (Character value: 257) asString.
	text := ('test' , e , e , e , e , 'test') asText.
	expect := 'test????test'.
	p := NewParagraph new.
	style := TextStyle default.
	p
		compose: text
		style: style
		from: 1
		in: (0 @ 0 corner: 100 @ 100).
	"See CompositionScanner>>setActualFont: &  
	CompositionScanner>>composeFrom:inRectangle:firstLine:leftSide:rightSide:"
	height := style defaultFont height + style leading.
	width := (expect
				inject: 0
				into: [:tally :next | tally
						+ (style defaultFont widthOf: next)]) + p caretWidth.
	p adjustRightX.
	self assert: p extent = (width @ height).
	"Display getCanvas
		paragraph: p
		bounds: (10 @ 10 extent: 100 @ 100)
		color: Color black"
]

{ #category : #tests }
FontTest >> testResetAfterEmphasized [
	"self debug: #testResetAfterEmphasized"
	| normal derivative |
	normal := TextStyle defaultFont.
	derivative := normal emphasized: 3.
	self assert: (normal derivativeFonts at: 3) == derivative.
	normal reset.
	self assert: (normal derivativeFonts select:[:any| any isSynthetic]) isEmpty

]
