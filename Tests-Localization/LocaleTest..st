"
LocaleTest buildSuite run
"
Class {
	#name : #LocaleTest,
	#superclass : #TestCase,
	#instVars : [
		'previousID',
		'previousKeyboardInterpreter',
		'previousClipboardInterpreter'
	],
	#category : #'Tests-Localization'
}

{ #category : #failures }
LocaleTest >> expectedFailures [

	^ super expectedFailures,
		((NaturalLanguageTranslator translators isEmpty 
			or: [(NaturalLanguageTranslator translators values collect: [:t | t localeID ]) 
				asSet size = 1])
			ifTrue: [#(testLocaleChanged) "no locale available to switch to"]
			ifFalse: [ #()]),
		#(testIsFontAvailable "metatoys.org is not accessible")

]

{ #category : #running }
LocaleTest >> setUp [

	previousID := Locale current localeID.
	previousKeyboardInterpreter := self currentHand instVarNamed: 'keyboardInterpreter'.
	previousClipboardInterpreter := Clipboard default instVarNamed: 'interpreter'.
	self currentHand clearKeyboardInterpreter.
	Clipboard default clearInterpreter.
]

{ #category : #running }
LocaleTest >> tearDown [

	self currentHand instVarNamed: 'keyboardInterpreter' put: previousKeyboardInterpreter.
	Clipboard default instVarNamed: 'interpreter' put: previousClipboardInterpreter.
	Locale switchToID: (LocaleID isoLanguage: previousID).
]

{ #category : #tests }
LocaleTest >> testEncodingName [
	"self debug: #testEncodingName"
	| locale |
	locale := Locale isoLanguage: 'ja'.
	self assert: locale languageEnvironment fontEncodingName = #FontJapaneseEnvironment
]

{ #category : #tests }
LocaleTest >> testIsFontAvailable [
	"self debug: #testIsFontAvailable"
	
	<timeout: 60> "takes quite a while"
	self ensureInternetConnectionTo: 'http://metatoys.org/pub/'.
	
	Preferences restoreFontsAfter: [
		| currentDefaultTextStyle |
		currentDefaultTextStyle := TextStyle default.
		[ 
			TextStyle setDefault: (TextStyle actualTextStyles at: #Accuny).
			(Locale isoLanguage: 'ja') languageEnvironment removeFonts.
			self assert: (Locale isoLanguage: 'en') languageEnvironment isFontAvailable.
			"Next test should fail after installing Japanese font"
			self assert: (Locale isoLanguage: 'ja') languageEnvironment isFontAvailable not.
			(Locale isoLanguage: 'ja') languageEnvironment installFont.
			self assert: (Locale isoLanguage: 'ja') languageEnvironment isFontAvailable ]
				ensure: [ TextStyle setDefault: currentDefaultTextStyle.
						FileDirectory default deleteFileNamed: (Locale isoLanguage: 'ja') languageEnvironment fontFullName. ] ].
]

{ #category : #tests }
LocaleTest >> testLocaleChanged [
	"self debug: #testLocaleChanged"
	"LanguageEnvironment >> startUp is called from Prject >> localeChanged"
	<timeout: 60> "takes quite a while"
	Project current updateLocaleDependents.
	self assert: (self currentHand instVarNamed: 'keyboardInterpreter') isNil description: 'non-nil keyboardInterpreter'.
	self assert: (Clipboard default instVarNamed: 'interpreter') isNil description: 'non-nil interpreter'.
	Locale switchToID: (LocaleID isoLanguage: 'ja').
	self assert: 'ja' equals: Locale current localeID isoLanguage.
	Locale switchToID: (LocaleID isoLanguage: 'en').
	self assert: 'en' equals: Locale current localeID isoLanguage.
]
