Class {
	#name : #UTF32CNInputInterpreter,
	#superclass : #KeyboardInputInterpreter,
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
UTF32CNInputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [ 
	| keyValue |
	keyValue := evtBuf at: 6.
	keyValue < 256
		ifTrue: [^Character value: keyValue].
	^ Character leadingChar: SimplifiedChineseEnvironment leadingChar code: keyValue
]
