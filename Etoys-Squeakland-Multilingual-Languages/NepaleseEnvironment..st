Class {
	#name : #NepaleseEnvironment,
	#superclass : #LanguageEnvironment,
	#category : #'Etoys-Squeakland-Multilingual-Languages'
}

{ #category : #'subclass responsibilities' }
NepaleseEnvironment class >> clipboardInterpreterClass [

	^ UTF8ClipboardInterpreter.

]

{ #category : #'subclass responsibilities' }
NepaleseEnvironment class >> fileNameConverterClass [

	^ UTF8TextConverter.

]

{ #category : #'subclass responsibilities' }
NepaleseEnvironment class >> inputInterpreterClass [
	| platformName |
	platformName := SmalltalkImage current platformName.
	platformName = 'Win32'
		ifTrue: [^ UTF32NPInputInterpreter].
	platformName = 'Mac OS'
		ifTrue: [^ MacUnicodeInputInterpreter].
	platformName = 'unix'
		ifTrue: [^ UTF32NPInputInterpreter].
	^ MacRomanInputInterpreter
]

{ #category : #'subclass responsibilities' }
NepaleseEnvironment class >> leadingChar [

	^ 15.

]

{ #category : #'subclass responsibilities' }
NepaleseEnvironment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	
	^#('ne')
]

{ #category : #'subclass responsibilities' }
NepaleseEnvironment class >> systemConverterClass [

	^ UTF8TextConverter.

]
