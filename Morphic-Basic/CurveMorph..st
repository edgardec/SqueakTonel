"
This is really only a shell for creating Shapes with smooth outlines.
"
Class {
	#name : #CurveMorph,
	#superclass : #PolygonMorph,
	#category : #'Morphic-Basic'
}

{ #category : #'instance creation' }
CurveMorph class >> arrowPrototype [

	| aa |
	aa := PolygonMorph vertices: (Array with: 5@40 with: 5@8 with: 35@8 with: 35@40) 
		color: Color black 
		borderWidth: 2 
		borderColor: Color black.
	aa beSmoothCurve; makeOpen; makeForwardArrow.		"is already open"
	aa dashedBorder: {10. 10. Color red}.
		"A dash spec is a 3- or 5-element array with
		{ length of normal border color.
		length of alternate border color.
		alternate border color}"
	aa computeBounds.
	^ aa
]

{ #category : #'parts bin' }
CurveMorph class >> descriptionForPartsBin [
	^ self partName:	'Curve'
		categories:		#('Graphics' 'Basic')
		documentation:	'A smooth wiggly curve, or a curved solid.  Shift-click to get handles and move the points.'
]

{ #category : #initialization }
CurveMorph >> initialize [

	super initialize.
	self beSmoothCurve.

]

{ #category : #'parts bin' }
CurveMorph >> initializeToStandAlone [

	super initializeToStandAlone.
	self beSmoothCurve.

]

{ #category : #testing }
CurveMorph >> isCurvier [
	"Test used by smoothing routines.  If true use true closed curve splines for closed curves. If not mimic old stodgy curveMorph curves with one sharp bend. Curve overrides this test for backward compatability.."
	^ (false)
]
