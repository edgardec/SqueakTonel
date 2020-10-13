Class {
	#name : #SimpleButtonDelayedMenuMorph,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'didMenu'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'event handling' }
SimpleButtonDelayedMenuMorph >> handlesMouseStillDown: evt [

	^true
]

{ #category : #'event handling' }
SimpleButtonDelayedMenuMorph >> mouseDown: evt [

	didMenu := nil.
	super mouseDown: evt.

]

{ #category : #'event handling' }
SimpleButtonDelayedMenuMorph >> mouseStillDown: evt [
	(mouseDownTime isNil or: [(Time millisecondClockValue - mouseDownTime) abs < 1000]) ifTrue: [
		^super mouseStillDown: evt
	].
	didMenu ifNotNil: [^super mouseStillDown: evt].
	self color: oldColor.		"in case menu never returns"
	didMenu := target showMenuFor: actionSelector event: evt.

]

{ #category : #'event handling' }
SimpleButtonDelayedMenuMorph >> mouseUp: evt [

	didMenu == true ifFalse: [^super mouseUp: evt].
	oldColor ifNotNil: [
		self color: oldColor.
		oldColor := nil
	].
]
