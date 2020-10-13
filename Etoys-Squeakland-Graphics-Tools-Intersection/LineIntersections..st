"
This class computes all intersections of a set of line segments. The input segments must be integer coordinates. The intersections returned will be accurate, meaning that fractional points describing the intersections will be reported. It is up to the client to convert these fractional points if required.
"
Class {
	#name : #LineIntersections,
	#superclass : #Object,
	#instVars : [
		'segments',
		'activeEdges',
		'events',
		'intersections',
		'lastIntersections'
	],
	#classVars : [
		'Debug'
	],
	#category : #'Etoys-Squeakland-Graphics-Tools-Intersection'
}

{ #category : #debug }
LineIntersections class >> debugMode [
	^Debug == true
]

{ #category : #debug }
LineIntersections class >> debugMode: aBool [
	"LineIntersections debugMode: true"
	"LineIntersections debugMode: false"
	Debug := aBool.
]

{ #category : #example }
LineIntersections class >> exampleLines: n [
	"LineIntersections exampleLines: 100"
	| segments rnd canvas intersections pt p1 p2 |
	rnd := Random new.
	segments := (1 to: n) collect:[:i|
		p1 := (rnd next @ rnd next * 500) asIntegerPoint.
		[p2 := (rnd next @ rnd next * 200 - 100) asIntegerPoint.
		p2 isZero] whileTrue.
		LineSegment from: p1 to: p1 + p2].
	canvas := Display getCanvas.
	canvas fillRectangle: (0@0 extent: 600@600) color: Color white.
	segments do:[:seg|
		canvas line: seg start to: seg end width: 1 color: Color black.
	].
	intersections := LineIntersections of: segments.
	intersections do:[:array|
		pt := array at: 1.
		canvas fillRectangle: (pt asIntegerPoint - 2 extent: 5@5) color: Color red].
	Display restoreAfter:[].
]

{ #category : #'instance creation' }
LineIntersections class >> of: anArrayOfLineSegments [
	^self new computeIntersectionsOf: anArrayOfLineSegments
]

{ #category : #'instance creation' }
LineIntersections class >> regularize: pointCollection [
	"Make the pointList non-intersecting, e.g., insert points at intersections and have the outline include those points"
	| pointList segments last intersections map pts |
	pointList := pointCollection collect:[:pt| pt asIntegerPoint].
	segments := WriteStream on: (Array new: pointList size).
	last := pointList last.
	pointList do:[:next|
		segments nextPut: (LineSegment from: last to: next).
		last := next.
	].
	segments := segments contents.
	intersections := self of: segments.
	map := IdentityDictionary new: segments size.
	intersections do:[:is|
		(map at: is second ifAbsentPut:[WriteStream on: (Array new: 2)]) nextPut: is first.
		(map at: is third ifAbsentPut:[WriteStream on: (Array new: 2)]) nextPut: is first.
	].
	pts := WriteStream on: (Array new: pointList size).
	segments do:[:seg|
		intersections := (map at: seg) contents.
		intersections := intersections sort:
			[:p1 :p2|  (p1 squaredDistanceTo: seg start) <= (p2 squaredDistanceTo: seg start)].
		last := intersections at: 1.
		pts nextPut: last.
		intersections do:[:next|
			(next = last and:[next = seg end]) ifFalse:[
				pts nextPut: next.
				last := next]].
	].
	^pts contents collect:[:pt| pt asFloatPoint]
]

{ #category : #computing }
LineIntersections >> computeIntersectionAt: leftIndex belowOrRightOf: aPoint [
	| leftEdge rightEdge pt evt |
	leftIndex < 1 ifTrue:[^self].
	leftIndex >= activeEdges size ifTrue:[^self].
	leftEdge := activeEdges at: leftIndex.
	rightEdge := activeEdges at: leftIndex+1.
	Debug == true ifTrue:[
		self debugDrawLine: leftEdge with: rightEdge color: Color yellow.
		self debugDrawLine: leftEdge with: rightEdge color: Color blue.
		self debugDrawLine: leftEdge with: rightEdge color: Color yellow.
		self debugDrawLine: leftEdge with: rightEdge color: Color blue.
	].
	pt := self intersectFrom: leftEdge start to: leftEdge end with: rightEdge start to: rightEdge end.
	pt ifNil:[^self].
	pt y < aPoint y ifTrue:[^self].
	(pt y = aPoint y and:[pt x <= aPoint x]) ifTrue:[^self].
	Debug == true ifTrue:[self debugDrawPoint: pt].
	evt := LineIntersectionEvent type: #cross position: pt segment: leftEdge.
	evt crossedEdge: rightEdge.
	events add: evt.
]

{ #category : #computing }
LineIntersections >> computeIntersectionsOf: anArrayOfLineSegments [
	segments := anArrayOfLineSegments.
	self initializeEvents.
	self processEvents.
	^intersections contents
]

{ #category : #computing }
LineIntersections >> crossEdgeEvent: evt [
	| evtPoint edge index other |
	lastIntersections 
		ifNil:[lastIntersections := Array with: evt]
		ifNotNil:[
			(lastIntersections anySatisfy:
				[:old| old edge == evt edge and:[old crossedEdge == evt crossedEdge]]) ifTrue:[^self].
			lastIntersections := lastIntersections copyWith: evt].
	evtPoint := evt position.
	edge := evt edge.
	self recordIntersection: edge with: evt crossedEdge at: evtPoint.
	Debug == true ifTrue:[
		self debugDrawLine: edge with: evt crossedEdge color: Color red.
		self debugDrawLine: edge with: evt crossedEdge color: Color blue.
		self debugDrawLine: edge with: evt crossedEdge color: Color red.
		self debugDrawLine: edge with: evt crossedEdge color: Color blue].
	index := self firstIndexForInserting: evtPoint.
	[other := activeEdges at: index.
	other == edge] whileFalse:[index := index + 1].
	"Swap edges at index"
	"self assert:[(activeEdges at: index+1) == evt crossedEdge]."
	other := activeEdges at: index+1.
	activeEdges at: index+1 put: edge.
	activeEdges at: index put: other.
	"And compute new intersections"
	self computeIntersectionAt: index-1 belowOrRightOf: evtPoint.
	self computeIntersectionAt: index+1 belowOrRightOf: evtPoint.
]

{ #category : #debug }
LineIntersections >> debugDrawLine: line color: aColor [
	Display getCanvas
		line: (line start * self debugScale)
		to: (line end * self debugScale)
		width: 3
		color: aColor.
	self debugWait.
]

{ #category : #debug }
LineIntersections >> debugDrawLine: line1 with: line2 color: aColor [
	Display getCanvas
		line: (line1 start * self debugScale)
		to: (line1 end * self debugScale)
		width: 3
		color: aColor.
	Display getCanvas
		line: (line2 start * self debugScale)
		to: (line2 end * self debugScale)
		width: 3
		color: aColor.
	self debugWait.
]

{ #category : #debug }
LineIntersections >> debugDrawPoint: pt [
	Display getCanvas
		fillRectangle: (pt * self debugScale - 3 extent: 6@6) truncated color: Color red.
	self debugWait.
]

{ #category : #debug }
LineIntersections >> debugScale [
	^1
]

{ #category : #debug }
LineIntersections >> debugWait [
	(Delay forMilliseconds: 100) wait.
]

{ #category : #computing }
LineIntersections >> endEdgeEvent: evt [
	| evtPoint edge index other |
	evtPoint := evt position.
	edge := evt edge.
	Debug == true ifTrue:[self debugDrawLine: edge color: Color green].
	index := self firstIndexForInserting: evtPoint.
	[other := activeEdges at: index.
	other == edge] whileFalse:[index := index + 1].
	"Remove edge at index"
	activeEdges removeAt: index.
	self computeIntersectionAt: index-1 belowOrRightOf: evtPoint.
]

{ #category : #private }
LineIntersections >> firstIndexForInserting: aPoint [
	| index |
	index := self indexForInserting: aPoint.
	[index > 1 and:[((activeEdges at: index-1) sideOfPoint: aPoint) = 0]]
		whileTrue:[index := index-1].
	^index
]

{ #category : #private }
LineIntersections >> indexForInserting: aPoint [
	"Return the appropriate index for inserting the given x value"
	| index low high side |
	low := 1.
	high := activeEdges size.
	[index := (high + low) bitShift: -1.
	low > high] whileFalse:[
		side := (activeEdges at: index) sideOfPoint: aPoint.
		side = 0 ifTrue:[^index].
		side > 0
			ifTrue:[high := index - 1]
			ifFalse:[low := index + 1]].
	^low
]

{ #category : #computing }
LineIntersections >> initializeEvents [
	"Initialize the events for all given line segments"
	| mySeg pt1 pt2 |
	events := WriteStream on: (Array new: segments size * 2).
	segments do:[:seg|
		pt1 := seg start asPoint.
		pt2 := seg end asPoint.
		(pt1 sortsBefore: pt2) 
			ifTrue:[mySeg := LineIntersectionSegment from: pt1 to: pt2]
			ifFalse:[mySeg := LineIntersectionSegment from: pt2 to: pt1].
		mySeg referentEdge: seg.
		events nextPut: (LineIntersectionEvent type: #start position: mySeg start segment: mySeg).
		events nextPut: (LineIntersectionEvent type: #end position: mySeg end segment: mySeg).
	].
	events := Heap withAll: events contents sortBlock: [:ev1 :ev2| ev1 sortsBefore: ev2].
]

{ #category : #private }
LineIntersections >> intersectFrom: pt1Start to: pt1End with: pt2Start to: pt2End [
	| det deltaPt alpha beta pt1Dir pt2Dir |
	pt1Dir := pt1End - pt1Start.
	pt2Dir := pt2End - pt2Start.
	det := (pt1Dir x * pt2Dir y) - (pt1Dir y * pt2Dir x).
	deltaPt := pt2Start - pt1Start.
	alpha := (deltaPt x * pt2Dir y) - (deltaPt y * pt2Dir x).
	beta := (deltaPt x * pt1Dir y) - (deltaPt y * pt1Dir x).
	det = 0 ifTrue:[^nil]. "no intersection"
	alpha * det < 0 ifTrue:[^nil].
	beta * det < 0 ifTrue:[^nil].
	det > 0 
		ifTrue:[(alpha > det or:[beta > det]) ifTrue:[^nil]]
		ifFalse:[(alpha < det or:[beta < det]) ifTrue:[^nil]].
	"And compute intersection"
	^pt1Start + (alpha * pt1Dir / (det@det))
]

{ #category : #private }
LineIntersections >> isLeft: dir1 comparedTo: dir2 [
	"Return true if dir1 is left of dir2"
	| det |
	det := ((dir1 x * dir2 y) - (dir2 x * dir1 y)).
	"det = 0 ifTrue:[self error:'line on line']."
	^det <= 0
]

{ #category : #computing }
LineIntersections >> processEvents [
	| evt |
	intersections := WriteStream on: (Array new: segments size).
	activeEdges := OrderedCollection new.
	[events isEmpty] whileFalse:[
		evt := events removeFirst.
		evt type == #start ifTrue:[self startEdgeEvent: evt].
		evt type == #end ifTrue:[self endEdgeEvent: evt].
		evt type == #cross 
			ifTrue:[self crossEdgeEvent: evt]
			ifFalse:[lastIntersections := nil].
	].
]

{ #category : #computing }
LineIntersections >> recordIntersection: edge with: other at: evtPoint [
	intersections nextPut:
		(Array with: evtPoint
				with: edge referentEdge
				with: other referentEdge).
]

{ #category : #computing }
LineIntersections >> startEdgeEvent: evt [
	| idx edge evtPoint index keepChecking other side |
	edge := evt segment.
	Debug == true ifTrue:[self debugDrawLine: edge color: Color blue].
	evtPoint := evt position.
	"Find left-most insertion point"
	idx := self firstIndexForInserting: evtPoint.
	index := idx.
	keepChecking := true.
	"Check all edges containing the same insertion point"
	[idx <= activeEdges size
		ifTrue:[	other := activeEdges at: idx.
				side := other sideOfPoint: evtPoint]
		ifFalse:[side := -1].
	side = 0] whileTrue:[
		idx := idx + 1.
		self recordIntersection: edge with: other at: evtPoint.
		"Check edges as long as we haven't found the insertion index"
		keepChecking ifTrue:[
			(self isLeft: other direction comparedTo: edge direction)
				ifTrue:[index := index + 1]
				ifFalse:[keepChecking := false]].
	].
	activeEdges add: edge afterIndex: index-1.
	self computeIntersectionAt: index-1 belowOrRightOf: evtPoint.
	self computeIntersectionAt: index belowOrRightOf: evtPoint.
]
