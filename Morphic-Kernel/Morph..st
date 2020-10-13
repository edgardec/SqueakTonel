"
A Morph (from the Greek ""shape"" or ""form"") is an interactive graphical object. General information on the Morphic system can be found at http://wiki.squeak.org/squeak/30. 

Morphs exist in a tree, rooted at a World (generally a PasteUpMorph). The morphs owned by a morph are its submorphs. Morphs are drawn recursively; if a Morph has no owner it never gets drawn. To hide a Morph and its submorphs, set its #visible property to false using the #visible: method. 

The World (screen) coordinate system is used for most coordinates, but can be changed if there is a TransformMorph somewhere in the owner chain. 

My instance variables have accessor methods (e.g., #bounds, #bounds:). Most users should use the accessor methods instead of using the instance variables directly.

Structure:
instance var 	Type 			Description 
bounds 			Rectangle 		A Rectangle indicating my position and a size that will enclose 									me. 
owner 			Morph		 	My parent Morph, or nil for the top-level Morph, which is a
 				or nil			world, typically a PasteUpMorph.
submorphs 		Array 			My child Morphs. 
fullBounds 		Rectangle 		A Rectangle minimally enclosing me and my submorphs. 
color 			Color 			My primary color. Subclasses can use this in different ways. 
extension 		MorphExtension Allows extra properties to be stored without adding a
				or nil  				storage burden to all morphs. 

By default, Morphs do not position their submorphs. Morphs may position their submorphs directly or use a LayoutPolicy to automatically control their submorph positioning.

Although Morph has some support for BorderStyle, most users should use BorderedMorph if they want borders.
"
Class {
	#name : #Morph,
	#superclass : #Object,
	#instVars : [
		'bounds',
		'owner',
		'submorphs',
		'fullBounds',
		'color',
		'extension'
	],
	#classVars : [
		'HaloForAll',
		'IndicateKeyboardFocus',
		'MetaMenuForAll',
		'PreferredCornerRadius',
		'UseSoftDropShadow'
	],
	#category : #'Morphic-Kernel'
}

{ #category : #testing }
Morph class >> allSketchMorphClasses [
	"Morph allSketchMorphClasses"
	^ Array
		streamContents: [:s | self
				withAllSubclassesDo: [:cls | cls isSketchMorphClass
						ifTrue: [s nextPut: cls ]]]

]

{ #category : #testing }
Morph class >> allSketchMorphForms [
	"Answer a Set of forms of SketchMorph (sub) instances, except those 
	used as button images, ones being edited, and those with 0 extent."

	| reasonableForms |
	reasonableForms := Set new.
	Morph allSketchMorphClasses do:
		[:cls | cls allInstances do:
			[:m | | form |
			(m owner isKindOf: SketchEditorMorph orOf: IconicButton)
				ifFalse:
					[form := m form.
					((form width > 0) and: [form height > 0]) ifTrue: [reasonableForms add: form]]]].
	^ reasonableForms
]

{ #category : #scripting }
Morph class >> authoringPrototype [
	"Answer an instance of the receiver suitable for placing in a parts bin for authors"
	
	^ self new markAsPartsDonor
]

{ #category : #'fileIn\/Out' }
Morph class >> fileReaderServicesForFile: fullName suffix: suffix [

	^({ 'morph'. 'morphs'. 'sp'. '*' } includes: suffix)
		ifTrue: [
			{SimpleServiceEntry 
				provider: self 
				label: 'load as morph'
				selector: #fromFileName:
				description: 'load as morph'}]
		ifFalse: [#()]
]

{ #category : #'fileIn\/Out' }
Morph class >> fromFileName: fullName [
	"Reconstitute a Morph from the file, presumed to be represent a Morph saved
	via the SmartRefStream mechanism, and open it in an appropriate Morphic world"

 	| aFileStream morphOrList |
	aFileStream := (MultiByteBinaryOrTextStream with: ((FileStream readOnlyFileNamed: fullName) binary contentsOfEntireFile)) binary reset.
	morphOrList := aFileStream fileInObjectAndCode.
	(morphOrList isKindOf: SqueakPage) ifTrue: [morphOrList := morphOrList contentsMorph].
	Smalltalk isMorphic
		ifTrue: [Project current world addMorphsAndModel: morphOrList]
		ifFalse:
			[morphOrList isMorph ifFalse: [self inform: 'Can only load a single morph
into an mvc project via this mechanism.' translated].
			morphOrList openInWorld]
]

{ #category : #preferences }
Morph class >> haloForAll [

	<preference: 'Offer Halo for All Morphs'
		categoryList: #(Morphic)
		description: 'If enabled, there will be a halo provided for any morph after a certain input gesture is detected, which is usually a BLUE (middle) mouse click.'
		type: #Boolean>
	^ HaloForAll ifNil: [true]
]

{ #category : #preferences }
Morph class >> haloForAll: aBoolean [

	HaloForAll := aBoolean.
]

{ #category : #'new-morph participation' }
Morph class >> includeInNewMorphMenu [
	"Return true for all classes that can be instantiated from the menu"
	^ true
]

{ #category : #preferences }
Morph class >> indicateKeyboardFocus [

	<preference: 'Indicate Keyboard Focus'
		categoryList: #(keyboard Morphic general)
		description: 'If enabled, there will be a visual highlight drawn onto the morph to help the user find out about the current keyboard focus. This is especially useful when the keyboard focus does not match the mouse position.'
		type: #Boolean>
	^ IndicateKeyboardFocus ifNil: [false]
]

{ #category : #preferences }
Morph class >> indicateKeyboardFocus: aBoolean [

	IndicateKeyboardFocus := aBoolean.
]

{ #category : #'class initialization' }
Morph class >> initialize [
	"Morph initialize"
	FileServices registerFileReader: self
]

{ #category : #'instance creation' }
Morph class >> initializedInstance [
	"Answer an instance of the receiver which in some sense is initialized.  In the case of Morphs, this will yield an instance that can be attached to the Hand after having received the same kind of basic initialization that would be obtained from an instance chosen from the 'new morph' menu.
	Return nil if the receiver is reluctant for some reason to return such a thing"

	^ (self class includesSelector: #descriptionForPartsBin)
		ifTrue:
			[self newStandAlone]
		ifFalse:
			[self new]
]

{ #category : #testing }
Morph class >> isSketchMorphClass [
	^false
]

{ #category : #preferences }
Morph class >> metaMenuForAll [

	<preference: 'Offer Meta Menu for All Morphs'
		categoryList: #(Morphic)
		description: 'If enabled, there will be a meta menu provided for any morph after a certain input gesture is detected, which is usually a CTRL+Any mouse click.'
		type: #Boolean>
	^ MetaMenuForAll ifNil: [true]
]

{ #category : #preferences }
Morph class >> metaMenuForAll: aBoolean [

	MetaMenuForAll := aBoolean.
]

{ #category : #misc }
Morph class >> morphsUnknownToTheirOwners [
	"Return a list of all morphs (other than HandMorphs) whose owners do not contain them in their submorph lists"
	"Morph morphsUnknownToTheirOwners"
	| problemMorphs |
	problemMorphs := OrderedCollection new.
	self allSubInstances do:
		[:m | | itsOwner |
		(m isHandMorph not and: [((itsOwner := m owner) ~~ nil and: [(itsOwner submorphs includes: m) not])])
			ifTrue:
				[problemMorphs add: m]].
	^ problemMorphs
]

{ #category : #'instance creation' }
Morph class >> newBounds: bounds [

	^ self new privateBounds: bounds
]

{ #category : #'instance creation' }
Morph class >> newBounds: bounds color: color [

	^ (self new privateBounds: bounds) privateColor: color

]

{ #category : #'new-morph participation' }
Morph class >> newStandAlone [
	"Answer an instance capable of standing by itself as a usable morph."

	^ self basicNew initializeToStandAlone
]

{ #category : #'instance creation' }
Morph class >> newSticky [

	^ self new beSticky
]

{ #category : #'new-morph participation' }
Morph class >> partName: aName categories: aList documentation: aDoc [
	"Answer a DescriptionForPartsBin which will represent a launch of a new instance of my class via the #newStandAlone protocol sent to my class. Use the category-list and documentation provided"


	^ DescriptionForPartsBin new
		formalName: aName
		categoryList: aList
		documentation: aDoc
		globalReceiverSymbol: self name
		nativitySelector: #newStandAlone
]

{ #category : #'new-morph participation' }
Morph class >> partName: aName categories: aList documentation: aDoc sampleImageForm: aForm [
	"Answer a DescriptionForPartsBin which will represent a launch of a new instance of my class via the #newStandAlone protocol sent to my class. Use the category-list and documentation provided.  This variant allows an overriding image form to be provided, useful in cases where we don't want to launch a sample instance just to get the form"

	| descr |
	descr := DescriptionForPartsBin new
		formalName: aName
		categoryList: aList
		documentation: aDoc
		globalReceiverSymbol: self name
		nativitySelector: #newStandAlone.
	descr sampleImageForm: aForm.
	^ descr

]

{ #category : #preferences }
Morph class >> preferredCornerRadius [

	<preference: 'Preferred Corner Radius'
		categoryList: #(Morphic windows menus)
		description: 'If a morph wants rounded corners, use this radius. May be overwritten in subclasses.'
		type: #Number>
	^ PreferredCornerRadius ifNil: [6]
]

{ #category : #preferences }
Morph class >> preferredCornerRadius: anInteger [

	PreferredCornerRadius := anInteger.
]

{ #category : #defaults }
Morph class >> selectionBackground [
	"The background for selected items in lists and tree-list thingies."
	^ self subduedHilites ifTrue: [
			TranslucentColor r: 0.0 g: 0.0 b: 0.8 alpha: 0.2
		] ifFalse: [
			"This is tuned so the red-foreground used for list texts stays somewhat legible."
			Color r: 0.8 g:0.8 b: 0.81 alpha: 0.85 
		].

]

{ #category : #'fileIn\/Out' }
Morph class >> serviceLoadMorphFromFile [
	"Answer a service for loading a .morph file"

	^ SimpleServiceEntry 
		provider: self 
		label: 'load as morph' translatedNoop
		selector: #fromFileName:
		description: 'load as morph' translatedNoop
		buttonLabel: 'load' translatedNoop
]

{ #category : #'fileIn\/Out' }
Morph class >> services [

	^ Array with: self serviceLoadMorphFromFile
]

{ #category : #preferences }
Morph class >> themeProperties [
	
	| catName |
	catName := 'Other'.
	
	^{ 
		{ #hardShadowColor. catName.  'The color of shadows. An alpha about 0.5 is recommended.' }.
		{ #hardShadowOffset. catName. 'The offset of the shadows behind the morph.' } .
		{ #softShadowColor. catName.  'The color of soft shadows. An alpha less than 0.05 is recommended.' }.
		{ #softShadowOffset. catName. 'The offset of soft shadows behind the morph.' } .
		{ #keyboardFocusColor. catName. 'The color of the keyboard focus indication.' }.
		{ #keyboardFocusWidth. catName. 'The width of the keyboard focus indication.' }.
	}
]

{ #category : #'initialize-release' }
Morph class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #preferences }
Morph class >> useSoftDropShadow [

	<preference: 'Use Soft Drop Shadow'
		categoryList: #(Morphic windows menus performance)
		description: 'If drop shadows are enabled, this preference will switch between hard and soft shadows. Soft shadows are more expensive.'
		type: #Boolean>
	^ UseSoftDropShadow ifNil: [ false ]
]

{ #category : #preferences }
Morph class >> useSoftDropShadow: aBoolean [

	UseSoftDropShadow = aBoolean ifTrue: [^ self].
	UseSoftDropShadow := aBoolean.
	
	SystemWindow refreshAllWindows.
	DialogWindow refreshAllDialogs.
	SystemProgressMorph reset.
	TheWorldMainDockingBar updateInstances.
]

{ #category : #'submorphs-add\/remove' }
Morph >> abandon [
	"Like delete, but we really intend not to use this morph again.  Clean up a few things."

	self delete
]

{ #category : #'dropping\/grabbing' }
Morph >> aboutToBeGrabbedBy: aHand [
	"The receiver is being grabbed by a hand.
	Perform necessary adjustments (if any) and return the actual morph
	that should be added to the hand."
	| extentToHandToHand cmd |
	self formerOwner: owner.
	self formerPosition: self position.
	cmd := self undoGrabCommand.
	cmd ifNotNil:[self setProperty: #undoGrabCommand toValue: cmd].
	(extentToHandToHand := self valueOfProperty: #expandedExtent)
			ifNotNil:
				[self removeProperty: #expandedExtent.
				self extent: extentToHandToHand].
	^self "Grab me"
]

{ #category : #menus }
Morph >> absorbStateFromRenderer: aRenderer [ 
	"Transfer knownName, actorState, visible, and player info over from aRenderer, which was formerly imposed above me as a transformation shell but is now going away."

	| current |
	(current := aRenderer actorStateOrNil) ifNotNil:
		[self actorState: current.
		aRenderer actorState: nil].

	(current := aRenderer knownName) ifNotNil:
		[self setNameTo: current.
		aRenderer setNameTo: nil].

	(current := aRenderer player) ifNotNil:
		[self player: current.
		current rawCostume: self.
		aRenderer player: nil].

	self visible: aRenderer visible
]

{ #category : #'dropping\/grabbing' }
Morph >> acceptDroppingMorph: aMorph event: evt [
	"This message is sent when a morph is dropped onto a morph that has agreed to accept the dropped morph by responding 'true' to the wantsDroppedMorph:Event: message. This default implementation just adds the given morph to the receiver."
	| layout |
	layout := self layoutPolicy.
	layout ifNil:[^self addMorph: aMorph].
	self privateAddMorph: aMorph 
		atIndex: (layout indexForInserting: aMorph at: evt position in: self).
]

{ #category : #'submorphs-add\/remove' }
Morph >> actWhen [
	"Answer when the receiver, probably being used as a button, should have its action triggered"

	^ self valueOfProperty: #actWhen ifAbsentPut: [#buttonDown]
]

{ #category : #'submorphs-add\/remove' }
Morph >> actWhen: aButtonPhase [
	"Set the receiver's actWhen trait"

	self setProperty: #actWhen toValue: aButtonPhase
]

{ #category : #'events-accessing' }
Morph >> actionMap [
	"Answer an action map"

	| actionMap |
	actionMap := self valueOfProperty: #actionMap.
	actionMap ifNil:
		[actionMap := self createActionMap].
	^ actionMap
]

{ #category : #structure }
Morph >> activeHand [

	self flag: #deprecated. "mt: Use #currentHand instead."
	^ self currentHand
]

{ #category : #accessing }
Morph >> actorState: anActorState [ 
	"change the receiver's actorState"
	self assureExtension actorState: anActorState
]

{ #category : #accessing }
Morph >> actorStateOrNil [
	"answer the redeiver's actorState"
	^ extension ifNotNil: [extension actorState]
]

{ #category : #'e-toy support' }
Morph >> adaptToWorld: aWorld [
	"The receiver finds itself operating in a possibly-different new world.  If any of the receiver's parts are world-dependent (such as a target of a SimpleButtonMorph, etc.), then have them adapt accordingly"
	submorphs do: [:m | m adaptToWorld: aWorld].
	self eventHandler ifNotNil:
		[self eventHandler adaptToWorld: aWorld]
]

{ #category : #menus }
Morph >> addAddHandMenuItemsForHalo: aMenu hand: aHandMorph [
	"The former charter of this method was to add halo menu items that pertained specifically to the hand.  Over time this charter has withered, and most morphs reimplement this method simply to add their morph-specific menu items.  So in the latest round, all other implementors in the standard image have been removed.  However, this is left here as a hook for the benefit of existing code in client uses."


]

{ #category : #'events-alarms' }
Morph >> addAlarm: aSelector after: delayTime [
	"Add an alarm (that is an action to be executed once) with the given set of parameters"
	^self addAlarm: aSelector withArguments: #() after: delayTime
]

{ #category : #'events-alarms' }
Morph >> addAlarm: aSelector at: scheduledTime [
	"Add an alarm (that is an action to be executed once) with the given set of parameters"
	^self addAlarm: aSelector withArguments: #() at: scheduledTime
]

{ #category : #'events-alarms' }
Morph >> addAlarm: aSelector with: arg1 after: delayTime [
	"Add an alarm (that is an action to be executed once) with the given set of parameters"
	^self addAlarm: aSelector withArguments: (Array with: arg1) after: delayTime
]

{ #category : #'events-alarms' }
Morph >> addAlarm: aSelector with: arg1 at: scheduledTime [
	"Add an alarm (that is an action to be executed once) with the given set of parameters"
	^self addAlarm: aSelector withArguments: (Array with: arg1) at: scheduledTime
]

{ #category : #'events-alarms' }
Morph >> addAlarm: aSelector with: arg1 with: arg2 after: delayTime [
	"Add an alarm (that is an action to be executed once) with the given set of parameters"
	^self addAlarm: aSelector withArguments: (Array with: arg1 with: arg2) after: delayTime
]

{ #category : #'events-alarms' }
Morph >> addAlarm: aSelector with: arg1 with: arg2 at: scheduledTime [
	"Add an alarm (that is an action to be executed once) with the given set of parameters"
	^self addAlarm: aSelector withArguments: (Array with: arg1 with: arg2) at: scheduledTime
]

{ #category : #'events-alarms' }
Morph >> addAlarm: aSelector withArguments: args after: delayTime [
	"Add an alarm (that is an action to be executed once) with the given set of parameters"
	^self addAlarm: aSelector withArguments: args at: Time millisecondClockValue + delayTime
]

{ #category : #'events-alarms' }
Morph >> addAlarm: aSelector withArguments: args at: scheduledTime [
	"Add an alarm (that is an action to be executed once) with the given set of parameters"
	| scheduler |
	scheduler := self alarmScheduler.
	scheduler ifNotNil:[scheduler addAlarm: aSelector withArguments: args for: self at: scheduledTime].
]

{ #category : #'submorphs-add\/remove' }
Morph >> addAllMorphs: aCollection [
	^self addAllMorphsBack: aCollection
]

{ #category : #'submorphs-add\/remove' }
Morph >> addAllMorphs: aCollection after: anotherMorph [
	^self addAllMorphs: aCollection behind: anotherMorph
]

{ #category : #'submorphs-add\/remove' }
Morph >> addAllMorphs: aCollection behind: anotherMorph [
	^self privateAddAllMorphs: aCollection 
			atIndex: (submorphs indexOf: anotherMorph) + 1
]

{ #category : #'submorphs-add\/remove' }
Morph >> addAllMorphs: aCollection inFrontOf: anotherMorph [
	^self privateAddAllMorphs: aCollection
			atIndex: ((submorphs indexOf: anotherMorph) max: 1)
]

{ #category : #'submorphs-add\/remove' }
Morph >> addAllMorphsBack: aCollection [
	^self privateAddAllMorphs: aCollection atIndex: submorphs size + 1
]

{ #category : #'submorphs-add\/remove' }
Morph >> addAllMorphsFront: aCollection [
	^self privateAddAllMorphs: aCollection atIndex: 1
]

{ #category : #menu }
Morph >> addBorderStyleMenuItems: aMenu hand: aHandMorph [
	"Probably one could offer border-style items even if it's not a borderedMorph, so this remains a loose end for the moment"

]

{ #category : #'layout-menu' }
Morph >> addCellLayoutMenuItems: aMenu hand: aHand [
	"Cell (e.g., child) related items"
	| menu sub |
	menu := MenuMorph new defaultTarget: self.
		menu addUpdating: #hasDisableTableLayoutString action: #changeDisableTableLayout.
		menu addLine.

		sub := MenuMorph new defaultTarget: self.
		#(rigid shrinkWrap spaceFill) do:[:sym|
			sub addUpdating: #hResizingString: target: self selector: #hResizing: argumentList: (Array with: sym)].
		menu add:'horizontal resizing' translated subMenu: sub.

		sub := MenuMorph new defaultTarget: self.
		#(rigid shrinkWrap spaceFill) do:[:sym|
			sub addUpdating: #vResizingString: target: self selector: #vResizing: argumentList: (Array with: sym)].
		menu add:'vertical resizing' translated subMenu: sub.

	aMenu ifNotNil:[aMenu add: 'child layout' translated subMenu: menu].
	^menu
]

{ #category : #menus }
Morph >> addCopyItemsTo: aMenu [
	"Add copy-like items to the halo menu"

	| subMenu |
	subMenu := MenuMorph new defaultTarget: self.
	subMenu add: 'copy to paste buffer' translated action: #copyToPasteBuffer:.
	subMenu add: 'copy text' translated action: #clipText.
	subMenu add: 'copy Postscript' translated action: #clipPostscript.
	subMenu add: 'print Postscript to file...' translated target: self selector: #printPSToFile.
	aMenu add: 'copy & print...' translated subMenu: subMenu
]

{ #category : #menus }
Morph >> addCustomHaloMenuItems: aMenu hand: aHandMorph [
	"Add morph-specific items to the given menu which was invoked by the given hand from the halo.  To get started, we defer to the counterpart method used with the option-menu, but in time we can have separate menu choices for halo-menus and for option-menus"

	self addCustomMenuItems: aMenu hand: aHandMorph
]

{ #category : #menus }
Morph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add morph-specific items to the given menu which was invoked by the given hand.  This method provides is invoked both from the halo-menu and from the control-menu regimes."

]

{ #category : #'debug and other' }
Morph >> addDebuggingItemsTo: aMenu hand: aHandMorph [
	aMenu add: 'debug...' translated subMenu:  (self buildDebugMenu: aHandMorph)
]

{ #category : #'drop shadows' }
Morph >> addDropShadow [

	self
		hasDropShadow: true;
		shadowOffset: (self useSoftDropShadow
			ifTrue: [self userInterfaceTheme softShadowOffset ifNil: [10@8 corner: 10@12]]
			ifFalse: [self userInterfaceTheme hardShadowOffset ifNil: [1@1]]);
		shadowColor: (self useSoftDropShadow
			ifTrue: [self userInterfaceTheme softShadowColor ifNil: [Color black alpha: 0.01]]
			ifFalse: [self userInterfaceTheme hardShadowColor ifNil: [Color black alpha: 0.5]]).
]

{ #category : #'drop shadows' }
Morph >> addDropShadowMenuItems: aMenu hand: aHand [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu
		addUpdating: #hasDropShadowString
		action: #toggleDropShadow.
	menu addLine.
	menu add: 'shadow color...' translated target: self selector: #changeShadowColor.
	menu add: 'shadow offset...' translated target: self selector: #setShadowOffset:.
	aMenu add: 'drop shadow' translated subMenu: menu.
]

{ #category : #'meta-actions' }
Morph >> addEmbeddingMenuItemsTo: aMenu hand: aHandMorph [
	"Construct a menu offerring embed targets for the receiver.  If the incoming menu is is not degenerate, add the constructed menu as a submenu; in any case, answer the embed-target menu"

	| menu w |
	menu := MenuMorph new defaultTarget: self.
	w := self world.
	self potentialEmbeddingTargets reverseDo: [:m |
		menu add: (m == w ifTrue: ['desktop' translated] ifFalse: [m knownName ifNil:[m class name asString]]) target: m selector: #addMorphFrontFromWorldPosition: argumentList: {self topRendererOrSelf}.
		m == self topRendererOrSelf owner ifTrue:
			[menu lastItem color: Color red]].
	aMenu ifNotNil:
		[menu submorphCount > 0 
			ifTrue:[aMenu add:'embed into' translated subMenu: menu]].
	^ menu
]

{ #category : #'events-filtering-bubbling' }
Morph >> addEventBubbleFilter: anObject [
	self eventBubbleFilters: (self addFilter: anObject to: self eventBubbleFilters).
]

{ #category : #'events-filtering-capturing' }
Morph >> addEventCaptureFilter: anObject [
	self eventCaptureFilters: (self addFilter: anObject to: self eventCaptureFilters).
]

{ #category : #menus }
Morph >> addExportMenuItems: aMenu hand: aHandMorph [
	"Add export items to the menu"

	aMenu ifNotNil:
		[ | aSubMenu |
		aSubMenu := MenuMorph new defaultTarget: self.
		aSubMenu add: 'BMP file' translated action: #exportAsBMP.
		aSubMenu add: 'GIF file' translated action: #exportAsGIF.
		aSubMenu add: 'JPEG file' translated action: #exportAsJPEG.
		aSubMenu add: 'PNG file' translated action: #exportAsPNG.
		(self respondsTo: #exportAsEPS) ifTrue: [
			aSubMenu add: 'EPS file' translated action: #exportAsEPS].
		aMenu add: 'export...' translated subMenu: aSubMenu]

]

{ #category : #menus }
Morph >> addFillStyleMenuItems: aMenu hand: aHand [
	"Add the items for changing the current fill style of the Morph"
	| menu |
	self canHaveFillStyles ifFalse:[^aMenu add: 'change color...' translated target: self action: #changeColor].
	menu := MenuMorph new defaultTarget: self.
	self fillStyle addFillStyleMenuItems: menu hand: aHand from: self.
	menu addLine.
	menu add: 'solid fill' translated action: #useSolidFill.
	menu add: 'gradient fill' translated action: #useGradientFill.
	menu add: 'bitmap fill' translated action: #useBitmapFill.
	menu add: 'default fill' translated action: #useDefaultFill.
	aMenu add: 'fill style' translated subMenu: menu.
	"aMenu add: 'change color...' translated action: #changeColor"
]

{ #category : #'events-filtering' }
Morph >> addFilter: anObject to: aFilterGroup [
	"Add anObject to the given listener group. Return the new group."
	| filters |
	filters := aFilterGroup.
	(filters notNil and:[filters includes: anObject]) ifFalse:[
		filters
			ifNil:[filters := WeakArray with: anObject]
			ifNotNil:[filters := filters copyWith: anObject]].
	filters := filters copyWithout: nil. "obsolete entries"
	^filters
]

{ #category : #'rotate scale and flex' }
Morph >> addFlexShell [
	"Wrap a rotating and scaling shell around this morph."

	| oldHalo myWorld flexMorph anIndex |
	oldHalo:= self halo.
	myWorld := self world.
	self owner
		ifNil: [flexMorph := self newTransformationMorph asFlexOf: self]
		ifNotNil: [:myOwner |
			anIndex := myOwner submorphIndexOf: self.
			"Avoid triggering outOfWorld: on self by first adding flexMorph to myOwner and only then making myself a submorph of flexMorph via asFlexOf:"
			flexMorph := self newTransformationMorph.
			myOwner addMorph: flexMorph asElementNumber: anIndex.
			flexMorph asFlexOf: self.
			myWorld ifNotNil: [myWorld startSteppingSubmorphsOf: flexMorph]].
	self transferStateToRenderer: flexMorph.
	oldHalo ifNotNil: [oldHalo setTarget: flexMorph].

	^ flexMorph
]

{ #category : #'rotate scale and flex' }
Morph >> addFlexShellIfNecessary [
	"If this morph requires a flex shell to scale or rotate,
		then wrap it in one and return it.
	Polygons, eg, may override to return themselves."

	^ self addFlexShell
]

{ #category : #menu }
Morph >> addGestureMenuItems: aMenu hand: aHandMorph [
	"If the receiver wishes the Genie menu items, add a line to the menu and then those Genie items, else do nothing"
]

{ #category : #menu }
Morph >> addGraphModelYellowButtonItemsTo: aCustomMenu event: evt [
	^aCustomMenu
]

{ #category : #'halos and balloon help' }
Morph >> addHalo [
	"Invoke a halo programatically (e.g., not from a meta gesture)"
	
	^ self createHalo
		popUpFor: self;
		yourself
]

{ #category : #'halos and balloon help' }
Morph >> addHalo: evt [
	
	^ self createHalo
		popUpFor: self event: evt;
		yourself
]

{ #category : #'halos and balloon help' }
Morph >> addHalo: evt from: formerHaloOwner [
	"Transfer a halo from the former halo owner to the receiver"
	^self addHalo: evt
]

{ #category : #menus }
Morph >> addHaloActionsTo: aMenu [
	"Add items to aMenu representing actions requestable via halo"

	| subMenu |
	subMenu := MenuMorph new defaultTarget: self.
	subMenu addTitle: self externalName.
	subMenu addStayUpItemSpecial.
	subMenu addLine.
	subMenu add: 'delete' translated action: #dismissViaHalo.
	subMenu balloonTextForLastItem: 'Delete this object -- warning -- can be destructive!' translated.

	self maybeAddCollapseItemTo: subMenu.
	subMenu add: 'grab' translated action: #openInHand.
	subMenu balloonTextForLastItem: 'Pick this object up -- warning, since this removes it from its container, it can have adverse effects.' translated.

	subMenu addLine.

	subMenu add: 'resize' translated action: #resizeFromMenu.
	subMenu balloonTextForLastItem: 'Change the size of this object' translated.

	subMenu add: 'duplicate' translated action: #maybeDuplicateMorph.
	subMenu balloonTextForLastItem: 'Hand me a copy of this object' translated.
	"Note that this allows access to the non-instancing duplicate even when this is a uniclass instance"

	self couldMakeSibling ifTrue:
		[subMenu add: 'make a sibling' translated action: #handUserASibling.
		subMenu balloonTextForLastItem: 'Make a new sibling of this object and hand it to me' translated].

	subMenu addLine.
	subMenu add: 'property sheet' translated target: self renderedMorph action: #openAPropertySheet.
	subMenu balloonTextForLastItem: 'Open a property sheet for me. Allows changing lots of stuff at once.' translated.

	subMenu add: 'set color' translated target: self renderedMorph action: #changeColor.
	subMenu balloonTextForLastItem: 'Change the color of this object' translated.

	subMenu add: 'viewer' translated target: self action: #beViewed.
	subMenu balloonTextForLastItem: 'Open a Viewer that will allow everything about this object to be seen and controlled.' translated.

	subMenu add: 'tile browser' translated target: self action: #openInstanceBrowserWithTiles.
	subMenu balloonTextForLastItem: 'Open a tool that will facilitate tile scripting of this object.' translated.

	subMenu add: 'tile representing this object' translated target: self action: #tearOffTile.
	subMenu balloonTextForLastItem: 'Hand me a tile represting this object' translated.
	subMenu addLine.

	subMenu add: 'inspect' translated target: self action: #inspect.
	subMenu balloonTextForLastItem: 'Open an Inspector on this object' translated.

	aMenu add: 'halo actions...' translated subMenu: subMenu

]

{ #category : #'halos and balloon help' }
Morph >> addHandlesTo: aHaloMorph box: box [
	"Add halo handles to the halo.  Apply the halo filter if appropriate"

	
	aHaloMorph haloBox: box.
	Preferences haloSpecifications  do:
		[:aSpec | | wantsIt aSelector | 
			aSelector :=  aSpec addHandleSelector.
			wantsIt := Preferences selectiveHalos
				ifTrue:
					[self wantsHaloHandleWithSelector: aSelector inHalo: aHaloMorph]
				ifFalse:
					[true].
			wantsIt ifTrue:
				[(#(addMakeSiblingHandle: addDupHandle:) includes: aSelector) ifTrue:
					[wantsIt := self preferredDuplicationHandleSelector = aSelector].
			wantsIt ifTrue:
				[aHaloMorph perform: aSelector with: aSpec]]].

	aHaloMorph innerTarget addOptionalHandlesTo: aHaloMorph box: box
]

{ #category : #'events-filtering-bubbling' }
Morph >> addKeyboardBubbleFilter: anObject [
	self keyboardBubbleFilters: (self addFilter: anObject to: self keyboardBubbleFilters).
]

{ #category : #'events-filtering-capturing' }
Morph >> addKeyboardCaptureFilter: anObject [
	self keyboardCaptureFilters: (self addFilter: anObject to: self keyboardCaptureFilters).
]

{ #category : #'layout-menu' }
Morph >> addLayoutMenuItems: topMenu hand: aHand [
	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addUpdating: #hasNoLayoutString action: #changeNoLayout.
	aMenu addUpdating: #hasProportionalLayoutString action: #changeProportionalLayout.
	aMenu addUpdating: #hasTableLayoutString action: #changeTableLayout.
	aMenu addLine.
	aMenu add: 'change layout inset...' translated action: #changeLayoutInset:.
	aMenu addLine.
	self addCellLayoutMenuItems: aMenu hand: aHand.
	self addTableLayoutMenuItems: aMenu hand: aHand.
	aMenu addLine.
	aMenu add: 'copy layout properties' translated action: #copyLayoutProperties.
	topMenu ifNotNil:[topMenu add: 'layout' translated subMenu: aMenu].
	^aMenu
]

{ #category : #'halos and balloon help' }
Morph >> addMagicHaloFor: aHand [

	aHand halo ifNotNil: [:halo |
		halo target == self ifTrue:[^self].
		halo isMagicHalo ifFalse:[^self]].
	
	self createHalo
		popUpMagicallyFor: self hand: aHand
]

{ #category : #menus }
Morph >> addMiscExtrasTo: aMenu [
	"Add a submenu of miscellaneous extra items to the menu."

	| realOwner realMorph subMenu |
	subMenu := MenuMorph new defaultTarget: self.
	(self isWorldMorph not and: [(self renderedMorph isSystemWindow) not])
		ifTrue: [subMenu add: 'put in a window' translated action: #embedInWindow].
	
	self isWorldMorph ifFalse:
		[subMenu add: 'adhere to edge...' translated action: #adhereToEdge.
		subMenu addLine].
	
	realOwner := (realMorph := self topRendererOrSelf) owner.
	(realOwner isKindOf: TextPlusPasteUpMorph) ifTrue:
		[subMenu add: 'GeeMail stuff...' translated subMenu: (realOwner textPlusMenuFor: realMorph)].
	
	subMenu
		add: 'add mouse up action' translated action: #addMouseUpAction;
		add: 'remove mouse up action' translated action: #removeMouseUpAction;
		add: 'hand me tiles to fire this button' translated action: #handMeTilesToFire.
	subMenu addLine.
	subMenu add: 'arrowheads on pen trails...' translated action: #setArrowheads.
	subMenu addLine.
	
	subMenu defaultTarget: self topRendererOrSelf.
	subMenu add: 'draw new path' translated action: #definePath.
	subMenu add: 'follow existing path' translated action: #followPath.
	subMenu add: 'delete existing path' translated action: #deletePath.
	subMenu addLine.
	
	self addGestureMenuItems: subMenu hand: self currentHand.
	
	aMenu add: 'extras...' translated subMenu: subMenu
]

{ #category : #menu }
Morph >> addModelYellowButtonItemsTo: aCustomMenu event: evt [ 
	"Give my models a chance to add their context-menu items to  
	aCustomMenu."
	self model
		ifNotNil: [:mod |
			mod
				addModelYellowButtonMenuItemsTo: aCustomMenu
				forMorph: self
				hand: evt hand]
]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorph: aMorph [

	self addMorphFront: aMorph.
]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorph: newMorph after: aMorph [
	^self addMorph: newMorph behind: aMorph
]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorph: aMorph asElementNumber: aNumber [
	"Add the given morph so that it becomes the aNumber'th element of my submorph list.  If aMorph is already one of my submorphs, reposition it"

	(submorphs includes: aMorph) ifTrue:
		[aMorph privateDelete].
	(aNumber <= submorphs size)
		ifTrue:
			[self addMorph: aMorph inFrontOf: (submorphs at: aNumber)]
		ifFalse:
			[self addMorphBack: aMorph]

]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorph: newMorph behind: aMorph [
	"Add a morph to the list of submorphs behind the specified morph"
	^self privateAddMorph: newMorph atIndex: (submorphs indexOf: aMorph) + 1.

]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorph: aMorph fullFrame: aLayoutFrame [

	aMorph layoutFrame: aLayoutFrame.
	aMorph hResizing: #spaceFill; vResizing: #spaceFill.
	self addMorph: aMorph.


]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorph: newMorph inFrontOf: aMorph [
	"Add a morph to the list of submorphs in front of the specified morph"
	^self privateAddMorph: newMorph atIndex: ((submorphs indexOf: aMorph) max: 1).
]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorphBack: aMorph [
	^self privateAddMorph: aMorph atIndex: submorphs size+1
]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorphCentered: aMorph [

	aMorph position: bounds center - (aMorph extent // 2).
	self addMorphFront: aMorph.

]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorphFront: aMorph [
	^self privateAddMorph: aMorph atIndex: 1
]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorphFront: aMorph fromWorldPosition: wp [

	self addMorphFront: aMorph.
	aMorph position: (self transformFromWorld globalPointToLocal: wp)
]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorphFrontFromWorldPosition: aMorph [
	^self addMorphFront: aMorph fromWorldPosition: aMorph positionInWorld.
]

{ #category : #'WiW support' }
Morph >> addMorphInFrontOfLayer: aMorph [

	| targetLayer |

	targetLayer := aMorph morphicLayerNumberWithin: self.
	submorphs do: [ :each | | layerHere |
		each == aMorph ifTrue: [^self].
		layerHere := each morphicLayerNumberWithin: self.
		"the <= is the difference - it insures we go to the front of our layer"
		targetLayer <= layerHere ifTrue: [
			^self addMorph: aMorph inFrontOf: each
		].
	].
	self addMorphBack: aMorph.

]

{ #category : #'WiW support' }
Morph >> addMorphInLayer: aMorph [

	submorphs do: [ :each |
		each == aMorph ifTrue: [^self].
		aMorph morphicLayerNumber < each morphicLayerNumber ifTrue: [
			^self addMorph: aMorph inFrontOf: each
		].
	].
	self addMorphBack: aMorph

]

{ #category : #'submorphs-add\/remove' }
Morph >> addMorphNearBack: aMorph [ 
	| bg |
	(submorphs notEmpty and: [submorphs last mustBeBackmost]) 
		ifTrue: 
			[bg := submorphs last.
			bg privateDelete].
	self addMorphBack: aMorph.
	bg ifNotNil: [self addMorphBack: bg]
]

{ #category : #'debug and other' }
Morph >> addMouseActionIndicatorsWidth: anInteger color: aColor [

	self deleteAnyMouseActionIndicators.

	self changed.
	self hasRolloverBorder: true.
	self setProperty: #rolloverWidth toValue: anInteger@anInteger.
	self setProperty: #rolloverColor toValue: aColor.
	self layoutChanged.
	self changed.


]

{ #category : #'events-filtering-bubbling' }
Morph >> addMouseBubbleFilter: anObject [
	self mouseBubbleFilters: (self addFilter: anObject to: self mouseBubbleFilters).
]

{ #category : #'events-filtering-capturing' }
Morph >> addMouseCaptureFilter: anObject [
	self mouseCaptureFilters: (self addFilter: anObject to: self mouseCaptureFilters).
]

{ #category : #'debug and other' }
Morph >> addMouseUpAction [
	| codeToRun oldCode |
	oldCode := self
				valueOfProperty: #mouseUpCodeToRun
				ifAbsent: [''].
	codeToRun := UIManager default request: 'MouseUp expression:' translated initialAnswer: oldCode.
	self addMouseUpActionWith: codeToRun
]

{ #category : #'debug and other' }
Morph >> addMouseUpActionWith: codeToRun [ 
	((codeToRun isMessageSend) not and: [codeToRun isEmptyOrNil]) 
		ifTrue: [^self].
	self setProperty: #mouseUpCodeToRun toValue: codeToRun.
	self 
		on: #mouseUp
		send: #programmedMouseUp:for:
		to: self.
	self 
		on: #mouseDown
		send: #programmedMouseDown:for:
		to: self.
	self 
		on: #mouseEnter
		send: #programmedMouseEnter:for:
		to: self.
	self 
		on: #mouseLeave
		send: #programmedMouseLeave:for:
		to: self
]

{ #category : #menu }
Morph >> addMyYellowButtonMenuItemsToSubmorphMenus [
	"Answer true if I have items to add to the context menus of my submorphs"

	^true
]

{ #category : #menu }
Morph >> addNestedYellowButtonItemsTo: aMenu event: evt [ 
	"Add items to aMenu starting with me and proceeding down 
	through my submorph chain, 
	letting any submorphs that include the event position 
	contribute their items to the bottom of the menu, separated by 
	a line."
	| underMouse |

	self addYellowButtonMenuItemsTo: aMenu event: evt.

	underMouse := self
				submorphThat: [:each | each containsPoint: evt position]
				ifNone: [^ self].

	(underMouse addMyYellowButtonMenuItemsToSubmorphMenus
			and: [underMouse hasYellowButtonMenu])
		ifTrue: [| submenu |
			aMenu addLine.
			submenu := MenuMorph new defaultTarget: underMouse.
			underMouse addNestedYellowButtonItemsTo: submenu event: evt.
			aMenu
				add: underMouse externalName
				icon: (underMouse iconOrThumbnailOfSize: 16)
				subMenu: submenu
		]

]

{ #category : #'halos and balloon help' }
Morph >> addOptionalHandlesTo: aHalo box: box [
	aHalo addDirectionHandles
]

{ #category : #menus }
Morph >> addPaintingItemsTo: aMenu hand: aHandMorph [ 
	| subMenu movies |
	subMenu := MenuMorph new defaultTarget: self.
	subMenu
		add: 'repaint' translated action: #editDrawing;
		add: 'set rotation center' translated action: #setRotationCenter;
		add: 'reset forward-direction' translated action: #resetForwardDirection;
		add: 'set rotation style' translated action: #setRotationStyle;
		add: 'erase pixels of color' translated action: #erasePixelsUsing:;
		add: 'recolor pixels of color' translated action: #recolorPixelsUsing:;
		add: 'reduce color palette' translated action: #reduceColorPalette:;
		add: 'detect edges' translated action: #edgeDetect;
		add: 'sharpen' translated action: #sharpen;
		add: 'blur' translated action: #blur;
		add: 'emboss' translated action: #emboss;
		add: 'add a border around this shape...' translated action: #addBorderToShape:.
	movies := (self world rootMorphsAt: aHandMorph targetPoint) 
				select: [:m | (m isKindOf: MovieMorph) or: [m isSketchMorph]].
	movies size > 1 
		ifTrue: 
			[subMenu add: 'insert into movie' translated action: #insertIntoMovie:].
	aMenu add: 'painting...' translated subMenu: subMenu
]

{ #category : #'halos and balloon help' }
Morph >> addSimpleHandlesTo: aHaloMorph box: aBox [
	^ aHaloMorph addSimpleHandlesTo: aHaloMorph box: aBox
]

{ #category : #menus }
Morph >> addStandardHaloMenuItemsTo: aMenu hand: aHandMorph [
	"Add standard halo items to the menu"

	| unlockables etoysLoaded |

	self isWorldMorph ifTrue:
		[^ self addWorldHaloMenuItemsTo: aMenu hand: aHandMorph].

	self mustBeBackmost ifFalse:
		[aMenu add: 'send to back' translated action: #goBehind.
		aMenu add: 'bring to front' translated action: #comeToFront.
		self addEmbeddingMenuItemsTo: aMenu hand: aHandMorph.
		aMenu addLine].

	self addFillStyleMenuItems: aMenu hand: aHandMorph.
	self addBorderStyleMenuItems: aMenu hand: aHandMorph.
	self addDropShadowMenuItems: aMenu hand: aHandMorph.
	self addLayoutMenuItems: aMenu hand: aHandMorph.
	self addHaloActionsTo: aMenu.
	owner isTextMorph ifTrue:[self addTextAnchorMenuItems: aMenu hand: aHandMorph].
	aMenu addLine.
	self addToggleItemsToHaloMenu: aMenu.
	aMenu addLine.
	self addCopyItemsTo: aMenu.
	etoysLoaded := Morph includesSelector: #addPlayerItemsTo:.
	etoysLoaded ifTrue: [self addPlayerItemsTo: aMenu].
	self addExportMenuItems: aMenu hand: aHandMorph.
	etoysLoaded ifTrue: [self addStackItemsTo: aMenu].
	self addMiscExtrasTo: aMenu.
	Preferences noviceMode ifFalse:
		[self addDebuggingItemsTo: aMenu hand: aHandMorph].

	aMenu addLine.
	aMenu defaultTarget: self.

	aMenu addLine.

	unlockables := self submorphs select:
		[:m | m isLocked].
	unlockables size = 1 ifTrue:
		[aMenu
			add: ('unlock "{1}"' translated format: unlockables first externalName)
			action: #unlockContents].
	unlockables size > 1 ifTrue:
		[aMenu add: 'unlock all contents' translated action: #unlockContents.
		aMenu add: 'unlock...' translated action: #unlockOneSubpart].

	aMenu defaultTarget: aHandMorph.

]

{ #category : #'layout-menu' }
Morph >> addTableLayoutMenuItems: aMenu hand: aHand [
	| menu sub |
	menu := MenuMorph new defaultTarget: self.
	menu addUpdating: #hasReverseCellsString action: #changeReverseCells.
	menu addUpdating: #hasClipLayoutCellsString action: #changeClipLayoutCells.
	menu addUpdating: #hasRubberBandCellsString action: #changeRubberBandCells.
	menu addLine.
	menu add: 'change cell gap...' translated action: #changeCellGap:.
	menu add: 'change cell inset...' translated action: #changeCellInset:.
	menu add: 'change min cell size...' translated action: #changeMinCellSize:.
	menu add: 'change max cell size...' translated action: #changeMaxCellSize:.
	menu addLine.

	sub := MenuMorph new defaultTarget: self.
	#(leftToRight rightToLeft topToBottom bottomToTop) do:[:sym|
		sub addUpdating: #listDirectionString: target: self selector: #changeListDirection: argumentList: (Array with: sym)].
	menu add: 'list direction' translated subMenu: sub.

	sub := MenuMorph new defaultTarget: self.
	#(none leftToRight rightToLeft topToBottom bottomToTop) do:[:sym|
		sub addUpdating: #wrapDirectionString: target: self selector: #wrapDirection: argumentList: (Array with: sym)].
	menu add: 'wrap direction' translated subMenu: sub.

	sub := MenuMorph new defaultTarget: self.
	#(center topLeft topRight bottomLeft bottomRight topCenter leftCenter rightCenter bottomCenter) do:[:sym|
		sub addUpdating: #cellPositioningString: target: self selector: #cellPositioning: argumentList: (Array with: sym)].
	menu add: 'cell positioning' translated subMenu: sub.

	sub := MenuMorph new defaultTarget: self.
	#(topLeft bottomRight center justified) do:[:sym|
		sub addUpdating: #listCenteringString: target: self selector: #listCentering: argumentList: (Array with: sym)].
	menu add: 'list centering' translated subMenu: sub.

	sub := MenuMorph new defaultTarget: self.
	#(topLeft bottomRight center justified) do:[:sym|
		sub addUpdating: #wrapCenteringString: target: self selector: #wrapCentering: argumentList: (Array with: sym)].
	menu add: 'wrap centering' translated subMenu: sub.

	sub := MenuMorph new defaultTarget: self.
	#(none equal) do:[:sym|
		sub addUpdating: #listSpacingString: target: self selector: #listSpacing: argumentList: (Array with: sym)].
	menu add: 'list spacing' translated subMenu: sub.

	sub := MenuMorph new defaultTarget: self.
	#(none localRect localSquare globalRect globalSquare) do:[:sym|
		sub addUpdating: #cellSpacingString: target: self selector: #cellSpacing: argumentList: (Array with: sym)].
	menu add: 'cell spacing' translated subMenu: sub.

	aMenu ifNotNil:[aMenu add: 'table layout' translated subMenu: menu].
	^menu
]

{ #category : #'text-anchor' }
Morph >> addTextAnchorMenuItems: topMenu hand: aHand [

	^ self textAnchorProperties 
		addTextAnchorMenuItems: topMenu 
		hand: aHand
		for: self
]

{ #category : #menu }
Morph >> addTitleForHaloMenu: aMenu [ 
	aMenu
		addTitle: self externalName
		icon: (self iconOrThumbnailOfSize: (Preferences tinyDisplay ifFalse:[28] ifTrue:[16]))
]

{ #category : #menus }
Morph >> addToggleItemsToHaloMenu: aMenu [
	"Add standard true/false-checkbox items to the memu"

	#(
		(resistsRemovalString toggleResistsRemoval 'whether I should be reistant to easy deletion via the pink X handle' true)
		(stickinessString toggleStickiness 'whether I should be resistant to a drag done by mousing down on me' true)
		(lockedString lockUnlockMorph 'when "locked", I am inert to all user interactions' true)
		(hasClipSubmorphsString changeClipSubmorphs 'whether the parts of objects within me that are outside my bounds should be masked.' false)
		(hasDirectionHandlesString changeDirectionHandles 'whether direction handles are shown with the halo' false)
		(hasDragEnabledString changeDrag 'whether I am open to having objects dragged out of me' false)
		(hasDropEnabledString changeDrop 'whether I am open to having objects dropped into me' false)
	)
		select:[:each | Preferences noviceMode not or:[each fourth]]
		thenDo:
		[:each |
			aMenu addUpdating: each first action: each second.
			aMenu balloonTextForLastItem: each third translated].

	self couldHaveRoundedCorners ifTrue:
		[aMenu addUpdating: #roundedCornersString action: #toggleCornerRounding.
		aMenu balloonTextForLastItem: 'whether my corners should be rounded' translated]
]

{ #category : #'debug and other' }
Morph >> addViewingItemsTo: aMenu [
	"Add viewing-related items to the given menu.  If any are added, this method is also responsible for adding a line after them"
]

{ #category : #'halos and balloon help' }
Morph >> addWorldHandlesTo: aHaloMorph box: box [
	aHaloMorph haloBox: box.
	Preferences haloSpecificationsForWorld do:
		[:aSpec | 
			aHaloMorph perform: aSpec addHandleSelector with: aSpec].
	aHaloMorph innerTarget addOptionalHandlesTo: aHaloMorph box: box
]

{ #category : #menus }
Morph >> addWorldTargetSightingItems: aCustomMenu hand: aHandMorph [
"Use cursor to select a point on screen.
Set target from all possible morphs under cursor sight." 
	
	aCustomMenu addLine.
	
	aCustomMenu add: 'sight target' translated action: #sightWorldTargets:.
	
]

{ #category : #menu }
Morph >> addYellowButtonMenuItemsTo: aMenu event: evt [ 
	"Populate aMenu with appropriate menu items for a  
	yellow-button (context menu) click."
	aMenu defaultTarget: self.
	""
	Preferences noviceMode
		ifFalse: [aMenu addStayUpItem].
	""
	self addModelYellowButtonItemsTo: aMenu event: evt.
	""
	Preferences generalizedYellowButtonMenu
		ifFalse: [^ self].
	""
	aMenu addLine.
	aMenu add: 'inspect' translated action: #inspect.
	""
	aMenu addLine.
	self world selectedObject == self
		ifTrue: [aMenu add: 'deselect' translated action: #removeHalo]
		ifFalse: [aMenu add: 'select' translated action: #addHalo].
	""
	(self isWorldMorph
			or: [self mustBeBackmost
			or: [self wantsToBeTopmost]])
		ifFalse: [""
			aMenu addLine.
			aMenu add: 'send to back' translated action: #goBehind.
			aMenu add: 'bring to front' translated action: #comeToFront.
			self addEmbeddingMenuItemsTo: aMenu hand: evt hand].
	""
	self isWorldMorph
		ifFalse: [""
	Smalltalk
		at: #NCAAConnectorMorph
		ifPresent: [:connectorClass | 
			aMenu addLine.
			aMenu add: 'connect to' translated action: #startWiring.
			aMenu addLine].
	""

			self isFullOnScreen
				ifFalse: [aMenu add: 'move onscreen' translated action: #goHome]].
	""
	Preferences noviceMode
		ifFalse: [""
			self addLayoutMenuItems: aMenu hand: evt hand.
			(owner notNil
					and: [owner isTextMorph])
				ifTrue: [self addTextAnchorMenuItems: aMenu hand: evt hand]].
	""
	self isWorldMorph
		ifFalse: [""
			aMenu addLine.
			self addToggleItemsToHaloMenu: aMenu].
	""
	aMenu addLine.
	self isWorldMorph
		ifFalse: [aMenu add: 'copy to paste buffer' translated action: #copyToPasteBuffer:].
	(self allStringsAfter: nil) isEmpty
		ifFalse: [aMenu add: 'copy text' translated action: #clipText].
	""
	self addExportMenuItems: aMenu hand: evt hand.
	""
	(Preferences noviceMode not
			and: [self isWorldMorph not])
		ifTrue: [""
			aMenu addLine.
			aMenu add: 'adhere to edge...' translated action: #adhereToEdge].
	""
	self addCustomMenuItems: aMenu hand: evt hand
]

{ #category : #'change reporting' }
Morph >> addedMorph: aMorph [
	"Notify the receiver that the given morph was just added."

]

{ #category : #menus }
Morph >> adhereToEdge [
	| menu |
	menu := MenuMorph new defaultTarget: self.
	#(top right bottom left - center - topLeft topRight bottomRight bottomLeft - none)
		do: [:each |
			each == #-
				ifTrue: [menu addLine]
				ifFalse: [menu add: each asString translated selector: #setToAdhereToEdge: argument: each]].
	menu popUpEvent: self currentEvent in: self world
]

{ #category : #menus }
Morph >> adhereToEdge: edgeSymbol [ 
	| edgeMessage |
	(owner isNil or: [owner isHandMorph]) ifTrue: [^self].
	(owner class canUnderstand:  edgeSymbol) ifFalse:  [^self].
	(self class canUnderstand: ( edgeMessage := (edgeSymbol , ':') asSymbol ))
		 ifFalse:  [^self].
	
	self perform: edgeMessage
		withArguments: (Array with: (owner perform: edgeSymbol))
]

{ #category : #layout }
Morph >> adjustLayoutBounds [
	"Adjust the receivers bounds depending on the resizing strategy imposed"
	
	| hFit vFit box sbox myExtent myOrigin myBox |
	hFit := self hResizing.
	vFit := self vResizing.
	(hFit == #shrinkWrap or:[vFit == #shrinkWrap]) ifFalse:[^self]. "not needed"
	
	(self cellSpacing == #none and: [self listSpacing == #none]) ifFalse: [
		self flag: #todo. "mt: Find a way to make cell sizes accessible from here."
		self notify: 'It is not possible to shrink-wrap around submorphs when the layout policy reserves extra cell space. At this point, we have no access to that extra cell space and we do not know whether the submorph did make use of that extra space. So, shrink-wrapping could make the bounds very unstable.\\Please either reset #cellSpacing and #listSpacing - or change the resizing strategy to #rigid or #spaceFill.' withCRs.
		^ self]. 
	
	box := self layoutBounds.
	sbox := self submorphBoundsForShrinkWrap outsetBy: self cellInset.
	
	myExtent := box extent.
	myOrigin := box origin.
	hFit == #shrinkWrap ifTrue:[
		myExtent := sbox extent x @ myExtent y.
		myOrigin := sbox origin x @ myOrigin y].
	vFit == #shrinkWrap ifTrue:[
		myExtent := myExtent x @ sbox extent y.
		myOrigin := myOrigin x @ sbox origin y].
	"Make sure we don't get smaller than minWidth/minHeight"
	myExtent x < self minWidth ifTrue:[
		myExtent := (myExtent x max: 
			(self minWidth - self bounds width + self layoutBounds width)) @ myExtent y].
	myExtent y < self minHeight ifTrue:[
		myExtent := myExtent x @ (myExtent y max:
			(self minHeight - self bounds height + self layoutBounds height))].
		
	myBox := myOrigin extent: myExtent.
	self setLayoutBoundsFromLayout: myBox.
]

{ #category : #menus }
Morph >> adjustedCenter [
	"Provides a hook for objects to provide a reference point other than the receiver's center,for the purpose of centering a submorph under special circumstances, such as BalloonMorph"

	^ self center
]

{ #category : #menus }
Morph >> adjustedCenter: c [
	"Set the receiver's position based on the #adjustedCenter protocol for adhereToEdge.  By default this simply sets the receiver's center.   Though there are (at its inception anyway) no other implementors of this method, it is required in use with the #adhereToEdge when the centering of a submorph is to be with reference to a rectangle  other than the receiver's center."

	self center: c
]

{ #category : #accessing }
Morph >> adoptPaneColor: paneColor [
	self submorphsDo:[:m| m adoptPaneColor: paneColor].
]

{ #category : #'events-alarms' }
Morph >> alarmScheduler [
	"Return the scheduler being responsible for triggering alarms"
	^self world
]

{ #category : #'geometry - misc' }
Morph >> align: aPoint1 with: aPoint2 [
	"Translate by aPoint2 - aPoint1."

	^ self position: self position + (aPoint2 - aPoint1)
]

{ #category : #'submorphs-accessing' }
Morph >> allKnownNames [
	"Return a list of all known names based on the scope of the receiver.  Does not include the name of the receiver itself.  Items in parts bins are excluded.  Reimplementors (q.v.) can extend the list"

	^ Array streamContents:
		[:s | self allSubmorphNamesDo: [:n | s nextPut: n]]

]

{ #category : #menus }
Morph >> allMenuWordings [
	| tempMenu |
	tempMenu := self buildHandleMenu: self currentHand.
	tempMenu allMorphsDo: [:m | m step].  "Get wordings current"
	^ tempMenu allWordings
]

{ #category : #'submorphs-accessing' }
Morph >> allMorphs [
	"Return a collection containing all morphs in this composite morph (including the receiver)."

	| all |
	all := OrderedCollection new: 100.
	self allMorphsDo: [: m | all add: m].
	^ all
]

{ #category : #'e-toy support' }
Morph >> allMorphsAndBookPagesInto: aSet [
	"Return a set of all submorphs.  Don't forget the hidden ones like BookMorph pages that are not showing.  Consider only objects that are in memory (see allNonSubmorphMorphs)." 

	submorphs do: [:m | m allMorphsAndBookPagesInto: aSet].
	self allNonSubmorphMorphs do: [:m | 
			(aSet includes: m) ifFalse: ["Stop infinite recursion"
				m allMorphsAndBookPagesInto: aSet]].
	aSet add: self.
	self player ifNotNil:
		[self player allScriptEditors do: [:e | e allMorphsAndBookPagesInto: aSet]].
	^ aSet
]

{ #category : #'submorphs-accessing' }
Morph >> allMorphsDo: aBlock [ 
	"Evaluate the given block for all morphs in this composite morph (including the receiver)."

	submorphs do: [:m | m allMorphsDo: aBlock].
	aBlock value: self
]

{ #category : #'submorphs-add\/remove' }
Morph >> allMorphsWithPlayersDo: aTwoArgumentBlock [ 
	"Evaluate the given block for all morphs in this composite morph that have non-nil players.
	Also evaluate the block for the receiver if it has a player."

	submorphs do: [:m | m allMorphsWithPlayersDo: aTwoArgumentBlock ].
	self playerRepresented ifNotNil: [ :p | aTwoArgumentBlock value: self value: p ].

]

{ #category : #'submorphs-accessing' }
Morph >> allNonSubmorphMorphs [
	"Return a collection containing all morphs in this morph which are not currently in the submorph containment hierarchy (put in primarily for bookmorphs)"

	^ OrderedCollection new
]

{ #category : #structure }
Morph >> allOwners [
	"Return the owners of the reciever"

	^ Array streamContents: [:strm | self allOwnersDo: [:m | strm nextPut: m]]
]

{ #category : #structure }
Morph >> allOwnersDo: aBlock [
	"Evaluate aBlock with all owners of the receiver"
	owner ifNotNil:[^owner withAllOwnersDo: aBlock].
]

{ #category : #'debug and other' }
Morph >> allStringsAfter: aSubmorph [ 
	"return an OrderedCollection of strings of text in my submorphs.  If aSubmorph is non-nil, begin with that container."

	| list ok |
	list := OrderedCollection new.
	ok := aSubmorph isNil.
	self allMorphsDo: 
			[:sub | | string | 
			ok ifFalse: [ok := sub == aSubmorph].	"and do this one too"
			ok 
				ifTrue: 
					[(string := sub userString) ifNotNil: 
							[string isString ifTrue: [list add: string] ifFalse: [list addAll: string]]]].
	^list
]

{ #category : #'submorphs-accessing' }
Morph >> allSubmorphNamesDo: nameBlock [
	"Return a list of all known names of submorphs and nested submorphs of the receiver, based on the scope of the receiver.  Items in parts bins are excluded"

	self isPartsBin ifTrue: [^ self]. "Don't report names from parts bins"
	self submorphsDo: 
		[:m | m knownName ifNotNil: [:n | nameBlock value: n].
		m allSubmorphNamesDo: nameBlock].

]

{ #category : #geniestubs }
Morph >> allowsGestureStart: evt [
	^false
]

{ #category : #'debug and other' }
Morph >> altSpecialCursor0 [
	"an arrow"
	^(Form
	extent: 16@16
	depth: 8
	fromArray: #( 0 0 0 0 14869218 3806520034 3806520034 3791650816 14848144 2425393296 2425393378 0 14848144 2425393296 2425414144 0 14848144 2425393296 2430730240 0 14848144 2425393296 3791650816 0 14848144 2425393378 3791650816 0 14848144 2425414370 3806461952 0 14848144 2430788322 3806519808 0 14848144 3791651042 3806520034 0 14848226 0 3806520034 3791650816 14868992 0 14869218 3806461952 14811136 0 58082 3806519808 0 0 226 3806520034 0 0 0 3806520034 0 0 0 14869218)
	offset: 0@0)

]

{ #category : #'debug and other' }
Morph >> altSpecialCursor1 [
	"a star and an arrow"
	^(Form
	extent: 31@26
	depth: 8
	fromArray: #( 14417920 0 0 0 0 0 0 0 3705461980 3705461980 3705405440 0 0 0 0 0 3705461980 3705461980 3705461760 0 0 0 0 0 14474460 3705461980 3705405440 0 0 0 0 0 56540 3705461980 3690987520 0 0 3690987520 0 0 220 3705461980 3705461760 0 0 3690987520 0 0 220 3705405440 3705461980 0 0 3705405440 0 0 0 3705461760 56540 3690987520 220 3705405440 0 0 0 3705405440 220 3705461760 220 3705405440 0 0 0 0 0 14474460 220 3705461760 0 0 0 0 0 56540 3691044060 3705461760 0 0 0 0 0 220 3705461980 3705461760 0 0 0 0 56540 3705461980 3705461980 3705461980 3705461980 3705461760 0 0 220 3705461980 3705461980 3705461980 3705461980 3705461760 0 0 0 3705461980 3705461980 3705461980 3705461980 3705405440 0 0 0 14474460 3705461980 3705461980 3705461980 3690987520 0 0 0 56540 3705461980 3705461980 3705461760 0 0 0 0 220 3705461980 3705461980 3705405440 0 0 0 0 0 3705461980 3705461980 3690987520 0 0 0 0 0 3705461980 3705461980 3705405440 0 0 0 0 220 3705461980 3705461980 3705405440 0 0 0 0 220 3705461980 3705461980 3705405440 0 0 0 0 220 3705461980 14474460 3705405440 0 0 0 0 220 3705405440 220 3705461760 0 0 0 0 56540 3690987520 0 3705461760 0 0 0 0 56540 0 0 14474240 0)
	offset: 0@0)
]

{ #category : #'debug and other' }
Morph >> altSpecialCursor2 [
	| f |
	"a blue box with transparent center"
	f := Form extent: 32@32 depth: 32.
	f offset: (f extent // 2) negated.
	f fill: f boundingBox rule: Form over fillColor: (Color blue alpha: 0.5).
	f fill: (f boundingBox insetBy: 4) rule: Form over fillColor: Color transparent.
	^f

]

{ #category : #'debug and other' }
Morph >> altSpecialCursor3 [
	
	^self altSpecialCursor3: Color blue
]

{ #category : #'debug and other' }
Morph >> altSpecialCursor3: aColor [
	| f box |
	"a bulls-eye pattern in this color"
	f := Form extent: 32@32 depth: 32.
	f offset: (f extent // 2) negated.
	box := f boundingBox.
	[ box width > 0] whileTrue: [
		f fill: box rule: Form over fillColor: aColor.
		f fill: (box insetBy: 2) rule: Form over fillColor: Color transparent.
		box := box insetBy: 4.
	].
	^f

]

{ #category : #'meta-actions' }
Morph >> applyStatusToAllSiblings: evt [
	"Apply the statuses of all my scripts to the script status of all my siblings"

	| aPlayer |
	(aPlayer := self topRendererOrSelf player) belongsToUniClass ifFalse: [self error: 'not uniclass'].
	aPlayer instantiatedUserScriptsDo: 
		[:aScriptInstantiation | aScriptInstantiation assignStatusToAllSiblings]
]

{ #category : #updating }
Morph >> applyUserInterfaceTheme [

	"Re-initialize the shadow. Ensure shadow cache invalidation."
	self hasDropShadow ifTrue: [
		self addDropShadow.
		self removeProperty: #dropShadow.
		self changed].
]

{ #category : #drawing }
Morph >> areasRemainingToFill: aRectangle [
	"May be overridden by any subclasses with opaque regions"

	^ Array with: aRectangle
]

{ #category : #'stepping and presenter' }
Morph >> arrangeToStartStepping [
	"Arrange to start getting sent the 'step' message, but don't do that initial #step call that startStepping does"

	self arrangeToStartSteppingIn: self world
]

{ #category : #'stepping and presenter' }
Morph >> arrangeToStartSteppingIn: aWorld [
	"Start getting sent the 'step' message in aWorld.  Like startSteppingIn:, but without the initial one to get started'"
	aWorld ifNotNil:
		[aWorld startStepping: self.
		self changed]
]

{ #category : #converting }
Morph >> asDraggableMorph [
	"Huge or complex morphs have a serious impact on performance while being dragged. Use the thumbnail version."

	^ self thumbnail asMorph
]

{ #category : #creation }
Morph >> asMorph [
	^ self
]

{ #category : #'e-toy support' }
Morph >> asNumber: aPointOrNumber [
	"Support for e-toy demo."

	aPointOrNumber class = Point
		ifTrue: [^ aPointOrNumber r]
		ifFalse: [^ aPointOrNumber].

]

{ #category : #converting }
Morph >> asSnapshotThumbnail [
	^(ThumbnailImageMorph new  newImage: self imageForm ) extent: 90 asPoint .
]

{ #category : #'text-anchor' }
Morph >> asTextAnchor [
	"Convert the receiver to be embedded in text."
	
	^ TextAnchor new anchoredMorph: self
]

{ #category : #'accessing - extension' }
Morph >> assureExtension [
	"creates an extension for the receiver if needed"
	extension ifNil: [self initializeExtension].
	^ extension
]

{ #category : #player }
Morph >> assureExternalName [
	| aName |
	^ (aName := self knownName) ifNil:
		[self setNameTo: (aName := self externalName).
		^ aName]
]

{ #category : #'layout-properties' }
Morph >> assureLayoutProperties [
	| props |
	props := self layoutProperties.
	props == self ifTrue:[props := nil].
	props ifNil:[
		props := LayoutProperties new initializeFrom: self.
		self layoutProperties: props].
	^props
]

{ #category : #'layout-properties' }
Morph >> assureTableProperties [
	| props |
	props := self layoutProperties.
	props == self ifTrue:[props := nil].
	props ifNil:[
		props := TableLayoutProperties new initializeFrom: self.
		self layoutProperties: props].
	props includesTableProperties 
		ifFalse:[self layoutProperties: (props := props asTableLayoutProperties)].
	^props
]

{ #category : #'fileIn\/out' }
Morph >> attachToResource [
	"Connect a file -- either a saved .morph file or a graphics file as my resource.
	There appears to be nothing preventing a user from attaching a completely unrelated file ?"

	| pathName |
	pathName := UIManager default chooseFileMatchingSuffixes: (Form allTypicalFileExtensions add: 'morph'; yourself) label: 'Choose a file to load' translated.
	pathName ifNil: [^ self].  "User made no choice"

	self setProperty: #resourceFilePath toValue: pathName
]

{ #category : #'e-toy support' }
Morph >> automaticViewing [
	"Backstop, in case this message gets sent to an owner that is not a playfield"
	^ false
]

{ #category : #'halos and balloon help' }
Morph >> balloonColor [
	^ self
		valueOfProperty: #balloonColor
		ifAbsent: [self defaultBalloonColor]
]

{ #category : #'halos and balloon help' }
Morph >> balloonColor: aColor [
	^ self
		setProperty: #balloonColor
		toValue: aColor
]

{ #category : #'halos and balloon help' }
Morph >> balloonFont [
	^ self
		valueOfProperty: #balloonFont
		ifAbsent: [self defaultBalloonFont]
]

{ #category : #'halos and balloon help' }
Morph >> balloonFont: aFont [ 
	^ self setProperty: #balloonFont toValue: aFont
]

{ #category : #'halos and balloon help' }
Morph >> balloonHelpAligner [
	"Answer the morph to which the receiver's balloon help should point"
	^ (self valueOfProperty: #balloonTarget) ifNil: [self]
]

{ #category : #'halos and balloon help' }
Morph >> balloonHelpDelayTime [
	"Return the number of milliseconds before a balloon help should be put up on the receiver. The balloon help will only be put up if the receiver responds to #wantsBalloon by returning true."
	^ Preferences balloonHelpDelayTime
]

{ #category : #'halos and balloon help' }
Morph >> balloonHelpTextForHandle: aHandle [ 
	"Answer a string providing balloon help for the
	given halo handle"
	| itsSelector |
	itsSelector := aHandle eventHandler firstMouseSelector.
	itsSelector == #doRecolor:with:
		ifTrue: [^ Preferences propertySheetFromHalo
				ifTrue: ['Open a property sheet.']
				ifFalse: ['Change color']].
	itsSelector == #mouseDownInDimissHandle:with:
		ifTrue: [^ TrashCanMorph preserveTrash
				ifTrue: ['Move to trash']
				ifFalse: ['Remove from screen']].
	#(#(#addFullHandles 'More halo handles') #(#addSimpleHandles 'Fewer halo handles') #(#chooseEmphasisOrAlignment 'Emphasis & alignment') #(#chooseFont 'Change font') #(#chooseNewGraphicFromHalo 'Choose a new graphic') #(#chooseStyle 'Change style') #(#dismiss 'Remove') #(#doDebug:with: 'Debug') #(#doDirection:with: 'Choose forward direction') #(#doDup:with: 'Duplicate') #(#doMakeSibling:with: 'Make a sibling') #(#doMenu:with: 'Menu') #(#doGrab:with: 'Pick up') #(#editButtonsScript 'See the script for this button') #(#editDrawing 'Repaint') #(#doDupOrMakeSibling:with: 'Duplicate (press shift to make a sibling)') #(#doMakeSiblingOrDup:with: 'Make a sibling (press shift to make simple duplicate)') #(#makeNascentScript 'Make a scratch script') #(#makeNewDrawingWithin 'Paint new object') #(#mouseDownInCollapseHandle:with: 'Collapse') #(#mouseDownOnHelpHandle: 'Help') #(#openViewerForArgument 'Open a Viewer for me. Press shift for a snapshot.') #(#openViewerForTarget:with: 'Open a Viewer for me. Press shift for a snapshot.') #(#paintBackground 'Paint background') #(#prepareToTrackCenterOfRotation:with: 'Move object or set center of rotation') #(#presentViewMenu 'Present the Viewing menu') #(#startDrag:with: 'Move') #(#startGrow:with: 'Change size') #(#startRot:with: 'Rotate') #(#startScale:with: 'Change scale') #(#tearOffTile 'Make a tile representing this object') #(#tearOffTileForTarget:with: 'Make a tile representing this object') #(#trackCenterOfRotation:with: 'Set center of rotation') )
		do: [:pair | itsSelector == pair first
				ifTrue: [^ pair last]].
	^ 'unknown halo handle'translated
]

{ #category : #'halos and balloon help' }
Morph >> balloonMorphClass [

	^ NewBalloonMorph useNewBalloonMorph
		ifTrue: [NewBalloonMorph]
		ifFalse: [BalloonMorph]
]

{ #category : #accessing }
Morph >> balloonText [
	"Answer balloon help text or nil, if no help is available.  
	NB: subclasses may override such that they programatically  
	construct the text, for economy's sake, such as model phrases in 
	a Viewer"

	| result |
	extension ifNil: [^nil].
	
	extension balloonText
		ifNotNil: [:balloonText | result := balloonText]
		ifNil: [extension balloonTextSelector
			ifNotNil: [:balloonSelector |
				result := ScriptingSystem helpStringOrNilFor: balloonSelector.
				(result isNil and: [balloonSelector == #methodComment]) 
					ifTrue: [result := self methodCommentAsBalloonHelp].
				((result isNil and: [balloonSelector numArgs = 0]) 
					and: [self respondsTo: balloonSelector]) 
						ifTrue: [result := self perform: balloonSelector]]].
	^ result
]

{ #category : #accessing }
Morph >> balloonText: aString [

	self assureExtension balloonText: aString.
]

{ #category : #accessing }
Morph >> balloonTextSelector [
	"Answer balloon text selector item in the extension, nil if none"
	^ extension ifNotNil: [extension balloonTextSelector]
]

{ #category : #accessing }
Morph >> balloonTextSelector: aSelector [ 
	"change the receiver's balloonTextSelector"
	self assureExtension balloonTextSelector: aSelector
]

{ #category : #initialization }
Morph >> basicInitialize [
	"Do basic generic initialization of the instance variables:  
	Set up the receiver, created by a #basicNew and now ready to  
	be initialized, by placing initial values in the instance variables  
	as appropriate"
	owner := nil.
	submorphs := Array empty.
	bounds := self defaultBounds.
	color := self defaultColor
]

{ #category : #accessing }
Morph >> beFlap: aBool [
	"Mark the receiver with the #flap property, or unmark it"

	aBool
		ifTrue:
			[self setProperty: #flap toValue: true.
			self hResizing: #rigid.
			self vResizing: #rigid]
		ifFalse:
			[self removeProperty: #flap]
]

{ #category : #accessing }
Morph >> beSticky [
	"make the receiver sticky"
	self assureExtension sticky: true
]

{ #category : #'meta-actions' }
Morph >> beThisWorldsModel [

	self world setModel: self.
	self model: nil slotName: nil.	"A world's model cannot have another model"
]

{ #category : #accessing }
Morph >> beTransparent [
	self color: Color transparent
]

{ #category : #accessing }
Morph >> beUnsticky [
	"If the receiver is marked as sticky, make it now be unsticky"
	extension ifNotNil: [extension sticky: false]
]

{ #category : #accessing }
Morph >> borderColor [
	^self borderStyle color
]

{ #category : #accessing }
Morph >> borderColor: aColorOrSymbolOrNil [ 

	self flag: #compatibility. "mt: For old code. Should be removed in the future."
	aColorOrSymbolOrNil
		ifNil: [self borderStyle: nil]
		ifNotNil: [:colorOrSymbol |
			colorOrSymbol isSymbol ifTrue: [
				^ self borderStyle: ((self borderStyleForSymbol: colorOrSymbol)
											width: self borderStyle width;
											baseColor: self borderStyle baseColor;
											trackColorFrom: self;
											yourself)]].

	"Ensure a style object that can remember width and color."
	self borderStyle style = #none
		ifTrue: [self borderStyle: BorderStyle simple].

	"Set the color of the current border style."			
	self borderStyle
		baseColor: aColorOrSymbolOrNil;
		trackColorFrom: self.

	self changed.
]

{ #category : #accessing }
Morph >> borderStyle [
	^ self valueOfProperty: #borderStyle ifAbsentPut: [BorderStyle default]
]

{ #category : #accessing }
Morph >> borderStyle: aBorderStyle [

	aBorderStyle = self borderStyle ifTrue: [^ self].
	
	"If we cannot draw the new border, accept at least its color and width."
	((self canDrawBorder: aBorderStyle) or: [aBorderStyle isNil])
		ifTrue: [self setProperty: #borderStyle toValue: aBorderStyle]
		ifFalse: [
			self borderStyle
				width: aBorderStyle width;
				baseColor: aBorderStyle baseColor].

	self borderStyle trackColorFrom: self.

	self
		layoutChanged;
		changed.
]

{ #category : #accessing }
Morph >> borderStyleForSymbol: aStyleSymbol [
	"Answer a suitable BorderStyle for me of the type represented by a given symbol"

	^ (BorderStyle borderStyleForSymbol: aStyleSymbol asSymbol)
		ifNotNil: [:style | | existing |
			existing := self borderStyle.
			style
				width: existing width;
				baseColor: existing baseColor;
				trackColorFrom: self;
				yourself]
]

{ #category : #accessing }
Morph >> borderWidth [
	^self borderStyle width
]

{ #category : #accessing }
Morph >> borderWidth: aNumber [
	"Sets the width of the border in the current border style. If there is no border yet, set up a simple one so that the user can actually see the border width."

	self borderStyle width = aNumber ifTrue: [^ self].
	
	self borderStyle style = #none
		ifTrue: [^ self borderStyle: (BorderStyle simple width: aNumber; yourself)].
	
	self borderStyle width: aNumber.
	self layoutChanged; changed.
]

{ #category : #accessing }
Morph >> borderWidthForRounding [

	^ self borderWidth
]

{ #category : #geometry }
Morph >> bottom [
	" Return the y-coordinate of my bottom side "

	^ bounds bottom
]

{ #category : #geometry }
Morph >> bottom: aNumber [
	" Move me so that my bottom is at the y-coordinate aNumber. My extent (width & height) are unchanged "

	self position: (bounds left @ (aNumber - self height))
]

{ #category : #geometry }
Morph >> bottomCenter [

	^ bounds bottomCenter
]

{ #category : #geometry }
Morph >> bottomLeft [

	^ bounds bottomLeft
]

{ #category : #geometry }
Morph >> bottomLeft: aPoint [
	" Move me so that my bottom left corner is at aPoint. My extent (width & height) are unchanged "

	self position: ((aPoint x) @ (aPoint y - self height)).

]

{ #category : #geometry }
Morph >> bottomRight [

	^ bounds bottomRight
]

{ #category : #geometry }
Morph >> bottomRight: aPoint [
	" Move me so that my bottom right corner is at aPoint. My extent (width & height) are unchanged "

	self position: ((aPoint x - bounds width) @ (aPoint y - self height))

]

{ #category : #drawing }
Morph >> boundingBoxOfSubmorphs [
	| aBox |
	aBox := bounds origin extent: self minimumExtent.  "so won't end up with something empty"
	submorphs do:
		[:m | m visible ifTrue: [aBox := aBox quickMerge: m fullBounds]].
	^ aBox

]

{ #category : #geometry }
Morph >> bounds [
	"Return the bounds of this morph."
	"Note: It is best not to override this method because many methods in Morph and its subclasses use the instance variable directly rather than 'self bounds'. Instead, subclasses should be sure that the bounds instance variable is correct."

	^ bounds

]

{ #category : #geometry }
Morph >> bounds: newBounds [
	| oldExtent newExtent |
	oldExtent := self extent.
	newExtent := newBounds extent.
	(oldExtent dotProduct: oldExtent) <= (newExtent dotProduct: newExtent) ifTrue:[
		"We're growing. First move then resize."
		self position: newBounds topLeft; extent: newExtent.
	] ifFalse:[
		"We're shrinking. First resize then move."
		self extent: newExtent; position: newBounds topLeft.
	].
]

{ #category : #'geometry - local\/global' }
Morph >> bounds: aRectangle from: referenceMorph [
	"Return the receiver's bounds as seen by aMorphs coordinate frame"
	owner ifNil: [^ aRectangle].
	^(owner transformFrom: referenceMorph) globalBoundsToLocal: aRectangle

]

{ #category : #'geometry - local\/global' }
Morph >> bounds: aRectangle in: referenceMorph [
	"Return the receiver's bounds as seen by aMorphs coordinate frame"
	owner ifNil: [^ aRectangle].
	^(owner transformFrom: referenceMorph) localBoundsToGlobal: aRectangle

]

{ #category : #'halos and balloon help' }
Morph >> boundsForBalloon [

	"some morphs have bounds that are way too big"
	^self boundsInWorld
]

{ #category : #'geometry - local\/global' }
Morph >> boundsIn: referenceMorph [
	"Return the receiver's bounds as seen by aMorphs coordinate frame"
	^self bounds: self bounds in: referenceMorph
]

{ #category : #'geometry - local\/global' }
Morph >> boundsInWorld [
	^self bounds: self bounds in: self world
]

{ #category : #drawing }
Morph >> boundsWithinCorners [
	"Return a single sub-rectangle that lies entirely inside corners
	that are made by me.
	Used to identify large regions of window that do not need to be redrawn."

	^ self wantsRoundedCorners
		ifTrue: [self bounds insetBy: 0@self cornerRadius]
		ifFalse: [self bounds]

]

{ #category : #'meta-actions' }
Morph >> bringAllSiblingsToMe: evt [
	"bring all siblings of the receiver's player found in the same container to the receiver's location."

	| aPlayer aPosition aContainer |
	(aPlayer := self topRendererOrSelf player) belongsToUniClass ifFalse: [self error: 'not uniclass'].
	aPosition := self topRendererOrSelf position.
	aContainer := self topRendererOrSelf owner.
	(aPlayer class allInstances copyWithout: aPlayer) do:
		[:each |
			(aContainer submorphs includes: each costume) ifTrue:
				[each costume  position: aPosition]]
]

{ #category : #'debug and other' }
Morph >> buildDebugMenu: aHand [
	"Answer a debugging menu for the receiver.  The hand argument is seemingly historical and plays no role presently"

	| aMenu aPlayer |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addStayUpItem.
	(self hasProperty: #errorOnDraw) ifTrue:
		[aMenu add: 'start drawing again' translated action: #resumeAfterDrawError.
		aMenu addLine].
	(self hasProperty: #errorOnStep) ifTrue:
		[aMenu add: 'start stepping again' translated action: #resumeAfterStepError.
		aMenu addLine].

	aMenu add: 'inspect morph' translated action: #inspectInMorphic:.
	aMenu add: 'inspect owner chain' translated action: #inspectOwnerChain.
	Smalltalk isMorphic ifFalse:
		[aMenu add: 'inspect morph (in MVC)' translated action: #inspect].

	self isMorphicModel ifTrue:
		[aMenu add: 'inspect model' translated target: self model action: #inspect;
			add: 'explore model' translated target: self model action: #explore].
	(aPlayer := self player) ifNotNil:
		[aMenu add: 'inspect player' translated target: aPlayer action: #inspect].

     aMenu add: 'explore morph' translated target: self selector: #exploreInMorphic:.

	aMenu addLine.
	aPlayer ifNotNil:
		[ aMenu add: 'viewer for Player' translated target: self player action: #beViewed.
	aMenu balloonTextForLastItem: 'Opens a viewer on my Player -- this is the same thing you get if you click on the cyan "View" halo handle' translated ].

	aMenu add: 'viewer for Morph' translated target: self action: #viewMorphDirectly.
	aMenu balloonTextForLastItem: 'Opens a Viewer on this Morph, rather than on its Player' translated.
	aMenu addLine.

	aPlayer ifNotNil:
		[aPlayer class isUniClass ifTrue: [
			aMenu add: 'browse player class' translated target: aPlayer selector: #haveFullProtocolBrowsedShowingSelector: argumentList: #(nil)]].
	aMenu add: 'browse morph class' translated target: self selector: #browseHierarchy.
	(self isMorphicModel)
		ifTrue: [aMenu
				add: 'browse model class'
				target: self model
				selector: #browseHierarchy].
	aMenu addLine.

	self addViewingItemsTo: aMenu.
	aMenu 
		add: 'make own subclass' translated action: #subclassMorph;
		add: 'save morph in file' translated  action: #saveOnFile;
		addLine;
		add: 'call #tempCommand' translated action: #tempCommand;
		add: 'define #tempCommand' translated action: #defineTempCommand;
		addLine;

		add: 'control-menu...' translated target: self selector: #invokeMetaMenu:;
		add: 'edit balloon help' translated action: #editBalloonHelpText.

	^ aMenu
]

{ #category : #'meta-actions' }
Morph >> buildHandleMenu: aHand [
	"Build the morph menu for the given morph's halo's menu handle. This menu has two sections. The first section contains commands that are interpreted by the hand; the second contains commands provided by the target morph. This method allows the morph to decide which items should be included in the hand's section of the menu."

	| menu |

	(Preferences generalizedYellowButtonMenu
			and: [Preferences noviceMode])
		ifTrue: [^ self buildYellowButtonMenu: aHand].

	menu := MenuMorph new defaultTarget: self.
	menu addStayUpItem.
	menu addLine.
	self addStandardHaloMenuItemsTo: menu hand: aHand.
	menu defaultTarget: aHand.
	self addAddHandMenuItemsForHalo: menu  hand: aHand.
	menu defaultTarget: self.
	self addCustomHaloMenuItems: menu hand: aHand.
	menu defaultTarget: aHand.
	^ menu

]

{ #category : #'meta-actions' }
Morph >> buildMetaMenu: evt [
	"Build the morph menu. This menu has two sections. The first section contains commands that are handled by the hand; the second contains commands handled by the argument morph."
	| menu |
	menu := MenuMorph new defaultTarget: self.
	menu addStayUpItem.
	menu add: 'grab' translated action: #grabMorph:.
	menu add: 'copy to paste buffer' translated action: #copyToPasteBuffer:.
	self maybeAddCollapseItemTo: menu.
	menu add: 'delete' translated action: #dismissMorph:.
	menu addLine.
	menu add: 'copy text' translated action: #clipText.
	menu add: 'copy Postscript' translated action: #clipPostscript.
	menu add: 'print Postscript to file...' translated action: #printPSToFile.
	menu addLine.
	menu add: 'go behind' translated action: #goBehind.
	menu add: 'add halo' translated action: #addHalo:.
	menu add: 'duplicate' translated action: #maybeDuplicateMorph:.

	self addEmbeddingMenuItemsTo: menu hand: evt hand.

	menu add: 'resize' translated action: #resizeMorph:.
	"Give the argument control over what should be done about fill styles"
	self addFillStyleMenuItems: menu hand: evt hand.
	self addDropShadowMenuItems: menu hand: evt hand.
	self addLayoutMenuItems: menu hand: evt hand.
	menu addUpdating: #hasClipSubmorphsString target: self selector: #changeClipSubmorphs argumentList: #().
	menu addLine.

	(self morphsAt: evt position) size > 1 ifTrue:
		[menu add: 'submorphs...' translated
			target: self
			selector: #invokeMetaMenuAt:event:
			argument: evt position].
	menu addLine.
	menu add: 'inspect' translated selector: #inspectAt:event: argument: evt position.
	menu add: 'explore' translated action: #explore.
	menu add: 'browse hierarchy' translated action: #browseHierarchy.
	menu add: 'make own subclass' translated action: #subclassMorph.
	menu addLine.
	(self isMorphicModel) ifTrue:
		[menu add: 'save morph as prototype' translated action: #saveAsPrototype.
		(self ~~ self world modelOrNil) ifTrue:
			 [menu add: 'become this world''s model' translated action: #beThisWorldsModel]].
	menu add: 'save morph in file' translated action: #saveOnFile.
	(self hasProperty: #resourceFilePath)
		ifTrue: [((self valueOfProperty: #resourceFilePath) endsWith: '.morph')
				ifTrue: [menu add: 'save as resource' translated action: #saveAsResource].
				menu add: 'update from resource' translated action: #updateFromResource]
		ifFalse: [menu add: 'attach to resource' translated action: #attachToResource].
	menu add: 'show actions' translated action: #showActions.
	menu addLine.
	self addDebuggingItemsTo: menu hand: evt hand.

	self addCustomMenuItems: menu hand: evt hand.
	^ menu

]

{ #category : #menu }
Morph >> buildYellowButtonMenu: aHand [ 
	"Build the morph menu for the yellow button."

	| menu |
	menu := MenuMorph new defaultTarget: self.
	self addNestedYellowButtonItemsTo: menu event: self currentEvent.
	MenuIcons decorateMenu: menu.
	^ menu
]

{ #category : #'visual properties' }
Morph >> canApplyUserInterfaceTheme [
	^ self isInWorld and: [(self hasProperty: #noUserInterfaceTheme) not]
]

{ #category : #private }
Morph >> canBeEncroached [
	"Support for the #smartHorizontalSplitters preference."
	^ true
]

{ #category : #testing }
Morph >> canDrawAtHigherResolution [

	^false
]

{ #category : #testing }
Morph >> canDrawBorder: aBorderStyle [
	"Return true if the receiver can be drawn with the given border style."
	^true
]

{ #category : #'visual properties' }
Morph >> canHaveFillStyles [
	"Return true if the receiver can have general fill styles; not just colors.
	This method is for gradually converting old morphs."
	^self class == Morph "no subclasses"
]

{ #category : #'layout-properties' }
Morph >> cellGap [
	"Layout specific. This property specifies an extra space *between* cells in the layout."
	| props |
	props := self layoutProperties.
	^props ifNil:[0] ifNotNil:[props cellGap].
]

{ #category : #'layout-properties' }
Morph >> cellGap: aNumber [
	"Layout specific. This property specifies an extra space *between* cells in the layout."
	self assureTableProperties cellGap: aNumber.
	self layoutChanged.
]

{ #category : #'layout-properties' }
Morph >> cellInset [
	"Layout specific. This property specifies an extra inset for each cell in the layout."
	| props |
	props := self layoutProperties.
	^props ifNil:[0] ifNotNil:[props cellInset].
]

{ #category : #'layout-properties' }
Morph >> cellInset: aNumber [
	"Layout specific. This property specifies an extra inset for each cell in the layout."
	self assureTableProperties cellInset: aNumber.
	self layoutChanged.
]

{ #category : #'layout-properties' }
Morph >> cellPositioning [
	"Layout specific. This property describes how the receiver should be layed out in its owner when the bounds of the cell assigned to the receiver do not exactly match its bounds. Possible values are:
		#topLeft, #topRight, #bottomLeft, #bottomRight, #topCenter, #leftCenter, #rightCenter, #bottomCenter, #center 
	which align the receiver's bounds with the cell at the given point."
	| props |
	props := self layoutProperties.
	^props ifNil:[#center] ifNotNil:[props cellPositioning].
]

{ #category : #'layout-properties' }
Morph >> cellPositioning: aSymbol [
	"Layout specific. This property describes how the receiver should be layed out in its owner when the bounds of the cell assigned to the receiver do not exactly match its bounds. Possible values are:
		#topLeft, #topRight, #bottomLeft, #bottomRight, #topCenter, #leftCenter, #rightCenter, #bottomCenter, #center 
	which align the receiver's bounds with the cell at the given point."
	self assureTableProperties cellPositioning: aSymbol.
	self layoutChanged.
]

{ #category : #'layout-properties' }
Morph >> cellPositioningString: aSymbol [
	^self layoutMenuPropertyString: aSymbol from: self cellPositioning
]

{ #category : #'layout-properties' }
Morph >> cellSpacing [
	"Layout specific. This property describes how the cell size for each element in a list should be computed.
		#globalRect - globally equal rectangular cells
		#globalSquare - globally equal square cells
		#localRect - locally (e.g., per row/column) equal rectangular cells
		#localSquare - locally (e.g., per row/column) equal square cells
		#none - cells are sized based on available row/column constraints
	"
	| props |
	props := self layoutProperties.
	^props ifNil:[#none] ifNotNil:[props cellSpacing].
]

{ #category : #'layout-properties' }
Morph >> cellSpacing: aSymbol [
	"Layout specific. This property describes how the cell size for each element in a list should be computed.
		#globalRect - globally equal rectangular cells
		#globalSquare - globally equal square cells
		#localRect - locally (e.g., per row/column) equal rectangular cells
		#localSquare - locally (e.g., per row/column) equal square cells
		#none - cells are sized based on available row/column constraints
	"
	self checkCellSpacingProperty: aSymbol.
	self assureTableProperties cellSpacing: aSymbol.
	self layoutChanged.
]

{ #category : #'layout-properties' }
Morph >> cellSpacingString: aSymbol [
	^self layoutMenuPropertyString: aSymbol from: self cellSpacing
]

{ #category : #geometry }
Morph >> center [

	^ bounds center
]

{ #category : #geometry }
Morph >> center: aPoint [
	self position: (aPoint - (self extent // 2))
]

{ #category : #'layout-menu' }
Morph >> changeCellGap: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:[:newPoint |
		self cellGap: (newPoint - evt cursorPoint) asIntegerPoint // 5].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'layout-menu' }
Morph >> changeCellInset: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:[:newPoint |
		self cellInset: (newPoint - evt cursorPoint) asIntegerPoint // 5].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'layout-menu' }
Morph >> changeClipLayoutCells [
	self invalidRect: self fullBounds.
	self clipLayoutCells: self clipLayoutCells not.
	self invalidRect: self fullBounds.
]

{ #category : #drawing }
Morph >> changeClipSubmorphs [
	self clipSubmorphs: self clipSubmorphs not.
]

{ #category : #menus }
Morph >> changeColor [
	"Change the color of the receiver -- triggered, e.g. from a menu"
	NewColorPickerMorph useIt
		ifTrue: [ (NewColorPickerMorph on: self) openNear: self fullBoundsInWorld ]
		ifFalse:
			[ ColorPickerMorph new
				 choseModalityFromPreference ;
				 sourceHand: self activeHand ;
				 target: self ;
				 selector: #fillStyle: ;
				 originalColor: self color ;
				
				putUpFor: self
				near: self fullBoundsInWorld ]
]

{ #category : #'meta-actions' }
Morph >> changeColorTarget: anObject selector: aSymbol originalColor: aColor hand: aHand [ 
	"Put up a color picker for changing some kind of color.  May be modal or modeless, depending on #modalColorPickers setting"
	| desiredLoc |
	self flag: #arNote.
	"Simplify this due to anObject == self for almost all cases"
	desiredLoc := anObject isMorph
		ifTrue:
			[ Rectangle
				center: self position
				extent: 20 ]
		ifFalse:
			[ anObject == self world
				ifTrue: [ anObject viewBox bottomLeft + (20 @ -20) extent: 200 ]
				ifFalse: [ anObject fullBoundsInWorld ] ].
	^ NewColorPickerMorph useIt
		ifTrue:
			[ (NewColorPickerMorph
				on: anObject
				originalColor: aColor
				setColorSelector: aSymbol) openNear: desiredLoc ]
		ifFalse:
			[ ColorPickerMorph new
				 choseModalityFromPreference ;
				 sourceHand: aHand ;
				 target: anObject ;
				 selector: aSymbol ;
				 originalColor: aColor ;
				
				putUpFor: anObject
				near: desiredLoc ;
				 yourself ]
]

{ #category : #menus }
Morph >> changeDirectionHandles [
	^self wantsDirectionHandles: self wantsDirectionHandles not
]

{ #category : #'layout-menu' }
Morph >> changeDisableTableLayout [
	self disableTableLayout: self disableTableLayout not.
	self layoutChanged.
]

{ #category : #menus }
Morph >> changeDrag [
	^ self enableDrag: self dragEnabled not
]

{ #category : #menus }
Morph >> changeDragAndDrop [
	^ self enableDragNDrop: self dragNDropEnabled not
]

{ #category : #menus }
Morph >> changeDrop [
	^ self enableDrop: self dropEnabled not
]

{ #category : #'layout-menu' }
Morph >> changeHeightForWidth [
	"Convenience. Configure morphs that do not have a layout policy to be layed out properly in an owner that has such a policy. Tell that owner that I change my height if somebody changes my width."
	
	self
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		wrapDirection: #topToBottom.
]

{ #category : #'layout-menu' }
Morph >> changeLayoutInset: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:[:newPoint |
		self layoutInset: (newPoint - evt cursorPoint) asIntegerPoint // 5].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'layout-menu' }
Morph >> changeListDirection: aSymbol [
	| listDir wrapDir |
	self listDirection: aSymbol.
	(self wrapDirection == #none) ifTrue:[^self].
	"otherwise automatically keep a valid table layout"
	listDir := self listDirection.
	wrapDir := self wrapDirection.
	(listDir == #leftToRight or:[listDir == #rightToLeft]) ifTrue:[
		wrapDir == #leftToRight ifTrue:[^self wrapDirection: #topToBottom].
		wrapDir == #rightToLeft ifTrue:[^self wrapDirection: #bottomToTop].
	] ifFalse:[
		wrapDir == #topToBottom ifTrue:[^self wrapDirection: #leftToRight].
		wrapDir == #bottomToTop ifTrue:[^self wrapDirection: #rightToLeft].
	].

]

{ #category : #'layout-menu' }
Morph >> changeMaxCellSize: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:[:newPoint |
		self maxCellSize: (newPoint - evt cursorPoint) asIntegerPoint].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'layout-menu' }
Morph >> changeMinCellSize: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:[:newPoint |
		self minCellSize: (newPoint - evt cursorPoint) asIntegerPoint].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'layout-menu' }
Morph >> changeNoLayout [
	self layoutPolicy ifNil:[^self]. "already no layout"
	self layoutPolicy: nil.
	self layoutChanged.
]

{ #category : #'layout-menu' }
Morph >> changeProportionalLayout [
	| layout |
	((layout := self layoutPolicy) notNil and:[layout isProportionalLayout])
		ifTrue:[^self]. "already proportional layout"
	self layoutPolicy: ProportionalLayout new.
	self layoutChanged.
]

{ #category : #'layout-menu' }
Morph >> changeReverseCells [
	self reverseTableCells: self reverseTableCells not.
]

{ #category : #'layout-menu' }
Morph >> changeRubberBandCells [
	self rubberBandCells: self rubberBandCells not.
]

{ #category : #'drop shadows' }
Morph >> changeShadowColor [
	"Change the shadow color of the receiver -- triggered, e.g. from a menu"
	NewColorPickerMorph useIt
		ifTrue:
			[ (NewColorPickerMorph
				on: self
				originalColor: self shadowColor
				setColorSelector: #shadowColor:) openNearMorph: self ]
		ifFalse:
			[ ColorPickerMorph new
				 choseModalityFromPreference ;
				 sourceHand: self activeHand ;
				 target: self ;
				 selector: #shadowColor: ;
				 originalColor: self shadowColor ;
				
				putUpFor: self
				near: self fullBoundsInWorld ]
]

{ #category : #'layout-menu' }
Morph >> changeTableLayout [
	| layout |
	((layout := self layoutPolicy) notNil and:[layout isTableLayout])
		ifTrue:[^self]. "already table layout"
	self layoutPolicy: TableLayout new.
]

{ #category : #'layout-menu' }
Morph >> changeWidthForHeight [
	"Convenience. Configure morphs that do not have a layout policy to be layed out properly in an owner that has such a policy. Tell that owner that I change my width if somebody changes my height."
	
	self
		hResizing: #shrinkWrap;
		vResizing: #spaceFill;
		wrapDirection: #leftToRight.
]

{ #category : #updating }
Morph >> changed [
	"Report that the area occupied by this morph should be redrawn."
	^fullBounds 
		ifNil:[self invalidRect: self outerBounds]
		ifNotNil:[self invalidRect: fullBounds]
]

{ #category : #'layout-menu' }
Morph >> changesHeightForWidth [
	"When both axes are on #spaceFill, the receiver (morph) usually adapts any inner height-for-width layout unless there is more space to fill. Since we cannot know in advance, we assume that an extra layout run might be necessary."
	
	^ (self hResizing == #spaceFill and: [self vResizing == #spaceFill])
		or: [(self hResizing ~= #shrinkWrap
			and: [self vResizing = #shrinkWrap])
			and: [self wrapDirection ~= #none]]
]

{ #category : #'layout-menu' }
Morph >> changesWidthForHeight [
	"When both axes are on #spaceFill, the receiver (morph) usually adapts any inner height-for-width layout unless there is more space to fill. Since we cannot know in advance, we assume that an extra layout run might be necessary."
		
	^ (self hResizing == #spaceFill and: [self vResizing == #spaceFill])
		or: [(self hResizing = #shrinkWrap
			and: [self vResizing ~= #shrinkWrap])
			and: [self wrapDirection ~= #none]]
]

{ #category : #layout }
Morph >> checkCellSpacingProperty: aSymbol [
	
	aSymbol == #none ifTrue: [^ self].
	
	aSymbol == #globalRect ifTrue: [^ self].
	aSymbol == #globalSquare ifTrue: [^ self].
	aSymbol == #localRect ifTrue: [^ self].
	aSymbol == #localSquare ifTrue: [^ self].
	
	Error signal: 'Invalid cell-spacing property. Use #none, #globalRect, #globalSquare, #localRect, or #localSquare.'.
]

{ #category : #layout }
Morph >> checkListSpacingProperty: aSymbol [
	
	aSymbol == #none ifTrue: [^ self].
	aSymbol == #equal ifTrue: [^ self].
	
	Error signal: 'Invalid value for list-spacing property. Use #none or #equal.'.
]

{ #category : #layout }
Morph >> checkResizingProperty: aSymbol [

	aSymbol == #rigid ifTrue: [^ self].
	aSymbol == #shrinkWrap ifTrue: [^ self].
	aSymbol == #spaceFill ifTrue: [^ self].
	
	Error signal: 'Invalid value for resizing property. Use #rigid, #shrinkWrap, or #spaceFill.'.
]

{ #category : #menus }
Morph >> chooseNewGraphic [
	"Used by any morph that can be represented by a graphic"
	self chooseNewGraphicCoexisting: false

]

{ #category : #menus }
Morph >> chooseNewGraphicCoexisting: aBoolean [ 
	"Allow the user to choose a different form for her form-based morph"

	| replacee aGraphicalMenu |
	self isInWorld ifFalse: "menu must have persisted for a not-in-world object."
		[aGraphicalMenu := Project current world submorphThat:
				[:m | (m isKindOf: GraphicalMenu) and: [m target == self]]
			 ifNone:
				[^ self].
		^ aGraphicalMenu show; flashBounds].
	aGraphicalMenu := GraphicalMenu new
				initializeFor: self
				withForms: self reasonableForms
				coexist: aBoolean.
	aBoolean
		ifTrue: [self primaryHand attachMorph: aGraphicalMenu]
		ifFalse: [replacee := self topRendererOrSelf.
			replacee owner replaceSubmorph: replacee by: aGraphicalMenu]
]

{ #category : #menus }
Morph >> chooseNewGraphicFromHalo [
	"Allow the user to select a changed graphic to replace the one in the receiver"

	self currentWorld abandonAllHalos.
	self chooseNewGraphicCoexisting: true

]

{ #category : #accessing }
Morph >> clearArea [
	"Answer the clear area of the receiver. It means the area free  
	of docking bars."
	| visTop visBottom visLeft visRight |

	visTop := self top.
	visBottom := self bottom.
	visLeft := self left.
	visRight := self right.

	self dockingBars
		do: [:each | 
			(each isAdheringToTop and: [each bottom > visTop])
				ifTrue: [visTop := each bottom].

			(each isAdheringToBottom and: [each top < visBottom])
				ifTrue: [visBottom := each top].

			(each isAdheringToLeft and: [each right > visLeft])
				ifTrue: [visLeft := each right].

			(each isAdheringToRight and: [each left < visRight])
				ifTrue: [visRight := each left]
		].

	^ Rectangle
		left: visLeft
		right: visRight
		top: visTop
		bottom: visBottom

]

{ #category : #'event handling' }
Morph >> click [
	"Pretend the user clicked on me."

	(self handlesMouseDown: nil) ifTrue: [
		self mouseDown: nil.
		self mouseUp: nil].
]

{ #category : #'event handling' }
Morph >> click: evt [
	"Handle a single-click event. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation does nothing.
	LC 2/14/2000 08:32 - added: EventHandler notification"

	self eventHandler ifNotNil:
		[self eventHandler click: evt fromMorph: self].
]

{ #category : #drawing }
Morph >> clipLayoutCells [
	"Drawing/layout specific. If this property is set, clip the  
	submorphs of the receiver by its cell bounds."
	^ self
		valueOfProperty: #clipLayoutCells
		ifAbsent: [false]
]

{ #category : #drawing }
Morph >> clipLayoutCells: aBool [
	"Drawing/layout specific. If this property is set, clip the submorphs of the receiver by its cell bounds."
	aBool == false
		ifTrue:[self removeProperty: #clipLayoutCells]
		ifFalse:[self setProperty: #clipLayoutCells toValue: aBool].
	self changed.
]

{ #category : #drawing }
Morph >> clipSubmorphs [
	"Drawing specific. If this property is set, clip the receiver's  
	submorphs to the receiver's clipping bounds."
	
	extension ifNil: [^false].
	^ self
		valueOfProperty: #clipSubmorphs
		ifAbsent: [false]
]

{ #category : #drawing }
Morph >> clipSubmorphs: aBool [
	"Drawing specific. If this property is set, clip the receiver's submorphs to the receiver's clipping bounds."

	self fullBounds; changed.
	
	aBool == false
		ifTrue:[self removeProperty: #clipSubmorphs]
		ifFalse:[self setProperty: #clipSubmorphs toValue: aBool].
	
	self
		layoutChanged;
		fullBounds; changed.
]

{ #category : #printing }
Morph >> clipText [
	"Copy the text in the receiver or in its submorphs to the clipboard"
	| content |
	"My own text"
	content := self userString.
	"Or in my submorphs"
	content ifNil: [
		| list |
		list := self allStringsAfter: nil.
		list notEmpty ifTrue: [
			content := String streamContents: [:stream |
				list do: [:each | stream nextPutAll: each; cr]]]].
	"Did we find something?"
	content
		ifNil: [self flash "provide feedback"]
		ifNotNil: [Clipboard clipboardText: content].
]

{ #category : #drawing }
Morph >> clippingBounds [
	"Return the bounds to which any submorphs should be clipped if the property is set"
	^self innerBounds
]

{ #category : #menus }
Morph >> collapse [
	CollapsedMorph new beReplacementFor: self
]

{ #category : #accessing }
Morph >> color [

	^ color 	"has already been set to ((self valueOfProperty: #fillStyle) asColor)"
]

{ #category : #accessing }
Morph >> color: aColor [
	"Set the receiver's color.  Directly set the color if appropriate, else go by way of fillStyle"

	(aColor isColor or: [aColor isKindOf: InfiniteForm]) ifFalse:[^ self fillStyle: aColor].
	color = aColor ifFalse:
		[self removeProperty: #fillStyle.
		color := aColor.
		self borderStyle trackColorFrom: self.
		self changed]
]

{ #category : #'change reporting' }
Morph >> colorChangedForSubmorph: aSubmorph [
	"The color associated with aSubmorph was changed through the UI; react if needed"
]

{ #category : #accessing }
Morph >> colorForInsets [
	"Return the color to be used for shading inset borders.  The default is my own color, but it might want to be, eg, my owner's color.  Whoever's color ends up prevailing, the color itself gets the last chance to determine, so that when, for example, an InfiniteForm serves as the color, callers won't choke on some non-Color object being returned"
	(color isColor and:[color isTransparent and:[owner notNil]]) ifTrue:[^owner colorForInsets].
	^ color colorForInsets

]

{ #category : #printing }
Morph >> colorString: aColor [ 

	aColor ifNil: [ ^'nil' ].
	^aColor name
		ifNil: [ aColor storeString ]
		ifNotNil: [ :colorName | 'Color ', colorName ]
]

{ #category : #'submorphs-add\/remove' }
Morph >> comeToFront [
	| outerMorph |
	outerMorph := self topRendererOrSelf.
	(outerMorph owner isNil or: [outerMorph owner hasSubmorphs not]) 
		ifTrue: [^self].
	outerMorph owner firstSubmorph == outerMorph 
		ifFalse: [outerMorph owner addMorphFront: outerMorph]
]

{ #category : #'halos and balloon help' }
Morph >> comeToFrontAndAddHalo [
	self comeToFront.
	self addHalo
]

{ #category : #undo }
Morph >> commandHistory [
	"Return the command history for the receiver"
	| w |
	(w := self world) ifNotNil:[^w commandHistory].
	(w := self currentWorld) ifNotNil:[^w commandHistory].
	^CommandHistory new. "won't really record anything but prevent breaking things"
]

{ #category : #testing }
Morph >> completeModificationHash [

"World completeModificationHash"

	| resultSize result |
	resultSize := 10.
	result := ByteArray new: resultSize.
	self allMorphsDo: [ :each | | here | 
		here := each modificationHash.
		here withIndexDo: [ :ch :index | | i |
			i := index \\ resultSize + 1.
			result at: i put: ((result at: i) bitXor: ch asciiValue)
		].
	].
	^result
]

{ #category : #printing }
Morph >> constructorString [

	^ String streamContents: [:s | self printConstructorOn: s indent: 0].

]

{ #category : #structure }
Morph >> containingWindow [
	"Answer a window that contains the receiver. Try to use the model to find the right window. If I do not have a model, use the model of one of my owners. We could also just use #isSystemWindow. This, however, gives system windows the chance to refrain from taking ownership of this morph."

	| component |
	component := self.
	component model isNil ifTrue: [component := self firstOwnerSuchThat: [:m| m model notNil]].
	^(component isNil or: [component isWindowForModel: component model])
		ifTrue: [component]
		ifFalse: [(component firstOwnerSuchThat: [:m | m isWindowForModel: component model])
			"For models composed of models, we have to use #isSystemWindow."
			ifNil: [component firstOwnerSuchThat: [:m | m isSystemWindow]]]
]

{ #category : #'geometry testing' }
Morph >> containsPoint: aPoint [

	^ self bounds containsPoint: aPoint
]

{ #category : #'events-processing' }
Morph >> containsPoint: aPoint event: anEvent [
	"Return true if aPoint is considered to be inside the receiver for the given event.
	The default implementation treats locked children as integral part of their owners."
	(self fullBounds containsPoint: aPoint) ifFalse:[^false].
	(self containsPoint: aPoint) ifTrue:[^true].
	self submorphsDo:[:m|
		(m isLocked and:[m fullContainsPoint: 
			((m transformedFrom: self) globalPointToLocal: aPoint)]) ifTrue:[^true]].
	^false
]

{ #category : #copying }
Morph >> copy [

	^ self veryDeepCopy
]

{ #category : #'layout-properties' }
Morph >> copyLayoutProperties [
	^[Clipboard clipboardText: self layoutProperties stringWithLayout] ifError:[ nil ] 
]

{ #category : #'meta-actions' }
Morph >> copyToPasteBuffer: evt [
	self okayToDuplicate ifTrue:[evt hand copyToPasteBuffer: self].
]

{ #category : #'submorphs-add\/remove' }
Morph >> copyWithoutSubmorph: sub [
	"Needed to get a morph to draw without one of its submorphs.
	NOTE:  This must be thrown away immediately after use."
	^ self shallowCopy privateSubmorphs: (submorphs copyWithout: sub)
]

{ #category : #rounding }
Morph >> cornerRadius [

	^ self
		valueOfProperty: #cornerRadius
		ifAbsent: [self class preferredCornerRadius]
]

{ #category : #rounding }
Morph >> cornerRadius: radius [

	self
		setProperty: #cornerRadius
		toValue: radius.

	self changed.
]

{ #category : #rounding }
Morph >> cornerStyle [
	"Returns one of the following symbols:
		#square
		#rounded
	according to the current corner style."

	^ self valueOfProperty: #cornerStyle ifAbsent: [#square]
]

{ #category : #rounding }
Morph >> cornerStyle: aSymbol [
	"This method makes it possible to set up desired corner style. aSymbol has to be one of:
		#square
		#rounded"

	self setProperty: #cornerStyle toValue: aSymbol.
	self changed.
]

{ #category : #accessing }
Morph >> couldHaveRoundedCorners [
	^ true
]

{ #category : #testing }
Morph >> couldMakeSibling [
	"Answer whether it is appropriate to ask the receiver to make a sibling"

	^ true
]

{ #category : #'halos and balloon help' }
Morph >> createHalo [

	^ (Smalltalk at: self haloClass ifAbsent: [HaloMorph]) new
		bounds: self worldBoundsForHalo
		yourself
]

{ #category : #'e-toy support' }
Morph >> currentPlayerDo: aBlock [
	"If the receiver is a viewer/scriptor associated with a current Player object, evaluate the given block against that object"
]

{ #category : #'e-toy support' }
Morph >> cursor [
	"vacuous backstop in case it gets sent to a morph that doesn't know what to do with it"

	^ 1
]

{ #category : #'e-toy support' }
Morph >> cursor: aNumber [
	"vacuous backstop in case it gets sent to a morph that doesn't know what to do with it"

]

{ #category : #'event handling' }
Morph >> cursorPoint [
	^ self currentHand lastEvent cursorPoint
]

{ #category : #'e-toy support' }
Morph >> decimalPlacesForGetter: aGetter [
	"Answer the decimal places I prefer for showing a slot with the given getter, or nil if none"

	| decimalPrefs |
	decimalPrefs := self renderedMorph valueOfProperty: #decimalPlacePreferences ifAbsent: [^ nil].
	^ decimalPrefs at: aGetter ifAbsent: [nil]
]

{ #category : #copying }
Morph >> deepCopy [

	self error: 'Please use veryDeepCopy'.

]

{ #category : #menus }
Morph >> defaultArrowheadSize [
	
	^ self class defaultArrowheadSize
]

{ #category : #'halos and balloon help' }
Morph >> defaultBalloonColor [
	^ Display depth <= 2
		ifTrue: [Color white]
		ifFalse: [BalloonMorph balloonColor]
]

{ #category : #'halos and balloon help' }
Morph >> defaultBalloonFont [
	^ BalloonMorph balloonFont
]

{ #category : #'visual properties' }
Morph >> defaultBitmapFillForm [
	^ImageMorph defaultForm.

]

{ #category : #initialization }
Morph >> defaultBounds [
"answer the default bounds for the receiver"
	^ 0 @ 0 corner: 50 @ 40
]

{ #category : #initialization }
Morph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color blue
]

{ #category : #'events-processing' }
Morph >> defaultEventDispatcher [
	"Return the default event dispatcher to use with events that are directly sent to the receiver"
	^MorphicEventDispatcher new
]

{ #category : #'user interface' }
Morph >> defaultLabelForInspector [
	"Answer the default label to be used for an Inspector window on the receiver."
	^ self printStringLimitedTo: 40
]

{ #category : #accessing }
Morph >> defaultNameStemForInstances [
	^self class name
]

{ #category : #'e-toy support' }
Morph >> defaultValueOrNil [
	"If the receiver has a property named #defaultValue, return that property's value, else return nil"

	^ self valueOfProperty: #defaultValue ifAbsent: [nil]
]

{ #category : #'halos and balloon help' }
Morph >> defersHaloOnClickTo: aSubMorph [
	"If a cmd-click on aSubMorph would make it a preferred recipient of the halo, answer true"
	"May want to add a way (via a property) for morphs to assert true here -- this would let certain kinds of morphs that are unusually reluctant to take the halo on initial click"

	^ false
	
]

{ #category : #'debug and other' }
Morph >> defineTempCommand [
	"To use this, comment out what's below here, and substitute your own code.
You will then be able to invoke it from the standard debugging menus.  If invoked from the world menu, you'll always get it invoked on behalf of the world, but if invoked from an individual morph's meta-menu, it will be invoked on behalf of that individual morph.

Note that you can indeed reimplement tempCommand in an individual morph's class if you wish"

	ToolSet browse: Morph
		selector: #tempCommand
]

{ #category : #'submorphs-add\/remove' }
Morph >> delete [
	"Remove the receiver as a submorph of its owner and make its 
	new owner be nil."
	| oldWorld |
	self removeHalo.
	(oldWorld := self world) ifNotNil: [
		self disableSubmorphFocusForHand: self activeHand.
		self activeHand
	  		releaseKeyboardFocus: self;
			releaseMouseFocus: self].
	owner ifNotNil: [
		self privateDelete. "remove from world"
		self player ifNotNil: [:player |
			oldWorld ifNotNil: [
				player noteDeletionOf: self fromWorld: oldWorld]]].
]

{ #category : #'debug and other' }
Morph >> deleteAnyMouseActionIndicators [

	self changed.
	(self valueOfProperty: #mouseActionIndicatorMorphs ifAbsent: [#()]) do: [ :each |
		each deleteWithSiblings		"one is probably enough, but be safe"
	].
	self removeProperty: #mouseActionIndicatorMorphs.
	self hasRolloverBorder: false.
	self removeProperty: #rolloverWidth.
	self removeProperty: #rolloverColor.
	self layoutChanged.
	self changed.


]

{ #category : #'halos and balloon help' }
Morph >> deleteBalloon [
	"If I am showing a balloon, delete it."
	| w |
	w := self world ifNil:[^self].
	w deleteBalloonTarget: self.
]

{ #category : #'submorphs-add\/remove' }
Morph >> deleteDockingBars [
	"Delete the receiver's docking bars"
	self dockingBars
		do: [:each | each delete]
]

{ #category : #'submorphs-add\/remove' }
Morph >> deleteSubmorphsWithProperty: aSymbol [
	submorphs copy do:
		[:m | (m hasProperty: aSymbol) ifTrue: [m delete]]
]

{ #category : #'submorphs-add\/remove' }
Morph >> deleteUnlessHasFocus [
	"Runs on a step timer because we cannot be guaranteed to get focus change events."
	(self currentHand keyboardFocus ~= self and: [ self isInWorld ]) ifTrue:
		[ self
			 stopSteppingSelector: #deleteUnlessHasFocus ;
			 delete ]
]

{ #category : #classification }
Morph >> demandsBoolean [
	"Answer whether the receiver will only accept a drop if it is boolean-valued.  Particular to tile-scripting."

	^ self hasProperty: #demandsBoolean
]

{ #category : #thumbnail }
Morph >> demandsThumbnailing [
	"Answer whether the receiver, if in a thumbnailable parts bin, wants to be thumbnailed whether or not size requires it"

	^ false
]

{ #category : #'dropping\/grabbing' }
Morph >> disableDragNDrop [
	self enableDragNDrop: false
]

{ #category : #'layout-properties' }
Morph >> disableLayout [
	"Layout specific. Disable laying out the receiver in a layout"
	| props |
	props := self layoutProperties.
	^props ifNil:[false] ifNotNil:[props disableLayout].
]

{ #category : #'layout-properties' }
Morph >> disableLayout: aBool [
	"Layout specific. Disable laying out the receiver in a layout"

	self fullBounds; layoutChanged.
	self assureLayoutProperties disableLayout: aBool.
	self fullBounds; layoutChanged; changed.
]

{ #category : #dispatching }
Morph >> disableSubmorphFocusForHand: aHandMorph [
	"Check whether this morph or any of its submorph has the Genie focus.
	If yes, disable it."

]

{ #category : #'layout-properties' }
Morph >> disableTableLayout [
	"Layout specific. Disable laying out the receiver in table layout"
	| props |
	props := self layoutProperties.
	^props ifNil:[false] ifNotNil:[props disableTableLayout].
]

{ #category : #'layout-properties' }
Morph >> disableTableLayout: aBool [
	"Layout specific. Disable laying out the receiver in table layout"
	
	self fullBounds; layoutChanged.
	self assureLayoutProperties disableTableLayout: aBool.
	self fullBounds; layoutChanged; changed.
]

{ #category : #'meta-actions' }
Morph >> dismissMorph [
	"This is called from an explicit halo destroy/delete action.
	So first disconnect all constraints to keep the graph up to date."

	(self respondsTo: #disconnectAllConstraints) "Connectors package"
		ifTrue: [ self perform: #disconnectAllConstraints ].
	(self respondsTo: #releaseGraphModels) "CGPrereqs package (Connectors)"
		ifTrue: [ self perform: #releaseGraphModels ].
	self world ifNotNil: 
			[:w |  w abandonAllHalos; stopStepping: self].
	self delete
]

{ #category : #'meta-actions' }
Morph >> dismissMorph: evt [
	self dismissMorph
]

{ #category : #'submorphs-add\/remove' }
Morph >> dismissViaHalo [
	"The user has clicked in the delete halo-handle.  This provides a hook in case some concomitant action should be taken, or if the particular morph is not one which should be put in the trash can, for example."

	| cmd |
	self setProperty: #lastPosition toValue: self positionInWorld.
	self dismissMorph.
	TrashCanMorph preserveTrash ifTrue: [ 
		TrashCanMorph slideDismissalsToTrash
			ifTrue:[self slideToTrash: nil]
			ifFalse:[TrashCanMorph moveToTrash: self].
	].

	cmd := Command new cmdWording: 'dismiss ' translated, self externalName.
	cmd undoTarget: Project current world selector: #reintroduceIntoWorld: argument: self.
	cmd redoTarget: Project current world selector: #onceAgainDismiss: argument: self.
	Project current world rememberCommand: cmd.
]

{ #category : #button }
Morph >> doButtonAction [
	"If the receiver has a button-action defined, do it now.  The default button action of any morph is, well, to do nothing.  Note that there are several ways -- too many ways -- for morphs to have button-like actions.  This one refers not to the #mouseUpCodeToRun feature, nor does it refer to the Player-scripting mechanism.  Instead it is intended for morph classes whose very nature is to be buttons -- this method provides glue so that arbitrary buttons on the UI can be 'fired' programatticaly from user scripts"
]

{ #category : #'user interface' }
Morph >> doCancel [
	self delete
]

{ #category : #layout }
Morph >> doLayoutIn: layoutBounds [ 
	"Compute a new layout based on the given layout bounds."

	| box priorBounds |
	"0) Quick return. No children means no effect in layout policies. Use #minWidth and #minHeight to implement #shrinkWrap for morphs without submorphs."
	self hasSubmorphs ifFalse: [^ fullBounds := self outerBounds].
	
	"X.1) Prepare redraw. Testing for #bounds or #layoutBounds would be sufficient to figure out if we need an invalidation afterwards but #outerBounds is what we need for all leaf nodes so we use that"
	priorBounds := self outerBounds.

	"1) Give our children a chance to manually adjust *before* layout (cell) computation. This allows morphs to layout in their owner without having to use a layout policy."
	self submorphsDo: [:m | m ownerChanged].

	"2) Compute the new layout. This goes down the entire morph hierarchy. See #layoutInBounds: and #minExtent, which are the usual layout-policy callbacks."
	self layoutPolicy ifNotNil: [:layout |
		
		"2.1) Compute the new layout."
		self removeProperty: #doLayoutAgain.		
		layout layout: self in: layoutBounds.
		
		"2.2) Do one additional run on the layout if requested in #layoutInBounds:."
		(self hasProperty: #doLayoutAgain) ifTrue: [
			self removeProperty: #doLayoutAgain.		
			layout flushLayoutCache.
			layout layout: self in: layoutBounds].
		self assert: (self hasProperty: #doLayoutAgain) not].
		
	"3) Watch out for minimal extent and apply #shrinkWrap constraints."
	self adjustLayoutBounds.
	
	"4) Compute and set the new full bounds. IMPORTANT to finish layout computation."
	fullBounds := self privateFullBounds.
	
	"X.2) Redraw."
	box := self outerBounds.
	box = priorBounds ifFalse: [
		self invalidRect: (priorBounds quickMerge: box)].
]

{ #category : #menus }
Morph >> doMenuItem: menuString [
	| aMenu anItem aNominalEvent aHand |
	aMenu := self buildHandleMenu: (aHand := self currentHand).
	aMenu allMorphsDo: [:m | m step].  "Get wordings current"
	anItem := aMenu itemWithWording: menuString.
	anItem ifNil:
		[^ self player scriptingError: 'Menu item not found: ', menuString].
	aNominalEvent :=  MouseButtonEvent new
		setType: #mouseDown
		position: anItem bounds center
		which: 4 "red"
		buttons: 4 "red"
		hand: aHand
		stamp: nil.
	anItem invokeWithEvent: aNominalEvent
]

{ #category : #'submorphs-accessing' }
Morph >> dockingBars [
	"Answer the receiver's dockingBars"
	^ self submorphs
		select: [:each | each isDockingBar]

]

{ #category : #drawing }
Morph >> doesOwnRotation [
	"Some morphs don't want to TransformMorph to rotate their images, but we do"
	^ false
]

{ #category : #'event handling' }
Morph >> doubleClick: evt [
	"Handle a double-click event. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation does nothing.
	LC 2/14/2000 08:32 - added: EventHandler notification"

	self eventHandler ifNotNil:
		[self eventHandler doubleClick: evt fromMorph: self].
]

{ #category : #'event handling' }
Morph >> doubleClickTimeout: evt [
	"Handle a double-click timeout event. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation does nothing."

	self eventHandler ifNotNil:
		[self eventHandler doubleClickTimeout: evt fromMorph: self].
]

{ #category : #naming }
Morph >> downshiftedNameOfObjectRepresented [
	"Answer the downshiped version of the external name of the object represented"

	^ self nameOfObjectRepresented asLowercase
]

{ #category : #'dropping\/grabbing' }
Morph >> dragEnabled [
	"Get this morph's ability to add and remove morphs via drag-n-drop."
	^(self valueOfProperty: #dragEnabled) == true

]

{ #category : #'dropping\/grabbing' }
Morph >> dragEnabled: aBool [
	^self enableDrag: aBool
]

{ #category : #'dropping\/grabbing' }
Morph >> dragNDropEnabled [
	"Note: This method is only useful for dragEnabled == dropEnabled at all times"
	self separateDragAndDrop.
	^self dragEnabled and:[self dropEnabled]
]

{ #category : #'dropping\/grabbing' }
Morph >> dragSelectionColor [
	^ Color magenta
]

{ #category : #drawing }
Morph >> drawDropHighlightOn: aCanvas [

	self highlightedForDrop ifTrue: [
		self wantsRoundedCorners
			ifTrue: [aCanvas frameRoundRect: self fullBounds radius: self cornerRadius width: 1 color: self dropHighlightColor]
			ifFalse: [aCanvas frameRectangle: self fullBounds color: self dropHighlightColor]].
]

{ #category : #drawing }
Morph >> drawDropShadowOn: aCanvas [
	"Rectangular shadow with support for rounded corners."
	
	| shadowBounds |
	shadowBounds := self shadowOffset isRectangle
		ifTrue: [self bounds outsetBy: self shadowOffset]
		ifFalse: [self bounds translateBy: (self shadowOffset negated max: 0@0)].
	
	"Only redraw the shadow if the shadow area is affected."
	((aCanvas clipRect intersects: shadowBounds) and: [((self bounds insetBy: (self wantsRoundedCorners ifFalse: [0] ifTrue: [self cornerRadius])) containsRect: aCanvas clipRect) not])
		ifTrue: [
			(self hasProperty: #dropShadow)
				ifFalse: [self updateDropShadowCache].
			aCanvas
				translucentImage: (self valueOfProperty: #dropShadow)
				at: shadowBounds topLeft].
]

{ #category : #drawing }
Morph >> drawErrorOn: aCanvas [
	"The morph (or one of its submorphs) had an error in its drawing method."
	| saneBounds |
	saneBounds := bounds rounded.
	aCanvas
		frameAndFillRectangle: saneBounds
		fillColor: Color red
		borderWidth: 1
		borderColor: Color yellow.
	aCanvas line: saneBounds topLeft to: saneBounds bottomRight width: 1 color: Color yellow.
	aCanvas line: saneBounds topRight to: saneBounds bottomLeft width: 1 color: Color yellow.
]

{ #category : #drawing }
Morph >> drawKeyboardFocusIndicationOn: aCanvas [

	self wantsRoundedCorners
		ifTrue: [aCanvas frameRoundRect: self bounds radius: self cornerRadius width: self keyboardFocusWidth color: self keyboardFocusColor]
		ifFalse: [aCanvas frameRectangle: self bounds width: self keyboardFocusWidth color: self keyboardFocusColor].
]

{ #category : #drawing }
Morph >> drawMouseDownHighlightOn: aCanvas [

	self highlightedForMouseDown ifTrue: [
		self wantsRoundedCorners
			ifTrue: [aCanvas frameRoundRect: self fullBounds radius: self cornerRadius width: 1 color: self color darker darker]
			ifFalse: [aCanvas frameRectangle: self fullBounds color: self color darker darker]].
]

{ #category : #drawing }
Morph >> drawOn: aCanvas [

	self wantsRoundedCorners
		ifTrue: [aCanvas frameAndFillRoundRect: self bounds radius: self cornerRadius fillStyle: self fillStyle borderStyle: self borderStyle]
		ifFalse: [aCanvas frameAndFillRectangle: self bounds fillStyle: self fillStyle borderStyle: self borderStyle].
	

]

{ #category : #'filter streaming' }
Morph >> drawOnCanvas: aCanvas [
	^aCanvas fullDraw: self.

]

{ #category : #drawing }
Morph >> drawOverlayOn: aCanvas [
	"Draw something over all my submorphs."
	
	self drawDropHighlightOn: aCanvas.
	self drawMouseDownHighlightOn: aCanvas.

	(self indicateKeyboardFocus and: [self hasKeyboardFocus])
		ifTrue: [self drawKeyboardFocusIndicationOn: aCanvas].
]

{ #category : #drawing }
Morph >> drawRolloverBorderOn: aCanvas [ 
	| colorToUse offsetToUse myShadow newForm f |
	colorToUse := self
				valueOfProperty: #rolloverColor
				ifAbsent: [Color blue alpha: 0.5].
	offsetToUse := self
				valueOfProperty: #rolloverWidth
				ifAbsent: [10 @ 10].
	self hasRolloverBorder: false.
	myShadow := self shadowForm.
	self hasRolloverBorder: true.
	myShadow offset: 0 @ 0.
	f := ColorForm extent: myShadow extent depth: 1.
	myShadow displayOn: f.
	f colors: {Color transparent. colorToUse}.
	newForm := Form extent: offsetToUse * 2 + myShadow extent depth: 32.
	(WarpBlt toForm: newForm) sourceForm: f;
		 cellSize: 1;
		 combinationRule: 3;
		 copyQuad: f boundingBox innerCorners toRect: newForm boundingBox.
		
	self flag: #roundedCorners. "mt: Check for #wantsRoundedCorners and call appropriate things in canvas."
	aCanvas
		translateBy: offsetToUse negated
		during: [:shadowCanvas | 
			shadowCanvas shadowColor: colorToUse.
			shadowCanvas paintImage: newForm at: self position]
]

{ #category : #drawing }
Morph >> drawSubmorphsOn: aCanvas [ 
	"Display submorphs back to front"

	| drawBlock |
	submorphs isEmpty ifTrue: [^self].
	drawBlock := [:canvas | submorphs reverseDo: [:m | canvas fullDrawMorph: m]].
	self clipSubmorphs 
		ifTrue: [aCanvas clipBy: self clippingBounds during: drawBlock]
		ifFalse: [drawBlock value: aCanvas]
]

{ #category : #'dropping\/grabbing' }
Morph >> dropEnabled [
	"Get this morph's ability to add and remove morphs via drag-n-drop."
	^(self valueOfProperty: #dropEnabled) == true

]

{ #category : #'dropping\/grabbing' }
Morph >> dropEnabled: aBool [
	^self enableDrop: aBool
]

{ #category : #'event handling' }
Morph >> dropFiles: anEvent [
	"Handle a number of files dropped from the OS"

]

{ #category : #'dropping\/grabbing' }
Morph >> dropHighlightColor [
	^ Color blue
]

{ #category : #'dropping\/grabbing' }
Morph >> dropSuccessColor [
	^ Color blue
]

{ #category : #copying }
Morph >> duplicate [
	"Make and return a duplicate of the receiver"

	| newMorph aName w aPlayer topRend |
	((topRend := self topRendererOrSelf) ~~ self) ifTrue: [^ topRend duplicate].

	self okayToDuplicate ifFalse: [^ self].
	aName := (w := self world) ifNotNil:
		[w nameForCopyIfAlreadyNamed: self].
	newMorph := self veryDeepCopy.
	aName ifNotNil: [newMorph setNameTo: aName].

	newMorph arrangeToStartStepping.
	newMorph privateOwner: nil. "no longer in world"
	newMorph isPartsDonor: false. "no longer parts donor"
	(aPlayer := newMorph player) belongsToUniClass ifTrue:
		[aPlayer class bringScriptsUpToDate].
	aPlayer ifNotNil: [self currentWorld presenter flushPlayerListCache].
	^ newMorph
]

{ #category : #'meta-actions' }
Morph >> duplicateMorph: evt [
	"Make and return a duplicate of the receiver's argument"
	| dup |
	dup := self duplicate.
	evt hand grabMorph: dup from: owner. "duplicate was ownerless so use #grabMorph:from: here"
	^dup
]

{ #category : #copying }
Morph >> duplicateMorphCollection: aCollection [
	"Make and return a duplicate of the receiver"

	| newCollection names |

	names := aCollection collect: [ :ea | | newMorph w |
		(w := ea world) ifNotNil:
			[w nameForCopyIfAlreadyNamed: ea].
	].

	newCollection := aCollection veryDeepCopy.

	newCollection with: names do: [ :newMorph :name |
		name ifNotNil: [ newMorph setNameTo: name ].
		newMorph arrangeToStartStepping.
		newMorph privateOwner: nil. "no longer in world"
		newMorph isPartsDonor: false. "no longer parts donor"
	].

	^newCollection
]

{ #category : #'meta-actions' }
Morph >> duplicateMorphImage: evt [ 
	"Make and return a imageMorph of the receiver's argument imageForm"
	| dup |
	dup := self asSnapshotThumbnail withSnapshotBorder.
	dup bounds: self bounds.
	evt hand grabMorph: dup from: owner.
	"duplicate was ownerless so use #grabMorph:from: here"
	^ dup
]

{ #category : #'WiW support' }
Morph >> eToyRejectDropMorph: morphToDrop event: evt [

	| tm am |

	tm := TextMorph new 
		beAllFont: ((TextStyle named: Preferences standardEToysFont familyName) fontOfSize: 24);
		contents: 'GOT IT!'.
	(am := AlignmentMorph new)
		color: Color yellow;
		layoutInset: 10;
		useRoundedCorners;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		addMorph: tm;
		fullBounds;
		position: (self bounds center - (am extent // 2));
		openInWorld: self world.
	SoundService default playSoundNamed: 'yum' ifAbsentReadFrom: 'yum.aif'.
	morphToDrop rejectDropMorphEvent: evt.		"send it back where it came from"
	am delete

]

{ #category : #'halos and balloon help' }
Morph >> editBalloonHelpContent: aString [
	| reply |
	reply := UIManager default
		multiLineRequest: 'Edit the balloon help text for ' translated, self externalName
		centerAt: Sensor cursorPoint
		initialAnswer: (aString ifNil: [self noHelpString] ifNotNil: [aString])
		answerHeight: 200.
	reply ifNil: [^ self].  "User cancelled out of the dialog"
	(reply isEmpty or: [reply asString = self noHelpString])
		ifTrue: [self setBalloonText: nil]
		ifFalse: [self setBalloonText: reply]
]

{ #category : #'halos and balloon help' }
Morph >> editBalloonHelpText [
	"Modify the receiver's balloon help text."

	self editBalloonHelpContent: self balloonText
]

{ #category : #'e-toy support' }
Morph >> embedInWindow [

	| window worldToUse |

	worldToUse := self world.		"I'm assuming we are already in a world"
	window := (SystemWindow labelled: self defaultLabelForInspector) model: nil.
	window bounds: ((self position - ((0@window labelHeight) + window borderWidth))
						corner: self bottomRight + window borderWidth).
	window addMorph: self frame: (0@0 extent: 1@1).
	window updatePaneColors.
	worldToUse addMorph: window.
	window beKeyWindow.
]

{ #category : #'meta-actions' }
Morph >> embedInto: evt [
	"Embed the receiver into some other morph"
	|  target morphs |
	morphs := self potentialEmbeddingTargets.
	target := UIManager default 
		chooseFrom: (morphs collect:[:m| m knownName ifNil:[m class name asString]])
		values: self potentialEmbeddingTargets
		title: ('Place ', self externalName, ' in...').
	target ifNil:[^self].
	target addMorphFrontFromWorldPosition: self
]

{ #category : #'e-toy support' }
Morph >> embeddedInMorphicWindowLabeled: labelString [
	| window |
	window := (SystemWindow labelled: labelString) model: nil.
	window setStripeColorsFrom: Color white.
	window addMorph: self frame: (0@0 extent: 1@1).
	^ window
]

{ #category : #'dropping\/grabbing' }
Morph >> enableDrag: aBoolean [
	self setProperty: #dragEnabled toValue: aBoolean
]

{ #category : #'dropping\/grabbing' }
Morph >> enableDragNDrop [
	self enableDragNDrop: true
]

{ #category : #'dropping\/grabbing' }
Morph >> enableDragNDrop: aBoolean [
	"Set both properties at once"
	self separateDragAndDrop.
	self enableDrag: aBoolean.
	self enableDrop: aBoolean.
]

{ #category : #'dropping\/grabbing' }
Morph >> enableDrop: aBoolean [
	self setProperty: #dropEnabled toValue: aBoolean
]

{ #category : #'events-filtering-bubbling' }
Morph >> eventBubbleFilters [
	^ self valueOfProperty: #eventBubbleFilters
]

{ #category : #'events-filtering-bubbling' }
Morph >> eventBubbleFilters: anArrayOrNil [
	^ self setProperty: #eventBubbleFilters toValue: anArrayOrNil
]

{ #category : #'events-filtering-capturing' }
Morph >> eventCaptureFilters [
	^ self valueOfProperty: #eventCaptureFilters
]

{ #category : #'events-filtering-capturing' }
Morph >> eventCaptureFilters: anArrayOrNil [
	^ self setProperty: #eventCaptureFilters toValue: anArrayOrNil
]

{ #category : #'events-filtering' }
Morph >> eventFilterDocumentation [
	"
	Event filters represent a mechanism to intercept events *before* morphs get the chance to handle them. So, there are still event handlers, which are usually the morphs themselves. However, morphs can also be their own event filters. One application of event filters is keyboard shortcuts. Such filters should invoke the shortcut but ignore the original event to *be sure* that no other morph ever handles that. System windows have window shortcuts. The world has world shortcuts.
	
	When user input events are dispatched, there is a capturing phase and a bubbling phase. This dispatching behavior is described in MorphicEventDispatcher. Capturing means that we are looking for the handler (resp. morph) to handle the event, traversing submorph hierarchy. Bubbling means that once a morph handled the event, all owners get also the chance to handle that event *if* they honor the #wasHandled flag.. Event filters can be attached to any morph for the capturing or the bubbling phase. See it as code that is execute before/after the event handlers.
	
	Event filters are objects that implement #filterEvent:for:. All objects understand that message but do nothing. There is a PluggableEventFilter for a more dynamic programming approach.
	
	Morphic hands have specific focus holders. There is a keyboard focus and a mouse focus. For example, text morphs are good candidates for holders of the keyboard focus. Both foci bypass the traditional event capturing phase, which usually start at the world morph. However, capture filters are also apply before handling the focus event. See Morph >> #handleFocusEvent: for that. Note that after handling the focus event, events do bubble along their owners, which usually do nothing if they honor the #wasHandled flag, and hence all bubble event filters are executed unless events get ignored. Thus, we mimick the behavior of MorphicEventDispatcher in #handleFocusEvent:.
	
	There are event filters for all kinds of events, filters for keyboard events, and filters for mouse events. You can always install generic event filters and then check for the particular event type in that filter. However, it is good style to not install keyboard event filters as generic event filters. It makes code more readable.
	
	You can install global event capture filters in instances of HandMorph. For example,  Project current world firstHand provides access to the project's world's hand. Avoid using globals such as ActiveHand or ActiveWorld. BEWARE that global event filters can have unexpected effects and may be difficult to debug. Note that you cannot install global event bubble filters in the HandMorph. You have to install such a filter in the world because hands are not part of the event bubbling phase.
	
	For an example of keyboard capturing filters see SystemWindow >> #addKeyboardShortcuts and SystemWindow >> #filterEvent:for:. You can also take a look at: PasteUpMorph >> #addKeyboardShortcuts and PasteUpMorph >> #filterEvent:for: and DockingBarMorph >> #filterEvent:for: for a more elaborate example.
	
	Event filters include all the behavior of event listeners. An event listener converted to an event filter would be a global event capture filter that sents a copy of the event to itself:
	
	| listenerFilter someMorph |
	someMorph := Morph new.
	listenerFilter := PluggableEventFilter on: [:event :target | event copy sentTo: someMorph. event].
	Project current world activeHand addEventCaptureFilter: listenerFilter.
	
	Instead of:

	| someMorph |
	someMorph := Morph new.
	Project current world activeHand addEventListener: someMorph.
	
	The filter version might look more complicated than the traditional listener version but note that it is quite rare to install global event filters. The example for keyboard shortcuts reflects the simplicity of event filters."
]

{ #category : #accessing }
Morph >> eventHandler [
	"answer the receiver's eventHandler"
	^ extension ifNotNil: [extension eventHandler] 
]

{ #category : #accessing }
Morph >> eventHandler: anEventHandler [ 
	"Note that morphs can share eventHandlers and all is OK. "
	self assureExtension eventHandler: anEventHandler
]

{ #category : #drawing }
Morph >> expandFullBoundsForDropShadow: aRectangle [
	"Return an expanded rectangle for an eventual drop shadow"
	| delta box |

	self shadowOffset isRectangle
		ifTrue: [^ aRectangle outsetBy: self shadowOffset].

	box := aRectangle.
	delta := self shadowOffset.
	box := delta x >= 0 
		ifTrue:[box right: aRectangle right + delta x]
		ifFalse:[box left: aRectangle left + delta x].
	box := delta y >= 0
		ifTrue:[box bottom: aRectangle bottom + delta y]
		ifFalse:[box top: aRectangle top + delta y].
	^box
]

{ #category : #drawing }
Morph >> expandFullBoundsForRolloverBorder: aRectangle [
	| delta |
	delta := self valueOfProperty: #rolloverWidth ifAbsent: [10@10].
	^aRectangle expandBy: delta.


]

{ #category : #menus }
Morph >> exploreInMorphic [

	ToolSet explore: self.
]

{ #category : #menus }
Morph >> exploreInMorphic: evt [
	
	ToolSet explore: self.
]

{ #category : #menus }
Morph >> exportAsBMP [
	| fName |
	fName := UIManager default saveFilenameRequest:'Please enter the name' translated initialAnswer: self externalName,'.bmp'.
	fName ifNil:[^self].
	self exportAsBMPNamed: fName
]

{ #category : #menus }
Morph >> exportAsBMPNamed: aString [ 
	self imageForm writeBMPfileNamed: aString
]

{ #category : #menus }
Morph >> exportAsGIF [
	| fName |
	fName := UIManager default saveFilenameRequest:'Please enter the name' translated initialAnswer: self externalName,'.gif'.
	fName ifNil:[^self].
	self exportAsGIFNamed: fName
]

{ #category : #menus }
Morph >> exportAsGIFNamed: aString [ 
	GIFReadWriter
		putForm: self imageForm
		onFileNamed: aString
]

{ #category : #menus }
Morph >> exportAsJPEG [
	| fName |
	fName := UIManager default saveFilenameRequest: 'Please enter the name' translated initialAnswer: self externalName,'.jpeg'.
	fName ifNil: [^ self].
	self exportAsJPEGNamed: fName
]

{ #category : #menus }
Morph >> exportAsJPEGNamed: aString [ 
	self imageForm writeJPEGfileNamed: aString
]

{ #category : #menus }
Morph >> exportAsPNG [
	| fName |
	fName := UIManager default saveFilenameRequest:'Please enter the name' translated initialAnswer: self externalName,'.png'.
	fName ifNil:[^self].
	self exportAsPNGNamed: fName
]

{ #category : #menus }
Morph >> exportAsPNGNamed: aString [ 
	PNGReadWriter
		putForm: self imageForm
		onFileNamed: aString
]

{ #category : #'accessing - extension' }
Morph >> extension [
	"answer the recevier's extension"
	^ extension
]

{ #category : #geometry }
Morph >> extent [

	^ bounds extent
]

{ #category : #geometry }
Morph >> extent: aPoint [

	(bounds extent closeTo: aPoint) ifTrue: [^ self].
	self changed.
	bounds := (bounds topLeft extent: aPoint) rounded.
	self removeProperty: #dropShadow.
	self layoutChanged.
	self changed.

]

{ #category : #viewer }
Morph >> externalName [
	^ self knownName ifNil: [self innocuousName]
]

{ #category : #'visual properties' }
Morph >> fillStyle [
	"Return the current fillStyle of the receiver."
	^ self
		valueOfProperty: #fillStyle
		ifAbsent: ["Workaround already converted morphs"
			color
				ifNil: [self defaultColor]]
]

{ #category : #'visual properties' }
Morph >> fillStyle: aFillStyle [
	"Set the current fillStyle of the receiver."
	self setProperty: #fillStyle toValue: aFillStyle.
	"Workaround for Morphs not yet converted"
	color := aFillStyle asColor.
	self borderStyle trackColorFrom: self.
	self changed.
]

{ #category : #'visual properties' }
Morph >> fillWithRamp: rampSpecsOrColor oriented: aRatio [ 
	rampSpecsOrColor isColor
		ifTrue: [self color: rampSpecsOrColor".
			self borderColor: rampSpecsOrColor muchDarker"]
		ifFalse: [| fill | 
			fill := GradientFillStyle ramp: rampSpecsOrColor.
			fill origin: self bounds topLeft.
			fill direction: (self bounds extent * aRatio) truncated.
			fill radial: false.
			self fillStyle: fill.
			self borderColor: (rampSpecsOrColor first value mixed: 0.5 with: rampSpecsOrColor last value) muchDarker]
]

{ #category : #'submorphs-accessing' }
Morph >> findA: aClass [
	"Return the first submorph of the receiver that is descended from the given class. Return nil if there is no such submorph. Clients of this code should always check for a nil return value so that the code will be robust if the user takes the morph apart."

	^self submorphs
		detect: [:p | p isKindOf: aClass]
		ifNone: [nil]
]

{ #category : #'submorphs-accessing' }
Morph >> findDeepSubmorphThat: block1 ifAbsent: block2 [ 
	self
		allMorphsDo: [:m | (block1 value: m)
				== true ifTrue: [^ m]].
	^ block2 value
]

{ #category : #'submorphs-accessing' }
Morph >> findDeeplyA: aClass [
	"Return a morph in the submorph tree of the receiver that is descended from the given class. Return nil if there is no such morph. Clients of this code should always check for a nil return value so that the code will be robust if the user takes the morph apart."

	^ (self allMorphs copyWithout: self)
		detect: [:p | p isKindOf: aClass]
		ifNone: [nil]
]

{ #category : #'submorphs-accessing' }
Morph >> findSubmorphBinary: aBlock [
	"Use binary search for finding a specific submorph of the receiver. Caller must be certain that the ordering holds for the submorphs."
	^submorphs findBinary: aBlock ifNone:[nil].
]

{ #category : #'event handling' }
Morph >> firstClickTimedOut: evt [
	"Useful for double-click candidates who want to know whether or not the click is a single or double. In this case, ignore the #click: and wait for either this or #doubleClick:"


]

{ #category : #structure }
Morph >> firstOwnerSuchThat: conditionBlock [

	self allOwnersDo: [:m | (conditionBlock value: m) ifTrue: [^ m]].
	^ nil

]

{ #category : #'submorphs-accessing' }
Morph >> firstSubmorph [
	^submorphs first
]

{ #category : #macpal }
Morph >> flash [
	| originalColor |
	originalColor := self color.
	[ self color:
		(originalColor
			ifNil: [ Color black ]
			ifNotNil: [( (originalColor alpha: 1) adjustSaturation: 0.8 brightness: 0) negated ]) ]
		ensure:
			[ self refreshWorld.
			self color: originalColor ]
]

{ #category : #drawing }
Morph >> flashBounds [
	"Flash the receiver's bounds  -- does not use the receiver's color, thus works with StringMorphs and SketchMorphs, etc., for which #flash is useless.  No senders initially, but useful to send this from a debugger or inspector"

	5 timesRepeat:
		[Display flash: self boundsInWorld  andWait: 120]
]

{ #category : #'dropping\/grabbing' }
Morph >> formerOwner [
	^self valueOfProperty: #formerOwner
]

{ #category : #'dropping\/grabbing' }
Morph >> formerOwner: aMorphOrNil [ 
	aMorphOrNil 
		ifNil: [self removeProperty: #formerOwner]
		ifNotNil: [self setProperty: #formerOwner toValue: aMorphOrNil]
]

{ #category : #'dropping\/grabbing' }
Morph >> formerPosition [
	^self valueOfProperty: #formerPosition
]

{ #category : #'dropping\/grabbing' }
Morph >> formerPosition: formerPosition [ 
	formerPosition 
		ifNil: [self removeProperty: #formerPosition]
		ifNotNil: [self setProperty: #formerPosition toValue: formerPosition]
]

{ #category : #'rotate scale and flex' }
Morph >> forwardDirection [
	"Return the receiver's offset to distinguish #heading from #rotationDegrees."
	
	^ self valueOfProperty: #forwardDirection ifAbsent: [0.0]
]

{ #category : #'rotate scale and flex' }
Morph >> forwardDirection: newDirection [

	self setProperty: #forwardDirection toValue: newDirection.
]

{ #category : #layout }
Morph >> fullBounds [
	"Return the bounding box of the receiver and all its children. Recompute the layout if necessary."
	fullBounds ifNotNil:[^fullBounds].
	"Errors at this point can be critical so make sure we catch 'em all right"
	[self doLayoutIn: self layoutBounds] on: Error, Warning, Halt do:[:ex|
		"This should do it unless you don't screw up the bounds"
		fullBounds := bounds.
		ex pass].
	^fullBounds
]

{ #category : #'geometry - local\/global' }
Morph >> fullBoundsInWorld [
	^self bounds: self fullBounds in: self world
]

{ #category : #'geometry testing' }
Morph >> fullContainsPoint: aPoint [

	(self fullBounds containsPoint: aPoint) ifFalse: [^ false].  "quick elimination"
	(self containsPoint: aPoint) ifTrue: [^ true].  "quick acceptance"
	submorphs do: [:m | (m fullContainsPoint: aPoint) ifTrue: [^ true]].
	^ false

]

{ #category : #copying }
Morph >> fullCopy [
	"Deprecated, but maintained for backward compatibility with existing code (no senders in the base 3.0 image).   Calls are revectored to #veryDeepCopy, but note that #veryDeepCopy does not do exactly the same thing that the original #fullCopy did, so beware!"

	^ self veryDeepCopy
]

{ #category : #drawing }
Morph >> fullDrawOn: aCanvas [
	"Draw the full Morphic structure on the given Canvas"

	self visible ifFalse: [^ self].
	(aCanvas isVisible: self fullBounds) ifFalse:[^self].
	(self hasProperty: #errorOnDraw) ifTrue:[^self drawErrorOn: aCanvas].
	"Note: At some point we should generalize this into some sort of 
	multi-canvas so that we can cross-optimize some drawing operations."

	"Pass 1: Draw eventual drop-shadow"
	self hasDropShadow ifTrue: [self drawDropShadowOn: aCanvas].
	(self hasRolloverBorder and: [(aCanvas seesNothingOutside: self bounds) not])
		ifTrue: [self drawRolloverBorderOn: aCanvas].

	"Pass 2: Draw receiver itself"
	(aCanvas isVisible: self bounds) ifTrue:[aCanvas drawMorph: self].
	self drawSubmorphsOn: aCanvas.
	self drawOverlayOn: aCanvas.
]

{ #category : #caching }
Morph >> fullLoadCachedState [
	"Load the cached state of the receiver and its full submorph tree."

	self allMorphsDo: [:m | m loadCachedState].

]

{ #category : #printing }
Morph >> fullPrintOn: aStream [

	aStream nextPutAll: self class name , ' newBounds: (';
		print: bounds;
		nextPutAll: ') color: ' , (self colorString: color)
]

{ #category : #caching }
Morph >> fullReleaseCachedState [
	"Release the cached state of the receiver and its full submorph tree."

	self allMorphsDo: [:m | m releaseCachedState].

]

{ #category : #'e-toy support' }
Morph >> getNumericValue [
	"Only certain kinds of morphs know how to deal with this frontally; here we provide support for a numeric property of any morph"

	^ self valueOfProperty: #numericValue ifAbsent: [0]
]

{ #category : #'geometry - local\/global' }
Morph >> globalPointToLocal: aPoint [
	^self point: aPoint from: nil
]

{ #category : #'submorphs-add\/remove' }
Morph >> goBehind [
	"Move the receiver to bottom z-order."

	| topRend |
	topRend := self topRendererOrSelf.
	topRend owner ifNotNil:
		[:own | own addMorphNearBack: topRend]

]

{ #category : #'meta-actions' }
Morph >> grabMorph: evt [

	evt hand grabMorph: self
]

{ #category : #'dropping\/grabbing' }
Morph >> grabTransform [
	"Return the transform for the receiver which should be applied during grabbing"
	^owner ifNil:[IdentityTransform new] ifNotNil:[owner grabTransform]
]

{ #category : #'e-toy support' }
Morph >> gridFormOrigin: origin grid: smallGrid background: backColor line: lineColor [

	| bigGrid gridForm gridOrigin |
	gridOrigin := origin \\ smallGrid.
	bigGrid := (smallGrid asPoint x) @ (smallGrid asPoint y).
	gridForm := Form extent: bigGrid depth: Display depth.
	backColor ifNotNil: [gridForm fillWithColor: backColor].
	gridOrigin x to: gridForm width by: smallGrid x do:
		[:x | gridForm fill: (x@0 extent: 1@gridForm height) fillColor: lineColor].
	gridOrigin y to: gridForm height by: smallGrid y do:
		[:y | gridForm fill: (0@y extent: gridForm width@1) fillColor: lineColor].
	^ InfiniteForm with: gridForm

]

{ #category : #'geometry - misc' }
Morph >> gridPoint: ungriddedPoint [

	^ ungriddedPoint
]

{ #category : #'geometry - misc' }
Morph >> griddedPoint: ungriddedPoint [

	| griddingContext |
	self flag: #arNote. "Used by event handling - should transform to pasteUp for gridding"
	(griddingContext := self pasteUpMorph) ifNil: [^ ungriddedPoint].
	^ griddingContext gridPoint: ungriddedPoint
]

{ #category : #'layout-properties' }
Morph >> hResizing [
	"Layout specific. This property describes how the receiver should be resized with respect to its owner and its children. Possible values are:
		#rigid			-	do not resize the receiver
		#spaceFill		-	resize to fill owner's available space
		#shrinkWrap	-	resize to fit children
	"
	| props |
	props := self layoutProperties.
	^props ifNil:[#rigid] ifNotNil:[props hResizing].
]

{ #category : #'layout-properties' }
Morph >> hResizing: aSymbol [
	"Layout specific. This property describes how the receiver should be resized with respect to its owner and its children. Possible values are:
		#rigid			-	do not resize the receiver
		#spaceFill		-	resize to fill owner's available space
		#shrinkWrap	- resize to fit children
	"
	self checkResizingProperty: aSymbol.
	self assureLayoutProperties hResizing: aSymbol.
	self layoutChanged.

]

{ #category : #'layout-properties' }
Morph >> hResizingString: aSymbol [
	^self layoutMenuPropertyString: aSymbol from: self hResizing
]

{ #category : #'halos and balloon help' }
Morph >> halo [

	(self outermostWorldMorph ifNil: [^nil]) haloMorphs do: [:h | h target == self ifTrue: [^ h]].
	^ nil
]

{ #category : #'halos and balloon help' }
Morph >> haloClass [
	"Answer the name of the desired kind of HaloMorph to launch on behalf of the receiver"

	^ #HaloMorph

]

{ #category : #'halos and balloon help' }
Morph >> haloDelayTime [
	"Return the number of milliseconds before a halo should be put up on the receiver. The halo will only be put up if the receiver responds to #wantsHalo by returning true."
	^800
]

{ #category : #'e-toy support' }
Morph >> handUserASibling [
	"Make and hand the user a sibling instance.  Force the creation of a uniclass at this point if one does not already exist for the receiver."

	| topRend |
	topRend := self topRendererOrSelf.
	topRend couldMakeSibling ifFalse: [^ Beeper beep].

	topRend assuredPlayer assureUniClass.
	(topRend makeSiblings: 1) first openInHand
]

{ #category : #'events-processing' }
Morph >> handleDropFiles: anEvent [
	"Handle a drop from the OS."
	anEvent wasHandled ifTrue:[^self]. "not interested"
	(self wantsDropFiles: anEvent) ifFalse:[^self].
	anEvent wasHandled: true.
	self dropFiles: anEvent.

]

{ #category : #'events-processing' }
Morph >> handleDropMorph: anEvent [
	"Handle a dropping morph."
	| aMorph localPt |
	anEvent wasHandled ifTrue: [^ self]. "Not interested"
	aMorph := anEvent contents.
	"Do a symmetric check if both morphs like each other"
	((self wantsDroppedMorph: aMorph event: anEvent)	"I want her"
		and: [aMorph wantsToBeDroppedInto: self])		"she wants me"
		ifFalse: [aMorph removeProperty: #undoGrabCommand.
				^ self].
	anEvent wasHandled: true.
	"Transform the morph into the receiver's coordinate frame. This is currently incomplete since it only takes the offset into account where it really should take the entire transform."
	localPt := (self transformedFrom: anEvent hand world) "full transform down"
				globalPointToLocal: aMorph referencePosition.
	aMorph referencePosition: localPt.
	self acceptDroppingMorph: aMorph event: anEvent.
	aMorph justDroppedInto: self event: anEvent.

]

{ #category : #'events-processing' }
Morph >> handleEvent: anEvent [
	"Apply event filters and then handle the resulting event. We have to return the event to chain filters."

	| filteredEvent |
	filteredEvent := self sendFilterEventBubble: anEvent for: self.
	filteredEvent wasIgnored ifFalse: [filteredEvent sentTo: self].
	^ filteredEvent
]

{ #category : #'events-processing' }
Morph >> handleFocusEvent: anEvent [
	"Handle the given event. This message is sent if the receiver currently has the focus and is therefore receiving events directly from some hand. However, it might already have been handled due to overrides in #processFocusEvent:using:. We might want to get rid of this call-back in the future..."
	
	^ anEvent wasHandled
		ifTrue: [anEvent]
		ifFalse: [self handleEvent: anEvent]
]

{ #category : #'events-processing' }
Morph >> handleKeyDown: anEvent [
	"System level event handling."
	anEvent wasHandled ifTrue: [^ self].
	(self handlesKeyboard: anEvent) ifFalse: [^ self].
	(anEvent hand keyboardFocus ~~ self
		and: [self handlesKeyboardOnlyOnFocus])
			ifTrue: [^ self].
	
	anEvent wasHandled: true.
	^ self keyDown: anEvent
]

{ #category : #'events-processing' }
Morph >> handleKeyUp: anEvent [
	"System level event handling."
	anEvent wasHandled ifTrue: [^ self].
	(self handlesKeyboard: anEvent) ifFalse: [^ self].
	(anEvent hand keyboardFocus ~~ self
		and: [self handlesKeyboardOnlyOnFocus])
			ifTrue: [^ self].
	
	anEvent wasHandled: true.
	^ self keyUp: anEvent
]

{ #category : #'events-processing' }
Morph >> handleKeystroke: anEvent [ 
	"System level event handling. Has support for automatically grabbing the keyboard focus considering the keyboard focus delegate. See #newKeyboardFocus:"
	
	| handler |
	anEvent wasHandled ifTrue: [^ self].
	(self handlesKeyboard: anEvent) ifFalse: [^ self].
	(anEvent hand keyboardFocus ~~ self
		and: [self handlesKeyboardOnlyOnFocus])
			ifTrue: [^ self].
	
	handler := self wantsKeyboardFocus
		ifFalse: [self]
		ifTrue: [(anEvent hand newKeyboardFocus: self) ifNil: [self]].
	anEvent handler: handler.
	
	anEvent wasHandled: true.
	^ handler keyStroke: anEvent
]

{ #category : #'events-processing' }
Morph >> handleListenEvent: anEvent [
	"Handle the given event. This message is sent if the receiver is a registered listener for the given event."
	^anEvent sentTo: self.
]

{ #category : #'events-processing' }
Morph >> handleMouseDown: anEvent [
	"System level event handling."
	anEvent wasHandled ifTrue:[^self]. "not interested"
	anEvent hand removePendingBalloonFor: self.
	anEvent hand removePendingHaloFor: self.
	anEvent wasHandled: true.

	"Make me modal during mouse transitions"
	anEvent hand newMouseFocus: self event: anEvent.
	
	"this mouse down could be the start of a gesture, or the end of a gesture focus"
	(self isGestureStart: anEvent)
		ifTrue: [^ self gestureStart: anEvent].

	self mouseDown: anEvent.

	(self handlesMouseStillDown: anEvent) ifTrue:[
		self startStepping: #handleMouseStillDown: 
			at: Time millisecondClockValue + self mouseStillDownThreshold
			arguments: {anEvent copy resetHandlerFields}
			stepTime: self mouseStillDownStepRate ].

]

{ #category : #'events-processing' }
Morph >> handleMouseEnter: anEvent [
	"System level event handling."
	(anEvent isDraggingEvent) ifTrue:[
		(self handlesMouseOverDragging: anEvent) ifTrue:[
			anEvent wasHandled: true.
			self mouseEnterDragging: anEvent].
		^self].
	self wantsHalo "If receiver wants halo and balloon, trigger balloon after halo"
		ifTrue:[anEvent hand triggerHaloFor: self after: self haloDelayTime]
		ifFalse:[self wantsBalloon
			ifTrue:[anEvent hand triggerBalloonFor: self after: self balloonHelpDelayTime]].
	(self handlesMouseOver: anEvent) ifTrue:[
		anEvent wasHandled: true.
		self mouseEnter: anEvent.
	].
]

{ #category : #'events-processing' }
Morph >> handleMouseLeave: anEvent [
	"System level event handling."
	anEvent hand removePendingBalloonFor: self.
	anEvent hand removePendingHaloFor: self.
	anEvent isDraggingEvent ifTrue:[
		(self handlesMouseOverDragging: anEvent) ifTrue:[
			anEvent wasHandled: true.
			self mouseLeaveDragging: anEvent].
		^self].
	(self handlesMouseOver: anEvent) ifTrue:[
		anEvent wasHandled: true.
		self mouseLeave: anEvent.
	].

]

{ #category : #'events-processing' }
Morph >> handleMouseMove: anEvent [ 
	"System level event handling."
	anEvent wasHandled ifTrue: [ ^ self ].
	"not interested"
	(self handlesMouseMove: anEvent) ifFalse: [ ^ self ].
	anEvent wasHandled: true.
	self mouseMove: anEvent.
	(self handlesMouseStillDown: anEvent) ifTrue:
		[ "Step at the new location"
		self
			startStepping: #handleMouseStillDown:
			at: Time millisecondClockValue
			arguments: {anEvent copy resetHandlerFields}
			stepTime: self mouseStillDownStepRate ]
]

{ #category : #'events-processing' }
Morph >> handleMouseOver: anEvent [
	"System level event handling."
	anEvent hand mouseFocus == self ifTrue:[
		"Got this directly through #handleFocusEvent: so check explicitly"
		(self containsPoint: anEvent position event: anEvent) ifFalse:[^self]].
	anEvent hand noticeMouseOver: self event: anEvent
]

{ #category : #'events-processing' }
Morph >> handleMouseStillDown: anEvent [
	"Called from the stepping mechanism for morphs wanting continuously repeated 'yes the mouse is still down, yes it is still down, yes it has not changed yet, no the mouse is still not up, yes the button is down' etc messages"
	(anEvent hand mouseFocus == self) 
		ifFalse:[^self stopSteppingSelector: #handleMouseStillDown:].
	self mouseStillDown: anEvent.

]

{ #category : #'events-processing' }
Morph >> handleMouseUp: anEvent [
	"System level event handling."
	anEvent wasHandled ifTrue:[^self]. "not interested"
	anEvent hand mouseFocus == self ifFalse:[^self]. "Not interested in other parties"
	anEvent hand releaseMouseFocus: self.
	anEvent wasHandled: true.
	self mouseUp: anEvent.
	self stopSteppingSelector: #handleMouseStillDown:.
]

{ #category : #'events-processing' }
Morph >> handleMouseWheel: anEvent [
	"System level event handling."

	anEvent wasHandled ifTrue: [^self].
	(self handlesMouseWheel: anEvent) ifFalse: [^ self].
	anEvent wasHandled: true.
	^ self mouseWheel: anEvent
]

{ #category : #'events-processing' }
Morph >> handleUnknownEvent: anEvent [
	"An event of an unknown type was sent to the receiver. What shall we do?!"
	Beeper beep. 
	anEvent printString displayAt: 0@0.
	anEvent wasHandled: true.
]

{ #category : #'events-processing' }
Morph >> handleWindowEvent: anEvent [
	"Handle an event concerning our host window"
	anEvent wasHandled ifTrue:[^self]. "not interested"
	(self wantsWindowEvent: anEvent) ifFalse:[^self].
	anEvent wasHandled: true.
	self windowEvent: anEvent.

]

{ #category : #'dropping\/grabbing' }
Morph >> handledOwnDraggingBy: aHandMorph on: aCanvas [
"this is my chance to do something differrent to the normal dragging work. return true if I did what I wanted, false if not"
	^false
]

{ #category : #'event handling' }
Morph >> handlerForMouseDown: anEvent [ 
	"Return the (prospective) handler for a mouse down event. The handler is temporarily 
	installed and can be used for morphs further down the hierarchy to negotiate whether 
	the inner or the outer morph should finally handle the event."

	anEvent yellowButtonPressed
		ifTrue: [^ self handlerForYellowButtonDown: anEvent].
	(self handlesMouseDown: anEvent)
		ifFalse: [^ nil].	"not interested"

	anEvent handler
		ifNil: [^ self ].	"Same priority but I am innermost"

	"Nobody else was interested"
	^self mouseDownPriority >= anEvent handler mouseDownPriority
		ifTrue: [ self]
		ifFalse: [ nil]
]

{ #category : #'event handling' }
Morph >> handlerForYellowButtonDown: anEvent [ 
	"Return the (prospective) handler for a mouse down event with the yellow button pressed.
	The 	handler is temporarily installed and can be used for morphs further 
	down the hierarchy to negotiate whether the inner or the outer 
	morph should finally handle the event."

	(self hasYellowButtonMenu or: [ self handlesMouseDown: anEvent ])
		ifFalse: [ ^ nil].	"Not interested."

	anEvent handler
		ifNil: [^ self].	"Nobody else was interested"

	"Same priority but I am innermost."
	^ self mouseDownPriority >= anEvent handler mouseDownPriority
		ifFalse: [nil ]
		ifTrue: [self]
]

{ #category : #'event handling' }
Morph >> handlesKeyboard: evt [
	"Return true if the receiver wishes to handle the given keyboard event"
	self eventHandler ifNotNil: [^ self eventHandler handlesKeyboard: evt].
	^ false

]

{ #category : #'event handling' }
Morph >> handlesKeyboardOnlyOnFocus [
	"If set, reject every keyboard event until the receiver has received the keyboard focus in another way, i.e. a mouse click (see #mouseDown:) or programmatic focusing (see HandMorph >> #newKeyboardFocus:). This allows sending keyboard events to any owner of the receiver while the receiver is hovered by the hand. See senders.
	A particular user is DialogWindow which looks for Enter and Escape presses and should not loose these events to the content morph unless it is explicitly focused. For the full discussion, see http://forum.world.st/The-Inbox-Morphic-cbc-1665-mcz-td5117905.html."

	^ self valueOfProperty: #handlesKeyboardOnlyOnFocus ifAbsent: [false]
]

{ #category : #'event handling' }
Morph >> handlesKeyboardOnlyOnFocus: aBoolean [

	^ self setProperty: #handlesKeyboardOnlyOnFocus toValue: aBoolean
]

{ #category : #'event handling' }
Morph >> handlesMouseDown: evt [
	"Do I want to receive mouseDown events (mouseDown:, mouseMove:, mouseUp:)?"
	"NOTE: The default response is false, except if you have added sensitivity to mouseDown events using the on:send:to: mechanism.  Subclasses that implement these messages directly should override this one to return true." 

	self eventHandler ifNotNil: [^ self eventHandler handlesMouseDown: evt].
	^ false
]

{ #category : #'event handling' }
Morph >> handlesMouseMove: anEvent [ 
	"Do I want to receive mouseMove: when the hand passes over the receiver?  Rules say that by default a morph gets #mouseMove iff
		* the hand is not dragging anything,
			+ and some button is down,
			+ and the receiver is the current mouse focus."
	self eventHandler ifNotNil: [^ self eventHandler handlesMouseMove: anEvent].
	self wantsEveryMouseMove ifTrue: [^ true].
	anEvent hand hasSubmorphs ifTrue: [ ^ false ].
	(anEvent anyButtonPressed and: [ anEvent hand mouseFocus == self ]) ifFalse: [ ^ false ].
	^ true
]

{ #category : #'event handling' }
Morph >> handlesMouseOver: evt [
	"Do I want to receive mouseEnter: and mouseLeave: when the button is up and the hand is empty?  The default response is false, except if you have added sensitivity to mouseEnter: or mouseLeave:, using the on:send:to: mechanism." 

	self eventHandler ifNotNil: [^ self eventHandler handlesMouseOver: evt].
	^ false
]

{ #category : #'event handling' }
Morph >> handlesMouseOverDragging: evt [
	"Return true if I want to receive mouseEnterDragging: and mouseLeaveDragging: when the hand drags something over me (button up or button down), or when the mouse button is down but there is no mouseDown recipient.  The default response is false, except if you have added sensitivity to mouseEnterLaden: or mouseLeaveLaden:, using the on:send:to: mechanism."
	"NOTE:  If the hand state matters in these cases, it may be tested by constructs such as
		event anyButtonPressed
		event hand hasSubmorphs"

	self eventHandler ifNotNil: [^ self eventHandler handlesMouseOverDragging: evt].
	^ false
]

{ #category : #'event handling' }
Morph >> handlesMouseStillDown: evt [
	"Return true if the receiver wants to get repeated #mouseStillDown: messages between #mouseDown: and #mouseUp"
	self eventHandler ifNotNil: [^ self eventHandler handlesMouseStillDown: evt].
	^ false

]

{ #category : #'event handling' }
Morph >> handlesMouseWheel: evt [
	"Do I want to receive mouseWheel events? The default response is false, except if you have added sensitivity to mouseWheel events using the on:send:to: mechanism.  Subclasses that implement these messages directly should override this one to return true." 

	self eventHandler ifNotNil: [^ self eventHandler handlesMouseWheel: evt].
	^ false
]

{ #category : #'layout-menu' }
Morph >> hasClipLayoutCellsString [
	^ (self clipLayoutCells
		ifTrue: ['<on>']
		ifFalse: ['<off>']), 'clip to cell size' translated
]

{ #category : #drawing }
Morph >> hasClipSubmorphsString [
	"Answer a string that represents the clip-submophs checkbox"
	^ (self clipSubmorphs
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'provide clipping' translated
]

{ #category : #menus }
Morph >> hasDirectionHandlesString [
	^ (self wantsDirectionHandles
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'direction handles' translated
]

{ #category : #'layout-menu' }
Morph >> hasDisableTableLayoutString [
	^ (self disableTableLayout
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'disable layout in tables' translated
]

{ #category : #menus }
Morph >> hasDragAndDropEnabledString [
	"Answer a string to characterize the drag & drop status of the  
	receiver"
	^ (self dragNDropEnabled
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'drag and drop enabled' translated
]

{ #category : #menus }
Morph >> hasDragEnabledString [

	^ (self dragEnabled
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'drag out' translated
]

{ #category : #menus }
Morph >> hasDropEnabledString [

	^ (self dropEnabled
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'drop in' translated
]

{ #category : #'drop shadows' }
Morph >> hasDropShadow [
	"answer whether the receiver has DropShadow"
	^ self
		valueOfProperty: #hasDropShadow
		ifAbsent: [false]
]

{ #category : #'drop shadows' }
Morph >> hasDropShadow: aBool [

	self hasDropShadow = aBool ifTrue: [^ self].
	self changed.
	aBool
		ifTrue:[self setProperty: #hasDropShadow toValue: true]
		ifFalse:[self removeProperty: #hasDropShadow].
		
	self layoutChanged.
	self changed.
]

{ #category : #'drop shadows' }
Morph >> hasDropShadowString [
	^ (self hasDropShadow
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'show shadow' translated
]

{ #category : #'accessing - extension' }
Morph >> hasExtension [
	"answer whether the receiver has extention"
	^ extension notNil
]

{ #category : #'event handling' }
Morph >> hasFocus [

	self flag: #obsolete. "mt: Use #hasKeyboardFocus instead, which reads live hand information and no cache."
	^ false
]

{ #category : #'halos and balloon help' }
Morph >> hasHalo [
	^self hasProperty: #hasHalo.
]

{ #category : #'halos and balloon help' }
Morph >> hasHalo: aBool [
	aBool
		ifTrue:[self setProperty: #hasHalo toValue: true]
		ifFalse:[self removeProperty: #hasHalo]
]

{ #category : #'event handling' }
Morph >> hasKeyboardFocus [

	^ self activeHand
		ifNil: [false]
		ifNotNil: [:hand | self hasKeyboardFocus: hand]
]

{ #category : #'event handling' }
Morph >> hasKeyboardFocus: aHand [

	^ aHand keyboardFocus == self keyboardFocusDelegate
]

{ #category : #'event handling' }
Morph >> hasMouseFocus [

	^ self activeHand
		ifNil: [false]
		ifNotNil: [:hand | self hasMouseFocus: hand]
]

{ #category : #'event handling' }
Morph >> hasMouseFocus: aHand [

	^ aHand mouseFocus == self
]

{ #category : #'layout-menu' }
Morph >> hasNoLayoutString [
	^ (self layoutPolicy isNil
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'no layout' translated
]

{ #category : #structure }
Morph >> hasOwner: aMorph [
	"Return true if the receiver has aMorph in its owner chain"
	aMorph ifNil:[^true].
	self allOwnersDo:[:m| m = aMorph ifTrue:[^true]].
	^false
]

{ #category : #'accessing - properties' }
Morph >> hasProperty: aSymbol [ 
	"Answer whether the receiver has the property named aSymbol"
	extension ifNil: [^ false].
	^extension hasProperty: aSymbol
]

{ #category : #'layout-menu' }
Morph >> hasProportionalLayoutString [
	| layout |
	^ (((layout := self layoutPolicy) notNil
			and: [layout isProportionalLayout])
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'proportional layout' translated
]

{ #category : #'layout-menu' }
Morph >> hasReverseCellsString [
	^ (self reverseTableCells
		ifTrue: ['<on>']
		ifFalse: ['<off>']), 'reverse table cells' translated
]

{ #category : #'drop shadows' }
Morph >> hasRolloverBorder [
	"answer whether the receiver has RolloverBorder"
	^ self
		valueOfProperty: #hasRolloverBorder
		ifAbsent: [false]
]

{ #category : #'drop shadows' }
Morph >> hasRolloverBorder: aBool [
	aBool
		ifTrue:[self setProperty: #hasRolloverBorder toValue: true]
		ifFalse:[self removeProperty: #hasRolloverBorder]
]

{ #category : #'layout-menu' }
Morph >> hasRubberBandCellsString [
	^ (self rubberBandCells
		ifTrue: ['<on>']
		ifFalse: ['<off>']), 'rubber band cells' translated
]

{ #category : #'submorphs-accessing' }
Morph >> hasSubmorphWithProperty: aSymbol [
	^submorphs anySatisfy: [:m | m hasProperty: aSymbol]
]

{ #category : #'submorphs-accessing' }
Morph >> hasSubmorphs [
	^submorphs notEmpty
]

{ #category : #'layout-menu' }
Morph >> hasTableLayoutString [
	| layout |
	^ (((layout := self layoutPolicy) notNil
			and: [layout isTableLayout])
		ifTrue: ['<on>']
		ifFalse: ['<off>'])
		, 'table layout' translated
]

{ #category : #accessing }
Morph >> hasTranslucentColor [
	"Answer true if this any of this morph is translucent but not transparent."

	^ color isColor and: [color isTranslucentColor]

]

{ #category : #menu }
Morph >> hasYellowButtonMenu [
	"Answer true if I have any items at all for a context (yellow  
	button) menu."
	^ self wantsYellowButtonMenu
			or: [self models anySatisfy: [:each | each hasModelYellowButtonMenuItems]]
]

{ #category : #'rotate scale and flex' }
Morph >> heading [
	"Answer the current heading, which is #rotationDegrees relative to the #forwardDirection."

	^ self rotationDegrees + self forwardDirection
]

{ #category : #'rotate scale and flex' }
Morph >> heading: newHeading [

	self rotationDegrees: (newHeading - self forwardDirection).
]

{ #category : #geometry }
Morph >> height [

	^ bounds height
]

{ #category : #geometry }
Morph >> height: aNumber [
	" Set my height; my position (top-left corner) and width will remain the same "

	self extent: self width@aNumber asInteger.

]

{ #category : #menus }
Morph >> helpButton [
	"Answer a button whose action would be to put up help concerning the receiver"

	| aButton |
	aButton := SimpleButtonMorph new.
	aButton
		target: self;
		color: Color lightGreen;
		borderColor: Color lightGreen muchDarker;
		borderWidth: 1;
		label: '?' translated font: Preferences standardButtonFont;
		actionSelector: #presentHelp;
		setBalloonText: 'click here for help' translated.
	^ aButton
]

{ #category : #drawing }
Morph >> hide [

	self visible ifTrue: [self visible: false].
]

{ #category : #accessing }
Morph >> highlight [
	"The receiver is being asked to appear in a highlighted state.  Mostly used for textual morphs"
	self color: self highlightColor
]

{ #category : #accessing }
Morph >> highlightColor [
	
	| val |
	^ (val := self valueOfProperty: #highlightColor)
		ifNotNil:
			[val ifNil: [self error: 'nil highlightColor']]
		ifNil:
			[owner ifNil: [self color] ifNotNil: [owner highlightColor]]
]

{ #category : #accessing }
Morph >> highlightColor: aColor [
	self setProperty: #highlightColor toValue: aColor
]

{ #category : #'dropping\/grabbing' }
Morph >> highlightForDrop [
	self highlightForDrop: true
]

{ #category : #'dropping\/grabbing' }
Morph >> highlightForDrop: aBoolean [
	self setProperty: #highlightedForDrop toValue: aBoolean.
	self changed
]

{ #category : #drawing }
Morph >> highlightForMouseDown [
	self highlightForMouseDown: true
]

{ #category : #drawing }
Morph >> highlightForMouseDown: aBoolean [
	aBoolean 
		ifTrue:[self setProperty: #highlightedForMouseDown toValue: aBoolean]
		ifFalse:[self removeProperty: #highlightedForMouseDown. self resetExtension].
	self changed
]

{ #category : #'dropping\/grabbing' }
Morph >> highlightedForDrop [
	^(self valueOfProperty: #highlightedForDrop) == true
]

{ #category : #drawing }
Morph >> highlightedForMouseDown [
	^(self valueOfProperty: #highlightedForMouseDown) == true
]

{ #category : #thumbnail }
Morph >> icon [
	"Answer a form with an icon to represent the receiver"
	^ self valueOfProperty: #icon
]

{ #category : #thumbnail }
Morph >> iconOrThumbnail [

	^ self icon ifNil: [self thumbnail]
]

{ #category : #thumbnail }
Morph >> iconOrThumbnailOfSize: aNumberOrPoint [ 
	"Answer an appropiate form to represent the receiver"

	^ self iconOrThumbnail scaledIntoFormOfSize: aNumberOrPoint

]

{ #category : #drawing }
Morph >> imageForm [

	^ self imageFormForRectangle: self fullBounds

]

{ #category : #drawing }
Morph >> imageForm: depth backgroundColor: aColor forRectangle: rect [
	| canvas |
	canvas := Display defaultCanvasClass extent: rect extent depth: depth.
	canvas translateBy: rect topLeft negated
		during:[:tempCanvas| 
			tempCanvas fillRectangle: rect color: aColor.
			tempCanvas fullDrawMorph: self].
	^ canvas form offset: rect topLeft
]

{ #category : #drawing }
Morph >> imageForm: depth forRectangle: rect [
	| canvas |
	canvas := Display defaultCanvasClass extent: rect extent depth: depth.
	canvas translateBy: rect topLeft negated
		during:[:tempCanvas| tempCanvas fullDrawMorph: self].
	^ canvas form offset: rect topLeft
]

{ #category : #drawing }
Morph >> imageFormDepth: depth [

	^ self imageForm: depth forRectangle: self fullBounds

]

{ #category : #drawing }
Morph >> imageFormForRectangle: rect [

	^ self imageForm: Display depth forRectangle: rect

]

{ #category : #drawing }
Morph >> imageFormWithout: stopMorph andStopThere: stopThere [
	"Like imageForm, except it does not display stopMorph,
	and it will not display anything above it if stopThere is true.
	Returns a pair of the imageForm and a boolean that is true
		if it has hit stopMorph, and display should stop."
	| canvas rect |
	rect := self fullBounds.
	canvas := ColorPatchCanvas extent: rect extent depth: Display depth.
	canvas stopMorph: stopMorph.
	canvas doStop: stopThere.
	canvas translateBy: rect topLeft negated during:[:tempCanvas| tempCanvas fullDrawMorph: self].
	^ Array with: (canvas form offset: rect topLeft)
			with: canvas foundMorph
]

{ #category : #initialization }
Morph >> inAScrollPane [
	"Answer a scroll pane that allows the user to scroll the receiver in either direction.  It will have permanent scroll bars unless you take some special action."

	| widget |
	widget := ScrollPane new.
	widget borderWidth: 0.

	widget scroller addMorph: self.
	self position: 0@0.

	widget
		hScrollBarPolicy: #whenNeeded;
		vScrollBarPolicy: #whenNeeded;
		fit;
		extent: (widget width min: 300 max: 100) @ (widget height min: 150 max: 100).

	widget color: self color darker darker.
	^ widget
]

{ #category : #'parts bin' }
Morph >> inPartsBin [

	self isPartsDonor ifTrue: [^ true].
	self allOwnersDo: [:m | m isPartsBin ifTrue: [^ true]].
	^ false

]

{ #category : #'submorphs-accessing' }
Morph >> indexOfMorphAbove: aPoint [
	"Return index of lowest morph whose bottom is above aPoint.
	Will return 0 if the first morph is not above aPoint."

	submorphs withIndexDo: [:mm :ii | 
		mm fullBounds bottom >= aPoint y ifTrue: [^ ii - 1]].
	^ submorphs size
]

{ #category : #'meta-actions' }
Morph >> indicateAllSiblings [
	"Indicate all the receiver and all its siblings by flashing momentarily."

	| aPlayer allBoxes |
	(aPlayer := self topRendererOrSelf player) belongsToUniClass ifFalse: [^ self "error: 'not uniclass'"].
	allBoxes := aPlayer class allInstances
		select: [:m | m costume world == self currentWorld]
		thenCollect: [:m | m costume boundsInWorld].

	5 timesRepeat:
		[Display flashAll: allBoxes andWait: 120].
]

{ #category : #testing }
Morph >> indicateKeyboardFocus [

	^ (self hasProperty: #indicateKeyboardFocus)
		ifTrue: [(self valueOfProperty: #indicateKeyboardFocus) ~~ #never]
		ifFalse: [self class indicateKeyboardFocus]
]

{ #category : #printing }
Morph >> initString [

	^ String streamContents: [:s | self fullPrintOn: s]
]

{ #category : #'user interface' }
Morph >> initialExtent [
	| ext |
	(ext := self valueOfProperty: #initialExtent)
		ifNotNil:
			[^ ext].
	^ super initialExtent
]

{ #category : #initialization }
Morph >> initialize [
	"initialize the state of the receiver"
	owner := nil.
	submorphs := Array empty.
	bounds := self defaultBounds.
	color := self defaultColor
]

{ #category : #'accessing - extension' }
Morph >> initializeExtension [
	"private - initializes the receiver's extension"
	extension := MorphExtension new
]

{ #category : #'parts bin' }
Morph >> initializeToStandAlone [
	"Set up the receiver, created by a #basicNew and now ready to be initialized, as a fully-formed morph suitable for providing a graphic for a parts bin surrogate, and, when such a parts-bin surrogate is clicked on, for attaching to the hand as a viable stand-alone morph.  Because of historical precedent, #initialize has been expected to handle this burden, though a great number of morphs actually cannot stand alone.  In any case, by default we call the historical #initialize, though unhappily, so that all existing morphs will work no worse than before when using this protocol."

	self initialize
]

{ #category : #'geometry - layout' }
Morph >> innerBounds [
	"Return the inner rectangle enclosed by the bounds of this morph excluding the space taken by its borders. For an unbordered morph, this is just its bounds."

	^ self bounds insetBy: self borderStyle inset
]

{ #category : #'geometry - layout' }
Morph >> innerBounds: aRectangle [
	"Set the bounds for laying out children of the receiver.
	Note: written so that #innerBounds can be changed without touching this method"
	| outer inner |
	outer := self bounds.
	inner := self innerBounds.
	self bounds: (aRectangle origin + (outer origin - inner origin) corner:
				aRectangle corner + (outer corner - inner corner)).
]

{ #category : #'geometry - layout' }
Morph >> innerExtent [

	^ self innerBounds extent
]

{ #category : #'geometry - layout' }
Morph >> innerExtent: aPoint [

	self innerBounds: (self innerPosition extent: aPoint).
]

{ #category : #'geometry - layout' }
Morph >> innerPosition [

	^ self innerBounds topLeft
]

{ #category : #'geometry - layout' }
Morph >> innerPosition: aPoint [

	| prior delta |
	prior := self innerBounds.
	delta := (aPoint - prior topLeft) rounded.
	self innerBounds: (prior translateBy: delta).
]

{ #category : #naming }
Morph >> innocuousName [
	"Choose an innocuous name for the receiver -- one that does not end in the word Morph"

	| className allKnownNames |
	className := self defaultNameStemForInstances.
	(className size > 5 and: [className endsWith: 'Morph'])
		ifTrue: [className := className copyFrom: 1 to: className size - 5].
	className := className asString translated.
	allKnownNames := self world ifNil: [OrderedCollection new] ifNotNil: [self world allKnownNames].
	^ Utilities keyLike: className asString satisfying:
		[:aName | (allKnownNames includes: aName) not]
]

{ #category : #accessing }
Morph >> insetColor [
	owner ifNil:[^self color].
	^ self colorForInsets
]

{ #category : #'debug and other' }
Morph >> inspectArgumentsPlayerInMorphic: evt [
	evt hand attachMorph: ((Inspector openOn: self player) extent: 300@200)
]

{ #category : #'meta-actions' }
Morph >> inspectAt: aPoint event: evt [
	| morphs target |
	morphs := self morphsAt: aPoint.
	(morphs includes: self) ifFalse:[morphs := morphs copyWith: self].
	target := UIManager default
		chooseFrom: (morphs collect: [:m | m knownName ifNil:[m class name asString]])
		values: morphs
		title:  ('inspect whom?
(deepest at top)').
	target ifNil:[^self].
	target inspectInMorphic: evt
]

{ #category : #menus }
Morph >> inspectInMorphic [

	ToolSet inspect: self.
]

{ #category : #menus }
Morph >> inspectInMorphic: evt [

	ToolSet inspect: self.

]

{ #category : #'debug and other' }
Morph >> inspectOwnerChain [
	self ownerChain inspectWithLabel: 'Owner chain for ', self printString
]

{ #category : #'debug and other' }
Morph >> installModelIn: ignored [
	"Simple morphs have no model"
	"See MorphicApp for other behavior"
]

{ #category : #'geometry - local\/global' }
Morph >> intersects: aRectangle [
	"Answer whether aRectangle, which is in World coordinates, intersects me."

	^self fullBoundsInWorld intersects: aRectangle
]

{ #category : #initialization }
Morph >> intoWorld: aWorld [
	"The receiver has just appeared in a new world. Note:
		* aWorld can be nil (due to optimizations in other places)
		* owner is already set
		* owner's submorphs may not include receiver yet.
	Important: Keep this method fast - it is run whenever morphs are added."
	aWorld ifNil:[^self].
	self wantsSteps ifTrue:[aWorld startStepping: self].
	self submorphsDo:[:m| m intoWorld: aWorld].

]

{ #category : #'change reporting' }
Morph >> invalidRect: damageRect [
	^self invalidRect: damageRect from: self
]

{ #category : #'change reporting' }
Morph >> invalidRect: aRectangle from: aMorph [
	| damageRect |
	self visible ifFalse: [ ^self ].
	aRectangle hasPositiveExtent ifFalse: [ ^self ].
	damageRect := aRectangle.
	aMorph == self ifFalse:[
		"Clip to receiver's clipping bounds if the damage came from a child"
		self clipSubmorphs 
			ifTrue:[damageRect := aRectangle intersect: self clippingBounds]].
	owner ifNotNil: [owner invalidRect: damageRect from: self].
]

{ #category : #'meta-actions' }
Morph >> invokeHaloOrMove: anEvent [
	"Special gestures (cmd-mouse on the Macintosh; Alt-mouse on Windows and Unix) allow a mouse-sensitive morph to be moved or bring up a halo for the morph."
	| h tfm doNotDrag |
	h := anEvent hand halo.
	"Prevent wrap around halo transfers originating from throwing the event back in"
	doNotDrag := false.
	h ifNotNil:[
		(h innerTarget == self) ifTrue:[doNotDrag := true].
		(h innerTarget hasOwner: self) ifTrue:[doNotDrag := true].
		(self hasOwner: h target) ifTrue:[doNotDrag := true]].

	tfm := (self transformedFrom: nil) inverseTransformation.

	"cmd-drag on flexed morphs works better this way"
	h := self addHalo: (anEvent transformedBy: tfm).
	h ifNil: [^ self].
	doNotDrag ifTrue:[^self].
	"Initiate drag transition if requested"
	anEvent hand 
		waitForClicksOrDrag: h
		event: (anEvent transformedBy: tfm)
		selectors: { nil. nil. nil. #startDragTarget:. }
		threshold: HandMorph dragThreshold.
	"Pass focus explicitly here"
	anEvent hand newMouseFocus: h.
	"Reset temporary cursors to make available halo interaction visible."
	anEvent hand showTemporaryCursor: nil.
]

{ #category : #'meta-actions' }
Morph >> invokeMetaMenu: evt [

	| menu |
	menu := self buildMetaMenu: evt.
	menu addTitle: self externalName.
	menu popUpEvent: evt in: self world
]

{ #category : #'meta-actions' }
Morph >> invokeMetaMenuAt: aPoint event: evt [
	| morphs target |
	morphs := self morphsAt: aPoint.
	(morphs includes: self) ifFalse:[morphs := morphs copyWith: self].
	morphs size = 1 ifTrue:[morphs first invokeMetaMenu: evt].
	target := UIManager default
		chooseFrom: (morphs collect: [:m | m knownName ifNil:[m class name asString]])
		values: morphs.
	target ifNil:[^self].
	target invokeMetaMenu: evt
]

{ #category : #'e-toy support' }
Morph >> isAViewer [
	^ false
]

{ #category : #classification }
Morph >> isAlignmentMorph [

	^ false
]

{ #category : #classification }
Morph >> isBalloonHelp [
	^false
]

{ #category : #classification }
Morph >> isCompoundTileMorph [
	^false
]

{ #category : #testing }
Morph >> isDockingBar [
	"Return true if the receiver is a docking bar"
	^ false
]

{ #category : #accessing }
Morph >> isFlap [
	"Answer whether the receiver claims to be a flap"

	^ self hasProperty: #flap
]

{ #category : #classification }
Morph >> isFlapOrTab [
	^self isFlap or:[self isFlapTab]
]

{ #category : #classification }
Morph >> isFlapTab [
	^false
]

{ #category : #classification }
Morph >> isFlexMorph [

	^ false

]

{ #category : #testing }
Morph >> isFlexed [
	"Return true if the receiver is currently flexed"
	owner ifNil:[^false].
	^owner isFlexMorph
]

{ #category : #testing }
Morph >> isFullOnScreen [
	"Answer if the receiver is full contained in the owner visible  
	area."
	owner isInMemory
		ifFalse: [^ true].
	owner isNil
		ifTrue: [^ true].
	self visible
		ifFalse: [^ true].
	^ owner clearArea containsRect: self fullBounds
]

{ #category : #geniestubs }
Morph >> isGestureStart: anEvent [
	"This mouse down could be the start of a gesture, or the end of a gesture focus"

	anEvent hand isGenieEnabled
		ifFalse: [ ^false ].

	(self allowsGestureStart: anEvent)
		ifTrue: [^ true ].		"could be the start of a gesture"

	"otherwise, check for whether it's time to disable the Genie auto-focus"
	(anEvent hand isGenieFocused
		and: [anEvent whichButton ~= anEvent hand focusStartEvent whichButton])
			ifTrue: [anEvent hand disableGenieFocus].

	^false
]

{ #category : #classification }
Morph >> isHandMorph [

	^ false
]

{ #category : #testing }
Morph >> isImageMorph [
	^false
]

{ #category : #structure }
Morph >> isInDockingBar [
	"answer if the receiver is in a menu bar"
	^ (owner notNil) and: [owner isDockingBar]
]

{ #category : #structure }
Morph >> isInSystemWindow [
	"answer if the receiver is in a system window"
	^ owner isMorph and:[owner isSystemWindow or:[owner isInSystemWindow]]
]

{ #category : #structure }
Morph >> isInWorld [
	"Return true if this morph is in a world."

	^self world notNil
]

{ #category : #classification }
Morph >> isKedamaMorph [
	^false
]

{ #category : #'halos and balloon help' }
Morph >> isLikelyRecipientForMouseOverHalos [
	^self player notNil
]

{ #category : #testing }
Morph >> isLineMorph [
	^false
]

{ #category : #accessing }
Morph >> isLocked [
	"answer whether the receiver is Locked"
	extension ifNil: [^ false].
	^ extension locked
]

{ #category : #testing }
Morph >> isMenuItemMorph [
	^false
]

{ #category : #classification }
Morph >> isModalShell [
	^false
]

{ #category : #testing }
Morph >> isMorph [

	^ true
]

{ #category : #classification }
Morph >> isNumericReadoutTile [
	^false
]

{ #category : #'parts bin' }
Morph >> isPartsBin [
	^ false
]

{ #category : #'parts bin' }
Morph >> isPartsDonor [
	"answer whether the receiver is PartsDonor"
	extension ifNil: [^ false].
	^ extension isPartsDonor
]

{ #category : #'parts bin' }
Morph >> isPartsDonor: aBoolean [ 
	"change the receiver's isPartDonor property"
	(extension isNil and: [aBoolean not]) ifTrue: [^ self].
	self assureExtension isPartsDonor: aBoolean
]

{ #category : #classification }
Morph >> isPhraseTileMorph [
	^false
]

{ #category : #classification }
Morph >> isPlayfieldLike [
	^ false
]

{ #category : #classification }
Morph >> isRenderer [
	"A *renderer* morph transforms the appearance of its submorph in some manner. For example, it might supply a drop shadow or scale and rotate the morph it encases. Answer true if this morph acts as a renderer. This default implementation returns false."
	"Details: A renderer is assumed to have a single submorph. Renderers may be nested to concatenate their transformations. It is useful to be able to find the outer-most renderer. This can be done by ascending the owner chain from the rendered morph. To find the morph being rendered, one can descend through the (singleton) submorph lists of the renderer chain until a non-renderer is encountered."

	^ false

]

{ #category : #testing }
Morph >> isSafeToServe [
	"Return true if it is safe to serve this Morph using Nebraska." 
	^true
]

{ #category : #testing }
Morph >> isSelectionMorph [
	^false
]

{ #category : #accessing }
Morph >> isShared [
	"Answer whether the receiver has the #shared property.  This property allows it to be treated as a 'background' item"

	^ self hasProperty: #shared
]

{ #category : #testing }
Morph >> isSketchMorph [
	^self class isSketchMorphClass
]

{ #category : #classification }
Morph >> isSoundTile [
	^false
]

{ #category : #classification }
Morph >> isStandardViewer [
	^false
]

{ #category : #'stepping and presenter' }
Morph >> isStepping [
	"Return true if the receiver is currently stepping in its world"
	| aWorld |
	^ (aWorld := self world)
		ifNil:		[false]
		ifNotNil:	[aWorld isStepping: self]
]

{ #category : #'stepping and presenter' }
Morph >> isSteppingSelector: aSelector [
	"Return true if the receiver is currently stepping in its world"
	| aWorld |
	^ (aWorld := self world)
		ifNil:		[false]
		ifNotNil:	[aWorld isStepping: self selector: aSelector]
]

{ #category : #accessing }
Morph >> isSticky [
	"answer whether the receiver is Sticky"
	extension ifNil: [^ false].
	^ extension sticky
]

{ #category : #classification }
Morph >> isStickySketchMorph [
	^false
]

{ #category : #classification }
Morph >> isSyntaxMorph [
	^false
]

{ #category : #classification }
Morph >> isTextMorph [
	^false
]

{ #category : #'e-toy support' }
Morph >> isTileEditor [
	"No, I'm not"
	^false
]

{ #category : #classification }
Morph >> isTileMorph [
	^false
]

{ #category : #classification }
Morph >> isTilePadMorph [
	^false
]

{ #category : #classification }
Morph >> isViewer [
	^false
]

{ #category : #classification }
Morph >> isWorldMorph [

	^ false
]

{ #category : #classification }
Morph >> isWorldOrHandMorph [

	^ self isWorldMorph or: [self isHandMorph]
]

{ #category : #'dropping\/grabbing' }
Morph >> justDroppedInto: aMorph event: anEvent [
	"This message is sent to a dropped morph after it has been dropped on -- and been accepted by -- a drop-sensitive morph"

	| partsBinCase cmd |
	(self formerOwner notNil and: [self formerOwner ~~ aMorph])
		ifTrue: [self removeHalo].
	self formerOwner: nil.
	self formerPosition: nil.
	cmd := self valueOfProperty: #undoGrabCommand.
	cmd ifNotNil:[aMorph rememberCommand: cmd.
				self removeProperty: #undoGrabCommand].
	(partsBinCase := aMorph isPartsBin) ifFalse:
		[self isPartsDonor: false].
	(self isInWorld and: [partsBinCase not]) ifTrue:
		[self world startSteppingSubmorphsOf: self].
	"Note an unhappy inefficiency here:  the startStepping... call will often have already been called in the sequence leading up to entry to this method, but unfortunately the isPartsDonor: call often will not have already happened, with the result that the startStepping... call will not have resulted in the startage of the steppage."

	"An object launched by certain parts-launcher mechanisms should end up fully visible..."
	(self hasProperty: #beFullyVisibleAfterDrop) ifTrue:
		[aMorph == self currentWorld ifTrue:
			[self goHome].
		self removeProperty: #beFullyVisibleAfterDrop].
]

{ #category : #'dropping\/grabbing' }
Morph >> justGrabbedFrom: formerOwner [
	"The receiver was just grabbed from its former owner and is now attached to the hand. By default, we pass this message on if we're a renderer."
	(self isRenderer and:[self hasSubmorphs]) 
		ifTrue:[self firstSubmorph justGrabbedFrom: formerOwner].
]

{ #category : #'rotate scale and flex' }
Morph >> keepsTransform [
	"Return true if the receiver will keep it's transform while being grabbed by a hand."
	^false
]

{ #category : #'event handling' }
Morph >> keyDown: anEvent [
	"Handle a key down event. The default response is to let my eventHandler, if any, handle it."

	self eventHandler ifNotNil:
		[self eventHandler keyDown: anEvent fromMorph: self].

]

{ #category : #'event handling' }
Morph >> keyStroke: anEvent [
	"Handle a keystroke event.  The default response is to let my eventHandler, if any, handle it."

	self eventHandler ifNotNil:
		[self eventHandler keyStroke: anEvent fromMorph: self].

]

{ #category : #'event handling' }
Morph >> keyUp: anEvent [
	"Handle a key up event. The default response is to let my eventHandler, if any, handle it."

	self eventHandler ifNotNil:
		[self eventHandler keyUp: anEvent fromMorph: self].

]

{ #category : #'events-filtering-bubbling' }
Morph >> keyboardBubbleFilters [
	^ self valueOfProperty: #keyboardBubbleFilters
]

{ #category : #'events-filtering-bubbling' }
Morph >> keyboardBubbleFilters: anArrayOrNil [
	^ self setProperty: #keyboardBubbleFilters toValue: anArrayOrNil
]

{ #category : #'events-filtering-capturing' }
Morph >> keyboardCaptureFilters [
	^ self valueOfProperty: #keyboardCaptureFilters
]

{ #category : #'events-filtering-capturing' }
Morph >> keyboardCaptureFilters: anArrayOrNil [
	^ self setProperty: #keyboardCaptureFilters toValue: anArrayOrNil
]

{ #category : #'event handling' }
Morph >> keyboardFocusChange: aBoolean [
	"The message is sent to a morph when its keyboard focus change. The given argument indicates that the receiver is gaining keyboard focus (versus losing) the keyboard focus. Morphs that accept keystrokes should change their appearance in some way when they are the current keyboard focus."

	self eventHandler
		ifNotNil: [:h | h keyboardFocusChange: aBoolean fromMorph: self].

	self indicateKeyboardFocus
		ifTrue: [self changed].
]

{ #category : #drawing }
Morph >> keyboardFocusColor [

	^ self userInterfaceTheme keyboardFocusColor ifNil: [TranslucentColor r: 0.3 g: 0.5 b: 0.5 alpha: 0.5]
]

{ #category : #'event handling' }
Morph >> keyboardFocusDelegate [
	"If this morph ever tries to acquire the keyboard focus, this can be delegate to, for example, a submorph."
	
	^ self
]

{ #category : #drawing }
Morph >> keyboardFocusWidth [

	^ self userInterfaceTheme keyboardFocusWidth ifNil: [3]
]

{ #category : #testing }
Morph >> knownName [
	"answer a name by which the receiver is known, or nil if none"
	^ extension ifNotNil: [extension externalName]
]

{ #category : #'submorphs-accessing' }
Morph >> lastSubmorph [
	^submorphs last
]

{ #category : #'geometry - layout' }
Morph >> layoutBounds [
	"Return the bounds for laying out children of the receiver"
	| inset box |
	inset := self layoutInset.
	box := self innerBounds.
	inset isZero ifTrue:[^box].
	^box insetBy: inset.
]

{ #category : #'geometry - layout' }
Morph >> layoutBounds: aRectangle [
	"Set the bounds for laying out children of the receiver.
	Note: written so that #layoutBounds can be changed without touching this method"
	| outer inner |
	outer := self bounds.
	inner := self layoutBounds.
	self bounds: (aRectangle origin + (outer origin - inner origin) corner:
				aRectangle corner + (outer corner - inner corner)).
]

{ #category : #layout }
Morph >> layoutChanged [
	"Notify my dependents (such as owner and submorphs) about a possible layout change after, for example, a change in position or extent. As a result, the layout will be re-computed for this morph and all its submorphs on the next #fullBounds call."

	"0) Skip duplicate notifications. Only once after every successful layout computation."
	fullBounds ifNil: [^self].
	
	"1) Clear layout caches."
	fullBounds := nil.
	self layoutPolicy ifNotNil:[:layout | layout flushLayoutCache].
	
	"2) Notify all dependents. Note that we do not send #ownerChanged to our submorphs now because we have to ensure that each submorph gets notified *exactly once* right before layout computation. See #doLayoutIn:."
	self owner ifNotNil: [:o | self disableLayout ifFalse: [o layoutChanged]].
]

{ #category : #layout }
Morph >> layoutComputed [

	^ fullBounds notNil
]

{ #category : #'geometry - layout' }
Morph >> layoutExtent [

	^ self layoutBounds extent
]

{ #category : #'geometry - layout' }
Morph >> layoutExtent: aPoint [

	self layoutBounds: (self layoutPosition extent: aPoint).
]

{ #category : #'layout-properties' }
Morph >> layoutFrame [
	"Layout specific. Return the layout frame describing where the  
	receiver should appear in a proportional layout"
	^ extension ifNotNil: [extension layoutFrame]
]

{ #category : #'layout-properties' }
Morph >> layoutFrame: aLayoutFrame [
	"Layout specific. Return the layout frame describing where the receiver should appear in a proportional layout"
	self layoutFrame == aLayoutFrame ifTrue:[^self].
	self assureExtension layoutFrame: aLayoutFrame.
	self layoutChanged.
]

{ #category : #layout }
Morph >> layoutInBounds: cellBounds [
	
	self flag: #deprecated. "No actual deprecation warning because of debugging hazards."
	self
		layoutInBounds: cellBounds
		positioning: (self owner ifNil: [#center] ifNotNil: [:o | o cellPositioning]).
]

{ #category : #layout }
Morph >> layoutInBounds: cellBounds positioning: cellPositioning [
	"Layout specific. Apply the given bounds to the receiver after being layed out in its owner."
	
	| box |	
	"1) We are getting new bounds here but we haven't computed the receiver's layout yet."
	self layoutComputed ifFalse:[
		"Although the receiver has reported its #minExtent before the actual size it has may differ from what would be after the layout. Normally, this isn't a real problem, but if we have #shrinkWrap constraints (see #adjustLayoutBounds) then the receiver's bounds may be larger than the cellBounds. THAT is a problem because the centering may not work correctly if the receiver shrinks after the owner layout has been computed. To avoid this problem, we compute the receiver's layout now. Note that the layout computation is based on the new cell bounds rather than the receiver's current bounds."
		
		"1.1) Adjust the box for #rigid receiver. Both #spaceFill and #shrinkWrap can use the cellBounds for now, which is important for many space-fills in a row or column to have the same widths (or heights) such as all MenuMorphItems in our MenuMorph."
		box := cellBounds origin extent: 
			(self hResizing == #rigid ifTrue: [self bounds extent x] ifFalse: [cellBounds extent x]) @
			(self vResizing == #rigid ifTrue: [self bounds extent y] ifFalse: [cellBounds extent y]).
		
		"1.2) Move and resize the receiver to get started."
		self
			setPositionFromLayout: box origin;
			setExtentFromLayout: box extent.
		
		"1.3) Adjust to layout bounds and do the layout."
		box := box origin - (self bounds origin - self layoutBounds origin) corner:
					box corner - (self bounds corner - self layoutBounds corner).
		self doLayoutIn: box].
	
"	self assert: self layoutComputed.
	self assert: self owner layoutComputed not.
"
	"2) Are we done already?"
	cellBounds extent = self bounds extent
		"Nice fit. I usually am done here if #minExtent did already trigger layout update (via #fullBounds) while my owner's layout was calculating the cell sizes."
		ifTrue:[^ self setPositionFromLayout: cellBounds origin].
		
	"3) We have the receiver's layout. Maybe we just computed it or we did not invalidate it in this run. The latter happens if our owner invalidates without telling us. The user dragging size grips in windows, for example. Now we have to consider #spaceFill constraints, which may trigger re-computation of the receiver's layout."
	box := self bounds.
	self hResizing == #spaceFill 
		ifTrue: [
			"Support dynamic width-for-height due to space-fill constraint -- another layout run needed?"
			(box width ~= cellBounds width and: [self vResizing == #shrinkWrap])
				ifTrue: [self owner ifNotNil: [:o | o setProperty: #doLayoutAgain toValue: true]].
			"Fill the cell."
			box := box origin extent: cellBounds width @ box height].
		
	self vResizing == #spaceFill
		ifTrue: [
			"Support dynamic height-for-width due to space-fill constraint -- another layout run needed?"
			(box height ~= cellBounds height and: [self hResizing == #shrinkWrap])
				ifTrue: [self owner ifNotNil: [:o | o setProperty: #doLayoutAgain toValue: true]].
			"Fill the cell."	
			box := box origin extent: box width @ cellBounds height].

	"4) We have the receiver's layout. Align in the cell according o the owners layout properties."
	box := box align: (box perform: cellPositioning) with: (cellBounds perform: cellPositioning).

"	self assert: self layoutComputed.
	self assert: self owner layoutComputed not.
"
	"5) Install the new bounds. This may invalidate my layout again, which is okay because my owner will ask about my fullBounds in #doLayoutIn: (and #privateFullBounds). My layout will be re-computed then."		
	self bounds: box.
]

{ #category : #'layout-properties' }
Morph >> layoutInset [
	"Return the extra inset for layouts"
	| props |
	props := self layoutProperties.
	^props ifNil:[0] ifNotNil:[props layoutInset].
]

{ #category : #'layout-properties' }
Morph >> layoutInset: aNumber [
	"Return the extra inset for layouts"
	self assureTableProperties layoutInset: aNumber.
	self layoutChanged.
]

{ #category : #'layout-menu' }
Morph >> layoutMenuPropertyString: aSymbol from: currentSetting [ 
	| onOff wording |
	onOff := aSymbol == currentSetting
				ifTrue: ['<on>']
				ifFalse: ['<off>'].
	""
	wording := String
				streamContents: [:stream | 
					| index | 
					index := 1.
					aSymbol
						keysAndValuesDo: [:idx :ch | ch isUppercase
								ifTrue: [""stream nextPutAll: (aSymbol copyFrom: index to: idx - 1) asLowercase.
									stream nextPutAll: ' '.
									index := idx]].
					index < aSymbol size
						ifTrue: [stream nextPutAll: (aSymbol copyFrom: index to: aSymbol size) asLowercase]].
	""
	^ onOff , wording translated
]

{ #category : #'layout-properties' }
Morph >> layoutPolicy [
	"Layout specific. Return the layout policy describing how children 
	of the receiver should appear."
	^ extension ifNotNil: [ extension layoutPolicy]
]

{ #category : #'layout-properties' }
Morph >> layoutPolicy: aLayoutPolicy [
	"Layout specific. Return the layout policy describing how children of the receiver should appear."
	self layoutPolicy == aLayoutPolicy ifTrue:[^self].
	self assureExtension layoutPolicy: aLayoutPolicy.
	self layoutChanged.
]

{ #category : #'geometry - layout' }
Morph >> layoutPosition [

	^ self layoutBounds topLeft
]

{ #category : #'geometry - layout' }
Morph >> layoutPosition: aPoint [

	| prior delta |
	prior := self layoutBounds.
	delta := (aPoint - prior topLeft) rounded.
	self layoutBounds: (prior translateBy: delta).
]

{ #category : #'layout-properties' }
Morph >> layoutProperties [
	"Return the current layout properties associated with the  
	receiver"
	^ extension ifNotNil: [ extension layoutProperties]
]

{ #category : #'layout-properties' }
Morph >> layoutProperties: newProperties [
	"Return the current layout properties associated with the receiver"
	self layoutProperties == newProperties ifTrue:[^self].
	self assureExtension layoutProperties: newProperties.

]

{ #category : #layout }
Morph >> layoutProportionallyIn: newBounds [
	
	self flag: #deprecated. "No actual deprecation warning because of debugging hazards."
	self
		layoutProportionallyInBounds: newBounds
		positioning: (self owner ifNil: [#center] ifNotNil: [:o | o cellPositioning]).
]

{ #category : #layout }
Morph >> layoutProportionallyInBounds: layoutBounds positioning: cellPositioning [
	"Layout specific. Apply the given bounds to the receiver."
	| cellBounds frame |
	frame := self layoutFrame ifNil:[^self].
	"compute the cell size the receiver has given its layout frame"
	
	cellBounds := frame layout: self bounds in: layoutBounds.
	cellBounds := cellBounds topLeft extent: (cellBounds extent max: self minExtent).
	
	cellBounds = self bounds ifTrue: [^self]. "no change"
	^self layoutInBounds: cellBounds positioning: cellPositioning
]

{ #category : #geometry }
Morph >> left [
	" Return the x-coordinate of my left side "

	^ bounds left
]

{ #category : #geometry }
Morph >> left: aNumber [
	" Move me so that my left side is at the x-coordinate aNumber. My extent (width & height) are unchanged "

	self position: (aNumber @ bounds top)
]

{ #category : #geometry }
Morph >> leftCenter [

	^ bounds leftCenter
]

{ #category : #'layout-properties' }
Morph >> listCentering [
	"Layout specific. This property describes how the rows/columns in a list-like layout should be centered.
		#topLeft - center at start of primary direction
		#bottomRight - center at end of primary direction
		#center - center in the middle of primary direction
		#justified - insert extra space inbetween rows/columns
	"
	| props |
	props := self layoutProperties.
	^props ifNil:[#topLeft] ifNotNil:[props listCentering].
]

{ #category : #'layout-properties' }
Morph >> listCentering: aSymbol [
	"Layout specific. This property describes how the rows/columns in a list-like layout should be centered.
		#topLeft - center at start of primary direction
		#bottomRight - center at end of primary direction
		#center - center in the middle of primary direction
		#justified - insert extra space inbetween rows/columns
	"
	self assureTableProperties listCentering: aSymbol.
	self layoutChanged.
]

{ #category : #'layout-properties' }
Morph >> listCenteringString: aSymbol [
	^self layoutMenuPropertyString: aSymbol from: self listCentering
]

{ #category : #'layout-properties' }
Morph >> listDirection [
	"Layout specific. This property describes the direction in which a list-like layout should be applied. Possible values are:
		#leftToRight
		#rightToLeft
		#topToBottom
		#bottomToTop
	indicating the direction in which any layout should take place"
	| props |
	props := self layoutProperties.
	^props ifNil:[#topToBottom] ifNotNil:[props listDirection].
]

{ #category : #'layout-properties' }
Morph >> listDirection: aSymbol [
	"Layout specific. This property describes the direction in which a list-like layout should be applied. Possible values are:
		#leftToRight
		#rightToLeft
		#topToBottom
		#bottomToTop
	indicating the direction in which any layout should take place"
	self assureTableProperties listDirection: aSymbol.
	self layoutChanged.
]

{ #category : #'layout-properties' }
Morph >> listDirectionString: aSymbol [
	^self layoutMenuPropertyString: aSymbol from: self listDirection
]

{ #category : #'layout-properties' }
Morph >> listSpacing [
	"Layout specific. This property describes how the heights for different rows in a table layout should be handled.
		#equal - all rows have the same height
		#none - all rows may have different heights
	"
	| props |
	props := self layoutProperties.
	^props ifNil:[#none] ifNotNil:[props listSpacing].
]

{ #category : #'layout-properties' }
Morph >> listSpacing: aSymbol [
	"Layout specific. This property describes how the heights for different rows in a table layout should be handled.
		#equal - all rows have the same height
		#none - all rows may have different heights
	"
	self checkListSpacingProperty: aSymbol.
	self assureTableProperties listSpacing: aSymbol.
	self layoutChanged.
]

{ #category : #'layout-properties' }
Morph >> listSpacingString: aSymbol [
	^self layoutMenuPropertyString: aSymbol from: self listSpacing
]

{ #category : #caching }
Morph >> loadCachedState [
	"Load the cached state of this morph. This method may be called to pre-load the cached state of a morph to avoid delays when it is first used. (Cached state can always be recompued on demand, so a morph should not rely on this method being called.) Implementations of this method should do 'super loadCachedState'. This default implementation does nothing."

]

{ #category : #'geometry - local\/global' }
Morph >> localPointToGlobal: aPoint [
	^self point: aPoint in: nil
]

{ #category : #accessing }
Morph >> lock [
	self lock: true
]

{ #category : #accessing }
Morph >> lock: aBoolean [ 
	"change the receiver's lock property"
	(extension isNil and: [aBoolean not]) ifTrue: [^ self].
	self assureExtension locked: aBoolean
]

{ #category : #menus }
Morph >> lockUnlockMorph [
	"If the receiver is locked, unlock it; if unlocked, lock it"

	self isLocked ifTrue: [self unlock] ifFalse: [self lock]
]

{ #category : #menus }
Morph >> lockedString [
	"Answer the string to be shown in a menu to represent the 
	'locked' status"
	^ (self isLocked
		ifTrue: ['<on>']
		ifFalse: ['<off>']), 'be locked' translated
]

{ #category : #'submorphs-accessing' }
Morph >> mainDockingBars [
	"Answer the receiver's main dockingBars"
	^ self dockingBars
		select: [:each | each hasProperty: #mainDockingBarTimeStamp]
]

{ #category : #'e-toy support' }
Morph >> makeGraphPaper [
	| smallGrid backColor lineColor |
	smallGrid := Compiler evaluate: (UIManager default request: 'Enter grid size' translated initialAnswer: '16').
	smallGrid ifNil: [^ self].
	UIManager default informUser: 'Choose a background color' translated during: [backColor := Color fromUser].
	UIManager default informUser: 'Choose a line color' translated during: [lineColor := Color fromUser].
	self makeGraphPaperGrid: smallGrid background: backColor line: lineColor.
]

{ #category : #'e-toy support' }
Morph >> makeGraphPaperGrid: smallGrid background: backColor line: lineColor [

	| gridForm |
	gridForm := self gridFormOrigin: 0@0 grid: smallGrid asPoint background: backColor line: lineColor.
	self color: gridForm.
	self world ifNotNil: [self world fullRepaintNeeded].
	self changed: #newColor.  "propagate to view"

]

{ #category : #'meta-actions' }
Morph >> makeMultipleSiblings: evt [
	"Make multiple siblings, first prompting the user for how many"

	| result |
	self topRendererOrSelf couldMakeSibling ifFalse: [^ Beeper beep].
	result := UIManager default request: 'how many siblings do you want?' translated initialAnswer: '2'.
	result isEmptyOrNil ifTrue: [^ self].
	result first isDigit ifFalse: [^ Beeper beep].
	self topRendererOrSelf makeSiblings: result asInteger.
]

{ #category : #menus }
Morph >> makeNascentScript [
	^ self notYetImplemented
]

{ #category : #'meta-actions' }
Morph >> makeNewPlayerInstance: evt [
	"Make a duplicate of the receiver's argument.  This is called only where the argument has an associated Player as its costumee, and the intent here is to make another instance of the same uniclass as the donor Player itself.  Much works, but there are flaws so this shouldn't be used without recognizing the risks"

	evt hand attachMorph: self usableSiblingInstance
]

{ #category : #'meta-actions' }
Morph >> makeSiblings: count [
	"Make multiple sibling, and return the list"

	| listOfNewborns aPosition |
	aPosition := self position.
	listOfNewborns := (1 to: count asInteger) asArray collect: 
		[:anIndex | | anInstance |
			anInstance := self usableSiblingInstance.
			owner addMorphFront: anInstance.
			aPosition := aPosition + (10@10).
			anInstance position: aPosition.
			anInstance].
	self currentWorld startSteppingSubmorphsOf: self topRendererOrSelf owner.
	^ listOfNewborns
]

{ #category : #'meta-actions' }
Morph >> makeSiblingsLookLikeMe: evt [
	"Make all my siblings wear the same costume that I am wearing."

	| aPlayer |
	(aPlayer := self topRendererOrSelf player) belongsToUniClass ifFalse: [self error: 'not uniclass'].
	aPlayer class allInstancesDo:
		[:anInstance | anInstance == aPlayer ifFalse:
			[anInstance wearCostumeOf: aPlayer]]
]

{ #category : #'parts bin' }
Morph >> markAsPartsDonor [
	"Mark the receiver specially so that mouse actions on it are interpreted as 'tearing off a copy'"

	self isPartsDonor: true
]

{ #category : #'layout-properties' }
Morph >> maxCellSize [
	"Layout specific. This property specifies the maximum size of a table cell."
	| props |
	props := self layoutProperties.
	^props ifNil:[SmallInteger maxVal] ifNotNil:[props maxCellSize].
]

{ #category : #'layout-properties' }
Morph >> maxCellSize: aPoint [
	"Layout specific. This property specifies the maximum size of a table cell."
	self assureTableProperties maxCellSize: aPoint.
	self layoutChanged.
]

{ #category : #menus }
Morph >> maybeAddCollapseItemTo: aMenu [
	"If appropriate, add a collapse item to the given menu"

	| anOwner |
	(anOwner := self topRendererOrSelf owner) ifNotNil:
			[anOwner isWorldMorph ifTrue:
				[aMenu add: 'collapse' translated target: self action: #collapse]]
]

{ #category : #'meta-actions' }
Morph >> maybeDuplicateMorph [
	"Maybe duplicate the morph"

	self okayToDuplicate ifTrue:
		[self topRendererOrSelf duplicate openInHand]
]

{ #category : #'meta-actions' }
Morph >> maybeDuplicateMorph: evt [
	self okayToDuplicate ifTrue:[^self duplicateMorph: evt]
]

{ #category : #'other events' }
Morph >> menuButtonMouseEnter: event [
	"The mouse entered a menu-button area; show the menu cursor temporarily"

	event hand showTemporaryCursor: Cursor menu
]

{ #category : #'other events' }
Morph >> menuButtonMouseLeave: event [
	"The mouse left a menu-button area; restore standard cursor"

	event hand showTemporaryCursor: nil
]

{ #category : #menus }
Morph >> menuItemAfter: menuString [
	| allWordings |
	allWordings := self allMenuWordings.
	^ allWordings atWrap: ((allWordings indexOf: menuString) + 1)
]

{ #category : #menus }
Morph >> menuItemBefore: menuString [
	| allWordings |
	allWordings := self allMenuWordings.
	^ allWordings atWrap: ((allWordings indexOf: menuString) - 1)
]

{ #category : #accessing }
Morph >> methodCommentAsBalloonHelp [
	"Given that I am a morph that is associated with an object and a method, answer a suitable method comment relating to that object & method if possible"

	| inherentSelector actual |
	(inherentSelector := self valueOfProperty: #inherentSelector)
		ifNotNil:
			[(actual := (self firstOwnerSuchThat:[:m| m isPhraseTileMorph or:[m isSyntaxMorph]]) actualObject) ifNotNil:
				[^ actual class precodeCommentOrInheritedCommentFor: inherentSelector]].
	^ nil
]

{ #category : #'layout-properties' }
Morph >> minCellSize [
	"Layout specific. This property specifies the minimal size of a table cell."
	| props |
	props := self layoutProperties.
	^props ifNil:[0] ifNotNil:[props minCellSize].
]

{ #category : #'layout-properties' }
Morph >> minCellSize: aPoint [
	"Layout specific. This property specifies the minimal size of a table cell."
	self assureTableProperties minCellSize: aPoint.
	self layoutChanged.
]

{ #category : #layout }
Morph >> minExtent [
	"Layout specific. Return the minimum size the receiver can be represented in.
	Implementation note: When this message is sent from an owner trying to lay out its children it will traverse down the morph tree and recompute the minimal arrangement of the morphs based on which the minimal extent is returned. When a morph with some layout strategy is encountered, the morph will ask its strategy to compute the new arrangement. However, since the final size given to the receiver is unknown at the point of the query, the assumption is made that the current bounds of the receiver are the base on which the layout should be computed. This scheme prevents strange layout changes when for instance, a table is contained in another table. Unless the inner table has been resized manually (which means its bounds are already enlarged) the arrangement of the inner table will not change here. Thus the entire layout computation is basically an iterative process which may have different results depending on the incremental changes applied."

	| layout minExtent extra hFit vFit |
	hFit := self hResizing.
	vFit := self vResizing.
	
	(self owner isNil or: [self owner layoutPolicy isNil])
		ifTrue: [
			hFit == #spaceFill ifTrue: [hFit := #rigid].
			vFit == #spaceFill ifTrue: [vFit := #rigid]].

	"0) The receiver will not adjust to parents layout by growing or shrinking, which means that an accurate layout defines the minimum size. So, compute the layout and return its bounds as minimal extent. DO NOT return fullBounds because the morph itself is being layed out."
	(hFit == #spaceFill or: [vFit == #spaceFill]) 
		ifFalse: [self fullBounds. ^ self bounds extent].

	"1) Ask the layout policy to compute the minimum extent."
	layout := self layoutPolicy.
	layout isNil 
		ifTrue: [minExtent := 0@0]
		ifFalse: [minExtent := layout minExtentOf: self in: self layoutBounds].

	"2) #rigid fitting has to stay as is." 
	hFit == #rigid 
		ifTrue: [minExtent := self width @ minExtent y].
	vFit == #rigid 
		ifTrue: [minExtent := minExtent x @ self height].

	"3) #spaceFill fitting has to account for layout inset."
	hFit == #spaceFill
		ifTrue: [
			(vFit == #shrinkWrap and: [self wrapDirection ~= #none])
				ifTrue: [minExtent := 1 @ minExtent y "Give h-space a chance to v-wrap and v-shrink."]
				ifFalse: [
					extra := self bounds width - self layoutBounds width.
					minExtent := (minExtent x + extra) @ minExtent y]].
	vFit == #spaceFill
		ifTrue: [
			(hFit == #shrinkWrap and: [self wrapDirection ~= #none])
				ifTrue: [minExtent := minExtent x @ 1 "Give v-space a chance to h-wrap and h-shrink."]
				ifFalse: [
					extra := self bounds height - self layoutBounds height.
					minExtent := minExtent x @ (minExtent y + extra)]].

	"4) #shrinkWrap fitting has to support height-for-width (or width-for-height)."
	hFit == #shrinkWrap
		ifTrue: [
			self fullBounds. "Compute layout now to get shrink-wrapped width."
			minExtent := self width @ minExtent y].
	vFit == #shrinkWrap
		ifTrue: [
			self fullBounds. "Compute layout now to get shrink-wrapped height."
			minExtent := minExtent x @ self height].

	"5) For morphs without submorphs (or without a layout policy), be sure to overwrite #doLayoutIn: and use #minWidth and #minHeight to implement #shrinkWrap such as in MenuItemMorph."
	^ minExtent max: self minWidth @ self minHeight
]

{ #category : #layout }
Morph >> minExtent: aPoint [

	self error: 'Use #minimumExtent: if you want to set a minimum extent. #minExtent is a layout policy-specific callback.'
]

{ #category : #layout }
Morph >> minHeight [
	"Layout specific. If you don't use a layout policy but claim to be #shrinkWrap on the vertical axis, use #minHeight to answer that shrink-wrapped height. See MenuItemMorph."

	^ self
		valueOfProperty: #minHeight
		ifAbsent: [1]
]

{ #category : #layout }
Morph >> minHeight: aNumber [ 
	aNumber isNil 
		ifTrue: [self removeProperty: #minHeight]
		ifFalse: [self setProperty: #minHeight toValue: aNumber].
	self layoutChanged
]

{ #category : #layout }
Morph >> minWidth [
	"Layout specific. If you don't use a layout policy but claim to be #shrinkWrap on the horizontal axis, use #minWidth to answer that shrink-wrapped width."

	^ self
		valueOfProperty: #minWidth
		ifAbsent: [1]
]

{ #category : #layout }
Morph >> minWidth: aNumber [ 
	aNumber isNil 
		ifTrue: [self removeProperty: #minWidth]
		ifFalse: [self setProperty: #minWidth toValue: aNumber].
	self layoutChanged
]

{ #category : #'geometry - layout' }
Morph >> minimumExtent [
	
	^ self minWidth @ self minHeight
]

{ #category : #'geometry - layout' }
Morph >> minimumExtent: aPoint [
	"Do not shrink below this extent."

	self
		minWidth: aPoint x;
		minHeight: aPoint y.
]

{ #category : #'geometry - layout' }
Morph >> minimumHeight [
	"Wrapper for layout-specific function to avoid confusion."
	
	^ self minHeight
]

{ #category : #'geometry - layout' }
Morph >> minimumHeight: aNumber [
	"Wrapper for layout-specific function to avoid confusion."
	
	self minHeight: aNumber.
]

{ #category : #'geometry - layout' }
Morph >> minimumWidth [
	"Wrapper for layout-specific function to avoid confusion."
	
	^ self minWidth
]

{ #category : #'geometry - layout' }
Morph >> minimumWidth: aNumber [
	"Wrapper for layout-specific function to avoid confusion."
	
	self minWidth: aNumber.
]

{ #category : #polymorph }
Morph >> modalLockTo: aSystemWindow [
	"Lock the receiver as a modal owner of the given window."

	self lock
]

{ #category : #polymorph }
Morph >> modalUnlockFrom: aSystemWindow [
	"Unlock the receiver as a modal owner of the given window."

	self unlock
]

{ #category : #menus }
Morph >> model [
	^ nil 
]

{ #category : #accessing }
Morph >> modelOrNil [
	^ nil
]

{ #category : #'model access' }
Morph >> models [
	"Answer a collection of whatever models I may have."
	^ self modelOrNil
		ifNil: [ Array empty ]
		ifNotNil: [ Array with: self modelOrNil ]
]

{ #category : #testing }
Morph >> modificationHash [

	^String 
		streamContents: [ :strm |
			self longPrintOn: strm
		]
		limitedTo: 25

]

{ #category : #structure }
Morph >> morphPreceding: aSubmorph [
	"Answer the morph immediately preceding aSubmorph, or nil if none"

	| index |
	(index := submorphs indexOf: aSubmorph) > 1 ifTrue: [
		^submorphs at: index - 1 ].
	^nil
]

{ #category : #printing }
Morph >> morphReport [

	^self morphReportFor: #(hResizing vResizing bounds)
]

{ #category : #printing }
Morph >> morphReportFor: attributeList [

	| s |

	s := WriteStream on: String new.
	self
		morphReportFor: attributeList 
		on: s 
		indent: 0.
	StringHolder new contents: s contents; openLabel: 'morph report'
]

{ #category : #printing }
Morph >> morphReportFor: attributeList on: aStream indent: anInteger [

	anInteger timesRepeat: [aStream tab].
	aStream print: self; space.
	attributeList do: [ :a | aStream print: (self perform: a); space].
	aStream cr.
	submorphs do: [ :sub |
		sub morphReportFor: attributeList on: aStream indent: anInteger + 1
	].
]

{ #category : #thumbnail }
Morph >> morphRepresented [
	"If the receiver is an alias, answer the morph it represents; else answer self"

	^ self
]

{ #category : #'dropping\/grabbing' }
Morph >> morphToDropInPasteUp: aPasteUp [
	^ self
]

{ #category : #'WiW support' }
Morph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^(owner isNil or: [owner isWorldMorph]) ifTrue: [
		self valueOfProperty: #morphicLayerNumber ifAbsent: [100]
	] ifFalse: [
		owner morphicLayerNumber
	].

	"leave lots of room for special things"
]

{ #category : #'WiW support' }
Morph >> morphicLayerNumberWithin: anOwner [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^(owner isNil or: [owner isWorldMorph or: [anOwner == owner]]) ifTrue: [
		self valueOfProperty: #morphicLayerNumber ifAbsent: [100]
	] ifFalse: [
		owner morphicLayerNumber
	].

	"leave lots of room for special things"
]

{ #category : #'submorphs-accessing' }
Morph >> morphsAt: aPoint [
	"Return a collection of all morphs in this morph structure that contain the given point, possibly including the receiver itself.  The order is deepest embedding first."
	^self morphsAt: aPoint unlocked: false
]

{ #category : #'submorphs-accessing' }
Morph >> morphsAt: aPoint behind: aMorph unlocked: aBool [ 
	"Return all morphs at aPoint that are behind frontMorph; if aBool is true return only unlocked, visible morphs."

	| isBack all tfm |
	all := (aMorph isNil or: [owner isNil]) 
				ifTrue: 
					["Traverse down"

					(self fullBounds containsPoint: aPoint) ifFalse: [^#()].
					(aBool and: [self isLocked or: [self visible not]]) ifTrue: [^#()].
					nil]
				ifFalse: 
					["Traverse up"

					tfm := self transformedFrom: owner.
					all := owner 
								morphsAt: (tfm localPointToGlobal: aPoint)
								behind: self
								unlocked: aBool.
					WriteStream with: all].
	isBack := aMorph isNil.
	self submorphsDo: 
			[:m | | found | 
			isBack 
				ifTrue: 
					[tfm := m transformedFrom: self.
					found := m 
								morphsAt: (tfm globalPointToLocal: aPoint)
								behind: nil
								unlocked: aBool.
					found notEmpty 
						ifTrue: 
							[all ifNil: [all := WriteStream on: #()].
							all nextPutAll: found]].
			m == aMorph ifTrue: [isBack := true]].
	(isBack and: [self containsPoint: aPoint]) 
		ifTrue: 
			[all ifNil: [^Array with: self].
			all nextPut: self].
	^all ifNil: [#()] ifNotNil: [all contents]
]

{ #category : #'submorphs-accessing' }
Morph >> morphsAt: aPoint unlocked: aBool [
	"Return a collection of all morphs in this morph structure that contain the given point, possibly including the receiver itself.  The order is deepest embedding first."
	| mList |
	mList := WriteStream on: #().
	self morphsAt: aPoint unlocked: aBool do:[:m| mList nextPut: m].
	^mList contents
]

{ #category : #'submorphs-accessing' }
Morph >> morphsAt: aPoint unlocked: aBool do: aBlock [
	"Evaluate aBlock with all the morphs starting at the receiver which appear at aPoint. If aBool is true take only visible, unlocked morphs into account."
	
	(self fullBounds containsPoint: aPoint) ifFalse:[^self].
	(aBool and:[self isLocked or:[self visible not]]) ifTrue:[^self].
	self submorphsDo:[:m| | tfm |
		tfm := m transformedFrom: self.
		m morphsAt: (tfm globalPointToLocal: aPoint) unlocked: aBool do: aBlock].
	(self containsPoint: aPoint) ifTrue:[aBlock value: self].
]

{ #category : #'submorphs-accessing' }
Morph >> morphsInFrontOf: someMorph overlapping: aRectangle do: aBlock [
	"Evaluate aBlock with all top-level morphs in front of someMorph that overlap with the given rectangle. someMorph is either an immediate child of the receiver or nil (in which case all submorphs of the receiver are enumerated)."
	self submorphsDo:[:m|
		m == someMorph ifTrue:["Try getting out quickly"
			owner ifNil:[^self].
			^owner morphsInFrontOf: self overlapping: aRectangle do: aBlock].
		(m fullBoundsInWorld intersects: aRectangle)
			ifTrue:[aBlock value: m]].
	owner ifNil:[^self].
	^owner morphsInFrontOf: self overlapping: aRectangle do: aBlock.
]

{ #category : #'submorphs-accessing' }
Morph >> morphsInFrontOverlapping: aRectangle [
	"Return all top-level morphs in front of someMorph that overlap with the given rectangle."
	| morphList |
	morphList := WriteStream on: Array new.
	self morphsInFrontOf: nil overlapping: aRectangle do:[:m | morphList nextPut: m].
	^morphList contents
]

{ #category : #'submorphs-accessing' }
Morph >> morphsInFrontOverlapping: aRectangle do: aBlock [
	"Evaluate aBlock with all top-level morphs in front of someMorph that overlap with the given rectangle."
	^self morphsInFrontOf: nil overlapping: aRectangle do: aBlock
]

{ #category : #'events-filtering-bubbling' }
Morph >> mouseBubbleFilters [
	^ self valueOfProperty: #mouseBubbleFilters
]

{ #category : #'events-filtering-bubbling' }
Morph >> mouseBubbleFilters: anArrayOrNil [
	^ self setProperty: #mouseBubbleFilters toValue: anArrayOrNil
]

{ #category : #'events-filtering-capturing' }
Morph >> mouseCaptureFilters [
	^ self valueOfProperty: #mouseCaptureFilters
]

{ #category : #'events-filtering-capturing' }
Morph >> mouseCaptureFilters: anArrayOrNil [
	^ self setProperty: #mouseCaptureFilters toValue: anArrayOrNil
]

{ #category : #'event handling' }
Morph >> mouseDown: evt [ 
	"Handle a mouse down event. The default response is to let my 
	eventHandler, if any, handle it."

	self eventHandler
		ifNotNil: [self eventHandler mouseDown: evt fromMorph: self].

	"Check for option (menu) click"
	evt yellowButtonPressed
		ifTrue: [^ self yellowButtonActivity: evt shiftPressed].

]

{ #category : #'halos and balloon help' }
Morph >> mouseDownOnHelpHandle: anEvent [
	"The mouse went down in the show-balloon handle"
	
	| str |
	anEvent shiftPressed ifTrue: [^ self editBalloonHelpText].
	str := self balloonText.
	str ifNil: [str := self noHelpString].
	self showBalloon: str hand: anEvent hand.

]

{ #category : #'events-processing' }
Morph >> mouseDownPriority [
	"Return the default mouse down priority for the receiver. This supports a morph to get mouse down before one of its children."

	^ self
		valueOfProperty: #mouseDownPriority
		ifAbsent: [(self isPartsDonor or: [self isPartsBin])
			ifTrue:	[50]
			ifFalse:	[0]].
		
	"The above is a workaround for the complete confusion between parts donors and parts bins. Morphs residing in a parts bin may or may not have the parts donor property set; if they have they may or may not actually handle events. To work around this, parts bins get an equal priority to parts donors so that when a morph in the parts bin does have the property set but does not handle the event we still get a copy from picking it up through the parts bin. Argh. This just *cries* for a cleanup."
	"And the above comment is Andreas's from 10/2000, which was formerly retrievable by a #flag: call which however caused a problem when trying to recompile the method from decompiled source."
]

{ #category : #'events-processing' }
Morph >> mouseDownPriority: anInteger [
	
	anInteger = 0 ifTrue: [^ self removeProperty: #mouseDownPriority].
	
	self
		setProperty: #mouseDownPriority
		toValue: anInteger.
]

{ #category : #'event handling' }
Morph >> mouseEnter: evt [
	"Handle a mouseEnter event, meaning the mouse just entered my bounds with no button pressed. The default response is to let my eventHandler, if any, handle it."

	self eventHandler ifNotNil:
		[self eventHandler mouseEnter: evt fromMorph: self].

]

{ #category : #'event handling' }
Morph >> mouseEnterDragging: evt [
	"Handle a mouseEnterDragging event, meaning the mouse just entered my bounds with a button pressed or laden with submorphs.  The default response is to let my eventHandler, if any, handle it, or else to do nothing."

	self eventHandler ifNotNil:
		[^ self eventHandler mouseEnterDragging: evt fromMorph: self].

]

{ #category : #'event handling' }
Morph >> mouseLeave: evt [
	"Handle a mouseLeave event, meaning the mouse just left my bounds with no button pressed. The default response is to let my eventHandler, if any, handle it."

	self eventHandler ifNotNil:
		[self eventHandler mouseLeave: evt fromMorph: self].

]

{ #category : #'event handling' }
Morph >> mouseLeaveDragging: evt [
	"Handle a mouseLeaveLaden event, meaning the mouse just left my bounds with a button pressed or laden with submorphs. The default response is to let my eventHandler, if any, handle it; else to do nothing."

	self eventHandler ifNotNil:
		[self eventHandler mouseLeaveDragging: evt fromMorph: self]
]

{ #category : #'event handling' }
Morph >> mouseMove: evt [
	"Handle a mouse move event. The default response is to let my eventHandler, if any, handle it."
	self eventHandler ifNotNil:
		[self eventHandler mouseMove: evt fromMorph: self].

]

{ #category : #'event handling' }
Morph >> mouseStillDown: evt [
	"Handle a mouse move event. The default response is to let my eventHandler, if any, handle it."

	self eventHandler ifNotNil:
		[self eventHandler mouseStillDown: evt fromMorph: self].

]

{ #category : #geniestubs }
Morph >> mouseStillDownStepRate [
	"At what rate do I want to receive #mouseStillDown: notifications?"
	^1
]

{ #category : #'event handling' }
Morph >> mouseStillDownThreshold [
	"Return the number of milliseconds after which mouseStillDown: should be sent"
	^200
]

{ #category : #'event handling' }
Morph >> mouseUp: evt [
	"Handle a mouse up event. The default response is to let my eventHandler, if any, handle it."

	self eventHandler ifNotNil:
		[self eventHandler mouseUp: evt fromMorph: self].

]

{ #category : #'debug and other' }
Morph >> mouseUpCodeOrNil [
	"If the receiver has a mouseUpCodeToRun, return it, else return nil"

	^ self valueOfProperty: #mouseUpCodeToRun ifAbsent: [nil]
]

{ #category : #'event handling' }
Morph >> mouseWheel: anEvent [ 
	"Handle a mouse wheel event. The default response is to let my eventHandler, if any, handle it."

	self eventHandler ifNotNil: [:handler |
		handler mouseWheel: anEvent fromMorph: self].
]

{ #category : #'event handling' }
Morph >> moveOrResizeFromKeystroke: anEvent [ 
	"move or resize the receiver based on a keystroke"
	| dir | 

	anEvent keyValue = 28 ifTrue: [dir := -1 @ 0].
	anEvent keyValue = 29 ifTrue: [dir := 1 @ 0].
	anEvent keyValue = 30 ifTrue: [dir := 0 @ -1].
	anEvent keyValue = 31 ifTrue: [dir := 0 @ 1].

	dir notNil
		ifTrue:[
			anEvent controlKeyPressed ifTrue: [dir := dir * 10].

			anEvent shiftPressed
				ifTrue: [self extent: self extent + dir]
				ifFalse: [self position: self position + dir].

			"anEvent wasHandled: true."
	]

]

{ #category : #'e-toy support' }
Morph >> mustBeBackmost [
	"Answer whether the receiver needs to be the backmost morph in its owner's submorph list"

	^ false
]

{ #category : #naming }
Morph >> name: aName [ 
	(aName isString) ifTrue: [self setNameTo: aName]
]

{ #category : #naming }
Morph >> nameForFindWindowFeature [
	"Answer the name to show in a list of windows-and-morphs to represent the receiver"

	^ self knownName ifNil: [self class name]
]

{ #category : #'dropping\/grabbing' }
Morph >> nameForUndoWording [
	"Return wording appropriate to the receiver for use in an undo-related menu item (and perhaps elsewhere)"

	| aName |
	aName := self knownName ifNil: [self renderedMorph class name].
	^ aName truncateTo: 24
]

{ #category : #naming }
Morph >> nameInModel [
	"Return the name for this morph in the underlying model or nil."

	| w |
	w := self world.
	w isNil ifTrue: [^nil] ifFalse: [^w model nameFor: self]
]

{ #category : #naming }
Morph >> nameOfObjectRepresented [
	"Answer the external name of the object represented"

	^ self externalName
]

{ #category : #structure }
Morph >> nearestOwnerThat: conditionBlock [
	"Return the first enclosing morph for which aBlock evaluates to true, or nil if none"

	^ self firstOwnerSuchThat: conditionBlock

]

{ #category : #'rotate scale and flex' }
Morph >> newTransformationMorph [
	^TransformationMorph new
]

{ #category : #'halos and balloon help' }
Morph >> noHelpString [
	^ 'Help not yet supplied' translated
]

{ #category : #'e-toy support' }
Morph >> noteDecimalPlaces: aNumber forGetter: aGetter [
	"Make a mental note of the user's preference for a particular number of decimal places to be associated with the slot with the given getter"

	(self renderedMorph valueOfProperty: #decimalPlacePreferences ifAbsentPut: [IdentityDictionary new])
		at: aGetter put: aNumber
]

{ #category : #'submorphs-accessing' }
Morph >> noteNewOwner: aMorph [
	"I have just been added as a submorph of aMorph"
]

{ #category : #'objects from disk' }
Morph >> objectForDataStream: refStrm [ 
	"I am being written out on an object file"

	| dp |
	self sqkPage ifNotNil: 
			[refStrm rootObject == self | (refStrm rootObject == self sqkPage) 
				ifFalse: 
					[self url notEmpty 
						ifTrue: 
							[dp := self sqkPage copyForSaving.	"be careful touching this object!"
							refStrm replace: self with: dp.
							^dp]]].
	self prepareToBeSaved.	"Amen"
	^self
]

{ #category : #'e-toy support' }
Morph >> objectViewed [
	"Answer the morph associated with the player that the structure the receiver currently finds itself within represents."

	^ (self outermostMorphThat: [:o | o isViewer or:[ o isScriptEditorMorph]]) objectViewed

]

{ #category : #'geometry testing' }
Morph >> obtrudesBeyondContainer [
	"Answer whether the receiver obtrudes beyond the bounds of its container"

	| top formerOwner |
	top := self topRendererOrSelf.
	top owner ifNil: [^ false].
	^ top owner isHandMorph
		ifTrue:
			[((formerOwner := top formerOwner) notNil and: [formerOwner isInWorld])
				ifFalse:
					[false]
				ifTrue:
					[(formerOwner boundsInWorld containsRect: top boundsInWorld) not]]
		ifFalse:
			[(top owner bounds containsRect: top bounds) not]
]

{ #category : #menu }
Morph >> offerCostumeViewerMenu: aMenu [
	"do nothing"
]

{ #category : #'halos and balloon help' }
Morph >> okayToAddDismissHandle [
	"Answer whether a halo on the receiver should offer a dismiss handle.  This provides a hook for making it harder to disassemble some strucures even momentarily"

	^ self resistsRemoval not
]

{ #category : #'halos and balloon help' }
Morph >> okayToAddGrabHandle [
	"Answer whether a halo on the receiver should offer a grab handle.  This provides a hook for making it harder to deconstruct some strucures even momentarily"

	^ true
]

{ #category : #'halos and balloon help' }
Morph >> okayToBrownDragEasily [
	"Answer whether it it okay for the receiver to be brown-dragged easily -- i.e. repositioned within its container without extracting it.  At present this is just a hook -- nobody declines."

	^ true



"
	^ (self topRendererOrSelf owner isKindOf: PasteUpMorph) and:
		[self layoutPolicy isNil]"
]

{ #category : #player }
Morph >> okayToDuplicate [
	"Formerly this protocol was used to guard against awkward situations when there were anonymous scripts in the etoy system.  Nowadays we just always allow duplication"

	^ true
]

{ #category : #'halos and balloon help' }
Morph >> okayToExtractEasily [
	"Answer whether it it okay for the receiver to be extracted easily.  Not yet hooked up to the halo-permissions mechanism."

	^ self topRendererOrSelf owner dragNDropEnabled
]

{ #category : #'halos and balloon help' }
Morph >> okayToResizeEasily [
	"Answer whether it is appropriate to have the receiver be easily resized by the user from the halo"

	^ true

	"This one was too jarring, not that it didn't most of the time do the right  thing but because some of the time it didn't, such as in a holder.  If we pursue this path, the test needs to be airtight, obviously...
	^ (self topRendererOrSelf owner isKindOf: PasteUpMorph) and:
		[self layoutPolicy isNil]"
]

{ #category : #'halos and balloon help' }
Morph >> okayToRotateEasily [
	"Answer whether it is appropriate for a rotation handle to be shown for the receiver.  This is a hook -- at present nobody declines."

	^ true
]

{ #category : #'event handling' }
Morph >> on: eventName send: selector to: recipient [
	self eventHandler ifNil: [self eventHandler: EventHandler new].
	self eventHandler on: eventName send: selector to: recipient
]

{ #category : #'event handling' }
Morph >> on: eventName send: selector to: recipient withValue: value [
	"NOTE: selector must take 3 arguments, of which value will be the *** FIRST ***"

	self eventHandler ifNil: [self eventHandler: EventHandler new].
	self eventHandler on: eventName send: selector to: recipient withValue: value

]

{ #category : #'meta-actions' }
Morph >> openAPropertySheet [

	Smalltalk at: #ObjectPropertiesMorph ifPresent:[:aClass|
		^aClass basicNew
			targetMorph: self;
			initialize;
			openNearTarget
	].
	Beeper beep.
]

{ #category : #'meta-actions' }
Morph >> openATextPropertySheet [

	"should only be sent to morphs that are actually supportive"

	Smalltalk at: #TextPropertiesMorph ifPresent:[:aClass|
		^aClass basicNew
			targetMorph: self;
			initialize;
			openNearTarget
	].
	Beeper beep.
]

{ #category : #initialization }
Morph >> openCenteredInWorld [

	self 
		fullBounds;
		position: Display extent - self extent // 2;
		openInWorld.
]

{ #category : #initialization }
Morph >> openInHand [
	"Attach the receiver to the current hand in the current morphic world"

	self currentHand attachMorph: self
]

{ #category : #initialization }
Morph >> openInWindow [

	^self openInWindowLabeled: self defaultLabelForInspector

]

{ #category : #initialization }
Morph >> openInWindowLabeled: aString [

	^self openInWindowLabeled: aString inWorld: self currentWorld
]

{ #category : #initialization }
Morph >> openInWindowLabeled: aString inWorld: aWorld [

	| window extent |

	window := (SystemWindow labelled: aString) model: nil.
	window 
		" guess at initial extent"
		bounds:  (RealEstateAgent initialFrameFor: window initialExtent: self fullBounds extent world: aWorld);
		addMorph: self frame: (0@0 extent: 1@1);
		updatePaneColors.
	" calculate extent after adding in case any size related attributes were changed.  Use
	fullBounds in order to trigger re-layout of layout morphs"
	extent := self fullBounds extent
		+ (window extent - window layoutBounds extent).
	window extent: extent.
	aWorld addMorph: window.
	window beKeyWindow.
	aWorld startSteppingSubmorphsOf: window.
	^window

]

{ #category : #initialization }
Morph >> openInWorld [
        "Add this morph to the world."

      self openInWorld: self currentWorld.
]

{ #category : #initialization }
Morph >> openInWorld: aWorld [
	"Add this morph to the requested World."
	(aWorld visibleClearArea origin ~= (0@0) and: [self position = (0@0)]) ifTrue:
		[self position: aWorld visibleClearArea origin].
	aWorld addMorph: self.
	aWorld startSteppingSubmorphsOf: self
]

{ #category : #polymorph }
Morph >> openModal: aSystemWindow [
	"Open the given window locking the receiver until it is dismissed.
	Answer the system window.
	Restore the original keyboard focus when closed."

	|area mySysWin keyboardFocus|
	keyboardFocus := self activeHand keyboardFocus.
	mySysWin := self isSystemWindow ifTrue: [self] ifFalse: [self ownerThatIsA: SystemWindow].
	mySysWin ifNil: [mySysWin := self].
	mySysWin modalLockTo: aSystemWindow.
	area := RealEstateAgent maximumUsableArea.
	aSystemWindow extent: aSystemWindow initialExtent.
	aSystemWindow position = (0@0)
		ifTrue: [aSystemWindow
				position: self activeHand position - (aSystemWindow extent // 2)].
	aSystemWindow
		bounds: (aSystemWindow bounds translatedToBeWithin: area).
	[ToolBuilder default runModal: aSystemWindow openAsIs]
		ensure: [mySysWin modalUnlockFrom: aSystemWindow.
				self activeHand newKeyboardFocus: keyboardFocus].
	^aSystemWindow
]

{ #category : #initialization }
Morph >> openNear: aRectangle [ 
	self
		openNear: aRectangle
		in: self currentWorld
]

{ #category : #initialization }
Morph >> openNear: aRectangle in: aWorld [
	| wb leftOverlap rightOverlap topOverlap bottomOverlap best |
	wb := aWorld bounds.
	self fullBounds.
	leftOverlap := self width - (aRectangle left - wb left).
	rightOverlap := self width - (wb right - aRectangle right).
	topOverlap := self height - (aRectangle top - wb top).
	bottomOverlap := self height - (wb bottom - aRectangle bottom).
	best := nil.
	{
		{leftOverlap. #topRight:. #topLeft}.
		{rightOverlap. #topLeft:. #topRight}.
		{topOverlap. #bottomLeft:. #topLeft}.
		{bottomOverlap. #topLeft:. #bottomLeft}.
	} do: [ :tuple |
		(best isNil or: [tuple first < best first]) ifTrue: [best := tuple].
	].
	self perform: best second with: (aRectangle perform: best third).
	self bottom: (self bottom min: wb bottom) rounded.
	self right: (self right min: wb right) rounded.
	self top: (self top max: wb top) rounded.
	self left: (self left max: wb left) rounded.
	self openInWorld: aWorld.
]

{ #category : #initialization }
Morph >> openNearMorph: aMorph [ 
	self
		openNear: aMorph boundsInWorld
		in: (aMorph world
				ifNil: [self world
						ifNil: [Project current world]])
]

{ #category : #'player viewer' }
Morph >> openViewerForArgument [
	"Open up a viewer for a player associated with the morph in question. "
	self presenter viewMorph: self
]

{ #category : #structure }
Morph >> orOwnerSuchThat: conditionBlock [

	(conditionBlock value: self) ifTrue: [^ self].
	self allOwnersDo: [:m | (conditionBlock value: m) ifTrue: [^ m]].
	^ nil


]

{ #category : #'accessing - properties' }
Morph >> otherProperties [
	"answer the receiver's otherProperties"
	^ extension ifNotNil: [extension otherProperties]
]

{ #category : #initialization }
Morph >> outOfWorld: aWorld [
	"The receiver has just appeared in a new world. Notes:
		* aWorld can be nil (due to optimizations in other places)
		* owner is still valid
	Important: Keep this method fast - it is run whenever morphs are removed."
	aWorld ifNil:[^self].
	"ar 1/31/2001: We could explicitly stop stepping the receiver here but for the sake of speed I'm for now relying on the lazy machinery in the world itself."
	"aWorld stopStepping: self."
	self submorphsDo:[:m| m outOfWorld: aWorld].

]

{ #category : #'geometry - layout' }
Morph >> outerBounds [
	"Return the 'outer' bounds of the receiver, e.g., the bounds that need to be invalidated when the receiver changes."
	| box |
	box := self bounds.
	self hasDropShadow ifTrue:[box := self expandFullBoundsForDropShadow: box].
	self hasRolloverBorder ifTrue:[box := self expandFullBoundsForRolloverBorder: box].
	^box
]

{ #category : #'geometry - layout' }
Morph >> outerBounds: aRectangle [
	"Set the bounds for laying out children of the receiver.
	Note: written so that #outerBounds can be changed without touching this method"
	| outer inner |
	outer := self bounds.
	inner := self outerBounds.
	self bounds: (aRectangle origin + (outer origin - inner origin) corner:
				aRectangle corner + (outer corner - inner corner)).
]

{ #category : #'geometry - layout' }
Morph >> outerExtent [

	^ self outerBounds extent
]

{ #category : #'geometry - layout' }
Morph >> outerExtent: aPoint [

	self outerBounds: (self outerPosition extent: aPoint).
]

{ #category : #'geometry - layout' }
Morph >> outerPosition [

	^ self outerBounds topLeft
]

{ #category : #'geometry - layout' }
Morph >> outerPosition: aPoint [

	| prior delta |
	prior := self outerBounds.
	delta := (aPoint - prior topLeft) rounded.
	self outerBounds: (prior translateBy: delta).
]

{ #category : #structure }
Morph >> outermostMorphThat: conditionBlock [
	"Return the outermost containing morph for which aBlock is true, or nil if none"

	| outermost |
	self allOwnersDo: [:m | (conditionBlock value: m) ifTrue: [outermost := m]].
	^ outermost
]

{ #category : #menu }
Morph >> outermostOwnerWithYellowButtonMenu [
	"Answer me or my outermost owner that is willing to contribute menu items to a context menu.
	Don't include the world."

	| outermost |
	outermost := self outermostMorphThat: [ :ea |
		ea isWorldMorph not and: [ ea hasYellowButtonMenu ]].
	^outermost ifNil: [ self hasYellowButtonMenu ifTrue: [ self ] ifFalse: []] 
]

{ #category : #structure }
Morph >> outermostWorldMorph [

	| outer |
	self world ifNotNil: [ :world |^world].
	self flag: #arNote. "stuff below is really only for MVC"
	outer := self outermostMorphThat: [ :x | x isWorldMorph].
	outer ifNotNil: [^outer].
	self isWorldMorph ifTrue: [^self].
	^nil
]

{ #category : #'geometry - etoys' }
Morph >> overlapsShadowForm: itsShadow bounds: itsBounds [
	"Answer true if itsShadow and my shadow overlap at all"
	| overlapExtent overlap myRect myShadow goalRect goalShadow bb |
	overlap := self fullBounds intersect: itsBounds.
	overlapExtent := overlap extent.
	overlapExtent > (0 @ 0)
		ifFalse: [^ false].
	myRect := overlap translateBy: 0 @ 0 - self topLeft.
	myShadow := (self imageForm contentsOfArea: myRect) stencil.
	goalRect := overlap translateBy: 0 @ 0 - itsBounds topLeft.
	goalShadow := (itsShadow contentsOfArea: goalRect) stencil.

			"compute a pixel-by-pixel AND of the two stencils.  Result will be black 
			(pixel value = 1) where black parts of the stencils overlap"
			bb := BitBlt toForm: myShadow.
			bb 
				copyForm: goalShadow
				to: 0 @ 0
				rule: Form and.
	
	^(bb destForm tallyPixelValues second) > 0 
]

{ #category : #structure }
Morph >> owner [
	"Returns the owner of this morph, which may be nil."

	^ owner
]

{ #category : #'debug and other' }
Morph >> ownerChain [
	"Answer a list of objects representing the receiver and all of its owners.   The first element is the receiver, and the last one is typically the world in which the receiver resides"

	| c next |
	c := OrderedCollection with: self.
	next := self.
	[(next := next owner) notNil] whileTrue: [c add: next].
	^c asArray
]

{ #category : #'change reporting' }
Morph >> ownerChanged [
	"This morph's owner has changed its geometry and is about to update its layout. This is a simple layout hook to update this morph's geometry according to its owner.
	
	For more advanced strategies, use a LayoutPolicy with some LayoutProperties. See #layoutPolicy: and maybe also #doLayoutIn:."

	self snapToEdgeIfAppropriate.
]

{ #category : #structure }
Morph >> ownerThatIsA: aClass [
	"Return the first enclosing morph that is a kind of aClass, or nil if none"

	^ self firstOwnerSuchThat: [:m | m isKindOf: aClass]
]

{ #category : #structure }
Morph >> ownerThatIsA: firstClass orA: secondClass [
	"Return the first enclosing morph that is a kind of one of the two classes given, or nil if none"

	^ self firstOwnerSuchThat: [:m | (m isKindOf: firstClass) or: [m isKindOf: secondClass]]
]

{ #category : #printing }
Morph >> pagesHandledAutomatically [

	^false
]

{ #category : #'parts bin' }
Morph >> partRepresented [
	^self
]

{ #category : #structure }
Morph >> pasteUpMorph [
	"Answer the closest containing morph that is a PasteUp morph"
	^ self ownerThatIsA: PasteUpMorph
]

{ #category : #structure }
Morph >> pasteUpMorphHandlingTabAmongFields [
	"Answer the nearest PasteUpMorph in my owner chain that has the tabAmongFields property, or nil if none"

	| aPasteUp |
	aPasteUp := self owner.
	[aPasteUp notNil] whileTrue:
		[aPasteUp tabAmongFields ifTrue:
			[^ aPasteUp].
		aPasteUp := aPasteUp owner].
	^ nil
]

{ #category : #thumbnail }
Morph >> permitsThumbnailing [
	^ true
]

{ #category : #'player commands' }
Morph >> playSoundNamed: soundName [
	"Play the sound with the given name.
	Does nothing if this image lacks sound playing facilities."

	SoundService default playSoundNamed: soundName asString
]

{ #category : #accessing }
Morph >> player [
	"answer the receiver's player"
	^ extension ifNotNil: [extension player]
]

{ #category : #accessing }
Morph >> player: anObject [ 
	"change the receiver's player"
	self assureExtension player: anObject
]

{ #category : #accessing }
Morph >> playerRepresented [
	"Answer the player represented by the receiver.  Morphs that serve as references to other morphs reimplement this; be default a morph represents its own player."

	^ self player
]

{ #category : #'geometry - local\/global' }
Morph >> point: aPoint from: aReferenceMorph [

	owner ifNil: [^ aPoint].
	^ (owner transformFrom: aReferenceMorph) globalPointToLocal: aPoint.

]

{ #category : #'geometry - local\/global' }
Morph >> point: aPoint in: aReferenceMorph [

	owner ifNil: [^ aPoint].
	^ (owner transformFrom: aReferenceMorph) localPointToGlobal: aPoint.

]

{ #category : #'geometry - local\/global' }
Morph >> pointFromWorld: aPoint [
	^self point: aPoint from: self world
]

{ #category : #'geometry - local\/global' }
Morph >> pointInWorld: aPoint [
	^self point: aPoint in: self world
]

{ #category : #geometry }
Morph >> position [

	^ bounds topLeft
]

{ #category : #geometry }
Morph >> position: aPoint [ 
	"Change the position of this morph, which is the top left corner of its bounds."
	
	| delta box |
	delta := (aPoint - self bounds topLeft) rounded.
	
	"Skip drawing and layout updates for null changes."
	(delta x = 0 and: [delta y = 0])
		ifTrue: [^ self].

	"Optimize drawing. Record one damage rectangle for short distance and two damage rectangles for large distances."
	box := self fullBounds.	
	(delta dotProduct: delta) > 100 "More than 10 pixels?"
		ifTrue: [self
					invalidRect: box;
					invalidRect: (box translateBy: delta)]
		ifFalse: [self
					invalidRect: (box merge: (box translateBy: delta))].
	
	"Move this morph and *all* of its submorphs."
	self privateFullMoveBy: delta.
	
	"For all known layout policies, my layout and the layout of my children is fine. Only the layout of my owner might be affected. So, tell about it."
	self owner ifNotNil: [:o | 
		self flag: #todo. "mt: Maybe we can save a lot of effort and troubles by only calling #layoutChanged if the owner has a layout policy installed? Take the thumbs of scroll-bars as an example..."
		o layoutChanged].
]

{ #category : #'geometry - local\/global' }
Morph >> positionInWorld [

	^ self pointInWorld: self position.

]

{ #category : #'geometry - misc' }
Morph >> positionSubmorphs [
	self submorphsDo:
		[:aMorph | aMorph snapToEdgeIfAppropriate]
]

{ #category : #'meta-actions' }
Morph >> potentialEmbeddingTargets [
	"Return the potential targets for embedding the receiver"

	| oneUp topRend |
	(oneUp := (topRend := self topRendererOrSelf) owner) ifNil:[^#()].
	^ (oneUp morphsAt: topRend referencePosition behind: topRend unlocked: true) select:
		[:m | m  isFlexMorph not]
]

{ #category : #'meta-actions' }
Morph >> potentialTargets [
	"Return the potential targets for the receiver.
	This is derived from Morph>>potentialEmbeddingTargets."
	owner ifNil:[^#()].
	^owner morphsAt: self referencePosition behind: self unlocked: true not
]

{ #category : #'meta-actions' }
Morph >> potentialTargetsAt: aPoint [ 
	"Return the potential targets for the receiver.  
	This is derived from Morph>>potentialEmbeddingTargets."
	| realOwner |
	realOwner := self topRendererOrSelf
	owner
		ifNil: [^ #()].
	^ realOwner
		morphsAt: aPoint
		
]

{ #category : #'halos and balloon help' }
Morph >> preferredDuplicationHandleSelector [
	"Answer the selector, either #addMakeSiblingHandle: or addDupHandle:, to be offered as the default in a halo open on me"

	Preferences oliveHandleForScriptedObjects ifFalse:
		[^ #addDupHandle:].
	^ self renderedMorph valueOfProperty: #preferredDuplicationHandleSelector ifAbsent:
		[self player class isUniClass
			ifTrue:
				[#addMakeSiblingHandle:]
			ifFalse:
				[#addDupHandle:]]
]

{ #category : #'Multilingual-ImmPlugin' }
Morph >> preferredKeyboardBounds [

	self flag: #ImmPlugin.
	^ self bounds: self bounds in: self world.

]

{ #category : #'Multilingual-ImmPlugin' }
Morph >> preferredKeyboardPosition [

	self flag: #ImmPlugin.
	^ (self bounds: self bounds in: self world) topLeft.

]

{ #category : #'fileIn\/out' }
Morph >> prepareToBeSaved [
	"Prepare this morph to be saved to disk. Subclasses should nil out any instance variables that holds state that should not be saved, such as cached Forms. Note that this operation may take more drastic measures than releaseCachedState; for example, it might discard the transcript of an interactive chat session."

	self releaseCachedState.
	self formerOwner: nil.
	self formerPosition: nil.
	self removeProperty: #undoGrabCommand.
	fullBounds := nil
]

{ #category : #menus }
Morph >> presentHelp [
	"Present a help message if there is one available"

	self inform: 'Sorry, no help has been
provided here yet.'
]

{ #category : #accessing }
Morph >> presenter [
	^ owner ifNotNil: [owner presenter] ifNil: [self currentWorld presenter]
]

{ #category : #structure }
Morph >> primaryHand [

	^ self currentWorld primaryHand
]

{ #category : #printing }
Morph >> printConstructorOn: aStream indent: level [

	^ self printConstructorOn: aStream indent: level nodeDict: IdentityDictionary new

]

{ #category : #printing }
Morph >> printConstructorOn: aStream indent: level nodeDict: nodeDict [
	| nodeString |
	(nodeString := nodeDict at: self ifAbsent: [nil])
		ifNotNil: [^ aStream nextPutAll: nodeString].
	submorphs isEmpty ifFalse: [aStream nextPutAll: '('].
	aStream nextPutAll: '('.
	self fullPrintOn: aStream.
	aStream nextPutAll: ')'.
	submorphs isEmpty ifTrue: [^ self].
	submorphs size <= 4
	ifTrue:
		[aStream crtab: level+1;
			nextPutAll: 'addAllMorphs: (Array'.
		1 to: submorphs size do:
			[:i | aStream crtab: level+1; nextPutAll: 'with: '.
			(submorphs at: i) printConstructorOn: aStream indent: level+1 nodeDict: nodeDict].
		aStream nextPutAll: '))']
	ifFalse:
		[aStream crtab: level+1;
			nextPutAll: 'addAllMorphs: ((Array new: ', submorphs size printString, ')'.
		1 to: submorphs size do:
			[:i |
			aStream crtab: level+1; nextPutAll: 'at: ', i printString, ' put: '.
			(submorphs at: i) printConstructorOn: aStream indent: level+1 nodeDict: nodeDict.
			aStream nextPutAll: ';'].
		aStream crtab: level+1; nextPutAll: 'yourself))']
]

{ #category : #printing }
Morph >> printOn: aStream [ 
	| aName |
	super printOn: aStream.
	(aName := self knownName) notNil 
		ifTrue: [aStream nextPutAll: '<' , aName , '>'].
	aStream nextPutAll: '('.
	aStream
		print: self identityHash;
		nextPutAll: ')'
]

{ #category : #printing }
Morph >> printSpecs [

	| printSpecs |

	printSpecs := self valueOfProperty: #PrintSpecifications.
	printSpecs ifNil: [
		printSpecs := PrintSpecifications defaultSpecs.
		self printSpecs: printSpecs.
	].
	^printSpecs
]

{ #category : #printing }
Morph >> printSpecs: aPrintSecification [

	self setProperty: #PrintSpecifications toValue: aPrintSecification.

]

{ #category : #printing }
Morph >> printStructureOn: aStream indent: tabCount [

	tabCount timesRepeat: [aStream tab].
	self printOn: aStream.
	aStream cr.
	self submorphsDo: [:m | m printStructureOn: aStream indent: tabCount + 1].

]

{ #category : #private }
Morph >> privateAddAllMorphs: aCollection atIndex: index [
	"Private. Add aCollection of morphs to the receiver"
	| myWorld otherSubmorphs offset |
	(index between: 1 and: submorphs size+1)
		ifFalse: [^ self error: 'index out of range'].
	myWorld := self world.
	otherSubmorphs := submorphs copyWithoutAll: aCollection.
	offset := aCollection count: [:m | (submorphs indexOf: m) between: 1 and: index - 1].
	submorphs := otherSubmorphs copyReplaceFrom: index-offset to: index-offset-1 with: aCollection.
	aCollection do: [:m | | itsOwner itsWorld |
		itsOwner := m owner.
		itsOwner ifNotNil: [
			itsWorld := m world.
			(itsWorld == myWorld) ifFalse: [
				itsWorld ifNotNil: [self privateInvalidateMorph: m].
				m outOfWorld: itsWorld].
			(itsOwner ~~ self) ifTrue: [
				m owner privateRemove: m.
				m owner removedMorph: m ]].
		m privateOwner: self.
		myWorld ifNotNil: [self privateInvalidateMorph: m].
		(myWorld == itsWorld) ifFalse: [m intoWorld: myWorld].
		itsOwner == self ifFalse: [
			self addedMorph: m.
			m noteNewOwner: self ].
	].
	self layoutChanged.

]

{ #category : #private }
Morph >> privateAddMorph: aMorph atIndex: index [

	| oldIndex myWorld itsWorld oldOwner |
	((index >= 1) and: [index <= (submorphs size + 1)])
		ifFalse: [^ self error: 'index out of range'].
	myWorld := self world.
	oldOwner := aMorph owner.
	(oldOwner == self and: [(oldIndex := submorphs indexOf: aMorph) > 0]) ifTrue:[
		"aMorph's position changes within in the submorph chain"
		oldIndex < index ifTrue:[
			"moving aMorph to back"
			submorphs replaceFrom: oldIndex to: index-2 with: submorphs startingAt: oldIndex+1.
			submorphs at: index-1 put: aMorph.
		] ifFalse:[
			"moving aMorph to front"
			oldIndex-1 to: index by: -1 do:[:i|
				submorphs at: i+1 put: (submorphs at: i)].
			submorphs at: index put: aMorph.
		].
	] ifFalse:[
		"adding a new morph"
		oldOwner ifNotNil:[
			itsWorld := aMorph world.
			itsWorld ifNotNil: [self privateInvalidateMorph: aMorph].
			(itsWorld == myWorld) ifFalse: [aMorph outOfWorld: itsWorld].
			oldOwner privateRemove: aMorph.
			oldOwner removedMorph: aMorph.
		].
		aMorph privateOwner: self.
		submorphs := submorphs copyReplaceFrom: index to: index-1 with: (Array with: aMorph).
		(itsWorld == myWorld) ifFalse: [aMorph intoWorld: myWorld].
	].
	myWorld ifNotNil:[self privateInvalidateMorph: aMorph].
	self layoutChanged.
	oldOwner == self ifFalse: [
		self addedMorph: aMorph.
		aMorph noteNewOwner: self ].

]

{ #category : #private }
Morph >> privateBounds: boundsRect [
	"Private! Use position: and/or extent: instead."

	fullBounds := nil.
	bounds := boundsRect.
]

{ #category : #private }
Morph >> privateColor: aColor [

	color := aColor.

]

{ #category : #'submorphs-add\/remove' }
Morph >> privateDelete [
	"Remove the receiver as a submorph of its owner"
	owner ifNotNil:[owner removeMorph: self].
]

{ #category : #private }
Morph >> privateDeleteWithAbsolutelyNoSideEffects [
	"Private! Should only be used by methods that maintain the ower/submorph invariant."
	"used to delete a morph from an inactive world"

	owner ifNil: [^self].
	owner privateRemoveMorphWithAbsolutelyNoSideEffects: self.
	owner := nil.


]

{ #category : #'accessing - extension' }
Morph >> privateExtension: aMorphExtension [
	"private - change the receiver's extension"
	extension := aMorphExtension
]

{ #category : #layout }
Morph >> privateFullBounds [
	"Private. Compute the actual full bounds of the receiver"

	| box |
	submorphs isEmpty ifTrue: [^self outerBounds].
	box := self outerBounds copy.
	box := box quickMerge: (self clipSubmorphs 
						ifTrue: [self submorphBounds intersect: self clippingBounds]
						ifFalse: [self submorphBounds]).
	^box origin asIntegerPoint corner: box corner asIntegerPoint
]

{ #category : #private }
Morph >> privateFullBounds: boundsRect [
	"Private! Computed automatically."

	fullBounds := boundsRect.
]

{ #category : #layout }
Morph >> privateFullBoundsForRedraw [
	"Private. Compute the current submorph bounds *all the way down* to trigger re-draw. Implementation is based on #privateFullBounds and #submorphBounds. Avoid triggering layout computation but return bounds as is."
	
	| box |
	self hasSubmorphs ifFalse: [^ self outerBounds].
	box := self outerBounds copy.
	box := box quickMerge: (self clipSubmorphs 
						ifTrue: [self submorphBoundsForShrinkWrap intersect: self clippingBounds]
						ifFalse: [self submorphBoundsForShrinkWrap]).
	^box origin asIntegerPoint corner: box corner asIntegerPoint
]

{ #category : #private }
Morph >> privateFullMoveBy: delta [
	"Private! Relocate me and all of my subMorphs by recursion. Subclasses that implement different coordinate systems may override this method."

	self privateMoveBy: delta.
	1 to: submorphs size do: [:i |
		(submorphs at: i) privateFullMoveBy: delta].
	owner ifNotNil:[
		owner isTextMorph ifTrue:[owner adjustTextAnchor: self]].
]

{ #category : #'change reporting' }
Morph >> privateInvalidateMorph: aMorph [
	"Private. Invalidate the given morph after adding or removing.
	This method is private because a) we're invalidating the morph 'remotely'
	and b) it forces a fullBounds computation which should not be necessary
	for a general morph c) the morph may or may not actually invalidate
	anything (if it's not in the world nothing will happen) and d) the entire
	mechanism should be rewritten."
	aMorph fullBounds.
	aMorph changed
]

{ #category : #private }
Morph >> privateMoveBy: delta [ 
	"Private! Use 'position:' instead."
	| fill |
	self player ifNotNil: ["Most cases eliminated fast by above test"
		self getPenDown ifTrue: [
			"If this is a costume for a player with its 
			pen down, draw a line."
			self moveWithPenDownBy: delta]].
	bounds := bounds translateBy: delta.
	fullBounds ifNotNil: [fullBounds := fullBounds translateBy: delta].
	fill := self fillStyle.
	fill isOrientedFill ifTrue: [fill origin: fill origin + delta]
]

{ #category : #private }
Morph >> privateOwner: aMorph [
	"Private! Should only be used by methods that maintain the ower/submorph invariant."

	owner := aMorph.
]

{ #category : #private }
Morph >> privateRemove: aMorph [
	"Private! Should only be used by methods that maintain the ower/submorph invariant."

	submorphs := submorphs copyWithout: aMorph.
	self layoutChanged.
]

{ #category : #private }
Morph >> privateRemoveMorphWithAbsolutelyNoSideEffects: aMorph [
	"Private! Should only be used by methods that maintain the ower/submorph invariant."
	"used to delete a morph from an inactive world"

	submorphs := submorphs copyWithout: aMorph.


]

{ #category : #private }
Morph >> privateSubmorphs [
	"Private! Use 'submorphs' instead."

	^ submorphs
]

{ #category : #private }
Morph >> privateSubmorphs: aCollection [
	"Private! Should only be used by methods that maintain the ower/submorph invariant."

	submorphs := aCollection.
]

{ #category : #'events-processing' }
Morph >> processEvent: anEvent [
	"Process the given event using the default event dispatcher."
	^self processEvent: anEvent using: self defaultEventDispatcher
]

{ #category : #'events-processing' }
Morph >> processEvent: anEvent using: defaultDispatcher [
	"This is the central entry for dispatching events in morphic. Given some event and a default dispatch strategy, find the right receiver and let him handle it.
	WARNING: This is a powerful hook. If you want to use a different event dispatcher from the default, here is the place to hook it in. Depending on how the dispatcher is written (e.g., whether it calls simply #processEvent: or #processEvent:using:) you can change the dispatch strategy for entire trees of morphs. Similarly, you can disable entire trees of morphs from receiving any events whatsoever. Read the documentation in class MorphicEventDispatcher before playing with it.
	Event filters for this capture phase can both influence and overrule the way the receiver can reject the event. If the filter ignores the event, the whole event procecssing will stop. If the filtered event is still not ignored, the receiver can decide to still reject it end regular event dispatch will go on."
	
	| filteredEvent |
	filteredEvent := self sendFilterEventCapture: anEvent for: self.
	filteredEvent wasIgnored ifTrue: [^ filteredEvent].
	
	(self rejectsEvent: filteredEvent) ifTrue:[^#rejected].
	^defaultDispatcher dispatchEvent: filteredEvent with: self
]

{ #category : #'events-processing' }
Morph >> processFocusEvent: anEvent [

	^self processFocusEvent: anEvent using: self defaultEventDispatcher
]

{ #category : #'events-processing' }
Morph >> processFocusEvent: anEvent using: defaultDispatcher [
	"Event dispatching shortcut."

	^ defaultDispatcher dispatchFocusEvent: anEvent with: self
]

{ #category : #'debug and other' }
Morph >> programmedMouseDown: anEvent for: aMorph [

	aMorph addMouseActionIndicatorsWidth: 15 color: (Color blue alpha: 0.7).


]

{ #category : #'debug and other' }
Morph >> programmedMouseEnter: anEvent for: aMorph [

	aMorph addMouseActionIndicatorsWidth: 10 color: (Color blue alpha: 0.3).


]

{ #category : #'debug and other' }
Morph >> programmedMouseLeave: anEvent for: aMorph [

	self deleteAnyMouseActionIndicators.

]

{ #category : #'debug and other' }
Morph >> programmedMouseUp: anEvent for: aMorph [ 
	| aCodeString |
	self deleteAnyMouseActionIndicators.
	aCodeString := self valueOfProperty: #mouseUpCodeToRun ifAbsent: [^self].
	(self fullBounds containsPoint: anEvent cursorPoint) ifFalse: [^self].
	
	[(aCodeString isMessageSend) 
		ifTrue: [aCodeString value]
		ifFalse: 
			[Compiler 
				evaluate: aCodeString
				for: self
				notifying: nil]] 
			on: ProgressTargetRequestNotification
			do: [:ex | ex resume: self]	"in case a save/load progress display needs a home"
]

{ #category : #accessing }
Morph >> raisedColor [
	"Return the color to be used for shading raised borders. The 
	default is my own color, but it might want to be, eg, my 
	owner's color. Whoever's color ends up prevailing, the color 
	itself gets the last chance to determine, so that when, for 
	example, an InfiniteForm serves as the color, callers won't choke 
	on some non-Color object being returned"
	(color isColor
			and: [color isTransparent
					and: [owner notNil]])
		ifTrue: [^ owner raisedColor].
	^ color asColor raisedColor
]

{ #category : #'WiW support' }
Morph >> randomBoundsFor: aMorph [

	| trialRect |
	trialRect := (
		self topLeft + 
			((self width * (15 + 75 atRandom/100)) rounded @
			(self height * (15 + 75 atRandom/100)) rounded)
	) extent: aMorph extent.
	^trialRect translateBy: (trialRect amountToTranslateWithin: self bounds)

]

{ #category : #thumbnail }
Morph >> readoutForField: fieldSym [
	"Provide a readout that will show the value of the slot/pseudoslot of the receiver generated by sending fieldSym to the receiver"

	| aContainer |
	"still need to get this right"
	aContainer := AlignmentMorph newColumn.
	aContainer layoutInset: 0; hResizing: #rigid; vResizing: #shrinkWrap.
	aContainer addMorphBack: (StringMorph new contents: (self perform: fieldSym) asString).
	^ aContainer
]

{ #category : #menus }
Morph >> reasonableBitmapFillForms [
	"Answer an OrderedCollection of forms that could be used to replace my bitmap fill, with my current form first."
	| reasonableForms myGraphic |
	reasonableForms := self class allSketchMorphForms.
	reasonableForms addAll: Imports default images.
	reasonableForms addAll: (BitmapFillStyle allSubInstances collect:[:f| f form]).
	reasonableForms
		remove: (myGraphic := self fillStyle form)
		ifAbsent: [].
	reasonableForms := reasonableForms asOrderedCollection.
	reasonableForms addFirst: myGraphic.
	^reasonableForms
]

{ #category : #menus }
Morph >> reasonableForms [
	"Answer an OrderedCollection of forms that could be used to replace my form, with my current form first."
	| reasonableForms myGraphic |
	reasonableForms := self class allSketchMorphForms.
	reasonableForms addAll: Imports default images.
	reasonableForms
		remove: (myGraphic := self form)
		ifAbsent: [].
	reasonableForms := reasonableForms asOrderedCollection.
	reasonableForms addFirst: myGraphic.
	^reasonableForms
]

{ #category : #geniestubs }
Morph >> redButtonGestureDictionaryOrName: aSymbolOrDictionary [
]

{ #category : #'e-toy support' }
Morph >> referencePlayfield [
	"Answer the PasteUpMorph to be used for cartesian-coordinate reference"

	| former |
	owner ifNotNil:
		[(self topRendererOrSelf owner isHandMorph and: [(former := self formerOwner) notNil])
			ifTrue:
				[former := former renderedMorph.
				^ former isPlayfieldLike 
					ifTrue: [former]
					ifFalse: [former referencePlayfield]]].

	self allOwnersDo: [:o | o isPlayfieldLike ifTrue: [^ o]].
	^ Project current world
]

{ #category : #'rotate scale and flex' }
Morph >> referencePosition [
	"Return the current reference position of the receiver"
	| box |
	box := self bounds.
	^box origin + (self rotationCenter * box extent).

]

{ #category : #'rotate scale and flex' }
Morph >> referencePosition: aPosition [
	"Move the receiver to match its reference position with aPosition"
	| newPos intPos |
	newPos := self position + (aPosition - self referencePosition).
	intPos := newPos asIntegerPoint.
	newPos = intPos 
		ifTrue:[self position: intPos]
		ifFalse:[self position: newPos].
]

{ #category : #'rotate scale and flex' }
Morph >> referencePositionInWorld [

	^ self pointInWorld: self referencePosition

]

{ #category : #'rotate scale and flex' }
Morph >> referencePositionInWorld: aPoint [
	| localPosition |
	localPosition := owner
		ifNil: [aPoint]
		ifNotNil: [(owner transformFrom: self world) globalPointToLocal: aPoint].

	self referencePosition: localPosition

]

{ #category : #drawing }
Morph >> refreshWorld [
	"If this morph is in a world, refresh the world. This can be used to immediately redraw a morph after it changed. Note that you should use this call rather sparsely because it bypasses Morphics damage recording mechanism."
	
	self world ifNotNil: [:w | w displayWorldSafely].
]

{ #category : #accessing }
Morph >> regularColor [
	
	| val |
	^ (val := self valueOfProperty: #regularColor)
		ifNotNil:
			[val ifNil: [self error: 'nil regularColor']]
		ifNil:
			[owner ifNil: [self color] ifNotNil: [owner regularColor]]
]

{ #category : #accessing }
Morph >> regularColor: aColor [
	self setProperty: #regularColor toValue: aColor
]

{ #category : #'events-processing' }
Morph >> rejectDropEvent: anEvent [
	"This hook allows the receiver to repel a drop operation currently executed. The method is called prior to checking children so the receiver must validate that the event was really designated for it.
	Note that the ordering of the tests below is designed to avoid a (possibly expensive) #fullContainsPoint: test. If the receiver doesn't want to repel the morph anyways we don't need to check after all."
	(self repelsMorph: anEvent contents event: anEvent) ifFalse:[^self]. "not repelled"
	(self fullContainsPoint: anEvent position) ifFalse:[^self]. "not for me"
	"Throw it away"
	anEvent wasHandled: true.
	anEvent contents rejectDropMorphEvent: anEvent.
]

{ #category : #'dropping\/grabbing' }
Morph >> rejectDropMorphEvent: evt [
	"The receiver has been rejected, and must be put back somewhere.  There are three cases:
	(1)  It remembers its former owner and position, and goes right back there
	(2)  It remembers its former position only, in which case it was torn off from a parts bin, and the UI is that it floats back to its donor position and then vanishes.
	(3)  Neither former owner nor position is remembered, in which case it is whisked to the Trash"

	self removeProperty: #undoGrabCommand.
	(self formerOwner notNil and: [self formerOwner isPartsBin not]) ifTrue:
		[^ self slideBackToFormerSituation: evt].

	self formerPosition ifNotNil:  "Position but no owner -- can just make it vanish"
		[^ self vanishAfterSlidingTo: self formerPosition event: evt].
		
	self slideToTrash: evt
]

{ #category : #'events-processing' }
Morph >> rejectsEvent: anEvent [
	"Return true to reject the given event. Rejecting an event means neither the receiver nor any of it's submorphs will be given any chance to handle it."
	^self isLocked or:[self visible not]
]

{ #category : #'events-removing' }
Morph >> releaseActionMap [
	"Release the action map"
	
 	self removeProperty: #actionMap
]

{ #category : #caching }
Morph >> releaseCachedState [
	"Release any state that can be recomputed on demand, such as the pixel values for a color gradient or the editor state for a TextMorph. This method may be called to save space when a morph becomes inaccessible. Implementations of this method should do 'super releaseCachedState'."
	self borderStyle releaseCachedState. 

]

{ #category : #accessing }
Morph >> rememberedColor [
	"Answer a rememberedColor, or nil if none"

	^ self valueOfProperty: #rememberedColor ifAbsent: [nil]
]

{ #category : #accessing }
Morph >> rememberedColor: aColor [
	"Place aColor in a property so I can retrieve it later.  A tortuous but expedient flow of data"

	^ self setProperty: #rememberedColor toValue: aColor
]

{ #category : #'events-alarms' }
Morph >> removeAlarm: aSelector [
	"Remove the given alarm"
	| scheduler |
	scheduler := self alarmScheduler.
	scheduler ifNotNil:[scheduler removeAlarm: aSelector for: self].
]

{ #category : #'events-alarms' }
Morph >> removeAlarm: aSelector at: scheduledTime [
	"Remove the given alarm"
	| scheduler |
	scheduler := self alarmScheduler.
	scheduler ifNotNil:[scheduler removeAlarm: aSelector at: scheduledTime for: self].
]

{ #category : #other }
Morph >> removeAllButFirstSubmorph [
	"Remove all of the receiver's submorphs other than the first one."

	self submorphs allButFirst do: [:m | m delete]
]

{ #category : #'submorphs-add\/remove' }
Morph >> removeAllMorphs [
	| oldMorphs myWorld |
	myWorld := self world.
	(fullBounds notNil or: [ myWorld notNil ]) ifTrue: [ self invalidRect: self fullBounds ].
	submorphs do:
		[ : m | myWorld ifNotNil: [ m outOfWorld: myWorld ].
		m privateOwner: nil ].
	oldMorphs := submorphs.
	submorphs := Array empty.
	oldMorphs do: [ : m | self removedMorph: m ].
	self layoutChanged
]

{ #category : #'submorphs-add\/remove' }
Morph >> removeAllMorphsIn: aCollection [
	"greatly speeds up the removal of *lots* of submorphs"
	| set myWorld |
	set := IdentitySet new: aCollection size * 4 // 3.
	aCollection do: [:each | each owner == self ifTrue: [ set add: each]].
	myWorld := self world.
	(fullBounds notNil or:[myWorld notNil]) ifTrue:[self invalidRect: self fullBounds].
	set do: [:m | myWorld ifNotNil: [ m outOfWorld: myWorld ]. m privateOwner: nil].
	submorphs := submorphs reject: [ :each | set includes: each].
	set do: [ :m | self removedMorph: m ].
	self layoutChanged.

]

{ #category : #'drop shadows' }
Morph >> removeDropShadow [
	self hasDropShadow ifFalse:[^self].
	self changed.
	self hasDropShadow: false.
	fullBounds ifNotNil:[fullBounds := self privateFullBounds].
	self changed.
]

{ #category : #'events-filtering-bubbling' }
Morph >> removeEventBubbleFilter: anObject [
	self eventBubbleFilters: (self removeFilter: anObject from: self eventBubbleFilters).
]

{ #category : #'events-filtering-capturing' }
Morph >> removeEventCaptureFilter: anObject [
	self eventCaptureFilters: (self removeFilter: anObject from: self eventCaptureFilters).
]

{ #category : #'events-filtering' }
Morph >> removeFilter: anObject from: aFilterGroup [ 
	"Remove anObject from the given listener group. Return the new group."

	| filters |
	aFilterGroup ifNil: [^nil].
	filters := aFilterGroup.
	filters := filters copyWithout: anObject.
	filters := filters copyWithout: nil.	"obsolete entries"
	filters isEmpty ifTrue: [filters := nil].
	^filters
]

{ #category : #'rotate scale and flex' }
Morph >> removeFlexShell [
	self isFlexed
		ifTrue: [self owner removeFlexShell]
]

{ #category : #'halos and balloon help' }
Morph >> removeHalo [
	"remove the surrounding halo (if any)"

	self halo ifNotNil: [ self primaryHand removeHalo ]
]

{ #category : #'events-filtering-bubbling' }
Morph >> removeKeyboardBubbleFilter: anObject [
	self keyboardBubbleFilters: (self removeFilter: anObject from: self keyboardBubbleFilters).
]

{ #category : #'events-filtering-capturing' }
Morph >> removeKeyboardCaptureFilter: anObject [
	self keyboardCaptureFilters: (self removeFilter: anObject from: self keyboardCaptureFilters).
]

{ #category : #'event handling' }
Morph >> removeLink: actionCode [
	self eventHandler ifNotNil:
		[self eventHandler on: actionCode send: nil to: nil]
]

{ #category : #'submorphs-add\/remove' }
Morph >> removeMorph: aMorph [
	"Remove the given morph from my submorphs"
	| aWorld |
	aMorph owner == self ifFalse:[^self].
	aWorld := self world.
	aWorld ifNotNil:[
		aMorph outOfWorld: aWorld.
		self privateInvalidateMorph: aMorph.
	].
	self privateRemove: aMorph.
	aMorph privateOwner: nil.
	self removedMorph: aMorph.

]

{ #category : #'events-filtering-bubbling' }
Morph >> removeMouseBubbleFilter: anObject [
	self mouseBubbleFilters: (self removeFilter: anObject from: self mouseBubbleFilters).
]

{ #category : #'events-filtering-capturing' }
Morph >> removeMouseCaptureFilter: anObject [
	self mouseCaptureFilters: (self removeFilter: anObject from: self mouseCaptureFilters).
]

{ #category : #'debug and other' }
Morph >> removeMouseUpAction [

	self primaryHand showTemporaryCursor: nil.
	self removeProperty: #mouseUpCodeToRun.
	#(mouseUp mouseEnter mouseLeave mouseDown) do: [ :sym |
		self
			on: sym 
			send: #yourself 
			to: nil.
	]


]

{ #category : #'accessing - properties' }
Morph >> removeProperty: aSymbol [ 
	"removes the property named aSymbol if it exists"
	extension ifNil:  [^ self].
	extension removeProperty: aSymbol
]

{ #category : #'submorphs-add\/remove' }
Morph >> removedMorph: aMorph [
	"Notify the receiver that aMorph was just removed from its children"

]

{ #category : #testing }
Morph >> renameInternal: aName [ 
	"Change the internal name (because of a conflict) but leave the external name unchanged.  Change Player class name, but do not change the names that appear in tiles.  When coming in from disk, and have name conflict, References will already have the new name. "

	self knownName = aName ifTrue: [^ aName].
	self topRendererOrSelf setNameTo: aName.
	
	"References dictionary already has key aName"

	"If this player has a viewer flap, it will remain present"

	"Tiles in scripts all stay the same"

	"Compiled methods for scripts have been fixed up because the same association was reused"
	
	^ aName
]

{ #category : #testing }
Morph >> renameTo: aName [ 
	"Set Player name in costume. Update Viewers. Fix all tiles (old style). fix 
	References. New tiles: recompile, and recreate open scripts. If coming in 
	from disk, and have name conflict, References will already have new 
	name."
	| aPresenter putInViewer aPasteUp renderer oldKey assoc classes oldName |
	oldName := self knownName.
	oldName=aName ifTrue: [ ^aName ].
	(renderer := self topRendererOrSelf) setNameTo: aName.
	putInViewer := false.
	((aPresenter := self presenter) isNil or: [renderer player isNil]) 
		ifFalse: 
			[putInViewer := aPresenter currentlyViewing: renderer player.
			putInViewer ifTrue: [renderer player viewerFlapTab hibernate]].
	"empty it temporarily"
	(aPasteUp := self topPasteUp) 
		ifNotNil: [aPasteUp allTileScriptingElements do: [:m | m bringUpToDate]].
	"Fix References dictionary. See restoreReferences to know why oldKey is  
	already aName, but oldName is the old name."
	oldKey := References keyAtIdentityValue: renderer player ifAbsent: [].
	oldKey ifNotNil: 
			[assoc := References associationAt: oldKey.
			oldKey = aName 
				ifFalse: 
					["normal rename"

					assoc key: (renderer player uniqueNameForReferenceFrom: aName).
					References rehash]].
	putInViewer ifTrue: [aPresenter viewMorph: self].
	"recreate my viewer"
	oldKey ifNil: [^aName].
	"Force strings in tiles to be remade with new name. New tiles only."
	Preferences universalTiles ifFalse: [^aName].
	classes := (self systemNavigation allCallsOn: assoc) 
				collect: [:each | each classSymbol].
	classes asSet 
		do: [:clsName | (Smalltalk at: clsName) replaceSilently: oldName to: aName].
	"replace in text body of all methods. Can be wrong!"
	"Redo the tiles that are showing. This is also done in caller in 
	unhibernate. "
	aPasteUp ifNotNil: 
			[aPasteUp allTileScriptingElements do: 
					[:mm | 
					"just ScriptEditorMorphs"

					nil.
					(mm isScriptEditorMorph) 
						ifTrue: 
							[((mm playerScripted class compiledMethodAt: mm scriptName) 
								hasLiteral: assoc) 
									ifTrue: 
										[mm
											hibernate;
											unhibernate]]]].
	^aName
]

{ #category : #structure }
Morph >> renderedMorph [
	"This now  gets overridden by rendering morphs."

	^self
]

{ #category : #'dropping\/grabbing' }
Morph >> repelsMorph: aMorph event: ev [
	^ false
]

{ #category : #'submorphs-add\/remove' }
Morph >> replaceSubmorph: oldMorph by: newMorph [
	| index itsPosition w |
	oldMorph stopStepping.
	itsPosition := oldMorph referencePositionInWorld.
	index := submorphs indexOf: oldMorph.
	oldMorph privateDelete.
	self privateAddMorph: newMorph atIndex: index.
	newMorph referencePositionInWorld: itsPosition.
	(w := newMorph world) ifNotNil:
		[w startSteppingSubmorphsOf: newMorph]
]

{ #category : #printing }
Morph >> reportableSize [
	"Answer a size worth reporting as the receiver's size in a list view"

	| total |
	total := super reportableSize.
	submorphs do:
		[:m | total := total + m reportableSize].
	^ total
]

{ #category : #thumbnail }
Morph >> representativeNoTallerThan: maxHeight norWiderThan: maxWidth thumbnailHeight: thumbnailHeight [
	"Return a morph representing the receiver but which is no taller than aHeight.  If the receiver is already small enough, just return it, else return a MorphThumbnail companioned to the receiver, enforcing the maxWidth.  If the receiver personally *demands* thumbnailing, do it even if there is no size-related reason to do it."

	self demandsThumbnailing ifFalse:
		[self permitsThumbnailing ifFalse: [^ self].
		(self fullBounds height <= maxHeight and: [self fullBounds width <= maxWidth]) ifTrue: [^ self]].

	^ MorphThumbnail new extent: maxWidth @ (thumbnailHeight min: self fullBounds height); morphRepresented: self
]

{ #category : #'fileIn\/out' }
Morph >> reserveUrl: urlString [
	"Write a dummy object to the server to hold a name and place for this object."

	| dummy ext str |
	dummy := PasteUpMorph new.
	dummy borderWidth: 2.
	dummy setProperty: #initialExtent toValue: (ext := 300@100).
	dummy topLeft: 50@50; extent: ext.	"reset when comes in"
	str := (TextMorph new) topLeft: dummy topLeft + (10@10); 
		extent: dummy width - 15 @ 30.
	dummy addMorph: str.
	str contents: 'This is a place holder only.  Please \find the original page and choose \"send this page to server"' withCRs.
	str extent: dummy width - 15 @ 30.
	dummy saveOnURL: urlString.

	"Claim that url myself"
	self setProperty: #SqueakPage toValue: dummy sqkPage.
	(dummy sqkPage) contentsMorph: self; dirty: true.
	^ self url
]

{ #category : #'accessing - extension' }
Morph >> resetExtension [
	"reset the extension slot if it is not needed"
	(extension notNil and: [extension isDefault]) ifTrue: [extension := nil] 
]

{ #category : #menus }
Morph >> resetForwardDirection [
	self forwardDirection: 0.
]

{ #category : #'dropping\/grabbing' }
Morph >> resetHighlightForDrop [
	self highlightForDrop: false
]

{ #category : #'parts bin' }
Morph >> residesInPartsBin [
	"Answer true if the receiver is, or has some ancestor owner who is, a parts bin"
	^ owner ifNotNil: [owner residesInPartsBin] ifNil: [false]
]

{ #category : #accessing }
Morph >> resistsRemoval [
	"Answer whether the receiver is marked as resisting removal"

	^ self hasProperty: #resistsRemoval
]

{ #category : #accessing }
Morph >> resistsRemoval: aBoolean [
	"Set the receiver's resistsRemoval property as indicated"

	aBoolean
		ifTrue:
			[self setProperty: #resistsRemoval toValue: true]
		ifFalse:
			[self removeProperty: #resistsRemoval]
]

{ #category : #menus }
Morph >> resistsRemovalString [
	"Answer the string to be shown in a menu to represent the 
	'resistsRemoval' status"
	^ (self resistsRemoval
		ifTrue: ['<on>']
		ifFalse: ['<off>']), 'resist being deleted' translated
]

{ #category : #'meta-actions' }
Morph >> resizeFromMenu [
	"Commence an interaction that will resize the receiver"

	^ self resizeMorph: self currentEvent
]

{ #category : #'meta-actions' }
Morph >> resizeMorph: evt [
	| handle |
	handle := HandleMorph new forEachPointDo: [:newPoint | 
		self extent: (self griddedPoint: newPoint) - self bounds topLeft].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #initialization }
Morph >> resourceJustLoaded [
	"In case resource relates to me"
	self releaseCachedState.
]

{ #category : #'event handling' }
Morph >> restoreSuspendedEventHandler [
	| savedHandler |
	(savedHandler := self valueOfProperty: #suspendedEventHandler) ifNotNil:
		[self eventHandler: savedHandler].
	submorphs do: [:m | m restoreSuspendedEventHandler]

]

{ #category : #'debug and other' }
Morph >> resumeAfterDrawError [

	self changed.
	self removeProperty:#errorOnDraw.
	self changed.
]

{ #category : #'debug and other' }
Morph >> resumeAfterStepError [
	"Resume stepping after an error has occured."

	self startStepping. "Will #step"
	self removeProperty:#errorOnStep. "Will remove prop only if #step was okay"

]

{ #category : #'layout-properties' }
Morph >> reverseTableCells [
	"Layout specific. This property describes if the cells should be treated in reverse order of submorphs."
	| props |
	props := self layoutProperties.
	^props ifNil:[false] ifNotNil:[props reverseTableCells].
]

{ #category : #'layout-properties' }
Morph >> reverseTableCells: aBool [
	"Layout specific. This property describes if the cells should be treated in reverse order of submorphs."
	self assureTableProperties reverseTableCells: aBool.
	self layoutChanged.
]

{ #category : #geometry }
Morph >> right [
	" Return the x-coordinate of my right side "
	^ bounds right
]

{ #category : #geometry }
Morph >> right: aNumber [
	" Move me so that my right side is at the x-coordinate aNumber. My extent (width & height) are unchanged "

	self position: ((aNumber - bounds width) @ bounds top)
]

{ #category : #geometry }
Morph >> rightCenter [

	^ bounds rightCenter
]

{ #category : #structure }
Morph >> root [
	"Return the root of the composite morph containing the receiver. The owner of the root is either nil, a WorldMorph, or a HandMorph. If the receiver's owner is nil, the root is the receiver itself. This method always returns a morph."

	(owner isNil or: [owner isWorldOrHandMorph]) ifTrue: [^self].
	^owner root
]

{ #category : #structure }
Morph >> rootAt: location [
	"Just return myself, unless I am a WorldWindow.
	If so, then return the appropriate root in that world"

	^ self
]

{ #category : #'submorphs-accessing' }
Morph >> rootMorphsAt: aPoint [
	"Return the list of root morphs containing the given point, excluding the receiver.
	ar 11/8/1999: Moved into morph for an incredibly ugly hack in 3D worlds"
self flag: #arNote. "check this at some point"
	^ self submorphs select:
		[:m | (m fullContainsPoint: aPoint) and: [m isLocked not]]
]

{ #category : #'submorphs-accessing' }
Morph >> rootMorphsAtGlobal: aPoint [
	"Return the list of root morphs containing the given point, excluding the receiver.
	ar 11/8/1999: Moved into morph for an incredibly ugly hack in 3D worlds"

	^ self rootMorphsAt: (self pointFromWorld: aPoint)
]

{ #category : #'rotate scale and flex' }
Morph >> rotationCenter [
	"Return the rotation center of the receiver. The rotation center defines the relative offset inside the receiver's bounds for locating the reference position."
	^self valueOfProperty: #rotationCenter ifAbsent:[0.5@0.5]

]

{ #category : #'rotate scale and flex' }
Morph >> rotationCenter: aPointOrNil [
	"Set the new rotation center of the receiver. The rotation center defines the relative offset inside the receiver's bounds for locating the reference position."
	aPointOrNil isNil
		ifTrue:[self removeProperty: #rotationCenter]
		ifFalse:[self setProperty: #rotationCenter toValue: aPointOrNil]

]

{ #category : #'rotate scale and flex' }
Morph >> rotationDegrees [

	self isFlexed ifFalse: [^ 0.0].
	self owner in: [:flexShell | ^ flexShell rotationDegrees].
]

{ #category : #'rotate scale and flex' }
Morph >> rotationDegrees: degrees [

	self isFlexed ifFalse: [self addFlexShell].
	self owner in: [:flexShell | flexShell rotationDegrees: degrees].
]

{ #category : #'e-toy support' }
Morph >> rotationStyle [
	"Return the 'rotation style' of the receiver"
	^#normal
]

{ #category : #'e-toy support' }
Morph >> rotationStyle: aSymbol [
	"Set the 'rotation style' of the receiver; this is ignored for non-sketches"
]

{ #category : #miscellaneous }
Morph >> roundUpStrays [
	"Bring submorphs of playfieldlike structures in the receiver's interior back within view."

	self submorphsDo:
		[:m | m isPlayfieldLike ifTrue: [m roundUpStrays]]
]

{ #category : #rounding }
Morph >> roundedCorners [
	"Return a list of those corners to round.

		1-4
		|  |
		2-3

	Returned array contains `codes' of those corners, which should be rounded.

	1 denotes top-left corner
	2 denotes bottom-left corner
	3 denotes bottom-right corner
	4 denotes top-right corner.

	Thus, if this method returned #(2 3) that would mean that bottom (left and right)
	corners would be rounded whereas top (left and right) corners wouldn't be rounded.

	This method returns #(1 2 3 4) and that means that all the corners should be rounded."

	^ #(1 2 3 4)
]

{ #category : #rounding }
Morph >> roundedCornersString [
	"Answer the string to put in a menu that will invite the user to 
	switch to the opposite corner-rounding mode"
	^ (self wantsRoundedCorners
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'round corners' translated
]

{ #category : #'layout-properties' }
Morph >> rubberBandCells [
	"Layout specific. This property describes if a parent that is #shrinkWrapped around its children should ignore any #spaceFill children. E.g., when #rubberBandCells is true, the compound layout will always stay at the smallest available size, even though some child may be able to grow."
	| props |
	props := self layoutProperties.
	^props ifNil:[false] ifNotNil:[props rubberBandCells].
]

{ #category : #'layout-properties' }
Morph >> rubberBandCells: aBool [
	"Layout specific. This property describes if a parent that is #shrinkWrapped around its children should ignore any #spaceFill children. E.g., when #rubberBandCells is true, the compound layout will always stay at the smallest available size, even though some child may be able to grow."
	self assureTableProperties rubberBandCells: aBool.
	self layoutChanged.
]

{ #category : #'meta-actions' }
Morph >> saveAsPrototype [
	(UIManager default confirm: 'Make this morph the prototype for ', self class printString, '?')
		ifFalse: [^ self].
	self class prototype: self.

]

{ #category : #'fileIn\/out' }
Morph >> saveAsResource [

	| pathName |
	(self hasProperty: #resourceFilePath) ifFalse: [^ self].
	pathName := self valueOfProperty: #resourceFilePath.
	(pathName asLowercase endsWith: '.morph') ifFalse:
		[^ self error: 'Can only update morphic resources'].
	(FileStream newFileNamed: pathName) fileOutClass: nil andObject: self.
]

{ #category : #'fileIn\/out' }
Morph >> saveDocPane [

	Smalltalk at: #DocLibrary ifPresent:[:dl| dl external saveDocCheck: self]
]

{ #category : #'fileIn\/out' }
Morph >> saveOnFile [
	"Ask the user for a filename and save myself on a SmartRefStream file.  Writes out the version and class structure.  The file is fileIn-able.  UniClasses will be filed out."
	| aFileName |
	aFileName := ('my {1}.morph' translated format: {self class name}) asFileName.	"do better?"
	aFileName := UIManager default saveFilenameRequest: 'File name?' translated 
			initialAnswer: aFileName.
	aFileName ifNil: [^ Beeper beep].

	self allMorphsDo: [:m | m prepareToBeSaved].

	self saveOnFileNamed: aFileName
]

{ #category : #'fileIn\/out' }
Morph >> saveOnURL [
	"Ask the user for a url and save myself on a SmartReferenceStream file.  Writes out the version and class structure.  The file is fileIn-able.  UniClasses will be filed out."

	| um pg |
	(pg := self saveOnURLbasic) == #cancel ifTrue: [^ self].
	um := URLMorph newForURL: pg url.
	um setURL: pg url page: pg.
	pg isContentsInMemory ifTrue: [pg computeThumbnail].
	um isBookmark: true.
	um removeAllMorphs.
	um color: Color transparent.
	self primaryHand attachMorph: um.
]

{ #category : #'fileIn\/out' }
Morph >> saveOnURL: suggestedUrlString [ 
	"Save myself on a SmartReferenceStream file.  If I don't already have a url, use the suggested one.  Writes out the version and class structure.  The file is fileIn-able.  UniClasses will be filed out."
	| url pg stamp pol |
	(pg := self valueOfProperty: #SqueakPage)
		ifNil: [ pg := SqueakPage new ]
		ifNotNil:
			[ pg contentsMorph ~~ self ifTrue:
				[ self inform: 'morph''s SqueakPage property is out of date'.
				pg := SqueakPage new ] ].
	(url := pg url) ifNil: [ url := pg urlNoOverwrite: suggestedUrlString ].
	stamp := Utilities authorInitialsPerSe.
	stamp isEmptyOrNil ifTrue: [ stamp := '*' ].
	pg
		saveMorph: self
		author: stamp.
	SqueakPageCache
		atURL: url
		put: pg.
	"setProperty: #SqueakPage"
	(pol := pg policy) ifNil: [ pol := #neverWrite ].
	pg
		 policy: #now ;
		 dirty: true.
	pg write.
	"force the write"
	pg policy: pol.
	^pg
]

{ #category : #'fileIn\/out' }
Morph >> saveOnURLbasic [
	"Ask the user for a url and save myself on a SmartReferenceStream file.  Writes out the version and class structure.  The file is fileIn-able.  UniClasses will be filed out."

	| url pg stamp pol |
	(pg := self valueOfProperty: #SqueakPage) ifNil: [pg := SqueakPage new]
		ifNotNil: 
			[pg contentsMorph ~~ self 
				ifTrue: 
					[self inform: 'morph''s SqueakPage property is out of date'.
					pg := SqueakPage new]].
	(url := pg url) ifNil: 
			[url := ServerDirectory defaultStemUrl , '1.sp'.	"A new legal place"
			url := UIManager default 
						request: 'url of a place to store this object.
Must begin with file:// or ftp://'
						initialAnswer: url.
			url isEmpty ifTrue: [^#cancel]].
	stamp := Utilities authorInitialsPerSe.
	stamp isEmptyOrNil ifTrue: [ stamp := '*' ].
	pg saveMorph: self author: stamp.
	SqueakPageCache atURL: url put: pg.	"setProperty: #SqueakPage"
	(pol := pg policy) ifNil: [pol := #neverWrite].
	pg
		policy: #now;
		dirty: true.
	pg write.	"force the write"
	pg policy: pol.
	^pg
]

{ #category : #accessing }
Morph >> scaleFactor [
	^self valueOfProperty: #scaleFactor ifAbsent: [ 1.0 ]

]

{ #category : #'geometry - etoys' }
Morph >> screenLocation [
	"For compatibility only"

	^ self fullBounds origin
]

{ #category : #'geometry - etoys' }
Morph >> screenRectangle [
	"For compatibility only"

	^ self fullBounds
]

{ #category : #'selected object' }
Morph >> selectedObject [
	"answer the selected object for the hand or nil is none"
	^ self primaryHand selectedObject
]

{ #category : #'events-processing' }
Morph >> sendFilterEvent: anEvent for: anObject to: filterGroup [
	"An event gets filtered if some event filter wants to filter it."
	
	| filteredEvent |
	filterGroup ifNil: [^anEvent].

	filteredEvent := anEvent.
	filterGroup do: [:filterOrNil | filterOrNil ifNotNil: [:filter |
		filteredEvent := filter filterEvent: filteredEvent for: anObject]].
	
	^ filteredEvent
]

{ #category : #'events-processing' }
Morph >> sendFilterEventBubble: anEvent for: anObject [
	"Apply event bubbling filters."

	^ self
		sendFilterEventBubbleAgain: (self sendFilterEvent: anEvent for: anObject to: self eventBubbleFilters)
		for: anObject
]

{ #category : #'events-processing' }
Morph >> sendFilterEventBubbleAgain: anEvent for: anObject [
	"Apply keyboard-specific and mouse-specific bubbling filters. If a filter changes the event type, filter again. WARNING: This is a powerful mechanism. Filters can create endless loops, which are difficult to debug."

	| filteredEvent |
	filteredEvent := anEvent.
	
	filteredEvent isKeyboard ifTrue: [
		filteredEvent := self sendFilterEvent: filteredEvent for: anObject to: self keyboardBubbleFilters.
		filteredEvent isKeyboard not ifTrue: [^ self sendFilterEventBubbleAgain: filteredEvent for: anObject]].
		
	filteredEvent isMouse ifTrue: [
		filteredEvent := self sendFilterEvent: filteredEvent for: anObject to: self mouseBubbleFilters.
		filteredEvent isMouse not ifTrue: [^ self sendFilterEventBubbleAgain: filteredEvent for: anObject]].

	^ filteredEvent
]

{ #category : #'events-processing' }
Morph >> sendFilterEventCapture: anEvent for: anObject [
	"Apply event capturing filters."

	^ self
		sendFilterEventCaptureAgain: (self sendFilterEvent: anEvent for: anObject to: self eventCaptureFilters)
		for: anObject
]

{ #category : #'events-processing' }
Morph >> sendFilterEventCaptureAgain: anEvent for: anObject [
	"Apply keyboard-specific and mouse-specific capturing filters. If a filter changes the event type, filter again. WARNING: This is a powerful mechanism. Filters can create endless loops, which are difficult to debug."

	| filteredEvent |
	filteredEvent := anEvent.
	
	filteredEvent isKeyboard ifTrue: [
		filteredEvent := self sendFilterEvent: filteredEvent for: anObject to: self keyboardCaptureFilters.
		filteredEvent isKeyboard not ifTrue: [^ self sendFilterEventCaptureAgain: filteredEvent for: anObject]].
		
	filteredEvent isMouse ifTrue: [
		filteredEvent := self sendFilterEvent: filteredEvent for: anObject to: self mouseCaptureFilters.
		filteredEvent isMouse not ifTrue: [^ self sendFilterEventCaptureAgain: filteredEvent for: anObject]].

	^ filteredEvent
]

{ #category : #'dropping\/grabbing' }
Morph >> separateDragAndDrop [
	"Conversion only. Separate the old #dragNDropEnabled into #dragEnabled and #dropEnabled and remove the old property."
	| dnd |
	(self hasProperty: #dragNDropEnabled) ifFalse:[^self].
	dnd := (self valueOfProperty: #dragNDropEnabled) == true.
	self dragEnabled: dnd.
	self dropEnabled: dnd.
	self removeProperty: #dragNDropEnabled.

]

{ #category : #menus }
Morph >> setArrowheads [
	"Let the user edit the size of arrowheads for this object"

	| aParameter result  |
	aParameter := self renderedMorph valueOfProperty:  #arrowSpec ifAbsent:
		[Preferences parameterAt: #arrowSpec ifAbsent: [5 @ 4]].
	result := Morph obtainArrowheadFor: 'Head size for arrowheads: ' translated defaultValue: aParameter asString.
	result ifNotNil:
			[self renderedMorph  setProperty: #arrowSpec toValue: result]
		ifNil:
			[Beeper beep]
]

{ #category : #'e-toy support' }
Morph >> setAsActionInButtonProperties: buttonProperties [

	^false	"means I don't know how to be set as a button action"
]

{ #category : #'halos and balloon help' }
Morph >> setBalloonText: stringOrText [
	"Set receiver's balloon help text. Pass nil to remove the help."

	self flag: #deprecated. "mt: Use #balloonText:."
	self balloonText: stringOrText.
]

{ #category : #'halos and balloon help' }
Morph >> setBalloonText: stringOrText maxLineLength: aLength [ 
	"Set receiver's balloon help text. Pass nil to remove the help."
	
	self flag: #deprecated. "mt: Use #balloonText:."
	(extension isNil and: [stringOrText isNil]) ifTrue: [^ self].
	self assureExtension balloonText: 
		(stringOrText ifNotNil: [stringOrText asString withNoLineLongerThan: aLength])
]

{ #category : #accessing }
Morph >> setBorderStyle: aSymbol [
	"Set the border style of my costume"

	(self borderStyleForSymbol: aSymbol)
		ifNotNil: [:style | self borderStyle: style].
]

{ #category : #'halos and balloon help' }
Morph >> setCenteredBalloonText: aString [
	self setBalloonText: aString.
	self setProperty: #helpAtCenter toValue: true
]

{ #category : #'geometry - misc' }
Morph >> setConstrainedPosition: aPoint hangOut: partiallyOutside [
	"Change the position of this morph and and all of its submorphs to aPoint, but don't let me go outside my owner's bounds.  Let me go within two pixels of completely outside if partiallyOutside is true."

	| trialRect delta boundingMorph bRect |
	self flag: #smelly. "mt: The consideration of partiallyOutside is strange... The explicit #laoyutChanged, too."
	owner ifNil:[^self].
	trialRect := aPoint extent: self bounds extent.
	boundingMorph := self topRendererOrSelf owner.
	delta := boundingMorph
			ifNil:    [0@0]
			ifNotNil: [
				bRect := partiallyOutside 
					ifTrue: [boundingMorph bounds insetBy: 
								self extent negated + boundingMorph borderWidth + (2@2)]
					ifFalse: [boundingMorph bounds].
				trialRect amountToTranslateWithin: bRect].
	self position: aPoint + delta.
	self layoutChanged  "So that, eg, surrounding text will readjust"

]

{ #category : #'rotate scale and flex' }
Morph >> setDirectionFrom: aPoint [
	| delta degrees |
	delta := (self transformFromWorld globalPointToLocal: aPoint) - self referencePosition.
	degrees := delta degrees + 90.0.
	self forwardDirection: (degrees \\ 360) rounded.

]

{ #category : #miscellaneous }
Morph >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed"

	self extent: anExtent
]

{ #category : #layout }
Morph >> setExtentFromLayout: aPoint [
	"Sets the extent for laying out children of the receiver. We avoid triggering #layoutChanged again. This implementation is based on #extent:."
	
	"self assert: self owner layoutComputed not."
	
	self flag: #compatibility. "mt: There are way too many morphs that use #extent: to implement their own layout strategy such as updating gradient fills and submorph positions AND TEXT MORPH PARAGRAPHS (!). So, we *must* call #extent: to trigger those layout updates. Since our owner has not yet computed its layout, we are fine performance-wise."
	self extent: aPoint.
	
	self flag: #alternative. "mt: The following code represents the desired implementation of this method."
	"(self extent closeTo: aPoint) ifTrue: [^ self].

	self invalidRect: self outerBounds.
	bounds := bounds topLeft extent: aPoint.
	
	self removeProperty: #dropShadow.
	self invalidRect: self outerBounds."
]

{ #category : #miscellaneous }
Morph >> setFlexExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed.  Set the extent of the top renderer as indicated."

	self addFlexShellIfNecessary.
	self topRendererOrSelf extent: anExtent
]

{ #category : #layout }
Morph >> setLayoutBoundsFromLayout: newLayoutBounds [
	"Set the bounds for laying out children of the receiver. WE DO NOT MOVE CHILDREN HERE!
	
	Note that this code is written so that #layoutBounds can be changed without touching this method. For example, the layout bounds are smaller or larger than the current bounds.
	
	WE MUST NOT TRIGGER #layoutChanged AGAIN! See #doLayoutIn: and #adjustLayoutBounds."
	
	| priorBounds outer inner box |
	priorBounds := self outerBounds.
		
	outer := self bounds.
	inner := self layoutBounds.
	bounds := newLayoutBounds origin + (outer origin - inner origin) corner:
				newLayoutBounds corner + (outer corner - inner corner).
	
	bounds = outer ifFalse: [
		self removeProperty: #dropShadow.
		self invalidRect: (priorBounds quickMerge: self outerBounds)].
]

{ #category : #naming }
Morph >> setNamePropertyTo: aName [ 
	"change the receiver's externalName"
	self assureExtension externalName: aName
]

{ #category : #naming }
Morph >> setNameTo: aName [ 
	| nameToUse nameString |
	nameToUse := aName ifNotNil: 
					[(nameString := aName asString) notEmpty ifTrue: [nameString] ifFalse: ['*']].
	self setNamePropertyTo: nameToUse	"no Texts here!"
]

{ #category : #'e-toy support' }
Morph >> setNumericValue: aValue [
	"Set the receiver's contents to reflect the given numeric value.  Only certain kinds of morphs know what to do with this, the rest, for now, stash the number in a property, where it may not be visible but at least it won't be lost, and can be retrieved by the companion getter.  This code is never reached under normal circumstances, because the #numericValue slot is not shown in Viewers for most kinds of morphs, and those kinds of morphs that do show it also reimplement this method.  However, this code *could* be reached via a user script which sends #setNumericValue: but whose receiver has been changed, via tile-scripting drag and drop for example, to one that doesn't directly handle numbers"

	ScriptingSystem informScriptingUser: 'an unusual setNumericValue: call was made'.
	self renderedMorph setProperty: #numericValue toValue: aValue

]

{ #category : #layout }
Morph >> setPositionFromLayout: aPoint [
	"Sets the position for laying out children of the receiver. We have to move the children here. We avoid triggering #layoutChanged again. This implementation is based on #position:."
	
	| delta box |
	delta := (aPoint - self bounds topLeft) rounded.
	(delta x = 0 and: [delta y = 0]) ifTrue: [^ self].

	box := self privateFullBoundsForRedraw.
	self invalidRect: (box merge: (box translateBy: delta)).
	
	self privateFullMoveBy: delta.
]

{ #category : #'accessing - properties' }
Morph >> setProperties: aList [
	"Set many properties at once from a list of prop, value, prop, value"

	1 to: aList size by: 2 do: [:ii |
		self setProperty: (aList at: ii) toValue: (aList at: ii+1)].
]

{ #category : #'accessing - properties' }
Morph >> setProperty: aSymbol toValue: anObject [ 
	"change the receiver's property named aSymbol to anObject"
	anObject ifNil: [^ self removeProperty: aSymbol].
	self assureExtension setProperty: aSymbol toValue: anObject
]

{ #category : #menus }
Morph >> setRotationCenter [
	| p |
	self world displayWorld.
	p := Cursor crossHair showWhile:
		[Sensor waitButton].
	Sensor waitNoButton.
	self setRotationCenterFrom: (self transformFromWorld globalPointToLocal: p).


]

{ #category : #menus }
Morph >> setRotationCenterFrom: aPoint [
	self rotationCenter: (aPoint - self bounds origin) / self bounds extent asFloatPoint.
]

{ #category : #'drop shadows' }
Morph >> setShadowOffset: evt [
	| handle |
	handle := HandleMorph new forEachPointDo:
		[:newPoint | self shadowPoint: newPoint].
	evt hand attachMorph: handle.
	handle startStepping.

]

{ #category : #'e-toy support' }
Morph >> setStandardTexture [
	| parms |
	parms := self textureParameters.
	self makeGraphPaperGrid: parms first
		background: parms second
		line: parms third
]

{ #category : #menus }
Morph >> setToAdhereToEdge: anEdge [
	anEdge ifNil: [^ self].
	anEdge == #none ifTrue: [^ self removeProperty: #edgeToAdhereTo].
	self setProperty: #edgeToAdhereTo toValue: anEdge.

]

{ #category : #'drop shadows' }
Morph >> shadowColor [
	^self valueOfProperty: #shadowColor ifAbsent:[Color black]
]

{ #category : #'drop shadows' }
Morph >> shadowColor: aColor [
	self shadowColor = aColor ifTrue: [^ self].
	self setProperty: #shadowColor toValue: aColor.
	self removeProperty: #dropShadow.
	self changed.
]

{ #category : #drawing }
Morph >> shadowForm [
	"Return a form representing the 'shadow' of the receiver - e.g., all pixels that are occupied by the receiver are one, all others are zero."
	| canvas |
	canvas := (Display defaultCanvasClass extent: self fullBounds extent depth: 1)
				asShadowDrawingCanvas: Color black. "Color black represents one for 1bpp"
	canvas translateBy: bounds topLeft negated
		during:[:tempCanvas| tempCanvas fullDrawMorph: self].
	^ canvas form offset: bounds topLeft

]

{ #category : #'drop shadows' }
Morph >> shadowOffset [
	"Return the current shadow offset"
	^self valueOfProperty: #shadowOffset ifAbsent:[0@0]
]

{ #category : #'drop shadows' }
Morph >> shadowOffset: aPoint [
	"Set the current shadow offset"

	self shadowOffset = aPoint ifTrue: [^ self].
	self changed.

	(aPoint isNil or: [ aPoint isZero ])
		ifTrue:[self removeProperty: #shadowOffset]
		ifFalse:[self setProperty: #shadowOffset toValue: aPoint].

	self removeProperty: #dropShadow.
	self layoutChanged.
	self changed.
]

{ #category : #'drop shadows' }
Morph >> shadowPoint: newPoint [
	"Can be reset in #addDropShadow."
	
	| delta |
	delta := newPoint - self center.
	self shadowOffset: (self useSoftDropShadow
		ifTrue: [(10@8 corner: 10@12) outsetBy: delta]
		ifFalse: [delta]).


]

{ #category : #'geometry - misc' }
Morph >> shiftSubmorphsOtherThan: listNotToShift by: delta [
	| rejectList |
	rejectList := listNotToShift ifNil: [OrderedCollection new].
	(submorphs copyWithoutAll: rejectList) do:
		[:m | m position: (m position + delta)]
]

{ #category : #testing }
Morph >> shouldDropOnMouseUp [
	| former |
	former := self formerPosition ifNil:[^false].
	^(former dist: self position) > 10
]

{ #category : #'WiW support' }
Morph >> shouldGetStepsFrom: aWorld [
	^self world == aWorld
]

{ #category : #player }
Morph >> shouldRememberCostumes [
	^true
]

{ #category : #drawing }
Morph >> show [

	self visible ifFalse: [self visible: true].
]

{ #category : #'meta-actions' }
Morph >> showActions [
	"Put up a message list browser of all the code that this morph  
	would run for mouseUp, mouseDown, mouseMove, mouseEnter,  
	mouseLeave, and  
	mouseLinger. tk 9/13/97"
	| list cls selector adder |
	list := OrderedCollection new.
	adder := [:mrClass :mrSel | list
				add: (MethodReference class: mrClass selector: mrSel)].
	"the eventHandler"
	self eventHandler
		ifNotNil: [list := self eventHandler methodRefList.
			(self eventHandler handlesMouseDown: nil)
				ifFalse: [adder value: HandMorph value: #grabMorph:]].
	"If not those, then non-default raw events"
	#(#keyStroke: #mouseDown: #mouseEnter: #mouseLeave: #mouseMove: #mouseUp: #doButtonAction )
		do: [:sel | 
			cls := self class whichClassIncludesSelector: sel.
			cls
				ifNotNil: ["want more than default behavior"
					cls == Morph
						ifFalse: [adder value: cls value: sel]]].
	"The mechanism on a Button"
	(self respondsTo: #actionSelector)
		ifTrue: ["A button"
			selector := self actionSelector.
			cls := self target class whichClassIncludesSelector: selector.
			cls
				ifNotNil: ["want more than default behavior"
					cls == Morph
						ifFalse: [adder value: cls value: selector]]].
	MessageSet openMessageList: list sort name: 'Actions
of ' , self printString autoSelect: nil
]

{ #category : #'halos and balloon help' }
Morph >> showBalloon [

	self showBalloon: self balloonText.
]

{ #category : #'halos and balloon help' }
Morph >> showBalloon: msgString [
	"Pop up a balloon containing the given string."

	self isInWorld ifFalse: [^ self].
	(msgString isNil or: [msgString isEmpty]) ifTrue: [^ self].
	
	(self balloonMorphClass
		string: msgString
		for: self balloonHelpAligner)
			popUp.
]

{ #category : #'halos and balloon help' }
Morph >> showBalloon: msgString at: point [
	"Pop up a balloon containing the given string."

	self isInWorld ifFalse: [^ self].
	(msgString isNil or: [msgString isEmpty]) ifTrue: [^ self].
	
	(self balloonMorphClass
		string: msgString
		for: self balloonHelpAligner)
			popUpAt: point.
]

{ #category : #'halos and balloon help' }
Morph >> showBalloon: msgString hand: aHand [
	"Pop up a balloon containing the given string. Note that any existing BalloonMorphs will be removed from the world."

	| balloon |
	self isInWorld ifFalse: [^ self].
	
	balloon := (self balloonMorphClass
		string: msgString
		for: self balloonHelpAligner).
		
	balloon
		popUpFor: self
		hand: (aHand ifNil: [self world activeHand]).
]

{ #category : #'meta-actions' }
Morph >> showHiders [
	self allMorphsDo:[:m | m show]
]

{ #category : #'submorphs-accessing' }
Morph >> shuffleSubmorphs [
	"Randomly shuffle the order of my submorphs.  Don't call this method lightly!"

	| bg |
	self invalidRect: self fullBounds.
	(submorphs notEmpty and: [submorphs last mustBeBackmost]) 
		ifTrue: 
			[bg := submorphs last.
			bg privateDelete].
	submorphs := submorphs shuffled.
	bg ifNotNil: [self addMorphBack: bg].
	self layoutChanged
]

{ #category : #'meta-actions' }
Morph >> sightTargets: event [ 
	"Return the potential targets for the receiver.  
	This is derived from Morph>>potentialEmbeddingTargets."
	| bullseye candidates choice |
	owner ifNil: [^ #()].
	bullseye := Point fromUserWithCursor: Cursor target.
	candidates := self potentialTargetsAt: bullseye.
	choice := UIManager default 
		chooseFrom: (candidates collect:[:m| m knownName ifNil:[m class name]])
		values: candidates.
	choice ifNotNil:[self target: choice].
]

{ #category : #'meta-actions' }
Morph >> sightWorldTargets: event [ 
	"Return the potential targets for the receiver.  
	This is derived from Morph>>potentialEmbeddingTargets."
	| bullseye myWorld candidates choice |
	myWorld := self world ifNil: [^ #()].
	bullseye := Point fromUserWithCursor: Cursor target.
	candidates := myWorld morphsAt: bullseye.
	choice := UIManager default 
		chooseFrom: (candidates collect:[:m| m knownName ifNil:[m class name]])
		values: candidates.
	choice ifNotNil:[self target: choice].
]

{ #category : #'dropping\/grabbing' }
Morph >> slideBackToFormerSituation: evt [ 
	"A drop of the receiver having been rejected, slide it back to where it came from, if possible."

	| slideForm formerOwner formerPosition aWorld startPoint endPoint trans |
	formerOwner := self formerOwner.
	formerPosition := self formerPosition.
	(aWorld := evt hand world) ifNil: [^ self delete]. "Likely a moribund hand from an EventRecorder playback."

	trans := formerOwner transformFromWorld.
	slideForm := trans isPureTranslation 
				ifTrue: [self imageForm offset: 0 @ 0]
				ifFalse: 
					[((TransformationMorph new asFlexOf: self) transform: trans) imageForm 
						offset: 0 @ 0]. 
	startPoint := evt hand fullBounds origin.
	endPoint := trans localPointToGlobal: formerPosition.
	owner removeMorph: self.
	aWorld displayWorld.
	slideForm 
		slideFrom: startPoint
		to: endPoint
		nSteps: 12
		delay: 15.
	"The OLPC Virtual Screen wouldn't notice the last update here."
	self refreshWorld.
	formerOwner addMorph: self.
	self position: formerPosition.
	self justDroppedInto: formerOwner event: evt
]

{ #category : #'dropping\/grabbing' }
Morph >> slideToTrash: evt [
	"Perhaps slide the receiver across the screen to a trash can and make it disappear into it.  In any case, remove the receiver from the screen."

	| aForm trash startPoint endPoint morphToSlide |
	((self renderedMorph == ScrapBook default scrapBook) or: [self renderedMorph isKindOf: TrashCanMorph]) ifTrue:
		[self dismissMorph.  ^ self].
	TrashCanMorph slideDismissalsToTrash ifTrue:
		[morphToSlide := self representativeNoTallerThan: 200 norWiderThan: 200 thumbnailHeight: 100.
		aForm := morphToSlide imageForm offset: (0@0).
		trash := self currentWorld
			findDeepSubmorphThat:
				[:aMorph | (aMorph isKindOf: TrashCanMorph) and:
					[aMorph topRendererOrSelf owner == self currentWorld]]
			ifAbsent:
				[trash := TrashCanMorph new.
				trash position: self currentWorld bottomLeft - (0 @ (trash extent y + 26)).
				trash openInWorld.
				trash].
		endPoint := trash fullBoundsInWorld center.
		startPoint := self topRendererOrSelf fullBoundsInWorld center - (aForm extent // 2)].
	self dismissMorph.
	self currentWorld displayWorld.
	TrashCanMorph slideDismissalsToTrash ifTrue:
		[aForm slideFrom: startPoint to: endPoint nSteps: 12 delay: 15].
	ScrapBook default addToTrash: self
]

{ #category : #menus }
Morph >> snapToEdgeIfAppropriate [
	| edgeSymbol oldBounds aWorld |
	(edgeSymbol := self valueOfProperty: #edgeToAdhereTo) ifNotNil:
		[oldBounds := bounds.
		self adhereToEdge: edgeSymbol.
		bounds ~= oldBounds ifTrue: [(aWorld := self world) ifNotNil: [aWorld viewBox ifNotNil:
			[aWorld displayWorld]]]]
]

{ #category : #'layout-properties' }
Morph >> spaceFillWeight [
	"Layout specific. This property describes the relative weight that 
	should be given to the receiver when extra space is distributed 
	between different #spaceFill cells."

	^ self
		valueOfProperty: #spaceFillWeight
		ifAbsent: [1]
]

{ #category : #'layout-properties' }
Morph >> spaceFillWeight: aNumber [
	"Layout specific. This property describes the relative weight that should be given to the receiver when extra space is distributed between different #spaceFill cells."
	aNumber = 1
		ifTrue:[self removeProperty: #spaceFillWeight]
		ifFalse:[self setProperty: #spaceFillWeight toValue: aNumber].
	self layoutChanged.
]

{ #category : #naming }
Morph >> specialNameInModel [
	"Return the name for this morph in the underlying model or nil."

	"Not an easy problem.  For now, take the first part of the mouseDownSelector symbol in my eventHandler (fillBrushMouseUp:morph: gives 'fillBrush').  5/26/97 tk"

	| hh |
	(self isMorphicModel) 
		ifTrue: [^self slotName]
		ifFalse: 
			[self eventHandler ifNotNil: 
					[self eventHandler mouseDownSelector ifNotNil: 
							[hh := self eventHandler mouseDownSelector indexOfSubCollection: 'Mouse'
										startingAt: 1.
							hh > 0 
								ifTrue: [^self eventHandler mouseDownSelector copyFrom: 1 to: hh - 1]].
					self eventHandler mouseUpSelector ifNotNil: 
							[hh := self eventHandler mouseUpSelector indexOfSubCollection: 'Mouse'
										startingAt: 1.
							hh > 0 ifTrue: [^self eventHandler mouseUpSelector copyFrom: 1 to: hh - 1]]]].

	"	(self eventHandler mouseDownRecipient respondsTo: #nameFor:) ifTrue: [
					^ self eventHandler mouseDownRecipient nameFor: self]]].	"
	"myModel := self findA: MorphicModel.
			myModel ifNotNil: [^ myModel slotName]"
	^self world specialNameInModelFor: self
]

{ #category : #accessing }
Morph >> sqkPage [
	^ self valueOfProperty: #SqueakPage
]

{ #category : #initialization }
Morph >> standardPalette [
	"Answer a standard palette forced by some level of enclosing presenter, or nil if none"
	| pal aPresenter itsOwner |
	(aPresenter := self presenter) ifNil: [^ nil].
	^ (pal := aPresenter ownStandardPalette)
		ifNotNil: [pal]
		ifNil:	[(itsOwner := aPresenter associatedMorph owner)
					ifNotNil:
						[itsOwner standardPalette]
					ifNil:
						[nil]]
]

{ #category : #'stepping and presenter' }
Morph >> start [
	"Start running my script. For ordinary morphs, this means start stepping."

	self startStepping.

]

{ #category : #'event handling' }
Morph >> startDrag: evt [
	"Handle a double-click event. This message is only sent to clients that request it by sending #waitForClicksOrDrag:event: to the initiating hand in their mouseDown: method. This default implementation does nothing."

	self eventHandler ifNotNil:
		[self eventHandler startDrag: evt fromMorph: self].
]

{ #category : #'dropping\/grabbing' }
Morph >> startDrag: anItem with: anObject [
	self currentHand attachMorph: anObject
]

{ #category : #'stepping and presenter' }
Morph >> startStepping [
	"Start getting sent the 'step' message."
	self startStepping: #stepAt: at: Time millisecondClockValue arguments: nil stepTime: nil.
]

{ #category : #'stepping and presenter' }
Morph >> startStepping: aSelector at: scheduledTime arguments: args stepTime: stepTime [
	"Start stepping the receiver"
	| w |
	w := self world.
	w ifNotNil: [
		w startStepping: self at: scheduledTime selector: aSelector arguments: args stepTime: stepTime.
		self changed].
]

{ #category : #'stepping and presenter' }
Morph >> startSteppingIn: aWorld [
	"Start getting sent the 'step' message in aWorld"

	self step.  "one to get started!"
	aWorld ifNotNil: [aWorld startStepping: self].
	self changed
]

{ #category : #'stepping and presenter' }
Morph >> startSteppingSelector: aSelector [
	"Start getting sent the 'step' message."
	self startStepping: aSelector at: Time millisecondClockValue arguments: nil stepTime: nil.
]

{ #category : #menu }
Morph >> startWiring [
	Smalltalk
		at: #NCAAConnectorMorph
		ifPresent: [:connectorClass | connectorClass newCurvyArrow startWiringFrom: self] 
]

{ #category : #'stepping and presenter' }
Morph >> step [
	"Do some periodic activity. Use startStepping/stopStepping to start and stop getting sent this message. The time between steps is specified by this morph's answer to the stepTime message.  The generic version dispatches control to the player, if any.  The nasty circumlocation about owner's transformation is necessitated by the flexing problem that the player remains in the properties dictionary both of the flex and the real morph.  In the current architecture, only the top renderer's pointer to the player should actually be honored for the purpose of firing."

]

{ #category : #'stepping and presenter' }
Morph >> stepAt: millisecondClockValue [
	"Do some periodic activity. Use startStepping/stopStepping to start and stop getting sent this message. The time between steps is specified by this morph's answer to the stepTime message.
	The millisecondClockValue parameter gives the value of the millisecond clock at the moment of dispatch.
	Default is to dispatch to the parameterless step method for the morph, but this protocol makes it possible for some morphs to do differing things depending on the clock value"
	self player ifNotNil:[:p| p stepAt: millisecondClockValue].
	self step

]

{ #category : #'stepping and presenter' }
Morph >> stepTime [
	"Answer the desired time between steps in milliseconds. This default implementation requests that the 'step' method be called once every second."

	^ self topRendererOrSelf player ifNotNil: [10] ifNil: [1000]
]

{ #category : #menus }
Morph >> stickinessString [
	"Answer the string to be shown in a menu to represent the  
	stickiness status"
	^ (self isSticky
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'resist being picked up' translated
]

{ #category : #accessing }
Morph >> sticky: aBoolean [ 
	"change the receiver's sticky property"
	(extension isNil and: [aBoolean not]) ifTrue: [^ self].
	self assureExtension sticky: aBoolean
]

{ #category : #'stepping and presenter' }
Morph >> stop [
	"Stop running my script. For ordinary morphs, this means stop stepping."

	self stopStepping.

]

{ #category : #'stepping and presenter' }
Morph >> stopStepping [
	"Stop getting sent the 'step' message."

	| w |
	w := self world.
	w ifNotNil: [w stopStepping: self].

]

{ #category : #'stepping and presenter' }
Morph >> stopSteppingSelector: aSelector [
	"Stop getting sent the given message."
	| w |
	w := self world.
	w ifNotNil: [w stopStepping: self selector: aSelector].

]

{ #category : #'stepping and presenter' }
Morph >> stopSteppingSelfAndSubmorphs [
	self allMorphsDo: [:m | m stopStepping]

]

{ #category : #'objects from disk' }
Morph >> storeDataOn: aDataStream [
	"Let all Morphs be written out.  All owners are weak references.  They only go out if the owner is in the tree being written."
	| cntInstVars cntIndexedVars ti localInstVars |

	"block my owner unless he is written out by someone else"
	cntInstVars := self class instSize.
	cntIndexedVars := self basicSize.
	localInstVars := Morph instVarNames.
	ti := 2.  
	((localInstVars at: ti) = 'owner') & (Morph superclass == Object) ifFalse:
			[self error: 'this method is out of date'].
	aDataStream
		beginInstance: self class
		size: cntInstVars + cntIndexedVars.
	1 to: ti-1 do:
		[:i | aDataStream nextPut: (self instVarAt: i)].
	aDataStream nextPutWeak: owner.	"owner only written if in our tree"
	ti+1 to: cntInstVars do:
		[:i | aDataStream nextPut: (self instVarAt: i)].
	1 to: cntIndexedVars do:
		[:i | aDataStream nextPut: (self basicAt: i)]
]

{ #category : #printing }
Morph >> structureString [
	"Return a string that showing this morph and all its submorphs in an indented list that reflects its structure."

	| s |
	s := WriteStream on: (String new: 1000).
	self printStructureOn: s indent: 0.
	^ s contents

]

{ #category : #'meta-actions' }
Morph >> subclassMorph [
	"Create a new subclass of this morph's class and make this morph be an instance of it."

	| oldClass newClassName newClass |
	oldClass := self class.
	newClassName := UIManager default
		request: 'Please give this new class a name'
		initialAnswer: oldClass name.
	newClassName = '' ifTrue: [^ self].
	(Smalltalk includesKey: newClassName)
		ifTrue: [^ self inform: 'Sorry, there is already a class of that name'].

	newClass := oldClass subclass: newClassName asSymbol
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: oldClass category asString.
	self becomeForward: (self as: newClass)
]

{ #category : #'submorphs-accessing' }
Morph >> submorphAfter [
	"Return the submorph after (behind) me, or nil"
	| ii |
	owner ifNil: [^ nil].
	^ (ii := owner submorphIndexOf: self) = owner submorphs size 
		ifTrue: [nil]
		ifFalse: [owner submorphs at: ii+1].
	

]

{ #category : #'submorphs-accessing' }
Morph >> submorphBefore [
	"Return the submorph after (behind) me, or nil"
	| ii |
	owner ifNil: [^ nil].
	^ (ii := owner submorphIndexOf: self) = 1 
		ifTrue: [nil]
		ifFalse: [owner submorphs at: ii-1].
	

]

{ #category : #layout }
Morph >> submorphBounds [
	"Private. Compute the actual full bounds of the receiver"
	| box |
	submorphs do: [:m | | subBox | 
		(m visible) ifTrue: [
			subBox := m fullBounds.
			box 
				ifNil:[box := subBox copy]
				ifNotNil:[box := box quickMerge: subBox]]].
	box ifNil:[^self bounds]. "e.g., having submorphs but not visible"
	^ box origin asIntegerPoint corner: box corner asIntegerPoint

]

{ #category : #layout }
Morph >> submorphBoundsForShrinkWrap [
	"Private. Compute the submorph bounds of the receiver to shrink-wrap around. Note that we are not interested in my submorphs' fullBounds. For full-bound wrapping, use #shrinkWrap all the way down."
	
	| box |
	self submorphsDo: [:m |
		m visible ifTrue: [
			box 
				ifNil:[box := m bounds copy]
				ifNotNil:[box := box quickMerge: m bounds]]].
	box ifNil:[^ self layoutBounds]. "e.g., having submorphs but not visible"
	^ box origin asIntegerPoint corner: box corner asIntegerPoint
]

{ #category : #'submorphs-accessing' }
Morph >> submorphCount [

	^ submorphs size
]

{ #category : #'submorphs-add\/remove' }
Morph >> submorphIndexOf: aMorph [
	"Assuming aMorph to be one of my submorphs, answer where it occurs in my submorph list"

	^ submorphs indexOf: aMorph ifAbsent: [nil]
]

{ #category : #'submorphs-accessing' }
Morph >> submorphNamed: aName [
	^ self submorphNamed: aName ifNone: [nil]
]

{ #category : #'submorphs-accessing' }
Morph >> submorphNamed: aName ifNone: aBlock [ 
	"Find the first submorph with this name, or a button with an action selector of that name"

	
	self submorphs do: [:p | p knownName = aName ifTrue: [^p]].
	self submorphs do: 
			[:button | | sub args | 
			(button respondsTo: #actionSelector) 
				ifTrue: [button actionSelector == aName ifTrue: [^button]].
			((button respondsTo: #arguments) and: [(args := button arguments) notNil]) 
				ifTrue: [(args at: 2 ifAbsent: [nil]) == aName ifTrue: [^button]].
			(button isAlignmentMorph) 
				ifTrue: [(sub := button submorphNamed: aName ifNone: [nil]) ifNotNil: [^sub]]].
	^aBlock value
]

{ #category : #'submorphs-accessing' }
Morph >> submorphOfClass: aClass [

	^self findA: aClass
]

{ #category : #'submorphs-accessing' }
Morph >> submorphThat: block1 ifNone: block2 [

	^submorphs detect: block1 ifNone: block2
	
]

{ #category : #'submorphs-accessing' }
Morph >> submorphWithProperty: aSymbol [
	^ submorphs detect: [:aMorph | aMorph hasProperty: aSymbol] ifNone: [nil]
]

{ #category : #'submorphs-accessing' }
Morph >> submorphs [
	"This method returns my actual submorphs collection. Modifying the collection directly could be dangerous; make a copy if you need to alter it."
	^ submorphs 
]

{ #category : #'submorphs-accessing' }
Morph >> submorphsBehind: aMorph do: aBlock [
	| behind |
	behind := false.
	submorphs do:
		[:m | m == aMorph ifTrue: [behind := true]
						ifFalse: [behind ifTrue: [aBlock value: m]]].

]

{ #category : #'submorphs-accessing' }
Morph >> submorphsDo: aBlock [ 
	submorphs do: aBlock
]

{ #category : #'submorphs-accessing' }
Morph >> submorphsInFrontOf: aMorph do: aBlock [
	| behind |
	behind := false.
	submorphs do:
		[:m | m == aMorph ifTrue: [behind := true]
						ifFalse: [behind ifFalse: [aBlock value: m]]].

]

{ #category : #'submorphs-accessing' }
Morph >> submorphsReverseDo: aBlock [

	submorphs reverseDo: aBlock.
]

{ #category : #'submorphs-accessing' }
Morph >> submorphsSatisfying: aBlock [
	^ submorphs select: [:m | (aBlock value: m) == true]
]

{ #category : #'event handling' }
Morph >> suspendEventHandler [
	self eventHandler ifNotNil:
		[self setProperty: #suspendedEventHandler toValue: self eventHandler.
		self eventHandler: nil].
	submorphs do: [:m | m suspendEventHandler].  "All those rectangles"
]

{ #category : #'event handling' }
Morph >> tabAmongFields [
	^ Preferences tabAmongFields
		or: [self hasProperty: #tabAmongFields] 
]

{ #category : #'accessing-backstop' }
Morph >> target: aMorph [
"Morphs with targets will override. This backstop does nothing."
"This is here because targeting meta-actions are taken at morph level. 
Do not remove."
]

{ #category : #'meta-actions' }
Morph >> targetFromMenu: aMenu [ 
	"Some other morph become target of the receiver"
	| newTarget |
	
	newTarget := aMenu startUpWithCaption: self externalName , ' targets...'.
	newTarget
		ifNil: [^ self].
	self target: newTarget
]

{ #category : #'meta-actions' }
Morph >> targetWith: evt [
	"Some other morph become target of the receiver"
	|  morphs newTarget |
	morphs := self potentialTargets.
	newTarget := UIManager default
		chooseFrom: (morphs collect: [:m | m knownName ifNil:[m class name asString]])
		values: morphs
		title:  self externalName, ' targets...'.
	newTarget ifNil:[^self].
	self target: newTarget.
]

{ #category : #'debug and other' }
Morph >> tempCommand [
	"Generic backstop.  If you care to, you can comment out what's below here, and substitute your own code, though the intention of design of the feature is that you leave this method as it is, and instead reimplement tempCommand in the class of whatever individual morph you care to.  In any case, once you have your own #tempCommand in place, you will then be able to invoke it from the standard debugging menus."

	self inform: 'Before calling tempCommand, you
should first give it a definition.  To
do this, choose "define tempCommand"
from the debug menu.' translated
]

{ #category : #'text-anchor' }
Morph >> textAnchorProperties [

	^ self valueOfProperty: #textAnchorProperties ifAbsentPut: [TextAnchorProperties new]
]

{ #category : #printing }
Morph >> textToPaste [
	"If the receiver has text to offer pasting, answer it, else answer nil"

	^ nil
]

{ #category : #'e-toy support' }
Morph >> textureParameters [
	"Answer a triplet giving the preferred grid size, background color, and line color.  The choices here are as suggested by Alan, 9/13/97"

	^ Array with: 16 with: Color lightYellow with: Color lightGreen lighter lighter
]

{ #category : #thumbnail }
Morph >> thumbnail [
	"Answer an appropiate form to represent the receiver"

	| maxExtent fb |
	
	maxExtent := 320 @ 240.
	fb := self fullBounds.
	^ fb area <= (maxExtent x * maxExtent y)
		ifTrue: [self imageForm]
		ifFalse: [self imageFormForRectangle: (fb topLeft extent: maxExtent)]
]

{ #category : #rounding }
Morph >> toggleCornerRounding [
	self cornerStyle == #rounded
		ifTrue: [self cornerStyle: #square]
		ifFalse: [self cornerStyle: #rounded].
	self changed
]

{ #category : #'drop shadows' }
Morph >> toggleDropShadow [
	self hasDropShadow
		ifTrue:[self removeDropShadow]
		ifFalse:[self addDropShadow].
]

{ #category : #accessing }
Morph >> toggleLocked [
	
	self lock: self isLocked not
]

{ #category : #accessing }
Morph >> toggleResistsRemoval [
	"Toggle the resistsRemoval property"

	self resistsRemoval
		ifTrue:
			[self removeProperty: #resistsRemoval]
		ifFalse:
			[self setProperty: #resistsRemoval toValue: true]
]

{ #category : #accessing }
Morph >> toggleStickiness [
	"togle the receiver's Stickiness"
	extension ifNil: [^ self beSticky].
	extension sticky: extension sticky not
]

{ #category : #geometry }
Morph >> top [
	" Return the y-coordinate of my top side "

	^ bounds top
]

{ #category : #geometry }
Morph >> top: aNumber [
	" Move me so that my top is at the y-coordinate aNumber. My extent (width & height) are unchanged "

	self position: (bounds left @ aNumber)
]

{ #category : #geometry }
Morph >> topCenter [

	^ bounds topCenter
]

{ #category : #geometry }
Morph >> topLeft [

	^ bounds topLeft
]

{ #category : #geometry }
Morph >> topLeft: aPoint [
	" Move me so that my top left corner is at aPoint. My extent (width & height) are unchanged "

	self position: aPoint

]

{ #category : #structure }
Morph >> topPasteUp [
	"If the receiver is in a world, return that; otherwise return the outermost pasteup morph"
	^ self outermostMorphThat: [:m | m isKindOf: PasteUpMorph]
]

{ #category : #structure }
Morph >> topRendererOrSelf [
	"Answer the topmost renderer for this morph, or this morph itself if it has no renderer. See the comment in Morph>isRenderer."

	| top topsOwner |
	owner ifNil: [^self].
	self isWorldMorph ifTrue: [^self].	"ignore scaling of this world"
	top := self.
	topsOwner := top owner.
	[topsOwner notNil and: [topsOwner isRenderer]] whileTrue: 
			[top := topsOwner.
			topsOwner := top owner].
	^top
]

{ #category : #geometry }
Morph >> topRight [

	^ bounds topRight
]

{ #category : #geometry }
Morph >> topRight: aPoint [
	" Move me so that my top right corner is at aPoint. My extent (width & height) are unchanged "

	self position: ((aPoint x - bounds width) @ (aPoint y))

]

{ #category : #'halos and balloon help' }
Morph >> transferHalo: event from: formerHaloOwner [
	"Progressively transfer the halo to the next likely recipient"
	| localEvt w target |

	self flag: #workAround. "For halo's distinction between 'target' and 'innerTarget' we need to bypass any renderers."
	(formerHaloOwner == self and:[self isRenderer and:[self wantsHaloFromClick not]]) ifTrue:[
		event shiftPressed ifTrue:[
			target := owner.
			localEvt := event transformedBy: (self transformedFrom: owner).
		] ifFalse:[
			target := self renderedMorph.
			localEvt := event transformedBy: (target transformedFrom: self).
		].
		^target transferHalo: localEvt from: target].

"	formerHaloOwner == self ifTrue:[^ self removeHalo]."

	"Never transfer halo to top-most world"
	(self isWorldMorph and:[owner isNil]) ifFalse:[
		(self wantsHaloFromClick and:[formerHaloOwner ~~ self]) 
			ifTrue:[^self addHalo: event from: formerHaloOwner]].

	event shiftPressed ifTrue:[
		"Pass it outwards"
		owner ifNotNil:[^owner transferHalo: event from: formerHaloOwner].
		"We're at the top level; throw the event back in to find recipient"
		formerHaloOwner removeHalo.
		^self processEvent: event copy resetHandlerFields.
	].
	self submorphsDo:[:m|
		localEvt := event transformedBy: (m transformedFrom: self).
		(m fullContainsPoint: localEvt position) 
			ifTrue:[^m transferHalo: event from: formerHaloOwner].
	].
	"We're at the bottom most level; throw the event back up to the root to find recipient"
	formerHaloOwner removeHalo.

	Preferences maintainHalos ifFalse:[
		(w := self world) ifNil: [ ^self ].
		localEvt := event transformedBy: (self transformedFrom: w) inverseTransformation.
		^w processEvent: localEvt resetHandlerFields.
	].

]

{ #category : #menus }
Morph >> transferStateToRenderer: aRenderer [
	"Transfer knownName, actorState, visible, and player info over to aRenderer, which is being imposed above me as a transformation shell"

	| current |
	(current := self actorStateOrNil) ifNotNil:
		[aRenderer actorState: current.
		self actorState: nil].

	(current := self knownName) ifNotNil:
		[aRenderer setNameTo: current.
		self setNameTo: nil].

	(current := self player) ifNotNil:
		[aRenderer player: current.
		self player rawCostume: aRenderer.
		"NB player is redundantly pointed to in the extension of both the renderer and the rendee; this is regrettable but many years ago occasionally people tried to make that clean but always ran into problems iirc"
		"self player: nil"].

	aRenderer simplySetVisible: self visible



 

		
]

{ #category : #'event handling' }
Morph >> transformFrom: uberMorph [ 
	"Return a transform to be used to map coordinates in a morph above me into my childrens coordinates, or vice-versa. This is used to support scrolling, scaling, and/or rotation. This default implementation just returns my owner's transform or the identity transform if my owner is nil. 
	Note:  This method cannot be used to map into the receiver's coordinate system!"

	(self == uberMorph or: [owner isNil]) ifTrue: [^IdentityTransform new].
	^owner transformFrom: uberMorph
]

{ #category : #'event handling' }
Morph >> transformFromOutermostWorld [
	"Return a transform to map world coordinates into my local coordinates"

	"self isWorldMorph ifTrue: [^ MorphicTransform identity]."
	^ self transformFrom: self outermostWorldMorph
]

{ #category : #'event handling' }
Morph >> transformFromWorld [
	"Return a transform to map world coordinates into my local coordinates"

	^ self transformFrom: nil
]

{ #category : #'geometry - misc' }
Morph >> transformedBy: aTransform [
	aTransform isIdentity ifTrue:[^self].
	aTransform isPureTranslation ifTrue:[
		^self position: (aTransform localPointToGlobal: self position).
	].
	^self addFlexShell transformedBy: aTransform
]

{ #category : #'events-processing' }
Morph >> transformedFrom: uberMorph [
	"Return a transform to map coordinates of uberMorph, a morph above me in my owner chain, into the coordinates of MYSELF not any of my children."
	self flag: #arNote. "rename this method"
	owner ifNil:[^IdentityTransform new].
	^ (owner transformFrom: uberMorph)
]

{ #category : #'dropping\/grabbing' }
Morph >> transportedMorph [
	^self
]

{ #category : #naming }
Morph >> tryToRenameTo: aName [
	"A new name has been submited; make sure it's appropriate, and react accordingly.  This circumlocution provides the hook by which the simple renaming of a field can result in a change to variable names in a stack, etc.  There are some problems to worry about here."

	self renameTo: aName.
]

{ #category : #accessing }
Morph >> unHighlight [
	self color: self regularColor
]

{ #category : #menus }
Morph >> uncollapseSketch [

	| uncollapsedVersion w whomToDelete |

	(w := self world) ifNil: [^self].
	uncollapsedVersion := self valueOfProperty: #uncollapsedMorph.
	uncollapsedVersion ifNil: [^self].
	whomToDelete := self valueOfProperty: #collapsedMorphCarrier.
	uncollapsedVersion setProperty: #collapsedPosition toValue: whomToDelete position.

	whomToDelete delete.
	w addMorphFront: uncollapsedVersion.


]

{ #category : #'dropping\/grabbing' }
Morph >> undoGrabCommand [
	"Return an undo command for grabbing the receiver"

	| cmd |
	owner ifNil:
		[^ nil]. "no owner - no undo"
	^ (cmd := Command new)
		cmdWording: 'move ' translated, self nameForUndoWording;
		undoTarget: self
		selector: #undoMove:redo:owner:bounds:predecessor:
		arguments: {cmd. false. owner. self bounds. (owner morphPreceding: self)};
		yourself
]

{ #category : #undo }
Morph >> undoMove: cmd redo: redo owner: formerOwner bounds: formerBounds predecessor: formerPredecessor [ 
	"Handle undo and redo of move commands in morphic"

	self owner ifNil: [^Beeper beep].
	redo 
		ifFalse: 
			["undo sets up the redo state first"

			cmd 
				redoTarget: self
				selector: #undoMove:redo:owner:bounds:predecessor:
				arguments: { 
						cmd.
						true.
						owner.
						bounds.
						owner morphPreceding: self}].
	formerOwner ifNotNil: 
			[formerPredecessor ifNil: [formerOwner addMorphFront: self]
				ifNotNil: [formerOwner addMorph: self after: formerPredecessor]].
	self bounds: formerBounds.
	(self isSystemWindow) ifTrue: [self beKeyWindow]
]

{ #category : #accessing }
Morph >> unlock [
	self lock: false
]

{ #category : #accessing }
Morph >> unlockContents [
	self submorphsDo:
		[:m | m unlock]
]

{ #category : #'e-toy support' }
Morph >> unlockOneSubpart [
	| unlockables reply |
	unlockables := self submorphs select:
		[:m | m isLocked].
	unlockables size <= 1 ifTrue: [^ self unlockContents].
	reply := UIManager default
		chooseFrom: (unlockables collect: [:m | m externalName]) 
		values: unlockables
		title:  'Who should be be unlocked?' translated.
	reply isNil ifTrue: [^ self].
	reply unlock
]

{ #category : #'fileIn\/out' }
Morph >> updateAllFromResources [

	self allMorphsDo: [:m | m updateFromResource]
]

{ #category : #naming }
Morph >> updateAllScriptingElements [
	"A sledge-hammer sweep from the world down to make sure that all live scripting elements are up to date.  Presently in eclipse, not sent at the moment."

	| aPasteUp |
	(aPasteUp := self topPasteUp) ifNotNil:
		[aPasteUp allTileScriptingElements do: [:m | m bringUpToDate]]
]

{ #category : #'e-toy support' }
Morph >> updateCachedThumbnail [
	"If I have a cached thumbnail, then update it.  Copied up from Dan's original version in PasteUpMorph so it can be used by all morphs."
	| cachedThumbnail |

	(cachedThumbnail := self valueOfProperty: #cachedThumbnail) ifNotNil:
		[(cachedThumbnail respondsTo: #computeThumbnail) 
			ifTrue: [cachedThumbnail computeThumbnail]
			ifFalse: [self removeProperty: #computeThumbnail]].
		"Test and removal are because the thumbnail is being replaced by another Morph.  We don't know why.  Need to fix that at the source."
]

{ #category : #drawing }
Morph >> updateDropShadowCache [

	| shadowOffset shadowBounds offset form canvas drawBlock localBounds mask maskCanvas |
	(shadowOffset := self shadowOffset) isRectangle
		ifTrue: [
			shadowBounds := 0@0 corner: (self bounds outsetBy: shadowOffset) extent.
			offset := 0@0.
			localBounds := shadowOffset topLeft extent: self extent ]
		ifFalse: [
			| extent |
			extent := self extent.
			shadowBounds := 0@0 corner: extent + shadowOffset abs.
			offset := shadowOffset max: 0@0.
			localBounds := (shadowOffset negated max: 0@0) extent: extent ].
		
	form := Form extent: shadowBounds extent depth: Display depth.
	canvas := form getCanvas.

	drawBlock := self useSoftDropShadow
		ifFalse: [
			[:c | self wantsRoundedCorners
					ifTrue: [c fillRoundRect: localBounds radius: self cornerRadius fillStyle: self shadowColor]
					ifFalse: [c fillRectangle: localBounds fillStyle: self shadowColor]]]
		ifTrue: [
			[:c | self wantsRoundedCorners
					ifTrue: [0 to: 9 do: [:i |
						c
							fillRoundRect: (shadowBounds insetBy: i)
							radius: (self cornerRadius max: 20) -i
							fillStyle: (self shadowColor alpha: self shadowColor alpha * (i+1))]]
					ifFalse: [0 to: 9 do: [:i | 
						c
							fillRoundRect: (shadowBounds insetBy: i) radius: 20-i
							fillStyle: (self shadowColor alpha: self shadowColor alpha * (i+1))]]]].
			
	canvas 
		translateBy: offset
		during: [ :shadowCanvas | drawBlock value: shadowCanvas].

	"Support transparent morph colors without having the shadow to shine through.."
	mask := Form extent: shadowBounds extent depth: Display depth.
	maskCanvas := mask getCanvas.
	self wantsRoundedCorners
		ifTrue: [maskCanvas fillRoundRect: (localBounds insetBy: self borderWidth) radius: self cornerRadius fillStyle: Color black]
		ifFalse: [maskCanvas fillRectangle: (localBounds insetBy: self borderWidth) fillStyle: Color black].
	mask
		displayOn: form
		at: 0@0
		rule: Form erase.
	
	self setProperty: #dropShadow toValue: form.
]

{ #category : #'fileIn\/out' }
Morph >> updateFromResource [
	| pathName newMorph f |
	(pathName := self valueOfProperty: #resourceFilePath) ifNil: [^self].
	(pathName asLowercase endsWith: '.morph') 
		ifTrue: 
			[newMorph := (FileStream readOnlyFileNamed: pathName) fileInObjectAndCode.
			(newMorph isMorph) 
				ifFalse: [^self error: 'Resource not a single morph']]
		ifFalse: 
			[f := Form fromFileNamed: pathName.
			f ifNil: [^self error: 'unrecognized image file format'].
			newMorph := self world drawingClass withForm: f].
	newMorph setProperty: #resourceFilePath toValue: pathName.
	self owner replaceSubmorph: self by: newMorph
]

{ #category : #copying }
Morph >> updateReferencesUsing: aDictionary [ 
	"Update intra-morph references within a composite morph that 
	has been copied. For example, if a button refers to morph X in 
	the orginal 
	composite then the copy of that button in the new composite 
	should refer to 
	the copy of X in new composite, not the original X. This default 
	implementation updates the contents of any morph-bearing slot. 
	It may be 
	overridden to avoid this behavior if so desired."
	| old |
	Morph instSize + 1
		to: self class instSize
		do: [:i | 
			old := self instVarAt: i.
			old isMorph
				ifTrue: [self
						instVarAt: i
						put: (aDictionary
								at: old
								ifAbsent: [old])]].
	extension ifNotNil: [extension updateReferencesUsing: aDictionary]
]

{ #category : #thumbnail }
Morph >> updateThumbnailUrl [
	"If I have a cached thumbnail, then update it's urls."
	| cachedThumbnail |

	(cachedThumbnail := self valueOfProperty: #cachedThumbnail) ifNotNil:
		[(cachedThumbnail respondsTo: #computeThumbnail) 
			ifTrue: [cachedThumbnail pageMorph: self url inBook: owner url]
			ifFalse: [self removeProperty: #computeThumbnail]].
			"Test and removal are because the thumbnail is being replaced 
			by another Morph.  We don't know why.  Need to fix that at 
			the source."
]

{ #category : #thumbnail }
Morph >> updateThumbnailUrlInBook: bookUrl [
	"If I have a cached thumbnail, then update it's urls."
	| cachedThumbnail |

	(cachedThumbnail := self valueOfProperty: #cachedThumbnail) ifNotNil:
		[(cachedThumbnail respondsTo: #computeThumbnail) 
			ifTrue: [cachedThumbnail pageMorph: self url inBook: bookUrl]
			ifFalse: [self removeProperty: #computeThumbnail]].
			"Test and removal are because the thumbnail is being replaced 
			by another Morph.  We don't know why.  Need to fix that at 
			the source."
]

{ #category : #'events-accessing' }
Morph >> updateableActionMap [
	"Answer an updateable action map, saving it in my #actionMap property"
	
	| actionMap |
	actionMap := self valueOfProperty: #actionMap.
	actionMap ifNil:
		[actionMap := self createActionMap.
		self setProperty: #actionMap toValue: actionMap].
	^ actionMap
]

{ #category : #accessing }
Morph >> url [
	"If I have been assigned a url, return it.  For PasteUpMorphs mostly."
	| sq |
	(sq := self sqkPage) ifNotNil: [^ sq url].
	^ self valueOfProperty: #url
		
]

{ #category : #copying }
Morph >> usableSiblingInstance [
	"Return another similar morph whose Player is of the same class as mine.
	Do not open it in the world."

	| aName newPlayer newMorph topRenderer counter world |
	(topRenderer := self topRendererOrSelf) == self 
		ifFalse: [^topRenderer usableSiblingInstance].
	self assuredPlayer assureUniClass.
	newMorph := self veryDeepCopySibling.
	newPlayer := newMorph player.
	newPlayer resetCostumeList.
	(aName := self knownName) isNil 
		ifTrue: [self player notNil ifTrue: [aName := newMorph innocuousName]].
	"Force a difference here"

	aName := aName stemAndNumericSuffix at: 1. 
	
	world := self world ifNil: [Project current world].
	(world hasProperty: #nameCounter) ifFalse: [
		(world setProperty: #nameCounter toValue: Dictionary new)
	].

	counter := (world valueOfProperty: #nameCounter) at: aName ifAbsent: [1].
	newMorph setNameTo: aName, counter.
	(world valueOfProperty: #nameCounter)  at: aName put: counter + 1.

	newMorph privateOwner: nil.
	newPlayer assureEventHandlerRepresentsStatus.
	self presenter flushPlayerListCache.
	^newMorph
]

{ #category : #'visual properties' }
Morph >> useBitmapFill [
	"Make receiver use a solid fill style (e.g., a simple color)"
	| fill |
	self fillStyle isBitmapFill ifTrue:[^self]. "Already done"
	fill := BitmapFillStyle fromForm: self defaultBitmapFillForm.
	"Note: Must fix the origin due to global coordinates"
	fill origin: self bounds origin.
	self fillStyle: fill.
]

{ #category : #'visual properties' }
Morph >> useDefaultFill [
	"Make receiver use a solid fill style (e.g., a simple color)"
	self fillStyle: self defaultColor.
]

{ #category : #'visual properties' }
Morph >> useGradientFill [
	"Make receiver use a solid fill style (e.g., a simple color)"
	| fill color1 color2 |
	self fillStyle isGradientFill ifTrue:[^self]. "Already done"
	color1 := self color asColor.
	color2 := color1 negated.
	fill := GradientFillStyle ramp: {0.0 -> color1. 1.0 -> color2}.
	fill origin: self topLeft.
	fill direction: 0 @ self bounds extent y.
	fill normal: self bounds extent x @ 0.
	fill radial: false.
	self fillStyle: fill
]

{ #category : #'drop shadows' }
Morph >> useSoftDropShadow [

	^ self
		valueOfProperty: #useSoftDropShadow
		ifAbsent: [self class useSoftDropShadow]
]

{ #category : #'drop shadows' }
Morph >> useSoftDropShadow: aBooleanOrNil [

	aBooleanOrNil
		ifNil: [self removeProperty: #useSoftDropShadow]
		ifNotNil: [self setProperty: #useSoftDropShadow toValue: aBooleanOrNil].
]

{ #category : #'visual properties' }
Morph >> useSolidFill [
	"Make receiver use a solid fill style (e.g., a simple color)"
	self fillStyle isSolidFill ifTrue:[^self]. "Already done"
	self fillStyle: self fillStyle asColor. "Try minimizing changes"
]

{ #category : #'change reporting' }
Morph >> userSelectedColor: aColor [
	"The user, via the UI, chose aColor to be the color for the receiver; set it, and tell my owner in case he wishes to react"
	self color: aColor.
	self world ifNotNil: [owner colorChangedForSubmorph: self]
]

{ #category : #accessing }
Morph >> userString [
	"Do I have a text string to be searched on?"

	^ nil
]

{ #category : #'layout-properties' }
Morph >> vResizeToFit: aBoolean [
	aBoolean ifTrue:[
		self vResizing: #shrinkWrap.
	] ifFalse:[
		self vResizing: #rigid.
	].
]

{ #category : #'layout-properties' }
Morph >> vResizing [
	"Layout specific. This property describes how the receiver should be resized with respect to its owner and its children. Possible values are:
		#rigid			-	do not resize the receiver
		#spaceFill		-	resize to fill owner's available space
		#shrinkWrap	- resize to fit children
	"
	| props |
	props := self layoutProperties.
	^props ifNil:[#rigid] ifNotNil:[props vResizing].
]

{ #category : #'layout-properties' }
Morph >> vResizing: aSymbol [
	"Layout specific. This property describes how the receiver should be resized with respect to its owner and its children. Possible values are:
		#rigid			-	do not resize the receiver
		#spaceFill		-	resize to fill owner's available space
		#shrinkWrap	- resize to fit children
	"
	self checkResizingProperty: aSymbol.
	self assureLayoutProperties vResizing: aSymbol.
	self layoutChanged.

]

{ #category : #'layout-properties' }
Morph >> vResizingString: aSymbol [
	^self layoutMenuPropertyString: aSymbol from: self vResizing
]

{ #category : #'accessing - properties' }
Morph >> valueOfProperty: aSymbol [ 
	"answer the value of the receiver's property named aSymbol"
	^ extension ifNotNil: [extension valueOfProperty: aSymbol]
]

{ #category : #'accessing - properties' }
Morph >> valueOfProperty: aSymbol ifAbsent: aBlock [ 
	"if the receiver possesses a property of the given name, answer  
	its value. If not then evaluate aBlock and answer the result of  
	this block evaluation"
	
	extension ifNil: [ ^aBlock value ].
	^extension	valueOfProperty: aSymbol ifAbsent: aBlock
]

{ #category : #'accessing - properties' }
Morph >> valueOfProperty: aSymbol ifAbsentPut: aBlock [ 
	"If the receiver possesses a property of the given name, answer  
	its value. If not, then create a property of the given name, give 
	it the value obtained by evaluating aBlock, then answer that  
	value"
	^ self assureExtension valueOfProperty: aSymbol ifAbsentPut: aBlock
]

{ #category : #'accessing - properties' }
Morph >> valueOfProperty: aSymbol ifPresentDo: aBlock [ 
	"If the receiver has a property of the given name, evaluate  
	aBlock on behalf of the value of that property"
	extension ifNil:  [^ self].
	^ aBlock value: (extension valueOfProperty: aSymbol ifAbsent: [^ self])
]

{ #category : #'dropping\/grabbing' }
Morph >> vanishAfterSlidingTo: aPosition event: evt [

	| aForm aWorld startPoint endPoint |
	aForm := self imageForm offset: 0@0.
	aWorld := self world.
	startPoint := evt hand fullBounds origin.
	self delete.
	aWorld displayWorld.
	endPoint := aPosition.
	aForm slideFrom: startPoint  to: endPoint nSteps: 12 delay: 15.
	SoundService soundEnabled ifTrue: [TrashCanMorph playDeleteSound].

]

{ #category : #copying }
Morph >> veryDeepCopyWith: deepCopier [
	"Copy me and the entire tree of objects I point to.  An object in the tree twice is copied once, and both references point to him.  deepCopier holds a dictionary of objects we have seen.  See veryDeepInner:, veryDeepFixupWith:"

	self prepareToBeSaved.
	^ super veryDeepCopyWith: deepCopier
]

{ #category : #copying }
Morph >> veryDeepFixupWith: deepCopier [
	"If some fields were weakly copied, fix new copy here."

	"super veryDeepFixupWith: deepCopier.	Object has no fixups, so don't call it"

	"If my owner is being duplicated too, then store his duplicate.
	 If I am owned outside the duplicated tree, then I am no longer owned!"
	owner := deepCopier references at: owner ifAbsent: [nil].


]

{ #category : #copying }
Morph >> veryDeepInner: deepCopier [ 
	"The inner loop, so it can be overridden when a field should not  
	be traced."
	"super veryDeepInner: deepCopier.	know Object has no inst vars"
	bounds := bounds shallowCopy.
	"Points are shared with original"
	"owner := owner.	special, see veryDeepFixupWith:"
	submorphs := submorphs veryDeepCopyWith: deepCopier.
	"each submorph's fixup will install me as the owner"
	"fullBounds := fullBounds.	fullBounds is shared with original!"
	color := color veryDeepCopyWith: deepCopier.
	"color, if simple, will return self. may be complex"
	extension := (extension veryDeepCopyWith: deepCopier)
]

{ #category : #accessing }
Morph >> viewBox [
	^ self pasteUpMorph viewBox
]

{ #category : #'debug and other' }
Morph >> viewMorphDirectly [
	"Open a Viewer directly on the Receiver, i.e. no Player involved"

	self presenter viewObjectDirectly: self renderedMorph

	
]

{ #category : #drawing }
Morph >> visible [
	"answer whether the receiver is visible"
	extension ifNil: [^ true].
	^ extension visible
]

{ #category : #drawing }
Morph >> visible: aBoolean [ 
	"set the 'visible' attribute of the receiver to aBoolean"
	(extension isNil and:[aBoolean]) ifTrue: [^ self].
	self visible == aBoolean ifTrue: [^ self].
	
	self changed.
	self assureExtension visible: aBoolean.
	self changed
]

{ #category : #accessing }
Morph >> visibleClearArea [
	"Answer the receiver visible clear area. The intersection 
	between the clear area and the viewbox."
	^ self viewBox intersect: self clearArea
]

{ #category : #'halos and balloon help' }
Morph >> wantsBalloon [
	"Answer true if receiver wants to show a balloon help text is a few moments."

	^ (self balloonText notNil) and: [Preferences balloonHelpEnabled]
]

{ #category : #'connectors-scripting' }
Morph >> wantsConnectorVocabulary [
	"Answer true if I want to show a 'connector' vocabulary"
	^false
]

{ #category : #'halos and balloon help' }
Morph >> wantsDirectionHandles [
	^self valueOfProperty: #wantsDirectionHandles ifAbsent:[Preferences showDirectionHandles]
]

{ #category : #'halos and balloon help' }
Morph >> wantsDirectionHandles: aBool [
	aBool == Preferences showDirectionHandles
		ifTrue:[self removeProperty: #wantsDirectionHandles]
		ifFalse:[self setProperty: #wantsDirectionHandles toValue: aBool].

]

{ #category : #'event handling' }
Morph >> wantsDropFiles: anEvent [
	"Return true if the receiver wants files dropped from the OS."
	^false
]

{ #category : #'dropping\/grabbing' }
Morph >> wantsDroppedMorph: aMorph event: evt [
	"Return true if the receiver wishes to accept the given morph, which is being dropped by a hand in response to the given event. Note that for a successful drop operation both parties need to agree. The symmetric check is done automatically via aMorph wantsToBeDroppedInto: self."

	^self dropEnabled
]

{ #category : #'event handling' }
Morph >> wantsEveryMouseMove [
	"Unless overridden, this method allows processing to skip mouse move events
	when processing is lagging.  No 'significant' event (down/up, etc) will be skipped."

	^ false
]

{ #category : #'halos and balloon help' }
Morph >> wantsHalo [
	| topOwner |
	^(topOwner := self topRendererOrSelf owner) notNil 
		and: [topOwner wantsHaloFor: self]
]

{ #category : #'halos and balloon help' }
Morph >> wantsHaloFor: aSubMorph [
	^ false
]

{ #category : #'halos and balloon help' }
Morph >> wantsHaloFromClick [

	^ self valueOfProperty: #wantsHaloFromClick ifAbsent: [^true].
]

{ #category : #'halos and balloon help' }
Morph >> wantsHaloFromClick: aBoolean [

	self 
		setProperty: #wantsHaloFromClick
		toValue: aBoolean.
]

{ #category : #'halos and balloon help' }
Morph >> wantsHaloHandleWithSelector: aSelector inHalo: aHaloMorph [
	"Answer whether the receiver would like to offer the halo handle with the given selector (e.g. #addCollapseHandle:)"

	(#(addDismissHandle:) includes: aSelector) ifTrue:
		[^ self resistsRemoval not].

	(#( addDragHandle: ) includes: aSelector) ifTrue:
		[^ self okayToBrownDragEasily].

	(#(addGrowHandle: addScaleHandle:) includes: aSelector) ifTrue:
		[^ self okayToResizeEasily].

	(#( addRotateHandle: ) includes: aSelector) ifTrue:
		[^ self okayToRotateEasily].

	(#(addRecolorHandle:) includes: aSelector) ifTrue:
		[^ self renderedMorph wantsRecolorHandle].

	true ifTrue: [^ true]
	
]

{ #category : #'event handling' }
Morph >> wantsKeyboardFocus [
	"Whether this morph should get the current keyboard focus when handling a keyboard event to speed up further event processing."

	^ false
]

{ #category : #'event handling' }
Morph >> wantsKeyboardFocusFor: aSubmorph [
	"Answer whether a plain mouse click on aSubmorph, a text-edit-capable thing, should result in a text selection there"
	^ false
]

{ #category : #menu }
Morph >> wantsMetaMenu [

	^ self valueOfProperty: #wantsMetaMenu ifAbsent: [true]
]

{ #category : #menu }
Morph >> wantsMetaMenu: aBoolean [

	self 
		setProperty: #wantsMetaMenu
		toValue: aBoolean.
]

{ #category : #'e-toy support' }
Morph >> wantsRecolorHandle [
	"Answer whether the receiver would like a recoloring halo handle to be put up.  Since this handle also presently affords access to the property-sheet, it is presently always allowed, even though SketchMorphs don't like regular recoloring"

	^ true
	

]

{ #category : #rounding }
Morph >> wantsRoundedCorners [
	"Return true if the receiver wants its corners rounded"
	^ self cornerStyle == #rounded
]

{ #category : #'halos and balloon help' }
Morph >> wantsScriptorHaloHandle [
	"Answer whether the receiver would like to have a Scriptor halo handle put up on its behalf.  Initially, only the ScriptableButton says yes"

	^ false
]

{ #category : #'halos and balloon help' }
Morph >> wantsSimpleSketchMorphHandles [
	"Answer true if my halo's simple handles should include the simple sketch morph handles."
	^false
]

{ #category : #'stepping and presenter' }
Morph >> wantsSteps [
	"Return true if the receiver overrides the default Morph step method."
	"Details: Find first class in superclass chain that implements #step and return true if it isn't class Morph."

	| c |
	self isPartsDonor ifTrue: [^ false].
	(self == self topRendererOrSelf) ifTrue: [self player wantsSteps ifTrue: [^ true]].
	c := self class.
	[c includesSelector: #step] whileFalse: [c := c superclass].
	^ c ~= Morph
]

{ #category : #accessing }
Morph >> wantsToBeCachedByHand [
	"Return true if the receiver wants to be cached by the hand when it is dragged around.
	Note: The default implementation queries all submorphs since subclasses may have shapes that do not fill the receiver's bounds completely."
	self hasTranslucentColor ifTrue:[^false].
	self submorphsDo:[:m|
		m wantsToBeCachedByHand ifFalse:[^false].
	].
	^true
]

{ #category : #'dropping\/grabbing' }
Morph >> wantsToBeDroppedInto: aMorph [
	"Return true if it's okay to drop the receiver into aMorph. This check is symmetric to #wantsDroppedMorph:event: to give both parties a chance of figuring out whether they like each other."
	^true
]

{ #category : #'dropping\/grabbing' }
Morph >> wantsToBeOpenedInWorld [
	"Return true if the receiver wants to be put into the World directly,
	rather than allowing the user to place it (e.g., prevent attaching me
	to the hand after choosing 'new morph' in the world menu)"
	^false
]

{ #category : #accessing }
Morph >> wantsToBeTopmost [
	"Answer if the receiver want to be one of the topmost objects in its owner"
	^ self isFlapOrTab
]

{ #category : #'event handling' }
Morph >> wantsWindowEvents: anEvent [
	"Return true if the receiver wants to process host window events. These are only dispatched to the World anyway, but one could have an eventListener in the Hand or a windowEventHandler in the World"
	^false
]

{ #category : #menu }
Morph >> wantsYellowButtonMenu [
	"Answer true if the receiver wants a yellow button menu"
	self
		valueOfProperty: #wantsYellowButtonMenu
		ifPresentDo: [:value | ^ value].
	""
	self isInSystemWindow
		ifTrue: [^ false].""
	(Preferences noviceMode
			and: [self isInDockingBar])
		ifTrue: [^ false].""
	^ Preferences generalizedYellowButtonMenu
]

{ #category : #menu }
Morph >> wantsYellowButtonMenu: aBoolean [ 
	"Change the receiver to wants or not a yellow button menu"
	self setProperty: #wantsYellowButtonMenu toValue: aBoolean
]

{ #category : #geometry }
Morph >> width [

	^ bounds width
]

{ #category : #geometry }
Morph >> width: aNumber [
	" Set my width; my position (top-left corner) and height will remain the same "

	self extent: aNumber asInteger@self height.

]

{ #category : #'dropping\/grabbing' }
Morph >> willingToBeDiscarded [
	^ true
]

{ #category : #'event handling' }
Morph >> windowEvent: anEvent [
	"Host window event"
]

{ #category : #structure }
Morph >> withAllOwners [
	"Return the receiver and all its owners"

	^ Array streamContents: [:strm | self withAllOwnersDo: [:m | strm nextPut: m]]
]

{ #category : #structure }
Morph >> withAllOwnersDo: aBlock [
	"Evaluate aBlock with the receiver and all of its owners"
	aBlock value: self.
	owner ifNotNil:[^owner withAllOwnersDo: aBlock].
]

{ #category : #structure }
Morph >> world [
	^owner isNil ifTrue: [nil] ifFalse: [owner world]
]

{ #category : #'geometry - misc' }
Morph >> worldBounds [
	^ self world bounds
]

{ #category : #'geometry - misc' }
Morph >> worldBoundsForHalo [
	"Answer the rectangle to be used as the inner dimension of my halos.
	Allow for showing either bounds or fullBounds, and compensate for the optional bounds rectangle."

	| r |
	r := (Preferences haloEnclosesFullBounds)
		ifFalse: [ self boundsIn: nil ]
		ifTrue: [ self fullBoundsInWorld ].
	Preferences showBoundsInHalo ifTrue: [ ^r outsetBy: 2 ].
	^r
]

{ #category : #'event handling' }
Morph >> wouldAcceptKeyboardFocus [
	"Answer whether a plain mouse click on the receiver should result in a text selection there"
	^ false
]

{ #category : #'event handling' }
Morph >> wouldAcceptKeyboardFocusUponTab [
	"Answer whether the receiver is in the running as the new keyboard focus if the tab key were hit at a meta level.  This provides the leverage for tabbing among fields of a card, for example."

	^ false
]

{ #category : #'layout-properties' }
Morph >> wrapCentering [
	"Layout specific. This property describes how the rows/columns in a list-like layout should be centered.
		#topLeft - center at start of secondary direction
		#bottomRight - center at end of secondary direction
		#center - center in the middle of secondary direction
		#justified - insert extra space inbetween rows/columns
	"
	| props |
	props := self layoutProperties.
	^props ifNil:[#topLeft] ifNotNil:[props wrapCentering].
]

{ #category : #'layout-properties' }
Morph >> wrapCentering: aSymbol [
	"Layout specific. This property describes how the rows/columns in a list-like layout should be centered.
		#topLeft - center at start of secondary direction
		#bottomRight - center at end of secondary direction
		#center - center in the middle of secondary direction
		#justified - insert extra space inbetween rows/columns
	"
	self assureTableProperties wrapCentering: aSymbol.
	self layoutChanged.
]

{ #category : #'layout-properties' }
Morph >> wrapCenteringString: aSymbol [
	^self layoutMenuPropertyString: aSymbol from: self wrapCentering
]

{ #category : #'layout-properties' }
Morph >> wrapDirection [
	"Layout specific. This property describes the direction along which a list-like layout should be wrapped. Possible values are:
		#leftToRight
		#rightToLeft
		#topToBottom
		#bottomToTop
		#none
	indicating in which direction wrapping should occur. This direction must be orthogonal to the list direction, that is if listDirection is #leftToRight or #rightToLeft then wrapDirection must be #topToBottom or #bottomToTop and vice versa."
	| props |
	props := self layoutProperties.
	^props ifNil:[#none] ifNotNil:[props wrapDirection].
]

{ #category : #'layout-properties' }
Morph >> wrapDirection: aSymbol [
	"Layout specific. This property describes the direction along which a list-like layout should be wrapped. Possible values are:
		#leftToRight
		#rightToLeft
		#topToBottom
		#bottomToTop
		#none
	indicating in which direction wrapping should occur. This direction must be orthogonal to the list direction, that is if listDirection is #leftToRight or #rightToLeft then wrapDirection must be #topToBottom or #bottomToTop and vice versa."
	self assureTableProperties wrapDirection: aSymbol.
	self layoutChanged.

]

{ #category : #'layout-properties' }
Morph >> wrapDirectionString: aSymbol [
	^self layoutMenuPropertyString: aSymbol from: self wrapDirection 
]

{ #category : #'e-toy support' }
Morph >> wrappedInWindow: aSystemWindow [
	| aWindow |
	aWindow := aSystemWindow model: Model new.
	aWindow addMorph: self frame: (0@0 extent: 1@1).
	aWindow extent: self extent.
	^ aWindow
]

{ #category : #'e-toy support' }
Morph >> wrappedInWindowWithTitle: aTitle [
	| aWindow w2 |
	aWindow := (SystemWindow labelled: aTitle) model: Model new.
	aWindow addMorph: self frame: (0@0 extent: 1@1).
	w2 := aWindow borderWidth * 2.
	w2 := 3.		"oh, well"
	aWindow extent: self fullBounds extent + (0 @ aWindow labelHeight) + (w2 @ w2).
	^ aWindow
]

{ #category : #'event handling' }
Morph >> yellowButtonActivity: shiftState [ 
	"Find me or my outermost owner that has items to add to a  
	yellow button menu.  
	shiftState is true if the shift was pressed.  
	Otherwise, build a menu that contains the contributions from  
	myself and my interested submorphs,  
	and present it to the user."
	| menu |
	self isWorldMorph
		ifFalse: [| outerOwner | 
			outerOwner := self outermostOwnerWithYellowButtonMenu.
			outerOwner
				ifNil: [^ self].
			outerOwner == self
				ifFalse: [^ outerOwner yellowButtonActivity: shiftState]].
	menu := self buildYellowButtonMenu: self currentHand.
	menu
		addTitle: self externalName
		icon: (self iconOrThumbnailOfSize: (Preferences tinyDisplay ifTrue: [16] ifFalse: [28])).
	menu popUpInWorld: self currentWorld
]

{ #category : #geniestubs }
Morph >> yellowButtonGestureDictionaryOrName: aSymbolOrDictionary [
]
