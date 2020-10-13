Class {
	#name : #OutOfScopeNotification,
	#superclass : #Notification,
	#category : #'Compiler-Exceptions'
}

{ #category : #'as yet unclassified' }
OutOfScopeNotification >> defaultAction [

	self resume: false
]
