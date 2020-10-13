"
An IndentingListItemMorph is a StringMorph that draws itself with an optional toggle at its left, as part of the display of the SimpleHierarchicalListMorph.

It will also display lines around the toggle if the #showLinesInHierarchyViews Preference is set.

Instance variables:

indentLevel <SmallInteger> 	the indent level, from 0 at the root and increasing by 1 at each level of the hierarchy.

isExpanded <Boolean>		true if this item is expanded (showing its children)

complexContents <ListItemWrapper>	an adapter wrapping my represented item that can answer its children, etc.
	
firstChild <IndentingListItemMorph|nil>	my first child, or nil if none
	
container <SimpleHierarchicalListMorph>	my container
	
nextSibling <IndentingListItemMorph|nil>	the next item in the linked list of siblings, or nil if none.

Contributed by Bob Arning as part of the ObjectExplorer package.
Don't blame him if it's not perfect.  We wanted to get it out for people to play with.
"
Class {
	#name : #IndentingListItemMorph,
	#superclass : #StringMorph,
	#instVars : [
		'indentLevel',
		'isExpanded',
		'complexContents',
		'firstChild',
		'container',
		'nextSibling',
		'icon',
		'backgroundColor'
	],
	#category : #'Morphic-Explorer'
}

{ #category : #defaults }
IndentingListItemMorph class >> iconColumnIndex [
	"Hack. For now, say who gets the icon here. We need a generic solution for icons in multi-column trees. PluggableTreeMorph does something in that direction."
	^ 2
]

{ #category : #'drag and drop' }
IndentingListItemMorph >> acceptDroppingMorph: toDrop event: evt [
	complexContents acceptDroppingObject: toDrop complexContents.
	toDrop delete.
	self highlightForDrop: false.
]

{ #category : #'container protocol - private' }
IndentingListItemMorph >> addChildrenForList: hostList addingTo: morphList withExpandedItems: expandedItems [

	firstChild ifNotNil: [
		firstChild withSiblingsDo: [ :aNode | aNode delete].
	].
	firstChild := nil.
	complexContents hasContents ifFalse: [^self].
	firstChild := hostList 
		addMorphsTo: morphList
		from: complexContents contents 
		allowSorting: true
		withExpandedItems: expandedItems
		atLevel: indentLevel + 1.
	
]

{ #category : #filtering }
IndentingListItemMorph >> applyFilter: filter [

	self
		applyFilter: filter
		depthOffset: self indentLevel.
]

{ #category : #filtering }
IndentingListItemMorph >> applyFilter: filter depthOffset: offset [

	| selfMatch childMatch |
	self isExpanded ifTrue: [self toggleExpandedState].
	
	selfMatch := self matches: filter.
	childMatch := self matchesAnyChild: filter depthOffset: offset.
	
	selfMatch | childMatch ifFalse: [^ self hide].
	
	selfMatch ifTrue: [
		self backgroundColor: ((Color gray: 0.85) alpha: 0.5)].
	childMatch ifTrue: [
		self toggleExpandedState.
		self childrenDo: [:child | child applyFilter: filter depthOffset: offset]].
]

{ #category : #accessing }
IndentingListItemMorph >> backgroundColor [
	^ backgroundColor
]

{ #category : #accessing }
IndentingListItemMorph >> backgroundColor: aColor [
	backgroundColor := aColor.
	self changed.
]

{ #category : #accessing }
IndentingListItemMorph >> balloonText [

	^complexContents balloonText ifNil: [super balloonText]
]

{ #category : #'halos and balloon help' }
IndentingListItemMorph >> boundsForBalloon [

	"some morphs have bounds that are way too big"
	container ifNil: [^super boundsForBalloon].
	^self boundsInWorld intersect: container boundsInWorld
]

{ #category : #testing }
IndentingListItemMorph >> canExpand [

	^complexContents hasContents
]

{ #category : #private }
IndentingListItemMorph >> charactersOccluded [
	"Answer the number of characters occluded in my #visibleList by my right edge."
	| listIndex leftEdgeOfRightmostColumn eachString indexOfLastVisible iconWidth totalWidth |
	listIndex := 0.
	leftEdgeOfRightmostColumn := container columns
		ifNil: [ 0 ]
		ifNotNil:
			[ : cols | (1 to: cols size - 1)
				inject: 0
				into:
					[ : sum : each | sum + (self widthOfColumn: each) ] ].
	eachString := container columns
		ifNil: [ self complexContents asString ]
		ifNotNil:
			[ : cols | self contentsAtColumn: container columns size ].
	iconWidth := self icon
		ifNil: [ 0 ]
		ifNotNil:
			[ : icon | icon width + 2 ].
	totalWidth := self toggleBounds right.
	indexOfLastVisible := ((1 to: eachString size)
		detect:
			[ : stringIndex | (totalWidth:=totalWidth+(self fontToUse widthOf: (eachString at: stringIndex))) >
				(container width -
					(container vIsScrollbarShowing
						ifTrue: [ container vScrollBar width ]
						ifFalse: [ 0 ]) - iconWidth - leftEdgeOfRightmostColumn) ]
		ifNone: [ eachString size + 1 ]) - 1.
	^ eachString size - indexOfLastVisible
]

{ #category : #accessing }
IndentingListItemMorph >> children [
	| children |
	children := OrderedCollection new.
	self childrenDo: [:each | children add: each].
	^children
]

{ #category : #enumeration }
IndentingListItemMorph >> childrenDo: aBlock [

	firstChild ifNotNil: [
		firstChild withSiblingsDo: aBlock ]
]

{ #category : #'container protocol' }
IndentingListItemMorph >> collapse [

	self isExpanded ifFalse: [^ self].
	
	self isExpanded: false.
	
	firstChild ifNotNil: [:collapsingNode |
	 	| toDelete |
		toDelete := OrderedCollection new.
		collapsingNode withSiblingsDo: [:aNode | aNode recursiveAddTo: toDelete].
		container noteRemovalOfAll: toDelete].
	
	self changed.
]

{ #category : #drawing }
IndentingListItemMorph >> colorToUse [

	^ (self valueOfProperty: #wasRefreshed ifAbsent: [false])
		ifTrue: [complexContents highlightColor ifNil: [self highlightTextColor]]
		ifFalse: [
			self isSelected ifTrue: [^ self selectionTextColor].			
			complexContents preferredColor ifNil: [self color]]
]

{ #category : #accessing }
IndentingListItemMorph >> complexContents [

	^complexContents
]

{ #category : #'accessing - columns' }
IndentingListItemMorph >> contentsAtColumn: index [
	"Split string contents at <tab> character."
	
	| column scanner cell |
	column := 0.
	scanner := ReadStream on: contents asString.
	[(cell := scanner upTo: Character tab) notEmpty]
		whileTrue: [column := column + 1. column = index ifTrue: [^ cell]].
	^ ''
]

{ #category : #'accessing - columns' }
IndentingListItemMorph >> contentsSplitByColumns [
	"Split string contents at <tab> character."
	
	| result scanner cell |
	result := OrderedCollection new.
	scanner := ReadStream on: contents asString.
	[(cell := scanner upTo: Character tab) notEmpty]
		whileTrue: [result add: cell].
	^ result
]

{ #category : #initialization }
IndentingListItemMorph >> defaultColor [

	^complexContents
		ifNil: [ super defaultColor ]
		ifNotNil: [ complexContents preferredColor ]
]

{ #category : #drawing }
IndentingListItemMorph >> drawHoverOn: aCanvas [ 

	aCanvas
		fillRectangle: self bounds
		color: self hoverColor.
]

{ #category : #drawing }
IndentingListItemMorph >> drawLineToggleToTextOn: aCanvas lineColor: lineColor hasToggle: hasToggle [
	"If I am not the only item in my container, draw the line between:
		- my toggle (if any) or my left edge (if no toggle)
		- and my text left edge"

	| myBounds myCenter hLineY hLineLeft |
	self isSoleItem ifTrue: [ ^self ].
	myBounds := self toggleBounds.
	myCenter := myBounds center.
	hLineY := myCenter y.
	hLineLeft := myCenter x - 1.
	"Draw line from toggle to text"
	aCanvas
		line: hLineLeft @ hLineY
		to: myBounds right + 0 @ hLineY
		width: 1
		color: lineColor
]

{ #category : #drawing }
IndentingListItemMorph >> drawLinesOn: aCanvas lineColor: lineColor indentThreshold: aNumber [
	self indentLevel > aNumber ifTrue: [
		| hasToggle |
		hasToggle := self hasToggle.
		"Draw line from toggle to text"
		self drawLineToggleToTextOn: aCanvas lineColor: lineColor hasToggle: hasToggle.

		"Draw the line from my toggle to the nextSibling's toggle"
		self nextVisibleSibling ifNotNil: [ self drawLinesToNextSiblingOn: aCanvas lineColor: lineColor hasToggle: hasToggle ]].

	"If I have children and am expanded, draw a line to my first child"
	((self firstVisibleChild notNil
		and: [self isExpanded])
		and: [self firstVisibleChild indentLevel > aNumber])
			ifTrue: [ self drawLinesToFirstChildOn: aCanvas lineColor: lineColor ]
]

{ #category : #drawing }
IndentingListItemMorph >> drawLinesToFirstChildOn: aCanvas lineColor: lineColor [ 
	"Draw line from me to next sibling"

	| child vLineX vLineTop vLineBottom childBounds childCenter |
	child := self firstVisibleChild.
	childBounds := child toggleBounds.
	childCenter := childBounds center.
	vLineX := childCenter x - 1.
	vLineTop := bounds bottom.
	child hasToggle
		ifTrue: [vLineBottom := childCenter y - 7]
		ifFalse: [vLineBottom := childCenter y].
	aCanvas
		line: vLineX @ vLineTop
		to: vLineX @ vLineBottom
		width: 1
		color: lineColor
]

{ #category : #drawing }
IndentingListItemMorph >> drawLinesToNextSiblingOn: aCanvas lineColor: lineColor hasToggle: hasToggle [
	| myBounds nextSibBounds vLineX myCenter vLineTop vLineBottom |
	myBounds := self toggleBounds.
	nextSibBounds := self nextVisibleSibling toggleBounds.
	myCenter := myBounds center.
	vLineX := myCenter x - 1.
	vLineTop := myCenter y.
	vLineBottom := nextSibBounds center y.
	"Draw line from me to next sibling"
	aCanvas
		line: vLineX @ vLineTop
		to: vLineX @ vLineBottom
		width: 1
		color: lineColor
]

{ #category : #drawing }
IndentingListItemMorph >> drawOn: aCanvas [
	
	| tRect sRect columnScanner columnLeft |
	self backgroundColor ifNotNil: [:c |
		aCanvas fillRectangle: self innerBounds color: c].

	tRect := self toggleRectangle.	
	self drawToggleOn: aCanvas in: tRect.

	sRect := bounds withLeft: tRect right + self hMargin.
	sRect := sRect top: sRect top + sRect bottom - self fontToUse height // 2.	
	
	(container columns isNil or: [(contents asString indexOf: Character tab) = 0]) ifTrue: [
		icon ifNotNil: [
			aCanvas
				translucentImage: icon
				at: sRect left @ (self top + (self height - icon height // 2)).
			sRect := sRect left: sRect left + icon width + 2.
		].
		
		aCanvas drawString: contents asString in: sRect font: self fontToUse color: self colorToUse.
	
	] ifFalse: [
		columnLeft := sRect left.
		columnScanner := ReadStream on: contents asString.
		container columns withIndexDo: [ :widthSpec :column | | columnRect columnData columnWidth |
			"Draw icon."
			column = self class iconColumnIndex ifTrue: [
				icon ifNotNil: [
					aCanvas
						translucentImage: icon
						at: columnLeft @ (self top + (self height - icon height // 2)).
					columnLeft := columnLeft + icon width + 2]].

			columnWidth := self widthOfColumn: column.
			columnRect := columnLeft @ sRect top extent: columnWidth @ sRect height.
			columnData := columnScanner upTo: Character tab.
			
			"Draw string."
			columnData ifNotEmpty: [
				aCanvas drawString: columnData in: columnRect font: self fontToUse color: self colorToUse].

			"Compute next column offset."			
			columnLeft := columnRect right + 5.
			column = 1 ifTrue: [columnLeft := columnLeft - tRect right + self left].
			
		].
	]
]

{ #category : #drawing }
IndentingListItemMorph >> drawSelectionOn: aCanvas [ 

	| fill |
	fill := self selectionColor isColor
		ifTrue: [SolidFillStyle color: self selectionColor]
		ifFalse: [self selectionColor].
	fill isGradientFill ifTrue: [
		fill origin: self topLeft.
		fill direction: 0@ self height].

	aCanvas
		fillRectangle: self bounds
		fillStyle: fill.
]

{ #category : #drawing }
IndentingListItemMorph >> drawToggleOn: aCanvas in: aRectangle [

	| aForm centeringOffset |
	complexContents hasContents ifFalse: [^self].
	aForm := isExpanded 
		ifTrue: [container expandedForm]
		ifFalse: [container notExpandedForm].
	centeringOffset := ((aRectangle height - aForm extent y) / 2.0) rounded.
	^aCanvas 
		paintImage: aForm 
		at: (aRectangle topLeft translateBy: 0 @ centeringOffset).

]

{ #category : #'container protocol' }
IndentingListItemMorph >> expand [

 	| newChildren c |

	(self isExpanded or: [self canExpand not])
		ifTrue: [^ self].
	
	(c := self getChildren) ifEmpty: [
		"Due to the guessing in #canExpand, it may still fail here."
		^ self].

	self isExpanded: true.

	newChildren := container 
		addSubmorphsAfter: self 
		fromCollection: c 
		allowSorting: true.

	firstChild := newChildren first.
]

{ #category : #accessing }
IndentingListItemMorph >> filterColor [

	^ self valueOfProperty: #filterColor ifAbsent: [Color yellow]
]

{ #category : #accessing }
IndentingListItemMorph >> filterColor: aColor [

	| cc fill |
	cc := aColor.

	MenuMorph gradientMenu
		ifFalse: [fill := SolidFillStyle color: cc]
		ifTrue: [
			fill := GradientFillStyle ramp: { 
				0.0 -> cc twiceLighter. 
				1 -> cc twiceDarker }].
			
	self setProperty: #filterColor toValue: fill.
]

{ #category : #accessing }
IndentingListItemMorph >> filterTextColor [

	^ self valueOfProperty: #filterTextColor ifAbsent: [Color black]
]

{ #category : #accessing }
IndentingListItemMorph >> filterTextColor: aColor [

	self setProperty: #filterTextColor toValue: aColor.
]

{ #category : #accessing }
IndentingListItemMorph >> firstChild [

	^firstChild
]

{ #category : #accessing }
IndentingListItemMorph >> firstVisibleChild [

	^ self firstChild ifNotNil: [:c |
		c visible ifTrue: [c] ifFalse: [c nextVisibleSibling]]
]

{ #category : #layout }
IndentingListItemMorph >> fitContents [

	super fitContents.
	self width: container preferredSubmorphWidth.
]

{ #category : #'model access' }
IndentingListItemMorph >> getChildren [

	^ self getChildrenFor: complexContents
]

{ #category : #'model access' }
IndentingListItemMorph >> getChildrenFor: model [

	^ model contents
]

{ #category : #'model access' }
IndentingListItemMorph >> getIcon [

	^ complexContents icon
]

{ #category : #'model access' }
IndentingListItemMorph >> getLabel [

	^ self getLabelFor: complexContents
]

{ #category : #'model access' }
IndentingListItemMorph >> getLabelFor: model [
	"Note that the given model is usually aListItemWrapper."
	
	^ model asStringOrText
]

{ #category : #accessing }
IndentingListItemMorph >> hMargin [

	^ 3
]

{ #category : #testing }
IndentingListItemMorph >> hasIcon [
	"Answer whether the receiver has an icon."
	^ icon notNil
]

{ #category : #private }
IndentingListItemMorph >> hasToggle [
	^ complexContents hasContents
]

{ #category : #drawing }
IndentingListItemMorph >> highlight [

	self changed.
	

]

{ #category : #accessing }
IndentingListItemMorph >> highlightTextColor [

	^ self valueOfProperty: #highlightTextColor ifAbsent: [Color red]
]

{ #category : #accessing }
IndentingListItemMorph >> highlightTextColor: aColor [

	self setProperty: #highlightTextColor toValue: aColor.
]

{ #category : #accessing }
IndentingListItemMorph >> hoverColor [

	^ self valueOfProperty: #hoverColor ifAbsent: [Color veryLightGray]
]

{ #category : #accessing }
IndentingListItemMorph >> hoverColor: aColor [

	self setProperty: #hoverColor toValue: aColor.
]

{ #category : #accessing }
IndentingListItemMorph >> icon [
	"answer the receiver's icon"
	^ icon
]

{ #category : #'mouse events' }
IndentingListItemMorph >> inToggleArea: aPoint [

	^self toggleRectangle containsPoint: aPoint
]

{ #category : #accessing }
IndentingListItemMorph >> indentLevel [

	^indentLevel
]

{ #category : #initialization }
IndentingListItemMorph >> initWithColor: aColor andFont: aFont [

	(self hasProperty: #hasColorFromText)
		ifFalse: [self color: aColor].

	(self hasProperty: #hasEmphasisFromText)
		ifTrue: [
			(self hasProperty: #hasFontFromText)
				ifFalse: [self font: aFont "Keeps emphasis from text."]]
		ifFalse: [
			(self hasProperty: #hasFontFromText)
				ifTrue: [self emphasis: aFont emphasis "Keeps font from text."]
				ifFalse: [self font: aFont emphasis: aFont emphasis]]

]

{ #category : #initialization }
IndentingListItemMorph >> initWithContents: anObject prior: priorMorph forList: hostList indentLevel: newLevel [

	container := hostList.
	
	complexContents := anObject.
	anObject addDependent: self.
	
	self initWithContents: self getLabel font: Preferences standardListFont emphasis: nil.
	indentLevel := 0.
	isExpanded := false.
 	nextSibling := firstChild := nil.
	priorMorph ifNotNil: [
		priorMorph nextSibling: self.
	].
	indentLevel := newLevel.
	icon := self getIcon ifNotNil: [:form | form scaleIconToDisplay].
	self extent: self minWidth @ self minHeight
]

{ #category : #initialization }
IndentingListItemMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	indentLevel := 0.
	isExpanded := false
]

{ #category : #initialization }
IndentingListItemMorph >> initializeFromText: aText [
	"Overridden to keep track of text-based attributes."
	
	| priorFont priorEmphasis priorColor |
	priorFont := self font.
	priorEmphasis := self emphasis.
	priorColor := self color.
	
	super initializeFromText: aText.
	
	priorFont == self font
		ifFalse: [self setProperty: #hasFontFromText toValue: true].
	priorFont == self emphasis
		ifFalse: [self setProperty: #hasEmphasisFromText toValue: true].
	priorColor == self color
		ifFalse: [self setProperty: #hasColorFromText toValue: true].
]

{ #category : #accessing }
IndentingListItemMorph >> isExpanded [

	^isExpanded
]

{ #category : #accessing }
IndentingListItemMorph >> isExpanded: aBoolean [

	isExpanded := aBoolean
]

{ #category : #testing }
IndentingListItemMorph >> isFirstItem [
	^owner submorphs first == self
]

{ #category : #testing }
IndentingListItemMorph >> isSelected [

	^ container ifNil: [false] ifNotNil: [container selectedMorph == self]
]

{ #category : #testing }
IndentingListItemMorph >> isSoleItem [
	^self isFirstItem and: [ owner submorphs size = 1 ]
]

{ #category : #filtering }
IndentingListItemMorph >> matches: pattern [

	^ self matches: pattern in: complexContents
]

{ #category : #filtering }
IndentingListItemMorph >> matches: pattern in: model [ 
	^ ((PluggableTreeMorph filterByLabelsOnly
		ifTrue: [ model itemName ]
		ifFalse: [ self getLabelFor: model ])
			findString: pattern
			startingAt: 1
			caseSensitive: false) > 0
]

{ #category : #filtering }
IndentingListItemMorph >> matchesAnyChild: pattern depthOffset: offset [

	| maxDepth next current |
	maxDepth := PluggableTreeMorph maximumSearchDepth - self indentLevel + offset.
	maxDepth <= 0 ifTrue: [^ false].
	
	next := (self getChildren collect: [:obj | 1 -> obj]) asOrderedCollection.
	[next notEmpty] whileTrue: [
		current := next removeFirst.
		
		(self matches: pattern in: current value)
			ifTrue: [^ true].
		
		current key < maxDepth ifTrue: [
			next addAll: ((self getChildrenFor: current value) collect: [:obj | (current key + 1) -> obj])].
		].
	
	^ false
]

{ #category : #layout }
IndentingListItemMorph >> minHeight [
	| iconHeight |
	iconHeight := self hasIcon
				ifTrue: [self icon height + 2]
				ifFalse: [0].
	^ self fontToUse height max: iconHeight 
]

{ #category : #layout }
IndentingListItemMorph >> minWidth [
	| iconWidth |
	iconWidth := self hasIcon
				ifTrue: [self icon width + 2]
				ifFalse: [0].
	^ (self fontToUse widthOfString: contents)
		+ iconWidth 
]

{ #category : #accessing }
IndentingListItemMorph >> nextSibling [

	^nextSibling
]

{ #category : #accessing }
IndentingListItemMorph >> nextSibling: anotherMorph [

	nextSibling := anotherMorph
]

{ #category : #accessing }
IndentingListItemMorph >> nextVisibleSibling [

	| m |
	m := self nextSibling.
	[m isNil or: [m visible]] whileFalse: [
		m := m nextSibling].
	^ m
]

{ #category : #'container protocol - private' }
IndentingListItemMorph >> openPath: anArray [ 
	| found |
	anArray isEmpty
		ifTrue: [^ container setSelectedMorph: nil].
	found := nil.
	self
		withSiblingsDo: [:each | found
				ifNil: [(each complexContents asString = anArray first
							or: [anArray first isNil])
						ifTrue: [found := each]]].
	found
		ifNil: ["try again with no case sensitivity"
			self
				withSiblingsDo: [:each | found
						ifNil: [(each complexContents asString sameAs: anArray first)
								ifTrue: [found := each]]]].
	found
		ifNotNil: [found isExpanded
				ifFalse: [found toggleExpandedState.
					container adjustSubmorphPositions].
			found changed.
			anArray size = 1
				ifTrue: [^ container setSelectedMorph: found].
			^ found firstChild
				ifNil: [container setSelectedMorph: nil]
				ifNotNil: [found firstChild openPath: anArray allButFirst]].
	^ container setSelectedMorph: nil
]

{ #category : #'accessing - columns' }
IndentingListItemMorph >> preferredColumnCount [

	^ self contentsSplitByColumns size
]

{ #category : #'accessing - columns' }
IndentingListItemMorph >> preferredWidthOfColumn: index [

	^ (self fontToUse widthOfString: (self contentsAtColumn: index)) + 
		(index = 1 ifTrue: [self toggleRectangle right - self left] ifFalse: [0])
]

{ #category : #'container protocol - private' }
IndentingListItemMorph >> recursiveAddTo: aCollection [

	firstChild ifNotNil: [
		firstChild withSiblingsDo: [ :aNode | aNode recursiveAddTo: aCollection].
	].
	aCollection add: self
	
]

{ #category : #'container protocol - private' }
IndentingListItemMorph >> recursiveDelete [

	firstChild ifNotNil: [
		firstChild withSiblingsDo: [ :aNode | aNode recursiveDelete].
	].
	self delete
	
]

{ #category : #initialization }
IndentingListItemMorph >> refresh [

	self contents: self getLabel.
	icon := self getIcon ifNotNil: [:form | form scaleIconToDisplay].
	
	(self valueOfProperty: #wasRefreshed ifAbsent: [false]) ifFalse: [
		self setProperty: #wasRefreshed toValue: true].
]

{ #category : #accessing }
IndentingListItemMorph >> selectionColor [

	^ self valueOfProperty: #selectionColor ifAbsent: [Color blue]
]

{ #category : #accessing }
IndentingListItemMorph >> selectionColor: aColor [

	| cc fill |
	cc := aColor.

	MenuMorph gradientMenu
		ifFalse: [fill := SolidFillStyle color: cc]
		ifTrue: [
			fill := GradientFillStyle ramp: { 
				0.0 -> cc twiceLighter. 
				1 -> cc twiceDarker }].

	self setProperty: #selectionColor toValue: fill.
]

{ #category : #accessing }
IndentingListItemMorph >> selectionTextColor [

	^ self valueOfProperty: #selectionTextColor ifAbsent: [Color white]
]

{ #category : #accessing }
IndentingListItemMorph >> selectionTextColor: aColor [

	self setProperty: #selectionTextColor toValue: aColor.
]

{ #category : #private }
IndentingListItemMorph >> toggleBounds [
	^self toggleRectangle
]

{ #category : #'container protocol' }
IndentingListItemMorph >> toggleExpandedState [

	self isExpanded
		ifTrue: [self collapse]
		ifFalse: [self expand].
]

{ #category : #private }
IndentingListItemMorph >> toggleRectangle [

	| h indent |
	h := bounds height.
	indent := (12 * RealEstateAgent scaleFactor) rounded.
	^(bounds left + self hMargin + (indent * indentLevel)) @ bounds top extent: indent@h
]

{ #category : #drawing }
IndentingListItemMorph >> unhighlight [

	self changed.
	
	

]

{ #category : #updating }
IndentingListItemMorph >> update: aspect [
	"See ListItemWrapper and subclasses for possible change aspects."
	
	aspect = #contents ifTrue: [
		self isExpanded ifTrue: [self toggleExpandedState].
		self canExpand ifTrue: [self toggleExpandedState].
		container adjustSubmorphPositions].
		
	super update: aspect.
]

{ #category : #accessing }
IndentingListItemMorph >> userString [
	"Add leading tabs to my userString"
	^ (String new: indentLevel withAll: Character tab), super userString

]

{ #category : #'accessing - columns' }
IndentingListItemMorph >> widthOfColumn: columnIndex [ 

	^ (container widthOfColumn: columnIndex) ifNil: [self width]
]

{ #category : #private }
IndentingListItemMorph >> withSiblingsDo: aBlock [

	| node |
	node := self.
	[node isNil] whileFalse: [
		aBlock value: node.
		node := node nextSibling
	].
]

{ #category : #converting }
IndentingListItemMorph >> withoutListWrapper [

	^complexContents withoutListWrapper
]
