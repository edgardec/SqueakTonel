"
I am used to allow the ComplexProgressIndicator one last chance at finding an appropriate place to display. If I am unhandled, then the cursor location and a default rectangle are used.
"
Class {
	#name : #ProgressTargetRequestNotification,
	#superclass : #Notification,
	#category : #'System-Exceptions'
}

{ #category : #handling }
ProgressTargetRequestNotification >> defaultAction [

	self resume: nil
]
