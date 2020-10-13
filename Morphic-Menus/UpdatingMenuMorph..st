Class {
	#name : #UpdatingMenuMorph,
	#superclass : #MenuMorph,
	#instVars : [
		'menuUpdater'
	],
	#category : #'Morphic-Menus'
}

{ #category : #events }
UpdatingMenuMorph >> activate: evt [
	"Receiver should be activated; e.g., so that control passes correctly."
	
	self updateMenu.
	super activate: evt
]

{ #category : #initialization }
UpdatingMenuMorph >> initialize [

	super initialize.
	menuUpdater := MenuUpdater new
]

{ #category : #update }
UpdatingMenuMorph >> updateMenu [

	menuUpdater update: self
]

{ #category : #initialization }
UpdatingMenuMorph >> updater: anObject updateSelector: aSelector [

	menuUpdater updater: anObject updateSelector: aSelector
]

{ #category : #initialization }
UpdatingMenuMorph >> updater: anObject updateSelector: aSelector arguments: anArray [

	menuUpdater updater: anObject updateSelector: aSelector arguments: anArray
]
