"
The Morphic tool builder.
"
Class {
	#name : #MorphicToolBuilder,
	#superclass : #ToolBuilder,
	#instVars : [
		'widgets',
		'panes',
		'parentMenu'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #services }
MorphicToolBuilder class >> getBoundsForWindow: morph [

	^ morph bounds
]

{ #category : #accessing }
MorphicToolBuilder class >> isActiveBuilder [
	"Answer whether I am the currently active builder"
	^Smalltalk isMorphic
]

{ #category : #services }
MorphicToolBuilder class >> setBoundsForWindow: morph to: rectangle [

	^ morph bounds: rectangle
]

{ #category : #private }
MorphicToolBuilder >> add: aMorph to: aParent [
	
	aMorph layoutFrame
		ifNotNil: [aParent addMorph: aMorph fullFrame: aMorph layoutFrame]
		ifNil: [aParent addMorphBack: aMorph].
]

{ #category : #'widget classes' }
MorphicToolBuilder >> alternateMultiSelectListClass [
	^ AlternatePluggableListMorphOfMany 
]

{ #category : #private }
MorphicToolBuilder >> asFrame: aRectangle [
	| frame |
	aRectangle ifNil:[^nil].
	frame := LayoutFrame new.
	frame 
		leftFraction: aRectangle left; 
		rightFraction: aRectangle right; 
		topFraction: aRectangle top; 
		bottomFraction: aRectangle bottom.
	^frame
]

{ #category : #private }
MorphicToolBuilder >> buildHelpFor: widget spec: aSpec [
	aSpec help ifNotNil: [:stringOrSymbol |
		stringOrSymbol isSymbol
			ifTrue: [widget balloonTextSelector: stringOrSymbol]
			ifFalse: [widget balloonText: stringOrSymbol]].
]

{ #category : #'widgets optional' }
MorphicToolBuilder >> buildPluggableAlternateMultiSelectionList: aSpec [
	| listMorph listClass |
	aSpec getSelected ifNotNil: [ ^ self error: 'There is no PluggableAlternateListMorphOfManyByItem' ].
	listClass := self alternateMultiSelectListClass.
	listMorph := listClass 
		on: aSpec model
		list: aSpec list
		primarySelection: aSpec getIndex
		changePrimarySelection: aSpec setIndex
		listSelection: aSpec getSelectionList
		changeListSelection: aSpec setSelectionList
		menu: aSpec menu.
	listMorph
		setProperty: #highlightSelector toValue: #highlightMessageList:with: ;
		enableDragNDrop: SystemBrowser browseWithDragNDrop ;
		menuTitleSelector: #messageListSelectorTitle.
	self 
		register: listMorph
		id: aSpec name.
	listMorph
		keystrokeActionSelector: aSpec keyPress ;
		getListElementSelector: aSpec listItem ;
		getListSizeSelector: aSpec listSize;
		getIconSelector: aSpec icon;
		getHelpSelector: aSpec helpItem.
		
	self buildHelpFor: listMorph spec: aSpec.
		
	self 
		setFrame: aSpec frame 
		in: listMorph.
	self setLayoutHintsFor: listMorph spec: aSpec.
	parent ifNotNil: [ self add: listMorph to: parent ].
	panes ifNotNil: [ aSpec list ifNotNil:[panes add: aSpec list ] ].
	^ listMorph
]

{ #category : #'widgets required' }
MorphicToolBuilder >> buildPluggableButton: aSpec [
	| widget label state action enabled |
	label := aSpec label.
	state := aSpec state.
	action := aSpec action.
	widget := self buttonClass on: aSpec model
				getState: (state isSymbol ifTrue:[state])
				action: nil
				label: (label isSymbol ifTrue:[label]).
	widget style: aSpec style.
	aSpec changeLabelWhen
		ifNotNil: [ :event | widget whenChanged: event update: aSpec label].
	self register: widget id: aSpec name.
	enabled := aSpec enabled.
	enabled isSymbol
		ifTrue:[widget getEnabledSelector: enabled]
		ifFalse:[widget enabled:enabled].
	widget action: action.
	aSpec color isColor
		ifTrue: [widget offColor: aSpec color]
		ifFalse: [widget getColorSelector: aSpec color].
	self buildHelpFor: widget spec: aSpec. 
	(label isSymbol or:[label == nil]) ifFalse:[widget label: label].
	self setFrame: aSpec frame in: widget.
	self setLayoutHintsFor: widget spec: aSpec.
	parent ifNotNil:[self add: widget to: parent].
	^widget
]

{ #category : #'widgets optional' }
MorphicToolBuilder >> buildPluggableCheckBox: spec [

	| widget label state action |
	label := spec label.
	state := spec state.
	action := spec action.
	widget := self checkBoxClass on: spec model
				getState: (state isSymbol ifTrue:[state])
				action: (action isSymbol ifTrue:[action])
				label: (label isSymbol ifTrue:[label]).
	self register: widget id: spec name.

	widget installButton.
	spec color ifNotNil: [:c | widget color: c].
	self setFrame: spec frame in: widget.
	self setLayoutHintsFor: widget spec: spec.
	parent ifNotNil: [:p | self add: widget to: p].
	^widget
]

{ #category : #'widgets optional' }
MorphicToolBuilder >> buildPluggableCodePane: aSpec [

	| widget |
	widget := super buildPluggableCodePane: aSpec.
	
	"Override code-specific default properties."
	widget wantsWrapBorder: PluggableTextMorph visualWrapBorder.
	widget wrapFlag: (aSpec softLineWrap ifNil: [PluggableTextMorph softLineWrap]).
	^ widget
]

{ #category : #'widgets optional' }
MorphicToolBuilder >> buildPluggableDialog: aSpec [

	| widget |

	widget := self dialogClass new.
	self register: widget id: aSpec name.
	
	widget model: aSpec model.

	"Set child dependent layout properties. The pane morph holds the special contents."
	widget paneMorph wantsPaneSplitters: (aSpec wantsResizeHandles ifNil: [true]).
	self setLayoutHintsFor: widget paneMorph spec: aSpec.
	widget paneMorph layoutInset: (aSpec padding ifNil: [ProportionalSplitterMorph gripThickness]).
	widget paneMorph cellGap: (aSpec spacing ifNil: [ProportionalSplitterMorph gripThickness]).
	widget paneMorph wantsPaneSplitters ifTrue: [
		widget paneMorph addCornerGrips"addEdgeGrips".
		widget paneMorph grips do: [:ea | ea showHandle: true]].

	"Now create the children."
	panes := OrderedCollection new.
	aSpec children isSymbol
		ifTrue: [
			widget getChildrenSelector: aSpec children.
			widget update: aSpec children]
		ifFalse: [
			self buildAll: aSpec children in: widget paneMorph].

	"Now create the buttons."
	aSpec buttons isSymbol
		ifTrue: [
			widget getButtonsSelector: aSpec buttons.
			widget update: aSpec buttons]
		ifFalse: [
			self buildAll: aSpec buttons in: widget buttonRowMorph.
			widget updateButtonProperties].

	aSpec title ifNotNil: [:label |
		label isSymbol 
			ifTrue:[widget getTitleSelector: label; update: label]
			ifFalse:[widget title: label]].
	aSpec message ifNotNil: [:label |
		label isSymbol 
			ifTrue:[widget getMessageSelector: label; update: label]
			ifFalse:[widget message: label]].
	
	"Interaction behavior."
	aSpec autoCancel ifNotNil: [:b | widget autoCancel: b].
	aSpec exclusive ifNotNil: [:b | widget exclusive: b].
		
	widget closeDialogSelector: aSpec closeAction.
	self buildHelpFor: widget spec: aSpec. 

	"Everything is shrink-wrapped around the pane morph."
	widget paneMorph extent: (aSpec extent ifNil:[widget initialExtent]).

	^ widget
]

{ #category : #'widgets optional' }
MorphicToolBuilder >> buildPluggableDropDownList: spec [

	| widget model listSelector selectionSelector selectionSetter |
	model := spec model.
	listSelector := spec listSelector.
	selectionSelector := spec selectionSelector.
	selectionSetter := spec selectionSetter.
	widget := self dropDownListClass new
		model: model;
		listSelector: listSelector;
		selectionSelector: selectionSelector;
		selectionSetter: selectionSetter;
		yourself.
	self register: widget id: spec name.

	widget installDropDownList.
	self setFrame: spec frame in: widget.
	self setLayoutHintsFor: widget spec: spec.
	parent ifNotNil:[self add: widget to: parent].
	^widget
]

{ #category : #'widgets optional' }
MorphicToolBuilder >> buildPluggableInputField: aSpec [
	| widget |
	widget := self buildPluggableText: aSpec.
	widget minimumHeight: 0.
	widget acceptOnCR: true.
	widget hideScrollBarsIndefinitely.
	^widget
]

{ #category : #'widgets required' }
MorphicToolBuilder >> buildPluggableList: aSpec [
	| widget listClass getIndex setIndex |
	aSpec getSelected ifNil:[
		listClass := self listClass.
		getIndex := aSpec getIndex.
		setIndex := aSpec setIndex.
	] ifNotNil:[
		listClass := self listByItemClass.
		getIndex := aSpec getSelected.
		setIndex := aSpec setSelected.
	].
	widget := listClass on: aSpec model
				list: aSpec list
				selected: getIndex
				changeSelected: setIndex
				menu: aSpec menu
				keystroke: aSpec keyPress.
	self register: widget id: aSpec name.
	
	widget
		dragItemSelector: aSpec dragItem;
		dropItemSelector: aSpec dropItem;
		wantsDropSelector: aSpec dropAccept;
		dragStartedSelector: aSpec dragStarted.

	self setListPropertiesFor: widget spec: aSpec.
	^widget
]

{ #category : #'widgets required' }
MorphicToolBuilder >> buildPluggableMenu: menuSpec [ 
	| prior menu |
	prior := parentMenu.
	parentMenu := menu := self menuClass new.
	menuSpec label ifNotNil:[parentMenu addTitle: menuSpec label].
	menuSpec items do:[:each| each buildWith: self].
	parentMenu := prior.
	^menu
]

{ #category : #'widgets required' }
MorphicToolBuilder >> buildPluggableMenuItem: itemSpec [
	| item action label menu |
	item := self menuItemClass new.
	label := (itemSpec isCheckable
		ifTrue: [	itemSpec checked ifTrue: ['<on>'] ifFalse: ['<off>']]
		ifFalse: ['']), itemSpec label.
	item contents: label.
	item isEnabled: itemSpec enabled.
	(action := itemSpec action) ifNotNil:[
		item 
			target: action receiver;
			selector: action selector;
			arguments: action arguments.
	].
	(menu := itemSpec subMenu) ifNotNil:[
		item subMenu: (menu buildWith: self).
	].
	parentMenu ifNotNil:[parentMenu addMorphBack: item].
	itemSpec separator ifTrue:[parentMenu addLine].
	^item
]

{ #category : #'widgets required' }
MorphicToolBuilder >> buildPluggableMultiColumnList: aSpec [
	| widget listClass getIndex setIndex |
	aSpec getSelected ifNil:[
		listClass := self multiColumnListClass.
		getIndex := aSpec getIndex.
		setIndex := aSpec setIndex.
	] ifNotNil: [
		listClass := self multiColumnListByItemClass.
		getIndex := aSpec getSelected.
		setIndex := aSpec setSelected.
	].
	widget := listClass on: aSpec model
				list: aSpec list
				selected: getIndex
				changeSelected: setIndex
				menu: aSpec menu
				keystroke: aSpec keyPress.
	self register: widget id: aSpec name.
	
"	widget
		dragItemSelector: aSpec dragItem;
		dropItemSelector: aSpec dropItem;
		wantsDropSelector: aSpec dropAccept;
		dragStartedSelector: aSpec dragStarted."

	self setListPropertiesFor: widget spec: aSpec.
	
	"Be sure to enable the horizontal scrollbar if not all columns are #spaceFill."
	(aSpec columnResizings anySatisfy: [:sym | sym ~= #spaceFill])
		ifTrue: [widget hScrollBarPolicy: #whenNeeded].
		
	widget
		cellPositioningForColumns: aSpec itemAlignments;
		cellInsetForColumns: aSpec itemPaddings;
		hResizingForColumns: aSpec columnResizings;
		spaceFillWeightForColumns: aSpec columnSpaceFillWeights.
	
	^widget
]

{ #category : #'widgets optional' }
MorphicToolBuilder >> buildPluggableMultiSelectionList: aSpec [
	| widget listClass |
	aSpec getSelected ifNotNil:[^self error:'There is no PluggableListMorphOfManyByItem'].
	listClass := self multiSelectListClass.
	widget := listClass on: aSpec model
		list: aSpec list
		primarySelection: aSpec getIndex
		changePrimarySelection: aSpec setIndex
		listSelection: aSpec getSelectionList
		changeListSelection: aSpec setSelectionList
		menu: aSpec menu.
	widget keystrokeActionSelector: aSpec keyPress.
	self register: widget id: aSpec name.
	self setListPropertiesFor: widget spec: aSpec.
	^widget
]

{ #category : #'widgets required' }
MorphicToolBuilder >> buildPluggablePanel: aSpec [

	| widget |
	widget := self panelClass new.
	self register: widget id: aSpec name.

	widget model: aSpec model.

	"Set child dependent layout properties."
	widget wantsPaneSplitters: (aSpec wantsResizeHandles ifNil: [false]).
	self setLayoutHintsFor: widget spec: aSpec.
	widget layoutInset: (aSpec padding ifNil: [0]).
	widget cellGap: (aSpec spacing ifNil: [
		widget wantsPaneSplitters
			ifTrue: [ProportionalSplitterMorph gripThickness]
			ifFalse: [2]]).

	"Now create the children."
	aSpec children isSymbol
		ifTrue: [
			widget getChildrenSelector: aSpec children.
			widget update: aSpec children]
		ifFalse: [
			self buildAll: aSpec children in: widget].

	self setFrame: aSpec frame in: widget.
	self setLayout: aSpec layout in: widget.
	
	parent ifNotNil:[self add: widget to: parent].

	widget borderWidth: 0.
	self buildHelpFor: widget spec: aSpec. 
	widget color: Color transparent.
	
	^ widget
]

{ #category : #'widgets optional' }
MorphicToolBuilder >> buildPluggableScrollPane: spec [

	| widget panel |
	widget := self scrollPaneClass new.
	widget model: spec model.
	self register: widget id: spec name.
	
	spec children
		ifNotNil: [:obj |
			"Create panel morph to scroll it."
			panel := self pluggablePanelSpec new
				model: spec model;
				children: obj;
				layout: spec layout;
				horizontalResizing: (spec layout == #proportional ifTrue: [#rigid] ifFalse: [#shrinkWrap]);
				verticalResizing: (spec layout == #proportional ifTrue: [#rigid] ifFalse: [#shrinkWrap]);
				buildWith: self.
			widget morph: panel.
			]
		ifNil: [spec morph
			ifNotNil: [:m | widget morph: m]
			ifNil: [widget morphClass: spec morphClass]].
	
	self setFrame: spec frame in: widget.
	self setLayoutHintsFor: widget spec: spec.
	
	parent ifNotNil: [self add: widget to: parent].
	
	spec borderWidth ifNotNil: [:w | widget borderWidth: w].
	
	"Set scroll bar policies. By default, use scroll bars only when needed. Do not follow system-wide preferences here."
	spec hScrollBarPolicy
		caseOf: {
			[#always] -> [widget alwaysShowHScrollBar].
			[#never] -> [widget hideHScrollBarIndefinitely].
			[#whenNeeded] -> [widget showHScrollBarOnlyWhenNeeded] }
		otherwise: [widget showHScrollBarOnlyWhenNeeded].
	spec vScrollBarPolicy
		caseOf: {
			[#always] -> [widget alwaysShowVScrollBar].
			[#never] -> [widget hideVScrollBarIndefinitely].
			[#whenNeeded] -> [widget showVScrollBarOnlyWhenNeeded] }
		otherwise: [widget showVScrollBarOnlyWhenNeeded].
	
	^ widget
]

{ #category : #'widgets required' }
MorphicToolBuilder >> buildPluggableSpacer: spec [

	| widget |
	widget := self spacerClass new.
	self register: widget id: spec name.
	
	widget borderWidth: 0.
	widget color: (spec color ifNil: [Color transparent]).
	widget extent: spec extent.

	self buildHelpFor: widget spec: spec. 
	
	self setFrame: spec frame in: widget.
	self setLayoutHintsFor: widget spec: spec.
		
	parent ifNotNil:[self add: widget to: parent].
	^widget
]

{ #category : #'widgets required' }
MorphicToolBuilder >> buildPluggableText: aSpec [
	| widget |
	widget := self textPaneClass new.
	aSpec stylerClass ifNotNil: [:c | widget styler: (c new view: widget)].	
	widget
		on: aSpec model
		text: aSpec getText 
		accept: aSpec setText
		readSelection: aSpec selection 
		menu: aSpec menu.
	aSpec font ifNotNil: [:f | widget font: f].
	
	widget readOnly: aSpec readOnly.
	widget editTextSelector: aSpec editText.
	widget wantsFrameAdornments: aSpec indicateUnacceptedChanges.

	widget askBeforeDiscardingEdits: aSpec askBeforeDiscardingEdits.
	widget setProperty: #alwaysAccept toValue: aSpec askBeforeDiscardingEdits not.

	widget wrapFlag: (aSpec softLineWrap ifNil: [true]).
	
	self register: widget id: aSpec name.
	widget getColorSelector: aSpec color.
	widget getTextColorSelector: aSpec textColor.
	self buildHelpFor: widget spec: aSpec.
	 
	self setFrame: aSpec frame in: widget.
	self setLayoutHintsFor: widget spec: aSpec.
	
	parent ifNotNil:[self add: widget to: parent].
	^widget
]

{ #category : #'widgets required' }
MorphicToolBuilder >> buildPluggableTree: aSpec [
	| widget |
	widget := self treeClass new.
	self register: widget id: aSpec name.

	widget getLabelSelector: aSpec label.
	widget getIconSelector: aSpec icon.

	widget model: aSpec model.
	widget nodeClass: aSpec nodeClass.

	widget getRootsSelector: aSpec roots.
	widget getChildrenSelector: aSpec getChildren.
	widget hasChildrenSelector: aSpec hasChildren.

	widget getSelectedSelector: aSpec getSelected.
	widget setSelectedSelector: aSpec setSelected.
	widget getSelectedPathSelector: aSpec getSelectedPath.
	widget setSelectedPathSelector: aSpec setSelectedPath.

	widget setSelectedParentSelector: aSpec setSelectedParent.

	widget getHelpSelector: aSpec help.
	widget getMenuSelector: aSpec menu.

	widget keystrokeActionSelector: aSpec keyPress.
	widget autoDeselect: aSpec autoDeselect.
	widget doubleClickSelector: aSpec doubleClick.
	
	widget dropItemSelector: aSpec dropItem.
	widget wantsDropSelector: aSpec dropAccept.
	widget dragItemSelector: aSpec dragItem.
	widget dragStartedSelector: aSpec dragStarted.
	
	widget columns: aSpec columns.
	
	"Override default scroll bar policies if needed. Widget will use preference values otherwise."
	aSpec hScrollBarPolicy ifNotNil: [:policy |
		policy caseOf: {
			[#always] -> [widget alwaysShowHScrollBar].
			[#never] -> [widget hideHScrollBarIndefinitely].
			[#whenNeeded] -> [widget showHScrollBarOnlyWhenNeeded]. } ].
	aSpec vScrollBarPolicy ifNotNil: [:policy |
		policy caseOf: {
			[#always] -> [widget alwaysShowVScrollBar].
			[#never] -> [widget hideVScrollBarIndefinitely].
			[#whenNeeded] -> [widget showVScrollBarOnlyWhenNeeded]. } ].	
	
	self setFrame: aSpec frame in: widget.
	self setLayoutHintsFor: widget spec: aSpec.
	
	parent ifNotNil:[self add: widget to: parent].
"	panes ifNotNil:[
		aSpec roots ifNotNil:[panes add: aSpec roots].
	].	"
	^widget
]

{ #category : #'widgets required' }
MorphicToolBuilder >> buildPluggableWindow: aSpec [
	| widget |

	aSpec layout == #proportional ifFalse:[
		"This needs to be implemented - probably by adding a single pane and then the rest"
		^self error: 'Not implemented'.
	].

	widget := (self windowClassFor: aSpec) new.
	self register: widget id: aSpec name.
	
	widget model: aSpec model.

	"Set child dependent layout properties."
	widget wantsPaneSplitters: (aSpec wantsResizeHandles ifNil: [true]).
	self setLayoutHintsFor: widget spec: aSpec.
	widget layoutInset: (aSpec padding ifNil: [ProportionalSplitterMorph gripThickness]).
	widget cellGap: (aSpec spacing ifNil: [ProportionalSplitterMorph gripThickness]).
	
	"Now create the children."
	panes := OrderedCollection new.
	aSpec children isSymbol
		ifTrue: [
			widget getChildrenSelector: aSpec children.
			widget update: aSpec children]
		ifFalse: [
			self buildAll: aSpec children in: widget].
	widget setUpdatablePanesFrom: panes.
	
	aSpec label ifNotNil: [:label|
		label isSymbol 
			ifTrue:[widget getLabelSelector: label]
			ifFalse:[widget setLabel: label]].

	aSpec multiWindowStyle notNil ifTrue:
		[widget savedMultiWindowState: (SavedMultiWindowState on: aSpec model)].

	widget closeWindowSelector: aSpec closeAction.
	self buildHelpFor: widget spec: aSpec. 

	widget bounds: (RealEstateAgent 
		initialFrameFor: widget 
		initialExtent: (aSpec extent ifNil:[widget initialExtent])
		world: self currentWorld).

	widget refreshWindowColor.

	^ widget
]

{ #category : #'widget classes' }
MorphicToolBuilder >> buttonClass [
	^ PluggableButtonMorphPlus
]

{ #category : #'widget classes' }
MorphicToolBuilder >> checkBoxClass [
	^ PluggableCheckBoxMorph
]

{ #category : #opening }
MorphicToolBuilder >> close: aWidget [
	"Close a previously opened widget"
	aWidget delete
]

{ #category : #'widget classes' }
MorphicToolBuilder >> codePaneClass [
	^ PluggableTextMorphPlus
]

{ #category : #'widget classes' }
MorphicToolBuilder >> dialogClass [
	^ PluggableDialogWindow
]

{ #category : #'widget classes' }
MorphicToolBuilder >> dropDownListClass [
	^ PluggableDropDownListMorph
]

{ #category : #'widget classes' }
MorphicToolBuilder >> listByItemClass [
	^ PluggableListMorphByItemPlus
]

{ #category : #'widget classes' }
MorphicToolBuilder >> listClass [
	^ PluggableListMorphPlus
]

{ #category : #'widget classes' }
MorphicToolBuilder >> menuClass [
	^ MenuMorph
]

{ #category : #'widget classes' }
MorphicToolBuilder >> menuItemClass [
	^ MenuItemMorph
]

{ #category : #'widget classes' }
MorphicToolBuilder >> multiColumnListByItemClass [
	^ PluggableMultiColumnListMorphByItem
]

{ #category : #'widget classes' }
MorphicToolBuilder >> multiColumnListClass [
	^ PluggableMultiColumnListMorph
]

{ #category : #'widget classes' }
MorphicToolBuilder >> multiSelectListClass [
	^ PluggableListMorphOfMany
]

{ #category : #opening }
MorphicToolBuilder >> open: anObject [
	"Build and open the object. Answer the widget opened."
	
	^ (self build: anObject) openAsTool
]

{ #category : #opening }
MorphicToolBuilder >> open: anObject label: aString [
	"Build an open the object, labeling it appropriately if it is a window. Answer the widget opened."
	
	| morph |
	morph := self open: anObject.
	morph isSystemWindow
		ifTrue: [morph setLabel: aString]
		ifFalse: [morph name: aString].
	^ morph
]

{ #category : #'widget classes' }
MorphicToolBuilder >> panelClass [
	^ PluggablePanelMorph
]

{ #category : #private }
MorphicToolBuilder >> register: widget id: id [
	id ifNil:[^self].
	widgets ifNil:[widgets := Dictionary new].
	widgets at: id put: widget.
	widget setNameTo: id.
]

{ #category : #opening }
MorphicToolBuilder >> runModal: aWidget [
	"Run the (previously opened) widget modally, e.g., 
	do not return control to the sender before the user has responded."
	[aWidget world notNil] whileTrue: [
		aWidget outermostWorldMorph doOneCycle.
	].

]

{ #category : #'widget classes' }
MorphicToolBuilder >> scrollPaneClass [
	^ PluggableScrollPane
]

{ #category : #private }
MorphicToolBuilder >> setFrame: aRectangle in: widget [
	| frame |
	aRectangle ifNil:[^nil].
	frame := aRectangle isRectangle
		ifTrue: [self asFrame: aRectangle]
		ifFalse: [aRectangle]. "assume LayoutFrame"
	widget layoutFrame: frame.
	widget hResizing: #spaceFill; vResizing: #spaceFill.
]

{ #category : #private }
MorphicToolBuilder >> setLayout: layout in: widget [
	layout == #proportional ifTrue:[
		widget layoutPolicy: ProportionalLayout new.
		^self].
	layout == #horizontal ifTrue:[
		widget layoutPolicy: TableLayout new.
		widget listDirection: #leftToRight.
		"widget cellInset: 1@1.
		widget layoutInset: 1@1."
		widget color: Color transparent.
		"and then some..."
		^self].
	layout == #vertical ifTrue:[
		widget layoutPolicy: TableLayout new.
		widget listDirection: #topToBottom.
		"widget cellInset: 1@1.
		widget layoutInset: 1@1."
		widget color: Color transparent.
		"and then some..."
		^self].
	^self error: 'Unknown layout: ', layout.
]

{ #category : #private }
MorphicToolBuilder >> setLayoutHintsFor: widget spec: aSpec [

	aSpec minimumWidth >= 0
		ifTrue: [widget minimumWidth: aSpec minimumWidth].
	aSpec minimumHeight >= 0
		ifTrue: [widget minimumHeight: aSpec minimumHeight].
	aSpec padding
		ifNotNil: [:p | widget layoutInset: p].
	"aSpec margin
		ifNotNil: [:m | widget layoutOutset: m]."
	
	widget hResizing: (aSpec horizontalResizing ifNil: [#spaceFill]).
	widget vResizing: (aSpec verticalResizing ifNil: [#spaceFill]).
]

{ #category : #private }
MorphicToolBuilder >> setListPropertiesFor: widget spec: aSpec [
		
	"Override default scroll bar policies if needed. Widget will use preference values otherwise."
	aSpec hScrollBarPolicy ifNotNil: [:policy |
		policy caseOf: {
			[#always] -> [widget alwaysShowHScrollBar].
			[#never] -> [widget hideHScrollBarIndefinitely].
			[#whenNeeded] -> [widget showHScrollBarOnlyWhenNeeded]. } ].
	aSpec vScrollBarPolicy ifNotNil: [:policy |
		policy caseOf: {
			[#always] -> [widget alwaysShowVScrollBar].
			[#never] -> [widget hideVScrollBarIndefinitely].
			[#whenNeeded] -> [widget showVScrollBarOnlyWhenNeeded]. } ].	
	
	widget
		getListElementSelector: aSpec listItem;
		getListSizeSelector: aSpec listSize;
		getIconSelector: aSpec icon;
		getHelpSelector: aSpec helpItem;
		doubleClickSelector: aSpec doubleClick.
	
	widget
		autoDeselect: aSpec autoDeselect;
		keystrokePreviewSelector: aSpec keystrokePreview.
	
	aSpec filterableList ifNotNil: [:b | widget filterableList: b].
	aSpec clearFilterAutomatically ifNotNil: [:b | widget clearFilterAutomatically: b].
	
	aSpec color ifNotNil: [:c | widget color: c].
	self buildHelpFor: widget spec: aSpec. 
			
	self setFrame: aSpec frame in: widget.
	self setLayoutHintsFor: widget spec: aSpec.
	aSpec itemAlignment ifNotNil: [:alignment | widget listMorph cellPositioning: alignment].
	aSpec itemPadding ifNotNil: [:padding | widget listMorph cellInset: padding].
	
	parent ifNotNil:[self add: widget to: parent].
	(panes notNil and: [aSpec list notNil]) ifTrue: [panes add: aSpec list].

]

{ #category : #'widget classes' }
MorphicToolBuilder >> spacerClass [

	^ Morph
]

{ #category : #'widget classes' }
MorphicToolBuilder >> textPaneClass [
	^ PluggableTextMorphPlus
]

{ #category : #'widget classes' }
MorphicToolBuilder >> treeClass [
	^ PluggableTreeMorph
]

{ #category : #private }
MorphicToolBuilder >> widgetAt: id ifAbsent: aBlock [
	widgets ifNil:[^aBlock value].
	^widgets at: id ifAbsent: aBlock
]

{ #category : #'widget classes' }
MorphicToolBuilder >> windowClass [
	^ PluggableSystemWindow
]

{ #category : #'widget classes' }
MorphicToolBuilder >> windowClassFor: aSpec [
	^aSpec multiWindowStyle
		caseOf:
		{	[nil]				->	[PluggableSystemWindow].
			[#labelButton]	->	[PluggableSystemWindowWithLabelButton] }
		otherwise:				[PluggableSystemWindowWithLabelButton]
]
