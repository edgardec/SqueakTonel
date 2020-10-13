Class {
	#name : #CP1253InputInterpreter,
	#superclass : #KeyboardInputInterpreter,
	#instVars : [
		'converter'
	],
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
CP1253InputInterpreter >> initialize [

	converter := CP1253TextConverter new.

]

{ #category : #'as yet unclassified' }
CP1253InputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [

	| keyValue |
	keyValue := evtBuf third.
	^ converter toSqueak: keyValue asCharacter.

]
