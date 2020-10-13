Class {
	#name : #SugarRoundedField,
	#superclass : #Morph,
	#instVars : [
		'label',
		'mask',
		'backgroundColor'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #'as yet unclassified' }
SugarRoundedField >> backgroundColor: aColor [

	backgroundColor := aColor.
	mask := self makeMask: self extent foregroundColor: color backgroundColor: backgroundColor.

]

{ #category : #'as yet unclassified' }
SugarRoundedField >> drawOn: aCanvas [

	mask ifNil: [^super drawOn: aCanvas].

	aCanvas drawImage: mask at: self position.

]

{ #category : #'as yet unclassified' }
SugarRoundedField >> extent: aPoint [

	mask := self makeMask: aPoint foregroundColor: color backgroundColor: backgroundColor.
	"self recenterLabel."
	super extent: aPoint.

]

{ #category : #'as yet unclassified' }
SugarRoundedField >> initialize [

	super initialize.
	self color: Color white.
	backgroundColor := (Color r: 0.258 g: 0.258 b: 0.258).
	self clipSubmorphs: true.
	self extent: 160@50.

]

{ #category : #'as yet unclassified' }
SugarRoundedField >> label: aStringOrMorph [

	label ifNotNil: [label delete. label := nil].
	label := aStringOrMorph.
	label isString ifTrue: [
		label := StringMorph new label: label font: Preferences standardEToysFont
	].
	self resizeLabel.

]

{ #category : #'as yet unclassified' }
SugarRoundedField >> makeMask: extent foregroundColor: fgColor backgroundColor: bgColor [

	| f c diameter |
	f := Form extent: extent depth: 16.
	f fillColor: bgColor.
	c := f getCanvas asBalloonCanvas.
	c aaLevel: 2.
	diameter := extent x min: extent y.
	c drawOval: (0@0 extent: diameter@diameter) color: fgColor borderWidth: 0 borderColor: Color black.
	c drawOval: (((extent x - diameter)@0) extent: diameter@diameter) color: fgColor borderWidth: 0 borderColor: Color black.
	c fillRectangle: (((diameter // 2)@0) extent: ((extent x - diameter)@(extent y))) fillStyle: fgColor.
	c finish.
	^ f.

]

{ #category : #'as yet unclassified' }
SugarRoundedField >> naviHeight: aNumber [

	self extent: self width@(aNumber * 0.6).
	self resizeLabel.
]

{ #category : #'as yet unclassified' }
SugarRoundedField >> recenterLabel [

	label ifNotNil: [
		label center: self center.
		self addMorph: label.
	].

]

{ #category : #'as yet unclassified' }
SugarRoundedField >> resizeLabel [

	| small |
	(label notNil and: [label hasFocus not]) ifTrue: [
		label width: self width - 10.
		small :=self height < 45.
		label label: Project current world project name font: (StrikeFont familyName: 'BitstreamVeraSans' size: (small ifTrue: [15] ifFalse: [24])).
		label center: self center.
		label left: self left + 10.
		self addMorph: label.
	].

]

{ #category : #'as yet unclassified' }
SugarRoundedField >> wantsKeyboardFocusFor: aMorph [

	^ aMorph == label and: [aMorph isMemberOf: UpdatingStringMorph].

]
