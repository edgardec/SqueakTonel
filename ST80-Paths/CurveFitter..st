"
I represent a conic section determined by three points p1, p2 and p3. I interpolate p1 and p3 and am tangent to line p1, p2 at p1 and line p3, p2 at p3.
"
Class {
	#name : #CurveFitter,
	#superclass : #Path,
	#category : #'ST80-Paths'
}

{ #category : #examples }
CurveFitter class >> example [
	"Designate three locations on the screen by clicking any button. The
	curve determined by the points will be displayed with a long black form."

	| aCurveFitter aForm |  
	aForm := Form extent: 1@30.			"make a long thin Form for display "
	aForm fillBlack.							"turn it black"
	aCurveFitter := CurveFitter new.
	aCurveFitter form: aForm.						"set the form for display"
				"collect three Points and show them on the dispaly"
	aCurveFitter firstPoint: Sensor waitButton. Sensor waitNoButton.
	aForm displayOn: Display at: aCurveFitter firstPoint.
	aCurveFitter secondPoint: Sensor waitButton. Sensor waitNoButton.
	aForm displayOn: Display at: aCurveFitter secondPoint.
	aCurveFitter thirdPoint: Sensor waitButton. Sensor waitNoButton.
	aForm displayOn: Display at: aCurveFitter thirdPoint.

	aCurveFitter displayOn: Display					"display the CurveFitter"

	"CurveFitter example"
]

{ #category : #'instance creation' }
CurveFitter class >> new [

	| newSelf | 
	newSelf := super new: 3.
	newSelf add: 0@0.
	newSelf add: 0@0.
	newSelf add: 0@0.
	^newSelf
]

{ #category : #displaying }
CurveFitter >> displayOn: aDisplayMedium at: aPoint clippingBox: clipRect rule: anInteger fillColor: aForm [

	| pa pb k s p1 p2 p3 line |
	line := Line new.
	line form: self form.
	collectionOfPoints size < 3 ifTrue: [self error: 'Curve must have three points'].
	p1 := self firstPoint.
	p2 := self secondPoint.
	p3 := self thirdPoint.
	s := Path new.
	s add: p1.
	pa := p2 - p1.
	pb := p3 - p2.
	k := 5 max: pa x abs + pa y abs + pb x abs + pb y abs // 20.
	"k is a guess as to how many line segments to use to approximate 
	the curve."
	1 to: k do: 
		[:i | 
		s add: pa * i // k + p1 * (k - i) + (pb * (i - 1) // k + p2 * (i - 1)) // (k - 1)].
	s add: p3.
	1 to: s size - 1 do: 
		[:i | 
		line beginPoint: (s at: i).
		line endPoint: (s at: i + 1).
		line displayOn: aDisplayMedium
			at: aPoint
			clippingBox: clipRect
			rule: anInteger
			fillColor: aForm]
]

{ #category : #displaying }
CurveFitter >> displayOn: aDisplayMedium transformation: aTransformation clippingBox: clipRect rule: anInteger fillColor: aForm [

	| transformedPath newCurveFitter |
	transformedPath := aTransformation applyTo: self.
	newCurveFitter := CurveFitter new.
	newCurveFitter firstPoint: transformedPath firstPoint.
	newCurveFitter secondPoint: transformedPath secondPoint.
	newCurveFitter thirdPoint: transformedPath thirdPoint.
	newCurveFitter form: self form.
	newCurveFitter
		displayOn: aDisplayMedium
		at: 0 @ 0
		clippingBox: clipRect
		rule: anInteger
		fillColor: aForm
]
