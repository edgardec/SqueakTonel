"
Like PluggableMultiColumnListMorph but maps #setIndexSelector and #getIndexSelector to actual items instead of indexes.
"
Class {
	#name : #PluggableMultiColumnListMorphByItem,
	#superclass : #PluggableMultiColumnListMorph,
	#category : #'Morphic-Pluggable Widgets'
}

{ #category : #'model access' }
PluggableMultiColumnListMorphByItem >> changeModelSelection: modelIndex [
	"Change the model's selected item to be the one at the given index."

	setIndexSelector ifNotNil: [
		model
			perform: setIndexSelector
			with: (modelIndex = 0 ifTrue: [#()] ifFalse: [self getFullList collect: [:column | column at: modelIndex]])].
]

{ #category : #'model access' }
PluggableMultiColumnListMorphByItem >> getCurrentSelectionIndex [
	"Answer the index of the current selection. Similar to #selection: but with the full list instead of the (maybe) filtered list."

	getIndexSelector ifNil: [^ 0].
	
	(model perform: getIndexSelector) in: [:row |
		row ifNil: [^ 0].
		row ifEmpty: [^ 0].
		
		1 to: self fullListSize do: [:rowIndex |
			| match |
			match := true.
			self getFullList doWithIndex: [:column :columnIndex |
				match := match and: [(column at: rowIndex) = (row at: columnIndex)]].
			match ifTrue: [^ rowIndex]]].
	
	^ 0
]
