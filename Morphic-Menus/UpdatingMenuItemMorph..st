"
A menu item whose textual label and whose enablement are updatable.  The wordingProvider provides the current wording, upon being being sent the wordingSelector.

The item can also dynamically update whether or not it should be enabled; to do this, give it an enablementSelector, which is also sent to the wordingProvider..
"
Class {
	#name : #UpdatingMenuItemMorph,
	#superclass : #MenuItemMorph,
	#instVars : [
		'wordingProvider',
		'wordingSelector',
		'enablementSelector',
		'wordingArgument'
	],
	#category : #'Morphic-Menus'
}

{ #category : #'stepping and presenter' }
UpdatingMenuItemMorph >> arrangeToStartSteppingIn: aWorld [
	super arrangeToStartSteppingIn: aWorld.
	self updateContents.
]

{ #category : #world }
UpdatingMenuItemMorph >> decorateOwner [

	MenuIcons decorateMenu: owner.
]

{ #category : #enablement }
UpdatingMenuItemMorph >> enablement [ 

	enablementSelector isBlock
		ifTrue: [^ enablementSelector value]
		ifFalse: [enablementSelector numArgs = 0
				ifTrue: [^ wordingProvider perform: enablementSelector]
				ifFalse: [^ wordingProvider perform: enablementSelector
										withArguments: arguments]]
]

{ #category : #enablement }
UpdatingMenuItemMorph >> enablementSelector: aSelector [ 
	enablementSelector := aSelector isBlock 
				ifTrue: [aSelector copyForSaving]
				ifFalse: [aSelector] 
]

{ #category : #'stepping and presenter' }
UpdatingMenuItemMorph >> step [
	super step.
	self updateContents.
]

{ #category : #'stepping and presenter' }
UpdatingMenuItemMorph >> stepTime [
	^ 1200
]

{ #category : #wording }
UpdatingMenuItemMorph >> target: anObject [
"For us if the old target and wording provider are the same update both."
target = wordingProvider 
	ifTrue: [ wordingProvider := target := anObject ]
	ifFalse: [  target := anObject ] .

]

{ #category : #world }
UpdatingMenuItemMorph >> updateContents [
	"Update the receiver's contents"

	| newString enablement nArgs |
	((wordingProvider isNil) or: [wordingSelector isNil]) ifFalse: [
		nArgs := wordingSelector numArgs.
		newString := nArgs = 0
			ifTrue:
				[wordingProvider perform: wordingSelector]
			ifFalse:
				[(nArgs = 1 and: [wordingArgument notNil])
					ifTrue:
						[wordingProvider perform: wordingSelector with: wordingArgument]
					ifFalse:
						[nArgs == arguments size ifTrue:
							[wordingProvider perform: wordingSelector withArguments: arguments]]].
		newString = (self contentString ifNil: [ contents ])
			ifFalse: [self contents: newString.
				self decorateOwner ]].
	enablementSelector ifNotNil:
		[(enablement := self enablement) == isEnabled 
			ifFalse:	[self isEnabled: enablement]]
]

{ #category : #wording }
UpdatingMenuItemMorph >> wordingArgument: anArgument [
	"Set the receiver's wordingArgument as indicated"

	wordingArgument := anArgument
]

{ #category : #wording }
UpdatingMenuItemMorph >> wordingProvider: aProvider wordingSelector: aSelector [
	wordingProvider := aProvider.
	wordingSelector := aSelector
]
