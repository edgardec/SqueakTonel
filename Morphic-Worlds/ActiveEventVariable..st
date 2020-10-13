Class {
	#name : #ActiveEventVariable,
	#superclass : #DynamicVariable,
	#category : #'Morphic-Worlds'
}

{ #category : #accessing }
ActiveEventVariable class >> default [

	^ self currentHand ifNotNil: [:hand | hand lastEvent]
]

{ #category : #accessing }
ActiveEventVariable class >> value: anObject during: aBlock [
	"For backword compatibility with 5.3 and earlier, still maintain the original global variable."

	| priorEvent |
	priorEvent := self value.
	ActiveEvent := anObject.
	^ [super value: anObject during: aBlock] ensure: [
		ActiveEvent == anObject ifTrue: [ActiveEvent := priorEvent]]
]
