Class {
	#name : #PluggableMultiColumnListSpec,
	#superclass : #PluggableListSpec,
	#instVars : [
		'itemAlignments',
		'itemPaddings',
		'columnResizings',
		'columnSpaceFillWeights'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #building }
PluggableMultiColumnListSpec >> buildWith: builder [
	^builder buildPluggableMultiColumnList: self
]

{ #category : #accessing }
PluggableMultiColumnListSpec >> columnResizings [
	"For each column, define the horizontal resizing (or #hResizing) behavior. Choose from #rigid, #shrinkWrap, and #spaceFill."
	
	^ columnResizings ifNil: [#(spaceFill)]
]

{ #category : #accessing }
PluggableMultiColumnListSpec >> columnResizings: someSymbols [

	columnResizings := someSymbols.
]

{ #category : #accessing }
PluggableMultiColumnListSpec >> columnSpaceFillWeights [
	"For each column, define the relative space-fill weight, which will be used if the resizing strategy is set to #spaceFill."
	
	^ columnSpaceFillWeights ifNil: [#(1)]
]

{ #category : #accessing }
PluggableMultiColumnListSpec >> columnSpaceFillWeights: someNumbers [
	
	columnSpaceFillWeights := someNumbers.
]

{ #category : #accessing }
PluggableMultiColumnListSpec >> itemAlignments [
	"For each column, define the alignment of each list item in its layout cell. The value can encode both horizontal and vertical dimensions."
	
	^ itemAlignments ifNil: [self itemAlignment ifNil: [#()] ifNotNil: [:alignment | {alignment}]]
]

{ #category : #accessing }
PluggableMultiColumnListSpec >> itemAlignments: someSymbols [
	"For convenience, map #left and #right to their correct values. At least for Morphic."

	itemAlignments := someSymbols collect: [:alignment |
		alignment == #left ifTrue: [#leftCenter] ifFalse: [
		alignment == #right ifTrue: [#rightCenter] ifFalse: [
		alignment]]].
]

{ #category : #accessing }
PluggableMultiColumnListSpec >> itemPaddings [
	
	^ itemPaddings ifNil: [self itemPadding ifNil: [#()] ifNotNil: [:padding | {padding}]]
]

{ #category : #accessing }
PluggableMultiColumnListSpec >> itemPaddings: someNumbersOrPointsOrRectangles [
	
	itemPaddings := someNumbersOrPointsOrRectangles.
]
