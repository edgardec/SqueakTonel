"
A CharacterBlockScannerForMVC is specialization of a CharacterBlockScanner used for compatibility with Smalltalk-80 Model View Controller framework.

"
Class {
	#name : #CharacterBlockScannerForMVC,
	#superclass : #CharacterBlockScanner,
	#category : #'ST80-Support'
}

{ #category : #private }
CharacterBlockScannerForMVC >> buildCharacterBlockIn: para [
	"This method is used by the MVC version only."
	
	| lineIndex runLength lineStop stopCondition |
	"handle nullText"
	(para numberOfLines = 0 or: [text size = 0])
		ifTrue:	[^ CharacterBlock new stringIndex: 1  "like being off end of string"
					text: para text
					topLeft: (para leftMarginForDisplayForLine: 1 alignment: (alignment ifNil:[textStyle alignment]))
								@ para compositionRectangle top
					extent: 0 @ textStyle lineGrid].
	"find the line"
	lineIndex := para lineIndexOfTop: characterPoint y.
	destY := para topAtLineIndex: lineIndex.
	line := para lines at: lineIndex.
	lastIndex := line first.
	rightMargin := para rightMarginForDisplay.
	self setStopConditions.  " also loads the font, alignment and all emphasis attributes "

	(lineIndex = para numberOfLines and:
		[(destY + line lineHeight) < characterPoint y])
			ifTrue:	["if beyond lastLine, force search to last character"
					self characterPointSetX: rightMargin]
			ifFalse:	[characterPoint y < (para compositionRectangle) top
						ifTrue: ["force search to first line"
								characterPoint := (para compositionRectangle) topLeft].
					characterPoint x > rightMargin
						ifTrue:	[self characterPointSetX: rightMargin]].
	destX := leftMargin := para leftMarginForDisplayForLine: lineIndex alignment: alignment.
	nextLeftMargin:= para leftMarginForDisplayForLine: lineIndex+1 alignment: alignment.
	runLength := text runLengthFor: line first.
	lineStop := characterIndex	"scanning for index"
		ifNil: [ line last ].			"scanning for point"
	runStopIndex := lastIndex + (runLength - 1) min: lineStop.
	lastCharacterWidth := 0.
	spaceCount := 0.
	self handleIndentation.

	[stopCondition := self scanCharactersFrom: lastIndex to: runStopIndex
			in: text string rightX: characterPoint x.
	"see setStopConditions for stopping conditions for character block operations."
	self perform: stopCondition] whileFalse.

	^characterIndex == nil
			ifTrue: ["characterBlockAtPoint"
					^ CharacterBlock new stringIndex: lastIndex text: text
						topLeft: characterPoint + (font descentKern @ 0)
						extent: lastCharacterWidth @ line lineHeight]
			ifFalse: ["characterBlockForIndex"
					^ CharacterBlock new stringIndex: lastIndex text: text
						topLeft: characterPoint + ((font descentKern) - kern @ 0)
						extent: lastCharacterWidth @ line lineHeight]
]

{ #category : #scanning }
CharacterBlockScannerForMVC >> characterBlockAtPoint: aPoint in: aParagraph [
	"Answer a CharacterBlock for character in aParagraph at point aPoint. It 
	is assumed that aPoint has been transformed into coordinates appropriate 
	to the text's destination form rectangle and the composition rectangle."

	self initializeFromParagraph: aParagraph clippedBy: aParagraph clippingRectangle.
	characterPoint := aPoint.
	^self buildCharacterBlockIn: aParagraph
]

{ #category : #scanning }
CharacterBlockScannerForMVC >> characterBlockForIndex: targetIndex in: aParagraph [ 
	"Answer a CharacterBlock for character in aParagraph at targetIndex. The 
	coordinates in the CharacterBlock will be appropriate to the intersection 
	of the destination form rectangle and the composition rectangle."

	self 
		initializeFromParagraph: aParagraph 
		clippedBy: aParagraph clippingRectangle.
	characterIndex := targetIndex.
	characterPoint := 
		aParagraph rightMarginForDisplay @ 
			(aParagraph topAtLineIndex: 
				(aParagraph lineIndexOfCharacterIndex: characterIndex)).
	^self buildCharacterBlockIn: aParagraph
]

{ #category : #private }
CharacterBlockScannerForMVC >> characterPointSetX: xVal [
	characterPoint := xVal @ characterPoint y
]

{ #category : #'stop conditions' }
CharacterBlockScannerForMVC >> crossedX [
	characterIndex == nil ifFalse: [
		"If the last character of the last line is a space,
		and it crosses the right margin, then locating
		the character block after it is impossible without this hack."
		characterIndex > text size ifTrue: [
			lastIndex := characterIndex.
			characterPoint := (nextLeftMargin ifNil: [leftMargin]) @ (destY + line lineHeight).
			^true]].
	^super crossedX
]
