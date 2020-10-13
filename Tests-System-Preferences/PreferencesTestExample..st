"
This class provides an example for how to use preference pragmas.
"
Class {
	#name : #PreferencesTestExample,
	#superclass : #Object,
	#classVars : [
		'BooleanPref',
		'ColorPref',
		'NumericPref',
		'TextPref'
	],
	#category : #'Tests-System-Preferences'
}

{ #category : #preferences }
PreferencesTestExample class >> booleanPref [
	<preference: 'Boolean Preference Example'
		category: 'Examples'
		description: 'A simple example for a boolean preference  (see PreferenceExample>>booleanPref)'
		type: #Boolean>
	^BooleanPref
]

{ #category : #preferences }
PreferencesTestExample class >> booleanPref: aBool [
	BooleanPref := aBool.
	self inform: 'The new preference value is: ', aBool asString.
]

{ #category : #preferences }
PreferencesTestExample class >> colorPref [
	<preference: 'Color Preference Example'
		category: 'Examples'
		description: 'A simple example for a color preference (see PreferenceExample>>colorPref)'
		type: #Color>
	^ColorPref
]

{ #category : #preferences }
PreferencesTestExample class >> colorPref: aColor [
	ColorPref := aColor.
	self inform: 'The new preference value is: ', aColor asString.
]

{ #category : #preferences }
PreferencesTestExample class >> initialize [	"PreferenceExample initialize"
	"Initialize the default values and register preferences"
	TextPref := 'Hello World'.
	NumericPref := 1234.
	BooleanPref := true.
	ColorPref := Color green.
]

{ #category : #preferences }
PreferencesTestExample class >> numericPref [
	<preference: 'Numeric Preference Example'
		category: 'Examples'
		description: 'A simple example for a numeric preference (see PreferenceExample>>numericPref)'
		type: #Number>
	^NumericPref
]

{ #category : #preferences }
PreferencesTestExample class >> numericPref: aNumber [
	NumericPref := aNumber.
	self inform: 'The new preference value is: ', aNumber asString.
]

{ #category : #preferences }
PreferencesTestExample class >> textPref [
	<preference: 'Textual Preference Example'
		category: 'Examples'
		description: 'A simple example for a textual preference (see PreferenceExample>>textPref)'
		type: #String>
	^TextPref
]

{ #category : #preferences }
PreferencesTestExample class >> textPref: aString [
	TextPref := aString.
]
