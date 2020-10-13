"
I am responsible for building the visual representation of a preference that accepts true and false values. This view is aimed to be used inside a PreferenceBrowser panel.
"
Class {
	#name : #PBBooleanPreferenceView,
	#superclass : #PBPreferenceView,
	#category : #PreferenceBrowser
}

{ #category : #'class initialization' }
PBBooleanPreferenceView class >> initialize [
	PreferenceViewRegistry ofBooleanPreferences register: self.

]

{ #category : #'class initialization' }
PBBooleanPreferenceView class >> unload [
	"Unload order is not guaranteed so guard against failure"
	[PreferenceViewRegistry ofBooleanPreferences unregister: self] on: Error do:[].
]

{ #category : #'user interface' }
PBBooleanPreferenceView >> enabledButton [
	| aButton |
	aButton := UpdatingThreePhaseButtonMorph checkBox
		target: self preference;
		actionSelector: #togglePreferenceValue;
		getSelector: #preferenceValue;
		label: 'enabled' translated;
		yourself.
	^self horizontalPanel
		addMorphBack: aButton;
		yourself.
]

{ #category : #'user interface' }
PBBooleanPreferenceView >> localToProjectButton [
	| aButton |
	aButton := UpdatingThreePhaseButtonMorph checkBox
		target: self preference;
		actionSelector: #toggleProjectLocalness;
		getSelector: #localToProject;
		label: 'local' translated;
		yourself.
	^self horizontalPanel
		addMorphBack: aButton;
		yourself.
]

{ #category : #'user interface' }
PBBooleanPreferenceView >> representativeButtonWithColor: aColor inPanel: aPreferencesPanel [
	^self horizontalPanel
		layoutInset: 2;
		cellGap: 7;
		color: aColor;
		addMorphBack: self morphForName;
		addMorphBack: self horizontalFiller; 
		addMorphBack: self enabledButton;
		addMorphBack: self localToProjectButton;
		yourself.
]
