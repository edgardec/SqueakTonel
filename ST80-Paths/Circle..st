"
I represent a full circle. I am made from four Arcs.
"
Class {
	#name : #Circle,
	#superclass : #Arc,
	#category : #'ST80-Paths'
}

{ #category : #examples }
Circle class >> exampleOne [ 
	"Click any button somewhere on the screen. The point will be the center
	of the circcle of radius 150."

	| aCircle aForm |
	aForm := Form extent: 1@30.
	aForm fillBlack.
	aCircle := Circle new.
	aCircle form: aForm.
	aCircle radius: 150.
	aCircle center: Sensor waitButton.
	aCircle displayOn: Display
	
	"Circle exampleOne"
]

{ #category : #examples }
Circle class >> exampleTwo [
	"Designate a rectangular area that should be used as the brush for
	displaying the circle. Click any button at a point on the screen which
	will be the center location for the circle. The curve will be displayed
	with a long black form."

	| aCircle aForm |
	aForm := Form fromUser.
	aCircle := Circle new.
	aCircle form: aForm.
	aCircle radius: 150.
	aCircle center: Sensor waitButton.
	aCircle displayOn: Display at: 0 @ 0 rule: Form reverse
 
	 "Circle exampleTwo"
]

{ #category : #'display box access' }
Circle >> computeBoundingBox [

	^center - radius + form offset extent: form extent + (radius * 2) asPoint
]

{ #category : #displaying }
Circle >> displayOn: aDisplayMedium at: aPoint clippingBox: clipRect rule: anInteger fillColor: aForm [

	1 to: 4 do:
		[:i |
		super quadrant: i.
		super displayOn: aDisplayMedium
			at: aPoint
			clippingBox: clipRect
			rule: anInteger
			fillColor: aForm]
]

{ #category : #displaying }
Circle >> displayOn: aDisplayMedium transformation: aTransformation clippingBox: clipRect rule: anInteger fillColor: aForm [

	1 to: 4 do:
		[:i |
		super quadrant: i.
		super displayOn: aDisplayMedium
			transformation: aTransformation
			clippingBox: clipRect
			rule: anInteger
			fillColor: aForm]
]
