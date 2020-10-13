"
A wrapper around either kind of watcher.  My primary raison d'etre is so that I can automatically change names when my player changes names.
"
Class {
	#name : #WatcherWrapper,
	#superclass : #AlignmentMorph,
	#instVars : [
		'player',
		'variableName'
	],
	#category : #'Etoys-Scripting Support'
}

{ #category : #accessing }
WatcherWrapper >> associatedPlayer [
	"Answer the player with which I'm associated"

	^ player
]

{ #category : #updating }
WatcherWrapper >> bringUpToDate [
	"Given that my player may have been renamed, reformulate my external name"

	self reconstituteName
	
]

{ #category : #initialization }
WatcherWrapper >> buildForPlayer: aPlayer getter: aGetter [ 
	"Build up basic structure"
	| aColor |
	self
		player: aPlayer
		variableName: aGetter inherentSelector.
	aColor := Color
				r: 0.387
				g: 0.581
				b: 1.0.
	self listDirection: #leftToRight;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 color: aColor;
		 layoutInset: -1;
		 borderWidth: 1;
		 borderColor: aColor darker;
		 listCentering: #center.
	self
		addMorphBack: (self buildReadout: aGetter)
]

{ #category : #initialization }
WatcherWrapper >> buildReadout: aGetter [ 
	| triplet type wording setter vocab readout |
	triplet := self readoutInformation: aGetter.
	type := triplet first.
	wording := triplet second.
	setter := triplet third.
	vocab := Vocabulary vocabularyForType: type.
	readout := vocab
				updatingTileForTarget: player
				partName: wording
				getter: aGetter
				setter: setter.
	readout
		setNameTo: ('{1}''s {2}' translated format: {player externalName. wording}).
	readout
		minHeight: (vocab wantsArrowsOnTiles
				ifTrue: [22]
				ifFalse: [14]).
	^ readout
]

{ #category : #initialization }
WatcherWrapper >> fancyForPlayer: aPlayer getter: aGetter [ 
	"build a labeled readout"
	| aColor aLabel |
	self buildForPlayer: aPlayer getter: aGetter.
	aColor := self detailedWatcherColor.
	aLabel := StringMorph contents: variableName translated , ' = ' font: ScriptingSystem fontForTiles.
	aLabel setProperty: #watcherLabel toValue: true.
	self addMorphFront: aLabel.
	self addMorphFront: (aPlayer tileReferringToSelf borderWidth: 0;
			 layoutInset: 4 @ 0;
			 typeColor: aColor;
			 color: aColor;
			 bePossessive)
]

{ #category : #accessing }
WatcherWrapper >> getterTilesForDrop [
	"Answer getter tiles to use if there is an attempt to drop me onto a tile pad"

	| aCategoryViewer |
	aCategoryViewer := CategoryViewer new initializeFor: player categoryChoice: #basic.
	^ aCategoryViewer getterTilesFor: variableName asGetterSelector type: self resultType
]

{ #category : #accessing }
WatcherWrapper >> isTileLike [
	"Answer whether the receiver can participate tile-like"

	^ true
]

{ #category : #identification }
WatcherWrapper >> isTileScriptingElement [
	"Answer whether the receiver is a tile-scripting element"

	^ true
]

{ #category : #accessing }
WatcherWrapper >> justGrabbedFrom: formerOwner [
	"The receiver was just grabbed from its former owner and is now attached to the hand."

	(submorphs select: [:m | m isTileMorph]) do:
		[:m | m hidePopArrows].
	super justGrabbedFrom: formerOwner
]

{ #category : #updating }
WatcherWrapper >> localeChanged [
]

{ #category : #initialization }
WatcherWrapper >> player: aPlayer variableName: aVariableName [
	"Set up my initial state"
	player := aPlayer.
	variableName := aVariableName.
	self reconstituteName

]

{ #category : #initialization }
WatcherWrapper >> readoutInformation: aGetter [ 
	"Answer a triplet of {type. wording. setter}"
	| info anInterface |
	info := player slotInfoForGetter: aGetter.
	"In case of a variable"
	info
		ifNotNil: [^ {info type. aGetter inherentSelector. variableName asSetterSelector}].
	"In case of a slot"
	anInterface := Vocabulary eToyVocabulary
				methodInterfaceAt: aGetter
				ifAbsent: [^ {#Unknown. '*'. nil}].
	^ {anInterface resultType. anInterface wording. anInterface companionSetterSelector}
]

{ #category : #accessing }
WatcherWrapper >> readoutMorph [
	"Answer the submorph of mine that serves as my readout"

	^ self allMorphs detect:
		[:m | m isEtoyReadout] ifNone: [nil]
]

{ #category : #updating }
WatcherWrapper >> reconstituteName [
	"Reconstitute the external name of the receiver"

	variableName ifNotNil:
		[self setNameTo: ('{1}''s {2}' translated format: {player externalName. variableName translated}).
		(self submorphWithProperty: #watcherLabel) ifNotNil:
			[:aLabel | aLabel contents: variableName asString translated, ' = ']]
]

{ #category : #accessing }
WatcherWrapper >> resultType [
	"Answer the result type the receiver would produce."

	^ player typeForSlotWithGetter: variableName asGetterSelector
]

{ #category : #accessing }
WatcherWrapper >> tileRows [
	"Answer, for the benefit of d&d scripting, a structure appropriate for dropping nto a script"

	^ Array with: (Array with: self getterTilesForDrop)
]

{ #category : #initialization }
WatcherWrapper >> unlabeledForPlayer: aPlayer getter: aGetter [ 
	"build a simple watcher"
	| readout |
	self buildForPlayer: aPlayer getter: aGetter.
	readout := self submorphs last.
	(readout isKindOf: TileMorph)
		ifTrue: [readout labelMorph lock: true.
			readout labelMorph beSticky]
]
