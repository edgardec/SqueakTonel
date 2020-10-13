"
I provide a way to override the style of Project entry (which is buried deep in several different methods). My default is a normal full-screen enter.
"
Class {
	#name : #ProjectEntryNotification,
	#superclass : #Notification,
	#instVars : [
		'projectToEnter'
	],
	#category : #'System-Exceptions'
}

{ #category : #exceptionInstantiator }
ProjectEntryNotification class >> signal: aProject [

	| ex |
	ex := self new.
	ex projectToEnter: aProject.
	^ex signal: 'Entering ',aProject printString
]

{ #category : #handling }
ProjectEntryNotification >> defaultAction [

	self resume: projectToEnter enter
]

{ #category : #accessing }
ProjectEntryNotification >> projectToEnter [

	^projectToEnter
]

{ #category : #accessing }
ProjectEntryNotification >> projectToEnter: aProject [

	projectToEnter := aProject
]
