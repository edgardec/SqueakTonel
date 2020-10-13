"
This empty class just makes the fact explicit that this object is a sound object that needs can be played. Just like other sounds.

Example: (MIDISound fromFileNamed: 'some.mid') play
"
Class {
	#name : #MIDISound,
	#superclass : #ScorePlayer,
	#category : #'Sound-Scores'
}

{ #category : #playing }
MIDISound >> play [
	"The base class ScorePlayer has two interfaces: a sound and a sound player. Choose the right interface depending on whether MIDI support is present."
	
	SoundService soundEnabled ifFalse: [^ self].
	
	SimpleMIDIPort useMIDIDeviceForOutput ifTrue: [
		[self openMIDIPort]
			on: Error
			do: [
				SimpleMIDIPort askForDefault.
				[self openMIDIPort]
					on: Error
					do: [
						self inform: 'Use of MIDI device is not working. Using custom synthesis.\Go to preferences to change again.' withCRs.
						SimpleMIDIPort useMIDIDeviceForOutput: false]]].

	self reset; resumePlaying.
]
