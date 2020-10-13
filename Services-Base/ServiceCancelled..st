"
Exception raised when a service is cancelled, to inform the user.
"
Class {
	#name : #ServiceCancelled,
	#superclass : #Warning,
	#category : #'Services-Base'
}

{ #category : #handling }
ServiceCancelled >> defaultAction [
	Transcript cr; show: 'service has been cancelled'
]

{ #category : #accessing }
ServiceCancelled >> messageText [
	^ 'Service has been cancelled'
]
