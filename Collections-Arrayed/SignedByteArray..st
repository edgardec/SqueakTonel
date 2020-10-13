"
A SignedByteArray store 8bit signed Integer values in the range -128 to 127.
Negative values are stored as 2's complement.
"
Class {
	#name : #SignedByteArray,
	#superclass : #SignedIntegerArray,
	#type : #bytes,
	#category : #'Collections-Arrayed'
}

{ #category : #accessing }
SignedByteArray >> at: index [
	| word |
	<primitive: 165>
	word := self basicAt: index.
	^word >= 16r80	"Negative?!"
		ifTrue:[16r100 - word]
		ifFalse:[word]
]

{ #category : #accessing }
SignedByteArray >> at: index put: anInteger [
	| byte |
	<primitive: 166>
	anInteger < 0
		ifTrue:
			[anInteger < -16r80 ifTrue: [self error: anInteger asString , ' out of range'].
			 byte := 16r100 + anInteger]
		ifFalse:
			[anInteger > 16r7F ifTrue: [self error: anInteger asString , ' out of range'].
			 byte := anInteger].
	self  basicAt: index put: byte.
	^anInteger
]

{ #category : #accessing }
SignedByteArray >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 1
]
