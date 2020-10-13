Class {
	#name : #PreferenceWizardProgressMorph,
	#superclass : #SystemProgressMorph,
	#category : #PreferenceBrowser
}

{ #category : #'as yet unclassified' }
PreferenceWizardProgressMorph class >> install [

	self reset.
	UniqueInstance := self basicNew initialize; yourself.
]

{ #category : #'as yet unclassified' }
PreferenceWizardProgressMorph >> createProgressBar [
	
	^ SystemProgressBarMorph new 
		extent: 500@20;
		color: Color transparent;
		barColor: Color white;
		borderColor: Color white;
		borderWidth: 2;
		yourself
		
]

{ #category : #'as yet unclassified' }
PreferenceWizardProgressMorph >> openInWorld [

	"Ignore."
]

{ #category : #'as yet unclassified' }
PreferenceWizardProgressMorph >> reposition [

	"Ignore."
]

{ #category : #'as yet unclassified' }
PreferenceWizardProgressMorph >> setDefaultParameters [
	"change the receiver's appareance parameters"

	self
		color: Color transparent;
		borderWidth: 0;
		font: (StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 12);
		textColor: Color white.
]
