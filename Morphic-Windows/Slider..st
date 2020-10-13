"
I am a widget that helps users enter a numerically bounded value. I have a minimum and a maximum value. My thumb indicates my current value. My orientation can be vertical or horizontal, which is usually determined by the ratio of my extent. Nevertheless, you can force me to use a specific orientation,

Note that I can be pluggable and get data from a model.
"
Class {
	#name : #Slider,
	#superclass : #MorphicModel,
	#instVars : [
		'slider',
		'value',
		'setValueSelector',
		'getValueSelector',
		'sliderShadow',
		'sliderColor',
		'descending',
		'minimumValue',
		'maximumValue',
		'quantum',
		'getMinimumValueSelector',
		'getMaximumValueSelector',
		'orientation'
	],
	#category : #'Morphic-Windows'
}

{ #category : #'new-morph participation' }
Slider class >> includeInNewMorphMenu [
	"OK to instantiate"
	^ true
]

{ #category : #'instance creation' }
Slider class >> on: anObject getValue: getSel setValue: setSel [
	"Answer a new instance of the receiver with
	the given selectors as the interface."

	^self new
		on: anObject
		getValue: getSel
		setValue: setSel
]

{ #category : #'instance creation' }
Slider class >> on: anObject getValue: getSel setValue: setSel min: min max: max quantum: quantum [
	"Answer a new instance of the receiver with
	the given selectors as the interface."

	| instance |
	instance := self new
		quantum: quantum;
		on: anObject
		getValue: getSel
		setValue: setSel.
	min isSymbol
		ifTrue: [instance getMinimumValueSelector: min]
		ifFalse: [instance minimumValue: min].
	max isSymbol
		ifTrue: [instance getMaximumValueSelector: max]
		ifFalse: [instance maximumValue: max].
	^ instance
]

{ #category : #preferences }
Slider class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the slider''s border.' }.
		{ #borderWidth. 'Borders'. 'Width of the slider''s border.' }.
		{ #color. 'Colors'. 'Background color of the slider.' }.

		{ #thumbBorderColor. 'Colors'. 'Color of the slider thumb''s border.' }.
		{ #thumbBorderWidth. 'Borders'. 'Width of the slider thumb''s border.' }.
		{ #thumbColor. 'Colors'. 'Background color of the slider thumb.' }.
		
		{ #thumbShadowModifier. 'Colors'. 'How to modify the thumb color to get the shadow color.' }.
	}
]

{ #category : #'accessing - ui' }
Slider >> adoptPaneColor: paneColor [

	super adoptPaneColor: paneColor.
	paneColor ifNotNil: [:c | self sliderColor: c].
]

{ #category : #updating }
Slider >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	
	self setDefaultParameters.
]

{ #category : #geometry }
Slider >> computeSlider [
	| r v |
	r := self roomToMove.
	v := self maximumValue = self minimumValue
		ifTrue: [0]
		ifFalse: [(value - self minimumValue) / (self maximumValue - self minimumValue)].
	self descending
		ifFalse:
			[self moveSliderTo: (self orientation == #horizontal
				ifTrue: [r topLeft + ((r width * v) asInteger @ 0)]
				ifFalse: [r topLeft + (0 @ (r height * v)  asInteger)])]
		ifTrue:
			[self moveSliderTo: (self orientation == #horizontal
				ifTrue:	[r bottomRight - ((r width * v) asInteger @ 0)]
				ifFalse:	[r bottomRight - ((0 @ (r height * v) asInteger))])].
	self resizeSliderTo: self sliderExtent.
]

{ #category : #accessing }
Slider >> convertToCurrentVersion: varDict refStream: smartRefStrm [ 
	
	(setValueSelector = #scrollBarValue:) ifTrue:[self setValueSelector: #vScrollBarValue:].
	^ super convertToCurrentVersion: varDict refStream: smartRefStrm
]

{ #category : #initialization }
Slider >> defaultBounds [
"answer the default bounds for the receiver"
	^ 0 @ 0 corner: 16 @ 100
]

{ #category : #accessing }
Slider >> descending [

	^ descending
]

{ #category : #accessing }
Slider >> descending: aBoolean [

	descending := aBoolean.
	self computeSlider.
]

{ #category : #geometry }
Slider >> extent: newExtent [

	(bounds extent closeTo: newExtent) ifTrue: [^ self].

	super extent: newExtent.

	self updateSlider.
]

{ #category : #'model access' }
Slider >> getMaximumValue [
	
	self getMaximumValueSelector ifNotNil: [:selector |
		self maximumValue: (model perform: selector)].
	^ self maximumValue
]

{ #category : #'accessing - model' }
Slider >> getMaximumValueSelector [

	^ getMaximumValueSelector
]

{ #category : #'accessing - model' }
Slider >> getMaximumValueSelector: aSymbol [

	getMaximumValueSelector := aSymbol.
]

{ #category : #'model access' }
Slider >> getMinimumValue [
	
	self getMinimumValueSelector ifNotNil: [:selector |
		self minimumValue: (model perform: selector)].
	^ self minimumValue
]

{ #category : #'accessing - model' }
Slider >> getMinimumValueSelector [

	^ getMinimumValueSelector
]

{ #category : #'accessing - model' }
Slider >> getMinimumValueSelector: aSymbol [

	getMinimumValueSelector := aSymbol.
]

{ #category : #'model access' }
Slider >> getValue [
	"Updates internal value with model data if possible. Returns the updated value or the current one."
	
	self getValueSelector ifNotNil: [:selector |
		self value: (model perform: selector)].
	^ self value
]

{ #category : #'accessing - model' }
Slider >> getValueSelector [

	^ getValueSelector
]

{ #category : #'accessing - model' }
Slider >> getValueSelector: aSymbol [

	getValueSelector := aSymbol.
]

{ #category : #'layout-properties' }
Slider >> hResizing [
	"Due to possible automatic orientation change on extent changes, we have to calculate the resizing property based on the current orientation. Otherwise, layout will break.There is, however, support for using the resizing property in layout properties if set."

	self layoutProperties ifNotNil: [:props |
		^ props hResizing].
	
	^ self orientation == #horizontal
		ifTrue: [#spaceFill]
		ifFalse: [#rigid]
]

{ #category : #'other events' }
Slider >> hideSliderShadow [

	sliderShadow hide.
]

{ #category : #initialization }
Slider >> initialize [

	super initialize.

	value := 0.0.
	descending := false.
	
	self initializeSlider.
	self setDefaultParameters.
]

{ #category : #initialization }
Slider >> initializeSlider [

	slider := RectangleMorph
		newBounds: self totalSliderArea
		color: self thumbColor.
	
	sliderShadow := RectangleMorph
		newBounds: self totalSliderArea
		color: self pagingArea color.
	
	slider on: #mouseMove send: #scrollAbsolute: to: self.
	slider on: #mouseDown send: #mouseDownInSlider: to: self.
	slider on: #mouseUp send: #mouseUpInSlider: to: self.

	self addMorphFront: sliderShadow.
	self addMorphFront: slider.

	self computeSlider.
	self hideSliderShadow.
]

{ #category : #accessing }
Slider >> maximumValue [
	
	^ maximumValue ifNil: [1.0]
]

{ #category : #accessing }
Slider >> maximumValue: aNumber [
	
	maximumValue := aNumber.
	self setValue: self value.
]

{ #category : #geometry }
Slider >> minHeight [

	^ self orientation == #horizontal
		ifTrue: [super minHeight max: self borderWidth + 1]
		ifFalse: [super minHeight max: self sliderThickness * 2]
]

{ #category : #geometry }
Slider >> minWidth [

	^ self orientation == #horizontal
		ifTrue: [super minWidth max: self sliderThickness * 2]
		ifFalse: [super minWidth max: self borderWidth + 1]
]

{ #category : #accessing }
Slider >> minimumValue [
	^ minimumValue ifNil: [0.0]
]

{ #category : #accessing }
Slider >> minimumValue: aNumber [

	minimumValue := aNumber.
	self setValue: self value.
]

{ #category : #'other events' }
Slider >> mouseDownInSlider: event [ 

	slider borderStyle style == #raised
		ifTrue: [slider borderStyle: (BorderStyle inset width: slider borderWidth)].
	
	self showSliderShadow.
]

{ #category : #'other events' }
Slider >> mouseUpInSlider: event [ 

	slider borderStyle style == #inset
		ifTrue: [slider borderStyle: (BorderStyle raised width: slider borderWidth)].
	
	self hideSliderShadow.
]

{ #category : #geometry }
Slider >> moveSliderTo: newPosition [
	"Sliently move the slider (or thumb) to not trigger any #layoutChanged events."
	
	| delta |
	self flag: #codeDuplication. "mt: We need a better way to silently do position changes. See Morph >> #position:."
	
	delta := (newPosition - slider position) rounded.
	delta = (0@0) ifTrue: [^ self].
	
	slider privateFullMoveBy: delta.
	self changed.
	
]

{ #category : #initialization }
Slider >> on: anObject getValue: getSel setValue: setSel [

	self
		model: anObject;
		getValueSelector: getSel;
		setValueSelector: setSel;
		getValue.
]

{ #category : #accessing }
Slider >> orientation [

	^ orientation ifNil: [bounds isWide ifTrue: [#horizontal] ifFalse: [#vertical]]
]

{ #category : #accessing }
Slider >> orientation: aSymbol [

	orientation == aSymbol ifTrue: [^ self].
	orientation := aSymbol.
	self updateSlider.
]

{ #category : #'accessing - ui' }
Slider >> pagingArea [
	^self
]

{ #category : #accessing }
Slider >> quantum [

	^ quantum
]

{ #category : #accessing }
Slider >> quantum: aNumber [

	quantum := aNumber.
	self setValue: self value.
]

{ #category : #geometry }
Slider >> resizeSliderTo: newExtent [
	
	slider extent: newExtent.
]

{ #category : #geometry }
Slider >> roomToMove [
	^ self totalSliderArea insetBy: (0@0 extent: self sliderExtent)
]

{ #category : #scrolling }
Slider >> scrollAbsolute: event [
	| r p |
	r := self roomToMove.
	self orientation == #horizontal
		ifTrue: [r width = 0 ifTrue: [^ self]]
		ifFalse: [r height = 0 ifTrue: [^ self]].
	p := event targetPoint adhereTo: r.
	self descending
		ifFalse:
			[self setValueFraction: (self orientation == #horizontal 
				ifTrue: [(p x - r left) asFloat / r width]
				ifFalse: [(p y - r top) asFloat / r height])]
		ifTrue:
			[self setValueFraction: (self orientation == #horizontal
				ifTrue: [(r right - p x) asFloat / r width]
				ifFalse:	[(r bottom - p y) asFloat / r height])]
]

{ #category : #scrolling }
Slider >> scrollBy: delta [

	self setValue: self value + delta.
]

{ #category : #scrolling }
Slider >> scrollToMaximum [

	self setValue: self maximumValue.
]

{ #category : #scrolling }
Slider >> scrollToMinimum [

	self setValue: self minimumValue.
]

{ #category : #initialization }
Slider >> setDefaultParameters [
	"change the receiver's appareance parameters"

	self
		color: (self userInterfaceTheme color ifNil: [Color lightGray]);
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color gray]);
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [1]).
	
	slider
		color: (self userInterfaceTheme thumbColor ifNil: [Color veryVeryLightGray]);
		borderColor: (self userInterfaceTheme thumbBorderColor ifNil: [Color gray: 0.6]);
		borderWidth: (self userInterfaceTheme thumbBorderWidth ifNil: [0]).

	sliderShadow
		borderWidth: slider borderWidth;
		borderColor: Color transparent.

	sliderColor := slider color.
	self updateSliderColor: slider color.
]

{ #category : #'model access' }
Slider >> setValue: newValue [
	"Either changes the value directly or tries to go the loop through the model. See #update:."

	self setValueSelector ifNotNil: [:selector |
		| trimmedValue |
		trimmedValue := self trimmedValue: newValue.
		"Only notify about changed values."
		trimmedValue ~= self value ifTrue: [
			model perform: selector with: trimmedValue]].

	(self setValueSelector isNil or: [self getValueSelector isNil])
		ifTrue: [self value: newValue].
]

{ #category : #support }
Slider >> setValueFraction: newValueFraction [

	self setValue: (newValueFraction * (self maximumValue - self minimumValue)) + self minimumValue.
]

{ #category : #'accessing - model' }
Slider >> setValueSelector [

	^ setValueSelector
]

{ #category : #'accessing - model' }
Slider >> setValueSelector: aSymbol [

	setValueSelector := aSymbol.
]

{ #category : #'other events' }
Slider >> showSliderShadow [

	sliderShadow color: self sliderShadowColor.
	sliderShadow cornerStyle: slider cornerStyle.
	sliderShadow privateBounds: slider bounds. "mt: Avoid #layoutChanged. See #moveSliderTo:."
	sliderShadow show.
]

{ #category : #'accessing - ui' }
Slider >> sliderColor [
	"color scheme for the whole slider widget"
	
	^ sliderColor ifNil: [self userInterfaceTheme thumbColor ifNil: [Color veryVeryLightGray]]
]

{ #category : #'accessing - ui' }
Slider >> sliderColor: newColor [

	sliderColor := newColor.
	self updateSliderColor: sliderColor.
]

{ #category : #geometry }
Slider >> sliderExtent [
	^ self orientation == #horizontal
		ifTrue: [self sliderThickness @ self innerBounds height]
		ifFalse: [self innerBounds width @ self sliderThickness]
]

{ #category : #'accessing - ui' }
Slider >> sliderShadowColor [

	^ ((self userInterfaceTheme thumbShadowModifier
			ifNil: [ [:c | c alpha: 0.7 ] ]) value: self sliderColor)
]

{ #category : #geometry }
Slider >> sliderThickness [
	^ 7
]

{ #category : #'accessing - ui' }
Slider >> thumb [

	^ slider
]

{ #category : #'accessing - ui' }
Slider >> thumbColor [
	"Color of the draggable 'thumb'"
	^ self sliderColor
]

{ #category : #geometry }
Slider >> totalSliderArea [
	^ self innerBounds
]

{ #category : #support }
Slider >> trimmedValue: aValue [

	| trimmedValue |
	trimmedValue := aValue min: self maximumValue max: self minimumValue.
	self quantum ifNotNil: [:q | trimmedValue := trimmedValue roundTo: q].
	^ trimmedValue

]

{ #category : #accessing }
Slider >> truncate [

	^ self quantum == 1
]

{ #category : #accessing }
Slider >> truncate: aBoolean [

	self quantum: (aBoolean ifTrue: [1] ifFalse: [nil]).
]

{ #category : #updating }
Slider >> update: aSymbol [
	"Update the value."
	
	super update: aSymbol.
	
	aSymbol = self getValueSelector ifTrue: [self getValue. ^ self].
	aSymbol = self getMinimumValueSelector ifTrue: [self getMinimumValue. ^ self].
	aSymbol = self getMaximumValueSelector ifTrue: [self getMaximumValue. ^ self].
]

{ #category : #updating }
Slider >> updateSlider [
	"Updates layout properties of the slider."
	
	slider bounds: self totalSliderArea.
	sliderShadow bounds: slider bounds.
	
	self computeSlider.

]

{ #category : #updating }
Slider >> updateSliderColor: aColor [

	slider color: aColor.
	sliderShadow color: self sliderShadowColor.
]

{ #category : #'layout-properties' }
Slider >> vResizing [
	"Due to possible automatic orientation change on extent changes, we have to calculate the resizing property based on the current orientation. Otherwise, layout will break. There is, however, support for using the resizing property in layout properties if set."

	self layoutProperties ifNotNil: [:props |
		^ props vResizing].

	^ self orientation == #vertical
		ifTrue: [#spaceFill]
		ifFalse: [#rigid]
]

{ #category : #accessing }
Slider >> value [

	^ value
]

{ #category : #accessing }
Slider >> value: newValue [

	| t |
	t := self trimmedValue: newValue.
	t = value ifTrue: [^ self].
	
	value := t.
	self computeSlider.
]

{ #category : #testing }
Slider >> wantsSlot [
	"For now do it the old way, until we sort this out"
	^ true
]
