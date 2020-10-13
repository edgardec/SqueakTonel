"
A generalization of the clock morph

Try
	InfoStringMorph new openInWorld
or
	(InfoStringMorph on: [Smalltalk vmParameterAt: 9])
		stepTime: 50;
		openInWorld
"
Class {
	#name : #InfoStringMorph,
	#superclass : #StringMorph,
	#instVars : [
		'stepTime',
		'block'
	],
	#category : #'Etoys-Squeakland-Morphic-Demo'
}

{ #category : #'instance creation' }
InfoStringMorph class >> on: aBlock [
	^ self new block: aBlock
]

{ #category : #accessing }
InfoStringMorph >> block [
	^ block
]

{ #category : #accessing }
InfoStringMorph >> block: aBlock [
	block := aBlock
]

{ #category : #initialization }
InfoStringMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	stepTime := 1000.
	block := [Time now]
]

{ #category : #'stepping and presenter' }
InfoStringMorph >> step [
	self contents: block value asString
]

{ #category : #testing }
InfoStringMorph >> stepTime [
	^ stepTime
]

{ #category : #accessing }
InfoStringMorph >> stepTime: anInteger [
	stepTime := anInteger
]
