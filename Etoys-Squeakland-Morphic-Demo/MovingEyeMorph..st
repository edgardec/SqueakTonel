Class {
	#name : #MovingEyeMorph,
	#superclass : #EllipseMorph,
	#instVars : [
		'inner',
		'iris'
	],
	#classVars : [
		'IrisSize'
	],
	#category : #'Etoys-Squeakland-Morphic-Demo'
}

{ #category : #'parts bin' }
MovingEyeMorph class >> descriptionForPartsBin [
	^ self partName:	'MovingEye' translatedNoop
		categories:		{'Just for Fun' translatedNoop}
		documentation:	'An eye which follows the cursor' translatedNoop
]

{ #category : #'class initialization' }
MovingEyeMorph class >> initialize [
"
	MovingEyeMorph initialize
"
	IrisSize := (0.42@0.50).
]

{ #category : #accessing }
MovingEyeMorph >> color: aColor [

	super color: aColor.
	
	"Migrate old instances."
	inner color: Color transparent.
	
	"Keep iris visible."
	aColor = iris color
		ifTrue: [iris borderWidth: 1; borderColor: aColor negated]
		ifFalse: [iris borderWidth: 0].
]

{ #category : #initialization }
MovingEyeMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color black
]

{ #category : #geometry }
MovingEyeMorph >> extent: aPoint [

	super extent: aPoint.
	inner extent: (self extent * ((1.0@1.0)-IrisSize)) asIntegerPoint.
	iris extent: (self extent * IrisSize) asIntegerPoint.
	inner position: (self center - (inner extent // 2)) asIntegerPoint.

]

{ #category : #initialization }
MovingEyeMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	inner := EllipseMorph new.
	inner color: Color transparent.
	inner extent: (self extent * (1.0 @ 1.0 - IrisSize)) asIntegerPoint.
	inner borderWidth: 0.
""
	iris := EllipseMorph new.
	iris color: Color white.
	iris extent: (self extent * IrisSize) asIntegerPoint.
""
	self addMorphCentered: inner.
	inner addMorphCentered: iris.
""
	self extent: 26 @ 33
]

{ #category : #accessing }
MovingEyeMorph >> irisColor [

	^ iris color
]

{ #category : #accessing }
MovingEyeMorph >> irisColor: aColor [

	iris color: aColor.
	
	"Keep iris visible."
	aColor = self color
		ifTrue: [iris borderWidth: 1; borderColor: aColor negated]
		ifFalse: [iris borderWidth: 0].
]

{ #category : #accessing }
MovingEyeMorph >> irisPos [

	^ iris position
]

{ #category : #accessing }
MovingEyeMorph >> irisPos: cp [

	| a b theta x y |
	theta := (cp - self center) theta.
	a := inner width // 2.
	b := inner height // 2.
	x := a * (theta cos).
	y := b * (theta sin).
	iris position: ((x@y) asIntegerPoint) + self center - (iris extent // 2).
]

{ #category : #'stepping and presenter' }
MovingEyeMorph >> step [
	| cp |
	cp := self globalPointToLocal: self world primaryHand position.
	(inner containsPoint: cp)
		ifTrue: [iris position: (cp - (iris extent // 2))]
		ifFalse: [self irisPos: cp].
]

{ #category : #testing }
MovingEyeMorph >> stepTime [

	^ 100.
]
