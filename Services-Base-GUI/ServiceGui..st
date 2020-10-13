"
I abstract all the UI-related behaviors for the services framework.
In the future I could be changed to be compatible with ToolBuilder
"
Class {
	#name : #ServiceGui,
	#superclass : #Object,
	#instVars : [
		'menu',
		'bar',
		'service',
		'n'
	],
	#classInstVars : [
		'bars'
	],
	#category : #'Services-Base-GUI'
}

{ #category : #'registering button bars' }
ServiceGui class >> bars [
	^ bars
]

{ #category : #hooks }
ServiceGui class >> browser: b classCategoryMenu: aMenu [ 
	^ (self new  for:b  id:#browserClassCategoryMenu)  inlineInMenu:aMenu
]

{ #category : #hooks }
ServiceGui class >> browser: b classMenu: aMenu [ 
	^ (self new  for:b  id:#browserClassMenu)  inlineInMenu:aMenu
]

{ #category : #hooks }
ServiceGui class >> browser: b codePaneMenu: aMenu [ 

	^(self new for: b id: #browserCodePaneMenu) inlineInMenu: aMenu
]

{ #category : #hooks }
ServiceGui class >> browser: b messageCategoryMenu: aMenu [ 
	^ (self new  for:b  id:#browserMethodCategoryMenu)  inlineInMenu:aMenu
]

{ #category : #hooks }
ServiceGui class >> browser: aBrowser messageListMenu: aMenu [ 
	^ (self new
		for: aBrowser
		id: #browserMethodMenu) inlineInMenu: aMenu
]

{ #category : #hooks }
ServiceGui class >> browserButtonRow: aBrowser [
	^ (self new for: aBrowser id: #browserButtonBar) buildButtonBar 
]

{ #category : #hooks }
ServiceGui class >> browserButtonRow: aBrowser inlinedIn: row [ 
	| bar |
	self buttonBarServices 
		ifTrue: [bar := (self new for: aBrowser id: #browserButtonBar) buildButtonBar.
			row addMorphBack: bar].
	^ row
]

{ #category : #preferences }
ServiceGui class >> buttonBarServices [
	^ ServicePreferences valueOfPreference: #useServicesInBrowserButtonBar 
]

{ #category : #'registering button bars' }
ServiceGui class >> initialize [
	bars := OrderedCollection new.
	(TheWorldMenu respondsTo: #registerOpenCommand:)
		ifTrue: [TheWorldMenu unregisterOpenCommand: 'Services Browser'.
			TheWorldMenu registerOpenCommand: {'Services Browser'. {PreferenceBrowser. #openForServices}}]
]

{ #category : #preferences }
ServiceGui class >> inlineServices [
	^ ServicePreferences valueOfPreference: #inlineServicesInMenu 
]

{ #category : #preferences }
ServiceGui class >> onlyServices [
	^ ServicePreferences valueOfPreference: #useOnlyServicesInMenu
]

{ #category : #'opening menus' }
ServiceGui class >> openMenuFor: aServiceCategory [
	(self new menuFor: aServiceCategory) invokeModal
]

{ #category : #'registering button bars' }
ServiceGui class >> registerBar: aBar for: service [
	
	self bars removeAllSuchThat: [:a | a value isNil].
	self bars add: (WeakValueAssociation key: service value: aBar).
]

{ #category : #'registering button bars' }
ServiceGui class >> updateBar: cat [
	
	self bars 
		select: [:assoc | (assoc key id = cat id) & assoc value notNil] 
		thenDo: [:assoc | | newBar | 
			cat requestor: assoc key requestor.
			newBar := self new buttonBarFor: cat.
			assoc value removeAllMorphs.
			newBar submorphsDo: [:m | assoc value addMorphBack: m]]
]

{ #category : #'registering button bars' }
ServiceGui class >> updateBars [
	
	self bars do: [:assoc | | oldCat cat newBar bar | 
		(bar := assoc value) ifNotNil: [
			oldCat := assoc key.
			cat := oldCat id service.
			cat requestor: oldCat requestor.
			newBar := self new buttonBarFor: cat.
			bar removeAllMorphs.
			newBar submorphsDo: [:m | bar addMorphBack: m]].
		]
]

{ #category : #hooks }
ServiceGui class >> updateMenu: aMenu forModel: aModel selector: selector [
	('codePane*' match: selector) ifTrue: [
	(self new for: aModel id: #codeSelectionRefactorings) inlineInMenu: aMenu].
	^ aMenu
	
]

{ #category : #hooks }
ServiceGui class >> worldMenu: aMenu [
	^ (self new for: aMenu id: #world) inlineInMenu: aMenu
]

{ #category : #accessing }
ServiceGui >> bar [
	^ bar
]

{ #category : #building }
ServiceGui >> buildButtonBar [
	bar := self buttonBarFor: service.
	self class registerBar: bar for: service.
	^ bar
]

{ #category : #servicecategory }
ServiceGui >> buttonBarFor: aServiceCategory [ 
	self styleBar: self bar.
	aServiceCategory enabledServices
		do: [:each | self bar
				addMorphBack: (self buttonFor: each)].
	^ self bar
]

{ #category : #services }
ServiceGui >> buttonFor: aService [
	^ aService isCategory ifTrue: [self buttonForCategory: aService]
							ifFalse: [self buttonForAction: aService]
]

{ #category : #serviceactions }
ServiceGui >> buttonForAction: aService [ 
	"see getstate for availability?"

	| aButton |
	aButton := PluggableButtonMorph 
				on: aService
				getState: nil
				action: #execute.
	self styleButton: aButton.
	aButton
		label: aService buttonLabel;
		setBalloonText: aService description.
	^aButton
]

{ #category : #servicecategory }
ServiceGui >> buttonForCategory: aService [ 
	"see getstate for availability?"

	| aButton |
	aButton := PluggableButtonMorph 
				on: [:button | aService requestor: button requestor. 
								self class openMenuFor: aService] 
				getState: nil
				action: #value:.
	aButton arguments: (Array with: aButton).
	self styleButton: aButton.
	aButton
		label: aService buttonLabel.
	^aButton
]

{ #category : #initialization }
ServiceGui >> for: caller id: id [ 
	service := id service.
	caller ifNotNil: [service requestor: caller requestor]
]

{ #category : #initialization }
ServiceGui >> initialize [
	super initialize.
	menu := OrderedCollection new.
	bar := AlignmentMorph newRow.
	n := OrderedCollection with: 0
]

{ #category : #building }
ServiceGui >> inlineInMenu: aMenu [ 
	^ self class inlineServices
		ifTrue: [self inlineInMenu: aMenu for: service]
		ifFalse: [aMenu]
]

{ #category : #servicecategory }
ServiceGui >> inlineInMenu: aMenu for: aServiceCategory [ 
	menu addLast: aMenu.
	aServiceCategory enabledServices
		do: [:each | self menuItemFor: each].
	^ self popMenu
]

{ #category : #accessing }
ServiceGui >> menu [
	^ menu last
]

{ #category : #servicecategory }
ServiceGui >> menuFor: aServiceCategory [ 
	| submenu |
	submenu := self subMenuFor: aServiceCategory.
	^ submenu
		addTitle: (aServiceCategory menuLabel)
]

{ #category : #services }
ServiceGui >> menuItemFor: aService [
	[aService isCategory ifTrue: [self menuItemForCategory: aService]
							ifFalse: [self menuItemForAction: aService]] 
		on: Error
		do: [:er | (self confirm: 'menuItemFor: error. debug?') ifTrue: [er signal]]
]

{ #category : #serviceactions }
ServiceGui >> menuItemForAction: aServiceAction [ 
	"Returns a menuItem triggering self"
	self menu
		add: (aServiceAction menuLabelNumbered: self n)
		target: aServiceAction
		selector: #execute.
	Smalltalk isMorphic ifTrue: [
		self menu lastItem isEnabled: aServiceAction executeCondition.
		self menu balloonTextForLastItem: aServiceAction description]
]

{ #category : #servicecategory }
ServiceGui >> menuItemForCategory: aServiceCategory [ 
	"Returns a menuItem triggering self"
	| submenu |
	submenu := self subMenuFor: aServiceCategory.
	self menu add: (aServiceCategory menuLabelNumbered: self n) subMenu: submenu
]

{ #category : #servicecategory }
ServiceGui >> n [
	^ n last
]

{ #category : #servicecategory }
ServiceGui >> n: nn [
	n removeLast.
	n addLast: nn
]

{ #category : #servicecategory }
ServiceGui >> popMenu [
	| aMenu |
	aMenu := menu removeLast.
	n removeLast.
	self styleMenu: aMenu.
	^ aMenu
]

{ #category : #servicecategory }
ServiceGui >> pushMenu [
	menu addLast: MenuMorph new.
	n addLast: 0
]

{ #category : #styling }
ServiceGui >> styleBar: aBar [
	aBar setNameTo: 'button bar'.
	aBar beSticky;
		hResizing: #spaceFill;
		wrapCentering: #center;
		cellPositioning: #leftCenter;
		clipSubmorphs: true;
		color: Color veryVeryLightGray.
]

{ #category : #styling }
ServiceGui >> styleButton: aButton [ 
	aButton color: Color transparent;
	onColor: Color transparent offColor: Color transparent;
	
	borderStyle: (BorderStyle width: 1 color: Color gray);
	askBeforeChanging: true;
	clipSubmorphs: true;
	hResizing: #spaceFill;
	vResizing: #spaceFill.
	^ self
]

{ #category : #styling }
ServiceGui >> styleMenu: aMenu [ 
	"gradient, etc ..?"
	"aMenu color: Color white;
		
		borderStyle: (BorderStyle width: 1 color: Color gray);
		 clipSubmorphs: true;
		 addDropShadow;
		
		shadowColor: (TranslucentColor
				r: 0.0
				g: 0.0
				b: 0.0
				alpha: 0.666);
		 shadowOffset: 1 @ 1"
]

{ #category : #servicecategory }
ServiceGui >> subMenuFor: aServiceCategory [ 
	self pushMenu.
	aServiceCategory enabledServices
		ifEmpty: [self menuItemFor: ServiceAction new].
	aServiceCategory enabledServices
		doWithIndex: [:each :i | self n: i. self menuItemFor: each].
	^ self popMenu
]
