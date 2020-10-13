"
This class provides the support for the languages in 'Latin-1' category.  Although we could have different language environments for different languages in the category, so far nobody seriously needed it.

"
Class {
	#name : #Latin1Environment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-Languages'
}

{ #category : #'subclass responsibilities' }
Latin1Environment class >> clipboardInterpreterClass [

	^ UTF8ClipboardInterpreter
]

{ #category : #'subclass responsibilities' }
Latin1Environment class >> defaultEncodingName [
	| platformName osVersion |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	(#('Win32' 'Mac OS' 'ZaurusOS') includes: platformName) 
		ifTrue: [^'iso8859-1'].
	(#('unix') includes: platformName) ifTrue: [^'iso8859-1'].
	^'mac-roman'
]

{ #category : #'subclass responsibilities' }
Latin1Environment class >> fileNameConverterClass [

	^ self systemConverterClass

]

{ #category : #'rendering support' }
Latin1Environment class >> flapTabTextFor: aString [

	^ aString.

]

{ #category : #'rendering support' }
Latin1Environment class >> flapTabTextFor: aString in: aFlapTab [

	^ aString.

]

{ #category : #'subclass responsibilities' }
Latin1Environment class >> inputInterpreterClass [
	| platformName |
	platformName := Smalltalk platformName.
	(platformName = 'Win32')
		ifTrue: [^ (self win32VMUsesUnicode) ifTrue: [UTF32InputInterpreter] ifFalse: [MacRomanInputInterpreter]].
	platformName = 'Mac OS'
		ifTrue: [^ MacUnicodeInputInterpreter].
	platformName = 'unix'
		ifTrue: [^ UTF32InputInterpreter].
	^ MacUnicodeInputInterpreter
]

{ #category : #'language methods' }
Latin1Environment class >> nextPutRightHalfValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

	^ self traditionalCharsetClass nextPutRightHalfValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state.

]

{ #category : #'language methods' }
Latin1Environment class >> nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state [

	^ self traditionalCharsetClass nextPutValue: ascii toStream: aStream withShiftSequenceIfNeededForTextConverterState: state.
]

{ #category : #'subclass responsibilities' }
Latin1Environment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	
	^#('fr' 'es' 'ca' 'eu' 'pt' 'it' 'sq' 'rm' 'nl' 'de' 'da' 'sv' 'no' 'fi' 'fo' 'is' 'ga' 'gd' 'en' 'af' 'sw')
]

{ #category : #'subclass responsibilities' }
Latin1Environment class >> systemConverterClass [

	| platformName osVersion |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk getSystemAttribute: 1002.
	platformName = 'Win32'
		ifTrue: [^ (self win32VMUsesUnicode) ifTrue: [UTF8TextConverter] ifFalse: [ISO88591TextConverter]].
	platformName = 'Mac OS'
		ifTrue: [^ ('10*' match: Smalltalk osVersion)
				ifTrue: [UTF8TextConverter]
				ifFalse: [MacRomanTextConverter]].
	platformName = 'unix'
		ifTrue: [^ UTF8TextConverter].
	^ MacRomanTextConverter
]

{ #category : #'language methods' }
Latin1Environment class >> traditionalCharsetClass [

	^ Latin1.

]
