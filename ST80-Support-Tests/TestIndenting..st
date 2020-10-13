Class {
	#name : #TestIndenting,
	#superclass : #TestCase,
	#instVars : [
		'para'
	],
	#category : #'ST80-Support-Tests'
}

{ #category : #running }
TestIndenting >> setUp [
	| text style |
	text := 'p	' asText, (Text string: 'word word' attribute: (TextIndent tabs: 1)).
	style := (TextStyle named: #Accuny) copy.
	style defaultFontIndex: 2. "Default to Accuny12 as expected by tests."
	para := text asParagraph textStyle: style
]

{ #category : #tests }
TestIndenting >> testBreakAtSpaceLeavesSpaceOnOriginalLine [
	"When an indented line is broken at a space, the character block must still lie in the line crossing the right margin."
	| cb |
	para compositionRectangle: (0@0 extent: para width - 24 @100); updateCompositionHeight.
	para clippingRectangle: (0@0 extent: 200@200).
	cb := para characterBlockForIndex: 7.
	self assert: cb top = 0.
	self assert: cb left >= 24
]

{ #category : #tests }
TestIndenting >> testCR [
	"Checks whether the beginning of a new line starts at the indented position"
	| cb leftMargin |
	para replaceFrom: 7 to: 7 with: (String with: Character cr) displaying: false.
	para clippingRectangle: (0@0 extent: 200@200).
	cb := para characterBlockForIndex: 8.
	leftMargin := para textStyle leftMarginTabAt: 1.
	self assert: cb top > 0.
	self assert: cb left = leftMargin
]

{ #category : #tests }
TestIndenting >> testCR2 [
	"Checks whether the drawing of indented text is really indented..."
	| cb |
	para replaceFrom: 7 to: 7 with: (String with: Character cr) displaying: false.
	para clippingRectangle: (0@0 extent: 200@200).
	cb := para characterBlockForIndex: 8.
	self assert: (para asForm copy: (0@cb top extent: 24@cb height)) isAllWhite
]

{ #category : #tests }
TestIndenting >> testCR3 [
	"Checks whether the beginning of a new line starts at the indented position"
	| cb leftMargin |
	para replaceFrom: 11 to: 11 with: (Text string: (String with: Character cr) attribute: (TextIndent tabs: 1)) displaying: false.
	para clippingRectangle: (0@0 extent: 200@200).
	cb := para characterBlockForIndex: 12.
	leftMargin := para textStyle leftMarginTabAt: 1.
	self assert: cb top > 0.
	self assert: cb left = leftMargin
]

{ #category : #tests }
TestIndenting >> testNewLineAndTabProvidesDoubleIndent [
	"Checks whether the beginning of a new line starts at the indented position"
	| cb leftMargin |
	para replaceFrom: 11 to: 11 with: (Text string: (String with: Character cr) attribute: (TextIndent tabs: 1)) displaying: false.
	cb := para characterBlockForIndex: 12.
	leftMargin := para textStyle leftMarginTabAt: 1.
	self assert: cb top > 0.
	self assert: cb left = leftMargin
]

{ #category : #tests }
TestIndenting >> testNewLineLeaveSpacesOnOldLine [
	"Checks whether the drawing of indented text is really indented..."
	| cb |
	para replaceFrom: 7 to: 7 with: (String with: Character cr) displaying: false.

	cb := para characterBlockForIndex: 8.
	self assert: (para asForm copy: (0@cb top extent: 24@cb height)) isAllWhite
]

{ #category : #tests }
TestIndenting >> testNewLineStartsIndented [
	"Checks whether the beginning of a new line starts at the indented position"
	| cb leftMargin |
	para replaceFrom: 7 to: 7 with: (String with: Character cr) displaying: false.
	leftMargin := para textStyle leftMarginTabAt: 1.
	cb := para characterBlockForIndex: 8.
	self assert: cb top > 0.
	self assert: cb left = leftMargin
]

{ #category : #tests }
TestIndenting >> testNewLineStartsIndentedWhenWrapped [
	"Checks whether the beginning of a new line starts at the indented position"
	| cb leftMargin |
	para compositionRectangle: (0@0 extent: para width - 24@100); updateCompositionHeight.
	para clippingRectangle: (0@0 extent: 200@200).
	cb := para characterBlockForIndex: 8.
	leftMargin := para textStyle leftMarginTabAt: 1.
	self assert: cb top > 0.
	self assert: cb left = leftMargin
]

{ #category : #tests }
TestIndenting >> testSetUp [
	"just reminding us all what the paragraph looks like to begin with. assuming Accuny12 font "
	| cb firstTabStop |
	firstTabStop := para textStyle nextTabXFrom: 1 leftMargin: 0 rightMargin: 200.
	
	cb := para characterBlockForIndex: 1.  "p"
	self assert: cb top = 0.
	self assert: cb left = 0.
	self assert: cb right = 7.
	
	cb := para characterBlockForIndex: 2.  "the tab"
	self assert: cb top = 0.
	self assert: cb left = 7.
	self assert: cb right = firstTabStop.

	cb := para characterBlockForIndex: 3.  "w" 
	self assert: cb top = 0.
	self assert: cb left = firstTabStop.
	self assert: cb right = (firstTabStop + 10).
	
	cb := para characterBlockForIndex: 7.  " " "between word and word"
	self assert: cb top = 0.
	self assert: cb left = (firstTabStop + 28).
	self assert: cb right = (firstTabStop + 33).
	
	cb := para characterBlockForIndex: 11.  "d" "last char"
	self assert: cb top = 0.
	self assert: cb left = (firstTabStop + 55).
	self assert: cb right = (firstTabStop + 61).
	
		

]
