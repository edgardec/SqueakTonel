Class {
	#name : #ClockMorph,
	#superclass : #StringMorph,
	#instVars : [
		'showSeconds',
		'show24hr'
	],
	#category : #'MorphicExtras-Demo'
}

{ #category : #scripting }
ClockMorph class >> authoringPrototype [
	^ super authoringPrototype contents: Time now printString
]

{ #category : #'parts bin' }
ClockMorph class >> descriptionForPartsBin [
	"Answer a description for use in parts bins."

	^ self partName:	'Digital Clock' translatedNoop
		categories:		{'Just for Fun' translatedNoop}
		documentation:	'A digital clock' translatedNoop
]

{ #category : #'class initialization' }
ClockMorph class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'class initialization' }
ClockMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#ClockMorph,	#authoringPrototype.	'Clock' translatedNoop.			'A simple digital clock' translatedNoop}
						forFlapNamed: 'Supplies'.
						cl registerQuad: {#ClockMorph.	#authoringPrototype.	'Clock' translatedNoop. 'A simple digital clock' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.]
]

{ #category : #'class initialization' }
ClockMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #menu }
ClockMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add toggles for showing-seconds and display-24-hrs to the halo menu"

	"NB:  intentionallyi no super call here!"

	aCustomMenu add: 'change font' translated action: #changeFont.

	aCustomMenu addUpdating: #showingSecondsString action: #toggleShowingSeconds.
	aCustomMenu addUpdating: #displaying24HourString action: #toggleShowing24hr
]

{ #category : #accessing }
ClockMorph >> balloonText [

	^ Date current weekday, ', ', Date current printString
]

{ #category : #initialization }
ClockMorph >> initialize [
	"initialize the state of the receiver"

	super initialize.

	showSeconds := true.
	show24hr := false.
	self font: Preferences standardMenuFont emphasis: 1.
	self step
]

{ #category : #'parts bin' }
ClockMorph >> initializeToStandAlone [
	super initializeToStandAlone.
	showSeconds := false.
	self font: (Preferences standardMenuFont emphasized: 1).
	self step
]

{ #category : #'24hr' }
ClockMorph >> show24hr: aBoolean [
	show24hr := aBoolean
]

{ #category : #seconds }
ClockMorph >> showSeconds: aBoolean [
	showSeconds := aBoolean
]

{ #category : #'stepping and presenter' }
ClockMorph >> step [

	| time |
	super step.
	time := String streamContents: [ :stream |
		| t |
		t := Time now.
		t seconds: t asSeconds. "ignore nanoSeconds"
		t 
			print24: (show24hr == true)
			showSeconds: (showSeconds == true)
			on: stream].
	self contents: time
]

{ #category : #'stepping and presenter' }
ClockMorph >> stepTime [
	"Answer the desired time between steps in milliseconds."

	^999
]

{ #category : #'24hr' }
ClockMorph >> toggleShowing24hr [
	show24hr := (show24hr == true) not

]

{ #category : #seconds }
ClockMorph >> toggleShowingSeconds [
	showSeconds := (showSeconds == true) not

]
