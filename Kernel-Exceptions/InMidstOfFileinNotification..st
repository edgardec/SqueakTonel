Class {
	#name : #InMidstOfFileinNotification,
	#superclass : #Notification,
	#category : #'Kernel-Exceptions'
}

{ #category : #handling }
InMidstOfFileinNotification >> defaultAction [

	self resume: false
]
