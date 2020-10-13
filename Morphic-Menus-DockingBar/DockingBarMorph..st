Class {
	#name : #DockingBarMorph,
	#superclass : #Morph,
	#instVars : [
		'originalColor',
		'gradientRamp',
		'fillsOwner',
		'avoidVisibleBordersAtEdge',
		'autoGradient',
		'selectedItem',
		'activeSubMenu',
		'oldKeyboardFocus',
		'oldMouseFocus'
	],
	#category : #'Morphic-Menus-DockingBar'
}

{ #category : #scripting }
DockingBarMorph class >> defaultNameStemForInstances [
	^ 'DockingBar'
]

{ #category : #samples }
DockingBarMorph class >> example1 [
	" 
	DockingBarMorph example1.  
	 
	(Color lightBlue wheel: 4) do:[:c | DockingBarMorph example1 
	color: c; borderColor: c twiceDarker]. 
	 
	Project current world deleteDockingBars.
	"
	| instance |
	instance := DockingBarMorph new.
	""
	instance addSpace: 10.
	instance
		addMorphBack: (ClockMorph new show24hr: true).
	instance addSpacer.
	instance
		addMorphBack: (ClockMorph new show24hr: true).
	instance addSpace: 10.
	""
	instance adhereToTop.
	""
	instance autoGradient: true.
	instance layoutInset: 10.
	""
	^ instance openInWorld
]

{ #category : #samples }
DockingBarMorph class >> example2 [
	" 
	DockingBarMorph example2.  
	Project current world deleteDockingBars.  
	"
	| menu |
	menu := DockingBarMorph new.
	""
	menu addSpace: 10.
	menu
		add: 'Squeak'
		icon: MenuIcons smallConfigurationIcon
		subMenu: self squeakMenu.
	menu
		add: 'Configuration'
		icon: MenuIcons smallWindowIcon
		subMenu: self squeakMenu.
	menu addSpace: 10.
	menu addLine.
	menu addSpace: 10.
	menu
		addMorphBack: (ImageMorph new image: MenuIcons smallBackIcon).
	menu addSpace: 10.
	menu
		addMorphBack: (ImageMorph new image: MenuIcons smallForwardIcon).
	menu addSpace: 10.
	menu addLine.
	menu addSpacer.
	""
	menu addMorphBack: ProjectNavigationMorph new speakerIcon.
	""
	menu addSpace: 10.
	menu
		addMorphBack: (ClockMorph new show24hr: true).
	menu addSpace: 10.
	""
	menu adhereToTop.
	""
	menu autoGradient: true.
	""
	^ menu openInWorld
]

{ #category : #samples }
DockingBarMorph class >> example3 [
	" 
	DockingBarMorph example3. 
	Project current world deleteDockingBars.
	"
	(Color lightBlue wheel: 4)
		with: #(#top #bottom #left #right )
		do: [:col :edge | 
			| instance | 
			instance := DockingBarMorph example1.
			instance adhereTo: edge.
			instance color: col.
			instance borderColor: col twiceDarker]
]

{ #category : #samples }
DockingBarMorph class >> squeakMenu [
	| menu |
	menu := DockingBarMenuMorph new defaultTarget: self.
	menu
		add: 'Hello'
		target: self
		selector: #inform:
		argument: 'Hello World!'.
	menu
		add: 'Long Hello'
		target: self
		selector: #inform:
		argument: 'Helloooo World!'.
	menu
		add: 'A very long Hello'
		target: self
		selector: #inform:
		argument: 'Hellooooooooooooooo World!'.
	menu
		add: 'An incredible long Hello'
		target: self
		selector: #inform:
		argument: 'Hellooooooooooooooooooooooo World!'.
	^ menu
]

{ #category : #preferences }
DockingBarMorph class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the menu''s border.' }.
		{ #borderWidth. 'Geometry'. 'Width of the menu''s border.' }.
		{ #borderStyle. 'Borders'. 'Whether to use a plain border, inset, or outset.' }.
		{ #color. 'Colors'. 'Background color of the menu.' }.

		{ #lineColor. 'Colors'. 'Color of the separators between menu items.' }.
		{ #lineStyle. 'Colors'. 'Use border-style to change appearance.' }.
		{ #lineWidth. 'Geometry'. 'How big the separators should be.' }.
	}
]

{ #category : #'dropping\/grabbing' }
DockingBarMorph >> aboutToBeGrabbedBy: aHand [ 
	"The morph is about to be grabbed, make it float"
	self beFloating.
	self updateBounds.
	self updateColor.
	(self bounds containsPoint: aHand position)
		ifFalse: [self center: aHand position].
self owner restoreFlapsDisplay
]

{ #category : #events }
DockingBarMorph >> activate: evt [ 
	"Receiver should be activated; e.g., so that control passes  
	correctly."
	
	oldKeyboardFocus := evt hand keyboardFocus.
	self oldMouseFocus: evt hand mouseFocus.
	evt hand 
		newKeyboardFocus: self;
		newMouseFocus: self.
	self ensureSelectedItem: evt
]

{ #category : #control }
DockingBarMorph >> activeSubmenu: aSubmenu [ 
	activeSubMenu isNil
		ifFalse: [activeSubMenu delete].
	activeSubMenu := aSubmenu.
	aSubmenu isNil
		ifTrue: [^ self].
	activeSubMenu updateMenu.
	activeSubMenu selectItem: nil event: nil.
	MenuIcons decorateMenu: activeSubMenu.
	activeSubMenu 
		activatedFromDockingBar: self;
		beSticky;
		resistsRemoval: true;
		removeMatchString
]

{ #category : #construction }
DockingBarMorph >> add: wordingString icon: aForm help: helpString subMenu: aMenuMorph [ 
	"Append the given submenu with the given label."
	| item |
	item := DockingBarItemMorph new.
	item contents: wordingString.
	item subMenu: aMenuMorph.
	item icon: aForm.
	helpString isNil
		ifFalse: [item setBalloonText: helpString].
	self addMorphBack: item
]

{ #category : #construction }
DockingBarMorph >> add: wordingString icon: aForm selectedIcon: anotherForm help: helpString subMenu: aMenuMorph [ 
	"Append the given submenu with the given label."
	| item |
	item := DockingBarItemMorph new
		contents: wordingString;
		subMenu: aMenuMorph;
		icon: aForm;
		selectedIcon: anotherForm.
	helpString isNil ifFalse: [
		item setBalloonText: helpString ].
	self addMorphBack: item
]

{ #category : #construction }
DockingBarMorph >> add: wordingString icon: aForm subMenu: aMenuMorph [ 
	"Append the given submenu with the given label."
^ self add: wordingString icon: aForm help: nil subMenu: aMenuMorph 
]

{ #category : #construction }
DockingBarMorph >> add: aString subMenu: aMenuMorph [ 
	"Append the given submenu with the given label."
	self add: aString icon: nil subMenu: aMenuMorph 
]

{ #category : #accessing }
DockingBarMorph >> addBlankIconsIfNecessary: anIcon [ 
	"If any of my items have an icon, ensure that all do by using 
	anIcon for those that don't"
	self items
		reject: [:each | each hasIconOrMarker]
		thenDo: [:each | each icon: anIcon]
]

{ #category : #menu }
DockingBarMorph >> addCustomMenuItems: aMenu hand: aHandMorph [ 
	"Populate aMenu with appropriate menu items for a  
	yellow-button (context menu) click."
	super addCustomMenuItems: aMenu hand: aHandMorph.
	""
	aMenu addLine.
	aMenu addUpdating: #autoGradientString action: #toggleAutoGradient.
	self isFloating
		ifFalse: [""
			aMenu addUpdating: #fillsOwnerString action: #toggleFillsOwner.
			aMenu addUpdating: #avoidVisibleBordersAtEdgeString action: #toggleAvoidVisibleBordersAtEdge]
]

{ #category : #construction }
DockingBarMorph >> addDefaultSpace [
	"Add a new space of the given size to the receiver."
	^ self addSpace: (Preferences tinyDisplay ifFalse:[10] ifTrue:[3])
]

{ #category : #construction }
DockingBarMorph >> addItem: aBlock [
	| item |
	item := DockingBarItemMorph new.
	aBlock value: item.
	self addMorphBack: item
]

{ #category : #construction }
DockingBarMorph >> addLine [
	"Append a divider line to this menu. Suppress duplicate lines."

	| colorToUse |
	submorphs isEmpty ifTrue: [^ self].
	self lastSubmorph knownName = #line ifTrue: [^ self].
	
	colorToUse := self userInterfaceTheme lineColor ifNil: [Color gray: 0.9].
	self addMorphBack: (Morph new
		color: colorToUse;
		extent: (self userInterfaceTheme lineWidth ifNil: [2]) asPoint;
		borderStyle: (self userInterfaceTheme lineStyle ifNil: [BorderStyle inset]);
		borderColor: colorToUse;
		borderWidth: 1;
		name: #line; "see above"
		yourself).
]

{ #category : #construction }
DockingBarMorph >> addSpace: sizePointOrNumber [ 
	"Add a new space of the given size to the receiver."
	| space |
	space := RectangleMorph new.
	space extent: sizePointOrNumber asPoint.
	space color: Color transparent.
	space borderWidth: 0.
	self addMorphBack: space
]

{ #category : #construction }
DockingBarMorph >> addSpacer [
	"Add a new spacer to the receiver. 
	 
	Spacer are objects that try to use as much space as they can"
	self
		addMorphBack: (AlignmentMorph newSpacer: Color transparent)
]

{ #category : #construction }
DockingBarMorph >> addUpdatingItem: aBlock [
	| item |
	item := DockingBarUpdatingItemMorph new.
	aBlock value: item.
	self addMorphBack: item
]

{ #category : #'change reporting' }
DockingBarMorph >> addedMorph: aMorph [
	"Update the new morph's layout properties according to my orientation."

	aMorph isMenuItemMorph ifFalse: [^ self].
	
	self isVertical
		ifTrue: [
			aMorph hResizing: #spaceFill.
			aMorph vResizing: #shrinkWrap ]
		ifFalse: [
			aMorph hResizing: #shrinkWrap.
			aMorph vResizing: #spaceFill ].
]

{ #category : #'private - accessing' }
DockingBarMorph >> adhereTo: edgeSymbol [ 
	"Private - Instruct the receiver to adhere to the given edge.  
	 
	Options: #left #top #right #bottom or #none"
	""
	(#(#left #top #right #bottom #none ) includes: edgeSymbol)
		ifFalse: [^ self error: 'invalid option'].
	""
	self setToAdhereToEdge: edgeSymbol.
	self updateLayoutProperties.
	self updateColor
]

{ #category : #accessing }
DockingBarMorph >> adhereToBottom [
	"Instract the receiver to adhere to bottom"
	 self adhereTo:#bottom
]

{ #category : #accessing }
DockingBarMorph >> adhereToLeft [
	"Instract the receiver to adhere to left"
	self adhereTo: #left
]

{ #category : #accessing }
DockingBarMorph >> adhereToRight [
	"Instract the receiver to adhere to right"
	self adhereTo: #right
]

{ #category : #accessing }
DockingBarMorph >> adhereToTop [
	"Instract the receiver to adhere to top"
	self adhereTo: #top
]

{ #category : #update }
DockingBarMorph >> applyUserInterfaceTheme [

	| colorToUse |
	gradientRamp := nil.
	
	super applyUserInterfaceTheme.
	
	self setDefaultParameters.
	
	"Update properties of separating lines."
	colorToUse := self userInterfaceTheme lineColor ifNil: [Color gray: 0.9].
	self submorphs
		select: [:ea | ea knownName = #line]
		thenDo: [:line |
			line
				color: colorToUse;
				extent: (self userInterfaceTheme lineWidth ifNil: [2]) asPoint;
				borderStyle: (self userInterfaceTheme lineStyle ifNil: [BorderStyle inset]) copy;
				borderColor: colorToUse].
]

{ #category : #accessing }
DockingBarMorph >> autoGradient [
	"Answer if the receiver is in autoGradient mode"
	^ autoGradient
]

{ #category : #accessing }
DockingBarMorph >> autoGradient: aBoolean [ 
	"Instruct the receiver to fill the owner or not"
	autoGradient := aBoolean.
	self updateColor
]

{ #category : #menu }
DockingBarMorph >> autoGradientString [
	"Answer the string to be shown in a menu to represent the  
	'resistsRemoval' status"
	^ (self autoGradient
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'auto gradient' translated
]

{ #category : #accessing }
DockingBarMorph >> avoidVisibleBordersAtEdge [
"Answer if the receiver is in avoidVisibleBordersAtEdge mode"
	^ avoidVisibleBordersAtEdge
]

{ #category : #accessing }
DockingBarMorph >> avoidVisibleBordersAtEdge: aBoolean [ 
	"Instruct the receiver to avoid showing the borders at edge"
	avoidVisibleBordersAtEdge := aBoolean.
self updateLayoutProperties.
]

{ #category : #menu }
DockingBarMorph >> avoidVisibleBordersAtEdgeString [
	"Answer the string to be shown in a menu to represent the  
	'resistsRemoval' status"
	^ (self avoidVisibleBordersAtEdge
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'avoid visible borders at edge' translated
]

{ #category : #accessing }
DockingBarMorph >> beFloating [
	"Instract the receiver to be floating"
	self adhereTo: #none
]

{ #category : #accessing }
DockingBarMorph >> color: aColor [ 
	"Set the receiver's color."

	super color: aColor.
	originalColor := aColor asColor.
	gradientRamp := nil.
""
self updateColor
]

{ #category : #events }
DockingBarMorph >> deactivate: evt [ 

	| newKeyboardFocus newMouseFocus |
	self selectItem: nil event: evt.
	newKeyboardFocus := self oldKeyboardFocus.
	newMouseFocus := self oldMouseFocus.
	oldKeyboardFocus := oldMouseFocus := nil.
	evt hand
		newKeyboardFocus: newKeyboardFocus;
		newMouseFocus: newMouseFocus
]

{ #category : #'submorphs-add\/remove' }
DockingBarMorph >> delete [

	self currentHand removeKeyboardListener: self.
	activeSubMenu ifNotNil: [
		activeSubMenu delete].
	^ super delete
]

{ #category : #control }
DockingBarMorph >> deleteIfPopUp: evt [ 
	
	evt ifNotNil: [
		evt hand releaseMouseFocus: self ]
]

{ #category : #'private - accessing' }
DockingBarMorph >> edgeToAdhereTo [
	"private - answer the edge where the receiver is adhering to"
	^ self
		valueOfProperty: #edgeToAdhereTo
		ifAbsent: [#none]
]

{ #category : #events }
DockingBarMorph >> ensureSelectedItem: evt [
	
	self selectedItem ifNil: [
		self 
			selectItem: (
				self submorphs 
					detect: [ :each | each isKindOf: DockingBarItemMorph ] 
					ifNone: [ ^self ]) 
			event: evt ]
]

{ #category : #geometry }
DockingBarMorph >> extent: aPoint [ 
	"change the receiver's extent"
	(bounds extent closeTo: aPoint) ifTrue: [^ self].
	super extent: aPoint.
	self updateColor
]

{ #category : #accessing }
DockingBarMorph >> fillsOwner [
	"Answer if the receiver is in fillOwner mode"
	^ fillsOwner
]

{ #category : #accessing }
DockingBarMorph >> fillsOwner: aBoolean [ 
	"Instruct the receiver to fill the owner or not"
	fillsOwner := aBoolean.
self updateLayoutProperties
]

{ #category : #menu }
DockingBarMorph >> fillsOwnerString [
	"Answer the string to be shown in a menu to represent the  
	'resistsRemoval' status"
	^ (self fillsOwner
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'fills owner' translated

]

{ #category : #'events-processing' }
DockingBarMorph >> filterEvent: aKeyboardEvent for: anObject [
	"Provide keyboard shortcuts."
	
	| index itemToSelect |

	aKeyboardEvent controlKeyPressed
		ifFalse: [^ aKeyboardEvent].

	aKeyboardEvent isKeystroke
		ifFalse: [^ aKeyboardEvent].
			
	"Search field."
	aKeyboardEvent keyCharacter = $0
		ifTrue: [
			self searchBarMorph ifNotNil: [ :morph |
				morph model activate: aKeyboardEvent in: morph ].
			^ aKeyboardEvent ignore "hit!"].
	
	"Select menu items."
	(aKeyboardEvent keyValue 
		between: $1 asciiValue 
		and: $9 asciiValue)
			ifFalse: [^ aKeyboardEvent].	
			
	index := aKeyboardEvent keyValue - $1 asciiValue + 1.
	itemToSelect := (self submorphs select: [ :each | 
		each isKindOf: DockingBarItemMorph ]) 
			at: index 
			ifAbsent: [^ aKeyboardEvent].
			
	self activate: aKeyboardEvent.
	self 
		selectItem: itemToSelect
		event: aKeyboardEvent.

	^ aKeyboardEvent ignore "hit!"
]

{ #category : #'private - layout' }
DockingBarMorph >> gradientRamp [
	| cc |
	cc := originalColor adjustSaturation: -0.08 brightness: 0.4.
	^ gradientRamp ifNil:[gradientRamp := {
			0.0 -> cc. 
			0.25 -> (originalColor mixed: 0.5 with: cc). 
			0.9 -> originalColor.
			1.0 -> originalColor darker.}]
]

{ #category : #'private - layout' }
DockingBarMorph >> gradientRamp: colorRamp [ 
	gradientRamp := colorRamp.
""
self updateColor
]

{ #category : #'events-processing' }
DockingBarMorph >> handlesKeyboard: evt [

	^true
]

{ #category : #testing }
DockingBarMorph >> indicateKeyboardFocus [
	^ false
]

{ #category : #'initialize-release' }
DockingBarMorph >> initialize [
	"initialize the receiver"
	super initialize.
	self changeTableLayout.
	
	selectedItem := nil.
	activeSubMenu := nil.
	fillsOwner := true.
	avoidVisibleBordersAtEdge := true.
	autoGradient := MenuMorph gradientMenu.
	self 
		setDefaultParameters ; 
		rubberBandCells: true ;
		beFloating ; 
		beSticky ;
		layoutInset: 0 ;
		dropEnabled: true
]

{ #category : #accessing }
DockingBarMorph >> isAdheringToBottom [
	"Answer true if the receiver is adhering to bottom"
	^ self edgeToAdhereTo == #bottom
]

{ #category : #accessing }
DockingBarMorph >> isAdheringToLeft [
	"Answer true if the receiver is adhering to left"
	^ self edgeToAdhereTo == #left
]

{ #category : #accessing }
DockingBarMorph >> isAdheringToRight [
	"Answer true if the receiver is adhering to right"
	^ self edgeToAdhereTo == #right
]

{ #category : #accessing }
DockingBarMorph >> isAdheringToTop [
	"Answer true if the receiver is adhering to top"
	^ self edgeToAdhereTo == #top
]

{ #category : #testing }
DockingBarMorph >> isDockingBar [
	"Return true if the receiver is a docking bar"
	^ true
]

{ #category : #accessing }
DockingBarMorph >> isFloating [
	"Answer true if the receiver has a float layout"
	^ self isHorizontal not
		and: [self isVertical not]
]

{ #category : #accessing }
DockingBarMorph >> isHorizontal [
	"Answer true if the receiver has a horizontal layout"
	^ self isAdheringToTop
		or: [self isAdheringToBottom]
]

{ #category : #accessing }
DockingBarMorph >> isSticky [
	"answer whether the receiver is Sticky"
	^ Preferences noviceMode
		or: [super isSticky] 
]

{ #category : #accessing }
DockingBarMorph >> isVertical [
	"Answer true if the receiver has a vertical layout"
	^ self isAdheringToLeft
		or: [self isAdheringToRight]

]

{ #category : #accessing }
DockingBarMorph >> items [

	^ submorphs select: [:m | m isKindOf: MenuItemMorph]
]

{ #category : #'dropping\/grabbing' }
DockingBarMorph >> justDroppedInto: aMorph event: anEvent [ 
	| ownerBounds leftRegion droppedPosition rightRegion topRegion bottomRegion |
	super justDroppedInto: aMorph event: anEvent.
	""
	self owner isNil
		ifTrue: [^ self].
	""
	ownerBounds := aMorph bounds.
	topRegion := ownerBounds bottom: ownerBounds top + (ownerBounds height // 5).
	bottomRegion := ownerBounds top: ownerBounds bottom - (ownerBounds height // 5).
	""
	leftRegion := ownerBounds right: ownerBounds left + (ownerBounds width // 5).
	leftRegion := leftRegion top: topRegion bottom.
	leftRegion := leftRegion bottom: bottomRegion top.
	""
	rightRegion := ownerBounds left: ownerBounds right - (ownerBounds width // 5).
	rightRegion := rightRegion top: topRegion bottom.
	rightRegion := rightRegion bottom: bottomRegion top.
	""
	droppedPosition := anEvent position.
	(topRegion containsPoint: droppedPosition)
		ifTrue: [
			^ self adhereToTop].
	(bottomRegion containsPoint: droppedPosition)
		ifTrue: [
			^ self adhereToBottom].
	(leftRegion containsPoint: droppedPosition)
		ifTrue: [
			^ self adhereToLeft].
	(rightRegion containsPoint: droppedPosition)
		ifTrue: [
			^ self adhereToRight].
	""
	self beFloating
]

{ #category : #'events-processing' }
DockingBarMorph >> keyStroke: evt [ 

	| asc |
	asc := evt keyCharacter asciiValue.
	asc = 27 ifTrue: [ "escape key" 
		^self deactivate: evt ].
	asc = self selectSubmenuKey ifTrue: [
		self ensureSelectedItem: evt.
		self selectedItem subMenu ifNotNil: [ :subMenu |
			subMenu items ifNotEmpty: [
				subMenu activate: evt.
				^subMenu moveSelectionDown: 1 event: evt ] ] ].
	asc = self previousKey ifTrue: [ ^self moveSelectionDown: -1 event: evt ].
	asc = self nextKey ifTrue: [ ^self moveSelectionDown: 1 event: evt ].
	selectedItem ifNotNil: [ 
		selectedItem subMenu ifNotNil: [ :subMenu |
			" If we didn't handle the keystroke, pass the keyboard focus 
			to the open submenu. "
			evt hand newKeyboardFocus: subMenu.
			subMenu keyStroke: evt ] ]
]

{ #category : #'WiW support' }
DockingBarMorph >> morphicLayerNumber [
	"helpful for insuring some morphs always appear in front of or 
	behind others. smaller numbers are in front"
	^ 11
]

{ #category : #'events-processing' }
DockingBarMorph >> mouseDown: evt [

	(self fullContainsPoint: evt position) ifFalse: [
		self selectItem: nil event: evt.
		self deleteIfPopUp: evt ]
]

{ #category : #'events-processing' }
DockingBarMorph >> mouseMove: evt [
	"We might transfer control to *either* the currently active submenu or the pop up owner, if any. Since the active sub menu is always displayed upfront check it first."
	
	selectedItem ifNotNil:[selectedItem activateSubmenu: evt].
]

{ #category : #'events-processing' }
DockingBarMorph >> mouseUp: evt [

	evt hand newMouseFocus: self.
]

{ #category : #control }
DockingBarMorph >> moveSelectionDown: direction event: evt [
	"Move the current selection up or down by one, presumably under keyboard control.
	direction = +/-1"

	| index |
	index := (submorphs indexOf: selectedItem ifAbsent: [1-direction]) + direction.
	submorphs do: "Ensure finite"
		[:unused | | m |
		m := submorphs atWrap: index.
		((m isKindOf: DockingBarItemMorph) and: [m isEnabled]) ifTrue:
			[^ self selectItem: m event: evt].
		"Keep looking for an enabled item"
		index := index + direction sign].
	^ self selectItem: nil event: evt
]

{ #category : #'events-processing' }
DockingBarMorph >> nextKey [

	self isHorizontal ifTrue: [ ^29 " right arrow" ].
	self isVertical ifTrue: [ ^31 " down arrow " ]
]

{ #category : #events }
DockingBarMorph >> oldKeyboardFocus [
	
	oldKeyboardFocus = self
		ifTrue: [ ^nil ]
		ifFalse: [ ^oldKeyboardFocus ]
]

{ #category : #events }
DockingBarMorph >> oldMouseFocus [
	
	oldMouseFocus = self
		ifTrue: [ ^nil ]
		ifFalse: [ ^oldMouseFocus ]
]

{ #category : #events }
DockingBarMorph >> oldMouseFocus: aMorph [
	
	(self submorphs includes: aMorph) 
		ifFalse: [ oldMouseFocus := aMorph ]
		ifTrue: [ oldMouseFocus := nil ]
	
]

{ #category : #'change reporting' }
DockingBarMorph >> ownerChanged [
"The receiver's owner has changed its layout. "
	self updateBounds.
	^ super ownerChanged
]

{ #category : #'private - accessing' }
DockingBarMorph >> predominantDockingBarsOfChastes: predominantChastes [ 
	"Private - Answer a collection of the docking bar of my owner  
	that are predominant to the receiver.  
	 
	By 'predominant' we mean docking bar that have the right to  
	get a position before the receiver.  
	 
	The predominance of individual living in the same chaste is  
	determinated by the arrival order.  
	"
	| allDockingBars byChaste byArrival |
	(self owner isNil
			or: [self owner isHandMorph])
		ifTrue: [^ #()].
	""
	allDockingBars := self owner dockingBars.
	""
	byChaste := allDockingBars
				select: [:each | predominantChastes includes: each edgeToAdhereTo].
	""
	(predominantChastes includes: self edgeToAdhereTo)
		ifFalse: [^ byChaste].
	""
	byChaste := byChaste
				reject: [:each | each edgeToAdhereTo = self edgeToAdhereTo].
	""
	byArrival := allDockingBars
				select: [:each | each edgeToAdhereTo = self edgeToAdhereTo].

	byArrival := byArrival copyAfter: self.
	""
	^ byChaste , byArrival
]

{ #category : #'events-processing' }
DockingBarMorph >> previousKey [

	self isHorizontal ifTrue: [ ^28 "left arrow" ].
	self isVertical ifTrue: [ ^30 "up arrow " ]
]

{ #category : #'events-processing' }
DockingBarMorph >> processFocusEvent: evt using: dispatcher [

	^ dispatcher dispatchFocusEventFully: evt with: self
]

{ #category : #'initialize-release' }
DockingBarMorph >> release [
	activeSubMenu := selectedItem := oldKeyboardFocus := oldMouseFocus := nil
]

{ #category : #accessing }
DockingBarMorph >> resistsRemoval [
"Answer whether the receiver is marked as resisting removal"
	^ Preferences noviceMode
		or: [super resistsRemoval]
]

{ #category : #accessing }
DockingBarMorph >> rootMenu [
	^ self
]

{ #category : #rounding }
DockingBarMorph >> roundedCorners [
	"Return a list of those corners to round"
	self isAdheringToTop
		ifTrue: [^ #(2 3 )].
	self isAdheringToBottom
		ifTrue: [^ #(1 4 )].
	self isAdheringToLeft 
		ifTrue: [^ #(3 4 )].
	self isAdheringToRight
		ifTrue: [^ #(1 2 )].
	^ #(1 2 3 4 )
]

{ #category : #'events-processing' }
DockingBarMorph >> searchBarMorph [

	^self submorphs detect: [ :each | each knownName = #searchBar ] ifNone: [ nil ]
]

{ #category : #control }
DockingBarMorph >> selectItem: aMenuItem event: anEvent [ 
	selectedItem
		ifNotNil: [selectedItem deselect: anEvent].
	selectedItem := aMenuItem.
	selectedItem
		ifNotNil: [selectedItem select: anEvent]
]

{ #category : #'events-processing' }
DockingBarMorph >> selectSubmenuKey [

	self isAdheringToTop ifTrue: [ ^31 ].
	self isAdheringToRight ifTrue: [ ^28 ].
	self isAdheringToLeft ifTrue: [ ^29 ].
	self isAdheringToBottom ifTrue: [ ^30 ].
	^31
]

{ #category : #private }
DockingBarMorph >> selectedItem [

	(selectedItem notNil and: [ 
		selectedItem isSelected ]) ifTrue: [ 
			^selectedItem ].
	^ nil
]

{ #category : #'initialize-release' }
DockingBarMorph >> setDefaultParameters [
	"private - set the default parameter using Preferences as the inspiration source"

	self
		color: (self userInterfaceTheme color ifNil: [Color r: 0.9 g: 0.9 b: 0.9]);
		borderStyle: (self userInterfaceTheme borderStyle ifNil: [BorderStyle simple]) copy;
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color gray]);
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [0]).
		
	self extent: (Preferences standardMenuFont height asPoint).
]

{ #category : #menus }
DockingBarMorph >> snapToEdgeIfAppropriate [
	(self owner isNil
			or: [self owner isHandMorph])
		ifTrue: [^ self].
	""
	self updateBounds
]

{ #category : #accessing }
DockingBarMorph >> stayUp [
	^ false
]

{ #category : #menu }
DockingBarMorph >> toggleAutoGradient [
	self autoGradient: self autoGradient not
]

{ #category : #menu }
DockingBarMorph >> toggleAvoidVisibleBordersAtEdge [
	self avoidVisibleBordersAtEdge: self avoidVisibleBordersAtEdge not
]

{ #category : #menu }
DockingBarMorph >> toggleFillsOwner [
	self fillsOwner: self fillsOwner not
]

{ #category : #'private - layout' }
DockingBarMorph >> updateBounds [
	"private - update the receiver's bounds"
	self updateExtent.
	self isFloating
		ifFalse: [self updatePosition]
]

{ #category : #'private - layout' }
DockingBarMorph >> updateColor [
	"private - update the receiver's color"
	| fill |
	MenuMorph gradientMenu ifFalse: [
		self color ~= originalColor ifTrue: [self color: originalColor].
		^ self].
	""
	fill := GradientFillStyle ramp: self gradientRamp.
	""
	fill origin: self topLeft.
	self isVertical
		ifTrue: [fill direction: self width @ 0]
		ifFalse: [fill direction: 0 @ self height].
	""
	self fillStyle: fill
]

{ #category : #'private - layout' }
DockingBarMorph >> updateExtent [
	"private - update the receiver's extent"
	| margin |
	self fullBounds.
	self fillsOwner
		ifFalse: [^ self].
	""
	margin := self avoidVisibleBordersAtEdge
				ifTrue: [self borderWidth * 2]
				ifFalse: [0].""
	self isHorizontal
		ifTrue: [self width: self owner width + margin].""
	self isVertical
		ifTrue: [| usedHeight | 
			usedHeight := self usedHeightByPredominantDockingBarsOfChastes: #(#top #bottom ).
			self height: self owner height + margin - usedHeight]
]

{ #category : #'private - layout' }
DockingBarMorph >> updateLayoutProperties [
	"private - update the layout properties based on adhering,  
	fillsOwner and avoidVisibleBordersAtEdge preferencs"
	""
	(self isHorizontal
			or: [self isFloating])
		ifTrue: [self listDirection: #leftToRight]
		ifFalse: [self listDirection: #topToBottom].
	""
	self hResizing: #shrinkWrap.
	self vResizing: #shrinkWrap.
	self fillsOwner
		ifTrue: [""
			self isHorizontal
				ifTrue: [self hResizing: #spaceFill].
			self isVertical
				ifTrue: [self vResizing: #spaceFill]].
	""
	self isHorizontal ifTrue: [
		self submorphsDo: [:m | m hResizing: #shrinkWrap; vResizing: #spaceFill]].
	self isVertical ifTrue: [
		self submorphsDo: [:m | m vResizing: #shrinkWrap; hResizing: #spaceFill]].

]

{ #category : #'private - layout' }
DockingBarMorph >> updatePosition [
	"private - update the receiver's position"
	| edgeSymbol margin |
	edgeSymbol := self edgeToAdhereTo.
	self
		perform: (edgeSymbol , ':') asSymbol
		with: (self owner perform: edgeSymbol).
	""
	margin := self avoidVisibleBordersAtEdge
				ifTrue: [self borderWidth asPoint]
				ifFalse: [0 asPoint].
	""
	self isAdheringToTop
		ifTrue: [| usedHeight | 
			usedHeight := self usedHeightByPredominantDockingBarsOfChastes: #(#top ).
			self topLeft: self owner topLeft - margin + (0 @ usedHeight)].
	self isAdheringToBottom
		ifTrue: [| usedHeight | 
			usedHeight := self usedHeightByPredominantDockingBarsOfChastes: #(#bottom ).
			self bottomLeft: self owner bottomLeft + (-1 @ 1 * margin) - (0 @ usedHeight)].
	""
	self isAdheringToLeft
		ifTrue: [| usedHeight usedWidth | 
			usedHeight := self usedHeightByPredominantDockingBarsOfChastes: #(#top ).
			usedWidth := self usedWidthByPredominantDockingBarsOfChastes: #(#left ).
			self topLeft: self owner topLeft - margin + (usedWidth @ usedHeight)].
	self isAdheringToRight
		ifTrue: [| usedHeight usedWidth | 
			usedHeight := self usedHeightByPredominantDockingBarsOfChastes: #(#top ).
			usedWidth := self usedWidthByPredominantDockingBarsOfChastes: #(#right ).
			self topRight: self owner topRight + (1 @ -1 * margin) + (usedWidth negated @ usedHeight)]
]

{ #category : #'private - accessing' }
DockingBarMorph >> usedHeightByPredominantDockingBarsOfChastes: predominantChastes [ 
	"Private - convenience"
	| predominants |
	predominants := self predominantDockingBarsOfChastes: predominantChastes.
	^ predominants isEmpty
		ifTrue: [0]
		ifFalse: [(predominants
				collect: [:each | each height]) sum]
]

{ #category : #'private - accessing' }
DockingBarMorph >> usedWidthByPredominantDockingBarsOfChastes: predominantChastes [ 
	"Private - convenience"
	| predominants |
	predominants := self predominantDockingBarsOfChastes: predominantChastes.
	^ predominants isEmpty
		ifTrue: [0]
		ifFalse: [(predominants
				collect: [:each | each width]) sum]
]

{ #category : #'events-processing' }
DockingBarMorph >> wantsEveryMouseMove [
	^ true
]

{ #category : #accessing }
DockingBarMorph >> wantsToBeTopmost [
	"Answer if the receiver want to be one of the topmost objects in 
	its owner"
	^ true
]

{ #category : #menu }
DockingBarMorph >> wantsYellowButtonMenu [
	"Answer true if the receiver wants a yellow button menu"
	^ Preferences noviceMode not
]
