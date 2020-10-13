"
Obsolete -- the functionality of this class was subsumed in March 2007 by class PlaybackInvoker.

Class retained ""temporarily"" in support of pre-existing content.  Probably can now be gotten rid of...


Formerly:

A button which, when clicked, will open up an event-playback space, in which the user can play an event ""movie"".

caption - a String --the label beneath the button's icon.

contentArea - a Worldlet - a veryDeepCopy of the contentArea of the contributing MentoringEventRecorder at the time the recording was made.

tape  - an Array of MorphicEvent objects.

voiceRecorder - a copy of the voiceRecorder of the contributing MentoringEventRecorder.
"
Class {
	#name : #EventPlaybackButton,
	#superclass : #IconicButton,
	#instVars : [
		'caption',
		'contentArea',
		'tape',
		'autoStart',
		'autoDismiss',
		'initialPicture',
		'finalPicture'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #'menu ' }
EventPlaybackButton >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add custom menu items to the menu"

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu addUpdating: #autoStartString  target: self action: #toggleAutoStart.
	aCustomMenu addUpdating: #autoDismissString  target: self action: #toggleAutoDismiss.
	aCustomMenu addLine.

	aCustomMenu addLine.
	aCustomMenu add: 'change caption' translated target: self action: #changeCaption.
	aCustomMenu add: 'open in recording theatre' translated target: self action: #openInRecordingSpace
]

{ #category : #accessing }
EventPlaybackButton >> autoDismiss: anObject [
	"Set the value of autoDismiss"

	autoDismiss := anObject
]

{ #category : #'menu ' }
EventPlaybackButton >> autoDismissString [
	"Answer a string telling the status of my autoDismiss."

	^ ((autoDismiss == true)
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'auto dismiss' translated
]

{ #category : #accessing }
EventPlaybackButton >> autoStart: anObject [
	"Set the value of autoStart"

	autoStart := anObject
]

{ #category : #'menu ' }
EventPlaybackButton >> autoStartString [
	"Answer a string telling the status of my autoStart."

	^ ((autoStart == true)
		ifTrue:
			['<yes>']
		ifFalse:
			['<no>']), 'auto start' translated
]

{ #category : #accessing }
EventPlaybackButton >> caption [
	"Answer the caption."

	^ caption
]

{ #category : #accessing }
EventPlaybackButton >> caption: anObject [
	"Set the value of caption"

	caption := anObject
]

{ #category : #'menu ' }
EventPlaybackButton >> changeCaption [
	"Allow the user to edit the caption name for this button.  Create a new button with the new caption."

	| result interimSpace newButton |
	result := FillInTheBlank request: 'Please edit the caption' translated initialAnswer:  caption.
	result isEmptyOrNil ifTrue: [^ self].
	caption := result.
	interimSpace := EventRecordingSpace new.
	interimSpace initializeFromPlaybackButton: self.
	newButton := self class new initializeFrom: interimSpace.
	self labelGraphic: newButton imageForm
]

{ #category : #accessing }
EventPlaybackButton >> contentArea [
	"Answer my contentArea, a Worldlet."

	^ contentArea
]

{ #category : #initialization }
EventPlaybackButton >> duration [
	"Answer what the duration of event-movie represented by the receiver would be."

	^ EventRecorderMorph durationOfTape: tape
]

{ #category : #accessing }
EventPlaybackButton >> durationInMilliseconds [
	"Answer the duration of the activity represented by the receiver, in milliseconds."

	^ MentoringEventRecorder durationInMillisecondsOfTape:  tape
]

{ #category : #accessing }
EventPlaybackButton >> finalPicture [
	"Answer the value of finalPicture"

	^ finalPicture
]

{ #category : #accessing }
EventPlaybackButton >> finalPicture: anObject [
	"Set the value of finalPicture"

	finalPicture := anObject
]

{ #category : #accessing }
EventPlaybackButton >> initialPicture [
	"Answer the value of initialPicture"

	^ initialPicture
]

{ #category : #accessing }
EventPlaybackButton >> initialPicture: anObject [
	"Set the value of initialPicture"

	initialPicture := anObject
]

{ #category : #initialization }
EventPlaybackButton >> initializeFrom: anEventRecordingSpace [
	"Initialize the receiver to be a button which will play the sequence currenty defined in the given event-recording space."

	self initializeToShow: anEventRecordingSpace initialContentArea withLabel: anEventRecordingSpace captionString andSend: #launchPlayback to: self.
	"Icon is made with the recording space in whatever state the user prefers -- may be at the beginning or end of playback, for example."

	autoStart := true.
	autoDismiss := true.

	anEventRecordingSpace rewind.
	contentArea := anEventRecordingSpace initialContentArea veryDeepCopy.
	tape := anEventRecordingSpace eventRecorder tape veryDeepCopy.
	caption := anEventRecordingSpace captionString veryDeepCopy.
	initialPicture := anEventRecordingSpace initialPicture veryDeepCopy.
	finalPicture := anEventRecordingSpace finalPicture veryDeepCopy.

	self on: #click send: nil to: nil.  "Undo generic IconicButton evt handler"
	self target: self; actionSelector: #launchPlayback; arguments: #().
	self actWhen: #buttonUp.

	anEventRecordingSpace balloonHelpString ifNotNil:
		[:t | self setBalloonText: t]


	
]

{ #category : #initialization }
EventPlaybackButton >> launchPlayback [
	"Launch a playback window."

	| aPlaybackSpace |
	aPlaybackSpace := EventPlaybackSpace new.
	aPlaybackSpace setProperty: #originatingButton toValue: self.
	aPlaybackSpace contentArea: contentArea veryDeepCopy tape: tape veryDeepCopy.
	aPlaybackSpace captionString: caption.
	aPlaybackSpace position: 0@0.
	aPlaybackSpace rewind.
	aPlaybackSpace autoStart: (autoStart == true).
	aPlaybackSpace autoDismiss: (autoDismiss == true).

	aPlaybackSpace openInWorld.
	autoStart == true ifTrue: [aPlaybackSpace play]

]

{ #category : #button }
EventPlaybackButton >> openInRecordingSpace [
	"Open a new EventRecordingSpace based on the receiver."

	EventRecordingSpace openFromPlaybackButton: self
]

{ #category : #initialization }
EventPlaybackButton >> playbackConcludedIn: aPlaybackSpace [
	"A playback invoked by the receiver has concluded; if appropriate, change the appearance of the receiver."
]

{ #category : #'event roll' }
EventPlaybackButton >> putEventsOnto: aStream [
	"Put events onto a stream that will create a revised event tape for the an event theatre."

	| aNewEvent anEventRoll |
	aNewEvent :=  MediaPlayEvent new.
	anEventRoll := self ownerThatIsA: EventRollMorph.
	aNewEvent setType: #startEventPlayback argument: self hand: nil stamp: (anEventRoll timeStampForCurrentPositionOf: self).
	aStream nextPut: aNewEvent
]

{ #category : #'drag and drop' }
EventPlaybackButton >> suitableForDroppingIntoEventRoll [
	"Answer whether the receiver is suitable for dropping into an eventRoll"

	^ true
]

{ #category : #accessing }
EventPlaybackButton >> tape [
	"Answer the tape"

	^ tape
]

{ #category : #accessing }
EventPlaybackButton >> tape: anObject [
	"Set the value of tape"

	tape := anObject
]

{ #category : #'menu ' }
EventPlaybackButton >> toggleAutoDismiss [
	"Toggle my autoDismiss state."

	autoDismiss := (autoDismiss == true)  not
]

{ #category : #'menu ' }
EventPlaybackButton >> toggleAutoStart [
	"Toggle my autoStart state."

	autoStart := (autoStart == true) not
]
