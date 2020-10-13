Class {
	#name : #KeyboardInputInterpreter,
	#superclass : #Object,
	#pools : [
		'EventSensorConstants'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #keyboard }
KeyboardInputInterpreter >> nextCharFrom: sensor firstEvt: evtBuf [

	self subclassResponsibility.


]
