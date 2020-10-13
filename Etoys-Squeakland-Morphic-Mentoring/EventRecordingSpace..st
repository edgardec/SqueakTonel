"
Externally called the Event Theatre, this is a tool for authoring event-recorded sequences with possible voiceover.  Event ""tapes"" created with an Event Theatre can be edited using the Event Roll.

Values for the ""state"" instance variable, which characterizes the combined state of an Event-Theatre + MentoringEventRecorder complex:

readyToRecord				No recording ever made

rewound						Recording exists; not actively doing anything, and recently rewound.
atEndOfPlayback				Recording exists; not actively doing anything; played since last rewind.

recordingWithSound			Currently making primary recording, with sound
recording						Currently making primary recording, sans sound

playback
playbackAddingVoiceover	Currently running playback while recording a voiceover for a portion of it

suspendedPlayback			In the midst of playback, user hit the Pause button
"
Class {
	#name : #EventRecordingSpace,
	#superclass : #AlignmentMorph,
	#instVars : [
		'contentArea',
		'controlsPanel',
		'soundPanel',
		'publishButton',
		'abandonButton',
		'menuButton',
		'recordButton',
		'recordAgainButton',
		'recordVoiceoverButton',
		'stopRecordingVoiceoverButton',
		'scriptButton',
		'playButton',
		'rewindButton',
		'stopButton',
		'pauseButton',
		'resumeButton',
		'captionMorph',
		'showingSoundButton',
		'eventRecorder',
		'state',
		'initialContentArea',
		'balloonHelpString',
		'initialPicture',
		'finalPicture',
		'showingSoundPanel',
		'eventRoll',
		'priorVersions'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #'instance creation' }
EventRecordingSpace class >> defaultNameStemForInstances [
	"Answer the default name stem for new instances of this class"

	^ 'Event Theatre' translatedNoop
]

{ #category : #'parts bin' }
EventRecordingSpace class >> descriptionForPartsBin [
	"Answer a description for use in a parts bin."

	^ self partName:	'Event Theatre' translatedNoop
		categories:		{'Multimedia' translatedNoop}
		documentation:	'A framework for creating tutorial snippets' translatedNoop
]

{ #category : #'instance creation' }
EventRecordingSpace class >> open [
	"Open up a new instance of the receiver."

	| anInst |
	anInst := self new.
	anInst visible: false.
	anInst openInWorldOrWorldlet.
	anInst initializeFlaps. "after placing anInst in its world"
	anInst center:  anInst owner center.
	anInst show
	

"
EventRecordingSpace open.
"
]

{ #category : #'instance creation' }
EventRecordingSpace class >> openCentered [
	"Open up a new instance of the receiver, centered "

	| anInst |
	anInst := self new.
	anInst visible: false.
	anInst openInWorldOrWorldlet.
	anInst center:  anInst owner center.
	anInst show.
	"anInst putUpHelpFlap"
"
EventRecordingSpace open.
"
]

{ #category : #'instance creation' }
EventRecordingSpace class >> openFromPlaybackButton: aButton [
	"Open an EventRecordingSpace derived from a playback button.  The primary reason for doing this would be to re-record voiceover."

	| aSpace |
	aSpace := EventRecordingSpace new.
	aSpace initializeFromPlaybackButton: aButton.
	aSpace center: self currentWorld center.
	aSpace openInWorld
]

{ #category : #commands }
EventRecordingSpace >> abandon [
	"Abandon the entire exercise."

	(state ~= #readyToRecord and: [eventRecorder saved not]) ifTrue:
		[(PopUpMenu confirm:
'The current recording has not been saved, and will be
lost if you do this; are you sure you want to proceed?' translated trueChoice: 'yes, abandon this Event Theatre' translated falseChoice: 'no, let me reconsider' translated) ifFalse: [^ self]].

	eventRoll ifNotNil: [eventRoll delete].
	eventRoll := nil.
	self topRendererOrSelf delete.
	self abandonReplayHandsAndHalos
]

{ #category : #commands }
EventRecordingSpace >> abandonReplayHandsAndHalos [
	"Cleanup after playback."

	self currentWorld abandonReplayHandsAndHalosFor: eventRecorder
]

{ #category : #'event roll' }
EventRecordingSpace >> acceptNewTape: aTape [
	"Accept the given tape as the new one for this event-theatre.  This comes from editing the event-tape using the EventRoll."

	eventRecorder tape: aTape.
	self rememberCurrentRecording

]

{ #category : #processing }
EventRecordingSpace >> addControlWithSpacer: aControl [
	"Add the control, followed by a variable transparent spacer, to my controls panel."

	controlsPanel addMorphBack: aControl.
	controlsPanel  addVariableTransparentSpacer
]

{ #category : #menu }
EventRecordingSpace >> addMenuButtonItemsTo: aMenu [
	"Build the contents of the menu to be presented when the menu button in my tool-bar is clicked."

	"CAUTION:  Debugging items still present."

	aMenu addTitle: 'Recording Options' translated.

	aMenu addTranslatedList: #(
		('set balloon help'		setBalloonHelp  'Allows you to provide a message to be presented to a user as balloon-help when the mouse lingers over buttons that trigger playback of the tape of this event theatre')
		('shrink event tape' shrinkTape)
		"('save on file...' saveSequenceOnFile)"
		-
		('revert to version...'	offerVersions)
		('delete old versions'	deleteOldVersions)
		-) translatedNoop.

	SugarNavigatorBar showSugarNavigator
		ifTrue:
			[aMenu addTranslatedList: (self sugarNavigatorFlapOrNil
				ifNil: [#(('add sugar navigator flap' addSugarNavigatorFlap)) translatedNoop]
				ifNotNil: [#(('remove sugar navigatorFlap' removeSugarNavigatorFlap)) translatedNoop])]
		ifFalse:
			[aMenu addTranslatedList: (self navigatorFlapOrNil
				ifNil: [#(('add navigator flap' addNavigatorFlap)) translatedNoop]
				ifNotNil: [#(('remove navigatorFlap' removeNavigatorFlap)) translatedNoop]).

			aMenu addTranslatedList: (self suppliesFlapOrNil
				ifNil: [#(('add supplies flap' addSuppliesFlap)) translatedNoop]
				ifNotNil: [#(('remove suppliesFlap' removeSuppliesFlap)) translatedNoop])].

	aMenu addTranslatedList: #(
		-
		('event roll' makeHorizontalRoll 'open a horizontal piano-roll-like tool for the viewing and editing the events of this event theatre.')
		('remove event-roll' removeEventRoll  'abandon any event-roll that may be associated with this theatre.')
		-) translatedNoop.

	Preferences debugging ifTrue:
		[self addMoreSubMenuTo: aMenu]
]

{ #category : #menu }
EventRecordingSpace >> addMoreSubMenuTo: aMenu [
	"Add the 'more...' submenu to a menu."

	| submenu |
	submenu := MenuMorph new defaultTarget: self.
	submenu addTitle: 'More options' translated.

	submenu addTranslatedList: #(
		('inspect event theatre' inspect)
		('inspect event recorder' inspectEventRecorder)
		('inspect sound recorder' inspectSoundRecorder)
		('inspect event tape' inspectEventTape)
		('inspect event roll' inspectEventRoll)
		('inspect nav bar' inspectNavBar)
		-
		('parse event tape' parseEventTape)
		('convert to canonical coordinates (broken)' convertToCanonicalForm)
		('movie-clip player'  addMovieClipPlayer)) translatedNoop.

	aMenu add: 'more...' translated subMenu: submenu
]

{ #category : #flaps }
EventRecordingSpace >> addNavigatorFlap [
	"Add a navigator flap if there is none."

	| existing aFlap navBar aFlapTab |
	existing := contentArea submorphs detect: [:aMorph | (aMorph isKindOf: FlapTab) and: [aMorph flapID = 'Navigator']] ifNone: [nil].
	existing ifNotNil: [^ self].  "already present"

	navBar := EventRecordingSpaceNavigator new.
	aFlap := PasteUpMorph newSticky borderWidth: 0;
			extent: navBar extent + (0@20);
			color: (Color orange alpha: 0.8);
			beFlap: true;
			addMorph: navBar beSticky.
	aFlap hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	aFlap useRoundedCorners.
	aFlap setNameTo: 'Navigator' translated.
	navBar fullBounds.  "to establish width"
	
	aFlapTab := InteriorFlapTab new referent: aFlap.
	aFlapTab setName: 'Navigator' translated edge: #bottom color: Color orange.

	aFlapTab setBalloonText: aFlapTab balloonTextForFlapsMenu.
	aFlap borderWidth: 0.
	contentArea addMorphFront: aFlapTab.
	aFlapTab position: (contentArea bottomLeft + (0 @ -24)).
	aFlapTab referent left: (aFlapTab center x - (aFlapTab referent width//2) max: 0).
	contentArea installFlaps

]

{ #category : #flaps }
EventRecordingSpace >> addSugarNavigatorFlap [
	"If the content area does not have a sugar-navigator flap, give it one."

	| existing aBar |
	existing := contentArea submorphs detect: [:aMorph | aMorph isKindOf: InteriorSugarNavBar] ifNone: [nil].
	existing ifNotNil: [^ self].  "already present"

	aBar := InteriorSugarNavBar new.
	contentArea addMorphFront: aBar.
	aBar position: contentArea position.
	aBar finishInitialization.
	contentArea installFlaps


]

{ #category : #flaps }
EventRecordingSpace >> addSuppliesFlap [
	"If the content area does not have a Supplies flap, give it one."

	| existing aFlap actualFlap |
	existing := contentArea submorphs detect: [:aMorph | (aMorph isKindOf: FlapTab) and: [aMorph flapID = 'Supplies']] ifNone: [nil].
	existing ifNotNil: [^ self].  "already present"

	aFlap := Flaps newSuppliesFlapFromQuads: Flaps quadsDefiningPlugInSuppliesFlap positioning: #right.
	contentArea addMorphFront: (actualFlap := aFlap as: InteriorFlapTab).
	actualFlap setToPopOutOnDragOver: true.
	actualFlap edgeToAdhereTo: #bottom.
	actualFlap right: contentArea right.
	contentArea installFlaps


]

{ #category : #processing }
EventRecordingSpace >> addToSoundPanelWithSpacer: aControl [
	"Add the control, followed by a variable transparent spacer, to my sound panel."

	soundPanel addMorphBack: aControl.
	soundPanel  addVariableTransparentSpacer
]

{ #category : #commands }
EventRecordingSpace >> addVoiceControls [
	"Add  voice controls to the receiver."

	eventRecorder addVoiceControls


]

{ #category : #processing }
EventRecordingSpace >> allNonSubmorphMorphs [
	"Answer a list of morphs within me that are not submorphs."

	^ {eventRecorder}
]

{ #category : #processing }
EventRecordingSpace >> areaOffset [
	"Answer the difference between my content area and the one in which the events I will play back were recorded."

	^ self contentArea bounds origin -  self contentAreaBoundsWhenRecorded origin 
]

{ #category : #processing }
EventRecordingSpace >> assureContentAreaStaysAt: aPoint [
	"selbst-verst‚Äö√†√∂¬¨√ündlich"

	self currentWorld doOneCycleNow.
	self topLeft: ((self topLeft - contentArea topLeft ) + aPoint)
]

{ #category : #menu }
EventRecordingSpace >> assureUsingVoice [
	"If not using voice controls, start using them."

	eventRecorder voiceRecorder
		ifNil:
			[eventRecorder addVoiceControls.
			self populateControlsPanel]
]

{ #category : #accessing }
EventRecordingSpace >> balloonHelpString [
	"Answer the value of balloonHelpString"

	^ balloonHelpString
]

{ #category : #accessing }
EventRecordingSpace >> balloonHelpString: anObject [
	"Set the value of balloonHelpString"

	balloonHelpString := anObject
]

{ #category : #initialization }
EventRecordingSpace >> buttonWithLabel: aLabel actionSelector: aSelector balloonText: helpText [
	"Answer a button with the receiver as target, and with the given label, selector, and help text."

	| aButton |
	aButton := SimpleButtonMorph new label: aLabel translated font: (StrikeFont familyName: 'Accujen' size: 18).
	aButton color: Color blue veryMuchLighter.
	aButton target: self.
	aButton actWhen: #buttonUp.
	aButton actionSelector: aSelector.
	helpText ifNotNil: [aButton setBalloonText: helpText translated].
	^ aButton

]

{ #category : #access }
EventRecordingSpace >> captionString [
	"Answer the current caption string"

	^ eventRecorder ifNil: ['Untitled'] ifNotNil: [eventRecorder caption]
]

{ #category : #access }
EventRecordingSpace >> captionString: aString [
	"Set my eventRecorder's captionString."

	eventRecorder caption: aString
]

{ #category : #access }
EventRecordingSpace >> contentArea [
	"Answer the contentArea"

	^ contentArea
]

{ #category : #processing }
EventRecordingSpace >> contentAreaBoundsWhenRecorded [
	"Answer the bounds of the content area at the time the recording was made."

	^ initialContentArea
		ifNil: 
			[contentArea bounds]
		ifNotNil:
			[initialContentArea bounds]
]

{ #category : #access }
EventRecordingSpace >> controlsPanel [
	"Answer the controls panel."

	^ controlsPanel
]

{ #category : #processing }
EventRecordingSpace >> convertToCanonicalForm [
	"In the canonical form, a content area origined at (0, 0) is established, and all event time-stamps are shifted such that 0 is the start of the tape."

	| delta baseline |
	self confirm: 'Caution: this is broken!' translated orCancel: [^ self].

	delta := contentArea topLeft negated.
	baseline := eventRecorder tape first timeStamp.
	eventRecorder tape:
		(eventRecorder tape collect:
			[:anEvent |
				anEvent timeStamp: (anEvent timeStamp - baseline).
				((anEvent isKindOf: MorphicUnknownEvent) and:
						[anEvent type = #noteTheatreBounds]) ifTrue:
					[anEvent argument: (0@0 extent: contentArea extent)].
				anEvent translateBy: delta]).
	initialContentArea position: 0@0
]

{ #category : #halo }
EventRecordingSpace >> defersHaloToInterior [
	"Answer whether  when a halo-click goes down over some subobject within me, I should defer to it rather than seize the halo myself."

	^ true
]

{ #category : #halo }
EventRecordingSpace >> defersHaloToInteriorMorph: aMorph [
	"Answer whether  when a halo-click goes down over some subobject within me, I should defer to it rather than seize the halo myself."

	^ true
]

{ #category : #processing }
EventRecordingSpace >> deleteOldVersions [
	"Delete past versions remembered."

	priorVersions := nil.
	state ~= #readiyToRecord ifTrue: [self rememberCurrentRecording]
]

{ #category : #commands }
EventRecordingSpace >> dismantlePaintBoxArtifacts [
	"Cleanup after playback -- if a paint-box has been left up, take it down."

	(self currentWorld findA: SketchEditorMorph) ifNotNil: [:skEd |
		skEd cancelOutOfPainting].
]

{ #category : #menu }
EventRecordingSpace >> editMenuButtonDefinition [
	"For debugging and development only!  Open up a single-method browser on the method that defines the main menu of the receiver."

	| mr |
	mr := MethodReference new setStandardClass: self class methodSymbol: #addMenuButtonItemsTo:.
	self systemNavigation browseMessageList: {mr} name: 'Event Theatre menu Definition' translated autoSelect: nil
]

{ #category : #processing }
EventRecordingSpace >> encouragesHaloTransferToEnclosedPasteUpMorph [
	"Answer true, because a cmd-click on a submorph of a PasteUpMorph which itself is a submorph of mine should get the halo first."

	^ true
]

{ #category : #processing }
EventRecordingSpace >> escapeHitInEventRecorder [
	"The user hit escape in the event recorder, to stop the recording..."

	self state = #recording ifTrue: [^ self stopRecording].

	self state = #playbackAddingVoiceover ifTrue:
		[eventRecorder terminateVoiceRecording]. 

	self state: #atEndOfPlayback.
	self populateControlsPanel.
	self borderColor: self color
]

{ #category : #access }
EventRecordingSpace >> eventRecorder [
	"Answer the receiver's eventRecorder."

	^ eventRecorder
]

{ #category : #accessing }
EventRecordingSpace >> finalPicture [
	"Answer the value of finalPicture"

	^ finalPicture ifNil: [finalPicture := contentArea imageForm]
]

{ #category : #commands }
EventRecordingSpace >> forgetPriorPaintBoxSettings [
	"Remove prior memory of paint box brush size and color from the initialContentArea"

	initialContentArea removeProperty: #paintBoxBrushSymbol.
	initialContentArea removeProperty: #paintBoxCurrentColor
]

{ #category : #'events-processing' }
EventRecordingSpace >> handlesMouseDown: anEvent [
	"Watch for user clicking during playback"

	(#(playback playbackAddingVoiceover) includes: state) ifFalse: [^ false].

	^ (anEvent hand ~~ eventRecorder playHand "true for a real outside event") and:
		[contentArea bounds containsPoint: anEvent position]
]

{ #category : #access }
EventRecordingSpace >> helpString [
	"Answer a help string for the Event Theatre."

	^ 'The Event Theatre provides a framework for authoring "event-movies".  It uses custom variants of the Navigator, the Supplies flap, the painting system, property sheets, Viewer flaps, etc., all of which reside within the controlled confines of the Theatre.

To author an event-movie, get a  new Event Theatre from the Objects catalog or from the "open..." branch of the desktop menu.

1. Resize the Theatre, using the halo, to the delivery size desired for playback.

2. Use the menu in the controls panel to add or delete Supplies and Navigator flaps as desired.

3. Edit the "caption" by clicking on the text that says "Untitled" and typing your desired caption.  This caption is affixed to playback buttons, and, generally, provides a way to identify the event-movie.

4. Set up the "initial conditions" for the event-movie you''re about to record (e.g., paint a background, provide some explanatory text, add objects you want to be present at the start of the movie.) When the recording is first opened by the user for playback, and whenever the recording has been rewound, this is exactly what it will look like.

5. When ready to start the recording, press the "Record" button. A red border will be seen around the recorder, to indicate that recording is in progress.  Recording will continue until you hit the ESC key.

6. Note that if you  want to include sound in your recording, you can add it directly during playback, or you can produce voiceover externally and add it in later using the Event Roll.

7. Now proceed to "do", with the mouse and keyboard, whatever you wish to record.   For best results, all mouse gestures should be made within the interior of the Theatre.

8. Hit ESC when done recording.

9. To review what you''ve recorded, press "Play". If unhappy with the result, repeat steps 1-8.

10.  If you''re happy with the result, and now wish to add a sound, open the sound panel, then click Play to replay the recording, and whenever you wish to add a snippet of voiceover, click on the "Start Recording Voiceover" button, and start talking, and when done with that snippet click the "Stop Recording Voiceover" button.  Once the playback finishes, the added voiceover(s) will become part of the event tape, and will be seen in the event roll.

11. When you''re happy with the result, hit the "Publish" button, to get a playback button. There are currently two choices:

a. Iconic Button - Initially provides a picture of the initial scene of the movie, scaled 0.3x, and overlaid with the word HINT.  When the user clicks on such a button, the event-movie is played back in an ephemeral "playback theatre", and after the playback is done, the playback theatre shrinks down to a 0.5x scale-downed picture of the *final* scene of the movie.  Subsequent hitting of the button will again invoke a playback.

b. Textual Button - a simple labeled button which, when pressed, triggers playback of the event tape.

12. The playback buttons you obtain when you "Publish" can be placed anywhere, such as on the page of a book. You can control, via a playback-button''s halo menu, whether or not it should be "auto-start", and whether or not "auto-dismiss". When the user presses the button, a "Playback" space will open, which resembles an Event Theatre, but has only playback-relevant controls.   A playback set up for both auto-start and auto-dismiss comes without any controls.

13.  To edit the "event tape" of a recording you have made in an Event Theatre, and for a generally good time, click on the interlocking-circles icon to obtain a tool that allows you to visualize and to edit a "score" or "piano roll" of the event tape.


Summary of terms

Event Theatre
  The main tool for creating an Event Tape.

Event Roll
  An auxiliary tool showing the full "score" of an Event Tape. 

Event Tape
  The results of an event-theatre session;  an interaction sequence that can be played back.

Event Recording
  A term interchangeable with "Event Tape."

Event Movie
  What you see when you play back an Event Tape.

' translated
]

{ #category : #processing }
EventRecordingSpace >> initialContentArea [
	"Answer the initialContentArea, with the intent of copying it."

	^ initialContentArea
]

{ #category : #accessing }
EventRecordingSpace >> initialPicture [
	"Answer the value of initialPicture"

	^ initialPicture
]

{ #category : #initialization }
EventRecordingSpace >> initialize [
	"Initialize the receiver to be a complete mentoring space"

	super initialize.

	eventRecorder := MentoringEventRecorder new.
	eventRecorder recordingSpace: self.
	self beSticky.
	self listDirection: #topToBottom; hResizing: #shrinkWrap; vResizing: #shrinkWrap.
	self extent: 1@1.
	self borderWidth: 2; borderColor: Color gray.
	self useRoundedCorners.
	showingSoundPanel := false.

	(contentArea := Worldlet new)
		setNameTo: 'tutorial';
		color: Color white;
		setProperty: #automaticPhraseExpansion toValue: true;
		beSticky.

	self addMorphBack: contentArea.

	controlsPanel := AlignmentMorph newRow.
	controlsPanel hResizing: #spaceFill.
	controlsPanel listCentering: #center. 
	controlsPanel listSpacing: #equal.
	controlsPanel cellInset: 4.
	controlsPanel minHeight: 32.
	self addMorphBack: controlsPanel.

	soundPanel := AlignmentMorph newRow.
	soundPanel hResizing: #spaceFill.
	soundPanel listCentering: #center. 
	soundPanel listSpacing: #equal.
	soundPanel cellInset: 4.
	soundPanel minHeight: 32.
	soundPanel color:  (Color r: 1.0 g: 0.839 b: 0.645).

	self makeStatusButtons.
	
	state := #readyToRecord.
	self populateControlsPanel.

	"initializeFlaps will be called later, after opening in world"


]

{ #category : #initialization }
EventRecordingSpace >> initializeFlaps [

	SugarNavigatorBar showSugarNavigator
		ifTrue:
			[self addSugarNavigatorFlap]
		ifFalse:
			[self addSuppliesFlap.
			self addNavigatorFlap]
]

{ #category : #initialization }
EventRecordingSpace >> initializeFromPlaybackButton: anEventPlaybackButton [
	"Initialize my content area, caption, and tape from a playback button."

	| soundEvent |
	initialContentArea := anEventPlaybackButton contentArea veryDeepCopy.
	eventRecorder tape: anEventPlaybackButton tape veryDeepCopy.
	eventRecorder caption: anEventPlaybackButton  caption.
	soundEvent := eventRecorder tape  detect: [:evt | evt 
type = #startSound] ifNone: [nil].
	soundEvent ifNotNil:  "For benefit of possible re-record of voiceover"
		[eventRecorder startSoundEvent: soundEvent].
	initialPicture := anEventPlaybackButton initialPicture veryDeepCopy ifNil:
		[self inform: 'caution - old playback; button lacks vital data.' translated.
		^ nil].
	finalPicture := anEventPlaybackButton finalPicture veryDeepCopy.
	eventRecorder saved: true.

	self rewind.
	self center: self currentWorld center.
]

{ #category : #commands }
EventRecordingSpace >> inspectEventRecorder [
	"Inspect the event recorder."

	eventRecorder inspect
]

{ #category : #debugging }
EventRecordingSpace >> inspectEventRoll [
	"Inspect the receiver's eventRoll"

	eventRoll ifNotNil: [eventRoll inspectWithLabel: 'Event Roll for ' translated, self captionString] ifNil: [Beeper beep]
]

{ #category : #debugging }
EventRecordingSpace >> inspectEventTape [
	"If there is an existing event tape, inspect it."

	eventRecorder tape ifNotNil:
		[eventRecorder tape inspectWithLabel: 'Event tape for ', self captionString]
]

{ #category : #'sugar flaps' }
EventRecordingSpace >> inspectNavBar [
	"Debugging -- inspect a nav-bar if I have one."

	| bar |
	bar := self contentArea submorphs detect: [:m | m isKindOf: ProjectNavigationMorph] ifNone: [nil].
	bar ifNotNil: [bar inspect]
]

{ #category : #commands }
EventRecordingSpace >> inspectSoundRecorder [
	"Inspect the sound recorder."

	eventRecorder voiceRecorder inspect
]

{ #category : #commands }
EventRecordingSpace >> installPaintBoxSettingsPrevailingAtRecordingTime [
	"Install  settings for the PaintBox assumed by the recording, in preparation for playback.  But first save the existing values  for these settings, so that after playback the pre-existing state could be restored, though in current design we decide not to do that last."

	self setProperty: #incomingPaintBoxBrushSymbol toValue: PaintBoxMorph prototype currentBrushSymbol.
	self setProperty: #incomingPaintBoxCurrentColor toValue: PaintBoxMorph prototype getColor.

	(contentArea valueOfProperty: #paintBoxBrushSymbol) ifNotNil:
		[:sym |
			PaintBoxMorph prototype brush: sym].

	(contentArea valueOfProperty: #paintBoxCurrentColor) ifNotNil:
		[:aColor |
			PaintBoxMorph prototype currentColor: aColor]
]

{ #category : #'events-processing' }
EventRecordingSpace >> invokeHaloOrMove: anEvent [

	(eventRecorder userStopReplayMaybe: anEvent) ifTrue: [^ self stopPlayback]. 
	super invokeHaloOrMove: anEvent.

]

{ #category : #initialization }
EventRecordingSpace >> justTornOffFromPartsBin [
	"A notification that the receiver was just torn off from a supplies flap, objects catalogue, or other parts factory; intercept this message to put up a help flap, for example."

	"self putUpHelpFlap"
]

{ #category : #commands }
EventRecordingSpace >> makeHorizontalRoll [
	"Create a horizontal roll viewer for this recording space"

	state = #readyToRecord ifTrue: [
		^ self inform: 'Nothing recorded yet' translated].
	
	"self convertToCanonicalForm." "Would prefer to do this but there are still issues."
	
	eventRoll ifNil: [
		eventRoll := EventRollMorph new.
		eventRoll eventTheatre: self].
	
	eventRoll formulate.
	
	eventRoll isInWorld
		ifFalse: [eventRoll
				openInWorld;
				setExtentFromHalo: (self currentWorld width - 10) @ eventRoll height;
				top: self bottom;
				bottom: (eventRoll bottom min: self currentWorld bottom);
				left: self currentWorld left + 2] "presumably zero"
		ifTrue: [eventRoll comeToFront].
]

{ #category : #initialization }
EventRecordingSpace >> makeStatusButtons [
	"Build, but do not insert, the buttons that control"

	publishButton := self buttonWithLabel: 'Publish' actionSelector: #publishButtonHit balloonText: 'When you hit this, you will be handed a button which, when it is clicked, will open up an Event Player in which the recording can be played back.' translated.

	abandonButton := self tanOButton.
	abandonButton actionSelector: #abandon.
	abandonButton  setBalloonText: 'Abandon this effort and throw away this window' translated.

	recordButton := self buttonWithLabel: 'Record' translated actionSelector: #record balloonText: 'Start Recording' translated.

	menuButton := self menuButton.
	"self buttonWithLabel: 'Options' translated actionSelector: #offerMenu balloonText: 'Offers a menu of options'."

	scriptButton :=  IconicButton new target: self;
		borderWidth: 0;
		labelGraphic: (ScriptingSystem formAtKey: #Script);
		color: Color transparent; 
		actWhen: #buttonUp;
		actionSelector: #makeHorizontalRoll;
		setBalloonText: 'show this theatre''s script in a piano-roll-like format for visualizaitoin and editing.' translated;
		yourself.

	recordAgainButton := self buttonWithLabel: 'Record Again' translated actionSelector: #recordAgain balloonText: 'Abandon existing recording and start a new one.' translated.

	recordVoiceoverButton := self buttonWithLabel: 'Start Recording Voiceover' translated actionSelector: #recordVoiceover balloonText: 'Add a voiceover to the existing event-recorded sequence ' translated.

	stopRecordingVoiceoverButton := self buttonWithLabel: 'Stop Record Voiceover' translated actionSelector: #stopRecordingVoiceover balloonText: nil  " 'Stop the recording of the voiceover segment currently being recorded' translated ".

	playButton := self buttonWithLabel: 'Play' translated actionSelector: #play balloonText: 'Replay this sequence' translated.

	rewindButton := self buttonWithLabel: 'Rewind' translated actionSelector: #rewind balloonText: 'Reset to the starting condition for this recording' translated.

	stopButton := self buttonWithLabel: 'Stop' translated actionSelector: #stopPlayback balloonText: 'Stop playing or recording this panel' translated.

	pauseButton := self buttonWithLabel: 'Pause' translated actionSelector: #pausePlayback balloonText: 'Temporarily pause this playback' translated.

	resumeButton := self buttonWithLabel: 'Resume' translated actionSelector: #resumePlayback balloonText: 'Resume playback' translated.

	captionMorph := UpdatingStringMorph contents: self captionString font: ScriptingSystem fontForTiles.
	captionMorph useStringFormat.
	captionMorph target: self.
	captionMorph getSelector: #captionString; putSelector: #captionString:; growable: true; minimumWidth: 48.

	showingSoundButton := UpdatingThreePhaseButtonMorph blackTriangularOpener.
	showingSoundButton
		target: self;
		actionSelector: #toggleShowingSoundPanel;
		getSelector: #notShowingSoundPanel.
	showingSoundButton setBalloonText: 'show/hide voice controls' translated




]

{ #category : #'events-processing' }
EventRecordingSpace >> mouseDown: evt [
	
	(eventRecorder userStopReplayMaybe: evt) ifTrue: [self stopPlayback]. 
	^ super mouseDown: evt.
	
]

{ #category : #'events-processing' }
EventRecordingSpace >> mouseDownPriority [
	"High so we can stop playback, but we do not mark it as handled, so others can run too."

	^ (#(playback playbackAddingVoiceover) includes: state)
		ifTrue:
			[110]
		ifFalse:
			[0]
]

{ #category : #flaps }
EventRecordingSpace >> navigatorFlapOrNil [
	"If the receiver has an existing navigator flap, answer it, else answer nil"

	^ contentArea submorphs detect: [:aMorph | (aMorph isKindOf: FlapTab) and: [aMorph flapID = 'Navigator']] ifNone: [nil]
]

{ #category : #accessing }
EventRecordingSpace >> notShowingSoundPanel [
	"Answer the opposite of the value of showingSoundPanel"

	^ showingSoundPanel not
]

{ #category : #menu }
EventRecordingSpace >> offerMenu [
	"A menu button was hit.  Offer a menu of options for the receiver."

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	self addMenuButtonItemsTo: aMenu.
	aMenu popUpInWorld
]

{ #category : #menu }
EventRecordingSpace >> offerVersions [
	"Offer the user the opportunity to revert to a prior version of a recorded event tape."

	| aList aMenu |
	aList := self priorVersions collect: [:v | v first].
	aList ifEmpty: [^ self inform:  'no versions available, sorry' translated].
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'Choose a version to restore' translated.
	aList do:
		[:el | aMenu add: el printString selector: #restoreVersionStamped: argument: el].
	aMenu popUpInWorld
]

{ #category : #processing }
EventRecordingSpace >> openTextualPlaybackButton [
	"Open a textual playback button that will play the receiver."

	| aButton |
	aButton := PlaybackInvoker new initializeFrom: self.
	aButton showString: self captionString.
	self  publishPlaybackButton: aButton
]

{ #category : #processing }
EventRecordingSpace >> openUnhintedPlaybackButton [
	"Open a playback button without the HINT overlay."

	self publishPlaybackButton:  (PlaybackInvoker new initializeFrom: self)
]

{ #category : #debugging }
EventRecordingSpace >> parseEventTape [
	"Parse the event tape; open an Inspector on the derivative tape."

	| aParser parserClass |
	eventRecorder tape ifNil: [^ self inform: 'nothing recorded yet' translated].
	
	parserClass := Smalltalk at: #EventTapeParser ifAbsent: [^ Beeper beep].
	aParser := parserClass new eventTape: eventRecorder tape.
	aParser parseTape.
	aParser newTape inspectWithLabel: 'Parsed Tape - ', Time now printString
]

{ #category : #commands }
EventRecordingSpace >> pausePlayback [
	 "Pause the playback.  Sender responsible for setting state to #suspendedPlayback"

	eventRecorder pausePlayback.
	(self currentWorld findA: SketchEditorMorph) ifNotNil:
		[:skEd | skEd cancelOutOfPainting.
		^ self rewind].
	self borderColor: Color orange.
	self setProperty: #suspendedContentArea toValue: contentArea veryDeepCopy.
	self populateControlsPanel
]

{ #category : #processing }
EventRecordingSpace >> play [
	"Play the tape once."

	eventRecorder ifNotNil:
		[self comeToFront.
		self restoreInitialContentArea.
		self installPaintBoxSettingsPrevailingAtRecordingTime.
		self abandonReplayHandsAndHalos.
		self state: #playback.
		eventRecorder play]

	
]

{ #category : #processing }
EventRecordingSpace >> playingEnded [
	"The playback reached the end."

	| snippetsList |
	self state: #atEndOfPlayback.
	snippetsList := eventRecorder valueOfProperty: #snippetsList.
	snippetsList isEmptyOrNil ifFalse:
		[snippetsList do:
			[:soundEvent |
				eventRecorder mergeMediaEvent: soundEvent].
		self pushEventTapeToEventRoll ].
	eventRecorder removeProperty: #snippetsList.

	self populateControlsPanel.
	self borderColor: self color.
	self abandonReplayHandsAndHalos.
	self removeProperty: #suspendedContentArea.
	self refreshRoll.
	self removeAlarm: #offerTickingMenu:  "in case timing unlucky."

]

{ #category : #processing }
EventRecordingSpace >> populateControlsPanel [
	"Build the things that need to be in the controls panel."

	| neverRecorded aMorph existing |
	scriptButton ifNil: [self makeStatusButtons].

	existing := contentArea topLeft.
	controlsPanel removeAllMorphs.
	soundPanel removeAllMorphs.
	soundPanel addVariableTransparentSpacer.
	self populateSoundPanel.

	(#(recording recordingWithSound) includes: self state) ifTrue:
		[controlsPanel  addVariableTransparentSpacer.
		 aMorph := StringMorph contents: 'Hit ESC to stop recording' translated font: (StrikeFont familyName:  'Accujen' size: 24).
		self addControlWithSpacer: aMorph.
		^ self assureContentAreaStaysAt:  existing].

	(#(playback playbackAddingVoiceover) includes: self state) ifTrue:
		[self addControlWithSpacer: captionMorph lock.
		self addControlWithSpacer:  pauseButton.
		self addControlWithSpacer: stopButton.
		 ^ self assureContentAreaStaysAt: existing].

	controlsPanel  addTransparentSpacerOfSize: 6@0.
	controlsPanel addMorphBack: abandonButton.
	controlsPanel addTransparentSpacerOfSize: 12@0.
	controlsPanel addMorphBack: self helpButton.
	controlsPanel addTransparentSpacerOfSize: 12@0.
	controlsPanel addMorphBack: menuButton.

	controlsPanel  addVariableTransparentSpacer.
	neverRecorded := state = #readyToRecord.
	neverRecorded ifFalse:
		[self addControlWithSpacer: publishButton.
		self addControlWithSpacer: scriptButton].

	self addControlWithSpacer: captionMorph unlock.

	neverRecorded
		ifTrue:
			[self addControlWithSpacer: recordButton]
		ifFalse:
			[self addControlWithSpacer: recordAgainButton].


	state = #playback ifTrue: [self addControlWithSpacer: stopButton].
	state == #suspendedPlayback ifTrue:
		[self addControlWithSpacer: resumeButton].

	neverRecorded ifFalse: [self addControlWithSpacer: rewindButton].

	(#(rewound atEndOfPlayback) includes: self state) ifTrue:
		[self addControlWithSpacer: playButton].
	controlsPanel addVariableTransparentSpacer.
	controlsPanel addMorphBack: showingSoundButton.
	controlsPanel addTransparentSpacerOfSize: 6@0.
	self assureContentAreaStaysAt:  existing

]

{ #category : #processing }
EventRecordingSpace >> populateSoundPanel [
	"Like de selector say."

	| rec levelSlider meterBox voiceControls sliderWrapper |
	(#( playbackAddingVoiceover) includes: self state) ifTrue:
		[self  addToSoundPanelWithSpacer: stopRecordingVoiceoverButton].

	(#(playback) includes: self state) ifTrue:
		[self addToSoundPanelWithSpacer: recordVoiceoverButton].

	rec := eventRecorder assuredVoiceRecorder.
	voiceControls := AlignmentMorph newColumn.
	voiceControls hResizing: #shrinkWrap; vResizing: #shrinkWrap; layoutInset: 0.
	voiceControls setNameTo: 'voice controls'.
	levelSlider := SimpleSliderMorph new
		color: color;
		extent: 60@2;
		target: rec;
		setNameTo: 'level control';
		actionSelector: #recordLevel:;
		adjustToValue: rec recordLevel.
	
	sliderWrapper := AlignmentMorph newRow
		color: color;
		layoutInset: 0;
		wrapCentering: #center; cellPositioning: #leftCenter;
		hResizing: #shrinkWrap;
		vResizing: #rigid;
		height: 8.
	sliderWrapper addMorphBack: (StringMorph contents: '0 ' font: (StrikeFont familyName: 'Accujen' size: 10)).
	sliderWrapper addMorphBack: levelSlider.
	sliderWrapper addMorphBack: (StringMorph contents: ' 10' font: (StrikeFont familyName: 'Accujen' size: 10)).
	voiceControls addMorphBack: sliderWrapper.

	meterBox := Morph new extent: 82@8; color: Color gray.
	eventRecorder recordMeter height: 8.
	meterBox addMorph: eventRecorder recordMeter.
	eventRecorder recordMeter position: meterBox position.

	voiceControls addMorphBack: meterBox.
	meterBox setNameTo: 'meter box'.

	self addToSoundPanelWithSpacer: voiceControls

]

{ #category : #processing }
EventRecordingSpace >> possiblyAddVoiceControlsToControlPanel [
	"Like de selector say."

	| rec levelSlider meterBox voiceControls sliderWrapper |
	(rec := eventRecorder voiceRecorder) ifNil: [^ self].
	voiceControls := AlignmentMorph newColumn.
	voiceControls hResizing: #shrinkWrap; vResizing: #shrinkWrap; layoutInset: 0.
	voiceControls setNameTo: 'voice controls'.
	levelSlider := SimpleSliderMorph new
		color: color;
		extent: 60@2;
		target: rec;
		setNameTo: 'level control';
		actionSelector: #recordLevel:;
		adjustToValue: rec recordLevel.
	
	sliderWrapper := AlignmentMorph newRow
		color: color;
		layoutInset: 0;
		wrapCentering: #center; cellPositioning: #leftCenter;
		hResizing: #shrinkWrap;
		vResizing: #rigid;
		height: 8.
	sliderWrapper addMorphBack: (StringMorph contents: '0 ' font: (StrikeFont familyName: 'Accujen' size: 10)).
	sliderWrapper addMorphBack: levelSlider.
	sliderWrapper addMorphBack: (StringMorph contents: ' 10' font: (StrikeFont familyName: 'Accujen' size: 10)).
	voiceControls addMorphBack: sliderWrapper.

	meterBox := Morph new extent: 82@8; color: Color gray.
	eventRecorder recordMeter height: 8.
	meterBox addMorph: eventRecorder recordMeter.
	eventRecorder recordMeter position: meterBox position.

	voiceControls addMorphBack: meterBox.
	meterBox setNameTo: 'meter box'.

	self addToSoundPanelWithSpacer: voiceControls

]

{ #category : #commands }
EventRecordingSpace >> presentHelp [
	"Sent when a Help button is hit; provide the user with some form of help for the tool at hand"

	| aFlapTab |
	aFlapTab := ScriptingSystem assureFlapOfLabel: 'Event Theatre' translated withContents: self helpString.
	aFlapTab showFlap
]

{ #category : #access }
EventRecordingSpace >> priorVersions [
	"Answer a list of (<time stamp> recordingSpace) pairs representing prior versions of the recording."

	^ priorVersions ifNil: [priorVersions := OrderedCollection new]
]

{ #category : #access }
EventRecordingSpace >> priorVersions: pv [
	"Set the priorVersions - used during restoration"

	^ priorVersions := pv
]

{ #category : #processing }
EventRecordingSpace >> publishButtonHit [
	"Hand the user a button which, when hit, will open a playback window on the content of the receiver as currently constituted."

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTranslatedList:  #(
		('Iconic button' openUnhintedPlaybackButton)
		('Textual button' openTextualPlaybackButton)) translatedNoop.

	aMenu center:  publishButton center; openInWorld
]

{ #category : #processing }
EventRecordingSpace >> publishPlaybackButton: aButton [
	"Given a playback button, depending on the setting of the #dismissEventTheatreUponPublish preference, either:
	[a]  Dismiss the event thetre, and put the button at topleft of screen, or
	[b]  Leave the event theatre up, and 'hand' the user the button."

	eventRecorder saved: true.
	Preferences dismissEventTheatreUponPublish
		ifTrue:
			[aButton openNearTopLeftOfScreen.
			self abandon]
		ifFalse:
			[aButton openInHand]
]

{ #category : #commands }
EventRecordingSpace >> pushEventTapeToEventRoll [
	"If I have an eventRoll, push my revised tape to it."

	eventRoll ifNotNil:
		[eventRoll acceptTape: eventRecorder tape.
		eventRoll formulate]
]

{ #category : #initialization }
EventRecordingSpace >> putUpHelpFlap [
	"If appropriate, put up (if not alredy present) a flap giving documentation"

	(ScriptingSystem assureFlapOfLabel: 'Event Theatre' withContents: self helpString)
		hideFlap

]

{ #category : #commands }
EventRecordingSpace >> record [
	"Commence event recording..."

	self currentWorld abandonAllHalos.
	self comeToFront.
	
	initialContentArea := contentArea veryDeepCopy.
	self forgetPriorPaintBoxSettings.
	initialPicture := contentArea imageForm.
	self state: #recording.
	self borderColor: Color red.
	self populateControlsPanel.
	self currentWorld doOneCycleNow.

	eventRecorder record
]

{ #category : #commands }
EventRecordingSpace >> recordAgain [
	"There is already a recording; abandon it and make a fresh recording."

	self record
]

{ #category : #commands }
EventRecordingSpace >> recordVoiceover [
	"During playback, or alongside initial recording, record a voiceover"

	| newState |
	self comeToFront.
	
	newState := self state = #recording
		ifTrue:
			[#recordingWithSound]
		ifFalse:
			[#playbackAddingVoiceover].
	self state: newState.
	
	eventRecorder startRecordingNewSound.

	self populateControlsPanel.
	newState = #playbackAddingVoiceover ifTrue: [self borderColor: Color blue]

]

{ #category : #commands }
EventRecordingSpace >> refreshRoll [
	"If there is an event-roll [script] affiliated with the receiver, refresh it."

	eventRoll ifNotNil: [eventRoll updateCursorFromRecordingSpace]
]

{ #category : #commands }
EventRecordingSpace >> rememberCurrentRecording [
	"Remember the current state of the receiver as a version."

	| priors newEntry |
	priors := self priorVersions.
	priorVersions := OrderedCollection new.
	newEntry := Array with: Time dateAndTimeNow with: self veryDeepCopy.
	priorVersions := priors copyWith: newEntry
]

{ #category : #commands }
EventRecordingSpace >> rememberPaintBoxSettingsAtRecordingOutset [
	"If this is the first such call in a recording session, make a note of the brush-size and current-color settings of the PaintBoxMorph prototype at the outset of recording.  These are preserved as properties of the contentArea, so that they will travel with playback buttons affiliated with it."

	(initialContentArea hasProperty: #paintBoxBrushSymbol) ifFalse:
		[initialContentArea setProperty: #paintBoxBrushSymbol toValue: PaintBoxMorph prototype currentBrushSymbol.
		initialContentArea setProperty: #paintBoxCurrentColor toValue: PaintBoxMorph prototype getColor]
]

{ #category : #'event roll' }
EventRecordingSpace >> removeEventRoll [
	"Abandon any existing event roll for the receiver."

	eventRoll ifNotNil: [eventRoll delete].
	eventRoll := nil
]

{ #category : #flaps }
EventRecordingSpace >> removeNavigatorFlap [
	"Remove a navigator flap if there is none."

	| existing |
	existing := contentArea submorphs detect: [:aMorph | (aMorph isKindOf: FlapTab) and: [aMorph flapID = 'Navigator']] ifNone: [nil].
	existing ifNotNil: [existing dismissViaHalo]
]

{ #category : #'sugar flaps' }
EventRecordingSpace >> removeSugarNavigatorFlap [
	"Hide the fake interior sugar navigator."

	(contentArea findA: InteriorSugarNavBar) ifNotNil:
		[:aBar | aBar delete]
]

{ #category : #flaps }
EventRecordingSpace >> removeSuppliesFlap [
	"Remove a navigator flap if there is none."

	| existing |
	existing := contentArea submorphs detect: [:aMorph | (aMorph isKindOf: FlapTab) and: [aMorph flapID = 'Supplies']] ifNone: [nil].
	existing ifNotNil: [existing dismissViaHalo]
]

{ #category : #commands }
EventRecordingSpace >> restoreIncomingPaintBoxSettings [
	"After a playback, restore the current-brush-width and current-color settings that had prevailed before playback started.  Only current sender has its call to this method commented out, however..."

	(self valueOfProperty: #incomingPaintBoxBrushSymbol) ifNotNil:
		[:sym | PaintBoxMorph prototype brush: sym.
		self removeProperty: #incomingPaintBoxBrushSymbol].

	(self valueOfProperty: #incomingPaintBoxCurrentColor) ifNotNil:
		[:aColor | PaintBoxMorph prototype currentColor: aColor.
		self removeProperty:  #incomingPaintBoxCurrentColor]
]

{ #category : #processing }
EventRecordingSpace >> restoreInitialContentArea [
	"Restore the initial content area."

	| existingPosition |
	initialContentArea ifNil:  "Never recorded, so the baseline is an empty content area"
		[contentArea removeAllMorphs.
		self addNavigatorFlap.
		self addSuppliesFlap.
		self populateControlsPanel.
		^ self].
 
	existingPosition := contentArea position.
	contentArea ifNotNil: [contentArea delete].
	self addMorphFront: (contentArea := initialContentArea veryDeepCopy).
	contentArea position: existingPosition.

	eventRecorder noteAreaBounds.

]

{ #category : #processing }
EventRecordingSpace >> restoreVersionStamped: aStamp [
	"Restore the receiver to its state preserved under the given time-stamp."

	| rollShowing foundPair eventTheatre revisedPriorVersions |
	rollShowing := eventRoll notNil and: [eventRoll isInWorld].
	rollShowing ifTrue: [eventRoll delete].
	foundPair := self priorVersions detect: [:pair | pair first = aStamp] ifNone: [^ self error: 'version lost'].

	self delete.
	eventTheatre := foundPair second veryDeepCopy.
	revisedPriorVersions := (priorVersions copyWithout: foundPair) copyWith: foundPair.
	eventTheatre priorVersions: revisedPriorVersions.
	eventTheatre openInWorld.
	eventTheatre removeEventRoll.
	rollShowing ifTrue: [eventTheatre makeHorizontalRoll]
	
	
]

{ #category : #commands }
EventRecordingSpace >> resumePlayback [
	"Resume a suspended playback."

	self comeToFront.
	contentArea  delete.
	contentArea := (self valueOfProperty: #suspendedContentArea) .
	self addMorphFront: contentArea.
	eventRecorder synchronize.
	self state: #playback.
	eventRecorder playHand  suspended: false.
	self populateControlsPanel.
	self borderColor: Color gray.
]

{ #category : #commands }
EventRecordingSpace >> rewind [
	"Rewind the tape, as it were, after a recording or playback."

	self restoreInitialContentArea.
	self abandonReplayHandsAndHalos.
	eventRecorder noteRewound.
	self state: #rewound.
	self populateControlsPanel.
	self refreshRoll
]

{ #category : #commands }
EventRecordingSpace >> setBalloonHelp [
	"Allow the user to edit the balloon-help string to be used for playback buttons."

	| reply aString |
	aString := 
	reply := FillInTheBlank
		multiLineRequest: 'Edit the balloon help to be supplied for playback buttons made for this event movie' translated
		centerAt: Sensor cursorPoint
		initialAnswer: (aString ifNil: [self noHelpString] ifNotNil: [aString])
		answerHeight: 200.
	reply ifNil: [^ self].  "User cancelled out of the dialog"
	(reply isEmpty or: [reply asString = self noHelpString])
		ifTrue: [self balloonHelpString: nil]
		ifFalse: [self balloonHelpString: reply]
]

{ #category : #commands }
EventRecordingSpace >> setCaption [
	"Interactively supply the caption,.  Not currently called, as its entry in the tool's menu is for the moment commented out..."

	| aCaption aResult |
	eventRecorder ifNil: [^ self].
	aCaption := eventRecorder caption ifNil: ['Your Title Goes Here' translated].
	aResult := FillInTheBlank request: 'Please edit the caption' translated initialAnswer: aCaption.
	aResult isEmptyOrNil ifFalse:
		[eventRecorder caption: aResult.
		captionMorph contents: aResult]
		
]

{ #category : #halo }
EventRecordingSpace >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed."

	contentArea width: anExtent x.
	contentArea height: (anExtent y - (self innerBounds height - contentArea height)).
]

{ #category : #commands }
EventRecordingSpace >> shrinkTape [
	"If I have a tape, shrink it."

	state = #readyToRecord ifTrue:
		[^ self inform: 'nothing recorded yet' translated].

	eventRecorder shrink.
	self rememberCurrentRecording.
	self pushEventTapeToEventRoll
]

{ #category : #access }
EventRecordingSpace >> state [
	"Answer the state."

	^ state
]

{ #category : #access }
EventRecordingSpace >> state: aState [
	"Set the receiver's state, with no side effects."

	state := aState
]

{ #category : #processing }
EventRecordingSpace >> step [
	"Periodic stepping."

	super step.
	eventRecorder step "So record meter gets updated"
]

{ #category : #commands }
EventRecordingSpace >> stop [
	"Stop recording or playing the event recorder."

	eventRecorder ifNotNil: [eventRecorder stop].
	self refreshRoll
]

{ #category : #commands }
EventRecordingSpace >> stopPlayback [
	"Stop the playback on the event recorder."

	eventRecorder stop.
	self playingEnded
]

{ #category : #commands }
EventRecordingSpace >> stopRecording [
	"Make the event-recorder stop recording"

	eventRecorder stop.
	finalPicture := contentArea imageForm.

	self state: #atEndOfPlayback.
	self populateControlsPanel.
	self borderColor: self color.

	self rememberCurrentRecording.

	self pushEventTapeToEventRoll
]

{ #category : #commands }
EventRecordingSpace >> stopRecordingVoiceover [
	"The user has hit the button asking to stop recording voiceover."

	eventRecorder terminateVoiceRecording.
	self state = #playbackAddingVoiceover ifTrue:
		[self state: #playback].
	self populateControlsPanel

	

	
]

{ #category : #flaps }
EventRecordingSpace >> sugarNavBarOrNil [
	"If I have a fake-sugar-nav-bar, answer it, else answer nil."

	^ contentArea submorphs detect: [:aMorph | aMorph isKindOf: InteriorSugarNavBar] ifNone: [nil]
]

{ #category : #flaps }
EventRecordingSpace >> sugarNavigatorFlapOrNil [
	"If the receiver has an existing sugar navigator flap, answer it, else answer nil"

	^ contentArea submorphs detect: [:aMorph | aMorph isKindOf: InteriorSugarNavBar] ifNone: [nil]
]

{ #category : #'sugar flaps' }
EventRecordingSpace >> sugarPartsBinQuads [
	"Answer definitions for the contents of the supplies bin within the sugar-nav-bar of the event theatre."

	^  {
	{#ObjectsTool. #newStandAlone. 'Object Catalog' translatedNoop. 'A tool that lets you browse the catalog of available objects' translatedNoop}.
	{#AllScriptsTool. #allScriptsToolForActiveWorld. 'All Scripts' translatedNoop. 'Stop, Step, and Go buttons for controlling all your scripts at once.  The tool can also be "opened up" to control each script in your project individually.' translatedNoop}.
	{#AllPlayersTool. #allPlayersToolForActiveWorld. 'Players' translatedNoop. 'A tool listing all the scripted objects in the project.' translatedNoop}.
	{#TrashCanMorph. #new	. 'Trash' translatedNoop. 'A tool for discarding objects' translatedNoop}.
	{#TextMorph	. #authoringPrototype. 'Text' translatedNoop.	'Text that you can edit into anything you desire.' translatedNoop}.
	{#RecordingControls. #authoringPrototype. 'Sound Recorder' translatedNoop. 'A device for making sound recordings.' translatedNoop}.
	{#RectangleMorph. #authoringPrototype. 'Rectangle' translatedNoop. 'A rectangle' translatedNoop}.
	{#EllipseMorph. #authoringPrototype. 'Ellipse' translatedNoop.  'An ellipse or circle' translatedNoop}.
	{#StarMorph. #authoringPrototype. 'Star' translatedNoop. 'A star' translatedNoop}.
	{#BookMorph. #authoringPrototype. 'Book' translatedNoop. 'A multi-paged structure' translatedNoop}.
	{#ScriptingSystem. #prototypicalHolder. 'Holder' translatedNoop. 'A place for storing alternative pictures in an animation, etc.' translatedNoop}.
	{#JoystickMorph	. #authoringPrototype. 'Joystick' translatedNoop. 'A joystick-like control' translatedNoop}.
	{#PasteUpMorph. #authoringPrototype. 'Playfield' translatedNoop. 'A place for assembling parts or for staging animations' translatedNoop}.
	{#ScriptableButton. #authoringPrototype. 'Button' translatedNoop. 'A button to use with tile scripting; its script will be a method of its containing playfield' translatedNoop}.
	{#SimpleSliderMorph.	#authoringPrototype.	'Slider' translatedNoop.	'A slider for showing and setting numeric values.' translatedNoop}
}
asOrderedCollection
]

{ #category : #'sugar flaps' }
EventRecordingSpace >> sugarSuppliesFlapTab [
	"Build and answer an interior sugar-supplies flap"

	|  aFlapTab aStrip quads |
	quads := self sugarPartsBinQuads.
	aStrip := PartsBin newPartsBinWithOrientation: #leftToRight andColor: Color gray muchLighter from: quads withPreviousEntries: #().
	Flaps twiddleSuppliesButtonsIn: aStrip.
	aFlapTab := InteriorSolidSugarSuppliesTab new referent: aStrip beSticky.
	aFlapTab sugarNavBar: self sugarNavBarOrNil.
	aFlapTab setName: 'Supplies' translated edge: #top color: Color red lighter.
	aFlapTab position: (contentArea topLeft + (0 @ SugarNavTab new height)).
	aFlapTab setBalloonText: aFlapTab balloonTextForFlapsMenu.
	aFlapTab applyThickness: 20.

	aStrip extent: contentArea width @ (76 * (1 + (1350 // contentArea width))).
	aStrip beFlap: true.
	aStrip autoLineLayout: true.
	aFlapTab useSolidTab.
	aFlapTab height: 20; color:  (Color r: 0.804 g: 0.804 b: 0.804).

	^ aFlapTab
]

{ #category : #flaps }
EventRecordingSpace >> suppliesFlapOrNil [
	"If the receiver has an existing supplies flap, answer it, else answer nil"

	^ contentArea submorphs detect: [:aMorph | (aMorph isKindOf: FlapTab) and: [aMorph flapID = 'Supplies']] ifNone: [nil]
]

{ #category : #commands }
EventRecordingSpace >> toggleShowingSoundPanel [
	"Toggle whether showing the sound panel."

	showingSoundPanel := (showingSoundPanel ~~ false) not.  "bkwd compat"
	showingSoundPanel 
		ifFalse:
			[soundPanel delete]
		ifTrue:
			[self addMorphBack: soundPanel]
]

{ #category : #menu }
EventRecordingSpace >> toggleUsingVoice [
	"Toggle whether or not using voice."

	eventRecorder voiceRecorder
		ifNil:
			[eventRecorder addVoiceControls]
		ifNotNil:
			[eventRecorder deleteVoiceControls].
	self populateControlsPanel
]

{ #category : #menu }
EventRecordingSpace >> usingVoice [
	"Answer whether voice is enbled"

	^ eventRecorder voiceRecorder notNil
]

{ #category : #menu }
EventRecordingSpace >> usingVoiceString [
	"Answer a string characterizing whether voice is being used or not."

	^ (eventRecorder voiceRecorder
		ifNil: ['<no>'] ifNotNil: ['<yes>']), 'record voice during event recording' translated
]
