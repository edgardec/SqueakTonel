Class {
	#name : #RemovedEvent,
	#superclass : #AbstractEvent,
	#category : #'System-Change Notification'
}

{ #category : #accessing }
RemovedEvent class >> changeKind [

	^#Removed
]

{ #category : #accessing }
RemovedEvent class >> supportedKinds [
	"All the kinds of items that this event can take."
	
	^ Array with: self classKind with: self methodKind with: self categoryKind with: self protocolKind
]

{ #category : #testing }
RemovedEvent >> isRemoved [

	^true
]

{ #category : #printing }
RemovedEvent >> printEventKindOn: aStream [

	aStream nextPutAll: 'Removed'
]
