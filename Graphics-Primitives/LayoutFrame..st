"
I define a frame for positioning some morph in a proportional layout.

Instance variables:
	leftFraction 
	topFraction 
	rightFraction 
	bottomFraction 	<Float>		The fractional distance (between 0 and 1) to place the morph in its owner's bounds
	leftOffset 
	topOffset 
	rightOffset 
	bottomOffset 	<Integer>	Fixed pixel offset to apply after fractional positioning (e.g., ""10 pixel right of the center of the owner"")
"
Class {
	#name : #LayoutFrame,
	#superclass : #Object,
	#instVars : [
		'leftFraction',
		'leftOffset',
		'topFraction',
		'topOffset',
		'rightFraction',
		'rightOffset',
		'bottomFraction',
		'bottomOffset'
	],
	#category : #'Graphics-Primitives'
}

{ #category : #accessing }
LayoutFrame class >> classVersion [
	^1 "changed treatment of bottomOffset and rightOffset"

]

{ #category : #'instance creation' }
LayoutFrame class >> fractions: fractionsOrNil [
	^self fractions: fractionsOrNil offsets: nil
]

{ #category : #'instance creation' }
LayoutFrame class >> fractions: fractionsOrNil offsets: offsetsOrNil [

	| fractions offsets |

	fractions := fractionsOrNil ifNil: [0@0 extent: 0@0].
	offsets := offsetsOrNil ifNil: [0@0 extent: 0@0].
	^self new
		topFraction: fractions top offset: offsets top;
		leftFraction: fractions left offset: offsets left;
		bottomFraction: fractions bottom offset: offsets bottom;
		rightFraction: fractions right offset: offsets right

]

{ #category : #'instance creation' }
LayoutFrame class >> fullFrame [

	^ self fractions: (0 @ 0 corner: 1 @ 1)
]

{ #category : #'instance creation' }
LayoutFrame class >> offsets: offsetsOrNil [
	^self fractions: nil offsets: offsetsOrNil
]

{ #category : #accessing }
LayoutFrame >> bottomFraction [
	^bottomFraction
]

{ #category : #accessing }
LayoutFrame >> bottomFraction: aNumber [
	bottomFraction := aNumber
]

{ #category : #accessing }
LayoutFrame >> bottomFraction: aNumber offset: anInteger [

	bottomFraction := aNumber.
	bottomOffset := anInteger
]

{ #category : #accessing }
LayoutFrame >> bottomOffset [
	^bottomOffset
]

{ #category : #accessing }
LayoutFrame >> bottomOffset: anInteger [
	bottomOffset := anInteger
]

{ #category : #'objects from disk' }
LayoutFrame >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	| className oldClassVersion |

	"JW 2/1/2001"
	"Since class version isn't passed in varDict, look it up through smartRefSrm."
	className := varDict at: #ClassName.
	oldClassVersion := (smartRefStrm structures at: className) first.
	(oldClassVersion = 0) ifTrue: [ self negateBottomRightOffsets ].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.

]

{ #category : #'initialize-release' }
LayoutFrame >> fixup [
	"Set-up default value for un-initialized layout frames"
	
	"LayoutFrame allInstancesDo: [:e | e fixup]."
	
	leftFraction ifNil: [leftFraction := 0].
	leftOffset ifNil: [leftOffset := 0].
	topFraction ifNil: [topFraction := 0].
	topOffset ifNil: [topOffset := 0].
	rightFraction ifNil: [rightFraction := 0].
	rightOffset ifNil: [rightOffset := 0].
	bottomFraction ifNil: [bottomFraction := 0].
	bottomOffset ifNil: [bottomOffset := 0].
]

{ #category : #testing }
LayoutFrame >> hasFixedHeight [

	^ self topFraction = self bottomFraction
]

{ #category : #testing }
LayoutFrame >> hasFixedWidth [

	^ self leftFraction = self rightFraction
]

{ #category : #'initialize-release' }
LayoutFrame >> initialize [
	"By default, let the frame be empty.
	This way, we can later define a proportional layout via fractions,
	or a fixed layout via offsets, or whatever mixture of both."
	
	leftFraction := leftOffset := topFraction := topOffset := rightFraction := rightOffset := bottomFraction := bottomOffset := 0
]

{ #category : #layout }
LayoutFrame >> layout: oldBounds in: newBounds [
	"Return the proportional rectangle insetting the given bounds"
	| left right top bottom | 
	left := newBounds left + (newBounds width * leftFraction).
	left := left + leftOffset.
	right := newBounds right - (newBounds width * (1.0 - rightFraction)).
	right := right + rightOffset.
	top := newBounds top + (newBounds height * topFraction).
	top := top + topOffset.
	bottom := newBounds bottom - (newBounds height * (1.0 - bottomFraction)).
	bottom := bottom + bottomOffset.
	^(left rounded @ top rounded) corner: (right rounded @ bottom rounded)
]

{ #category : #accessing }
LayoutFrame >> leftFraction [
	^leftFraction
]

{ #category : #accessing }
LayoutFrame >> leftFraction: aNumber [
	leftFraction := aNumber
]

{ #category : #accessing }
LayoutFrame >> leftFraction: aNumber offset: anInteger [

	leftFraction := aNumber.
	leftOffset := anInteger
]

{ #category : #accessing }
LayoutFrame >> leftOffset [
	^leftOffset
]

{ #category : #accessing }
LayoutFrame >> leftOffset: anInteger [
	leftOffset := anInteger
]

{ #category : #layout }
LayoutFrame >> minExtentFrom: minExtent [
	"Return the minimal extent the given bounds can be represented in"
	^ (self minWidthFrom: minExtent x) @ (self minHeightFrom: minExtent y)
]

{ #category : #layout }
LayoutFrame >> minHeightFrom: minHeight [
	"Return the minimal height the given bounds can be represented in
	we have:
		top = (height * topFraction + topOffset)
		bottom = (height * bottomFraction + bottomOffset)
	we want to fullfill those constraints if possible:
		0 <= top <= height
		0 <= bottom <= heigth
		bottom - top >= minHeight"
	| height |
	height := bottomFraction = topFraction
		ifTrue: [0]
		ifFalse: [minHeight + topOffset - bottomOffset / (bottomFraction - topFraction) max: 0].
	topFraction < 1 ifTrue: [height := height max: topOffset / (1 - topFraction)].
	bottomFraction < 1 ifTrue: [height := height max: bottomOffset / (1 - bottomFraction)].
	topFraction > 0 ifTrue: [height := height max: topOffset negated / topFraction].
	bottomFraction > 0 ifTrue: [height := height max: bottomOffset negated / bottomFraction].
	^ height truncated
]

{ #category : #layout }
LayoutFrame >> minWidthFrom: minWidth [
	"Return the minimal width the given bounds can be represented in
	we have:
		left = (width * leftFraction + leftOffset)
		right = (width * rightFraction + rightOffset)
	we want to fullfill those constraints if possible:
		0 <= left <= width
		0 <= right <= heigth
		right - left >= minwidth"
	| width |
	width := rightFraction = leftFraction
		ifTrue: [0]
		ifFalse: [minWidth + leftOffset - rightOffset / (rightFraction - leftFraction) max: 0].
	leftFraction < 1 ifTrue: [width := width max: leftOffset / (1 - leftFraction)].
	rightFraction < 1 ifTrue: [width := width max: rightOffset / (1 - rightFraction)].
	leftFraction > 0 ifTrue: [width := width max: leftOffset negated / leftFraction].
	rightFraction > 0 ifTrue: [width := width max: rightOffset negated / rightFraction].
	^ width truncated
]

{ #category : #'objects from disk' }
LayoutFrame >> negateBottomRightOffsets [

	bottomOffset ifNotNil: [ bottomOffset := bottomOffset negated ].
	rightOffset ifNotNil: [ rightOffset := rightOffset negated ].


]

{ #category : #printing }
LayoutFrame >> printOn: aStream [

	super printOn: aStream.
	
	aStream nextPutAll: '( '.
	
	{ {'l'. self leftFraction. self leftOffset}. {'t'. self topFraction. self topOffset}. {'r'. self rightFraction. self rightOffset}. {'b'. self bottomFraction. self bottomOffset} } do: [:spec |
		aStream nextPutAll: spec first; space.
		
		spec second printOn: aStream maxDecimalPlaces: 2.
		
		aStream nextPutAll: (spec third >= 0 ifTrue: ['+'] ifFalse: ['-']).
		spec third abs printOn: aStream maxDecimalPlaces: 0]
			separatedBy: [aStream space].
			
	aStream nextPutAll: ' )'.
]

{ #category : #accessing }
LayoutFrame >> rightFraction [
	^rightFraction
]

{ #category : #accessing }
LayoutFrame >> rightFraction: aNumber [
	rightFraction := aNumber
]

{ #category : #accessing }
LayoutFrame >> rightFraction: aNumber offset: anInteger [

	rightFraction := aNumber.
	rightOffset := anInteger
]

{ #category : #accessing }
LayoutFrame >> rightOffset [
	^rightOffset
]

{ #category : #accessing }
LayoutFrame >> rightOffset: anInteger [
	rightOffset := anInteger
]

{ #category : #accessing }
LayoutFrame >> topFraction [
	^topFraction
]

{ #category : #accessing }
LayoutFrame >> topFraction: aNumber [
	topFraction := aNumber
]

{ #category : #accessing }
LayoutFrame >> topFraction: aNumber offset: anInteger [

	topFraction := aNumber.
	topOffset := anInteger
]

{ #category : #accessing }
LayoutFrame >> topOffset [
	^topOffset
]

{ #category : #accessing }
LayoutFrame >> topOffset: anInteger [
	topOffset := anInteger
]
