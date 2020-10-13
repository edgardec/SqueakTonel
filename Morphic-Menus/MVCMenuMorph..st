"
I simulate the MVC menu classes PopUpMenu, SelectionMenu, and CustomMenu when running in a Morphic world. I am also used to implement Utilities>informUser:during:.
"
Class {
	#name : #MVCMenuMorph,
	#superclass : #MenuMorph,
	#instVars : [
		'done',
		'mvcSelection'
	],
	#category : #'Morphic-Menus'
}

{ #category : #'instance creation' }
MVCMenuMorph class >> from: aPopupMenu title: titleStringOrNil [
	"Answer a MenuMorph constructed from the given PopUpMenu. Used to simulate MVC-style menus in a Morphic-only world."

	| menu items lines selections labelString j |
	menu := self new.
	titleStringOrNil ifNotNil: [
		titleStringOrNil isEmpty ifFalse: [menu addTitle: titleStringOrNil]].
	labelString := aPopupMenu labelString.
	items := labelString asString lines.
	labelString isText ifTrue:
		["Pass along text emphasis if present"
		j := 1.
		items := items collect:
			[:item | | emphasis |
			j := labelString asString findString: item startingAt: j.
			emphasis := TextEmphasis new emphasisCode: (labelString emphasisAt: j).
			item asText addAttribute: emphasis]].
	lines := aPopupMenu lineArray.
	lines ifNil: [lines := #()].
	menu cancelValue: 0.
	menu defaultTarget: menu.
	selections := (1 to: items size) asArray.
	1 to: items size do: [:i |
		menu add: (items at: i) selector: #selectMVCItem: argument: (selections at: i).
		(lines includes: i) ifTrue: [menu addLine]].
	^ menu

]

{ #category : #private }
MVCMenuMorph >> cancelValue: selectionOrNil [
	"Set the value to be returned if the user cancels without making a selection."

	mvcSelection := selectionOrNil.

]

{ #category : #invoking }
MVCMenuMorph >> displayAt: aPoint during: aBlock [
	"Add this menu to the Morphic world during the execution of the given block."

	Smalltalk isMorphic ifFalse: [^ self].

	[self currentWorld addMorph: self centeredNear: aPoint.
	self world displayWorld.  "show myself"
	aBlock value]
		ensure: [self delete]
]

{ #category : #invoking }
MVCMenuMorph >> informUserAt: aPoint during: aBlock [
	"Add this menu to the Morphic world during the execution of the given block."

	| title w |
	Smalltalk isMorphic ifFalse: [^ self].
	
	title := self allMorphs detect: [:ea | ea hasProperty: #titleString].
	title := title submorphs first.
	self visible: false.
	w := self currentWorld.
	aBlock value: [:string|
		self visible ifFalse: [
			w addMorph: self centeredNear: aPoint.
			self visible: true].
		title contents: string.
		self setConstrainedPosition: Sensor cursorPoint hangOut: false.
		self changed.
		w displayWorld		 "show myself"
	]. 
	self delete.
	w displayWorld.
]

{ #category : #initializing }
MVCMenuMorph >> initialize [
	super initialize.
	self setProperty: #morphicLayerNumber toValue: self morphicLayerNumber

]

{ #category : #invoking }
MVCMenuMorph >> invokeAt: aPoint in: aWorld [
	"Add this menu to the given world centered at the given point. Wait for the user to make a selection and answer it. The selection value returned is an integer in keeping with PopUpMenu, if the menu is converted from an MVC-style menu."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	^ self invokeAt: aPoint in: aWorld allowKeyboard: Preferences menuKeyboardControl
]

{ #category : #invoking }
MVCMenuMorph >> invokeAt: aPoint in: aWorld allowKeyboard: aBoolean [
	"Add this menu to the given world centered at the given point. Wait for the user to make a selection and answer it. The selection value returned is an integer in keeping with PopUpMenu, if the menu is converted from an MVC-style menu."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop." 
	| w originalFocusHolder |
	self flag: #bob.		"is <aPoint> global or local?"
	self flag: #arNote.	"<aPoint> is local to aWorld"
	originalFocusHolder := aWorld primaryHand keyboardFocus.
	self popUpAt: aPoint forHand: aWorld primaryHand in: aWorld allowKeyboard: aBoolean.
	done := false.
	w := aWorld outermostWorldMorph. "containing hand"
	[self isInWorld & done not] whileTrue: [w doOneSubCycle].
	self delete.
	originalFocusHolder ifNotNil: [aWorld primaryHand newKeyboardFocus: originalFocusHolder].
	^ mvcSelection

]

{ #category : #'WiW support' }
MVCMenuMorph >> morphicLayerNumber [
	^self valueOfProperty: #morphicLayerNumber ifAbsent: [10].

]

{ #category : #private }
MVCMenuMorph >> selectMVCItem: item [
	"Called by the MenuItemMorph that the user selects.
	Record the selection and set the done flag to end this interaction."

	mvcSelection := item.
	done := true.

]
