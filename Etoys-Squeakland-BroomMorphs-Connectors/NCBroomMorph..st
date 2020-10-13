"
This is a BroomMorph that won't move labels or connectors.
"
Class {
	#name : #NCBroomMorph,
	#superclass : #BroomMorph,
	#category : #'Etoys-Squeakland-BroomMorphs-Connectors'
}

{ #category : #'parts bin' }
NCBroomMorph class >> descriptionForPartsBin [
	^ self partName: 	'Connector Broom' translatedNoop
		categories:		{'Connectors' translatedNoop}
		documentation:	'A broom to align shapes with' translatedNoop
]

{ #category : #'instance creation' }
NCBroomMorph class >> newInHand [
	self new openInHand
]

{ #category : #initialization }
NCBroomMorph >> basicClass [
	^NCBroomMorph
]

{ #category : #initialization }
NCBroomMorph >> resetFilter [

	self filter: [ :m | m isConnector not and: [ m isConstraint not ] ].
]
