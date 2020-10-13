Class {
	#name : #KeyNotFound,
	#superclass : #Error,
	#instVars : [
		'key'
	],
	#category : #'Collections-Exceptions'
}

{ #category : #'instance creation' }
KeyNotFound class >> key: anObject [
	^self new key: anObject
]

{ #category : #accessing }
KeyNotFound >> description [
	"Return a textual description of the exception."
	^self messageText
]

{ #category : #accessing }
KeyNotFound >> key [
	"The key which wasn't found"
	^key
]

{ #category : #accessing }
KeyNotFound >> key: anObject [
	"The key which wasn't found"
	key := anObject
]

{ #category : #accessing }
KeyNotFound >> messageText [
	"Return a textual description of the exception."
	^messageText ifNil:['Key not found: ', key]
]
