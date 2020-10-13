"
Inspired by an oiginal design of Hans-Martin Mosner, this ScrollBar is intended to exercise the handling of input events in Morphic.  With sufficient flexibility in this area, all particular behavior can be concentrated in this single class with no need to specialize any other morphs to achieve button, slider and menu-button behavior.

Once we have this working, put in logic for horizontal operation as well.

CachedImages was added to reduce the number of forms created and thrown away. This will be helpful for Nebraska and others as well.
"
Class {
	#name : #ScrollBar,
	#superclass : #Slider,
	#instVars : [
		'menuButton',
		'upButton',
		'downButton',
		'pagingArea',
		'scrollDelta',
		'pageDelta',
		'interval',
		'menuSelector',
		'timeOfMouseDown',
		'timeOfLastScroll',
		'nextPageDirection',
		'currentScrollDelay'
	],
	#classVars : [
		'ArrowImagesCache',
		'BoxesImagesCache',
		'GradientScrollBar',
		'RoundedScrollBarLook',
		'ScrollBarsWithoutArrowButtons',
		'ScrollBarsWithoutMenuButton',
		'UpArrow',
		'UpArrow8Bit'
	],
	#category : #'Morphic-Windows'
}

{ #category : #preferences }
ScrollBar class >> alwaysShowFlatScrollbarForAlternativeLook [
	"Set this value to true, if you want to see the flat scrollbar look in flop-out mode as well as inboard.  Otherwise the flop-out scrollbar will be rounded and inboard will be flat."
	^ false
]

{ #category : #images }
ScrollBar class >> arrowOfDirection: aSymbol size: finalSizeInteger color: aColor [ 
	"answer a form with an arrow based on the parameters"
	^ ArrowImagesCache at: {aSymbol. finalSizeInteger max: 1. aColor}
]

{ #category : #'images - samples' }
ScrollBar class >> arrowSamples [
	"create a set of arrow with different sizes, colors and directions"
	" 
	ScrollBar arrowSamples.  
	"
	| column |
	column := AlignmentMorph newColumn vResizing: #shrinkWrap;
				 hResizing: #shrinkWrap;
				 layoutInset: 1;
				 borderColor: Color black;
				 borderWidth: 0;
				 wrapCentering: #center;
				 cellPositioning: #center;
				 color: Color white;
				 yourself.
	
	self sampleSizes
		do: [:size | 
			| row | 
			row := AlignmentMorph newRow color: Color transparent;
						 vResizing: #shrinkWrap;
						 cellGap: 2 @ 0;
						 yourself.
			
			self sampleColors
				do: [:color | 
					#(#top #right #bottom #left )
						do: [:direction | 
							row addMorphBack: (ScrollBar
									arrowOfDirection: direction
									size: size
									color: color) asMorph]].
			
			column addMorphBack: row].
	
	column openInHand
]

{ #category : #images }
ScrollBar class >> boxOfSize: finalSizeInteger color: aColor [ 
	"answer a form with an box based on the parameters"
	^ BoxesImagesCache at: {finalSizeInteger. aColor}
]

{ #category : #'images - samples' }
ScrollBar class >> boxSamples [
	"create a set of box with different sizes and colors"
	" 
	ScrollBar boxSamples.  
	"
	| column |
	column := AlignmentMorph newColumn vResizing: #shrinkWrap;
				 hResizing: #shrinkWrap;
				 layoutInset: 1;
				 borderColor: Color black;
				 borderWidth: 0;
				 wrapCentering: #center;
				 cellPositioning: #center;
				 color: Color white;
				 yourself.
	""
	self sampleSizes
		do: [:size | 
			| row | 
			row := AlignmentMorph newRow color: Color transparent;
						 vResizing: #shrinkWrap;
						 cellGap: 2 @ 0;
						 yourself.
			""
			self sampleColors
				do: [:color | 
					row addMorphBack: (ScrollBar boxOfSize: size color: color) asMorph].
			""
			column addMorphBack: row].
	""
	""
	column openInHand
]

{ #category : #images }
ScrollBar class >> changesInPreferences [
	"the related preferences changed"
	self initializeImagesCache
	" ScrollBar allInstances do: [:each | each removeAllMorphs; initializeSlider] "
]

{ #category : #'class initialization' }
ScrollBar class >> cleanUp [
	"Re-initialize the image cache"

	self initializeImagesCache
]

{ #category : #'class initialization' }
ScrollBar class >> createArrowImagesCache [
	"creates the cache to store the arrow forms"
	^ LRUCache
		size: 40
		factory: [:key | ""
			self
				createArrowOfDirection: key first
				size: key second
				color: key third]
]

{ #category : #images }
ScrollBar class >> createArrowOfDirection: aSymbolDirection size: size color: aColor [ 
	"PRIVATE - create an arrow with aSymbolDirectionDirection, finalSizeInteger and aColor  
	aSymbolDirectionDirection = #top, #bottom. #left or #right  
	 ScrollBar initializeImagesCache.
	Try with: 
	(ScrollBar createArrowOfDirection: #right size: 14 color: Color lightGreen) asMorph openInHand."
	
	| form canvas vertices margin |
	form := Form extent: size asPoint depth: 32.
	canvas := form getCanvas.
	margin := size < 14 ifTrue: [2] ifFalse: [3].
	vertices := {
		size // 2 @ margin.
		size asPoint - margin asPoint.
		margin @ (size-margin).
		size // 2 @ margin}.
	
	"Preferences gradientScrollBars
		ifTrue: [
			fillStyle := GradientFillStyle ramp: {
					0.0 -> (aColor adjustBrightness: 0.5).
					0.1-> (aColor adjustBrightness: 0.05).
					0.6 -> (aColor darker)}.
			fillStyle origin: size // 2 @ margin.
			fillStyle direction: 0 @ size]
		ifFalse: [
			fillStyle := SolidFillStyle color: aColor]. "
	
	canvas
		drawPolygon: vertices
		fillStyle: (SolidFillStyle color: aColor).
	
	^ (form rotateBy: (aSymbolDirection caseOf: {
		[#top] -> [0].
		[#bottom] -> [180].
		[#left] -> [270].
		[#right] -> [90]})) clippedToSize: size asPoint
]

{ #category : #'class initialization' }
ScrollBar class >> createBoxImagesCache [
	"creates the cache to store the arrow forms"
	^ LRUCache
		size: 20
		factory: [:key | self createBoxOfSize: key first color: key second]
]

{ #category : #images }
ScrollBar class >> createBoxOfSize: anInteger color: aColor [ 
	"PRIVATE - create a box with anInteger and aColor  
	 
	Try with:  
	(ScrollBar createBoxOfSize: 32 color: Color gray) asMorph  
	openInHand.  
	"
	
	| form canvas margin |
	form := Form extent: anInteger asPoint depth: 32.
	canvas := form getCanvas.
	margin := anInteger < 14 ifTrue: [3] ifFalse: [4].

	"Preferences gradientScrollBars
		ifTrue: [
			fillStyle := GradientFillStyle ramp: {
					0.0 -> (aColor adjustBrightness: 0.5).
					0.1-> (aColor adjustBrightness: 0.05).
					0.6 -> (aColor darker)}.
			fillStyle origin: margin asPoint.
			fillStyle direction: anInteger @ 0]
		ifFalse: [
			fillStyle := SolidFillStyle color: aColor]. "
	
	canvas
		fillRectangle: ((0@0 extent: anInteger asPoint) insetBy: margin)
		fillStyle: (SolidFillStyle color: aColor).
		
	^ form
]

{ #category : #preferences }
ScrollBar class >> gradientScrollBar [

	<preference: 'gradientScrollBar'
		categoryList: #(windows scrolling)
		description: 'If true, scroll bars will have a gradient look.'
		type: #Boolean>
	^ GradientScrollBar ifNil: [false]
]

{ #category : #preferences }
ScrollBar class >> gradientScrollBar: aBoolean [

	GradientScrollBar = aBoolean ifTrue: [^ self].
	GradientScrollBar := aBoolean.

	ScrollBar allSubInstancesDo: [:ea | ea updateSliderColor].
]

{ #category : #'class initialization' }
ScrollBar class >> initialize [
	"ScrollBar initialize"
	UpArrow := Form
				extent: 6 @ 3
				fromArray: #(805306368 2013265920 4227858432 )
				offset: 0 @ 0.
	""
	self initializeImagesCache.

	"Adjustments for FaceLift"
	Preferences disable: #scrollBarsNarrow.
	SystemWindow allSubInstancesDo:[:w| w updatePaneColors].
	ScrollPane allSubInstancesDo:[:pane| pane hideOrShowScrollBars].

]

{ #category : #'class initialization' }
ScrollBar class >> initializeImagesCache [
	"initialize the receiver's ImagesCache. 
	 
	normally this method is not evaluated more than in the class 
	initializazion. "

	" 
	ScrollBar initializeImagesCache.
	"

	ArrowImagesCache := self createArrowImagesCache.
	BoxesImagesCache := self createBoxImagesCache
]

{ #category : #'class initialization' }
ScrollBar class >> postRecompileAction [
	"The ArrowImagesCache and BoxesImagesCache are LRUCaches that reference blocks
	 (including indirectly via their map which is a PluggableDictionary integerDictionary).
	 Rebuild them to ensure blocks reference freshly recompiled methods."

	self initializeImagesCache
]

{ #category : #'class initialization' }
ScrollBar class >> refreshAllScrollBars [

	ScrollBar allSubInstances do: [:s |
		s updateSlider].
]

{ #category : #preferences }
ScrollBar class >> roundedScrollBarLook [

	<preference: 'roundedScrollBarLook'
		category: #scrolling
		description: 'If true, morphic scrollbars will look rounded.'
		type: #Boolean>
	^ RoundedScrollBarLook ifNil: [false]
]

{ #category : #preferences }
ScrollBar class >> roundedScrollBarLook: aBoolean [

	RoundedScrollBarLook = aBoolean ifTrue: [^ self].
	RoundedScrollBarLook := aBoolean.
	
	ScrollBar allSubInstancesDo: [:ea | ea updateSliderCornerStyle].
]

{ #category : #'images - samples' }
ScrollBar class >> sampleColors [
	"private"
	^ (Color lightCyan wheel: 5)
]

{ #category : #'images - samples' }
ScrollBar class >> sampleSizes [
	
"private"
	^ #(10 12 14 16 18 32 64 )
]

{ #category : #preferences }
ScrollBar class >> scrollBarsWithoutArrowButtons [

	<preference: 'scrollBarsWithoutArrowButtons'
		category: #scrolling
		description: 'If true, morphic scrollbars will not include arrow buttons but only the slider.'
		type: #Boolean>
	^ ScrollBarsWithoutArrowButtons ifNil: [false]
]

{ #category : #preferences }
ScrollBar class >> scrollBarsWithoutArrowButtons: aBoolean [

	ScrollBarsWithoutArrowButtons = aBoolean ifTrue: [^ self].
	ScrollBarsWithoutArrowButtons := aBoolean.
	self refreshAllScrollBars.
]

{ #category : #preferences }
ScrollBar class >> scrollBarsWithoutMenuButton [

	<preference: 'scrollBarsWithoutMenuButton'
		category: #scrolling
		description: 'If true, morphic scrollbars will not include a menu button.'
		type: #Boolean>
	^ ScrollBarsWithoutMenuButton ifNil: [false]
]

{ #category : #preferences }
ScrollBar class >> scrollBarsWithoutMenuButton: aBoolean [

	ScrollBarsWithoutMenuButton = aBoolean ifTrue: [^ self].
	ScrollBarsWithoutMenuButton := aBoolean.
	self refreshAllScrollBars.
]

{ #category : #preferences }
ScrollBar class >> themeProperties [

	^ super themeProperties, {		
		{ #pagingAreaColorModifier. 'Colors'. 'How to modify the paging area color when adopting a pane color.' }.
		{ #thumbColorModifier. 'Colors'. 'How to modify the thumb color when adopting a pane color.' }.
		{ #borderColorModifier. 'Colors'. 'How to modify the border color when adopting a pane color.' }.
	}
]

{ #category : #updating }
ScrollBar >> adoptPaneColor: aColor [
	"Adopt the given pane color"
	aColor ifNil:[^self].
	self sliderColor: aColor.
]

{ #category : #updating }
ScrollBar >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
]

{ #category : #geometry }
ScrollBar >> boundsForDownButton [
	
	^ self innerBounds bottomRight - self buttonExtent 
		extent: self buttonExtent
]

{ #category : #geometry }
ScrollBar >> boundsForMenuButton [

	^ self innerBounds topLeft extent: self buttonExtent
]

{ #category : #geometry }
ScrollBar >> boundsForUpButton [

	^ (self menuButton visible
		ifFalse: [self innerBounds topLeft]
		ifTrue: [self orientation == #horizontal
			ifTrue: [self menuButton bounds topRight - (1@0)]
			ifFalse: [self menuButton bounds bottomLeft - (0@1)]])
		extent: self buttonExtent
]

{ #category : #geometry }
ScrollBar >> buttonExtent [
	^ self orientation == #horizontal
		ifTrue: [self innerBounds height asPoint]
		ifFalse: [self innerBounds width asPoint]
]

{ #category : #scrolling }
ScrollBar >> doScrollByPage [
	"Scroll automatically while mouse is down"
	(self waitForDelay1: 300 delay2: 100) ifFalse: [^ self].
	nextPageDirection
		ifTrue: [self setValue: value + pageDelta]
		ifFalse: [self setValue: value - pageDelta]

]

{ #category : #scrolling }
ScrollBar >> doScrollDown [
	"Scroll automatically while mouse is down"
	(self waitForDelay1: 200 delay2: 40) ifFalse: [^ self].
	self setValue: value + scrollDelta.
]

{ #category : #scrolling }
ScrollBar >> doScrollUp [
	"Scroll automatically while mouse is down"
	(self waitForDelay1: 200 delay2: 40) ifFalse: [^ self].
	self setValue: value - scrollDelta.
]

{ #category : #accessing }
ScrollBar >> downButton [
	^ downButton
]

{ #category : #images }
ScrollBar >> downImage [
	"answer a form to be used in the down button"
	^ self class
		arrowOfDirection: (self orientation == #horizontal
				ifTrue: [#right]
				ifFalse: [#bottom])
		size: (self buttonExtent x min: self buttonExtent y)
		color: self imageColor
]

{ #category : #geometry }
ScrollBar >> expandSlider [
	"Compute the new size of the slider (use the old sliderThickness as a minimum)."
	| r |
	r := self totalSliderArea.
	slider extent: (self orientation == #horizontal
		ifTrue: [(((r width * self interval) asInteger max: self minThumbThickness) min: r width) @ slider height]
		ifFalse: [slider width @ (((r height * self interval) asInteger max: self minThumbThickness) min: r height)])
]

{ #category : #geometry }
ScrollBar >> extent: p [ 

	(bounds extent closeTo: p) ifTrue: [^ self].
	
	p x > p y
		ifTrue: [super
				extent: (p max: 8 @ 4)]
		ifFalse: [super
				extent: (p max: 4 @ 8)].
			
	self updateSliderColor.
	
]

{ #category : #scrolling }
ScrollBar >> finishedScrolling [
	self stopStepping.
	self scrollBarAction: nil.

]

{ #category : #testing }
ScrollBar >> hasButtons [

	^ (self menuButton visible or: [upButton visible]) or: [downButton visible]
]

{ #category : #accessing }
ScrollBar >> imageColor [

	^ slider ifNil: [Color black] ifNotNil: [:s | 
		(s color = s borderColor or: [s borderColor isTransparent])
			ifTrue: [s color adjustBrightness: (s color brightness < 0.5 ifTrue: [0.2] ifFalse: [-0.2])]
			ifFalse: [s borderColor]]
]

{ #category : #initialize }
ScrollBar >> initialize [

	interval := 0.2.
	scrollDelta := 0.02.
	pageDelta := 0.2.
	
	super initialize.
]

{ #category : #initialize }
ScrollBar >> initializeDownButton [
	"initialize the receiver's downButton"

	downButton := RectangleMorph newBounds: self boundsForDownButton.
	downButton 
		on: #mouseDown
		send: #scrollDownInit
		to: self.
	downButton 
		on: #mouseUp
		send: #finishedScrolling
		to: self.
	self updateDownButtonImage.	
	self addMorphFront: downButton.
	downButton
		visible: self class scrollBarsWithoutArrowButtons not;
		disableLayout: downButton visible not.
]

{ #category : #initialize }
ScrollBar >> initializeMenuButton [
"initialize the receiver's menuButton"
	"Preferences disable: #scrollBarsWithoutMenuButton"
	"Preferences enable: #scrollBarsWithoutMenuButton"
	menuButton := RectangleMorph newBounds: self boundsForMenuButton.
	menuButton
		on: #mouseEnter
		send: #menuButtonMouseEnter:
		to: self.
	menuButton
		on: #mouseDown
		send: #menuButtonMouseDown:
		to: self.
	menuButton
		on: #mouseLeave
		send: #menuButtonMouseLeave:
		to: self.
	"menuButton 
	addMorphCentered: (RectangleMorph 
	newBounds: (0 @ 0 extent: 4 @ 2) 
	color: Color black)."
	self updateMenuButtonImage.
	self addMorphFront: menuButton.
	menuButton
		visible: (self class scrollBarsWithoutMenuButton or: [self orientation == #horizontal]) not;
		disableLayout: menuButton visible not.
]

{ #category : #initialize }
ScrollBar >> initializePagingArea [
	
	"Appearance"
	pagingArea := RectangleMorph newBounds: self totalSliderArea.
	self addMorphBack: pagingArea.
			
	"Interactions"
	pagingArea
		on: #mouseDown
		send: #scrollPageInit:
		to: self.
	pagingArea
		on: #mouseUp
		send: #finishedScrolling
		to: self.
	

]

{ #category : #initialize }
ScrollBar >> initializeSlider [

	self
		initializeMenuButton;
		initializeUpButton;
		initializeDownButton;
		initializePagingArea.
		
	super initializeSlider.
	
	self expandSlider.
]

{ #category : #initialize }
ScrollBar >> initializeUpButton [
"initialize the receiver's upButton"
	upButton := RectangleMorph newBounds: self boundsForUpButton.
	upButton
		on: #mouseDown
		send: #scrollUpInit
		to: self.
	upButton
		on: #mouseUp
		send: #finishedScrolling
		to: self.
	self updateUpButtonImage.
	self addMorph: upButton.	
	upButton
		visible: self class scrollBarsWithoutArrowButtons not;
		disableLayout: upButton visible not.
]

{ #category : #accessing }
ScrollBar >> interval [
	
	^ interval ifNil: [interval := 0.2]
]

{ #category : #accessing }
ScrollBar >> interval: d [
	"Supply an optional floating fraction so slider can expand to indicate range"
	interval := d min: 1.0.
	self expandSlider.
	self computeSlider.
]

{ #category : #accessing }
ScrollBar >> menuButton [

	^ menuButton ifNil: [menuButton := RectangleMorph new]
]

{ #category : #'event handling' }
ScrollBar >> menuButtonMouseDown: event [
	event hand showTemporaryCursor: nil.
	self use: menuSelector orMakeModelSelectorFor: 'MenuButtonPressed:'
		in: [:sel | menuSelector := sel.  model perform: sel with: event]
]

{ #category : #images }
ScrollBar >> menuImage [
	"answer a form to be used in the menu button"
	^ self class
		boxOfSize: (self buttonExtent x min: self buttonExtent y)
		color: self imageColor
]

{ #category : #accessing }
ScrollBar >> menuSelector [
	^ menuSelector
]

{ #category : #accessing }
ScrollBar >> menuSelector: aSymbol [
	menuSelector := aSymbol.
]

{ #category : #geometry }
ScrollBar >> minHeight [
	"The minimum extent is that of 2 or 3 buttons in a row or column,
	the 'up' and 'down' button and optionally the 'menu' button."

	| buttonCount refExtent refBorder |
	refExtent := upButton minExtent.
	refBorder := upButton borderWidth.
	buttonCount := {
		upButton visible.
		downButton visible.
		self menuButton visible. } count: [:ea | ea].
	^ self orientation == #horizontal
		ifTrue: [super minHeight max: 5]
		ifFalse: [super minHeight max: ((buttonCount * refExtent y) - (buttonCount-1 * refBorder))]
]

{ #category : #geometry }
ScrollBar >> minThumbThickness [

	^ Preferences standardDefaultTextFont height
]

{ #category : #geometry }
ScrollBar >> minWidth [
	"The minimum extent is that of 2 or 3 buttons in a row or column,
	the 'up' and 'down' button and optionally the 'menu' button."

	| buttonCount refExtent refBorder |
	refExtent := upButton minExtent.
	refBorder := upButton borderWidth.
	buttonCount := {
		upButton visible.
		downButton visible.
		self menuButton visible. } count: [:ea | ea].
	^ self orientation == #horizontal
		ifTrue: [super minWidth max: ((buttonCount * refExtent x) - (buttonCount-1 * refBorder))]
		ifFalse: [super minWidth max: 5]
]

{ #category : #'event handling' }
ScrollBar >> mouseDownInSlider: event [

	"make the entire scrollable area visible if a full scrollbar is clicked on"
	self interval = self maximumValue ifTrue: [
		self setValue: 0.
		self model hideOrShowScrollBars].
	
	self showSliderShadow.
]

{ #category : #accessing }
ScrollBar >> pagingArea [
	^pagingArea
]

{ #category : #'scroll timing' }
ScrollBar >> resetTimer [
	timeOfMouseDown := Time millisecondClockValue.
	timeOfLastScroll := timeOfMouseDown - 1000 max: 0.
	nextPageDirection := nil.
	currentScrollDelay := nil
]

{ #category : #scrolling }
ScrollBar >> scrollBarAction [
	^self valueOfProperty: #scrollBarAction
]

{ #category : #scrolling }
ScrollBar >> scrollBarAction: aSymbol [
	self setProperty: #scrollBarAction toValue: aSymbol
]

{ #category : #accessing }
ScrollBar >> scrollDelta [
	^ scrollDelta
]

{ #category : #accessing }
ScrollBar >> scrollDelta: d1 pageDelta: d2 [
	"Supply optional increments for better scrolling of, eg, text"
	scrollDelta := d1.
	pageDelta := d2.
]

{ #category : #scrolling }
ScrollBar >> scrollDown: count [
	self setValue: value + (scrollDelta * count).
]

{ #category : #scrolling }
ScrollBar >> scrollDownInit [
	self resetTimer.
	self scrollBarAction: #doScrollDown.
	self startStepping.
]

{ #category : #scrolling }
ScrollBar >> scrollPageInit: evt [

	evt redButtonPressed ifFalse: [^ self].

	self resetTimer.
	self setNextDirectionFromEvent: evt.
	self scrollBarAction: #doScrollByPage.
	self startStepping.
]

{ #category : #scrolling }
ScrollBar >> scrollUp: count [
	self setValue: value - (scrollDelta * count).
]

{ #category : #scrolling }
ScrollBar >> scrollUpInit [
	self resetTimer.
	self scrollBarAction: #doScrollUp.
	self startStepping.
]

{ #category : #initialize }
ScrollBar >> setDefaultParameters [

	"Compared to generic sliders, I am not my own paging area. Thus, make me transparent."
	self
		color: Color transparent;
		borderWidth: 0.

	pagingArea
		color: (self userInterfaceTheme color ifNil: [Color veryVeryLightGray darker alpha: 0.35]);
		borderWidth: 0. "no border for the paging area"

	slider
		color: (self userInterfaceTheme thumbColor ifNil: [Color veryVeryLightGray]);
		borderColor: (self userInterfaceTheme thumbBorderColor ifNil: [Color gray: 0.6]);
		borderWidth: (self userInterfaceTheme thumbBorderWidth ifNil: [1]).
	
	self updateSliderCornerStyle.
	
	sliderShadow
		cornerStyle: slider cornerStyle;
		borderWidth: slider borderWidth;
		borderColor: Color transparent.
	
	sliderColor := slider color.
	self updateSliderColor: slider color.
]

{ #category : #scrolling }
ScrollBar >> setNextDirectionFromEvent: event [

	nextPageDirection := self orientation == #horizontal
		ifTrue: [event cursorPoint x >= slider center x]
		ifFalse: [event cursorPoint y >= slider center y].

]

{ #category : #accessing }
ScrollBar >> sliderColor: aColor [ 
	"Change the color of the scrollbar to go with aColor."

	super sliderColor: aColor.
	self updateSliderColor: aColor.
]

{ #category : #geometry }
ScrollBar >> sliderExtent [
	"The sliderExtent is now stored in the slider itself, not hardcoded as it is in the superclass."
	^slider extent
]

{ #category : #geometry }
ScrollBar >> sliderThickness [
	^ self orientation == #horizontal
		ifTrue: [self height]
		ifFalse: [self width]
]

{ #category : #'stepping and presenter' }
ScrollBar >> step [
	| action |
	action := self scrollBarAction.
	action ifNotNil:[self perform: action].
]

{ #category : #'stepping and presenter' }
ScrollBar >> stepTime [
	^ currentScrollDelay ifNil: [300]
]

{ #category : #geometry }
ScrollBar >> totalSliderArea [
	| upperReferenceBounds lowerReferenceBounds |
	upperReferenceBounds := (upButton visible ifFalse: [self menuButton visible ifTrue: [self menuButton] ifFalse: [nil]] ifTrue: [upButton])
		ifNil: [self topLeft corner: (self orientation == #horizontal ifTrue: [self bottomLeft + (1@0)] ifFalse: [self topRight + (0@1)])]
		ifNotNil: [:button | button bounds].
	lowerReferenceBounds := downButton visible
		ifFalse: [(self orientation == #horizontal ifTrue: [self topRight - (1@0)] ifFalse: [self bottomLeft - (0@1)]) corner: self bottomRight]
		ifTrue: [downButton bounds].
	^ self orientation == #horizontal
		ifTrue: [upperReferenceBounds topRight - (1@0) corner: lowerReferenceBounds bottomLeft + (1@0)]
		ifFalse:[upperReferenceBounds bottomLeft - (0@1) corner: lowerReferenceBounds topRight + (0@1)].

]

{ #category : #images }
ScrollBar >> upArrow8Bit [

	"convert to 8-bit and convert white to transparent to avoid gratuitous conversion every time we put one in an ImageMorph"

	^UpArrow8Bit ifNil: [
		UpArrow8Bit := (ColorForm mappingWhiteToTransparentFrom: UpArrow) asFormOfDepth: 8
	]
]

{ #category : #accessing }
ScrollBar >> upButton [
	^ upButton
]

{ #category : #images }
ScrollBar >> upImage [
	"answer a form to be used in the up button"
	^ self class
		arrowOfDirection: (self orientation == #horizontal
				ifTrue: [#left]
				ifFalse: [#top])
		size: (self buttonExtent x min: self buttonExtent y)
		color: self imageColor
]

{ #category : #updating }
ScrollBar >> updateDownButtonImage [
	"update the receiver's downButton.  put a new image inside"
	downButton removeAllMorphs.
	downButton addMorphCentered: (ImageMorph new image: self downImage).
]

{ #category : #updating }
ScrollBar >> updateMenuButtonImage [
	"update the receiver's menuButton. put a new image inside"

	self menuButton removeAllMorphs.
	self menuButton addMorphCentered: (ImageMorph new image: self menuImage).
]

{ #category : #updating }
ScrollBar >> updateSlider [

	| imagesNeedUpdate |
	imagesNeedUpdate := upButton width ~= (self orientation == #horizontal ifTrue: [self height] ifFalse: [self width]).
	
	self menuButton
		visible: (self orientation == #horizontal or: [self class scrollBarsWithoutMenuButton]) not;
		disableLayout: self menuButton visible not;
		bounds: self boundsForMenuButton.
	self upButton
		visible: self class scrollBarsWithoutArrowButtons not;
		disableLayout: self upButton visible not;
		bounds: self boundsForUpButton.
	self downButton
		visible: self class scrollBarsWithoutArrowButtons not;
		disableLayout: self downButton visible not;
		bounds: self boundsForDownButton.

	super updateSlider.

	pagingArea bounds: self totalSliderArea.
	self expandSlider.

	imagesNeedUpdate ifTrue: [
		self menuButton visible ifTrue: [self updateMenuButtonImage].
		self upButton visible ifTrue: [self updateUpButtonImage].
		self downButton visible ifTrue: [self updateDownButtonImage]].
]

{ #category : #updating }
ScrollBar >> updateSliderColor [

	self updateSliderColor: self sliderColor.
]

{ #category : #updating }
ScrollBar >> updateSliderColor: aColor [

	self class gradientScrollBar
		ifFalse: [self updateSliderColorSolid: aColor]
		ifTrue: [self updateSliderColorGradient: aColor].
		
	self flag: #performance. "mt: This is slow..."
	self updateMenuButtonImage.
	self updateUpButtonImage.
	self updateDownButtonImage.
]

{ #category : #updating }
ScrollBar >> updateSliderColorGradient: aColor [

	| gradient cc |
	pagingArea color: ((self userInterfaceTheme pagingAreaColorModifier
		ifNil: [ [:c | c darker alpha: 0.35] ]) value: aColor).
	slider borderColor: ((self userInterfaceTheme borderColorModifier
		ifNil: [ [:c | c adjustBrightness: -0.3] ]) value: aColor).
	
	cc := ((self userInterfaceTheme thumbColorModifier
		ifNil: [ [:c | c] ]) value: aColor).
	
	gradient := GradientFillStyle ramp: {
		0.0 -> Color white.
		0.1-> (cc adjustBrightness: 0.05).
		0.6 -> (cc darker)}.
	
	"Fill the thumb"
	gradient origin: slider topLeft.
	gradient direction: (self orientation == #horizontal
		ifTrue:[0@slider height]
		ifFalse:[slider width@0]).
	slider fillStyle: gradient.
	
	"Fill the buttons"
	{self menuButton. self upButton. self downButton} do: [:ea |
		gradient := gradient copy.
		gradient origin: ea topLeft.
		gradient direction: (self orientation == #horizontal
			ifTrue:[0@ea height]
			ifFalse:[ea width@0]).
		ea
			fillStyle: gradient;
			borderWidth: slider borderWidth;
			borderColor: slider borderColor].
]

{ #category : #updating }
ScrollBar >> updateSliderColorSolid: aColor [

	sliderShadow color: self sliderShadowColor.

	slider color: ((self userInterfaceTheme thumbColorModifier
		ifNil: [ [:c | c] ]) value: aColor).

	slider borderColor: ((self userInterfaceTheme borderColorModifier
		ifNil: [ [:c | c adjustBrightness: -0.3] ]) value: aColor).

	pagingArea color: ((self userInterfaceTheme pagingAreaColorModifier
		ifNil: [ [:c | c darker alpha: 0.35] ]) value: aColor).
		
	{self menuButton. self upButton. self downButton} do: [:ea |
		ea
			color: slider color;
			borderWidth: slider borderWidth;
			borderColor: slider borderColor].
]

{ #category : #updating }
ScrollBar >> updateSliderCornerStyle [
	"Right now, only the slider's corner style is affected. Buttons and paging area remain square. Looks better somehow... :-)"
	
	slider cornerStyle: (self class roundedScrollBarLook ifTrue: [#rounded] ifFalse: [#square]).
]

{ #category : #updating }
ScrollBar >> updateUpButtonImage [
"update the receiver's upButton. put a new image inside"
	upButton removeAllMorphs.
	upButton addMorphCentered: (ImageMorph new image: self upImage).
]

{ #category : #'scroll timing' }
ScrollBar >> waitForDelay1: delay1 delay2: delay2 [ 
	"Return true if an appropriate delay has passed since the last scroll operation.
	The delay decreases exponentially from delay1 to delay2."

	| now scrollDelay |
	timeOfLastScroll ifNil: [self resetTimer].	"Only needed for old instances"
	now := Time millisecondClockValue.
	(scrollDelay := currentScrollDelay) isNil 
		ifTrue: [scrollDelay := delay1	"initial delay"].
	currentScrollDelay := scrollDelay * 9 // 10 max: delay2.	"decrease the delay"
	timeOfLastScroll := now.
	^true
]

{ #category : #'stepping and presenter' }
ScrollBar >> wantsSteps [
	^self scrollBarAction notNil
]
