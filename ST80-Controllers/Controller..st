"
A Controller coordinates a View, its model, and user actions. It provides scheduling (control) behavior to determine when the user wants to communicate with the model or view.
"
Class {
	#name : #Controller,
	#superclass : #Object,
	#instVars : [
		'model',
		'view',
		'sensor',
		'deferredActionQueue',
		'lastActivityTime'
	],
	#classVars : [
		'MinActivityLapse'
	],
	#category : #'ST80-Controllers'
}

{ #category : #initialization }
Controller class >> initialize [
	"Controller initialize"
	self minActivityLapse: 10.
]

{ #category : #initialization }
Controller class >> minActivityLapse: milliseconds [
	"minimum time to delay between calls to controlActivity"
	MinActivityLapse := milliseconds ifNotNil: [ milliseconds rounded ].
]

{ #category : #cursor }
Controller >> centerCursorInView [
	"Position sensor's mousePoint (which is assumed to be connected to the 
	cursor) to the center of its view's inset display box (see 
	Sensor|mousePoint: and View|insetDisplayBox)."

	^sensor cursorPoint: view insetDisplayBox center
]

{ #category : #'as yet unclassified' }
Controller >> closeAndUnscheduleNoTerminate [

]

{ #category : #'control defaults' }
Controller >> controlActivity [
	"Pass control to the next control level (that is, to the Controller of a 
	subView of the receiver's view) if possible. It is sent by 
	Controller|controlLoop each time through the main control loop. It should 
	be redefined in a subclass if some other action is needed."

	self processDeferredActions.
	self controlToNextLevel
]

{ #category : #'basic control sequence' }
Controller >> controlInitialize [
	"Sent by Controller|startUp as part of the standard control sequence, it 
	provides a place in the standard control sequence for initializing the 
	receiver (taking into account the current state of its model and view). It 
	should be redefined in subclasses to perform some specific action."

	^self
]

{ #category : #'basic control sequence' }
Controller >> controlLoop [ 
	"Sent by Controller|startUp as part of the standard control sequence. 
	Controller|controlLoop sends the message Controller|isControlActive to test 
	for loop termination. As long as true is returned, the loop continues. 
	When false is returned, the loop ends. Each time through the loop, the 
	message Controller|controlActivity is sent."

	[self interActivityPause. self isControlActive] whileTrue: [
		self controlActivity. Processor yield]
]

{ #category : #'basic control sequence' }
Controller >> controlTerminate [
	"Provide a place in the standard control sequence for terminating the 
	receiver (taking into account the current state of its model and view). It 
	should be redefined in subclasses to perform some specific action."

	^self
]

{ #category : #'control defaults' }
Controller >> controlToNextLevel [
	"Pass control to the next control level (that is, to the Controller of a 
	subView of the receiver's view) if possible. The receiver finds the 
	subView (if any) of its view whose inset display box (see 
	View|insetDisplayBox) contains the sensor's cursor point. The Controller 
	of this subView is then given control if it answers true in response to 
	the message Controller|isControlWanted."

	| aView |
	aView := view subViewWantingControl.
	aView ~~ nil ifTrue: [aView controller startUp]
]

{ #category : #'basic control sequence' }
Controller >> deferredActionQueue [

	^deferredActionQueue ifNil: [deferredActionQueue := SharedQueue new]
]

{ #category : #'initialize-release' }
Controller >> initialize [
	"Initialize the state of the receiver. Subclasses should include 'super 
	initialize' when redefining this message to insure proper initialization."

	sensor := EventSensor default
]

{ #category : #'view access' }
Controller >> inspectView [
	view notNil ifTrue: [^ view inspect; yourself]
]

{ #category : #'basic control sequence' }
Controller >> interActivityPause [
	"if we are looping quickly, insert a short delay.  Thus if we are just doing UI stuff, we won't take up much CPU"
	| currentTime wait |
	MinActivityLapse ifNotNil: [
		lastActivityTime ifNotNil: [ 
			currentTime := Time millisecondClockValue.
			wait := lastActivityTime + MinActivityLapse - currentTime.
			wait > 0 ifTrue: [ 
				wait <= MinActivityLapse  "big waits happen after a snapshot"
					ifTrue: [DisplayScreen checkForNewScreenSize.
							(Delay forMilliseconds: wait) wait ]. ]. ]. ].

	lastActivityTime := Time millisecondClockValue.
]

{ #category : #'control defaults' }
Controller >> isControlActive [
	"Answer whether receiver wishes to continue evaluating its controlLoop 
	method. It is sent by Controller|controlLoop in order to determine when 
	the receiver's control loop should terminate, and should be redefined in 
	a subclass if some special condition for terminating the main control loop 
	is needed."

	^ self viewHasCursor
		and: [sensor blueButtonPressed not
		and: [sensor yellowButtonPressed not]]
]

{ #category : #'control defaults' }
Controller >> isControlWanted [
	"Answer whether the cursor is inside the inset display box (see 
	View|insetDisplayBox) of the receiver's view. It is sent by 
	Controller|controlNextLevel in order to determine whether or not control 
	should be passed to this receiver from the Controller of the superView of 
	this receiver's view."

	^self viewHasCursor
]

{ #category : #'model access' }
Controller >> model [
	"Answer the receiver's model which is the same as the model of the 
	receiver's view."

	^model
]

{ #category : #'model access' }
Controller >> model: aModel [ 
	"Controller|model: and Controller|view: are sent by View|controller: in 
	order to coordinate the links between the model, view, and controller. In 
	ordinary usage, the receiver is created and passed as the parameter to 
	View|controller: so that the receiver's model and view links can be set 
	up by the view."

	model := aModel
]

{ #category : #'control defaults' }
Controller >> processDeferredActions [

	Project current isMVC ifFalse: [^ self].
	Project current world processDeferredActions.
]

{ #category : #'initialize-release' }
Controller >> release [
	"Breaks the cycle between the receiver and its view. It is usually not 
	necessary to send release provided the receiver's view has been properly 
	released independently."

	model := nil.
	view ~~ nil
		ifTrue: 
			[view controller: nil.
			view := nil]
]

{ #category : #'sensor access' }
Controller >> sensor [
	"Answer the receiver's sensor. Subclasses may use other objects that are 
	not instances of Sensor or its subclasses if more general kinds of 
	input/output functions are required."

	^sensor
]

{ #category : #'sensor access' }
Controller >> sensor: aSensor [
	"Set the receiver's sensor to aSensor."

	sensor := aSensor
]

{ #category : #'basic control sequence' }
Controller >> startUp [
	"Give control to the receiver. The default control sequence is to initialize 
	(see Controller|controlInitialize), to loop (see Controller|controlLoop), and 
	then to terminate (see Controller|controlTerminate). After this sequence, 
	control is returned to the sender of Control|startUp. The receiver's control 
	sequence is used to coordinate the interaction of its view and model. In 
	general, this consists of polling the sensor for user input, testing the 
	input with respect to the current display of the view, and updating the 
	model to reflect intended changes."

	self controlInitialize.
	self controlLoop.
	self controlTerminate
]

{ #category : #'basic control sequence' }
Controller >> terminateAndInitializeAround: aBlock [
	"1/12/96 sw"
	self controlTerminate.
	aBlock value.
	self controlInitialize
]

{ #category : #'view access' }
Controller >> view [
	"Answer the receiver's view."

	^view
]

{ #category : #'view access' }
Controller >> view: aView [ 
	"Controller|view: and Controller|model: are sent by View|controller: in 
	order to coordinate the links between the model, view, and controller. In 
	ordinary usage, the receiver is created and passed as the parameter to 
	View|controller: and the receiver's model and view links are set up 
	automatically by the view."

	view := aView
]

{ #category : #cursor }
Controller >> viewHasCursor [
	"Answer whether the cursor point of the receiver's sensor lies within the 
	inset display box of the receiver's view (see View|insetDisplayBox). 
	Controller|viewHasCursor is normally used in internal methods."

	^ view ifNotNil: [view containsPoint: sensor cursorPoint] ifNil: [false]
]
