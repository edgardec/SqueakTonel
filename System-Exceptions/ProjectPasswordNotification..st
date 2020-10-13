Class {
	#name : #ProjectPasswordNotification,
	#superclass : #Notification,
	#category : #'System-Exceptions'
}

{ #category : #handling }
ProjectPasswordNotification >> defaultAction [

	self resume: ''
]
