Class {
	#name : #CodecDemoMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'codecClassName'
	],
	#category : #'Etoys-Squeakland-Sound-Interface'
}

{ #category : #layout }
CodecDemoMorph >> acceptDroppingMorph: aMorph event: evt [

	| codecClass |
	'None' = codecClassName
		ifTrue: [aMorph sound play]
		ifFalse: [
			codecClass := Smalltalk at: codecClassName ifAbsent: [^ self].
			(codecClass new compressAndDecompress: aMorph sound) play].
	aMorph position: self topRight + (10@0).

]

{ #category : #menus }
CodecDemoMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'select codec' translated action: #selectCodec.

]

{ #category : #'as yet unclassified' }
CodecDemoMorph >> codecClassName: aStringOrSymbol [

	| label |
	codecClassName := aStringOrSymbol asSymbol.
	self removeAllMorphs.
	label := StringMorph contents: aStringOrSymbol.
	label position: self position + (5@5).
	self addMorph: label.
	label lock: true.
	self extent: label extent + (10@10).

]

{ #category : #initialization }
CodecDemoMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color
		r: 1.0
		g: 0.806
		b: 0.677
]

{ #category : #initialization }
CodecDemoMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	
	self codecClassName: 'MuLawCodec'
]

{ #category : #'as yet unclassified' }
CodecDemoMorph >> selectCodec [

	| aMenu codecs newCodec |
	aMenu := CustomMenu new title: 'Codec:'.
	codecs := SoundCodec allSubclasses collect: [:c | c name] as: OrderedCollection.
	codecs add: 'None'.
	codecs sort do:[:cName | aMenu add: cName action: cName].
	newCodec := aMenu startUp ifNil: [^ self].
	self codecClassName: newCodec.

]

{ #category : #'dropping\/grabbing' }
CodecDemoMorph >> wantsDroppedMorph: aMorph event: evt [

	^ aMorph isMemberOf: SoundTile

]
