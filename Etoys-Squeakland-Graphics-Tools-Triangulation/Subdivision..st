"
I perform (constraint) delauney triangulations on a set of points. See my class side for examples.
"
Class {
	#name : #Subdivision,
	#superclass : #Object,
	#instVars : [
		'area',
		'startingEdge',
		'point1',
		'point2',
		'point3',
		'stamp',
		'outlineThreshold'
	],
	#category : #'Etoys-Squeakland-Graphics-Tools-Triangulation'
}

{ #category : #'instance creation' }
Subdivision class >> constraintOutline: pointCollection [
	^(self points: pointCollection shuffled) constraintOutline: pointCollection
]

{ #category : #examples }
Subdivision class >> example1 [	"Subdivision example1"
	| ptList subdivision |
	ptList := ((5 to: 35) collect:[:i| i*10@50]),
			{350@75. 70@75. 70@100},
			((7 to: 35) collect:[:i| i*10@100]),
			{350@125. 50@125}.
	subdivision := self points: ptList.
	self exampleDraw: subdivision points: ptList.

]

{ #category : #examples }
Subdivision class >> example2 [	"Subdivision example2"
	"Same as example1, but this time using the outline constraints"
	| ptList subdivision |
	ptList := ((5 to: 35) collect:[:i| i*10@50]),
			{350@75. 70@75. 70@100},
			((7 to: 35) collect:[:i| i*10@100]),
			{350@125. 50@125}.
	subdivision := (self points: ptList) constraintOutline: ptList; yourself.
	self exampleDraw: subdivision points: ptList.

]

{ #category : #examples }
Subdivision class >> example3 [	"Subdivision example3"
	"Same as example2 but marking edges"
	| ptList subdivision |
	ptList := ((5 to: 35) collect:[:i| i*10@50]),
			{350@75. 70@75. 70@100},
			((7 to: 35) collect:[:i| i*10@100]),
			{350@125. 50@125}.
	subdivision := (self points: ptList) constraintOutline: ptList; yourself.
	subdivision markExteriorEdges.
	self exampleDraw: subdivision points: ptList.

]

{ #category : #examples }
Subdivision class >> example4 [	"Subdivision example4"
	"A nasty self-intersecting shape"
	"Same as example2 but marking edges"
	| ptList subdivision |
	ptList := {
		50@100. 
		100@100.
		150@100.
		150@150.
		100@150.
		100@100.
		100@50.
		300@50.
		300@300.
		50@300.
	}.
	subdivision := (self points: ptList) constraintOutline: ptList; yourself.
	subdivision markExteriorEdges.
	self exampleDraw: subdivision points: ptList.

]

{ #category : #examples }
Subdivision class >> exampleDraw: subdivision points: ptList [
	| canvas |
	Display fillWhite.
	canvas := Display getCanvas.
	subdivision edgesDo:[:e|
		canvas line: e origin to: e destination width: 1 color: e classificationColor].
	ptList do:[:pt|
		canvas fillRectangle: (pt - 1 extent: 3@3) color: Color red.
	].
	Display restoreAfter:[].
]

{ #category : #'instance creation' }
Subdivision class >> points: pointCollection [
	^self new points: pointCollection
]

{ #category : #'instance creation' }
Subdivision class >> withSize: rectangle [
	^self new withSize: rectangle
]

{ #category : #constraints }
Subdivision >> assureEdgeFrom: lastPt to: nextPt lastEdge: lastEdge [
	"Find and return the edge connecting nextPt and lastPt.
	lastEdge starts at lastPt so we can simply run around all
	the edges at lastPt and find one that ends in nextPt.
	If none is found, subdivide between lastPt and nextPt."
	| nextEdge destPt |
	nextEdge := lastEdge.
	[destPt := nextEdge destination.
	destPt x = nextPt x and:[destPt y = nextPt y]] whileFalse:[
		nextEdge := nextEdge originNext.
		nextEdge = lastEdge ifTrue:[
			"Edge not found. Subdivide and start over"
			nextEdge := self insertEdgeFrom: lastPt to: nextPt lastEdge: lastEdge.
			nextEdge ifNil:[^nil].
		].
	].
	nextEdge isBorderEdge: true.
	^nextEdge

]

{ #category : #constraints }
Subdivision >> assureEdgeFrom: lastPt to: nextPt lastEdge: lastEdge into: outPoints [
	"Find and return the edge connecting nextPt and lastPt.
	lastEdge starts at lastPt so we can simply run around all
	the edges at lastPt and find one that ends in nextPt.
	If none is found, subdivide between lastPt and nextPt."
	| nextEdge destPt |
	nextEdge := lastEdge.
	[destPt := nextEdge destination.
	destPt x = nextPt x and:[destPt y = nextPt y]] whileFalse:[
		nextEdge := nextEdge originNext.
		nextEdge = lastEdge ifTrue:[
			"Edge not found. Subdivide and start over"
			nextEdge := self insertEdgeFrom: lastPt to: nextPt lastEdge: lastEdge into: outPoints.
			nextEdge ifNil:[^nil].
		].
	].
	nextEdge isBorderEdge: true.
	^nextEdge

]

{ #category : #constraints }
Subdivision >> constraintOutline: pointList [
	"Make sure all line segments in the given closed outline appear in the triangulation."
	| lastPt nextPt lastEdge nextEdge outPoints |
	outlineThreshold ifNil:[outlineThreshold := 1.0e-3].
	lastPt := pointList last.
	lastEdge := self locatePoint: lastPt.
	lastEdge origin = lastPt 
		ifFalse:[lastEdge := lastEdge symmetric].
	outPoints := WriteStream on: (Array new: pointList size).
	1 to: pointList size do:[:i|
		nextPt := pointList at: i.
		lastPt = nextPt ifFalse:[
			nextEdge := self assureEdgeFrom: lastPt to: nextPt lastEdge: lastEdge into: outPoints.
			outPoints nextPut: nextPt.
			nextEdge ifNil:[
				nextEdge := self locatePoint: nextPt.
				lastEdge destination = nextPt 
					ifFalse:[lastEdge := lastEdge symmetric].
			].
			lastEdge := nextEdge symmetric originNext].
		lastPt := nextPt.
	].
	^outPoints contents
]

{ #category : #private }
Subdivision >> debugDraw [
	| scale ofs |
	scale := 100.
	ofs := 400.
	self edgesDo:[:e|
		Display getCanvas line: e origin * scale + ofs to: e destination * scale + ofs width: 3 color: e classificationColor].
]

{ #category : #accessing }
Subdivision >> edges [
	"Return the triangulation edges"
	| edges |
	edges := IdentitySet new: 500.
	startingEdge first collectQuadEdgesInto:edges.
	"Build line segments"
	edges := edges collect:[:edge | 
				LineSegment from: edge first origin to: edge first destination].
	"Remove the outer triangulation edges"
	^edges select:[:edge|
			area origin <= edge start and:[edge start <= area corner and:[area origin <= edge end and:[edge end <= area corner]]]]
]

{ #category : #private }
Subdivision >> edgesDo: aBlock [
	startingEdge first edgesDo: aBlock stamp: (stamp := stamp + 1).
]

{ #category : #accessing }
Subdivision >> faces [
	"Construct and return triangles"
	| firstEdge nextEdge lastEdge |
	firstEdge := nextEdge := startingEdge first.
	[lastEdge := nextEdge.
	nextEdge := nextEdge originNext.
	nextEdge == firstEdge] whileFalse:[
		"Make up a triangle between lastEdge and nextEdge"
	].

]

{ #category : #constraints }
Subdivision >> findEdgeFrom: lastPt to: nextPt lastEdge: lastEdge [
	"Find and return the edge connecting nextPt and lastPt.
	lastEdge starts at lastPt so we can simply run around all
	the edges at lastPt and find one that ends in nextPt."
	| nextEdge destPt |
	nextEdge := lastEdge.
	[destPt := nextEdge destination.
	destPt x = nextPt x and:[destPt y = nextPt y]] whileFalse:[
		nextEdge := nextEdge originNext.
		nextEdge = lastEdge ifTrue:[^nil].
	].
	^nextEdge
]

{ #category : #constraints }
Subdivision >> flagExteriorEdgesFrom: lastEdge to: nextEdge direction: thisWay [
	| tmpEdge |
	lastEdge isBorderEdge ifFalse:[self error: 'not border'].
	nextEdge isBorderEdge ifFalse:[self error: 'not border'].
	tmpEdge := lastEdge.
	thisWay ifTrue:[
		[tmpEdge := tmpEdge originNext.
		tmpEdge == nextEdge] whileFalse:[
			tmpEdge isBorderEdge ifTrue:[self error: 'border'].
			tmpEdge isExteriorEdge: true.
		].
	] ifFalse:[
		[tmpEdge := tmpEdge originPrev.
		tmpEdge == nextEdge] whileFalse:[
			tmpEdge isBorderEdge ifTrue:[self error: 'border'].
			tmpEdge isExteriorEdge: true.
		].
	].
]

{ #category : #private }
Subdivision >> innerTriangleEdgesDo: aBlock [
	startingEdge first triangleEdges: (stamp := stamp + 1) do:
		[:e1 :e2 :e3|
			self assert:[e1 origin = e3 destination].
			self assert:[e2 origin = e1 destination].
			self assert:[e3 origin = e2 destination].
			(e1 isExteriorEdge or:[e2 isExteriorEdge or:[e3 isExteriorEdge]]) ifFalse:[
				aBlock value: e1 value: e2 value: e3.
			].
		].

]

{ #category : #private }
Subdivision >> innerTriangleVerticesDo: aBlock [
	startingEdge first triangleEdges: (stamp := stamp + 1) do:
		[:e1 :e2 :e3|
			self assert:[e1 origin = e3 destination].
			self assert:[e2 origin = e1 destination].
			self assert:[e3 origin = e2 destination].
			(e1 isExteriorEdge or:[e2 isExteriorEdge or:[e3 isExteriorEdge]]) ifFalse:[
				aBlock value: e1 origin value: e2 origin value: e3 origin.
			].
		].

]

{ #category : #private }
Subdivision >> innerTriangles [
	| out |
	out := WriteStream on: (Array new: 100).
	self innerTriangleVerticesDo:[:p1 :p2 :p3| out nextPut: {p1. p2. p3}].
	^out contents
]

{ #category : #constraints }
Subdivision >> insertEdgeFrom: lastPt to: nextPt lastEdge: prevEdge [
	| midPt lastEdge nextEdge dst |
	dst := lastPt - nextPt.
	(dst dotProduct: dst) < outlineThreshold ifTrue:[^nil].
	midPt := lastPt interpolateTo: nextPt at: 0.5.
	self insertPoint: midPt.
	lastEdge := prevEdge.
	nextEdge := self assureEdgeFrom: lastPt to: midPt lastEdge: lastEdge.
	nextEdge ifNil:[^nil].
	lastEdge := nextEdge symmetric originNext.
	nextEdge := self assureEdgeFrom: midPt to: nextPt lastEdge: lastEdge.
	^nextEdge
]

{ #category : #constraints }
Subdivision >> insertEdgeFrom: lastPt to: nextPt lastEdge: prevEdge into: outPoints [
	| midPt lastEdge nextEdge dst |
	dst := lastPt - nextPt.
	(dst dotProduct: dst) < outlineThreshold ifTrue:[^nil].
	midPt := lastPt interpolateTo: nextPt at: 0.5.
	self insertPoint: midPt.
	lastEdge := prevEdge.
	nextEdge := self assureEdgeFrom: lastPt to: midPt lastEdge: lastEdge into: outPoints.
	outPoints nextPut: midPt.
	nextEdge ifNil:[^nil].
	lastEdge := nextEdge symmetric originNext.
	nextEdge := self assureEdgeFrom: midPt to: nextPt lastEdge: lastEdge into: outPoints.
	^nextEdge
]

{ #category : #triangulation }
Subdivision >> insertPoint: aPoint [
	"Inserts a new point into a subdivision representing a Delaunay
	triangulation, and fixes the affected edges so that the result
	is still a Delaunay triangulation. This is based on the
	pseudocode from Guibas and Stolfi (1985) p.120, with slight
	modifications and a bug fix."
	| edge base |
	(area origin <= aPoint and:[aPoint <= area corner]) ifFalse:[self halt].
	edge := self locatePoint: aPoint.
	(edge origin = aPoint or:[edge destination = aPoint]) ifTrue:[^self].
	(edge isPointOn: aPoint) ifTrue:[
		edge := edge originPrev.
		edge originNext deleteEdge].
	"Connect the new point to the vertices of the containing
	triangle (or quadrilateral, if the new point fell on an
	existing edge.)"
	base := self quadEdgeClass new.
	(base first) origin: edge origin; destination: aPoint.
	base first spliceEdge: edge.
	startingEdge := base.
	[base := edge connectEdge: base first symmetric.
	edge := base first originPrev.
	edge leftNext == startingEdge first] whileFalse.
	"Examine suspect edges to ensure that the Delaunay condition is satisfied."
	[true] whileTrue:[ | t |
	t := edge originPrev.
	((edge isRightPoint: t destination) and:[
		self insideCircle: aPoint with: edge origin with: t destination with: edge destination])
			 ifTrue:[
					edge swapEdge.
					edge := edge originPrev.
	] ifFalse:[
		(edge originNext == startingEdge first) ifTrue:[^self]. "No more suspect edges"
		"pop a suspect edge"
		edge := edge originNext leftPrev]].
]

{ #category : #constraints }
Subdivision >> insertSpine [
	| ptList start end |
	ptList := WriteStream on: (Array new: 100).
	self edgesDo:[:e|
		(e isBorderEdge or:[e isExteriorEdge]) ifFalse:[
			start := e origin.
			end := e destination.
			ptList nextPut: (start + end * 0.5).
		].
	].
	ptList contents do:[:pt| self insertPoint: pt].
]

{ #category : #triangulation }
Subdivision >> insideCircle: aPoint with: a with: b with: c [
	"Returns TRUE if the point d is inside the circle defined by the
	points a, b, c. See Guibas and Stolfi (1985) p.107."
	^(((a dotProduct: a) * (self triArea: b with: c with: aPoint)) -
	((b dotProduct: b) * (self triArea: a with: c with: aPoint)) +
	((c dotProduct: c) * (self triArea: a with: b with: aPoint)) -
	((aPoint dotProduct: aPoint) * (self triArea: a with: b with: c))) > 0.0
]

{ #category : #triangulation }
Subdivision >> locatePoint: aPoint [
	"Returns an edge e, s.t. either x is on e, or e is an edge of
	a triangle containing x. The search starts from startingEdge
	and proceeds in the general direction of x. Based on the
	pseudocode in Guibas and Stolfi (1985) p.121."

	| edge |
	edge := startingEdge first.
	[true] whileTrue:[
		(aPoint = edge origin or:[aPoint = edge destination]) ifTrue:[^edge].
		(edge isRightPoint: aPoint) ifTrue:[edge := edge symmetric]
		ifFalse:[(edge originNext isRightPoint: aPoint) ifFalse:[edge := edge originNext]
		ifTrue:[(edge destPrev isRightPoint: aPoint) ifFalse:[edge := edge destPrev]
		ifTrue:[^edge]]]].
]

{ #category : #constraints }
Subdivision >> markExteriorEdges [
	"Recursively flag all edges that are known to be exterior edges.
	If the outline shape is not simple this may result in marking all edges."
	| firstEdge |
	firstEdge := self locatePoint: point1.
	firstEdge origin = point1 
		ifFalse:[firstEdge := firstEdge symmetric].
	firstEdge markExteriorEdges: (stamp := stamp + 1).
]

{ #category : #constraints }
Subdivision >> markExteriorEdges: thisWay in: pointList [
	"Mark edges as exteriors"
	| lastPt nextPt lastEdge nextEdge |
	lastPt := pointList last.
	lastEdge := self locatePoint: lastPt.
	lastEdge origin = lastPt 
		ifFalse:[lastEdge := lastEdge symmetric].
	nextEdge := self findEdgeFrom: lastPt to: (pointList atWrap: pointList size-1) lastEdge: lastEdge.
	lastEdge := nextEdge.
	1 to: pointList size do:[:i|
		nextPt := pointList at: i.
		lastPt = nextPt ifFalse:[
			nextEdge := self findEdgeFrom: lastPt to: nextPt lastEdge: lastEdge.
			nextEdge ifNil:[
				nextEdge := self locatePoint: nextPt.
				lastEdge destination = nextPt 
					ifFalse:[lastEdge := lastEdge symmetric].
			] ifNotNil:[
				self flagExteriorEdgesFrom: lastEdge to: nextEdge direction: thisWay.
			].
			lastEdge := nextEdge symmetric].
		lastPt := nextPt.
	].

]

{ #category : #accessing }
Subdivision >> outlineThreshold [
	"Return the current outline threshold.
	The outline threshold determines when to stop recursive
	subdivision of outline edges in the case of non-simple
	(that is self-intersecting) polygons."
	^outlineThreshold
]

{ #category : #accessing }
Subdivision >> outlineThreshold: aNumber [
	"Set the current outline threshold.
	The outline threshold determines when to stop recursive
	subdivision of outline edges in the case of non-simple
	(that is self-intersecting) polygons."
	outlineThreshold := aNumber
]

{ #category : #'initialize-release' }
Subdivision >> p1: pt1 p2: pt2 p3: pt3 [
	| ea eb ec |
	point1 := pt1.
	point2 := pt2.
	point3 := pt3.
	stamp := 0.
	ea := self quadEdgeClass new.
	(ea first) origin: pt1; destination: pt2.
	eb := self quadEdgeClass new.
	self splice: ea first symmetric with: eb first.
	(eb first) origin: pt2; destination: pt3.
	ec := self quadEdgeClass new.
	self splice: eb first symmetric with: ec first.
	(ec first) origin: pt3; destination: pt1.
	self splice: ec first symmetric with: ea first.
	startingEdge := ea.

]

{ #category : #accessing }
Subdivision >> points: pointCollection [

	| min max |
	pointCollection isEmpty ifTrue:[
		min := -1.0@ -1.0.
		max := 1.0@1.0.
	] ifFalse:[
		min := max := pointCollection anyOne.
		pointCollection do:[:p|
			min := min min: p.
			max := max max: p]].
	self withSize: (min corner: max).
	pointCollection do:[:p| self insertPoint: p].
]

{ #category : #private }
Subdivision >> quadEdgeClass [
	^SubdivisionQuadEdge
]

{ #category : #triangulation }
Subdivision >> splice: edge1 with: edge2 [

	edge1 spliceEdge: edge2
]

{ #category : #accessing }
Subdivision >> startingEdge [
	^startingEdge
]

{ #category : #triangulation }
Subdivision >> triArea: a with: b with: c [
	"Returns twice the area of the oriented triangle (a, b, c), i.e., the
	area is positive if the triangle is oriented counterclockwise."
	^((b x - a x) * (c y - a y)) - ((b y - a y) * (c x - a x))
]

{ #category : #private }
Subdivision >> trianglesDo: aBlock [
	"Return the full triangulation of the receiver"
	startingEdge first triangleEdges: (stamp := stamp + 1) do: aBlock.

]

{ #category : #'initialize-release' }
Subdivision >> withSize: aRectangle [

	| offset scale p1 p2 p3 |
	area := aRectangle.
	"Construct a triangle containing area"
	offset := area origin.
	scale := area extent.
	p1 := (-1@ -1) * scale + offset.
	p2 := (2@ -1) * scale + offset.
	p3 := (0.5@3) * scale + offset.
	self p1: p1 p2: p2 p3: p3.
]
