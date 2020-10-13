"
This is the AppRegistry class for the sound system.

A sound system offers a small protocol for playing sounds and making beeps and works like a facade towards the rest of Squeak. A sound system is registered in this registry and can be accessed by ""SoundService default"". This way we decouple the sound system from the rest of Squeak and make it pluggable. It also is a perfect spot to check for the Preference class>>soundsEnabled.
"
Class {
	#name : #SoundService,
	#superclass : #AppRegistry,
	#classVars : [
		'SoundEnabled'
	],
	#category : #'System-Applications'
}

{ #category : #playing }
SoundService class >> beep [

	self soundEnabled ifFalse: [^ self].

	self defaultOrNil ifNotNil: [:soundSystem | soundSystem beep].
]

{ #category : #accessing }
SoundService class >> default [
	"This app registry returns instances instead of classes."
	
	| cls |
	cls := super default.
	^ cls new
]

{ #category : #accessing }
SoundService class >> default: aClassOrNil [
	"See #default. This app registry returns instances instead of classes. Yet, make sure to only store classes so that always fresh instances will be returned."
	
	^ super default: (aClassOrNil ifNotNil: [:obj |
		obj isBehavior
			ifTrue: [obj]
			ifFalse: [obj class]])
]

{ #category : #accessing }
SoundService class >> defaultOrNil [
	"This app registry returns instances instead of classes."
	
	^ super defaultOrNil ifNotNil: [:default | default new]
]

{ #category : #playing }
SoundService class >> playSound: sound [

	self soundEnabled ifFalse: [^ self].

	self defaultOrNil ifNotNil: [:soundSystem |
		soundSystem playSound: sound].
]

{ #category : #preferences }
SoundService class >> soundEnabled [
	<preference: 'Enable sound'
		category: 'media'
		description: 'If false, all sound playing is disabled'
		type: #Boolean>
	^SoundEnabled ifNil: [true]
]

{ #category : #preferences }
SoundService class >> soundEnabled: aBoolean [
	SoundEnabled := aBoolean
]

{ #category : #preferences }
SoundService class >> soundEnablingString [
	^ self soundEnabled
		ifFalse:
			['turn sound on' translated]
		ifTrue:
			['turn sound off' translated]
]

{ #category : #playing }
SoundService class >> stop [

	self defaultOrNil ifNotNil: [:soundSystem |
		soundSystem shutDown].
]

{ #category : #preferences }
SoundService class >> toggleSoundEnabled [
	self soundEnabled: self soundEnabled not
]
