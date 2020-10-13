"
An abstract superclass for both CategoryViewer and StandardViewer.  A viewer is always associated with a particular 'scriptedPlayer' -- the object whose protocol it shows in tile form.
"
Class {
	#name : #Viewer,
	#superclass : #AlignmentMorph,
	#instVars : [
		'scriptedPlayer'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #queries }
Viewer >> aboutMethod: aSelector [ 
	"Give the user documentation for the selector"
	| aClass help |
	aClass := scriptedPlayer class whichClassIncludesSelector: aSelector.
	help := aClass firstCommentAt: aSelector.
	help
		ifNotNil: [self
				inform: (help string withNoLineLongerThan: 25)]
]

{ #category : #'special phrases' }
Viewer >> angleToPhrase [

	| outerPhrase getTile |
	outerPhrase := PhraseTileMorph new 
				setOperator: #+
				type: #Number
				rcvrType: #Player
				argType: #Color.	"temp dummy"
	(outerPhrase submorphs second) delete.	"operator"
	(outerPhrase submorphs second) delete.	"color"
	getTile := TileCommandWithArgumentMorph newKedamaAngleToTile.

	outerPhrase addMorphBack: getTile.
	^outerPhrase
]

{ #category : #'special phrases' }
Viewer >> bounceOnColorPhrase [

	| outerPhrase bounceOn |
	outerPhrase := PhraseTileMorph new 
				setOperator: #+
				type: #Boolean
				rcvrType: #Player
				argType: #Color.	"temp dummy"
	(outerPhrase submorphs second) delete.	"operator"
	(outerPhrase submorphs second) delete.	"color"
	bounceOn := KedamaBounceOnColorTile new.
	"upHill setPatchDefaultTo: (scriptedPlayer defaultPatchPlayer)."
	outerPhrase addMorphBack: bounceOn.
	^outerPhrase.

]

{ #category : #'special phrases' }
Viewer >> bounceOnPhrase [

	| outerPhrase getTile |
	outerPhrase := PhraseTileMorph new 
				setOperator: #+
				type: #Boolean
				rcvrType: #Player
				argType: #Color.	"temp dummy"
	(outerPhrase submorphs second) delete.	"operator"
	(outerPhrase submorphs second) delete.	"color"
	getTile := TileCommandWithArgumentMorph newKedamaBounceOnTile.

	outerPhrase addMorphBack: getTile.
	^outerPhrase.

]

{ #category : #queries }
Viewer >> browseImplementorsOf: aSelector [
	"Open a browser on implementors of aSelector"

	self systemNavigation browseAllImplementorsOf: aSelector


]

{ #category : #queries }
Viewer >> browseMethodFull: aSelector [ 
	"Open a traditional browser on aSelector, in whatever class implements 
	aSelector "
	| aClass |
	aClass := scriptedPlayer class whichClassIncludesSelector: aSelector.
	Browser fullOnClass: aClass selector: aSelector
]

{ #category : #queries }
Viewer >> browseMethodInheritance: aSelector [ 
	"Open an inheritance browser on aSelector"
	| aClass |
	aClass := scriptedPlayer class whichClassIncludesSelector: aSelector.
	self systemNavigation methodHierarchyBrowserForClass: aClass selector: aSelector
]

{ #category : #queries }
Viewer >> browseSendersOf: aSelector [ 
	"Open a browser on senders of aSelector"

	self systemNavigation browseAllCallsOn: aSelector
]

{ #category : #queries }
Viewer >> browseVersionsOf: aSelector [ 
	"Open a browser on versions of aSelector"
	| aClass |
	aClass := scriptedPlayer class whichClassIncludesSelector: aSelector.
	VersionsBrowser browseVersionsForClass: aClass selector: aSelector
]

{ #category : #commands }
Viewer >> chooseVocabulary [
	"Put up a menu allowing the user to specify which protocol to use in this viewer"

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'Choose a vocabulary' translated.
	"aMenu addStayUpItem."  "For debugging only"
	Vocabulary allStandardVocabularies do:
		[:aVocabulary |
			(scriptedPlayer class implementsVocabulary: aVocabulary)
				ifTrue:
					[aMenu add: aVocabulary vocabularyName selector: #switchToVocabulary: argument: aVocabulary.
					aVocabulary == self currentVocabulary ifTrue:
						[aMenu lastItem color: Color blue]. 
					aMenu balloonTextForLastItem: aVocabulary documentation]].
	aMenu popUpInWorld: self currentWorld
]

{ #category : #'special phrases' }
Viewer >> colorComponentPhraseFor: componentName [

	| outerPhrase getTile |
	outerPhrase := PhraseTileMorph new 
				setOperator: #+
				type: #Number
				rcvrType: #Player
				argType: #Color.	"temp dummy"
	(outerPhrase submorphs second) delete.	"operator"
	(outerPhrase submorphs second) delete.	"color"
	getTile := KedamaGetColorComponentTile new.
	getTile componentName: componentName.
	getTile setPatchDefaultTo: (scriptedPlayer defaultPatchPlayer).
	outerPhrase addMorphBack: getTile.
	^outerPhrase
]

{ #category : #'special phrases' }
Viewer >> colorSeesPhrase [
	"In classic tiles, answer a complete phrase that represents the colorSees test"

	| outerPhrase |
	outerPhrase := PhraseTileMorph new 
				setOperator: #+
				type: #Boolean
				rcvrType: #Player
				argType: #Color.	"temp dummy"
	"Install (ColorSeerTile new) in middle position"
	(outerPhrase submorphs second) delete.	"operator"
	outerPhrase addMorphBack:(ColorSeerTile new showPalette: false).
	(outerPhrase submorphs second) goBehind.	"Make it third"
	outerPhrase submorphs last addMorph: (ColorTileMorph new showPalette: false;
				typeColor: (ScriptingSystem colorForType: #Color); yourself).
	^outerPhrase
]

{ #category : #'special phrases' }
Viewer >> distanceToPhrase [

	| outerPhrase getTile |
	outerPhrase := PhraseTileMorph new 
				setOperator: #+
				type: #Number
				rcvrType: #Player
				argType: #Color.	"temp dummy"
	(outerPhrase submorphs second) delete.	"operator"
	(outerPhrase submorphs second) delete.	"color"
	getTile := TileCommandWithArgumentMorph newKedamaDistanceToTile.
	outerPhrase addMorphBack: getTile.
	^outerPhrase
]

{ #category : #initialization }
Viewer >> initialize [
	super initialize.
	self useRoundedCornersInEtoys.
	self hResizing: #spaceFill; vResizing: #shrinkWrap.
	self listDirection: #topToBottom.
	self cellPositioning: #topLeft
]

{ #category : #'e-toy support' }
Viewer >> isAViewer [
	^ true
]

{ #category : #'e-toy support' }
Viewer >> isCandidateForAutomaticViewing [
	^ false
]

{ #category : #queries }
Viewer >> isViewer [
	^true
]

{ #category : #commands }
Viewer >> newPermanentScript [
	"Create a new, empty script and attach it to the hand"

	| aMorph |
	self scriptedPlayer assureUniClass.
	aMorph := ImageMorph new image: (ScriptingSystem formAtKey: 'newScript').
	aMorph setProperty: #newPermanentScript toValue: true.
	aMorph setProperty: #newPermanentPlayer toValue: self scriptedPlayer.
	self primaryHand attachMorph: aMorph
]

{ #category : #commands }
Viewer >> nextCostume [
	| aList aPlayer itsCurrent anIndex newIndex |
	aList := (aPlayer := scriptedPlayer) availableCostumesForArrows.
	aList isEmptyOrNil ifTrue: [^ Beeper beep].
	itsCurrent := aPlayer costume renderedMorph.
	anIndex := aList indexOf: itsCurrent ifAbsent: [nil].
	newIndex := anIndex
		ifNil:		[1]
		ifNotNil:	[anIndex + 1].
	newIndex > aList size ifTrue: [newIndex := 1].
	aPlayer renderedCostume: (aList at: newIndex).
	self presenter ifNotNil: [self presenter updateViewer: self]
]

{ #category : #transition }
Viewer >> noteDeletionOf: aMorph [
	| pal |
	aMorph player == scriptedPlayer ifTrue:
		[(pal := self standardPalette)
			ifNotNil: [pal showNoPalette]
			ifNil:	[self delete]]   "Viewer on a discarded player"
]

{ #category : #'e-toy support' }
Viewer >> objectViewed [
	"Answer the graphical object to which the receiver's phrases apply"

	^ (scriptedPlayer isPlayerLike)
		ifTrue:
			[scriptedPlayer costume]
		ifFalse:
			[scriptedPlayer]
]

{ #category : #'special phrases' }
Viewer >> overlapsAnyPhrase [
	"Answer a conjured-up overlaps phrase in classic tile"

	^ self conjuredUpPhraseWithOperator: #overlapsAny:
]

{ #category : #'special phrases' }
Viewer >> overlapsPhrase [
	"Answer a conjured-up overlaps phrase in classic tiles."

	^ self conjuredUpPhraseWithOperator:  #overlaps:
]

{ #category : #'special phrases' }
Viewer >> patchUphillPhrase [

	| outerPhrase upHill |
	outerPhrase := PhraseTileMorph new 
				setOperator: #+
				type: #Number
				rcvrType: #Player
				argType: #Color.	"temp dummy"
	(outerPhrase submorphs second) delete.	"operator"
	(outerPhrase submorphs second) delete.	"color"
	upHill := TileCommandWithArgumentMorph newKedamaGetUpHillTile.
	upHill setArgumentDefaultTo: (scriptedPlayer defaultPatchPlayer).
	outerPhrase addMorphBack: upHill.
	^outerPhrase.

]

{ #category : #'special phrases' }
Viewer >> patchValuePhrase [

	| outerPhrase getTile |
	outerPhrase := PhraseTileMorph new 
				setOperator: #+
				type: #Number
				rcvrType: #Player
				argType: #Color.	"temp dummy"
	(outerPhrase submorphs second) delete.	"operator"
	(outerPhrase submorphs second) delete.	"color"
	getTile := TileCommandWithArgumentMorph newKedamaGetPatchValueTile.
	getTile setArgumentDefaultTo: (scriptedPlayer defaultPatchPlayer).
	outerPhrase addMorphBack: getTile.
	^outerPhrase
]

{ #category : #commands }
Viewer >> previousCostume [
	| aList aPlayer itsCurrent anIndex newIndex |
	aList := (aPlayer := scriptedPlayer) availableCostumesForArrows.
	aList isEmptyOrNil ifTrue: [^ Beeper beep].
	itsCurrent := aPlayer costume renderedMorph.
	anIndex := aList indexOf: itsCurrent ifAbsent: [nil].
	newIndex := anIndex
		ifNil:		[aList size]
		ifNotNil:	[anIndex - 1].
	newIndex < 1 ifTrue: [newIndex := aList size].
	aPlayer renderedCostume: (aList at: newIndex).
	self presenter ifNotNil: [self presenter updateViewer: self]
]

{ #category : #'dropping\/grabbing' }
Viewer >> repelsMorph: aMorph event: ev [
	"viewers in flaps are resistant to drop gestures"
	owner isFlap ifTrue:[^true].
	^false
]

{ #category : #transition }
Viewer >> retargetFrom: oldPlayer to: newPlayer [
	"Retarget the receiver so that instead of viewing oldPlayer, it now views newPlayer, which are expected to be different instances of the same uniclass"

	scriptedPlayer == oldPlayer
		ifTrue:
			[self allMorphs do:  "nightmarishly special-cased, sorry"
				[:aMorph | 
					(aMorph isKindOf: Viewer) ifTrue:  "includes self"
						[aMorph scriptedPlayer: newPlayer].
					((aMorph isKindOf: UpdatingStringMorph) and: [aMorph target == oldPlayer]) ifTrue:
						[aMorph target: newPlayer].
					(aMorph isKindOf: TileMorph) ifTrue:
						[aMorph retargetFrom: oldPlayer to: newPlayer]]]
]

{ #category : #access }
Viewer >> scriptedPlayer [
	^ scriptedPlayer
]

{ #category : #access }
Viewer >> scriptedPlayer: aPlayer [
	scriptedPlayer := aPlayer
]

{ #category : #'special phrases' }
Viewer >> seesColorPhrase [
	"In classic tiles, answer a complete phrase that represents the seesColor test"

	| outerPhrase seesColorTile |
	outerPhrase := PhraseTileMorph new 
				setOperator: #+
				type: #Boolean
				rcvrType: #Player
				argType: #Color.	"temp dummy"
	"Install (ColorSeerTile new) in middle position"
	(outerPhrase submorphs second) delete.	"operator"
	seesColorTile := TileMorph new setOperator: #seesColor:.
	outerPhrase addMorphBack: seesColorTile.
	(outerPhrase submorphs second) goBehind.	"Make it third"
	"	selfTile := self tileForSelf bePossessive.	Done by caller.
	selfTile position: 1.
	outerPhrase firstSubmorph addMorph: selfTile.
"
	outerPhrase submorphs last addMorph: (ColorTileMorph new showPalette: false;
				typeColor: (ScriptingSystem colorForType: #Color); yourself).
	^outerPhrase
]

{ #category : #'special phrases' }
Viewer >> touchesAPhrase [
	"Answer a conjured-up touchesA phrase in classic tiles."

	^ self conjuredUpPhraseWithOperator: #touchesA:
]

{ #category : #'special phrases' }
Viewer >> turtleOfPhrase [

	| outerPhrase getTile |
	outerPhrase := PhraseTileMorph new 
				setOperator: #+
				type: #Player
				rcvrType: #Player
				argType: #Color.	"temp dummy"
	(outerPhrase submorphs second) delete.	"operator"
	(outerPhrase submorphs second) delete.	"color"
	getTile := TileCommandWithArgumentMorph newKedamaGetTurtleOfTile.
	outerPhrase addMorphBack: getTile.
	^outerPhrase
]

{ #category : #copying }
Viewer >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
scriptedPlayer := deepCopier references at: scriptedPlayer ifAbsent: [scriptedPlayer].
]

{ #category : #copying }
Viewer >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
scriptedPlayer := scriptedPlayer.		"Weakly copied"
	"Store into it to satisfy checkVariables"
]

{ #category : #'dropping\/grabbing' }
Viewer >> wantsToBeDroppedInto: aMorph [
	"Return true if it's okay to drop the receiver into aMorph"
	^aMorph isWorldMorph "only into worlds"
]
