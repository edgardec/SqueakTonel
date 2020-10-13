Class {
	#name : #RectangleTest,
	#superclass : #TestCase,
	#category : #'GraphicsTests-Primitives'
}

{ #category : #tests }
RectangleTest >> testArea [
	| r1 empty |
	r1 := 0@0 extent: 10@20.
	self assert: r1 area = (10*20).
	self assert: (r1 translateBy: -20@10) area = (10*20) description: 'translation preserves area'.
	
	empty := 10@20 corner: 0@0.
	self assert: empty area = 0 description: 'the area of an empty rectangle is null'.
	empty := 10@0 corner: 0@20.
	self assert: empty area = 0 description: 'the area of an empty rectangle is null'.
	empty := 0@20 corner: 10@0.
	self assert: empty area = 0 description: 'the area of an empty rectangle is null'.
]

{ #category : #tests }
RectangleTest >> testAreasOutside1 [
   "RectangleTest new testAreasOutside1"
    | frame rects visibleArea  |
    frame := 0@0 extent: 300@300.
    rects := OrderedCollection new: 80.
    0 to: 3 do: [:i |
      0 to: 2 do: [:j |
            rects add: (i@j * 20 extent: 10@10)
    ]  ].
  
   visibleArea := Array with: frame.
   rects do: [:rect |  | remnants |
      remnants := OrderedCollection new.
      visibleArea do: [:a | remnants addAll: (a areasOutside: rect)].
      visibleArea := remnants.
  ].
  visibleArea := visibleArea asArray.
  self assert: (visibleArea allSatisfy: [:r | r area ~= 0]).

   1 to: visibleArea size do: [:idx |
     idx + 1 to: visibleArea size do: [:idx2 |
        self deny: ((visibleArea at: idx) intersects: (visibleArea at: idx2)).
  ]  ].

  1 to: rects size do: [:idx |
     1 to: visibleArea size do: [:idx2 |
        self deny: ((rects at: idx) intersects: (visibleArea at: idx2)).
  ]  ].


]

{ #category : #tests }
RectangleTest >> testAreasOutside2 [
   "RectangleTest new testAreasOutside2"
    | frame rects visibleArea  |
    frame := 0@0 extent: 300@300.
    rects := OrderedCollection new: 80.
    rects add: (50@50 corner: 200 @ 200);
          add: (100@100 corner: 250@250).
  
   visibleArea := Array with: frame.
   rects do: [:rect |  | remnants |
      remnants := OrderedCollection new.
      visibleArea do: [:a | remnants addAll: (a areasOutside: rect)].
      visibleArea := remnants.
  ].
  visibleArea := visibleArea asArray.
  self assert: (visibleArea allSatisfy: [:r | r area ~= 0]).

   1 to: visibleArea size do: [:idx |
     idx + 1 to: visibleArea size do: [:idx2 |
        self deny: ((visibleArea at: idx) intersects: (visibleArea at: idx2)).
  ]  ].

  1 to: rects size do: [:idx |
     1 to: visibleArea size do: [:idx2 |
        self deny: ((rects at: idx) intersects: (visibleArea at: idx2)).
  ]  ].


]

{ #category : #tests }
RectangleTest >> testBottomHalf [
	| r |
	r := 10@20 corner: 30@50.
	self assert: (10@35 corner: 30@50) equals: r bottomHalf.
	self assert: (10@42 corner: 30@50) equals: r bottomHalf bottomHalf
]

{ #category : #tests }
RectangleTest >> testBottomLeftQuadrant [
	| r |
	r := 10@20 corner: 30@50.
	self assert: (10@35 corner: 20@50) equals: r bottomLeftQuadrant.
	self assert: (10@42 corner: 15@50) equals: r bottomLeftQuadrant bottomLeftQuadrant
]

{ #category : #tests }
RectangleTest >> testBottomRightQuadrant [
	| r |
	r := 10@20 corner: 30@50.
	self assert: (20@35 corner: 30@50) equals: r bottomRightQuadrant.
	self assert: (25@42 corner: 30@50) equals: r bottomRightQuadrant bottomRightQuadrant
]

{ #category : #tests }
RectangleTest >> testCenter [
	| r1 c |
	r1 := 0@0 extent: 10@20.
	c := r1 center.
	self assert: (r1 containsPoint: c) description: 'the center is inside the rectangle'.
	self assert: (r1 topLeft dist: c) = (r1 bottomRight dist: c).
	self assert: (r1 bottomLeft dist: c) = (r1 topRight dist: c).
	self assert: (r1 topLeft dist: c) = (r1 bottomLeft dist: c).
	self assert: (r1 translateBy: -20@10) center = (c translateBy: -20@10) description: 'the center is translated with the rectangle'.
]

{ #category : #tests }
RectangleTest >> testCenterEmpty [
	| r1 c |
	r1 := 30@10 corner: 10@20.
	c := r1 center.
	self deny: (r1 containsPoint: c) description: 'An empty rectangle does not contain any point.'.
	self assert: (r1 topLeft dist: c) = (r1 bottomRight dist: c).
	self assert: (r1 bottomLeft dist: c) = (r1 topRight dist: c).
	self assert: (r1 topLeft dist: c) = (r1 bottomLeft dist: c).
	self assert: (r1 translateBy: -20@10) center = (c translateBy: -20@10) description: 'the center is translated with the rectangle'.
]

{ #category : #tests }
RectangleTest >> testCorner1 [
   "RectangleTest new testCorner1"
    | rect |
   rect := 10@10 extent: 20@30.
   self deny: (rect containsPoint: rect corner).
]

{ #category : #tests }
RectangleTest >> testDegeneratedIntersectionTest [
	| horizontalLine verticalLine outsideRectangle |
	horizontalLine := 10@10 extent: 20@0.
	verticalLine := 20@0 extent: 0@20.
	self assert: (horizontalLine intersects: verticalLine).
	outsideRectangle := 100@10 extent: 20@20.
	self deny: (horizontalLine intersects: outsideRectangle).
]

{ #category : #tests }
RectangleTest >> testFlip [
	| r1 c r1Horiz r1Vert |
	r1 := 30@10 extent: 10@20.
	c := 5@5.
	r1Horiz := r1 flipBy: #horizontal centerAt: c.
	r1Vert := r1 flipBy: #vertical centerAt: c.

	self assert: r1 area = r1Horiz area description: 'flip preserves area'.
	self assert: r1 area = r1Vert area description: 'flip preserves area'.
	
	self assert: r1 extent = r1Horiz extent description: 'flip preserves extent'.
	self assert: r1 extent = r1Vert extent description: 'flip preserves extent'.
	
	self assert:  (r1 flipBy: #horizontal centerAt: r1 center) = r1.
	self assert:  (r1 flipBy: #vertical centerAt: r1 center) = r1
]

{ #category : #tests }
RectangleTest >> testFlipEmpty [
	| r1 c r1Horiz r1Vert |
	r1 := 30@10 corner: 10@20.
	c := 5@5.
	r1Horiz := r1 flipBy: #horizontal centerAt: c.
	r1Vert := r1 flipBy: #vertical centerAt: c.
	
	self assert: r1 area = r1Horiz area description: 'flip preserves area'.
	self assert: r1 area = r1Vert area description: 'flip preserves area'.
	
	self assert: r1 extent = r1Horiz extent description: 'flip preserves extent'.
	self assert: r1 extent = r1Vert extent description: 'flip preserves extent'.
	
	self assert:  (r1 flipBy: #horizontal centerAt: r1 center) = r1.
	self assert:  (r1 flipBy: #vertical centerAt: r1 center) = r1
]

{ #category : #tests }
RectangleTest >> testIntersection1 [
   "RectangleTest new testIntersection1"
    | rect1 rect2 |
   rect1 := 10@10 corner: 20@30.
   rect2 := rect1 corner extent: 20@40.
   self deny: (rect1 intersects: rect2).
]

{ #category : #tests }
RectangleTest >> testIntersection2 [
   "RectangleTest new testIntersection2"
    | rect1 rect2 |
   rect1 := 0@0 corner: 40@40.
   rect2 := 40@40 corner: 50@50.
   self deny: (rect1 intersects: rect2);
        deny: (rect2 intersects: rect1).
]

{ #category : #tests }
RectangleTest >> testIntersectionEmpty [
	| rect1 empty1 empty2 |
	rect1 := 10@10 corner: 40@40.
	empty1 := 50@50 corner: 0@0.
	empty2 := 30@30 corner: 20@20.
	self
		deny: (rect1 intersects: empty1);
		deny: (rect1 intersects: empty2);
		deny: (empty1 intersects: rect1);
		deny: (empty2 intersects: rect1);
		deny: (empty1 intersects: empty2);
		deny: (empty2 intersects: empty1).
]

{ #category : #tests }
RectangleTest >> testLeftHalf [
	| r |
	r := 10@20 corner: 30@50.
	self assert: (10@20 corner: 20@50) equals: r leftHalf.
	self assert: (10@20 corner: 15@50) equals: r leftHalf leftHalf
]

{ #category : #tests }
RectangleTest >> testMergingDisjointRects [

	| coll merge |
	coll := OrderedCollection new.
	coll add: (Rectangle left: -10 right: 0 top: -10 bottom: 0).
	coll add: (Rectangle left: 0 right: 10 top: 0 bottom: 10).
	merge := Rectangle merging: coll.
	self assert: merge = (Rectangle left: -10 right: 10 top: -10 bottom: 10).
]

{ #category : #tests }
RectangleTest >> testMergingNestedRects [

	| coll merge |
	coll := OrderedCollection new.
	coll add: (Rectangle left: 1 right: 10 top: 1 bottom: 10).
	coll add: (Rectangle left: 4 right: 5 top: 4 bottom: 5).
	merge := Rectangle merging: coll.
	self assert: merge = coll first.
]

{ #category : #tests }
RectangleTest >> testMergingOverlappingRects [

	| coll merge |
	coll := OrderedCollection new.
	coll add: (Rectangle left: 5 right: 10 top: 0 bottom: 15).
	coll add: (Rectangle left: 0 right: 15 top: 5 bottom: 10).
	merge := Rectangle merging: coll.
	self assert: merge = (Rectangle left: 0 right: 15 top: 0 bottom: 15).
]

{ #category : #tests }
RectangleTest >> testMergingTrivial [

	| coll merge |
	coll := OrderedCollection new.
	coll add: (Rectangle left: 1 right: 1 top: 1 bottom: 1).

	merge := Rectangle merging: coll.
	self assert: merge = coll first.

]

{ #category : #tests }
RectangleTest >> testMergingTwoRects [

	| coll merge |
	coll := OrderedCollection new.
	coll add: (Rectangle left: 1 right: 1 top: 1 bottom: 1).
	coll add: (Rectangle left: 10 right: 10 top: 10 bottom: 10).

	merge := Rectangle merging: coll.
	self assert: merge = (Rectangle left: 1 right: 10 top: 1 bottom: 10).
]

{ #category : #tests }
RectangleTest >> testRightHalf [
	| r |
	r := 10@20 corner: 30@50.
	self assert: (20@20 corner: 30@50) equals: r rightHalf.
	self assert: (25@20 corner: 30@50) equals: r rightHalf rightHalf
]

{ #category : #tests }
RectangleTest >> testRotate [
	| r1 c r1Left r1Right r1Pi |
	r1 := 30@10 extent: 10@20.
	c := 5@5.
	r1Left := r1 rotateBy: #left centerAt: c.
	r1Right := r1 rotateBy: #right centerAt: c.
	r1Pi := r1 rotateBy: #pi centerAt: c.
	
	self assert: r1 area = r1Left area description: 'rotation preserves area'.
	self assert: r1 area = r1Right area description: 'rotation preserves area'.
	self assert: r1 area = r1Pi area description: 'rotation preserves area'.
	
	self assert: r1 extent transposed = r1Left extent.
	self assert: r1 extent transposed = r1Right extent.
	self assert: r1 extent = r1Pi extent.
	
	self assert:  (r1 rotateBy: #pi centerAt: r1 center) = r1
]

{ #category : #tests }
RectangleTest >> testRotateEmpty [
	| r1 c r1Left r1Right r1Pi |
	r1 := 30@10 corner: 10@20.
	c := 5@5.
	r1Left := r1 rotateBy: #left centerAt: c.
	r1Right := r1 rotateBy: #right centerAt: c.
	r1Pi := r1 rotateBy: #pi centerAt: c.
	
	self assert: r1 area = r1Left area description: 'rotation preserves area'.
	self assert: r1 area = r1Right area description: 'rotation preserves area'.
	self assert: r1 area = r1Pi area description: 'rotation preserves area'.
	
	self assert: r1 extent transposed = r1Left extent.
	self assert: r1 extent transposed = r1Right extent.
	self assert: r1 extent = r1Pi extent.
	
	self assert:  (r1 rotateBy: #pi centerAt: r1 center) = r1
]

{ #category : #tests }
RectangleTest >> testRoundingAfterHalfPixelTranslation [
	"A rectangle right on the cusp of rounding changes shape if origin and
	corner are in differenct quadrants"
	"self debug: #testRoundingAfterHalfPixelTranslation"
	| trouble noTrouble |
	trouble := 10 negated asPoint rect: 10 asPoint.
	noTrouble := trouble translateBy: 15.
	
	10 timesRepeat: [trouble := (trouble translateBy: 0.5) rounded].
	10 timesRepeat: [noTrouble := (noTrouble translateBy: 0.5) rounded].
	
	self assert: trouble extent = noTrouble extent
]

{ #category : #tests }
RectangleTest >> testRoundingAfterHalfPixelTranslationFirstQuadrant [
	"A rectangle right on the cusp of rounding changes shape if origin and
	corner are in differenct quadrants"
	"self debug: #testRoundingAfterHalfPixelTranslation"
	| a b |
	a := 10 asPoint rect: 10 asPoint.
	b := a translateBy: 15.
	
	10 timesRepeat: [a := (a translateBy: 0.5) rounded].
	10 timesRepeat: [b := (b translateBy: 0.5) rounded].
	
	self assert: a extent = b extent
]

{ #category : #tests }
RectangleTest >> testStoreOn [
	| assoc assoc2 |
	assoc := (0@0 extent: 1@1) -> 0.
	assoc2 := Compiler evaluate: assoc storeString.
	self assert: assoc key = assoc2 key.
	self assert: assoc value = assoc2 value.
]

{ #category : #tests }
RectangleTest >> testTopHalf [
	| r |
	r := 10@20 corner: 30@50.
	self assert: (10@20 corner: 30@35) equals: r topHalf.
	self assert: (10@20 corner: 30@27) equals: r topHalf topHalf
]

{ #category : #tests }
RectangleTest >> testTopLeftQuadrant [
	| r |
	r := 10@20 corner: 30@50.
	self assert: (10@20 corner: 20@35) equals: r topLeftQuadrant.
	self assert: (10@20 corner: 15@27) equals: r topLeftQuadrant topLeftQuadrant
]

{ #category : #tests }
RectangleTest >> testTopRightQuadrant [
	| r |
	r := 10@20 corner: 30@50.
	self assert: (20@20 corner: 30@35) equals: r topRightQuadrant.
	self assert: (25@20 corner: 30@27) equals: r topRightQuadrant topRightQuadrant
]
