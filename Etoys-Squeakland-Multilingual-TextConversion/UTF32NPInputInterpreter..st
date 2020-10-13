Class {
	#name : #UTF32NPInputInterpreter,
	#superclass : #KeyboardInputInterpreter,
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #all }
UTF32NPInputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [ 
	| keyValue |
	keyValue := evtBuf at: 6.
	keyValue < 256
		ifTrue: [^Character value: keyValue].
	^ Character leadingChar: NepaleseEnvironment leadingChar code: keyValue
]
