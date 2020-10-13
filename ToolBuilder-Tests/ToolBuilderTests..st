"
Some tests to make sure ToolBuilder does what it says.
"
Class {
	#name : #ToolBuilderTests,
	#superclass : #TestCase,
	#instVars : [
		'builder',
		'widget',
		'queries',
		'depth'
	],
	#category : #'ToolBuilder-Tests'
}

{ #category : #testing }
ToolBuilderTests class >> isAbstract [
	^self == ToolBuilderTests
]

{ #category : #support }
ToolBuilderTests >> acceptWidgetText [
	"accept text in widget"
	^ self subclassResponsibility
]

{ #category : #'tests-menus' }
ToolBuilderTests >> assertItemFiresWith: aBlock [
	| spec |
	spec := builder pluggableMenuSpec new.
	spec model: self.
	aBlock value: spec.
	widget := builder build: spec.
	queries := IdentitySet new.
	self fireMenuItemWidget.
	self assert: (queries includes: #fireMenuAction)
]

{ #category : #support }
ToolBuilderTests >> buttonWidgetEnabled [
	"Answer whether the current widget (a button) is currently enabled"
	
	^ widget getModelState
]

{ #category : #support }
ToolBuilderTests >> changeListWidget [
	"Change the list widget's selection index"
	self subclassResponsibility
]

{ #category : #support }
ToolBuilderTests >> expectedButtonSideEffects [
	"side effect queries we expect to see on buttons"
	^#()
]

{ #category : #'tests-button' }
ToolBuilderTests >> fireButton [
	queries add: #fireButton.
]

{ #category : #support }
ToolBuilderTests >> fireButtonWidget [
	"Fire the widget, e.g., perform what is needed for the guy to trigger its action"
	self subclassResponsibility
]

{ #category : #'tests-menus' }
ToolBuilderTests >> fireMenuAction [
	queries add: #fireMenuAction
]

{ #category : #'tests-menus' }
ToolBuilderTests >> fireMenuItemWidget [
	self subclassResponsibility
]

{ #category : #'tests-panel' }
ToolBuilderTests >> getChildren [
	queries add: #getChildren.
	^#()
]

{ #category : #'tests-trees' }
ToolBuilderTests >> getChildrenOf: item [
	queries add: #getChildrenOf.
	depth := depth + 1.
	^ depth < 4 ifTrue: [(1 to: 9) asArray] ifFalse: [#()]
]

{ #category : #'tests-text' }
ToolBuilderTests >> getColor [
	queries add: #getColor.
	^Color tan
]

{ #category : #'tests-button' }
ToolBuilderTests >> getEnabled [
	queries add: #getEnabled.
	^true
]

{ #category : #'tests-trees' }
ToolBuilderTests >> getHelpOf: item [
	^'help'
]

{ #category : #'tests-trees' }
ToolBuilderTests >> getIconOf: item [
	queries add: #getIconOf.
	^nil
]

{ #category : #'tests-button' }
ToolBuilderTests >> getLabel [
	queries add: #getLabel.
	^'TestLabel'
]

{ #category : #'tests-trees' }
ToolBuilderTests >> getLabelOf: item [
	queries add: #getLabelOf.
	^item asString
]

{ #category : #'tests-lists' }
ToolBuilderTests >> getList [
	queries add: #getList.
	^(1 to: 100) collect:[:i| i printString].
]

{ #category : #'tests-lists' }
ToolBuilderTests >> getListIndex [
	queries add: #getListIndex.
	^13
]

{ #category : #'tests-lists' }
ToolBuilderTests >> getListSelection [
	queries add: #getListSelection.
	^'55'
]

{ #category : #'tests-lists' }
ToolBuilderTests >> getMenu: aMenu [
	queries add: #getMenu.
	^aMenu
]

{ #category : #'tests-trees' }
ToolBuilderTests >> getRoots [
	queries add: #getRoots.
	^(1 to: 9) asArray
]

{ #category : #'tests-button' }
ToolBuilderTests >> getState [
	queries add: #getState.
	^true
]

{ #category : #'tests-text' }
ToolBuilderTests >> getText [
	queries add: #getText.
	^Text new
]

{ #category : #'tests-text' }
ToolBuilderTests >> getTextSelection [
	queries add: #getTextSelection.
	^(1 to: 0)
]

{ #category : #'tests-trees' }
ToolBuilderTests >> getTreeSelectionPath [
	queries add: #getTreeSelectionPath.
	^{2. 4. 3}
]

{ #category : #'tests-trees' }
ToolBuilderTests >> hasChildren: item [
	queries add: #hasChildren.
	^true
]

{ #category : #'tests-lists' }
ToolBuilderTests >> keyPress: key [
	queries add: #keyPress.
]

{ #category : #'tests-button' }
ToolBuilderTests >> makeButton [
	| spec |
	spec := self makeButtonSpec.
	widget := builder build: spec.
	^widget
]

{ #category : #'tests-button' }
ToolBuilderTests >> makeButtonSpec [
	| spec |
	spec := builder pluggableButtonSpec new.
	spec name: #button.
	spec model: self.
	spec label: #getLabel.
	spec color: #getColor.
	spec state: #getState.
	spec enabled: #getEnabled.
	^spec
]

{ #category : #'tests-input' }
ToolBuilderTests >> makeInputField [
	| spec |
	spec := self makeInputFieldSpec.
	widget := builder build: spec.
]

{ #category : #'tests-input' }
ToolBuilderTests >> makeInputFieldSpec [
	| spec |
	spec := builder pluggableInputFieldSpec new.
	spec name: #input.
	spec model: self.
	spec getText: #getText.
	spec selection: #getTextSelection.
	spec color: #getColor.
	"<-- the following cannot be tested very well -->"
	spec setText: #setText:.
	spec menu: #getMenu:.
	^spec
]

{ #category : #'tests-lists' }
ToolBuilderTests >> makeItemList [
	| spec |
	spec := self makeItemListSpec.
	widget := builder build: spec.
]

{ #category : #'tests-lists' }
ToolBuilderTests >> makeItemListSpec [
	| spec |
	spec := builder pluggableListSpec new.
	spec name: #list.
	spec model: self.
	spec list: #getList.
	spec getSelected: #getListSelection.
	"<-- the following cannot be tested very well -->"
	spec setSelected: #setListSelection:.
	spec menu: #getMenu:.
	spec keyPress: #keyPress:.
	^spec
]

{ #category : #'tests-lists' }
ToolBuilderTests >> makeList [
	| spec |
	spec := self makeListSpec.
	widget := builder build: spec.
]

{ #category : #'tests-lists' }
ToolBuilderTests >> makeListSpec [
	| spec |
	spec := builder pluggableListSpec new.
	spec name: #list.
	spec model: self.
	spec list: #getList.
	spec getIndex: #getListIndex.
	"<-- the following cannot be tested very well -->"
	spec setIndex: #setListIndex:.
	spec menu: #getMenu:.
	spec keyPress: #keyPress:.
	^spec
]

{ #category : #'tests-panel' }
ToolBuilderTests >> makePanel [
	| spec |
	spec := self makePanelSpec.
	widget := builder build: spec.
]

{ #category : #'tests-panel' }
ToolBuilderTests >> makePanelSpec [
	| spec |
	spec := builder pluggablePanelSpec new.
	spec name: #panel.
	spec model: self.
	spec children: #getChildren.
	^spec
]

{ #category : #'tests-text' }
ToolBuilderTests >> makeText [
	| spec |
	spec := self makeTextSpec.
	widget := builder build: spec.
]

{ #category : #'tests-text' }
ToolBuilderTests >> makeTextSpec [
	| spec |
	spec := builder pluggableTextSpec new.
	spec name: #text.
	spec model: self.
	spec getText: #getText.
	spec selection: #getTextSelection.
	spec color: #getColor.
	"<-- the following cannot be tested very well -->"
	spec setText: #setText:.
	spec menu: #getMenu:.
	^spec
]

{ #category : #'tests-trees' }
ToolBuilderTests >> makeTree [
	| spec |
	spec := self makeTreeSpec.
	widget := builder build: spec.
]

{ #category : #'tests-trees' }
ToolBuilderTests >> makeTreeSpec [
	| spec |
	spec := builder pluggableTreeSpec new.
	spec name: #tree.
	spec model: self.
	spec roots: #getRoots.
	"<-- the following cannot be tested very well -->"
	spec getSelectedPath: #getTreeSelectionPath.
	spec getChildren: #getChildrenOf:.
	spec hasChildren: #hasChildren:.
	spec label: #getLabelOf:.
	spec icon: #getIconOf:.
	spec help: #getHelpOf:.
	spec setSelected: #setTreeSelection:.
	spec menu: #getMenu:.
	spec keyPress: #keyPress:.
	^spec
]

{ #category : #'tests-window' }
ToolBuilderTests >> makeWindow [
	| spec |
	spec := self makeWindowSpec.
	widget := builder build: spec.
]

{ #category : #'tests-window' }
ToolBuilderTests >> makeWindowSpec [
	| spec |
	spec := builder pluggableWindowSpec new.
	spec name: #window.
	spec model: self.
	spec children: #getChildren.
	spec label: #getLabel.
	spec closeAction: #noteWindowClosed.
	^spec
]

{ #category : #'tests-window' }
ToolBuilderTests >> noteWindowClosed [
	queries add: #noteWindowClosed.
]

{ #category : #'tests-window' }
ToolBuilderTests >> openWindow [
	| spec |
	spec := self makeWindowSpec.
	widget := builder open: spec.
]

{ #category : #support }
ToolBuilderTests >> returnFalse [
	^false
]

{ #category : #support }
ToolBuilderTests >> returnTrue [
	^true
]

{ #category : #'tests-lists' }
ToolBuilderTests >> setListIndex: index [
	queries add: #setListIndex.
]

{ #category : #'tests-lists' }
ToolBuilderTests >> setListSelection: newIndex [
	queries add: #setListSelection.
]

{ #category : #'tests-text' }
ToolBuilderTests >> setText: newText [
	queries add: #setText.
	^false
]

{ #category : #'tests-trees' }
ToolBuilderTests >> setTreeSelection: node [
	queries add: #setTreeSelection.
]

{ #category : #support }
ToolBuilderTests >> setUp [
	queries := IdentitySet new.
	depth := 0.
]

{ #category : #support }
ToolBuilderTests >> shutDown [
	self myDependents: nil
]

{ #category : #'tests-menus' }
ToolBuilderTests >> testAddTargetSelectorArgumentList [
	self assertItemFiresWith: 
		[:spec | spec
				add: 'Menu Item' 
				target: self
				selector: #fireMenuAction
				argumentList: #()]
]

{ #category : #'tests-button' }
ToolBuilderTests >> testButtonFiresBlock [
	| spec |
	spec := builder pluggableButtonSpec new.
	spec model: self.
	spec action: [self fireButton].
	widget := builder build: spec.
	queries := IdentitySet new.
	self fireButtonWidget.
	self assert: (queries includes: #fireButton).
]

{ #category : #'tests-button' }
ToolBuilderTests >> testButtonFiresMessage [
	| spec |
	spec := builder pluggableButtonSpec new.
	spec model: self.
	spec action: (MessageSend receiver: self selector: #fireButton arguments: #()).
	widget := builder build: spec.
	queries := IdentitySet new.
	self fireButtonWidget.
	self assert: (queries includes: #fireButton).
]

{ #category : #'tests-button' }
ToolBuilderTests >> testButtonFiresSymbol [
	| spec |
	spec := builder pluggableButtonSpec new.
	spec model: self.
	spec action: #fireButton.
	widget := builder build: spec.
	queries := IdentitySet new.
	self fireButtonWidget.
	self assert: (queries includes: #fireButton).
]

{ #category : #'tests-button' }
ToolBuilderTests >> testButtonInitiallyDisabled [
	| spec |
	spec := builder pluggableButtonSpec new.
	spec model: self.
	spec label: #getLabel.
	spec color: #getColor.
	spec state: #getState.
	spec enabled: #returnFalse.
	widget := builder build: spec.
	self deny: (self buttonWidgetEnabled)
]

{ #category : #'tests-button' }
ToolBuilderTests >> testButtonInitiallyDisabledSelector [
	| spec |
	spec := builder pluggableButtonSpec new.
	spec model: self.
	spec label: #getLabel.
	spec color: #getColor.
	spec state: #getState.
	spec enabled: #returnFalse.
	widget := builder build: spec.
	self deny: (self buttonWidgetEnabled)
]

{ #category : #'tests-button' }
ToolBuilderTests >> testButtonInitiallyEnabled [
	| spec |
	spec := builder pluggableButtonSpec new.
	spec model: self.
	spec label: #getLabel.
	spec color: #getColor.
	spec state: #getState.
	spec enabled: #returnTrue.
	widget := builder build: spec.
	self assert: (self buttonWidgetEnabled)
]

{ #category : #'tests-button' }
ToolBuilderTests >> testButtonInitiallyEnabledSelector [
	| spec |
	spec := builder pluggableButtonSpec new.
	spec model: self.
	spec label: #getLabel.
	spec color: #getColor.
	spec state: #getState.
	spec enabled: #returnTrue.
	widget := builder build: spec.
	self assert: (self buttonWidgetEnabled)
]

{ #category : #'tests-button' }
ToolBuilderTests >> testButtonWidgetID [
	self makeButton.
	self assert: (builder widgetAt: #button) == widget.
]

{ #category : #'tests-button' }
ToolBuilderTests >> testGetButtonColor [
	self makeButton.
	queries := IdentitySet new.
	self changed: #getColor.
	self assert: (queries includes: #getColor).
	self assert: self widgetColor = self getColor.
]

{ #category : #'tests-button' }
ToolBuilderTests >> testGetButtonEnabled [
	self makeButton.
	queries := IdentitySet new.
	self changed: #getEnabled.
	self assert: (queries includes: #getEnabled).
]

{ #category : #'tests-button' }
ToolBuilderTests >> testGetButtonLabel [
	self makeButton.
	queries := IdentitySet new.
	self changed: #getLabel.
	self assert: (queries includes: #getLabel).
]

{ #category : #'tests-button' }
ToolBuilderTests >> testGetButtonSideEffects [
	self makeButton.
	queries := IdentitySet new.
	self changed: #testSignalWithNoDiscernableEffect.
	self expectedButtonSideEffects do:[:sym|
		self assert: (queries includes: sym). 
		queries remove: sym.
	].
	self assert: queries isEmpty.
]

{ #category : #'tests-button' }
ToolBuilderTests >> testGetButtonState [
	self makeButton.
	queries := IdentitySet new.
	self changed: #getState.
	self assert: (queries includes: #getState).
]

{ #category : #'tests-input' }
ToolBuilderTests >> testGetInputFieldColor [
	self makeInputField.
	queries := IdentitySet new.
	self changed: #getColor.
	self assert: (queries includes: #getColor).
	self assert: self widgetColor = self getColor.
]

{ #category : #'tests-input' }
ToolBuilderTests >> testGetInputFieldSelection [
	self makeInputField.
	queries := IdentitySet new.
	self changed: #getTextSelection.
	self assert: (queries includes: #getTextSelection).
]

{ #category : #'tests-input' }
ToolBuilderTests >> testGetInputFieldSideEffectFree [
	self makeInputField.
	queries := IdentitySet new.
	self changed: #testSignalWithNoDiscernableEffect.
	self assert: queries isEmpty.
]

{ #category : #'tests-input' }
ToolBuilderTests >> testGetInputFieldText [
	self makeInputField.
	queries := IdentitySet new.
	self changed: #getText.
	self assert: (queries includes: #getText).
]

{ #category : #'tests-lists' }
ToolBuilderTests >> testGetItemListSideEffectFree [
	self makeItemList.
	queries := IdentitySet new.
	self changed: #testSignalWithNoDiscernableEffect.
	self assert: queries isEmpty.
]

{ #category : #'tests-lists' }
ToolBuilderTests >> testGetList [
	self makeList.
	queries := IdentitySet new.
	self changed: #getList.
	self assert: (queries includes: #getList).
]

{ #category : #'tests-lists' }
ToolBuilderTests >> testGetListIndex [
	self makeList.
	queries := IdentitySet new.
	self changed: #getListIndex.
	self assert: (queries includes: #getListIndex).
]

{ #category : #'tests-lists' }
ToolBuilderTests >> testGetListSelection [
	self makeItemList.
	queries := IdentitySet new.
	self changed: #getListSelection.
	self assert: (queries includes: #getListSelection).
]

{ #category : #'tests-lists' }
ToolBuilderTests >> testGetListSideEffectFree [
	self makeList.
	queries := IdentitySet new.
	self changed: #testSignalWithNoDiscernableEffect.
	self assert: queries isEmpty.
]

{ #category : #'tests-panel' }
ToolBuilderTests >> testGetPanelChildren [
	self makePanel.
	queries := IdentitySet new.
	self changed: #getChildren.
	self assert: (queries includes: #getChildren).
]

{ #category : #'tests-panel' }
ToolBuilderTests >> testGetPanelSideEffectFree [
	self makePanel.
	queries := IdentitySet new.
	self changed: #testSignalWithNoDiscernableEffect.
	self assert: queries isEmpty.
]

{ #category : #'tests-text' }
ToolBuilderTests >> testGetText [
	self makeText.
	queries := IdentitySet new.
	self changed: #getText.
	self assert: (queries includes: #getText).
]

{ #category : #'tests-text' }
ToolBuilderTests >> testGetTextColor [
	self makeText.
	queries := IdentitySet new.
	self changed: #getColor.
	self assert: (queries includes: #getColor).
	self assert: self widgetColor = self getColor.
]

{ #category : #'tests-text' }
ToolBuilderTests >> testGetTextSelection [
	self makeText.
	queries := IdentitySet new.
	self changed: #getTextSelection.
	self assert: (queries includes: #getTextSelection).
]

{ #category : #'tests-text' }
ToolBuilderTests >> testGetTextSideEffectFree [
	self makeText.
	queries := IdentitySet new.
	self changed: #testSignalWithNoDiscernableEffect.
	self assert: queries isEmpty.
]

{ #category : #'tests-window' }
ToolBuilderTests >> testGetWindowChildren [
	self makeWindow.
	queries := IdentitySet new.
	self changed: #getChildren.
	self assert: (queries includes: #getChildren).
]

{ #category : #'tests-window' }
ToolBuilderTests >> testGetWindowLabel [
	self makeWindow.
	queries := IdentitySet new.
	self changed: #getLabel.
	self assert: (queries includes: #getLabel).
]

{ #category : #'tests-window' }
ToolBuilderTests >> testGetWindowSideEffectFree [
	self makeWindow.
	queries := IdentitySet new.
	self changed: #testSignalWithNoDiscernableEffect.
	self assert: queries isEmpty.
]

{ #category : #'tests-input' }
ToolBuilderTests >> testInputWidgetID [
	self makeInputField.
	self assert: (builder widgetAt: #input) == widget.
]

{ #category : #'tests-lists' }
ToolBuilderTests >> testItemListWidgetID [
	self makeItemList.
	self assert: (builder widgetAt: #list) == widget.
]

{ #category : #'tests-lists' }
ToolBuilderTests >> testListWidgetID [
	self makeList.
	self assert: (builder widgetAt: #list) == widget.
]

{ #category : #'tests-panel' }
ToolBuilderTests >> testPanelWidgetID [
	self makePanel.
	self assert: (builder widgetAt: #panel) == widget.
]

{ #category : #'tests-input' }
ToolBuilderTests >> testSetInputField [
	self makeInputField.
	queries := IdentitySet new.
	self acceptWidgetText.
	self assert: (queries includes: #setText).
]

{ #category : #'tests-lists' }
ToolBuilderTests >> testSetListIndex [
	self makeList.
	queries := IdentitySet new.
	self changeListWidget.
	self assert: (queries includes: #setListIndex).
]

{ #category : #'tests-lists' }
ToolBuilderTests >> testSetListSelection [
	self makeItemList.
	queries := IdentitySet new.
	self changeListWidget.
	self assert: (queries includes: #setListSelection).
]

{ #category : #'tests-text' }
ToolBuilderTests >> testSetText [
	self makeText.
	queries := IdentitySet new.
	self acceptWidgetText.
	self assert: (queries includes: #setText).
]

{ #category : #'tests-text' }
ToolBuilderTests >> testTextWidgetID [
	self makeText.
	self assert: (builder widgetAt: #text) == widget
]

{ #category : #'tests-trees' }
ToolBuilderTests >> testTreeExpandPath [
	"@@@@: REMOVE THIS - it's a hack (changed: #openPath)"
	self makeTree.
	queries := IdentitySet new.
	self changed: {#openPath. '4'. '2'. '3'}.
	self waitTick.
	self assert: (queries includes: #getChildrenOf).
	self assert: (queries includes: #setTreeSelection).
	self assert: (queries includes: #getLabelOf).

]

{ #category : #'tests-trees' }
ToolBuilderTests >> testTreeExpandPathFirst [
	"@@@@: REMOVE THIS - it's a hack (changed: #openPath)"
	self makeTree.
	queries := IdentitySet new.
	self changed: {#openPath. '1'. '2'. '2'}.
	self waitTick.
	self assert: (queries includes: #getChildrenOf).
	self assert: (queries includes: #setTreeSelection).
	self assert: (queries includes: #getLabelOf).

]

{ #category : #'tests-trees' }
ToolBuilderTests >> testTreeGetSelectionPath [
	self makeTree.
	queries := IdentitySet new.
	self changed: #getTreeSelectionPath.
	self waitTick.
	self assert: (queries includes: #getTreeSelectionPath).
	self assert: (queries includes: #setTreeSelection).
]

{ #category : #'tests-trees' }
ToolBuilderTests >> testTreeRoots [
	self makeTree.
	queries := IdentitySet new.
	depth := 0.
	self changed: #getRoots.
	self assert: (queries includes: #getRoots).
]

{ #category : #'tests-trees' }
ToolBuilderTests >> testTreeWidgetID [
	self makeTree.
	self assert: (builder widgetAt: #tree) == widget.
]

{ #category : #'tests-window' }
ToolBuilderTests >> testWindowCloseAction [
	self openWindow.
	builder close: widget.
	self assert: (queries includes: #noteWindowClosed).
]

{ #category : #'tests-window' }
ToolBuilderTests >> testWindowID [
	self makeWindow.
	self assert: (builder widgetAt: #window) == widget.
]

{ #category : #support }
ToolBuilderTests >> waitTick [
	^nil
]

{ #category : #support }
ToolBuilderTests >> widgetColor [
	"Answer color from widget"
	self subclassResponsibility

	"NOTE: You can bail out if you don't know how to get the color from the widget:
		^self getColor
	will work."
]

{ #category : #support }
ToolBuilderTests >> windowColorToUse [

	^ Color black
]
