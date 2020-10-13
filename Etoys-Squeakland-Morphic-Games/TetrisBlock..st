Class {
	#name : #TetrisBlock,
	#superclass : #Morph,
	#instVars : [
		'angle',
		'shapeInfo',
		'board',
		'baseCellNumber'
	],
	#classVars : [
		'ShapeChoices'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'as yet unclassified' }
TetrisBlock class >> flipShapes: anArray [

	^OrderedCollection new 
		add: anArray;
		add: (anArray collect: [ :each | each y negated @ each x]);
		add: (anArray collect: [ :each | each x negated @ each y negated]);
		add: (anArray collect: [ :each | each y @ each x negated]);
		yourself
	

]

{ #category : #'new-morph participation' }
TetrisBlock class >> includeInNewMorphMenu [

	^false
]

{ #category : #'as yet unclassified' }
TetrisBlock class >> shapeChoices [

	^ ShapeChoices ifNil: [
		ShapeChoices := {
			{ {  0 @ 0 .  1 @ 0 .  0 @ 1 .  1 @ 1  } }.	"square - one is sufficient here"
			self flipShapes: {  0 @  0 . -1 @  0 .  1 @  0 .  0 @ -1  }.	"T"
			{ 
				{  0 @ 0 . -1 @ 0 .  1 @ 0 .  2 @ 0  }.
				{  0 @ 0 .  0 @ -1 .  0 @ 1 .  0 @ 2  } 	"long - two are sufficient here"
			}.
			self flipShapes: { 0 @ 0 .  0 @ -1 .  0 @  1 .  1 @  1  }.	"L"
			self flipShapes: { 0 @ 0 .  0 @ -1 .  0 @  1 . -1 @  1  }.	"inverted L"
			self flipShapes: { 0 @ 0 . -1 @  0 .  0 @ -1 .  1 @ -1  }.	"S"
			self flipShapes: {  0 @ 0 .  1 @ 0 .  0 @ -1 . -1 @ -1  } "Z"
		}.
	]

]

{ #category : #'as yet unclassified' }
TetrisBlock >> board: theBoard [

	board := theBoard.
	4 timesRepeat: [
		self addMorph: (
			RectangleMorph new
				color: color;
				extent: board cellSize;
				borderRaised
		 )
	].
	self positionCellMorphs.
]

{ #category : #initialization }
TetrisBlock >> defaultBounds [
"answer the default bounds for the receiver"
	^ (2 @ 2) negated extent: 1 @ 1
]

{ #category : #initialization }
TetrisBlock >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Tetris colors atRandom
]

{ #category : #'as yet unclassified' }
TetrisBlock >> dropByOne [
 
	^self moveDeltaX: 0 deltaY: 1 deltaAngle: 0
]

{ #category : #initialization }
TetrisBlock >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	
	"keep this puppy out of sight"
	shapeInfo := self class shapeChoices atRandom.
	baseCellNumber := 4 atRandom + 2 @ 1.
	angle := 4 atRandom
]

{ #category : #'as yet unclassified' }
TetrisBlock >> moveDeltaX: deltaX deltaY: deltaY deltaAngle: deltaAngle [ 

	| delta |

	delta := deltaX @ deltaY.
	(shapeInfo atWrap: angle + deltaAngle) do: [ :offsetThisCell | 
		(board emptyAt: baseCellNumber + offsetThisCell + delta) ifFalse: [^ false]
	].
	baseCellNumber := baseCellNumber + delta.
	angle := angle + deltaAngle - 1 \\ 4 + 1.
	self positionCellMorphs.
	^ true 
]

{ #category : #'as yet unclassified' }
TetrisBlock >> positionCellMorphs [

	(shapeInfo atWrap: angle) withIndexDo: [ :each :index |
		(submorphs at: index)
			position: (board originForCell: baseCellNumber + each)
	].
	fullBounds := nil.
	self changed.
	 

]
