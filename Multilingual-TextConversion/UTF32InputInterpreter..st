Class {
	#name : #UTF32InputInterpreter,
	#superclass : #KeyboardInputInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #keyboard }
UTF32InputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [ 
	"Fall back to internal char-code if char is 0"
	^(evtBuf at: 6) > 0
		ifTrue: [(evtBuf at: 6) asCharacter]
		ifFalse:
			[(evtBuf at: 3) asCharacter].

]
