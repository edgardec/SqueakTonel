"
A tool used in conjunction with an event-recording-space to view and edit events in an event score.
"
Class {
	#name : #EventRollMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'startTime',
		'millisecondsPerPixel',
		'totalDuration',
		'eventTheatre',
		'rawEventTape',
		'mouseTrack',
		'keyboardTrack',
		'mediaTrack',
		'actualRoll',
		'eventPlaybackCursor'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #processing }
EventRollMorph >> abandon [
	"Forget any memory of this event roll, and dismiss it.  When/if an event-roll is later requested from my event theatre, a fresh one will be launched."

	eventTheatre ifNotNil: [eventTheatre removeEventRoll].
	self delete
]

{ #category : #initialization }
EventRollMorph >> acceptTape: aTape [
	"Accept a new event tape; this will rebuild everything."

	| aParser |
	rawEventTape :=  aTape.
	startTime := rawEventTape first timeStamp.
	aParser := EventTapeParser new.
	aParser eventTape: rawEventTape.
	aParser parseTape.
	mouseTrack := aParser mouseTrack.
	keyboardTrack := aParser keyboardTrack.
	mediaTrack := aParser ambientTrack select: [:t | t isKindOf: MediaPlayEvent].
	totalDuration := self computeTotalDuration



]

{ #category : #menus }
EventRollMorph >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add morph-specific  items to the halo menu."

	super addCustomMenuItems: aMenu hand: aHandMorph.
	aMenu addTranslatedList: #(
		('change scale...' changeScale   'allows you to supply a precise scale-factor manually.')
		('retrofit to event-theatre' pushChangesBackToEventTheatre   'normally not necessary, but if you suspect that edits you have made in this event roll have not been fully appreciated by the event theatre, choose this to force the event theatre to reflect what you see in the event roll.' )) translatedNoop
]

{ #category : #display }
EventRollMorph >> addMenuButtonItemsTo: aMenu [
	"Add menu items to the menu obtained by clicking on the menu icon"

	"CAUTION:  Debugging items still present."

	aMenu addTitle: 'Event-Roll Options' translated.

	aMenu addTranslatedList: #(
		('revert to version...'  offerVersions 'allows you to back up to any earlier version of the event tape.') ) translatedNoop.

	Preferences debugging ifTrue:
		[aMenu addTranslatedList: #(
		-

	"	('change scale...' changeScale   'allows you to supply a precise scale-factor manualliy.')
		('retrofit to event-theatre' pushChangesBackToEventTheatre  'normally not necessary, but if you suspect that edits you have made in this event roll have not been fully appreciated by the event theatre, choose this to force the event theatre to reflect what you see in the event roll.' )
		-
		('restore original event theatre'	restoreOriginalEventTheatre  'Restore the event theatre, and hence this event roll, to how they were when you first made this roll.')
		-"
		('inspect event roll' inspect  'debugging -- open an Inspector on this event roll')
		('update cursor' updateCursorFromRecordingSpace 'debugging -- update the red roll cursor')
		('update scrollbar' updateScrollbar  'debugging -- update the scrollbar')
		-
		('edit this menu' editMenuButtonDefinition 'debugging -- change the definition of this menu.')) translatedNoop]
]

{ #category : #processing }
EventRollMorph >> changeScale [
	"Let the user reconsider the scale.  Normally, we expect the user to change the scale using the scale slider, but the earlier feature embodied here, which allows the user to type in the desired new scale, is, for the moment at least, retained."

	| result |
	result := FillInTheBlank request: 'Milliseconds per pixel [currently ' translated, millisecondsPerPixel printString, ']' initialAnswer: millisecondsPerPixel printString.

	(result isEmptyOrNil not and: [result asNumber ~= millisecondsPerPixel]) ifTrue:
		[self establishScale: result asNumber]
]

{ #category : #initialization }
EventRollMorph >> colorForButtons: anInteger [
	"Answer a color to use to encode the button configuration"

	(#(1 65) includes: anInteger) ifTrue: [^ Color blue lighter].
	(#(2 34) includes: anInteger) ifTrue: [^ Color yellow lighter].
	anInteger = 4 ifTrue: [^ Color red lighter].

	"Need to flesh this out "
	^ Color green lighter
]

{ #category : #processing }
EventRollMorph >> computeTotalDuration [
	"Answer the total duration of the events in my current raw event tape, in miliseconds, in a sledgehammer fashion.  Because of the slowness of this, the result is cached in my totalDuration inst var. "

	| baseline total |
	total := 0.
	baseline := rawEventTape first timeStamp.
	rawEventTape do:
		[:evt |
			evt type = #noCondense ifFalse: "annoying non-cooperator!"
				[total := total max: (evt timeStamp + evt durationInMilliseconds - baseline)]].
	^ total
]

{ #category : #processing }
EventRollMorph >> establishScale: msPerPixel [
	"Establish the number provided as the millisecondsPerPixel."

	millisecondsPerPixel := ((msPerPixel asNumber rounded) max: 1) min: 50.
	self formulate
]

{ #category : #accessing }
EventRollMorph >> eventTheatre [
	"Answer the value of eventTheatre"

	^ eventTheatre
]

{ #category : #initialization }
EventRollMorph >> eventTheatre: anEventTheatre [
	"Establish the eventTheatre for an EventRoll."

	eventTheatre := anEventTheatre.
	self acceptTape: anEventTheatre eventRecorder tape.

	"(ScriptingSystem assureFlapOfLabel: 'Event Roll' translated withContents: self helpString translated) hideFlap"


]

{ #category : #processing }
EventRollMorph >> formulate [
	"Given that all my relevant inst vars are now filled,build the structures that constitute the tool."

		"Replace the parts of the tool that change"

	| outer scrollAreaWidth |
	submorphs size  > 1
		ifFalse:
			[scrollAreaWidth := 600]
		ifTrue:
			[scrollAreaWidth := submorphs second width].

	[submorphs size > 1] whileTrue: [submorphs last delete].

	actualRoll := EventTimeline new extent: ( (self totalDuration / millisecondsPerPixel) @ 160).
	actualRoll color: Color yellow muchLighter.
	actualRoll beSticky.
	outer := ScrollPane new extent: scrollAreaWidth @ 160.
	outer model: self.
	outer useRoundedCorners.
	outer scrollBarOnLeft: false.
	outer scroller addMorph: actualRoll.
	outer retractable: false.
	outer vScrollBarPolicy: #never.
	outer hScrollBarPolicy: #always.

	self addMorphBack: outer.

	self setMouseEventMorphs.
	self setKeyboardEventMorphs.
	self setMediaEventMorphs.
	self setTimeIndicators.

	actualRoll addMorphFront: eventPlaybackCursor.
	eventPlaybackCursor  bounds: (actualRoll topLeft extent: (2 @ actualRoll height)).

	self setVerticalGrid: (1000/millisecondsPerPixel)  rounded  backgroundColor: Color blue veryMuchLighter lineColor: Color gray darker.
	
	self updateScrollbar
]

{ #category : #documentation }
EventRollMorph >> helpString [
	"Answer a help string for the Event Roll."

	^ 'An Event Roll is a used to visualize and edit the score, or "tape", of an Event Theatre''s "event movie".

The Roll shows three "tracks", one for all Mouse events, one for Keyboard events, and one for all other events, such as sound.

You can *remove* any item from an event roll by just picking it up with the mouse and dropping it anywhere outside the roll (such as on the desktop or in the trash-can.)  If in doubt about the effect of removing an item, you can put it on the desktop, play the revised tape, then pick up the event from the desktop and drop it back near where you found it in the event roll, and replay again to compare.

You can *reposition* any item in an event roll by picking it up with the mouse and dropping it anywhere else in the roll.  CAUTION:  Items in the mouse-event track should not be dropped such that they overlap -- see caveat below under "Tips".

You can drag various kinds of items *into* the roll.  For example, you can drop a "Morph" or a "Tile" obtained from a SoundRecorder, and you can drop a "button" representing another event-recorded sequence (though it is not at the moment recommended to do the latter.)  One straightforward way of adding voiceovers to an existing event recording is to play back the recording while selectively making individual snippets of voice recordings using a separate, standard Squeak SoundRecording tool.  After you are satisfied with a recording, obtain a "morph" from the sound-recording tool, and position it as desired in the event roll.

You can *resize* items in the "mouse" track of an event roll.  When you stretch or shrink a mouse-sequence, the events within the sequence get remapped linearly within the duration represented by the new size of the sequence as seen in the event roll.  [CAUTION:  Do not resize a mouse item such that it will overlap an adjacent one.  It is a bug that this is even allowed.]

In addition to adding separately-recorded voiceovers using the mechanism described in item 3 above, there is a built-in voiceover mechanism in the Event Theatre.  Whenever you are playing back an existing event-recording in an Event Theatre, a "Record Voiceover" button will appear.  If you press this, the playback of the event recording will continue and you can record a voiceover to go with any portion you wish.  When you are done recording a snippet, you can hit the "stop recording voiceover" button; playback will continue, and you can subsequently, on this pass or any future one, add more voiceover snippets.  To remove a voiceover snippet, simply drag it out of the event roll; to reposition it, simply pick it up with the mouse and drop it back into the event roll at the desired position.

When you make a change in an Event Roll, it will immediately change the tape of the Event Theatre, so that when you replay the event-movie you will immediately see see the change.  If you are unhappy with the change, there is a one-level "undo" available which will revert the EventTheatre to its state before the last edit you made in the EventRoll.  There is also a "deeper" level of "undo" available that will revert the EventTheatre (and hence the associated EventRoll) to the initial state they were in when you first launched the event roll.


Keyboard Track

You can reposition or delete any keyboard-track item.

Color conventions in the keyboard track: (These will change soon!)

	White	Simple lower-case character, no modifier key pressed
	Red		Shift-key pressed
	Green	Alt-key pressed
	Yellow	Control-key pressed

	Yellow	A "space" character
	Blue		A "backspace" character

Unprintable characters are shown in red with the ascii value displayed, e.g. #13 for a "return" character.

*Important Tips*

(1)  To get the halo on an object inside an EventRoll, hold down the SHIFT key as you halo-click on the object.

(2)  DO NOT reposition or resize mouse-track items such that any two of them overlap, since this will result in the events represented by the two items getting co-mingled in such a way that they you will never be able to separate them again, and the mixture will have crazy results.  It is a bug that you are allowed to drop mouse-track items such that they overlap.  So please, DO NOT DO IT!  If by accident you do, you might be interested in trying out some of the revert mechanisms in the system.
' translated
]

{ #category : #initialization }
EventRollMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self layoutInset: 0.
	self color:  (Color r: 0.677 g: 0.839 b: 1.0).
	self useRoundedCorners.
	self listDirection: #leftToRight; hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 1@1.

	millisecondsPerPixel := 10.

	eventPlaybackCursor := EventRollCursor new.
	self beSticky.
	self makeControlsPanel
]

{ #category : #processing }
EventRollMorph >> installChangedTapeToNewEventTheatre [
	"Install the changed tape into a *new* eventTheatre."

	self shouldBeImplemented
]

{ #category : #initialization }
EventRollMorph >> makeButtonsPanel [
	"Answer a horizontal panel containing my control buttons."

	| aBut buttons |
	buttons := AlignmentMorph newRow beTransparent.
	buttons hResizing: #spaceFill.
	buttons  listCentering: #center. 
	buttons listSpacing: #equal.
	buttons cellInset: 2; layoutInset: 0.

	buttons addVariableTransparentSpacer.
	buttons addMorphBack: (aBut := self tanOButton).
	aBut actionSelector: #abandon.
	aBut setBalloonText: 'Abandon  this piano roll.  If you have made changes and wish them to be propagated back to the originating event-theatre, be sure to do that before abandoning the piano roll.' translated.

	buttons addTransparentSpacerOfSize: (5@0).
	buttons addMorphBack:  self helpButton.
	buttons addTransparentSpacerOfSize: (5@0).

	buttons addMorphBack: self menuButton.
	buttons addTransparentSpacerOfSize: (5@0).

	buttons addVariableTransparentSpacer.
	^ buttons
]

{ #category : #processing }
EventRollMorph >> makeControlsPanel [
	"One-time initialization.  Upon entry, the receiver has no submorphs; upon exit, it has one, namely its controlsPanel, which contains the scale slider, the track headings, and the control buttons."

	| topWrapper labelWrapper aMorph aPanel |
	aPanel := AlignmentMorph newColumn beTransparent.
	aPanel hResizing: #shrinkWrap; vResizing: #shrinkWrap.

	topWrapper := AlignmentMorph newRow beTransparent.
	topWrapper hResizing: #spaceFill; vResizing: #shirnkWrap.
	topWrapper rubberBandCells: true.

	labelWrapper := AlignmentMorph newColumn beTransparent.
	labelWrapper addTransparentSpacerOfSize: 0@4.
	#('mouse' 'keyboard' 'media') translatedNoop do:
		[:aString |
			aMorph := Morph new extent: 80@ 20.
			aMorph hResizing: #rigid; vResizing: #rigid.
			aMorph beTransparent.
			aMorph addMorphCentered: (StringMorph contents: aString translated font: (StrikeFont familyName: 'Accujen' size: 24)).
			labelWrapper addMorphBack: aMorph.
			labelWrapper addTransparentSpacerOfSize: 0@20].
	labelWrapper submorphs last delete.  "that last spacer"
	topWrapper addMorphBack:  labelWrapper.
	labelWrapper on: #mouseDown send: #grabMorph: to: self.

	topWrapper addMorphBack: self scaleSlider.

	aPanel addMorphBack: topWrapper.
	aPanel addMorphBack: self makeButtonsPanel.
	self addMorph: aPanel
]

{ #category : #miscellaneous }
EventRollMorph >> millisecondsPerPixel [
	"Answer the receiver's millisecondsPerPixel."

	^ millisecondsPerPixel
]

{ #category : #processing }
EventRollMorph >> offerVersions [
	"Let the user choose a prior version to which to revert."

	eventTheatre offerVersions 
]

{ #category : #accessing }
EventRollMorph >> pixelsPerSecond [
	"Answer the number of pixels of the roll it takes to represent one second of real time."

	^ 1000 // millisecondsPerPixel 
]

{ #category : #accessing }
EventRollMorph >> pixelsPerSecond: aNumber [
	"Set the number of pixels per second."

	self establishScale:  ((1.0 / aNumber) * 1000) rounded
]

{ #category : #documentation }
EventRollMorph >> presentHelp [
	"Sent when a Help button is hit; provide the user with some form of help for the tool at hand"

	| aFlapTab |
	aFlapTab := ScriptingSystem assureFlapOfLabel: 'Event Roll' translated withContents: self helpString.
	aFlapTab showFlap
]

{ #category : #processing }
EventRollMorph >> pushChangesBackToEventTheatre [
	"Push the event-tape changes implied by the user's edit in the event-roll back into the originating event theatre."

	| allNewEvents |
	allNewEvents := Array streamContents:
		[:aStream |
			rawEventTape do:
				[:e | (e isMemberOf: MorphicUnknownEvent) ifTrue:
					[aStream nextPut: e]].   "Misc directives such as do not condense & worldlet bounds"

			actualRoll submorphs do:
				[:m |
					m putEventsOnto: aStream]].
					
	allNewEvents sort: [:a :b | a timeStamp < b timeStamp].
	eventTheatre acceptNewTape: allNewEvents.
	self acceptTape: allNewEvents.
	self formulate
]

{ #category : #processing }
EventRollMorph >> scaleSlider [
	"Answer a device that can serve to govern the scale of the piano roll."

	| aSlider |
	aSlider := SimpleSliderMorph new
		color: Color blue muchLighter;
		extent: 12 @ 120;
		target: self;
		minVal: 1;
		maxVal: 50;
		setNameTo: 'scale';
		actionSelector: #establishScale:;
		adjustToValue: millisecondsPerPixel.
	^ aSlider
	

]

{ #category : #accessing }
EventRollMorph >> scrollPaneForRoll [
	"Answer the scrollPane that encompasses the roll."

	^ submorphs second
]

{ #category : #miscellaneous }
EventRollMorph >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed."

	submorphs second width: ((anExtent x - submorphs first width - 8))
]

{ #category : #display }
EventRollMorph >> setKeyboardEventMorphs [
	"Place morphs representing the keyboard track on the roll."

	| aMorph aChar stroke report |
	true ifTrue: [^ self setKeystrokeEventMorphs].

	keyboardTrack do:
		[:evt |
			aMorph := KeyboardEventMorph new.
			aMorph hResizing: #shrinkWrap.
			aMorph vResizing: #shrinkWrap.
			aMorph beTransparent.
			aMorph event: evt.
			aMorph extent: (evt duration / millisecondsPerPixel) @ 20.
			aMorph left: ((evt startTime - startTime)/ millisecondsPerPixel).
			aMorph top: 44.
			stroke := evt events detect: [:event | event type = #keystroke]
				ifNone: [nil].
			aChar := stroke ifNotNil: [stroke keyCharacter] ifNil: [evt events first keyCharacter].	
			report := (aChar tokenish or: [aChar isSpecial] or: [aChar = $ ])
				ifTrue:
					[aChar asString]
				ifFalse:
					['#', aChar asciiValue printString].

			aMorph character: aChar.
			aMorph addMorphCentered: (StringMorph contents: report font: (StrikeFont familyName: 'Accujen' size: 15)) lock.
			actualRoll addMorphBack: aMorph]
]

{ #category : #display }
EventRollMorph >> setKeystrokeEventMorphs [
	"Place morphs representing keystrokes into keyboard track on the roll."

	| aMorph aChar report |
	keyboardTrack do:
		[:evt |
			aMorph := KeyboardEventMorph new.
			aMorph layoutPolicy: TableLayout new.
			aMorph hResizing: #shrinkWrap.
			aMorph vResizing: #shrinkWrap.
			aMorph beTransparent.
			aMorph event: evt.
			aMorph left: ((evt timeStamp - startTime) / millisecondsPerPixel).
		
			aMorph top: 50.
			aChar := evt keyCharacter.
			report := (aChar tokenish or: [aChar isSpecial] or: [#($  $.) includes: aChar])
				ifTrue:
					[aChar asString]
				ifFalse:
					['#', aChar asciiValue printString].

			aMorph character: aChar.
			aMorph addMorphCentered: (StringMorph contents: report font: (StrikeFont familyName: 'Accujen' size: 24)) lock.
			actualRoll addMorphBack: aMorph]
]

{ #category : #display }
EventRollMorph >> setMediaEventMorphs [
	"Place morphs representing the media track on the roll."

	| aMorph aWheel |
	mediaTrack ifEmpty: [^ self].
	aWheel := Color wheel: mediaTrack size.
	mediaTrack doWithIndex:
		[:evt :index |
			aMorph := MediaEventMorph new.
			aMorph hResizing: #shrinkWrap.
			aMorph vResizing: #shrinkWrap.
			aMorph color: ((aWheel at: index) alpha: 0.5).
			aMorph event: evt.
			aMorph extent: ((evt durationInMilliseconds / millisecondsPerPixel) @ 32).
			aMorph left: ((evt timeStamp - startTime)/ millisecondsPerPixel).
			aMorph top: 84.
			actualRoll addMorphBack: aMorph]
]

{ #category : #display }
EventRollMorph >> setMouseEventMorphs [
	"Place morphs representing the mouse track on the roll."

	| aMorph aColor |
	mouseTrack do:
		[:evt |
			aMorph := MouseEventSequenceMorph new.
			aMorph event: evt.
			aMorph extent: (evt duration / millisecondsPerPixel) @ 26.
			aMorph left: ((evt startTime - startTime)/ millisecondsPerPixel).
			aMorph top: 6.
			aColor := evt events first type = #mouseMove
				ifTrue:
					[Color gray lighter]
				ifFalse:
					[self colorForButtons: evt events first buttons].
			aMorph color: aColor.
			actualRoll addMorphBack: aMorph.
			"aMorph on: #doubleClick send: #openExpandedView: to: aMorph"]
]

{ #category : #display }
EventRollMorph >> setTimeIndicators [
	"Place morphs divulging elapsed time on the roll."

	| aMorph outer |
	 1 to: (self totalDuration // 1000) do:
		[:sec |
			aMorph := StringMorph contents: sec printString font: (StrikeFont familyName: 'Accujen' size: 32).
			outer := RectangleMorph new.
			outer extent: (aMorph extent + (1@1)).
			outer borderWidth: 0.
			outer color: (Color r: 0.903 g: 0.903 b: 1.0).
			outer addMorphBack: aMorph.
			aMorph center: outer center.
			outer center:  ((sec * 1000) // millisecondsPerPixel) @ 128.
			aMorph color: Color brown.
			actualRoll addMorphBack: outer]
]

{ #category : #processing }
EventRollMorph >> setVerticalGrid: anInteger backgroundColor: backColor lineColor: lineColor [
	"Make the receiver's color be an Infinite Form of repetitions of a form consisting of just a "

	| gridForm |
	gridForm := Form extent: anInteger @ anInteger depth: Display depth.
	backColor ifNotNil: [gridForm fillWithColor: backColor].
	gridForm fill: ((gridForm width -1) @0 extent: 1 @ gridForm height) fillColor: lineColor.

	actualRoll color: (InfiniteForm with: gridForm)

]

{ #category : #stepping }
EventRollMorph >> step [
	"Periodic action... here, we update the cursor of the receiver's roll, and scroll the  current cursor's position in the roll into view if necessary."

	(#(playback playbackAddingVoiceover) includes: eventTheatre state) ifTrue:
		[self updateCursorFromRecordingSpace]
		
]

{ #category : #stepping }
EventRollMorph >> stepTime [
	"Fast as I can."

	^ 0
]

{ #category : #miscellaneous }
EventRollMorph >> timeStampForCurrentPositionOf: anEventMorph [
	"Answer the time-stamp corresponding to the position of the left edge of the given eventMorph, assumed to be a submorph of my actual roll."

	^ startTime + (anEventMorph left * millisecondsPerPixel)
]

{ #category : #miscellaneous }
EventRollMorph >> timeStampForRightEdgeOf: anEventMorph [
	"Answer the time-stamp corresponding to the position of the right edge of the given eventMorph, assumed to be a submorph of my actual roll."

	^ startTime + (anEventMorph right * millisecondsPerPixel)
]

{ #category : #processing }
EventRollMorph >> totalDuration [
	"Answer the total duration of the events in my current event tape, in miliseconds."

	^ totalDuration ifNil: [totalDuration := self computeTotalDuration]
]

{ #category : #processing }
EventRollMorph >> updateCursorFromRecordingSpace [
	"Yup"

	| cursorX aRect |
	actualRoll ifNil: [^ self].
	cursorX :=   ((eventTheatre eventRecorder millisecondsIntoPlayback ) // millisecondsPerPixel) min: (actualRoll width - 2).
	aRect := cursorX @ 0 extent: 2 @ actualRoll height.
	eventPlaybackCursor bounds:  aRect.
	self scrollPaneForRoll scrollHorizontallyToShow: aRect
]

{ #category : #processing }
EventRollMorph >> updateScrollbar [
	"Every subsystem needs a little bit of inscrutable magic.  Here it is for the event roll."

	self setExtentFromHalo: (self extent + (33@0)).
	self setExtentFromHalo: (self extent  +  (8@0))
]

{ #category : #stepping }
EventRollMorph >> wantsSteps [
	"Answer whether the receiver wants to be sent the #step message periodically."

	^ true
]

{ #category : #'drag and drop' }
EventRollMorph >> wantsToBeDroppedInto: aMorph [
	"Return true if it's okay to drop the receiver into aMorph."

	^ aMorph isWorldMorph "only into worlds"
]
