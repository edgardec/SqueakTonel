"
A SignedDoubleWordArray store 64bit signed Integer values in the range (1<<63)negated (-9,223,372,036,854,775,808) to (1<<63-1) (9,223,372,036,854,775,807) - that is about 9 US-quintillon (10**3**(5+1)*9), or 9 british-trillion (10**6**3*9).
Negative values are stored as 2's complement.
"
Class {
	#name : #SignedDoubleWordArray,
	#superclass : #SignedIntegerArray,
	#type : #longs,
	#category : #'Collections-Arrayed'
}

{ #category : #accessing }
SignedDoubleWordArray >> at: index [
	| word64 |
	<primitive: 165>
	word64 := self basicAt: index.
	word64 < SmallInteger maxVal ifTrue:[^word64]. "Avoid LargeInteger computations"
	^word64 >= 16r8000000000000000	"Negative?!"
		ifTrue: ["word64 - 16r10000000000000000"
			  (word64 bitInvert64 + 1) negated]
		ifFalse: [word64]
]

{ #category : #accessing }
SignedDoubleWordArray >> at: index put: anInteger [
	| word64 |
	<primitive: 166>
	anInteger < 0
		ifTrue:
			[anInteger < -16r8000000000000000 ifTrue: [self error: anInteger asString , ' out of range'].
			"word64 := 16r10000000000000000 + anInteger"
			word64 := (anInteger + 1) negated bitInvert64]
		ifFalse:
			[anInteger > 16r7FFFFFFFFFFFFFFF ifTrue: [self error: anInteger asString , ' out of range'].
			word64 := anInteger].
	self  basicAt: index put: word64.
	^anInteger
]

{ #category : #accessing }
SignedDoubleWordArray >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 8
]
