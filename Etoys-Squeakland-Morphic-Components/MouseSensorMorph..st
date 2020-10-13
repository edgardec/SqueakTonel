Class {
	#name : #MouseSensorMorph,
	#superclass : #Component,
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #'as yet unclassified' }
MouseSensorMorph class >> includeInNewMorphMenu [
	"Only include instances of subclasses of me"
	^ self ~~ MouseSensorMorph
]

{ #category : #drawing }
MouseSensorMorph >> fullDrawOn: aCanvas [
	self installed ifFalse: [aCanvas drawMorph: self]
]

{ #category : #initialization }
MouseSensorMorph >> initialize [
	super initialize.
	self bounds: (0@0 extent: 20@20)
]

{ #category : #testing }
MouseSensorMorph >> installed [

self halt: 'under construction'
"
	^ (owner ~~ nil) and: [owner isWorldOrHandMorph not]
"
]
