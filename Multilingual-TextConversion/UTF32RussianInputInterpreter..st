Class {
	#name : #UTF32RussianInputInterpreter,
	#superclass : #UTF32InputInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #keyboard }
UTF32RussianInputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [ 
	| keyValue |
	keyValue := evtBuf at: 6.
	keyValue < 256
		ifTrue: [^Character value: keyValue].
	^ Character leadingChar: RussianEnvironment leadingChar code: keyValue
]
