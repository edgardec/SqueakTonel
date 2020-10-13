Class {
	#name : #AddedEvent,
	#superclass : #AbstractEvent,
	#category : #'System-Change Notification'
}

{ #category : #accessing }
AddedEvent class >> changeKind [

	^#Added
]

{ #category : #accessing }
AddedEvent class >> supportedKinds [
	"All the kinds of items that this event can take."
	
	^ Array with: self classKind with: self methodKind with: self categoryKind with: self protocolKind
]

{ #category : #testing }
AddedEvent >> isAdded [

	^true
]

{ #category : #printing }
AddedEvent >> printEventKindOn: aStream [

	aStream nextPutAll: 'Added'
]
