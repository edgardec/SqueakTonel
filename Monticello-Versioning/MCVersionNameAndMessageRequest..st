Class {
	#name : #MCVersionNameAndMessageRequest,
	#superclass : #Notification,
	#instVars : [
		'suggestion',
		'initialMessage',
		'patchBlock'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #handling }
MCVersionNameAndMessageRequest >> defaultAction [
	^ MCSaveVersionDialog new
		versionName: suggestion;
		logMessage: initialMessage;
		patchBlock: patchBlock;
		selection: 1;
		showModally
]

{ #category : #accessing }
MCVersionNameAndMessageRequest >> initialMessage [
	^ initialMessage
]

{ #category : #accessing }
MCVersionNameAndMessageRequest >> initialMessage: aString [
	initialMessage := aString
]

{ #category : #accessing }
MCVersionNameAndMessageRequest >> patchBlock [
	^ patchBlock
]

{ #category : #accessing }
MCVersionNameAndMessageRequest >> patchBlock: aBlock [
	patchBlock := aBlock

]

{ #category : #accessing }
MCVersionNameAndMessageRequest >> suggestedName [
	^ suggestion
]

{ #category : #accessing }
MCVersionNameAndMessageRequest >> suggestedName: aString [
	suggestion := aString
]
