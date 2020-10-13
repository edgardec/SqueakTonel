"
A single selection list element.

Instance variables:
	list		<Symbol>	The selector to retrieve the list elements.
	getIndex	<Symbol>	The selector to retrieve the list selection index.
	setIndex	<Symbol>	The selector to set the list selection index.
	getSelected	<Symbol>	The selector to retrieve the list selection.
	setSelected	<Symbol>	The selector to set the list selection.
	menu	<Symbol>	The selector to offer (to retrieve?) the context menu.
	keyPress <Symbol>	The selector to invoke for handling keyboard shortcuts.
	autoDeselect	<Boolean>	Whether the list should allow automatic deselection or not.
	dragItem	<Symbol>	Selector to initiate a drag action on an item
	dropItem	<Symbol>	Selector to initiate a drop action of an item
	dropAccept	<Symbol>	Selector to determine whether a drop would be accepted
"
Class {
	#name : #PluggableListSpec,
	#superclass : #PluggableWidgetSpec,
	#instVars : [
		'list',
		'getIndex',
		'setIndex',
		'getSelected',
		'setSelected',
		'menu',
		'keyPress',
		'autoDeselect',
		'dragItem',
		'dropItem',
		'dropAccept',
		'doubleClick',
		'listSize',
		'listItem',
		'keystrokePreview',
		'icon',
		'vScrollBarPolicy',
		'hScrollBarPolicy',
		'dragStarted',
		'helpItem',
		'filterableList',
		'clearFilterAutomatically',
		'itemAlignment',
		'itemPadding'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #'accessing - selection' }
PluggableListSpec >> autoDeselect [
	"Answer whether this tree can be automatically deselected"
	^autoDeselect ifNil:[true]
]

{ #category : #'accessing - selection' }
PluggableListSpec >> autoDeselect: aBool [
	"Indicate whether this tree can be automatically deselected"
	autoDeselect := aBool
]

{ #category : #building }
PluggableListSpec >> buildWith: builder [
	^builder buildPluggableList: self
]

{ #category : #'accessing - list' }
PluggableListSpec >> clearFilterAutomatically [
	^ clearFilterAutomatically
]

{ #category : #'accessing - list' }
PluggableListSpec >> clearFilterAutomatically: aBoolean [
	clearFilterAutomatically := aBoolean.
]

{ #category : #accessing }
PluggableListSpec >> doubleClick [
	"Answer the selector to perform when a double-click occurs"
	^doubleClick
]

{ #category : #accessing }
PluggableListSpec >> doubleClick: aSymbol [
	"Set the selector to perform when a double-click occurs"
	doubleClick := aSymbol.
]

{ #category : #'accessing - drag and drop' }
PluggableListSpec >> dragItem [
	"Answer the selector for dragging an item"
	^dragItem
]

{ #category : #'accessing - drag and drop' }
PluggableListSpec >> dragItem: aSymbol [
	"Set the selector for dragging an item"
	dragItem := aSymbol
]

{ #category : #'accessing - drag and drop' }
PluggableListSpec >> dragStarted [
	^ dragStarted
]

{ #category : #'accessing - drag and drop' }
PluggableListSpec >> dragStarted: symbol [
	dragStarted := symbol.
]

{ #category : #'accessing - drag and drop' }
PluggableListSpec >> dropAccept [
	"Answer the selector to determine whether a drop would be accepted"
	^dropAccept
]

{ #category : #'accessing - drag and drop' }
PluggableListSpec >> dropAccept: aSymbol [
	"Answer the selector to determine whether a drop would be accepted"
	dropAccept := aSymbol.
]

{ #category : #'accessing - drag and drop' }
PluggableListSpec >> dropItem [
	"Answer the selector for dropping an item"
	^dropItem
]

{ #category : #'accessing - drag and drop' }
PluggableListSpec >> dropItem: aSymbol [
	"Set the selector for dropping an item"
	dropItem := aSymbol
]

{ #category : #'accessing - list' }
PluggableListSpec >> filterableList [
	^ filterableList
]

{ #category : #'accessing - list' }
PluggableListSpec >> filterableList: aBoolean [
	filterableList := aBoolean.
]

{ #category : #'accessing - selection' }
PluggableListSpec >> getIndex [
	"Answer the selector for retrieving the list's selection index"
	^getIndex
]

{ #category : #'accessing - selection' }
PluggableListSpec >> getIndex: aSymbol [
	"Indicate the selector for retrieving the list's selection index"
	getIndex := aSymbol
]

{ #category : #'accessing - selection' }
PluggableListSpec >> getSelected [
	"Answer the selector for retrieving the list selection"
	^getSelected
]

{ #category : #'accessing - selection' }
PluggableListSpec >> getSelected: aSymbol [
	"Indicate the selector for retrieving the list selection"
	getSelected := aSymbol
]

{ #category : #accessing }
PluggableListSpec >> hScrollBarPolicy [

	^ hScrollBarPolicy
]

{ #category : #accessing }
PluggableListSpec >> hScrollBarPolicy: aSymbol [
	"#always, #never, #whenNeeded"

	hScrollBarPolicy := aSymbol.
]

{ #category : #accessing }
PluggableListSpec >> helpItem [
	
	^ helpItem
]

{ #category : #accessing }
PluggableListSpec >> helpItem: selector [
	
	helpItem := selector.
]

{ #category : #accessing }
PluggableListSpec >> icon [
	^ icon
]

{ #category : #accessing }
PluggableListSpec >> icon: aSelector [
	icon := aSelector
]

{ #category : #accessing }
PluggableListSpec >> itemAlignment [
	"Define the alignment of each list item in its layout cell. The value can encode both horizontal and vertical dimensions."
	
	^ itemAlignment
]

{ #category : #accessing }
PluggableListSpec >> itemAlignment: aSymbol [
	"For convenience, map #left and #right to their correct values. At least for Morphic."
	
	aSymbol == #left ifTrue: [^ itemAlignment := #leftCenter].
	aSymbol == #right ifTrue: [^ itemAlignment := #rightCenter].
	
	itemAlignment := aSymbol.
]

{ #category : #accessing }
PluggableListSpec >> itemPadding [
	
	^ itemPadding
]

{ #category : #accessing }
PluggableListSpec >> itemPadding: numberOrPointOrRectangle [
	
	itemPadding := numberOrPointOrRectangle.
]

{ #category : #accessing }
PluggableListSpec >> keyPress [
	"Answer the selector for invoking the list's keyPress handler"
	^keyPress
]

{ #category : #accessing }
PluggableListSpec >> keyPress: aSymbol [
	"Indicate the selector for invoking the list's keyPress handler"
	keyPress := aSymbol
]

{ #category : #accessing }
PluggableListSpec >> keystrokePreview [
	"Answer the selector to determine whether to allow the model a preview of keystrokes"
	^ keystrokePreview
]

{ #category : #accessing }
PluggableListSpec >> keystrokePreview: aSymbol [
	"The selector to determine whether to allow the model a preview of keystrokes"
	keystrokePreview := aSymbol.
]

{ #category : #'accessing - list' }
PluggableListSpec >> list [
	"Answer the selector for retrieving the list contents"
	^list
]

{ #category : #'accessing - list' }
PluggableListSpec >> list: aSymbol [
	"Indicate the selector for retrieving the list contents"
	list := aSymbol.
]

{ #category : #'accessing - list' }
PluggableListSpec >> listItem [
	"Answer the selector for retrieving the list element"
	^listItem
]

{ #category : #'accessing - list' }
PluggableListSpec >> listItem: aSymbol [
	"Indicate the selector for retrieving the list element"
	listItem := aSymbol.
]

{ #category : #'accessing - list' }
PluggableListSpec >> listSize [
	"Answer the selector for retrieving the list size"
	^listSize
]

{ #category : #'accessing - list' }
PluggableListSpec >> listSize: aSymbol [
	"Indicate the selector for retrieving the list size"
	listSize := aSymbol.
]

{ #category : #accessing }
PluggableListSpec >> menu [
	"Answer the selector for retrieving the list's menu"
	^menu
]

{ #category : #accessing }
PluggableListSpec >> menu: aSymbol [
	"Indicate the selector for retrieving the list's menu"
	menu := aSymbol
]

{ #category : #'accessing - selection' }
PluggableListSpec >> setIndex [
	"Answer the selector for setting the list's selection index"
	^setIndex
]

{ #category : #'accessing - selection' }
PluggableListSpec >> setIndex: aSymbol [
	"Answer the selector for setting the list's selection index"
	setIndex := aSymbol
]

{ #category : #'accessing - selection' }
PluggableListSpec >> setSelected [
	"Answer the selector for setting the list selection"
	^setSelected
]

{ #category : #'accessing - selection' }
PluggableListSpec >> setSelected: aSymbol [
	"Indicate the selector for setting the list selection"
	setSelected := aSymbol
]

{ #category : #accessing }
PluggableListSpec >> vScrollBarPolicy [

	^ vScrollBarPolicy
]

{ #category : #accessing }
PluggableListSpec >> vScrollBarPolicy: aSymbol [
	"#always, #never, #whenNeeded"
	
	vScrollBarPolicy := aSymbol.
]
