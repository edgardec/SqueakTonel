"
An abstract superclass for VerticalNumberLine and HorizontalNumberLine.

minValue - Number - the value corresponding to the left edge of the line.
pixelsPerUnit - Integer - the number of pixels on the graph that correspond to a single unit in the metric space of the line.
actualColor - the color borne by the axis
axis - a two-vertex PolygonMorph which is the actual line
showZero - Boolean - if false, then a 0 legend will *not* be show.
"
Class {
	#name : #NumberLineMorph,
	#superclass : #Morph,
	#instVars : [
		'minValue',
		'actualColor',
		'axis',
		'showZero',
		'pixelsPerUnit',
		'unitsPerMark',
		'marksPerLegend'
	],
	#category : #'Etoys-Squeakland-MorphicExtras-Charts'
}

{ #category : #'viewer categories' }
NumberLineMorph class >> additionsToViewerCategoryNumberLine [
	^ #('number line' (
	"	(command fitPlayfield 'extend or contract such that the line fits within the containing playfield.')"
		(slot minVal 'smallest value shown on the axis' Number readWrite Player getMinVal Player setMinVal:)
		(slot maxVal 'largest value shown on the axis' Number readWrite Player getMaxVal Player setMaxVal:)

		(slot pixelsPerUnit 'number of screen pixels per unit on the number line' Number readWrite Player getPixelsPerUnit Player setPixelsPerUnit:)
		(slot unitsPerMark 'number of units between tick marks on the number line' Number readWrite Player getUnitsPerMark Player setUnitsPerMark:)
		(slot marksPerLegend 'number of ticks between successive legends' Number readWrite Player getMarksPerLegend Player setMarksPerLegend:)

		(slot showZero 'whether to show the numeral 0 at the zero point on this axis' Boolean readWrite Player getShowZero Player setShowZero:)
		(slot showNegativeArrowHead 'whether to show an arrow-head at the extreme lower end of the axis' Boolean readWrite Player getShowNegativeArrowHead Player setShowNegativeArrowHead:)) )
]

{ #category : #'instance creation' }
NumberLineMorph class >> from: minValue pixelsPerUnit: pixelsPerUnit  unitsPerMark: unitsPerMark marksPerLegend: marksPerLegend [

	^ (self new
			minValue: minValue pixelsPerUnit: pixelsPerUnit unitsPerMark: unitsPerMark marksPerLegend: marksPerLegend)
]

{ #category : #'instance creation' }
NumberLineMorph class >> newStandAlone [

	^ (self from: -10 pixelsPerUnit: 30 unitsPerMark: 1 marksPerLegend: 1) update; yourself
]

{ #category : #'halo menu' }
NumberLineMorph >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Use my line's menu additions"
	super addCustomMenuItems: aMenu hand: aHandMorph.
	aMenu addLine.

	aMenu addList: {
		{'set pixels per unit' translated. 			#choosePixelsPerUnit.			'set the number of pixels per unit on the number line.' translated}.
		{'set units per mark' translated.	#chooseUnitsPerMark.	'set the number of units between marks on the number line.' translated}.
		{'set marks per legend' translated.	#chooseMarksPerLegend.	'set the number of units between tick marks on the number line.' translated}.

		{'set max value' translated.	#chooseMaxValue. 	'set the maximum value to be shown on the number line.' translated}.
		{'set min value' translated . 	#chooseMinValue.		'set the minimum value shown on the number line.' translated}}.

	aMenu
		addUpdating: #showingNegativeArrowHeadPhrase target: self action: #toggleNegativeArrowHead;
		addUpdating: #showingZeroPhrase target: self action: #toggleShowingZero..


]

{ #category : #'visual properties' }
NumberLineMorph >> allowance [
	"Answer the allowance for overhead -- put here to avoid hard-coding the number in multiple other places..."

	^ 50
]

{ #category : #abstract }
NumberLineMorph >> asValidExtent: newExtent [ 
	^ self subclassResponsibility
]

{ #category : #abstract }
NumberLineMorph >> centerOfAxisVertex: n [ 
	^ self subclassResponsibility
]

{ #category : #'halo menu' }
NumberLineMorph >> chooseMarksPerLegend [
	"Put up a dialog disclosing the current increment and inviting the user to specify a new one."

	| result |
	result := FillInTheBlank request: 'marksPerLegend' translated initialAnswer: self marksPerLegend printString.
	result isEmptyOrNil ifTrue: [^ self].
	self marksPerLegend: result asNumber

]

{ #category : #'halo menu' }
NumberLineMorph >> chooseMaxValue [
	"Put up a dialog showing the current maxValue and inviting the user to specify a new one."

	| result |
	result := FillInTheBlank request: 'type new max value' initialAnswer: self maxValue printString.
	result isEmptyOrNil ifTrue: [^ self].
	self maxValue: result asNumber

]

{ #category : #'halo menu' }
NumberLineMorph >> chooseMinValue [
	"Put up a dialog disclosing the current minValue and allowing the user to specify a new value for it."

	| result |
	result := FillInTheBlank request: 'type new min value' initialAnswer: self minValue printString.
	result isEmptyOrNil ifTrue: [^ self].
	self minValue: result asNumber

]

{ #category : #'halo menu' }
NumberLineMorph >> choosePixelsPerUnit [
	"Put up a dialog showing the current pixelsPerUnit and allowing the user to submit a new one."

	| result |
	result := FillInTheBlank request: 'type new pixels per unit' translated initialAnswer: pixelsPerUnit printString.
	result isEmptyOrNil ifTrue: [^ self].
	self pixelsPerUnit: result asNumber
]

{ #category : #menu }
NumberLineMorph >> chooseUnitsPerMark [
	"Put up a dialog disclosing the current unitsPerMark and inviting the user to specify a new one."

	| result |
	result := FillInTheBlank request: 'unitsPerMark' translated initialAnswer: self unitsPerMark printString.
	result isEmptyOrNil ifTrue: [^ self].
	self unitsPerMark: result asNumber

]

{ #category : #accessing }
NumberLineMorph >> color [
	^ actualColor
]

{ #category : #accessing }
NumberLineMorph >> color: aColor [ 
	actualColor := aColor.
	super color: Color transparent.
	self update
]

{ #category : #accessing }
NumberLineMorph >> extent: newExtent [ 
	super
		extent: (self asValidExtent: newExtent).
	self update
]

{ #category : #accessing }
NumberLineMorph >> fillStyle: aFillStyle [ 
	self color: aFillStyle asColor
]

{ #category : #initialization }
NumberLineMorph >> initialize [
	"Basic initialization."

	super initialize.
	actualColor := Color black.
	axis := PolygonMorph arrowPrototype arrowSpec: 8 @ 4;
				 lineBorderWidth: 1.
	pixelsPerUnit := 40.
	unitsPerMark := 5.
	marksPerLegend := 1.
	showZero := true.
	minValue := 0.
	self addMorph: axis;
		 color: actualColor.
	self update
]

{ #category : #accessing }
NumberLineMorph >> legendsHeight [
	^ TextStyle defaultFont height
]

{ #category : #accessing }
NumberLineMorph >> legendsWidth [
	^ (self widthOfString: self minValue asString)
		max: (self widthOfString: self maxValue asString)
]

{ #category : #accessing }
NumberLineMorph >> marksHeight [
	^ 5
]

{ #category : #accessing }
NumberLineMorph >> marksPerLegend [
	"Answer the value of marksPerLegend."

	^ marksPerLegend
]

{ #category : #'halo menu' }
NumberLineMorph >> marksPerLegend: aNumber [
	"Set the value of marksPerLegend."

	marksPerLegend := aNumber rounded max: 1.
	self update
]

{ #category : #accessing }
NumberLineMorph >> marksWidth [
	^ 5
]

{ #category : #accessing }
NumberLineMorph >> maxVal [
	^ self maxValue
]

{ #category : #accessing }
NumberLineMorph >> maxValue [
	^ self subclassResponsibility
]

{ #category : #accessing }
NumberLineMorph >> minVal [
	^ self minValue
]

{ #category : #accessing }
NumberLineMorph >> minValue [
	^ minValue
]

{ #category : #accessing }
NumberLineMorph >> minValue: aNumber [ 
	minValue := aNumber.
	self update
]

{ #category : #initialization }
NumberLineMorph >> minValue: minInteger pixelsPerUnit: ppuInteger unitsPerMark: upmInteger marksPerLegend: mplInteger [ 
	"Initialize the receiver to have the given minimum value, pixelsPerUnit, unitsPerMark, and marksPerLegend"

	minValue := minInteger.
	pixelsPerUnit := ppuInteger.
	unitsPerMark := upmInteger.
	marksPerLegend := mplInteger
]

{ #category : #abstract }
NumberLineMorph >> newMark [
	^ self subclassResponsibility
]

{ #category : #'visual properties' }
NumberLineMorph >> offset [
	^ 25
]

{ #category : #accessing }
NumberLineMorph >> pixelsPerUnit [
	"Answer the number of pixels per unit in the receiver's metric system."

	^ pixelsPerUnit
]

{ #category : #accessing }
NumberLineMorph >> pixelsPerUnit: aNumber [
	"Set the number of pixels that will constitute one 'unit' along the receiver.  Retain existing min and max values."

	| newPixelsPerUnit existingMax |
	(newPixelsPerUnit := aNumber max: 1) = pixelsPerUnit
		ifTrue: [^ self].

	self retainCenterAcross:
		[existingMax := self maxValue.
		pixelsPerUnit := newPixelsPerUnit.
		self update.
		self maxValue: existingMax]
]

{ #category : #updating }
NumberLineMorph >> placeAxis [
	1
		to: 2
		do: [:i | axis vertices
				at: i
				put: (self centerOfAxisVertex: i)].
	axis borderColor: self color.
	axis computeBounds
]

{ #category : #coordinates }
NumberLineMorph >> retainCenterAcross: aBlock [
	"The scale of the receiver is being changed..."

	| oldCenter |
	oldCenter := self center.
	aBlock value.
	self center: oldCenter
]

{ #category : #accessing }
NumberLineMorph >> setMaxVal: aNumber [ 
	self maxValue: aNumber
]

{ #category : #accessing }
NumberLineMorph >> setMinVal: aNumber [ 
	self minValue: aNumber
]

{ #category : #accessing }
NumberLineMorph >> showNegativeArrowHead [
	^ axis arrows = #both
]

{ #category : #accessing }
NumberLineMorph >> showNegativeArrowHead: aBoolean [ 
	aBoolean
		ifTrue: [axis makeBothArrows]
		ifFalse: [axis makeForwardArrow]
]

{ #category : #accessing }
NumberLineMorph >> showZero [
	^ showZero
]

{ #category : #accessing }
NumberLineMorph >> showZero: aBoolean [ 
	showZero := aBoolean.
	self update
]

{ #category : #'halo menu' }
NumberLineMorph >> showingNegativeArrowHeadPhrase [
	"Answer a phrase representing whether or not the receiver is currently showing an arrowhead at its negative end."

	^ (self showNegativeArrowHead ifTrue: ['<yes>'] ifFalse: ['<no>']), 'show negative arrowhead' translated
]

{ #category : #'halo menu' }
NumberLineMorph >> showingZeroPhrase [
	"Answer a phrase telling whether or not the legend for the zero-point should be shown on the axis."

	^ (showZero ifTrue: ['<yes>'] ifFalse: ['<no>']), 'show legend for the zero point.' translated
]

{ #category : #'halo menu' }
NumberLineMorph >> toggleNegativeArrowHead [
	"Toggle the setting of the flag governing whether the negative-direction arrowhead should be shown."

	self showNegativeArrowHead: self showNegativeArrowHead not
]

{ #category : #'halo menu' }
NumberLineMorph >> toggleShowingZero [
	"Toggle the setting of the flag that governs whether the zero-point legend should be shown."

	self showZero: self showZero not
]

{ #category : #accessing }
NumberLineMorph >> unitsPerMark [
	^ unitsPerMark
]

{ #category : #accessing }
NumberLineMorph >> unitsPerMark: anInteger [
	unitsPerMark := anInteger.
	self update
]

{ #category : #updating }
NumberLineMorph >> update [
	minValue ifNotNil:
		[self placeAxis; addLegendsAndMarks]
]

{ #category : #accessing }
NumberLineMorph >> widthOfString: aString [ 
	^ TextStyle defaultFont widthOfString: aString
]
