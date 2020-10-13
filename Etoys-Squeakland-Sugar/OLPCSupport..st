Class {
	#name : #OLPCSupport,
	#superclass : #Object,
	#classVars : [
		'XOFlashCharacter'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #'class initialization' }
OLPCSupport class >> initialize [
	"Class initialization."

	"self xoFlashCharacter"
]

{ #category : #'instance creation' }
OLPCSupport class >> xoCharacterWithExtent: anExtent insideColor: color1 outsideColor: color2 [
	"Answer a copy of the standard XO flash character, deploying the two colors provided"

	| aChar |
	aChar := self xoFlashCharacter veryDeepCopy.
	aChar firstColor: color1 secondColor: color2.
	aChar extent: anExtent.
	aChar defaultAALevel: 4.
	^ aChar

"
(OLPCSupport xoCharacterWithExtent: 50@71 insideColor: Color red outsideColor: Color green) openInHand
"
]

{ #category : #'instance creation' }
OLPCSupport class >> xoCharacterWithHeight: aHeight insideColor: color1 outsideColor: color2 [
	"Answer a copy of the standard XO flash character, deploying the two colors provided"

	| bigChar aRatio anExtent |
	bigChar := self xoFlashCharacter.
	aRatio := aHeight / bigChar height.
	anExtent := (aRatio * bigChar width) rounded @ aHeight.
	^ self xoCharacterWithExtent: anExtent insideColor: color1 outsideColor: color2

"
(OLPCSupport xoCharacterWithHeight: 25  insideColor: Color yellow outsideColor: Color green) openInHand
"
]

{ #category : #'instance creation' }
OLPCSupport class >> xoFlashCharacter [
	"Answer a copy of the standard XO flash character"

	XOFlashCharacter ifNil:
		[(Smalltalk classNamed: 'FlashMorphReader')
			ifNil: [^ nil]
			ifNotNil: [:reader |
				XOFlashCharacter := ((reader on: (Base64MimeConverter mimeDecodeToBytes: 'RldTA18BAABgAC7gAC7gABUBAEMC////vwA1AQAAAQBgwKOwaqfQAgCysrIAAgICAUYAAgIC
IQ1uHIfTY+NWgE1eAYxzgeCzY50AKMwApnRzMdHKiATKYAc48xzjgFbMAV+PjCrasUBlSJgD
SUA2uJZbaSUAlmALVzB5bdsBLlATEtqVNbaAJWoBKlwEFiERLUhxoCcgCmR++OuLe43HIccA
pIAnkdh2TI60CSwDLLfHY7vjzjkxNsAktAyzkyyAskAsOy3uOO747HpMsQLJALTssLyG5JgS
KAHn73E497jjsh2KgEiYBx2FcFFYgAQIS0AF1Jvp6x306ny3LlABLQAXkmBy3kQBhKAZI0W9
YrLfT1jLdQgGUoBijRSokTABKyAIr29ZU/esVjKjRsAErAAivY1pUV4BQlAULt3fT6fvWNOl
R3AFCUBPuXsaMt25PAAAhgYGAQABAABAAAAA' readStream)) processFile submorphs first)]].
	^ XOFlashCharacter veryDeepCopy defaultAALevel: 4

"
(757@1061)  is the extent of the imported XO character.
((757 @ 1061) / 15) rounded 50@71
((OLPCSupport xoFlashCharacter extent: 50@71) firstColor: Color red secondColor: Color green) openInHand

XOFlashCharacter := nil.
"
]

{ #category : #'instance creation' }
OLPCSupport class >> xoFlashCharacter: aMorph [
	"Set the given morph to be the XO flash character."

	XOFlashCharacter := aMorph

"
OLPCSupport xoFlashCharacter: (FlashMorphReader on: (Base64MimeConverter mimeDecodeToBytes: 'RldTA8wAAABgAC7gAC7gABUBAEMC////vwCiAAAAAQBgwKOwaqfQAQCysrIBRgACAgIRNW3B
v/vZTKlMmQCKUAizmJdBm8AlvAM+ffNptvmzKl0GLoCW8A0aJdGgBelAXTGjeyptvm02l0aA
F2UBeMaJTGdEAlRADJneymVvZU2lM50QCVEAMGZTJgAilAIs5nfNmUCttyDZtEvvACa9ANDR
m0dEAvJgC9L9CYw0UMAmRAAvL5i8wAEOYARNEvAAhgYGAQABAABAAAAA' readStream)) processFile submorphs first.

"
]
