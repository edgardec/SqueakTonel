Class {
	#name : #ChatRecorder,
	#superclass : #SoundRecorder,
	#category : #'Nebraska-Audio Chat'
}

{ #category : #'as yet unclassified' }
ChatRecorder >> initialize [
	
	"setting a higher desired recording rate seemed to fix certain powerbook problems.
	I'm still trying to understand it all, but there it is for now"

	super initialize.
	samplingRate := 44100.


]

{ #category : #'as yet unclassified' }
ChatRecorder >> pause [
	"Go into pause mode. The record level continues to be updated, but no sound is recorded."

	paused := true.
	((currentBuffer ~~ nil) and: [nextIndex > 1])
		ifTrue: [self emitPartialBuffer.
				self allocateBuffer].

	soundPlaying ifNotNil: [
		soundPlaying pause.
		soundPlaying := nil].

	self stopRecording.

	"Preferences canRecordWhilePlaying ifFalse: [self stopRecording]."

]

{ #category : #'as yet unclassified' }
ChatRecorder >> playback [
	"Playback the sound that has been recorded."

	self pause.
	soundPlaying := self recordedSound ifNil: [^self].
	soundPlaying play.

]

{ #category : #accessing }
ChatRecorder >> recordedSound: aSound [

	self clearRecordedSound.
	recordedSound := aSound.
]

{ #category : #'as yet unclassified' }
ChatRecorder >> resumeRecording [
	"Continue recording from the point at which it was last paused."

	self startRecording.
	paused := false.

]
