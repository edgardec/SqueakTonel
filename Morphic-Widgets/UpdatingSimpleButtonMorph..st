"
Adds to SimpleButtonMorph the ability to keep its own wording up to date by send a given message (indicated by its wordingSelector) to a given object (indicated by its wordingTarget, and normally the same as its target.)
"
Class {
	#name : #UpdatingSimpleButtonMorph,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'wordingProvider',
		'wordingSelector'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'stepping and presenter' }
UpdatingSimpleButtonMorph >> step [
	"If appropriate update the receiver's label"

	| newString |
	super step.
	wordingProvider ifNotNil:
		[newString := wordingProvider perform: wordingSelector.
		newString = self label ifFalse: [self labelString: newString; changed]]
]

{ #category : #'stepping and presenter' }
UpdatingSimpleButtonMorph >> stepTime [
	"Answer the desired time between steps in milliseconds.  If the receiver has a wordingProvider that may dynamically provide changed wording for the label, step once every 1.5 seconds"

	^ wordingProvider ifNotNil: [1500] ifNil: [super stepTime]
]

{ #category : #'stepping and presenter' }
UpdatingSimpleButtonMorph >> wantsSteps [
	"Answer whether the receiver wishes to be sent the #step message.  In the current case, this decision depends on whether there is a wordingProvider which can dynamically provide fresh wording for the button's label"

	^ wordingProvider notNil
]

{ #category : #accessing }
UpdatingSimpleButtonMorph >> wordingSelector: aSelector [
	wordingSelector := aSelector.
	wordingProvider ifNil: [wordingProvider := target]
]
