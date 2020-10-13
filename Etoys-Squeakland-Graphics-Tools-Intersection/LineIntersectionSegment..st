"
I represent a line segment used during the computation of intersections.

Instance variables:
	referentEdge	<LineSegment>	The line segment this segment originated from.

"
Class {
	#name : #LineIntersectionSegment,
	#superclass : #LineSegment,
	#instVars : [
		'referentEdge'
	],
	#category : #'Etoys-Squeakland-Graphics-Tools-Intersection'
}

{ #category : #accessing }
LineIntersectionSegment >> referentEdge [
	^referentEdge
]

{ #category : #accessing }
LineIntersectionSegment >> referentEdge: anEdge [
	referentEdge := anEdge
]
