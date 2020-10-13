"
The morph that displays the list in a PluggableListMorph.  It is ""lazy"" because it will only request the list items that it actually needs to display.

I will cache the maximum width of my items in maxWidth to avoid this potentially expensive and frequent computation.

The following layout properties are supported:
- #cellPositioning: #leftCenter [default], #center, #rightCenter
- #cellInset: [default: 3@0 corner: 3@0]
"
Class {
	#name : #LazyListMorph,
	#superclass : #Morph,
	#instVars : [
		'listItems',
		'listIcons',
		'listFilterOffsets',
		'font',
		'selectedRow',
		'selectedRows',
		'preSelectedRow',
		'listSource',
		'maxWidth',
		'columnIndex',
		'iconExtent',
		'backgroundColor',
		'showFilter'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #accessing }
LazyListMorph >> backgroundColor [
	"Since #color is this morph's default text color, this extra property is used for the actual background color. Supports nil."
	
	^ backgroundColor
]

{ #category : #accessing }
LazyListMorph >> backgroundColor: aColor [

	backgroundColor = aColor ifTrue: [^ self].
	backgroundColor := aColor.

	self changed.
	"Invalidate owner because we want to fill the vertical axis in the viewport entirely."
	self owner ifNotNil: [:o | o changed].
]

{ #category : #drawing }
LazyListMorph >> bottomVisibleRowForCanvas: aCanvas [
        "return the bottom visible row in aCanvas's clip rectangle"
        ^self rowAtLocation: aCanvas clipRect bottomLeft - (0@1).

]

{ #category : #layout }
LazyListMorph >> cellInset: inset [
	"Always store a rectangle to speed up drawing."
	
	super cellInset: (inset isRectangle
						ifTrue: [inset]
						ifFalse: [inset asPoint corner: inset asPoint]).
]

{ #category : #drawing }
LazyListMorph >> colorForRow: row [
	
	^(selectedRow notNil and: [ row = selectedRow])
		ifTrue: [ self selectionTextColor ]
		ifFalse: [ self color ].
]

{ #category : #accessing }
LazyListMorph >> columnIndex [
	^ columnIndex
]

{ #category : #accessing }
LazyListMorph >> columnIndex: anInteger [
	columnIndex := anInteger.
]

{ #category : #drawing }
LazyListMorph >> display: item atRow: row on: canvas [
	"display the given item at row row"

	| drawBounds emphasized rowColor itemAsText alignment |
	itemAsText := item asStringOrText.
	alignment := self cellPositioning.
	
	"If it is a text, we will only use the first character's emphasis."
	emphasized := itemAsText isText 
		ifTrue: [font emphasized: (itemAsText emphasisAt: 1)] 
		ifFalse: [font].
	
	rowColor := itemAsText isText
		ifTrue: [itemAsText colorAt: 1 ifNone: [self colorForRow: row]]
		ifFalse: [self colorForRow: row].
	
	drawBounds := self drawBoundsForRow: row.
	
	alignment ~= #leftCenter ifTrue: [
		| itemWidth |
		itemWidth := self widthToDisplayItem: item. "includes left/right margins"
		alignment == #center ifTrue: [
			drawBounds := (self center x - (itemWidth / 2) floor) @ drawBounds top corner: (self center x + (itemWidth / 2) ceiling) @ drawBounds bottom].
		alignment == #rightCenter ifTrue: [
			drawBounds := (self right - itemWidth) @ drawBounds top corner: self right @ drawBounds bottom]].

	"Draw icon if existing. Adjust draw bounds in that case."
	drawBounds := drawBounds translateBy: (self cellInset left @ 0).
	(self icon: row) ifNotNil: [ :icon || top |
		top := drawBounds top + ((drawBounds height - self iconExtent y) // 2).
		canvas translucentImage: icon at: drawBounds left @ top.
		drawBounds := drawBounds left: drawBounds left + self iconExtent x + 2 ].
		
	"We will only draw strings here."
	drawBounds := drawBounds translateBy: (0 @ self cellInset top).
	canvas
		drawString: itemAsText asString
		in: drawBounds
		font: emphasized
		color: rowColor.

	"Draw filter matches if any."
	self
		displayFilterOn: canvas
		for: row
		in: drawBounds
		font: emphasized.
]

{ #category : #drawing }
LazyListMorph >> displayFilterOn: canvas for: row in: drawBounds font: font [
	"Draw filter matches if any."
	
	| fillStyle fillHeight |
	self showFilter ifFalse: [^ self].
	
	fillHeight := font height.
	fillStyle := self filterColor isColor
		ifTrue: [SolidFillStyle color: self filterColor]
		ifFalse: [self filterColor].
	fillStyle isGradientFill ifTrue: [
		fillStyle origin: drawBounds topLeft.
		fillStyle direction: 0@ fillHeight].
	
	(self filterOffsets: row) do: [:offset |
		| highlightRectangle |
		highlightRectangle := ((drawBounds left + offset first first) @ drawBounds top
			corner: (drawBounds left + offset first last) @ (drawBounds top + fillHeight)).
		canvas
			frameAndFillRoundRect: (highlightRectangle outsetBy: 1@0)
			radius: (3 * RealEstateAgent scaleFactor) truncated
			fillStyle: fillStyle
			borderWidth: (1 * RealEstateAgent scaleFactor) truncated
			borderColor: fillStyle asColor twiceDarker.
		canvas
			drawString: offset second
			in: highlightRectangle
			font: font
			color: self filterTextColor].
]

{ #category : #layout }
LazyListMorph >> doLayoutIn: layoutBounds [
	"Only consider #shrinkWrap. Other layout properties are implemented in #drawOn:."

	self adjustLayoutBounds.
	fullBounds := self outerBounds.
]

{ #category : #drawing }
LazyListMorph >> drawBackgroundForMulti: row on: aCanvas [ 
	"shade the background paler, if this row is selected, but not the current selected row"
	| selectionDrawBounds |
	selectionDrawBounds := self drawBoundsForRow: row.
	selectionDrawBounds := selectionDrawBounds intersect: self bounds.
	aCanvas
		fillRectangle: selectionDrawBounds
		color: self multiSelectionColor
]

{ #category : #'list management' }
LazyListMorph >> drawBoundsForRow: row [
	"calculate the bounds that row should be drawn at.  This might be outside our bounds!"
	| topLeft drawBounds |
	topLeft := self topLeft x @ (self topLeft y + ((row - 1) * self rowHeight)).
	drawBounds := topLeft extent: self width @ self rowHeight.
	^drawBounds
]

{ #category : #drawing }
LazyListMorph >> drawOn: aCanvas [

	| topRow bottomRow |
	self backgroundColor ifNotNil: [:color |
		aCanvas fillRectangle: (self topLeft corner: self right @ ((self owner ifNil: [self]) bottom)) color: color].

	self getListSize = 0 ifTrue: [ ^self ].
	
	self drawPreSelectionOn: aCanvas.
	
	topRow := self topVisibleRowForCanvas: aCanvas.
	bottomRow := self bottomVisibleRowForCanvas: aCanvas.

	"Draw multi-selection."
	self listSource hasMultiSelection ifTrue: [
		topRow to: bottomRow do: [ :row |
			(self listSource itemSelectedAmongMultiple: row) ifTrue: [
				self drawBackgroundForMulti: row on: aCanvas ] ] ].
	self drawSelectionOn: aCanvas.

	"Draw hovered row if preference enabled."
	PluggableListMorph highlightHoveredRow ifTrue: [
		self listSource hoverRow > 0 ifTrue: [
			self highlightHoverRow: listSource hoverRow on: aCanvas ] ].

	"Draw all visible rows."
	topRow to: bottomRow do: [ :row |
		self display: (self item: row) atRow: row on: aCanvas ].

	"Finally, highlight drop row for drag/drop operations.."
	self listSource potentialDropRow > 0 ifTrue: [
		self highlightPotentialDropRow: self listSource potentialDropRow on: aCanvas ].
]

{ #category : #drawing }
LazyListMorph >> drawPreSelectionOn: aCanvas [
	
	self 
		drawSelectionFor: preSelectedRow
		withColor: self preSelectionColor 
		on: aCanvas
]

{ #category : #drawing }
LazyListMorph >> drawSelectionFor: index withColor: color on: aCanvas [
	
	| selectionDrawBounds fill |
	index ifNil: [ ^self ].
	index = 0 ifTrue: [ ^self ].
	selectionDrawBounds := self drawBoundsForRow: index.
	selectionDrawBounds := selectionDrawBounds intersect: self bounds.
	
	fill := color isColor
		ifTrue: [SolidFillStyle color: color]
		ifFalse: [color].
	fill isGradientFill ifTrue: [
		fill origin: selectionDrawBounds topLeft.
		fill direction: 0@ selectionDrawBounds height].
	
	listSource hasMultiSelection
		ifFalse: [aCanvas fillRectangle: selectionDrawBounds fillStyle: fill]
		ifTrue: [aCanvas frameRectangle: selectionDrawBounds color: fill asColor] .
]

{ #category : #drawing }
LazyListMorph >> drawSelectionOn: aCanvas [
	
	self 
		drawSelectionFor: selectedRow 
		withColor: self selectionColor 
		on: aCanvas
]

{ #category : #accessing }
LazyListMorph >> filterColor [
	^ self valueOfProperty: #filterColor ifAbsent: [Color yellow]
]

{ #category : #accessing }
LazyListMorph >> filterColor: aColor [

	| cc fill |
	cc := aColor.

	MenuMorph gradientMenu
		ifFalse: [fill := SolidFillStyle color: cc]
		ifTrue: [
			fill := GradientFillStyle ramp: { 
				0.0 -> cc twiceLighter. 
				1 -> cc twiceDarker }].

	self setProperty: #filterColor toValue: fill
]

{ #category : #'list access - cached' }
LazyListMorph >> filterOffsets: row [
	"Do inst-var access on listFilterOffsets here to initialize it as late as possible."
	
	listFilterOffsets ifNil: [listFilterOffsets := Array new: self getListSize].
		
	^ (listFilterOffsets at: row) ifNil: [
		| offsets |
		offsets := self getFilterOffsets: row.
		listFilterOffsets at: row put: offsets.
		offsets]
]

{ #category : #accessing }
LazyListMorph >> filterTextColor [
	^ self valueOfProperty: #filterTextColor ifAbsent: [Color black]
]

{ #category : #accessing }
LazyListMorph >> font [
	"return the font used for drawing.  The response is never nil"
	^font
]

{ #category : #accessing }
LazyListMorph >> font: newFont [

	font := (newFont ifNil: [ TextStyle default defaultFont ]).
	listFilterOffsets := nil.
	
	self layoutChanged.
	self changed.
]

{ #category : #'list access' }
LazyListMorph >> getFilterOffsets: row [
	"Calculate matching character indexes for the current filter term."
	
	| item filter offsets currentIndex sub emphasized |
	filter := self listSource filterTerm.
	filter ifEmpty: [^ Array empty].

	item := (self item: row) asStringOrText.

	emphasized := item isText 
		ifTrue: [font emphasized: (item emphasisAt: 1)] 
		ifFalse: [font].
		
	item := item asString.

	offsets := OrderedCollection new.
	
	currentIndex := 1.
	[currentIndex > 0] whileTrue: [
		currentIndex := item findString: filter startingAt: currentIndex caseSensitive: false.
		currentIndex > 0 ifTrue: [ | left width |
			left := emphasized widthOfString: item from: 1 to: currentIndex-1.
			sub := item copyFrom: currentIndex to: currentIndex + filter size - 1.
			width := emphasized widthOfString: sub.
			offsets addLast: {(left to: left + width). sub}.
			currentIndex := currentIndex + 1] ].
	^ offsets
]

{ #category : #'list access' }
LazyListMorph >> getListIcon: row [
	
	^ listSource iconAt: row column: self columnIndex

]

{ #category : #'list access' }
LazyListMorph >> getListItem: index [

	^ listSource itemAt: index column: self columnIndex
]

{ #category : #'list access' }
LazyListMorph >> getListSize [
	"return the number of items in the list"
	listSource ifNil: [ ^0 ].
	^listSource listSize
]

{ #category : #drawing }
LazyListMorph >> highlightHoverRow: row on: aCanvas [
	| drawBounds  |
	drawBounds := self drawBoundsForRow: row.
	drawBounds := drawBounds intersect: self bounds.
	aCanvas fillRectangle: drawBounds color: self hoverColor.
]

{ #category : #drawing }
LazyListMorph >> highlightPotentialDropRow: row  on: aCanvas [
	| drawBounds  |
	drawBounds := self drawBoundsForRow: row.
	drawBounds := drawBounds intersect: self bounds.
	aCanvas frameRectangle: drawBounds color: self selectionColor asColor
]

{ #category : #accessing }
LazyListMorph >> hoverColor [
	^ self valueOfProperty: #hoverColor ifAbsent: [Color veryVeryLightGray]
]

{ #category : #'list access - cached' }
LazyListMorph >> icon: row [
	"Do inst-var access on listIcons here to initialize it as late as possible."
	
	self listSource canHaveIcons ifFalse: [^ nil].
	
	listIcons ifNil: [listIcons := Array new: self getListSize].
	
	^ (listIcons at: row) ifNil: [
		| icon |
		icon := (self getListIcon: row) ifNotNil: [:form | form scaleIconToDisplay].
		"Update cache for uniform icon extent."
		iconExtent ifNil: [iconExtent := icon ifNotNil: [icon extent]].
		listIcons at: row put: icon.
		icon]
]

{ #category : #layout }
LazyListMorph >> iconExtent [

	^ iconExtent ifNil: [
		self getListSize = 0
			ifTrue: [((14@14) * RealEstateAgent scaleFactor) truncated]
			ifFalse: [(self icon: 1) ifNil: [0@0] ifNotNil: [:form | form extent]]]
]

{ #category : #initialization }
LazyListMorph >> initialize [

	super initialize.

	self color: Color black.
	self cellInset: 3@0.

	font := Preferences standardListFont.
	
	listItems := nil.
	listIcons := nil.
	listFilterOffsets := nil.
	
	selectedRow := nil.
	selectedRows := PluggableSet integerSet.
	preSelectedRow := nil.
]

{ #category : #'list access - cached' }
LazyListMorph >> item: index [
	"Do inst-var access on listItems here to initialize it as late as possible."

	listItems ifNil: [listItems := Array new: self getListSize].

	^ (listItems at: index) ifNil: [
		| newItem itemWidth |	
		newItem := self getListItem: index.

		"Update the width cache."
		maxWidth ifNotNil: [
			itemWidth := self widthToDisplayItem: newItem.
			itemWidth > maxWidth ifTrue: [
				maxWidth := itemWidth.
				super layoutChanged]].

		listItems at: index put: newItem.
		newItem].
]

{ #category : #layout }
LazyListMorph >> layoutChanged [
	"See #item:. We have to invalidate listItems or maxWidth will not be updated if you switch hResizing to #shrinkWrap."
	
	listItems := nil.
	maxWidth := nil.
	iconExtent := nil.
	
	super layoutChanged.
]

{ #category : #layout }
LazyListMorph >> listChanged [
	"set newList to be the list of strings to display"

	listItems := nil.
	listIcons := nil.
	listFilterOffsets := nil.

	maxWidth := nil.
		
	"selectedRow := nil. --- avoid reset to keep UI stable. See PluggableListMorph >> #selectionIndex and #selectionIndex:."
	selectedRows := PluggableSet integerSet.
	preSelectedRow := nil.
	
	self layoutChanged.
	self changed.

]

{ #category : #accessing }
LazyListMorph >> listSource [
	^ listSource
]

{ #category : #accessing }
LazyListMorph >> listSource: aListSource [
	"set the source of list items -- typically a PluggableListMorph"
	listSource := aListSource.
]

{ #category : #layout }
LazyListMorph >> maxHeight [
	
	^ (self getListSize max: 1) * self rowHeight
]

{ #category : #layout }
LazyListMorph >> maxWidth [
	"Approximate the maximum width of this lazy list. Take first n items as a sample."

	| threshold listSize |
	maxWidth ifNotNil:[^maxWidth].

	threshold := 30.
	listSize := self getListSize.
	
	maxWidth := 0.
	1 to: (threshold min: listSize) do: [:index |
		maxWidth := maxWidth max: (self widthToDisplayItem: (self getListItem: index))].

	^ maxWidth

]

{ #category : #accessing }
LazyListMorph >> multiSelectionColor [

	^ self valueOfProperty: #multiSelectionColor ifAbsent: [self selectionColor asColor]
]

{ #category : #accessing }
LazyListMorph >> multiSelectionColor: aColor [

	self setProperty: #multiSelectionColor toValue: aColor.
]

{ #category : #'list management' }
LazyListMorph >> preSelectedRow: index [
	" Show the user which row is about to become selected, thus providing feedback if there is a delay between the selection gesture and the actual selection of the row. "
	
	preSelectedRow := index.
	self changed.
]

{ #category : #accessing }
LazyListMorph >> preSelectionColor [
	^ self valueOfProperty: #preSelectionColor ifAbsent: [Color gray]
]

{ #category : #'list management' }
LazyListMorph >> rowAtLocation: aPoint [
	"return the number of the row at aPoint"
	| y |
	y := aPoint y.
	y < self top ifTrue: [ ^ 1 min: self getListSize ].
	^((y - self top // self rowHeight) + 1) min: self getListSize max: 0
]

{ #category : #updating }
LazyListMorph >> rowChanged: anInteger [

	self invalidRect: (self drawBoundsForRow: anInteger).
]

{ #category : #updating }
LazyListMorph >> rowChanged: oneRow with: anotherRow [
	"Speed up drawing. Merge consecutive rows because the default damage recorder might not merge these rectangles."

	oneRow ifNil: [anotherRow ifNil: [^ self] ifNotNil: [^ self rowChanged: anotherRow]].
	anotherRow ifNil: [^ self rowChanged: oneRow].
	
	(oneRow - anotherRow) abs = 1
		ifTrue: [
			self invalidRect: ((self drawBoundsForRow: oneRow)
									quickMerge: (self drawBoundsForRow: anotherRow))]
		ifFalse: [
			self invalidRect: (self drawBoundsForRow: oneRow).
			self invalidRect: (self drawBoundsForRow: anotherRow)].
]

{ #category : #layout }
LazyListMorph >> rowHeight [

	^ font height + self cellInset top + self cellInset bottom
]

{ #category : #'list management' }
LazyListMorph >> selectRow: index [
	" Select the index-th row. Clear the pre selection highlight. "
	selectedRows add: index.
	preSelectedRow := nil.
	self changed.
]

{ #category : #'list management' }
LazyListMorph >> selectedRow [
	"return the currently selected row, or nil if none is selected"
	^selectedRow
]

{ #category : #'list management' }
LazyListMorph >> selectedRow: index [
	" Select the index-th row. Clear the pre selection highlight. If nil, remove the current selection. "

	self rowChanged: selectedRow with: index.
	selectedRow := index.
	preSelectedRow := nil.
]

{ #category : #'list management' }
LazyListMorph >> selection [

	^ self selectedRow ifNotNil: [:row |
		(row between: 1 and: self getListSize)
			ifTrue: [self item: row] 
			ifFalse: [nil]]
]

{ #category : #accessing }
LazyListMorph >> selectionColor [
	^ self valueOfProperty: #selectionColor ifAbsent: [Color blue]
]

{ #category : #accessing }
LazyListMorph >> selectionColor: aColor [

	| cc fill |
	cc := aColor.

	MenuMorph gradientMenu
		ifFalse: [fill := SolidFillStyle color: cc]
		ifTrue: [
			fill := GradientFillStyle ramp: { 
				0.0 -> cc twiceLighter. 
				1 -> cc twiceDarker }].

	self setProperty: #selectionColor toValue: fill
]

{ #category : #accessing }
LazyListMorph >> selectionTextColor [
	^ self valueOfProperty: #selectionTextColor ifAbsent: [Color white]
]

{ #category : #accessing }
LazyListMorph >> showFilter [

	^ (showFilter ~~ false and: [listSource filterableList])
]

{ #category : #accessing }
LazyListMorph >> showFilter: aBoolean [

	showFilter = aBoolean ifTrue: [^ self].
	showFilter := aBoolean.
	self changed.
]

{ #category : #layout }
LazyListMorph >> submorphBoundsForShrinkWrap [
	"Since we have no submorphs, we calculate those bounds here. Skip width calculation if we do not #shrinkWrap."

	^ self hResizing == #shrinkWrap
		ifTrue: [(self topLeft extent: self maxWidth @ self maxHeight) insetBy: self cellInset]
		ifFalse: [self topLeft extent: 0 @ (self maxHeight - self cellInset top - self cellInset bottom)]
]

{ #category : #drawing }
LazyListMorph >> topVisibleRowForCanvas: aCanvas [
        "return the top visible row in aCanvas's clip rectangle"
        ^self rowAtLocation: aCanvas clipRect topLeft.

]

{ #category : #'list management' }
LazyListMorph >> unselectRow: index [
	"unselect the index-th row"
	selectedRows remove: index ifAbsent: [].
	preSelectedRow := nil.
	self changed.
]

{ #category : #accessing }
LazyListMorph >> userString [
	"Do I have a text string to be searched on?"

	^ String streamContents: [:strm |
		1 to: self getListSize do: [:i |
			"must use asStringOrText because that's what the drawing uses, too"
			strm nextPutAll: (self getListItem: i) asStringOrText; cr]]
]

{ #category : #layout }
LazyListMorph >> widthToDisplayItem: item [ 

	| labelWidth iconWidth leftMargin rightMargin |
	labelWidth := self font widthOfStringOrText: item asStringOrText.
	iconWidth := self listSource canHaveIcons ifTrue: [self iconExtent x] ifFalse: [0].
	leftMargin := self cellInset left.
	rightMargin := self cellInset right.
	^ leftMargin + iconWidth + labelWidth + rightMargin
]
