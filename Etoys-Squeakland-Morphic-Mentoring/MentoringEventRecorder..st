"
A custom subclass of the EventRecorderMorph used within the olpc mentoring system.  The event theatre's ""state"" constitutes the state for the MentoringEventRecorder itself as well.  These are not the same states that are used by the vanilla EventRcorderMorph superclass.

The states are:

readyToRecord				No recording ever made

rewound						After a rewind.   Not recording, not playing
atEndOfPlayback				After a playback  Not recording, not playing

recordingWithSound			Currently making primary recording, with sound
recording						Currenty making primary recoring, sans sound

playback						Amid playback
playbackAddingVoiceover	Recording a voiceover while while playing back

suspendedPlayback			User hit Pause while doing playback


"
Class {
	#name : #MentoringEventRecorder,
	#superclass : #EventRecorderMorph,
	#instVars : [
		'recordingSpace',
		'startPlaybackTime',
		'millisecondsIntoPlayback',
		'areaOffset',
		'areaBounds',
		'lastInterpolation'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #services }
MentoringEventRecorder class >> durationInMillisecondsOfTape: anArray [
	"Answer the total duration in milliseconds of the event tape represnted by the array."

	| baseline totalDuration |
	totalDuration := 0.
	baseline := anArray first timeStamp.
	anArray do:
		[:anEvent |
			anEvent type = #noCondense  ifFalse:  "exclude the noCondense weirdos because their timestamps can be bogus"
				[totalDuration := anEvent timeStamp + anEvent durationInMilliseconds - baseline]].
	^ totalDuration
	
]

{ #category : #initialization }
MentoringEventRecorder >> addButtons [
	"Add buttons to the receiver.  For the mentoring case, the buttons are actually  managed by the EventRecordingSpace."

	self makeStatusLight
]

{ #category : #initialization }
MentoringEventRecorder >> addJournalFile [
	"In case there is a chance of not regaining control to stop recording and save a file, the EventRecorder can write directly to file as it is recording.  This is useful for capturing a sequence that results in a nasty crash."

	journalFile ifNotNil: [journalFile close].
	journalFile := FileStream newFileNamed: (FileDirectory default nextNameFor: 'EventRecorder' extension: 'tape').
	journalFile nextPutAll:'Event Tape v1 ASCII'; cr.
]

{ #category : #sound }
MentoringEventRecorder >> addVoiceControls [ 
	"Add voice capabililty by allocating a sound recorder."

	voiceRecorder := SoundRecorder new
		desiredSampleRate: 11025.0;		"<==try real hard to get the low rate"
		codec: (GSMCodec new).		"<--this should compress better than ADPCM.. is it too slow?"
		"codec: (ADPCMCodec new initializeForBitsPerSample: 4 samplesPerFrame: 0)."

	recordMeter := Morph new extent: 1@16; color: Color yellow.

]

{ #category : #sound }
MentoringEventRecorder >> assuredVoiceRecorder [
	"Answer my voiceRecorder, allocating a new one if necessary."

	^ voiceRecorder ifNil: 
		[self addVoiceControls.
		voiceRecorder]
]

{ #category : #accessing }
MentoringEventRecorder >> caption [
	"Answer the caption, a string... initialize it to a default value if it is not yet defined."

	^ caption ifNil: [caption := 'Untitled' translated]
]

{ #category : #commands }
MentoringEventRecorder >> caption: aCaption [
	"Set the receiver's caption."

	caption := aCaption
]

{ #category : #'event handling' }
MentoringEventRecorder >> currentEventTimeStamp: aStamp [
	"Make a note of the current event time stamp, for the benefit of piano rolls tracking my playback."

	millisecondsIntoPlayback := aStamp - startPlaybackTime
]

{ #category : #menu }
MentoringEventRecorder >> deleteVoiceControls [
	"Stop using voice controls"

	voiceRecorder := nil
]

{ #category : #'fileIn\/Out' }
MentoringEventRecorder >> fileNameForTape [
	"Answer a file name to use for the event tape"

	^ FileDirectory default nextNameFor: 'EventRecorder' extension: 'tape'
]

{ #category : #commands }
MentoringEventRecorder >> findPlayOffset [
	"Compute the difference between my content area and the one in which the events I will play back were recorded."

	areaOffset := recordingSpace areaOffset
]

{ #category : #commands }
MentoringEventRecorder >> handleEscape [
	"The user hit esc to stop recording or playback, so stop."

	| interimTape unmatchedMouseDown upEvent |
	tapeStream ifNotNil:
		[(#(recording recordingWithSound) includes: self state ) ifTrue:
			[interimTape := tapeStream contents.
			unmatchedMouseDown := nil.
			interimTape reversed detect:
				[:evt |
					evt eventType = #mouseDown
						ifTrue:
							[unmatchedMouseDown := evt.
							true]
						ifFalse:
							[evt eventType = #mouseUp]]
				ifNone:
					[nil].
			unmatchedMouseDown ifNotNil:
				["synthesize a matching up-event"
				upEvent := unmatchedMouseDown veryDeepCopy.
				upEvent timeStamp: Time millisecondClockValue.
				upEvent setType: #mouseUp.
				tapeStream nextPut: upEvent].

			tape := tapeStream contents.
			saved := false]].

	self pauseIn: self world.
	tapeStream := nil.
	recordMeter ifNotNil: [recordMeter width: 1].

	recordingSpace escapeHitInEventRecorder
]

{ #category : #'events-processing' }
MentoringEventRecorder >> handleListenEvent: anEvent [
	"Process a listen event."

	anEvent hand == recHand ifFalse: [^ self].	"not for me"
	(#(recording recordingWithSound) includes: self state)  ifFalse: 
		["If user got an error while recording and deleted recorder, will still be listening"
		recHand ifNotNil: [recHand removeEventListener: self].
		^ self].
	anEvent timeStamp: Time millisecondClockValue. "Workaround a bug in Windows VM"
	anEvent = lastEvent ifTrue: [^ self].
	(anEvent isKeyboard and: [anEvent keyValue = 27 "esc"])
		ifTrue: [^ self handleEscape].
	time := anEvent timeStamp.
	tapeStream ifNotNil:
		[tapeStream nextPut: (anEvent copy setHand: nil)].
	lastEvent := anEvent
]

{ #category : #initialization }
MentoringEventRecorder >> initialize [
	"Initialize the receiver."

	super initialize.
	startPlaybackTime := 0.
	millisecondsIntoPlayback := 0.
	self assuredVoiceRecorder
]

{ #category : #'event handling' }
MentoringEventRecorder >> mergeMediaEvent: anEvent [
	"Merge the event, presently time-stamped with a relative time-stamp., with my existing tape.  Answer the merged tape.  It is the responsibility of the sender to notify other objects that may be interested in the change, such as an event roll."

	| itsTimeStamp eventFollowingIt newTape anIndex itsCopy copysTimeStamp |
	itsTimeStamp :=  anEvent timeStamp.
	itsCopy := anEvent copy.
	itsCopy timeStamp: (copysTimeStamp := itsTimeStamp + tape first timeStamp).

	eventFollowingIt := tape detect: [:evt | evt timeStamp > copysTimeStamp]  ifNone: [nil].
	anIndex := eventFollowingIt
		ifNil:
			[tape size + 1]
		ifNotNil:
			[tape indexOf: eventFollowingIt].

	newTape := Array streamContents:
		[:aStream | 
			tape doWithIndex:
				[:evt :index |
					index = anIndex ifTrue:
						[aStream nextPut: itsCopy].
					aStream nextPut: evt].
			anIndex > tape size ifTrue: [aStream nextPut: itsCopy]].

	tape := newTape
]

{ #category : #accessing }
MentoringEventRecorder >> millisecondsIntoPlayback [
	"Answer the value of millisecondsIntoPlayback"

	^ self state = #atEndOfPlayback
		ifTrue:
			[self myDurationInMS + (tape last duration)]
		ifFalse:
			[millisecondsIntoPlayback]
]

{ #category : #accessing }
MentoringEventRecorder >> millisecondsIntoPlayback: anObject [
	"Set the value of millisecondsIntoPlayback"

	millisecondsIntoPlayback := anObject
]

{ #category : #'event handling' }
MentoringEventRecorder >> nextEventToPlay [
	"Return the next event when it is time to be replayed.
	If it is not yet time, then return an interpolated mouseMove.
	Return nil if nothing has happened.
	Return an EOF event if there are no more events to be played."

	| nextEvent now nextTime lastP delta |
	(tapeStream isNil or:[tapeStream atEnd]) 
		ifTrue:[^MorphicUnknownEvent new setType: #EOF argument: nil].
	now := Time millisecondClockValue.
	nextEvent := tapeStream next shallowCopy.	"always copied"
	areaOffset ifNotNil: [nextEvent isMouse ifTrue: 
		[nextEvent position: nextEvent position + areaOffset]]. 
	nextEvent isKeyboard ifTrue: [ nextEvent setPosition: areaBounds center].
	nextEvent type == #noCondense ifTrue: [^nil].	"ignore in playback"
	deltaTime ifNil:[deltaTime := now - nextEvent timeStamp].
	nextTime := nextEvent timeStamp + deltaTime.
	now < time ifTrue:["clock rollover"
		time := now.
		deltaTime := nil.
		^nil "continue it on next cycle"].
	time := now.
	(now >= nextTime) ifTrue:[
		nextEvent setTimeStamp: nextTime.
		nextEvent isMouse ifTrue:[lastEvent := nextEvent] ifFalse:[lastEvent := nil].
		^nextEvent].
	tapeStream skip: -1.
	"Not time for the next event yet, but interpolate the mouse.
	This allows tapes to be compressed when velocity is fairly constant."
	lastEvent ifNil: [^ nil].
	now - lastInterpolation < 20 "WorldState minCycleLapse" ifTrue: [^ nil].
	lastP := lastEvent position.
	delta := (nextEvent position - lastP) * (now - lastEvent timeStamp) // (nextTime - lastEvent timeStamp).
	(delta dist: lastDelta) < 3 ifTrue: [^ nil]. "Almost no movement"
	lastDelta := delta.
	lastInterpolation := now.
	^ MouseMoveEvent new
		setType: #mouseMove 
		startPoint: lastEvent position endPoint: lastP + delta
		trail: nil buttons: lastEvent buttons hand: nil stamp: now.
]

{ #category : #commands }
MentoringEventRecorder >> noteAreaBounds [
	"Note the bounds of the content area"

	areaBounds := recordingSpace contentArea bounds
	
]

{ #category : #commands }
MentoringEventRecorder >> noteRewound [
	"Note that the user has done a 'rewind'"

	self state: nil.
	millisecondsIntoPlayback := 0
]

{ #category : #'event handling' }
MentoringEventRecorder >> objectTrackingEvents [
	"Answer an object tracking events or pseudo-event.  This is a hook allowing the EventRecordingSpace to keep track of cursor position to provide to event rolls."

	^ self
]

{ #category : #'pause\/resume' }
MentoringEventRecorder >> pauseIn: aWorld [
	"Suspend -- a stop command, typically because an EOF event was found on the event tape being played."

	(#(recordingWithSound playbackAddingVoiceover) includes: self state) ifTrue:
		[self terminateVoiceRecording.
		self state: #atEndOfPlayback.
		recHand ifNotNil: [recHand removeEventListener: self].
		recHand := nil.].

	(#(playback) includes: self state) ifTrue:
		[self state: #suspendedPlay.
		playHand ifNotNil:
			[playHand halo ifNotNil: [playHand halo delete].
			playHand delete].
		aWorld removeHand: playHand.
		self removeProperty: #suspendedContentArea.
		playHand := nil.
		recordingSpace playingEnded.
		aWorld firstHand showHardwareCursor: true]
	
]

{ #category : #commands }
MentoringEventRecorder >> pausePlayback [
	"The user requested pause in mid-playback.  Preserve the salient information required for a proper resume when and if the user subsquently presses 'resume'"

	self state: #suspendedPlayback.
	recordMeter ifNotNil: [recordMeter width: 1].
	playHand suspended: true

]

{ #category : #'event handling' }
MentoringEventRecorder >> perhapsPlaySound: aSound [
	"Perhaps play given sound.  But, if busy creating a voiceover, do not.  And if the sound is nil, being a dummy placeholder, likewise don't atempt to play it."

	aSound ifNotNil: 
		[(self state = #playbackAddingVoiceover) ifFalse:
			[aSound play]]
]

{ #category : #commands }
MentoringEventRecorder >> play [
	"Play the movie, as it were."

	tape ifNil: [^ self].
	tapeStream := ReadStream on: tape.
	self resumePlayIn: self currentWorld.

]

{ #category : #'fileIn\/Out' }
MentoringEventRecorder >> readTape [
	"Put up a prompt for reading an event tape; if one is provided, read it."

	| fileName |
	fileName := UIManager default chooseFileMatchingSuffixes: #('tape' ) .
	fileName ifNotNil: [self readTapeFrom: (FileStream fileNamed: fileName)]
]

{ #category : #'fileIn\/Out' }
MentoringEventRecorder >> readTape: fileName [ 
	"Read an event tape from the given file-name.  Answer nil if no such file."

	| file |
	(fileName = '') ifTrue: [^ nil]. 
 "Note that for some reason, (FileStream isAFileNamed: '') always returns true."

	self writeCheck.
	(FileStream isAFileNamed: fileName) ifFalse: [^ nil].
	file := FileStream oldFileNamed: fileName.
	tape := self readFrom: file.
	file close.
	saved := true  "Still exists on file"
]

{ #category : #'fileIn\/Out' }
MentoringEventRecorder >> readTapeFrom: aFileStream [
	"Read in the tape from the fileStream provided."

	tape := self readFrom: aFileStream.
	aFileStream close.
	saved := true  "Still exists on file"
]

{ #category : #commands }
MentoringEventRecorder >> record [
	"Commence recording or re-recording."

	tapeStream := WriteStream on: (Array new: 10000).
	self resumeRecordIn: self currentWorld.

]

{ #category : #sound }
MentoringEventRecorder >> recordMeter [
	"Hand back the actual recordMeter object."

	^ recordMeter
]

{ #category : #accessing }
MentoringEventRecorder >> recordingSpace: anObject [
	"Set the value of recordingSpace"

	recordingSpace := anObject
]

{ #category : #commands }
MentoringEventRecorder >> rememberPaintBoxSettingsAtRecordingOutset [
	"Recording is about to take place.  Remember settings if appropriate."

	recordingSpace rememberPaintBoxSettingsAtRecordingOutset
]

{ #category : #'pause\/resume' }
MentoringEventRecorder >> resumePlayIn: aWorld [
	"Playback" 

	| anEvent aPosition |
	recordingSpace abandonReplayHandsAndHalos.
	self flag: #deferred.  "I guess it's the above line that messes up the nesting of these guys..."

	self state: #playback.
	recordingSpace populateControlsPanel.
	aWorld doOneCycle.

	playHand := HandMorphForReplay new recorder: self.
	[((anEvent := tapeStream next) notNil and: [(anEvent isKindOf: UserInputEvent) not])]
		whileTrue: [].
	aPosition := anEvent
		ifNil:
			[recordingSpace contentArea center]
		ifNotNil:
			[anEvent position].
	tapeStream reset.
	playHand position: aPosition + recordingSpace areaOffset.
	aWorld addHand: playHand.
	playHand newKeyboardFocus: aWorld.
	playHand userInitials: '' andPicture: nil.

	lastEvent := nil.
	lastDelta := 0@0.
	startPlaybackTime := Time millisecondClockValue.
	millisecondsIntoPlayback := 0.
	self findPlayOffset.

	self synchronize

]

{ #category : #commands }
MentoringEventRecorder >> resumePlayingWithoutPassingStop [
	"Like play, but avoids the stop step that does more than we'd like."

	tapeStream := ReadStream on: tape.
	self resumePlayIn: self currentWorld.

]

{ #category : #'pause\/resume' }
MentoringEventRecorder >> resumeRecordIn: aWorld [
	"Start recording, actually."

	| anEvent |
	recHand := aWorld activeHand ifNil: [aWorld primaryHand].
	recHand newKeyboardFocus: aWorld.
	recHand addEventListener: self.

	lastEvent := nil.
	self state:  #recording.

	anEvent := MorphicUnknownEvent new setType: #noteTheatreBounds argument: recordingSpace  initialContentArea bounds copy hand: nil stamp: Time millisecondClockValue.
	tapeStream nextPut: anEvent.

	self synchronize.

]

{ #category : #commands }
MentoringEventRecorder >> rewind [
	"Carry out a rewind."

	recordingSpace abandonReplayHandsAndHalos.
	recordingSpace restoreInitialContentArea
]

{ #category : #accessing }
MentoringEventRecorder >> saved [
	"Answer whether the current recording has been saved."

	^ saved
]

{ #category : #accessing }
MentoringEventRecorder >> saved: aBoolean [
	"Set the #saved inst var as indicated, with no side effects."

	saved := aBoolean
]

{ #category : #commands }
MentoringEventRecorder >> shrink [
	"Shorten the tape by deleting mouseMove events that can just as well be
	interpolated later at playback time."

	tape ifNil: [^ Beeper beep].
	^ super shrink
]

{ #category : #'pause\/resume' }
MentoringEventRecorder >> startRecordingNewSound [
	"Commence the recording of a new sound by way of voiceover."

	startSoundEvent := MediaPlayEvent new setType: #startSound argument: nil hand: nil stamp: (Time millisecondClockValue - startPlaybackTime).
	self state = #recordingWithSound
		ifTrue:
			[tapeStream nextPut: startSoundEvent].
	"If not, then we're recording after-the-fact voiceover; in this case, we hold on to the new event and later on when the sound is complete we merge the event into the tape stream at the appropriate place."

	voiceRecorder clearRecordedSound.
	voiceRecorder resumeRecording
]

{ #category : #accessing }
MentoringEventRecorder >> startSoundEvent: anEvent [ 
	"Set the receiver's startSoundEvent"

	startSoundEvent := anEvent
]

{ #category : #commands }
MentoringEventRecorder >> state [
	"Answer the receiver's state."

	^ recordingSpace ifNotNil: [recordingSpace state]
]

{ #category : #accessing }
MentoringEventRecorder >> state: aState [ 
	"Set the receiver's state."

	recordingSpace
		ifNotNil:
			 [recordingSpace state: aState]
]

{ #category : #'stepping and presenter' }
MentoringEventRecorder >> step [
	"Step the event recorder."
	
	(#(recordingWithSound playbackAddingVoiceover) includes: self state)
		ifTrue:
			[recordMeter width: (voiceRecorder meterLevel + 1)]
]

{ #category : #commands }
MentoringEventRecorder >> stop [
	"Stop recording or playing."

	tapeStream ifNotNil:
		[(#(recording recordingWithSound) includes: self state) ifTrue:
			[tape := tapeStream contents.
			saved := false]].
	self terminateVoiceRecording.  "In case doing"
	journalFile ifNotNil:
		[journalFile close].
	self pauseIn: self currentWorld.
	tapeStream := nil.
	self state: #atEndOfPlayback.
	recordingSpace abandonReplayHandsAndHalos.
	recordMeter ifNotNil: [recordMeter width: 1].
]

{ #category : #commands }
MentoringEventRecorder >> stopRecording [
	"The user hit the 'stop recording' button."

	self stop
]

{ #category : #'event handling' }
MentoringEventRecorder >> synchronize [

	super synchronize.
	lastInterpolation := time.
]

{ #category : #accessing }
MentoringEventRecorder >> tape [
	"Answer the current tape"

	^ tape
]

{ #category : #'pause\/resume' }
MentoringEventRecorder >> terminateVoiceRecording [
	"If I am doing voice recording,either alongside event recording or alongside event playback, stop doing it."

	| snippetsList |
	(#(recordingWithSound playbackAddingVoiceover) includes: self state)
		ifTrue:
			[voiceRecorder pause.
			startSoundEvent argument: voiceRecorder recordedSound.
			voiceRecorder clearRecordedSound.
			self state = #playbackAddingVoiceover ifTrue:
				[snippetsList := self valueOfProperty: #snippetsList ifAbsentPut: OrderedCollection new.
				snippetsList add: startSoundEvent.
				startSoundEvent := nil]]
]

{ #category : #'pause\/resume' }
MentoringEventRecorder >> userStopReplayMaybe: anEvent [
	"If the user clicks or types a keystroke within the interior during replay, return true so we can stop the replay."

	(#(playback playbackAddingVoiceover) includes: self state)  ifFalse: [^ false].
	(anEvent hand isKindOf: HandMorphForReplay) ifTrue: [^ false].	"ignore own events"
	(anEvent isKeyboard or: [anEvent isMouse and: [anEvent anyButtonPressed]]) 
			ifFalse: [^ false]. "mouse move"
	"got a click or keystroke"
	(anEvent isMouse and: [recordingSpace controlsPanel bounds containsPoint: anEvent position])
		ifTrue: [^ false]. 
	^ true
]

{ #category : #accessing }
MentoringEventRecorder >> voiceRecorder [
	"Answer the receiver's voiceRecorder."

	^ voiceRecorder
]

{ #category : #initialization }
MentoringEventRecorder >> voiceRecorder: v [
	"Set the voiceRecorder"

	voiceRecorder := v
]

{ #category : #'fileIn\/Out' }
MentoringEventRecorder >> writeCheck [
	"Well, for now we just don't..."

"
	(saved not and: [self confirm: 'The current tape has not been saved.
Would you like to do so now?']) ifTrue:
		[self writeTape]."

]

{ #category : #'fileIn\/Out' }
MentoringEventRecorder >> writeTape [
	"Write the tape."

	| args bb aFileName |
	bb := self findDeepSubmorphThat: [:mm | (mm isKindOf: SimpleButtonMorph)
				and: [mm label = 'writeTape']] 
			ifAbsent: [nil].
	args := bb ifNil: [#()] ifNotNil: [bb arguments].
	(args notEmpty and: [args first notEmpty]) 
		ifTrue: 
			[args first.
			self writeTape: args first]
		ifFalse: 
			[aFileName := self fileNameForTape.
			self writeTape: aFileName].
]
