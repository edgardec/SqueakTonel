"
Holds information about user-defined instance variables in Players.
"
Class {
	#name : #SlotInformation,
	#superclass : #Object,
	#instVars : [
		'type',
		'documentation',
		'floatPrecision',
		'variableDock',
		'variableDefinition'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #access }
SlotInformation >> documentation [
	"Answer the receiver's documentation"

	documentation ifNil: [documentation := 'This is a variable defined by you.  Please edit this into your own meaningful documentation.' translated].
	^ documentation
]

{ #category : #access }
SlotInformation >> documentation: d [
	documentation := d
]

{ #category : #access }
SlotInformation >> floatPrecision [
	"Answer the floatPrecision for the slot:
		1.0 ->	show whole number
		0.1	->	show one digit of precision
		.01 ->	show two digits of precision
		etc.
	Initialize the precision to 1 if it is not present"

	^ floatPrecision isNumber ifTrue: [floatPrecision] ifFalse: [floatPrecision := 1]
]

{ #category : #access }
SlotInformation >> floatPrecision: prec [
	floatPrecision := prec
]

{ #category : #initialization }
SlotInformation >> initialize [
	"Initialize the receiver's instance variables to default values"

	documentation := 'as yet undocumented'.
	type := #Number.
	floatPrecision := 0.1.
]

{ #category : #printing }
SlotInformation >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' precision: ', floatPrecision asString, ' ; type = ', type asString
]

{ #category : #access }
SlotInformation >> type [
	"Answer the type of the receiver, initializing it to Number if it is nil"

	type isEmptyOrNil ifTrue: [^ type := #Number].
	type first isUppercase ifFalse: [^ type := type capitalized].
		"because of lingering, annoying issue of projects created in a plug-in image"
	^ type
]

{ #category : #access }
SlotInformation >> type: aType [
	type := aType
]

{ #category : #access }
SlotInformation >> variableDock [
	"Answer the variable dock associated with the receiver, or nil if none"

	^ variableDock
]

{ #category : #access }
SlotInformation >> variableDock: vd [
	"Set the receiver's variableDock as indicated"

	variableDock := vd
]
