"
A facelifted version of John Maloney's original RecordingControlsMorph.
"
Class {
	#name : #RecordingControls,
	#superclass : #AlignmentMorph,
	#instVars : [
		'recorder',
		'recordingStatusLight',
		'recordMeter',
		'recordingSaved'
	],
	#category : #'Etoys-Squeakland-Sound-Interface'
}

{ #category : #'as yet unclassified' }
RecordingControls class >> additionsToViewerCategories [
	"Answer a list of (<categoryName> <list of category specs>) pairs that characterize the phrases this kind of morph wishes to add to various Viewer categories."

	^ #((#'sound recorder'
			((command recordButtonHit 'start recording')
			(command stopButtonHit 'stop recording or playback')
			(command playButtonHit 'play recording')
  )))
]

{ #category : #'parts bin' }
RecordingControls class >> descriptionForPartsBin [
	"If the receiver is a member of a class that would like to be represented in a parts bin, answer the name by which it should be known, and a documentation string to be provided, for example, as balloon help."

	^ self partName:	'SoundRecorder' translatedNoop
		categories:		{'Multimedia' translatedNoop}
		documentation:	'A device for making sound recordings.' translatedNoop
]

{ #category : #'class initialization' }
RecordingControls class >> initialize [
	"Class initialization."

	self registerInFlapsRegistry
]

{ #category : #'class initialization' }
RecordingControls class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#RecordingControls. #authoringPrototype.	'Sound Recorder' translatedNoop. 'A device for making sound recordings.' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#RecordingControls. #authoringPrototype. 'Sound Recorder' translatedNoop. 'A device for making sound recordings.' translatedNoop}
						forFlapNamed: 'Widgets'.]
]

{ #category : #'class initialization' }
RecordingControls class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #initialization }
RecordingControls >> addButtonRows [
	"Add the row of buttons at the top of the tool."

	| aWrapper aButton textButtons  maxWidth |
	aWrapper := AlignmentMorph newRow vResizing: #shrinkWrap.

	aWrapper addMorphBack: self makeStatusLight.
	aWrapper addTransparentSpacerOfSize: 6 @ 1.

	aButton := self buttonName: 'Record' translated action: #recordButtonHit.
	aButton setBalloonText: 'Start a new recording' translated.
	aWrapper addMorphBack: aButton.
	textButtons := OrderedCollection with: aButton.
	aWrapper addTransparentSpacerOfSize: 4 @ 1.

	aButton := self buttonName: 'Stop' translated action: #stopButtonHit.
	aButton setBalloonText: 'Stop current recording or playback' translated.
	aWrapper addMorphBack: aButton.
	textButtons add: aButton.
	aWrapper addTransparentSpacerOfSize: 4 @ 1.

	aButton := self buttonName: 'Play' translated action: #playButtonHit.
	aButton setBalloonText: 'Play the current recording from its beginning' translated.
	aWrapper addMorphBack: aButton.
	textButtons add: aButton.
	aWrapper addTransparentSpacerOfSize: 16 @ 1.

	aButton := self buttonName: 'Save' translated action: #saveButtonHit.
	aButton setBalloonText: 'Save the current recording for future use.' translated.
	aWrapper addMorphBack: aButton.
	textButtons add: aButton.
	aWrapper addTransparentSpacerOfSize: 8 @ 1.

	aWrapper addMorphBack: self menuButton.

	maxWidth := (textButtons collect: [:b | b width]) max.
	textButtons do: [:b | b width: maxWidth].

	self addMorphBack: aWrapper.
	aWrapper layoutChanged.

	^ aWrapper fullBounds extent
]

{ #category : #initialization }
RecordingControls >> addMenuButtonItemsTo: aMenu [
	"The menu button was hit, and aMenu will be put up in response.  Populated the menu with the appropriate items."

	aMenu title: 'Sound Recorder Options' translated.
	aMenu addStayUpItem.

	aMenu addUpdating: #durationString target: self selector: #yourself argumentList: #().

	aMenu addTranslatedList: #(
		-
		('help'	putUpAndOpenHelpFlap 'opens a flap which contains instructions')
		-
		('hand me a sound token'		makeSoundMorph	'hands you a lozenge representing the current sound,  which you can drop into a piano-roll or an event-roll, or later add to the sound library.  Double-click on it to hear the sound')
		-) translatedNoop.

	Preferences eToyFriendly
		ifFalse:
			[aMenu addTranslatedList: #(
				('trim'							trim	'remove any blanks space at the beginning and/or end of the recording.  Caution -- this feature seems to be broken, at least on some platforms, so use at your own risk.  For safety, save this sound in its untrimmed form before venturing to trim.')) translatedNoop].

	aMenu addTranslatedList: #(
				('choose compression...'	chooseCodec 	'choose which data-compression scheme should be used to encode the recording.')
				('wave editor'					showEditor	'open up the wave-editor tool to visualize and to edit the sound recorded')) translatedNoop
]

{ #category : #initialization }
RecordingControls >> addRecordLevelSliderIn: aPoint [
	"Add the slider that allows the record-level to be adjusted."

	| levelSlider r aLabel |
	levelSlider := SimpleSliderMorph new
		color: color darker;
		extent: (aPoint x * 0.75) asInteger@(aPoint y*0.6) asInteger;
		target: recorder;
		actionSelector: #recordLevel:;
		adjustToValue: recorder recordLevel.
	levelSlider sliderBalloonHelp: 'Drag to set the record level' translated.
	r := AlignmentMorph newRow
		color: color;
		layoutInset: 0;
		wrapCentering: #center; cellPositioning: #leftCenter;
		hResizing: #shrinkWrap;
		vResizing: #rigid;
		height: aPoint y + 2.
	aLabel := StringMorph contents: '0 ' font:  ScriptingSystem fontForEToyButtons.
	r addMorphBack: aLabel.
	aLabel setBalloonText: 'minimum record-level' translated.
	r addMorphBack: levelSlider.
	aLabel := StringMorph contents: '10 ' font:  ScriptingSystem fontForEToyButtons.
	aLabel setBalloonText: 'maximum record-level' translated.
	r addMorphBack: aLabel.
	self addMorphBack: r.

]

{ #category : #initialization }
RecordingControls >> buttonName: aString action: aSymbol [
	"Create a button with the given label and action selector, and answer it."

	^ SimpleButtonMorph new
		target: self;
		label: aString font: ScriptingSystem fontForEToyButtons;
		actionSelector: aSymbol

]

{ #category : #private }
RecordingControls >> buttonWithSelector: aSelector [
	"Answer the button in my button pane that bears the given selector."

	^ submorphs first submorphs detect:
		[:m | (m isKindOf: SimpleButtonMorph) and:
			[m actionSelector = aSelector]]
]

{ #category : #private }
RecordingControls >> changeCodec: aClass name: aString [ 
	"Use the supplied class as the supplier of the current codec, and call it by the name provided when needed for a menu item."

	| button newLabel |
	(aClass notNil and: [aClass isAvailable])
		ifTrue:
			[recorder codec: aClass new.
			newLabel := aString]
		ifFalse:
			[newLabel := 'None'.
			recorder codec: nil].

	"The below is for when there is a button showing the compression..."
	self submorphs
		do: [:raw | raw submorphs
				do: [:each | ((each isKindOf: SimpleButtonMorph)
							and: [each actionSelector = #chooseCodec])
						ifTrue: [button := each]]].

	button ifNotNil: [button labelString: newLabel]
]

{ #category : #'menu commands' }
RecordingControls >> chooseCodec [
	"Put up a menu allowing the user to choose which codec to use."
	| menu aName aCodec |
	menu := MenuMorph new defaultTarget: self.
	aCodec := recorder codec.
	aName := aCodec
				ifNil: ['None' translated]
				ifNotNil: [aCodec class visibleCodecName].
	menu title: ('Compression method\Currently: {1}' translated withCRs format: {aName}).
	OggDriver isAvailable
		ifTrue: [menu
				add: 'Speex (for speech)' translated
				target: self
				selector: #changeCodec:name:
				argumentList: {OggSpeexCodec. OggSpeexCodec visibleCodecName}.
			menu
				add: 'Vorbis (for music)' translated
				target: self
				selector: #changeCodec:name:
				argumentList: {OggVorbisCodec. OggVorbisCodec visibleCodecName}].
	menu
		add: 'GSM (simple compression)' translated
		target: self
		selector: #changeCodec:name:
		argumentList: {GSMCodec. GSMCodec visibleCodecName}.
	menu
		add: 'No compression' translated
		target: self
		selector: #changeCodec:name:
		argumentList: {nil. 'None' translated}.
	recorder codec
		ifNil: [menu items last color: Color red]
		ifNotNil: [menu items
				do: [:itm | itm arguments first = recorder codec class
						ifTrue: [itm color: Color red]]].
	menu popUpInWorld
]

{ #category : #private }
RecordingControls >> delete [
	"Stop the recorder from recording or playing."
	self stop.
	self stopStepping.
	^super delete

]

{ #category : #private }
RecordingControls >> durationString [
	"Answer a string representing my duration."

	recorder ifNotNil:
		[recorder recordedSound ifNotNil:
			[:aSound | ^ 'Recorded sound duration: {1} second(s)' translated format: {(aSound duration printShowingDecimalPlaces: 2)}]].

	^ 'no sound recorded yet' translated
]

{ #category : #documentation }
RecordingControls >> helpString [
	"Answer a help string for the SoundRecorder"

	^ '
Press "Record" to start recording.  Press Stop when finished recording.

After making a recording, you can:
   Press "Play" to play back the recording.
   Press "Record" to start a new recording
      (the old one would be discarded).
   Press "Save" to save the recording in the sound library.

Press the menu icon to get a menu with further options.

If you wish to refer to the sound in scripts, you need to add it to the sound library; press Save to do that; you will need to supply a name for it.

If you want to retain the sound but do not need to refer to it in scripts, you need not name it; instead, use "hand me a sound token", found in the menu, to obtain a little "sound token" object that you can subsequently use in a variety of ways:
  You can double-click on the sound token to hear the sound again.
  You can decide to save the sound after all, by using an item in the sound token''s halo menu.
  You can drop the sound token into a PianoRoll or an EventRoll.
' translated
]

{ #category : #initialization }
RecordingControls >> initialize [
	"Initialize the receiver."

	| r full |
	super initialize.
	self hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	self borderWidth: 2.
	self listDirection: #topToBottom.
	recorder := SoundRecorder new.
	recordingSaved := false.
	full := self addButtonRows.
	self changeCodec: OggSpeexCodec name: 'Speex'.

	"self addRecordLevelSliderIn: full."  "Doesn't work in most or maybe even all platforms..."

	r := AlignmentMorph newRow vResizing: #shrinkWrap.
	r addMorphBack: (self makeRecordMeterIn: full).
	self addMorphBack: r.
	self extent: 10@10.  "make minimum size"
	self setButtonEnablement

]

{ #category : #documentation }
RecordingControls >> justTornOffFromPartsBin [
	"A notification that the receiver was just torn off from a supplies flap, objects catalogue, or other parts factory; intercept this message to put up a help flap, for example."

	"self putUpHelpFlap"
]

{ #category : #initialization }
RecordingControls >> makeRecordMeterIn: aPoint [
	"Create the morph that will serve as the receiver's record meter, using the given point for its extent."

	| outerBox h |
	h := (aPoint y * 0.6) asInteger.
	outerBox := Morph new extent: (aPoint x) asInteger@h; color: Color gray.
	recordMeter := Morph new extent: 1@h; color: Color yellow.
	recordMeter position: outerBox topLeft + (1@1).
	outerBox addMorph: recordMeter.
	^ outerBox

]

{ #category : #private }
RecordingControls >> makeSoundMorph [
	"Hand the user an anonymous-sound object  representing the receiver's sound."

	| m aName |
	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].
	recorder pause.
	recordingSaved := true.
	m := AnonymousSoundMorph new.

	m sound: recorder recordedSound interimName: (aName :=  'Unnamed Sound').

	m setNameTo: aName.
	self currentHand attachMorph: m.
]

{ #category : #initialization }
RecordingControls >> makeStatusLight [
	"Make the recordingStatusLight, plce it in the #recordingStatusLight instance variable, and answer it.  It is the responsibility of the sender to add it to the tool's structure."

	recordingStatusLight := EllipseMorph new extent: 24@24.
	recordingStatusLight borderWidth: 1; borderColor: Color gray lighter.
	recordingStatusLight color: Color transparent.
	recordingStatusLight setBalloonText: 'When red, it means you are currently recording' translated.
	^ recordingStatusLight

]

{ #category : #'button commands' }
RecordingControls >> playButtonHit [
	"The user hit the play button."

	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].  "will have put up informer"
	(self buttonWithSelector: #stopButtonHit) setAppearanceForEnablement: true.
	(self buttonWithSelector: #playButtonHit) setAppearanceForEnablement: true.
	(self buttonWithSelector: #saveButtonHit) setAppearanceForEnablement: true.

	self playback
]

{ #category : #private }
RecordingControls >> playback [
	"The user hit the playback button"

	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].
	recorder pause.
	recorder playback.

]

{ #category : #documentation }
RecordingControls >> putUpAndOpenHelpFlap [
	"If appropriate, put up (if not already present) a flap giving documentation"

	| aFlap |
	aFlap := ScriptingSystem assureFlapOfLabel: 'Sound Recorder' translated withContents: self helpString.
	aFlap showFlap

]

{ #category : #documentation }
RecordingControls >> putUpHelpFlap [
	"If appropriate, put up (if not alredy present) a flap giving documentation"

	(ScriptingSystem assureFlapOfLabel: 'Sound Recorder' translated withContents: self helpString)
		hideFlap

]

{ #category : #private }
RecordingControls >> record [
	"Start the recorder."

	recorder clearRecordedSound.
	recordingSaved := false.
	recorder resumeRecording.

]

{ #category : #'button commands' }
RecordingControls >> recordButtonHit [
	"The user hit the record button."

	(self buttonWithSelector: #stopButtonHit) setAppearanceForEnablement: true.
	self record.
]

{ #category : #private }
RecordingControls >> recorder [
	"Answer the receiver's recorder."

	^ recorder

]

{ #category : #private }
RecordingControls >> saveAnonymousSound [
	"Save the recorded sound in a so-called 'anonymous sound tile'.  Such a tile holds the actual sound, rather than a reference to an element of the sound library."

	| aTile |
	self flag: #deferred.
	true ifTrue: [^ self makeSoundMorph].
	"When other issues are solved, cut over to the below...

	aTile := AnonymousSoundTile new.
	aTile actualSound: recorder recordedSound.
	aTile emblazonAppropriateLabel.
	aTile bounds: aTile fullBounds.
	aTile openInHand"
]

{ #category : #'button commands' }
RecordingControls >> saveButtonHit [
	"The user hit the 'save' button."

	| sndName tile |
	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].
	recorder pause.

	sndName := FillInTheBlank
				request: 'Sound name?' translated
				initialAnswer: 'unnamed' translated .
			sndName isEmpty ifTrue: [^ self].
			sndName = 'unnamed' translated
				ifTrue:
					[^ self saveAnonymousSound].

	sndName := SampledSound unusedSoundNameLike: sndName.
	recorder codecSignature
		ifNil: [SampledSound
			addLibrarySoundNamed: sndName
			samples: recorder condensedSamples
			samplingRate: recorder samplingRate]
		ifNotNil: [SampledSound
			addLibrarySoundNamed: sndName
			bytes: recorder condensedChannels
			codecSignature: recorder codecSignature].

	recordingSaved := true.

	tile := SoundTile new literal: sndName.
	tile bounds: tile fullBounds.
	tile openInHand
]

{ #category : #private }
RecordingControls >> setButtonEnablement [
	"Enable my buttons."

	| exists aButton mySound recordingOrPlaying |
	exists := (mySound := recorder recordedSound) notNil.
	exists
		ifTrue:
			[aButton := self buttonWithSelector: #recordButtonHit.
			aButton setBalloonText: 'Discard the current recording and start making a fresh recording' translated.
			recordingOrPlaying := mySound isPlaying or: [recorder isPaused not]]
		ifFalse:
			[recordingOrPlaying := false].
	(self buttonWithSelector: #stopButtonHit) setAppearanceForEnablement: recordingOrPlaying.
	(self buttonWithSelector: #playButtonHit) setAppearanceForEnablement: exists.
	(self buttonWithSelector: #saveButtonHit) setAppearanceForEnablement: exists.

]

{ #category : #'menu commands' }
RecordingControls >> showEditor [
	"Show my samples in a WaveEditor."

	| ed w |
	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].
	recorder pause.
	ed := WaveEditor new.
	ed data: recorder condensedSamples.
	ed samplingRate: recorder samplingRate.
	w := self world.
	w activeHand
		ifNil: [w addMorph: ed]
		ifNotNil: [w activeHand attachMorph: ed].


]

{ #category : #stepping }
RecordingControls >> startStepping [
	"Make the level meter active when dropped into the world. Do nothing if already recording. Note that this will cause other recorders to stop recording..."

	super startStepping.
	recorder isPaused ifTrue: [
		SoundRecorder allSubInstancesDo: [:r | r stopRecording].  "stop all other sound recorders"
		recorder pause].  "meter is updated while paused"

]

{ #category : #stepping }
RecordingControls >> step [
	"Periodic action.  Assure that the status light and recordMeter properly reflect the state of the recorder."

	recorder isPaused
		ifTrue: [recordingStatusLight color: Color transparent]
		ifFalse: [recordingStatusLight color: Color red].
	recordMeter extent: (recorder meterLevel + 1) @ recordMeter height.

]

{ #category : #stepping }
RecordingControls >> stepTime [
	"Answer the desired time between steps in milliseconds."

	^ 50

]

{ #category : #private }
RecordingControls >> stop [
	"Stop the recorder from recording or playing."

	recorder pause

]

{ #category : #'button commands' }
RecordingControls >> stopButtonHit [
	"The user hit the stop button."

	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].
	self stop.
	self setButtonEnablement.  "But in case it hasn't got the word..."
	(self buttonWithSelector: #stopButtonHit) setAppearanceForEnablement: false

]

{ #category : #stepping }
RecordingControls >> stopStepping [
	"Turn off recording."

	super stopStepping.
	recorder stopRecording.

]

{ #category : #'menu commands' }
RecordingControls >> trim [
	"Show my samples in a GraphMorph."
	
	| oldDuration newDuration delta msg |
	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].
	recorder pause.
	recordingSaved ifFalse:
		[(self confirm: 'Caution:  this is dangerous and destructive!
Do you really want to "trim" your recording?
(It might be smart to save the untrimmed
version in a sound token before trimming)' translated) ifFalse: [^ self]].

	oldDuration := recorder recordedSound duration.
	recorder trim: 1400 normalizedVolume: 80.0.
	newDuration := recorder recordedSound duration.
	delta := oldDuration - newDuration.
	delta > 0
		ifTrue:
			[recordingSaved := false.
			msg := (delta printShowingDecimalPlaces: 3), ' second(s) trimmed' translated]
		ifFalse:
			[msg := 'unable to trim any more, sorry' translated].
	self inform: msg
]

{ #category : #copying }
RecordingControls >> updateReferencesUsing: aDictionary [
	"Copy my recorder."

	super updateReferencesUsing: aDictionary.
	recorder := SoundRecorder new.

]
