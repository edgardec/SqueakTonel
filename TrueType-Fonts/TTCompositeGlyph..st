"
This class represents a composite TrueType glyph, e.g.one which contains many simple TTGlyphs.
"
Class {
	#name : #TTCompositeGlyph,
	#superclass : #TTGlyph,
	#instVars : [
		'glyphs'
	],
	#category : #'TrueType-Fonts'
}

{ #category : #accessing }
TTCompositeGlyph >> addGlyph: aGlyph transformation: aMatrix [
	glyphs := glyphs copyWith: (aMatrix -> aGlyph)
]

{ #category : #accessing }
TTCompositeGlyph >> basicGlyphs [

	^ glyphs

]

{ #category : #accessing }
TTCompositeGlyph >> basicGlyphs: colOfAssocs [

	glyphs := colOfAssocs

]

{ #category : #accessing }
TTCompositeGlyph >> buildAllContours [
	"Build the contours in all non-composite glyphs."
	glyphs do:[:assoc| assoc value buildAllContours].
]

{ #category : #private }
TTCompositeGlyph >> computeContours [
	| out |
	out := WriteStream on: (Array new: glyphs size * 4).
	self glyphsAndTransformationsDo:[:glyph :transform|
		glyph contours do:[:ptArray|
			out nextPut: (transform localPointsToGlobal: ptArray).
		].
	].
	^out contents
]

{ #category : #accessing }
TTCompositeGlyph >> contours [
	^contours ifNil:[contours := self computeContours]
]

{ #category : #private }
TTCompositeGlyph >> flipAroundY [
	bounds := (bounds origin x @ bounds corner y negated) corner:
				(bounds corner x @ bounds origin y negated).
	contours := nil.
]

{ #category : #accessing }
TTCompositeGlyph >> glyphs [

	^glyphs collect:[:assoc| assoc value].
]

{ #category : #accessing }
TTCompositeGlyph >> glyphsAndTransformationsDo: aBlock [
	glyphs do:[:assoc|
		aBlock value: assoc value value: assoc key.
	].
]

{ #category : #initialize }
TTCompositeGlyph >> initialize [
	glyphs := #().
]

{ #category : #testing }
TTCompositeGlyph >> isComposite [
	^true
]

{ #category : #initialize }
TTCompositeGlyph >> referenceVertexAt: index [
	"Only used while reading before constructing contours"
	| i |
	i := index.
	self glyphsAndTransformationsDo: [:glyph :transform | | p |
		p := glyph referenceVertexAt: i.
		p isPoint
			ifTrue: [^transform localPointToGlobal: p].
		i := i - p].
	self error: ['this should not happen']
]
