"
Optionally associated with a PasteUpMorph, provides a local scope for the running of scripts.

Once more valuable, may be again, but at present occupies primarily a historical niche.

Maintains a playerList cache.

Holds, optionally three 'standard items' -- standardPlayer standardPlayfield standardPalette -- originally providing idiomatic support of ongoing squeak-team internal work, but now extended to more general applicability.

   
"
Class {
	#name : #EtoysPresenter,
	#superclass : #Presenter,
	#instVars : [
		'associatedMorph',
		'standardPlayer',
		'standardPlayfield',
		'standardPalette',
		'playerList'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #'class initialization' }
EtoysPresenter class >> initialize [
	Presenter defaultPresenterClass: self.
	PasteUpMorph allInstancesDo:[:p| p dumpPresenter].
	Vocabulary initializeStandardVocabularies.
]

{ #category : #'class initialization' }
EtoysPresenter class >> unload [
	Presenter defaultPresenterClass: nil.
	PasteUpMorph allInstancesDo:[:p| p dumpPresenter].

]

{ #category : #scripting }
EtoysPresenter >> adaptedToWorld: aWorld [
	"If I refer to a world or a hand, return the corresponding items in the new world."
	^aWorld presenter
]

{ #category : #'button creation' }
EtoysPresenter >> addTrashCan [
	| aPosition aCan |
	(aCan := associatedMorph findA: TrashCanMorph) ifNotNil: [^ aCan].
	aCan := TrashCanMorph newSticky.
	aPosition := associatedMorph positionNear: (associatedMorph bottomRight - aCan extent) forExtent: aCan extent adjustmentSuggestion:  (-10 @ 0).
	aCan position: aPosition.
	associatedMorph addMorph: aCan.
	aCan startStepping.
	aCan setToAdhereToEdge: #bottomRight.
	^ aCan

]

{ #category : #playerList }
EtoysPresenter >> allCurrentlyTickingScriptInstantiations [
	"Answer a list of ScriptInstantiation objects representing all the scripts within the scope of the receiver which are currently ticking."

	^ Array streamContents:
		[:aStream | 
			self allExtantPlayers do:
				[:aPlayer | aPlayer instantiatedUserScriptsDo:
					[:aScriptInstantiation |
						aScriptInstantiation status == #ticking ifTrue:
							[aStream nextPut: aScriptInstantiation]]]]
]

{ #category : #intialize }
EtoysPresenter >> allExtantPlayers [
	"The initial intent here was to produce a list of Player objects associated with any Morph in the tree beneath the receiver's associatedMorph.  whether it is the submorph tree or perhaps off on unseen bookPages.  We have for the moment moved away from that initial intent, and in the current version we only deliver up players associated with the submorph tree only.  <-- this note dates from 4/21/99

Call #flushPlayerListCache; to force recomputation."

	| fullList |
	playerList ifNotNil:
		[^ playerList].
	associatedMorph ifNil:
		[^ #()].

	fullList := associatedMorph allMorphs select: 
		[:m | m player ~~ nil] thenCollect: [:m | m player].
	fullList copy do:
		[:aPlayer |
			aPlayer class scripts do:
				[:aScript |  aScript isTextuallyCoded ifFalse:
					[aScript currentScriptEditor ifNotNil: [:ed |
						| objectsReferredToByTiles |
						objectsReferredToByTiles := ed allMorphs
							select:
								[:aMorph | (aMorph isKindOf: TileMorph) and: [aMorph type == #objRef]]
							thenCollect:
								[:aMorph | aMorph actualObject].
						fullList addAll: objectsReferredToByTiles]]]].

	^ playerList := fullList asSet asArray sort:
			[:a :b | a externalName < b externalName]
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> allGoButtons [
	"Answer a list of all script-controlling Go buttons within my scope"

	^ associatedMorph allMorphs select:
		[:aMorph | (aMorph isKindOf: ThreePhaseButtonMorph) and:
			[aMorph actionSelector == #goUp:with:]]

	"ActiveWorld presenter allGoButtons"
]

{ #category : #playerList }
EtoysPresenter >> allKnownScriptSelectors [
	"Answer a list of all the selectors implemented by any user-scripted objected within the scope of the receiver"

	| aSet allUniclasses |
	aSet := Set with: ('script' translated , '1') asSymbol.
	allUniclasses := (self presenter allPlayersWithUniclasses collect:
		[:aPlayer | aPlayer class]) asSet.
	allUniclasses do:
		[:aUniclass | aSet addAll: aUniclass namedTileScriptSelectors].
	^ aSet sorted

"ActiveWorld presenter allKnownScriptSelectors"

]

{ #category : #playerList }
EtoysPresenter >> allKnownUnaryScriptSelectors [
	"Answer a list of all the unary selectors implemented by any user-scripted objected within the scope of the receiver; include #emptyScript as a bail-out"

	| aSet allUniclasses |
	aSet := Set with: #emptyScript.
	allUniclasses := (self allPlayersWithUniclasses collect:
		[:aPlayer | aPlayer class]) asSet.
	allUniclasses do:
		[:aUniclass | aSet addAll: aUniclass namedUnaryTileScriptSelectors].
	^ aSet sorted

"ActiveWorld presenter allKnownUnaryScriptSelectors"

]

{ #category : #playerList }
EtoysPresenter >> allPlayersWithUniclasses [
	"Answer a list of all players known to the receiver that have uniclasses"

	^ self allExtantPlayers select: [:p | p belongsToUniClass]
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> allStepButtons [
	"Answer a list of all the script-controlling Step buttons within my scope"

	^ associatedMorph allMorphs select:
		[:aMorph | (aMorph isKindOf: ThreePhaseButtonMorph) and:
			[aMorph actionSelector == #stepStillDown:with:]]

	"ActiveWorld presenter allStepButtons"
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> allStopButtons [
	"Answer a list of all script-controlling Stop buttons within my scope"

	^ associatedMorph allMorphs select:
		[:aMorph | (aMorph isKindOf: ThreePhaseButtonMorph) and:
			[aMorph actionSelector == #stopUp:with:]]

	"ActiveWorld presenter allStopButtons"
]

{ #category : #access }
EtoysPresenter >> associatedMorph [
	^ associatedMorph
]

{ #category : #access }
EtoysPresenter >> associatedMorph: aMorph [
	associatedMorph := aMorph
]

{ #category : #'tile support' }
EtoysPresenter >> booleanTiles [
	"Answer some boolean-valued tiles.  This dates back to very early etoy work in 1997, and presently has no sent senders"

	| list |
	list := #(#(0 #< 1) #(0 #<= 1) #(0 #= 1) #(0 #~= 1) #(0 #> 1) #(0 #>= 1)).
	list := list asOrderedCollection collect: 
					[:entry | 
					| rcvr op arg |
					rcvr := entry first.
					op := (entry second) asSymbol.
					arg := entry last.
					self 
						phraseForReceiver: rcvr
						op: op
						arg: arg
						resultType: #Boolean].
	list add: (self 
				phraseForReceiver: Color red
				op: #=
				arg: Color red
				resultType: #Boolean).
	^list	"copyWith: CompoundTileMorph new"
]

{ #category : #playerList }
EtoysPresenter >> browseAllScriptsTextually [
	"Open a method-list browser on all the scripts in the project"

	| aList aMethodList |
	(aList := self uniclassesAndCounts) size = 0 ifTrue: [^ self inform: 'there are no scripted players'].
	aMethodList := OrderedCollection new.
	aList do:
		[:aPair | aPair first addMethodReferencesTo: aMethodList].
	aMethodList size > 0 ifFalse: [^ self inform: 'there are no scripts in this project!'].
	
	SystemNavigation new 
		browseMessageList: aMethodList 
		name: 'All scripts in this project' 
		autoSelect: nil

"
ActiveWorld presenter browseAllScriptsTextually
"
]

{ #category : #viewer }
EtoysPresenter >> cacheSpecs: aMorph [
	"For SyntaxMorph's type checking, cache the list of all viewer command specifications."

	aMorph world ifNil: [^ true].
	Preferences universalTiles ifFalse: [^ true].
	Preferences eToyFriendly ifFalse: [^ true].	"not checking"
	(Project current projectParameterAt: #fullCheck ifAbsent: [false]) 
		ifFalse: [^ true].	"not checking"

	SyntaxMorph initialize.
]

{ #category : #'tile support' }
EtoysPresenter >> constantTile: anObject [ 
	"Answer a constant tile that represents the object"

	(anObject isColor) 
		ifTrue: 
			[^ColorTileMorph new typeColor: (ScriptingSystem colorForType: #Color)].
	^anObject newTileMorphRepresentative 
		typeColor: (ScriptingSystem colorForType: (self typeForConstant: anObject))
]

{ #category : #'standardPlayer etc' }
EtoysPresenter >> createStandardPlayer [
	| aMorph |

	aMorph := ImageMorph new image: (ScriptingSystem formAtKey: 'standardPlayer').
	associatedMorph addMorphFront: aMorph.
	(standardPlayer := aMorph assuredPlayer) renameTo: 'dot' translated.
	aMorph setBalloonText: '...'.
	self positionStandardPlayer.
	^ standardPlayer
]

{ #category : #misc }
EtoysPresenter >> currentlyViewing: aPlayer [ 
	"Only detects viewers in tabs"

	aPlayer ifNil: [^false].
	^aPlayer viewerFlapTab notNil
]

{ #category : #misc }
EtoysPresenter >> drawingJustCompleted: aSketchMorph [
	"The user just finished drawing.  Now maybe put up a viewer"

	| aWorld |
	self flushPlayerListCache.  "Because a new drawing already created one, thus obviating #assuredPlayer kicking in with its invalidation"

	aWorld := associatedMorph world.
	(aWorld hasProperty: #automaticFlapViewing)
		ifTrue:
			[^ aWorld presenter viewMorph: aSketchMorph].

	(aWorld hasProperty: #automaticViewing)
		ifTrue:
			[self viewMorph: aSketchMorph]
]

{ #category : #playerList }
EtoysPresenter >> flushPlayerListCache [
	playerList := nil
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> goButtonState: newState [
	"Get all go buttons in my scope to show the correct state"

	self allGoButtons do:
		[:aButton | aButton state: newState]
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> goUp: evt with: aMorph [
	self startRunningScripts
]

{ #category : #playerList }
EtoysPresenter >> hasAnyTextuallyCodedScripts [
	"Answer whether any uniclasses in the receiver have any textually coded scripts"

	self uniclassesAndCounts do:
		[:classAndCount | 
			classAndCount first scripts do:
				[:aScript | aScript isTextuallyCoded ifTrue: [^ true]]].
	^ false

"
ActiveWorld presenter hasAnyTextuallyCodedScripts
"
]

{ #category : #misc }
EtoysPresenter >> morph: aMorph droppedIntoPasteUpMorph: aPasteUpMorph [
	aPasteUpMorph automaticViewing ifTrue:
		[aMorph isCandidateForAutomaticViewing ifTrue:
			[self viewMorph: aMorph]]
]

{ #category : #viewer }
EtoysPresenter >> nascentPartsViewer [
	^ StandardViewer new
]

{ #category : #viewer }
EtoysPresenter >> nascentPartsViewerFor: aViewee [
	"Create a new, naked Viewer object for viewing aViewee.  Give it a vocabulary if either the viewee insists on one or if the project insists on one."

	| aViewer aVocab |
	(aViewee isKindOf: KedamaExamplerPlayer) ifTrue: [^ KedamaStandardViewer new].
	aViewer := StandardViewer new.
	(aVocab := aViewee vocabularyDemanded)
		ifNotNil:
			[aViewer useVocabulary: aVocab]
		ifNil:
			[(aVocab := associatedMorph currentVocabularyFor: aViewee) ifNotNil:
				[aViewer useVocabulary: aVocab]].
	
	"If the viewee does not *demand* a special kind of Viewer, and if the project has not specified a preferred vocabulary, then the system defaults will kick in later"
	^ aViewer
]

{ #category : #'palette & parts bin' }
EtoysPresenter >> ownStandardPalette [
	^ standardPalette
]

{ #category : #'tile support' }
EtoysPresenter >> phraseForReceiver: rcvr op: op arg: arg resultType: resultType [ 
	"Answer a PhraseTileMorph affiliated with the given receiver, initialized to hold the given operator, argument, and result type"

	| m argTile rcvrTile |
	arg isNil 
		ifTrue: 
			[m := PhraseTileMorph new 
						setOperator: op
						type: resultType
						rcvrType: (self typeForConstant: rcvr)]
		ifFalse: 
			[m := PhraseTileMorph new 
						setOperator: op
						type: resultType
						rcvrType: (self typeForConstant: rcvr)
						argType: (self typeForConstant: arg).
			argTile := self constantTile: arg.
			argTile position: m lastSubmorph position.
			m lastSubmorph addMorph: argTile].
	rcvrTile := self constantTile: rcvr.
	"	TilePadMorph makeReceiverColorOfResultType ifTrue: [rcvrTile color: m color]."
	rcvrTile position: m firstSubmorph position.
	m firstSubmorph addMorph: rcvrTile.
	m vResizing: #shrinkWrap.
	^m
]

{ #category : #'standardPlayer etc' }
EtoysPresenter >> positionStandardPlayer [
	"Put the standard player slightly off-screen"

	standardPlayer ifNotNil:
		[standardPlayer costume position: (associatedMorph topLeft - (13@0))]
]

{ #category : #printing }
EtoysPresenter >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' (', self identityHash printString, ')'
]

{ #category : #intialize }
EtoysPresenter >> reallyAllExtantPlayers [
	
	^self reallyAllExtantPlayersNoSort sorted:
		[:a :b | a externalName < b externalName]
]

{ #category : #intialize }
EtoysPresenter >> reallyAllExtantPlayersNoSort [
	"The initial intent here was to produce a list of Player objects associated with any Morph in the tree beneath the receiver's associatedMorph.  whether it is the submorph tree or perhaps off on unseen bookPages.  We have for the moment moved away from that initial intent, and in the current version we only deliver up players associated with the submorph tree only.  <-- this note dates from 4/21/99"

	| fullList objectsReferredToByTiles aSet fullClassList |
	self flushPlayerListCache.
	aSet := IdentitySet new: 400.
	associatedMorph allMorphsAndBookPagesInto: aSet.
	fullList := aSet select: 
		[:m | m player ~~ nil] thenCollect: [:m | m player].
	fullClassList := fullList collect: [:aPlayer | aPlayer class] thenSelect: [:aClass | aClass isUniClass].
	fullClassList do:
		[:aPlayerClass |
			aPlayerClass scripts do:
				[:aScript | aScript isTextuallyCoded ifFalse:
					[aScript currentScriptEditor ifNotNil: [:ed |
						objectsReferredToByTiles := ed allMorphs
							select:
								[:aMorph | (aMorph isKindOf: TileMorph) and: [aMorph type == #objRef]]
							thenCollect:
								[:aMorph | aMorph actualObject].
						fullList addAll: objectsReferredToByTiles]]]].

	^ fullList
]

{ #category : #playerList }
EtoysPresenter >> reinvigorateAllScriptsTool: anAllScriptsTool [ 
	"Rebuild the contents of an All Scripts tool"

	| showingOnlyActiveScripts candidateList firstTwo oldList allExtantPlayers newList morphList |
	showingOnlyActiveScripts := anAllScriptsTool showingOnlyActiveScripts.
	self flushPlayerListCache.
	"needed? Probably to pick up on programmatical script-status control only"

	firstTwo := {anAllScriptsTool submorphs first.  anAllScriptsTool submorphs second}.
	oldList := (anAllScriptsTool submorphs copyFrom: 3 to: anAllScriptsTool submorphs size) collect:
		[:aRow |
			(aRow findA: UpdatingSimpleButtonMorph) target].

	allExtantPlayers := self allExtantPlayers.
	anAllScriptsTool showingAllInstances "take all instances of all classes"
		ifTrue:
			[candidateList := allExtantPlayers]  

		ifFalse:  "include only one exemplar per uniclass.  Try to get one that has some qualifying scripts"
			[candidateList := Set new.
			allExtantPlayers do:
				[:aPlayer |
					(candidateList noneSatisfy: [:plyr | plyr isMemberOf: aPlayer class]) ifTrue:
						[aPlayer instantiatedUserScriptsDo: [:aScriptInstantiation |
							(showingOnlyActiveScripts not or: [aScriptInstantiation pausedOrTicking]) 								ifTrue:
									[candidateList add: aPlayer]]]]].
	newList := OrderedCollection new.
	candidateList do:
		[:aPlayer | aPlayer instantiatedUserScriptsDo:
			[:aScriptInstantiation |
				(showingOnlyActiveScripts not or: [aScriptInstantiation pausedOrTicking]) ifTrue:
					[newList add: aScriptInstantiation]]].

	oldList asSet = newList asSet
		ifFalse:
			[anAllScriptsTool removeAllMorphs; addAllMorphs: firstTwo.
			morphList := newList collect:
				[:aScriptInstantiation |  aScriptInstantiation statusControlRowIn: anAllScriptsTool].
			anAllScriptsTool addAllMorphs: morphList.
			newList do:
				[:aScriptInstantiation | aScriptInstantiation updateAllStatusMorphs]]
]

{ #category : #playerList }
EtoysPresenter >> reinvigoratePlayersTool: aPlayersTool [ 
	"Rebuild the contents of the Players tool"

	| firstTwo oldList newList rowsForPlayers |
	firstTwo := {aPlayersTool submorphs first.  aPlayersTool submorphs second}.
	oldList := (aPlayersTool submorphs copyFrom: 3 to: aPlayersTool submorphs size) collect:
		[:aRow |
			aRow playerRepresented].
	self flushPlayerListCache.
	newList := self allExtantPlayers.
	oldList asSet = newList asSet
		ifFalse:
			[aPlayersTool removeAllMorphs; addAllMorphs: firstTwo.
			rowsForPlayers := newList collect:
				[:aPlayer |  aPlayer entryForPlayersTool: aPlayersTool].
			aPlayersTool addAllMorphs: rowsForPlayers ]
]

{ #category : #playerList }
EtoysPresenter >> reportPlayersAndScripts [
	"Open a window which contains a report on players and their scripts"

	| aList aString |
	self flushPlayerListCache.  "Just to be certain we get everything"
	Smalltalk garbageCollect.
	(aList := self uniclassesAndCounts) ifEmpty:  [^ self inform: 'there are no scripted players' translated].
	aString := String streamContents:
		[:aStream |
			aList do:
				[:aPair |
					aStream nextPutAll: aPair first name, ' -- ', aPair second printString.
					aStream nextPutAll: ' ', (aPair second > 1 ifTrue: ['instances'] ifFalse: ['instance']) translated, ', '.
					aStream nextPutAll: 'named' translated.
					aPair first allInstancesDo: [:inst | aStream space; nextPutAll: inst externalName].
					aStream cr].
			aStream cr.
			aList do:
				[:aPair |
					aStream cr.
					aStream nextPutAll: 
'--------------------------------------------------------------------------------------------'.
					aStream cr; nextPutAll: aPair first typicalInstanceName.
					aStream nextPutAll: '''s' translated.
					aStream nextPutAll: ' scripts:' translated.
					aPair first addDocumentationForScriptsTo: aStream]].

	(StringHolder new contents: aString)
		openLabel: 'All scripts in this project' translated

"self currentWorld presenter reportPlayersAndScripts"
]

{ #category : #'palette & parts bin' }
EtoysPresenter >> standardPalette: aPalette [
	standardPalette := aPalette
]

{ #category : #'standardPlayer etc' }
EtoysPresenter >> standardPlayer [
	standardPlayer ifNil:
		[self createStandardPlayer].
	standardPlayer costume isInWorld ifFalse: [associatedMorph addMorphNearBack: standardPlayer costume].
	^ standardPlayer
]

{ #category : #misc }
EtoysPresenter >> standardPlayfield: aPlayfield [
	standardPlayfield := aPlayfield
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> startRunningScripts [
	"Start running scripts; get stop-step-go buttons to show the right thing"

	self stopButtonState: #off.
	self stepButtonState: #off.
	self goButtonState: #on.
	associatedMorph startRunningAll.

	"associatedMorph borderColor: Preferences borderColorWhenRunning."

	ThumbnailMorph recursionReset.  "needs to be done once in a while (<- tk note from 1997)"
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> startRunningScriptsFrom: ignored [
	"Start running all scripts.  Get all script-control buttons to show the right thing."

	self startRunningScripts
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> stepButtonState: newState [
	"Get all step buttons in my scope to show the correct state"

	self allStepButtons do:
		[:aButton | aButton state: newState]
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> stepDown: evt with: aMorph [
	self stopRunningScripts
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> stepStillDown: dummy with: theButton [
	"The step button is still down; get temporary button feedback right and step all and then get all button feedback right again"

	self stepButtonState: #pressed.
	self stopButtonState: #off.
	associatedMorph stepAll.
	associatedMorph world displayWorld.
	self stepButtonState: #off.
	self stopButtonState: #on

]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> stepUp: evt with: aMorph [
	"The step button came up; get things right"

	self stepButtonState: #off
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> stopButtonState: newState [
	"Get all stop buttons in my scope to show the correct state"

	self allStopButtons do:
		[:aButton | aButton state: newState]
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> stopRunningScripts [
	"Put all ticking scripts within my scope into paused mode.  Get any scripting-control buttons to show the correct state"

	self stopButtonState: #on.
	self stepButtonState: #off.
	self goButtonState: #off.
	associatedMorph stopRunningAll.

	"associatedMorph borderColor: Preferences borderColorWhenStopped"
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> stopRunningScriptsFrom: ignored [
	"Stop running scripts; get all script-control buttons to reflect this"

	self stopRunningScripts
]

{ #category : #'stop-step-go buttons' }
EtoysPresenter >> stopUp: dummy with: theButton [
	self flushPlayerListCache.  "catch guys not in cache but who're running"
	self stopRunningScripts
]

{ #category : #'palette & parts bin' }
EtoysPresenter >> systemQueryPhraseWithActionString: anActionString labelled: aLabel [
	"Answer a SystemQueryPhrase with the given action string and label"

	| aTile aPhrase |
	
	aPhrase := SystemQueryPhrase new.
	aTile := BooleanTile new.
	aTile setExpression: anActionString label: aLabel.
	aPhrase addMorph: aTile.
	aPhrase enforceTileColorPolicy.
	^ aPhrase
]

{ #category : #misc }
EtoysPresenter >> tempCommand [
	Transcript cr; show: '#tempCommand invoked for Presenter'
]

{ #category : #playerList }
EtoysPresenter >> toolToViewScriptInstantiations [
	"Open a tool which shows, and allows the user to change the status of, all the instantiations of all the user-written scripts in the world"

	AllScriptsTool launchAllScriptsToolFor: self

	"self currentWorld presenter toolToViewScriptInstantiations"
]

{ #category : #'tile support' }
EtoysPresenter >> typeForConstant: anObject [
	^ anObject basicType
]

{ #category : #playerList }
EtoysPresenter >> uniclassesAndCounts [
	"Answer a list of all players known to the receiver that have uniclasses"

	^ (self allPlayersWithUniclasses collect: [:aPlayer | aPlayer class]) asSet asArray collect:
		[:aClass | Array
			with:	aClass
			with:	aClass instanceCount]


	"self currentWorld presenter uniclassesAndCounts"
]

{ #category : #viewer }
EtoysPresenter >> updateViewer: aViewer [
	self updateViewer: aViewer forceToShow: nil
]

{ #category : #viewer }
EtoysPresenter >> updateViewer: aViewer forceToShow: aCategorySymbol [
	"Update the given viewer to make sure it is in step with various possible changes in the outside world, and when reshowing it be sure it shows the given category"

	| aPlayer aPosition newViewer oldOwner wasSticky barHeight itsVocabulary aCategory categoryInfo restrictedIndex syms |
	aCategory := aCategorySymbol ifNotNil: [aViewer currentVocabulary translatedWordingFor: aCategorySymbol].
	categoryInfo := aViewer categoryMorphs  asOrderedCollection collect:
		[:aMorph | aMorph categoryRestorationInfo].

	itsVocabulary := aViewer currentVocabulary.
	syms := aViewer symbolsOfCategoriesCurrentlyShowing.
	aCategory ifNotNil: [(syms includes: aCategorySymbol) ifFalse:
		[(syms isEmpty or: [syms first ~= #search])
			ifTrue:
				[categoryInfo addFirst: aCategorySymbol.]
			ifFalse:
				[categoryInfo add: aCategorySymbol afterIndex: 1]]].
	aPlayer := aViewer scriptedPlayer.
	aPosition := aViewer position.
	wasSticky := aViewer isSticky.
	newViewer := aViewer species new visible: false.
	(aViewer isMemberOf: KedamaStandardViewer)
		ifTrue: [restrictedIndex := aViewer restrictedIndex].
	barHeight := aViewer submorphs first listDirection == #topToBottom
		ifTrue:
			[aViewer submorphs first submorphs first height]
		ifFalse:
			[0].
	Preferences viewersInFlaps ifTrue:
		[newViewer setProperty: #noInteriorThumbnail toValue: true].

	newViewer rawVocabulary: itsVocabulary.
	newViewer limitClass: aViewer limitClass.
	newViewer initializeFor: aPlayer barHeight: barHeight includeDismissButton: aViewer hasDismissButton showCategories: categoryInfo.
	(newViewer isMemberOf: KedamaStandardViewer)
		ifTrue: [
			newViewer providePossibleRestrictedView: 0.
			newViewer providePossibleRestrictedView: restrictedIndex].
	wasSticky ifTrue: [newViewer beSticky].
	oldOwner := aViewer owner.
	oldOwner ifNotNil:
		[oldOwner replaceSubmorph: aViewer by: newViewer].
	
	"It has happened that old readouts are still on steplist.  We may see again!"

	newViewer position: aPosition.
	newViewer enforceTileColorPolicy.
	newViewer visible: true.
	newViewer world ifNotNil: [:aWorld | aWorld startSteppingSubmorphsOf: newViewer].
	newViewer layoutChanged
]

{ #category : #'tile support' }
EtoysPresenter >> valueTiles [
	"Answer some constant-valued tiles.  This dates back to very early etoy work in 1997, and presently has no senders"

	| tiles |
	tiles := OrderedCollection new.
	tiles add: (5 newTileMorphRepresentative typeColor: (ScriptingSystem colorForType: #Number)).
	tiles add: (ColorTileMorph new typeColor: (ScriptingSystem colorForType: #Color)).
	tiles add: (TileMorph new typeColor: (ScriptingSystem colorForType: #Number);
			setExpression: '(180 atRandom)'
			label: 'random').
	tiles add: RandomNumberTile new.
	^ tiles
]

{ #category : #viewer }
EtoysPresenter >> viewMorph: aMorph [ 
	| aPlayer openViewers aViewer aPalette aRect aPoint nominalHeight aFlapTab topItem flapLoc |
	Sensor leftShiftDown 
		ifFalse: 
			[((aPalette := aMorph standardPalette) notNil and: [aPalette isInWorld]) 
				ifTrue: [^aPalette viewMorph: aMorph]].
	aPlayer := (topItem := aMorph topRendererOrSelf) assuredPlayer.
	openViewers := aPlayer allOpenViewers.
	aViewer := openViewers isEmpty ifFalse: [ openViewers first ] ifTrue: [ self nascentPartsViewer ].
	self cacheSpecs: topItem.	"redo the spec cache once in a while"

	"19 sept 2000 - allow flaps in any paste up"
	flapLoc := associatedMorph.	"world"
	Preferences viewersInFlaps  ifTrue:  [
		aViewer owner ifNotNil: [ :f | ^f flapTab showFlap; yourself ].
		aViewer setProperty: #noInteriorThumbnail toValue: true.
			aViewer initializeFor: aPlayer barHeight: 0.
			aViewer enforceTileColorPolicy.
			aViewer fullBounds.	"force layout"
			"associatedMorph addMorph: aViewer."	"why???"
			flapLoc hideViewerFlapsOtherThanFor: aPlayer.
			aFlapTab := flapLoc viewerFlapTabFor: topItem.
			aFlapTab referent submorphs 
				do: [:m | (m isKindOf: Viewer) ifTrue: [m delete]].
			aViewer visible: true.
			aFlapTab applyThickness: aViewer width + 25.
			aFlapTab spanWorld.
			aFlapTab showFlap.
			aViewer position: aFlapTab referent position.
			aFlapTab referent addMorph: aViewer beSticky.	"moved"
			flapLoc startSteppingSubmorphsOf: aFlapTab.
			flapLoc startSteppingSubmorphsOf: aViewer.
			^aFlapTab].
	aViewer initializeFor: aPlayer barHeight: 6.
	aViewer enforceTileColorPolicy.
	aViewer fullBounds.	"force layout"
	Preferences automaticViewerPlacement 
		ifTrue: 
			[aPoint := aMorph bounds right 
						@ (aMorph center y - ((nominalHeight := aViewer initialHeightToAllow) // 2)).
			aRect := (aPoint extent: aViewer width @ nominalHeight) 
						translatedToBeWithin: flapLoc bounds.
			aViewer position: aRect topLeft.
			aViewer visible: true.
			associatedMorph addMorph: aViewer.
			flapLoc startSteppingSubmorphsOf: aViewer.
			"it's already in the world, somewhat coincidentally"
			^aViewer].
	aMorph primaryHand attachMorph: (aViewer visible: true).
	^aViewer
]

{ #category : #viewer }
EtoysPresenter >> viewObject: anObject [
	"Open up and return a viewer on the given object.  If the object is a Morph, open a viewer on its associated Player"

	anObject isMorph
		ifTrue:
			[self viewMorph: anObject]  "historic morph/player implementation"
		ifFalse:
			[self viewObjectDirectly: anObject]
]

{ #category : #viewer }
EtoysPresenter >> viewObjectDirectly: anObject [
	"Open up and return a viewer on the given object"

	|  aViewer aRect aPoint nominalHeight aFlapTab flapLoc |

	associatedMorph addMorph: (aViewer := self nascentPartsViewerFor: anObject).
	flapLoc := associatedMorph "world".
	Preferences viewersInFlaps ifTrue:
		[aViewer setProperty: #noInteriorThumbnail toValue: true.
		aViewer initializeFor: anObject barHeight: 0.
		aViewer enforceTileColorPolicy.
		flapLoc hideViewerFlapsOtherThanFor: anObject.
		aFlapTab := flapLoc viewerFlapTabFor: anObject.
		aFlapTab referent submorphs do: 
			[:m | (m isKindOf: Viewer) ifTrue: [m delete]].
		aFlapTab referent addMorph: aViewer beSticky.
		aViewer visible: true.
		aFlapTab applyThickness: aViewer width + 25.
		aFlapTab spanWorld.
		aFlapTab showFlap. 
		aViewer position: aFlapTab referent position.
		flapLoc startSteppingSubmorphsOf: aFlapTab.
		flapLoc startSteppingSubmorphsOf: aViewer.
		^ aFlapTab].
	
	"Caution: the branch below is historical and has not been used for a long time, though if you set the #viewersInFlaps preference to false you'd hit it.  Not at all recently maintained."
	aViewer initializeFor: anObject barHeight: 6.
	aViewer enforceTileColorPolicy.
	Preferences automaticViewerPlacement ifTrue:
		[aPoint := anObject bounds right @ 
			(anObject center y - ((nominalHeight := aViewer initialHeightToAllow) // 2)).
		aRect := (aPoint extent: (aViewer width @ nominalHeight)) translatedToBeWithin: flapLoc bounds.
		aViewer position: aRect topLeft.
		aViewer visible: true.
		flapLoc startSteppingSubmorphsOf: aViewer.
		"it's already in the world, somewhat coincidentally"
		^ aViewer].
	anObject primaryHand attachMorph: (aViewer visible: true).
	^aViewer
]

{ #category : #access }
EtoysPresenter >> world [
	^ associatedMorph world
]
