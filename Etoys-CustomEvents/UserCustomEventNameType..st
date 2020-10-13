"
This is a data type that enumerates user-defined custom event names.

You can turn off the display of such events in the script status popups by turning off the

	allowEtoyUserCustomEvents
	
Preference.
"
Class {
	#name : #UserCustomEventNameType,
	#superclass : #SymbolListType,
	#category : #'Etoys-CustomEvents'
}

{ #category : #'class initialization' }
UserCustomEventNameType class >> allowEtoyUserCustomEventsPreferenceChanged [
	Cursor wait showWhile: [ Vocabulary changeMadeToViewerAdditions ]
]

{ #category : #'class initialization' }
UserCustomEventNameType class >> initialize [
	Vocabulary embraceAddedTypeVocabularies.
	Preferences
		addPreference: #allowEtoyUserCustomEvents
		categories:  #('scripting')
		default: false
		balloonHelp: 'If true, you can define your own events that can trigger scripts within a World.'
		projectLocal:  false
		changeInformee:  self
		changeSelector: #allowEtoyUserCustomEventsPreferenceChanged
]

{ #category : #queries }
UserCustomEventNameType >> choices [
	"Answer an alphabetized list of known user custom event selectors"

	| choices |
	choices := ScriptingSystem userCustomEventNames.
	^choices isEmpty ifTrue: [ #('no event') ] ifFalse: [ choices ]
]

{ #category : #initialization }
UserCustomEventNameType >> initialize [
	"Initialize the CustomEvents vocabulary"

	super initialize.
	self vocabularyName: #CustomEvents
]

{ #category : #tiles }
UserCustomEventNameType >> representsAType [
	"Answer whether this vocabulary represents an end-user-sensible data type"

	^true
]
