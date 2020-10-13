"
signaled by font loading code when reading a DiskProxy that calls for a missing font.
"
Class {
	#name : #MissingFont,
	#superclass : #Notification,
	#instVars : [
		'familyName',
		'pixelSize'
	],
	#category : #'Graphics-Fonts'
}

{ #category : #'instance creation' }
MissingFont class >> forFamilyName: aName pixelSize: aSize [
	^(self new)
		familyName: aName;
		pixelSize: aSize;
		yourself.
]

{ #category : #handling }
MissingFont >> defaultAction [
	familyName ifNil: [ familyName := 'NoName' ].
	pixelSize ifNil: [ pixelSize := 12 ].

	^((familyName beginsWith: 'Comic')
		ifTrue: [ TextStyle named: (Preferences standardEToysFont familyName) ]
		ifFalse: [ TextStyle default ]) fontOfSize: pixelSize.
]

{ #category : #accessing }
MissingFont >> familyName [
	"Answer the value of familyName"

	^ familyName
]

{ #category : #accessing }
MissingFont >> familyName: anObject [
	"Set the value of familyName"

	familyName := anObject
]

{ #category : #accessing }
MissingFont >> pixelSize [
	"Answer the value of pixelSize"

	^ pixelSize
]

{ #category : #accessing }
MissingFont >> pixelSize: anObject [
	"Set the value of pixelSize"

	pixelSize := anObject
]

{ #category : #printing }
MissingFont >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(;
		nextPutAll: familyName;
		nextPut: $-;
		print: pixelSize;
		nextPut: $).
]
