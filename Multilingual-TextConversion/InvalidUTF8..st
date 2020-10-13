"
An InvalidUTF8 is an Exception that is raised when attempting to decode an invalid UTF-8 Sequence

Instance Variables
	string:		<String>

string
	- the string that were decoded

"
Class {
	#name : #InvalidUTF8,
	#superclass : #Error,
	#instVars : [
		'string'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #'priv handling' }
InvalidUTF8 >> isResumable [
	^true
]

{ #category : #printing }
InvalidUTF8 >> messageText [
	"Return a textual description of the exception."
	^messageText ifNil: [string
		ifNil: ['Invalid UTF8']
		ifNotNil: ['Invalid utf8: ', string]]
]

{ #category : #private }
InvalidUTF8 >> string: aString [
	string := aString
]
