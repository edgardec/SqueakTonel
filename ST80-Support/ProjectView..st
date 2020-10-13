"
I am a view of a project. I display a scaled version of the project's thumbnail, which itself is a scaled-down snapshot of the screen taken when the project was last exited.

"
Class {
	#name : #ProjectView,
	#superclass : #StandardSystemView,
	#classVars : [
		'ArmsLengthCmd'
	],
	#category : #'ST80-Support'
}

{ #category : #opening }
ProjectView class >> open: aProject [ 
	"Answer an instance of me for the argument, aProject. It is created on the
	display screen."
	| topView |
	topView := self new model: aProject.
	topView minimumSize: 50 @ 30.
	topView borderWidth: 2.
	topView controller open
]

{ #category : #opening }
ProjectView class >> openAndEnter: aProject [ 
	"Answer an instance of me for the argument, aProject. It is created on 
	the display screen."
	| topView |
	topView := self new model: aProject.
	topView minimumSize: 50 @ 30.
	topView borderWidth: 2.
	topView window: (RealEstateAgent initialFrameFor: topView world: nil).
	ScheduledControllers schedulePassive: topView controller.
	aProject
		enter: false
		revert: false
		saveForRevert: false
]

{ #category : #displaying }
ProjectView >> armsLengthCommand: aCommand [
	"Set up a save to be done after the subproject exits to here.  displayOn: checks it."

	ArmsLengthCmd := aCommand.
]

{ #category : #initialization }
ProjectView >> defaultControllerClass [
	^ ProjectController
]

{ #category : #displaying }
ProjectView >> displayDeEmphasized [
	| cmd |
	"Display this view with emphasis off.  Check for a command that
could not be executed in my subproject.  Once it is done, remove the
trigger."

	super displayDeEmphasized.
	ArmsLengthCmd ifNil: [^ self].
	ArmsLengthCmd first == model ifFalse: [^ self].	"not ours"
	cmd := ArmsLengthCmd second.
	ArmsLengthCmd := nil.
	model "project" perform: cmd.
	model "project" enter.

]

{ #category : #displaying }
ProjectView >> displayView [
	super displayView.
	self label = model name
		ifFalse: [self setLabelTo: model name].
	self isCollapsed ifTrue: [^ self].
	model thumbnail ifNil: [^ self].
	self insetDisplayBox extent = model thumbnail extent
		ifTrue: [model thumbnail displayAt: self insetDisplayBox topLeft]
		ifFalse: [(model thumbnail
					magnify: model thumbnail boundingBox
					by: self insetDisplayBox extent asFloatPoint / model thumbnail extent) 				displayAt: self insetDisplayBox topLeft]

]

{ #category : #initialization }
ProjectView >> maybeRelabel: newLabel [
	"If the change set name given by newLabel is already in use, do nothing; else relabel the view"

	(newLabel isEmpty or: [newLabel = self label])
		ifTrue: [^ self].
	(ChangeSet named: newLabel) == nil
		ifFalse: [^ self].
	self relabel: newLabel
]

{ #category : #initialization }
ProjectView >> relabel: newLabel [
	(newLabel isEmpty or: [newLabel = self label])
		ifTrue: [^ self].
	(ChangeSet named: newLabel) == nil
		ifFalse: [self inform: 'Sorry that name is already used'.
				^ self].
	model projectChangeSet name: newLabel.
	super relabel: newLabel
]

{ #category : #displaying }
ProjectView >> release [
	super release.
	Smalltalk garbageCollect
]

{ #category : #initialization }
ProjectView >> uncacheBits [
	super uncacheBits.
	self label ~=  model name ifTrue: [self setLabelTo: model name]
]
