Class {
	#name : #KOI8RTextConverter,
	#superclass : #TextConverter,
	#classVars : [
		'FromTable'
	],
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
KOI8RTextConverter class >> encodingNames [ 

	^ #('koi8-r') copy

]

{ #category : #'as yet unclassified' }
KOI8RTextConverter class >> initialize [
"
	KOI8RTextConverter initialize
"
	FromTable := Dictionary new.
	FromTable at: 16r2500 put: 16r80.
	FromTable at: 16r2502 put: 16r81.
	FromTable at: 16r250C put: 16r82.
	FromTable at: 16r2510 put: 16r83.
	FromTable at: 16r2514 put: 16r84.
	FromTable at: 16r2518 put: 16r85.
	FromTable at: 16r251C put: 16r86.
	FromTable at: 16r2524 put: 16r87.
	FromTable at: 16r252C put: 16r88.
	FromTable at: 16r2534 put: 16r89.
	FromTable at: 16r253C put: 16r8A.
	FromTable at: 16r2580 put: 16r8B.
	FromTable at: 16r2584 put: 16r8C.
	FromTable at: 16r2588 put: 16r8D.
	FromTable at: 16r258C put: 16r8E.
	FromTable at: 16r2590 put: 16r8F.
	FromTable at: 16r2591 put: 16r90.
	FromTable at: 16r2592 put: 16r91.
	FromTable at: 16r2593 put: 16r92.
	FromTable at: 16r2320 put: 16r93.
	FromTable at: 16r25A0 put: 16r94.
	FromTable at: 16r2219 put: 16r95.
	FromTable at: 16r221A put: 16r96.
	FromTable at: 16r2248 put: 16r97.
	FromTable at: 16r2264 put: 16r98.
	FromTable at: 16r2265 put: 16r99.
	FromTable at: 16r00A0 put: 16r9A.
	FromTable at: 16r2321 put: 16r9B.
	FromTable at: 16r00B0 put: 16r9C.
	FromTable at: 16r00B2 put: 16r9D.
	FromTable at: 16r00B7 put: 16r9E.
	FromTable at: 16r00F7 put: 16r9F.
	FromTable at: 16r2550 put: 16rA0.
	FromTable at: 16r2551 put: 16rA1.
	FromTable at: 16r2552 put: 16rA2.
	FromTable at: 16r0451 put: 16rA3.
	FromTable at: 16r2553 put: 16rA4.
	FromTable at: 16r2554 put: 16rA5.
	FromTable at: 16r2555 put: 16rA6.
	FromTable at: 16r2556 put: 16rA7.
	FromTable at: 16r2557 put: 16rA8.
	FromTable at: 16r2558 put: 16rA9.
	FromTable at: 16r2559 put: 16rAA.
	FromTable at: 16r255A put: 16rAB.
	FromTable at: 16r255B put: 16rAC.
	FromTable at: 16r255C put: 16rAD.
	FromTable at: 16r255D put: 16rAE.
	FromTable at: 16r255E put: 16rAF.
	FromTable at: 16r255F put: 16rB0.
	FromTable at: 16r2560 put: 16rB1.
	FromTable at: 16r2561 put: 16rB2.
	FromTable at: 16r0401 put: 16rB3.
	FromTable at: 16r2562 put: 16rB4.
	FromTable at: 16r2563 put: 16rB5.
	FromTable at: 16r2564 put: 16rB6.
	FromTable at: 16r2565 put: 16rB7.
	FromTable at: 16r2566 put: 16rB8.
	FromTable at: 16r2567 put: 16rB9.
	FromTable at: 16r2568 put: 16rBA.
	FromTable at: 16r2569 put: 16rBB.
	FromTable at: 16r256A put: 16rBC.
	FromTable at: 16r256B put: 16rBD.
	FromTable at: 16r256C put: 16rBE.
	FromTable at: 16r00A9 put: 16rBF.
	FromTable at: 16r044E put: 16rC0.
	FromTable at: 16r0430 put: 16rC1.
	FromTable at: 16r0431 put: 16rC2.
	FromTable at: 16r0446 put: 16rC3.
	FromTable at: 16r0434 put: 16rC4.
	FromTable at: 16r0435 put: 16rC5.
	FromTable at: 16r0444 put: 16rC6.
	FromTable at: 16r0433 put: 16rC7.
	FromTable at: 16r0445 put: 16rC8.
	FromTable at: 16r0438 put: 16rC9.
	FromTable at: 16r0439 put: 16rCA.
	FromTable at: 16r043A put: 16rCB.
	FromTable at: 16r043B put: 16rCC.
	FromTable at: 16r043C put: 16rCD.
	FromTable at: 16r043D put: 16rCE.
	FromTable at: 16r043E put: 16rCF.
	FromTable at: 16r043F put: 16rD0.
	FromTable at: 16r044F put: 16rD1.
	FromTable at: 16r0440 put: 16rD2.
	FromTable at: 16r0441 put: 16rD3.
	FromTable at: 16r0442 put: 16rD4.
	FromTable at: 16r0443 put: 16rD5.
	FromTable at: 16r0436 put: 16rD6.
	FromTable at: 16r0432 put: 16rD7.
	FromTable at: 16r044C put: 16rD8.
	FromTable at: 16r044B put: 16rD9.
	FromTable at: 16r0437 put: 16rDA.
	FromTable at: 16r0448 put: 16rDB.
	FromTable at: 16r044D put: 16rDC.
	FromTable at: 16r0449 put: 16rDD.
	FromTable at: 16r0447 put: 16rDE.
	FromTable at: 16r044A put: 16rDF.
	FromTable at: 16r042E put: 16rE0.
	FromTable at: 16r0410 put: 16rE1.
	FromTable at: 16r0411 put: 16rE2.
	FromTable at: 16r0426 put: 16rE3.
	FromTable at: 16r0414 put: 16rE4.
	FromTable at: 16r0415 put: 16rE5.
	FromTable at: 16r0424 put: 16rE6.
	FromTable at: 16r0413 put: 16rE7.
	FromTable at: 16r0425 put: 16rE8.
	FromTable at: 16r0418 put: 16rE9.
	FromTable at: 16r0419 put: 16rEA.
	FromTable at: 16r041A put: 16rEB.
	FromTable at: 16r041B put: 16rEC.
	FromTable at: 16r041C put: 16rED.
	FromTable at: 16r041D put: 16rEE.
	FromTable at: 16r041E put: 16rEF.
	FromTable at: 16r041F put: 16rF0.
	FromTable at: 16r042F put: 16rF1.
	FromTable at: 16r0420 put: 16rF2.
	FromTable at: 16r0421 put: 16rF3.
	FromTable at: 16r0422 put: 16rF4.
	FromTable at: 16r0423 put: 16rF5.
	FromTable at: 16r0416 put: 16rF6.
	FromTable at: 16r0412 put: 16rF7.
	FromTable at: 16r042C put: 16rF8.
	FromTable at: 16r042B put: 16rF9.
	FromTable at: 16r0417 put: 16rFA.
	FromTable at: 16r0428 put: 16rFB.
	FromTable at: 16r042D put: 16rFC.
	FromTable at: 16r0429 put: 16rFD.
	FromTable at: 16r0427 put: 16rFE.
	FromTable at: 16r042A put: 16rFF.

]

{ #category : #'as yet unclassified' }
KOI8RTextConverter >> fromSqueak: char [

	^ Character value: (FromTable at: char charCode ifAbsent: [char asciiValue])
]

{ #category : #'as yet unclassified' }
KOI8RTextConverter >> nextFromStream: aStream [

	| character1 |
	aStream isBinary ifTrue: [^ aStream basicNext].
	character1 := aStream basicNext.
	character1 isNil ifTrue: [^ nil].
	^ self toSqueak: character1.

]

{ #category : #'as yet unclassified' }
KOI8RTextConverter >> nextPut: aCharacter toStream: aStream [

	| charCode |
	aStream isBinary ifTrue: [ ^aCharacter storeBinaryOn: aStream ].
	(charCode := aCharacter charCode) < 256 
		ifFalse: [ aStream basicNextPut: ((Character value: (self fromSqueak: aCharacter) charCode)) ]
		ifTrue: [ 
			(latin1Encodings at: charCode + 1)
				ifNil: [ aStream basicNextPut: aCharacter ]
				ifNotNil: [ :encodedString | aStream basicNextPutAll: encodedString ] ].
	^aCharacter

]

{ #category : #'as yet unclassified' }
KOI8RTextConverter >> toSqueak: char [

	| value |
	value := char charCode.

	value < 128 ifTrue: [^ char].
	value > 255 ifTrue: [^ char].
	^ Character leadingChar: RussianEnvironment leadingChar code: (#(
		16r2500 16r2502 16r250C 16r2510 16r2514 16r2518 16r251C 16r2524
		16r252C 16r2534 16r253C 16r2580 16r2584 16r2588 16r258C 16r2590
		16r2591 16r2592 16r2593 16r2320 16r25A0 16r2219 16r221A 16r2248
		16r2264 16r2265 16r00A0 16r2321 16r00B0 16r00B2 16r00B7 16r00F7
		16r2550 16r2551 16r2552 16r0451 16r2553 16r2554 16r2555 16r2556
		16r2557 16r2558 16r2559 16r255A 16r255B 16r255C 16r255D 16r255E
		16r255F 16r2560 16r2561 16r0401 16r2562 16r2563 16r2564 16r2565
		16r2566 16r2567 16r2568 16r2569 16r256A 16r256B 16r256C 16r00A9
		16r044E 16r0430 16r0431 16r0446 16r0434 16r0435 16r0444 16r0433
		16r0445 16r0438 16r0439 16r043A 16r043B 16r043C 16r043D 16r043E
		16r043F 16r044F 16r0440 16r0441 16r0442 16r0443 16r0436 16r0432
		16r044C 16r044B 16r0437 16r0448 16r044D 16r0449 16r0447 16r044A
		16r042E 16r0410 16r0411 16r0426 16r0414 16r0415 16r0424 16r0413
		16r0425 16r0418 16r0419 16r041A 16r041B 16r041C 16r041D 16r041E
		16r041F 16r042F 16r0420 16r0421 16r0422 16r0423 16r0416 16r0412
		16r042C 16r042B 16r0417 16r0428 16r042D 16r0429 16r0427 16r042A
) at: (value - 128 + 1)).

]
