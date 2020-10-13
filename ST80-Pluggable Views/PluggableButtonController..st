"
The controller for Buttons.  Not meant to be used with buttons that have mouseOver feeback when the button is not pressed.  Use mouseEnter/mouseLeave for that. 
"
Class {
	#name : #PluggableButtonController,
	#superclass : #Controller,
	#instVars : [
		'selector',
		'arguments',
		'shownAsComplemented'
	],
	#category : #'ST80-Pluggable Views'
}

{ #category : #'control defaults' }
PluggableButtonController >> controlActivity [ 

	shownAsComplemented ifNil: [^ self].
	shownAsComplemented = self viewHasCursor
		ifFalse:
			[view ifNotNil: [view toggleMouseOverFeedback]. 
			shownAsComplemented := shownAsComplemented not]
]

{ #category : #'basic control sequence' }
PluggableButtonController >> controlInitialize [ 
	"Provide feedback indicating that button has been entered with the mouse down. If triggerOnMouseDown is true, then do the button action on mouse down--and don't bother with the feedback since the action happens immediately."

	sensor anyButtonPressed ifFalse: [^ self].
	view triggerOnMouseDown
		ifTrue: [sensor yellowButtonPressed 
			ifTrue: [self yellowButtonActivity]
			ifFalse: [view performAction]]
		ifFalse: [view toggleMouseOverFeedback.
				 shownAsComplemented := true]
]

{ #category : #'basic control sequence' }
PluggableButtonController >> controlTerminate [ 
	"Reverse the feedback displayed by controlInitialize, if any. Perform the button action if necessary."

	view ifNotNil:
		[view triggerOnMouseDown
			ifFalse:
				[shownAsComplemented ifTrue: [view toggleMouseOverFeedback].
				self viewHasCursor ifTrue: [view performAction]]]
]

{ #category : #'control defaults' }
PluggableButtonController >> isControlActive [ 

	^ sensor anyButtonPressed
]

{ #category : #'control defaults' }
PluggableButtonController >> isControlWanted [

	"sensor flushKeyboard."
	self viewHasCursor & sensor anyButtonPressed ifFalse: [^ false].
	view askBeforeChanging
		ifTrue: [^ model okToChange]  "ask before changing"
		ifFalse: [^ true].

]

{ #category : #'button activity' }
PluggableButtonController >> yellowButtonActivity [
	"Invoke the model's menu.  This is option-click, NOT the normal button press."
	| menu |
	menu := view getMenu: false.
	menu == nil
		ifTrue: [sensor waitNoButton]
		ifFalse: [self terminateAndInitializeAround: [menu invokeOn: model]].

]
