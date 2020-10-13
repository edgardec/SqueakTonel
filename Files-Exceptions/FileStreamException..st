Class {
	#name : #FileStreamException,
	#superclass : #Error,
	#instVars : [
		'fileName'
	],
	#category : #'Files-Exceptions'
}

{ #category : #exceptionInstantiator }
FileStreamException class >> fileName: aFileName [
	^self new fileName: aFileName
]

{ #category : #exceptionDescription }
FileStreamException >> fileName [
	^fileName
]

{ #category : #exceptionBuilder }
FileStreamException >> fileName: aFileName [
	fileName := aFileName
]

{ #category : #exceptionDescription }
FileStreamException >> isResumable [
	"Determine whether an exception is resumable."

	^true
]

{ #category : #exceptionDescription }
FileStreamException >> messageText [
	
	"Return an exception's message text."

	^messageText == nil
		ifTrue: [fileName printString]
		ifFalse: [messageText]
]
