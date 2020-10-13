Class {
	#name : #ReorganizedEvent,
	#superclass : #AbstractEvent,
	#category : #'System-Change Notification'
}

{ #category : #accessing }
ReorganizedEvent class >> changeKind [

	^#Reorganized
]

{ #category : #accessing }
ReorganizedEvent class >> supportedKinds [

	^Array with: self classKind
]

{ #category : #testing }
ReorganizedEvent >> isReorganized [
	^ true
]

{ #category : #printing }
ReorganizedEvent >> printEventKindOn: aStream [

	aStream nextPutAll: 'Reorganized'
]
