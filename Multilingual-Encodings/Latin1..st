"
This class represents the domestic character encoding called ISO-8859-1, also known as Latin-1 used for Most of the Western European Languages.
"
Class {
	#name : #Latin1,
	#superclass : #EncodedCharSet,
	#classInstVars : [
		'RightHalfSequence'
	],
	#category : #'Multilingual-Encodings'
}

{ #category : #'class methods' }
Latin1 class >> charFromUnicode: uniCode [

	^ Character leadingChar: self leadingChar code: uniCode
]

{ #category : #'class methods' }
Latin1 class >> convertToUnicode: aCode [
	^aCode
]

{ #category : #'class methods' }
Latin1 class >> emitSequenceToResetStateIfNeededOn: aStream forState: state [

	(state g0Leading ~= 0) ifTrue: [
		state charSize: 1.
		state g0Leading: 0.
		state g0Size: 1.
		aStream basicNextPutAll: CompoundTextSequence.
	].

	"Actually, G1 state should go back to ISO-8859-1, too."

]

{ #category : #'class initialization' }
Latin1 class >> initialize [
"
	self initialize
"


	CompoundTextSequence := String streamContents: [:s |
		s nextPut: Character escape.
		s nextPut: $(.
		s nextPut: $B.
	].

	RightHalfSequence := String streamContents: [:s |
		s nextPut: Character escape.
		s nextPut: $-.
		s nextPut: $A.
	].

]

{ #category : #'character classification' }
Latin1 class >> isLetterCode: anInteger [
	^ Unicode isLetterCode: anInteger


]

{ #category : #'class methods' }
Latin1 class >> leadingChar [

	^ 0.

]

{ #category : #private }
Latin1 class >> nextPutRightHalfValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

	state charSize: 1.
	state g1Leading: 0.
	state g1Size: 1.
	aStream basicNextPutAll: RightHalfSequence.
	aStream basicNextPut: (Character value: ascii).

]

{ #category : #'class methods' }
Latin1 class >> nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

	(ascii <= 16r7F and: [state g0Leading ~= 0]) ifTrue: [
		state charSize: 1.
		state g0Leading: 0.
		state g0Size: 1.
		aStream basicNextPutAll: CompoundTextSequence.
		aStream basicNextPut: (Character value: ascii).
		^ self.
	].

	((16r80 <= ascii and: [ascii <= 16rFF]) and: [state g1Leading ~= 0]) ifTrue: [
		^ self nextPutRightHalfValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state.
	].

	aStream basicNextPut: (Character value: ascii).
	^ self.

]

{ #category : #'accessing - displaying' }
Latin1 class >> printingDirection [

	^ #right.

]
