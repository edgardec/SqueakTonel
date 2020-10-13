"
I represent a request for an Environment that is not necessarily the CurrentEnvironment, but any Environment available in the system.

Instance Variables

"
Class {
	#name : #EnvironmentRequest,
	#superclass : #Notification,
	#category : #'Environments-Notifications'
}

{ #category : #exceptionDescription }
EnvironmentRequest >> defaultAction [
	| all environment |
	all := Environment allInstances.
	environment := UIManager default chooseFrom: all values: all.
	self resume: environment.
]
