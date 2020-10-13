"
I am a queue for sound - give me a bunch of sounds to play and I will play them one at a time in the order that they are received.

Example:
""Here is a simple example which plays two sounds three times.""
| clink warble queue |
clink := SampledSound soundNamed: 'clink'.
warble := SampledSound soundNamed: 'warble'.
queue := QueueSound new.
3 timesRepeat:[
	queue add: clink; add: warble
].
queue play.

Structure:
 startTime 		Integer -- if present, start playing when startTime <= Time millisecondClockValue
							(schedule the sound to play later)
 sounds			SharedQueue -- the synchronized list of sounds.
 currentSound	AbstractSound -- the currently active sound
 done			Boolean -- am I done playing ?

Other:
You may want to keep track of the queue's position so that you can feed it at an appropriate rate. To do this in an event driven way, modify or subclass nextSound to notify you when appropriate. You could also poll by checking currentSound, but this is not recommended for most applications.


"
Class {
	#name : #QueueSound,
	#superclass : #AbstractSound,
	#instVars : [
		'startTime',
		'sounds',
		'currentSound',
		'done'
	],
	#category : #'Sound-Synthesis'
}

{ #category : #accessing }
QueueSound >> add: aSound [
	self sounds nextPut: aSound.
	^ aSound
]

{ #category : #accessing }
QueueSound >> currentSound [
	^ currentSound ifNil: [currentSound := self nextSound]
]

{ #category : #accessing }
QueueSound >> currentSound: aSound [
	currentSound := aSound
]

{ #category : #'sound generation' }
QueueSound >> doControl [
	super doControl.
	self currentSound ifNotNil: [:curSound | curSound doControl]
]

{ #category : #accessing }
QueueSound >> done: aBoolean [
	done := aBoolean
]

{ #category : #initialization }
QueueSound >> initialize [
	super initialize.
	sounds := SharedQueue new.
	done := false.
	startTime := Time millisecondClockValue
]

{ #category : #'sound generation' }
QueueSound >> mixSampleCount: n into: aSoundBuffer startingAt: startIndex leftVol: leftVol rightVol: rightVol [
	"Play a collection of sounds in sequence."

	| finalIndex i remaining count rate |
	self currentSound ifNil: [^ self].  "already done"
	self startTime > Time millisecondClockValue ifTrue: [^ self].
	rate := self samplingRate.
	finalIndex := (startIndex + n) - 1.
	i := startIndex.
	[i <= finalIndex] whileTrue: [
		[
			self currentSound ifNil: [^ self].
			(remaining := self currentSound samplesRemaining) <= 0]
				whileTrue: [self currentSound: self nextSound].
		count := (finalIndex - i) + 1.
		remaining < count ifTrue: [count := remaining].
		self currentSound mixSampleCount: count into: aSoundBuffer startingAt: i leftVol: leftVol rightVol: rightVol.
		i := i + count]
]

{ #category : #'sound generation' }
QueueSound >> nextSound [
	| answer |
	sounds isEmpty ifTrue: [^ nil].
	answer := sounds next.
	answer reset.
	^ answer
]

{ #category : #'sound generation' }
QueueSound >> reset [
	super reset.
	self currentSound
		ifNil: [self currentSound: self nextSound]
		ifNotNil: [:curSound | curSound reset]
]

{ #category : #'sound generation' }
QueueSound >> samplesRemaining [
	(done and: [self sounds isEmpty])
		ifTrue: [^ 0]
		ifFalse: [^ 1000000].

]

{ #category : #accessing }
QueueSound >> sounds [
	^ sounds
]

{ #category : #accessing }
QueueSound >> startTime [
	^ startTime
]

{ #category : #accessing }
QueueSound >> startTime: anInteger [
	startTime := anInteger
]
