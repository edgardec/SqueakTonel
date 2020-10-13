"
A PluggableButtonMorph is a combination of an indicator for a boolean value stored in its model and an action button. The action of a button is often, but not always, to toggle the boolean value that it shows. Its pluggable selectors are:

		getStateSelector		fetch a boolean value from the model
		actionSelector		invoke this button's action on the model
		getLabelSelector		fetch this button's lable from the model
		getMenuSelector		fetch a pop-up menu for this button from the model

Any of the above selectors can be nil, meaning that the model does not supply behavior for the given action, and the default behavior should be used. For example, if getStateSelector is nil, then this button shows the state of a read-only boolean that is always false.

The model informs its view(s) of changes by sending #changed: to itself with getStateSelector as a parameter. The view tells the model when the button is pressed by sending actionSelector.

If the actionSelector takes one or more arguments, then the following are relevant:
		arguments			A list of arguments to provide when the actionSelector is called.
		argumentsProvider	The object that is sent the argumentSelector to obtain arguments, if dynamic
		argumentsSelector	The message sent to the argumentProvider to obtain the arguments.

Options:
	askBeforeChanging		have model ask user before allowing a change that could lose edits
	triggerOnMouseDown	do this button's action on mouse down (vs. up) transition
	shortcutCharacter		a place to record an optional shortcut key

"
Class {
	#name : #PluggableButtonMorph,
	#superclass : #Morph,
	#instVars : [
		'model',
		'label',
		'font',
		'getStateSelector',
		'actionSelector',
		'getLabelSelector',
		'getMenuSelector',
		'shortcutCharacter',
		'askBeforeChanging',
		'triggerOnMouseDown',
		'offColor',
		'onColor',
		'feedbackColor',
		'showSelectionFeedback',
		'allButtons',
		'arguments',
		'argumentsProvider',
		'argumentsSelector',
		'style',
		'hoverColor',
		'borderColor',
		'textColor',
		'labelOffset',
		'wantsGradient'
	],
	#classVars : [
		'GradientButton',
		'RoundedButtonCorners'
	],
	#category : #'Morphic-Pluggable Widgets'
}

{ #category : #example }
PluggableButtonMorph class >> example [
	"PluggableButtonMorph example openInWorld"

	| s1 s2 s3 b1 b2 b3 row switchClass |
	switchClass := Smalltalk at: #Switch ifAbsent: [^self inform: 'MVC class Switch not present'].
	s1 := switchClass new.
	s2 := switchClass new turnOn.
	s3 := switchClass new.
	s2 onAction: [s3 turnOff].
	s3 onAction: [s2 turnOff].
	b1 := (PluggableButtonMorph on: s1 getState: #isOn action: #switch) label: 'S1'.
	b2 := (PluggableButtonMorph on: s2 getState: #isOn action: #turnOn) label: 'S2'.
	b3 := (PluggableButtonMorph on: s3 getState: #isOn action: #turnOn) label: 'S3'.
	b1
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	b2
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	b3
		hResizing: #spaceFill;
		vResizing: #spaceFill.

	row := AlignmentMorph newRow
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		addAllMorphs: (Array with: b1 with: b2 with: b3);
		extent: 120@35.
	^ row

]

{ #category : #preferences }
PluggableButtonMorph class >> gradientButton [
	<preference: 'gradientButton'
		category: 'windows'
		description: 'If true, buttons will have a gradient look.'
		type: #Boolean>
	^ GradientButton ifNil: [ true ]
]

{ #category : #preferences }
PluggableButtonMorph class >> gradientButton: aBoolean [

	GradientButton = aBoolean ifTrue: [^ self].
	GradientButton := aBoolean.
	
	PluggableButtonMorph allSubInstancesDo: [:ea | ea updateFillStyle].
]

{ #category : #'instance creation' }
PluggableButtonMorph class >> on: anObject [

	^ self on: anObject getState: #isOn action: #switch

]

{ #category : #'instance creation' }
PluggableButtonMorph class >> on: anObject getState: getStateSel action: actionSel [

	^ self new
		on: anObject
		getState: getStateSel
		action: actionSel
		label: nil
		menu: nil

]

{ #category : #'instance creation' }
PluggableButtonMorph class >> on: anObject getState: getStateSel action: actionSel label: labelSel [

	^ self new
		on: anObject
		getState: getStateSel
		action: actionSel
		label: labelSel
		menu: nil

]

{ #category : #'instance creation' }
PluggableButtonMorph class >> on: anObject getState: getStateSel action: actionSel label: labelSel menu: menuSel [

	^ self new
		on: anObject
		getState: getStateSel
		action: actionSel
		label: labelSel
		menu: menuSel

]

{ #category : #preferences }
PluggableButtonMorph class >> roundedButtonCorners [
	<preference: 'Rounded Button Corners'
		category: 'windows'
		description: 'If true, pluggable buttons in system windows will be rounded'
		type: #Boolean>
	^ RoundedButtonCorners ifNil: [ true ]
]

{ #category : #preferences }
PluggableButtonMorph class >> roundedButtonCorners: aBoolean [

	| world |
	RoundedButtonCorners := aBoolean.
	world := Project current world.
	world invalidRect: world bounds from: world.
]

{ #category : #preferences }
PluggableButtonMorph class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the button''s border.' }.
		{ #borderWidth. 'Borders'. 'Width of the button''s border.' }.
		{ #borderStyle. 'Borders'. 'Whether to use a plain border, inset, or outset.' }.
		{ #color. 'Colors'. 'Background color of the button.' }.

		{ #font. 'Fonts'. 'Font for button title.' }.
		{ #textColor. 'Colors'. 'Color for the button title label.' }.
	}
]

{ #category : #accessing }
PluggableButtonMorph >> action: aSymbol [ 
	"Set actionSelector to be the action defined by aSymbol."

	actionSelector := aSymbol.

]

{ #category : #accessing }
PluggableButtonMorph >> actionSelector [
	"Answer the receiver's actionSelector"

	^ actionSelector
]

{ #category : #accessing }
PluggableButtonMorph >> actionSelector: aSymbol [ 
	"Set actionSelector to be the action defined by aSymbol."

	actionSelector := aSymbol.

]

{ #category : #updating }
PluggableButtonMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self setDefaultParameters.
]

{ #category : #arguments }
PluggableButtonMorph >> arguments: args [
	"If the receiver takes argument(s) that are static, they can be filled by calling this.  If its argument(s) are to be dynamically determined, then use an argumentProvider and argumentSelector instead"

	arguments := args
]

{ #category : #arguments }
PluggableButtonMorph >> argumentsProvider: anObject argumentsSelector: aSelector [
	"Set the argument provider and selector"

	argumentsProvider := anObject.
	argumentsSelector := aSelector
]

{ #category : #accessing }
PluggableButtonMorph >> askBeforeChanging [

	^ askBeforeChanging

]

{ #category : #accessing }
PluggableButtonMorph >> askBeforeChanging: aBoolean [
	"If this preference is turned on, then give the model an opportunity to ask the user before accepting a change that might cause unaccepted edits to be lost."

	askBeforeChanging := aBoolean.

]

{ #category : #browse }
PluggableButtonMorph >> browseAllImplementorsOfActionSelector [
	SystemNavigation default browseAllImplementorsOf: actionSelector localTo: model class
]

{ #category : #'debug menu' }
PluggableButtonMorph >> browseImplementationOfActionSelector [

	| method |
	method := model class lookupSelector: actionSelector.
	ToolSet browse: method methodClass selector: method selector.
]

{ #category : #'debug menu' }
PluggableButtonMorph >> buildDebugMenu: aHandMorph [
	| aMenu |
	aMenu := super buildDebugMenu: aHandMorph.
	aMenu addLine.
	aMenu add: 'browse action code' translated target: self action: #browseImplementationOfActionSelector.
	aMenu add: 'debug action invocation' translated target: self action: #debugAction.
	^ aMenu
]

{ #category : #'debug menu' }
PluggableButtonMorph >> debugAction [

	(Process
		forBlock: [self performAction]
		runUntil: [:context | context selector = self actionSelector])
			debugWithTitle: ('Debug button action "{1}" in model "{2}"' format: {self label. self target printString}).
]

{ #category : #drawing }
PluggableButtonMorph >> drawLabelOn: aCanvas [

	| fontToUse labelToUse colorToUse labelWidth layoutBounds drawBlock |
	self label ifNil: [^ self].

	layoutBounds := self layoutBounds.
	labelToUse := self label asString.
	fontToUse := self font.
	colorToUse := self textColorToUse.
	
	"Support very narrow buttons. Shrink text to monogram then."
	((layoutBounds width < self labelShrinkThreshold
		and: [self hResizing ~~ #shrinkWrap])
		and: [labelToUse size > 3]) ifTrue: [
			labelToUse := labelToUse first asString. "Show first character only."
			fontToUse := fontToUse emphasized: (TextEmphasis bold) emphasisCode].
	
	labelWidth := fontToUse widthOfString: labelToUse.

	drawBlock := [:c | c
			drawString: labelToUse
			at: (layoutBounds center x - (labelWidth // 2) max: (layoutBounds left)) 
				@ (layoutBounds center y - (fontToUse height // 2))
			font: fontToUse
			color: colorToUse].
		
	self clipSubmorphs
		ifTrue: [aCanvas clipBy: layoutBounds during: drawBlock]
		ifFalse: [drawBlock value: aCanvas]
]

{ #category : #drawing }
PluggableButtonMorph >> drawMorphLabelOn: aCanvas [

	| layoutBounds |
	layoutBounds := self layoutBounds.

	self label privateFullMoveBy: (layoutBounds center - self label center).
	
	self clipSubmorphs
		ifTrue: [aCanvas
			clipBy: layoutBounds
			during: [:c | c fullDrawMorph: self label]]
		ifFalse: [aCanvas fullDrawMorph: self label].
]

{ #category : #drawing }
PluggableButtonMorph >> drawOn: aCanvas [ 

	(self fillStyle isColor not and: [self fillStyle isGradientFill])
		ifTrue: [self fillStyle origin: self topLeft; direction: 0@ self height].

	super drawOn: aCanvas.
	
	aCanvas
		translateBy: self labelOffset
		during: [:c |
			self label isMorph
				ifTrue: [self drawMorphLabelOn: c]
				ifFalse: [self drawLabelOn: c]].
]

{ #category : #accessing }
PluggableButtonMorph >> enabled [
	^true
]

{ #category : #accessing }
PluggableButtonMorph >> feedbackColor [
	^ feedbackColor
]

{ #category : #accessing }
PluggableButtonMorph >> feedbackColor: aColor [
	"Set the color of this button's selection feedback border."

	feedbackColor := aColor.
	self changed.

]

{ #category : #accessing }
PluggableButtonMorph >> font [

	^ font ifNil: [Preferences standardButtonFont]
]

{ #category : #accessing }
PluggableButtonMorph >> font: aFont [

	font = aFont ifTrue: [^ self].
	font := aFont.
	
	self updateMinimumExtent.
	self changed.
]

{ #category : #accessing }
PluggableButtonMorph >> getLabelSelector [
	^ getLabelSelector
]

{ #category : #accessing }
PluggableButtonMorph >> getLabelSelector: aSymbol [
	getLabelSelector := aSymbol.
	self update: getLabelSelector.
]

{ #category : #private }
PluggableButtonMorph >> getMenu: shiftPressed [ 
	"Answer the menu for this button, supplying an empty menu to be filled in. If the menu selector takes an extra argument, pass in the current state of the shift key."

	| menu |
	getMenuSelector isNil ifTrue: [^nil].
	menu := MenuMorph new defaultTarget: model.
	getMenuSelector numArgs = 1 
		ifTrue: [^model perform: getMenuSelector with: menu].
	getMenuSelector numArgs = 2 
		ifTrue: 
			[^model 
				perform: getMenuSelector
				with: menu
				with: shiftPressed].
	^self error: 'The getMenuSelector must be a 1- or 2-keyword symbol'
]

{ #category : #private }
PluggableButtonMorph >> getModelState [
	"Answer the result of sending the receiver's model the getStateSelector message."

	^ getStateSelector 
		ifNil: [false]
		ifNotNil: [model perform: getStateSelector]
]

{ #category : #accessing }
PluggableButtonMorph >> getStateSelector [
	^ getStateSelector
]

{ #category : #accessing }
PluggableButtonMorph >> getStateSelector: aSymbol [
	getStateSelector := aSymbol.
	self update: getStateSelector.
]

{ #category : #'layout-properties' }
PluggableButtonMorph >> hResizing: aSymbol [
	"We adapt our minimum extent according to our resize behavior."
	
	self hResizing == aSymbol ifTrue: [^ self].
	super hResizing: aSymbol.
	self updateMinimumExtent.
]

{ #category : #'event handling' }
PluggableButtonMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'event handling' }
PluggableButtonMorph >> handlesMouseOver: evt [

	^ true
]

{ #category : #'event handling' }
PluggableButtonMorph >> handlesMouseOverDragging: evt [

	^ true
]

{ #category : #initialization }
PluggableButtonMorph >> initialize [

	super initialize.

	"Layout properties."
	self
		extent: 20 @ 15;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		layoutInset: (4@0 corner: 4@0);
		clipSubmorphs: true;
		wrapCentering: #center;
		cellPositioning: #topCenter.
	
	"Initialize instance variables."
	model := nil.
	label := nil.
	getStateSelector := nil.
	actionSelector := nil.
	getLabelSelector := nil.
	getMenuSelector := nil.
	shortcutCharacter := nil.
	askBeforeChanging := false.
	triggerOnMouseDown := false.
	allButtons := nil.
	argumentsProvider := nil.
	argumentsSelector := nil.
	
	self setDefaultParameters.

]

{ #category : #private }
PluggableButtonMorph >> invokeMenu: evt [
	"Invoke my menu in response to the given event."
	| menu |
	menu := self getMenu: evt shiftPressed.
	menu ifNotNil: [menu popUpEvent: evt in: self world]
]

{ #category : #accessing }
PluggableButtonMorph >> label [
	"Answer the DisplayObject used as this button's label."

	^ label ifNil: ['']

]

{ #category : #accessing }
PluggableButtonMorph >> label: aStringOrTextOrMorph [

	label = aStringOrTextOrMorph ifTrue: [^ self].
	label := aStringOrTextOrMorph isString
		ifFalse: [aStringOrTextOrMorph asMorph]
		ifTrue: [aStringOrTextOrMorph].
	
	self updateMinimumExtent.
	self changed.
]

{ #category : #accessing }
PluggableButtonMorph >> label: aStringOrTextOrMorph font: aFont [

	self label: aStringOrTextOrMorph.
	self font: aFont.	
]

{ #category : #accessing }
PluggableButtonMorph >> labelOffset [
	^ labelOffset ifNil: [0@0]
]

{ #category : #accessing }
PluggableButtonMorph >> labelOffset: aPoint [
	labelOffset := aPoint.
]

{ #category : #drawing }
PluggableButtonMorph >> labelShrinkThreshold [
	"Determines the minimum width for labels not to be shrunk down to their first character."
	
	^ (self font widthOf: $m)*3
]

{ #category : #accessing }
PluggableButtonMorph >> model [

	^ model
]

{ #category : #accessing }
PluggableButtonMorph >> model: anObject [
	"Set my model and make me me a dependent of the given object."

	model ifNotNil: [model removeDependent: self].
	anObject ifNotNil: [anObject addDependent: self].
	model := anObject.

]

{ #category : #'event handling' }
PluggableButtonMorph >> mouseDown: evt [
	"Details: If this button is triggered on mouse down or the event is the menu gesture, handle it immediately. Otherwise, make a list of buttons (including the receiver) for mouseMove feedback. This allows a simple radio-button effect among the button submorphs of a given morph."

	allButtons := nil.
	evt yellowButtonPressed ifTrue: [^ self invokeMenu: evt].
	triggerOnMouseDown
		ifTrue: [self performAction]
		ifFalse: [
			allButtons := owner submorphs select: [:m | m class = self class].
			self updateFillStyle: evt].

]

{ #category : #'event handling' }
PluggableButtonMorph >> mouseEnter: evt [

	self updateFillStyle: evt.
]

{ #category : #'event handling' }
PluggableButtonMorph >> mouseLeave: evt [

	self updateFillStyle: evt.
]

{ #category : #'event handling' }
PluggableButtonMorph >> mouseLeaveDragging: evt [

	self mouseLeave: evt
]

{ #category : #'event handling' }
PluggableButtonMorph >> mouseMove: evt [

	allButtons ifNil: [^ self].
	allButtons do: [:m | m updateFillStyle: evt].
]

{ #category : #'event handling' }
PluggableButtonMorph >> mouseUp: evt [

	self updateFillStyle: evt.
	
	allButtons ifNil: [^ self].
	allButtons do: [:m |
		(m containsPoint: evt cursorPoint) ifTrue: [m performAction]].
	allButtons := nil.
	self changed.

]

{ #category : #accessing }
PluggableButtonMorph >> offColor [
	^ offColor

]

{ #category : #accessing }
PluggableButtonMorph >> offColor: colorWhenOff [
	"Set the fill colors to be used when this button is off."

	| cc |
	cc := colorWhenOff isTransparent ifTrue: [(Color gray: 0.9) alpha: 0.5] ifFalse: [colorWhenOff].
	self
		onColor: ((self userInterfaceTheme selectionModifier ifNil: [ [:c | c adjustBrightness: -0.2] ]) value: cc)
		offColor: cc

]

{ #category : #initialization }
PluggableButtonMorph >> on: anObject getState: getStateSel action: actionSel label: labelSel menu: menuSel [

	self model: anObject.
	getStateSelector := getStateSel.
	actionSelector := actionSel.
	getLabelSelector := labelSel.
	getMenuSelector := menuSel.
	
	self update: labelSel.
	self update: getStateSel.
	self updateFillStyle.
]

{ #category : #accessing }
PluggableButtonMorph >> onColor: colorWhenOn offColor: colorWhenOff [
	"Set the fill colors to be used when this button is on/off."

	onColor := colorWhenOn.
	offColor := colorWhenOff.
	
	hoverColor := (self userInterfaceTheme hoverModifier ifNil: [ [:c | c adjustBrightness: -0.1] ]) value: offColor.
	feedbackColor := (self userInterfaceTheme feedbackModifier ifNil: [ [:c | c adjustBrightness: -0.3] ]) value: offColor.
	
	self updateFillStyle.
]

{ #category : #accessing }
PluggableButtonMorph >> performAction [
	"Inform the model that this button has been pressed. Sent by the controller when this button is pressed. If the button's actionSelector takes any arguments, they are obtained dynamically by sending the argumentSelector to the argumentsProvider"

	askBeforeChanging ifTrue: [model okToChange ifFalse: [^ self]].
	actionSelector ifNotNil:
		[actionSelector numArgs = 0
			ifTrue:
				[model perform: actionSelector]
			ifFalse:
				[argumentsProvider ifNotNil:
					[arguments := argumentsProvider perform: argumentsSelector].
					model perform: actionSelector withArguments: arguments]]
]

{ #category : #initialization }
PluggableButtonMorph >> setDefaultParameters [
	"change the receiver's appareance parameters"

	self
		color: (self userInterfaceTheme color ifNil: [Color gray: 0.91]);
		borderStyle: (self userInterfaceTheme borderStyle ifNil: [BorderStyle default]) copy;
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color gray]);
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [1]);
		font: (self userInterfaceTheme font ifNil: [TextStyle defaultFont]);
		textColor: (self userInterfaceTheme textColor ifNil: [Color black]).

	borderColor := self borderColor.
	self	offColor: self color.
]

{ #category : #accessing }
PluggableButtonMorph >> shortcutCharacter [
	"Return the Character to be used as a shortcut to turn on this switch, or nil if this switch doesn't have a keyboard shortcut."

	^ shortcutCharacter

]

{ #category : #accessing }
PluggableButtonMorph >> shortcutCharacter: aCharacter [ 
	"Set the character to be used as a keyboard shortcut for turning on this switch."

	shortcutCharacter := aCharacter.

]

{ #category : #accessing }
PluggableButtonMorph >> style [
	"Treat aSymbol as a hint to modify the button appearance."
	^style

]

{ #category : #accessing }
PluggableButtonMorph >> style: aSymbol [
	"Use aSymbol as a hint to modify the button appearance."
	style := aSymbol

]

{ #category : #accessing }
PluggableButtonMorph >> target [

	^ model
]

{ #category : #accessing }
PluggableButtonMorph >> target: anObject [

	self model: anObject.
]

{ #category : #accessing }
PluggableButtonMorph >> textColor [
	^ textColor ifNil: [Color black "old instances"]
]

{ #category : #accessing }
PluggableButtonMorph >> textColor: aColor [
	textColor := aColor.
	self changed.
]

{ #category : #drawing }
PluggableButtonMorph >> textColorToUse [

	^ self textColor
]

{ #category : #accessing }
PluggableButtonMorph >> triggerOnMouseDown [

	^ triggerOnMouseDown

]

{ #category : #accessing }
PluggableButtonMorph >> triggerOnMouseDown: aBoolean [
	"If this preference is turned on, then trigger my action immediately when the mouse goes down."

	triggerOnMouseDown := aBoolean.

]

{ #category : #updating }
PluggableButtonMorph >> update: aParameter [ 

	getLabelSelector ifNotNil: [:sel |
		aParameter == sel ifTrue: [self label: (model perform: sel)]].
	getStateSelector ifNotNil: [:sel |
		aParameter == sel ifTrue: [self updateFillStyle]].
]

{ #category : #updating }
PluggableButtonMorph >> updateFillStyle [

	self
		updateFillStylePressing: false
		hovering: false.
]

{ #category : #updating }
PluggableButtonMorph >> updateFillStyle: evt [

	self
		updateFillStylePressing: (evt redButtonPressed and: [self containsPoint: evt position])
		hovering: (evt redButtonPressed not and: [self containsPoint: evt position]).
]

{ #category : #updating }
PluggableButtonMorph >> updateFillStylePressing: isPressing hovering: isHovering [

	| gradient cc |
	"Migrate old instances."
	hoverColor ifNil: [hoverColor := onColor darker].
	
	self labelOffset: (isPressing ifTrue: [1@1] ifFalse: [0@0]).
	
	self getModelState
		ifTrue: [self color: onColor]
		ifFalse: [self color: offColor].
	self borderStyle color: borderColor.
	
	self wantsGradient ifFalse: [
		isPressing ifTrue: [
			self color: feedbackColor.
			self borderStyle color: feedbackColor muchDarker].
		isHovering ifTrue: [
			self color: hoverColor.
			self borderStyle color: borderColor].
		^ self].
	
	isPressing ifTrue: [
		cc := feedbackColor.
		self borderColor: feedbackColor muchDarker.
		gradient := GradientFillStyle ramp: {
			0.0 -> cc muchDarker.
			0.1-> (cc adjustBrightness: -0.2).
			0.5 -> cc.
			0.9-> (cc adjustBrightness: -0.1).
			1 -> cc muchDarker}].
	isHovering ifTrue: [
		cc := hoverColor.
		gradient := GradientFillStyle ramp: {
			0.0 -> Color white.
			0.1-> (cc adjustBrightness: 0.05).
			0.6 -> (cc darker)}].
	gradient ifNil: [
		cc := self color.
		gradient := GradientFillStyle ramp: {
			0.0 -> Color white.
			0.1-> (cc adjustBrightness: 0.05).
			0.6 -> (cc darker)}].
		
	gradient origin: bounds topLeft.
	gradient direction: 0@self height.
	
	self fillStyle: gradient.
]

{ #category : #layout }
PluggableButtonMorph >> updateMinimumExtent [

	| hMin vMin |
	self label isMorph
		ifTrue: [^ self minimumExtent: self label minExtent].

	hMin := vMin := 0.
	self hResizing ~~ #spaceFill
		ifTrue: [hMin := (self font widthOfString: self label)].
	self vResizing ~~ #spaceFill
		ifTrue: [vMin := self font height].

	hMin := hMin + (2* self borderStyle width).
	vMin := vMin + (2* self borderStyle width).
			
	self layoutInset isRectangle
		ifTrue: [
			hMin := hMin + self layoutInset left + self layoutInset right.
			vMin := vMin + self layoutInset top + self layoutInset bottom]
		ifFalse: [self layoutInset isPoint
			ifTrue: [
				hMin := hMin + (2* self layoutInset x).
				vMin := vMin + (2* self layoutInset y)]
			ifFalse: [
				hMin := hMin + (2* self layoutInset).
				vMin := vMin + (2* self layoutInset)]].
	
	self minimumExtent: hMin @ vMin.

	"Since we have no submorphs, we have to resize here if we want to shrink wrap."
	self hResizing == #shrinkWrap ifTrue: [self width: hMin].
	self vResizing == #shrinkWrap ifTrue: [self height: vMin].
]

{ #category : #'layout-properties' }
PluggableButtonMorph >> vResizing: aSymbol [
	"We adapt our minimum extent according to our resize behavior."
	
	self vResizing == aSymbol ifTrue: [^ self].
	super vResizing: aSymbol.
	self updateMinimumExtent.
]

{ #category : #copying }
PluggableButtonMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
model := deepCopier references at: model ifAbsent: [model].

]

{ #category : #copying }
PluggableButtonMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"model := model.		Weakly copied"
label := label veryDeepCopyWith: deepCopier.
"getStateSelector := getStateSelector.		a Symbol"
"actionSelector := actionSelector.		a Symbol"
"getLabelSelector := getLabelSelector.		a Symbol"
"getMenuSelector := getMenuSelector.		a Symbol"
shortcutCharacter := shortcutCharacter veryDeepCopyWith: deepCopier.
askBeforeChanging := askBeforeChanging veryDeepCopyWith: deepCopier.
triggerOnMouseDown := triggerOnMouseDown veryDeepCopyWith: deepCopier.
offColor := offColor veryDeepCopyWith: deepCopier.
onColor := onColor veryDeepCopyWith: deepCopier.
feedbackColor := feedbackColor veryDeepCopyWith: deepCopier.
hoverColor := hoverColor veryDeepCopyWith: deepCopier.
borderColor := borderColor veryDeepCopyWith: deepCopier.
textColor := textColor veryDeepCopyWith: deepCopier.
labelOffset := labelOffset veryDeepCopyWith: deepCopier.
allButtons := nil.		"a cache"
arguments := arguments veryDeepCopyWith: deepCopier.
argumentsProvider := argumentsProvider veryDeepCopyWith: deepCopier.
"argumentsSelector := argumentsSelector.   a Symbol" 
style := style.  "a Symbol"
]

{ #category : #accessing }
PluggableButtonMorph >> wantsGradient [
	^ wantsGradient ifNil: [self class gradientButton]
]

{ #category : #accessing }
PluggableButtonMorph >> wantsGradient: aBoolean [
	wantsGradient := aBoolean.
	self changed.
]

{ #category : #rounding }
PluggableButtonMorph >> wantsRoundedCorners [
	"If the button is intended to invoke a menu for selection, provide a visual
	distinction by inverting the rounded corners attribute."

	^ (self class roundedButtonCorners or: [super wantsRoundedCorners])
		xor: style == #menuButton
]
