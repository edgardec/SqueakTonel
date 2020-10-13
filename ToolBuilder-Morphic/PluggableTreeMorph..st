"
A pluggable tree morph.
"
Class {
	#name : #PluggableTreeMorph,
	#superclass : #SimpleHierarchicalListMorph,
	#instVars : [
		'rootWrappers',
		'selectedWrapper',
		'getRootsSelector',
		'getChildrenSelector',
		'hasChildrenSelector',
		'getLabelSelector',
		'getIconSelector',
		'getSelectedPathSelector',
		'setSelectedPathSelector',
		'setSelectedParentSelector',
		'getHelpSelector',
		'dropItemSelector',
		'wantsDropSelector',
		'dragItemSelector',
		'dragTypeSelector',
		'nodeClass',
		'lastKeystrokeTime',
		'lastKeystrokes',
		'dragStartedSelector',
		'doubleClickSelector'
	],
	#classVars : [
		'FilterByLabelsOnly',
		'MaximumSearchDepth'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #preferences }
PluggableTreeMorph class >> filterByLabelsOnly [
	<preference: 'Filterable Trees by labels only'
		category: 'scrolling'
		description: 'When using the Filterable Lists option, set this to only match the labels, not the contents, of hierarchical lists.  Otherwise, search both labels and contents will be matched.'
		type: #Boolean>
	^ FilterByLabelsOnly ifNil: [ false ]
]

{ #category : #preferences }
PluggableTreeMorph class >> filterByLabelsOnly: aBoolean [
	FilterByLabelsOnly := aBoolean
]

{ #category : #preferences }
PluggableTreeMorph class >> maximumSearchDepth [
	<preference: 'Maximum tree search depth'
		category: 'scrolling'
		description: 'When using the Filterable Lists option, this specifies the maximum depth that will be searched below the current selection in of the hierarchy.'
		type: #Number>
	^ MaximumSearchDepth ifNil: [ 1 ]
]

{ #category : #preferences }
PluggableTreeMorph class >> maximumSearchDepth: anInteger [
	MaximumSearchDepth := anInteger.
]

{ #category : #'drag and drop' }
PluggableTreeMorph >> acceptDroppingMorph: aTransferMorph event: evt [ 

	dropItemSelector ifNil: [^ self].
	potentialDropMorph ifNil: [^ self].
	
	model
		perform: dropItemSelector
		withEnoughArguments: {
			aTransferMorph passenger. 
			potentialDropMorph withoutListWrapper. 
			aTransferMorph shouldCopy.
			aTransferMorph}.

	self resetPotentialDropMorph.
	evt hand releaseMouseFocus: self.
	Cursor normal show
]

{ #category : #'node access' }
PluggableTreeMorph >> balloonTextForNode: node [
	getHelpSelector ifNil:[^nil].
	^model perform: getHelpSelector with: node item
]

{ #category : #'event handling' }
PluggableTreeMorph >> basicKeyPressed: aChar [

	self updateLastKeystrokes: aChar.
	
	model okToChange ifFalse: [^ false].
	
	PluggableListMorph filterableLists
		ifTrue: [self triggerFilterTree]
		ifFalse: [self selectNextMorphByFilter].
	
	^ true
]

{ #category : #geometry }
PluggableTreeMorph >> bottomVisibleRowIndex [
	| itemAtBottom |
	itemAtBottom := self itemFromPoint: self bottomLeft + (3 @ -3).
	^ itemAtBottom
		ifNil: [ scroller submorphs size ]
		ifNotNil:
			[ : item | scroller submorphs indexOf: item ]
]

{ #category : #geometry }
PluggableTreeMorph >> charactersOccluded [
	^ self visibleItems
		inject: 0
		into:
			[ : sum : each | sum + each charactersOccluded ]
]

{ #category : #'node access' }
PluggableTreeMorph >> contentsOfNode: node [

	| children |
	getChildrenSelector ifNil: [^#()].
	children := model perform: getChildrenSelector with: node item.
	^ self nodesForChildren: children inNode: node

]

{ #category : #'event handling' }
PluggableTreeMorph >> doubleClick: evt [

	| aMorph |
	aMorph := self itemFromPoint: evt position.
	self model perform: self doubleClickSelector with: aMorph withoutListWrapper

]

{ #category : #accessing }
PluggableTreeMorph >> doubleClickEnabled [

	^ self doubleClickSelector notNil
]

{ #category : #accessing }
PluggableTreeMorph >> doubleClickSelector [

	^ doubleClickSelector
]

{ #category : #accessing }
PluggableTreeMorph >> doubleClickSelector: anObject [

	doubleClickSelector := anObject
]

{ #category : #accessing }
PluggableTreeMorph >> dragItemSelector [
	^dragItemSelector
]

{ #category : #accessing }
PluggableTreeMorph >> dragItemSelector: aSymbol [
	dragItemSelector := aSymbol.
	aSymbol ifNotNil:[self dragEnabled: true].
]

{ #category : #accessing }
PluggableTreeMorph >> dragStartedSelector [
	^ dragStartedSelector
]

{ #category : #accessing }
PluggableTreeMorph >> dragStartedSelector: aSymbol [
	dragStartedSelector := aSymbol.
]

{ #category : #accessing }
PluggableTreeMorph >> dragTypeSelector [
	^dragTypeSelector
]

{ #category : #accessing }
PluggableTreeMorph >> dragTypeSelector: aSymbol [
	dragTypeSelector := aSymbol.
]

{ #category : #accessing }
PluggableTreeMorph >> dropItemSelector [
	^dropItemSelector
]

{ #category : #accessing }
PluggableTreeMorph >> dropItemSelector: aSymbol [
	dropItemSelector := aSymbol.
	aSymbol ifNotNil:[self dropEnabled: true].
]

{ #category : #'node access' }
PluggableTreeMorph >> dropNode: srcNode on: dstNode [
	dropItemSelector ifNil:[^nil].
	model perform: dropItemSelector with: srcNode item with: dstNode item
]

{ #category : #filtering }
PluggableTreeMorph >> filterTree [
	self hasFilter ifFalse:
		[ self removeFilter.
		^ self ].
	self indicateFiltered.
	"Clean up the tree."
	(self selectedMorph
		ifNil: [ self roots ]
		ifNotNil:
			[ : m | {m} ]) do:
		[ : item | | filteredItems |
		item applyFilter: lastKeystrokes.
		item visible ifFalse:
			[ "Do not hide the item where the filter is based on."
			item show.
			item isExpanded ifFalse: [ item toggleExpandedState ] ].
		filteredItems := self filteredItems.
		"If configured as a navigation tool, advance the selection."
		(PluggableTreeMorph maximumSearchDepth = 1 and: [ PluggableTreeMorph filterByLabelsOnly not ]) ifTrue:
			[ |toBeExpanded|
			(filteredItems notEmpty and: [ selectedMorph ~= filteredItems last ]) ifTrue:
				[ self setSelectedMorph:
					(toBeExpanded := selectedMorph
						ifNil: [ filteredItems first ]
						ifNotNil: [ filteredItems after: selectedMorph ]).
				toBeExpanded isExpanded ifFalse: [ toBeExpanded toggleExpandedState ] ] ] ].
	self adjustSubmorphPositions
]

{ #category : #filtering }
PluggableTreeMorph >> filteredItems [
	"Answer the items which visible because they matched the current filters."
	^ self items select: [ : each | each visible ]
]

{ #category : #accessing }
PluggableTreeMorph >> getChildrenSelector [
	^getChildrenSelector
]

{ #category : #accessing }
PluggableTreeMorph >> getChildrenSelector: aSymbol [
	getChildrenSelector := aSymbol.
]

{ #category : #selection }
PluggableTreeMorph >> getCurrentSelectionItem [
	"Our models are supposed to return real objects, not wrappers. See PluggableTreeItemNode."
	
	| selectedObject |
	selectedObject := self getSelectedSelector
		ifNil: [^ nil]
		ifNotNil: [:symbol | model perform: symbol].
	^ scroller submorphs
		detect: [:each | each complexContents item == selectedObject]
		ifFound: [:each | each complexContents]
		ifNone: [nil]
]

{ #category : #accessing }
PluggableTreeMorph >> getHelpSelector [
	^getHelpSelector
]

{ #category : #accessing }
PluggableTreeMorph >> getHelpSelector: aSymbol [
	getHelpSelector := aSymbol
]

{ #category : #accessing }
PluggableTreeMorph >> getIconSelector [
	^getIconSelector
]

{ #category : #accessing }
PluggableTreeMorph >> getIconSelector: aSymbol [
	getIconSelector := aSymbol
]

{ #category : #accessing }
PluggableTreeMorph >> getLabelSelector [
	^getLabelSelector
]

{ #category : #accessing }
PluggableTreeMorph >> getLabelSelector: aSymbol [
	getLabelSelector := aSymbol
]

{ #category : #accessing }
PluggableTreeMorph >> getMenuSelector [
	^getMenuSelector
]

{ #category : #accessing }
PluggableTreeMorph >> getMenuSelector: aSymbol [
	getMenuSelector := aSymbol
]

{ #category : #accessing }
PluggableTreeMorph >> getRootsSelector [
	^getRootsSelector
]

{ #category : #accessing }
PluggableTreeMorph >> getRootsSelector: aSelector [
	getRootsSelector := aSelector.
	self update: getRootsSelector.
]

{ #category : #selection }
PluggableTreeMorph >> getSelectedPath [
	
	^ self getSelectedPathSelector ifNotNil: [:sel | model perform: sel]
]

{ #category : #accessing }
PluggableTreeMorph >> getSelectedPathSelector [
	^getSelectedPathSelector
]

{ #category : #accessing }
PluggableTreeMorph >> getSelectedPathSelector: aSymbol [
	getSelectedPathSelector := aSymbol.
	self update: getSelectedPathSelector.
]

{ #category : #accessing }
PluggableTreeMorph >> getSelectedSelector [
	^getSelectionSelector
]

{ #category : #accessing }
PluggableTreeMorph >> getSelectedSelector: aSymbol [
	getSelectionSelector := aSymbol.
	self update: getSelectionSelector.
]

{ #category : #accessing }
PluggableTreeMorph >> hasChildrenSelector [
	^hasChildrenSelector
]

{ #category : #accessing }
PluggableTreeMorph >> hasChildrenSelector: aSymbol [
	hasChildrenSelector := aSymbol
]

{ #category : #filtering }
PluggableTreeMorph >> hasFilter [
	^ lastKeystrokes isEmptyOrNil not
]

{ #category : #'node access' }
PluggableTreeMorph >> hasNodeContents: node [
	hasChildrenSelector ifNil:[^node contents isEmpty not].
	^model perform: hasChildrenSelector with: node item
]

{ #category : #'node access' }
PluggableTreeMorph >> iconOfNode: node [
	getIconSelector ifNil:[^nil].
	^model perform: getIconSelector with: node item
]

{ #category : #filtering }
PluggableTreeMorph >> indicateFiltered [
	"self color: (Color gray: 0.95)."
]

{ #category : #filtering }
PluggableTreeMorph >> indicateUnfiltered [
	self color: (self userInterfaceTheme color ifNil: [Color white]).
	scroller submorphsDo: [:m |
		m visible: true; backgroundColor: nil].
	self adjustSubmorphPositions.
]

{ #category : #initialization }
PluggableTreeMorph >> initialize [

	super initialize.
	
	"Filter"
	lastKeystrokeTime := 0.
	lastKeystrokes := ''
]

{ #category : #'node access' }
PluggableTreeMorph >> instantiateNodeWithContents: item index: aNumber parent: anObject [

	^ (self nodeClass with: item model: self)
		index: aNumber;
		parent: anObject
]

{ #category : #'node access' }
PluggableTreeMorph >> isDraggableNode: node [
	^true
]

{ #category : #accessing }
PluggableTreeMorph >> items [
	^ scroller submorphs
]

{ #category : #'event handling' }
PluggableTreeMorph >> keyStroke: event [

	^ (super keyStroke: event)
		ifTrue: [true]
		ifFalse: [self basicKeyPressed: event keyCharacter].
]

{ #category : #'event handling' }
PluggableTreeMorph >> keyboardFocusChange: aBoolean [ 
	aBoolean ifFalse:
		[ PluggableListMorph clearFilterAutomatically ifTrue:
			[ self hasFilter ifTrue: [ self removeFilter ] ] ].
	super keyboardFocusChange: aBoolean.
]

{ #category : #accessing }
PluggableTreeMorph >> keystrokeActionSelector [
	^keystrokeActionSelector
]

{ #category : #accessing }
PluggableTreeMorph >> keystrokeActionSelector: aSymbol [
	keystrokeActionSelector := aSymbol
]

{ #category : #'event handling' }
PluggableTreeMorph >> mouseDown: evt [
	| aMorph selectors |
	
	aMorph := self itemFromPoint: evt position.
	evt yellowButtonPressed  "First check for option (menu) click"
		ifTrue: [
			(PluggableListMorph menuRequestUpdatesSelection and: [model okToChange]) ifTrue: [
				aMorph == selectedMorph 
					ifFalse: [self setSelectedMorph: aMorph]].
			^ self yellowButtonActivity: evt shiftPressed].
	(aMorph notNil and:[aMorph inToggleArea: (aMorph point: evt position from: self)])
		ifTrue:[^self toggleExpandedState: aMorph event: evt]. 
	aMorph ifNil:[^super mouseDown: evt].
	
	aMorph highlightForMouseDown.
	self setProperty: #highlightedMorph toValue: aMorph.
	
	selectors := Array 
		with: #click:
		with: (self doubleClickEnabled ifTrue: [#doubleClick:] ifFalse: [nil])
		with: nil
		with: (self dragEnabled ifTrue:[#startDrag:] ifFalse:[nil]).
	evt hand waitForClicksOrDrag: self event: evt selectors: selectors threshold: HandMorph dragThreshold "pixels".
]

{ #category : #accessing }
PluggableTreeMorph >> nodeClass [
	^ nodeClass ifNil: [PluggableTreeItemNode]
]

{ #category : #accessing }
PluggableTreeMorph >> nodeClass: aListWrapperClass [
	nodeClass := aListWrapperClass.
]

{ #category : #'node access' }
PluggableTreeMorph >> nodesForChildren: aCollection inNode: anObject [

	^ aCollection isSequenceable
		ifTrue: [aCollection collectWithIndex: 
			[:item :index |
				self instantiateNodeWithContents: item index: index parent: anObject]]
		ifFalse: [ | count |
			count := 0. "artificial index."
			aCollection collect: 
				[:item |
					count := count + 1.
					self instantiateNodeWithContents: item index: count parent: anObject]]
]

{ #category : #'node access' }
PluggableTreeMorph >> printNode: node [
	getLabelSelector ifNil:[^node item printString].
	^model perform: getLabelSelector with: node item
]

{ #category : #filtering }
PluggableTreeMorph >> removeFilter [
	lastKeystrokes := String empty.
	self indicateUnfiltered.
]

{ #category : #filtering }
PluggableTreeMorph >> selectNextMorphByFilter [
]

{ #category : #selection }
PluggableTreeMorph >> selectPath: path [

	self
		selectPath: path
		in: (scroller submorphs at: 1 ifAbsent: [^self]).
]

{ #category : #selection }
PluggableTreeMorph >> selectPath: path in: listItem [
	path ifNil: [^self].
	path isEmpty ifTrue: [^self setSelectedMorph: nil].
	listItem withSiblingsDo: [:each | 
		(each complexContents item = path first) ifTrue: [
			each isExpanded ifFalse: [
				each toggleExpandedState.
				self adjustSubmorphPositions.
			].
			each changed.
			path size = 1 ifTrue: [
				^self setSelectedMorph: each
			].
			each firstChild ifNil: [^self setSelectedMorph: nil].
			^self selectPath: path allButFirst in: each firstChild
		].
	].
	^self setSelectedMorph: nil


]

{ #category : #selection }
PluggableTreeMorph >> selectedMorph: aMorph [

	super selectedMorph: aMorph.
		
	"If the update came from the model, make my state consistent again."
	selectedWrapper := aMorph complexContents.
	self setSelectedParentMorph: aMorph.
]

{ #category : #selection }
PluggableTreeMorph >> setSelectedMorph: aMorph [
	
	selectedWrapper := aMorph complexContents.
	
	"Let the model now about the selected object, not wrapper."
	setSelectionSelector ifNotNil: [:symbol |
		model 
			perform: symbol 
			with: (selectedWrapper ifNotNil: [:w | w item])].
		
	self setSelectedParentMorph: aMorph.
	self setSelectedPath: aMorph.
]

{ #category : #selection }
PluggableTreeMorph >> setSelectedParentMorph: aMorph [

	"The model may not have access to the parent object in terms of this tree structure."
	setSelectedParentSelector ifNotNil: [:symbol |
		model
			perform: symbol
			with: (selectedWrapper ifNotNil: [:w | w parent ifNotNil: [:pw | pw item]])].
]

{ #category : #accessing }
PluggableTreeMorph >> setSelectedParentSelector [
	^ setSelectedParentSelector
]

{ #category : #accessing }
PluggableTreeMorph >> setSelectedParentSelector: aSymbol [
	setSelectedParentSelector := aSymbol.
]

{ #category : #selection }
PluggableTreeMorph >> setSelectedPath: aMorph [

	| items wrapperPath |
	setSelectedPathSelector ifNotNil: [:setSelectedPathSelector |
		wrapperPath := selectedWrapper 
			ifNil: [#()]
			ifNotNil: [
				wrapperPath := {selectedWrapper} asOrderedCollection.
				[wrapperPath last parent notNil] 
					whileTrue: [wrapperPath addLast: wrapperPath last parent].
				wrapperPath].
		items := wrapperPath collect: [:w | w item].
		model
			perform: setSelectedPathSelector
			with: items].
			

]

{ #category : #accessing }
PluggableTreeMorph >> setSelectedPathSelector [
	^ setSelectedPathSelector

]

{ #category : #accessing }
PluggableTreeMorph >> setSelectedPathSelector: aSymbol [
	setSelectedPathSelector := aSymbol.

]

{ #category : #accessing }
PluggableTreeMorph >> setSelectedSelector [
	^setSelectionSelector
]

{ #category : #accessing }
PluggableTreeMorph >> setSelectedSelector: aSymbol [
	setSelectionSelector := aSymbol
]

{ #category : #'event handling' }
PluggableTreeMorph >> specialKeyPressed: asciiValue [

	(super specialKeyPressed: asciiValue)
		ifTrue: [^ true].
		
	(#(8 13) includes: asciiValue) ifTrue: [
		"backspace key" 
		self removeFilter.
		^ true].

	^ false
]

{ #category : #'drag and drop' }
PluggableTreeMorph >> startDrag: evt [ 
	
	| itemMorph |
	self dragItemSelector ifNil: [^ self].
	evt hand hasSubmorphs ifTrue: [^ self].
	self model okToChange ifFalse: [^ self].
	
	itemMorph := scroller submorphs
		detect: [:any | any highlightedForMouseDown]
		ifNone: [^ self].

	"Prepare visuals."
	itemMorph highlightForMouseDown: false.
	self setSelectedMorph: itemMorph.

	[ "Initiate drag."
		(self model perform: self dragItemSelector with: itemMorph withoutListWrapper) ifNotNil: [:passenger | | ddm |
			ddm := (self valueOfProperty: #dragTransferClass ifAbsent: [TransferMorph]) withPassenger: passenger from: self.
			ddm dragTransferType: (self dragTypeSelector ifNotNil: [:s | self model perform: s with: itemMorph withoutListWrapper]).
			ddm updateFromUserInputEvent: evt.
			self dragStartedSelector ifNotNil: [:s | self model perform: s with: itemMorph with: ddm].
			evt hand grabMorph: ddm].
	] ensure: [
		Cursor normal show.
		evt hand releaseMouseFocus: self].
]

{ #category : #geometry }
PluggableTreeMorph >> topVisibleRowIndex [
	^ scroller submorphs indexOf: (self itemFromPoint: self topLeft+(3@3))
]

{ #category : #filtering }
PluggableTreeMorph >> triggerFilterTree [

	self removeAlarm: #filterTree.
	self addAlarm: #filterTree after: 300.
]

{ #category : #updating }
PluggableTreeMorph >> update: what [
	what ifNil:[^self].
	what == getRootsSelector ifTrue:[
		self wrapRoots: (model perform: getRootsSelector).
		^ self].
	
	what == getSelectedPathSelector ifTrue:[
		self selectPath: self getSelectedPath.
		^ self].
		
	what == #expandRootsRequested ifTrue: [
		self expandRoots.
		^ self].
	
	super update: what.

]

{ #category : #updating }
PluggableTreeMorph >> update: what with: anObject [

	super update: what with: anObject.
	
	what == #objectChanged ifTrue: [
		self updateFromChangedObject: anObject].
]

{ #category : #updating }
PluggableTreeMorph >> updateFromChangedObject: anObject [

	scroller submorphs
		detect: [:morph | morph complexContents item == anObject]
		ifFound: [:morph | self updateMorph: morph]
		ifNone: ["Ignore the request. Object may not be visible anyway."].
]

{ #category : #'event handling' }
PluggableTreeMorph >> updateLastKeystrokes: aChar [

	| milliseconds slowKeyStroke |
	milliseconds := Time millisecondClockValue.
	slowKeyStroke := (Time milliseconds: milliseconds since: lastKeystrokeTime)
		> (PluggableListMorph filterableLists ifTrue: [ 500 ] ifFalse: [ 300 ]).
	lastKeystrokeTime := milliseconds.
	
	slowKeyStroke
		ifTrue: [lastKeystrokes := aChar asLowercase asString]
		ifFalse: [lastKeystrokes := lastKeystrokes , aChar asLowercase asString.].
]

{ #category : #updating }
PluggableTreeMorph >> updateMorph: morph [

	morph complexContents refresh.
	morph refresh.
	
	morph isExpanded
		ifFalse: [self changed]
		ifTrue: [
			morph
				toggleExpandedState;
				toggleExpandedState.
			self adjustSubmorphPositions].

]

{ #category : #'node access' }
PluggableTreeMorph >> updateNode: node [

]

{ #category : #geometry }
PluggableTreeMorph >> visibleItems [
	^ self items ifNotEmpty:
		[ : items | items
			copyFrom: self topVisibleRowIndex
			to: self bottomVisibleRowIndex ]
]

{ #category : #accessing }
PluggableTreeMorph >> wantsDropSelector [
	^wantsDropSelector
]

{ #category : #accessing }
PluggableTreeMorph >> wantsDropSelector: aSymbol [
	wantsDropSelector := aSymbol
]

{ #category : #'drag and drop' }
PluggableTreeMorph >> wantsDroppedMorph: aTransferMorph event: anEvent [

	dropItemSelector ifNil: [^ false].
	wantsDropSelector ifNil: [^ true].

	(aTransferMorph isKindOf: TransferMorph) ifFalse: [^ false].

	^ model perform: wantsDropSelector withEnoughArguments: {
		aTransferMorph passenger.
		aTransferMorph dragTransferType.
		aTransferMorph source.
		aTransferMorph}
]

{ #category : #'node access' }
PluggableTreeMorph >> wantsDroppedNode: srcNode on: dstNode [
	dropItemSelector ifNil:[^false].
	wantsDropSelector ifNil:[^true].
	^(model perform: wantsDropSelector with: srcNode with: dstNode) == true
]

{ #category : #updating }
PluggableTreeMorph >> wrapRoots: someObjects [

	rootWrappers := someObjects collect: [:item|
		self nodeClass with: item model: self].
	self list: rootWrappers.
]
