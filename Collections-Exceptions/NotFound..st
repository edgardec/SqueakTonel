Class {
	#name : #NotFound,
	#superclass : #Error,
	#instVars : [
		'object'
	],
	#category : #'Collections-Exceptions'
}

{ #category : #'instance creation' }
NotFound class >> object: anObject [
	^self new object: anObject
]

{ #category : #accessing }
NotFound >> messageText [
	"Return a textual description of the exception."
	^messageText ifNil:['Object is not in the collection.']
]

{ #category : #accessing }
NotFound >> object [
	^object
]

{ #category : #accessing }
NotFound >> object: anObject [
	object := anObject
]
