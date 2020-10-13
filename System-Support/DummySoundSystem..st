"
This is a dummy sound system registered in SoundService to absorb all sound playing and to use the primitive beep instead of sampled sounds when playing a beep.
"
Class {
	#name : #DummySoundSystem,
	#superclass : #AbstractSoundSystem,
	#category : #'System-Support'
}

{ #category : #'class initialization' }
DummySoundSystem class >> initialize [
	SoundService register: self.
]

{ #category : #'class initialization' }
DummySoundSystem class >> unload [
	SoundService unregister: self.
]

{ #category : #playing }
DummySoundSystem >> beep [
	"Make a primitive beep."

	Beeper beepPrimitive
]

{ #category : #playing }
DummySoundSystem >> playSampledSound: samples rate: rate [
	"Do nothing."
	
]

{ #category : #playing }
DummySoundSystem >> playSound: sound [
	"Do nothing."
]

{ #category : #playing }
DummySoundSystem >> playSoundNamed: soundName [
	"Do nothing."
]

{ #category : #playing }
DummySoundSystem >> playSoundNamed: soundName ifAbsentReadFrom: aifFileName [
	"Do nothing."
]

{ #category : #playing }
DummySoundSystem >> playSoundNamedOrBeep: soundName [ 
	"There is no sound support, so we make the beep."

	self beep
]

{ #category : #misc }
DummySoundSystem >> randomBitsFromSoundInput: bitCount [
	"I'm not sure what the right thing to do here is."

	self error: 'Can not provide random data.'
]

{ #category : #misc }
DummySoundSystem >> sampledSoundChoices [
	"No choices other than this."

	^ #('silence')
]

{ #category : #misc }
DummySoundSystem >> soundNamed: soundName [
	"There are no sounds to look up."

	^ nil
]
