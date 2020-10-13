Class {
	#name : #FrameRateMorph,
	#superclass : #StringMorph,
	#instVars : [
		'lastDisplayTime',
		'framesSinceLastDisplay'
	],
	#category : #'MorphicExtras-Demo'
}

{ #category : #scripting }
FrameRateMorph class >> authoringPrototype [
	"Answer a morph representing a prototypical instance of the receiver"

	| aMorph |
	aMorph := self new.
	aMorph color: Color blue.
	aMorph step.
	^ aMorph
]

{ #category : #'parts bin' }
FrameRateMorph class >> descriptionForPartsBin [
	^ self partName:	'FrameRate' translatedNoop
		categories:		{'Just for Fun' translatedNoop}
		documentation:	'A readout that allows you to monitor the frame rate of your system' translatedNoop
]

{ #category : #'class initialization' }
FrameRateMorph class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'class initialization' }
FrameRateMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl |
			cl registerQuad: {
					#FrameRateMorph. #authoringPrototype. 'Frame Rate' translatedNoop.
					'An indicator of how fast your system is running' translatedNoop}
				forFlapNamed: 'Widgets'.
			cl registerQuad: {
					#FrameRateMorph. #authoringPrototype. 'Frame Rate' translatedNoop.
					'An indicator of how fast your system is running' translatedNoop}
				forFlapNamed: 'Supplies']
]

{ #category : #'class initialization' }
FrameRateMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #initialization }
FrameRateMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	lastDisplayTime := 0.
	framesSinceLastDisplay := 0.
	self font: (Preferences standardMenuFont emphasized: 1).

]

{ #category : #'parts bin' }
FrameRateMorph >> initializeToStandAlone [
	"Initialize the receiver as a stand-alone entity"

	super initializeToStandAlone.
	self color: Color blue.
	self font: (Preferences standardMenuFont emphasized: 1).
	self step.

]

{ #category : #'stepping and presenter' }
FrameRateMorph >> step [
	"Compute and display (every half second or so) the current framerate"

	| now mSecs mSecsPerFrame framesPerSec newContents |
	framesSinceLastDisplay := framesSinceLastDisplay + 1.
	now := Time millisecondClockValue.
	mSecs := now - lastDisplayTime.
	(mSecs > 500 or: [mSecs < 0 "clock wrap-around"]) ifTrue: 
		[mSecsPerFrame := mSecs // framesSinceLastDisplay.
		framesPerSec := (framesSinceLastDisplay * 1000) // mSecs.
		newContents := mSecsPerFrame printString, ' mSecs (', framesPerSec printString, ' frame', (framesPerSec = 1 ifTrue: [''] ifFalse: ['s']), '/sec)'.
		self contents: newContents.
		lastDisplayTime := now.
		framesSinceLastDisplay := 0]
	ifFalse:
		["Ensure at least one pixel is drawn per frame"
		Preferences higherPerformance ifTrue: [self invalidRect: (self position extent: 1@1)]]
]

{ #category : #'stepping and presenter' }
FrameRateMorph >> stepTime [
	"Answer the desired time between steps in milliseconds."

	^ 0

]
