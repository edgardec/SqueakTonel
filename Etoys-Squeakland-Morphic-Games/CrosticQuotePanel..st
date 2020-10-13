Class {
	#name : #CrosticQuotePanel,
	#superclass : #WordGamePanelMorph,
	#instVars : [
		'cluesPanel'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #geometry }
CrosticQuotePanel >> extent: newExtent [

	| w h nAcross relLoc topLeft |
	w := self firstSubmorph width - 1.  h := self firstSubmorph height - 1.
	nAcross := newExtent x - (self borderWidth-1*2)-1 // w.
	topLeft := self position + self borderWidth - 1.
	submorphs withIndexDo:
		[:m :i | 
		relLoc := (i-1 \\ nAcross * w) @ (i-1 // nAcross * h).
		m position: topLeft + relLoc].
	super extent: ((w * nAcross + 1) @ (submorphs size - 1 // nAcross + 1 * h+1))
					+ (self borderWidth - 1 * 2).

]

{ #category : #defaults }
CrosticQuotePanel >> highlight: morph [

	self unhighlight.
	cluesPanel unhighlight.
	morph startOfWord morphsInWordDo:
		[:m | m color: Color lightGreen.
		(cluesPanel letterMorphs at: m indexInQuote) color: Color lightMagenta].
	morph color: Color green.
	(cluesPanel letterMorphs at: morph indexInQuote) color: Color magenta.

]

{ #category : #defaults }
CrosticQuotePanel >> keyCharacter: aLetter atIndex: indexInQuote nextFocus: nextFocus [

	(self letterMorphs at: indexInQuote) setLetter: aLetter.
	(cluesPanel letterMorphs at: indexInQuote) setLetter: aLetter.
	self highlight: nextFocus

]

{ #category : #defaults }
CrosticQuotePanel >> lostFocus [

	self unhighlight.
	cluesPanel unhighlight
]

{ #category : #initialization }
CrosticQuotePanel >> quote: quoteWithBlanks answers: theAnswers cluesPanel: panel [

	| n morph prev clueIxs |
	cluesPanel := panel.
	self color: Color gray.
	clueIxs := Array new: quoteWithBlanks size.
	theAnswers withIndexDo: [:a :i | a do: [:j | clueIxs at: j put: i]].
	letterMorphs := OrderedCollection new.
	prev := nil.
	self addAllMorphs: (quoteWithBlanks asArray collect:
		[:c |
		c isLetter
			ifTrue: [n := letterMorphs size + 1.
					morph := WordGameLetterMorph new boxed.
					CrosticPanel oldStyle
						ifTrue: [morph indexInQuote: n id1: n printString.
								morph id2: (($A to: $Z) at: (clueIxs at: n)) asString]
						ifFalse: [morph indexInQuote: n id1: nil].
					morph setLetter: Character space.
					morph on: #mouseDown send: #mouseDownEvent:letterMorph: to: self.
					morph on: #keyStroke send: #keyStrokeEvent:letterMorph: to: self.
					letterMorphs addLast: morph]
			ifFalse: [morph := WordGameLetterMorph new boxed indexInQuote: nil id1: nil.
					CrosticPanel oldStyle ifTrue: [morph extent: 26@24  "Oops"]].
		morph predecessor: prev.
		prev ifNotNil: [prev successor: morph].
		prev := morph]).

]
