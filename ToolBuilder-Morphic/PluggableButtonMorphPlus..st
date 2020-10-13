"
An extended version of PluggableButtonMorph supporting enablement, color and block/message actions.
"
Class {
	#name : #PluggableButtonMorphPlus,
	#superclass : #PluggableButtonMorph,
	#instVars : [
		'enabled',
		'action',
		'getColorSelector',
		'getEnabledSelector',
		'updateMap',
		'disabledColor',
		'disabledTextColor'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #preferences }
PluggableButtonMorphPlus class >> themeProperties [

	^ super themeProperties, {
		{ #disabledColor. 'Colors'. 'Color when button cannot be clicked.' }.
		{ #disabledTextColor. 'Colors'. 'Color for label when button cannot be clicked.' }.
	}
]

{ #category : #accessing }
PluggableButtonMorphPlus >> action [
	^action
]

{ #category : #accessing }
PluggableButtonMorphPlus >> action: anAction [	
	action := nil.
	anAction isSymbol ifTrue:[^super action: anAction].
	action := anAction.
]

{ #category : #updating }
PluggableButtonMorphPlus >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
]

{ #category : #'debug menu' }
PluggableButtonMorphPlus >> browseImplementationOfActionSelector [

	action
		ifNil: [super browseImplementationOfActionSelector]
		ifNotNil: [action homeMethod browse].
]

{ #category : #'debug menu' }
PluggableButtonMorphPlus >> debugAction [

	action ifNil: [^ super debugAction].
	(Process
		forBlock: [self performAction]
		runUntil: [:context | context closure = action])
			debugWithTitle: ('Debug button action "{1}" in model "{2}"' format: {self label. self target printString}).
]

{ #category : #accessing }
PluggableButtonMorphPlus >> enabled [
	^ enabled ifNil: [enabled := true]
]

{ #category : #accessing }
PluggableButtonMorphPlus >> enabled: aBool [
	enabled := aBool.
	self updateFillStyle.
]

{ #category : #accessing }
PluggableButtonMorphPlus >> getColorSelector [
	^getColorSelector
]

{ #category : #accessing }
PluggableButtonMorphPlus >> getColorSelector: aSymbol [
	getColorSelector := aSymbol.
	self update: getColorSelector.
]

{ #category : #accessing }
PluggableButtonMorphPlus >> getEnabledSelector [
	^getEnabledSelector
]

{ #category : #accessing }
PluggableButtonMorphPlus >> getEnabledSelector: aSymbol [
	getEnabledSelector := aSymbol.
	self update: getEnabledSelector.
]

{ #category : #'event handling' }
PluggableButtonMorphPlus >> handlesMouseDown: evt [
	^ enabled
]

{ #category : #'event handling' }
PluggableButtonMorphPlus >> handlesMouseOver: evt [
	^ enabled
]

{ #category : #'event handling' }
PluggableButtonMorphPlus >> handlesMouseOverDragging: evt [
	^ enabled
]

{ #category : #'initialize-release' }
PluggableButtonMorphPlus >> initialize [

	enabled := true.
	super initialize.
]

{ #category : #action }
PluggableButtonMorphPlus >> performAction [
	enabled ifFalse:[^self].
	action ifNotNil:[^action value].
	^super performAction
]

{ #category : #'initialize-release' }
PluggableButtonMorphPlus >> setDefaultParameters [

	disabledColor := (self userInterfaceTheme disabledColor ifNil: [Color transparent]).
	disabledTextColor := (self userInterfaceTheme disabledTextColor ifNil: [Color gray: 0.6]).

	super setDefaultParameters.	
	
]

{ #category : #drawing }
PluggableButtonMorphPlus >> textColorToUse [

	^ self enabled
		ifTrue: [super textColorToUse]
		ifFalse: [disabledTextColor ifNil: [Color gray: 0.6]]
]

{ #category : #updating }
PluggableButtonMorphPlus >> update: what [

	super update: what.
		
	getColorSelector ifNotNil: [:sel |
		what == sel ifTrue: [self offColor: (model perform: sel)]].

	getEnabledSelector ifNotNil: [:sel |
		what == sel ifTrue: [self enabled: (model perform: sel)]].

	updateMap ifNotNil:
		[(updateMap at: what ifAbsent: [])
			ifNotNil: [ :newTarget | self update: newTarget]].

]

{ #category : #'initialize-release' }
PluggableButtonMorphPlus >> updateFillStylePressing: isPressing hovering: isHovering [

	enabled ifFalse: [
		self color: (disabledColor ifNil: [Color transparent]).
		self borderStyle baseColor: disabledTextColor.
		^ self].
	
	super updateFillStylePressing: isPressing hovering: isHovering.
]

{ #category : #updating }
PluggableButtonMorphPlus >> updateMap [
	^ updateMap ifNil: [updateMap := Dictionary new]

]

{ #category : #updating }
PluggableButtonMorphPlus >> whenChanged: notification update: target [
	"On receipt of a notification, such as #contents notification from a CodeHolder,
	invoke an update as if target had been the original notification."

	self updateMap at: notification put: target
]
