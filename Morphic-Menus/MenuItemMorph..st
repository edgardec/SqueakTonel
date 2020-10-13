"
I represent an item in a menu.

Instance variables:
	isEnabled 	<Boolean>	True if the menu item can be executed.
	subMenu 	<MenuMorph | nil>	The submenu to activate automatically when the user mouses over the item.
	isSelected 	<Boolean>	True if the item is currently selected.
	target 		<Object>		The target of the associated action.
	selector 		<Symbol>	The associated action.
	arguments 	<Array>		The arguments for the associated action.
	icon		<Form | nil>	An optional icon form to be displayed to my left.

If I have a dynamic marker, created by strings like <yes> or <no> in my contents, it will be installed as a submorph.
"
Class {
	#name : #MenuItemMorph,
	#superclass : #StringMorph,
	#instVars : [
		'isEnabled',
		'subMenu',
		'isSelected',
		'target',
		'selector',
		'arguments',
		'icon'
	],
	#classVars : [
		'SubMenuMarker'
	],
	#category : #'Morphic-Menus'
}

{ #category : #preferences }
MenuItemMorph class >> applyUserInterfaceTheme [

	SubMenuMarker := self defaultSubMenuMarker.
]

{ #category : #defaults }
MenuItemMorph class >> defaultSubMenuMarker [

	^ MenuIcons subMenuMarker dyed: ((UserInterfaceTheme current get: #textColor for: self) ifNil: [Color black]).
]

{ #category : #'class initialization' }
MenuItemMorph class >> initialize [
	"MenuItemMorph initialize"

	SubMenuMarker := self defaultSubMenuMarker.

]

{ #category : #preferences }
MenuItemMorph class >> themeProperties [

	^ super themeProperties, {	
		{ #font. 'Fonts'. 'Font for menu items.' }.
		{ #textColor. 'Colors'. 'Color for the menu item''s labels.' }.
		{ #disabledTextColor. 'Colors'. 'Color to use for disabled menu item labels.' }.
		{ #selectionColor. 'Colors'. 'Color used for items when hovering or selecting them.' }.
		{ #selectionTextColor. 'Colors'. 'Color used for label when hovering or selecting them.' }.
	}
]

{ #category : #grabbing }
MenuItemMorph >> aboutToBeGrabbedBy: aHand [
	"Don't allow the receiver to act outside a Menu"
	| menu box |
	(owner notNil and:[owner submorphs size = 1]) ifTrue:[
		"I am a lonely menuitem already; just grab my owner"
		owner stayUp: true.
		^owner 	aboutToBeGrabbedBy: aHand].
	box := self bounds.
	menu := MenuMorph new defaultTarget: nil.
	menu addMorphFront: self.
	menu bounds: box.
	menu stayUp: true.
	self isSelected: false.
	^menu
]

{ #category : #accessing }
MenuItemMorph >> action: aBlock [

	self 
		target: aBlock;
		selector: #value
]

{ #category : #events }
MenuItemMorph >> activateOwnerMenu: evt [
	"Activate our owner menu; e.g., pass control to it"
	owner ifNil:[^false]. "not applicable"
	(owner fullContainsPoint: evt position) ifFalse:[^false].
	owner activate: evt.
	^true
]

{ #category : #events }
MenuItemMorph >> activateSubmenu: evt [
	"Activate our submenu; e.g., pass control to it"
	subMenu ifNil:[^false]. "not applicable"
	(subMenu fullContainsPoint: evt position) ifFalse:[^false].
	subMenu activate: evt.
	^true
]

{ #category : #accessing }
MenuItemMorph >> adaptToWorld: aWorld [

	super adaptToWorld: aWorld.
	target := target adaptedToWorld: aWorld.
]

{ #category : #accessing }
MenuItemMorph >> addSubMenu: aBlock [

	subMenu := self createSubmenu.
	aBlock value: subMenu.
	self changed.

]

{ #category : #accessing }
MenuItemMorph >> addUpdatingSubMenu: aBlock [

	subMenu := UpdatingMenuMorph new.
	subMenu updater: aBlock updateSelector: #value:.
	self changed.

]

{ #category : #selecting }
MenuItemMorph >> adjacentTo [

	^{ self outerBounds topRight. self bounds topLeft }
]

{ #category : #accessing }
MenuItemMorph >> allWordingsNotInSubMenus: verbotenSubmenuContentsList [
	"Answer a collection of the wordings of all items and subitems, but omit the stay-up item, and also any items in any submenu whose tag is in verbotenSubmenuContentsList"

	self isStayUpItem ifTrue:[^ #()].
	subMenu ifNotNil:
		[^ (verbotenSubmenuContentsList includes: self contents asString)
			ifTrue:
				[#()]
			ifFalse:
				[subMenu allWordingsNotInSubMenus: verbotenSubmenuContentsList]].

	^ Array with: self contents asString
]

{ #category : #updating }
MenuItemMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	
	self
		color: (self userInterfaceTheme textColor ifNil: [Color black]);
		font: (self userInterfaceTheme font ifNil: [TextStyle defaultFont]).
	
]

{ #category : #accessing }
MenuItemMorph >> arguments [

	^ arguments

]

{ #category : #accessing }
MenuItemMorph >> arguments: aCollection [

	arguments := aCollection.

]

{ #category : #private }
MenuItemMorph >> bottomArrow [
	^ ColorForm
		mappingWhiteToTransparentFrom: ((SubMenuMarker rotateBy: 90) asFormOfDepth:8)
]

{ #category : #browse }
MenuItemMorph >> browseAllImplementorsOfRealSelector [
	SystemNavigation default browseAllImplementorsOf: self realSelector localTo: target class
]

{ #category : #browse }
MenuItemMorph >> browseImplementationOfActionSelector [

	| method |
	method := target class lookupSelector: selector.
	ToolSet browse: method methodClass selector: method selector.
]

{ #category : #browse }
MenuItemMorph >> buildDebugMenu: aHandMorph [
	| aMenu |
	aMenu := super buildDebugMenu: aHandMorph.
	aMenu addLine.
	aMenu add: 'browse action code' translated target: self action: #browseImplementationOfActionSelector.
	aMenu add: 'debug action invocation' translated target: self action: #debugAction.
	^ aMenu
]

{ #category : #accessing }
MenuItemMorph >> colorToUse [

	^ isSelected & isEnabled
		ifTrue: [ self userInterfaceTheme selectionTextColor ifNil: [Color white] ]
		ifFalse: [ color ]
]

{ #category : #accessing }
MenuItemMorph >> contentString [
	^self valueOfProperty: #contentString
]

{ #category : #accessing }
MenuItemMorph >> contentString: aString [ 
	aString 
		ifNil: [self removeProperty: #contentString]
		ifNotNil: [self setProperty: #contentString toValue: aString]
]

{ #category : #accessing }
MenuItemMorph >> contents: aString [
	^self contents: aString withMarkers: true
]

{ #category : #accessing }
MenuItemMorph >> contents: aString withMarkers: aBool [
	^self contents: aString withMarkers: aBool inverse: false
]

{ #category : #accessing }
MenuItemMorph >> contents: aString withMarkers: aBool inverse: inverse [ 
	"Set the menu item entry. If aBool is true, parse aString for embedded markers."

	| markerIndex marker |
	self contentString: nil.	"get rid of old"
	aBool ifFalse: [^super contents: aString].
	self removeAllMorphs.	"get rid of old markers if updating"
	self hasIcon ifTrue: [ self icon: nil ].
	(aString notEmpty and: [aString first = $<]) 
		ifFalse: [^super contents: aString].
	markerIndex := aString indexOf: $>.
	markerIndex = 0 ifTrue: [^super contents: aString].
	marker := (aString copyFrom: 1 to: markerIndex) asLowercase.
	(#('<on>' '<off>' '<yes>' '<no>') includes: marker) 
		ifFalse: [^super contents: aString].
	self contentString: aString.	"remember actual string"
	marker := (marker = '<on>' or: [marker = '<yes>']) ~= inverse 
				ifTrue: [self onImage]
				ifFalse: [self offImage].
	super contents:  (aString copyFrom: markerIndex + 1 to: aString size).
	"And set the marker"
	marker := ImageMorph new image: marker scaleIconToDisplay.
	marker position: self left @ (self top + 2).
	self addMorphFront: marker
]

{ #category : #private }
MenuItemMorph >> createSubmenu [

	^MenuMorph new
]

{ #category : #private }
MenuItemMorph >> createUpdatingSubmenu [

	^UpdatingMenuMorph new
]

{ #category : #browse }
MenuItemMorph >> debugAction [

	(Process
		forBlock: [self doButtonAction]
		runUntil: [:context | context selector = self selector])
			debugWithTitle: ('Debug menu action "{1}" in model "{2}"' format: {self contents. self target printString}).
]

{ #category : #initialization }
MenuItemMorph >> defaultBounds [
"answer the default bounds for the receiver"
	^ 0 @ 0 extent: 10 @ 10
]

{ #category : #initialization }
MenuItemMorph >> deleteIfPopUp: evt [
	"Recurse up for nested pop ups"
	owner ifNotNil:[owner deleteIfPopUp: evt].
]

{ #category : #selecting }
MenuItemMorph >> deselect: evt [

	self isSelected: false.
	subMenu ifNotNil: [
		owner ifNotNil: [ owner activeSubmenu: nil ] ].
]

{ #category : #private }
MenuItemMorph >> deselectItem [
	| item |
	self isSelected: false.
	subMenu ifNotNil: [subMenu deleteIfPopUp].
	(owner isKindOf: MenuMorph) ifTrue:
		[item := owner popUpOwner.
		(item isKindOf: MenuItemMorph) ifTrue: [item deselectItem]].

]

{ #category : #events }
MenuItemMorph >> doButtonAction [
	"Called programattically, this should trigger the action for which the receiver is programmed"

	self invokeWithEvent: nil
]

{ #category : #layout }
MenuItemMorph >> doLayoutIn: layoutBounds [
	"Since we have no layout policy, make sure to compute the fullBounds right manually. Maybe we could also override #submorphBoundsForShrinkWrap, but since we have no submorphs, #adjustLayoutBounds is never called..."
	
	self hResizing = #shrinkWrap
		ifTrue: [self width: self minWidth].
	self vResizing = #shrinkWrap
		ifTrue: [self height: self minHeight].

	super doLayoutIn: layoutBounds.
]

{ #category : #drawing }
MenuItemMorph >> drawBackgroundOn: aCanvas [ 

	isSelected & isEnabled
		ifTrue: [aCanvas fillRectangle: self bounds fillStyle: self selectionFillStyle].
]

{ #category : #drawing }
MenuItemMorph >> drawIconOn: aCanvas [ 

	self hasIcon ifTrue: [
		| iconForm | 
		iconForm := self iconForm.
		aCanvas
			translucentImage: iconForm 
			at: self bounds left @ (self top + (self height - iconForm height // 2)).].
]

{ #category : #drawing }
MenuItemMorph >> drawLabelOn: aCanvas [ 

	| stringBounds |	
	stringBounds := self bounds.
	
	self hasIcon ifTrue: [
		stringBounds := stringBounds left: stringBounds left + self iconForm width + 2 ].
	self hasMarker ifTrue: [
		stringBounds := stringBounds left: stringBounds left + self submorphBounds width + 8 ].
	
	stringBounds := stringBounds top: stringBounds top + stringBounds bottom - self fontToUse height // 2.

	aCanvas
		drawString: self contents
		in: stringBounds
		font: self fontToUse
		color: self colorToUse.
]

{ #category : #drawing }
MenuItemMorph >> drawOn: aCanvas [ 

	self
		drawBackgroundOn: aCanvas;
		drawIconOn: aCanvas;
		drawLabelOn: aCanvas;
		drawSubMenuMarkerOn: aCanvas.
]

{ #category : #drawing }
MenuItemMorph >> drawSubMenuMarkerOn: aCanvas [ 

	self hasSubMenu ifTrue: [
		| subMenuMarker subMenuMarkerPosition | 
		subMenuMarker := self subMenuMarker.
		subMenuMarkerPosition := self right - subMenuMarker width @ (self top + self bottom - subMenuMarker height // 2).
		aCanvas paintImage: subMenuMarker at: subMenuMarkerPosition ]
]

{ #category : #grabbing }
MenuItemMorph >> duplicateMorph: evt [
	"Make and return a duplicate of the receiver's argument"
	| dup menu |
	dup := self duplicate isSelected: false.
	menu := MenuMorph new defaultTarget: nil.
	menu addMorphFront: dup.
	menu bounds: self bounds.
	menu stayUp: true.
	evt hand grabMorph: menu from: owner. "duplicate was ownerless so use #grabMorph:from: here"
	^menu
]

{ #category : #events }
MenuItemMorph >> handleMouseUp: anEvent [
	"The handling of control between menu item requires them to act on mouse up even if not the current focus. This is different from the default behavior which really only wants to handle mouse ups when they got mouse downs before"
	anEvent wasHandled ifTrue:[^self]. "not interested"
	anEvent hand releaseMouseFocus: self.
	anEvent wasHandled: true.
	self mouseUp: anEvent.
]

{ #category : #events }
MenuItemMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #events }
MenuItemMorph >> handlesMouseOver: anEvent [
	^true
]

{ #category : #events }
MenuItemMorph >> handlesMouseOverDragging: evt [
	^true
]

{ #category : #accessing }
MenuItemMorph >> hasIcon [
	"Answer whether the receiver has an icon. If menues without icons are
	requested, pretend to not bear one unless we have not content."
	^ self icon notNil and: [
		Preferences menuWithIcons or: [self contents isEmptyOrNil]].
]

{ #category : #accessing }
MenuItemMorph >> hasIconOrMarker [
	"Answer whether the receiver has an icon or a marker."
	^ self hasIcon or: [ submorphs isEmpty not ]
]

{ #category : #accessing }
MenuItemMorph >> hasMarker [
	"Answer whether the receiver has a marker morph."
	^ submorphs isEmpty not
]

{ #category : #accessing }
MenuItemMorph >> hasSubMenu [
	"Return true if the receiver has a submenu"
	^subMenu notNil
]

{ #category : #accessing }
MenuItemMorph >> hasSubMenu: aMenuMorph [
	subMenu ifNil:[^false].
	subMenu == aMenuMorph ifTrue:[^true].
	^subMenu hasSubMenu: aMenuMorph
]

{ #category : #accessing }
MenuItemMorph >> help: aString [

	self setBalloonText: aString
]

{ #category : #accessing }
MenuItemMorph >> icon [
	"answer the receiver's icon"
	^ icon
]

{ #category : #accessing }
MenuItemMorph >> icon: aFormOrNil [

	icon := aFormOrNil
		ifNotNil: [:form | form scaleIconToDisplay].
	self height: self minHeight.
	self width: self minWidth.
]

{ #category : #private }
MenuItemMorph >> iconForm [
	"private - answer the form to be used as the icon"
	^ isEnabled
		ifTrue: [self icon]
		ifFalse: [self icon asGrayScale]
]

{ #category : #initialization }
MenuItemMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	
	contents := ''.
	hasFocus := false.
	isEnabled := true.
	subMenu := nil.
	isSelected := false.
	target := nil.
	selector := nil.
	arguments := nil.
	font := self userInterfaceTheme font ifNil: [TextStyle defaultFont].
	self
		color: (self userInterfaceTheme textColor ifNil: [Color black]);
		hResizing: #spaceFill;
		vResizing: #shrinkWrap
]

{ #category : #events }
MenuItemMorph >> invokeWithEvent: evt [
	"Perform the action associated with the given menu item."

	self isEnabled ifFalse: [^ self].
	
	(owner notNil and: [self isStayUpItem not]) ifTrue: [
		self flag: #workAround. "The tile system invokes menus straightforwardly so the menu might not be in the world."
		self world ifNotNil: [:world |
			owner deleteIfPopUp: evt.
			"Repair damage before invoking the action for better feedback"
			world displayWorldSafely]].
	
	selector ifNil: [^ self].
	
	Cursor normal showWhile: [
		"show cursor in case item opens a new MVC window"
		selector numArgs isZero
				ifTrue: [target perform: selector]
				ifFalse: [target perform: selector withArguments: (
					selector numArgs = arguments size
						ifTrue: [arguments]
						ifFalse: [arguments copyWith: evt] )] ].
]

{ #category : #accessing }
MenuItemMorph >> isEnabled [

	^ isEnabled

]

{ #category : #accessing }
MenuItemMorph >> isEnabled: aBoolean [

	| colorToUse |
	isEnabled = aBoolean ifTrue: [^ self].
	isEnabled := aBoolean.
	
	colorToUse := isEnabled
		ifTrue: [self userInterfaceTheme textColor ifNil: [Color black]]
		ifFalse: [self userInterfaceTheme disabledTextColor ifNil: [Color gray]].
	
	self color: colorToUse.
]

{ #category : #testing }
MenuItemMorph >> isMenuItemMorph [
	^true
]

{ #category : #selecting }
MenuItemMorph >> isSelected [
	^ isSelected 
]

{ #category : #selecting }
MenuItemMorph >> isSelected: aBoolean [

	isSelected := aBoolean.
	self changed.

]

{ #category : #accessing }
MenuItemMorph >> isStayUpItem [

	^selector == #toggleStayUp: or: [selector == #toggleStayUpIgnore:evt:]
]

{ #category : #accessing }
MenuItemMorph >> itemWithWording: wording [
	"If any of the receiver's items or submenu items have the given wording (case-blind comparison done), then return it, else return nil."
	(self contents asString sameAs: wording) ifTrue:[^self].
	subMenu ifNotNil:[^subMenu itemWithWording: wording].
	^nil
]

{ #category : #private }
MenuItemMorph >> leftArrow [
	^ ColorForm
		mappingWhiteToTransparentFrom: ((SubMenuMarker rotateBy: 180)asFormOfDepth: 8)
]

{ #category : #layout }
MenuItemMorph >> minHeight [
	| iconHeight |
	iconHeight := self hasIcon
				ifTrue: [self icon height + 2]
				ifFalse: [0].
	^ self fontToUse height + 2 max: iconHeight
]

{ #category : #layout }
MenuItemMorph >> minWidth [

	| subMenuWidth iconWidth markerWidth |
	subMenuWidth := self hasSubMenu
		ifTrue: [ 10 ]
		ifFalse: [ 0 ].
	iconWidth := self hasIcon
		ifTrue: [ self icon width + 2 ]
		ifFalse: [ 0 ].
	markerWidth := self hasMarker
		ifTrue: [ self submorphBounds width + 8 ]
		ifFalse: [ 0 ].
	^(self fontToUse widthOfString: contents)
		+ subMenuWidth + iconWidth + markerWidth + self stringMargin
]

{ #category : #events }
MenuItemMorph >> mouseDown: evt [
	"Handle a mouse down event. Menu items get activated when the mouse is over them."

	evt shiftPressed ifTrue: [ ^super mouseDown: evt ].  "enable label editing" 
	evt hand newMouseFocus: owner. "Redirect to menu for valid transitions"
	owner selectItem: self event: evt
]

{ #category : #events }
MenuItemMorph >> mouseEnter: evt [
	"The mouse entered the receiver"

	owner ifNotNil: [ owner selectItem: self event: evt ]
]

{ #category : #events }
MenuItemMorph >> mouseEnterDragging: evt [

	self mouseEnter: evt.
]

{ #category : #events }
MenuItemMorph >> mouseUp: evt [
	"Handle a mouse up event. Menu items get activated when the mouse is over them. Do nothing if we're not in a 'valid menu transition', meaning that the current hand focus must be aimed at the owning menu."
	
	evt hand mouseFocus == owner ifFalse: [ ^self ].
	self contentString ifNotNil: [
		self contents: self contentString withMarkers: true inverse: true.
		self refreshWorld.
		(Delay forMilliseconds: 200) wait ].
	self deselect: evt.
	self invokeWithEvent: evt.		

]

{ #category : #private }
MenuItemMorph >> offImage [
	"Return the form to be used for indicating an '<off>' marker"
	
	^ MenuIcons checkBoxOff dyed: (self userInterfaceTheme textColor ifNil: [Color black])
]

{ #category : #private }
MenuItemMorph >> onImage [
	"Return the form to be used for indicating an '<on>' marker"

	^ MenuIcons checkBoxOn dyed: (self userInterfaceTheme textColor ifNil: [Color black])
]

{ #category : #browse }
MenuItemMorph >> realSelector [
	selector == #perform:orSendTo: ifTrue: [^arguments first].
	^selector
]

{ #category : #private }
MenuItemMorph >> rightArrow [

	^ SubMenuMarker
]

{ #category : #selecting }
MenuItemMorph >> select: evt [
	self isSelected: true.
	owner activeSubmenu: subMenu.
	subMenu ifNotNil: [
		subMenu delete.
		subMenu
			popUpAdjacentTo: self adjacentTo
			forHand: evt hand
			from: self.
		subMenu selectItem: nil event: evt].
]

{ #category : #private }
MenuItemMorph >> selectionFillStyle [
	" Answer the fill style to use with the receiver is the selected element "

	| fill baseColor |
	baseColor := self userInterfaceTheme selectionColor ifNil: [Color r: 0.4 g: 0.5 b: 0.7].
	MenuMorph gradientMenu ifFalse: [ ^baseColor ].

	fill := GradientFillStyle ramp: { 
		0.0 -> baseColor thriceLighter. 
		1 -> baseColor thriceDarker }.
	fill origin: self topLeft.
	fill direction: 0 @ self height.
	^ fill
]

{ #category : #accessing }
MenuItemMorph >> selector [

	^ selector

]

{ #category : #accessing }
MenuItemMorph >> selector: aSymbol [

	selector := aSymbol.

]

{ #category : #layout }
MenuItemMorph >> stringMargin [

	^Preferences tinyDisplay
		ifTrue: [ 1 ]
		ifFalse: [ 6 ]
]

{ #category : #accessing }
MenuItemMorph >> subMenu [

	^ subMenu

]

{ #category : #accessing }
MenuItemMorph >> subMenu: aMenuMorph [

	subMenu := aMenuMorph.
	self changed.

]

{ #category : #private }
MenuItemMorph >> subMenuMarker [
	"private - answer the form to be used as submenu marker"
	
	^self rightArrow
]

{ #category : #accessing }
MenuItemMorph >> subMenuUpdater: updater selector: selector [

	subMenu := self createUpdatingSubmenu.
	subMenu updater: updater updateSelector: selector.
	self changed.

]

{ #category : #accessing }
MenuItemMorph >> subMenuUpdater: updater selector: selector arguments: arguments [

	subMenu := self createUpdatingSubmenu.
	subMenu updater: updater updateSelector: selector arguments: arguments.
	self changed.

]

{ #category : #accessing }
MenuItemMorph >> target [

	^ target
]

{ #category : #accessing }
MenuItemMorph >> target: anObject [

	target := anObject.

]

{ #category : #private }
MenuItemMorph >> upArrow [
	^ ColorForm
		mappingWhiteToTransparentFrom: ((SubMenuMarker rotateBy: 270)asFormOfDepth: 8)
]

{ #category : #private }
MenuItemMorph >> updateLayoutInDockingBar [
]

{ #category : #copying }
MenuItemMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

	super veryDeepFixupWith: deepCopier.
	target := deepCopier references at: target ifAbsent: [target].
	arguments notNil ifTrue:
	[arguments := arguments collect: [:each |
		deepCopier references at: each ifAbsent: [each]]]
]

{ #category : #copying }
MenuItemMorph >> veryDeepInner: deepCopier [ 
	"Copy all of my instance variables. Some need to be not copied  
	at all, but shared. Warning!! Every instance variable defined in  
	this class must be handled. We must also implement  
	veryDeepFixupWith:. See DeepCopier class comment."
	super veryDeepInner: deepCopier.
	isEnabled := isEnabled veryDeepCopyWith: deepCopier.
	subMenu := subMenu veryDeepCopyWith: deepCopier.
	isSelected := isSelected veryDeepCopyWith: deepCopier.
	icon := icon veryDeepCopyWith: deepCopier.
	"target := target.		Weakly copied"
	"selector := selector.		a Symbol"
	arguments := arguments.
]

{ #category : #'meta actions' }
MenuItemMorph >> wantsHaloFromClick [
	"Only if I'm not a lonely submenu"
	^owner notNil and:[owner submorphs size > 1]
]
