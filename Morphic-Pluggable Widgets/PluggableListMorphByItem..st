"
Like PluggableListMorph but maps #setIndexSelector and #getIndexSelector to actual items instead of indexes.
"
Class {
	#name : #PluggableListMorphByItem,
	#superclass : #PluggableListMorph,
	#category : #'Morphic-Pluggable Widgets'
}

{ #category : #'model access' }
PluggableListMorphByItem >> changeModelSelection: anInteger [
	"Change the model's selected item to be the one at the given index."

	setIndexSelector ifNotNil: [
		model
			perform: setIndexSelector
			with: (self getFullList at: anInteger ifAbsent: [nil])].
]

{ #category : #'model access' }
PluggableListMorphByItem >> getCurrentSelectionIndex [
	"Answer the index of the current selection."

	^ getIndexSelector
		ifNil: [0]
		ifNotNil: [self getFullList indexOf: (model perform: getIndexSelector)]
]
