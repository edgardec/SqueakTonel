"
A panel for authoring ""graph paper""
	backgroundColor -- the color of the ground
	gridColor -- the color of the fine lines
	gridEvery -- number of pixels between fine grid lines.
	darkerGridColor -- color of the secondary, less-frequently-drawn grid
	darkerLineEvery -- number of primary grid units between darker grid lines
	offset -- the offset of the InfiniteForm produced.
"
Class {
	#name : #GraphPaperPanel,
	#superclass : #GenericPropertiesMorph,
	#instVars : [
		'backgroundColor',
		'gridColor',
		'gridEvery',
		'showDarkerGridAlso',
		'darkerGridColor',
		'darkerGridEvery',
		'offset'
	],
	#category : #'Etoys-Squeakland-Morphic-Experimental'
}

{ #category : #examples }
GraphPaperPanel class >> classicCartesianGraph [
	"Answer a nicely configured playfield with horizontal and vertical axes and a background well-suited for determining units on the plane."

	| aPlayfield horiz vert pixelsPerUnit parms |
	aPlayfield := PasteUpMorph new extent: 642 @ 642.
	horiz := HorizontalNumberLineMorph new.
	horiz width: 640.

	aPlayfield addMorphBack: horiz.
	vert := VerticalNumberLineMorph new.
	vert height: 640.
	aPlayfield addMorphBack: vert.

	pixelsPerUnit := 16.

	horiz center: (aPlayfield center + (0 @ -2)).
	vert center: (aPlayfield center + (-14 @ -2)).

	horiz minValue: -20 pixelsPerUnit: pixelsPerUnit unitsPerMark: 1 marksPerLegend: 5.
	vert minValue: -20 pixelsPerUnit: pixelsPerUnit unitsPerMark: 1 marksPerLegend: 5.

	horiz registerGraphCoordinate: 0 atPlayfieldLocation: 322.
	vert registerGraphCoordinate: 0 atPlayfieldLocation: 318.
	vert showZero: false.

	parms := GraphPaperParameters backgroundColor: Color green muchLighter gridColor: Color blue muchLighter gridEvery: 16 showDarkerGridAlso: true darkerGridColor: Color blue muchDarker darkerGridEvery: 10 offset: (0 @ 0).
	aPlayfield establishGraphPaperFrom: parms.

	horiz update.
	vert update.

	"temporary fudges to get this basically looking right, though there had been hope that the above attempts would have already succeded..."
	WorldState addDeferredUIMessage:
		[vert y: 296.
		vert maxValue: 20.
		horiz y: 314.
		horiz maxValue: 20].

	^ aPlayfield

"
GraphPaperPanel classicCartesianGraph openInHand
"
]

{ #category : #examples }
GraphPaperPanel class >> simpleGraphPaper [
	"Answer a playfield set up with simple graph paper."

	| aPlayfield parms |
	aPlayfield := PasteUpMorph new extent: 640 @ 480.

	parms := GraphPaperParameters backgroundColor: Color lightYellow gridColor: Color lightGreen lighter lighter gridEvery: 16 showDarkerGridAlso: true darkerGridColor: Color green lighter darkerGridEvery: 10 offset: (0 @ 0).
	aPlayfield establishGraphPaperFrom: parms.

	^ aPlayfield

"
GraphPaperPanel simpleGraphPaper openInHand
"
]

{ #category : #'parts-bin' }
GraphPaperPanel class >> supplementaryPartsDescriptions [
	"Answer a list of DescriptionForPartsBin objects that characterize objects that this class wishes to contribute to Stationery bins *other* than by the standard default #newStandAlone protocol"

	^ {
	DescriptionForPartsBin
		formalName: 'x-y plane' translatedNoop
		categoryList: {'Graphing' translatedNoop}
		documentation: 
			'an x-y plane with x and y axes' translatedNoop
		globalReceiverSymbol: #GraphPaperPanel
		nativitySelector: #classicCartesianGraph.

	DescriptionForPartsBin
		formalName: 'graph paper' translatedNoop
		categoryList: {'Graphing' translatedNoop}
		documentation: 
			'simple graph paper' translatedNoop
		globalReceiverSymbol: #GraphPaperPanel
		nativitySelector: #simpleGraphPaper.

	"DescriptionForPartsBin
		formalName: 'Broad x-y plane' translatedNoop
		categoryList: {'Graphing' translatedNoop}
		documentation: 
			'an x-y plane with axes covering a range from -20 to 20' translatedNoop
		globalReceiverSymbol: #GraphPaperPanel
		nativitySelector: #largerCartesianGraph.

	DescriptionForPartsBin
		formalName: 'First quadrant' translatedNoop
		categoryList: {'Graphing' translatedNoop}
		documentation: 
			'the first quadrant of an x-y plane' translatedNoop
		globalReceiverSymbol: #GraphPaperPanel
		nativitySelector: #firstQuadrantGraph."
}
]

{ #category : #'adjusting parameters' }
GraphPaperPanel >> adjustOffset: aFractionalPoint [
	"Adjust the offset to reflect the value embodied in the argument supplied."

	| constrained |
	constrained := aFractionalPoint min: (1 @ 1) max: (-1 @ -1).
	offset := (constrained * self gridEvery asPoint) rounded.
	self showSliderFeedback: offset.
	self makeToolReflectCurrentSettings
]

{ #category : #accessing }
GraphPaperPanel >> backgroundColor [
	"Answer the value of backgroundColor"

	^ backgroundColor
]

{ #category : #accessing }
GraphPaperPanel >> backgroundColor: anObject [
	"Set the value of backgroundColor"

	backgroundColor := anObject.
	self makeToolReflectCurrentSettings
]

{ #category : #private }
GraphPaperPanel >> colorPickerFor: target getter: getterSymbol setter: setterSymbol [
	"Answer a color picker for the given target, getter, and setter, for use in the panel."

	^ ColorPickerMorph new
		noChart: true;
		initializeForGraphPaperPanel;
		target: target;
		selector: setterSymbol;
		originalColor: (target perform: getterSymbol)
]

{ #category : #accessing }
GraphPaperPanel >> darkerGridColor [
	"Answer the value of darkerGridColor."

	^ darkerGridColor
]

{ #category : #accessing }
GraphPaperPanel >> darkerGridColor: anObject [
	"Set the value of darkerGridColor."

	darkerGridColor := anObject.
	self makeToolReflectCurrentSettings
]

{ #category : #accessing }
GraphPaperPanel >> darkerGridEvery [
	"Answer the value of darkerGridEvery."

	^ darkerGridEvery
]

{ #category : #accessing }
GraphPaperPanel >> darkerGridEvery: aNumber [
	"Set the value of darkerGridEvery."

	darkerGridEvery := aNumber rounded.
	self harmonizeGridEvery.
	self makeToolReflectCurrentSettings
]

{ #category : #accepting }
GraphPaperPanel >> doAccept [
	"The user hit 'accept' -- have the target remember the parameters embodied, and dismiss the panel."

	myTarget renderedMorph establishGraphPaperFrom: (GraphPaperParameters new fillFrom: self).
	self delete
]

{ #category : #accepting }
GraphPaperPanel >> doApply [
	"The user hit 'apply' -- have the target remember the parameters embodied.  Keep the panel up.   If user makes any further changes in the panel but then hits cancel, fill style will revert to the version saved here."

	myTarget renderedMorph establishGraphPaperFrom: (GraphPaperParameters new fillFrom: self).
	thingsToRevert at: #fillStyle: put: myTarget fillStyle.

]

{ #category : #private }
GraphPaperPanel >> doEnables [
	"Carry out appropriate enablings within the receiver's interior."

	| itsName existing |
	existing := darkerGridEvery.
	self harmonizeCoarseGrid.
	existing = darkerGridEvery ifFalse:
		[self makeToolReflectCurrentSettings].

	self allMorphsDo: [ :each |
		itsName := each knownName.
		(#(pickerForDarkerGrid darkerGridEvery) includes: itsName) ifTrue:
			[self enable: each when: self showDarkerGridAlso].
		(#(offset) includes: itsName) ifTrue:
			[self enable: each when: true]]
]

{ #category : #private }
GraphPaperPanel >> doSolidColor [
	"Abandon use of graph paper; use the prevailing background as the new solid color."

	myTarget color: self backgroundColor.
	self delete.
	myTarget openAppropriatePropertySheet
]

{ #category : #accessing }
GraphPaperPanel >> gridColor [
	"Answer the value of gridColor"

	^ gridColor
]

{ #category : #accessing }
GraphPaperPanel >> gridColor: anObject [
	"Set the value of gridColor."

	gridColor := anObject.
	self makeToolReflectCurrentSettings
]

{ #category : #accessing }
GraphPaperPanel >> gridEvery [
	"Answer the value of gridEvery."

	^ gridEvery
]

{ #category : #accessing }
GraphPaperPanel >> gridEvery: aNumber [
	"Set the value of gridEvery"

	gridEvery := aNumber rounded.
	self harmonizeCoarseGrid.
	self makeToolReflectCurrentSettings
]

{ #category : #'adjusting parameters' }
GraphPaperPanel >> harmonizeCoarseGrid [
	"The pixelsPerUnit having changed, reconsider  'darkerGridEvery'  and the slider that governs it."

	| aSlider maxGridEvery |
	maxGridEvery := self maxValueForCoarseGrid.
	darkerGridEvery := darkerGridEvery min:  maxGridEvery max: 2.
	aSlider := self deepSubpartNamed: #darkerGridEverySlider.
	aSlider ifNotNil:
		[aSlider setMaxVal: maxGridEvery.
		aSlider adjustToValue: darkerGridEvery]

	
]

{ #category : #'adjusting parameters' }
GraphPaperPanel >> harmonizeGridEvery [
	"Other metrics having possibly changed, make sure the gridEvery variable is within range and that its slider offers a reasonable range of values."

	| aSlider maxGridEvery |
	maxGridEvery := self maxValueForGridEvery.
	gridEvery := gridEvery min:  maxGridEvery max: 10.
	aSlider := self deepSubpartNamed: #gridEverySlider.
	aSlider ifNotNil:
		[aSlider setMaxVal: maxGridEvery.
		aSlider adjustToValue: gridEvery]

	
]

{ #category : #accessing }
GraphPaperPanel >> hasTarget: aMorph [
	"Answer whether the receiver's target is the morph in question."

	^ aMorph renderedMorph == myTarget
]

{ #category : #initialization }
GraphPaperPanel >> initialize [
	"Initialize the receiver.  Notice that, because of GenericPropertiesMorph's custom, 'myTarget' is already set before this is called."

	| existing toUse |
	super initialize.
	existing := myTarget renderedMorph valueOfProperty: #graphPaperParameters.
	toUse := existing
		ifNotNil:
			[existing deepCopy]
		ifNil:
			[GraphPaperParameters new].
	backgroundColor := existing
		ifNotNil:	
			[toUse backgroundColor]
		ifNil:
			[myTarget color asColor].
	gridColor := toUse gridColor.
	gridEvery := toUse gridEvery.
	showDarkerGridAlso := toUse showDarkerGridAlso.
	darkerGridColor := toUse darkerGridColor.
	darkerGridEvery := toUse darkerGridEvery.
	offset := toUse showDarkerGridAlso ifTrue: [toUse offset] ifFalse: [0 @ 0].

	thingsToRevert at: #fillStyle: put: myTarget fillStyle.
	self rebuild.

	self makeToolReflectCurrentSettings

	
]

{ #category : #accessing }
GraphPaperPanel >> makeToolReflectCurrentSettings [
	"Make the appropriate item reflect graph-paper corresponding to current settings."

	myTarget color: (GraphPaperParameters new fillFrom: self) asInfiniteForm
]

{ #category : #'adjusting parameters' }
GraphPaperPanel >> maxValueForCoarseGrid [
	"Given the pixelsPerUnit and the dimensions of my target, determine and answer a plausible maximum value for the coarse-grid multiplier."

	| maxDimension |
	maxDimension := myTarget width max: myTarget height.
	^ ((maxDimension // gridEvery) - 1) max: 2
]

{ #category : #'adjusting parameters' }
GraphPaperPanel >> maxValueForGridEvery [
	"Answer the largest plausible value for gridEvery"

	| maxDimension |
	maxDimension := myTarget width max: myTarget height.
	^ self showDarkerGridAlso
		ifTrue:
			[maxDimension // darkerGridEvery]
		ifFalse:
			[(maxDimension - 1) max: 10]
]

{ #category : #accessing }
GraphPaperPanel >> offset [
	"Answer the value of offset"

	^ offset
]

{ #category : #accessing }
GraphPaperPanel >> offset: anObject [
	"Set the value of offset"

	offset := anObject
]

{ #category : #panes }
GraphPaperPanel >> paneForBackgroundColorPicker [
	"Answer a pane for governing the background color."

	^ self 
		inAColumn: {
			(self inAColumn: {
				self colorPickerFor: self
						 getter: #backgroundColor setter: #backgroundColor:.
				self lockedString: 'paper color' translated.
			}
			named: #pickerForBackground) layoutInset: 0.
		}

]

{ #category : #panes }
GraphPaperPanel >> paneForDarkerGridColorPicker [
	"Answer a pane for governing the secondary line color."

	^ self 
		inAColumn: {
			(self inAColumn: {
				self colorPickerFor: self
						 getter: #darkerGridColor setter: #darkerGridColor:.
				self lockedString: 'coarse grid color' translated.
			}
			named: #pickerForDarkerGrid) layoutInset: 0.
		}

]

{ #category : #panes }
GraphPaperPanel >> paneForDarkerGridEvery [
	"Answer a pane for the darkerGridEvery datum."

	| aSlider |
	aSlider :=  SimpleSliderMorph new
		color: color darker;
		extent: 100@28;
		target: self;
		minVal: 2;
		maxVal: 40;
		actionSelector: #darkerGridEvery:;
		setNameTo: #darkerGridEverySlider;
		adjustToValue: self darkerGridEvery.

	^ (self inARow: {
			(UpdatingStringMorph new)
				getSelector: #darkerGridEvery;
				putSelector: #darkerGridEvery:;
				target: self;
				growable: false;
				decimalPlaces: 0;
				minimumWidth: 40;
				maximumWidth: 40;
				yourself.
			aSlider}) setNameTo: #darkerGridEvery; yourself
]

{ #category : #panes }
GraphPaperPanel >> paneForExtras [
	"Answer a pane for the checkbox and buttons"

	^ self 
		inAColumn: {
			self transparentSpacerOfSize: (10 @ 20).
			self paneForGridEvery.
			self transparentSpacerOfSize: (10 @ 40).
			self paneForSecondaryGridToggle.
			self transparentSpacerOfSize: (10 @ 10).
			self paneForDarkerGridEvery.
			self transparentSpacerOfSize: (10 @ 40).
			self paneForOffset.
			self transparentSpacerOfSize: (10 @ 40).
		} 
		named: #paneForExtras.
]

{ #category : #panes }
GraphPaperPanel >> paneForGridColorPicker [
	"Answer a pane for governing the grid color."

	^ self 
		inAColumn: {
			(self inAColumn: {
				self colorPickerFor: self
						 getter: #gridColor setter: #gridColor:.
				self lockedString: 'grid color' translated.
			}
			named: #pickerForGrid) layoutInset: 0.
		}

]

{ #category : #panes }
GraphPaperPanel >> paneForGridEvery [
	"Answer a pane to govern the gridEvery datum."

	| aSlider |
	aSlider :=  SimpleSliderMorph new
		color: color darker;
		extent: 100@28;
		target: self;
		minVal: 4;
		maxVal: 360;
		actionSelector: #gridEvery:;
		setNameTo: #gridEverySlider;
		adjustToValue: self gridEvery.

	^ self inARow: {
		self lockedString: ('grid size' translated, '  ').
		(UpdatingStringMorph new)
				getSelector: #gridEvery;
				putSelector: #gridEvery:;
				target: self;
				growable: false;
				decimalPlaces: 0;
				minimumWidth: 40;
				maximumWidth: 40;
				yourself.
			aSlider}
]

{ #category : #panes }
GraphPaperPanel >> paneForOffset [
	"Answer a pane for the Offset button."

	| aPane |
	aPane := (self inARow: {
		self
			buildFakeSlider: 'Offset' translated
			selector: #adjustOffset:
			help: 'Drag in here to change the offset' translated
				}) hResizing: #shrinkWrap.
	aPane setNameTo: #offset.
	^ aPane


]

{ #category : #panes }
GraphPaperPanel >> paneForSecondaryGridToggle [
	"Answer a pane to govern the secondary grid."

	^ self inARow: {
		self
			directToggleButtonFor: self 
			getter: #showDarkerGridAlso
			setter: #toggleShowDarkerGridAlso
			help: 'Also show coarse grid' translated.
		self lockedString: ' coarse grid' translated.
	}

]

{ #category : #initialization }
GraphPaperPanel >> rebuild [
	"Rebuild the contents of the property sheet."

	| buttons |
	self removeAllMorphs.
	self addARow: {
		self lockedString: myTarget topRendererOrSelf externalName
		"self lockedString: ('Graph paper for {1}' translated format: {myTarget topRendererOrSelf externalName})".
	}.

	self addARow: {
		self paneForBackgroundColorPicker.
		self paneForGridColorPicker.

	}.
	self addARow: {
		self paneForExtras.
		self paneForDarkerGridColorPicker.
	}.

	buttons := OrderedCollection new.
	buttons addAll: {
		self 
			buttonNamed: 'Apply' translated action: #doApply color: color lighter 
			help: 'keep changes made thus far, but keep panel open' translated.
		self 
			buttonNamed: 'Accept' translated action: #doAccept color: color lighter 
			help: 'keep changes made and close panel' translated.
		self 
			buttonNamed: 'Cancel' translated action: #doCancel color: color lighter 
			help: 'cancel changes made and close panel' translated.
		self  transparentSpacerOfSize: (100 @ 1).
		self buttonNamed: 'Solid color' translated action: #doSolidColor color: color lighter help: 'abandon graph paper, use a solid color instead' translated
	}.
	
	self addARow: buttons
]

{ #category : #accessing }
GraphPaperPanel >> showDarkerGridAlso [
	"Answer the value of showDarkerGridAlso"

	^ showDarkerGridAlso
]

{ #category : #accessing }
GraphPaperPanel >> showDarkerGridAlso: anObject [
	"Set the value of showDarkerGridAlso"

	showDarkerGridAlso := anObject
]

{ #category : #'adjusting parameters' }
GraphPaperPanel >> toggleShowDarkerGridAlso [
	"Toggle whether a secondary grid should be shown."

	showDarkerGridAlso := self showDarkerGridAlso not.
	showDarkerGridAlso ifTrue: [offset := 0].
	self rebuild.
	self doEnables.
	self makeToolReflectCurrentSettings
]
