"
EncodedCharSet initialize.
LanguageEnvironment resetKnownEnvironments.
Locale switchToID: (LocaleID isoLanguage: 'ru').

"
Class {
	#name : #RussianEnvironment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-Languages'
}

{ #category : #'subclass responsibilities' }
RussianEnvironment class >> clipboardInterpreterClass [

	^ UTF8ClipboardInterpreter.

]

{ #category : #'subclass responsibilities' }
RussianEnvironment class >> fileNameConverterClass [

	^UTF8TextConverter.

]

{ #category : #'subclass responsibilities' }
RussianEnvironment class >> inputInterpreterClass [
	| platformName  |
	platformName := Smalltalk platformName.
	platformName = 'Win32'
		ifTrue: [^UTF32RussianInputInterpreter].
	platformName = 'Mac OS'
		ifTrue: [^ (('10*' match: Smalltalk osVersion)
					and: [(Smalltalk getSystemAttribute: 3) isNil])
				ifTrue: [MacUnicodeInputInterpreter]
				ifFalse: [MacRomanInputInterpreter]].
	platformName = 'unix'
		ifTrue: [^ UTF32RussianInputInterpreter].
	^ MacRomanInputInterpreter
]

{ #category : #'subclass responsibilities' }
RussianEnvironment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	
	^#('ru' )
]

{ #category : #'subclass responsibilities' }
RussianEnvironment class >> systemConverterClass [

	^ UTF8TextConverter
]
