Class {
	#name : #Variable,
	#superclass : #ObjectWithDocumentation,
	#instVars : [
		'defaultValue',
		'floatPrecision',
		'variableName',
		'variableType'
	],
	#category : #'Protocols-Kernel'
}

{ #category : #value }
Variable >> defaultValue [
	"Answer the default value to be supplied to the receiver"

	^ defaultValue
]

{ #category : #name }
Variable >> name: aName type: aType [
	"Set the variable's name and type as indicated"

	variableName := aName.
	variableType := aType
]

{ #category : #name }
Variable >> printOn: aStream [
	"Print the receiver on the stream"

	super printOn: aStream.
	aStream nextPutAll: ' named ', (self variableName ifNil: ['<unnamed>']), ' type = ', variableType printString, ' default val = ', defaultValue printString
]

{ #category : #value }
Variable >> sample [
	"The closest we can come to an object for our type"

	| ty clsName |
	self defaultValue ifNotNil: [^ self defaultValue].
	ty := self variableType.
	"How translate a type like #player into a class?"
	clsName := ty asString.
	clsName at: 1 put: (clsName first asUppercase).
	clsName := clsName asSymbol.
	(Smalltalk includesKey: clsName) ifFalse: [self error: 'What type is this?'. ^ 5].
	^ (Smalltalk at: clsName) initializedInstance
]

{ #category : #name }
Variable >> variableName [
	"Answer the variable name of the receiver"

	^ variableName
]

{ #category : #type }
Variable >> variableType [
	"Anser the variable type of the receiver"

	^ variableType
]

{ #category : #type }
Variable >> variableType: aType [
	"Set the receiver's variable type as requested"

	variableType := aType
]
