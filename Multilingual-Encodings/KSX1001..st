"
This class represents the domestic character encoding called KS X 1001 used for Korean.
"
Class {
	#name : #KSX1001,
	#superclass : #EncodedCharSet,
	#category : #'Multilingual-Encodings'
}

{ #category : #'class methods' }
KSX1001 class >> compoundTextSequence [

	^ CompoundTextSequence.

]

{ #category : #'class initialization' }
KSX1001 class >> initialize [
"
	KSX1001 initialize
"

	CompoundTextSequence := String
				streamContents: 
					[:stream | 
					stream nextPut: Character escape.
					stream nextPut: $$.
					stream nextPut: $(.
					stream nextPut: $C]
]

{ #category : #'character classification' }
KSX1001 class >> isLetterCode: anInteger [
	| value |
	value := anInteger // 94 + 1.
	^ 1 <= value and: [value < 84].

]

{ #category : #'class methods' }
KSX1001 class >> leadingChar [

	^ 3.

]

{ #category : #'class methods' }
KSX1001 class >> nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

	| c1 c2 |
	state charSize: 2.
	(state g0Leading ~= self leadingChar) ifTrue: [
		state g0Leading: self leadingChar.
		state g0Size: 2.
		aStream basicNextPutAll: CompoundTextSequence.
	].
	c1 := ascii // 94 + 16r21.
	c2 := ascii \\ 94 + 16r21.
	^ aStream basicNextPut: (Character value: c1); basicNextPut: (Character value: c2).

]

{ #category : #'class methods' }
KSX1001 class >> ucsTable [

	^ UCSTable ksx1001Table.

]
