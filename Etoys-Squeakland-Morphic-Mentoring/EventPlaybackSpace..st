"
An area used for playback of event-recorded movies, as it were.
"
Class {
	#name : #EventPlaybackSpace,
	#superclass : #EventRecordingSpace,
	#instVars : [
		'autoStart',
		'autoDismiss'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #commands }
EventPlaybackSpace >> abandon [
	"Abandon the entire exercise."

	self delete.
	self dismantlePaintBoxArtifacts.
	self abandonReplayHandsAndHalos.
	(self valueOfProperty: #stopper) ifNotNil:
		[:stopper | stopper delete].
	(self valueOfProperty: #originatingButton) ifNotNil:
		[:aButton | aButton playbackConcludedIn: self]
]

{ #category : #menu }
EventPlaybackSpace >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add morph-specific items to the given menu which was invoked by the given hand.  This method is invoked both from the halo-menu and from the control-menu regimes."

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addTranslatedList: #(
		( 'open for score-editing' openForScoreEditing  'Display this event-movie in a form such that its score can be viewed and edited.')) translatedNoop

]

{ #category : #menu }
EventPlaybackSpace >> addMenuButtonItemsTo: aMenu [
	"Subclasses wishing to partake of generic menuButton support should reimplement this, and *not* call super ;-)"

	aMenu addTranslatedList: #(
		('rewind'				rewind)
		('play again'			play)) translatedNoop.
	Preferences debugging ifTrue:
		[aMenu addTranslatedList: #(
		-
		('inspect' inspect)
		-
		('edit this menu' editMenuButtonDefinition)) translatedNoop]
]

{ #category : #initialization }
EventPlaybackSpace >> addStopper [
	"Add a control that can be clicked to make the playback stop."

	| aStopper |
	aStopper := self tanOButton.
	aStopper on: #mouseDown send: #abandon to: self.
	self setProperty: #stopper toValue: aStopper.
	aStopper openInWorld.
	aStopper topLeft: (self topLeft - (6@6))
]

{ #category : #accessing }
EventPlaybackSpace >> autoDismiss: anObject [
	"Set the value of autoDismiss"

	autoDismiss := anObject
]

{ #category : #accessing }
EventPlaybackSpace >> autoStart: anObject [
	"Set the value of autoStart"

	autoStart := anObject
]

{ #category : #commands }
EventPlaybackSpace >> comeToFront [
	"Bring the receiver to the front, then its dismisser in front of it."

	super comeToFront.
	(self valueOfProperty: #stopper) ifNotNil:
		[:s | s comeToFront]
]

{ #category : #initialization }
EventPlaybackSpace >> contentArea: anArea tape: aTape [
	"Basic initialization:  Set the receiver's contentArea &  tape."

	autoStart := false.  "Caller will change these subsequenty if needed"
	autoDismiss := false.

	contentArea ifNotNil: [contentArea delete].
	initialContentArea := anArea veryDeepCopy.
	self restoreInitialContentArea.
	eventRecorder tape: aTape veryDeepCopy.
	eventRecorder recordingSpace: self.
	eventRecorder noteAreaBounds.

	self color:  (Color r: 0.677 g: 0.935 b: 0.484)

	
]

{ #category : #initialization }
EventPlaybackSpace >> launchFrom: aButton [
	"Initialize the receiver from an invoker button, and launch it."
	
	| where |
	self setProperty: #originatingButton toValue: aButton.
	self contentArea: aButton contentArea veryDeepCopy tape: aButton tape veryDeepCopy.
	self captionString: aButton caption.
	self rewind.
	autoStart := aButton autoStart.
	autoDismiss := aButton autoDismiss.

	"showChrome  := aButton showChrome."
	where := aButton whereToAppear.

	self openInWorld.
	where = #screenCenter ifTrue: [self center: self currentWorld center].
	where = #buttonPosition ifTrue: [self position: aButton position].
	where = #containerOrigin ifTrue: [self position: aButton owner position].
	self goHome.
	self addStopper.

	autoStart ifTrue: [self play]
]

{ #category : #processing }
EventPlaybackSpace >> okayToResizeEasily [
	"Answer whether the receiver would be glad to offer a grow handle."

	^ false
]

{ #category : #processing }
EventPlaybackSpace >> okayToRotateEasily [
	"Answer whether it is appropriate for a rotation handle to be shown for the receiver. "

	^ false
]

{ #category : #commands }
EventPlaybackSpace >> openForScoreEditing [
	"Open the receiver's event-movie in a conventional EventRecordingSpace."

	| aButton aSpace |
	aButton := self valueOfProperty: #originatingButton ifAbsent: [^ self].

	aSpace := EventRecordingSpace new.
	aSpace initializeFromPlaybackButton: aButton.
	aSpace openInWorld.
	aSpace center: self center.
	self abandon
]

{ #category : #processing }
EventPlaybackSpace >> playingEnded [
	"The playback reached the end."

	self dismantlePaintBoxArtifacts.
	autoDismiss ifTrue: [^ self abandon].

	self state: #atEndOfPlayback.
	self populateControlsPanel.
	self borderColor: self color.
	self abandonReplayHandsAndHalos.
	self removeAlarm: #offerTickingMenu:.  "In case timing is unlucky"

]

{ #category : #processing }
EventPlaybackSpace >> playingStopped [
	"The playback reached the end"

	self dismantlePaintBoxArtifacts.
	autoDismiss ifTrue: [^ self abandon].

	state := #atEndOfPlayback.
	self populateControlsPanel.
	self borderColor: self color.
	self abandonReplayHandsAndHalos

]

{ #category : #processing }
EventPlaybackSpace >> populateControlsPanel [
	"Build the things that need to be in the controls panel."

	((autoStart = true) and: [autoDismiss = true]) ifTrue:
		[controlsPanel delete.
		soundPanel delete.
		^ self].

	showingSoundButton ifNil: [self initialize.  self makeStatusButtons].  "bkwd compat"

	controlsPanel color:  (Color r: 0.677 g: 0.935 b: 0.484).
	controlsPanel removeAllMorphs.
	soundPanel ifNotNil: [soundPanel delete].

	(autoStart == true and:  [autoDismiss == true]) ifTrue: [^ self]. 

	controlsPanel  addVariableTransparentSpacer.

	self addControlWithSpacer: abandonButton.
"	self addControlWithSpacer: menuButton."
	self addControlWithSpacer: captionMorph lock.

	state = #playback ifTrue: [self addControlWithSpacer: stopButton].
	self addControlWithSpacer: rewindButton.
	(#(rewound atEndOfPlayback) includes: state) ifTrue: [self addControlWithSpacer: playButton]


]

{ #category : #initialization }
EventPlaybackSpace >> putUpHelpFlap [
	"If appropriate, put up (if not alredy present) a flap giving documentation.  Present here to override EventRecordingSpace's wish to put up a help flap in this situation."

	
]
