"
A statement with other whole statements inside it.  If-Then.  Test.
"
Class {
	#name : #CompoundTileMorph,
	#superclass : #TileLikeMorph,
	#instVars : [
		'type',
		'testPart',
		'yesPart',
		'noPart',
		'justGrabbedFromViewer'
	],
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #'new-morph participation' }
CompoundTileMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #layout }
CompoundTileMorph >> acceptDroppingMorph: aMorph event: evt [
	"Forward the dropped morph to the appropriate part."

	(self targetPartFor: aMorph) acceptDroppingMorph: aMorph event: evt.

]

{ #category : #access }
CompoundTileMorph >> associatedPlayer [
	^ nil
]

{ #category : #'code generation' }
CompoundTileMorph >> codeString [
	^ String streamContents: [:aStream | self storeCodeOn: aStream indent: 1]

]

{ #category : #initialization }
CompoundTileMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
CompoundTileMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color orange muchLighter
]

{ #category : #'event handling' }
CompoundTileMorph >> handlesMouseDown: evt [
	^true
]

{ #category : #'event handling' }
CompoundTileMorph >> handlesMouseOver: evt [

	^ true

]

{ #category : #'event handling' }
CompoundTileMorph >> handlesMouseOverDragging: evt [

	^ true

]

{ #category : #initialization }
CompoundTileMorph >> initialize [
	"initialize the state of the receiver"

	| r stringMorph d h |
	super initialize.
	self layoutInset: 2.
	self listDirection: #topToBottom.
	self hResizing: #shrinkWrap; vResizing: #shrinkWrap; cellInset: (0 @ 1); minCellSize: (200@14).
	h := Preferences standardEToysFont height.
	"NB: hResizing gets reset to #spaceFill below, after the standalone structure is created"
	r := AlignmentMorph newRow color: color;
				 layoutInset: 0.
	r setProperty: #demandsBoolean toValue: true.
	r addMorphBack: (Morph new color: color;
			 extent: 2 @ 5).
	"spacer"
	stringMorph := StringMorph new contents: 'Test' translated.
	stringMorph name: 'Test'.
	stringMorph font: Preferences standardEToysFont.
	stringMorph on: #mouseEnterDragging send: #delegatingMouseEnter: to: self.
	r addMorphBack: stringMorph.
	r addMorphBack: (Morph new color: color;
			 extent: 5 @ 5).
	"spacer"
	r addMorphBack: (testPart := BooleanScriptEditor new borderWidth: 0;
					 layoutInset: 1).
	testPart color: Color transparent.
	testPart height: h; minHeight: h.
	testPart hResizing: #spaceFill.
	self addMorphBack: r.
	r := AlignmentMorph newRow color: color;
				 layoutInset: 0.
	r addMorphBack: (d := Morph new color: color;
			 extent: 30 @ stringMorph height)."stringMorph is refering to wrong one, but ok."
	d on: #mouseEnterDragging send: #delegatingMouseEnter: to: self.
	"spacer"
	stringMorph := StringMorph new contents: 'Yes' translated.
	stringMorph name: 'Yes'.
	stringMorph font: Preferences standardEToysFont.
	r addMorphBack: stringMorph.
	r addMorphBack: (Morph new color: color;
			 extent: 5 @ 5).
	"spacer"
	r addMorphBack: (yesPart := ScriptEditorMorph new borderWidth: 0;
					 layoutInset: 2).
	yesPart height: h; minHeight: h.
	yesPart hResizing: #spaceFill.
	yesPart color: Color transparent.
	self addMorphBack: r.
	r := AlignmentMorph newRow color: color;
				 layoutInset: 0.
	r addMorphBack: (d := Morph new color: color;
			 extent: 35 @ stringMorph height).
	d on: #mouseEnterDragging send: #delegatingMouseEnter: to: self.
	"spacer"
	stringMorph := StringMorph new contents: 'No' translated.
	stringMorph name: 'No'.
	stringMorph font: Preferences standardEToysFont.
	r addMorphBack: stringMorph.
	r addMorphBack: (Morph new color: color;
			 extent: 5 @ 5).
	"spacer"
	r addMorphBack: (noPart := ScriptEditorMorph new borderWidth: 0;
					 layoutInset: 2).
	noPart height: h; minHeight: h.
	noPart hResizing: #spaceFill.
	noPart color: Color transparent.
	self addMorphBack: r.
	self bounds: self fullBounds.
	self updateWordingToMatchVocabulary.
 	self hResizing:#spaceFill

]

{ #category : #miscellaneous }
CompoundTileMorph >> install [
	"Backstop for obscure cases"
]

{ #category : #testing }
CompoundTileMorph >> isCompoundTileMorph [
	^true
]

{ #category : #'e-toy support' }
CompoundTileMorph >> isTileEditor [
	"Yes I am"
	^true
]

{ #category : #testing }
CompoundTileMorph >> isTileScriptingElement [

	^ true

]

{ #category : #'event handling' }
CompoundTileMorph >> mouseDown: evt [ 
	"Pretend we picked up the tile and then put it down for a trial  
	positioning."
	"The essence of ScriptEditor mouseEnter:"
	| ed ss guyToTake |
"	self isPartsDonor ifTrue:[
		dup := self duplicate.
		evt hand attachMorph: dup.
		dup position: evt position.
		^self].
	submorphs isEmpty 			never true
		ifTrue: [^ self].
"
	(ed := self enclosingEditor) ifNil: [^evt hand grabMorph: self].

	guyToTake := self.
	owner class == TilePadMorph
		ifTrue: ["picking me out of another phrase"
			(ss := submorphs first) class == TilePadMorph
				ifTrue: [ss := ss submorphs first].
			guyToTake :=  ss veryDeepCopy].
	evt hand grabMorph: guyToTake.
	ed startStepping.
	ed mouseEnterDragging: evt.
	ed setProperty: #justPickedUpPhrase toValue: true.

]

{ #category : #'event handling' }
CompoundTileMorph >> mouseEnter: evt [
	"Resume drop-tracking in enclosing editor"
	self removeHighlightFeedback.
	self addCommandFeedback: evt.

]

{ #category : #'event handling' }
CompoundTileMorph >> mouseEnterDragging: evt [
	^ self.

]

{ #category : #'event handling' }
CompoundTileMorph >> mouseLeave: evt [
	"Resume drop-tracking in enclosing editor"
	| ed |
	self removeHighlightFeedback.
	(ed := self enclosingEditor) ifNotNil: [^ed mouseEnterDragging: evt].
]

{ #category : #'event handling' }
CompoundTileMorph >> mouseLeaveDragging: evt [
	"Test button state elsewhere if at all"
	
	self removeHighlightFeedback.
	self mouseLeave: evt
	
	

]

{ #category : #access }
CompoundTileMorph >> myMorph [
	^nil
]

{ #category : #mouse }
CompoundTileMorph >> prepareToUndoDropOf: aMorph [
	"needs to be here, as a no-op, owing to being hit obscurely on occasion"
]

{ #category : #miscellaneous }
CompoundTileMorph >> recompileScript [
	"Pertains only when the test is outside a script?!"

]

{ #category : #miscellaneous }
CompoundTileMorph >> resultType [
	"Answer the result type of the receiver"

	^ #Command
]

{ #category : #miscellaneous }
CompoundTileMorph >> rowOfRightTypeFor: aLayoutMorph forActor: anActor [
	aLayoutMorph demandsBoolean ifTrue:
		[^ self error: 'oops, cannot do that, please close this'].
	^ self
]

{ #category : #miscellaneous }
CompoundTileMorph >> scriptEdited [
	 "Pertains only when the test is outside a script?!"
]

{ #category : #access }
CompoundTileMorph >> scriptee [
	 "Pertains only when the test is outside a script?!"
	^ nil
]

{ #category : #'code generation' }
CompoundTileMorph >> storeCodeBlockFor: scriptPart on: aStream indent: tabCount [

	| rows r |
	rows := scriptPart tileRows.
	1 to: rows size do: [:i |
		tabCount timesRepeat: [aStream tab].
		r := rows at: i.
		r do: [:t | t storeCodeOn: aStream indent: tabCount].
		i < rows size ifTrue: [aStream nextPut: $.; cr]].

]

{ #category : #'code generation' }
CompoundTileMorph >> storeCodeOn: aStream indent: tabCount [

	aStream nextPut: $(.
	testPart storeCodeOn: aStream indent: 0.
	aStream nextPut: $); cr.

	tabCount + 1 timesRepeat: [aStream tab].
	aStream nextPutAll: 'ifTrue: ['; cr.
	self storeCodeBlockFor: yesPart on: aStream indent: tabCount + 2.
	aStream nextPut: $]; cr.
	tabCount + 1 timesRepeat: [aStream tab].
	aStream nextPutAll: 'ifFalse: ['; cr.
	self storeCodeBlockFor: noPart on: aStream indent: tabCount + 2.
	aStream nextPut: $].

]

{ #category : #mouse }
CompoundTileMorph >> targetPartFor: aMorph [
	"Return the row into which the given morph should be inserted."

	| centerY |
	centerY := aMorph fullBounds center y.
	(Array with: testPart with: yesPart with: noPart) do: [:m |
		(centerY <= m bounds bottom) ifTrue: [^ m]].
	^ noPart

]

{ #category : #miscellaneous }
CompoundTileMorph >> tile: tile isOnLineAfter: previousTile [
	"Return true if the given tile is not on the same line at the previous tile or if the previous tile is nil."

	| tileRow previousRow |
	previousTile ifNil: [^ true].
	tileRow := tile owner.
	[tileRow isMemberOf: AlignmentMorph]
		whileFalse: [tileRow := tileRow owner].  "find the owning row"
	previousRow := previousTile owner.
	[previousRow isMemberOf: AlignmentMorph]
		whileFalse: [previousRow := previousRow owner].  "find the owning row"
	^ tileRow ~~ previousRow

]

{ #category : #miscellaneous }
CompoundTileMorph >> tileRows [
	"Answer a list of tile rows, in this case just one though it's compound"

	^ Array with: (Array with: self veryDeepCopy)
]

{ #category : #miscellaneous }
CompoundTileMorph >> type [

	^ #compound

]

{ #category : #initialization }
CompoundTileMorph >> updateWordingToMatchVocabulary [
	| labels |
	labels := OrderedCollection new.
	self submorphs do: [:submorph |
		submorph submorphs do: [:subsubmorph |
			subsubmorph class == StringMorph ifTrue: [labels add: subsubmorph]]].
	labels do: [:label | label knownName ifNotNil: [ :nm | label acceptValue: nm translated ]]

]

{ #category : #'dropping\/grabbing' }
CompoundTileMorph >> wantsDroppedMorph: aMorph event: evt [
	"Removing this method entirely would be okay someday"

	^ false
"
	^ (aMorph isKindOf: TileMorph) or:
	   [(aMorph isKindOf: ScriptEditorMorph) or:
	   [(aMorph isKindOf: CompoundTileMorph) or:
	   [aMorph isKindOf: CommandTilesMorph]]]"

]
