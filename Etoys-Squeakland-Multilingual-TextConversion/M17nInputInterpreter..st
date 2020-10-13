"
A flexible input interpreter that is tuned to variations in keyboard events coming in from the VM.

Old VMs passed only a 8-bit keycode evt[3] and 0 in evt[6]. This code could be in any one of the code pages. On Mac, this used mac-roman, while on Unix, this could be ASCII or UTF-8 depending on the locale.

Newer VMs pass UTF32 in evt[6]. This can be 'cooked' based on the current language setting to generate a Character.
"
Class {
	#name : #M17nInputInterpreter,
	#superclass : #KeyboardInputInterpreter,
	#instVars : [
		'converter'
	],
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
M17nInputInterpreter >> initialize [

	converter := UTF8TextConverter new.
]

{ #category : #'as yet unclassified' }
M17nInputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [ 
	| keyValue |
	keyValue := evtBuf at: 6.
	0 = keyValue ifTrue: [ ^self nextUtf8Char: sensor firstEvt: evtBuf ].
	256 > keyValue ifTrue: [ ^keyValue asCharacter ].
	^ Character leadingChar: (Locale current languageEnvironment leadingChar) code: keyValue
]

{ #category : #'as yet unclassified' }
M17nInputInterpreter >> nextUtf8Char: sensor firstEvt: evtBuf [
	"this code should really go into InputSensor>>fullKey"
	| aCollection bytes peekEvent keyValue type stream multiChar evt |
	self flag: #fixthis.
	keyValue := evtBuf third.
	evtBuf fourth = EventKeyChar ifTrue: [type := #keystroke].
	peekEvent := sensor peekEvent.
	(peekEvent notNil and: [peekEvent fourth = EventKeyDown]) ifTrue: [
		sensor nextEvent.
		peekEvent := sensor peekEvent].

	(type == #keystroke
	and: [peekEvent notNil 
	and: [peekEvent first = EventTypeKeyboard
	and: [peekEvent fourth = EventKeyChar]]]) ifTrue: [
		aCollection := OrderedCollection with: keyValue asCharacter.
		bytes := (keyValue <= 127)
			ifTrue: [ 0 ]
			ifFalse: [ (keyValue bitAnd: 16rE0) = 192
				ifTrue: [ 1 ]
				ifFalse: [ (keyValue bitAnd: 16rF0) = 224
					ifTrue: [ 2 ]
					ifFalse: [ 3 ]
				]
			].
		[bytes > 0] whileTrue: [
			(evt :=  sensor nextEvent) fourth = EventKeyChar ifTrue: [
				bytes := bytes - 1.
				aCollection add: (Character value: evt third)]].
		"aCollection do: [ :each | Transcript show: (each asciiValue hex , ' ')].
		Transcript show: Character cr."
		stream := ReadStream on: (String withAll: aCollection).
		multiChar := converter nextFromStream: stream.
		multiChar isOctetCharacter ifFalse: [ sensor nextEvent ].
		^ multiChar].

	^ keyValue asCharacter
]
