"
This is a example of how to use a morph. It consists of only two 
methods, initialize and step.

DoIt:
MorphExample new openInWorld.




"
Class {
	#name : #MorphExample,
	#superclass : #RectangleMorph,
	#instVars : [
		'phase',
		'ball',
		'star'
	],
	#category : #'Etoys-Squeakland-Morphic-Demo'
}

{ #category : #initialization }
MorphExample >> initialize [
	"initialize the state of the receiver"
	super initialize.
	phase := 1.
	self extent: 200 @ 200.
	ball := EllipseMorph new extent: 30 @ 30.
	self
		addMorph: ((star := StarMorph new extent: 150 @ 150) center: self center)
]

{ #category : #'stepping and presenter' }
MorphExample >> step [
	phase := phase\\8 + 1.
	phase = 1 ifTrue: [^ ball delete].
	phase < 4 ifTrue:[^self].
	phase = 4 ifTrue: [self addMorph: ball].
	ball align: ball center with: (star vertices at: (phase-3*2)).
]
