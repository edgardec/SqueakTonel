Class {
	#name : #ISO88592InputInterpreter,
	#superclass : #KeyboardInputInterpreter,
	#instVars : [
		'converter'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #'initialize-release' }
ISO88592InputInterpreter >> initialize [

	converter := ISO88592TextConverter new.

]

{ #category : #keyboard }
ISO88592InputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [

	| keyValue |
	keyValue := evtBuf third.
	^ converter toSqueak: keyValue asCharacter.

]
