Class {
	#name : #HtmlReadWriterTest,
	#superclass : #TestCase,
	#instVars : [
		'readWriter',
		'html',
		'text'
	],
	#category : #'CollectionsTests-Text'
}

{ #category : #running }
HtmlReadWriterTest >> convertHtml: anHtmlString [

	html := anHtmlString.
	text :=	(readWriter on: html readStream) nextText.
]

{ #category : #running }
HtmlReadWriterTest >> convertText: aText [

	text := aText.
	html := String streamContents: [:writeStream |
		(readWriter on: writeStream) nextPutText: text].
]

{ #category : #running }
HtmlReadWriterTest >> setUp [

	super setUp.
	
	readWriter := HtmlReadWriter new.
	html := ''.
	text := '' asText.
]

{ #category : #tests }
HtmlReadWriterTest >> test01Emphasis [

	{
		'<b>Hello, World!</b>'.
		'Hello, World!' asText addAttribute: TextEmphasis bold.
		
		'<b>Hello</b>, World!'.		
		'Hello, World!' asText addAttribute: TextEmphasis bold from: 1 to: 5.
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs.
		
		self convertText: expectedText.
		self assert: expectedHtml equals: html].
]

{ #category : #tests }
HtmlReadWriterTest >> test02Mixed [
	"At the moment, the html code generation is kind of verbose..."
	
	{
		'<b>Hello, </b><b><i>World!</i></b>!'.
		'Hello, World!!' asText
			addAttribute: TextEmphasis bold from: 1 to: 13;
			addAttribute: TextEmphasis italic from: 8 to: 13.
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs.
		
		self convertText: expectedText.
		self assert: expectedHtml equals: html].
]

{ #category : #tests }
HtmlReadWriterTest >> test03FontTag [

	{
		'<font color="#FFFF00">Hello, World!</font>'.
		'Hello, World!' asText
			addAttribute: (TextColor color: Color yellow).
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs.
		
		self convertText: expectedText.
		self assert: expectedHtml equals: html].
]

{ #category : #tests }
HtmlReadWriterTest >> test04LineBreaks [

	{
		'Hello, World!<br>
'.
		'Hello, World!
' asText.

		'Hello, <b>World!<br>
</b>'.
		'Hello, World!
' asText
			addAttribute: TextEmphasis bold from: 8 to: 14.
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs.
		
		self convertText: expectedText.
		self assert: expectedHtml equals: html.
		
		self convertHtml: html.
		self convertText: text.
		self assert: expectedHtml equals: html.
		
		
		].
]

{ #category : #tests }
HtmlReadWriterTest >> test05Escaping [

	{
		'<b>Morph&gt;&gt;#drawOn:</b>'.
		'Morph>>#drawOn:' asText addAttribute: TextEmphasis bold.
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs.
		
		self convertText: expectedText.
		self assert: expectedHtml equals: html].
]

{ #category : #tests }
HtmlReadWriterTest >> test06Comments [

	| expectedText |
	expectedText := 'Hello & World!' asText
		addAttribute: TextEmphasis bold.
		
	self convertHtml: '
<!-- This is <> JUST! &&;; a COMMENT! -->
<b>Hello &amp; World!</b>'.

	self assert: expectedText string equals: text string.
	self assert: expectedText runs equals: text runs.
]

{ #category : #tests }
HtmlReadWriterTest >> test07CodeRoundTrip [

	| textWithDoIt |
	textWithDoIt := self textWithDoIt.
	self assert: textWithDoIt equals: textWithDoIt printHtmlString asTextFromHtml
	
]

{ #category : #tests }
HtmlReadWriterTest >> test08MultilineCode [

	{ '<code>
<pre>3 + 7.
3 &gt; 4.</pre></code>' .	
	Text string: '3 + 7.
3 > 4.' runs: (RunArray runs: #(13) values: { {TextDoIt evalString: '3 + 7.
3 > 4.' } } )
	}  pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs.
		
		self convertText: expectedText.
		self assert: expectedHtml equals: html].
]

{ #category : #tests }
HtmlReadWriterTest >> test09StruckOut [

	{
		'<s>Hello, World!</s>'.
		'Hello, World!' asText addAttribute: TextEmphasis struckOut.
		
		'<s>Hello</s>, World!'.		
		'Hello, World!' asText addAttribute: TextEmphasis struckOut from: 1 to: 5.
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs.
		
		self convertText: expectedText.
		self assert: expectedHtml equals: html].
]

{ #category : #tests }
HtmlReadWriterTest >> test10Underline [

	{
		'<u>Hello, World!</u>'.
		'Hello, World!' asText addAttribute: TextEmphasis underlined.
		
		'<u>Hello</u>, World!'.		
		'Hello, World!' asText addAttribute: TextEmphasis underlined from: 1 to: 5.
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs.
		
		self convertText: expectedText.
		self assert: expectedHtml equals: html].
]

{ #category : #tests }
HtmlReadWriterTest >> test11Alignment [

	{
	"	'<center>Hello, World!</center>'.
		'Hello, World!' asText addAttribute: TextAlignment centered.
"
		'<div align=left>Hello, World!</div>'.
		'Hello, World!' asText addAttribute: TextAlignment leftFlush.

		'<div align=right>Hello, World!</div>'.
		'Hello, World!' asText addAttribute: TextAlignment rightFlush.

		'<div align=justify>Hello, World!</div>'.
		'Hello, World!' asText addAttribute: TextAlignment justified.
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs.
		
		self convertText: expectedText.
		self assert: expectedHtml equals: html].
]

{ #category : #tests }
HtmlReadWriterTest >> test12AlignmentMixed [

	{
		'<center>Hello, <i>World!</i></center>'.
		'Hello, World!' asText
			addAttribute: TextAlignment centered;
			addAttribute: TextEmphasis italic from: 8 to: 13.
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs.
		
		self convertText: expectedText.
		self assert: expectedHtml equals: html].
]

{ #category : #tests }
HtmlReadWriterTest >> test13SpanTag [

	{
		'<span style="width: 100px;color:#FFFF00; font-style: bold; font-size: 10px">Hello, World!</span>'.
		'Hello, World!' asText
			addAttribute: (TextColor color: Color yellow);
			addAttribute: (TextEmphasis bold).
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs]
]

{ #category : #tests }
HtmlReadWriterTest >> test14NumericalHtmlEntities [

	{
		'&#46;&#x00021;'.
		'.!' asText.
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string]
]

{ #category : #tests }
HtmlReadWriterTest >> test15NestedTagsStillEndBefore [

	{
		'<span><i>Hallo</i> welt</span>'.
		'Hallo welt' asText
			addAttribute: TextEmphasis italic from: 1 to: 5.
	} pairsDo: [:expectedHtml :expectedText |
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		self assert: expectedText runs equals: text runs]
]

{ #category : #tests }
HtmlReadWriterTest >> test16ImgTag [
	<timeout: 10>

	| imgUrl imgExpression formFromUrl formFromExpression |
	imgUrl := 'https://squeak.org/img/downloads/image.png'.
	imgExpression := 'Form dotOfSize: 12@12 color: Color green'.
	
	self ensureSecureInternetConnection.
	
	formFromUrl := (Smalltalk classNamed: 'WebClient') ifNotNil: [:client |
		Form fromBinaryStream: (client httpGet: imgUrl) content asByteArray readStream].
	formFromExpression := Compiler evaluate: imgExpression.
	
	RealEstateAgent scaleFactor = 1.0 ifFalse: [
		formFromUrl := formFromUrl scaledToSize: (formFromUrl extent * RealEstateAgent scaleFactor).
		formFromExpression := formFromExpression scaledToSize: (formFromExpression extent * RealEstateAgent scaleFactor)].
	
	{
		'Hello <img src="{1}"> World' format: { imgUrl }.
		('Hello {1} World' format: { Character startOfHeader }) asText
			addAttribute: formFromUrl asTextAnchor from: 7 to: 7;
			addAttribute: (TextColor color: Color transparent) from: 7 to: 7.

		'Hello <img src="code://{1}"> World' format: { imgExpression }.
		('Hello {1} World' format: { Character startOfHeader }) asText
			addAttribute: formFromExpression asTextAnchor from: 7 to: 7;
			addAttribute: (TextColor color: Color transparent) from: 7 to: 7.
		
	} pairsDo: [:expectedHtml :expectedText |
		
		self convertHtml: expectedHtml.
		self assert: expectedText string equals: text string.
		expectedText runs with: text runs do: [:expectedAttributes :actualAttributes |
			expectedAttributes with: actualAttributes do: [:expectedAttribute :actualAttribute |
				self assert: (expectedAttribute = actualAttribute or: [
					((expectedAttribute respondsTo: #anchoredMorph)
						and: [actualAttribute respondsTo: #anchoredMorph])
						and: [(expectedAttribute anchoredMorph "aForm" unhibernate; bits)
							= (actualAttribute anchoredMorph "aForm" unhibernate; bits)]  ]) ]]].
]

{ #category : #support }
HtmlReadWriterTest >> textWithDoIt [
	" Version of TextAction>>emphasizeScanner: with a Doit on the third line "
	| doit |
	doit := TextDoIt basicNew instVarAt: 1 put: 'Purple ifNil: [Purple := self userInterfaceTheme color ifNil: [Color r: 0.4 g: 0.0 b: 1]].'; yourself.
	^ (Text string: 'emphasizeScanner: scanner
"Set the emphasis for text display"
Purple ifNil: [Purple := self userInterfaceTheme color ifNil: [Color r: 0.4 g: 0.0 b: 1]].
scanner textColor: Purple.' runs: (RunArray runs: #(17 1 7 1 35 1 6 1 6 1 1 6 1 2 1 4 1 18 1 5 1 6 1 1 5 1 2 1 3 1 2 1 3 1 2 1 1 1 1 1 1 7 1 10 1 6 1 ) values: ((Array new: 47) at: 1 put: ((Array new: 1) at: 1 put: (TextEmphasis basicNew instVarAt: 1 put: 1; instVarAt: 2 put: true; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.5); yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.5 b: 0.5); yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); yourself); at: 7 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.25 g: 0.25 b: 0.25); yourself); at: 2 put: doit; yourself); at: 8 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 9 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.5); yourself); at: 2 put: doit; yourself); at: 10 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 11 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 12 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.25 g: 0.25 b: 0.25); yourself); at: 2 put: doit; yourself); at: 13 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 14 put: ((Array new: 2) at: 1 put: (TextEmphasis basicNew instVarAt: 1 put: 1; instVarAt: 2 put: true; yourself); at: 2 put: doit; yourself); at: 15 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 16 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.5 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 17 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 18 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.5); yourself); at: 2 put: doit; yourself); at: 19 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 20 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.5); yourself); at: 2 put: doit; yourself); at: 21 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 22 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.5); yourself); at: 2 put: doit; yourself); at: 23 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 24 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.5 b: 0.0); yourself); at: 2 put: doit; yourself); at: 25 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 26 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 27 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.5); yourself); at: 2 put: doit; yourself); at: 28 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 29 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.5 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 30 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 31 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.5); yourself); at: 2 put: doit; yourself); at: 32 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 33 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.5 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 34 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 35 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.5); yourself); at: 2 put: doit; yourself); at: 36 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 37 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.5 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 38 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.5 b: 0.0); yourself); at: 2 put: doit; yourself); at: 39 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 40 put: ((Array new: 2) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); at: 2 put: doit; yourself); at: 41 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); yourself); at: 42 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.5); yourself); yourself); at: 43 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); yourself); at: 44 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.5); yourself); yourself); at: 45 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); yourself); at: 46 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.25 g: 0.25 b: 0.25); yourself); yourself); at: 47 put: ((Array new: 1) at: 1 put: (TextColor basicNew instVarAt: 1 put: (Color r: 0.0 g: 0.0 b: 0.0); yourself); yourself); yourself)))
]
