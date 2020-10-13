"
This class represents the domestic character encoding called GB 2312 used for simplified Chinese.

"
Class {
	#name : #GB2312,
	#superclass : #EncodedCharSet,
	#category : #'Multilingual-Encodings'
}

{ #category : #'class methods' }
GB2312 class >> compoundTextSequence [

	^ CompoundTextSequence

]

{ #category : #'class initialization' }
GB2312 class >> initialize [
"
	GB2312 initialize
"

	CompoundTextSequence := String
				streamContents: 
					[:stream | 
					stream nextPut: Character escape.
					stream nextPut: $$.
					stream nextPut: $(.
					stream nextPut: $A].

]

{ #category : #'character classification' }
GB2312 class >> isLetterCode: anInteger [
	| value |
	value := anInteger // 94 + 1.
	^ 1 <= value and: [value < 84].

]

{ #category : #'class methods' }
GB2312 class >> leadingChar [

	^ 2.

]

{ #category : #'class methods' }
GB2312 class >> nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

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
GB2312 class >> ucsTable [

	^ UCSTable gb2312Table.

]
