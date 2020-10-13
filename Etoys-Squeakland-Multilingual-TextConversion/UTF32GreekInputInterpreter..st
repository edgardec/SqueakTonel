Class {
	#name : #UTF32GreekInputInterpreter,
	#superclass : #UTF32InputInterpreter,
	#category : #'Etoys-Squeakland-Multilingual-TextConversion'
}

{ #category : #'as yet unclassified' }
UTF32GreekInputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [ 
	| keyValue |
	keyValue := evtBuf at: 6.
	keyValue < 256
		ifTrue: [^Character value: keyValue].
	^ Character leadingChar: GreekEnvironment leadingChar code: keyValue
]
