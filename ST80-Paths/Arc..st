"
Arcs are an unusual implementation of splines due to Ted Kaehler.  Imagine two lines that meet at a corner. Now imagine two moving points; one moves from the corner to the end on one line, the other moves from the end of the other line in to the corner.  Now imagine a series of lines drawn between those moving points at each step along the way (they form a sort of spider web pattern).  By connecting segments of the intersecting lines, a smooth curve is achieved that is tangent to both of the original lines.  Voila.
"
Class {
	#name : #Arc,
	#superclass : #Path,
	#instVars : [
		'quadrant',
		'radius',
		'center'
	],
	#category : #'ST80-Paths'
}

{ #category : #examples }
Arc class >> example [
	"Click the button somewhere on the screen. The designated point will
	be the center of an Arc with radius 50 in the 4th quadrant."

	| anArc aForm |
	aForm := Form extent: 1 @ 30.	"make a long thin Form for display"
	aForm fillBlack.						"turn it black"
	anArc := Arc new.
	anArc form: aForm.					"set the form for display"
	anArc radius: 50.0.
	anArc center: Sensor waitButton.
	anArc quadrant: 4.
	anArc displayOn: Display.
	Sensor waitButton

	"Arc example"
]

{ #category : #accessing }
Arc >> center [
	"Answer the point at the center of the receiver."

	^center
]

{ #category : #accessing }
Arc >> center: aPoint [ 
	"Set aPoint to be the receiver's center."

	center := aPoint
]

{ #category : #accessing }
Arc >> center: aPoint radius: anInteger [ 
	"The receiver is defined by a point at the center and a radius. The 
	quadrant is not reset."

	center := aPoint.
	radius := anInteger
]

{ #category : #accessing }
Arc >> center: aPoint radius: anInteger quadrant: section [ 
	"Set the receiver's quadrant to be the argument, section. The size of the 
	receiver is defined by the center and its radius."

	center := aPoint.
	radius := anInteger.
	quadrant := section
]

{ #category : #'display box access' }
Arc >> computeBoundingBox [
	| aRectangle aPoint |
	aRectangle := center - radius + form offset extent: form extent + (radius * 2) asPoint.
	aPoint := center + form extent.
	quadrant = 1 ifTrue: [^ aRectangle encompass: center x @ aPoint y].
	quadrant = 2 ifTrue: [^ aRectangle encompass: aPoint x @ aPoint y].
	quadrant = 3 ifTrue: [^ aRectangle encompass: aPoint x @ center y].
	quadrant = 4 ifTrue: [^ aRectangle encompass: center x @ center y]
]

{ #category : #displaying }
Arc >> displayOn: aDisplayMedium at: aPoint clippingBox: clipRect rule: anInteger fillColor: aForm [

	| nSegments line angle sin cos xn yn |
	nSegments := 12.0.
	line := Line new.
	line form: self form.
	angle := (90.0 / nSegments) degreesToRadians.
	sin := angle sin.
	cos := angle cos.
	quadrant = 1
		ifTrue: 
			[xn := radius asFloat.
			yn := 0.0].
	quadrant = 2
		ifTrue: 
			[xn := 0.0.
			yn := 0.0 - radius asFloat].
	quadrant = 3
		ifTrue: 
			[xn := 0.0 - radius asFloat.
			yn := 0.0].
	quadrant = 4
		ifTrue: 
			[xn := 0.0.
			yn := radius asFloat].
	nSegments asInteger
		timesRepeat: 
			[ | xn1 yn1 |
			xn1 := xn * cos + (yn * sin).
			yn1 := yn * cos - (xn * sin).
			line beginPoint: center + (xn asInteger @ yn asInteger).
			line endPoint: center + (xn1 asInteger @ yn1 asInteger).
			line
				displayOn: aDisplayMedium
				at: aPoint
				clippingBox: clipRect
				rule: anInteger
				fillColor: aForm.
			xn := xn1.
			yn := yn1]
]

{ #category : #displaying }
Arc >> displayOn: aDisplayMedium transformation: aTransformation clippingBox: clipRect rule: anInteger fillColor: aForm [

	| newArc tempCenter |
	newArc := Arc new.
	tempCenter := aTransformation applyTo: self center.
	newArc center: tempCenter x asInteger @ tempCenter y asInteger.
	newArc quadrant: self quadrant.
	newArc radius: (self radius * aTransformation scale x) asInteger.
	newArc form: self form.
	newArc
		displayOn: aDisplayMedium
		at: 0 @ 0
		clippingBox: clipRect
		rule: anInteger
		fillColor: aForm
]

{ #category : #accessing }
Arc >> quadrant [
	"Answer the part of the circle represented by the receiver."
	^quadrant
]

{ #category : #accessing }
Arc >> quadrant: section [ 
	"Set the part of the circle represented by the receiver to be the argument, 
	section."

	quadrant := section
]

{ #category : #accessing }
Arc >> radius [
	"Answer the receiver's radius."

	^radius
]

{ #category : #accessing }
Arc >> radius: anInteger [ 
	"Set the receiver's radius to be the argument, anInteger."

	radius := anInteger
]
