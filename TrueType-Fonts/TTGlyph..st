"
This class represents a glyph of a TrueType font.

Instance variables:
	bounds			<Rectangle>	The receiver's bounds
	contours		<Array of: PointArray> The compressed contours in the receiver
	advanceWidth	<Integer>	advance width of the glyph
	leftSideBearing	<Integer>	left side bearing
	rightSideBearing <Integer>	right side bearing
	glyphIndex 		<Integer>	the original index of the glyph (used for kerning)
"
Class {
	#name : #TTGlyph,
	#superclass : #Object,
	#instVars : [
		'bounds',
		'contours',
		'advanceWidth',
		'leftSideBearing',
		'rightSideBearing',
		'glyphIndex'
	],
	#category : #'TrueType-Fonts'
}

{ #category : #accessing }
TTGlyph >> advanceWidth [
	^advanceWidth
]

{ #category : #accessing }
TTGlyph >> advanceWidth: aNumber [
	advanceWidth := aNumber.
]

{ #category : #converting }
TTGlyph >> asFormWithScale: scale ascender: ascender descender: descender [
	^ self
		asFormWithScale: scale
		ascender: ascender
		descender: descender
		fgColor: Color black
		bgColor: Color white
		depth: 8
		replaceColor: true.

]

{ #category : #converting }
TTGlyph >> asFormWithScale: scale ascender: ascender descender: descender fgColor: fgColor bgColor: bgColor depth: depth [

	^ self
		asFormWithScale: scale
		ascender: ascender
		descender: descender
		fgColor: fgColor
		bgColor: bgColor
		depth: depth
		replaceColor: false.

]

{ #category : #converting }
TTGlyph >> asFormWithScale: scale ascender: ascender descender: descender fgColor: fgColor bgColor: bgColor depth: depth replaceColor: replaceColorFlag [

	^ self
		asFormWithScale: scale
		ascender: ascender
		descender: descender
		fgColor: fgColor
		bgColor: bgColor
		depth: depth
		replaceColor: replaceColorFlag
		lineGlyph: nil
		lingGlyphWidth: 0
		emphasis: 0.
]

{ #category : #converting }
TTGlyph >> asFormWithScale: scale ascender: ascender descender: descender fgColor: fgColor bgColor: bgColor depth: depth replaceColor: replaceColorFlag lineGlyph: lineGlyph lingGlyphWidth: lWidth emphasis: code [

	| form canvas newScale |
	form := Form extent: (advanceWidth @ (ascender - descender) * scale) rounded depth: depth.
	form fillColor: bgColor.
	canvas := form getCanvas asBalloonCanvas.
	canvas aaLevel: 4.
	canvas transformBy: (MatrixTransform2x3 withScale: scale asPoint * (1 @ -1)).
	canvas transformBy: (MatrixTransform2x3 withOffset: 0 @ ascender negated).
	canvas
		drawGeneralBezierShape: self contours
		color: fgColor 
		borderWidth: 0 
		borderColor: fgColor.
	((code bitAnd: 4) ~= 0 or: [(code bitAnd: 16) ~= 0]) ifTrue: [
		newScale := (form width + 1) asFloat / lineGlyph calculateWidth asFloat.
		canvas transformBy: (MatrixTransform2x3 withScale: (newScale / scale)@1.0).

		(code bitAnd: 4) ~= 0 ifTrue: [
			canvas
				drawGeneralBezierShape: lineGlyph contours
				color: fgColor 
				borderWidth: 0 
				borderColor: fgColor.
		].

		(code bitAnd: 16) ~= 0 ifTrue: [
			canvas transformBy: (MatrixTransform2x3 withOffset: 0@(ascender // 2)).
			canvas
				drawGeneralBezierShape: lineGlyph contours
				color: fgColor 
				borderWidth: 0 
				borderColor: fgColor.
		].
	].

	replaceColorFlag ifTrue: [
		form replaceColor: bgColor withColor: Color transparent.
	].
	^ form
]

{ #category : #accessing }
TTGlyph >> bounds [
	^bounds
]

{ #category : #accessing }
TTGlyph >> bounds: aRectangle [
	bounds := aRectangle
]

{ #category : #'private-initialization' }
TTGlyph >> buildAllContours [
	"Build the contours in all non-composite glyphs."
	^self buildContours
]

{ #category : #'private-initialization' }
TTGlyph >> buildContours [
	"Build the contours in the receiver glyph.
	The contour is constructed by converting the points
	form each contour into an absolute value and then
	compressing the contours into PointArrays."
	| tx ty |
	tx := ty := 0.
	contours := contours collect:[:contour| | points |
		contour isCollection ifTrue:[^self]. "already built"
		points := contour points.
		points do:[:pt|
			pt x: (tx := tx + pt x).
			pt y: (ty := ty + pt y)].
		contour asCompressedPoints].
]

{ #category : #private }
TTGlyph >> calculateWidth [

	| min max |
	min := SmallInteger maxVal.
	max := SmallInteger minVal.
	self contours do: [:a | a do: [:p |
		p x > max ifTrue: [max := p x].
		p x < min ifTrue: [min := p x].
	]].
	^ max - min.

]

{ #category : #accessing }
TTGlyph >> contours [
	^contours
]

{ #category : #accessing }
TTGlyph >> contours: aCollection [
	contours := aCollection asArray.
]

{ #category : #private }
TTGlyph >> display [
	| canvas |
	canvas := Display getCanvas.
	self contours do:[:ptArray|
		1 to: ptArray size by: 3 do:[:i|
			canvas line: (ptArray at: i) // 10
					to: (ptArray at: i+2) // 10
					width: 1 color: Color black.
		].
	].
]

{ #category : #private }
TTGlyph >> flipAroundY [
	bounds := (bounds origin x @ bounds corner y negated) corner:
				(bounds corner x @ bounds origin y negated).
	contours := self contours collect:[:contour| contour collect:[:pt| pt x @ pt y negated]].
]

{ #category : #accessing }
TTGlyph >> glyphIndex [
	^glyphIndex
]

{ #category : #accessing }
TTGlyph >> glyphIndex: anInteger [
	glyphIndex := anInteger
]

{ #category : #accessing }
TTGlyph >> glyphsAndTransformationsDo: aBlock [
	aBlock value: self value: MatrixTransform2x3 identity
]

{ #category : #'initialize-release' }
TTGlyph >> initialize [

	bounds := 0@0 corner: 0@0.
	contours := #().
	advanceWidth := 0.
	leftSideBearing := 0.
	rightSideBearing := 0.
]

{ #category : #'private-initialization' }
TTGlyph >> initializeContours: numContours with: endPoints [
	"Initialize the contours for creation of the glyph."
	| startPt pts endPt |
	contours := Array new: numContours.
	startPt := -1.
	1 to: numContours do:[:i|
		endPt := endPoints at: i.
		pts := Array new: endPt - startPt.
		1 to: pts size do:[:j| pts at: j put: TTPoint new].
		contours at: i put: (TTContourConstruction on: pts).
		startPt := endPt].
]

{ #category : #testing }
TTGlyph >> isComposite [
	^false
]

{ #category : #accessing }
TTGlyph >> leftSideBearing [
	^leftSideBearing
]

{ #category : #accessing }
TTGlyph >> leftSideBearing: aNumber [
	leftSideBearing := aNumber.
]

{ #category : #printing }
TTGlyph >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPut:$(;
		print: (contours ifNil: [0] ifNotNil: [contours size]);
		nextPut:$).
]

{ #category : #'private-initialization' }
TTGlyph >> referenceVertexAt: index [
	"Only used while reading before constructing contours"
	| count |
	count := 0.
	contours do: [:construction | | vertices |
		vertices := construction points.
		index - count > vertices size
			ifTrue: [count := count + vertices size]
			ifFalse: [^(vertices at: index - count) asPoint]].
	^count
]

{ #category : #accessing }
TTGlyph >> rightSideBearing [
	^rightSideBearing
]

{ #category : #accessing }
TTGlyph >> rightSideBearing: aNumber [
	rightSideBearing := aNumber.
]

{ #category : #'private-initialization' }
TTGlyph >> updateRightSideBearing [
	"Update the right side bearing value"
	"@@: Is the following really correct?!?!"
	rightSideBearing := advanceWidth - leftSideBearing - bounds corner x + bounds origin x
]
