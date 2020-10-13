Class {
	#name : #NoInputInterpreter,
	#superclass : #KeyboardInputInterpreter,
	#category : #'Multilingual-TextConversion'
}

{ #category : #keyboard }
NoInputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [



	| keyValue |

	keyValue := evtBuf third.

	^ keyValue asCharacter.


]
