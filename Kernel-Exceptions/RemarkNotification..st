Class {
	#name : #RemarkNotification,
	#superclass : #Notification,
	#category : #'Kernel-Exceptions'
}

{ #category : #'priv handling' }
RemarkNotification >> defaultAction [

	Transcript showln: self messageText.
]
