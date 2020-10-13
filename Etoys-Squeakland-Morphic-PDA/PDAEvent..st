"
See PDA comment. 
"
Class {
	#name : #PDAEvent,
	#superclass : #PDARecord,
	#instVars : [
		'date',
		'time',
		'duration',
		'alarm'
	],
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #comparing }
PDAEvent >> <= other [ 
	date = other date ifFalse: [^date < other date].
	time isNil ifTrue: [^true].
	other time isNil ifTrue: [^false].
	^time <= other time
]

{ #category : #'as text' }
PDAEvent >> asListItem [

	| timeString ampm |
	time ifNil: [^ '-- ' , (description copyUpTo: Character cr) , ' --'].
	timeString := time printString.
	ampm := timeString last: 2.
	^ (timeString allButLast: 3) , ampm , '  ' , (description copyUpTo: Character cr)
]

{ #category : #date }
PDAEvent >> date [
	"Return the value of date"
	^ date
]

{ #category : #date }
PDAEvent >> date: newValue [
	"Assign newValue to date."

	date := newValue.
]

{ #category : #duration }
PDAEvent >> duration [
	"Return the value of duration"
	^ duration
]

{ #category : #duration }
PDAEvent >> duration: newValue [
	"Assign newValue to duration."

	duration := newValue.
]

{ #category : #date }
PDAEvent >> matchesDate: aDate [

	^ date = aDate
]

{ #category : #time }
PDAEvent >> time [
	"Return the value of time"
	^ time
]

{ #category : #time }
PDAEvent >> time: newValue [
	"Assign newValue to time."

	time := newValue
]
