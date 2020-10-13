Class {
	#name : #LedTimerMorph,
	#superclass : #LedMorph,
	#instVars : [
		'counting',
		'startSeconds'
	],
	#category : #'MorphicExtras-Leds'
}

{ #category : #'new-morph participation' }
LedTimerMorph class >> includeInNewMorphMenu [

	^false
]

{ #category : #accessing }
LedTimerMorph >> continue [

	counting := true
]

{ #category : #initialization }
LedTimerMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	counting := false.
	startSeconds := Time totalSeconds
]

{ #category : #accessing }
LedTimerMorph >> pause [

	counting ifTrue: [self updateTime].
	counting := false
]

{ #category : #accessing }
LedTimerMorph >> reset [

	startSeconds := Time totalSeconds.
	self value: 0.
]

{ #category : #accessing }
LedTimerMorph >> resume [

	counting ifFalse: [
		counting := true.
		startSeconds :=  (Time totalSeconds) - self value]
]

{ #category : #'stepping and presenter' }
LedTimerMorph >> start [

	counting := true
]

{ #category : #'stepping and presenter' }
LedTimerMorph >> step [

	flash
		ifTrue: [super step]
		ifFalse: [
			counting ifTrue: [self updateTime]]
]

{ #category : #'stepping and presenter' }
LedTimerMorph >> stepTime [

	^ 1000
]

{ #category : #'stepping and presenter' }
LedTimerMorph >> stop [

	counting ifTrue: [self updateTime].
	counting := false.
]

{ #category : #'stepping and presenter' }
LedTimerMorph >> updateTime [

	self value:  Time totalSeconds - startSeconds.
	self changed
]
