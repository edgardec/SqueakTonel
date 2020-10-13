Class {
	#name : #ProjectSwikiServer,
	#superclass : #ServerDirectory,
	#instVars : [
		'acceptsUploads'
	],
	#category : #'Network-RemoteDirectory'
}

{ #category : #testing }
ProjectSwikiServer >> acceptsUploads [
	^acceptsUploads == true
]

{ #category : #accessing }
ProjectSwikiServer >> acceptsUploads: aBoolean [
	acceptsUploads := aBoolean
]

{ #category : #testing }
ProjectSwikiServer >> isProjectSwiki [
	^true
]

{ #category : #initialize }
ProjectSwikiServer >> wakeUp [
]
