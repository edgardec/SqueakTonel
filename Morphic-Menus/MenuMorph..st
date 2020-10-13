"
Instance variables:
	defaultTarget 	<Object>				The default target for creating menu items
	selectedItem		<MenuItemMorph> 	The currently selected item in the receiver
	stayUp 			<Boolean>			True if the receiver should stay up after clicks
	popUpOwner 	<MenuItemMorph>	The menu item that automatically invoked the receiver, if any.
	activeSubMenu 	<MenuMorph>		The currently active submenu.
"
Class {
	#name : #MenuMorph,
	#superclass : #Morph,
	#instVars : [
		'defaultTarget',
		'selectedItem',
		'stayUp',
		'popUpOwner',
		'activeSubMenu',
		'originalFocusHolder'
	],
	#classVars : [
		'CloseBoxImage',
		'CloseBoxImageFlat',
		'CloseBoxImageGradient',
		'GradientMenu',
		'MenuBorderColor',
		'MenuBorderWidth',
		'MenuColor',
		'MenuLineColor',
		'MenuSelectionColor',
		'MenuTitleBorderColor',
		'MenuTitleBorderWidth',
		'MenuTitleColor',
		'PushPinImage',
		'RoundedMenuCorners'
	],
	#category : #'Morphic-Menus'
}

{ #category : #utilities }
MenuMorph class >> chooseFrom: aList lines: linesArray title: queryString [
	"Choose an item from the given list. Answer the index of the selected item."

	| menu aBlock result |
	aBlock := [:v | result := v].
	menu := self new.
	menu addTitle: queryString.
	1 to: aList size do: [:i| 
		menu add: (aList at: i) asString target: aBlock selector: #value: argument: i.
		(linesArray includes: i) ifTrue:[menu addLine]].
	MenuIcons decorateMenu: menu.
	result := 0.
	menu
		invokeAt: self currentHand position
		in: self currentWorld
		allowKeyboard: true.
	^ result
]

{ #category : #utilities }
MenuMorph class >> chooseFrom: aList values: valueList lines: linesArray title: queryString [
	"Choose an item from the given list. Answer the index of the selected item."
	| index |
	index := self chooseFrom: aList lines: linesArray title: queryString.
	^ valueList at: index ifAbsent: [nil]
]

{ #category : #images }
MenuMorph class >> closeBoxImage [

	^ self gradientMenu
		ifTrue: [self closeBoxImageGradient]
		ifFalse: [self closeBoxImageFlat]
]

{ #category : #images }
MenuMorph class >> closeBoxImageFlat [

	^ CloseBoxImageFlat ifNil: [CloseBoxImageFlat := SystemWindow closeBoxImageFlat]
]

{ #category : #images }
MenuMorph class >> closeBoxImageGradient [

	^ CloseBoxImageGradient ifNil: [CloseBoxImageGradient := SystemWindow closeBoxImageGradient]
]

{ #category : #utilities }
MenuMorph class >> confirm: queryString [
	"Put up a yes/no menu with caption queryString. Answer true if the 
	response is yes, false if no. This is a modal question--the user must 
	respond yes or no."

	"MenuMorph confirm: 'Are you hungry?'"

	^ self confirm: queryString trueChoice: 'Yes' translated falseChoice: 'No' translated
]

{ #category : #utilities }
MenuMorph class >> confirm: queryString orCancel: cancelBlock [ 
	"Put up a yes/no/cancel menu with caption aString. Answer true if  the response is yes, false if no. If cancel is chosen, evaluate cancelBlock. This is a modal question--the user must respond yes or no."
	"MenuMorph confirm: 'Reboot universe' orCancel:[^'Nevermind'] "
	| choice |
	choice := self chooseFrom: {'Yes' translated. 'No' translated. 'Cancel' translated}
		lines: #()
		title: queryString.
	choice = 1 ifTrue: [^ true].
	choice = 2 ifTrue: [^ false].
	^ cancelBlock value
]

{ #category : #utilities }
MenuMorph class >> confirm: queryString trueChoice: trueChoice falseChoice: falseChoice [ 
	"Put up a yes/no menu with caption queryString. The actual wording for the two choices will be as provided in the trueChoice and falseChoice parameters. Answer true if the response is the true-choice,  false if it's the false-choice. This is a modal question -- the user must respond one way or the other."
	"MenuMorph 
		confirm: 'Are you hungry?'  
		trueChoice: 'yes, I''m famished'  
		falseChoice: 'no, I just ate'"

	| menu aBlock result |
	aBlock := [:v | result := v].
	menu := self new.
	menu addTitle: queryString icon: MenuIcons confirmIcon.
	menu add: trueChoice target: aBlock selector: #value: argument: true.
	menu add: falseChoice target: aBlock selector: #value: argument: false.
	MenuIcons decorateMenu: menu.
	[menu
		invokeAt: self currentHand position
		in: self currentWorld
		allowKeyboard: true.
	result == nil] whileTrue.
	^ result
]

{ #category : #'instance creation' }
MenuMorph class >> entitled: aString [
	"Answer a new instance of me with the given title."

	^ self new addTitle: aString

]

{ #category : #example }
MenuMorph class >> example [
	"MenuMorph example popUpInWorld"

	| menu |
	menu := MenuMorph new.
	menu addTitle: 'Fruit' translated.
	menu addStayUpItem.
	menu add: 'apples' action: #apples.
	menu add: 'oranges' action: #oranges.
	menu addLine.
	menu addLine.  "extra lines ignored"
	menu add: 'peaches' action: #peaches.
	menu addLine.
	menu add: 'pears' action: #pears.
	menu addLine.
	^ menu

]

{ #category : #'instance creation' }
MenuMorph class >> fromArray: anArray [ 
	"Construct a menu from anArray. The elements of anArray  
	must be either:  
	* A pair of the form: <label> <selector>  
	or	* The 'dash' (or 'minus sign') symbol  
	 
	Refer to the example at the bottom of the method"
	| menu |

	menu := self new.

	anArray
		do: [:anElement |
			anElement size = 1
				ifTrue: [
					anElement == #- ifFalse: [^ self error: 'badly-formed menu constructor'].
					menu addLine.
				]
				ifFalse: [
					anElement size = 2 ifFalse: [^ self error: 'badly-formed menu constructor'].
					menu add: anElement first action: anElement second.
				]
		].

	^ menu
]

{ #category : #preferences }
MenuMorph class >> gradientMenu [

	<preference: 'gradientMenu'
		category: #menus
		description: 'If true, the menus will have a gradient look.'
		type: #Boolean>
	^ GradientMenu ifNil: [true]
]

{ #category : #preferences }
MenuMorph class >> gradientMenu: aBoolean [

	GradientMenu = aBoolean ifTrue: [^ self].
	GradientMenu := aBoolean.

	self flag: #refactor. "mt: Heavy use of the gradient-menu property..."
	
	SystemProgressMorph reset.
	PluggableTextMorph flushAdornmentCache.

	MenuMorph allSubInstancesDo: [:ea | ea setDefaultParameters; setTitleParameters; updateColor].
	DockingBarMorph allSubInstancesDo: [:ea | ea setDefaultParameters; updateColor].

	TheWorldMainDockingBar updateInstances.
	PluggableListMorph allSubInstancesDo: [:ea | ea setListParameters].
	SimpleHierarchicalListMorph allSubInstancesDo: [:ea | ea setDefaultParameters].
	
]

{ #category : #utilities }
MenuMorph class >> inform: queryString [
	"MenuMorph inform: 'I like Squeak'"

	| menu |
	menu := self new.
	menu addTitle: queryString icon: MenuIcons confirmIcon.
	menu add: 'OK' translated target: self selector: #yourself.
	MenuIcons decorateMenu: menu.
	menu
		invokeAt: self currentHand position
		in: self currentWorld
		allowKeyboard: true.
]

{ #category : #'instance creation' }
MenuMorph class >> initialize [

	"MenuMorph initialize"
	CloseBoxImage := nil.
	PushPinImage := nil.


]

{ #category : #images }
MenuMorph class >> pushPinImage [
	"Answer the push-pin image, creating and caching it at this time if it is absent"

	^ MenuIcons smallPinIcon
]

{ #category : #preferences }
MenuMorph class >> roundedMenuCorners [

	<preference: 'roundedMenuCorners'
		category: #menus
		description: 'Whether morphic menus should have rounded corners.'
		type: #Boolean>
	^ RoundedMenuCorners ifNil: [true]
]

{ #category : #preferences }
MenuMorph class >> roundedMenuCorners: aBoolean [

	RoundedMenuCorners := aBoolean.
	SystemProgressMorph reset.
	TheWorldMainDockingBar updateInstances.
]

{ #category : #preferences }
MenuMorph class >> themeProperties [

	^ super themeProperties, {
		{ #borderColor. 'Colors'. 'Color of the menu''s border.' }.
		{ #borderWidth. 'Borders'. 'Width of the menu''s border.' }.
		{ #borderStyle. 'Borders'. 'Whether to use a plain border, inset, or outset.' }.
		{ #color. 'Colors'. 'Background color of the menu.' }.

		{ #titleBorderColor. 'Colors'. 'Color of the menu title border.' }.
		{ #titleBorderWidth. 'Geometry'. 'Width of the menu title border.' }.
		{ #titleBorderStyle. 'Borders'. 'Whether to use a plain border, inset, or outset for the title.' }.
		{ #titleColor. 'Colors'. 'Background color of the menu'' title.' }.
		{ #titleFont. 'Fonts'. 'Font for menu title.' }.
		{ #titleTextColor. 'Colors'. 'Color for the menu title label.' }.

		{ #lineColor. 'Colors'. 'Color of the separators between menu items.' }.
		{ #lineStyle. 'Colors'. 'Use border-style to change appearance.' }.
		{ #lineWidth. 'Geometry'. 'How big the separators should be.' }.
	}
]

{ #category : #events }
MenuMorph >> activate: evt [
	"Receiver should be activated; e.g., so that control passes correctly."
	evt hand 
		newMouseFocus: self;
		newKeyboardFocus: self
]

{ #category : #control }
MenuMorph >> activeSubmenu: aSubmenu [ 
	activeSubMenu ifNotNil: [
		activeSubMenu delete ].
	activeSubMenu := aSubmenu.
	activeSubMenu ifNotNil: [
		activeSubMenu updateMenu ]
]

{ #category : #construction }
MenuMorph >> add: aString action: aSymbolOrValuable [ 
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the default target object."
	"Details: Note that the menu item added captures the default target object at the time the item is added; the default target can later be changed before added additional items without affecting the targets of previously added entries. The model is that each entry is like a button that knows everything it needs to perform its action."
	aSymbolOrValuable isSymbol
		ifTrue:
			[ self
				add: aString
				target: defaultTarget
				selector: aSymbolOrValuable
				argumentList: Array empty ]
		ifFalse:
			[ self
				add: aString
				target: aSymbolOrValuable
				selector: #value
				argumentList: Array empty ]
]

{ #category : #construction }
MenuMorph >> add: wordingString help: helpString action: aSymbol [ 
	"Append a menu item with the given label. If the item is  
	selected, it will send the given selector to the default target  
	object."
	"Details: Note that the menu item added captures the default  
	target object at the time the item is added; the default target  
	can later be changed before added additional items without  
	affecting the targets of previously added entries. The model is 
	that each entry is like a button that knows everything it needs 
	to perform its action."
	self
		add: wordingString
		target: defaultTarget
		selector: aSymbol
		argumentList: Array empty.
	self balloonTextForLastItem:helpString
]

{ #category : #construction }
MenuMorph >> add: wordingString icon: aForm help: helpString subMenu: aMenuMorph [ 
	"Append the given submenu with the given label."
	| item |
	item := MenuItemMorph new.

	item contents: wordingString.
	item subMenu: aMenuMorph.
	item icon: aForm.
	helpString isNil
		ifFalse: [item setBalloonText: helpString].
	self addMorphBack: item
]

{ #category : #construction }
MenuMorph >> add: wordingString icon: aForm subMenu: aMenuMorph [ 
	"Append the given submenu with the given label."
	^ self
		add: wordingString
		icon: aForm
		help: nil
		subMenu: aMenuMorph
]

{ #category : #construction }
MenuMorph >> add: aString selector: aSymbol argument: arg [

	self add: aString
		target: defaultTarget
		selector: aSymbol
		argumentList: (Array with: arg)

]

{ #category : #construction }
MenuMorph >> add: aString subMenu: aMenuMorph [ 
	"Append the given submenu with the given label."
	self
		add: aString
		icon: nil
		subMenu: aMenuMorph
]

{ #category : #construction }
MenuMorph >> add: aString subMenu: aMenuMorph target: target selector: aSymbol argumentList: argList [
	"Append the given submenu with the given label."

	| item |
	item := MenuItemMorph new.
	item 
		contents: aString;
		target: target;
		selector: aSymbol;
		arguments: argList asArray;
		subMenu: aMenuMorph.
	self addMorphBack: item.
	^item
]

{ #category : #construction }
MenuMorph >> add: aString target: aTarget action: aSymbol [ 
	self
		add: aString
		target: aTarget
		selector: aSymbol
		argumentList: Array empty
]

{ #category : #construction }
MenuMorph >> add: aString target: anObject selector: aSymbol [ 
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object."
	self
		add: aString
		target: anObject
		selector: aSymbol
		argumentList: Array empty
]

{ #category : #construction }
MenuMorph >> add: aString target: target selector: aSymbol argument: arg [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given argument."

	self add: aString
		target: target
		selector: aSymbol
		argumentList: (Array with: arg)

]

{ #category : #construction }
MenuMorph >> add: aString target: target selector: aSymbol argumentList: argList [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument."

	| item |
	item := MenuItemMorph new
		contents: aString;
		target: target;
		selector: aSymbol;
		arguments: argList asArray.
	self addMorphBack: item.

]

{ #category : #construction }
MenuMorph >> addAllFrom: aMenuMorph [ 
	aMenuMorph submorphs
		do: [:each | 
			(each isKindOf: MenuItemMorph)
				ifTrue: [self
						add: each contents
						target: each target
						selector: each selector
						argumentList: each arguments].
			(each knownName = #line)
				ifTrue: [self addLine]] 
]

{ #category : #accessing }
MenuMorph >> addBlankIconsIfNecessary: anIcon [ 
	"If any of my items have an icon, ensure that all do by using  
	anIcon for those that don't"
	self items
		reject: [:each | each hasIconOrMarker]
		thenDo: [:each | each icon: anIcon]
]

{ #category : #menu }
MenuMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu add: 'add title...' translated action: #addTitle.
	aCustomMenu add: 'set target...' translated action: #setTarget:.
	defaultTarget ifNotNil: [
		aCustomMenu add: 'add item...' translated action: #addItem].
	aCustomMenu add: 'add line' translated action: #addLine.
	(self items count:[:any| any hasSubMenu]) > 0
		ifTrue:[aCustomMenu add: 'detach submenu' translated action: #detachSubMenu:].
]

{ #category : #menu }
MenuMorph >> addItem [

	| string sel |
	string := UIManager default request: 'Label for new item?'.
	string isEmpty ifTrue: [^ self].
	sel := UIManager default request: 'Selector?'.
	sel isEmpty ifFalse: [sel := sel asSymbol].
	self add: string action: sel.

]

{ #category : #construction }
MenuMorph >> addItem: aBlock [
	| item |
	item := MenuItemMorph new.
	aBlock value: item.
	self addMenuItem: item
]

{ #category : #construction }
MenuMorph >> addLine [
	"Append a divider line to this menu. Suppress duplicate lines."

	| colorToUse |
	self hasItems ifFalse: [^ self].
	self lastSubmorph knownName = #line ifTrue: [^ self].
	
	colorToUse := self userInterfaceTheme lineColor ifNil: [Color gray: 0.9].
	self addMorphBack: (Morph new
		color: colorToUse;
		hResizing: #spaceFill;
		height: (self userInterfaceTheme lineWidth ifNil: [2]);
		borderStyle: (self userInterfaceTheme lineStyle ifNil: [BorderStyle inset]);
		borderColor: colorToUse;
		borderWidth: 1;
		name: #line; "see above"
		yourself).
]

{ #category : #construction }
MenuMorph >> addList: aList [
	"Add the given items to this menu, where each item is a pair (<string> <actionSelector>)..  If an element of the list is simply the symobl $-, add a line to the receiver.  The optional third element of each entry, if present, provides balloon help."

	aList do: [:tuple |
		(tuple == #-)
			ifTrue: [self addLine]
			ifFalse:
				[self add: tuple first action: tuple second.
				tuple size > 2 ifTrue:
					[self balloonTextForLastItem: tuple third]]]
]

{ #category : #construction }
MenuMorph >> addMenuItem: aMenuItemMorph [
	self addMorphBack: aMenuItemMorph
]

{ #category : #construction }
MenuMorph >> addService: aService for: serviceUser [
	"Append a menu item with the given service. If the item is selected, it will perform the given service."

	aService addServiceFor: serviceUser toMenu: self.
]

{ #category : #construction }
MenuMorph >> addServices2: services for: served extraLines: linesArray [

	services withIndexDo: [:service :i |
		service addServiceFor: served toMenu: self.
		self lastItem setBalloonText: service description.
		(linesArray includes: i)  ifTrue: [self addLine] ]

]

{ #category : #construction }
MenuMorph >> addServices: services for: served extraLines: linesArray [

	services withIndexDo: [:service :i |
		self addService: service for: served.
		submorphs last setBalloonText: service description.
		(linesArray includes: i) | service useLineAfter 
			ifTrue: [self addLine]].

]

{ #category : #construction }
MenuMorph >> addStayUpIcons [
	| title closeBox pinBox |
	title := submorphs
				detect: [:ea | ea hasProperty: #titleString]
				ifNone: [
					"Called too soon. Will add stay-up icons when title is added."
					self setProperty: #needsTitlebarWidgets toValue: true.
					^ self].
	closeBox := SystemWindowButton new target: self;
				 actionSelector: #delete;
				 color: Color transparent;
				 setBalloonText: 'close this menu' translated;
				 borderWidth: 0.
	self class closeBoxImage scaleIconToDisplay in: [:icon |
		closeBox labelGraphic: icon; extent: icon extent].
	pinBox := SystemWindowButton new target: self;
				 actionSelector: #stayUp:;
				 arguments: {true};
				 color: Color transparent;
				 setBalloonText: 'keep this menu up' translated;
				 borderWidth: 0.
	self class pushPinImage scaleIconToDisplay in: [:icon |
		pinBox labelGraphic: icon; extent: icon extent].
		
	title
		addMorphFront: closeBox;
		addMorphBack: pinBox.
		
	self setProperty: #hasTitlebarWidgets toValue: true.
	self removeProperty: #needsTitlebarWidgets.
	self removeStayUpItems
]

{ #category : #construction }
MenuMorph >> addStayUpItem [
	"Append a menu item that can be used to toggle this menu's persistence."

	(self valueOfProperty: #hasTitlebarWidgets ifAbsent: [ false ])
		ifTrue: [ ^self ].
	self addStayUpIcons.
]

{ #category : #construction }
MenuMorph >> addStayUpItemSpecial [
	"Append a menu item that can be used to toggle this menu's persistent."

	"This variant is resistant to the MVC compatibility in #setInvokingView:"

	(self valueOfProperty: #hasTitlebarWidgets ifAbsent: [ false ])
		ifTrue: [ ^self ].
	self addStayUpIcons.
]

{ #category : #menu }
MenuMorph >> addTitle [

	| string |
	string := UIManager default request: 'Title for this menu?'.
	string isEmpty ifTrue: [^ self].
	self addTitle: string.

]

{ #category : #construction }
MenuMorph >> addTitle: aString [
	"Add a title line at the top of this menu."

	self addTitle: aString updatingSelector: nil updateTarget: nil
]

{ #category : #construction }
MenuMorph >> addTitle: aString icon: aForm [ 
	"Add a title line at the top of this menu."
	self
		addTitle: aString
		icon: aForm
		updatingSelector: nil
		updateTarget: nil 
]

{ #category : #construction }
MenuMorph >> addTitle: aString icon: aForm updatingSelector: aSelector updateTarget: aTarget [ 
	"Add a title line at the top of this menu Make aString its initial contents. If aSelector is not nil, then periodically obtain fresh values for its contents by sending aSelector to aTarget."
	
	| container fontToUse colorToUse labelArea |
	
	container := AlignmentMorph newRow.
	self setTitleParametersFor: container.
	
	aForm ifNotNil: [:form | container addMorphBack: form asMorph].

	fontToUse := self userInterfaceTheme titleFont ifNil: [TextStyle defaultFont].
	colorToUse := self userInterfaceTheme titleTextColor ifNil: [Color black].
	
	"Build the label."
	aSelector
		ifNil: [
			labelArea := AlignmentMorph newColumn
				color: Color transparent;
				vResizing: #shrinkWrap;
				wrapCentering: #center;
				cellPositioning: #topCenter.
			aString asString linesDo: [:line | labelArea 
					addMorphBack: ((StringMorph contents: line 
										font: fontToUse)
										color: colorToUse;
										yourself)]]
		ifNotNil: [
			labelArea := UpdatingStringMorph on: aTarget selector: aSelector.
			labelArea font: fontToUse.
			labelArea color: colorToUse.
			labelArea useStringFormat.
			labelArea lock].
		
	container addMorphBack: labelArea.
	""
	container setProperty: #titleString toValue: aString.
	self addMorphFront: container.
	""
	(self hasProperty: #needsTitlebarWidgets)
		ifTrue: [self addStayUpIcons]
]

{ #category : #construction }
MenuMorph >> addTitle: aString updatingSelector: aSelector updateTarget: aTarget [ 
	"Add a title line at the top of this menu Make aString its initial  
	contents.  
	If aSelector is not nil, then periodically obtain fresh values for  
	its contents by sending aSelector to aTarget.."
	^ self
		addTitle: aString
		icon: nil
		updatingSelector: aSelector
		updateTarget: aTarget
]

{ #category : #construction }
MenuMorph >> addTranslatedList: aList [
	"Add the given items to this menu, where each item is a pair (<string> <actionSelector>)..  If an element of the list is simply the symobl $-, add a line to the receiver.  The optional third element of each entry, if present, provides balloon help.
	The first and third items will be translated."

	aList do: [:tuple |
		(tuple == #-)
			ifTrue: [self addLine]
			ifFalse:
				[self add: tuple first translated action: tuple second.
				tuple size > 2 ifTrue:
					[self balloonTextForLastItem: tuple third translated ]]]
]

{ #category : #construction }
MenuMorph >> addUpdating: aWordingSelector action: aSymbol [ 
	self
		addUpdating: aWordingSelector
		target: defaultTarget
		selector: aSymbol
		argumentList: Array empty
]

{ #category : #construction }
MenuMorph >> addUpdating: aWordingSelector enablement: anEnablementSelector action: aSymbol [ 
	self
		addUpdating: aWordingSelector
		enablementSelector: anEnablementSelector
		target: defaultTarget
		selector: aSymbol
		argumentList: Array empty
]

{ #category : #construction }
MenuMorph >> addUpdating: wordingSelector enablementSelector: enablementSelector target: target selector: aSymbol argumentList: argList [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument.  In this variant, the wording of the menu item is obtained by sending the wordingSelector to the target, and the optional enablementSelector determines whether or not the item should be enabled.  Answer the item itself."

	| item |
	item := UpdatingMenuItemMorph new
		target: target;
		selector: aSymbol;
		wordingProvider: target wordingSelector: wordingSelector;
		enablementSelector: enablementSelector;
		arguments: argList asArray.
	self addMorphBack: item.
	^ item

]

{ #category : #construction }
MenuMorph >> addUpdating: aWordingSelector target: aTarget action: aSymbol [ 
	self
		addUpdating: aWordingSelector
		target: aTarget
		selector: aSymbol
		argumentList: Array empty
]

{ #category : #construction }
MenuMorph >> addUpdating: wordingSelector target: target selector: aSymbol argumentList: argList [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument.  In this variant, the wording of the menu item is obtained by sending the wordingSelector to the target,  Answer the item added."

	| item |
	item := UpdatingMenuItemMorph new
		target: target;
		selector: aSymbol;
		wordingProvider: target wordingSelector: wordingSelector;
		arguments: argList asArray.
	self addMorphBack: item.
	^ item

]

{ #category : #construction }
MenuMorph >> addUpdatingItem: aBlock [
	| item |
	item := UpdatingMenuItemMorph new.
	aBlock value: item.
	self addMenuItem: item
]

{ #category : #construction }
MenuMorph >> addWithLabel: aLabel enablement: anEnablementSelector action: aSymbol [ 
	self
		addWithLabel: aLabel
		enablementSelector: anEnablementSelector
		target: defaultTarget
		selector: aSymbol
		argumentList: Array empty
]

{ #category : #construction }
MenuMorph >> addWithLabel: aLabel enablementSelector: enablementSelector target: target selector: aSymbol argumentList: argList [
	"Append a menu item with the given label. If the item is selected, it will send the given selector to the target object with the given arguments. If the selector takes one more argument than the number of arguments in the given list, then the triggering event is supplied as as the last argument.  In this variant, the wording of the menu item is constant, and the optional enablementSelector determines whether or not the item should be enabled."

	| item |
	item := UpdatingMenuItemMorph new
		target: target;
		selector: aSymbol;
		contents: aLabel;
		wordingProvider: target wordingSelector: nil;
		enablementSelector: enablementSelector;
		arguments: argList asArray.
	self addMorphBack: item.

]

{ #category : #update }
MenuMorph >> applyUserInterfaceTheme [

	| colorToUse |
	super applyUserInterfaceTheme.
	
	self setDefaultParameters.
	
	"Update properties of separating lines."
	colorToUse := self userInterfaceTheme lineColor ifNil: [Color gray: 0.9].
	self submorphs
		select: [:ea | ea knownName = #line]
		thenDo: [:line |
			line
				color: colorToUse;
				height: (self userInterfaceTheme lineWidth ifNil: [2]);
				borderStyle: (self userInterfaceTheme lineStyle ifNil: [BorderStyle inset]) copy;
				borderColor: colorToUse].
]

{ #category : #construction }
MenuMorph >> balloonTextForLastItem: balloonText [
	submorphs last setBalloonText: balloonText
]

{ #category : #accessing }
MenuMorph >> commandKeyHandler [
	"Answer the receiver's commandKeyHandler"

	^ self valueOfProperty: #commandKeyHandler ifAbsent: [nil]
]

{ #category : #accessing }
MenuMorph >> commandKeyHandler: anObject [
	"Set the receiver's commandKeyHandler.  Whatever you set here needs to be prepared to respond to the message #commandKeyTypedIntoMenu: "

	self setProperty: #commandKeyHandler toValue: anObject
]

{ #category : #events }
MenuMorph >> deactivate: evt [

	"If a stand-alone menu, just delete it"
	popUpOwner ifNil: [ 
		self deleteIfPopUp: evt.
		^true ].
	"If a sub-menu, then deselect, and return focus to outer menu"
	self selectItem: nil event: evt.
	evt hand newMouseFocus: popUpOwner owner.
	evt hand newKeyboardFocus: popUpOwner owner
]

{ #category : #accessing }
MenuMorph >> defaultTarget [
	^defaultTarget
]

{ #category : #construction }
MenuMorph >> defaultTarget: anObject [
	"Set the default target for adding menu items."

	defaultTarget := anObject.

]

{ #category : #initialization }
MenuMorph >> delete [
	"Delete the receiver."

	self hideKeyboardHelp.
	activeSubMenu ifNotNil: [activeSubMenu stayUp ifFalse: [activeSubMenu delete]].
	self isFlexed ifTrue: [^ owner delete].
	^ super delete
]

{ #category : #control }
MenuMorph >> deleteIfPopUp [
	"Remove this menu from the screen if stayUp is not true. If it is a submenu, also remove its owning menu."

	stayUp ifFalse: [self topRendererOrSelf delete].
	(popUpOwner notNil and: [popUpOwner isKindOf: MenuItemMorph]) ifTrue: [
		popUpOwner isSelected: false.
		(popUpOwner owner isKindOf: MenuMorph)
			ifTrue: [popUpOwner owner deleteIfPopUp]].
	self hideKeyboardHelp.

]

{ #category : #control }
MenuMorph >> deleteIfPopUp: evt [
	"Remove this menu from the screen if stayUp is not true. If it is a submenu, also remove its owning menu."

	stayUp ifFalse: [self topRendererOrSelf delete].
	(popUpOwner notNil) ifTrue: [
		popUpOwner isSelected: false.
		popUpOwner deleteIfPopUp: evt].
	evt ifNotNil: [
		evt hand releaseMouseFocus: self.
		originalFocusHolder ifNotNil: [
			self hideKeyboardHelp.
			evt hand newKeyboardFocus: originalFocusHolder.
			originalFocusHolder := nil]].
]

{ #category : #menu }
MenuMorph >> detachSubMenu: evt [
	| possibleTargets item subMenu index |
	possibleTargets := self items select:[:any| any hasSubMenu].
	possibleTargets size > 0 ifTrue:[
		index := UIManager default 
				chooseFrom: (possibleTargets collect:[:t| t contents asString])
				title: 'Which menu?'.
		index = 0 ifTrue:[^self]].
	item := possibleTargets at: index.
	subMenu := item subMenu.
	subMenu ifNotNil: [
		item subMenu: nil.
		item delete.
		subMenu stayUp: true.
		subMenu popUpOwner: nil.
		subMenu addTitle: item contents.
		evt hand attachMorph: subMenu].

]

{ #category : #'keyboard control' }
MenuMorph >> displayFiltered: evt [
	| matchStr allItems matches feedbackMorph |
	matchStr := self valueOfProperty: #matchString.
	allItems := self submorphs select: [:m | m isKindOf: MenuItemMorph].
	matches :=  allItems select: [:m | | isMatch | 
		isMatch := 
			matchStr isEmpty or: [
				m contents includesSubstring: matchStr caseSensitive: false].
		m isEnabled: isMatch.
		isMatch].
	feedbackMorph := self valueOfProperty: #feedbackMorph.
	feedbackMorph ifNil: [
		feedbackMorph := TextMorph new
			color: Color darkGray;
			yourself.
		self
			addLine;
			addMorphBack: feedbackMorph lock.
		self setProperty: #feedbackMorph toValue: feedbackMorph.
		self fullBounds.  "Lay out for submorph adjacency"].
	feedbackMorph contents: '<', matchStr, '>'.
	matchStr isEmpty ifTrue: [
		feedbackMorph delete.
		self submorphs last delete.
		self removeProperty: #feedbackMorph].
	" This method is invoked with evt = nil from MenuMorph >> removeMatchString. 
	The current implementation can't select an item without an event. "
	(evt notNil and: [ matches size >= 1 ]) ifTrue: [
		self selectItem: matches first event: evt]
]

{ #category : #menu }
MenuMorph >> doButtonAction [
	"Do the receiver's inherent button action.  Makes sense for the kind of MenuMorph that is a wrapper for a single menu-item -- pass it on the the item"

	(self findA: MenuItemMorph) ifNotNil: [:aMenuItem | aMenuItem doButtonAction]
]

{ #category : #'keystroke helpers' }
MenuMorph >> handleCRStroke: evt [

	| selectable |
	evt keyValue = 13 ifFalse: [ ^false ].
	selectedItem ifNotNil: [
		selectedItem hasSubMenu 
			ifTrue: [
				evt hand 
					newMouseFocus: selectedItem subMenu;
					newKeyboardFocus: selectedItem subMenu ]
			ifFalse:  [
				selectedItem invokeWithEvent: evt ].
		^true ].
	(selectable := self items) size = 1 ifTrue: [ 
		selectable first invokeWithEvent: evt ].
	^true
]

{ #category : #'keystroke helpers' }
MenuMorph >> handleCommandKeyPress: evt [

	(evt commandKeyPressed and: [
		self commandKeyHandler notNil ]) ifTrue: [
			self commandKeyHandler commandKeyTypedIntoMenu: evt.
			self deleteIfPopUp: evt.
			^true ].
	^false
]

{ #category : #'keystroke helpers' }
MenuMorph >> handleDownStroke: evt [

	evt keyValue = 31 ifFalse: [ ^false ].
	self moveSelectionDown: 1 event: evt.
	^true
]

{ #category : #'keystroke helpers' }
MenuMorph >> handleEscStroke: evt [

	evt keyValue = 27 ifFalse: [ ^false ].
	self 
		valueOfProperty: #matchString
		ifPresentDo: [ :str | 
			str isEmpty ifFalse: [ "If filtered, first ESC removes filter"
				self setProperty: #matchString toValue: String new.
				self selectItem: nil event: evt.
				self displayFiltered: evt.
				^true ] ].
	self deactivate: evt.
	^true
]

{ #category : #'keystroke helpers' }
MenuMorph >> handleFiltering: evt [

	| matchString |
	matchString := self valueOfProperty: #matchString ifAbsentPut: [ String new ].
	matchString := true
		caseOf: {
			[ evt keyCharacter = Character backspace ] ->
				[ matchString isEmpty 
					ifTrue: [ matchString ] 
					ifFalse: [ matchString allButLast ] ].
			[ evt keyValue >= 32 ] ->
				[ matchString , evt keyCharacter ] }
		otherwise: [ matchString ].
	self setProperty: #matchString toValue: matchString.
	self displayFiltered: evt
]

{ #category : #'keystroke helpers' }
MenuMorph >> handleLeftStroke: evt [

	28 = evt keyValue ifFalse: [ ^false ].
	self stepIntoSubmenu: evt.
	^true
]

{ #category : #'keystroke helpers' }
MenuMorph >> handlePageDownStorke: evt [

	evt keyValue = 12 ifFalse: [ ^false ].
	self moveSelectionDown: 5 event: evt.
	^true
]

{ #category : #'keystroke helpers' }
MenuMorph >> handlePageDownStroke: evt [

	evt keyValue = 12 ifFalse: [ ^false ].
	self moveSelectionDown: 5 event: evt.
	^true
]

{ #category : #'keystroke helpers' }
MenuMorph >> handlePageUpStroke: evt [

	evt keyValue = 11 ifFalse: [ ^false ].
	self moveSelectionDown: -5 event: evt.
	^true
]

{ #category : #'keystroke helpers' }
MenuMorph >> handleRightStroke: evt [

	29 = evt keyValue ifFalse: [ ^false ].
	self stepIntoSubmenu: evt.
	^true
]

{ #category : #'keystroke helpers' }
MenuMorph >> handleUpStorke: evt [

	evt keyValue = 30 ifFalse: [ ^false ].
	self moveSelectionDown: -1 event: evt.
	^true
]

{ #category : #'keyboard control' }
MenuMorph >> handlesKeyboard: evt [
	"Answer whether the receiver handles the keystroke represented by the event"

	^ evt anyModifierKeyPressed not or: [evt commandKeyPressed and: [self commandKeyHandler notNil]]
]

{ #category : #events }
MenuMorph >> handlesMouseDown: evt [
	^true
]

{ #category : #events }
MenuMorph >> handlesMouseOver: evt [
	^ true
]

{ #category : #accessing }
MenuMorph >> hasItems [
	"Answer if the receiver has menu items"
	^ submorphs
		anySatisfy: [:each | each isKindOf: MenuItemMorph] 
]

{ #category : #accessing }
MenuMorph >> hasSubMenu: aMenuMorph [
	self items do: [:each | (each hasSubMenu: aMenuMorph) ifTrue:[^true]].
	^ false

]

{ #category : #'keystroke helpers' }
MenuMorph >> hideKeyboardHelp [
	self deleteBalloon
]

{ #category : #testing }
MenuMorph >> indicateKeyboardFocus [

	^ self rootMenu hasProperty: #hasUsedKeyboard
]

{ #category : #'modal control' }
MenuMorph >> informUserAt: aPoint during: aBlock [
	"Add this menu to the Morphic world during the execution of the given block."

	| title world |
	title := self allMorphs detect: [ :ea | ea hasProperty: #titleString ].
	title := title submorphs first.
	self visible: false.
	world := self currentWorld.
	aBlock value: [:string|
		self visible ifFalse:[
			world addMorph: self centeredNear: aPoint.
			self visible: true].
		title contents: string.
		self setConstrainedPosition: self currentHand cursorPoint hangOut: false.
		self changed.
		world displayWorld "show myself"]. 
	self delete.
	world displayWorld.
]

{ #category : #initialization }
MenuMorph >> initialize [
	super initialize.

	self setDefaultParameters.

	self changeTableLayout.
	self listDirection: #topToBottom.
	self hResizing: #shrinkWrap.
	self vResizing: #shrinkWrap.
	defaultTarget := nil.
	selectedItem := nil.
	stayUp := false.
	popUpOwner := nil.
]

{ #category : #'modal control' }
MenuMorph >> invokeAt: aPoint in: aWorld allowKeyboard: aBoolean [
	"Add this menu to the given world centered at the given point. Wait for the user to make a selection and answer it. The selection value returned is an integer in keeping with PopUpMenu, if the menu is converted from an MVC-style menu."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop." 
	| w originalFocusHolder |
	originalFocusHolder := aWorld primaryHand keyboardFocus.
	self popUpAt: aPoint forHand: aWorld primaryHand in: aWorld allowKeyboard: aBoolean.
	w := aWorld outermostWorldMorph. "containing hand"
	[self isInWorld] whileTrue: [w doOneSubCycle].
	self delete.
	originalFocusHolder ifNotNil: [aWorld primaryHand newKeyboardFocus: originalFocusHolder].

]

{ #category : #private }
MenuMorph >> invokeMetaMenu: evt [
	stayUp ifFalse:[^self]. "Don't allow this"
	^super invokeMetaMenu: evt
]

{ #category : #'modal control' }
MenuMorph >> invokeModal [
	"Invoke this menu and don't return until the user has chosen a value.
	See example below on how to use modal menu morphs."
	^ self invokeModal: Preferences menuKeyboardControl

	"Example:
	| menu sub entry |
	menu := MenuMorph new.
	1 to: 3 do: [:i |
		entry := 'Line', i printString.
		sub := MenuMorph new.
		menu add: entry subMenu: sub.
		#('Item A' 'Item B' 'Item C')  do:[:subEntry|
			sub add: subEntry target: menu 
				selector: #modalSelection: argument: {entry. subEntry}]].
	menu invokeModal.
"


]

{ #category : #'modal control' }
MenuMorph >> invokeModal: allowKeyboardControl [
	"Invoke this menu and don't return until the user has chosen a value.  If the allowKeyboarControl boolean is true, permit keyboard control of the menu"

	^ self
		invokeModalAt: self currentHand position
		in: self currentWorld
		allowKeyboard: allowKeyboardControl
]

{ #category : #'modal control' }
MenuMorph >> invokeModalAt: aPoint in: aWorld [
	"Add this menu to the given world centered at the given point. Wait for the user to make a selection and answer it. The selection value returned is an integer in keeping with PopUpMenu, if the menu is converted from an MVC-style menu."
	"Details: This is invoked synchronously from the caller. In order to keep processing inputs and updating the screen while waiting for the user to respond, this method has its own version of the World's event loop."

	^ self invokeModalAt: aPoint in: aWorld allowKeyboard: Preferences menuKeyboardControl
]

{ #category : #'modal control' }
MenuMorph >> invokeModalAt: aPoint in: aWorld allowKeyboard: aBoolean [
	"Invoke this menu and don't return until the user has chosen a value.
	See senders of this method for finding out how to use modal menu morphs."
	| w originalFocusHolder |
	originalFocusHolder := aWorld primaryHand keyboardFocus.
	self popUpAt: aPoint forHand: aWorld primaryHand in: aWorld allowKeyboard: aBoolean.
	self isModalInvokationDone: false.
	w := aWorld outermostWorldMorph. "containing hand"
	[self isInWorld & self isModalInvokationDone not] whileTrue: [w doOneSubCycle].
	self delete.
	originalFocusHolder ifNotNil: [aWorld primaryHand newKeyboardFocus: originalFocusHolder].
	^ self modalSelection
]

{ #category : #'modal control' }
MenuMorph >> isModalInvokationDone [
	^self valueOfProperty: #isModalInvokationDone ifAbsent:[false]
]

{ #category : #'modal control' }
MenuMorph >> isModalInvokationDone: aBool [
	self setProperty: #isModalInvokationDone toValue: aBool

]

{ #category : #accessing }
MenuMorph >> itemWithWording: wording [
	"If any of the receiver's items or submenu items have the given wording (case-blind comparison done), then return it, else return nil."
	
	self items do:[:anItem | | found |
		found := anItem itemWithWording: wording.
		found ifNotNil:[^found]].
	^ nil
]

{ #category : #accessing }
MenuMorph >> items [

	^ submorphs select: [:m | m isKindOf: MenuItemMorph]

]

{ #category : #'dropping\/grabbing' }
MenuMorph >> justDroppedInto: aMorph event: evt [
	| halo |
	super justDroppedInto: aMorph event: evt.
	halo := evt hand halo.
	(halo notNil and:[halo target hasOwner: self]) ifTrue:[
		"Grabbed single menu item"
		self addHalo: evt.
	].
	stayUp ifFalse:[evt hand newMouseFocus: self].
	self hasDropShadow: Preferences menuAppearance3d.
]

{ #category : #'keyboard control' }
MenuMorph >> keyStroke: evt [ 
	self hideKeyboardHelp; noteRootMenuHasUsedKeyboard.
	self keyStrokeHandlers
		detect: [:each | self perform: each with: evt]
		ifNone: [self handleFiltering: evt]
]

{ #category : #'keystroke helpers' }
MenuMorph >> keyStrokeHandlers [

	^#(
		handleCommandKeyPress:
		handleCRStroke:
		handleEscStroke:
		handleLeftStroke:
		handleRightStroke:
		handleUpStorke:
		handleDownStroke:
		handlePageUpStroke:
		handlePageDownStroke:)
]

{ #category : #construction }
MenuMorph >> labels: labelList lines: linesArray selections: selectionsArray [ 
	"This method allows the receiver to accept old-style SelectionMenu creation messages. It should be used only for backward compatibility during the MVC-to-Morphic transition. New code should be written using the other menu construction protocol such as addList:."

	"Labels can be either a sting with embedded crs, or a collection of strings."

	| labelArray |
	labelArray := (labelList isString) 
				ifTrue: [labelList lines]
				ifFalse: [labelList]. 
	1 to: labelArray size
		do: 
			[:i | 
			self add: (labelArray at: i) action: (selectionsArray at: i).
			(linesArray includes: i) ifTrue: [self addLine]]
]

{ #category : #accessing }
MenuMorph >> lastItem [
	
	submorphs reverseDo: [ :each |
		(each isKindOf: MenuItemMorph) ifTrue: [ ^each ] ].
	^submorphs last
]

{ #category : #accessing }
MenuMorph >> lastSelection [
	"Return the label of the last selected item or nil."

	^selectedItem ifNotNil: [selectedItem selector]
]

{ #category : #'modal control' }
MenuMorph >> modalSelection [
	^self valueOfProperty: #modalSelection ifAbsent:[nil]
]

{ #category : #'modal control' }
MenuMorph >> modalSelection: anObject [
	self setProperty: #modalSelection toValue: anObject.
	self isModalInvokationDone: true
]

{ #category : #private }
MenuMorph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"
	^self valueOfProperty: #morphicLayerNumber  ifAbsent: [
		stayUp ifTrue:[100] ifFalse:[10]
	]
]

{ #category : #events }
MenuMorph >> mouseDown: evt [
	"Handle a mouse down event."
	(stayUp or:[self fullContainsPoint: evt position]) 
		ifFalse:[^self deleteIfPopUp: evt]. "click outside"
	self isSticky ifTrue: [^self].
	
	"Grab the menu and drag it to some other place"
	self hasDropShadow: false.
	evt hand grabMorph: self.
]

{ #category : #events }
MenuMorph >> mouseLeave: evt [
	self selectItem: nil event: evt.
]

{ #category : #events }
MenuMorph >> mouseMove: evt [
	" If the mouse moves over an item not selected, we try to set it as selected.
	If this happens depends on that the current selected item wants to release
	its selection. "

	self selectedItem ifNil: [
		self 
			selectItem: (
				self items 
					detect: [ :each | each containsPoint: evt position ] 
					ifNone: [ nil ])
			event: evt].

	"Transfer control to *either* the currently active submenu or the pop up owner, if any. Since the active sub menu is always displayed upfront check it first."	
	self selectedItem ifNotNil: [
		(self selectedItem activateSubmenu: evt) 
			ifTrue: [ ^self ]
			ifFalse: [ 
				(self containsPoint: evt position) ifFalse: [ 
					self selectItem: nil event: evt ] ] ].

	"Note: The following does not traverse upwards but it's the best I can do for now"
	popUpOwner ifNotNil:[(popUpOwner activateOwnerMenu: evt) ifTrue: [^ self]].

]

{ #category : #events }
MenuMorph >> mouseUp: evt [
	"Handle a mouse up event.
	Note: This might be sent from a modal shell."
	(self fullContainsPoint: evt position) ifFalse:[
		^ self deleteIfPopUp: evt].
	stayUp ifFalse:[
		"Still in pop-up transition; keep focus"
		evt hand newMouseFocus: self].
]

{ #category : #'keyboard control' }
MenuMorph >> moveSelectionDown: direction event: evt [
	"Move the current selection up or down by one, presumably under keyboard control.
	direction = +/-1"

	| index |
	index := (submorphs indexOf: selectedItem ifAbsent: [1-direction]) + direction.
	submorphs do: "Ensure finite"
		[:unused | | m |
		m := submorphs atWrap: index.
		((m isKindOf: MenuItemMorph) and: [m isEnabled]) ifTrue:
			[^ self selectItem: m event: evt].
		"Keep looking for an enabled item"
		index := index + direction sign].
	^ self selectItem: nil event: evt
]

{ #category : #'keystroke helpers' }
MenuMorph >> noteRootMenuHasUsedKeyboard [

	(self rootMenu hasProperty: #hasUsedKeyboard) ifFalse: [
		self setProperty: #hasUsedKeyboard toValue: true.
		self changed ].
]

{ #category : #control }
MenuMorph >> popUpAdjacentTo: rightOrLeftPoint forHand: hand from: sourceItem [ 
	"Present this menu at the given point under control of the given hand."
	
	| tryToPlace selectedOffset rightPoint leftPoint |
	hand world startSteppingSubmorphsOf: self.
	popUpOwner := sourceItem.
	
	self fullBounds.
	self updateColor.

	"ensure layout is current"
	selectedOffset := (selectedItem
				ifNil: [self items first]) position - self position.
	tryToPlace := [:where :mustFit | | delta | 
			self position: where - selectedOffset.
			delta := self boundsInWorld amountToTranslateWithin: sourceItem worldBounds.
			(delta x = 0
					or: [mustFit])
				ifTrue: [delta = (0 @ 0)
						ifFalse: [self position: self position + delta].
					sourceItem world addMorphFront: self.
					^ self]].
	rightPoint := rightOrLeftPoint first + ((self layoutInset + self borderWidth) @ 0).
	leftPoint := rightOrLeftPoint last + ((self layoutInset + self borderWidth - self width) @ 0).
	tryToPlace
		value: rightPoint value: false;
		 value: leftPoint value: false;
		 value: rightPoint value: true.
]

{ #category : #control }
MenuMorph >> popUpAt: aPoint forHand: hand in: aWorld [
	"Present this menu at the given point under control of the given hand.  Allow keyboard input into the menu."

	^ self popUpAt: aPoint forHand: hand in: aWorld allowKeyboard: Preferences menuKeyboardControl
]

{ #category : #control }
MenuMorph >> popUpAt: aPoint forHand: hand in: aWorld allowKeyboard: aBoolean [ 
	"Present this menu at the given point under control of the given 
	hand."
	| evt |
	aWorld submorphs
		select: [:each | (each isKindOf: MenuMorph)
				and: [each stayUp not]]
		thenCollect: [:menu | menu delete].
	self items isEmpty
		ifTrue: [^ self].
	MenuIcons decorateMenu: self.
	(self submorphs
		select: [:m | m isKindOf: UpdatingMenuItemMorph])
		do: [:m | m updateContents].
	"precompute width"
	self
		positionAt: aPoint
		relativeTo: (selectedItem
				ifNil: [self items first])
		inWorld: aWorld.
	aWorld addMorphFront: self.
	"Acquire focus for valid pop up behavior"
	hand
		newMouseFocus: self;
		showTemporaryCursor: nil.
	aBoolean
		ifTrue: [
			originalFocusHolder := hand keyboardFocus.
			hand newKeyboardFocus: self.
			self showKeyboardHelp].
	evt := hand lastEvent.
	(evt isKeyboard
			or: [evt isMouse
					and: [evt anyButtonPressed not]])
		ifTrue: ["Select first item if button not down"
			self moveSelectionDown: 1 event: evt
			"Select first item if button not down"].
	self updateColor.
	self changed
]

{ #category : #control }
MenuMorph >> popUpEvent: evt in: aWorld [
	"Present this menu in response to the given event."

	| aHand aPosition |
	aHand := evt ifNotNil: [evt hand] ifNil: [self currentHand].
	aPosition := aHand position truncated.
	^ self popUpAt: aPosition forHand: aHand in: aWorld
]

{ #category : #control }
MenuMorph >> popUpForHand: hand in: aWorld [
	| p |
	"Present this menu under control of the given hand."

	p := hand position truncated.
	^self popUpAt: p forHand: hand in: aWorld

]

{ #category : #control }
MenuMorph >> popUpInWorld [
	"Present this menu in the current World"

	^ self popUpInWorld: self currentWorld
]

{ #category : #control }
MenuMorph >> popUpInWorld: aWorld [
	"Present this menu under control of the given hand."
	^self popUpAt: aWorld primaryHand position forHand: aWorld primaryHand in: aWorld

]

{ #category : #control }
MenuMorph >> popUpNoKeyboard [
	"Present this menu in the current World, *not* allowing keyboard input into the menu"

	^ self
		popUpAt: self currentHand position
		forHand: self currentHand
		in: self currentWorld
		allowKeyboard: false
]

{ #category : #accessing }
MenuMorph >> popUpOwner [
	"Return the current pop-up owner that is the menu item that automatically initiated the receiver."
	^ popUpOwner

]

{ #category : #accessing }
MenuMorph >> popUpOwner: aMenuItemMorph [
	"Set the current pop-up owner"
	popUpOwner := aMenuItemMorph.

]

{ #category : #private }
MenuMorph >> positionAt: aPoint relativeTo: aMenuItem inWorld: aWorld [
	"Note: items may not be laid out yet (I found them all to be at 0@0),  
	so we have to add up heights of items above the selected item."

	| i yOffset sub delta |	
	self fullBounds. "force layout"
	i := 0.
	yOffset := 0.
	[(sub := self submorphs at: (i := i + 1)) == aMenuItem]
		whileFalse: [yOffset := yOffset + sub height].

	self position: aPoint - (2 @ (yOffset + 8)).

	"If it doesn't fit, show it to the left, not to the right of the hand."
	self right > aWorld worldBounds right
		ifTrue:
			[self right: aPoint x + 1].

	"Make sure that the menu fits in the world."
	delta := self bounds amountToTranslateWithin:
		(aWorld worldBounds withHeight: ((aWorld worldBounds height - 18) max: (self currentHand position y) + 1)).
	delta isZero ifFalse: [self position: self position + delta].
]

{ #category : #events }
MenuMorph >> processFocusEvent: evt using: dispatcher [

	^ dispatcher dispatchFocusEventFully: evt with: self
]

{ #category : #'keyboard control' }
MenuMorph >> removeMatchString [
	"Remove the matchString, if any."
	self setProperty: #matchString toValue: String new.
	self displayFiltered: nil
]

{ #category : #menu }
MenuMorph >> removeStayUpBox [
	| box |
	submorphs isEmpty ifTrue: [^self].
	(submorphs first isAlignmentMorph) ifFalse: [^self].
	box := submorphs first submorphs last.
	(box isKindOf: IconicButton) 
		ifTrue: 
			[box
				labelGraphic: (Form extent: box extent depth: 8);
				shedSelvedge;
				borderWidth: 0;
				lock]
]

{ #category : #menu }
MenuMorph >> removeStayUpItems [
	| stayUpItems |
	stayUpItems := self items select: [ :item | item isStayUpItem ].
	stayUpItems do: [ :ea | ea delete ].

]

{ #category : #accessing }
MenuMorph >> rootMenu [
	popUpOwner ifNil: [^ self].
	popUpOwner owner ifNil: [^ self].
	^ popUpOwner owner rootMenu
]

{ #category : #'keyboard control' }
MenuMorph >> selectCurrentItem: evt [ 
	| selectable |
	selectedItem ifNotNil: 
			[selectedItem hasSubMenu 
				ifTrue: [self selectSubMenu: evt]
				ifFalse: [selectedItem invokeWithEvent: evt]].
	(selectable := self items) size = 1 
		ifTrue: [selectable first invokeWithEvent: evt]
]

{ #category : #control }
MenuMorph >> selectItem: aMenuItem event: anEvent [
	"Change the selected item." 
	
	selectedItem ifNotNil:[selectedItem deselect: anEvent].
	selectedItem := aMenuItem.
	selectedItem ifNotNil:[selectedItem select: anEvent].
]

{ #category : #'keyboard control' }
MenuMorph >> selectMoreItem: evt [
	| allItems more |
	allItems := self submorphs select: [:m | m isKindOf: MenuItemMorph].
	more := allItems detect: [:m | (m contents size >= 4) and: [(m contents first: 4) asString = 'more'.]] ifNone: [^ self flash].
	self selectItem: more event: evt.
	selectedItem invokeWithEvent: evt
]

{ #category : #private }
MenuMorph >> selectedItem [
	^selectedItem
]

{ #category : #initialization }
MenuMorph >> setDefaultParameters [
	"change the receiver's appareance parameters"

	self
		color: (self userInterfaceTheme color ifNil: [Color r: 0.9 g: 0.9 b: 0.9]);
		borderStyle: (self userInterfaceTheme borderStyle ifNil: [BorderStyle simple]) copy;
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color gray]);
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [1]).

	Preferences menuAppearance3d ifTrue: [self addDropShadow].
	
	self layoutInset: 3.

]

{ #category : #menu }
MenuMorph >> setInvokingView: invokingView [
	"Re-work every menu item of the form
		<target> perform: <selector>
	to the form
		<target> perform: <selector> orSendTo: <invokingView>.
	This supports MVC's vectoring of non-model messages to the editPane."
	self items do:
		[:item |
		item hasSubMenu 
			ifTrue: [ item subMenu setInvokingView: invokingView]
			ifFalse: [ item arguments isEmpty ifTrue:  "only the simple messages"
						[item arguments: (Array with: item selector with: invokingView).
						item selector: #perform:orSendTo:]]]
]

{ #category : #menu }
MenuMorph >> setTarget: evt [ 
	"Set the default target object to be used for add item commands, and re-target all existing items to the new target or the the invoking hand."

	| oldDefaultTarget |
	oldDefaultTarget := defaultTarget .
	self sightTargets: evt. 
	oldDefaultTarget ~~ defaultTarget 
		ifTrue: [self updateItemsWithTarget: defaultTarget orWithHand: evt hand ].
	
]

{ #category : #initialization }
MenuMorph >> setTitleParameters [
		
	 self setTitleParametersFor: (self allMorphs
			detect: [:each | each hasProperty: #titleString]
			ifNone: [^ self]).
]

{ #category : #initialization }
MenuMorph >> setTitleParametersFor: aMenuTitle [ 

	aMenuTitle
		color: (self userInterfaceTheme titleColor ifNil: [Color transparent]);
		borderStyle: (self userInterfaceTheme titleBorderStyle ifNil: [BorderStyle simple]) copy;
		borderColor: (self userInterfaceTheme titleBorderColor ifNil: [Color r: 0.6 g: 0.7 b: 1]);
		borderWidth: (self userInterfaceTheme titleBorderWidth ifNil: [0]);
		cornerStyle: (self wantsRoundedCorners ifTrue: [#rounded] ifFalse: [#square]);
		vResizing: #shrinkWrap;
		wrapCentering: #center;
		cellPositioning: #center;
		cellGap: 5;
		layoutInset: (5@0 corner: 5@0).
]

{ #category : #'keystroke helpers' }
MenuMorph >> showKeyboardHelp [

	| help |
	help := self balloonMorphClass 
		string: 'Enter text to narrow selection\down to matching items ' withCRs
		for: self 
		corner: #topLeft.
	help popUpAt: self topCenter forHand: self activeHand
]

{ #category : #accessing }
MenuMorph >> stayUp [

	^ stayUp

]

{ #category : #accessing }
MenuMorph >> stayUp: aBoolean [

	stayUp := aBoolean.
	aBoolean ifTrue: [ self removeStayUpBox ].
	originalFocusHolder := nil. "Not needed anymore."
]

{ #category : #'keystroke helpers' }
MenuMorph >> stepIntoSubmenu: evt [

	(selectedItem notNil and: [ selectedItem hasSubMenu ]) ifTrue: [
		evt hand newMouseFocus: selectedItem subMenu.
		evt hand newKeyboardFocus: selectedItem subMenu.
		selectedItem subMenu moveSelectionDown: 1 event: evt.
		^true ].
	^false
]

{ #category : #menu }
MenuMorph >> target: aMorph [
"Set defaultTarget since thats what we got.
For the sake of targetSighting which assumes #target is a word we know."

defaultTarget := aMorph
]

{ #category : #construction }
MenuMorph >> title: aString [
	"Add a title line at the top of this menu."

	self addTitle: aString
]

{ #category : #menu }
MenuMorph >> toggleStayUp: evt [
	"Toggle my 'stayUp' flag and adjust the menu item to reflect its new state."

	self items do: [:item |
		item isStayUpItem ifTrue:
			[self stayUp: stayUp not.	
			 stayUp
				ifTrue: [item contents: 'dismiss this menu']
				ifFalse: [item contents: 'keep this menu up']]].
	evt hand releaseMouseFocus: self.
	stayUp ifFalse: [self topRendererOrSelf delete].

]

{ #category : #menu }
MenuMorph >> toggleStayUpIgnore: ignored evt: evt [

	"This variant is resistant to the MVC compatibility in #setInvokingView:"

	self toggleStayUp: evt.

]

{ #category : #'dropping\/grabbing' }
MenuMorph >> undoGrabCommand [
	^nil
]

{ #category : #'keyboard control' }
MenuMorph >> unfilterOrEscape: evt [ 
	self valueOfProperty: #matchString
		ifPresentDo: 
			[:str | 
			
			str isEmpty 
				ifFalse: 
					["If filtered, first ESC removes filter"

					self setProperty: #matchString toValue: String new.
					self selectItem: nil event: evt.
					self displayFiltered: evt]].
	"If a stand-alone menu, just delete it"
	popUpOwner ifNil: [^self delete].
	"If a sub-menu, then deselect, and return focus to outer menu"
	self selectSuperMenu: evt
]

{ #category : #control }
MenuMorph >> updateColor [
	| fill title cc |
	self class gradientMenu
		ifFalse: [^ self].
	(self fillStyle == self color) not 
		ifTrue: [^ self]. "Don't apply the gradient more than once"
	""
	title := self allMorphs
				detect: [:each | each hasProperty: #titleString]
				ifNone: [].
	
	cc := self color adjustSaturation: -0.08 brightness: 0.4.
	fill := GradientFillStyle ramp: {
		0.0 -> (title ifNil: [cc] ifNotNil: [cc muchLighter]). 
		0.25 -> (self color mixed: 0.5 with: cc). 
		1.0 -> self color}.
	""
	fill
		radial: false;
		origin: self topLeft;
		direction: 0 @ self height.
	""
	" 
	update the title color"

	title ifNotNil: [fill direction: 0@ title height].
	self fillStyle: fill.
	title ifNil: [^ self].
	""
	fill := GradientFillStyle ramp: {
			0.0 -> title color twiceLighter.
			1 -> title color twiceDarker}.
	""
	fill
		origin: title topLeft;
		direction: title width @ 0.
	""
	title fillStyle: fill
]

{ #category : #menu }
MenuMorph >> updateItemsWithTarget: aTarget orWithHand: aHand [
	"re-target all existing items"
	self items do: 
			[:item | item target ifNotNil: [
			item target isHandMorph 
				ifTrue: [item target: aHand]
				ifFalse: [item target: aTarget] ] ]
]

{ #category : #update }
MenuMorph >> updateMenu [
	" Do nothing "
]

{ #category : #copying }
MenuMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

super veryDeepFixupWith: deepCopier.
defaultTarget := deepCopier references at: defaultTarget ifAbsent: [defaultTarget].
popUpOwner := deepCopier references at: popUpOwner ifAbsent: [popUpOwner].
activeSubMenu := deepCopier references at: activeSubMenu ifAbsent:[activeSubMenu].
]

{ #category : #copying }
MenuMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	"defaultTarget := defaultTarget.		Weakly copied"
	selectedItem := selectedItem veryDeepCopyWith: deepCopier.
	stayUp := stayUp veryDeepCopyWith: deepCopier.
	popUpOwner := popUpOwner.		"Weakly copied"
	activeSubMenu := activeSubMenu. "Weakly copied"

]

{ #category : #events }
MenuMorph >> wantsEveryMouseMove [
	^ true
]

{ #category : #rounding }
MenuMorph >> wantsRoundedCorners [

	^ self class roundedMenuCorners or: [super wantsRoundedCorners]
]

{ #category : #control }
MenuMorph >> wantsToBeDroppedInto: aMorph [
	"Return true if it's okay to drop the receiver into aMorph.  A single-item MenuMorph is in effect a button rather than a menu, and as such should not be reluctant to be dropped into another object."

	^ (aMorph isWorldMorph or: [submorphs size = 1]) or:
		[Preferences systemWindowEmbedOK]
]
