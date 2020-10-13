"
A PluggableButtonView is a combination of an indicator for a boolean value stored in its model and an action button. The action of a button is often, but not always, to toggle the boolean value that it shows. Its pluggable selectors are:

		getStateSelector		fetch a boolean value from the model
		actionSelector		invoke this button's action on the model

Either of the above selectors can be nil, meaning that the model does not supply behavior for the given action, and the default behavior should be used. For example, if getStateSelector is nil, then this button shows the state of a read-only boolean that is always false.

The model informs a pluggable view of changes by sending #changed: to itself with getStateSelector as a parameter. The view tells the model when the button is pressed by sending actionSelector.

Options:
	askBeforeChanging		have model ask user before allowing change that could lose edits
	triggerOnMouseDown	do button action on mouse down (vs. up) transition
	shortcutCharacter		a place to record an optional shortcut key


"
Class {
	#name : #PluggableButtonView,
	#superclass : #View,
	#instVars : [
		'label',
		'getStateSelector',
		'actionSelector',
		'getLabelSelector',
		'getMenuSelector',
		'shortcutCharacter',
		'askBeforeChanging',
		'triggerOnMouseDown',
		'complemented',
		'argumentsProvider',
		'argumentsSelector'
	],
	#category : #'ST80-Pluggable Views'
}

{ #category : #example }
PluggableButtonView class >> example [
	"PluggableButtonView example"

	| s1 s2 s3 b1 b2 b3 topView |
	s1 := Switch new.
	s2 := Switch new turnOn.
	s3 := Switch new.
	s2 onAction: [s3 turnOff].
	s3 onAction: [s2 turnOff].
	b1 := (PluggableButtonView on: s1 getState: #isOn action: #switch) label: 'S1'.
	b2 := (PluggableButtonView on: s2 getState: #isOn action: #turnOn) label: 'S2'.
	b3 := (PluggableButtonView on: s3 getState: #isOn action: #turnOn) label: 'S3'.
	b1 borderWidth: 1.
	b2 borderWidth: 1.
	b3 borderWidth: 1.
	topView := StandardSystemView new
		label: 'Switch Test';
		addSubView: b1;
		addSubView: b2 toRightOf: b1;
		addSubView: b3 toRightOf: b2.
	topView controller open.

]

{ #category : #'instance creation' }
PluggableButtonView class >> on: anObject [

	^ self on: anObject getState: #isOn action: #switch

]

{ #category : #'instance creation' }
PluggableButtonView class >> on: anObject getState: getStateSel action: actionSel [

	^ self new
		on: anObject
		getState: getStateSel
		action: actionSel
		label: nil
		menu: nil
]

{ #category : #'instance creation' }
PluggableButtonView class >> on: anObject getState: getStateSel action: actionSel getArguments: getArgumentsSel from: argsProvidor [

	^ self new
		on: anObject
		getState: getStateSel
		action: actionSel
		getArguments: getArgumentsSel
		from: argsProvidor
		label: nil
		menu: nil
]

{ #category : #'instance creation' }
PluggableButtonView class >> on: anObject getState: getStateSel action: actionSel label: labelSel [

	^ self new
		on: anObject
		getState: getStateSel
		action: actionSel
		label: labelSel
		menu: nil
]

{ #category : #'instance creation' }
PluggableButtonView class >> on: anObject getState: getStateSel action: actionSel label: labelSel menu: menuSel [

	^ self new
		on: anObject
		getState: getStateSel
		action: actionSel
		label: labelSel
		menu: menuSel
]

{ #category : #accessing }
PluggableButtonView >> action: aSymbol [ 
	"Set actionSelector to be the action defined by aSymbol."

	actionSelector := aSymbol

]

{ #category : #accessing }
PluggableButtonView >> askBeforeChanging [

	^ askBeforeChanging

]

{ #category : #accessing }
PluggableButtonView >> askBeforeChanging: aBoolean [
	"If this preference is turned on, then give the model an opportunity to ask the user before accepting a change that might cause unaccepted edits to be lost."

	askBeforeChanging := aBoolean.

]

{ #category : #private }
PluggableButtonView >> centerAlignLabelWith: aPoint [
	"Align the center of the label with aPoint."

	| alignPt |
	alignPt := label boundingBox center.
	(label isKindOf: Paragraph) ifTrue: 
		[alignPt := alignPt + (0@(label textStyle leading))]. 
	(label isForm)
	  ifTrue: [label offset: 0 @ 0].
	label align: alignPt with: aPoint

]

{ #category : #private }
PluggableButtonView >> centerLabel [
	"If there is a label, align its center with the center of the insetDisplayBox"

	label ifNotNil: 
		[self centerAlignLabelWith: self insetDisplayBox center].

]

{ #category : #displaying }
PluggableButtonView >> deEmphasizeView [ 

	self getModelState ifTrue: [self displayNormal].

]

{ #category : #'controller access' }
PluggableButtonView >> defaultControllerClass [ 

	^ PluggableButtonController

]

{ #category : #other }
PluggableButtonView >> defaultWindow [
	"Return a rectangle large enough to contain this button's label. If this button is label-less, just return the standard View default window."

	label == nil
		ifTrue: [^ super defaultWindow]
		ifFalse: [^ label boundingBox expandBy: 6].

]

{ #category : #displaying }
PluggableButtonView >> display [
	"Sets the PluggableButtonView mode to 'normal', displays the border, displays the inside and, if its model is 'on', complements the inside."

	self displayBorder.
	self displayView.

]

{ #category : #displaying }
PluggableButtonView >> displayComplemented [
	"Complement the receiver if it isn't already."

	complemented ifFalse: [
		complemented := true.
		Display reverse: self insetDisplayBox].

]

{ #category : #displaying }
PluggableButtonView >> displayNormal [
	"Complement the receiver if its mode is 'complemented'."

	complemented ifTrue: [
		complemented := false.
		Display reverse: self insetDisplayBox].

]

{ #category : #displaying }
PluggableButtonView >> displayView [

	"Displays this switch and its label, if any."

	self clearInside.
	label ifNotNil: [
		(label isKindOf: Paragraph) ifTrue: [
			label foregroundColor: self foregroundColor
				 backgroundColor: self backgroundColor].
		label displayOn: Display
				at: label boundingBox topLeft
				clippingBox: self insetDisplayBox].
	complemented := false.
]

{ #category : #displaying }
PluggableButtonView >> emphasizeView [ 

	self getModelState ifTrue: [self displayComplemented].

]

{ #category : #private }
PluggableButtonView >> getMenu: shiftKeyDown [
	"Answer the menu for this view, supplying an empty menu to be filled in. If the menu selector takes an extra argument, pass in the current state of the shift key."

	| menu |
	getMenuSelector == nil ifTrue: [^ nil].
	menu := CustomMenu new.
	getMenuSelector numArgs = 1
		ifTrue: [^ model perform: getMenuSelector with: menu].
	getMenuSelector numArgs = 2
		ifTrue: [^ model perform: getMenuSelector with: menu with: shiftKeyDown].
	^ self error: 'The getMenuSelector must be a 1- or 2-keyword symbol'

]

{ #category : #private }
PluggableButtonView >> getModelState [
	"Answer the result of sending the receiver's model the getStateSelector message."

	(model isNil or: [getStateSelector isNil])
		ifTrue: [^ false]
		ifFalse: [^ model perform: getStateSelector].

]

{ #category : #'initialize-release' }
PluggableButtonView >> initialize [

 	super initialize.
	label := nil.
	getStateSelector := nil.
	actionSelector := nil.
	getLabelSelector := nil.
	getMenuSelector := nil.
	shortcutCharacter := nil.
	askBeforeChanging := false.
	triggerOnMouseDown := false.
	complemented := false.

]

{ #category : #private }
PluggableButtonView >> insetDisplayBox [
	"Answer the receiver's inset display box. The inset display box is the 
	intersection of the receiver's window, tranformed to display coordinates, 
	and the inset display box of the superView, inset by the border width. 
	The inset display box represents the region of the display screen in 
	which the inside of the receiver (all except the border) is displayed. If 
	the receiver is totally clipped by the display screen and its superView, 
	the resulting Rectangle will be invalid."

	insetDisplayBox ifNil: 
		[insetDisplayBox := self computeInsetDisplayBox.
		 self centerLabel].
	^insetDisplayBox
]

{ #category : #accessing }
PluggableButtonView >> label [
	"Answer the DisplayObject used as this button's label."

	^ label

]

{ #category : #accessing }
PluggableButtonView >> label: aStringOrDisplayObject [ 
	"Label this button with the given String or DisplayObject."

	| fontToUse |
	fontToUse := self userInterfaceTheme font ifNil: [TextStyle defaultFont].
	((aStringOrDisplayObject isKindOf: Paragraph)
	or: [aStringOrDisplayObject isForm])
		ifTrue: [label := aStringOrDisplayObject]
		ifFalse: [label := (Paragraph withText: (aStringOrDisplayObject asText
													addAttribute: (TextFontReference toFont: fontToUse)))].
	self centerLabel.

]

{ #category : #'initialize-release' }
PluggableButtonView >> on: anObject getState: getStateSel action: actionSel getArguments: getArgumentsSel from: argsProvidor label: labelSel menu: menuSel [

	self initialize.
	self model: anObject.
	getStateSelector := getStateSel.
	actionSelector := actionSel.
	argumentsSelector := getArgumentsSel.
	argumentsProvider := argsProvidor.
	getLabelSelector := labelSel.
	getMenuSelector := menuSel
]

{ #category : #'initialize-release' }
PluggableButtonView >> on: anObject getState: getStateSel action: actionSel label: labelSel menu: menuSel [

	self initialize.
	self model: anObject.
	getStateSelector := getStateSel.
	actionSelector := actionSel.
	getLabelSelector := labelSel.
	getMenuSelector := menuSel.
]

{ #category : #other }
PluggableButtonView >> performAction [
	"Inform the model that this button has been pressed. Sent by the controller when this button is pressed."

	argumentsSelector
		ifNil:
			[actionSelector ifNotNil:
				[model perform: actionSelector]]
		ifNotNil:
			[model perform: actionSelector
				withArguments:
					(Array with: (argumentsProvider perform: argumentsSelector))]
]

{ #category : #accessing }
PluggableButtonView >> shortcutCharacter [
	"Return the Character to be used as a shortcut to turn on this switch, or nil if this switch doesn't have a keyboard shortcut."

	^ shortcutCharacter

]

{ #category : #accessing }
PluggableButtonView >> shortcutCharacter: aCharacter [ 
	"Set the character to be used as a keyboard shortcut for turning on this switch."

	shortcutCharacter := aCharacter.

]

{ #category : #displaying }
PluggableButtonView >> toggleMouseOverFeedback [
	"Complement the label (or a portion of the displayBox if no label is defined) to show that the mouse is over this button. This feedback can be removed by a second call to this method."

	Display reverse: self insetDisplayBox fillColor: Color gray.
	Display reverse: (self insetDisplayBox insetBy: 2) fillColor: Color gray.

]

{ #category : #accessing }
PluggableButtonView >> triggerOnMouseDown [

	^ triggerOnMouseDown

]

{ #category : #accessing }
PluggableButtonView >> triggerOnMouseDown: aBoolean [
	"If this preference is turned on, then trigger my action immediately when the mouse goes down."

	triggerOnMouseDown := aBoolean.

]

{ #category : #other }
PluggableButtonView >> update: aParameter [ 

	aParameter == getLabelSelector ifTrue: [
		getLabelSelector ifNotNil: [
			self label: (model perform: getLabelSelector).
			self displayView]].
	self getModelState 
		ifTrue: [self displayComplemented]
		ifFalse: [self displayNormal].

]

{ #category : #other }
PluggableButtonView >> window: aWindow [
	"Center my label when my window changes."

	super window: aWindow.
	self centerLabel.

]
