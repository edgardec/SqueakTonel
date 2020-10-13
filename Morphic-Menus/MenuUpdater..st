Class {
	#name : #MenuUpdater,
	#superclass : #Object,
	#instVars : [
		'updater',
		'updateSelector',
		'arguments'
	],
	#category : #'Morphic-Menus'
}

{ #category : #updating }
MenuUpdater >> update: aMenuMorph [
	"Reconstitute the menu by first removing the contents and then building it afresh"

	aMenuMorph removeAllMorphs.
	arguments 
		ifNil: [ updater perform: updateSelector with: aMenuMorph ]
		ifNotNil: [ 
			updater 
				perform: updateSelector 
				withArguments: (arguments copyWith: aMenuMorph) ].
	aMenuMorph changed
]

{ #category : #initialization }
MenuUpdater >> updater: anObject updateSelector: aSelector [

	self updater: anObject updateSelector: aSelector arguments: nil
]

{ #category : #initialization }
MenuUpdater >> updater: anObject updateSelector: aSelector arguments: anArray [

	updater := anObject.
	updateSelector := aSelector.
	arguments := anArray
]
