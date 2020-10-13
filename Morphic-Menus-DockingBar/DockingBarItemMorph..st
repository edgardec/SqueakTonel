Class {
	#name : #DockingBarItemMorph,
	#superclass : #MenuItemMorph,
	#instVars : [
		'selectedIcon'
	],
	#category : #'Morphic-Menus-DockingBar'
}

{ #category : #selecting }
DockingBarItemMorph >> adjacentTo [

	| roundedCornersOffset verticalOffset |
	roundedCornersOffset := MenuMorph roundedMenuCorners
		ifTrue: [Morph preferredCornerRadius negated]
		ifFalse: [0].
	verticalOffset := 2.

	owner isFloating
		ifTrue: [^ {self bounds bottomLeft + (roundedCornersOffset @ verticalOffset)}].
	owner isAdheringToTop
		ifTrue: [^ {self bounds bottomLeft + (roundedCornersOffset @ verticalOffset)}].
	owner isAdheringToLeft
		ifTrue: [^ {self bounds topRight + (roundedCornersOffset @ verticalOffset)}].
	owner isAdheringToBottom
		ifTrue: [^ {self bounds topLeft + (roundedCornersOffset @ verticalOffset)}].
	owner isAdheringToRight
		ifTrue: [^ {self bounds topLeft + (roundedCornersOffset @ verticalOffset negated)}].
	^ {self bounds bottomLeft + (roundedCornersOffset @ 5)}
]

{ #category : #private }
DockingBarItemMorph >> createSubmenu [

	^DockingBarMenuMorph new
]

{ #category : #private }
DockingBarItemMorph >> createUpdatingSubmenu [

	^DockingBarUpdatingMenuMorph new
]

{ #category : #drawing }
DockingBarItemMorph >> drawIconOn: aCanvas [ 

	| pos |
	self hasIcon ifTrue: [
		| iconForm | 
		iconForm := self iconForm.

		pos := (contents
			ifEmpty: [self left + (self width - iconForm width // 2)]
			ifNotEmpty: [self left])
				@ (self top + (self height - iconForm height // 2)).

		aCanvas
			translucentImage: iconForm 
			at: pos].
]

{ #category : #drawing }
DockingBarItemMorph >> drawLabelOn: aCanvas [ 

	| stringBounds |	
	self contents ifEmpty: [^ self].
	
	stringBounds := bounds.
	
	self hasIcon ifTrue: [
		stringBounds := stringBounds left: stringBounds left + self iconForm width + 2 ].
	
	"Vertical centering."
	stringBounds := stringBounds top: stringBounds top + stringBounds bottom - self fontToUse height // 2.
	"Horizontal centering."
	stringBounds := stringBounds left: stringBounds left + (stringBounds width - (self fontToUse widthOfString: contents) // 2) abs.

	aCanvas
		drawString: contents
		in: stringBounds
		font: self fontToUse
		color: self colorToUse.
]

{ #category : #drawing }
DockingBarItemMorph >> drawSubMenuMarkerOn: aCanvas [ 
	"Ignore."
]

{ #category : #private }
DockingBarItemMorph >> iconForm [
	"private - answer the form to be used as the icon"
	^isEnabled
		ifTrue: [
			(isSelected and: [ selectedIcon notNil ])
				ifTrue: [ selectedIcon ]
				ifFalse: [ icon ] ]
		ifFalse: [
			icon asGrayScale ]
]

{ #category : #events }
DockingBarItemMorph >> mouseDown: evt [
	"Handle a mouse down event. Menu items get activated when the mouse is over them."

	(evt shiftPressed and:[self wantsKeyboardFocusOnShiftClick]) ifTrue: [ ^super mouseDown: evt ].  "enable label editing" 
	isSelected
		ifTrue: [
			owner selectItem: nil event: evt. ]
		ifFalse: [
			owner activate: evt. "Redirect to menu for valid transitions"
			owner selectItem: self event: evt. ]

]

{ #category : #events }
DockingBarItemMorph >> mouseEnter: evt [
	"Do not hover docking bar items directory. Mouse-down required. But if you already see a submenu, support hovering."

	owner selectedItem ifNotNil: [owner selectItem: self event: evt]
]

{ #category : #events }
DockingBarItemMorph >> mouseUp: evt [
	"Handle a mouse up event. Menu items get activated when the mouse is over them. Do nothing if we're not in a 'valid menu transition', meaning that the current hand focus must be aimed at the owning menu."
	
	evt hand mouseFocus == owner ifFalse: [ ^self ].
	self contentString ifNotNil: [
		self contents: self contentString withMarkers: true inverse: true.
		self refreshWorld.
		(Delay forMilliseconds: 200) wait ].
]

{ #category : #selecting }
DockingBarItemMorph >> select: evt [
	
	super select: evt.
	subMenu ifNotNil: [
		evt hand newKeyboardFocus: subMenu ]
]

{ #category : #accessing }
DockingBarItemMorph >> selectedIcon: aFormOrNil [

	selectedIcon := aFormOrNil
		ifNotNil: [:form | form scaleIconToDisplay].
]

{ #category : #private }
DockingBarItemMorph >> selectionFillStyle [

	| fill |
	fill := super selectionFillStyle.
	fill isColor ifTrue: [ ^fill ].
	self owner isVertical
		ifFalse: [ fill direction: 0 @ self height ]
		ifTrue: [ fill direction: self width @ 0 ].
	^fill
]

{ #category : #events }
DockingBarItemMorph >> wantsKeyboardFocusOnShiftClick [
	"set this preference to false to prevent user editing of docking bar menu items"
	^Preferences valueOfPreference: #allowMenubarItemEditing ifAbsent: [false]
]

{ #category : #rounding }
DockingBarItemMorph >> wantsRoundedCorners [

	^false
]
