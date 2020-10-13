Class {
	#name : #ListComponent,
	#superclass : #PluggableListMorph,
	#instVars : [
		'selectedItem',
		'setSelectionSelector',
		'pinSpecs'
	],
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #'model access' }
ListComponent >> changeModelSelection: anInteger [
	"Change the model's selected item index to be anInteger."

	setIndexSelector
		ifNil: 	["If model is not hooked up to index, then we won't get
					an update, so have to do it locally."
				self selectionIndex: anInteger]
		ifNotNil: [model perform: setIndexSelector with: anInteger].
	selectedItem := anInteger = 0 ifTrue: [nil] ifFalse: [self getListItem: anInteger].
	setSelectionSelector ifNotNil:
		[model perform: setSelectionSelector with: selectedItem]
]

{ #category : #components }
ListComponent >> initFromPinSpecs [
	| ioPin |
	getListSelector := pinSpecs first modelReadSelector.
	ioPin := pinSpecs second.
	getIndexSelector := ioPin isInput 
		ifTrue: [ioPin modelReadSelector]
		ifFalse: [nil].
	setIndexSelector := ioPin isOutput 
				ifTrue: [ioPin modelWriteSelector]
				ifFalse: [nil].
	setSelectionSelector := pinSpecs third modelWriteSelector
]

{ #category : #components }
ListComponent >> initPinSpecs [ 
	pinSpecs := Array
		with: (PinSpec new pinName: 'list' direction: #input
				localReadSelector: nil localWriteSelector: nil
				modelReadSelector: getListSelector modelWriteSelector: nil
				defaultValue: #(one two three) pinLoc: 1.5)
		with: (PinSpec new pinName: 'index' direction: #inputOutput
				localReadSelector: nil localWriteSelector: nil
				modelReadSelector: getIndexSelector modelWriteSelector: setIndexSelector
				defaultValue: 0 pinLoc: 2.5)
		with: (PinSpec new pinName: 'selectedItem' direction: #output
				localReadSelector: nil localWriteSelector: nil
				modelReadSelector: nil modelWriteSelector: setSelectionSelector
				defaultValue: nil pinLoc: 3.5)
]

{ #category : #initialization }
ListComponent >> list: listOfItems [
	super list: listOfItems.
	self selectionIndex: 0.
	selectedItem := nil.
	setSelectionSelector ifNotNil:
		[model perform: setSelectionSelector with: selectedItem]
]
