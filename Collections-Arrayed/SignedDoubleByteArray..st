"
A SignedDoubleByteArray store 16bit signed Integer values  in the range -32766 to 32765.
Negative values are stored as 2's complement.
"
Class {
	#name : #SignedDoubleByteArray,
	#superclass : #SignedIntegerArray,
	#type : #shorts,
	#category : #'Collections-Arrayed'
}

{ #category : #accessing }
SignedDoubleByteArray >> at: index [
	| word |
	<primitive: 165>
	word := self basicAt: index.
	^word >= 16r8000	"Negative?!"
		ifTrue:[16r10000 - word]
		ifFalse:[word]
]

{ #category : #accessing }
SignedDoubleByteArray >> at: index put: anInteger [
	| byte |
	<primitive: 166>
	anInteger < 0
		ifTrue:
			[anInteger < -16r8000 ifTrue: [self error: anInteger asString , ' out of range'].
			 byte := 16r10000 + anInteger]
		ifFalse:
			[anInteger > 16r7FFF ifTrue: [self error: anInteger asString , ' out of range'].
			 byte := anInteger].
	self  basicAt: index put: byte.
	^anInteger
]

{ #category : #accessing }
SignedDoubleByteArray >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 2
]
