Class {
	#name : #RecordingControlsMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'recorder',
		'recordingStatusLight',
		'recordMeter'
	],
	#category : #'MorphicExtras-SoundInterface'
}

{ #category : #'parts bin' }
RecordingControlsMorph class >> descriptionForPartsBin [
	^ self partName:	'SoundRecorder'
		categories:		#('Multimedia')
		documentation:	'A device for making sound recordings.'
]

{ #category : #'class initialization' }
RecordingControlsMorph class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'class initialization' }
RecordingControlsMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#RecordingControlsMorph.	#authoringPrototype.	'Sound' translatedNoop. 	'A device for making sound recordings.' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#RecordingControlsMorph.	#authoringPrototype.	'Sound' translatedNoop.	'A device for making sound recordings.'}
						forFlapNamed: 'Widgets'.]
]

{ #category : #'class initialization' }
RecordingControlsMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #initialization }
RecordingControlsMorph >> addButtonRows [

	| r fullWidth |
	r := AlignmentMorph newRow vResizing: #shrinkWrap.


	r addMorphBack: (self buttonName: 'Morph' translated action: #makeSoundMorph).
	r addMorphBack: (Morph new extent: 4@1; color: Color transparent).
	r addMorphBack: (self buttonName: 'Tile' translated action: #makeTile).
	r addMorphBack: (Morph new extent: 4@1; color: Color transparent).
	r addMorphBack: (self buttonName: 'Trim' translated action: #trim).
	r addMorphBack: (Morph new extent: 4@1; color: Color transparent).
	r addMorphBack: (self buttonName: 'Show' translated action: #showEditor).
	self addMorphBack: r.
	r layoutChanged.
	fullWidth := r fullBounds width.

	r := AlignmentMorph newRow vResizing: #shrinkWrap.
	r addMorphBack: (self buttonName: 'Record' translated action: #record).
	r addMorphBack: (Morph new extent: 4@1; color: Color transparent).
	r addMorphBack: (self buttonName: 'Stop' translated action: #stop).
	r addMorphBack: (Morph new extent: 4@1; color: Color transparent).
	r addMorphBack: (self buttonName: 'Play' translated action: #playback).
	r addMorphBack: (Morph new extent: 4@1; color: Color transparent).
	r addMorphBack: (self buttonName: 'Codec' translated action: #chooseCodec).
	r addMorphBack: self makeStatusLight.
	self addMorphBack: r.
	Smalltalk at: #OggSpeexCodec ifPresent: [:c |
		self changeCodec: c name: 'Speex'].
	r layoutChanged.
	fullWidth := fullWidth max: r fullBounds width.
	^ fullWidth@(r fullBounds height).

]

{ #category : #other }
RecordingControlsMorph >> addRecordLevelSlider [

	| levelSlider r |
	levelSlider := SimpleSliderMorph new
		color: color;
		extent: 100@2;
		target: recorder;
		actionSelector: #recordLevel:;
		adjustToValue: recorder recordLevel.
	r := AlignmentMorph newRow
		color: color;
		layoutInset: 0;
		wrapCentering: #center; cellPositioning: #leftCenter;
		hResizing: #shrinkWrap;
		vResizing: #rigid;
		height: 24.
	r addMorphBack: (StringMorph contents: '0 ').
	r addMorphBack: levelSlider.
	r addMorphBack: (StringMorph contents: ' 10').
	self addMorphBack: r.

]

{ #category : #other }
RecordingControlsMorph >> addRecordLevelSliderIn: aPoint [

	| levelSlider r |
	levelSlider := SimpleSliderMorph new
		color: color darker;
		extent: (aPoint x * 0.75) asInteger@(aPoint y*0.6) asInteger;
		target: recorder;
		actionSelector: #recordLevel:;
		adjustToValue: recorder recordLevel.
	r := AlignmentMorph newRow
		color: color;
		layoutInset: 0;
		wrapCentering: #center; cellPositioning: #leftCenter;
		hResizing: #shrinkWrap;
		vResizing: #rigid;
		height: aPoint y + 2.
	r addMorphBack: (StringMorph contents: '0 ' font: Preferences standardButtonFont).
	r addMorphBack: levelSlider.
	r addMorphBack: (StringMorph contents: ' 10' font: Preferences standardButtonFont).
	self addMorphBack: r.

]

{ #category : #other }
RecordingControlsMorph >> buttonName: aString action: aSymbol [

	^ SimpleButtonMorph new
		target: self;
		label: aString font: Preferences standardButtonFont;
		actionSelector: aSymbol

]

{ #category : #'button commands' }
RecordingControlsMorph >> changeCodec: aClass name: aString [ 
	| button newLabel |
	(aClass notNil
			and: [aClass isAvailable])
		ifTrue: [recorder codec: aClass new.
			newLabel := aString]
		ifFalse: [newLabel := 'None'].
	self submorphs
		do: [:raw | raw submorphs
				do: [:each | ((each isKindOf: SimpleButtonMorph)
							and: [each actionSelector = #chooseCodec])
						ifTrue: [button := each]]].
	button labelString: newLabel
]

{ #category : #'button commands' }
RecordingControlsMorph >> chooseCodec [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	Smalltalk at: #OggDriver ifPresent: [:oggDriver |
		oggDriver isAvailable
			ifTrue: [menu
					add: 'Speex'
					target: self
					selector: #changeCodec:name:
					argumentList: {Smalltalk at: #OggSpeexCodec. 'Speex'}.
				menu
					add: 'Vorbis'
					target: self
					selector: #changeCodec:name:
					argumentList: {Smalltalk at: #OggVorbisCodec. 'Vorbis'}]].
	menu
		add: 'GSM'
		target: self
		selector: #changeCodec:name:
		argumentList: {GSMCodec. 'GSM'}.
	menu
		add: 'None'
		target: self
		selector: #changeCodec:name:
		argumentList: {nil. 'None'}.
	menu popUpInWorld
]

{ #category : #'button commands' }
RecordingControlsMorph >> done [

	recorder stopRecording.
	self makeTile.
	self delete.

]

{ #category : #initialization }
RecordingControlsMorph >> initialize [

	| r full |
	super initialize.
	self hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	self borderWidth: 2.
	self listDirection: #topToBottom.
	recorder := SoundRecorder new.
	full := self addButtonRows.
	self addRecordLevelSliderIn: full.

	r := AlignmentMorph newRow vResizing: #shrinkWrap.
	r addMorphBack: (self makeRecordMeterIn: full).
	self addMorphBack: r.
	self extent: 10@10.  "make minimum size"

]

{ #category : #other }
RecordingControlsMorph >> makeRecordMeter [

	| outerBox |
	outerBox := Morph new extent: 102@18; color: Color gray.
	recordMeter := Morph new extent: 1@16; color: Color yellow.
	recordMeter position: outerBox topLeft + (1@1).
	outerBox addMorph: recordMeter.
	^ outerBox

]

{ #category : #other }
RecordingControlsMorph >> makeRecordMeterIn: aPoint [

	| outerBox h |
	h := (aPoint y * 0.6) asInteger.
	outerBox := Morph new extent: (aPoint x) asInteger@h; color: Color gray.
	recordMeter := Morph new extent: 1@h; color: Color yellow.
	recordMeter position: outerBox topLeft + (1@1).
	outerBox addMorph: recordMeter.
	^ outerBox

]

{ #category : #'button commands' }
RecordingControlsMorph >> makeSoundMorph [

	| m |
	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].

	recorder pause.
	m := SoundEventMorph new sound: recorder recordedSound.
	self world firstHand attachMorph: m.

]

{ #category : #other }
RecordingControlsMorph >> makeStatusLight [

	recordingStatusLight := Morph new extent: 18@18.
	recordingStatusLight color: Color transparent.
	^ recordingStatusLight

]

{ #category : #'button commands' }
RecordingControlsMorph >> makeTile [
	"Make a tile representing my sound.  Get a sound-name from the user by which the sound is to be known."

	| newStyleTile sndName tile tileClass |
	tileClass := Smalltalk at: #SoundTile ifAbsent:[nil].
	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].
	recorder pause.
	newStyleTile := tileClass notNil.
	newStyleTile
		ifTrue:
			[sndName := UIManager default
				request: 'Please name your new sound' translated
				initialAnswer: 'sound' translated.
			sndName isEmpty ifTrue: [^ self].

			sndName := SampledSound unusedSoundNameLike: sndName.
			SampledSound
				addLibrarySoundNamed: sndName
				samples: recorder condensedSamples
				samplingRate: recorder samplingRate.
			tile := tileClass new literal: sndName]
		ifFalse:
			[tile := InterimSoundMorph new sound: 
				(SampledSound
					samples: recorder condensedSamples
					samplingRate: recorder samplingRate)].

	tile bounds: tile fullBounds.
	tile openInHand
]

{ #category : #'button commands' }
RecordingControlsMorph >> playback [
	"The user hit the playback button"

	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].
	recorder pause.
	recorder playback.

]

{ #category : #'button commands' }
RecordingControlsMorph >> record [

	recorder clearRecordedSound.
	recorder resumeRecording.

]

{ #category : #accessing }
RecordingControlsMorph >> recorder [

	^ recorder

]

{ #category : #'button commands' }
RecordingControlsMorph >> show [
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

{ #category : #'button commands' }
RecordingControlsMorph >> showEditor [
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

{ #category : #'stepping and presenter' }
RecordingControlsMorph >> startStepping [
	"Make the level meter active when dropped into the world. Do nothing if already recording. Note that this will cause other recorders to stop recording..."

	super startStepping.
	recorder isPaused ifTrue: [
		SoundRecorder allSubInstancesDo: [:r | r stopRecording].  "stop all other sound recorders"
		recorder pause].  "meter is updated while paused"

]

{ #category : #'stepping and presenter' }
RecordingControlsMorph >> step [

	recorder isPaused
		ifTrue: [recordingStatusLight color: Color transparent]
		ifFalse: [recordingStatusLight color: Color red].
	recordMeter extent: (recorder meterLevel + 1) @ recordMeter height.

]

{ #category : #'stepping and presenter' }
RecordingControlsMorph >> stepTime [

	^ 50

]

{ #category : #'stepping and presenter' }
RecordingControlsMorph >> stop [

	recorder pause.

]

{ #category : #'stepping and presenter' }
RecordingControlsMorph >> stopStepping [
	"Turn off recording."

	super stopStepping.
	recorder stopRecording.

]

{ #category : #'button commands' }
RecordingControlsMorph >> trim [
	"Show my samples in a GraphMorph."
	
	recorder verifyExistenceOfRecordedSound ifFalse: [^ self].
	recorder pause.
	recorder trim: 1400 normalizedVolume: 80.0.

]

{ #category : #copying }
RecordingControlsMorph >> updateReferencesUsing: aDictionary [
	"Copy my recorder."

	super updateReferencesUsing: aDictionary.
	recorder := SoundRecorder new.

]
