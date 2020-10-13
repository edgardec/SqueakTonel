Class {
	#name : #MCToolWindowBuilder,
	#superclass : #Object,
	#instVars : [
		'builder',
		'window',
		'currentFrame',
		'tool'
	],
	#category : #'Monticello-UI'
}

{ #category : #'instance creation' }
MCToolWindowBuilder class >> builder: aBuilder tool: aTool [
	^ self basicNew initializeWithBuilder: aBuilder tool: aTool
]

{ #category : #building }
MCToolWindowBuilder >> build [
	^ builder build: window
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> buttonRow [
	^ self buttonRow: tool buttonSpecs
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> buttonRow: specArray [
	| panel |
	panel := builder pluggablePanelSpec new.
	panel children: OrderedCollection new.
	specArray do:
		[:spec | | button |
		
		button := builder pluggableButtonSpec new.
		button model: tool.
		button label: spec first asString.
		button action: spec second.
		button help: spec third.
		button enabled: (spec at: 4 ifAbsent: [#buttonEnabled]).
		button state: (spec at: 5 ifAbsent: [#buttonSelected]).
		panel children add: button].
	panel layout: #horizontal.
	panel frame: currentFrame.
	window children add: panel
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> codePane: aSymbol [
	| text |
	text := builder pluggableCodePaneSpec new.
	text 
		model: tool;
		getText: aSymbol; 
		setText: (aSymbol, ':') asSymbol;
		frame: currentFrame.
	window children add: text
]

{ #category : #accessing }
MCToolWindowBuilder >> frame: aLayoutFrame [
	currentFrame := aLayoutFrame
]

{ #category : #'initialize-release' }
MCToolWindowBuilder >> initializeWithBuilder: aBuilder tool: aTool [
	builder := aBuilder.
	tool := aTool.
	window := builder pluggableWindowSpec new.
	window children: OrderedCollection new.
	window label: tool label asString.
	window model: tool.
	window extent: tool defaultExtent.
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> innerButtonRow [
	^ self buttonRow: tool innerButtonSpecs
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> inputMorph: aSymbol [
	| text |
	text := builder pluggableInputFieldSpec new.
	text 
		model: tool;
		getText: aSymbol; 
		setText: (aSymbol, ':') asSymbol;
		frame: currentFrame.
	window children add: text
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> listMorph: listSymbol [
	^ self
		listMorph: (listSymbol, 'List') asSymbol
		selection: (listSymbol, 'Selection') asSymbol
		menu: (listSymbol, 'ListMenu:') asSymbol
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> listMorph: listSymbol keystroke: keystrokeSymbol [
	^ (self
		listMorph: (listSymbol, 'List') asSymbol
		selection: (listSymbol, 'Selection') asSymbol
		menu: (listSymbol, 'ListMenu:') asSymbol)
		keystrokeActionSelector: keystrokeSymbol;
		yourself
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> listMorph: listSymbol selection: selectionSymbol [
	self listMorph: listSymbol selection: selectionSymbol menu: nil
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> listMorph: listSymbol selection: selectionSymbol menu: menuSymbol [
	self listMorph: listSymbol selection: selectionSymbol menu: menuSymbol keystroke: nil
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> listMorph: listSymbol selection: selectionSymbol menu: menuSymbol keystroke: keystrokeSymbol [
	| list |
	list := builder pluggableListSpec new.
	list 
		model: tool;
		list: listSymbol; 
		getIndex: selectionSymbol; 
		setIndex: (selectionSymbol, ':') asSymbol;
		frame: currentFrame.
	menuSymbol ifNotNil: [list menu: menuSymbol].
	keystrokeSymbol ifNotNil: [list keyPress: keystrokeSymbol].
	window children add: list

]

{ #category : #'building-parts' }
MCToolWindowBuilder >> multiListMorph: listSymbol selection: selectionSymbol listSelection: listSelectionSymbol menu: menuSymbol [
	| list |
	list := builder pluggableMultiSelectionListSpec new.
	list 
		model: tool;
		list: listSymbol; 
		getIndex: selectionSymbol; 
		setIndex: (selectionSymbol, ':') asSymbol;
		getSelectionList: listSelectionSymbol;
		setSelectionList: (listSelectionSymbol, 'put:') asSymbol;
		frame: currentFrame.
	menuSymbol ifNotNil: [list menu: menuSymbol].
	window children add: list

]

{ #category : #'building-parts' }
MCToolWindowBuilder >> textMorph: aSymbol [
	| text |
	text := builder pluggableTextSpec new.
	text 
		model: tool;
		getText: aSymbol; 
		setText: (aSymbol, ':') asSymbol;
		frame: currentFrame.
	window children add: text
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> treeMorph: listSymbol [
	^ self
		treeMorph: (listSymbol, 'Tree') asSymbol
		selection: (listSymbol, 'SelectionWrapper') asSymbol
		menu: (listSymbol, 'TreeMenu:') asSymbol
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> treeMorph: listSymbol selection: selectionSymbol menu: menuSymbol [
	self notYetImplemented
]

{ #category : #'building-parts' }
MCToolWindowBuilder >> treeOrListMorph: listSymbol [
	^ self listMorph: listSymbol
]
