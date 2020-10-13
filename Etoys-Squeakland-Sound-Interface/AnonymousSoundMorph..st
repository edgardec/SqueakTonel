"
Holds a free-standing sound, i.e. one not associated with the system's sound library.
Can be played by hitting Play button, and can stop its playing by hitting Stop.
Can be dropped into a piano roll or into an event roll
Can also be named and added to the system sound library, by hitting the save button.
"
Class {
	#name : #AnonymousSoundMorph,
	#superclass : #AbstractMediaEventMorph,
	#instVars : [
		'sound',
		'interimName'
	],
	#category : #'Etoys-Squeakland-Sound-Interface'
}

{ #category : #'fileIn\/Out' }
AnonymousSoundMorph class >> fileReaderServicesForFile: fullName suffix: suffix [ 
	"Answer the file services associated with given file"

	^ (self registeredAudioFileSuffixes includes: suffix)
		ifTrue: [self services]
		ifFalse: [#()]
]

{ #category : #'fileIn\/Out' }
AnonymousSoundMorph class >> fromFileName: fullName [
	"Create an instance of the receiver from the given file path."
	
	| newPlayer aSound ext aName |
	newPlayer := self new initialize.
	('*aif*' match: fullName) 
		ifTrue: [aSound := SampledSound fromAIFFfileNamed: fullName].
	('*wav' match: fullName) 
		ifTrue: [aSound := SampledSound fromWaveFileNamed: fullName].
	newPlayer := self new.

	ext := FileDirectory extensionFor: fullName.
	aName :=  (FileDirectory on: fullName) pathParts last.
	ext size > 0 ifTrue:
		[aName := aName copyFrom: 1 to: (aName size - (ext size + 1))].
	
	newPlayer sound: aSound interimName: aName.

	newPlayer openInWorld; position: self currentWorld center.
]

{ #category : #'file suffixes' }
AnonymousSoundMorph class >> registeredAudioFileSuffixes [
    "Answer the file extensions for which the receiver registers audio services with FileList."
     "AnonymousSoundMorph registeredAudioFileSuffixes"

     ^ { 'aif'. 'aiff'.  'wav'}
]

{ #category : #initialization }
AnonymousSoundMorph >> addButtonRow [
	"Add the row of control buttons."

	| row button |
	row := AlignmentMorph newRow vResizing: #shrinkWrap;
				 color: Color transparent.
	row addVariableTransparentSpacer.
	button := SimpleButtonMorph new label: 'Play' translated font: ScriptingSystem fontForEToyButtons;
				 target: self;
				 actionSelector: #playSound.
	row addMorphBack: button.
	row addVariableTransparentSpacer.
	button := SimpleButtonMorph new label: 'Stop' translated font: ScriptingSystem fontForEToyButtons;
				 target: self;
				 actionSelector: #stopSound.
	row addMorphBack: button.
	row addVariableTransparentSpacer.

	button := SimpleButtonMorph new label: 'Save' translated font: ScriptingSystem fontForEToyButtons;
				 target: self;
				 actionSelector: #addToSoundLibrary .
	row addMorphBack: button.
	row addVariableTransparentSpacer.
	self addMorphBack: row
]

{ #category : #menu }
AnonymousSoundMorph >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add morph-specific items to the given menu which was invoked by the given hand.  This method provides is invoked both from the halo-menu and from the control-menu regimes."

	super addCustomMenuItems: aMenu hand: aHandMorph.

	aMenu addTranslatedList: #(
		-
		('wave editor' openWaveEditorOnSound 'open a wave-editor tool with this sound as its iniital sound')) translatedNoop
]

{ #category : #'piano roll' }
AnonymousSoundMorph >> addMorphsTo: morphList pianoRoll: pianoRoll eventTime: t betweenTime: leftTime and: rightTime [
	"Custom piano-roll processing.  Consult my sender for more info."

	| startX lengthInTicks endX |
	startTimeInScore > rightTime ifTrue: [^ self].  
	lengthInTicks := pianoRoll scorePlayer ticksForMSecs: sound duration * 1000.0.
	startTimeInScore + lengthInTicks < leftTime ifTrue: [^ self].
	startX := pianoRoll xForTime: startTimeInScore.
	endX := pianoRoll xForTime: startTimeInScore + lengthInTicks.
	morphList add: 
		(self left: startX; width: endX - startX).


]

{ #category : #menu }
AnonymousSoundMorph >> addToSoundLibrary [
	"Add the receiver's sound to the library, and hand the user a tile representing it."

	| aName tile |
	aName := FillInTheBlank request: 'kindly give the sound a name: ' translated initialAnswer: (interimName ifNil: ['']).
	aName isEmptyOrNil ifTrue: [^ self].

	aName := SampledSound unusedSoundNameLike:  aName.

	SampledSound
			addLibrarySoundNamed: aName
			samples: sound samples
			samplingRate: sound originalSamplingRate.
	tile := SoundTile new literal: aName.
	tile bounds: tile fullBounds.
	tile center: self fullBoundsInWorld center.
	(ScriptingTileHolder around: tile) center:  self fullBoundsInWorld center;
		openInWorld.
	
	self delete
]

{ #category : #initialization }
AnonymousSoundMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGreen
]

{ #category : #'piano roll' }
AnonymousSoundMorph >> encounteredAtTime: ticks inScorePlayer: scorePlayer atIndex: index inEventTrack: track secsPerTick: secsPerTick [

	"hack... since we are called from within the SoundPlayer loop, the Semaphore will
	block attempts to play directly from here"
	WorldState addDeferredUIMessage: [sound play].
]

{ #category : #initialization }
AnonymousSoundMorph >> initialize [
	"initialize the state of the receiver"

	super initialize.
	self height: 18.

	self balloonTextSelector: #soundMorphHelpString.
	self on: #doubleClick send: #playSound to: self.
	self on: #mouseMove send: #openInHand to: self.
	self on: #click send: #stopSound to: self.

	interimName := SampledSound unusedSoundNameLike: 'Unnamed' translated
]

{ #category : #'piano roll' }
AnonymousSoundMorph >> justDroppedInto: aMorph event: evt [
	"The receiver was just dropped into some container... respond accordingly."

	super justDroppedInto: aMorph event: evt.
	(aMorph isKindOf: PianoRollScoreMorph ) ifTrue: [^ self].
	submorphs size < 2 ifTrue:
		[self sound: sound interimName: interimName]
]

{ #category : #'piano roll' }
AnonymousSoundMorph >> justDroppedIntoPianoRoll: newOwner event: evt [
	"The receiver was just dropped into a piano roll... respond accordingly."

	| startX lengthInTicks endX |
	super justDroppedIntoPianoRoll: newOwner event: evt.
	submorphs size > 1 ifTrue: [submorphs last delete].
	self hResizing: #rigid; clipSubmorphs: true.

	startTimeInScore := newOwner timeForX: self left.
	lengthInTicks := newOwner scorePlayer ticksForMSecs: sound duration * 1000.0.
	endTimeInScore := startTimeInScore + lengthInTicks.

	endTimeInScore > newOwner scorePlayer durationInTicks ifTrue:
		[newOwner scorePlayer updateDuration].

	startX := newOwner xForTime: startTimeInScore.
	endX := newOwner xForTime: endTimeInScore.
	self width: endX - startX
]

{ #category : #menu }
AnonymousSoundMorph >> openWaveEditorOnSound [
	"Open a wave-editor tool on the receiver's sound"

	WaveEditor openOn: sound samples
]

{ #category : #menu }
AnonymousSoundMorph >> playSound [
	"Play the receiver's sound."

	sound play
]

{ #category : #'event roll' }
AnonymousSoundMorph >> putEventsOnto: aStream [
	"Write all of the events represented by the receiver in its current state onto the given stream."

	| aNewEvent |
	aNewEvent :=  MediaPlayEvent new.
	aNewEvent setType: #startSound argument: self sound hand: nil stamp: (self eventRoll timeStampForCurrentPositionOf: self).
	aStream nextPut: aNewEvent
]

{ #category : #caching }
AnonymousSoundMorph >> releaseCachedState [
	"If the sound is not currently compressed, compress it with the GSM codec"

	super releaseCachedState.
	sound isCompressed
		ifFalse: [sound := sound compressWith: GSMCodec].

]

{ #category : #accessing }
AnonymousSoundMorph >> sound [
	"Answer the sound."

	^ sound
]

{ #category : #initialization }
AnonymousSoundMorph >> sound: aSampledSound interimName: anInterimName [
	"Establish the sound object and an interim name."

	| aStringMorph |
	self removeAllMorphs.
	self hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	self borderWidth: 2.
	self listDirection: #topToBottom.
	sound := aSampledSound.
	interimName := anInterimName.

	aStringMorph := StringMorph contents: interimName font: ScriptingSystem fontForEToyButtons.
	self addMorphBack: aStringMorph.
	self addButtonRow.

	self balloonTextSelector: #soundMorphHelpString.
	self setNameTo: interimName
]

{ #category : #initialization }
AnonymousSoundMorph >> soundMorphHelpString [
	"Answer a string represnting the ballon text for the receiver."

	^ 'Holds a recorded sound of duration ' translated, (sound duration printShowingDecimalPlaces: 3),' seconds.
Double-click to hear the sound.  "add to sound library" available in halo menu.  Also suitable for dropping into a piano-roll or into an event-roll' translated
]

{ #category : #menu }
AnonymousSoundMorph >> stopPlayingSound [
	"If the receiver's sound is playing, stop it."

	sound pause
]

{ #category : #menu }
AnonymousSoundMorph >> stopSound [
	"Stop the receiver's sound from playing."

	sound pause
]

{ #category : #'event roll' }
AnonymousSoundMorph >> suitableForDroppingIntoEventRoll [
	"Answer whether the receiver is suitable for dropping into an Event Roll."

	^ true
]
