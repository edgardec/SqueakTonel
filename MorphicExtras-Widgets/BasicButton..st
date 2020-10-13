"
A minimalist button-like object intended for use with the tile-scripting system.
"
Class {
	#name : #BasicButton,
	#superclass : #RectangleMorph,
	#category : #'MorphicExtras-Widgets'
}

{ #category : #printing }
BasicButton class >> defaultNameStemForInstances [
	^ 'button' translatedNoop
]

{ #category : #menus }
BasicButton >> addCustomMenuItems: aCustomMenu hand: aHandMorph [ 
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'change label...' translated action: #setLabel
]

{ #category : #initialization }
BasicButton >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color yellow darker
]

{ #category : #initialization }
BasicButton >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
BasicButton >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color yellow
]

{ #category : #initialization }
BasicButton >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self label: 'Button'; useRoundedCorners
]

{ #category : #label }
BasicButton >> label [
	| s |
	s := ''.
	self allMorphsDo: [:m | (m isKindOf: StringMorph) ifTrue: [s := m contents]].
	^ s
]

{ #category : #label }
BasicButton >> label: aString [

	| oldLabel m |
	(oldLabel := self findA: StringMorph)
		ifNotNil: [oldLabel delete].
	m := StringMorph contents: aString font: TextStyle defaultFont.
	self extent: m extent + (self borderWidth + 6).
	m position: self center - (m extent // 2).
	self addMorph: m.
	m lock
]

{ #category : #label }
BasicButton >> label: aString font: aFontOrNil [

	| oldLabel m aFont |
	(oldLabel := self findA: StringMorph)
		ifNotNil: [oldLabel delete].
	aFont := aFontOrNil ifNil: [Preferences standardButtonFont].
	m := StringMorph contents: aString font: aFont.
	self extent: (m width + 6) @ (m height + 6).
	m position: self center - (m extent // 2).
	self addMorph: m.
	m lock

]

{ #category : #label }
BasicButton >> setLabel [
	| newLabel |
	newLabel := UIManager default
		request:
'Enter a new label for this button'
		initialAnswer: self label.
	newLabel isEmpty ifFalse: [self label: newLabel font: nil].

]
