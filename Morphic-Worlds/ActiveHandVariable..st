Class {
	#name : #ActiveHandVariable,
	#superclass : #DynamicVariable,
	#category : #'Morphic-Worlds'
}

{ #category : #accessing }
ActiveHandVariable class >> default [

	^ self currentWorld primaryHand
]

{ #category : #accessing }
ActiveHandVariable class >> value: anObject during: aBlock [
	"For backword compatibility with 5.3 and earlier, still maintain the original global variable."
	
	| priorHand |
	priorHand := self value.
	ActiveHand := anObject.
	^ [super value: anObject during: aBlock] ensure: [
		ActiveHand == anObject ifTrue: [ActiveHand := priorHand]]
]
