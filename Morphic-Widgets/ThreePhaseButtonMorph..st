"
A button morph with separate images for on, off, and pressed with the mouse. 

When the event actWhen occurs, send actionSelector with 'arguments' to target.  For other events, default to my eventHandler.  The current event is not supplied in the arguments to the actionSelector.  

image (a.k.a. onImage) may not be nil.  offImage and pressedImage may be nil.  nil there means be transparent and show the underlying object.  

Tools for debugging:
Display the images momentarily under program control (for positioning) (self is an instance).
	self state: #on.  self state: #off.
	self state: #pressed.  self state: #off.
Display a rectangle where the button is.
	Display fillWithColor: bounds + (self world viewBox origin).
	self invalidRect: bounds.
"
Class {
	#name : #ThreePhaseButtonMorph,
	#superclass : #ImageMorph,
	#instVars : [
		'offImage',
		'pressedImage',
		'state',
		'target',
		'actionSelector',
		'arguments',
		'actWhen',
		'label',
		'font',
		'textColor'
	],
	#classVars : [
		'AuthorModeOwner'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'instance creation' }
ThreePhaseButtonMorph class >> checkBox [
	"Answer a button pre-initialized with checkbox images."
	| f |
	^self new
		onImage: (f := (MenuIcons checkBoxOn dyed: Color red) scaleIconToDisplay);
		pressedImage: (MenuIcons checkBoxPressed dyed: Color black) scaleIconToDisplay;
		offImage: (MenuIcons checkBoxOff dyed: Color black) scaleIconToDisplay;
		extent: f extent + (2@0);
		setDefaultParameters;
		yourself

]

{ #category : #'class initialization' }
ThreePhaseButtonMorph class >> initialize [
	"ThreePhaseButtonMorph initialize"
	| extent inset |
	extent := 12@12.
	inset := 3.

	#('CheckBoxOff' 'CheckBoxOn' 'CheckBoxPressed') do: [:button |
		| f r |
		f := ColorForm extent: extent depth: 1.
		f colors: {Color transparent. Color black}.
		f borderWidth: 1.
		r := f boundingBox insetBy: inset.
		button = 'CheckBoxPressed' ifTrue: [f border: r width: 1].
		button = 'CheckBoxOn' ifTrue: [f fillBlack: r].
		ScriptingSystem saveForm: f atKey: button].

	#('RadioButtonOff' 'RadioButtonOn' 'RadioButtonPressed') do: [:button |
		| f r c |
		f := ColorForm extent: extent depth: 1.
		f colors: {Color transparent. Color black}.
		r := f boundingBox.
		c := f getCanvas.
		c frameOval: r color: Color black.
		r := r insetBy: inset.
		button = 'RadioButtonPressed' ifTrue:
			[c frameOval: r color: Color black].
		button = 'RadioButtonOn' ifTrue:
			[c fillOval: r color: Color black].
		ScriptingSystem saveForm: f atKey: button]
]

{ #category : #'instance creation' }
ThreePhaseButtonMorph class >> radioButton [
	"Answer a button pre-initialized with radiobutton images."
	| f |
	^self new
		onImage: (f := (MenuIcons radioButtonOn dyed: Color black) scaleIconToDisplay);
		pressedImage: (MenuIcons radioButtonPressed dyed: Color black) scaleIconToDisplay;
		offImage: (MenuIcons radioButtonOff dyed: Color black) scaleIconToDisplay;
		extent: f extent + (2@0);
		setDefaultParameters;
		yourself

]

{ #category : #preferences }
ThreePhaseButtonMorph class >> themeProperties [

	^ super themeProperties, {
		{ #color. 'Colors'. 'Color of the button.' }.
		{ #font. 'Fonts'. 'Font for button title.' }.
		{ #textColor. 'Colors'. 'Color for the button title label.' }.
	}
]

{ #category : #'submorphs-add\/remove' }
ThreePhaseButtonMorph >> actWhen: condition [
	"Accepts symbols:  #buttonDown, #buttonUp, and #whilePressed"
	actWhen := condition
]

{ #category : #accessing }
ThreePhaseButtonMorph >> actionSelector [

	^ actionSelector

]

{ #category : #accessing }
ThreePhaseButtonMorph >> actionSelector: aSymbolOrString [

	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^ actionSelector := nil].

	actionSelector := aSymbolOrString asSymbol.

]

{ #category : #updating }
ThreePhaseButtonMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self setDefaultParameters.
]

{ #category : #accessing }
ThreePhaseButtonMorph >> arguments [
	^ arguments
]

{ #category : #accessing }
ThreePhaseButtonMorph >> arguments: aCollection [

	arguments := aCollection asArray copy.

]

{ #category : #accessing }
ThreePhaseButtonMorph >> color: c [
	
	self onImage ifNotNil: [:form |
		self onImage: ((form asFormOfDepth: 32) collectColors: [:col | c alpha: col alpha])].
	self offImage ifNotNil: [:form |
		self offImage: ((form asFormOfDepth: 32) collectColors: [:col | c alpha: col alpha])].
	self pressedImage ifNotNil: [:form |
		self pressedImage: ((form asFormOfDepth: 32) collectColors: [:col | c alpha: col alpha])].
	
	^ super color: c
]

{ #category : #accessing }
ThreePhaseButtonMorph >> currentImage [

	state == #off ifTrue: [^ offImage].
	state == #pressed ifTrue: [^ pressedImage].
	state == #on ifTrue: [^ image].
	^ image
]

{ #category : #button }
ThreePhaseButtonMorph >> doButtonAction [
	"Perform the action of this button. Subclasses may override this method. The default behavior is to send the button's actionSelector to its target object with its arguments."

	| args |
	(target notNil and: [actionSelector notNil]) ifTrue: [
		args := actionSelector numArgs > arguments size
			ifTrue: [arguments copyWith: self currentEvent]
			ifFalse: [arguments].
		Cursor normal showWhile: [
			target perform: actionSelector withArguments: args].
		target isMorph ifTrue: [target changed]].
]

{ #category : #'event handling' }
ThreePhaseButtonMorph >> doButtonAction: evt [
	
	"Perform the action of this button. Subclasses may override this method. The default behavior is to send the button's actionSelector to its target object with its arguments."

	target ifNil: [^self].
	actionSelector ifNil: [^self].
	Cursor normal showWhile: [ | moreArgs |
		moreArgs := actionSelector numArgs > arguments size ifTrue: [
			arguments copyWith: evt
		] ifFalse: [
			arguments
		].
		target perform: actionSelector withArguments: moreArgs
	]
]

{ #category : #drawing }
ThreePhaseButtonMorph >> drawOn: aCanvas [

	| imageToUse |
	
	imageToUse := self currentImage.
	
	imageToUse ifNotNil: [aCanvas translucentImage: imageToUse at: bounds origin].	
	
	self label ifNotNil: [:lbl |
		aCanvas
			drawString: lbl
			at: bounds origin + (imageToUse ifNil: [0@0] ifNotNil: [:form | (form width @ 0) + (3@0)])
			font: self font
			color: self textColor].
]

{ #category : #geometry }
ThreePhaseButtonMorph >> extent: aPoint [
	"Do it normally"
	
	self changed.
	bounds := bounds topLeft extent: aPoint.
	self layoutChanged.
	self changed.

]

{ #category : #accessing }
ThreePhaseButtonMorph >> font [
	^ font ifNil: [TextStyle defaultFont]
]

{ #category : #accessing }
ThreePhaseButtonMorph >> font: aFont [
	font := aFont.
	super extent: self preferredExtent.
]

{ #category : #'event handling' }
ThreePhaseButtonMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'event handling' }
ThreePhaseButtonMorph >> handlesMouseStillDown: evt [
	^actWhen == #whilePressed
]

{ #category : #initialization }
ThreePhaseButtonMorph >> initialize [
	super initialize.
	state := #off.
	target := nil.
	actionSelector := #flash.
	arguments := Array empty.
	actWhen := #buttonUp

	"self on: #mouseStillDown send: #dragIfAuthoring: to: self."
		"real move should include a call on dragIfAuthoring: "
]

{ #category : #testing }
ThreePhaseButtonMorph >> isOn [
	^ state == #on
]

{ #category : #accessing }
ThreePhaseButtonMorph >> label [
	^ label
]

{ #category : #accessing }
ThreePhaseButtonMorph >> label: aString [
	label := aString.
	super extent: self preferredExtent.
]

{ #category : #'event handling' }
ThreePhaseButtonMorph >> mouseDown: evt [
	| now dt |
	actWhen == #buttonDown
		ifTrue: [self doButtonAction].
	actWhen == #buttonUp
		ifTrue: [self state: #pressed].
	actWhen == #whilePressed
		ifTrue: 
			[self state: #pressed.
			now := Time millisecondClockValue.
			"Allow on:send:to: to set the response to events other than actWhen"
			dt := Time millisecondClockValue - now max: 0.  "Time it took to do"
			"NOTE: this delay is temporary disabled because it makes event reaction delay,
				e.g. the action is not stopped even if you release the button... - Takashi" 
			[dt < 200 ifTrue: [(Delay forMilliseconds: 200-dt) wait]].
			self mouseStillDown: evt].
	super mouseDown: evt
]

{ #category : #'event handling' }
ThreePhaseButtonMorph >> mouseMove: evt [ 
	(#(#buttonUp #whilePressed ) includes: actWhen)
		ifTrue: [(self containsPoint: evt cursorPoint)
				ifTrue: [self state: #pressed]
				ifFalse: [self state: #off]].
	super mouseMove: evt
]

{ #category : #'event handling' }
ThreePhaseButtonMorph >> mouseStillDown: evt [
	actWhen == #whilePressed ifFalse:[^self].
	(self containsPoint: evt cursorPoint) ifTrue:[self doButtonAction].
]

{ #category : #'event handling' }
ThreePhaseButtonMorph >> mouseUp: evt [ 
	"Allow on:send:to: to set the response to events other than actWhen"
	actWhen == #buttonDown
		ifTrue: [super mouseUp: evt].
	actWhen == #buttonUp
		ifTrue: [(self containsPoint: evt cursorPoint)
				ifTrue: [self state: #on.
					self doButtonAction: evt.
					super mouseUp: evt]
				ifFalse: [self state: #off.
					target
						ifNotNil: ["Allow owner to keep it selected for radio
							buttons"
							target mouseUpBalk: evt]]].
	actWhen == #whilePressed
		ifTrue: [self state: #off.
			super mouseUp: evt]
]

{ #category : #accessing }
ThreePhaseButtonMorph >> offImage [
	^ offImage
]

{ #category : #accessing }
ThreePhaseButtonMorph >> offImage: aForm [
	offImage := aForm.
	self invalidRect: self bounds.
]

{ #category : #accessing }
ThreePhaseButtonMorph >> onImage [
	^ image
]

{ #category : #accessing }
ThreePhaseButtonMorph >> onImage: aForm [
	image := aForm.
	self invalidRect: self bounds.
]

{ #category : #accessing }
ThreePhaseButtonMorph >> preferredExtent [

	| iw ih lw lh |
	self currentImage ifNil: [^ 1@1].
	iw := self currentImage width.
	ih := self currentImage height.
	lw := self font widthOfString: (self label ifNil: ['']).
	lh := self font height.
	^ (iw + 3 + lw) @ (ih max: lh)
]

{ #category : #accessing }
ThreePhaseButtonMorph >> pressedImage [
	^ pressedImage
]

{ #category : #accessing }
ThreePhaseButtonMorph >> pressedImage: aForm [
	pressedImage := aForm.
	self invalidRect: self bounds.
]

{ #category : #printing }
ThreePhaseButtonMorph >> printOn: aStream [ 
	| string |
	aStream nextPutAll: '3PButton'.
	arguments notEmpty 
		ifTrue: [string := arguments at: (2 min: arguments size)].
	aStream nextPutAll: '('.
	(string notNil and: [string ~~ self]) 
		ifTrue: 
			[aStream
				print: string;
				space]
		ifFalse: 
			[aStream
				print: actionSelector;
				space].
	aStream
		print: self identityHash;
		nextPutAll: ')'
]

{ #category : #initialization }
ThreePhaseButtonMorph >> setDefaultParameters [

	self
		color: (self userInterfaceTheme color ifNil: [Color black]);
		font: (self userInterfaceTheme font ifNil: [TextStyle defaultFont]);
		textColor: (self userInterfaceTheme textColor ifNil: [Color black]).
]

{ #category : #accessing }
ThreePhaseButtonMorph >> state: newState [
	"Change the image and invalidate the rect."

	newState == state ifTrue: [^ self].
	state := newState.
	self invalidRect: bounds.	"All three images must be the same size"
]

{ #category : #'stepping and presenter' }
ThreePhaseButtonMorph >> step [
	(self hasProperty: #doesButtonAction) ifTrue:[
		self doButtonAction.
		self setProperty: #didButtonAction toValue: true.
	].
]

{ #category : #'stepping and presenter' }
ThreePhaseButtonMorph >> stepTime [
	(self hasProperty: #doesButtonAction) ifTrue:[^1].
	^super stepTime
]

{ #category : #accessing }
ThreePhaseButtonMorph >> target [

	^ target

]

{ #category : #accessing }
ThreePhaseButtonMorph >> target: anObject [

	target := anObject

]

{ #category : #accessing }
ThreePhaseButtonMorph >> textColor [
	^ textColor ifNil: [Color black]
]

{ #category : #accessing }
ThreePhaseButtonMorph >> textColor: aColor [
	textColor := aColor.
]

{ #category : #copying }
ThreePhaseButtonMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].
arguments := arguments collect: [:each |
	deepCopier references at: each ifAbsent: [each]].

]

{ #category : #copying }
ThreePhaseButtonMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
offImage := offImage veryDeepCopyWith: deepCopier.
pressedImage := pressedImage veryDeepCopyWith: deepCopier.
state := state veryDeepCopyWith: deepCopier.
"target := target.		Weakly copied"
"actionSelector := actionSelector.		Symbol"
"arguments := arguments.		Weakly copied"
actWhen := actWhen.		"Symbol"
]

{ #category : #'stepping and presenter' }
ThreePhaseButtonMorph >> wantsSteps [
	^(self hasProperty: #doesButtonAction) or:[super wantsSteps]
]
