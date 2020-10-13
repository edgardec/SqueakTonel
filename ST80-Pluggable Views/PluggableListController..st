Class {
	#name : #PluggableListController,
	#superclass : #ListController,
	#instVars : [
		'terminateDuringSelect'
	],
	#category : #'ST80-Pluggable Views'
}

{ #category : #private }
PluggableListController >> changeModelSelection: anInteger [
	"Let the view handle this."

	terminateDuringSelect ifTrue: [self controlTerminate].
	view changeModelSelection: anInteger.
	terminateDuringSelect ifTrue: [self controlInitialize].
]

{ #category : #initialization }
PluggableListController >> initialize [
	super initialize.
	self terminateDuringSelect: false
]

{ #category : #private }
PluggableListController >> processKeyboard [
	sensor keyboardPressed
		ifTrue: [view handleKeystroke: sensor keyboard]
		ifFalse: [super processKeyboard]
]

{ #category : #'control defaults' }
PluggableListController >> redButtonActivity [
	model okToChange   "Don't change selection if model refuses to unlock"
		ifTrue: [^ super redButtonActivity]
]

{ #category : #private }
PluggableListController >> terminateDuringSelect: trueOrFalse [
	terminateDuringSelect := trueOrFalse
]
