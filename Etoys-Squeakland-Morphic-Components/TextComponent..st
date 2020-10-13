Class {
	#name : #TextComponent,
	#superclass : #PluggableTextMorph,
	#instVars : [
		'pinSpecs'
	],
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #components }
TextComponent >> initComponentIn: aLayout [
	super initComponentIn: aLayout.
	self setText: self getText
]

{ #category : #components }
TextComponent >> initFromPinSpecs [
	| ioPin |
	ioPin := pinSpecs first.
	getTextSelector := ioPin isInput 
		ifTrue: [ioPin modelReadSelector]
		ifFalse: [nil].
	setTextSelector := ioPin isOutput 
				ifTrue: [ioPin modelWriteSelector]
				ifFalse: [nil]
]

{ #category : #components }
TextComponent >> initPinSpecs [ 
	pinSpecs := Array
		with: (PinSpec new pinName: 'text' direction: #inputOutput
				localReadSelector: nil localWriteSelector: nil
				modelReadSelector: getTextSelector modelWriteSelector: setTextSelector
				defaultValue: 'some text' pinLoc: 1.5)
]

{ #category : #initialization }
TextComponent >> initialize [
	"initialize the state of the receiver"
	super initialize.
	self extent: 144 @ 42
]
