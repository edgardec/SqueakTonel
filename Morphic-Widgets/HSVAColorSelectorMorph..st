"
Colour selector featuring a saturation/volume area, hue selection strip and alpha selection strip.
"
Class {
	#name : #HSVAColorSelectorMorph,
	#superclass : #Morph,
	#instVars : [
		'hsvMorph',
		'aMorph'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #accessing }
HSVAColorSelectorMorph >> aMorph [
	"The alpha-selector morph."
	^ aMorph
]

{ #category : #accessing }
HSVAColorSelectorMorph >> aMorph: anAColorSelectorMorph [
	"The alpha-selector morph."
	aMorph := anAColorSelectorMorph
]

{ #category : #accessing }
HSVAColorSelectorMorph >> alphaSelected: aFloat [
	"The alpha has changed."

	self triggerSelectedColor
]

{ #category : #accessing }
HSVAColorSelectorMorph >> colorSelected: aColor [
	"A color has been selected. Set the base color for the alpha channel."

	self aMorph color: aColor.
	self triggerSelectedColor
]

{ #category : #initialization }
HSVAColorSelectorMorph >> defaultColor [
	"Answer the default color/fill style for the receiver."
	
	^Color transparent

]

{ #category : #accessing }
HSVAColorSelectorMorph >> hsvMorph [
	"Answer the value of hsvMorph"

	^ hsvMorph
]

{ #category : #accessing }
HSVAColorSelectorMorph >> hsvMorph: anObject [
	"Set the value of hsvMorph"

	hsvMorph := anObject
]

{ #category : #initialization }
HSVAColorSelectorMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self
		extent: 180@168;
		changeTableLayout;
		cellGap: 4;
		aMorph: self newAColorMorph;
		hsvMorph: self newHSVColorMorph;
		addMorphBack: self hsvMorph;
		addMorphBack: self aMorph.
	self aMorph color: self hsvMorph selectedColor
]

{ #category : #'private - initialization' }
HSVAColorSelectorMorph >> newAColorMorph [
	"Answer a new alpha color morph."

	^AColorSelectorMorph new
		model: self;
		hResizing: #spaceFill;
		vResizing: #rigid;
		setValueSelector: #alphaSelected:;
		extent: 50@24
]

{ #category : #'private - initialization' }
HSVAColorSelectorMorph >> newHSVColorMorph [
	"Answer a new hue/saturation/volume color morph."

	^HSVColorSelectorMorph new
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		when: #colorSelected send: #colorSelected: to: self
]

{ #category : #accessing }
HSVAColorSelectorMorph >> selectedColor [
	"Answer the selected color."

	^self hsvMorph selectedColor alpha: self aMorph value
]

{ #category : #accessing }
HSVAColorSelectorMorph >> selectedColor: aColor [
	"Set the hue and sv components."

	self aMorph value: aColor alpha.
	self hsvMorph selectedColor: aColor asNontranslucentColor
]

{ #category : #events }
HSVAColorSelectorMorph >> triggerSelectedColor [
	"Trigger the event for the selected colour"
	self
		triggerEvent: #selectedColor
		with: self selectedColor.
	self changed: #selectedColor
]
