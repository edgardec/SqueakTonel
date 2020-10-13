"
A pluggable tree widget. PluggableTrees are slightly different from lists in such that they ALWAYS store the actual objects and use the label selector to query for the label of the item. PluggableTrees also behave somewhat differently in such that they do not have a ""getSelected"" message but only a getSelectedPath message. The difference is that getSelectedPath is used to indicate by the model that the tree should select the appropriate path. This allows disambiguation of items. Because of this, implementations of PluggableTrees must always set their internal selection directly, e.g., rather than sending the model a setSelected message and wait for an update of the #getSelected the implementation must set the selection before sending the #setSelected message. If a client doesn't want this, it can always just signal a change of getSelectedPath to revert to whatever is needed.

Instance variables:
	roots 	<Symbol>	The message to retrieve the roots of the tree.
	getSelectedPath	<Symbol> The message to retrieve the selected path in the tree.
	setSelectedPath	<Symbol> The message to set the selected path in the tree.
	setSelected	<Symbol>	The message to set the selected item in the tree.
	getChildren	<Symbol>	The message to retrieve the children of an item
	hasChildren	<Symbol>	The message to query for children of an item
	label 	<Symbol>	The message to query for the label of an item.
	icon 	<Symbol>	The message to query for the icon of an item.
	help 	<Symbol>	The message to query for the help of an item.
	menu	<Symbol>	The message to query for the tree's menu
	keyPress	<Symbol>	The message to process a keystroke.
	wantsDrop	<Symbol>	The message to query whether a drop might be accepted.
	dropItem	<Symbol>	The message to drop an item.
	enableDrag <Boolean>	Enable dragging from this tree.
	autoDeselect	<Boolean>	Whether the tree should allow automatic deselection or not.
	unusedVar	(unused)	This variable is a placeholder to fix problems with loading packages in 3.10.
"
Class {
	#name : #PluggableTreeSpec,
	#superclass : #PluggableWidgetSpec,
	#instVars : [
		'roots',
		'getSelectedPath',
		'setSelectedPath',
		'setSelected',
		'getSelected',
		'setSelectedParent',
		'getChildren',
		'hasChildren',
		'label',
		'icon',
		'unusedVar',
		'menu',
		'keyPress',
		'doubleClick',
		'dropItem',
		'dropAccept',
		'autoDeselect',
		'dragItem',
		'nodeClass',
		'columns',
		'vScrollBarPolicy',
		'hScrollBarPolicy',
		'dragStarted'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #'accessing - selection' }
PluggableTreeSpec >> autoDeselect [
	"Answer whether this tree can be automatically deselected"
	^autoDeselect ifNil:[true]
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> autoDeselect: aBool [
	"Indicate whether this tree can be automatically deselected"
	autoDeselect := aBool.
]

{ #category : #building }
PluggableTreeSpec >> buildWith: builder [
	^builder buildPluggableTree: self
]

{ #category : #accessing }
PluggableTreeSpec >> columns [
	^ columns
]

{ #category : #accessing }
PluggableTreeSpec >> columns: columnSpecs [
	columns := columnSpecs.
]

{ #category : #accessing }
PluggableTreeSpec >> doubleClick [
	"Answer the selector for reacting to a double click"
	^ doubleClick
]

{ #category : #accessing }
PluggableTreeSpec >> doubleClick: selector [
	"Set the selector for reacting to a double click"
	doubleClick := selector
]

{ #category : #'accessing - drag and drop' }
PluggableTreeSpec >> dragItem [
	^ dragItem.
]

{ #category : #'accessing - drag and drop' }
PluggableTreeSpec >> dragItem: aSymbol [
	"Set the selector for dragging an item"
	dragItem := aSymbol
]

{ #category : #'accessing - drag and drop' }
PluggableTreeSpec >> dragStarted [
	^ dragStarted
]

{ #category : #'accessing - drag and drop' }
PluggableTreeSpec >> dragStarted: symbol [
	dragStarted := symbol.
]

{ #category : #'accessing - drag and drop' }
PluggableTreeSpec >> dropAccept [
	"Answer the selector for querying the receiver about accepting drops"
	^dropAccept
]

{ #category : #'accessing - drag and drop' }
PluggableTreeSpec >> dropAccept: aSymbol [
	"Set the selector for querying the receiver about accepting drops"
	dropAccept := aSymbol
]

{ #category : #'accessing - drag and drop' }
PluggableTreeSpec >> dropItem [
	"Answer the selector for invoking the tree's dragDrop handler"
	^dropItem
]

{ #category : #'accessing - drag and drop' }
PluggableTreeSpec >> dropItem: aSymbol [
	"Indicate the selector for invoking the tree's dragDrop handler"
	dropItem := aSymbol
]

{ #category : #'accessing - hierarchy' }
PluggableTreeSpec >> getChildren [
	"Answer the message to get the children of this tree"
	^getChildren
]

{ #category : #'accessing - hierarchy' }
PluggableTreeSpec >> getChildren: aSymbol [
	"Indicate the message to retrieve the children of this tree"
	getChildren := aSymbol
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> getSelected [
	^ getSelected
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> getSelected: aSymbol [
	"Indicate a single node in the tree. Only works if that node is visible, too. Use #getSelectedPath otherwise."
	
	getSelected := aSymbol.
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> getSelectedPath [
	"Answer the message to retrieve the selection of this tree"
	^getSelectedPath
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> getSelectedPath: aSymbol [
	"Indicate the message to retrieve the selection of this tree"
	getSelectedPath := aSymbol
]

{ #category : #accessing }
PluggableTreeSpec >> hScrollBarPolicy [

	^ hScrollBarPolicy
]

{ #category : #accessing }
PluggableTreeSpec >> hScrollBarPolicy: aSymbol [
	"#always, #never, #whenNeeded"

	hScrollBarPolicy := aSymbol.
]

{ #category : #'accessing - hierarchy' }
PluggableTreeSpec >> hasChildren [
	"Answer the message to get the existence of children in this tree"
	^hasChildren
]

{ #category : #'accessing - hierarchy' }
PluggableTreeSpec >> hasChildren: aSymbol [
	"Indicate the message to retrieve the existence children in this tree"
	hasChildren := aSymbol
]

{ #category : #accessing }
PluggableTreeSpec >> icon [
	"Answer the message to get the icons of this tree"
	^icon
]

{ #category : #accessing }
PluggableTreeSpec >> icon: aSymbol [
	"Indicate the message to retrieve the icon of this tree"
	icon := aSymbol
]

{ #category : #accessing }
PluggableTreeSpec >> keyPress [
	"Answer the selector for invoking the tree's keyPress handler"
	^keyPress
]

{ #category : #accessing }
PluggableTreeSpec >> keyPress: aSymbol [
	"Indicate the selector for invoking the tree's keyPress handler"
	keyPress := aSymbol
]

{ #category : #accessing }
PluggableTreeSpec >> label [
	"Answer the message to get the labels of this tree"
	^label
]

{ #category : #accessing }
PluggableTreeSpec >> label: aSymbol [
	"Indicate the message to retrieve the labels of this tree"
	label := aSymbol
]

{ #category : #accessing }
PluggableTreeSpec >> menu [
	"Answer the message to get the menus of this tree"
	^menu
]

{ #category : #accessing }
PluggableTreeSpec >> menu: aSymbol [
	"Indicate the message to retrieve the menus of this tree"
	menu := aSymbol
]

{ #category : #accessing }
PluggableTreeSpec >> nodeClass [
	^ nodeClass
]

{ #category : #accessing }
PluggableTreeSpec >> nodeClass: aListWrapperClass [
	nodeClass := aListWrapperClass.
]

{ #category : #'accessing - hierarchy' }
PluggableTreeSpec >> roots [
	"Answer the message to retrieve the roots of this tree"
	^roots
]

{ #category : #'accessing - hierarchy' }
PluggableTreeSpec >> roots: aSymbol [
	"Indicate the message to retrieve the roots of this tree"
	roots := aSymbol
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> setSelected [
	"Answer the message to set the selection of this tree"
	^setSelected
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> setSelected: aSymbol [
	"Indicate the message to set the selection of this tree"
	setSelected := aSymbol
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> setSelectedParent [
	^ setSelectedParent
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> setSelectedParent: aSymbol [
	setSelectedParent := aSymbol
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> setSelectedPath [

	^ setSelectedPath
]

{ #category : #'accessing - selection' }
PluggableTreeSpec >> setSelectedPath: aSymbol [
	
	setSelectedPath := aSymbol
]

{ #category : #accessing }
PluggableTreeSpec >> vScrollBarPolicy [

	^ vScrollBarPolicy
]

{ #category : #accessing }
PluggableTreeSpec >> vScrollBarPolicy: aSymbol [
	"#always, #never, #whenNeeded"
	
	vScrollBarPolicy := aSymbol.
]
