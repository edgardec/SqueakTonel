Class {
	#name : #ColorTileMorph,
	#superclass : #TileMorph,
	#instVars : [
		'colorSwatch',
		'showPalette'
	],
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #other }
ColorTileMorph >> addColorSwatch [

	| m1 m2 desiredW |
	m1 := StringMorph contents: 'color' translated font: ScriptingSystem fontForTiles.
	m2 := Morph new extent: 16@14; color: (Color r: 0.8 g: 0 b: 0).
	desiredW := m1 width + 6.
	self extent: (desiredW max: self basicWidth) @ self class defaultH.
	m1 position: (bounds center x - (m1 width // 2)) @ (bounds top + 1).
	m2 position: (bounds center x - (m2 width // 2)) @ (m1 bottom - 1).
	self addMorph: m1; addMorph: m2.
	colorSwatch := m2
]

{ #category : #other }
ColorTileMorph >> colorSwatch [
	^ colorSwatch
]

{ #category : #other }
ColorTileMorph >> colorSwatchColor: aColor [
	colorSwatch color: aColor.

]

{ #category : #'event handling' }
ColorTileMorph >> handlesMouseDown: evt [

	(colorSwatch containsPoint: evt cursorPoint)
		ifTrue: [^ true]
		ifFalse: [^ super handlesMouseDown: evt].

]

{ #category : #initialization }
ColorTileMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	type := #literal.
	self addColorSwatch.
	showPalette := true.

]

{ #category : #other }
ColorTileMorph >> kedamaColorSwatchColor: aColor [

	colorSwatch userSelectedColor: aColor.

]

{ #category : #'code generation' }
ColorTileMorph >> kedamaStoreCodeAsPixelValueOn: aStream indent: tabCount [

	aStream nextPutAll: ((colorSwatch color pixelValueForDepth: 32) bitAnd: 16rFFFFFF) printString.

]

{ #category : #'event handling' }
ColorTileMorph >> mouseDown: evt [

	(colorSwatch containsPoint: evt cursorPoint)
		ifFalse: [super mouseDown: evt].

]

{ #category : #'event handling' }
ColorTileMorph >> mouseUp: evt [
	self changeColorTarget: self selector: #kedamaColorSwatchColor: originalColor: colorSwatch color hand: evt hand showPalette: self showPalette.

]

{ #category : #'code generation' }
ColorTileMorph >> parseNodeWith: encoder [

	^ encoder encodeLiteral: colorSwatch color.


]

{ #category : #accessing }
ColorTileMorph >> resultType [
	"Answer the result type of the receiver"

	^ #Color
]

{ #category : #initialization }
ColorTileMorph >> setLiteral: aLiteral [
	"Set the receiver's literal"

	self colorSwatchColor: aLiteral
]

{ #category : #accessing }
ColorTileMorph >> showPalette [

	^ showPalette isNil or: [showPalette].


]

{ #category : #accessing }
ColorTileMorph >> showPalette: aBoolean [

	showPalette := aBoolean.

]

{ #category : #'code generation' }
ColorTileMorph >> storeCodeOn: aStream indent: tabCount [

	aStream nextPutAll: colorSwatch color printString.

]

{ #category : #'player viewer' }
ColorTileMorph >> updateLiteralLabel [
	"Do nothing"
]

{ #category : #initialization }
ColorTileMorph >> updateWordingToMatchVocabulary [

	| stringMorph |
	stringMorph := submorphs detect: [:morph | morph class == StringMorph] ifNone: [^ self].
	stringMorph contents: 'color' translated.

]
