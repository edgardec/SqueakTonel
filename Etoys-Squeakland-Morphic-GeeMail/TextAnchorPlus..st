Class {
	#name : #TextAnchorPlus,
	#superclass : #TextAnchor,
	#category : #'Etoys-Squeakland-Morphic-GeeMail'
}

{ #category : #'as yet unclassified' }
TextAnchorPlus >> emphasizeScanner: scanner [

	anchoredMorph ifNil: [^self].
	(anchoredMorph owner isKindOf: TextPlusPasteUpMorph) ifFalse: [^anchoredMorph := nil].
	"follwing has been removed - there was no implementation for it"
	"scanner setYFor: anchoredMorph"


]
