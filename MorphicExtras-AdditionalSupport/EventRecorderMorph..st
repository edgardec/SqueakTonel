"
During recording, the EventRecorder subscribes to all events of the normal morphic hand, and saves them as they occur.

For replay, a second playback hand is created that reads events from the recorder and plays them back in the world.

The EventRecorder began with the work of Ted Kaehler and John Malone.  This was then signifcantly expanded by Leandro Caniglia and Valeria Murgia as a tutorial aid for the Morphic Wrapper project.

Since that time, I have...
Changed to a simple inboard array for the tape (event storage).
Provided the ability to condense linear mouse movement with interpolation at replay.
Made simple provisions for wrap-around of the millisecond clock.
Eliminated step methods in favor of using the processEvents cycle in the playback hand.
Provided a pause/resume mechanism that is capable of surviving project changes.
Added the ability to spawn a simple 'play me' button that can be saved as a morph.
Caused the playback hand to display its cursor double size for visibility.
Integrated a voice recorder with on-the-fly compression.
	This currently does NOT survive project changes, not is its data stored on the tape.
	Right now it can only be saved by saving the entire recorder as a morph.
	This will be fixed by adding a startSound event at each project change.
	We will also convert read/write file to use saveOnFile.
Added a journal file facility for recording sequences that end in a crash.
The above two features can be engaged via the ER's morph menu.
	- Dan Ingalls 3/6/99
"
Class {
	#name : #EventRecorderMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'tape',
		'state',
		'time',
		'deltaTime',
		'recHand',
		'playHand',
		'lastEvent',
		'lastDelta',
		'tapeStream',
		'saved',
		'statusLight',
		'voiceRecorder',
		'startSoundEvent',
		'recordMeter',
		'caption',
		'journalFile'
	],
	#category : #'MorphicExtras-AdditionalSupport'
}

{ #category : #'parts bin' }
EventRecorderMorph class >> descriptionForPartsBin [
	"Answer  a description for use in a parts bin"

	^ self partName: 'Event Recorder'
		categories: #(Presentation Tools)
		documentation: 'Lets you record and play back interactions'
]

{ #category : #'fileIn\/Out' }
EventRecorderMorph class >> fileReaderServicesForFile: fullName suffix: suffix [

	^(suffix = 'tape') | (suffix = '*') 
		ifTrue: [ self services]
		ifFalse: [#()]


]

{ #category : #'instance creation' }
EventRecorderMorph class >> fromFileNamed: aFileName [
	| file answer |
	file := FileStream readOnlyFileNamed: aFileName.
	answer := self readFrom: file setConverterForCode.
	file close.
	^ answer
]

{ #category : #'class initialization' }
EventRecorderMorph class >> initialize [

	FileServices registerFileReader: self
]

{ #category : #'instance creation' }
EventRecorderMorph class >> openTapeFromFile: fullName [
	"Open an eventRecorder tape for playback."
 
	(self new) readTape: fullName; openInWorld
]

{ #category : #'instance creation' }
EventRecorderMorph class >> readFrom: aStream [
	^ self new readFrom: aStream
]

{ #category : #'fileIn\/Out' }
EventRecorderMorph class >> services [

	^{SimpleServiceEntry 
			provider: self 
			label: 'open for playback'
			selector: #openTapeFromFile:.}

]

{ #category : #'initialize-release' }
EventRecorderMorph class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #initialization }
EventRecorderMorph >> addButtons [
	| r b w |

	caption ifNotNil: ["Special setup for play-only interface"
		(r := self makeARowForButtons)
			addMorphBack: (SimpleButtonMorph new target: self;
	 							label: caption font: Preferences standardButtonFont; actionSelector: #play);
			addMorphBack: self makeASpacer.
		w := r fullBounds height * 0.5.
		r addMorphBack: (self makeStatusLightIn: (w@w));
			addMorphBack: self makeASpacer.
		^ self addMorphBack: r
	].

	(r := self makeARowForButtons)
		addMorphBack: (b := self buttonFor: {#record. nil. 'Begin recording'});
		addMorphBack: self makeASpacer;
		addMorphBack: (self buttonFor: {#stop. b width. 'Stop recording - you can also use the ESC key to stop it'});
		addMorphBack: self makeASpacer;
		addMorphBack: (self buttonFor: {#play. b width. 'Play current recording'}).
	self addMorphBack: r.

	(r := self makeARowForButtons)
		addMorphBack: (b := self buttonFor: {#writeTape. nil. 'Save current recording on disk'});
		addMorphBack: self makeASpacer;
		addMorphBack: (self buttonFor: {#readTape. b width. 'Get a new recording from disk'}).
	self addMorphBack: r.

	(r := self makeARowForButtons)
		addMorphBack: (b := self buttonFor: {#shrink. nil. 'Make recording shorter by removing unneeded events'});
		addMorphBack: self makeASpacer.
	w := r fullBounds height * 0.5.
	r addMorphBack: (self makeStatusLightIn: (w@w));
		addMorphBack: self makeASpacer;
		addMorphBack: (self buttonFor: {#createPlayButton. b width. 'Make a simple button to play this recording'}).
	self addMorph: r.
	self setStatusLight: #ready.
]

{ #category : #initialization }
EventRecorderMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'add voice controls' translated action: #addVoiceControls.
	aCustomMenu add: 'add journal file' translated action: #addJournalFile.

]

{ #category : #initialization }
EventRecorderMorph >> addJournalFile [
	"In case there is a chance of not regaining control to stop recording and save a file, the EventRecorder can write directly to file as it is recording.  This is useful for capturing a sequence that results in a nasty crash."

	journalFile ifNotNil: [journalFile close].
	journalFile := FileStream newFileNamed: 'EventRecorder.tape'.
	journalFile nextPutAll:'Event Tape v1 ASCII'; cr.
]

{ #category : #'sound-piano rolls' }
EventRecorderMorph >> addMorphsTo: morphList pianoRoll: pianoRoll eventTime: t betweenTime: leftTime and: rightTime [

	| startX myDurationInTicks endX |

	startX := pianoRoll xForTime: t.
	myDurationInTicks := pianoRoll scorePlayer ticksForMSecs: self myDurationInMS.
	t > rightTime ifTrue: [^ self].  
	(t + myDurationInTicks) < leftTime ifTrue: [^ self].
	endX := pianoRoll xForTime: t + myDurationInTicks.

	morphList add: 
		(self hResizing: #spaceFill; left: startX; width: endX - startX).


]

{ #category : #sound }
EventRecorderMorph >> addVoiceControls [ 

	| levelSlider r meterBox |
	voiceRecorder := SoundRecorder new
		desiredSampleRate: 11025.0;		"<==try real hard to get the low rate"
		codec: (GSMCodec new).		"<--this should compress better than ADPCM.. is it too slow?"
		"codec: (ADPCMCodec new initializeForBitsPerSample: 4 samplesPerFrame: 0)."

	levelSlider := SimpleSliderMorph new
		color: color;
		extent: 100@2;
		target: voiceRecorder;
		actionSelector: #recordLevel:;
		adjustToValue: voiceRecorder recordLevel.
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

	meterBox := Morph new extent: 102@18; color: Color gray.
	recordMeter := Morph new extent: 1@16; color: Color yellow.
	recordMeter position: meterBox topLeft + (1@1).
	meterBox addMorph: recordMeter.

	r := AlignmentMorph newRow vResizing: #shrinkWrap.
	r addMorphBack: meterBox.
	self addMorphBack: r.

]

{ #category : #commands }
EventRecorderMorph >> button [
	"Make a simple button interface for replay only"
	| butnCaption erm |
	butnCaption := UIManager default request: 'Caption for this butn?' translated initialAnswer: 'play' translated.
	butnCaption isEmpty ifTrue: [^ self].
	erm := (EventRecorderMorph basicNew
				caption: butnCaption
				voiceRecorder: voiceRecorder copy
				tape: tape) initialize.
	self world primaryHand attachMorph: erm
]

{ #category : #accessing }
EventRecorderMorph >> button: label [ 
	^ self allMorphs
		detect: [:one | (one isKindOf: SimpleButtonMorph)
				and: [one label = label]]
		ifNone: []
]

{ #category : #initialization }
EventRecorderMorph >> buttonFor: data [ 

	| b |
	b := SimpleButtonMorph new 
		target: self;
		label: data first asString translated;
		actionSelector: data first.
	data second ifNotNil: [b width < data second ifTrue: [b width: data second]].
	data third ifNotNil: [b setBalloonText: data third translated].
	^b
]

{ #category : #initialization }
EventRecorderMorph >> caption: butnCaption voiceRecorder: butnRecorder tape: butnTape [
	caption := butnCaption.
	voiceRecorder := butnRecorder.
	tape := butnTape
]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> checkTape [
	"See if this tape was already converted to the new format"

	tape ifNil: [^self].
	tape isEmpty ifTrue: [^self].
	(tape first isKindOf: Association) 
		ifTrue: [tape := self convertV0Tape: tape]
]

{ #category : #commands }
EventRecorderMorph >> condense [
	"Shorten the tape by deleting mouseMove events that can just as well be
	interpolated later at playback time."

	"e1, e2, and e3 are three consecutive events on the tape.
	t1, t2, and t3 are the associated time steps for each of them."

	
	tape := Array streamContents: 
					[:tStream | | e1 t1 t2 e2 t3 e3 | 
					e1 := e2 := e3 := nil.
					t1 := t2 := t3 := nil.
					1 to: tape size
						do: 
							[:i | 
							e1 := e2.
							t1 := t2.
							e2 := e3.
							t2 := t3.
							e3 := tape at: i.
							t3 := e3 timeStamp.
							((e1 notNil and: 
									[e2 type == #mouseMove 
										& (e1 type == #mouseMove or: [e3 type == #mouseMove])]) 
								and: 
									["Middle point within 3 pixels of mean of outer two"

									e2 position 
										onLineFrom: e1 position
										to: e3 position
										within: 2.5]) 
									ifTrue: 
										["Delete middle mouse move event.  Absorb its time into e3"

										e2 := e1.
										t2 := t1]
									ifFalse: [e1 ifNotNil: [tStream nextPut: (e1 copy setTimeStamp: t1)]]].
					e2 ifNotNil: [tStream nextPut: (e2 copy setTimeStamp: t2)].
					e3 ifNotNil: [tStream nextPut: (e3 copy setTimeStamp: t3)]]
]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> convertV0Tape: anArray [
	"Convert the tape into the new format"
	| lastKey |
	lastKey := 0.
	^anArray collect:[:assn| | evt | 
		evt := assn value.
		evt setTimeStamp: (lastKey := lastKey + assn key).
		evt]
]

{ #category : #initialization }
EventRecorderMorph >> defaultBorderColor [
	^ Color transparent
]

{ #category : #initialization }
EventRecorderMorph >> defaultBorderStyle [
	^ BorderStyle raised
]

{ #category : #initialization }
EventRecorderMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 2
]

{ #category : #initialization }
EventRecorderMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color red
]

{ #category : #'sound-piano rolls' }
EventRecorderMorph >> encounteredAtTime: ticks inScorePlayer: scorePlayer atIndex: index inEventTrack: track secsPerTick: secsPerTick [

	self play.
]

{ #category : #'events-processing' }
EventRecorderMorph >> handleListenEvent: anEvent [
	"Record the given event"
	anEvent hand == recHand ifFalse: [^ self].	"not for me"
	state == #record ifFalse: [
		"If user got an error while recording and deleted recorder, will still be listening"
		recHand ifNotNil: [recHand removeEventListener: self].
		^self].
	anEvent = lastEvent ifTrue: [^ self].
	(anEvent isKeyboard and:[anEvent keyValue = 27 "esc"])
		ifTrue: [^ self stop].
	time := anEvent timeStamp.
	tapeStream nextPut: (anEvent copy setHand: nil).
	journalFile ifNotNil:
		[journalFile store: anEvent; cr; flush].
	lastEvent := anEvent.
]

{ #category : #initialization }
EventRecorderMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	saved := true.
	self listDirection: #topToBottom;
		 wrapCentering: #center;
		 cellPositioning: #topCenter;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 layoutInset: 2;
		 minCellSize: 4;
		 addButtons
]

{ #category : #'sound-piano rolls' }
EventRecorderMorph >> justDroppedIntoPianoRoll: newOwner event: evt [
	
	| startX lengthInTicks endX startTimeInScore endTimeInScore |

	super justDroppedIntoPianoRoll: newOwner event: evt.

	startTimeInScore := newOwner timeForX: self left.
	lengthInTicks := newOwner scorePlayer ticksForMSecs: self myDurationInMS.
	endTimeInScore := startTimeInScore + lengthInTicks.

	endTimeInScore > newOwner scorePlayer durationInTicks ifTrue:
		[newOwner scorePlayer updateDuration].

	startX := newOwner xForTime: startTimeInScore.
	endX := newOwner xForTime: endTimeInScore.
	self width: endX - startX.

]

{ #category : #initialization }
EventRecorderMorph >> makeARowForButtons [

	^AlignmentMorph newRow
		vResizing: #shrinkWrap;
		wrapCentering: #center;
		cellPositioning: #leftCenter;
		minCellSize: 4;
		color: Color blue
]

{ #category : #initialization }
EventRecorderMorph >> makeASpacer [

	^AlignmentMorph newSpacer: Color transparent
]

{ #category : #initialization }
EventRecorderMorph >> makeStatusLight [

	^statusLight := EllipseMorph new 
		extent: 11 @ 11;
		color: Color green;
		borderWidth: 0
]

{ #category : #'sound-piano rolls' }
EventRecorderMorph >> myDurationInMS [

	^tape isEmptyOrNil ifTrue: [
		10
	] ifFalse: [
		tape last timeStamp - tape first timeStamp
	]

]

{ #category : #'event handling' }
EventRecorderMorph >> nextEventToPlay [
	"Return the next event when it is time to be replayed.
	If it is not yet time, then return an interpolated mouseMove.
	Return nil if nothing has happened.
	Return an EOF event if there are no more events to be played."
	| nextEvent now nextTime lastP delta |
	(tapeStream isNil or:[tapeStream atEnd]) 
		ifTrue:[^MorphicUnknownEvent new setType: #EOF argument: nil].
	now := Time millisecondClockValue.
	nextEvent := tapeStream next.
	"nextEvent isKeyboard ifTrue: [ nextEvent setPosition: self position ]."
	deltaTime ifNil:[deltaTime := now - nextEvent timeStamp].
	nextTime := nextEvent timeStamp + deltaTime.
	now < time ifTrue:["clock rollover"
		time := now.
		deltaTime := nil.
		^nil "continue it on next cycle"].
	time := now.
	(now >= nextTime) ifTrue:[
		nextEvent := nextEvent copy setTimeStamp: nextTime.
		nextEvent isMouse ifTrue:[lastEvent := nextEvent] ifFalse:[lastEvent := nil].
		^nextEvent].
	tapeStream skip: -1.
	"Not time for the next event yet, but interpolate the mouse.
	This allows tapes to be compressed when velocity is fairly constant."
	lastEvent ifNil: [^ nil].
	lastP := lastEvent position.
	delta := (nextEvent position - lastP) * (now - lastEvent timeStamp) // (nextTime - lastEvent timeStamp).
	delta = lastDelta ifTrue: [^ nil]. "No movement"
	lastDelta := delta.
	^MouseMoveEvent new
		setType: #mouseMove 
		startPoint: lastEvent position endPoint: lastP + delta
		trail: #() buttons: lastEvent buttons hand: nil stamp: now.
]

{ #category : #'pause\/resume' }
EventRecorderMorph >> pauseIn: aWorld [
	"Suspend playing or recording, either as part of a stop command,
	or as part of a project switch, after which it will be resumed."

	self setStatusLight: #ready.
	state = #play ifTrue:
		[state := #suspendedPlay.
		playHand halo ifNotNil: [playHand halo delete].
		playHand delete.
		aWorld removeHand: playHand.
		aWorld firstHand showHardwareCursor: true.
		playHand := nil].
	state = #record ifTrue:
		[state := #suspendedRecord.
		recHand removeEventListener: self.
		recHand := nil].

	voiceRecorder ifNotNil:
		[voiceRecorder pause.
		startSoundEvent ifNotNil:
			[startSoundEvent argument: voiceRecorder recordedSound.
			voiceRecorder clearRecordedSound.
			startSoundEvent := nil]].

]

{ #category : #commands }
EventRecorderMorph >> play [

	self isInWorld ifFalse: [^ self].
	self stop.
	tape ifNil: [^ self].
	tapeStream := ReadStream on: tape.
	self resumePlayIn: self world.
	self setStatusLight: #nowPlaying.


]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> readFrom: aStream [
	"Private"
	| header |
	header := aStream nextLine.
	(header = 'Event Tape v1 BINARY') ifTrue:[^aStream fileInObjectAndCode].
	(header = 'Event Tape v1 ASCII') ifTrue:[^self readFromV1: aStream].
	"V0 had no header so guess"
	aStream reset.
	header first isDigit ifFalse:[^self convertV0Tape: (aStream fileInObjectAndCode)].
	^self convertV0Tape: (self readFromV0: aStream).

]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> readFromV0: aStream [
	^Array streamContents:[:tStream | | evt line t lineStream |
		[aStream atEnd] whileFalse:
			[line := aStream nextLine.
			line isEmpty "Some MW tapes have an empty record at the end"
				ifFalse: [lineStream := ReadStream on: line.
						t := Integer readFrom: lineStream.
						[lineStream peek isLetter] whileFalse: [lineStream next].
						evt := MorphicEvent readFromObsolete: lineStream.
						tStream nextPut: t -> evt]]].
]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> readFromV1: aStream [
	^Array streamContents:[:tStream |
		[aStream atEnd] whileFalse:[
			tStream nextPut: (MorphicEvent readFromString: aStream nextLine)]]
]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> readTape [
	^ self readTape: (UIManager default
							request: 'Tape to read' translated
							initialAnswer: 'tapeName.tape').
]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> readTape: fileName [ 
	| file |
	self writeCheck.
	(FileStream isAFileNamed: fileName) ifFalse: [^ nil].
	file := FileStream oldFileNamed: fileName.
	tape := self readFrom: file.
	file close.
	saved := true  "Still exists on file"
]

{ #category : #commands }
EventRecorderMorph >> record [

	self isInWorld ifFalse: [^ self].
	self stop.
	self writeCheck.
	self addJournalFile.
	tapeStream := WriteStream on: (Array new: 10000).
	self resumeRecordIn: self world.
	self setStatusLight: #nowRecording.

]

{ #category : #'pause\/resume' }
EventRecorderMorph >> resumeIn: aWorld [
	"Resume playing or recording after a project switch."

	self state = #suspendedPlay ifTrue:
		[self resumePlayIn: aWorld].
	self state = #suspendedRecord ifTrue:
		[self resumeRecordIn: aWorld].

]

{ #category : #'pause\/resume' }
EventRecorderMorph >> resumePlayIn: aWorld [

	playHand := HandMorphForReplay new recorder: self.
	playHand position: tapeStream peek position.
	aWorld addHand: playHand.
	playHand newKeyboardFocus: aWorld.
	playHand userInitials: 'play' andPicture: nil.

	lastEvent := nil.
	lastDelta := 0@0.
	state := #play.

	self synchronize.

]

{ #category : #'pause\/resume' }
EventRecorderMorph >> resumeRecordIn: aWorld [

	recHand := aWorld activeHand ifNil: [aWorld primaryHand].
	recHand newKeyboardFocus: aWorld.
	recHand addEventListener: self.

	lastEvent := nil.
	state := #record.

	voiceRecorder ifNotNil:
		[voiceRecorder clearRecordedSound.
		voiceRecorder resumeRecording.
		startSoundEvent := MorphicUnknownEvent new setType: #startSound argument: nil hand: nil stamp: Time millisecondClockValue.
		tapeStream nextPut: startSoundEvent].

	self synchronize.

]

{ #category : #commands }
EventRecorderMorph >> setStatusLight: aSymbol [

	aSymbol == #ready ifTrue: [
		statusLight color: Color green.
		tape ifNil: [
			statusLight setBalloonText: 'Ready to record'.
		] ifNotNil: [
			statusLight setBalloonText: 'Ready to record or play'.
		].
		^self
	].
	aSymbol == #nowRecording ifTrue: [
		statusLight 
			color: Color red;
			setBalloonText: 'Recording is active'.
		^self
	].
	aSymbol == #nowPlaying ifTrue: [
		statusLight 
			color: Color yellow;
			setBalloonText: 'Now playing'.
		^self
	].

]

{ #category : #commands }
EventRecorderMorph >> shrink [
	"Shorten the tape by deleting mouseMove events that can just as well be
	interpolated later at playback time."

	| oldSize priorSize |
	self writeCheck.
	oldSize := priorSize := tape size.
	[self condense.  tape size < priorSize] whileTrue: [priorSize := tape size].
	self inform: ('{1} events reduced to {2}' translated format:{oldSize. tape size}).
	voiceRecorder ifNotNil: [voiceRecorder suppressSilence].
	saved := false.

]

{ #category : #'stepping and presenter' }
EventRecorderMorph >> step [

	(state == #record and: [voiceRecorder notNil]) ifTrue: [
		recordMeter width: (voiceRecorder meterLevel + 1).
	].

]

{ #category : #'stepping and presenter' }
EventRecorderMorph >> stepTime [

	^500

]

{ #category : #'stepping and presenter' }
EventRecorderMorph >> stop [

	state = #record ifTrue:
		[tape := tapeStream contents.
		saved := false].
	journalFile ifNotNil:
		[journalFile close].
	self pauseIn: self world.
	tapeStream := nil.
	state := nil.
	self setStatusLight: #ready.
	recordMeter ifNotNil: [recordMeter width: 1].

	self checkTape.
]

{ #category : #'event handling' }
EventRecorderMorph >> synchronize [

	time := Time millisecondClockValue.
	deltaTime := nil.
]

{ #category : #'stepping and presenter' }
EventRecorderMorph >> wantsSteps [

	^true

]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> writeCheck [
	(saved not and: [self confirm: 'The current tape has not been saved.
Would you like to do so now?']) ifTrue:
		[self writeTape].

]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> writeFileNamed: fileName [
	| file noVoice delta |
	file := FileStream newFileNamed: fileName.
	noVoice := true.
	tape do:[:evt | evt type = #startSound ifTrue: [noVoice := false]].
	noVoice
		ifTrue: ["Simple format (reads fast) for no voice"
				file nextPutAll:'Event Tape v1 ASCII'; cr.
				delta := tape first timeStamp.
				tape do: [:evt | file store: (evt copy setTimeStamp: evt timeStamp-delta); cr].
				file close]
		ifFalse: ["Inclusion of voice events requires general object storage"
				file nextPutAll:'Event Tape v1 BINARY'; cr.
				file fileOutClass: nil andObject: tape].
	saved := true.
	^ file name
]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> writeTape [
	| args b fileName |
	args := (b := self button: 'writeTape') isNil
				ifTrue: [#()]
				ifFalse: [b arguments].
	(args notEmpty
			and: [args first notEmpty])
		ifTrue: [args first.
			self writeTape: args first]
		ifFalse: [fileName := UIManager default saveFilenameRequest: 'Tape to write' initialAnswer: 'tapeName.tape'.
			fileName ifNil: [^ self].
			^ self writeTape: fileName]
]

{ #category : #'fileIn\/Out' }
EventRecorderMorph >> writeTape: fileName [ 
	| name bb |
	name := self writeFileNamed: fileName.
	bb := self findDeepSubmorphThat: [:mm | (mm isKindOf: SimpleButtonMorph)
				and: [mm label = 'writeTape']] 
			ifAbsent: [^ self].
	bb actionSelector: #writeTape:.
	bb arguments: (Array with: name).

]
