"
This morph manages a set of PluggableTabButtonMorphs.  Each tab should be added in the left to right order that they should be displayed.  Each tab will be evenly sized to fit the available space.  This morph intercepts mouse clicks, figures out which tab was clicked, pops up the new tab as the active tab and triggers the registered event.  See PluggableTabButtonMorph for information on what a tab can consist of.

Example:

(PluggableTabBarMorph on: nil)
	addTab: (Text fromString: 'Test') withAction: [Transcript show: 'Test'; cr];
	addTab: (Text fromString: 'Another') withAction: [Transcript show: 'Another'; cr];
	width: 200;
	openInHand

"
Class {
	#name : #PluggableTabBarMorph,
	#superclass : #Morph,
	#instVars : [
		'target',
		'tabs',
		'activeTab'
	],
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #'instance creation' }
PluggableTabBarMorph class >> on: anObject [
	^ super new target: anObject
]

{ #category : #'private - access' }
PluggableTabBarMorph >> activeTab [
	activeTab ifNil: [
		self tabs size > 0 ifTrue: [
			activeTab := self tabs first key.
			activeTab active: true]].
	^ activeTab 
]

{ #category : #'private - access' }
PluggableTabBarMorph >> activeTab: aTabMorph [
	self activeTab ifNotNil: [self activeTab toggle].
	activeTab := aTabMorph.
	self activeTab toggle.
	aTabMorph delete.
	self addMorphFront: aTabMorph.
	self performActiveTabAction.
	self changed.

]

{ #category : #access }
PluggableTabBarMorph >> addTab: aStringOrTextOrMorph withAction: aSymbolOrBlock [
	"Add a new tab.  The tab will be added onto the end of the list and displayed on the far right of previously added tabs.  The first argument can be a simple String, a Text, or any Morph.  The second argument is the action to be performed when the tab is selected. It can either be a symbol for a unary method on the target object or a block.  Each tab is stored as an Association with the created tab as the key and the selector as the value."
	| tabMorph |
	tabMorph := PluggableTabButtonMorph on: nil label: [ aStringOrTextOrMorph].
	tabMorph color: self color.
	self addMorphBack: tabMorph.
	self tabs ifEmpty: [ self activeTab: tabMorph ].
	self tabs add: (Association key: tabMorph value: aSymbolOrBlock).
	self layoutChanged.
	self changed.
]

{ #category : #access }
PluggableTabBarMorph >> color: aFillStyle [
	color := aFillStyle.
	self tabs do: [ :anAssociation |
		anAssociation key color: aFillStyle ]

]

{ #category : #drawing }
PluggableTabBarMorph >> drawOn: aCanvas [
	self tabs size > 0 ifFalse: [^ self ].
	self tabs do: [ :anAssociation | | tab |
		tab := anAssociation key.
		tab drawOn: aCanvas]
]

{ #category : #actions }
PluggableTabBarMorph >> handlesMouseDown: anEvent [
	^ true
]

{ #category : #actions }
PluggableTabBarMorph >> layoutChanged [
	"Fix up our tabs bounds"
	| tabsCount |
	super layoutChanged.
	tabsCount := self tabs size.
	tabsCount isZero ifFalse: [ | tabInnerExtent count |
		tabInnerExtent := ((self width -
				((self tabs first key outerGap + self tabs last key outerGap) // 2)
					- tabsCount)
			 		// tabsCount)
			@ (self height).
		count := 1.
		self tabs do: [ :anAssociation | | tab |
			tab := anAssociation key.
			tab innerExtent: tabInnerExtent.
			count = 1
				ifTrue: [tab position: self position]
				ifFalse: [
					tab position:
						(self position translateBy:
							((tabInnerExtent x + 1) * (count - 1))@0)].
			count := count + 1  ]	].
	self changed.
]

{ #category : #actions }
PluggableTabBarMorph >> mouseDown: anEvent [
	| xPosition newTab |
	xPosition := anEvent cursorPoint x.
	newTab :=
		(self tabs detect: [ :anAssociation | | tabBounds |
				tabBounds := anAssociation key bounds.
				(tabBounds left <= xPosition) and: [ tabBounds right >= xPosition]]
			ifNone: [^self])
		key.
	newTab ifNil: [^ self].
	newTab = activeTab ifFalse: [ self activeTab: newTab ]
]

{ #category : #actions }
PluggableTabBarMorph >> performActiveTabAction [
	"Look up the Symbol or Block associated with the currently active tab, and perform it."
	
	| tabActionAssoc aSymbolOrBlock |
	
	tabActionAssoc := self tabs detect: [ :assoc | assoc key = self activeTab.] ifNone: [ Association new ].
	aSymbolOrBlock := tabActionAssoc value.
	aSymbolOrBlock ifNil: [ ^ false ].
	^ aSymbolOrBlock isSymbol
		ifTrue: [ self target perform: aSymbolOrBlock ]
		ifFalse: [ aSymbolOrBlock value ].
	
]

{ #category : #'private - access' }
PluggableTabBarMorph >> tabs [
	tabs ifNil: [ tabs := OrderedCollection new ].
	^ tabs
]

{ #category : #'private - access' }
PluggableTabBarMorph >> target [
	^ target
]

{ #category : #access }
PluggableTabBarMorph >> target: anObject [
	target := anObject
]
