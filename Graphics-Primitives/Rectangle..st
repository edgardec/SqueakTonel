"
I represent a rectangular area of the screen. Arithmetic functions take points as arguments and carry out scaling and translating operations to create new instances of me. Rectangle functions create new instances by determining intersections of rectangles with rectangles.

Note 1: only rectangles parallel to reference frame (Screen) can be represented by this class.

Note 2: the Rectangle is represented by two extremities of one diagonal. By convention, it must be the diagonal:
	from rectangle origin (the point having smallest coordinates in reference frame),
	to rectangle corner (the point having largest coordinates in reference frame).

Note 3: Screen coordinates conventions are:
	x is horizontal axis, zero at left border, oriented toward right;
	y is vertical axis, zero at top border, oriented toward bottom.
This corresponds to the latin convention for writing text from left to right and top to bottom.

Note 4: the Rectangle extent is obtained by subtracting rectangle origin to rectangle corner coordinates.
If this leads to a negative width (extent x coordinate) and/or a negative height (extent y coordinate), then the Rectangle is degenerated and considered empty.

Instance variables:
	origin	<Point> the coordinates of corner having smallest coordinates (top left in Screen coordinates)
	corner	<Point> the coordinates of corner having largest coordinates (bottom right in Screen coordinates)

"
Class {
	#name : #Rectangle,
	#superclass : #Object,
	#instVars : [
		'origin',
		'corner'
	],
	#category : #'Graphics-Primitives'
}

{ #category : #'instance creation' }
Rectangle class >> center: centerPoint extent: extentPoint [ 
	"Answer an instance of me whose center is centerPoint and width 
	by height is extentPoint.  "

	^self origin: centerPoint - (extentPoint//2) extent: extentPoint
]

{ #category : #'instance creation' }
Rectangle class >> encompassing: listOfPoints [
	"A number of callers of encompass: should use this method."
	| topLeft bottomRight |
	topLeft := bottomRight := listOfPoints first.
	listOfPoints allButFirstDo:
		[:p |topLeft := topLeft min: p.
					bottomRight := bottomRight max: p].
	^self origin: topLeft corner: bottomRight
	
]

{ #category : #'instance creation' }
Rectangle class >> exactCenter: centerPoint extent: extentPoint [ 
	"Answer an instance of me whose center is centerPoint and width 
	by height is extentPoint. "
	^ self origin: centerPoint - (extentPoint / 2) extent: extentPoint

]

{ #category : #'instance creation' }
Rectangle class >> fromUser [
	"Answer an instance of me that is determined by having the user 
	designate the top left and bottom right corners. The gridding for user 
	selection is 1@1."

	^self fromUser: 1 @ 1
]

{ #category : #'instance creation' }
Rectangle class >> fromUser: gridPoint [
	"Answer a Rectangle that is determined by having the user 
	designate the top left and bottom right corners. 
	The cursor reamins linked with the sensor, but
	the outline is kept gridded."
	| originRect |
	originRect := Cursor origin showWhile: 
		[((Sensor cursorPoint grid: gridPoint) extent: 0@0) newRectFrom:
			[:f | (Sensor cursorPoint grid: gridPoint) extent: 0@0]].
	^ Cursor corner showWhile:
		[originRect newRectFrom:
			[:f | f origin corner: (Sensor cursorPoint grid: gridPoint)]]
]

{ #category : #'instance creation' }
Rectangle class >> left: leftNumber right: rightNumber top: topNumber bottom: bottomNumber [ 
	"Answer an instance of me whose left, right, top, and bottom coordinates 
	are determined by the arguments."

	^ self basicNew setOrigin: leftNumber @ topNumber corner: rightNumber @ bottomNumber
]

{ #category : #'instance creation' }
Rectangle class >> locateMagnifiedView: aForm scale: scaleFactor [
	"Answer a rectangle at the location where the scaled view of the form,
	aForm, should be displayed."

	^ self originFromUser: (aForm extent * scaleFactor + (0@50))

]

{ #category : #'instance creation' }
Rectangle class >> merging: listOfRects [ 
	"A number of callers of merge: should use this method."
	| bottomRight topLeft |
	topLeft := listOfRects first topLeft.
	bottomRight := listOfRects first bottomRight.
	listOfRects
		allButFirstDo: [:r | topLeft := topLeft min: r topLeft.
			bottomRight := bottomRight max: r bottomRight].
	^self origin: topLeft corner: bottomRight.
	
]

{ #category : #'instance creation' }
Rectangle class >> origin: originPoint corner: cornerPoint [ 
	"Answer an instance of me whose corners (top left and bottom right) are 
	determined by the arguments."

	^self basicNew setOrigin: originPoint corner: cornerPoint
]

{ #category : #'instance creation' }
Rectangle class >> origin: originPoint extent: extentPoint [ 
	"Answer an instance of me whose top left corner is originPoint and width 
	by height is extentPoint."

	^self basicNew setOrigin: originPoint corner: originPoint + extentPoint
]

{ #category : #'instance creation' }
Rectangle class >> originFromUser: extentPoint [ 
	"Answer an instance of me that is determined by having the user 
	designate the top left corner. The width and height are determined by 
	extentPoint. The gridding for user selection is 1@1."

	^self originFromUser: extentPoint grid: 1 @ 1
]

{ #category : #'instance creation' }
Rectangle class >> originFromUser: extentPoint grid: gridPoint [ 
	"Answer an instance of me that is determined by having the user 
	designate the top left corner. The width and height are determined by 
	extentPoint. The gridding for user selection is scaleFactor. Assumes that 
	the sender has determined an extent that is a proper multiple of 
	scaleFactor."

	^ Cursor origin showWhile: 
		[((Sensor cursorPoint grid: gridPoint) extent: extentPoint) newRectFrom:
			[:f | (Sensor cursorPoint grid: gridPoint) extent: extentPoint]].

]

{ #category : #comparing }
Rectangle >> = aRectangle [ 
	"Answer true if the receiver's species, origin and corner match aRectangle's."

	self species = aRectangle species
		ifTrue: [^origin = aRectangle origin and: [corner = aRectangle corner]]
		ifFalse: [^false]
]

{ #category : #accessing }
Rectangle >> aboveCenter [
	"Answer the point slightly above the center of the receiver."

	^self topLeft + self bottomRight // (2@3)
]

{ #category : #'rectangle functions' }
Rectangle >> adjustTo: newRect along: side [ 
	"Return a copy adjusted to fit a neighbor that has changed size."
	side = #left ifTrue: [^ self withRight: newRect left].
	side = #right ifTrue: [^ self withLeft: newRect right].
	side = #top ifTrue: [^ self withBottom: newRect top].
	side = #bottom ifTrue: [^ self withTop: newRect bottom].
]

{ #category : #transforming }
Rectangle >> align: aPoint1 with: aPoint2 [ 
	"Answer a Rectangle that is a translated by aPoint2 - aPoint1."

	^self translateBy: aPoint2 - aPoint1
]

{ #category : #'rectangle functions' }
Rectangle >> allAreasOutsideList: aCollection do: aBlock [
	"Enumerate aBlock with all areas of the receiver not overlapping 
	any rectangle in the given collection"
	^self allAreasOutsideList: aCollection startingAt: 1 do: aBlock
]

{ #category : #'rectangle functions' }
Rectangle >> allAreasOutsideList: aCollection startingAt: startIndex do: aBlock [
	"Enumerate aBlock with all areas of the receiver not overlapping 
	any rectangle in the given collection"
	| yOrigin yCorner aRectangle index rr |
	index := startIndex.

	"Find the next intersecting rectangle from aCollection"
	[index <= aCollection size ifFalse:[^aBlock value: self].
	aRectangle := aCollection at: index.
	origin <= aRectangle corner and: [aRectangle origin <= corner]] 
		whileFalse:[index := index + 1].

	"aRectangle is intersecting; process it"
	aRectangle origin y > origin y 
		ifTrue: [rr := origin corner: corner x @ (yOrigin := aRectangle origin y).
				rr allAreasOutsideList: aCollection startingAt: index+1 do: aBlock]
		ifFalse: [yOrigin := origin y].
	aRectangle corner y < corner y
		ifTrue: [rr := origin x @ (yCorner := aRectangle corner y) corner: corner.
				rr allAreasOutsideList: aCollection startingAt: index+1 do: aBlock]
		ifFalse: [yCorner := corner y].
	aRectangle origin x > origin x 
		ifTrue: [rr := origin x @ yOrigin corner: aRectangle origin x @ yCorner.
				rr allAreasOutsideList: aCollection startingAt: index+1 do: aBlock].
	aRectangle corner x < corner x 
		ifTrue: [rr := aRectangle corner x @ yOrigin corner: corner x @ yCorner.
				rr allAreasOutsideList: aCollection startingAt: index+1 do: aBlock].
]

{ #category : #'rectangle functions' }
Rectangle >> amountToTranslateWithin: aRectangle [
	"Answer a Point, delta, such that self + delta is forced within aRectangle."
	"Altered so as to prefer to keep self topLeft inside when all of self
	cannot be made to fit 7/27/96 di"
	| dx dy |
	dx := 0.  dy := 0.
	self right > aRectangle right ifTrue: [dx := aRectangle right - self right].
	self bottom > aRectangle bottom ifTrue: [dy := aRectangle bottom - self bottom].
	(self left + dx) < aRectangle left ifTrue: [dx := aRectangle left - self left].
	(self top + dy) < aRectangle top ifTrue: [dy := aRectangle top - self top].
	^ dx@dy
]

{ #category : #accessing }
Rectangle >> area [
	"Answer the receiver's area, the product of width and height."
	| w |
	(w := self width) <= 0 ifTrue: [^ 0].
	^ w * self height max: 0
]

{ #category : #'rectangle functions' }
Rectangle >> areasOutside: aRectangle [
	"Answer an Array of Rectangles comprising the parts of the receiver not 
	intersecting aRectangle."

	| areas yOrigin yCorner |
	"Make sure the intersection is non-empty"
     (self intersects: aRectangle)
		ifFalse: [^Array with: self].
	areas := OrderedCollection new.
	aRectangle origin y > origin y
		ifTrue: [areas addLast: (origin corner: corner x @ (yOrigin := aRectangle origin y))]
		ifFalse: [yOrigin := origin y].
	aRectangle corner y < corner y
		ifTrue: [areas addLast: (origin x @ (yCorner := aRectangle corner y) corner: corner)]
		ifFalse: [yCorner := corner y].
	aRectangle origin x > origin x 
		ifTrue: [areas addLast: (origin x @ yOrigin corner: aRectangle origin x @ yCorner)].
	aRectangle corner x < corner x 
		ifTrue: [areas addLast: (aRectangle corner x @ yOrigin corner: corner x @ yCorner)].
	^areas
]

{ #category : #'rectangle functions' }
Rectangle >> bordersOn: her along: herSide [ 
	(herSide = #right and: [self left = her right])
	| (herSide = #left and: [self right = her left])
		ifTrue:
		[^ (self top max: her top) < (self bottom min: her bottom)].
	(herSide = #bottom and: [self top = her bottom])
	| (herSide = #top and: [self bottom = her top])
		ifTrue:
		[^ (self left max: her left) < (self right min: her right)].
	^ false
]

{ #category : #accessing }
Rectangle >> bottom [
	"Answer the position of the receiver's bottom horizontal line."

	^corner y
]

{ #category : #accessing }
Rectangle >> bottom: aNumber [
	^origin corner: corner x @ aNumber
]

{ #category : #accessing }
Rectangle >> bottomCenter [
	"Answer the point at the center of the bottom horizontal line of the 
	receiver."

	^self center x @ self bottom
]

{ #category : #transforming }
Rectangle >> bottomHalf [
	^self withTop: self center y
]

{ #category : #accessing }
Rectangle >> bottomLeft [
	"Answer the point at the left edge of the bottom horizontal line of the 
	receiver."

	^origin x @ corner y
]

{ #category : #transforming }
Rectangle >> bottomLeftQuadrant [
	^self leftCenter corner: self bottomCenter
]

{ #category : #accessing }
Rectangle >> bottomRight [
	"Answer the point at the right edge of the bottom horizontal line of the 
	receiver."

	^corner
]

{ #category : #transforming }
Rectangle >> bottomRightQuadrant [
	^self center corner: self bottomRight
]

{ #category : #accessing }
Rectangle >> boundingBox [
	^ self
]

{ #category : #'truncation and round off' }
Rectangle >> ceiling [
	"Answer the integer rectange to the bottom right of receiver.
	Return reciever if it already and integerRectange."

	self isIntegerRectangle ifTrue: [ ^ self ] .

	^origin ceiling corner: corner ceiling
]

{ #category : #accessing }
Rectangle >> center [
	"Answer the point at the center of the receiver."

	^self topLeft + self bottomRight // 2
]

{ #category : #transforming }
Rectangle >> centeredBeneath: aRectangle [
	 "Move the reciever so that its top center point coincides with the bottom center point of aRectangle.  5/20/96 sw:"

	^ self align: self topCenter with: aRectangle bottomCenter
]

{ #category : #'truncation and round off' }
Rectangle >> compressTo: grid [
	"Answer a Rectangle whose origin and corner are rounded to grid x and grid y.
	Rounding is done by upper value on origin and lower value on corner so that
	rounded rectangle is inside self."

	^Rectangle origin: (origin roundUpTo: grid)
				corner: (corner roundDownTo: grid)
]

{ #category : #'truncation and round off' }
Rectangle >> compressed [
	"Answer a Rectangle whose origin and corner are rounded to integers.
	Rounding is done by upper value on origin and lower value on corner so that
	rounded rectangle is inside self."

	^Rectangle origin: origin ceiling corner: corner floor
]

{ #category : #testing }
Rectangle >> containsPoint: aPoint [ 
	"Answer whether aPoint is within the receiver."

	^origin <= aPoint and: [aPoint < corner]
]

{ #category : #testing }
Rectangle >> containsRect: aRect [
	"Answer whether aRect is within the receiver (OK to coincide)."

	^ aRect origin >= origin and: [aRect corner <= corner]

]

{ #category : #accessing }
Rectangle >> corner [
	"Answer the point at the bottom right corner of the receiver."

	^corner
]

{ #category : #accessing }
Rectangle >> corners [
	"Return an array of corner points in the order of a quadrilateral spec for WarpBlt."

	^ Array
		with: self topLeft
		with: self bottomLeft
		with: self bottomRight
		with: self topRight

]

{ #category : #FMP }
Rectangle >> deltaToEnsureInOrCentered: r extra: aNumber [

	| dX dY halfXDiff halfYDiff |
	dX := dY := 0.
	halfXDiff := (r width - self width * aNumber) truncated.
	halfYDiff := (r height - self height  * aNumber) truncated.
	self left < r left
		ifTrue: [dX := self left - r left - halfXDiff]
		ifFalse: [self right > r right ifTrue: [dX := self right - r right + halfXDiff]].
	self top < r top
		ifTrue: [dY := self top - r top - halfYDiff]
		ifFalse: [self bottom > r bottom ifTrue: [dY := self bottom - r bottom + halfYDiff]].
	^dX @ dY

]

{ #category : #'rectangle functions' }
Rectangle >> encompass: aPoint [ 
	"Answer a Rectangle that contains both the receiver and aPoint.  5/30/96 sw"

	^ Rectangle 
		origin: (origin min: aPoint)
		corner: (corner max:  aPoint)
]

{ #category : #'rectangle functions' }
Rectangle >> expandBy: delta [ 
	"Answer a Rectangle that is outset from the receiver by delta. delta is a 
	Rectangle, Point, or scalar."

	(delta isRectangle)
		ifTrue: [^Rectangle 
					origin: origin - delta origin 
					corner: corner + delta corner]
		ifFalse: [^Rectangle 
					origin: origin - delta 
					corner: corner + delta]
]

{ #category : #'truncation and round off' }
Rectangle >> expandTo: grid [
	"Answer a Rectangle whose origin and corner are rounded to grid x and grid y.
	Rounding is done by upper value on origin and lower value on corner so that
	self is inside rounded rectangle."

	^Rectangle origin: (origin roundDownTo: grid)
				corner: (corner roundUpTo: grid)
]

{ #category : #'truncation and round off' }
Rectangle >> expanded [
	"Answer a Rectangle whose origin and corner are rounded to integers.
	Rounding is done by upper value on origin and lower value on corner so that
	self is inside rounded rectangle."

	^Rectangle origin: origin floor corner: corner ceiling
]

{ #category : #'rectangle functions' }
Rectangle >> extendBy: delta [ 
	"Answer a Rectangle with the same origin as the receiver, but whose corner is offset by delta. delta is a 
	Rectangle, Point, or scalar."

	(delta isRectangle)
		ifTrue: [^Rectangle 
					origin: origin
					corner: corner + delta corner]
		ifFalse: [^Rectangle 
					origin: origin
					corner: corner + delta]
]

{ #category : #accessing }
Rectangle >> extent [
	"Answer a point with the receiver's 
	width @ the receiver's height."

	^corner - origin
]

{ #category : #transforming }
Rectangle >> flipBy: direction centerAt: aPoint [ 
	"Return a copy flipped #vertical or #horizontal, about aPoint."
	| futureOrigin futureCorner |
	direction == #horizontal
		ifTrue:
			[futureOrigin := self topRight.
			futureCorner := self bottomLeft]
		ifFalse: [direction == #vertical
			ifTrue:
				[futureOrigin := self bottomLeft.
				futureCorner := self topRight]
			ifFalse: [self error: 'unrecognizable direction']].
	^ (futureOrigin flipBy: direction centerAt: aPoint)
		corner: (futureCorner flipBy: direction centerAt: aPoint)
]

{ #category : #'truncation and round off' }
Rectangle >> floor [
	"Answer the integer rectange to the topleft of receiver.
	Return reciever if it already and integerRectange."

	self isIntegerRectangle ifTrue: [ ^ self ] .

	^origin floor corner: corner floor
]

{ #category : #'rectangle functions' }
Rectangle >> forPoint: aPoint closestSideDistLen: sideDistLenBlock [
	"Evaluate the block with my side (symbol) closest to aPoint,
		the approx distance of aPoint from that side, and
		the length of the side (or 0 if aPoint is beyond the side)"
	| side |
	side := self sideNearestTo: aPoint.
	side == #right ifTrue:
		[^ sideDistLenBlock value: side value: (self right - aPoint x) abs
			value: ((aPoint y between: self top and: self bottom)
						ifTrue: [self height] ifFalse: [0])].
	side == #left ifTrue:
		[^ sideDistLenBlock value: side value: (self left - aPoint x) abs
			value: ((aPoint y between: self top and: self bottom)
						ifTrue: [self height] ifFalse: [0])].
	side == #bottom ifTrue:
		[^ sideDistLenBlock value: side value: (self bottom - aPoint y) abs
			value: ((aPoint x between: self left and: self right)
						ifTrue: [self width] ifFalse: [0])].
	side == #top ifTrue:
		[^ sideDistLenBlock value: side value: (self top - aPoint y) abs
			value: ((aPoint x between: self left and: self right)
						ifTrue: [self width] ifFalse: [0])].
]

{ #category : #testing }
Rectangle >> hasPositiveExtent [
	^ (corner x > origin x) and: [corner y > origin y]
]

{ #category : #comparing }
Rectangle >> hash [
	"Hash is reimplemented because = is implemented."

	^origin hash bitXor: corner hash
]

{ #category : #accessing }
Rectangle >> height [
	"Answer the height of the receiver."

	^corner y - origin y
]

{ #category : #accessing }
Rectangle >> innerCorners [
	"Return an array of inner corner points,
	ie, the most extreme pixels included,
	in the order of a quadrilateral spec for WarpBlt"
	| r1 |
	r1 := self topLeft corner: self bottomRight - (1@1).
	^ Array with: r1 topLeft with: r1 bottomLeft with: r1 bottomRight with: r1 topRight
]

{ #category : #'rectangle functions' }
Rectangle >> insetBy: delta [ 
	"Answer a Rectangle that is inset from the receiver by delta. delta is a 
	Rectangle, Point, or scalar."

	
	(delta isRectangle)
		ifTrue: [^Rectangle 
					origin: origin + delta origin 
					corner: corner - delta corner]
		ifFalse: [^Rectangle 
					origin: origin + delta 
					corner: corner - delta]
]

{ #category : #'rectangle functions' }
Rectangle >> insetOriginBy: originDeltaPoint cornerBy: cornerDeltaPoint [ 
	"Answer a Rectangle that is inset from the receiver by a given amount in 
	the origin and corner."

	^Rectangle
		origin: origin + originDeltaPoint
		corner: corner - cornerDeltaPoint
]

{ #category : #'rectangle functions' }
Rectangle >> intersect: aRectangle [ 
	"Answer a Rectangle that is the area in which the receiver overlaps with 
	aRectangle. Optimized for speed; old code read:
		^Rectangle 
			origin: (origin max: aRectangle origin)
			corner: (corner min: aRectangle corner)
	"
	| aPoint left right top bottom |
	aPoint := aRectangle origin.
	aPoint x > origin x ifTrue:[left := aPoint x] ifFalse:[left := origin x].
	aPoint y > origin y ifTrue:[top := aPoint y] ifFalse:[top := origin y].
	aPoint := aRectangle corner.
	aPoint x < corner x ifTrue:[right := aPoint x] ifFalse:[right := corner x].
	aPoint y < corner y ifTrue:[bottom := aPoint y] ifFalse:[bottom := corner y].
	^Rectangle
		origin: (left@top)
		corner: (right@bottom)

]

{ #category : #testing }
Rectangle >> intersects: aRectangle [ 
	"Answer whether aRectangle intersects the receiver anywhere."
	"Optimized; old code answered:
		(origin max: aRectangle origin) < (corner min: aRectangle corner)"

	| rOrigin rCorner |
	rOrigin := aRectangle origin.
	rCorner := aRectangle corner.
	rCorner x <= origin x	ifTrue: [^ false].
	rCorner y <= origin y	ifTrue: [^ false].
	rOrigin x >= corner x	ifTrue: [^ false].
	rOrigin y >= corner y	ifTrue: [^ false].
"None of the two rectangle shall be empty"
	corner x < origin x	ifTrue: [^ false].
	corner y < origin y	ifTrue: [^ false].
	rCorner x < rOrigin x	ifTrue: [^ false].
	rCorner y < rOrigin y	ifTrue: [^ false].
	^ true

]

{ #category : #'truncation and round off' }
Rectangle >> isIntegerRectangle [
	"Answer true if all component of receiver are integral."

	^origin isIntegerPoint and: [ corner isIntegerPoint ]
]

{ #category : #testing }
Rectangle >> isRectangle [
	^true
]

{ #category : #testing }
Rectangle >> isTall [
	^ self height > self width
]

{ #category : #testing }
Rectangle >> isWide [
	^ self width > self height
]

{ #category : #testing }
Rectangle >> isZero [
	^origin isZero and:[corner isZero]
]

{ #category : #accessing }
Rectangle >> left [
	"Answer the position of the receiver's left vertical line."

	^origin x
]

{ #category : #accessing }
Rectangle >> left: aNumber [
	^aNumber @ origin y corner: corner
]

{ #category : #accessing }
Rectangle >> leftCenter [
	"Answer the point at the center of the receiver's left vertical line."

	^self left @ self center y
]

{ #category : #transforming }
Rectangle >> leftHalf [
	^self withRight: self center x
]

{ #category : #'rectangle functions' }
Rectangle >> merge: aRectangle [ 
	"Answer a Rectangle that contains both the receiver and aRectangle."

	^Rectangle 
		origin: (origin min: aRectangle origin)
		corner: (corner max: aRectangle corner)
]

{ #category : #transforming }
Rectangle >> newRectButtonPressedDo: newRectBlock [ 
	"Track the outline of a new rectangle until mouse button 
	changes. newFrameBlock produces each new rectangle from the 
	previous. Only tracks while mouse is down."
	| rect newRect buttonNow delay |
	delay := Delay forMilliseconds: 10.
	buttonNow := Sensor anyButtonPressed.
	rect := self.
	Display
		border: rect
		width: 2
		rule: Form reverse
		fillColor: Color gray.
	[buttonNow]
		whileTrue: [delay wait.
			buttonNow := Sensor anyButtonPressed.
			newRect := newRectBlock value: rect.
			newRect = rect
				ifFalse: [Display
						border: rect
						width: 2
						rule: Form reverse
						fillColor: Color gray.
					Display
						border: newRect
						width: 2
						rule: Form reverse
						fillColor: Color gray.
					rect := newRect]].
	Display
		border: rect
		width: 2
		rule: Form reverse
		fillColor: Color gray.
	Project current pointerMoved. 
	Sensor processEvent: Sensor createMouseEvent.
	^ rect
]

{ #category : #transforming }
Rectangle >> newRectFrom: newRectBlock [
	"Track the outline of a new rectangle until mouse button changes.
	newFrameBlock produces each new rectangle from the previous"
	| rect newRect buttonStart buttonNow delay |
	delay := Delay forMilliseconds: 10.
	buttonStart := buttonNow := Sensor anyButtonPressed.
	rect := self.
	Display border: rect width: 2 rule: Form reverse fillColor: Color gray.
	[buttonNow == buttonStart] whileTrue: 
		[delay wait.
		buttonNow := Sensor anyButtonPressed.
		newRect := newRectBlock value: rect.
		newRect = rect ifFalse:
			[Display border: rect width: 2 rule: Form reverse fillColor: Color gray.
			Display border: newRect width: 2 rule: Form reverse fillColor: Color gray.
			rect := newRect]].
	Display border: rect width: 2 rule: Form reverse fillColor: Color gray.
	Project current pointerMoved. 
	Sensor processEvent: Sensor createMouseEvent.
	^ rect
]

{ #category : #accessing }
Rectangle >> origin [
	"Answer the point at the top left corner of the receiver."

	^origin
]

{ #category : #'rectangle functions' }
Rectangle >> outsetBy: delta [ 
	"Answer a Rectangle that is outset from the receiver by delta. delta is a 
	Rectangle, Point, or scalar."

	(delta isRectangle)
		ifTrue: [^Rectangle 
					origin: origin - delta origin 
					corner: corner + delta corner]
		ifFalse: [^Rectangle 
					origin: origin - delta 
					corner: corner + delta]
]

{ #category : #'rectangle functions' }
Rectangle >> pointNearestTo: aPoint [
	"Return the point on my border closest to aPoint"
	| side |
	(self containsPoint: aPoint)
		ifTrue:
			[side := self sideNearestTo: aPoint.
			side == #right ifTrue: [^ self right @ aPoint y].
			side == #left ifTrue: [^ self left @ aPoint y].
			side == #bottom ifTrue: [^ aPoint x @ self bottom].
			side == #top ifTrue: [^ aPoint x @ self top]]
		ifFalse:
			[^ aPoint adhereTo: self]
]

{ #category : #printing }
Rectangle >> printOn: aStream [ 
	"Refer to the comment in Object|printOn:."

	origin printOn: aStream.
	aStream nextPutAll: ' corner: '.
	corner printOn: aStream
]

{ #category : #'rectangle functions' }
Rectangle >> quickMerge: aRectangle [ 
	"Answer the receiver if it encloses the given rectangle or the merge of the two rectangles if it doesn't. THis method is an optimization to reduce extra rectangle creations."

	| useRcvr rOrigin rCorner minX maxX minY maxY |
	useRcvr := true.
	rOrigin := aRectangle topLeft.
	rCorner := aRectangle bottomRight.
	minX := rOrigin x < origin x ifTrue: [useRcvr := false. rOrigin x] ifFalse: [origin x].
	maxX := rCorner x > corner x ifTrue: [useRcvr := false. rCorner x] ifFalse: [corner x].
	minY := rOrigin y < origin y ifTrue: [useRcvr := false. rOrigin y] ifFalse: [origin y].
	maxY := rCorner y > corner y ifTrue: [useRcvr := false. rCorner y] ifFalse: [corner y].

	useRcvr
		ifTrue: [^ self]
		ifFalse: [^ Rectangle origin: minX@minY corner: maxX@maxY].

]

{ #category : #'rectangle functions' }
Rectangle >> rectanglesAt: y height: ht [
	(y+ht) > self bottom ifTrue: [^ Array new].
	^ Array with: (origin x @ y corner: corner x @ (y+ht))
]

{ #category : #accessing }
Rectangle >> right [
	"Answer the position of the receiver's right vertical line."

	^corner x
]

{ #category : #accessing }
Rectangle >> right: aNumber [
	^origin corner: aNumber @ corner y
]

{ #category : #accessing }
Rectangle >> rightCenter [
	"Answer the point at the center of the receiver's right vertical line."

	^self right @ self center y
]

{ #category : #transforming }
Rectangle >> rightHalf [
	^self withLeft: self center x
]

{ #category : #transforming }
Rectangle >> rotateBy: direction centerAt: aPoint [
	"Return a copy rotated #right, #left, or #pi about aPoint"
	| futureOrigin futureCorner |
	direction == #pi
		ifTrue:
			[futureOrigin := self corner.
			futureCorner := self origin]
		ifFalse: [direction == #left
			ifTrue:
				[futureOrigin := self topRight.
				futureCorner := self bottomLeft]
			ifFalse: [direction == #right
				ifTrue:
					[futureOrigin := self bottomLeft.
					futureCorner := self topRight]
				ifFalse: [self error: 'unrecognizable direction']]].
	^ (futureOrigin rotateBy: direction centerAt: aPoint)
		corner: (futureCorner rotateBy: direction centerAt: aPoint)
]

{ #category : #'truncation and round off' }
Rectangle >> roundTo: grid [
	"Answer a Rectangle whose origin and corner are rounded to grid x and grid y."

	^Rectangle origin: (origin roundTo: grid)
				corner: (corner roundTo: grid)
]

{ #category : #'truncation and round off' }
Rectangle >> rounded [
	"Answer a Rectangle whose origin and corner are rounded."

	^Rectangle origin: origin rounded extent: self extent rounded
]

{ #category : #transforming }
Rectangle >> scaleBy: scale [ 
	"Answer a Rectangle scaled by scale, a Point or a scalar."

	^Rectangle origin: origin * scale corner: corner * scale
]

{ #category : #transforming }
Rectangle >> scaleFrom: rect1 to: rect2 [
	"Produce a rectangle stretched according to the stretch from rect1 to rect2"
	^ (origin scaleFrom: rect1 to: rect2)
		corner: (corner scaleFrom: rect1 to: rect2)
]

{ #category : #private }
Rectangle >> setOrigin: topLeft corner: bottomRight [
	origin := topLeft.
	corner := bottomRight
]

{ #category : #'rectangle functions' }
Rectangle >> sideNearestTo: aPoint [
	| distToLeft distToRight distToTop distToBottom closest side |
	distToLeft := aPoint x - self left.
	distToRight := self right - aPoint x.
	distToTop := aPoint y - self top.
	distToBottom := self bottom - aPoint y.
	closest := distToLeft. side := #left.
	distToRight < closest ifTrue: [closest := distToRight. side := #right].
	distToTop < closest ifTrue: [closest := distToTop. side := #top].
	distToBottom < closest ifTrue: [closest := distToBottom. side := #bottom].
	^ side
"
 | r | r := Rectangle fromUser.
Display border: r width: 1.
[Sensor anyButtonPressed] whileFalse:
	[(r sideNearestTo: Sensor cursorPoint) , '      ' displayAt: 0@0]
"
]

{ #category : #transforming }
Rectangle >> squishedWithin: aRectangle [
	"Return an adjustment of the receiver that fits within aRectangle by reducing its size, not by changing its origin.  "

	^ origin corner: (corner min: aRectangle bottomRight)

"(50 @ 50 corner: 160 @ 100) squishedWithin:  (20 @ 10 corner: 90 @ 85)"

]

{ #category : #printing }
Rectangle >> storeOn: aStream [ 
	"printed form is good for storing too"
	
	aStream nextPut: $(.
	self printOn: aStream.
	aStream nextPut: $).
]

{ #category : #'rectangle functions' }
Rectangle >> swallow: aRectangle [ 
	"Modify the receiver so that it contains aRectangle."

	origin := origin min: aRectangle origin.
	corner := corner max: aRectangle corner
]

{ #category : #accessing }
Rectangle >> top [
	"Answer the position of the receiver's top horizontal line."

	^origin y
]

{ #category : #accessing }
Rectangle >> top: aNumber [
	^origin x @ aNumber corner: corner
]

{ #category : #accessing }
Rectangle >> topCenter [
	"Answer the point at the center of the receiver's top horizontal line."

	^self center x @ self top
]

{ #category : #transforming }
Rectangle >> topHalf [
	^self withBottom: self center y
]

{ #category : #accessing }
Rectangle >> topLeft [
	"Answer the point at the top left corner of the receiver's top horizontal line."

	^origin

]

{ #category : #transforming }
Rectangle >> topLeftQuadrant [
	^self topLeft corner: self center
]

{ #category : #accessing }
Rectangle >> topRight [
	"Answer the point at the top right corner of the receiver's top horizontal 
	line."

	^corner x @ origin y
]

{ #category : #transforming }
Rectangle >> topRightQuadrant [
	^self topCenter corner: self rightCenter
]

{ #category : #transforming }
Rectangle >> translateBy: factor [ 
	"Answer a Rectangle translated by factor, a Point or a scalar."

	^Rectangle origin: origin + factor corner: corner + factor
]

{ #category : #transforming }
Rectangle >> translatedAndSquishedToBeWithin: aRectangle [
	"Return an adjustment of the receiver that fits within aRectangle by
		- translating it to be within aRectangle if necessary, then
		- reducing its size, if necessary"

	^ (self translatedToBeWithin: aRectangle) squishedWithin: aRectangle
]

{ #category : #'rectangle functions' }
Rectangle >> translatedToBeWithin: aRectangle [
	"Answer a copy of the receiver that does not extend beyond aRectangle.  7/8/96 sw"

	^ self translateBy: (self amountToTranslateWithin: aRectangle)
]

{ #category : #'truncation and round off' }
Rectangle >> truncateTo: grid [
	"Answer a Rectangle whose origin and corner are truncated to grid x and grid y."

	^Rectangle origin: (origin truncateTo: grid)
				corner: (corner truncateTo: grid)
]

{ #category : #'truncation and round off' }
Rectangle >> truncated [
	"Answer a Rectangle whose origin and corner have any fractional parts removed. Answer the receiver if its coordinates are already integral."

	(origin x isInteger and:
	[origin y isInteger and:
	[corner x isInteger and:
	[corner y isInteger]]])
		ifTrue: [^ self].

	^ Rectangle origin: origin truncated corner: corner truncated

]

{ #category : #accessing }
Rectangle >> width [
	"Answer the width of the receiver."

	^corner x - origin x
]

{ #category : #'rectangle functions' }
Rectangle >> withBottom: y [ 
	"Return a copy of me with a different bottom y"
	^ origin x @ origin y corner: corner x @ y
]

{ #category : #'rectangle functions' }
Rectangle >> withHeight: height [ 
	"Return a copy of me with a different height"
	^ origin corner: corner x @ (origin y + height)
]

{ #category : #'rectangle functions' }
Rectangle >> withLeft: x [ 
	"Return a copy of me with a different left x"
	^ x @ origin y corner: corner x @ corner y
]

{ #category : #'rectangle functions' }
Rectangle >> withRight: x [ 
	"Return a copy of me with a different right x"
	^ origin x @ origin y corner: x @ corner y
]

{ #category : #'rectangle functions' }
Rectangle >> withSide: side setTo: value [  "return a copy with side set to value"
	^ self perform: (#(withLeft: withRight: withTop: withBottom: )
							at: (#(left right top bottom) indexOf: side))
		with: value
]

{ #category : #'rectangle functions' }
Rectangle >> withSideOrCorner: side setToPoint: newPoint [
	"Return a copy with side set to newPoint"

	^ self withSideOrCorner: side setToPoint: newPoint minExtent: 0@0
]

{ #category : #'rectangle functions' }
Rectangle >> withSideOrCorner: side setToPoint: newPoint minExtent: minExtent [
	"Return a copy with side set to newPoint"
	^self withSideOrCorner: side setToPoint: newPoint minExtent: minExtent
		limit: ((#(left top) includes: side) ifTrue: [SmallInteger minVal] ifFalse: [SmallInteger maxVal])
]

{ #category : #'rectangle functions' }
Rectangle >> withSideOrCorner: side setToPoint: newPoint minExtent: minExtent limit: limit [
	"Return a copy with side set to newPoint"
	side = #top ifTrue: [^ self withTop: (newPoint y min: corner y - minExtent y max: limit + minExtent y)].
	side = #bottom ifTrue: [^ self withBottom: (newPoint y min: limit - minExtent y max: origin y + minExtent y)].
	side = #left ifTrue: [^ self withLeft: (newPoint x min: corner x - minExtent x max: limit + minExtent x)].
	side = #right ifTrue: [^ self withRight: (newPoint x min: limit - minExtent x max: origin x + minExtent x)].
	side = #topLeft ifTrue: [^ (newPoint min: corner - minExtent) corner: self bottomRight].
	side = #bottomRight ifTrue: [^ self topLeft corner: (newPoint max: origin + minExtent)].
	side = #bottomLeft ifTrue: [^ self topRight rect: ((newPoint x min: corner x - minExtent x) @ (newPoint y max: origin y + minExtent y))].
	side = #topRight ifTrue: [^ self bottomLeft rect: ((newPoint x max: origin x + minExtent x) @ (newPoint y min: corner y - minExtent y))].
]

{ #category : #'rectangle functions' }
Rectangle >> withTop: y [ 
	"Return a copy of me with a different top y"
	^ origin x @ y corner: corner x @ corner y
]

{ #category : #'rectangle functions' }
Rectangle >> withWidth: width [ 
	"Return a copy of me with a different width"
	^ origin corner: (origin x + width) @ corner y
]
