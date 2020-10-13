"
see BorderedMorph
"
Class {
	#name : #RaisedBorder,
	#superclass : #SimpleBorder,
	#category : #'Morphic-Borders'
}

{ #category : #accessing }
RaisedBorder >> bottomRightColor [
	^ color mixed: 0.70 with: Color black
]

{ #category : #accessing }
RaisedBorder >> style [
	^#raised
]

{ #category : #accessing }
RaisedBorder >> topLeftColor [
	^ color mixed: 0.65 with: Color white
]

{ #category : #'color tracking' }
RaisedBorder >> trackColorFrom: aMorph [
	baseColor isTransparent ifTrue:[self color: aMorph raisedColor].
]
