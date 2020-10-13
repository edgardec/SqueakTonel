"
A variant of LazyListMorph that can display multi-column lists.
"
Class {
	#name : #MulticolumnLazyListMorph,
	#superclass : #LazyListMorph,
	#instVars : [
		'columnWidths'
	],
	#category : #'60Deprecated-Morphic-Widgets'
}

{ #category : #drawing }
MulticolumnLazyListMorph >> display: items atRow: row on: canvas [ 
	"display the specified item, which is on the specified row; for Multicolumn 
	lists, items will be a list of strings"
	| drawBounds |
	drawBounds :=  (self drawBoundsForRow: row) translateBy: (self hMargin @ 0).
	drawBounds := drawBounds intersect: self bounds.
	items
		with: (1 to: items size)
		do: [:item :index | 
			"move the bounds to the right at each step"
			index > 1
				ifTrue: [drawBounds := drawBounds left: drawBounds left + 6
									+ (columnWidths at: index - 1)].
			item isText
				ifTrue: [canvas
						drawString: item
						in: drawBounds
						font: (font
								emphasized: (item emphasisAt: 1))
						color: (self colorForRow: row)]
				ifFalse: [canvas
						drawString: item
						in: drawBounds
						font: font
						color: (self colorForRow: row)]]
]

{ #category : #drawing }
MulticolumnLazyListMorph >> drawOn: aCanvas [
        self getListSize = 0 ifTrue:[ ^self ].

        self setColumnWidthsFor: aCanvas.

        super drawOn: aCanvas
]

{ #category : #'list access' }
MulticolumnLazyListMorph >> getListItem: index [
	^listSource getListItem: index
]

{ #category : #'list management' }
MulticolumnLazyListMorph >> listChanged [
	columnWidths := nil.
	super listChanged
]

{ #category : #drawing }
MulticolumnLazyListMorph >> setColumnWidthsFor: aCanvas [
        | row topRow bottomRow |
        "set columnWidths for drawing on the specified canvas"
		columnWidths ifNil: [
		columnWidths := (self item: 1) collect: [ :ignored | 0 ]. ].
	topRow := (self topVisibleRowForCanvas: aCanvas) max: 1.
	bottomRow :=  (self bottomVisibleRowForCanvas: aCanvas) max: 1.
	topRow > bottomRow ifTrue: [ ^ self ].
	topRow to: bottomRow do: [ :rowIndex |
                row := self item: rowIndex.
                columnWidths := columnWidths with: row collect: [ :currentWidth :item |
				| widthOfItem |
				widthOfItem := (font widthOfStringOrText: item).
				widthOfItem > currentWidth
					ifTrue: [ self changed.  widthOfItem ]
					ifFalse: [ currentWidth ] ] ]
]

{ #category : #'scroll range' }
MulticolumnLazyListMorph >> widthToDisplayItem: item [
	| widths |
	widths := item collect: [ :each | super widthToDisplayItem: each ].
	^widths sum + (10 * (widths size - 1))   "add in space between the columns"

]
