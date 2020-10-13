"
An InvalidUTF8 is an Exception that is raised when attempting to decode an invalid UTF-8 Sequence

Instance Variables
	string:		<String>

string
	- the string that were decoded

"
Class {
	#name : #UndefinedConversion,
	#superclass : #Error,
	#instVars : [
		'unicodeValue',
		'targetEncoding'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #exceptionInstantiator }
UndefinedConversion class >> signalFor: characterValue toEncoding: anEncoding [

	self new
		unicodeValue: characterValue;
		targetEncoding: anEncoding;
		signal
]

{ #category : #private }
UndefinedConversion >> isResumable [
	^true
]

{ #category : #private }
UndefinedConversion >> messageText [
	"Return a textual description of the exception."
	^messageText ifNil: [
		'Can not represent the unicode character ' , (self unicodeValue printStringRadix: 16) , ' in ' , self targetEncoding encodingNames first]
]

{ #category : #accessing }
UndefinedConversion >> targetEncoding [
	
	^ targetEncoding

]

{ #category : #accessing }
UndefinedConversion >> targetEncoding: anObject [
	
	targetEncoding := anObject.

]

{ #category : #accessing }
UndefinedConversion >> unicodeValue [
	
	^ unicodeValue

]

{ #category : #accessing }
UndefinedConversion >> unicodeValue: anObject [
	
	unicodeValue := anObject.

]
