"
ButtonProperties test1

ButtonProperties test2

ButtonProperties test3


"
Class {
	#name : #ButtonProperties,
	#superclass : #Object,
	#instVars : [
		'target',
		'actionSelector',
		'arguments',
		'actWhen',
		'wantsRolloverIndicator',
		'mouseDownTime',
		'nextTimeToFire',
		'visibleMorph',
		'delayBetweenFirings',
		'mouseOverHaloWidth',
		'mouseOverHaloColor',
		'mouseDownHaloWidth',
		'mouseDownHaloColor',
		'stateCostumes',
		'currentLook'
	],
	#category : #'Etoys-Buttons'
}

{ #category : #printing }
ButtonProperties class >> defaultNameStemForInstances [
	^ 'button' translatedNoop
]

{ #category : #'as yet unclassified' }
ButtonProperties class >> ellipticalButtonWithText: aStringOrText [

	| m prop |

	m := EllipseMorph new.
	prop := m ensuredButtonProperties.
	prop
		target: #(1 2 3);
		actionSelector: #inspect;
		actWhen: #mouseUp;
		addTextToButton: aStringOrText;
		wantsRolloverIndicator: true.
	^m
]

{ #category : #'as yet unclassified' }
ButtonProperties class >> test1 [

	| m prop |
	m := EllipseMorph new.
	prop := m ensuredButtonProperties.
	prop
		target: #(1 2 3);
		actionSelector: #inspect;
		actWhen: #mouseUp.
	m openInWorld.
]

{ #category : #'as yet unclassified' }
ButtonProperties class >> test2 [

	(self ellipticalButtonWithText: 'Hello world') openInWorld.
]

{ #category : #'as yet unclassified' }
ButtonProperties class >> test3 [

	| m |

	(m := self ellipticalButtonWithText: 'Hello world') openInWorld.
	m ensuredButtonProperties
		target: Beeper;
		actionSelector: #beep;
		delayBetweenFirings: 1000.
]

{ #category : #accessing }
ButtonProperties >> actWhen [

	^ actWhen
]

{ #category : #accessing }
ButtonProperties >> actWhen: condition [

	(#(buttonDown mouseDown) includes: condition) ifTrue: [ actWhen := #mouseDown ].
	(#(buttonUp mouseUp) includes: condition) ifTrue: [ actWhen := #mouseUp ].
	(#(whilePressed mouseStillDown) includes: condition) ifTrue: [ actWhen := #mouseStillDown ].
	self setEventHandlers: true.
]

{ #category : #accessing }
ButtonProperties >> actionSelector [

	^ actionSelector

]

{ #category : #accessing }
ButtonProperties >> actionSelector: aSymbolOrString [

	aSymbolOrString isEmptyOrNil ifTrue: [^actionSelector := nil].
	aSymbolOrString = 'nil' ifTrue: [^actionSelector := nil].
	actionSelector := aSymbolOrString asSymbol.

]

{ #category : #initialization }
ButtonProperties >> adaptToWorld: aWorld [
	super adaptToWorld: aWorld.
	target := target adaptedToWorld: aWorld.
]

{ #category : #events }
ButtonProperties >> addMouseOverHalo [

	self wantsRolloverIndicator ifTrue: [
		visibleMorph 
			addMouseActionIndicatorsWidth: mouseOverHaloWidth 
			color: mouseOverHaloColor.
	].

]

{ #category : #accessing }
ButtonProperties >> addTextToButton: aStringOrText [

	| tm existing |

	existing := self currentTextMorphsInButton.
	existing do: [ :x | x delete].
	aStringOrText ifNil: [^self].
	tm := TextMorph new contents: aStringOrText.
	tm 
		fullBounds;
		lock;
		align: tm center with: visibleMorph center;
		setProperty: #textAddedByButtonProperties toValue: true;
		setToAdhereToEdge: #center.
	"maybe the user would like personal control here"
	"visibleMorph extent: (tm extent * 1.5) rounded."
	visibleMorph addMorphFront: tm.

]

{ #category : #accessing }
ButtonProperties >> adjustPositionsAfterSizeChange [

	"re-center label, etc??"
]

{ #category : #accessing }
ButtonProperties >> arguments [

	^ arguments

]

{ #category : #accessing }
ButtonProperties >> arguments: aCollection [

	arguments := aCollection asArray copy.

]

{ #category : #accessing }
ButtonProperties >> bringUpToDate [

	self establishEtoyLabelWording

]

{ #category : #accessing }
ButtonProperties >> currentLook [

	^currentLook ifNil: [currentLook := #normal]
]

{ #category : #accessing }
ButtonProperties >> currentTextInButton [

	| existing |

	existing := self currentTextMorphsInButton.
	existing isEmpty ifTrue: [^nil].
	^existing first

]

{ #category : #accessing }
ButtonProperties >> currentTextMorphsInButton [

	^visibleMorph submorphsSatisfying: [ :x | 
		x hasProperty: #textAddedByButtonProperties
	]

]

{ #category : #events }
ButtonProperties >> delayBetweenFirings [

	^delayBetweenFirings
]

{ #category : #events }
ButtonProperties >> delayBetweenFirings: millisecondsOrNil [

	delayBetweenFirings := millisecondsOrNil
]

{ #category : #events }
ButtonProperties >> displayCostume: aSymbol [

	self currentLook == aSymbol ifTrue: [^true].
	self stateCostumes at: aSymbol ifPresent: [ :aForm |
		currentLook := aSymbol.
		visibleMorph wearCostume: aForm.
		^true
	].
	^false

]

{ #category : #events }
ButtonProperties >> doButtonAction [
	
	self doButtonAction: nil
]

{ #category : #events }
ButtonProperties >> doButtonAction: evt [

	target ifNil: [^self].
	actionSelector ifNil: [^self].
	arguments ifNil: [arguments := #()].
	Cursor normal showWhile: [
		| arity |
		arity := actionSelector numArgs.
		arity = arguments size ifTrue: [
			target perform: actionSelector withArguments: arguments
		].
		arity = (arguments size + 1) ifTrue: [
			target perform: actionSelector withArguments: {evt},arguments
		].
		arity = (arguments size + 2) ifTrue: [
			target perform: actionSelector withArguments: {evt. visibleMorph},arguments
		].
	]
]

{ #category : #accessing }
ButtonProperties >> establishEtoyLabelWording [
	"Set the label wording, unless it has already been manually edited"

	| itsName |

	self isTileScriptingElement ifFalse: [^self].
	itsName := target externalName.
	self addTextToButton: itsName, ' ', arguments first.
	visibleMorph setBalloonText: 
		('click to run the script "{1}" in player named "{2}"' translated format: {arguments first. itsName}).

]

{ #category : #accessing }
ButtonProperties >> figureOutScriptSelector [

	self halt
]

{ #category : #initialization }
ButtonProperties >> initialize [

	wantsRolloverIndicator := false.
	delayBetweenFirings := nil.
	mouseOverHaloWidth := 10.
	mouseOverHaloColor := Color blue alpha: 0.3.
	mouseDownHaloWidth := 15.
	mouseDownHaloColor := Color blue alpha: 0.7.
	arguments := #().
]

{ #category : #accessing }
ButtonProperties >> isTileScriptingElement [

	actionSelector == #runScript: ifFalse: [^false].
	arguments isEmptyOrNil ifTrue: [^false].
	^target isPlayerLike
]

{ #category : #accessing }
ButtonProperties >> lockAnyText [

	self currentTextMorphsInButton do: [ :x | x lock: true].
]

{ #category : #events }
ButtonProperties >> mouseDown: evt [

	self displayCostume: #mouseDown.
	mouseDownTime := Time millisecondClockValue.
	nextTimeToFire := nil.
	delayBetweenFirings ifNotNil: [
		nextTimeToFire := mouseDownTime + delayBetweenFirings.
	].
	self wantsRolloverIndicator ifTrue: [
		visibleMorph 
			addMouseActionIndicatorsWidth: mouseDownHaloWidth 
			color: mouseDownHaloColor.
	].
	actWhen == #mouseDown ifFalse: [^self].
	(visibleMorph containsPoint: evt cursorPoint) ifFalse: [^self].
	self doButtonAction: evt.

"=====

	aMorph .

	now := Time millisecondClockValue.
	oldColor := color. 
	actWhen == #buttonDown
		ifTrue: [self doButtonAction]
		ifFalse: [	self updateVisualState: evt; refreshWorld].
	dt := Time millisecondClockValue - now max: 0.
	dt < 200 ifTrue: [(Delay forMilliseconds: 200-dt) wait].
	self mouseStillDown: evt.
====="
]

{ #category : #accessing }
ButtonProperties >> mouseDownHaloColor [

	^mouseDownHaloColor
]

{ #category : #accessing }
ButtonProperties >> mouseDownHaloColor: x [

	mouseDownHaloColor := x
]

{ #category : #accessing }
ButtonProperties >> mouseDownHaloWidth [

	^mouseDownHaloWidth
]

{ #category : #accessing }
ButtonProperties >> mouseDownHaloWidth: x [

	mouseDownHaloWidth := x
]

{ #category : #accessing }
ButtonProperties >> mouseDownLook: aFormOrMorph [

	self setLook: #mouseDown to: aFormOrMorph

]

{ #category : #events }
ButtonProperties >> mouseEnter: evt [

	self displayCostume: #mouseEnter.
	self addMouseOverHalo.

]

{ #category : #accessing }
ButtonProperties >> mouseEnterLook: aFormOrMorph [

	self setLook: #mouseEnter to: aFormOrMorph

]

{ #category : #events }
ButtonProperties >> mouseLeave: evt [

	self displayCostume: #normal.
	visibleMorph deleteAnyMouseActionIndicators.

]

{ #category : #events }
ButtonProperties >> mouseMove: evt [

	actWhen == #mouseDown ifTrue: [^ self].
	self updateVisualState: evt.
]

{ #category : #accessing }
ButtonProperties >> mouseOverHaloColor [

	^mouseOverHaloColor
]

{ #category : #accessing }
ButtonProperties >> mouseOverHaloColor: x [

	mouseOverHaloColor := x
]

{ #category : #accessing }
ButtonProperties >> mouseOverHaloWidth [

	^mouseOverHaloWidth
]

{ #category : #accessing }
ButtonProperties >> mouseOverHaloWidth: x [

	mouseOverHaloWidth := x
]

{ #category : #events }
ButtonProperties >> mouseStillDown: evt [

	(visibleMorph containsPoint: evt cursorPoint) ifFalse: [^self].
	nextTimeToFire ifNil: [^self].
	nextTimeToFire <= Time millisecondClockValue ifTrue: [
		self doButtonAction: evt.
		nextTimeToFire := Time millisecondClockValue + self delayBetweenFirings.
		^self
	].

]

{ #category : #events }
ButtonProperties >> mouseUp: evt [

	(self displayCostume: #mouseEnter) ifFalse: [self displayCostume: #normal].
	self addMouseOverHalo.

]

{ #category : #accessing }
ButtonProperties >> privateSetLook: aSymbol to: aFormOrMorph [ 
	| f |
	f := (aFormOrMorph isForm) 
				ifTrue: [aFormOrMorph]
				ifFalse: [aFormOrMorph imageForm].
	self stateCostumes at: aSymbol put: f
]

{ #category : #events }
ButtonProperties >> replaceVisibleMorph: aNewMorph [

	| old oldOwner oldText |

	old := visibleMorph.
	oldText := self currentTextInButton.
	self visibleMorph: nil.
	old buttonProperties: nil.
	aNewMorph buttonProperties: self.
	self visibleMorph: aNewMorph.
	self addTextToButton: oldText.
	oldOwner := old owner ifNil: [^self].
	oldOwner replaceSubmorph: old by: aNewMorph.
]

{ #category : #menu }
ButtonProperties >> setActWhen [

	| selections |
	selections := #(mouseDown mouseUp mouseStillDown).
	actWhen := UIManager default 
		chooseFrom: (selections collect: [:t | t translated])
		values: selections
		title: 'Choose one of the following conditions' translated.
]

{ #category : #menu }
ButtonProperties >> setActionSelector [

	| newSel |
	newSel := UIManager default
		request:
'Please type the selector to be sent to
the target when this button is pressed' translated
		initialAnswer: actionSelector.
	newSel isEmpty ifFalse: [self actionSelector: newSel].

]

{ #category : #menu }
ButtonProperties >> setArguments [

	| s newArgs newArgsArray |
	s := WriteStream on: ''.
	arguments do: [:arg | arg printOn: s. s nextPutAll: '. '].
	newArgs := UIManager default
		request:
'Please type the arguments to be sent to the target
when this button is pressed separated by periods' translated
		initialAnswer: s contents.
	newArgs isEmpty ifFalse: [
		newArgsArray := Compiler evaluate: '{', newArgs, '}' for: self.
		self arguments: newArgsArray].

]

{ #category : #accessing }
ButtonProperties >> setEventHandlers: enabled [

	enabled ifTrue: [
		visibleMorph on: #mouseDown send: #mouseDown: to: self.
		visibleMorph on: #mouseStillDown send: #mouseStillDown: to: self.
		visibleMorph on: #mouseUp send: #mouseUp: to: self.
		visibleMorph on: #mouseEnter send: #mouseEnter: to: self.
		visibleMorph on: #mouseLeave send: #mouseLeave: to: self.
	] ifFalse: [
		#(mouseDown mouseStillDown mouseUp mouseEnter mouseLeave) do: [ :sel |
			visibleMorph on: sel send: nil to: nil
		].
	].

]

{ #category : #menu }
ButtonProperties >> setLabel [

	| newLabel |
	newLabel := UIManager default
		request:
'Please a new label for this button'
		initialAnswer: self label.
	newLabel isEmpty ifFalse: [self label: newLabel].

]

{ #category : #accessing }
ButtonProperties >> setLook: aSymbol to: aFormOrMorph [

	(self stateCostumes includesKey: #normal) ifFalse: [
		self privateSetLook: #normal to: visibleMorph.
	].
	self privateSetLook: aSymbol to: aFormOrMorph.

]

{ #category : #menu }
ButtonProperties >> setPageSound: event [

	^ target menuPageSoundFor: self event: event
]

{ #category : #menu }
ButtonProperties >> setPageVisual: event [

	^ target menuPageVisualFor: self event: event
]

{ #category : #menu }
ButtonProperties >> setTarget: evt [ 
	| rootMorphs |
	rootMorphs := self world rootMorphsAt: evt targetPoint.
	target := rootMorphs size > 1 
		ifTrue: [rootMorphs second]
		ifFalse: [nil]
]

{ #category : #accessing }
ButtonProperties >> stateCostumes [

	^stateCostumes ifNil: [stateCostumes := Dictionary new]
]

{ #category : #accessing }
ButtonProperties >> target [

	^ target

]

{ #category : #accessing }
ButtonProperties >> target: anObject [

	target := anObject

]

{ #category : #accessing }
ButtonProperties >> unlockAnyText [

	self currentTextMorphsInButton do: [ :x | x lock: false].
]

{ #category : #copying }
ButtonProperties >> updateReferencesUsing: aDictionary [
	"If the arguments array points at a morph we are copying, then point at the new copy.  And also copies the array, which is important!"

	super updateReferencesUsing: aDictionary.
	arguments := arguments collect:
		[:old | aDictionary at: old ifAbsent: [old]].

]

{ #category : #'visual properties' }
ButtonProperties >> updateVisualState: evt [
	
"	oldColor ifNil: [^self].

	self color: 
		((self containsPoint: evt cursorPoint)
			ifTrue: [oldColor mixed: 1/2 with: Color white]
			ifFalse: [oldColor])"
]

{ #category : #copying }
ButtonProperties >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].
arguments := arguments collect: [:each |
	deepCopier references at: each ifAbsent: [each]].

]

{ #category : #copying }
ButtonProperties >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"target := target.		Weakly copied"
"actionSelector := actionSelector.		a Symbol"
"arguments := arguments.		All weakly copied"
actWhen := actWhen veryDeepCopyWith: deepCopier.
"oldColor := oldColor veryDeepCopyWith: deepCopier."
visibleMorph := visibleMorph.	"I guess this will have been copied already if needed"
delayBetweenFirings := delayBetweenFirings.
mouseDownHaloColor := mouseDownHaloColor.
stateCostumes := stateCostumes veryDeepCopyWith: deepCopier.
currentLook := currentLook.
]

{ #category : #accessing }
ButtonProperties >> visibleMorph: x [

	visibleMorph ifNotNil: [self setEventHandlers: false].
	visibleMorph := x.
	visibleMorph ifNotNil: [self setEventHandlers: true].

]

{ #category : #accessing }
ButtonProperties >> wantsRolloverIndicator [

	^wantsRolloverIndicator ifNil: [false]
]

{ #category : #accessing }
ButtonProperties >> wantsRolloverIndicator: aBoolean [

	wantsRolloverIndicator := aBoolean.
	wantsRolloverIndicator ifTrue: [
		self setEventHandlers: true.
	].
]
