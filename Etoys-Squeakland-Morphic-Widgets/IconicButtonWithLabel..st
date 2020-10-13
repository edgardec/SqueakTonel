Class {
	#name : #IconicButtonWithLabel,
	#superclass : #IconicButton,
	#instVars : [
		'label',
		'labelMorph'
	],
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #'as yet unclassified' }
IconicButtonWithLabel >> initializeWithThumbnail: aThumbnail withLabel: aLabel andColor: aColor andSend: aSelector to: aReceiver [ 	
	"Initialize the receiver to show aThumbnail on its face, giving it the label supplied and arranging for it, when the button goes down on it, to obtain a new morph by sending the supplied selector to the supplied receiver   If the label parameter is nil or an empty string, no label is used."

	| nonTranslucent |
	nonTranslucent := aColor asNontranslucentColor.

	aLabel isEmptyOrNil ifFalse: [
		labelMorph := StringMorph contents: aLabel font:  Preferences standardEToysFont.
	].

	self
		beTransparent;
		labelGraphic: (aThumbnail originalForm) color: nonTranslucent andLabel: labelMorph;
		borderWidth: 0;
		target: aReceiver;
		actionSelector: #launchPartVia:label:;
		arguments: {aSelector. aLabel};
		actWhen: #buttonDown.

	self stationarySetup.
]

{ #category : #'as yet unclassified' }
IconicButtonWithLabel >> labelGraphic: aForm color: nonTranslucent andLabel: aStringMorph [
	| graphicalMorph labeledItem actualForm |

	labeledItem := AlignmentMorph newColumn.
	labeledItem hResizing: #shrinkWrap.
	labeledItem vResizing: #shrinkWrap.
	labeledItem color: nonTranslucent.
	labeledItem borderWidth: 0.
	labeledItem
		layoutInset: 4@0;
		cellPositioning: #center.

	self removeAllMorphs.
	actualForm := (Form extent: aForm extent depth: 32) fillColor: nonTranslucent.
	aForm displayOn: actualForm at: 0@0 rule: 34.
	graphicalMorph := SketchMorph withForm: actualForm.

	labeledItem addMorph: graphicalMorph.
	labeledItem addMorphBack: (Morph new extent: (4@4)) beTransparent.
	aStringMorph ifNotNil: [
		labeledItem addMorphBack: aStringMorph
	].

	self addMorph: labeledItem.
	self extent: submorphs first fullBounds extent + (self borderWidth + 6).
	labeledItem lock.

]

{ #category : #'as yet unclassified' }
IconicButtonWithLabel >> labelString: aString [

	labelMorph ifNotNil: [
		labelMorph contents: aString.
		self extent: self firstSubmorph fullBounds extent + (self borderWidth + 6).
	].

]
