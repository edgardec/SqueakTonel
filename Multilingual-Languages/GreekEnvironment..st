"
This class provides the support for Greek.  It is here, but most of the methods are not implemented yet.

"
Class {
	#name : #GreekEnvironment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-Languages'
}

{ #category : #'subclass responsibilities' }
GreekEnvironment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	
	^#('el' )
]
