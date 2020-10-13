Class {
	#name : #ColorSwatch,
	#superclass : #UpdatingRectangleMorph,
	#instVars : [
		'argument'
	],
	#category : #'Etoys-Scripting Support'
}

{ #category : #'as yet unclassified' }
ColorSwatch >> argument: arg [
	argument := arg
]

{ #category : #'target access' }
ColorSwatch >> readFromTarget [
	"Obtain a value from the target and set it into my lastValue"

	| v |
	(target isNil or: [getSelector isNil]) ifTrue: [^contents].
	v := target perform: getSelector with: argument.
	lastValue := v.
	^v
]

{ #category : #setting }
ColorSwatch >> setTargetColor: aColor [
	"Set the target color as indicated"

	putSelector ifNotNil:
		[self color: aColor.
		contents := aColor.
		target perform: self putSelector withArguments: (Array with: argument with: aColor)]

]

{ #category : #testing }
ColorSwatch >> stepTime [
	^ 1000
]
