"
I represent a collection of Points through which a cubic spline curve is fitted.
"
Class {
	#name : #Spline,
	#superclass : #Path,
	#instVars : [
		'coefficients'
	],
	#category : #'ST80-Paths'
}

{ #category : #examples }
Spline class >> example [
	"Designate points on the Path by clicking the red button. Terminate by
	pressing any other button. A curve will be displayed, through the
	selected points, using a long black form."

	| splineCurve aForm flag|
	aForm := Form extent: 2@2.
	aForm  fillBlack.
	splineCurve := Spline new.
	splineCurve form: aForm.
	flag := true.
	[flag] whileTrue:
		[Sensor waitButton.
		 Sensor redButtonPressed
			ifTrue: 
				[splineCurve add: Sensor waitButton. 
				 Sensor waitNoButton.
				 aForm displayOn: Display at: splineCurve last]
			ifFalse: [flag:=false]].
	splineCurve computeCurve.
	splineCurve isEmpty 
		ifFalse: [splineCurve displayOn: Display.
				Sensor waitNoButton].
 
	"Spline example"
]

{ #category : #accessing }
Spline >> coefficients [
	"Answer an eight-element Array of Arrays each of which is the length 
	of the receiver. The first four arrays are the values, first, second and 
	third derivatives, respectively, for the parametric spline in x. The last 
	four elements are for y."

	^coefficients
]

{ #category : #displaying }
Spline >> computeCurve [
	"Compute an array for the coefficients."

	| length extras |
	length := self size.
	extras := 0.
	coefficients := Array new: 8.
	1 to: 8 do: [:i | coefficients at: i put: (Array new: length + extras)].
	1 to: 5 by: 4 do: 
		[:k | 
		1 to: length do:
			[:i | (coefficients at: k)
					at: i put: (k = 1
						ifTrue: [(self at: i) x asFloat]
						ifFalse: [(self at: i) y asFloat])].
			1 to: extras do: [:i | (coefficients at: k)
					at: length + i put: ((coefficients at: k)
						at: i + 1)].
			self derivs: (coefficients at: k)
				first: (coefficients at: k + 1)
				second: (coefficients at: k + 2)
				third: (coefficients at: k + 3)].
	extras > 0 
		ifTrue: [1 to: 8 do: 
					[:i | 
					coefficients at: i put: ((coefficients at: i)
											copyFrom: 2 to: length + 1)]]
]

{ #category : #private }
Spline >> derivs: a first: point1 second: point2 third: point3 [
	"Compute the first, second and third derivitives (in coefficients) from
	the Points in this Path (coefficients at: 1 and coefficients at: 5)."

	| l v anArray |
	l := a size.
	l < 2 ifTrue: [^self].
	l > 2
	  ifTrue:
		[v := Array new: l.
		 v  at:  1 put: 4.0.
		 anArray := Array new: l.
		 anArray  at:  1 put: (6.0 * ((a  at:  1) - ((a  at:  2) * 2.0) + (a  at:  3))).
		 2 to: l - 2 do:
			[:i | 
			v  at:  i put: (4.0 - (1.0 / (v  at:  (i - 1)))).
			anArray
				at:  i 
				put: (6.0 * ((a  at:  i) - ((a  at:  (i + 1)) * 2.0) + (a  at:  (i + 2)))
						- ((anArray  at:  (i - 1)) / (v  at:  (i - 1))))].
		 point2  at: (l - 1) put: ((anArray  at:  (l - 2)) / (v  at:  (l - 2))).
		 l - 2 to: 2 by: 0-1 do: 
			[:i | 
			point2 
				at: i 
				put: ((anArray  at:  (i - 1)) - (point2  at:  (i + 1)) / (v  at:  (i - 1)))]].
	point2 at: 1 put: (point2  at:  l put: 0.0).
	1 to: l - 1 do:
		[:i | point1 
				at: i 
				put: ((a at: (i + 1)) - (a  at:  i) - 
						((point2  at:  i) * 2.0 + (point2  at:  (i + 1)) / 6.0)).
		      point3 at: i put: ((point2  at:  (i + 1)) - (point2  at:  i))]
]

{ #category : #displaying }
Spline >> displayOn: aDisplayMedium at: aPoint clippingBox: clipRect rule: anInteger fillColor: aForm [ 
	"Display the receiver, a spline curve, approximated by straight line
	segments."

	| n line t x y x1 x2 x3 y1 y2 y3 |
	collectionOfPoints size < 1 ifTrue: [self error: 'a spline must have at least one point'].
	line := Line new.
	line form: self form.
	line beginPoint: 
		(x := (coefficients at: 1) at: 1) rounded @ (y := (coefficients at: 5) at: 1) rounded.
	1 to: (coefficients at: 1) size - 1 do: 
		[:i | 
		"taylor series coefficients"
		x1 := (coefficients at: 2) at: i.
		y1 := (coefficients at: 6) at: i.
		x2 := ((coefficients at: 3) at: i) / 2.0.
		y2 := ((coefficients at: 7) at: i) / 2.0.
		x3 := ((coefficients at: 4) at: i) / 6.0.
		y3 := ((coefficients at: 8) at: i) / 6.0.
		"guess n"
		n := 5 max: (x2 abs + y2 abs * 2.0 + ((coefficients at: 3)
							at: i + 1) abs + ((coefficients at: 7)
							at: i + 1) abs / 100.0) rounded.
		1 to: n - 1 do: 
			[:j | 
			t := j asFloat / n.
			line endPoint: 
				(x3 * t + x2 * t + x1 * t + x) rounded 
							@ (y3 * t + y2 * t + y1 * t + y) rounded.
			line
				displayOn: aDisplayMedium
				at: aPoint
				clippingBox: clipRect
				rule: anInteger
				fillColor: aForm.
			line beginPoint: line endPoint].
		line beginPoint: 
				(x := (coefficients at: 1) at: i + 1) rounded 
					@ (y := (coefficients at: 5) at: i + 1) rounded.
		line
			displayOn: aDisplayMedium
			at: aPoint
			clippingBox: clipRect
			rule: anInteger
			fillColor: aForm]
]

{ #category : #displaying }
Spline >> displayOn: aDisplayMedium transformation: aTransformation clippingBox: clipRect rule: anInteger fillColor: aForm [ 
	"Get the scaled and translated path of newKnots."

	| newKnots newSpline |
	newKnots := aTransformation applyTo: self.
	newSpline := Spline new.
	newKnots do: [:knot | newSpline add: knot].
	newSpline form: self form.
	newSpline
		displayOn: aDisplayMedium
		at: 0 @ 0
		clippingBox: clipRect
		rule: anInteger
		fillColor: aForm
]
