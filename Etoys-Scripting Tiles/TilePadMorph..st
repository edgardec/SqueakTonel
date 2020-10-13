"
The drop target for colored tiles.  Landing pad.  In the hierarchy, but not a tile itself.  Would like to eliminate this, but an attempt at it failed. 
"
Class {
	#name : #TilePadMorph,
	#superclass : #Morph,
	#instVars : [
		'type'
	],
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #color }
TilePadMorph class >> colorFudge [
	^ 0.4
]

{ #category : #layout }
TilePadMorph >> acceptDroppingMorph: aMorph event: evt [ 
	"Accept the given morph within my bowels"

	| editor wasPossessive morphToUse |
	wasPossessive := submorphs notEmpty and: [submorphs first isPossessive].
	morphToUse := self morphToDropFrom: aMorph.
	self prepareToUndoDropOf: morphToUse.
	self removeAllMorphs.
	morphToUse position: self position.
	self addMorph: morphToUse.
	wasPossessive ifTrue: [morphToUse bePossessive].
	((owner isKindOf: PhraseTileMorph) and: [self == owner submorphs last])
	"Note: the non-phrase-tile-owner case is in the Times pane of a times/repeat complex"
		ifTrue:
			[self lastTileMorph addSuffixArrow].

	self firstSubmorph hideWillingnessToAcceptDropFeedback.
	(editor := self topEditor) ifNotNil: [editor scriptEdited]
]

{ #category : #miscellaneous }
TilePadMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add custom menu items to the menu"

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	(self ownerThatIsA: ScriptEditorMorph) ifNotNil:
		[aCustomMenu add: 'restore default tile' translated action: #restoreDefaultTile.
		type = #Number ifTrue:
			[aCustomMenu add: 'place in a function' translated action: #wrapInFunction]]
]

{ #category : #miscellaneous }
TilePadMorph >> basicWidth [
	^ 18

]

{ #category : #mouse }
TilePadMorph >> canAccept: aMorph [
	"Answer whether this pad can accept the given morph"

	| itsType myType |
	((aMorph isKindOf: PhraseTileMorph) or: [aMorph isKindOf: TileMorph orOf: WatcherWrapper]) 		ifTrue:
			[^ ((itsType := aMorph resultType capitalized) = (myType := self type capitalized)) or:
				[(myType = #Graphic) and: [itsType = #Player]]].
	^ false
]

{ #category : #'event handling' }
TilePadMorph >> handlesMouseOverDragging: evt [
	^true
]

{ #category : #miscellaneous }
TilePadMorph >> isColorConstant: aParseNode [
	"Is this a Color constant, of the form (MessageNode (VariableNode Color->Color) (SelectorNode #r:g:b:) (LiteralNode LiteralNode LiteralNode))"

	| rec |
	((rec := aParseNode receiver) isKindOf: VariableNode) ifFalse: [^ false].
	rec key isVariableBinding ifFalse: [^ false].
	rec key value == Color ifFalse: [^ false].
	aParseNode selector key == #r:g:b: ifFalse: [^ false].
	aParseNode arguments  size = 3 ifFalse: [^ false].
	^ true

]

{ #category : #miscellaneous }
TilePadMorph >> isOutsideRef: aParseNode [
	"Is this a reference to an outside Player, of the form (self class refUnscriptedPlayer1)?
(MessageNode (VariableNode 'self') (SelectorNode 'class')) (SelectorNode 'refUnscriptedPlayer1')"

	| rec |
	((rec := aParseNode receiver) isKindOf: MessageNode) ifFalse: [^ false].
	rec receiver isSelfPseudoVariable ifFalse: [^ false].
	rec selector key == #class ifFalse: [^ false].
	aParseNode selector key numArgs = 0 ifFalse: [^ false].
	(aParseNode selector key beginsWith: 'ref') ifFalse: [^ false].
	^ true

]

{ #category : #miscellaneous }
TilePadMorph >> isTilePadMorph [
	^true
]

{ #category : #miscellaneous }
TilePadMorph >> lastTile [
	"The tile that might get an extension arrow"

	^ self lastSubmorph lastTile
]

{ #category : #miscellaneous }
TilePadMorph >> morphToDropFrom: aMorph [ 
	"Given a morph being carried by the hand, which the hand is about to drop, answer the actual morph to be deposited.  Normally this would be just the morph itself, but several unusual cases arise, which this method is designed to service."

	| vwr |
	(aMorph isKindOf: WatcherWrapper)
		ifTrue: [^ aMorph getterTilesForDrop].
	^ ((self type capitalized = #Graphic)  "Special-case requested by Alan 4/30/05"
		and: [(aMorph isKindOf: TileMorph) and: [aMorph resultType = #Player]])
			ifFalse:
				[aMorph]
			ifTrue:
				[vwr := CategoryViewer new initializeFor: aMorph associatedPlayer categoryChoice: #basic.
				vwr getterTilesFor: #graphic asGetterSelector type: #Graphic]
]

{ #category : #'event handling' }
TilePadMorph >> mouseEnterDragging: evt [
	"The mouse entered the receiver's interior dragging something."

	evt hand hasSubmorphs ifFalse: [^ self].
	(self wantsDroppedMorph: evt hand firstSubmorph event: evt) ifTrue:
		[submorphs ifNotEmpty:
			[self firstSubmorph showWillingnessToAcceptDropFeedback]]
]

{ #category : #'event handling' }
TilePadMorph >> mouseLeaveDragging: evt [
	"The mouse just left the interior of the receiver whilst dragging something.  If appropriate, take down beckoning feedback; if Ithe mouse is still within the interior of a surrounding pad, call its mouseEnterDragging: method."

	| aPad |
	evt hand hasSubmorphs ifFalse: [^ self].
	(self wantsDroppedMorph: evt hand firstSubmorph event: evt) ifTrue:
		[submorphs ifNotEmpty: [self firstSubmorph hideWillingnessToAcceptDropFeedback].
		aPad := self ownerSatisfying:
			[:m | (m isKindOf: TilePadMorph) and: [m bounds containsPoint: evt cursorPoint] and: [m wantsDroppedMorph: evt hand firstSubmorph event: evt]].
		aPad ifNotNil: [aPad mouseEnterDragging: evt]]
]

{ #category : #mouse }
TilePadMorph >> prepareToUndoDropOf: aMorph [ 
	| m |
	m := self owner.
	[m isNil] whileFalse: 
			[(m isKindOf: ScriptEditorMorph) ifTrue: [^m prepareToUndoDropOf: aMorph].
			m := m owner]
]

{ #category : #printing }
TilePadMorph >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' type='; print: type
]

{ #category : #miscellaneous }
TilePadMorph >> restoreDefaultTile [
	"Restore the receiver to showing only its default literal tile"

	self setToBearDefaultLiteral.
	(self ownerThatIsA: ScriptEditorMorph) ifNotNil:
		[:aScriptEditor | aScriptEditor install]
]

{ #category : #miscellaneous }
TilePadMorph >> setToBearDefaultLiteral [
	"Set the receiver so that it contains only a tile reflecting the default literal value for a pad of this type"

	| wasPossessive sm toAdd |
	wasPossessive := (type = #Player) and: [(sm := submorphs at: 1 ifAbsent: [nil]) notNil] and: [sm isPossessive].
	self removeAllMorphs.
	toAdd := (Vocabulary vocabularyForType: type) defaultArgumentTile.
	wasPossessive ifTrue:
		[toAdd bePossessive].
	self addMorphBack: toAdd
]

{ #category : #miscellaneous }
TilePadMorph >> setType: aSymbol [

	type := aSymbol.
	self color: (ScriptingSystem colorForType: type).
	self extent: (self basicWidth @ TileMorph defaultH)

]

{ #category : #'code generation' }
TilePadMorph >> storeCodeOn: aStream indent: tabCount [

	submorphs do: [:m | m storeCodeOn: aStream indent: tabCount].

]

{ #category : #miscellaneous }
TilePadMorph >> type [
	^ type
]

{ #category : #'dropping\/grabbing' }
TilePadMorph >> wantsDroppedMorph: aMorph event: evt [

	^ self canAccept: aMorph

]
