Class {
	#name : #CommentedEvent,
	#superclass : #AbstractEvent,
	#category : #'System-Change Notification'
}

{ #category : #accessing }
CommentedEvent class >> changeKind [

	^#Commented
]

{ #category : #accessing }
CommentedEvent class >> supportedKinds [

	^Array with: self classKind
]

{ #category : #testing }
CommentedEvent >> isCommented [

	^true
]

{ #category : #printing }
CommentedEvent >> printEventKindOn: aStream [

	aStream nextPutAll: 'Commented'
]
