Class {
	#name : #ActiveWorldVariable,
	#superclass : #DynamicVariable,
	#category : #'Morphic-Worlds'
}

{ #category : #accessing }
ActiveWorldVariable class >> default [

	^ Project current world
]

{ #category : #accessing }
ActiveWorldVariable class >> value: anObject during: aBlock [
	"For backword compatibility with 5.3 and earlier, still maintain the original global variable."

	| priorWorld |
	priorWorld := self value.
	ActiveWorld := anObject.
	^ [super value: anObject during: aBlock] ensure: [
		ActiveWorld == anObject ifTrue: [ActiveWorld := priorWorld]]
]
