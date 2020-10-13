"
I represent an event that occurs during the computation of line segment intersections.

Instance variables:
	position		<Point>	The position of where this event occurs
	type		<Symbol>	The type of the event
	edge		<LineIntersectionSegment>	The edge associated with this event.
	crossedEdge	<LineIntersectionSegment>	The crossing edge of a #cross event.
"
Class {
	#name : #LineIntersectionEvent,
	#superclass : #Object,
	#instVars : [
		'position',
		'type',
		'segment',
		'crossedEdge'
	],
	#category : #'Etoys-Squeakland-Graphics-Tools-Intersection'
}

{ #category : #'instance creation' }
LineIntersectionEvent class >> type: aSymbol position: aPoint segment: aSegment [
	^self new type: aSymbol position: aPoint segment: aSegment
]

{ #category : #accessing }
LineIntersectionEvent >> crossedEdge [
	^crossedEdge
]

{ #category : #accessing }
LineIntersectionEvent >> crossedEdge: aSegment [
	crossedEdge := aSegment
]

{ #category : #accessing }
LineIntersectionEvent >> edge [
	^segment
]

{ #category : #accessing }
LineIntersectionEvent >> position [
	^position
]

{ #category : #accessing }
LineIntersectionEvent >> priority [
	"Return the priority for this event"
	type == #start ifTrue:[^3]. "first insert new segments"
	type == #cross ifTrue:[^2]. "then process intersections"
	type == #end ifTrue:[^1]. "then remove edges"
	^self error:'Unknown type'
]

{ #category : #accessing }
LineIntersectionEvent >> segment [
	^segment
]

{ #category : #sorting }
LineIntersectionEvent >> sortsBefore: anEvent [
	(self position x = anEvent position x and:[self position y = anEvent position y])
		ifFalse:[^self position sortsBefore: anEvent position].
	^self priority > anEvent priority
]

{ #category : #accessing }
LineIntersectionEvent >> type [
	^type
]

{ #category : #'initialize-release' }
LineIntersectionEvent >> type: aSymbol position: aPoint segment: aSegment [
	type := aSymbol.
	position := aPoint.
	segment := aSegment.
]
