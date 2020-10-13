"
I am an MxN array of SameGameTiles, and implement most of the logic to play the SameGame, including adjacent tile selection and removal.
"
Class {
	#name : #SameGameBoard,
	#superclass : #AlignmentMorph,
	#instVars : [
		'protoTile',
		'rows',
		'columns',
		'palette',
		'selection',
		'selectionColor',
		'flashColor',
		'flash',
		'target',
		'actionSelector',
		'arguments'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'new-morph participation' }
SameGameBoard class >> includeInNewMorphMenu [

	^false
]

{ #category : #layout }
SameGameBoard >> acceptDroppingMorph: aMorph event: evt [
	"Allow the user to set the protoTile just by dropping it on this morph."

	self protoTile: aMorph.
	self removeAllMorphs.

]

{ #category : #accessing }
SameGameBoard >> actionSelector [

	^ actionSelector
]

{ #category : #accessing }
SameGameBoard >> actionSelector: aSymbolOrString [

	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^ actionSelector := nil].

	actionSelector := aSymbolOrString asSymbol.

]

{ #category : #private }
SameGameBoard >> adjustTiles [
	"add or remove new protoTile submorphs to fill out my new bounds"

	| newSubmorphs requiredSubmorphs count r c |
	columns := self width // protoTile width.
	rows := self height // protoTile height.
	requiredSubmorphs := rows * columns.
	newSubmorphs := OrderedCollection new.
	r := 0.
	c := 0.
	self submorphCount > requiredSubmorphs
		ifTrue: "resized smaller -- delete rows or columns"
			[count := 0.
			submorphs do:
				[:m | 
				count < requiredSubmorphs
					ifTrue:
						[m position: self position + (protoTile extent * (c @ r)).
						m arguments: (Array with: c @ r).
						newSubmorphs add: m]
					ifFalse: [m privateOwner: nil].
				count := count + 1.
				c := c + 1.
				c >= columns ifTrue: [c := 0. r := r + 1]]]
		ifFalse: "resized larger -- add rows or columns"
			[submorphs do:
				[:m |
				m position: self position + (self protoTile extent * (c @ r)).
				m arguments: (Array with: c @ r).
				newSubmorphs add: m.
				c := c + 1.
				c >= columns ifTrue: [c := 0. r := r + 1]].
			1 to: (requiredSubmorphs - self submorphCount) do:
				[:m |
				newSubmorphs add:
					(protoTile copy
						position: self position + (self protoTile extent * (c @ r));
						actionSelector: #tileClickedAt:newSelection:;
						arguments: (Array with: c @ r);
						target: self;
						privateOwner: self).
				c := c + 1.
				c >= columns ifTrue: [c := 0. r := r + 1]]].
	submorphs := newSubmorphs asArray.

]

{ #category : #undo }
SameGameBoard >> capturedState [
	"Note the state stored in the second element is an array of associations
	from submorph index to a shallowCopy of the morph, but only for those
	morphs that change.  Therefore the capturedState record *first* delivers
	all the morphs, and *then* computes the difference and stores this back.
	In the end, both undo and redo records follow this format."

	| prior state oldMorphs priorChanges newChanges |
	(prior := self valueOfProperty: #priorState) isNil 
		ifTrue: 
			[state := { 
						self shallowCopy.	"selection, etc."
						self submorphs collect: [:m | m shallowCopy].	"state of all tiles"
						owner scoreDisplay flash.	"score display"
						owner scoreDisplay value}.
			self setProperty: #priorState toValue: state.
			^state].
	oldMorphs := prior second.
	priorChanges := OrderedCollection new.
	newChanges := OrderedCollection new.
	1 to: oldMorphs size
		do: 
			[:i | 
			(oldMorphs at: i) color = (submorphs at: i) color 
				ifFalse: 
					[priorChanges addLast: i -> (oldMorphs at: i).
					newChanges addLast: i -> (submorphs at: i) shallowCopy]].
	self removeProperty: #priorState.
	prior at: 2 put: priorChanges asArray.	"Store back into undo state.2"
	^{ 
		self shallowCopy.	"selection, etc."
		newChanges asArray.	"state of tiles that changed"
		owner scoreDisplay flash.	"score display"
		owner scoreDisplay value}
]

{ #category : #actions }
SameGameBoard >> collapseColumn: col fromRow: row [

	| targetTile sourceTile |
	(targetTile := self tileAt: col@row) disabled ifTrue:
		[row - 1 to: 0 by: -1 do:
			[:r |
			(sourceTile := self tileAt: col@r) disabled ifFalse:
				[targetTile color: sourceTile color.
				targetTile disabled: false.
				sourceTile disabled: true.
				^ true]]].
	^ false

]

{ #category : #actions }
SameGameBoard >> collapseColumns: columnsToCollapse [

	| columnsToRemove |
	columnsToRemove := OrderedCollection new.
	columnsToCollapse do:
		[:c |
		rows - 1 to: 0 by: -1 do: [:r | self collapseColumn: c fromRow: r].
		(self tileAt: c@(rows-1)) disabled ifTrue: [columnsToRemove add: c]].
	self world displayWorld.
	columnsToRemove reverseDo: [:c | self removeColumn: c].

]

{ #category : #accessing }
SameGameBoard >> columns [

	^ columns
]

{ #category : #accessing }
SameGameBoard >> columns: newColumns [

	self extent: self protoTile extent * (newColumns @ rows)
]

{ #category : #accessing }
SameGameBoard >> columns: newColumns rows: newRows [

	self extent: self protoTile extent * (newColumns @ newRows)
]

{ #category : #initialization }
SameGameBoard >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 2
]

{ #category : #initialization }
SameGameBoard >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color gray
]

{ #category : #actions }
SameGameBoard >> deselectSelection [

	selection ifNotNil:
		[selection do: [:loc | (self tileAt: loc) setSwitchState: false; color: selectionColor].
		selection := nil.
		flash := false]
]

{ #category : #geometry }
SameGameBoard >> extent: aPoint [
	"constrain the extent to be a multiple of the protoTile size during resizing"
	super extent: (aPoint truncateTo: protoTile extent).
	self adjustTiles.
]

{ #category : #actions }
SameGameBoard >> findSelection [
	"find a possible selection and return it, or nil if no selection"

	| tile k testTile |
	0 to: rows-1 do:
		[:r |
		0 to: columns-1 do:
			[:c |
			tile := self tileAt: c@r.
			tile disabled  ifFalse:
				[k := tile color.
				c+1 < columns ifTrue:
					[testTile := self tileAt: (c+1)@r.
					(testTile disabled not and: [testTile color = k]) ifTrue: [^ tile]].
				r+1 < rows ifTrue:
					[testTile := self tileAt: c@(r+1).
					(testTile disabled not and: [testTile color = k]) ifTrue: [^ tile]]]]].
	 ^ nil
			
]

{ #category : #actions }
SameGameBoard >> hint [
	"find a possible selection and select it"

	| tile |
	self deselectSelection.
	tile := self findSelection.
	tile ifNotNil: [tile mouseDown: MouseButtonEvent new]
]

{ #category : #initialization }
SameGameBoard >> initialize [
	"initialize the state of the receiver"
	super initialize.
	target := nil.
	actionSelector := #selection.
	arguments := #().
	self layoutPolicy: nil.
	self hResizing: #rigid.
	self vResizing: #rigid.
	rows := self preferredRows.
	columns := self preferredColumns.

	palette := (Color wheel: self preferredTileTypes + 1) asOrderedCollection.
	flashColor := palette removeLast.
	flash := false.
	self extent: self protoTile extent * (columns @ rows).
	self resetBoard
]

{ #category : #preferences }
SameGameBoard >> preferredColumns [

	^ 20
]

{ #category : #preferences }
SameGameBoard >> preferredRows [

	^ 10
]

{ #category : #preferences }
SameGameBoard >> preferredTileTypes [

	^ 5
]

{ #category : #accessing }
SameGameBoard >> protoTile [

	protoTile ifNil: [protoTile := SameGameTile new].
	^ protoTile
]

{ #category : #accessing }
SameGameBoard >> protoTile: aTile [

	protoTile := aTile
]

{ #category : #actions }
SameGameBoard >> removeColumn: column [

	| sourceTile |
	column+1 to: columns-1 do:
		[:c |
		0 to: rows-1 do:
			[:r |
			sourceTile := self tileAt: c@r.
			(self tileAt: c-1@r)
				color: sourceTile color;
				disabled: sourceTile disabled]].
	0 to: rows-1 do:
		[:r | (self tileAt: columns-1@r) disabled: true]
]

{ #category : #actions }
SameGameBoard >> removeSelection [
	selection
		ifNil: [^ self].
	self
		rememberUndoableAction: [selection
				do: [:loc | (self tileAt: loc) setSwitchState: false; disabled: true].
			self collapseColumns: (selection
					collect: [:loc | loc x] as: Set) sorted.
			selection := nil.
			flash := false.
			(target notNil
					and: [actionSelector notNil])
				ifTrue: [target perform: actionSelector withArguments: arguments]]
		named: 'remove selection' translated
]

{ #category : #initialization }
SameGameBoard >> resetBoard [
	Collection initialize.  "randomize"
	selection := nil.
	self purgeAllCommands.
	self submorphsDo:
		[:m |
		m disabled: false.
		m setSwitchState: false.
		m color: palette atRandom].


]

{ #category : #accessing }
SameGameBoard >> rows [

	^ rows
]

{ #category : #accessing }
SameGameBoard >> rows: newRows [

	self extent: self protoTile extent * (columns @ newRows)
]

{ #category : #actions }
SameGameBoard >> selectTilesAdjacentTo: location [

	| al at |
	{-1@0. 0@ -1. 1@0. 0@1} do:
		[:offsetPoint |
		al := location + offsetPoint.
		((al x between: 0 and: columns - 1) and: [al y between: 0 and: rows - 1]) ifTrue:
			[at := self tileAt: al.
			(at color = selectionColor and: [at switchState not and: [at disabled not]]) ifTrue:
				[selection add: al.
				at setSwitchState: true.
				self selectTilesAdjacentTo: al]]]

]

{ #category : #accessing }
SameGameBoard >> selectionCount [

	^ selection isNil
		ifTrue: [0]
		ifFalse: [selection size]
]

{ #category : #'stepping and presenter' }
SameGameBoard >> step [

	| newColor |
	selection ifNotNil:
		[newColor := flash
			ifTrue: [selectionColor]
			ifFalse: [flashColor].
		selection do: [:loc | (self tileAt: loc) color: newColor].
		flash := flash not]

]

{ #category : #testing }
SameGameBoard >> stepTime [

	^ 500
]

{ #category : #accessing }
SameGameBoard >> target [

	^ target
]

{ #category : #accessing }
SameGameBoard >> target: anObject [

	target := anObject
]

{ #category : #accessing }
SameGameBoard >> tileAt: aPoint [

	^ submorphs at: (aPoint x + (aPoint y * columns) + 1)
]

{ #category : #actions }
SameGameBoard >> tileClickedAt: location newSelection: isNewSelection [ 
	| tile |
	isNewSelection 
		ifTrue: 
			[self deselectSelection.
			tile := self tileAt: location.
			selectionColor := tile color.
			selection := OrderedCollection with: location.
			self selectTilesAdjacentTo: location.
			selection size = 1 
				ifTrue: [self deselectSelection]
				ifFalse: 
					[(target notNil and: [actionSelector notNil]) 
						ifTrue: [target perform: actionSelector withArguments: arguments]]]
		ifFalse: [self removeSelection]
]

{ #category : #private }
SameGameBoard >> tilesRemaining [

	^ (submorphs reject: [:m | m disabled]) size

]

{ #category : #undo }
SameGameBoard >> undoFromCapturedState: st [ 

	self copyFrom: st first.
	st second do: [:assn | (submorphs at: assn key) copyFrom: assn value].
	selection ifNotNil:
		[selection do: [:loc | (self tileAt: loc) setSwitchState: false; color: selectionColor].
		selection := nil].
	owner scoreDisplay flash: st third.  "score display"
	owner scoreDisplay value: st fourth.
	self changed.
]
