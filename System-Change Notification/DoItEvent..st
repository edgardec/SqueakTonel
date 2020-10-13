Class {
	#name : #DoItEvent,
	#superclass : #AbstractEvent,
	#instVars : [
		'context'
	],
	#category : #'System-Change Notification'
}

{ #category : #accessing }
DoItEvent class >> changeKind [

	^#DoIt
]

{ #category : #'instance creation' }
DoItEvent class >> expression: stringOrStream context: aContext [
	| instance |
	instance := self item: stringOrStream kind: AbstractEvent expressionKind.
	instance context: aContext.
	^instance
]

{ #category : #accessing }
DoItEvent class >> supportedKinds [
	^ Array with: self expressionKind
]

{ #category : #accessing }
DoItEvent >> context [

	^context
]

{ #category : #'private-accessing' }
DoItEvent >> context: aContext [

	context := aContext
]

{ #category : #testing }
DoItEvent >> isDoIt [

	^true
]

{ #category : #printing }
DoItEvent >> printEventKindOn: aStream [

	aStream nextPutAll: 'DoIt'
]
