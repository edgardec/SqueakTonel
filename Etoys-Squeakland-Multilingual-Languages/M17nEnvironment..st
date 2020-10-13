"
This class supports multilingual Unicode environments that use UTF-8 encoding. Such a large scope implies the use of external fonts and external rendering engines like Pango. Currently, it is useful for Indic and a few Asian languages.
"
Class {
	#name : #M17nEnvironment,
	#superclass : #LanguageEnvironment,
	#category : #'Etoys-Squeakland-Multilingual-Languages'
}

{ #category : #'subclass responsibilities' }
M17nEnvironment class >> clipboardInterpreterClass [

	^ UTF8ClipboardInterpreter.

]

{ #category : #'subclass responsibilities' }
M17nEnvironment class >> fileNameConverterClass [

	^ UTF8TextConverter.

]

{ #category : #'subclass responsibilities' }
M17nEnvironment class >> inputInterpreterClass [
	| platformName |
	platformName := SmalltalkImage current platformName.
	platformName = 'MacOS'
			ifTrue: [^MacRomanInputInterpreter].
	^M17nInputInterpreter.
]

{ #category : #'subclass responsibilities' }
M17nEnvironment class >> leadingChar [

	^ Unicode leadingChar.

]

{ #category : #'subclass responsibilities' }
M17nEnvironment class >> supportedLanguages [
	"Include languages that will not conflict with other languages"
	
	^#('bn' 'gu' 'hi' 'kn' 'ml' 'mr' 'ta' 'te' 'sa')
]

{ #category : #'subclass responsibilities' }
M17nEnvironment class >> systemConverterClass [

	^ UTF8TextConverter.
]
