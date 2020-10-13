"
This morph can be used to show a list having multiple columns,  The columns are self width sized to make the largest entry in each list fit.  In some cases the pane may then be too narrow.

Use it like a regular PluggableListMorph except pass in an array of lists instead of a single list.

There are base assumptions made here that each list in the array of lists is the same size.

Also, the highlight color for the selection is easy to modify in the #highlightSelection method.  I used blue
when testing just to see it work.
"
Class {
	#name : #PluggableMultiColumnListMorph,
	#superclass : #PluggableListMorph,
	#instVars : [
		'listMorphs'
	],
	#category : #'Morphic-Pluggable Widgets'
}

{ #category : #layout }
PluggableMultiColumnListMorph >> cellInsetAtColumn: columnIndex [
	
	^ self cellInsetForColumns
		at: columnIndex
		ifAbsent: [
			"Repeat the inset of the last column or choose the default."
			self cellInsetForColumns
				ifEmpty: [3@0]
				ifNotEmpty: [:paddings | paddings last]]
]

{ #category : #layout }
PluggableMultiColumnListMorph >> cellInsetForColumns [
	
	^ self valueOfProperty: #cellInsetForColumns ifAbsent: [#()]
]

{ #category : #layout }
PluggableMultiColumnListMorph >> cellInsetForColumns: someSymbols [
	"Cache the preferred inset of items per column because column count can vary."
	
	self setProperty: #cellInsetForColumns toValue: someSymbols.
]

{ #category : #layout }
PluggableMultiColumnListMorph >> cellPositioningAtColumn: columnIndex [
	
	^ self cellPositioningForColumns
		at: columnIndex
		ifAbsent: [
			"Repeat the alignment of the last column or choose the default."
			self cellPositioningForColumns
				ifEmpty: [#leftCenter]
				ifNotEmpty: [:alignments | alignments last]]
]

{ #category : #layout }
PluggableMultiColumnListMorph >> cellPositioningForColumns [
	
	^ self valueOfProperty: #cellPositioningForColumns ifAbsent: [#()]
]

{ #category : #layout }
PluggableMultiColumnListMorph >> cellPositioningForColumns: someSymbols [
	"Cache the preferred positioning of items per column because column count can vary."
	
	self setProperty: #cellPositioningForColumns toValue: someSymbols.
]

{ #category : #geometry }
PluggableMultiColumnListMorph >> charactersOccluded [
	"Not meaningful in multi-column lists, since they should truncate their column widths according to how much space is needed vs. available to show a bit of each."
	^ 0
]

{ #category : #accessing }
PluggableMultiColumnListMorph >> columnCount [
	"Even an empty column is a column."
	
	^ self getFullList size max: 1
]

{ #category : #filtering }
PluggableMultiColumnListMorph >> filterColumnColor [

	^ (Color gray: 0.85) alpha: 0.4
]

{ #category : #filtering }
PluggableMultiColumnListMorph >> filterColumnIndex [
	"Which column to apply the filter to?"

	| i |
	i := 0.
	self listMorphs
		detect: [:m | i := i + 1. m backgroundColor notNil]
		ifNone: [i := 0].
	^ i
]

{ #category : #filtering }
PluggableMultiColumnListMorph >> filterList: columns columnIndex: index matching: aPattern [
	"A matching row has a match in at least one column."
	
	| frontMatching substringMatching rowCount columnCount tmp |
	aPattern ifEmpty: [^ columns].
	columns ifEmpty: [^ columns].
	
	rowCount := columns first size.
	rowCount = 0 ifTrue: [^ columns].
	columnCount := columns size.
	
	frontMatching := Array new: columnCount.
	1 to: columnCount do: [:c | frontMatching at: c put: OrderedCollection new].
	substringMatching := Array new: columnCount.
	1 to: columnCount do: [:c | substringMatching at: c put: OrderedCollection new].
	
	modelToView := Dictionary new.
	viewToModel := Dictionary new.
	tmp := OrderedCollection new.
	
	1 to: rowCount do: [:rowIndex |
		| match foundPos |
		match := false.
		foundPos := self
						filterListItem: ((columns at: index) at: rowIndex)
						matching: aPattern.
		foundPos = 1
			ifTrue: [
				1 to: columnCount do: [:colIndex |
					(frontMatching at: colIndex) add: ((columns at: colIndex) at: rowIndex)].
				modelToView at: rowIndex put: frontMatching first size.
				viewToModel at: frontMatching first size put: rowIndex]
			ifFalse: [foundPos > 1 ifTrue: [
				1 to: columnCount do: [:colIndex |
					(substringMatching at: colIndex) add: ((columns at: colIndex) at: rowIndex)].
				tmp add: rowIndex; add: substringMatching first size]]
	].
	
	tmp pairsDo: [:modelIndex :viewIndex |
		modelToView at: modelIndex put: viewIndex + frontMatching first size.
		viewToModel at: viewIndex + frontMatching first size put: modelIndex].

	^ (1 to: columnCount) collect: [:colIndex |
		(frontMatching at: colIndex), (substringMatching at: colIndex)]














]

{ #category : #filtering }
PluggableMultiColumnListMorph >> filterList: columns matching: aPattern [
	"A matching row has a match in at least one column."
	
	| frontMatching substringMatching rowCount columnCount tmp |
	aPattern ifEmpty: [^ columns].
	columns ifEmpty: [^ columns].
	
	"Enable column-specific filtering."
	self filterColumnIndex in: [:index |
		index > 0 ifTrue: [^ self filterList: columns columnIndex: index matching: aPattern]].
	
	rowCount := columns first size.
	rowCount = 0 ifTrue: [^ columns].
	columnCount := columns size.
	
	frontMatching := Array new: columnCount.
	1 to: columnCount do: [:c | frontMatching at: c put: OrderedCollection new].
	substringMatching := Array new: columnCount.
	1 to: columnCount do: [:c | substringMatching at: c put: OrderedCollection new].
	
	modelToView := Dictionary new.
	viewToModel := Dictionary new.
	tmp := OrderedCollection new.
	
	1 to: rowCount do: [:rowIndex |
		| match foundPos |
		match := false.
		foundPos := 0.
		1 to: columnCount do: [:colIndex |
			match := match or: [(foundPos := (self
									filterListItem: ((columns at: colIndex) at: rowIndex)
									matching: aPattern)+colIndex) > colIndex]].
		match & (foundPos = 2) "means front match in first column"
			ifTrue: [
				1 to: columnCount do: [:colIndex |
					(frontMatching at: colIndex) add: ((columns at: colIndex) at: rowIndex)].
				modelToView at: rowIndex put: frontMatching first size.
				viewToModel at: frontMatching first size put: rowIndex]
			ifFalse: [match ifTrue: [
				1 to: columnCount do: [:colIndex |
					(substringMatching at: colIndex) add: ((columns at: colIndex) at: rowIndex)].
				tmp add: rowIndex; add: substringMatching first size]]
	].
	
	tmp pairsDo: [:modelIndex :viewIndex |
		modelToView at: modelIndex put: viewIndex + frontMatching first size.
		viewToModel at: viewIndex + frontMatching first size put: modelIndex].

	^ (1 to: columnCount) collect: [:colIndex |
		(frontMatching at: colIndex), (substringMatching at: colIndex)]














]

{ #category : #initialization }
PluggableMultiColumnListMorph >> font: aFontOrNil [

	listMorphs do: [:lm | lm font: aFontOrNil].
	super font: aFontOrNil.
]

{ #category : #'list morph callbacks' }
PluggableMultiColumnListMorph >> fullListSize [
	"return the current number of items in the displayed list"
	
	^ self getFullList
		ifEmpty: [0]
		ifNotEmpty: [:columns | columns first size]
]

{ #category : #filtering }
PluggableMultiColumnListMorph >> getFilteredList [
	"Apply the current filter to the list. Maybe shorten the filter term if there are no matches."
	
	| fullList filteredList |
	fullList := self getFullList.
		
	self hasFilter ifFalse: [^ fullList].
	fullList ifEmpty: [^ fullList].
	fullList first ifEmpty: [^ fullList].
	
	filteredList := self filterList: fullList matching: lastKeystrokes.
	
	(filteredList first isEmpty not or: [ self allowEmptyFilterResult ])
		ifFalse: 
			[ "Remove the last character and try filtering again."
			lastKeystrokes := lastKeystrokes allButLast: 1.
			^ self
				 flash;
				 getFilteredList ].
			
	^ filteredList
]

{ #category : #'model access - cached' }
PluggableMultiColumnListMorph >> getFullList [
	"The full list arranges all items column-first."
	
	fullList ifNotNil: [^ fullList].
	
	fullList := getListSelector
		ifNotNil: [:selector | "A) Fetch the list column-first from the model."
			model perform: selector]
		ifNil: [
			(getListSizeSelector notNil and: [getListElementSelector notNil])
				ifFalse: ["X) We cannot fetch the list from the model. Make it empty."
					#()]
				ifTrue: [ "B) Fetch the list row-first from the model:" 
					| listSize |
					listSize := self getListSize.
					listSize = 0 ifTrue: [#() "Empty list"] ifFalse: [
						| firstRow columns |
						firstRow := self getListItem: 1.
						columns := Array new: firstRow size.
						1 to: columns size do: [:columnIndex |
							"Initialize all columns."
							columns at: columnIndex put: (Array new: listSize).
							"Put the first row in."
							(columns at: columnIndex) at: 1 put: (firstRow at: columnIndex)].
						"Put all other rows in."
						2 to: listSize do: [:rowIndex | (self getListItem: rowIndex)
							doWithIndex: [:item :columnIndex |
								(columns at: columnIndex) at: rowIndex put: item]].
						columns]]].

	self updateColumns.
	
	^ fullList
]

{ #category : #'model access' }
PluggableMultiColumnListMorph >> getListItem: modelIndex [
	"Return a row full of items."
	
	^ getListElementSelector
		ifNotNil: [:sel | model perform: sel with: modelIndex ]
		ifNil: [self getFullList collect: [:column | column at: modelIndex]]
]

{ #category : #layout }
PluggableMultiColumnListMorph >> hResizingAtColumn: columnIndex [
	
	^ self hResizingForColumns
		at: columnIndex
		ifAbsent: [
			"Repeat the resizing strategy of the last column or choose the default."
			self hResizingForColumns
				ifEmpty: [#spaceFill]
				ifNotEmpty: [:strategies | strategies last]]
]

{ #category : #layout }
PluggableMultiColumnListMorph >> hResizingForColumns [
	
	^ self valueOfProperty: #hResizingForColumns ifAbsent: [#()]
]

{ #category : #layout }
PluggableMultiColumnListMorph >> hResizingForColumns: someSymbols [
	"Cache the preferred horizontal resizing for each column because column count can vary."
	
	self setProperty: #hResizingForColumns toValue: someSymbols.
]

{ #category : #accessing }
PluggableMultiColumnListMorph >> hScrollBarPolicy: aSymbol [
	"The lazy list morph will never wrap its rows if they do not fit. Instead, they are just clipped. So, #spaceFill is fine if the horizontal scroll bar should never be visible."
	
	self checkScrollBarPolicy: aSymbol.
	
	aSymbol ~= #never
		ifTrue: [listMorphs do: [:lm | lm hResizing: #shrinkWrap]]
		ifFalse: [listMorphs do: [:lm | lm hResizing: #spaceFill]].
				
	^ super hScrollBarPolicy: aSymbol
]

{ #category : #filtering }
PluggableMultiColumnListMorph >> highlightNextColumn [

	| i currentColumn nextColumn |
	i := self filterColumnIndex.
	i = 0 ifTrue: [self listMorphs do: [:m | m showFilter: false]].

	currentColumn := self listMorphs at: (i max: 1).
	nextColumn := self listMorphs at: i \\ self listMorphs size + 1.
	
	currentColumn
		showFilter: false;
		backgroundColor: nil.
		
	nextColumn
		showFilter: true;
		backgroundColor: self filterColumnColor.
]

{ #category : #filtering }
PluggableMultiColumnListMorph >> highlightNoColumn [

	self listMorphs do: [:m |
		m showFilter: true; backgroundColor: nil].
]

{ #category : #accessing }
PluggableMultiColumnListMorph >> hoverRow: viewIndex [

	hoverRow = viewIndex ifTrue: [^ self].
	listMorphs do: [:listMorph |
		listMorph rowChanged: hoverRow with: viewIndex].
	super hoverRow: viewIndex.
]

{ #category : #'list morph callbacks' }
PluggableMultiColumnListMorph >> iconAt: rowIndex [

	^ self iconAt: rowIndex column: 1
]

{ #category : #'list morph callbacks' }
PluggableMultiColumnListMorph >> iconAt: rowIndex column: columnIndex [

	getIconSelector ifNil: [^ nil].

	getIconSelector numArgs = 1 ifTrue: [
		"For unspecific icon selectors only icons for the first column."
		^ columnIndex = 1
			ifTrue: [model perform: getIconSelector with: rowIndex]
			ifFalse: [nil]].
	
	^ model
		perform: getIconSelector
		with: (self modelIndexFor: rowIndex)
		with: columnIndex
]

{ #category : #initialization }
PluggableMultiColumnListMorph >> initialize [

	listMorphs := #().
	super initialize.

	self scroller
		listDirection: #leftToRight;
		cellPositioning: #topLeft.
		
	listMorphs := OrderedCollection with: listMorph.
]

{ #category : #'list morph callbacks' }
PluggableMultiColumnListMorph >> itemAt: rowIndex [

	^ self itemAt: rowIndex column: 1
]

{ #category : #'list morph callbacks' }
PluggableMultiColumnListMorph >> itemAt: rowIndex column: columnIndex [
	
	^ (self getList at: columnIndex) at: rowIndex
]

{ #category : #accessing }
PluggableMultiColumnListMorph >> listMorphs [

	^ listMorphs
]

{ #category : #'list morph callbacks' }
PluggableMultiColumnListMorph >> listSize [
	
	^ self visibleRowCount
]

{ #category : #filtering }
PluggableMultiColumnListMorph >> removeFilter [

	self highlightNoColumn.
	super removeFilter.

]

{ #category : #selection }
PluggableMultiColumnListMorph >> rowAboutToBecomeSelected: anInteger [

	listMorphs do: [:listMorph | listMorph preSelectedRow: anInteger].
	super rowAboutToBecomeSelected: anInteger.
]

{ #category : #'accessing - items' }
PluggableMultiColumnListMorph >> rowAtLocation: aPoint [
	"Return the row at the given point or 0 if outside"

	| pointInListMorphCoords rowIndex |
	pointInListMorphCoords := (self scroller transformFrom: self) transform: aPoint.

	listMorphs do: [:listMorph |
		rowIndex := listMorph rowAtLocation: pointInListMorphCoords.
		rowIndex > 0 ifTrue: [^ rowIndex]].

	^ 0

]

{ #category : #accessing }
PluggableMultiColumnListMorph >> rowCount [
	
	^ self getFullList
		ifEmpty: [0]
		ifNotEmpty: [:columns | columns first size]
]

{ #category : #selection }
PluggableMultiColumnListMorph >> selection [ 
	"Collect the selected row from all columns as array."
		
	^ self getList collect: [:column |
		column
			at: self selectionIndex
			ifAbsent: [nil]]
]

{ #category : #selection }
PluggableMultiColumnListMorph >> selection: someObjects [
	
	| found |
	someObjects size ~= self columnCount ifTrue: [^ self].
	
	1 to: self listSize do: [:row |
		found := true.
		self getList doWithIndex: [:items :column |
			found := found and: [(items at: row) = (someObjects at: column)]].
		found ifTrue: [^ self selectionIndex: row]].
]

{ #category : #selection }
PluggableMultiColumnListMorph >> selectionIndex: viewIndex [

	listMorphs do: [:listMorph | listMorph selectedRow: (viewIndex min: self listSize)].	
	super selectionIndex: viewIndex.
]

{ #category : #initialization }
PluggableMultiColumnListMorph >> setListParameters [

	listMorphs ifEmpty: [^ super setListParameters].
	
	listMorphs do: [:lm | listMorph := lm. super setListParameters].
	listMorph := listMorphs first.
]

{ #category : #layout }
PluggableMultiColumnListMorph >> spaceFillWeightAtColumn: columnIndex [
	
	^ self spaceFillWeightForColumns
		at: columnIndex
		ifAbsent: [
			"Repeat the weight of the last column or choose the default."
			self spaceFillWeightForColumns
				ifEmpty: [1]
				ifNotEmpty: [:weights | weights last]]
]

{ #category : #layout }
PluggableMultiColumnListMorph >> spaceFillWeightForColumns [
	
	^ self valueOfProperty: #spaceFillWeightForColumns ifAbsent: [#()]
]

{ #category : #layout }
PluggableMultiColumnListMorph >> spaceFillWeightForColumns: someSymbols [
	"Cache the preferred space-fill weight for each column because column count can vary."
	
	self setProperty: #spaceFillWeightForColumns toValue: someSymbols.
]

{ #category : #filtering }
PluggableMultiColumnListMorph >> specialKeyPressed: asciiValue [
	"Use the [Tab] key to filter specific columns."
	
	^ asciiValue = Character tab asciiValue
		ifTrue: [self highlightNextColumn]
		ifFalse: [super specialKeyPressed: asciiValue].
]

{ #category : #initialization }
PluggableMultiColumnListMorph >> textColor: aColor [

	listMorphs do: [:listMorph | listMorph color: aColor].
	super textColor: aColor.
]

{ #category : #updating }
PluggableMultiColumnListMorph >> updateColumns [
	"The number of columns must match the number of list morphs."
	
	| columnsChanged |
	columnsChanged := self columnCount ~= listMorphs size.
	
	[self columnCount < listMorphs size]
		whileTrue: [
			listMorphs removeLast delete].
	
	[self columnCount > listMorphs size]
		whileTrue: [
			listMorphs addLast: self createListMorph.
			self scroller addMorphBack: listMorphs last].
	
	listMorphs doWithIndex: [:listMorph :columnIndex |
		listMorph
			columnIndex: columnIndex;
			color: self textColor;
			cellPositioning: (self cellPositioningAtColumn: columnIndex);
			cellInset: (self cellInsetAtColumn: columnIndex);
			hResizing: (self hResizingAtColumn: columnIndex);
			spaceFillWeight: (self spaceFillWeightAtColumn: columnIndex)].
		
	columnsChanged ifTrue: [self setListParameters].
]

{ #category : #updating }
PluggableMultiColumnListMorph >> updateListMorph [
	"We have to notify all columns."
	
	listMorphs do: #listChanged.
]

{ #category : #'debug and other' }
PluggableMultiColumnListMorph >> userString [
	"Do I have a text string to be searched on?"

	^ String streamContents: [:strm |
		1 to: self rowCount do: [:row |
			1 to: self columnCount do: [:col |
				strm nextPutAll: ((self getFullList at: col) at: row) asStringOrText; tab].
			strm cr]]
]

{ #category : #updating }
PluggableMultiColumnListMorph >> verifyContents [
	"Verify the contents of the receiver, reconstituting if necessary.  Called whenever window is reactivated, to react to possible structural changes.  Also called periodically in morphic if the smartUpdating preference is true"

	| changed currentList modelList modelIndex |
	self flag: #performance. "mt: We do have changed/update. Why can't the tools communicate through an appropriate notifier such as the SystemChangeNotifier?"

	"1) Is the list still up to date?"
	currentList := fullList. fullList := nil.
	modelList := self getFullList.
	changed := false.
	modelList doWithIndex: [:column :index |
		changed := changed or: [(currentList at: index) ~= column]].
	changed ifFalse: [^ self].
	self updateList: modelList.
	
	"2) Is the selection still up to date?"
	modelIndex := self getCurrentSelectionIndex.
	(self modelIndexFor: self selectionIndex) = modelIndex ifTrue: [^ self].
	self updateListSelection: modelIndex.
]

{ #category : #accessing }
PluggableMultiColumnListMorph >> visibleRowCount [
	"Take the size of the first column. We treat all columns equally."

	^ self getList
		ifEmpty: [0]
		ifNotEmpty: [:columns | columns first size]
]
