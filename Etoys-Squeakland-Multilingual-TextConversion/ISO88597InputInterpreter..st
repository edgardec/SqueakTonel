Class {
	#name : #ISO88597InputInterpreter,
	#superclass : #KeyboardInputInterpreter,
	#instVars : [
		'converter'
	],
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
ISO88597InputInterpreter >> initialize [

	converter := ISO88597TextConverter new.

]

{ #category : #'as yet unclassified' }
ISO88597InputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [

	| keyValue |
	keyValue := evtBuf third.
	^ converter toSqueak: keyValue asCharacter.

]
