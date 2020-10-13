"
A token representing a single mouse event.  Used in mouse-event sequence editors.
"
Class {
	#name : #MouseEventToken,
	#superclass : #EllipseMorph,
	#instVars : [
		'index',
		'event'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #initialization }
MouseEventToken >> index: anIndex event: anEvent [
	"Given the receiver's index and event, initialize it."

	| aStringMorph |
	index := anIndex.
	event := anEvent.
	self borderWidth: 0.
	self beSticky.
	aStringMorph := StringMorph contents: anIndex printString font: (StrikeFont familyName: 'BitstreamVeraSans' size: 9).
	self extent: (aStringMorph width + 4)  @ (aStringMorph height + 4).
	self addMorphCentered: aStringMorph


]
