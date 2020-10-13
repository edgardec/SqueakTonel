Class {
	#name : #MinesBoard,
	#superclass : #AlignmentMorph,
	#instVars : [
		'protoTile',
		'rows',
		'columns',
		'flashCount',
		'tileCount',
		'target',
		'actionSelector',
		'arguments',
		'gameStart',
		'gameOver'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'new-morph participation' }
MinesBoard class >> includeInNewMorphMenu [

	^false
]

{ #category : #accessing }
MinesBoard >> actionSelector [

	^ actionSelector
]

{ #category : #accessing }
MinesBoard >> actionSelector: aSymbolOrString [

	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^ actionSelector := nil].

	actionSelector := aSymbolOrString asSymbol.

]

{ #category : #accessing }
MinesBoard >> adjustTiles [
	"reset tiles"

	| newSubmorphs count r c |

	submorphs do: "clear out all of the tiles."
		[:m | m privateOwner: nil].

	newSubmorphs := OrderedCollection new.

	r := 0.
	c := 0.
	count := columns * rows.

	1 to: count do:
				[:m |
				newSubmorphs add:
					(protoTile copy
						position: self position + (self protoTile extent * (c @ r));
						actionSelector: #tileClickedAt:newSelection:modifier:;
						arguments: (Array with: (c+1) @ (r+1));
						target: self;
						privateOwner: self).
				c := c + 1.
				c >= columns ifTrue: [c := 0. r := r + 1]].
	submorphs := newSubmorphs asArray.


]

{ #category : #actions }
MinesBoard >> blowUp [
	owner timeDisplay stop.
	self submorphsDo:
		[:m |
		m isMine ifTrue:
				[m switchState: true.].
		].
	flashCount := 2.
	gameOver := true.
]

{ #category : #actions }
MinesBoard >> clearMines: location [

	| al tile |

	(self countFlags: location) = (self findMines: location) ifTrue:
		[
		{-1@ -1. -1@0. -1@1. 0@1. 1@1. 1@0. 1@ -1. 0@ -1} do:
			[:offsetPoint |
			al := location + offsetPoint.
			((al x between: 1 and: columns) and: [al y between: 1 and: rows]) ifTrue: [
				tile := self tileAt: al.
				(tile mineFlag or: [tile switchState]) ifFalse:[
		   		self stepOnTile: al].].].
		].
]

{ #category : #actions }
MinesBoard >> countFlags: location [

	| al at flags |
	flags := 0.
	{-1@ -1. -1@0. -1@1. 0@1. 1@1. 1@0. 1@ -1. 0@ -1} do:
		[:offsetPoint |
		al := location + offsetPoint.
		((al x between: 1 and: columns) and: [al y between: 1 and: rows]) ifTrue:
			[at := self tileAt: al.
			(at mineFlag ) ifTrue:
				[flags := flags+1]]].
		^flags.
]

{ #category : #initialization }
MinesBoard >> defaultBorderColor [
	^ Color transparent
]

{ #category : #initialization }
MinesBoard >> defaultBorderStyle [
	^ BorderStyle inset
]

{ #category : #initialization }
MinesBoard >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 2
]

{ #category : #initialization }
MinesBoard >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #geometry }
MinesBoard >> extent: aPoint [
	"constrain the extent to be a multiple of the protoTile size during resizing"
	super extent: (aPoint truncateTo: protoTile extent).
]

{ #category : #actions }
MinesBoard >> findMines: location [

	| al at mines |
	mines := 0.
	{-1@ -1. -1@0. -1@1. 0@1. 1@1. 1@0. 1@ -1. 0@ -1} do:
		[:offsetPoint |
		al := location + offsetPoint.
		((al x between: 1 and: columns) and: [al y between: 1 and: rows]) ifTrue:
			[at := self tileAt: al.
			(at isMine ) ifTrue:
				[mines := mines+1]]].
		^mines.
]

{ #category : #initialization }
MinesBoard >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	target := nil.
	actionSelector := #selection.
	arguments := #().
	""
	self layoutPolicy: nil;
	  hResizing: #rigid;
	  vResizing: #rigid.
	""
	rows := self preferredRows.
	columns := self preferredColumns.
	flashCount := 0.
	""
	self extent: self protoTile extent * (columns @ rows).
	self adjustTiles.
	self resetBoard
]

{ #category : #preferences }
MinesBoard >> preferredColumns [

	^ 30
]

{ #category : #preferences }
MinesBoard >> preferredMines [

	^ 99
]

{ #category : #preferences }
MinesBoard >> preferredRows [

	^ 16
]

{ #category : #accessing }
MinesBoard >> protoTile [

	protoTile ifNil: [protoTile := MinesTile new].
	^ protoTile
]

{ #category : #accessing }
MinesBoard >> protoTile: aTile [

	protoTile := aTile
]

{ #category : #initialization }
MinesBoard >> resetBoard [

	gameStart := false.
	gameOver := false.
	[flashCount = 0] whileFalse: [self step].
	flashCount := 0.
	tileCount := 0.
	Collection initialize.  "randomize the Collection class"
	self purgeAllCommands.
	self submorphsDo: "set tiles to original state."
		[:m | m privateOwner: nil.  "Don't propagate all these changes..."
		m mineFlag: false.
		m disabled: false.
		m switchState: false.
		m isMine: false.
		m privateOwner: self].
	self changed  "Now note the change in bulk"
]

{ #category : #actions }
MinesBoard >> selectTilesAdjacentTo: location [

	| al at mines |
"	{-1@0. 0@ -1. 1@0. 0@1} do:"
	{-1@ -1. -1@0. -1@1. 0@1. 1@1. 1@0. 1@ -1. 0@ -1} do:
		[:offsetPoint |
		al := location + offsetPoint.
		((al x between: 1 and: columns) and: [al y between: 1 and: rows]) ifTrue:
			[at := self tileAt: al.
			(at switchState not and: [at disabled not]) ifTrue:
				[
				mines := (self tileAt: al) nearMines.
				at mineFlag ifTrue: [at mineFlag: false.].  "just in case we flagged it as a mine."
				at switchState: true.
				tileCount := tileCount + 1.
				mines=0 ifTrue: [self selectTilesAdjacentTo: al]]]]

]

{ #category : #initialization }
MinesBoard >> setMines: notHere [

	| count total c r sm |
	count := 0.
	total := self preferredMines.
	[count < total] whileTrue:[
		c := columns atRandom.
		r := rows atRandom.
		c@r = notHere ifFalse: [
			sm := self tileAt: c@r.
			sm isMine ifFalse: [
				"sm color: Color red lighter lighter lighter lighter."
				sm isMine: true.
				count := count + 1.]]
		].
	1 to: columns do: [ :col |
		1 to: rows do: [ :row |
			(self tileAt: col @ row) nearMines: (self findMines: (col @ row))
			]].
			
]

{ #category : #'stepping and presenter' }
MinesBoard >> step [

	flashCount = 0 ifFalse: [
		self submorphsDo:
			[:m |
				m color: m color negated.].
			flashCount := flashCount - 1.
			].

]

{ #category : #actions }
MinesBoard >> stepOnTile: location [

	| mines tile |
	tile := self tileAt: location.
	tile mineFlag ifFalse:[
		tile isMine ifTrue: [tile color: Color gray darker darker. self blowUp. ^false.]
			ifFalse:[
				mines := self findMines: location.
				tile switchState: true.
				tileCount := tileCount + 1.
				mines = 0 ifTrue: 
					[self selectTilesAdjacentTo: location]].
		tileCount = ((columns*rows) - self preferredMines) ifTrue:[ gameOver := true. flashCount := 2. 	owner timeDisplay stop.].
		^ true.] 
		ifTrue: [^ false.]


]

{ #category : #testing }
MinesBoard >> stepTime [

	^ 300
]

{ #category : #accessing }
MinesBoard >> target [

	^ target
]

{ #category : #accessing }
MinesBoard >> target: anObject [

	target := anObject
]

{ #category : #accessing }
MinesBoard >> tileAt: aPoint [

	^ submorphs at: (aPoint x + ((aPoint y - 1) * columns))
]

{ #category : #actions }
MinesBoard >> tileClickedAt: location newSelection: isNewSelection modifier: mod [
	| tile |
	"self halt."
	gameOver ifTrue: [^ false].
	tile := self tileAt: location.

	isNewSelection ifFalse: [
		mod ifTrue: [
				tile mineFlag: ((tile mineFlag) not).
				tile mineFlag ifTrue: [owner minesDisplay value: (owner minesDisplay value - 1)]
						ifFalse: [owner minesDisplay value: (owner minesDisplay value + 1)].
				^ true.].

		gameStart ifFalse: [ 
			self setMines: location.
			gameStart := true. 
			owner timeDisplay start.].
		^ self stepOnTile: location.
		]
	ifTrue:[ self clearMines: location.].
]
