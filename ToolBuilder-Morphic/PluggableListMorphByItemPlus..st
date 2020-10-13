"
Like PluggableListMorphPlus but maps #setIndexSelector and #getIndexSelector to actual items instead of indexes.
"
Class {
	#name : #PluggableListMorphByItemPlus,
	#superclass : #PluggableListMorphPlus,
	#instVars : [
		'itemList'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #'model access' }
PluggableListMorphByItemPlus >> changeModelSelection: anInteger [
	"Change the model's selected item to be the one at the given index."

	setIndexSelector ifNotNil: [
		model
			perform: setIndexSelector
			with: (self getFullList at: anInteger ifAbsent: [nil])].
]

{ #category : #'model access' }
PluggableListMorphByItemPlus >> getCurrentSelectionIndex [
	"Answer the index of the current selection."

	^ getIndexSelector
		ifNil: [0]
		ifNotNil: [self getFullList indexOf: (model perform: getIndexSelector)]
]
