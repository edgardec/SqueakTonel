"
A structure that allows you to view state and behavior of an object; it consists of a header and then any number of CategoryViewers.
"
Class {
	#name : #StandardViewer,
	#superclass : #Viewer,
	#instVars : [
		'firstPanel'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #categories }
StandardViewer >> addCategoryViewer [	
	self addCategoryViewerFor: self likelyCategoryToShow
]

{ #category : #categories }
StandardViewer >> addCategoryViewerFor: categoryInfo [
	"Add a category viewer for the given category info"

	self addCategoryViewerFor: categoryInfo atEnd: true
]

{ #category : #categories }
StandardViewer >> addCategoryViewerFor: categoryInfo atEnd: atEnd [
	"Add a category viewer for the given category info.  If atEnd is true, add it at the end, else add it just after the header morph"

	| aViewer |
	Cursor wait showWhile: [
		aViewer := self categoryViewerFor: categoryInfo.
		atEnd
			ifTrue:
				[self addMorphBack: aViewer]
			ifFalse:
				[self addMorph: aViewer after: submorphs first].
		aViewer establishContents.
		self world ifNotNil: [self world startSteppingSubmorphsOf: aViewer].
		self fitFlap.
		aViewer assureCategoryFullyVisible
			
			
	].

]

{ #category : #initialization }
StandardViewer >> addHeaderMorphWithBarHeight: anInteger includeDismissButton: aBoolean [
	"Add the header morph to the receiver, using anInteger as a guide for its height, and if aBoolean is true, include a dismiss buton for it"

	| header aButton aTextMorph nail wrpr costs headWrapper |
	header := AlignmentMorph newRow color: Color transparent; wrapCentering: #center; cellPositioning: #leftCenter.
	aBoolean ifTrue:
		[aButton := self tanOButton.
		header addMorph: aButton.
		aButton actionSelector: #dismiss;
				setBalloonText: 'remove this entire Viewer from the screen
don''t worry -- nothing will be lost!.' translated.
		header addTransparentSpacerOfSize: 3].

	costs := scriptedPlayer costumes.
	costs ifNotNil:
	[(costs size > 1 or: [costs size = 1 and: [costs first ~~ scriptedPlayer costume]]) ifTrue:
		[header addUpDownArrowsFor: self.
		"addArrowsOn: adds the box with two arrow at the front."
		(wrpr := header submorphs first) submorphs second setBalloonText: 'switch to previous costume' translated.	
		wrpr submorphs first  setBalloonText: 'switch to next costume' translated].
		header addTransparentSpacerOfSize: 3].	

	self viewsMorph ifTrue: [scriptedPlayer costume assureExternalName].
	aTextMorph := UpdatingStringMorph new
		useStringFormat;
		target:  scriptedPlayer;
		getSelector: #nameForViewer;
		setNameTo: 'name';
		font: ScriptingSystem fontForNameEditingInScriptor.
	self viewsMorph ifTrue:
		[aTextMorph putSelector: #setName:.
		aTextMorph setProperty: #okToTextEdit toValue: true].
	aTextMorph step.
	header  addMorphBack: aTextMorph.
	aTextMorph setBalloonText: 'Click here to edit the player''s name.' translated.	
	header addMorphBack: ((self transparentSpacerOfSize: 0) hResizing: #spaceFill; color: Color red).

	aButton := ThreePhaseButtonMorph
				labelSymbol: #AddInstanceVariable
				target: scriptedPlayer
				actionSelector: #addInstanceVariable
				arguments: #().
	aButton setBalloonText: 'click here to add a variable
to this object.' translated.
	header addMorphBack: aButton.

	header addTransparentSpacerOfSize: 3.

	nail := (self hasProperty: #noInteriorThumbnail)
		ifFalse:
			[ThumbnailMorph new objectToView: scriptedPlayer viewSelector: #costume]
		ifTrue:
			[ImageMorph new image: (ScriptingSystem formAtKey: #MenuIcon)].
	nail on: #mouseDown send: #offerViewerMenuForEvt:morph: to: scriptedPlayer.
	header addMorphBack: nail.
	nail setBalloonText: 'click here to get a menu
that will allow you to
locate this object,
tear off a tile, etc..' translated.
	(self hasProperty: #noInteriorThumbnail)
		ifFalse:
			[nail borderStyle: (BorderStyle raised width: 3)].

	header addTransparentSpacerOfSize: 3.

	aButton := ThreePhaseButtonMorph labelSymbol: #AddCategoryViewer.
	aButton
			actWhen: #buttonUp;
			target: self;
			actionSelector: #addCategoryViewer;
			setBalloonText: 'click here to add
another category pane' translated.
	header addMorphBack: aButton.

	header beSticky.
	anInteger > 0
		ifTrue:
			[headWrapper := AlignmentMorph newColumn color: self color.
			headWrapper addTransparentSpacerOfSize: (0 @ anInteger).
			headWrapper addMorphBack: header.
			self addMorph: headWrapper]
		ifFalse:
			[self addMorph: header]
]

{ #category : #categories }
StandardViewer >> addSearchPane [
	"Add a search pane"

	self addCategoryViewerFor: #(search '') atEnd: false
]

{ #category : #initialization }
StandardViewer >> affordsUniclass [
	"Answer true iff the receiver operates on behalf of an object that is, or could become, a member of a Uniclass"

	| viewee |
	^(viewee := self objectViewed) belongsToUniClass or: 
			[((viewee isInteger) not and: [viewee isBehavior not]) 
				and: [self userLevel > 0]]
]

{ #category : #categories }
StandardViewer >> categoriesCurrentlyShowing [
	^ self categoryMorphs collect: [:m | m currentCategory]
]

{ #category : #categories }
StandardViewer >> categoryMorphs [
	^ self submorphsSatisfying: [:m | m isKindOf: CategoryViewer]
]

{ #category : #categories }
StandardViewer >> categoryViewerFor: categoryInfo [ 
	"Answer a category viewer for the given category info"

	| aViewer |
	aViewer := ((categoryInfo isCollection) 
				and: [categoryInfo first == #search]) 
					ifFalse: [CategoryViewer new]
					ifTrue: [SearchingViewer new].
	aViewer initializeFor: scriptedPlayer categoryChoice: categoryInfo.
	^aViewer
]

{ #category : #categories }
StandardViewer >> chooseLimitClass [
	"Put up a menu allowing the user to choose the most generic class to show"

	| aMenu limitClass |
	aMenu := MenuMorph new defaultTarget: self.
	limitClass := self limitClass.
	scriptedPlayer class withAllSuperclasses do:
		[:aClass | 
			aClass == ProtoObject
				ifTrue:
					[aMenu addLine].
			aMenu add: aClass name selector: #setLimitClass: argument: aClass.
			aClass == limitClass ifTrue:
				[aMenu lastItem color: Color red].
			aClass == limitClass ifTrue: [aMenu addLine]].
	aMenu addTitle: 'Show only methods
implemented at or above...'.  "heh heh -- somebody please find nice wording here!"
	aMenu popUpInWorld: self currentWorld
]

{ #category : #macpal }
StandardViewer >> currentVocabulary [
	"Answer the vocabulary currently associated with the receiver"

	| aSym aVocab |
	aSym := self valueOfProperty: #currentVocabularySymbol ifAbsent: [nil].
	aSym ifNil:
		[aVocab := self valueOfProperty: #currentVocabulary ifAbsent: [nil].
		aVocab ifNotNil:
			[aSym := aVocab vocabularyName.
			self removeProperty: #currentVocabulary.
			self setProperty: #currentVocabularySymbol toValue: aSym]].
	^ aSym
		ifNotNil:
			[Vocabulary vocabularyNamed: aSym]
		ifNil:
			[(self world ifNil: [Project current world]) currentVocabularyFor: scriptedPlayer]
]

{ #category : #'user interface' }
StandardViewer >> dismiss [
	| aFlapTab |
	"User hit the dismiss button."
	(owner isKindOf: TabbedPalette)
		ifTrue:
			[^ owner showNoPalette].
	(aFlapTab := self pasteUpMorph correspondingFlapTab) ifNotNil:
		[^ aFlapTab dismissViaHalo].
	self topRendererOrSelf delete
]

{ #category : #'user interface' }
StandardViewer >> downArrowHit [
	self nextCostume
]

{ #category : #initialization }
StandardViewer >> fitFlap [
	(owner notNil and:[owner isFlap]) ifTrue:[
		owner width < self fullBounds width ifTrue:[
			owner assureFlapWidth: self fullBounds width.
		].
	].
]

{ #category : #'user interface' }
StandardViewer >> hasDismissButton [
	submorphs isEmptyOrNil ifTrue: [^ false].
	^ (submorphs first allMorphs detect:
		[:possible | possible isButton and: [possible actionSelector == #dismiss]]
			ifNone: [nil]) notNil
]

{ #category : #initialization }
StandardViewer >> initialHeightToAllow [
	^ 300
]

{ #category : #initialization }
StandardViewer >> initializeFor: aPlayer barHeight: anInteger [
	^ self initializeFor: aPlayer barHeight: anInteger includeDismissButton: true
]

{ #category : #initialization }
StandardViewer >> initializeFor: aPlayer barHeight: anInteger includeDismissButton: aBoolean [
	self initializeFor: aPlayer barHeight: anInteger includeDismissButton: aBoolean showCategories: nil
]

{ #category : #initialization }
StandardViewer >> initializeFor: aPlayer barHeight: anInteger includeDismissButton: aBoolean showCategories: categoryInfo [
	"Initialize the receiver to be a look inside the given Player.  The categoryInfo, if present, describes which categories should be present in it, in which order"

	scriptedPlayer := aPlayer.
	self listDirection: #topToBottom;
		hResizing: #spaceFill;
		width: 550;
		vResizing: #shrinkWrap;
		layoutInset: 3;
		cellInset: 3;
		borderWidth: 1.
	self color: self standardViewerColor.
	self borderColor: ScriptingSystem borderColor.
	self addHeaderMorphWithBarHeight: anInteger includeDismissButton: aBoolean.

	categoryInfo isEmptyOrNil
		ifFalse:  "Reincarnating an pre-existing list"
			[categoryInfo do:
				[:aCat | self addCategoryViewerFor: aCat]]
		ifTrue:  "starting fresh"
			[self addSearchPane. 
			self addCategoryViewer.
			self addCategoryViewer.
 			(self categoriesCurrentlyShowing includes: ScriptingSystem nameForInstanceVariablesCategory translated) ifTrue: [self addCategoryViewer].
 			(self categoriesCurrentlyShowing includes: ScriptingSystem nameForScriptsCategory translated) ifTrue: [self addCategoryViewer].
			(scriptedPlayer isPlayerLike and: [scriptedPlayer costume isMemberOf: KedamaMorph])ifTrue: [self addCategoryViewer]]

]

{ #category : #classification }
StandardViewer >> isStandardViewer [
	^true
]

{ #category : #categories }
StandardViewer >> likelyCategoryToShow [
	"Choose a category to show based on what's already showing and on some predefined heuristics"

	| possible all aCat currVocab candidate returnIfPossible |
	all := (scriptedPlayer categoriesForViewer: self) asOrderedCollection.
	possible := all copy.

	currVocab := self currentVocabulary.
	self categoryMorphs do:  [:m | 
		aCat := currVocab categoryWhoseTranslatedWordingIs: m currentCategory.
		aCat ifNotNil: [possible remove: aCat wording ifAbsent: []]].

	returnIfPossible := [:category | 
		candidate := category translatedInDomain: 'Etoys-Tiles'.
		(possible includes: candidate) ifTrue: [^ candidate]].

	scriptedPlayer hasUserDefinedSlots
		ifTrue: [returnIfPossible value: ScriptingSystem nameForInstanceVariablesCategory].
	scriptedPlayer hasUserDefinedScripts
		ifTrue: [returnIfPossible value: ScriptingSystem nameForScriptsCategory].

	#(kedama basic tests 'color & border' color flagging comparing motion geometry input preferences)
		do: returnIfPossible.

	candidate := possible isEmpty ifFalse: [possible first] ifTrue: [all first].
	^ candidate
]

{ #category : #categories }
StandardViewer >> limitClass [
	"Answer the limit class to use in this viewer"

	| aClass |
	(aClass := self valueOfProperty: #limitClass)  ifNotNil:
		[^ aClass].

	aClass := scriptedPlayer defaultLimitClassForVocabulary: self currentVocabulary.
	self setProperty: #limitClass toValue: aClass.
	^ aClass
]

{ #category : #categories }
StandardViewer >> limitClass: aClass [
	"Set aClass as the limit class for this viewer, without side effects"

	self setProperty: #limitClass toValue: aClass

]

{ #category : #'user interface' }
StandardViewer >> openLexicon [
	"Open a lexicon browser on the receiver, showing its current vocabulary"

	| littleHim | 
	littleHim := scriptedPlayer assureUniClass.

	(InstanceBrowser new useVocabulary: self currentVocabulary) openOnObject: littleHim  showingSelector: nil
]

{ #category : #categories }
StandardViewer >> outerViewer [
	"Answer the StandardViewer or equivalent that contains this object"

	^ self
]

{ #category : #initialization }
StandardViewer >> rawVocabulary: aVocabulary [
	"Mark the receiver as having aVocabulary as its vocabulary"

	self setProperty: #currentVocabularySymbol toValue: aVocabulary vocabularyName
]

{ #category : #categories }
StandardViewer >> recreateCategories [
	"To change from old to new tiles"
	| cats |
	cats := self categoriesCurrentlyShowing.
	self removeAllMorphsIn: self categoryMorphs.
	cats do: [:cat | self addCategoryViewerFor: cat]
]

{ #category : #'user interface' }
StandardViewer >> relaunchViewer [
	"Launch a new viewer to replace the receiver."

	self presenter updateViewer: self forceToShow: nil
]

{ #category : #categories }
StandardViewer >> searchingViewerMorphs [
	^ self submorphsSatisfying: [:m | m isKindOf: SearchingViewer].
]

{ #category : #categories }
StandardViewer >> setLimitClass: aClass [
	"Set aClass as the limit class for this viewer"

	self limitClass: aClass.
	self relaunchViewer

]

{ #category : #'user interface' }
StandardViewer >> standardViewerColor [
	 ^ Color r: 0.572 g: 0.883 b: 0.572
]

{ #category : #initialization }
StandardViewer >> switchToVocabulary: aVocabulary [
	"Make the receiver show categories and methods as dictated by aVocabulary.  If this constitutes a switch, then wipe out existing category viewers, which may be showing the wrong thing."

	self adoptVocabulary: aVocabulary.  "for benefit of submorphs"
	self setProperty: #currentVocabularySymbol toValue: aVocabulary vocabularyName.
	((scriptedPlayer isPlayerLike) and: [self isUniversalTiles not]) ifTrue:
		[scriptedPlayer allScriptEditors do:
			[:aScriptEditor |
				aScriptEditor adoptVocabulary: aVocabulary]]
]

{ #category : #categories }
StandardViewer >> symbolsOfCategoriesCurrentlyShowing [
	"Answer the category symbols of my categoryMorphs"

	^ self categoryMorphs collect: [:m | m chosenCategorySymbol]
]

{ #category : #'user interface' }
StandardViewer >> upArrowHit [
	self previousCostume
]

{ #category : #initialization }
StandardViewer >> useVocabulary: aVocabulary [
	"Make the receiver show categories and methods as dictated by aVocabulary"

	| itsName |
	((self valueOfProperty: #currentVocabularySymbol ifAbsent: [nil]) == (itsName := aVocabulary vocabularyName)) ifFalse:
		[self setProperty: #currentVocabularySymbol toValue: itsName.
		self removeProperty: #currentVocabulary.  "grandfathered"
		(self submorphs select: [:m | m isKindOf: CategoryViewer]) do: [:m | m delete]]
]

{ #category : #initialization }
StandardViewer >> userLevel [
	"Answer the user level for this viewer, which can be used in figuring out what to display in the viewer.  Initially, we make little use of this, but in past prototypes, and in future deployments, it may be handy."

	^ self valueOfProperty: #userLevel ifAbsent: [1]
]

{ #category : #'debug and other' }
StandardViewer >> viewMorphDirectly [
	"Launch a new viewer to replace the receiver."

	self delete.
	self presenter viewObjectDirectly: scriptedPlayer costume renderedMorph
]

{ #category : #initialization }
StandardViewer >> viewsMorph [
	"Answer whether the receiver views a morph.  Traditional viewers up until late 2000 *all* viewed morphs (as per the morph/player architecture), but viewers on non-morph/players have now become possible"

	^ scriptedPlayer isPlayerLike
]
