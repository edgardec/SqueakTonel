"
see BorderedMorph
"
Class {
	#name : #InsetBorder,
	#superclass : #SimpleBorder,
	#category : #'Morphic-Borders'
}

{ #category : #accessing }
InsetBorder >> bottomRightColor [
	^ color mixed: 0.65 with: Color white
]

{ #category : #accessing }
InsetBorder >> style [
	^#inset
]

{ #category : #accessing }
InsetBorder >> topLeftColor [
	^ color mixed: 0.70 with: Color black
]

{ #category : #'color tracking' }
InsetBorder >> trackColorFrom: aMorph [
	baseColor isTransparent ifTrue:[self color: aMorph insetColor].
]
