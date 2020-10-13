Class {
	#name : #LangEnvBugs,
	#superclass : #TestCase,
	#category : #'Tests-Bugs'
}

{ #category : #accessing }
LangEnvBugs >> defaultTimeout [

	^ super defaultTimeout * 10 "seconds"
]

{ #category : #running }
LangEnvBugs >> tearDown [

	[Preferences restoreDefaultFonts] valueSupplyingAnswers: #(('Sorry, could not revert font choices' #default))
]

{ #category : #tests }
LangEnvBugs >> testIsFontAvailable [
	"self new testIsFontAvailable"
	"self run: #testIsFontAvailable"
	| oldPref |
	oldPref := Preferences valueOfPreference: #tinyDisplay.
	Preferences restoreFontsAfter: [
		[Preferences enable: #tinyDisplay.
		"This should not throw an exception."
		(LanguageEnvironment localeID: (LocaleID isoLanguage: 'en')) isFontAvailable]
			ensure: [Preferences setPreference: #tinyDisplay toValue: oldPref]].
]
