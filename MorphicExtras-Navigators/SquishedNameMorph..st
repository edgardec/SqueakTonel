Class {
	#name : #SquishedNameMorph,
	#superclass : #Morph,
	#instVars : [
		'target',
		'getSelector',
		'setSelector'
	],
	#category : #'MorphicExtras-Navigators'
}

{ #category : #drawing }
SquishedNameMorph >> colorAroundName [

	^Color gray: 0.8
]

{ #category : #drawing }
SquishedNameMorph >> drawOn: aCanvas [

	| font stringToShow nameForm rectForName |

	super drawOn: aCanvas.
	self isEditingName ifTrue: [^self].

	font := self fontForName.
	stringToShow := self stringToShow.
	nameForm := (StringMorph contents: stringToShow font: font) imageForm.
	nameForm := nameForm scaledToSize: (self extent - (4@2) min: nameForm extent).
	rectForName := self bottomLeft + 
			(self width - nameForm width // 2 @ (nameForm height + 2) negated)
				extent: nameForm extent.
	rectForName topLeft eightNeighbors do: [ :pt |
		aCanvas
			stencil: nameForm 
			at: pt
			color: self colorAroundName.
	].
	aCanvas
		stencil: nameForm 
		at: rectForName topLeft 
		color: Color black.


	

]

{ #category : #drawing }
SquishedNameMorph >> fontForName [

	^(TextStyle default fontOfSize: 15) emphasized: 1

]

{ #category : #drawing }
SquishedNameMorph >> isEditingName [

	^((self findA: UpdatingStringMorph) ifNil: [^false]) hasFocus

]

{ #category : #drawing }
SquishedNameMorph >> stringToShow [

	(target isNil or: [getSelector isNil]) ifTrue: [^'????'].
	^target perform: getSelector
]

{ #category : #initialization }
SquishedNameMorph >> target: aTarget getSelector: symbol1 setSelector: symbol2 [

	target := aTarget.
	getSelector := symbol1.
	setSelector := symbol2.
]
