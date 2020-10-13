Class {
	#name : #StrokePoint,
	#superclass : #Object,
	#instVars : [
		'position',
		'prev',
		'next',
		'flags'
	],
	#category : #'Etoys-Squeakland-Graphics-Tools-Simplification'
}

{ #category : #'instance creation' }
StrokePoint class >> on: aPoint [
	^self new on: aPoint
]

{ #category : #accessing }
StrokePoint >> backwardDirection [
	"Compute the backward direction to the previous point in the stroke."
	| dir |
	dir := prev ifNil:[0@0] ifNotNil:[self position - prev position].
	dir isZero ifFalse:[dir := dir normalized].
	^dir
]

{ #category : #accessing }
StrokePoint >> defineIntermediatePoint [
	"Define an intermediate point for an extreme change in direction"
	| pt |
	pt := self class on: position.
	pt width: self width.
	pt prevPoint: self.
	pt nextPoint: next.
	next ifNotNil:[next prevPoint: pt].
	self nextPoint: pt.
	pt isFinal: self isFinal.
]

{ #category : #enumerating }
StrokePoint >> do: aBlock [
	aBlock value: self.
	next ifNotNil:[next do: aBlock].
]

{ #category : #accessing }
StrokePoint >> forwardDirection [
	"Compute the forward direction to the next point in the stroke."
	| dir |
	dir := next ifNil:[0@0] ifNotNil:[next position - self position].
	dir isZero ifFalse:[dir := dir normalized].
	^dir
]

{ #category : #intersecting }
StrokePoint >> intersectFrom: startPt with: startDir to: endPt with: endDir [
	"Compute the intersection of two lines, e.g., compute alpha and beta for
		startPt + (alpha * startDir) = endPt + (beta * endDir).
	Reformulating this yields
		(alpha * startDir) - (beta * endDir) = endPt - startPt.
	or
		(alpha * startDir) + (-beta * endDir) = endPt - startPt.
	or
		(alpha * startDir x) + (-beta * endDir x) = endPt x - startPt x.
		(alpha * startDir y) + (-beta * endDir y) = endPt y - startPt y.
	which is trivial to solve using Cramer's rule. Note that since
	we're really only interested in the intersection point we need only
	one of alpha or beta since the resulting intersection point can be
	computed based on either one."
	| det deltaPt alpha |
	det := (startDir x * endDir y) - (startDir y * endDir x).
	det = 0.0 ifTrue:[^nil]. "There's no solution for it"
	deltaPt := endPt - startPt.
	alpha := (deltaPt x * endDir y) - (deltaPt y * endDir x).
	alpha := alpha / det.
	"And compute intersection"
	^startPt + (alpha * startDir)
]

{ #category : #flags }
StrokePoint >> isFinal [
	^flags anyMask: 1
]

{ #category : #flags }
StrokePoint >> isFinal: aBool [
	flags := aBool ifTrue:[flags bitOr: 1] ifFalse:[flags bitClear: 1].
	(aBool and:[prev notNil and:[prev isFinal not]]) ifTrue:[prev isFinal: true].
]

{ #category : #flags }
StrokePoint >> isProcessed [
	^flags anyMask: 2
]

{ #category : #flags }
StrokePoint >> isProcessed: aBool [
	flags := aBool ifTrue:[flags bitOr: 2] ifFalse:[flags bitClear: 2].
]

{ #category : #accessing }
StrokePoint >> nextPoint [
	"Return the next point in the stroke"
	^next
]

{ #category : #accessing }
StrokePoint >> nextPoint: aPoint [
	"Set the next point in the stroke"
	next := aPoint
]

{ #category : #initialize }
StrokePoint >> on: aPoint [
	flags := 0.
	self position: aPoint.
]

{ #category : #accessing }
StrokePoint >> position [
	"Return the position of the receiver"
	^position
]

{ #category : #accessing }
StrokePoint >> position: aPoint [
	"Set the position of the receiver to aPoint"
	position := aPoint.
]

{ #category : #accessing }
StrokePoint >> prevPoint [
	"Return the previous point of the stroke"
	^prev
]

{ #category : #accessing }
StrokePoint >> prevPoint: aPoint [
	"Set the previous point of the stroke"
	prev := aPoint
]

{ #category : #printing }
StrokePoint >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut:$(; print: position; nextPut:$).
]

{ #category : #initialize }
StrokePoint >> releaseCachedState [
]

{ #category : #accessing }
StrokePoint >> removeIntermediatePoint [
	"Remove an intermediate point for an extreme change in direction"
	next ifNil:[^self].
	prev ifNil:[^self].
	next position = self position ifTrue:[
		next := next nextPoint.
		next ifNotNil:[next prevPoint: self].
		^self removeIntermediatePoint]
]
