"
Phrase Tile World: A single smalltalk expression in tiles.  Like (car forwardBy: number), having 3 tiles.  

type = command
rcvrType = #actor


In the Old Single tile world:  Holder for a phrase of tiles as it came from the viewer and while it is being dragged by the hand.

 
"
Class {
	#name : #PhraseTileMorph,
	#superclass : #TileLikeMorph,
	#instVars : [
		'resultType',
		'brightenedOnEnter',
		'userScriptSelector',
		'justGrabbedFromViewer',
		'vocabulary',
		'vocabularySymbol'
	],
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #scripting }
PhraseTileMorph class >> defaultNameStemForInstances [
	^ 'PhraseTile' translatedNoop
]

{ #category : #'backward compatibility' }
PhraseTileMorph class >> markViewerOrigination [
	"For bringing old content forward"

	| hadIt gotIt didntWantIt |
	hadIt := 0.
	gotIt := 0.
	didntWantIt := 0.
	self allSubInstancesDo:
		[:m | (m ownerThatIsA: CategoryViewer)
			ifNil:
				[m justGrabbedFromViewer: false.
				didntWantIt := didntWantIt + 1]
			ifNotNil:
				[(m justGrabbedFromViewerOrNil == true)
					ifTrue:
						[hadIt := hadIt + 1]
					ifFalse:
						[m justGrabbedFromViewer: true.
						gotIt := gotIt + 1]]].
	Transcript cr; show: 'updating phrase tiles -- already ok: '; show: hadIt; show: '  marked as in-viewer: '; show: gotIt; show: '  marked as not-in-viewer: '; show: didntWantIt.

	"PhraseTileMorph markViewerOrigination"
]

{ #category : #miscellaneous }
PhraseTileMorph >> actualObject [
	"Answer the player that's the object of my attention"

	^ self associatedPlayer
]

{ #category : #miscellaneous }
PhraseTileMorph >> addCustomMenuItems:  aMenu hand: aHand [
	"Add additional items to the halo manu"

	super addCustomMenuItems: aMenu hand: aHand.
	aMenu add: 'Sprout a new scriptor around this phrase' translated target: self action: #sproutNewScriptor
]

{ #category : #miscellaneous }
PhraseTileMorph >> associatedPlayer [
	"Answer the player that's the object of my attention"

	| pp |
	pp := self firstSubmorph.
	[pp isKindOf: PhraseTileMorph] whileTrue: [pp := pp firstSubmorph].
	^ pp firstSubmorph actualObject
]

{ #category : #miscellaneous }
PhraseTileMorph >> bePossessive [
	"No way for doubly possessive stuff to work at present, so we just catch and swallow this request here."

	self flag: #deferred
]

{ #category : #scripting }
PhraseTileMorph >> bringUpToDate [
	"Nothing here to do in the current architecture"
]

{ #category : #mouse }
PhraseTileMorph >> catchDivideByZero: aStream indent: tabCount [ 
	"See if I am have divide as my operator. If so, insert a test in the argument to divide."

	| exp |
	submorphs second type = #operator ifFalse: [^false].	"not me"
	exp := submorphs second operatorOrExpression.
	(#(/ // \\) includes: exp) ifFalse: [^false].	"not me"
	aStream space.
	aStream nextPutAll: '(self beNotZero: '.
	(submorphs third) storeCodeOn: aStream indent: tabCount.
	aStream nextPut: $).
	^true
]

{ #category : #'code generation' }
PhraseTileMorph >> codeString [
	^ String streamContents: [:aStream | self storeCodeOn: aStream indent: 1]

]

{ #category : #macpal }
PhraseTileMorph >> currentVocabulary [
	"Answer the current vocabulary"

	vocabulary "fix up old strutures"
		ifNotNil: 
			[vocabularySymbol := vocabulary vocabularyName.
			vocabulary := nil].

	^ vocabularySymbol
		ifNotNil:
			[Vocabulary vocabularyNamed: vocabularySymbol]
		ifNil:
			[super currentVocabulary]

]

{ #category : #miscellaneous }
PhraseTileMorph >> dismissViaHalo [
	"The user has clicked in the delete halo-handle.."

	| ed |
	ed := self topEditor.
	super dismissViaHalo.
	ed ifNotNil: [ed scriptEdited]
]

{ #category : #kedama }
PhraseTileMorph >> duplicate [
	"Make and return a duplicate of the receiver."

	| newMorph |
	newMorph := super duplicate.
	(self ownerThatIsA: Viewer) ifNotNil:
		[:aViewer | newMorph replacePlayerInReadoutWith: aViewer scriptedPlayer].

	^ newMorph
]

{ #category : #kedama }
PhraseTileMorph >> firstMorphBearingKedamaPlayer [

	self allMorphsWithPlayersDo: [:e :p | (p isKindOf: KedamaExamplerPlayer) ifTrue: [^ e]].
	^ nil.

]

{ #category : #'event handling' }
PhraseTileMorph >> handlesMouseDown: evt [
	^true
]

{ #category : #'event handling' }
PhraseTileMorph >> handlesMouseOver: evt [

	^ true

]

{ #category : #initialization }
PhraseTileMorph >> initialize [
	"Initialize a nascent instance"

	super initialize.
	resultType := #unknown.
	self wrapCentering: #center; cellPositioning: #leftCenter.
	self hResizing: #shrinkWrap.
	self vResizing: #spaceFill.
	self borderWidth: 0.
	self layoutInset: 0.
	self extent: 5@5.  "will grow to fit"
	self minCellSize: 0 @ TileMorph defaultH.
	self minHeight: TileMorph defaultH.
	justGrabbedFromViewer := true.  "All new PhraseTileMorphs that go through the initialize process (rather than being copied) are placed in viewers; the clones dragged out from them will thus have this set the right way; the drop code resets this to false"

]

{ #category : #queries }
PhraseTileMorph >> isBooleanType [
	"Answer whether the receiver has a boolean type"

	^ self resultType = #Boolean
]

{ #category : #'e-toy support' }
PhraseTileMorph >> isCandidateForAutomaticViewing [
	^ false
]

{ #category : #queries }
PhraseTileMorph >> isCommand [
	"Answer whether the receiver is a true line of phrase-command. If not,  
	it is a fragment that will not be able to serve as a line of script on its  
	own"
	| rcvrTile pad |
	submorphs isEmpty
		ifTrue: [^ false].
	pad := submorphs first.
	(pad isKindOf: TilePadMorph)
		ifTrue: [(submorphs second isKindOf: AssignmentTileMorph)
				ifTrue: [^ true].
			(((rcvrTile := pad submorphs first) isKindOf: TileMorph)
					and: [rcvrTile isPossessive])
				ifTrue: [^ false]].
	^ true
]

{ #category : #'e-toy support' }
PhraseTileMorph >> isPhraseTileMorph [
	^true
]

{ #category : #miscellaneous }
PhraseTileMorph >> isPlayer: aPlayer ofReferencingTile: tile [
	"Answer whether a given player is the object referred to by the given tile, or a sibling of that object."

	^ aPlayer class == self actualObject class
]

{ #category : #queries }
PhraseTileMorph >> isPossessive [
	^ false
]

{ #category : #scripting }
PhraseTileMorph >> isTileScriptingElement [
	^ true
]

{ #category : #'dropping\/grabbing' }
PhraseTileMorph >> justDroppedInto: newOwner event: evt [
	"Phrase tiles only auto-expand if they originate from viewers.  Any phrase tile, once dropped, loses its auto-phrase-expansion thing"

	(justGrabbedFromViewer = true and: [newOwner isKindOf: Viewer]) ifTrue: [
		self formerPosition ifNotNil: [
			^ self vanishAfterSlidingTo: self formerPosition event: evt
		].
	].
	justGrabbedFromViewer := false.
	super justDroppedInto: newOwner event: evt.

	((owner isKindOf: TilePadMorph) and: [submorphs size = 3] and: [#(bearingTo: distanceToPlayer:) includes:  submorphs second operatorOrExpression])
		ifTrue:
			[owner wrapInFunction.
			owner owner operator: #grouped wording: '()'  helpString: 'parenthesized' translated pad: owner.
			owner scriptEdited]
]

{ #category : #miscellaneous }
PhraseTileMorph >> justGrabbedFromViewer [
	"Answer whether the receiver originated in a Viewer.  Only tiles that originated in a viewer will ever do that infernal sprouting of a new script around them.  The nil branch is only for backward compatibility."

	^ justGrabbedFromViewer ifNil: [justGrabbedFromViewer := true]
]

{ #category : #miscellaneous }
PhraseTileMorph >> justGrabbedFromViewer: aBoolean [
	"Set the receiver's justGrabbedFromViewer instance variable"

	justGrabbedFromViewer := aBoolean
]

{ #category : #miscellaneous }
PhraseTileMorph >> justGrabbedFromViewerOrNil [
	"Answer the value of the receiver's justGrabbedFromViewer slot.  Needed only for conversion methods"

	^ justGrabbedFromViewer
]

{ #category : #miscellaneous }
PhraseTileMorph >> lastTile [
	"The tile that might get an extension arrow"

	^ self lastSubmorph lastTile
]

{ #category : #mouse }
PhraseTileMorph >> morphToDropInPasteUp: aPasteUp [
	"Answer the morph to drop in aPasteUp, given that the receiver is the putative droppee"

	| actualObject itsSelector aScriptor pos aWatcher op |

	((actualObject := self actualObject) isNil or: [actualObject isPlayerLike not] or:  [actualObject costume isInWorld not]) ifTrue:
		[^ ScriptingTileHolder around: self].

	self isCommand ifFalse:  "Can't expand to a scriptor, but maybe launch a watcher..."
		[^ (Preferences dropProducesWatcher and: [(#(unknown command) includes: self resultType) not] and:
			[(op := self operatorTile operatorOrExpression) notNil] and: [op numArgs = 0] and: [(Vocabulary gettersForbiddenFromWatchers includes: op) not])
			ifTrue:
				[aWatcher := WatcherWrapper new fancyForPlayer: self associatedPlayer getter: op.
				aWatcher position: self position]
			ifFalse:
				[ScriptingTileHolder around: self]].

	(aPasteUp automaticPhraseExpansion and: [self justGrabbedFromViewer])  ifFalse: [^ ScriptingTileHolder around: self].
	actualObject assureUniClass.
	itsSelector := self userScriptSelector.
	pos := self position.
	aScriptor := itsSelector isEmptyOrNil
		ifFalse:
			[actualObject scriptEditorFor: itsSelector]
		ifTrue:
			["It's a system-defined selector; construct an anonymous scriptor around it"
			actualObject newScriptorAround: self].
	aScriptor ifNil:[^ ScriptingTileHolder around: self].
	(self hasOwner: aScriptor) ifTrue:[
		aScriptor fullBounds. "force layout"
		aScriptor position: pos - self position.
	] ifFalse:[
		aScriptor position: self position.
	].
	(aScriptor valueOfProperty: #needsLayoutFixed) ifNotNil: [
		aScriptor removeProperty: #needsLayoutFixed.
		aScriptor fixLayout
	].

	^ aScriptor
]

{ #category : #kedama }
PhraseTileMorph >> morphsBearingPlayers [

	| c |
	c := OrderedCollection new.
	self allMorphsWithPlayersDo: [:e :p | c add: e].
	^ c asArray.

]

{ #category : #mouse }
PhraseTileMorph >> mouseDown: evt [ 
	"Handle a mouse-down on the receiver"

	| ed guyToTake dup enclosingPhrase |
	self removeHighlightFeedback.
	self isPartsDonor ifTrue:
		[dup := self duplicate.
		dup eventHandler: nil.   "Remove viewer-related evt mouseover feedback"
		evt hand attachMorph: dup.
		dup position: evt position + (-25@8).
		"So that the drag vs. click logic works"
		dup formerPosition: evt position.
		^ self].
	submorphs isEmpty
		ifTrue: [^ self].

	guyToTake := self.
	[(enclosingPhrase := guyToTake ownerThatIsA: PhraseTileMorph) notNil] whileTrue:
		[guyToTake := enclosingPhrase].  "This logic always grabs the outermost phrase, for now anyway"
	
	"the below had comment: 'picking me out of another phrase'"
	"owner class == TilePadMorph
		ifTrue:
			[(ss := submorphs first) class == TilePadMorph
				ifTrue: [ss := ss submorphs first].
			guyToTake :=  ss veryDeepCopy]."

	(ed := self enclosingEditor) ifNil: [^ evt hand grabMorph: guyToTake].
	evt hand grabMorph: guyToTake.
	ed startStepping.
	ed mouseEnterDragging: evt.
	ed setProperty: #justPickedUpPhrase toValue: true.

]

{ #category : #'event handling' }
PhraseTileMorph >> mouseEnter: evt [

	self removeHighlightFeedback.
	self addCommandFeedback: evt.

]

{ #category : #'event handling' }
PhraseTileMorph >> mouseLeave: evt [
	"Resume drop-tracking in enclosing editor"
	| ed |
	self removeHighlightFeedback.
	(ed := self enclosingTestTile) ifNotNil: [ed mouseEnter: evt].
]

{ #category : #miscellaneous }
PhraseTileMorph >> operatorTile [
	"Answer the submorph which comprises the operator tile of the receiver.  Ouch!"

	^ submorphs second
]

{ #category : #kedama }
PhraseTileMorph >> replacePlayerInReadoutWith: aPlayer [ 

	| tile |
	tile := self firstMorphBearingKedamaPlayer.
	tile ifNil: [^ self].
	(tile isMemberOf: TileMorph) ifFalse: [^ self].
	tile type = #objRef ifFalse: [^ self].
	tile referToSimilarObject: aPlayer.

	self allMorphsDo: [:e |
		((e isMemberOf: UpdatingStringMorph) or: [e isMemberOf: UpdatingRectangleMorph]) ifTrue: [
			e target isPlayerLike ifTrue: [
				e target: aPlayer
			].
		].
		(e isMemberOf: KedamaPatchTile) ifTrue: [
			e usePatch: (aPlayer costume renderedMorph kedamaWorld defaultPatch player).
		].
	].
]

{ #category : #miscellaneous }
PhraseTileMorph >> resultType [
	"Answer the result type of the receiver"

	^ resultType
]

{ #category : #all }
PhraseTileMorph >> rowOfRightTypeFor: aLayoutMorph forActor: aPlayer [
	"Answer a phrase of the right type for the putative container"

	| aTemporaryViewer aPhrase |
	aLayoutMorph demandsBoolean ifTrue:
		[self isBooleanType ifTrue: [^ self].
		aTemporaryViewer := CategoryViewer new invisiblySetPlayer: aPlayer.
		aPhrase := aTemporaryViewer booleanPhraseFromPhrase: self.
		aPhrase justGrabbedFromViewer: false.
		^ aPhrase].
	^ self
]

{ #category : #initialization }
PhraseTileMorph >> setAngleToOperator: opSymbol type: opType rcvrType: rcvrType argType: argType [
	"Set the operator, type, receiver type, and argument type for the phrase"

	| aTileMorph |

	resultType := opType.
	opType ifNotNil: [self color: (ScriptingSystem colorForType: opType)].
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	aTileMorph := TileCommandWithArgumentMorph newKedamaAngleToTile.
	aTileMorph adoptVocabulary: self currentVocabulary.
	self addMorphBack: ((aTileMorph setOperator: opSymbol asString) typeColor: color).

]

{ #category : #'customevents-scripting' }
PhraseTileMorph >> setAsActionInButtonProperties: buttonProperties [

	userScriptSelector ifNil: [
		buttonProperties
			target: self associatedPlayer;
			actionSelector: #evaluateUnloggedForSelf:;
			arguments: {self codeString}.
		^true
	].
	buttonProperties
		target: self objectViewed player;
		actionSelector: #triggerScript: ;
		arguments: {userScriptSelector}.
	^true

"==== or 

	buttonProperties
		target: (self morphToDropInPasteUp: nil);
		actionSelector: #tryMe;
		arguments: #().
	^true


	==="
]

{ #category : #initialization }
PhraseTileMorph >> setAssignmentRoot: opSymbol type: opType rcvrType: rcvrType argType: argType [
	resultType := opType.
	self color: (ScriptingSystem colorForType: opType).
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	self addMorphBack: ((AssignmentTileMorph new setRoot: opSymbol asString dataType: argType) typeColor: color).
	self addMorphBack: (TilePadMorph new setType: argType)

]

{ #category : #initialization }
PhraseTileMorph >> setAssignmentRoot: opSymbol type: opType rcvrType: rcvrType argType: argType vocabulary: aVocabulary [
	"Add submorphs to make me constitute a setter of the given symbol"

	| anAssignmentTile |
	resultType := opType.
	self color: (ScriptingSystem colorForType: opType).
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	anAssignmentTile := AssignmentTileMorph new rawVocabulary: aVocabulary.
	self addMorphBack: (anAssignmentTile typeColor: color).
	anAssignmentTile setRoot: opSymbol asString dataType: argType.
	anAssignmentTile setAssignmentSuffix: #':'.
	self addMorphBack: (TilePadMorph new setType: argType)
]

{ #category : #initialization }
PhraseTileMorph >> setBounceOnColorOperator: opSymbol type: opType rcvrType: rcvrType argType: argType [
	"Set the operator, type, receiver type, and argument type for the phrase"

	| aTileMorph |

	resultType := opType.
	opType ifNotNil: [self color: (ScriptingSystem colorForType: opType)].
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	aTileMorph := KedamaBounceOnColorTile new adoptVocabulary: self currentVocabulary.
	self addMorphBack: ((aTileMorph setOperator: opSymbol asString) typeColor: color).
	opSymbol numArgs = 1 ifTrue:
		[self addMorphBack: (TilePadMorph new setType: (argType ifNil: [#Object]))]
]

{ #category : #initialization }
PhraseTileMorph >> setBounceOnOperator: opSymbol type: opType rcvrType: rcvrType argType: argType [
	"Set the operator, type, receiver type, and argument type for the phrase"

	| aTileMorph |

	resultType := opType.
	opType ifNotNil: [self color: (ScriptingSystem colorForType: opType)].
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	aTileMorph := TileCommandWithArgumentMorph newKedamaBounceOnTile.
	aTileMorph adoptVocabulary: self currentVocabulary.
	self addMorphBack: ((aTileMorph setOperator: opSymbol asString) typeColor: color).

]

{ #category : #initialization }
PhraseTileMorph >> setColorComponentRoot: opSymbol componentName: componentName type: opType rcvrType: rcvrType argType: argType vocabulary: aVocabulary [
	"Add submorphs to make me constitute a setter of the given symbol"

	| anAssignmentTile |
	resultType := opType.
	self color: (ScriptingSystem colorForType: opType).
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	anAssignmentTile := KedamaSetColorComponentTile new rawVocabulary: aVocabulary.
	anAssignmentTile componentName: componentName.
	self addMorphBack: (anAssignmentTile typeColor: color).
	anAssignmentTile setRoot: opSymbol asString dataType: argType.
	self addMorphBack: (TilePadMorph new setType: argType)
]

{ #category : #initialization }
PhraseTileMorph >> setDistanceToOperator: opSymbol type: opType rcvrType: rcvrType argType: argType [
	"Set the operator, type, receiver type, and argument type for the phrase"

	| aTileMorph |

	resultType := opType.
	opType ifNotNil: [self color: (ScriptingSystem colorForType: opType)].
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	aTileMorph := TileCommandWithArgumentMorph newKedamaDistanceToTile.
	aTileMorph adoptVocabulary: self currentVocabulary.
	self addMorphBack: ((aTileMorph setOperator: opSymbol asString) typeColor: color).

]

{ #category : #initialization }
PhraseTileMorph >> setGetColorComponentOperator: opSymbol componentName: componentName type: opType rcvrType: rcvrType argType: argType [
	"Set the operator, type, receiver type, and argument type for the phrase"

	| aTileMorph |

	resultType := opType.
	opType ifNotNil: [self color: (ScriptingSystem colorForType: opType)].
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	aTileMorph := KedamaGetColorComponentTile new adoptVocabulary: self currentVocabulary.
	aTileMorph componentName: componentName.
	self addMorphBack: ((aTileMorph setOperator: opSymbol asString) typeColor: color).

]

{ #category : #initialization }
PhraseTileMorph >> setGetPixelOperator: opSymbol type: opType rcvrType: rcvrType argType: argType [
	"Set the operator, type, receiver type, and argument type for the phrase"

	| aTileMorph |

	resultType := opType.
	opType ifNotNil: [self color: (ScriptingSystem colorForType: opType)].
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	aTileMorph := TileCommandWithArgumentMorph newKedamaGetPatchValueTile.
	aTileMorph adoptVocabulary: self currentVocabulary.
	self addMorphBack: ((aTileMorph setOperator: opSymbol asString) typeColor: color).

]

{ #category : #initialization }
PhraseTileMorph >> setOperator: opSymbol type: opType rcvrType: rcvrType [
	self setOperator: opSymbol type: opType rcvrType: rcvrType argType: nil.

]

{ #category : #initialization }
PhraseTileMorph >> setOperator: opSymbol type: opType rcvrType: rcvrType argType: argType [
	"Set the operator, type, receiver type, and argument type for the phrase"

	| aTileMorph |

	resultType := opType.
	opType ifNotNil: [self color: (ScriptingSystem colorForType: opType)].
	self removeAllMorphs.
	self addMorph: (TilePadMorph new
		setType: rcvrType;
		changeTableLayout;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		yourself).
	aTileMorph := TileMorph new adoptVocabulary: self currentVocabulary.
	self addMorphBack: ((aTileMorph setOperator: opSymbol asString) typeColor: color).
	opSymbol numArgs = 1 ifTrue:
		[self addMorphBack: (TilePadMorph new setType: (argType ifNil: [#Object]))]
]

{ #category : #initialization }
PhraseTileMorph >> setPixelValueRoot: opSymbol type: opType rcvrType: rcvrType argType: argType vocabulary: aVocabulary [
	"Add submorphs to make me constitute a setter of the given symbol"

	| anAssignmentTile |
	resultType := opType.
	self color: (ScriptingSystem colorForType: opType).
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	anAssignmentTile := KedamaSetPixelValueTile new rawVocabulary: aVocabulary.
	self addMorphBack: (anAssignmentTile typeColor: color).
	anAssignmentTile setRoot: opSymbol asString dataType: argType.
	self addMorphBack: (TilePadMorph new setType: argType)
]

{ #category : #initialization }
PhraseTileMorph >> setSlotRefOperator: opSymbol type: opType [
	"Set the given symbol as the receiver's slot-reference operator, adding tiles to the receiver appropriately"

	resultType := opType.
	self color: (ScriptingSystem colorForType: opType).
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: #Player).
	self addMorphBack: ((TileMorph new setSlotRefOperator: opSymbol asString) typeColor: color)

]

{ #category : #initialization }
PhraseTileMorph >> setTurtleAtOperator: opSymbol type: opType rcvrType: rcvrType argType: argType [
	"Set the operator, type, receiver type, and argument type for the phrase"

	| aTileMorph |

	resultType := opType.
	opType ifNotNil: [self color: (ScriptingSystem colorForType: opType)].
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	aTileMorph := KedamaTurtleAtTile new adoptVocabulary: self currentVocabulary.
	self addMorphBack: ((aTileMorph setOperator: opSymbol asString) typeColor: color).
	opSymbol numArgs = 1 ifTrue:
		[self addMorphBack: (TilePadMorph new setType: (argType ifNil: [#Object]))]
]

{ #category : #initialization }
PhraseTileMorph >> setTurtleOfOperator: opSymbol type: opType rcvrType: rcvrType argType: argType [
	"Set the operator, type, receiver type, and argument type for the phrase"

	| aTileMorph |

	resultType := opType.
	opType ifNotNil: [self color: (ScriptingSystem colorForType: opType)].
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	aTileMorph := TileCommandWithArgumentMorph newKedamaGetTurtleOfTile.
	aTileMorph adoptVocabulary: self currentVocabulary.
	self addMorphBack: ((aTileMorph setOperator: opSymbol asString) typeColor: color).

]

{ #category : #initialization }
PhraseTileMorph >> setUpHillOperator: opSymbol type: opType rcvrType: rcvrType argType: argType [
	"Set the operator, type, receiver type, and argument type for the phrase"

	| aTileMorph |

	resultType := opType.
	opType ifNotNil: [self color: (ScriptingSystem colorForType: opType)].
	self removeAllMorphs.
	self addMorph: (TilePadMorph new setType: rcvrType).
	aTileMorph := TileCommandWithArgumentMorph newKedamaGetUpHillTile.
	aTileMorph adoptVocabulary: self currentVocabulary.
	self addMorphBack: ((aTileMorph setOperator: opSymbol asString) typeColor: color).

]

{ #category : #miscellaneous }
PhraseTileMorph >> sproutNewScriptor [
	"The receiver, operating as a naked phrase tile, wishes to get iself placed in a nascent script"

	| newScriptor |

	self actualObject assureUniClass.
	newScriptor := self actualObject newScriptorAround:
		((self ownerThatIsA: Viewer orA: ScriptEditorMorph)
			ifNotNil:
				[self veryDeepCopy]
			ifNil:
				[self]).
	self currentHand attachMorph: newScriptor
]

{ #category : #'code generation' }
PhraseTileMorph >> storeCodeOn: aStream indent: tabCount [ 
	"Add in some smarts for division by zero."

	aStream nextPut: $(.
	submorphs first storeCodeOn: aStream indent: tabCount.
	aStream space.
	submorphs second storeCodeOn: aStream indent: tabCount.
	submorphs size > 2 
		ifTrue: 
			[(self catchDivideByZero: aStream indent: tabCount) 
				ifFalse: 
					[aStream space.
					(submorphs third) storeCodeOn: aStream indent: tabCount]].
	aStream nextPut: $)
]

{ #category : #miscellaneous }
PhraseTileMorph >> tileRows [
	"Answer a list of tile rows -- in this case exactly one row -- representing the receiver.  The fullCopy is deeply problematical here in the presence of the formerOwner property, so it the latter is temporarily set aside"

	^ Array with: (Array with: self veryDeepCopy)
]

{ #category : #miscellaneous }
PhraseTileMorph >> try [
	"Evaluate the given phrase once"

	| aPlayer |
	(userScriptSelector notNil and: [userScriptSelector numArgs = 0])
		ifTrue:
			[aPlayer := self objectViewed player.
			aPlayer triggerScript: userScriptSelector]
		ifFalse:
			[Compiler evaluate:
				self codeString
				for: self associatedPlayer]
]

{ #category : #miscellaneous }
PhraseTileMorph >> userScriptSelector [
	^ userScriptSelector
]

{ #category : #miscellaneous }
PhraseTileMorph >> userScriptSelector: s [
	userScriptSelector := s
]

{ #category : #initialization }
PhraseTileMorph >> vocabulary: aVocab [ 
	"Set the vocabulary"

	vocabularySymbol := (aVocab isKindOf: Symbol) 
				ifTrue: [aVocab]
				ifFalse: [aVocab vocabularyName]
]
