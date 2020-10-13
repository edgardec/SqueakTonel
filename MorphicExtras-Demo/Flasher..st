"
A simple example - a circle that flashes.

The ""onColor"" instance variable indicates the color to use when ""on"",  A darker color is used to represent ""off"".

The #step method, called every 500ms. by default, alternatively makes the flasher show its ""on"" and its ""off"" color.
"
Class {
	#name : #Flasher,
	#superclass : #EllipseMorph,
	#instVars : [
		'onColor'
	],
	#category : #'MorphicExtras-Demo'
}

{ #category : #'parts bin' }
Flasher class >> descriptionForPartsBin [
	"Answer a description of the receiver for use in a parts bin"

	^ self partName:	'Flasher' translatedNoop
		categories:		{'Just for Fun' translatedNoop}
		documentation:	'A circle that flashes' translatedNoop
]

{ #category : #'parts bin' }
Flasher >> initializeToStandAlone [
	"Initialize the flasher."

	super initializeToStandAlone.
	self color: Color red.
	self onColor: Color red. 
	self borderWidth: 2.
	self extent: 25@25
]

{ #category : #operations }
Flasher >> onColor [
	"Answer my onColor"

	^ onColor ifNil: [onColor := Color red]
]

{ #category : #operations }
Flasher >> onColor: aColor [
	"Change my on color to be aColor"

	onColor := aColor.
	self color: aColor
]

{ #category : #'stepping and presenter' }
Flasher >> step [
	"Perform my standard periodic action"

	super step.
	self color = self onColor
		ifTrue: [self color: (onColor alphaMixed: 0.5 with: Color black)]
		ifFalse: [self color: onColor]
]

{ #category : #'stepping and presenter' }
Flasher >> stepTime [
	"Answer the desired time between steps, in milliseconds."

	^ 500
]
