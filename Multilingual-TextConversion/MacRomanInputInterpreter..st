Class {
	#name : #MacRomanInputInterpreter,
	#superclass : #KeyboardInputInterpreter,
	#instVars : [
		'converter'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #keyboard }
MacRomanInputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [

	| keyValue |
	keyValue := evtBuf third.
	^ keyValue asCharacter.

]
