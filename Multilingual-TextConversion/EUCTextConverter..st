"
Text converter for Extended Unix Character.  This is an abstract class.  The CJK variations are implemented as subclasses.
"
Class {
	#name : #EUCTextConverter,
	#superclass : #TextConverter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #private }
EUCTextConverter >> languageEnvironment [

	self subclassResponsibility

]

{ #category : #private }
EUCTextConverter >> leadingChar [

	^ self subclassResponsibility

]

{ #category : #conversion }
EUCTextConverter >> nextFromStream: aStream [

	| character1 character2 offset value1 value2 nonUnicodeChar |
	aStream isBinary ifTrue: [^ aStream basicNext].
	character1 := aStream basicNext ifNil: [^ nil].
	character1 asciiValue <= 127 ifTrue: [^ character1].
	character2 := aStream basicNext ifNil: [^ nil].
	offset := 16rA1.
	value1 := character1 asciiValue - offset.
	value2 := character2 asciiValue - offset.
	(value1 < 0 or: [value1 > 93]) ifTrue: [^ nil].
	(value2 < 0 or: [value2 > 93]) ifTrue: [^ nil].

	nonUnicodeChar := Character leadingChar: self leadingChar code: value1 * 94 + value2.
	^ Character leadingChar: self languageEnvironment leadingChar code: nonUnicodeChar asUnicode.

]

{ #category : #conversion }
EUCTextConverter >> nextPut: aCharacter toStream: aStream [ 
	| charCode leadingChar nonUnicodeChar |
	aStream isBinary ifTrue: [^aCharacter storeBinaryOn: aStream].
	charCode := aCharacter charCode.
	leadingChar := aCharacter leadingChar.
	(leadingChar = 0 and: [ charCode < 256 ]) ifTrue: [
		(latin1Encodings at: charCode + 1)
			ifNil: [ aStream basicNextPut: aCharacter ]
			ifNotNil: [ :encodedString | aStream basicNextPutAll: encodedString ].
		^aCharacter ].
	aCharacter isTraditionalDomestic
		ifFalse: [ nonUnicodeChar := self nonUnicodeClass charFromUnicode: charCode ]
		ifTrue: [ nonUnicodeChar := Character value: charCode ].
	nonUnicodeChar ifNotNil: [
		charCode := nonUnicodeChar charCode.
		aStream
			basicNextPut: (Character value: charCode // 94 + 161);
			basicNextPut: (Character value: charCode \\ 94 + 161) ].
	^aCharacter

]

{ #category : #private }
EUCTextConverter >> nonUnicodeClass [

	^ (EncodedCharSet charsetAt: self leadingChar).

]
