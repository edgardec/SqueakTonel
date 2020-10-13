Class {
	#name : #DockingBarMenuMorph,
	#superclass : #MenuMorph,
	#instVars : [
		'activatorDockingBar'
	],
	#category : #'Morphic-Menus-DockingBar'
}

{ #category : #accessing }
DockingBarMenuMorph >> activatedFromDockingBar: aDockingBar [ 

	activatorDockingBar := aDockingBar
]

{ #category : #'keystroke helpers' }
DockingBarMenuMorph >> handleCRStroke: evt [

	evt keyValue = 13 ifFalse: [ ^false ].
	selectedItem ifNotNil: [ selectedItem invokeWithEvent: evt ].
	^true
]

{ #category : #'keystroke helpers' }
DockingBarMenuMorph >> handleLeftStroke: evt [

	28 = evt keyValue ifFalse: [ ^false ].
	(self stepIntoSubmenu: evt) ifFalse: [ 
		self deactivate: evt.
		activatorDockingBar moveSelectionDown: -1 event: evt ].
	^true
]

{ #category : #'keystroke helpers' }
DockingBarMenuMorph >> handleRightStroke: evt [

	29 = evt keyValue ifFalse: [ ^false ].
	(self stepIntoSubmenu: evt) ifFalse: [
		self deactivate: evt.
		activatorDockingBar moveSelectionDown: 1 event: evt ].
	^true
]

{ #category : #rounding }
DockingBarMenuMorph >> roundedCorners [
	"Return a list of those corners to round"
	activatorDockingBar isFloating
		ifTrue: [^ #(2 3 )].
	activatorDockingBar isAdheringToTop
		ifTrue: [^ #(2 3 )].
	activatorDockingBar isAdheringToBottom
		ifTrue: [^ #(1 4 )].
	activatorDockingBar isAdheringToLeft
		ifTrue: [^ #(3 4 )].
	activatorDockingBar isAdheringToRight
		ifTrue: [^ #(1 2 )]
]

{ #category : #copying }
DockingBarMenuMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	activatorDockingBar := activatorDockingBar.  "Weakly copied"

]
