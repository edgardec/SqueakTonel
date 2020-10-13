Class {
	#name : #ColorTileRandom,
	#superclass : #TileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #'code generation' }
ColorTileRandom >> basicParseNodeWith: encoder [

	^ MessageNode new
				receiver: (encoder encodeLiteral: Color)
				selector: #random
				arguments: #()
				precedence: #random precedence
				from: encoder
				sourceRange: nil.

]

{ #category : #initialization }
ColorTileRandom >> initialize [
	"initialize the state of the receiver"

	| s c |
	super initialize.
	type := #function.
	self minHeight: 30; vResizing: #spaceFill; borderWidth: 0.
	c := ColorPickerMorph new.
	c extent: 15@15.
	self addMorphBack: c.
	c position: 3@3.
	s := StringMorph contents: 'random color' translated font: ScriptingSystem fontForTiles.
	self extent: (s width + 6 max: self basicWidth) @ self class defaultH.
	s position: (bounds center x - (s width // 2)) @ (bounds top + 1).
	self addMorph: s.

]

{ #category : #'code generation' }
ColorTileRandom >> parseNodeWith: encoder [

	^ self basicParseNodeWith: encoder.

]

{ #category : #accessing }
ColorTileRandom >> resultType [
	"Answer the result type of the receiver"

	^ #Color
]

{ #category : #'code generation' }
ColorTileRandom >> storeCodeOn: aStream indent: tabCount [ 
	"We have a hidden arg. Output two keywords with interspersed arguments."

	^aStream
		nextPutAll: 'Color';
		space;
		nextPutAll: 'random';
		space
]

{ #category : #initialization }
ColorTileRandom >> updateWordingToMatchVocabulary [

	| stringMorph |
	stringMorph := submorphs detect: [:morph | morph class == StringMorph] ifNone: [^ self].
	stringMorph contents: 'random color' translated.

]
