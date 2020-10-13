Class {
	#name : #AlertMorph,
	#superclass : #EllipseMorph,
	#instVars : [
		'onColor',
		'offColor',
		'myObjSock',
		'socketOwner'
	],
	#category : #'Nebraska-Audio Chat'
}

{ #category : #'visual properties' }
AlertMorph >> canHaveFillStyles [
	^false
]

{ #category : #accessing }
AlertMorph >> color: aColor [

	super color: aColor.
	onColor := aColor.
]

{ #category : #initialization }
AlertMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 2
]

{ #category : #initialization }
AlertMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color red
]

{ #category : #initialization }
AlertMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self extent: 25 @ 25.

]

{ #category : #accessing }
AlertMorph >> onColor [
	^onColor ifNil: [onColor := Color green]
]

{ #category : #'as yet unclassified' }
AlertMorph >> socketOwner: aChatGUI [

	socketOwner := aChatGUI.
]

{ #category : #'stepping and presenter' }
AlertMorph >> step [

	super step.
	offColor ifNil: [offColor := self onColor mixed: 0.5 with: Color black].
	socketOwner objectsInQueue = 0 ifTrue: [
		color = offColor ifFalse: [super color: offColor].
	] ifFalse: [
		super color: (color = onColor ifTrue: [offColor] ifFalse: [onColor]).
	].

]

{ #category : #testing }
AlertMorph >> stepTime [
	"Answer the desired time between steps in milliseconds."

	^ 500
]
