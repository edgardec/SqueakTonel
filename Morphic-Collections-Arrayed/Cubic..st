"
I am a segment between two points. In the form of a cubic polynomial that can be evaluated between 0..1 to obtain the end points and intermediate values.

"
Class {
	#name : #Cubic,
	#superclass : #Array,
	#type : #variable,
	#category : #'Morphic-Collections-Arrayed'
}

{ #category : #'cubic support' }
Cubic >> bestSegments [
	"Return the smallest integer number of segments that give the 
	best curve."
	^ self honeIn: self calcEnoughSegments
]

{ #category : #'cubic support' }
Cubic >> calcEnoughSegments [
	"Find the power of two that represents a sufficient number of  
	segments for this cubic.  
	The measure is the sum of distances for the segments.  
	We want this to be close enough not affect the straightness of  
	the drawn lines. Which means within one pixel."
	"^ self 
	enough: 2 
	withMeasure: (self measureFor: 1) 
	withIn: self leeway 
	This ran into a problem when the curve was an s-curve with 
	inflections. Besides honeIn will check to see if 1 is better than 
	two so we lose nothing by starting a little higher."
	^ self
		enough: 4
		withMeasure: (self measureFor: 2)
		withIn: self leeway
]

{ #category : #'cubic support' }
Cubic >> enough: nTry withMeasure: lastMeasure withIn: closeEnough [
"See comment in calcEnoughSegments for which I am a helper"
	| measure |
	measure := self measureFor: nTry.
	measure > (lastMeasure + closeEnough)
		ifFalse: [^ nTry // 2].
	^ self
		enough: 2 * nTry
		withMeasure: measure
		withIn: closeEnough
]

{ #category : #'cubic support' }
Cubic >> honeIn: enough [ 
	"Find if there is a smaller n than enough that give the same  
	measure for n."
	
	enough < 2 ifTrue: [ ^enough].
	^ self
		honeIn: enough
		step: enough // 2
		measure: (self measureFor: enough)
		withIn: self leeway
]

{ #category : #'cubic support' }
Cubic >> honeIn: centerN step: step measure: measure withIn: closeEnough [ 
	"Pick the best n by binary search."
	| nTry |
	step < 1
		ifTrue: [^ centerN].
	nTry := centerN - step.
	^ measure > (closeEnough
				+ (self measureFor: nTry))
		ifTrue: [self
				honeIn: centerN
				step: step // 2
				measure: measure
				withIn: closeEnough]
		ifFalse: [self
				honeIn: nTry
				step: step // 2
				measure: measure
				withIn: closeEnough]
]

{ #category : #'cubic support' }
Cubic >> leeway [
	"How close can measure be"
	^ 0.1
]

{ #category : #'cubic support' }
Cubic >> measureFor: n [ 
	"Return a distance measure for cubic curve with n segments. 
	For convienence and accuracy we use the sum of the
	distances. "
	"first point is poly of 0."
	| p1 measure |
	p1 := self at: 1.
	measure := 0.
	1 to: n do: [ :i |
		| x p2 |
		x := i asFloat / n.
		p2 := self polynomialEval: x @ x.
		measure := measure + (p2 dist: p1).
		p1 := p2 ].
	^measure
]
