Class {
	#name : #ParserNotification,
	#superclass : #Notification,
	#instVars : [
		'name'
	],
	#category : #'Compiler-Exceptions'
}

{ #category : #'as yet unclassified' }
ParserNotification class >> name: aString [
	^ (self new setName: aString) signal
]

{ #category : #handling }
ParserNotification >> openMenuIn: aBlock [
	self subclassResponsibility
]

{ #category : #private }
ParserNotification >> setName: aString [
	name := aString
]
