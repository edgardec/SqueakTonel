"
I represent a half-edge within a subdivision.
"
Class {
	#name : #SubdivisionHalfEdge,
	#superclass : #Object,
	#instVars : [
		'id',
		'point',
		'quadEdge',
		'next'
	],
	#category : #'Etoys-Squeakland-Graphics-Tools-Triangulation'
}

{ #category : #accessing }
SubdivisionHalfEdge class >> splice: edge1 with: edge2 [
	"This operator affects the two edge rings around the origins of a and b,
	and, independently, the two edge rings around the left faces of a and b.
	In each case, (i) if the two rings are distinct, Splice will combine
	them into one; (ii) if the two are the same ring, Splice will break it
	into two separate pieces.
	Thus, Splice can be used both to attach the two edges together, and
	to break them apart. See Guibas and Stolfi (1985) p.96 for more details
	and illustrations."
	| alpha beta t1 t2 t3 t4 |
	alpha := edge1 originNext rotated.
	beta := edge2 originNext rotated.

	t1 := edge2 originNext.
	t2 := edge1 originNext.
	t3 := beta originNext.
	t4 := alpha originNext.

	edge1 next: t1.
	edge2 next: t2.
	alpha next: t3.
	beta next: t4.
]

{ #category : #private }
SubdivisionHalfEdge >> ccw: a with: b with: c [

	^(self triArea: a with: b with: c) > 0.0
]

{ #category : #accessing }
SubdivisionHalfEdge >> center [
	^self origin + self destination * 0.5
]

{ #category : #accessing }
SubdivisionHalfEdge >> classificationColor [
	^quadEdge classificationColor
]

{ #category : #accessing }
SubdivisionHalfEdge >> classificationIndex [
	"Return the classification index of the receiver"
	^quadEdge classificationIndex
]

{ #category : #private }
SubdivisionHalfEdge >> collectQuadEdgesInto: aSet [

	(aSet includes: quadEdge) ifTrue:[^self].
	aSet add: quadEdge.
	self originNext collectQuadEdgesInto: aSet.
	self originPrev collectQuadEdgesInto: aSet.
	self destNext collectQuadEdgesInto: aSet.
	self destPrev collectQuadEdgesInto: aSet.
	^aSet
]

{ #category : #'topological operators' }
SubdivisionHalfEdge >> connectEdge: edge [
	"Add a new edge e connecting the destination of a to the
	origin of b, in such a way that all three have the same
	left face after the connection is complete.
	Additionally, the data pointers of the new edge are set."
	| e |
	e := self quadEdgeClass new.
	e first spliceEdge: self leftNext.
	e first symmetric spliceEdge: edge.
	(e first) origin: self destination; destination: edge origin.
	^e
]

{ #category : #'topological operators' }
SubdivisionHalfEdge >> deleteEdge [

	self spliceEdge: self originPrev.
	self symmetric spliceEdge: self symmetric originPrev.
]

{ #category : #accessing }
SubdivisionHalfEdge >> destNext [
	"Return the next ccw edge around (into) the destination of the current edge."
	^self symmetric originNext symmetric
]

{ #category : #accessing }
SubdivisionHalfEdge >> destPrev [
	"Return the next cw edge around (into) the destination of the current edge."
	^self inverseRotated originNext inverseRotated
]

{ #category : #accessing }
SubdivisionHalfEdge >> destination [
	^self symmetric origin
]

{ #category : #accessing }
SubdivisionHalfEdge >> destination: aPoint [
	self symmetric origin: aPoint
]

{ #category : #private }
SubdivisionHalfEdge >> displayOn: aGraphicsContext at: aPoint withSize: scaling stamp: timeStamp [

	| v1 v2 |
	(quadEdge timeStamp = timeStamp) ifTrue:[^self].
	quadEdge timeStamp: timeStamp.
	v1 := self origin.
	v2 := self destination.
	aGraphicsContext 
		displayLineFrom: (v1 * scaling)+aPoint
		to: (v2 * scaling) + aPoint.
	self originNext displayOn: aGraphicsContext at: aPoint withSize: scaling stamp: timeStamp.
	self originPrev displayOn: aGraphicsContext at: aPoint withSize: scaling stamp: timeStamp.
	self destNext displayOn: aGraphicsContext at: aPoint withSize: scaling stamp: timeStamp.

	self destPrev displayOn: aGraphicsContext at: aPoint withSize: scaling stamp: timeStamp.
]

{ #category : #enumeration }
SubdivisionHalfEdge >> edgesDo: aBlock stamp: timeStamp [
	(quadEdge timeStamp = timeStamp) ifTrue:[^self].
	quadEdge timeStamp: timeStamp.
	aBlock value: self.
	self originNext edgesDo: aBlock stamp: timeStamp.
	self originPrev edgesDo: aBlock stamp: timeStamp.
	self destNext edgesDo: aBlock stamp: timeStamp.
	self destPrev edgesDo: aBlock stamp: timeStamp.
]

{ #category : #accessing }
SubdivisionHalfEdge >> end [
	^self destination
]

{ #category : #'initialize-release' }
SubdivisionHalfEdge >> id: aNumber owner: aDelauneyQuadEdge [

	id := aNumber.
	quadEdge := aDelauneyQuadEdge.
]

{ #category : #accessing }
SubdivisionHalfEdge >> inverseRotated [
	" Return the dual of the current edge, directed from its left to its right."
	^quadEdge edges at: (id > 1 ifTrue:[id-1] ifFalse:[id+3])
]

{ #category : #accessing }
SubdivisionHalfEdge >> isBorderEdge [
	^quadEdge isBorderEdge
]

{ #category : #accessing }
SubdivisionHalfEdge >> isBorderEdge: aBool [
	quadEdge isBorderEdge: aBool
]

{ #category : #accessing }
SubdivisionHalfEdge >> isExteriorEdge [
	^quadEdge isExteriorEdge
]

{ #category : #accessing }
SubdivisionHalfEdge >> isExteriorEdge: aBool [
	quadEdge isExteriorEdge: aBool
]

{ #category : #accessing }
SubdivisionHalfEdge >> isInteriorEdge [
	^quadEdge isInteriorEdge
]

{ #category : #accessing }
SubdivisionHalfEdge >> isInteriorEdge: aBool [
	quadEdge isInteriorEdge: aBool
]

{ #category : #private }
SubdivisionHalfEdge >> isLeftPoint: aPoint [

	^self ccw: aPoint with: self origin with: self destination

]

{ #category : #private }
SubdivisionHalfEdge >> isPointOn: aPoint [
	"A predicate that determines if the point x is on the edge e.
	The point is considered on if it is in the EPS-neighborhood
	of the edge"
	| v1 v2 u v |
	v1 := aPoint - self origin.
	v2 := self destination - self origin.
	u := v1 dotProduct: v2.
	v := v1 crossProduct: v2.
	^(u isZero and:[v isZero])
]

{ #category : #private }
SubdivisionHalfEdge >> isRightPoint: aPoint [

	^self ccw: aPoint with: self destination with: self origin
]

{ #category : #accessing }
SubdivisionHalfEdge >> leftNext [
	"Return the ccw edge around the left face following the current edge."
	^self inverseRotated originNext rotated
]

{ #category : #accessing }
SubdivisionHalfEdge >> leftPrev [
	"Return the ccw edge around the left face before the current edge."
	^self originNext symmetric
]

{ #category : #accessing }
SubdivisionHalfEdge >> length [
	^self start dist: self end
]

{ #category : #enumeration }
SubdivisionHalfEdge >> markExteriorEdges: timeStamp [
	| nextEdge |
	quadEdge timeStamp = timeStamp ifTrue:[^self].
	quadEdge timeStamp: timeStamp.
	self isExteriorEdge: true.
	nextEdge := self.
	[nextEdge := nextEdge originNext.
	nextEdge == self or:[nextEdge isBorderEdge]] whileFalse:[
		nextEdge symmetric markExteriorEdges: timeStamp.
	].
	nextEdge := self.
	[nextEdge := nextEdge originPrev.
	nextEdge == self or:[nextEdge isBorderEdge]] whileFalse:[
		nextEdge symmetric markExteriorEdges: timeStamp.
	].
]

{ #category : #accessing }
SubdivisionHalfEdge >> next: aDelauneyEdge [

	next := aDelauneyEdge.
]

{ #category : #accessing }
SubdivisionHalfEdge >> nextBorderEdge [
	| edge |
	edge := self originNext.
	[edge == self] whileFalse:[
		edge isBorderEdge ifTrue:[^edge symmetric].
		edge := edge originNext].
	^nil
]

{ #category : #accessing }
SubdivisionHalfEdge >> origin [
	^point
]

{ #category : #accessing }
SubdivisionHalfEdge >> origin: aPoint [
	point := aPoint
]

{ #category : #accessing }
SubdivisionHalfEdge >> originNext [
	"Return the next ccw edge around (from) the origin of the current edge."
	^next
]

{ #category : #accessing }
SubdivisionHalfEdge >> originPrev [
	" Return the next cw edge around (from) the origin of the current edge."
	^self rotated originNext rotated
]

{ #category : #printing }
SubdivisionHalfEdge >> printOn: aStream [

	aStream
		nextPutAll: self class name;
		nextPut:$(;
		print: (self origin);
		nextPut:$/;
		print: self destination;
		nextPut:$);
		yourself
]

{ #category : #accessing }
SubdivisionHalfEdge >> quadEdge [
	^quadEdge
]

{ #category : #private }
SubdivisionHalfEdge >> quadEdgeClass [
	^SubdivisionQuadEdge
]

{ #category : #accessing }
SubdivisionHalfEdge >> rightNext [
	"Return the edge around the right face ccw following the current edge."
	^self rotated originNext inverseRotated
]

{ #category : #accessing }
SubdivisionHalfEdge >> rightPrev [
	"Return the edge around the right face ccw before the current edge."
	^self symmetric originNext
]

{ #category : #accessing }
SubdivisionHalfEdge >> rotated [
	" Return the dual of the current edge, directed from its right to its left"
	^quadEdge edges at: (id < 4 ifTrue:[id+1] ifFalse:[id-3])
]

{ #category : #'topological operators' }
SubdivisionHalfEdge >> spliceEdge: edge [
	"This operator affects the two edge rings around the origins of a and b,
	and, independently, the two edge rings around the left faces of a and b.
	In each case, (i) if the two rings are distinct, Splice will combine
	them into one; (ii) if the two are the same ring, Splice will break it
	into two separate pieces.
	Thus, Splice can be used both to attach the two edges together, and
	to break them apart. See Guibas and Stolfi (1985) p.96 for more details
	and illustrations."
	| alpha beta t1 t2 t3 t4 |
	alpha := self originNext rotated.
	beta := edge originNext rotated.

	t1 := edge originNext.
	t2 := self originNext.
	t3 := beta originNext.
	t4 := alpha originNext.

	self next: t1.
	edge next: t2.
	alpha next: t3.
	beta next: t4.
]

{ #category : #accessing }
SubdivisionHalfEdge >> squaredLength [
	^self start dotProduct: self end
]

{ #category : #accessing }
SubdivisionHalfEdge >> start [
	^self origin
]

{ #category : #'topological operators' }
SubdivisionHalfEdge >> swapEdge [
	"Essentially turns edge e counterclockwise inside its enclosing
	quadrilateral. The data pointers are modified accordingly."

	| a b |
	a := self originPrev.
	b := self symmetric originPrev.
	self spliceEdge: a.
	self symmetric spliceEdge: b.
	self spliceEdge: a leftNext.
	self symmetric spliceEdge: b leftNext.
	self origin: a destination; destination: b destination.
]

{ #category : #accessing }
SubdivisionHalfEdge >> symmetric [
	"Return the edge from the destination to the origin of the current edge."
	^quadEdge edges at:(id < 3 ifTrue:[id+2] ifFalse:[id - 2]).
]

{ #category : #accessing }
SubdivisionHalfEdge >> timeStamp [
	^quadEdge timeStamp
]

{ #category : #private }
SubdivisionHalfEdge >> triArea: a with: b with: c [
	"Returns twice the area of the oriented triangle (a, b, c), i.e., the
	area is positive if the triangle is oriented counterclockwise."
	^((b x - a x) * (c y - a y)) - ((b y - a y) * (c x - a x))
]

{ #category : #enumeration }
SubdivisionHalfEdge >> triangleEdges: timeStamp do: aBlock [
	| e1 e2 e3 |
	"Evaluate aBlock with all edges making up triangles"
	quadEdge timeStamp = timeStamp ifTrue:[^self].
	quadEdge timeStamp: timeStamp.
	e1 := self.
	e3 := self originNext symmetric.
	e2 := e3 originNext symmetric.
	(e2 timeStamp = timeStamp or:[e3 timeStamp = timeStamp])
		ifFalse:[aBlock value: e1 value: e2 value: e3].
	e1 := self originPrev.
	e3 := self symmetric.
	e2 := e3 originNext symmetric.
	(e1 timeStamp = timeStamp or:[e2 timeStamp = timeStamp])
		ifFalse:[aBlock value: e1 value: e2 value: e3].
	self originNext triangleEdges: timeStamp do: aBlock.
	self originPrev triangleEdges: timeStamp do: aBlock.
	self destNext triangleEdges: timeStamp do: aBlock.
	self destPrev triangleEdges: timeStamp do: aBlock.
]
