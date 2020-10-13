Class {
	#name : #MouseOverHandler,
	#superclass : #Object,
	#instVars : [
		'mouseOverMorphs',
		'enteredMorphs',
		'overMorphs',
		'leftMorphs'
	],
	#category : #'Morphic-Events'
}

{ #category : #'initialize-release' }
MouseOverHandler >> initialize [

	mouseOverMorphs := Array new.
	self initializeTrackedMorphs
]

{ #category : #'initialize-release' }
MouseOverHandler >> initializeTrackedMorphs [

	leftMorphs := OrderedCollection new.
	overMorphs := WriteStream on: #().
	enteredMorphs := WriteStream on: #().
]

{ #category : #'event handling' }
MouseOverHandler >> noticeMouseOver: aMorph event: anEvent [
	"Remember that the mouse is currently over some morph"

	leftMorphs remove: aMorph ifAbsent: [
		enteredMorphs nextPut: aMorph ].
	overMorphs nextPut: aMorph.

]

{ #category : #'event handling' }
MouseOverHandler >> processMouseOver: anEvent [ 
	"Re-establish the z-order for all morphs wrt the given event"

	| hand localEvt focus evt |
	anEvent ifNil: [^ self].
	hand := anEvent hand.
	leftMorphs := mouseOverMorphs asIdentitySet.
	"Assume some coherence for the number of objects in over list"
	overMorphs := WriteStream on: (Array new: leftMorphs size).
	enteredMorphs := WriteStream on: #().
	"Now go looking for eventual mouse overs"
	hand handleEvent: anEvent asMouseOver.
	"Get out early if there's no change"
	(leftMorphs isEmpty and: [ enteredMorphs position = 0 ]) 
		ifTrue: [ ^self initializeTrackedMorphs ].
	focus := hand mouseFocus.
	"Send #mouseLeave as appropriate"
	evt := anEvent asMouseLeave.
	"Keep the order of the left morphs by recreating it from the mouseOverMorphs"
	leftMorphs size > 1 
		ifTrue:
			[leftMorphs := mouseOverMorphs select: [:m | leftMorphs includes: m]].
			leftMorphs do: [ :m | 
			(m == focus or: [m hasOwner: focus])
				ifFalse: [ overMorphs nextPut: m ]
				ifTrue: 
					[ localEvt := evt transformedBy: (m transformedFrom: hand).
					m handleEvent: localEvt ] ].
	enteredMorphs ifNil: [ "inform: was called in handleEvent:"
		^self initializeTrackedMorphs ].
	"Send #mouseEnter as appropriate"
	evt := anEvent asMouseEnter.
	enteredMorphs contents reverseDo: [ :m | 
		(m == focus or: [m hasOwner: focus]) ifTrue: [
			localEvt := evt transformedBy: (m transformedFrom: hand).
			m handleEvent: localEvt ] ].
	"And remember the over list"
	overMorphs ifNotNil: [ mouseOverMorphs := overMorphs contents ].
	self initializeTrackedMorphs
]
