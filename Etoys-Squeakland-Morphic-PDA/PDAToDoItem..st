"
See PDA comment. 
"
Class {
	#name : #PDAToDoItem,
	#superclass : #PDARecord,
	#instVars : [
		'dayPosted',
		'dayDone',
		'priority',
		'deadline',
		'result'
	],
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #comparing }
PDAToDoItem >> <= other [

	priority = other priority ifFalse: [^ priority < other priority].
	^ super <= other
]

{ #category : #'as text' }
PDAToDoItem >> asListItem [

	^ (priority ifNil: [0]) printString , ' ' , super asListItem
]

{ #category : #'day done' }
PDAToDoItem >> dayDone [
	"Return the value of dayDone"
	^ dayDone
]

{ #category : #'day done' }
PDAToDoItem >> dayDone: newValue [
	"Assign newValue to dayDone."

	dayDone := newValue.
]

{ #category : #'day posted' }
PDAToDoItem >> dayPosted [
	"Return the value of dayPosted"
	^ dayPosted
]

{ #category : #'day posted' }
PDAToDoItem >> dayPosted: newValue [
	"Assign newValue to dayPosted."

	dayPosted := newValue.
]

{ #category : #deadline }
PDAToDoItem >> deadline [
	"Return the value of deadline"
	^ deadline
]

{ #category : #deadline }
PDAToDoItem >> deadline: newValue [
	"Assign newValue to deadline."

	deadline := newValue.
]

{ #category : #'day posted' }
PDAToDoItem >> matchesDate: aDate [

	dayPosted > aDate ifTrue: [^ false].
	dayDone ifNil: [^ true].
	^ dayDone >= aDate
]

{ #category : #priority }
PDAToDoItem >> priority [
	"Return the value of priority"
	^ priority
]

{ #category : #priority }
PDAToDoItem >> priority: newValue [
	"Assign newValue to priority."

	priority := newValue.
]

{ #category : #result }
PDAToDoItem >> result [
	"Return the value of result"
	^ result
]

{ #category : #result }
PDAToDoItem >> result: newValue [
	"Assign newValue to result."

	result := newValue.
]
