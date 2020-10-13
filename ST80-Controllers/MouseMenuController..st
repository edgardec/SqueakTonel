"
I am a Controller that modifies the scheduling of user activities so that the three mouse buttons can be used to make selections or display menus. The menu items are unary messages to the value of sending my instance the message menuMessageReceiver.
"
Class {
	#name : #MouseMenuController,
	#superclass : #Controller,
	#instVars : [
		'redButtonMenu',
		'redButtonMessages'
	],
	#category : #'ST80-Controllers'
}

{ #category : #'menu messages' }
MouseMenuController >> blueButtonActivity [
	"This normally opens the window menu. It is a no-op here
	as only the StandardSystemController deals with that kind
	of menus."
]

{ #category : #'control defaults' }
MouseMenuController >> controlActivity [
	"Refer to the comment in Controller|controlActivity."
	| cursorPoint |
	cursorPoint := sensor cursorPoint.
	super controlActivity.
	(cursorPoint = sensor cursorPoint and: [self viewHasCursor])
		ifTrue: 
			[sensor redButtonPressed ifTrue: [^ self redButtonActivity].
			sensor yellowButtonPressed ifTrue: [^ self yellowButtonActivity].
			sensor blueButtonPressed ifTrue: [^ self blueButtonActivity]]
]

{ #category : #'pluggable menus' }
MouseMenuController >> getPluggableYellowButtonMenu: shiftKeyState [
	^ view getMenu: shiftKeyState
]

{ #category : #'control defaults' }
MouseMenuController >> isControlActive [ 
	"In contrast to class Controller, only blue button but not yellow button
	events will end the receiver's control loop."

	^ self viewHasCursor and: [sensor blueButtonPressed not]
]

{ #category : #'menu messages' }
MouseMenuController >> performMenuMessage: aSelector [
	"Perform a menu command by sending self the message aSelector.
	 Default does nothing special."

	^self perform: aSelector
]

{ #category : #'pluggable menus' }
MouseMenuController >> pluggableYellowButtonActivity: shiftKeyState [
	"Invoke the model's popup menu."

	| menu |
	(menu := self getPluggableYellowButtonMenu: shiftKeyState)
		ifNil:
			[sensor waitNoButton]
		ifNotNil:
			[self terminateAndInitializeAround:
				[menu invokeOn: model orSendTo: self]]
]

{ #category : #'menu messages' }
MouseMenuController >> redButtonActivity [
	"Determine which item in the red button pop-up menu is selected. If one 
	is selected, then send the corresponding message to the object designated 
	as the menu message receiver."

	| index |
	redButtonMenu ~~ nil
		ifTrue: 
			[index := redButtonMenu startUp.
			index ~= 0 
				ifTrue: [self perform: (redButtonMessages at: index)]]
		ifFalse: [super controlActivity]
]

{ #category : #'menu setup' }
MouseMenuController >> redButtonMenu: aSystemMenu redButtonMessages: anArray [ 
	"Initialize the pop-up menu that should appear when the user presses the 
	red mouse button to be aSystemMenu. The corresponding messages that 
	should be sent are listed in the array, anArray."

	redButtonMenu release.
	redButtonMenu := aSystemMenu.
	redButtonMessages := anArray
]

{ #category : #'initialize-release' }
MouseMenuController >> release [
	super release.
	redButtonMenu release
]

{ #category : #'initialize-release' }
MouseMenuController >> reset [
	"Eliminate references to all mouse button menus."

	redButtonMenu := nil.
	redButtonMessages := nil
]

{ #category : #'pluggable menus' }
MouseMenuController >> shiftedTextPaneMenuRequest [
	"The user chose the more... branch from the text-pane menu."

	^ self pluggableYellowButtonActivity: true
]

{ #category : #'pluggable menus' }
MouseMenuController >> shiftedYellowButtonActivity [
	"Invoke the model's special popup menu."

	^ self pluggableYellowButtonActivity: true
]

{ #category : #'pluggable menus' }
MouseMenuController >> unshiftedYellowButtonActivity [
	"Invoke the model's normal popup menu."

	^ self pluggableYellowButtonActivity: false
]

{ #category : #'menu messages' }
MouseMenuController >> yellowButtonActivity [
	"This normally opens a popup menu. Determine the selected
	item and, if one is selected, then send the corresponding message
	to either the model or the receiver."

	^ self pluggableYellowButtonActivity: sensor leftShiftDown
]
