Class {
	#name : #DockingBarUpdatingMenuMorph,
	#superclass : #DockingBarMenuMorph,
	#instVars : [
		'arguments',
		'updater',
		'updateSelector',
		'menuUpdater'
	],
	#category : #'Morphic-Menus-DockingBar'
}

{ #category : #initialization }
DockingBarUpdatingMenuMorph >> delete [

	owner ifNotNil: [ 
		" When deleted remove my menu items, so I can avoid holding unwanted references to other objects. They will be updated anyway when I become visible again. "
		" The owner notNil condition is necessary because MenuItemMorph >> select: sends delete before I become visible, but after the menu items are updated. "
		self removeAllMorphs ].
	super delete
]

{ #category : #initialization }
DockingBarUpdatingMenuMorph >> initialize [

	super initialize.
	menuUpdater := MenuUpdater new
]

{ #category : #update }
DockingBarUpdatingMenuMorph >> updateMenu [

	menuUpdater update: self
]

{ #category : #initialization }
DockingBarUpdatingMenuMorph >> updater: anObject updateSelector: aSelector [

	menuUpdater updater: anObject updateSelector: aSelector
]

{ #category : #initialization }
DockingBarUpdatingMenuMorph >> updater: anObject updateSelector: aSelector arguments: anArray [

	menuUpdater updater: anObject updateSelector: aSelector arguments: anArray
]
