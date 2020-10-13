"
When clicked on by the user, open up an EventPlaybackSpace positioned within the receiver's container, ready to play back a given event tape with a given optional voice track.  

caption			A textual title for the exercise
contentArea		The reference bounds to which the coordinates in the tape are bound.
tape				An EventRecorder tape
voiceRecorder     An optional SoundRecorder
beforeBitmap		The bitmap of the receiver before the first time the user has requested the hint
afterBitmap		The bitmap of the receiver after the first time the user has requested the hint
timesPlayed		How many times the hint has been invoked
autoStart			If true, playback will happen automatically when the playback unit is opened.
autoDismiss       	If true, as soon as playback ends, the playback unit will go away, revealing the ""afterBitmap"" view of the receiver.


"
Class {
	#name : #PlaybackInvoker,
	#superclass : #SketchMorph,
	#instVars : [
		'caption',
		'contentArea',
		'tape',
		'beforeBitmap',
		'afterBitmap',
		'initialPicture',
		'finalPicture',
		'timesPlayed',
		'offeringHint',
		'autoStart',
		'autoDismiss',
		'whereToAppear',
		'postPlaybackImageFeature'
	],
	#classVars : [
		'HintForm'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #scripting }
PlaybackInvoker class >> defaultNameStemForInstances [
	"Answer the stem upon which object names are built."

	^ 'Play' translatedNoop
]

{ #category : #accessing }
PlaybackInvoker class >> hintForm [
	"Answer the picture of the word Hint"

	^ HintForm
]

{ #category : #'class initialization' }
PlaybackInvoker class >> initialize [
	"Class initialization."
	"PlaybackInvoker initialize"

	HintForm := Form
	extent: 152@31
	depth: 16
	fromArray: #( 554041345 65537 65537 65537 65537 66593 0 0 0 24306 65537 65537 65537 65537 65537 81388 0 0 0 0 0 0 0 0 8454 65537 65537 65537 65537 65537 69271552 0 0 0 0 0 0 0 0 65537 65537 65537 71877 1939210240 0 0 0 0 0 15852 65537 65537 65537 65537 65537 1523712000 0 0 0 0 0 0 8454 65537 65537 65537 65537 65537 65537 65537 65537 65537 65537 65537 65537 65537 554106881 69271553 69271553 69271553 69271553 69272608 0 0 0 23250 69271553 69271553 69271553 69271553 69271553 69287404 0 0 0 0 0 0 0 0 8455 66593 66593 66593 66593 66593 69206016 0 0 0 0 0 0 0 0 69271553 69271553 69271553 69271553 692584448 0 0 0 0 0 15852 69271553 69271553 69271553 69271553 69271553 1592918016 0 0 0 0 0 0 8455 66593 66593 66593 66593 66593 66593 66593 66593 66593 66593 66593 66593 66593 1662212818 1523669714 65537 65537 1523735250 1523670770 0 0 0 29590 1523735250 1523664429 65537 71877 1523735250 1523673941 0 0 0 0 0 0 0 0 25363 1523735249 1523712001 65537 88786 1523735249 1592918016 0 0 0 0 0 0 0 0 1523735250 1523669714 65537 65537 83502 0 0 0 0 0 27477 1523669714 1523723625 65537 1523735250 1523669714 1939210240 0 0 0 0 0 0 8454 68707 1038891467 1038891467 1038891467 1038891467 484835329 65537 277035467 1038891467 1038891467 1038891467 1038884069 66592 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 69271553 69271553 1731461120 0 0 0 0 0 0 15852 69272608 0 0 0 0 0 0 0 0 0 8455 73991 0 0 0 0 1038877729 66593 554041344 0 0 0 16909 66593 0 0 65537 66593 0 0 0 0 0 0 0 24306 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69271552 0 0 0 0 0 0 0 0 0 0 0 0 65537 65537 65537 277050263 0 0 0 0 0 0 15852 66593 0 0 0 0 0 0 0 0 0 8454 73990 0 0 0 0 1038876673 65537 554041344 0 0 0 15852 65537 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 138543105 69271553 69282120 0 0 0 0 0 0 15852 69272608 0 0 0 0 0 0 0 0 0 8455 73991 0 0 0 0 1038877729 66593 554041344 0 0 0 16908 66593 0 0 65537 66592 0 0 0 0 0 0 0 24306 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69206016 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038887239 65537 65537 1177354240 0 0 0 0 0 15852 66592 0 0 0 0 0 0 0 0 0 8454 73990 0 0 0 0 1038876673 65537 554041344 0 0 0 15852 66592 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108177814 277020673 69271553 90899 0 0 0 0 0 15852 69272608 0 0 0 0 0 0 0 0 0 26420 1523738420 0 0 0 0 1038877729 66593 554041344 0 0 0 28533 1523736306 0 0 65537 66593 0 0 0 0 0 0 0 24306 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69271552 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038876672 1662189569 65537 67650 1939210240 0 0 0 0 15852 66593 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038876673 65537 554041344 0 0 0 0 0 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108082688 17966 69271553 69271553 554106880 0 0 0 0 15852 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038877729 66593 554041344 0 0 0 0 0 0 0 65537 66592 0 0 0 0 0 0 0 24306 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69206016 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038876672 0 761856001 65537 81388 0 0 0 0 15852 66592 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038876673 65537 554041344 0 0 0 0 0 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108148224 0 1939281060 69271553 69272608 1592918016 0 0 0 15852 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038877729 66593 554041344 0 0 0 0 0 0 0 65537 66592 1523669714 1523735250 1523669714 1523735250 1523669714 1523735250 1523669714 1523729965 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69271552 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038876672 0 26420 69271553 65537 138507158 0 0 0 15852 66593 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038876673 65537 554041344 0 0 0 0 0 0 0 69271553 69271553 69271553 69271553 69271553 69271553 69271553 69271553 69271553 69271553 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108082688 0 0 1315897345 69271553 69280006 0 0 0 15852 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038877729 66593 554041344 0 0 0 0 0 0 0 65537 65537 65537 65537 65537 65537 65537 65537 65537 65537 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69206016 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038876672 0 0 11625 65537 65537 1038876672 0 0 15852 66592 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038876673 65537 554041344 0 0 0 0 0 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108148224 0 0 29590 415563777 69271553 69294802 0 0 15852 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038877729 66593 554041344 0 0 0 0 0 0 0 65537 66593 0 0 0 0 0 0 0 24306 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69271552 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038876672 0 0 0 1800734785 65537 67649 1800732672 0 15852 66593 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038876673 65537 554041344 0 0 0 0 0 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108082688 0 0 0 22192 69271553 69271553 484769792 0 15852 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038877729 66593 554041344 0 0 0 0 0 0 0 65537 66592 0 0 0 0 0 0 0 24306 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69206016 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038876672 0 0 0 0 900333569 65537 80331 0 15852 66592 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038876673 65537 554041344 0 0 0 0 0 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108148224 0 0 0 0 5284 69271553 69272608 1454440448 15852 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038877729 66593 554041344 0 0 0 0 0 0 0 65537 66593 0 0 0 0 0 0 0 24306 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69271552 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038876672 0 0 0 0 27477 69271553 65537 138505045 15852 66593 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038876673 65537 554041344 0 0 0 0 0 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108082688 0 0 0 0 0 1592918017 69271553 69277893 15852 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038877729 66593 554041344 0 0 0 0 0 0 0 65537 66592 0 0 0 0 0 0 0 24306 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69206016 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038876672 0 0 0 0 0 15852 65537 65537 900349420 66592 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038876673 65537 554041344 0 0 0 0 0 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108148224 0 0 0 0 0 0 554041345 69271553 69277892 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038877729 66593 554041344 0 0 0 0 0 0 0 65537 66593 0 0 0 0 0 0 0 24306 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69271552 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038876672 0 0 0 0 0 0 1939212353 65537 65537 66593 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038876673 65537 554041344 0 0 0 0 0 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108082688 0 0 0 0 0 0 23250 69271553 69271553 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038877729 66593 554041344 0 0 0 0 0 0 0 65537 66592 0 0 0 0 0 0 0 24306 65537 73990 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 69206016 0 0 0 0 0 0 0 0 0 0 0 0 65537 1038876672 0 0 0 0 0 0 0 1177354241 65537 66592 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038876673 65537 554041344 0 0 0 0 0 0 0 69271553 69272608 0 0 0 0 0 0 0 23250 69271553 69280006 0 0 0 0 0 0 0 0 0 0 0 0 1057 66593 69206016 0 0 0 0 0 0 0 0 0 0 0 0 69271553 1108148224 0 0 0 0 0 0 0 9511 69271553 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1038877729 66593 554041344 0 0 0 0 0 554041345 65537 65537 65537 65537 66593 0 0 0 24306 65537 65537 65537 65537 65537 81388 0 0 0 0 0 0 0 0 8454 65537 65537 65537 65537 65537 69271552 0 0 0 0 0 0 0 0 65537 65537 65537 65537 65537 1038876672 0 0 0 0 0 29591 207749121 66593 0 0 0 0 0 0 0 0 0 0 0 0 0 1592918017 65537 65537 65537 65537 65537 1038876672 0 0 0 554106881 69271553 69271553 69271553 69271553 69272608 0 0 0 23250 69271553 69271553 69271553 69271553 69271553 69287404 0 0 0 0 0 0 0 0 8455 66593 66593 66593 66593 66593 69206016 0 0 0 0 0 0 0 0 69271553 69271553 69271553 69271553 69271553 1108082688 0 0 0 0 0 0 1731461121 69272608 0 0 0 0 0 0 0 0 0 0 0 0 0 1523713057 66593 66593 66593 66593 66593 1038876672 0 0 0 1662212818 1523669714 1523735250 1523669714 1523735250 1523670770 0 0 0 29590 1523735250 1523669714 1523735250 1523669714 1523735250 1523673941 0 0 0 0 0 0 0 0 25363 1523735249 1523735250 1523735249 1523735250 1523735249 1592918016 0 0 0 0 0 0 0 0 1523735250 1523669714 1523735250 1523669714 1523735250 1800732672 0 0 0 0 0 0 20079 484778246 0 0 0 0 0 0 0 0 0 0 0 0 0 1939299025 1523735250 1523735249 1523735250 1523735249 1523735250 1800732672 0 0 0) offset: 0 @ 0
"
HintForm display.
HintForm asSketchMorph openInWorld.
PlaybackInvoker initialize.
"
]

{ #category : #'menu ' }
PlaybackInvoker >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add custom menu items to the menu"

	super addCustomMenuItems: aMenu hand: aHandMorph.

	aMenu addLine.
	aMenu addUpdating: #autoStartString  target: self action: #toggleAutoStart.
	aMenu addUpdating: #autoDismissString  target: self action: #toggleAutoDismiss.
	aMenu addUpdating: #postPlaybackImageFeatureString target: self action: #togglePostPlaybackImageFeature.
	aMenu addLine.
	aMenu addUpdating: #appearAtScreenCenterString target: self action: #appearAtScreenCenter.
	aMenu addUpdating: #appearAtContainerOriginString target: self action: #appearAtContainerOrigin.
	aMenu addUpdating: #appearAtButtonPositionString target: self action: #appearAtButtonPosition.

	aMenu addTranslatedList: #(
		-
		('imprint HINT' imprintHintOnForm)
		-
		('show initial picture' adoptInitialPicture )
		('show final picture' adoptFinalPicture )
		('show caption' adoptTextualAppearance)
		-
		('change caption' changeCaption)
		('open for editing' openInRecordingSpace)) translatedNoop
]

{ #category : #initialization }
PlaybackInvoker >> adoptAsCurrentForm: aForm [
	"Make the given form my current form."

	| existing |
	self isFlexed ifTrue: [self removeFlexShell].

	existing := self topLeft.
	scalePoint := 1@1.

	originalForm := aForm.
	rotatedForm := aForm.
	self extent: aForm extent.
	self topLeft: existing.

	self layoutChanged
]

{ #category : #appearance }
PlaybackInvoker >> adoptFinalPicture [
	"Adopt a scaled-down version of the final picture as my icon."

	self installScaledFinalPictureAsIcon
]

{ #category : #appearance }
PlaybackInvoker >> adoptInitialPicture [
	"Adopt a scaled-down version of the initial appearance of the playback theatre as my icon."
	
	self adoptAsCurrentForm: beforeBitmap copy
]

{ #category : #appearance }
PlaybackInvoker >> adoptTextualAppearance [
	"Make the receiver be a textually-emblazoned button."

	self showString: self caption

	
]

{ #category : #'menu ' }
PlaybackInvoker >> appearAtButtonPosition [
	"Arrange for playback to appear at the button's position."

	whereToAppear := #buttonPosition

	

]

{ #category : #'menu ' }
PlaybackInvoker >> appearAtButtonPositionString [
	"Answer a string telling whether the playback window should appear at the button's position."

	^ ((whereToAppear = #buttonPosition)
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'playback at button position' translated
]

{ #category : #'menu ' }
PlaybackInvoker >> appearAtContainerOrigin [
	"Arrange for playback to appear at the the button's contain'er's origin"

	whereToAppear := #containerOrigin

	

]

{ #category : #'menu ' }
PlaybackInvoker >> appearAtContainerOriginString [
	"Answer a string telling whether the playback window should appear at the center of the screen."

	^ ((whereToAppear = #containerOrigin)
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'playback at container origin' translated
]

{ #category : #'menu ' }
PlaybackInvoker >> appearAtScreenCenter [
	"Arrange for playback to appear at the screen center."

	whereToAppear := #screenCenter

	

]

{ #category : #'menu ' }
PlaybackInvoker >> appearAtScreenCenterString [
	"Answer a string telling whether the playback window should appear at the center of the screen."

	^ ((whereToAppear = #screenCenter)
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'playback at screen center' translated
]

{ #category : #accessing }
PlaybackInvoker >> autoDismiss [
	"Answer whether autoDismiss is in effect."

	^ autoDismiss = true
]

{ #category : #'menu ' }
PlaybackInvoker >> autoDismissString [
	"Answer a string telling the status of my autoDismiss."

	^ (autoDismiss
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'auto dismiss' translated
]

{ #category : #accessing }
PlaybackInvoker >> autoStart [
	"Answer whether autoStart is in effect."

	^ autoStart = true
]

{ #category : #'menu ' }
PlaybackInvoker >> autoStartString [
	"Answer a string telling the status of my autoStart."

	^ (autoStart
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'auto start' translated
]

{ #category : #accessing }
PlaybackInvoker >> caption [
	"Answer the caption."

	^ caption
]

{ #category : #'menu ' }
PlaybackInvoker >> changeCaption [
	"Allow the user to edit the caption name for this button.  Create a new button with the new caption."

	| result interimSpace newButton |
	result := FillInTheBlank request: 'Please edit the caption' translated initialAnswer:  caption.
	result isEmptyOrNil ifTrue: [^ self].
	caption := result.
	interimSpace := EventRecordingSpace new.
	interimSpace initializeFromPlaybackButton: self.
	newButton := PlaybackInvoker new initializeFrom: interimSpace.
	self form: newButton imageForm
]

{ #category : #accessing }
PlaybackInvoker >> contentArea [
	"Answer the contentArea."

	^ contentArea
]

{ #category : #'menu ' }
PlaybackInvoker >> defaultNameStemForInstances [
	"Answer a basis for names of default instances of the receiver."

	^ caption
]

{ #category : #accessing }
PlaybackInvoker >> finalPicture [
	"Answer the final picture."

	^ finalPicture
]

{ #category : #notification }
PlaybackInvoker >> fire [
	"Fire the receiver."

	self launchPlayback
]

{ #category : #initialization }
PlaybackInvoker >> imprintHintOnForm [
	"Make me show HINT imprinted on my before-image"

	| anOffset scaledHint combinedBitmap |
	self isFlexed ifTrue: [self removeFlexShell].
	scaledHint := self class hintForm scaledToSize: (0.8 * self extent).
	combinedBitmap := self imageForm deepCopy.
	anOffset := (self extent // 2) -  ((scaledHint width // 2) @ 0).
	scaledHint displayOn: combinedBitmap at: anOffset rule:  Form paint.
	self adoptAsCurrentForm: combinedBitmap
]

{ #category : #accessing }
PlaybackInvoker >> initialPicture [
	"Answer the initial picture."

	^ initialPicture
]

{ #category : #initialization }
PlaybackInvoker >> initializeFrom: anEventRecordingSpace [
	"Initialize the receiver from the given recording space."

	| beforeImage theatreCopy |

	theatreCopy := anEventRecordingSpace veryDeepCopy.
	"Still want to do the below but there are still maddening problems with it."
	"theatreCopy convertToCanonicalForm."

	autoStart := true.
	autoDismiss := true.

	caption := theatreCopy captionString.
	offeringHint := true.

	beforeImage := theatreCopy initialPicture.

	beforeBitmap := beforeImage scaledToSize: (beforeImage extent * 0.3) rounded.

	theatreCopy rewind.
	contentArea := theatreCopy initialContentArea veryDeepCopy.
	tape := theatreCopy eventRecorder tape veryDeepCopy.
	caption := theatreCopy captionString.

	theatreCopy balloonHelpString ifNotNil:
		[:t | self setBalloonText: t].

	self form: beforeBitmap.

	initialPicture := anEventRecordingSpace initialPicture veryDeepCopy.
	finalPicture := anEventRecordingSpace finalPicture veryDeepCopy.

	postPlaybackImageFeature := false.

	self on: #mouseUp send: #launchPlayback to: self


	
]

{ #category : #appearance }
PlaybackInvoker >> installScaledFinalPictureAsIcon [
	"Like de selector say."

	self adoptAsCurrentForm: (finalPicture scaledToSize: (finalPicture extent * 0.5) rounded)
]

{ #category : #'halos and balloon help' }
PlaybackInvoker >> isLikelyRecipientForMouseOverHalos [
	"Nein, danke."

	^ false
]

{ #category : #initialization }
PlaybackInvoker >> launchPlayback [
	"Launch a playback window."

	EventPlaybackSpace new launchFrom: self

]

{ #category : #'menu ' }
PlaybackInvoker >> offeringHintString [
	"Answer a string telling the status of my offeringHint."

	^ (offeringHint
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'offering hint'
]

{ #category : #'menu ' }
PlaybackInvoker >> openInRecordingSpace [
	"Open a new EventRecordingSpace based on the receiver."

	EventRecordingSpace openFromPlaybackButton: self
]

{ #category : #notification }
PlaybackInvoker >> playbackConcludedIn: aPlaybackSpace [
	"A playback invoked by the receiver has concluded; if appropriate, change the appearance of the receiver."

	postPlaybackImageFeature == true ifTrue:
		[self installScaledFinalPictureAsIcon]
	
]

{ #category : #'menu ' }
PlaybackInvoker >> postPlaybackImageFeatureString [
	"Answer a string telling whether the playback button should be a 50% rendition of the final bitmap after an invoked playback has ended"

	^ ((postPlaybackImageFeature = true)
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'post-playback feature' translated
]

{ #category : #appearance }
PlaybackInvoker >> showString: aString [ 
	"Make the receiver show the given string."

	| str rec |
	str := StringMorph contents: aString font: Preferences standardEToysButtonFont.

	rec := RectangleMorph new extent: (str extent + (10@10)); color:  (Color r: 0.677 g: 0.935 b: 0.484);  borderWidth: 1; yourself.
	rec addMorphBack: str.
	rec useRoundedCorners.
	str center: rec center.
	self form: rec imageForm

]

{ #category : #accessing }
PlaybackInvoker >> tape [
	"Answer the tape"

	^ tape
]

{ #category : #'menu ' }
PlaybackInvoker >> toggleAutoDismiss [
	"Toggle my autoDismiss state."

	autoDismiss := autoDismiss not
]

{ #category : #'menu ' }
PlaybackInvoker >> toggleAutoStart [
	"Toggle my autoStart state."

	autoStart := autoStart not
]

{ #category : #'menu ' }
PlaybackInvoker >> togglePostPlaybackImageFeature [
	"Toggle the setting of the postPlaybackImage feature."

	postPlaybackImageFeature := (postPlaybackImageFeature = true) not
]

{ #category : #accessing }
PlaybackInvoker >> whereToAppear [
	"Answer a symbol designating where to appear."

	whereToAppear ifNil: [whereToAppear := #buttonPosition].
	^ whereToAppear
]
