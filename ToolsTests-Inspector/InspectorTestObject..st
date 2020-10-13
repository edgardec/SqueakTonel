Class {
	#name : #InspectorTestObject,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'apple',
		'orange'
	],
	#category : #'ToolsTests-Inspector'
}

{ #category : #'instance creation' }
InspectorTestObject class >> newInvalid [
	"Creates an instance that cannot #printOn: without raising an error."

	^ self new
		beInvalid;
		yourself
]

{ #category : #accessing }
InspectorTestObject >> apple [

	^ apple
]

{ #category : #accessing }
InspectorTestObject >> apple: aSymbol [

	apple := aSymbol.
]

{ #category : #initialization }
InspectorTestObject >> beInvalid [

	self apple: 5.
]

{ #category : #accessing }
InspectorTestObject >> fruits [

	^ {self apple. self orange} select: [:fruit | fruit notNil and: [fruit size > 0]]
]

{ #category : #accessing }
InspectorTestObject >> orange [

	^ orange
]

{ #category : #accessing }
InspectorTestObject >> orange: aSymbol [

	orange := aSymbol.
]

{ #category : #printing }
InspectorTestObject >> printOn: aStream [

	aStream nextPutAll: 'Today''s offers: '.
	self fruits do: [:fruit | aStream print: fruit].
]
