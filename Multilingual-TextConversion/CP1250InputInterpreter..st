Class {
	#name : #CP1250InputInterpreter,
	#superclass : #KeyboardInputInterpreter,
	#instVars : [
		'converter'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #'initialize-release' }
CP1250InputInterpreter >> initialize [

	converter := CP1250TextConverter new.

]

{ #category : #keyboard }
CP1250InputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [

	"Input from the Czech keyboard under Windows doesn't correspond to cp-1250 or iso-8859-2 encoding!"

	| keyValue |

	keyValue := evtBuf third.
	^ converter toSqueak: keyValue asCharacter.


]
