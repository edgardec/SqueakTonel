"
This is the unit test for the class Point. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #PointTest,
	#superclass : #ClassTestCase,
	#category : #'GraphicsTests-Primitives'
}

{ #category : #tests }
PointTest >> testBasicFourDirections [
	"fourDirections returns the four rotation of the receiver in counter clockwise order with the receiver appearing last. "

	| samples results rejects |
	self assert:  (0 asPoint fourDirections) = (Array new: 4 withAll: 0 asPoint) . 
	samples := 0 asPoint eightNeighbors  .
	results := {
		{ 0 @ -1 . 	-1 @  0 . 	 0 @  1 . 	 1 @  0}.
		{ 1 @ -1 . 	-1 @ -1 . 	-1 @  1 . 	 1 @  1}.
		{ 1 @  0 . 	 0 @ -1 . 	-1 @  0 . 	 0 @  1}.
		{ 1 @  1 . 	 1 @ -1 . 	-1 @ -1 . 	-1 @  1}.
		{ 0 @  1 . 	 1 @  0 . 	 0 @ -1 . 	-1 @  0}.
		{-1 @  1 . 	 1 @  1 . 	 1 @ -1 . 	-1 @ -1}.
		{-1 @  0 . 	 0 @  1 . 	 1 @  0 . 	 0 @ -1}.
		{-1 @ -1 . 	-1 @  1 . 	 1 @  1 . 	 1 @ -1} } .

	rejects := (1 to: samples size ) reject: [ :each |
		 (samples at: each) fourDirections = (results at: each) ] .

	self assert: rejects isEmpty
]

{ #category : #tests }
PointTest >> testBearingToPoint [

	self assert: (0 @ 0 bearingToPoint: 0 @ 0) = 0.
	self assert: (0 @ 0 bearingToPoint: 0 @ -1) = 0.
	self assert: (0 @ 0 bearingToPoint: 1 @ 0) = 90.
	self assert: (0 @ 0 bearingToPoint: 0 @ 1) = 180.
	self assert: (0 @ 0 bearingToPoint: -1 @ 0) = 270.
	self assert: (0 @ 0 bearingToPoint: 1 @ 1) = 135.
	self assert: (0 @ 0 bearingToPoint: 0.01 @ 0) = 90.
	self assert: (0 @ 0 bearingToPoint: -2 @ -3) = 326.
	self assert: (0 @ 0 bearingToPoint: -0 @ 0) = 0.
	
	self assert: (-2 @ -3 bearingToPoint: 0 @ 0) = 146.
]

{ #category : #tests }
PointTest >> testFourDirectionsInvarients [
" fourDirections returns the four rotation of the reciever in counter clockwise order with the reciever appearing last. "

| samples  rejects |

samples := 
0 asPoint eightNeighbors  .

rejects :=
(1 to: samples size ) reject: [ :each |
		 (samples at: each) fourDirections last = ( samples  at: each) ] .

self assert: ( rejects isEmpty) .



]

{ #category : #tests }
PointTest >> testFourDirectionsRotationInvarients [
" fourDirections returns the four rotation of the reciever in counter clockwise order with the reciever appearing last. "

| samples  rejects |

samples := 
0 asPoint eightNeighbors  .

rejects :=
(1 to: samples size ) reject: [ :each | | answer  |
		(answer :=  (samples at: each) fourDirections ) .
		(1 to: 4) allSatisfy: [ :eachDirIndex | 
			( answer atWrap: eachDirIndex)  leftRotated
					 = (( answer atWrap: eachDirIndex + 1) )  ] ] .

self assert: ( rejects isEmpty) .



]

{ #category : #tests }
PointTest >> testIsZero [

	self assert: (0@0) isZero.	
	self deny:  (0@1) isZero.
	self deny:  (1@0) isZero.
	self deny:  (1@1) isZero.
]

{ #category : #tests }
PointTest >> testNormal [
	"quick check of results for #normal."
	| samples rejects results |
	samples := 0 asPoint eightNeighbors , (Array with: 0 asPoint) .

	results := 
 		{ 0.0 @ 1.0 .
		-0.707106781186547 @ 0.707106781186547 .
		-1.0 @ 0.0 .
		-0.707106781186547 @ -0.707106781186547 .
		0.0 @ -1.0 .
		0.707106781186547 @ -0.707106781186547 .
		1.0 @ 0.0 .
		0.707106781186547 @ 0.707106781186547 .
		-1 @ 0} .

	rejects := (1 to: samples size ) reject:
		[ :each | ((samples at: each) normal - (results at: each)) abs  < 1e-15 asPoint ] .

	self assert: rejects isEmpty
]

{ #category : #tests }
PointTest >> testNormal2 [
	"quick check of results for #normal.
	differs from the other testNormal in the way that the difference is measured."

	| samples rejects results differences |
	samples := 0 asPoint eightNeighbors , (Array with: 0 asPoint) .

	results := 
		{ 0.0 @ 1.0 .
		-0.707106781186547 @ 0.707106781186547 .
		-1.0 @ 0.0 .
		-0.707106781186547 @ -0.707106781186547 .
		0.0 @ -1.0 .
		0.707106781186547 @ -0.707106781186547 .
		1.0 @ 0.0 .
		0.707106781186547 @ 0.707106781186547 .
		-1 @ 0} .
	differences := samples with: results collect: [ :each :eachResult |
		each normal - eachResult ] .

	rejects := differences reject: [ :each | 
		(each x closeTo: 0.0) and: [each y closeTo: 0.0] ] .

	self assert: rejects isEmpty
]

{ #category : #tests }
PointTest >> testRectangleMix [

	{
		Rectangle center: 60@60 extent: 100@100.
		Rectangle origin: 10@10 extent: 100@100.
		Rectangle origin: 10@10 corner: 110@110.

		"1) Point/receiver is the origin, i.e. upper left corner."
		10@10 extent: 100@100.
		10@10 corner: 110@110.

		"2) Point/receiver is the extent."
		100@100 origin: 10@10.
		100@100 center: 60@60.

		"3) Receiver and argument are either origin or corner."
		110@110 rect: 10@10.
		
	} permutationsDo: [:rects |
		rects overlappingPairsDo: [:r1 :r2 |
			self assert: r1 equals: r2]].
]

{ #category : #tests }
PointTest >> testRectangleWithCenter [

	self
		assert: (Rectangle center: 50@50 extent: 100@100)
		equals: (100@100 center: 50@50).
]

{ #category : #tests }
PointTest >> testRectangleWithCorner [

	self
		assert: (Rectangle origin: 10@10 corner: 110@110)
		equals: (10@10 corner: 110@110).
]

{ #category : #tests }
PointTest >> testRectangleWithExtent [

	self
		assert: (Rectangle origin: 50@50 extent: 100@100)
		equals: (50@50 extent: 100@100).
]

{ #category : #tests }
PointTest >> testRectangleWithOrigin [

	self
		assert: (Rectangle origin: 50@50 extent: 100@100)
		equals: (100@100 origin: 50@50).
]

{ #category : #tests }
PointTest >> testRectangleWithPoints [

	self
		assert: (Rectangle origin: 50@50 corner: 100@100)
		equals: (100@100 rect: 50@50).
]

{ #category : #tests }
PointTest >> testRotations [
" Here we are testing rightRotated and leftRotated which are new.
Because there is really no coverage for point functions this also serves as a tests of sorts for 
rotateBy:CenterAt:"

| samples |
samples :=
0 asPoint eightNeighbors 
, (Array with: 0 asPoint) .

self assert: (samples allSatisfy: [ :each |
	each rightRotated leftRotated = each ] ) .

self assert: (samples allSatisfy: [ :each |
	each rightRotated  = (each rotateBy: #right centerAt: 0 asPoint)] ) .

self assert: (samples allSatisfy: [ :each |
	each leftRotated  = (each rotateBy: #left centerAt: 0 asPoint ) ] ) .

self assert: (samples allSatisfy: [ :each |
	each negated  = (each rotateBy: #pi centerAt: 0 asPoint ) ] ) .

self assert: (samples allSatisfy: [ :each | 
	each leftRotated leftRotated leftRotated leftRotated = each ]) .

self assert: (samples allSatisfy: [ :each |
	each rightRotated rightRotated rightRotated rightRotated  = each ] ) .

]

{ #category : #tests }
PointTest >> testSign [ 
	| samples results rejects |
	samples := 0 asPoint eightNeighbors , (Array with: 0 asPoint).

	results := samples collect: [ :each | each sign ].
	
	rejects := (1 to: samples size ) reject: [ :each |
		 (samples at: each) = (results at: each) ] .

	self assert: (rejects isEmpty) 



]

{ #category : #tests }
PointTest >> testTheta [
      | result dir tan x y |
	self assert: ((0 @ 1) theta - 90.0 degreesToRadians) abs < 1e-15.
	self assert: ((0 @ -1) theta - 270.0 degreesToRadians) abs < 1e-15.
	" See code of old and new theta"
	x := 1.0 . y := -1.0.
	tan := y  / x .
	dir := tan arcTan.
      result :=  360.0 degreesToRadians + dir.
      self assert: ((x @ y) theta - result) abs < 1e-15.
	x := -1.0. "Don't reuse old results when you want numeric precision!"
	tan := y  / x .
	dir := tan arcTan.
      result :=  180.0 degreesToRadians + dir.
      self assert: ((x @ y) theta - result) abs < 1e-15.

	
]

{ #category : #tests }
PointTest >> testZeroPointNormal [
	"old: normal of zero point raised divide by zero error.
	new: normal of zero point returns a direction right rotated from zero points direction."

	self assert: 90 equals: (0 asPoint normal bearingToPoint: 0 asPoint).
]
