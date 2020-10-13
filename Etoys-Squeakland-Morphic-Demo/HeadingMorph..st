Class {
	#name : #HeadingMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'degrees',
		'magnitude'
	],
	#category : #'Etoys-Squeakland-Morphic-Demo'
}

{ #category : #initialization }
HeadingMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
HeadingMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color
		r: 0.6
		g: 1.0
		b: 1.0
]

{ #category : #accessing }
HeadingMorph >> degrees [

	^ (degrees + 90.0) \\ 360.0
]

{ #category : #accessing }
HeadingMorph >> degrees: aNumber [

	degrees := (aNumber asFloat + 270.0) \\ 360.0.
]

{ #category : #drawing }
HeadingMorph >> drawArrowFrom: p1 to: p2 width: w color: aColor on: aCanvas [

	| d p |
	d := (p1 - p2) theta radiansToDegrees.
	aCanvas line: p1 to: p2 width: w color: aColor.
	p := p2 + (Point r: 5 degrees: d - 50).
	aCanvas line: p to: p2 width: w color: aColor.
	p := p2 + (Point r: 5 degrees: d + 50).
	aCanvas line: p to: p2 width: w color: aColor.

]

{ #category : #drawing }
HeadingMorph >> drawOn: aCanvas [

	| x y r center box |
	super drawOn: aCanvas.
	box := self innerBounds.
	1 to: 9 do: [:i |
		x := box left + ((box width * i) // 10).
		aCanvas line: (x@box top) to: (x@(box bottom - 1)) color: 
Color black.
		y := box top + ((box height * i) // 10).
		aCanvas line: (box left@y) to: ((box right - 1)@y) color: 
Color black].

	r := ((box width asFloat * magnitude asFloat) / 2.0) - 1.0.
	center := box center.
	self drawArrowFrom: center - (1@1)
		to: center + ((r * degrees degreesToRadians cos)@0) - (1@1)
		width: 3
		color: (Color red)
		on: aCanvas.
	self drawArrowFrom: center - (1@1)
		to: center + (0@(r * degrees degreesToRadians sin)) - (1@1)
		width: 3
		color: (Color red)
		on: aCanvas.
	self drawArrowFrom: center - (1@1)
		to: center + (Point r: r degrees: degrees) - (1@1)
		width: 3
		color: Color black
		on: aCanvas.

]

{ #category : #geometry }
HeadingMorph >> extent: aPoint [
	"Contrain extent to be square."

	| d |
	d := aPoint x min: aPoint y.
	super extent: d@d.

]

{ #category : #'event handling' }
HeadingMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
HeadingMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	degrees := 90.0.
	magnitude := 1.0.
	
	self extent: 160 @ 160
]

{ #category : #accessing }
HeadingMorph >> magnitude [

	^ magnitude
]

{ #category : #accessing }
HeadingMorph >> magnitude: aNumber [

	magnitude := (aNumber asFloat max: 0.0) min: 1.0.
]

{ #category : #events }
HeadingMorph >> mouseDown: evt [

	| v |
	self changed.
	v := evt cursorPoint - bounds center.
	degrees := v theta radiansToDegrees.
	magnitude := (v r asFloat / (bounds width asFloat / 2.0)) min: 1.0.

]

{ #category : #events }
HeadingMorph >> mouseMove: evt [

	self mouseDown: evt
]
