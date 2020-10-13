Class {
	#name : #DockingBarUpdatingItemMorph,
	#superclass : #UpdatingMenuItemMorph,
	#category : #'Morphic-Menus-DockingBar'
}

{ #category : #'as yet unclassified' }
DockingBarUpdatingItemMorph >> decorateOwner [

	"Ignore."
]

{ #category : #'as yet unclassified' }
DockingBarUpdatingItemMorph >> mouseEnter: evt [
	"Do not hover docking bar items directory. Mouse-down required. But if you already see a submenu, support hovering."

	owner selectedItem ifNotNil: [owner selectItem: self event: evt]
]
