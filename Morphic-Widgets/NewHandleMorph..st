Class {
	#name : #NewHandleMorph,
	#superclass : #HandleMorph,
	#instVars : [
		'hand',
		'offset',
		'waitingForClickInside'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'new-morph participation' }
NewHandleMorph class >> includeInNewMorphMenu [
	^ false
]

{ #category : #'submorphs-add\/remove' }
NewHandleMorph >> delete [
	hand ifNotNil:[
		hand showTemporaryCursor: nil.
	].
	super delete.
]

{ #category : #'resize\/collapse' }
NewHandleMorph >> followHand: aHand forEachPointDo: block1 lastPointDo: block2 [
	hand := aHand.
	pointBlock := block1.
	lastPointBlock := block2.
	self position: hand lastEvent cursorPoint - (self extent // 2)
]

{ #category : #'resize\/collapse' }
NewHandleMorph >> followHand: aHand forEachPointDo: block1 lastPointDo: block2 withCursor: aCursor [
	
	hand := aHand.
	hand showTemporaryCursor: aCursor "hotSpotOffset: aCursor offset negated".
	
	color := Color transparent.
	pointBlock := block1.
	lastPointBlock := block2.
	
	self borderWidth: 0.
	self position: hand lastEvent cursorPoint - (self extent // 2)
]

{ #category : #initialization }
NewHandleMorph >> initialize [
"initialize the state of the receiver"

	super initialize.
""
	waitingForClickInside := true.
	Preferences noviceMode
		ifTrue: [self setBalloonText: 'stretch']
]

{ #category : #'dropping\/grabbing' }
NewHandleMorph >> justDroppedInto: aMorph event: anEvent [
	"No dropping behavior because stepping will delete me.
	Moreover it needs to be done that way to evaluate lastPointBlock"

]

{ #category : #'WiW support' }
NewHandleMorph >> morphicLayerNumber [

	^1		"handles are very front-like - e.g. the spawn reframe logic actually asks if the first submorph of the world is one of us before deciding to create one"
]

{ #category : #accessing }
NewHandleMorph >> sensorMode [

	"If our client is still addressing the Sensor directly, we need to do so as well"
	^self valueOfProperty: #sensorMode ifAbsent: [false].

]

{ #category : #accessing }
NewHandleMorph >> sensorMode: aBoolean [

	"If our client is still addressing the Sensor directly, we need to do so as well"
	self setProperty: #sensorMode toValue: aBoolean.

]

{ #category : #'stepping and presenter' }
NewHandleMorph >> step [
	| eventSource |

	eventSource := self sensorMode ifTrue: [
		Sensor
	] ifFalse: [
		hand lastEvent
	].
	eventSource anyButtonPressed
		ifTrue: [waitingForClickInside := false.
				self position: eventSource cursorPoint - (self extent // 2).
				pointBlock value: self center]
		ifFalse: [waitingForClickInside
					ifTrue: [(self containsPoint: eventSource cursorPoint)
								ifFalse: ["mouse wandered out before clicked"
										^ self delete]]
					ifFalse: [lastPointBlock value: self center.
							^ self delete]]
]

{ #category : #'dropping\/grabbing' }
NewHandleMorph >> undoGrabCommand [
	^nil
]
