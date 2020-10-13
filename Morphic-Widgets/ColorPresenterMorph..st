"
Displays a colour with alpha against a white, hatched and black background.
"
Class {
	#name : #ColorPresenterMorph,
	#superclass : #MorphicModel,
	#instVars : [
		'contentMorph',
		'labelMorph',
		'solidLabelMorph',
		'getColorSelector'
	],
	#classVars : [
		'HatchForm'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'graphics constants' }
ColorPresenterMorph class >> hatchForm [
	"Answer a form showing a grid hatch pattern."

	^HatchForm ifNil: [HatchForm := self newHatchForm]
]

{ #category : #'graphics constants' }
ColorPresenterMorph class >> newHatchForm [
	"Answer a new hatch form."
	
	^(Form
	extent: 8@8
	depth: 1
	fromArray: #( 4026531840 4026531840 4026531840 4026531840 251658240 251658240 251658240 251658240)
	offset: 0@0)
]

{ #category : #'instance creation' }
ColorPresenterMorph class >> on: anObject color: getSel [
	"Answer a new instance of the receiver on the given model using
	the given selectors as the interface."
	
	"(ColorPresenterMorph on: (BorderedMorph new) color: #color) openInWorld"
	
	^self new
		on: anObject 
		color: getSel
]

{ #category : #accessing }
ColorPresenterMorph >> contentMorph [
	"The outer, containing Morph."
	^ contentMorph
]

{ #category : #accessing }
ColorPresenterMorph >> contentMorph: aMorph [
	"The outer, containing Morph."
	contentMorph := aMorph
]

{ #category : #accessing }
ColorPresenterMorph >> getColorSelector [
	"The selector symbol used to retrieve the color from my model."
	^ getColorSelector
]

{ #category : #accessing }
ColorPresenterMorph >> getColorSelector: aSymbol [
	"The selector symbol used to retrieve the color from my model."
	getColorSelector := aSymbol
]

{ #category : #initializing }
ColorPresenterMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		borderWidth: 0;
		changeTableLayout;
		labelMorph: self newLabelMorph;
		solidLabelMorph: self newLabelMorph;
		contentMorph: self newContentMorph;
		addMorphBack: self contentMorph
]

{ #category : #accessing }
ColorPresenterMorph >> labelMorph [
	"The morph that renders the actual color being presented."
	^ labelMorph
]

{ #category : #accessing }
ColorPresenterMorph >> labelMorph: aMorph [
	"The morph that renders the actual color being presented."
	labelMorph := aMorph
]

{ #category : #initializing }
ColorPresenterMorph >> newContentMorph [
	"Answer a new content morph"

	^Morph new
		color: Color transparent;
		changeTableLayout;
		borderStyle: (BorderStyle inset width: 1);
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		addMorph: self newHatchMorph;
		yourself
]

{ #category : #initializing }
ColorPresenterMorph >> newHatchMorph [
	"Answer a new morph showing the three backgrounds; white, hatch pattern, and black, against which my labelMorph is displayed."
	^ Morph new
		 color: Color transparent ;
		 changeProportionalLayout ;
		 vResizing: #spaceFill ;
		 hResizing: #spaceFill ;
		 minWidth: 48 ;
		 minHeight: 12 ;
		
		addMorph: (Morph new color: Color white)
		fullFrame: (LayoutFrame fractions: (0 @ 0 corner: 0.3 @ 1)) ;
		
		addMorph: (Morph new fillStyle: (InfiniteForm with: self class hatchForm))
		fullFrame: (LayoutFrame fractions: (0.3 @ 0 corner: 0.7 @ 1)) ;
		
		addMorph: self solidLabelMorph
		fullFrame: (LayoutFrame fractions: (0.7 @ 0 corner: 1 @ 1)) ;
		
		addMorph: self labelMorph
		fullFrame: (LayoutFrame fractions: (0 @ 0 corner: 1 @ 1))
]

{ #category : #initializing }
ColorPresenterMorph >> newLabelMorph [
	"Answer a new label morph"

	^Morph new
]

{ #category : #initializing }
ColorPresenterMorph >> on: anObject color: getColSel [
	"Set the receiver to the given model parameterized by the given message selectors."

	self
		model: anObject;
		getColorSelector: getColSel;
		updateColor
]

{ #category : #initializing }
ColorPresenterMorph >> setColor: aColor [
	"Update the colour of the labels."

	self labelMorph color: aColor.
	self solidLabelMorph color: aColor asNontranslucentColor
]

{ #category : #accessing }
ColorPresenterMorph >> solidLabelMorph [
	"Answer the value of solidLabelMorph"

	^ solidLabelMorph
]

{ #category : #accessing }
ColorPresenterMorph >> solidLabelMorph: anObject [
	"Set the value of solidLabelMorph"

	solidLabelMorph := anObject
]

{ #category : #initializing }
ColorPresenterMorph >> update: aSymbol [ 
	"Refer to the comment in View|update:."

	aSymbol == self getColorSelector ifTrue: 
		[self updateColor.
		^ self]
]

{ #category : #initializing }
ColorPresenterMorph >> updateColor [
	"Update the color state."

	|col|
	self getColorSelector ifNotNil: [
		col := (self model perform: self getColorSelector) ifNil: [Color transparent].
		self setColor: col]
]
