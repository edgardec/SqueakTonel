Class {
	#name : #TextPrintIt,
	#superclass : #TextDoIt,
	#category : #'Collections-Text'
}

{ #category : #'fileIn\/Out' }
TextPrintIt class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^$P
]

{ #category : #'mouse events' }
TextPrintIt >> actOnClickFor: anObject in: aParagraph at: clickPoint editor: editor [
	"Note: evalString gets evaluated IN THE CONTEXT OF anObject
	 -- meaning that self and all instVars are accessible"
	| result range index |
	result := Compiler evaluate: evalString for: anObject.
	result := ' ', result printString,' '.
	"figure out where the attribute ends in aParagraph"
	index := (aParagraph characterBlockAtPoint: clickPoint) stringIndex.
	range := aParagraph text rangeOf: self startingAt: index.
	editor selectFrom: range last+1 to: range last.
	editor zapSelectionWith: result.
	editor selectFrom: range last to: range last + result size.
	^ true 
]
