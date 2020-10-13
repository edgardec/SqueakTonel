"
I display bags as a histogram, that is a bar chart of the counts in the bag.

Example:
	HistogramMorph openOn: (Smalltalk allClasses gather: 
		[:class | class selectors collect: [:selector | class ]])


Instance Variables
	bag:		<Bag>
	cachedForm:		<Form>
	countLabelBlock:		<BlockClosure>
	counts:		<SequencableCollection>
	labelBlock:		<BlockClosure>
	limit:		<Number>
	max:		<Number>
	sum:		<Number>
	values:		<SequencableCollection>

bag
	- The bag that forms the data basis for the histogram display

cachedForm
	- A form used to cache the historgram rendering.

countLabelBlock
	- Optional. Block that receives the count for the current bar and should return a String.
	  Leaving this nil is equivalent to [:count | count asString].

counts
	- Cached collection of all counts in (value-)frequency-sorted order for rendering speed.
	See values.

labelBlock
	- Optional. Block that receives the value for the current bar and should return a 
	String for the label. Leaving this nil is equivalent to [:value | value asString].

limit
	- Maximum number of elements from values to consider. Defaults to 25.

max
	- Cached maximum value from values. 

sum
	- Cached sum of all elements in values. Determines overall histogram height.

values
	- Cached collection of all values in frequency-sorted order for rendering speed.
	See counts.
"
Class {
	#name : #HistogramMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'bag',
		'cachedForm',
		'values',
		'counts',
		'max',
		'sum',
		'limit',
		'labelBlock',
		'countLabelBlock'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'instance creation' }
HistogramMorph class >> on: aCollection [

	^ self new
		bag: aCollection asBag;
		yourself
]

{ #category : #'instance creation' }
HistogramMorph class >> openOn: aCollection [

	^ (self on: aCollection)
		openInHand
]

{ #category : #accessing }
HistogramMorph >> bag [

	^ bag
]

{ #category : #accessing }
HistogramMorph >> bag: anObject [

	self basicBag: anObject.
	self flush.
	self changed.

]

{ #category : #accessing }
HistogramMorph >> basicBag: anObject [

	bag := anObject.
]

{ #category : #accessing }
HistogramMorph >> basicLimit: anObject [

	limit := anObject.

]

{ #category : #accessing }
HistogramMorph >> cachedForm [

	^ cachedForm
]

{ #category : #accessing }
HistogramMorph >> cachedForm: anObject [

	cachedForm := anObject.
]

{ #category : #accessing }
HistogramMorph >> color: aColor [

	super color: aColor.
	self flushCachedForm.

]

{ #category : #accessing }
HistogramMorph >> countLabelBlock [

	^ countLabelBlock
]

{ #category : #accessing }
HistogramMorph >> countLabelBlock: anObject [

	countLabelBlock := anObject.
]

{ #category : #drawing }
HistogramMorph >> countLabelFor: aNumber [

	^ self countLabelBlock 
		ifNotNil: [:block | block value: aNumber]
		ifNil: [aNumber asString]

]

{ #category : #accessing }
HistogramMorph >> counts [

	^ counts
]

{ #category : #accessing }
HistogramMorph >> counts: anObject [

	counts := anObject.
]

{ #category : #initialization }
HistogramMorph >> defaultColor [
	^ Color veryVeryLightGray
]

{ #category : #drawing }
HistogramMorph >> drawBar: aRectangle value: anObject count: anInteger chartHeight: chartHeight font: aFont on: aCanvas [

	| label countLabel labelWidth countWidth midX  |
	label := self labelFor: anObject.
	countLabel := self countLabelFor: anInteger.
	labelWidth := aFont widthOfString: label.
	countWidth := aFont widthOfString: countLabel.
	midX := aRectangle origin x + (aRectangle width // 2).
	
	aCanvas fillRectangle: aRectangle color: Color blue.
	self drawLabel: label width: labelWidth at: (midX - (labelWidth // 2) @ chartHeight) barWidth: aRectangle width font: aFont on: aCanvas.
	countWidth < aRectangle width
		ifTrue: [aCanvas drawString: countLabel at: (midX - (countWidth // 2) @ (chartHeight - (3/2 * aFont height))) font: aFont color: Color lightGray].

]

{ #category : #drawing }
HistogramMorph >> drawDataOn: aCanvas [

	| numX elementWidth offsetX font fontHeight offsetY maxY barWidth barRadius chartHeight |
	font := TextStyle defaultFont.
	fontHeight := font height.
	numX := self limit.
	maxY := self sum.
	elementWidth := self width / (numX + 1).
	barWidth := 2 max: (elementWidth * 0.9) floor.
	barRadius := barWidth / 2.
	offsetX := elementWidth / 2.
	offsetY := fontHeight * 1.2
		max: (self values collect: [:value | font widthOfString: (self labelFor: value)]) max.
	chartHeight := self height - offsetY.

	0 to: (self height - offsetY) by: 20 do: [:i |
	aCanvas
		line: 0@i to: aCanvas clipRect width@i width: 1 color: (Color lightGray lighter alpha: 0.5)].
	
	self valuesAndCountsWithIndexDo: 
		[:value :count :barIndex | | barMidX origin end  |
		barIndex <= self limit ifTrue: [
			barMidX := barIndex * elementWidth.
			origin := barMidX - barRadius @ ((maxY - count) / maxY * chartHeight).
			end := barMidX + barRadius @ chartHeight.

			self
				drawBar: (origin corner: end)  
				value: value
				count: count
				chartHeight: chartHeight
				font: font
				on: aCanvas]].

]

{ #category : #drawing }
HistogramMorph >> drawLabel: aString width: aNumber at: aPoint barWidth: barWidth font: aFont on: aCanvas [

	aNumber <= barWidth
		ifTrue: [aCanvas drawString: aString at: aPoint font: aFont color: Color black]
		ifFalse: [
			| c  |
			c := Display defaultCanvasClass extent: aNumber @ aFont height.
			c drawString: aString at: 0 @ 0  font: aFont color: Color black.
			aCanvas paintImage: (c form rotateBy: -90 smoothing: 3) at: aPoint].
]

{ #category : #drawing }
HistogramMorph >> drawOn: aCanvas [ 
	| c |
	self cachedForm 
		ifNil:
			[c := Display defaultCanvasClass extent: self bounds extent.
			c translateBy: self bounds origin negated
				during: [:tempCanvas | super drawOn: tempCanvas].
			self drawDataOn: c.
			self cachedForm: c form].
	aCanvas 
		cache: self bounds
		using: self cachedForm
		during: [:cachingCanvas | self drawDataOn: cachingCanvas].

]

{ #category : #initialization }
HistogramMorph >> flush [

	| valuesAndCounts |
	self bag ifNil: [^self]. "nothing to do yet"
	valuesAndCounts := self bag sortedCounts.
	valuesAndCounts size < self limit
		ifTrue: [self basicLimit: valuesAndCounts size].
	self values: ((valuesAndCounts collect: [:ea | ea value]) first: self limit).
	self counts: ((valuesAndCounts collect: [:ea | ea key]) first: self limit).
	self max: self counts max.
	self sum: self counts sum.

	self flushCachedForm.

]

{ #category : #initialization }
HistogramMorph >> flushCachedForm [

	cachedForm := nil.

]

{ #category : #initialization }
HistogramMorph >> initialize [

	super initialize.
	self
		extent:  700 @ 400;
		basicLimit: 25;
		yourself.
]

{ #category : #accessing }
HistogramMorph >> labelBlock [

	^ labelBlock
]

{ #category : #accessing }
HistogramMorph >> labelBlock: anObject [

	labelBlock := anObject.
]

{ #category : #drawing }
HistogramMorph >> labelFor: aValue [

	^ self labelBlock 
		ifNotNil: [:block | block value: aValue]
		ifNil: [aValue asString]

]

{ #category : #layout }
HistogramMorph >> layoutChanged [

	super layoutChanged.
	cachedForm := nil.

]

{ #category : #accessing }
HistogramMorph >> limit [

	^ limit
]

{ #category : #accessing }
HistogramMorph >> limit: anObject [

	self basicLimit: anObject.
	self flush.
	self changed
]

{ #category : #accessing }
HistogramMorph >> max [

	^ max
]

{ #category : #accessing }
HistogramMorph >> max: anObject [

	max := anObject.
]

{ #category : #accessing }
HistogramMorph >> sum [

	^ sum
]

{ #category : #accessing }
HistogramMorph >> sum: anObject [

	sum := anObject
]

{ #category : #accessing }
HistogramMorph >> values [

	^ values
]

{ #category : #accessing }
HistogramMorph >> values: anObject [

	values := anObject.
]

{ #category : #enumeration }
HistogramMorph >> valuesAndCountsWithIndexDo: aBlock [

	1 to: self values size do: [:index |
		aBlock
			value: (self values at: index)
			value: (self counts at: index)
			value: index].	
]
