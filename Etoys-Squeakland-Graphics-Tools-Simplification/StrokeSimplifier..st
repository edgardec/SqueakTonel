"
I represent a very simple algorithm for simplifying an input stroke. See class side for an example.
"
Class {
	#name : #StrokeSimplifier,
	#superclass : #Object,
	#instVars : [
		'points',
		'firstPoint',
		'finalPoint',
		'lastPoint',
		'lastStrokePoint',
		'lastStrokeIndex',
		'distance',
		'samples',
		'time',
		'removeDuplicates',
		'simplifyStroke',
		'maxDistance',
		'maxSamples',
		'maxTime'
	],
	#category : #'Etoys-Squeakland-Graphics-Tools-Simplification'
}

{ #category : #examples }
StrokeSimplifier class >> flattenExample [		"StrokeSimplifier flattenExample"
	"This example demonstrate how aggressive the stroke recorder simplifies series of points"
	| pts fc lastPt nextPt |
	[Sensor anyButtonPressed] whileFalse.
	fc := FormCanvas on: Display.
	pts := self new.
	lastPt := Sensor cursorPoint.
	pts add: lastPt.
	[Sensor anyButtonPressed] whileTrue:[
		nextPt := Sensor cursorPoint.
		nextPt = lastPt ifFalse:[
			fc line: lastPt to: nextPt width: 3 color: Color black.
			pts add: nextPt.
			lastPt := nextPt.
		].
	].
	pts closeStroke.
	(PolygonMorph vertices: pts finalStroke color: Color transparent borderWidth: 3 borderColor: Color black) makeOpen; addHandles; openInWorld.

]

{ #category : #'instance creation' }
StrokeSimplifier class >> new [
	^self basicNew initialize.
]

{ #category : #'instance creation' }
StrokeSimplifier class >> smoothen: pointList length: unitLength [
	| prevPt curPt nextPt out prevMid nextMid segment length steps deltaT |
	out := WriteStream on: (Array new: pointList size).
	prevPt := pointList at: pointList size-1.
	curPt := pointList last.
	prevMid := (curPt + prevPt) * 0.5.
	1 to: pointList size do:[:i|
		nextPt := pointList at: i.
		nextMid := (nextPt + curPt) * 0.5.
		segment := Bezier2Segment from: prevMid to: nextMid via: curPt.
		length := segment length.
		steps := (length / unitLength) asInteger.
		steps < 1 ifTrue:[steps := 1].
		deltaT := 1.0 / steps.
		1 to: steps-1 do:[:k|
			out nextPut: (segment valueAt: deltaT * k)].
		out nextPut: nextMid.
		prevPt := curPt.
		curPt := nextPt.
		prevMid := nextMid.
	].
	^out contents
]

{ #category : #public }
StrokeSimplifier >> add: aPoint [
	lastPoint ifNotNil:[
		(aPoint = lastPoint position and:[removeDuplicates]) ifTrue:[^false].
	].
	self addPoint: aPoint.
	^true
]

{ #category : #simplification }
StrokeSimplifier >> addFirstPoint [
	"No points in stroke yet. Add the very first point."
	self addNextPoint.
	finalPoint := firstPoint := lastPoint.
	self addPoint: firstPoint position.
]

{ #category : #simplification }
StrokeSimplifier >> addLastPoint [
	self addNextPoint.

]

{ #category : #simplification }
StrokeSimplifier >> addNextPoint [
	lastStrokePoint ifNotNil:[
		lastStrokePoint releaseCachedState.
		lastStrokePoint nextPoint: lastPoint.
		lastPoint prevPoint: lastStrokePoint.
		self simplifyLineFrom: lastPoint.
	].
	lastStrokePoint := lastPoint.
	distance := 0. "Distance since last stroke point"
	samples := 0.	 "Samples since last stroke point"
	time := 0. "Time since last stroke point"
]

{ #category : #simplification }
StrokeSimplifier >> addPoint: aPoint [
	| strokePoint |
	strokePoint := self asStrokePoint: aPoint.
	strokePoint prevPoint: lastPoint.
	lastPoint ifNotNil:[
		lastPoint do:[:pt| lastPoint := pt].
		lastPoint nextPoint: strokePoint.
		lastPoint releaseCachedState].
	lastPoint := strokePoint.
	points add: strokePoint.
	simplifyStroke ifTrue:[self simplifyIncrementally].

]

{ #category : #private }
StrokeSimplifier >> asStrokePoint: aPoint [
	^StrokePoint on: aPoint
]

{ #category : #public }
StrokeSimplifier >> closeStroke [
	"Close the current stroke"
	lastPoint do:[:pt| lastPoint := pt].
	lastPoint nextPoint: firstPoint.
	self simplifyLineFrom: firstPoint.
	firstPoint := firstPoint nextPoint.
	self simplifyLineFrom: firstPoint.
	firstPoint := firstPoint nextPoint.
	self simplifyLineFrom: firstPoint.
	firstPoint prevPoint nextPoint: nil.
	firstPoint prevPoint: nil.	
]

{ #category : #public }
StrokeSimplifier >> currentStroke [
	"Return a copy of the current stroke.
	As far as we have it, that is."
	| pts |
	pts := WriteStream on: (Array new: 100).
	firstPoint do:[:pt| pts nextPut: pt position].
	^pts contents
]

{ #category : #public }
StrokeSimplifier >> finalStroke [
	"Return the final stroke"
	^self currentStroke
]

{ #category : #public }
StrokeSimplifier >> finalizeStroke [
	"Finalize the current stroke, e.g., remove the last point(s) if necessary"
	| prevPt |
	prevPt := lastPoint prevPoint.
	(prevPt prevPoint == nil or:[prevPt position = lastPoint position]) 
		ifFalse:[lastPoint := prevPt].
	lastPoint nextPoint: nil.
	firstPoint do:[:pt| pt isFinal: true].
]

{ #category : #public }
StrokeSimplifier >> firstPoint [
	^firstPoint
]

{ #category : #initialize }
StrokeSimplifier >> initialize [
	removeDuplicates := true.
	simplifyStroke := true.
	maxDistance := 10 squared.
	maxSamples := 10.
	maxTime := 1000.
	self reset.
]

{ #category : #public }
StrokeSimplifier >> next [
	"Returns the next 'final' point, e.g., one that will not be affected by simplification later"
	| thePoint |
	(finalPoint notNil and:[finalPoint isFinal]) ifFalse:[^nil].
	thePoint := finalPoint.
	finalPoint := finalPoint nextPoint.
	^thePoint
]

{ #category : #public }
StrokeSimplifier >> pointsDo: aBlock [
	firstPoint ifNil:[^self].
	firstPoint do: aBlock.
]

{ #category : #initialize }
StrokeSimplifier >> reset [
	points := OrderedCollection new: 100.
	lastPoint := nil.
	lastStrokePoint := nil.
]

{ #category : #simplification }
StrokeSimplifier >> simplifyIncrementally [
	"Simplify the last point that was added"
	| prevPt dir |
	lastStrokePoint ifNil:[^self addFirstPoint].
	prevPt := (points at: points size-1).
	dir := lastPoint position - prevPt position.
	distance := distance + (dir dotProduct: dir). "e.g., distance^2"
	samples := samples + 1.
	"time := time + (points last key - (points at: points size-1) key)."
	"If we have sampled too many points or went too far,
	add the next point. This may eventually result in removing earlier points."
	(samples >= maxSamples or:[distance >= maxDistance "or:[time > maxTime]"]) 
		ifTrue:[^self addNextPoint].
	"Note: We may want to add a time/speed feature in the future."
]

{ #category : #simplification }
StrokeSimplifier >> simplifyLineFrom: p5 [
	"Remove a point if it represents the intermediate point of a line.
	We only remove 'inner' points of a line, that is, for a sequence of points like

	p1----p2----p3----p4---p5

	we will remove only p3. This is so that any curve can be adequately represented, e.g., so that for a stroke running like:

		p0
		 |
		p1----p2----p3----p4----p5
							   |
							   |
							  p6
	we will neither touch p2 (required for the curve p0,p1,p2) nor p5 yet (the shape of the curve relies on p6 which is not yet recorded."
	| p4 p3 p2 p1 d1 d2 d3 d4 cosValue |
	p4 := p5 prevPoint ifNil:[^self].
	"Note: p4 (actually p1 from above) is final after we know the next point."
	p3 := p4 prevPoint ifNil:[^p4 isFinal: true].
	p2 := p3 prevPoint ifNil:[^self].
	p1 := p2 prevPoint ifNil:[^self].
	"First, compute the change in direction at p3 (this is the point we are *really* interested in)."
	d2 := p2 forwardDirection.
	d3 := p3 forwardDirection.
	cosValue := d2 dotProduct: d3.

	"See if the change is below the threshold for linearity.
	Note that the above computes the cosine of the directional change
	at p2,p3,p4 so that a value of 1.0 means no change at all, and -1.0
	means a reversal of 180 degrees."
	cosValue < 0.99 ifTrue:[
		"0.999 arcCos radiansToDegrees is approx. 2.56 degrees.
		If the cosine is less than we consider this line to be curved."
		^p2 isFinal: true]. "we're done here"

	"Okay, so the line is straight. Now make sure that the previous and the
	next segment are straight as well (so that we don't remove a point which
	defines the start/end of a curved segment)"

	d1 := p1 forwardDirection.
	cosValue := d1 dotProduct: d2.
	cosValue < 0.95 ifTrue:[
		"0.99 arcCos radiansToDegrees is approx. 8 degrees"
		^p2 isFinal: true].

	"And the same for the last segment"
	d4 := p4 forwardDirection.
	cosValue := d3 dotProduct: d4.
	cosValue < 0.95 ifTrue:[
		"0.99 arcCos radiansToDegrees is approx. 8 degrees"
		^p2 isFinal: true].

	"Okay, so p3 defines an inner point of a pretty straight line.
	Let's get rid of it."
	p2 nextPoint: p4.
	p4 prevPoint: p2.
	p2 releaseCachedState.
	p3 releaseCachedState.
	p4 releaseCachedState.
]
