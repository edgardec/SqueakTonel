"
A SignedWordArray store 64bit signed Integer values in the range -16r80000000 (-2,147,483,648) to 16r7FFFFFFF (2,147,483,647)
Negative values are stored as 2's complement.
"
Class {
	#name : #SignedWordArray,
	#superclass : #SignedIntegerArray,
	#type : #words,
	#category : #'Collections-Arrayed'
}

{ #category : #accessing }
SignedWordArray >> at: index [
	| word |
	<primitive: 165>
	word := self basicAt: index.
	word < 16r3FFFFFFF ifTrue:[^word]. "Avoid LargeInteger computations"
	^word >= 16r80000000	"Negative?!"
		ifTrue:["word - 16r100000000"
				(word bitInvert32 + 1) negated]
		ifFalse:[word]
]

{ #category : #accessing }
SignedWordArray >> at: index put: anInteger [
	| word |
	<primitive: 166>
	anInteger < 0
		ifTrue:[anInteger < -16r80000000 ifTrue: [self error: anInteger asString , ' out of range'].
				"word := 16r100000000 + anInteger"
				word := (anInteger + 1) negated bitInvert32]
		ifFalse:[anInteger > 16r7FFFFFFF ifTrue: [self error: anInteger asString , ' out of range'].
				word := anInteger].
	self  basicAt: index put: word.
	^anInteger
]

{ #category : #accessing }
SignedWordArray >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 4
]
