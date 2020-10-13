Class {
	#name : #PreferencesTestPreferences,
	#superclass : #Preferences,
	#category : #'Tests-System-Preferences'
}

{ #category : #'class initialization' }
PreferencesTestPreferences class >> initialize [

	super initialize.
	self initializeDictionaryOfPreferences.
]
