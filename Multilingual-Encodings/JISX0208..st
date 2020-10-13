"
This class represents the domestic character encoding called JIS X 0208 used for Japanese.
"
Class {
	#name : #JISX0208,
	#superclass : #EncodedCharSet,
	#category : #'Multilingual-Encodings'
}

{ #category : #'class methods' }
JISX0208 class >> charAtKuten: anInteger [

	| a b |
	a := anInteger \\ 100.
	b := anInteger // 100.
	(a > 94 or: [b > 94]) ifTrue: [
		self error: 'character code is not valid'.
	].
	^ Character leadingChar: self leadingChar code: ((b - 1) * 94) + a - 1.

]

{ #category : #'class methods' }
JISX0208 class >> compoundTextSequence [

	^ CompoundTextSequence.

]

{ #category : #'class initialization' }
JISX0208 class >> initialize [
"
	self initialize
"

	CompoundTextSequence := String streamContents: [:s |
		s nextPut: Character escape.
		s nextPut: $$.
		s nextPut: $B
	].

]

{ #category : #'accessing - displaying' }
JISX0208 class >> isBreakableAt: index in: text [

	| prev |
	index = 1 ifTrue: [^ false].
	prev := text at: index - 1.
	prev leadingChar ~= 1 ifTrue: [^ true].
	^ false

]

{ #category : #'character classification' }
JISX0208 class >> isLetterCode: anInteger [
	| value |
	value := anInteger // 94 + 1.
	^ 1 <= value and: [value < 84].

]

{ #category : #'class methods' }
JISX0208 class >> leadingChar [

	^ 1.

]

{ #category : #'class methods' }
JISX0208 class >> nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

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
JISX0208 class >> printingDirection [

	^ #right.

]

{ #category : #'class methods' }
JISX0208 class >> stringFromKutenArray: anArray [

	| s |
	s := WideString new: anArray size.
	1 to: anArray size do: [:i |
		s at: i put: (self charAtKuten: (anArray at: i)).
	].
	^s.

]

{ #category : #'class methods' }
JISX0208 class >> ucsTable [

	^ UCSTable jisx0208Table.

]

{ #category : #'class methods' }
JISX0208 class >> unicodeLeadingChar [

	^ JapaneseEnvironment leadingChar.

]
