Class {
	#name : #BorderedStringMorph,
	#superclass : #StringMorph,
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #drawing }
BorderedStringMorph >> drawOn: aCanvas [
	| nameForm |
	font := self fontToUse.
	nameForm := Form extent: bounds extent depth: 8.
	nameForm getCanvas drawString: contents at: 0@0 font: self fontToUse color: Color black.
	(bounds origin + 1) eightNeighbors do: [ :pt |
		aCanvas
			stencil: nameForm 
			at: pt
			color: self borderColor.
	].
	aCanvas
		stencil: nameForm 
		at: bounds origin + 1 
		color: color.


	

]

{ #category : #initialization }
BorderedStringMorph >> initWithContents: aString font: aFont emphasis: emphasisCode [
	super initWithContents: aString font: aFont emphasis: emphasisCode.
	self borderStyle: (SimpleBorder width: 1 color: Color white).
]

{ #category : #initialization }
BorderedStringMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	self
		borderStyle: (SimpleBorder width: 1 color: Color white)
]

{ #category : #accessing }
BorderedStringMorph >> measureContents [
	^super measureContents +2.
]
