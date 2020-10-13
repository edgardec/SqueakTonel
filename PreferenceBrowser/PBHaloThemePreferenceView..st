"
I am responsible for building the button for the Halo Theme preference
"
Class {
	#name : #PBHaloThemePreferenceView,
	#superclass : #PBPreferenceView,
	#category : #PreferenceBrowser
}

{ #category : #'class initialization' }
PBHaloThemePreferenceView class >> initialize [
	PreferenceViewRegistry ofHaloThemePreferences register: self.
]

{ #category : #'class initialization' }
PBHaloThemePreferenceView class >> unload [
	"Unload order is not guaranteed so guard against failure"
	[PreferenceViewRegistry ofHaloThemePreferences unregister: self] on: Error do:[]
]

{ #category : #'user interface' }
PBHaloThemePreferenceView >> haloThemeRadioButtons [
	"Answer a column of butons representing the choices of halo theme"

	| buttonColumn |
	buttonColumn := self verticalPanel.
	#(	(iconicHaloSpecifications iconic iconicHalosInForce	'circular halos with icons inside')
		(classicHaloSpecs	classic	classicHalosInForce		'plain circular halos')
		(simpleFullHaloSpecifications		simple	simpleHalosInForce	'fewer, larger halos')
		(customHaloSpecs	custom	customHalosInForce		'customizable halos')) do:

		[:quad |
			| aRadioButton  |
			aRadioButton := UpdatingThreePhaseButtonMorph radioButton
				target: Preferences;
				setBalloonText: quad fourth;
				actionSelector: #installHaloTheme:;
				getSelector: quad third;
				arguments: (Array with: quad first);
				label: quad second asString;
				yourself.
			buttonColumn addMorphBack: aRadioButton].
	^ buttonColumn

	"(Preferences preferenceAt: #haloTheme) view tearOffButton"
]

{ #category : #initialization }
PBHaloThemePreferenceView >> initialize [
	self addActionTitled: 'edit custom halos' 
		target: Preferences 
		selector:  #editCustomHalos 
		arguments: {} 
		balloonText: 'Click here to edit the method that defines the custom halos' translated.
]

{ #category : #'user interface' }
PBHaloThemePreferenceView >> representativeButtonWithColor: aColor inPanel: aPreferencesPanel [
	| innerPanel |
	innerPanel := self horizontalFiller
		addMorphBack: self horizontalFiller;
		addMorphBack: self haloThemeRadioButtons;
		yourself.
	^self verticalPanel
		color: aColor;
		layoutInset: 2;
		addMorphBack: self morphForName;
		addMorphBack: innerPanel.
]
