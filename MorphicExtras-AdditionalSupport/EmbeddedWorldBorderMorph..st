Class {
	#name : #EmbeddedWorldBorderMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'heights',
		'minWidth',
		'minHeight'
	],
	#category : #'MorphicExtras-AdditionalSupport'
}

{ #category : #menus }
EmbeddedWorldBorderMorph >> addCustomMenuItems: menu hand: aHandMorph [

	super addCustomMenuItems: menu hand: aHandMorph.

	self worldIEnclose
		addScalingMenuItems: menu 
		hand: aHandMorph

]

{ #category : #boxes }
EmbeddedWorldBorderMorph >> appViewBoxArea [

	^self genericBoxArea: 1

]

{ #category : #boxes }
EmbeddedWorldBorderMorph >> boxesAndColorsAndSelectors [

	^{
		{self zoomBoxArea. Color blue. #toggleZoom}.
		{self appViewBoxArea. Color yellow. #goAppView}.
		{self factoryViewBoxArea. Color red. #goFactoryView}.
		{self fullViewBoxArea. Color cyan. #goFullView}.
		{self normalEntryBoxArea. Color white. #goNormalProjectEntry}.
	}
]

{ #category : #drawing }
EmbeddedWorldBorderMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	self boxesAndColorsAndSelectors do: [ :each |
		aCanvas fillRectangle: each first fillStyle: each second
	].


]

{ #category : #geometry }
EmbeddedWorldBorderMorph >> extent: aPoint [

	bounds extent = aPoint ifFalse: [
		self changed.
		bounds := bounds topLeft extent: aPoint.
		self myWorldChanged.
	].

]

{ #category : #boxes }
EmbeddedWorldBorderMorph >> factoryViewBoxArea [

	^self genericBoxArea: 2

]

{ #category : #boxes }
EmbeddedWorldBorderMorph >> fullViewBoxArea [

	^self genericBoxArea: 3

]

{ #category : #boxes }
EmbeddedWorldBorderMorph >> genericBoxArea: countDownFromTop [

	^self innerBounds right @ (self top + (countDownFromTop * 2 * self borderWidth)) 
		extent: self borderWidth asPoint

]

{ #category : #navigation }
EmbeddedWorldBorderMorph >> goAppView [

	self worldIEnclose showApplicationView


]

{ #category : #navigation }
EmbeddedWorldBorderMorph >> goFactoryView [

	self worldIEnclose showFactoryView


]

{ #category : #navigation }
EmbeddedWorldBorderMorph >> goFullView [

	self worldIEnclose showFullView


]

{ #category : #navigation }
EmbeddedWorldBorderMorph >> goNormalProjectEntry [

	| w |
	w := self worldIEnclose.
	self delete.
	w project enter.


]

{ #category : #'event handling' }
EmbeddedWorldBorderMorph >> handlesMouseDown: evt [

	self boxesAndColorsAndSelectors do: [ :each |
		(each first containsPoint: evt cursorPoint) ifTrue: [^true]
	].
	^false


]

{ #category : #initialization }
EmbeddedWorldBorderMorph >> initialize [

	super initialize.
	self setBalloonText: 'This is the frame of an embedded project. Click on the colored boxes:
blue - expand or reduce
yellow - app view
red - factory view
cyan - full view
white - enter the project completely' translated
]

{ #category : #layout }
EmbeddedWorldBorderMorph >> minHeight: anInteger [

	super minHeight: anInteger.
	minHeight := anInteger.
]

{ #category : #layout }
EmbeddedWorldBorderMorph >> minWidth: anInteger [

	super minWidth: anInteger.
	minWidth := anInteger.
]

{ #category : #'WiW support' }
EmbeddedWorldBorderMorph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^20		"Embedded worlds come in front of other worlds' Project navigation morphs"
]

{ #category : #'event handling' }
EmbeddedWorldBorderMorph >> mouseDown: evt [

	self boxesAndColorsAndSelectors do: [ :each |
		(each first containsPoint: evt cursorPoint) ifTrue: [
			^self perform: each third
		].
	].



]

{ #category : #accessing }
EmbeddedWorldBorderMorph >> myTransformation [

	^submorphs detect: [ :x | x isKindOf: TransformationMorph] ifNone: [nil]

]

{ #category : #layout }
EmbeddedWorldBorderMorph >> myWorldChanged [
	| trans |
	trans := self myTransformation.
	self changed.
	self layoutChanged.
	trans ifNotNil:[
		trans extentFromParent: self innerBounds extent.
		bounds := self bounds topLeft extent: trans extent + (self borderWidth * 2).
	].
	self changed.

]

{ #category : #boxes }
EmbeddedWorldBorderMorph >> normalEntryBoxArea [

	^self genericBoxArea: 4

]

{ #category : #accessing }
EmbeddedWorldBorderMorph >> toggleZoom [

	self bounds: (
		bounds area > (Display boundingBox area * 0.9) ifTrue: [
			Display extent // 4 extent: Display extent // 2.
		] ifFalse: [
			Display boundingBox
		]
	)


]

{ #category : #accessing }
EmbeddedWorldBorderMorph >> worldIEnclose [

	^self myTransformation firstSubmorph	
					"quick hack since this is the only usage pattern at the moment"

]

{ #category : #boxes }
EmbeddedWorldBorderMorph >> zoomBoxArea [

	^self genericBoxArea: 0

]
