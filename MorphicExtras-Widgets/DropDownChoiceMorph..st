Class {
	#name : #DropDownChoiceMorph,
	#superclass : #PopUpChoiceMorph,
	#instVars : [
		'items',
		'border'
	],
	#classVars : [
		'SubMenuMarker'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'class initialization' }
DropDownChoiceMorph class >> initialize [
	"DropDownChoiceMorph initialize"

	| f |
	f := Form
		extent: 5@9
		fromArray: #(2147483648 3221225472 3758096384 4026531840 4160749568 4026531840 3758096384 3221225472 2147483648)
		offset: 0@0.
	SubMenuMarker := ColorForm mappingWhiteToTransparentFrom: f.

]

{ #category : #accessing }
DropDownChoiceMorph >> border [
	^border
]

{ #category : #accessing }
DropDownChoiceMorph >> border: newBorder [
	border := newBorder
]

{ #category : #drawing }
DropDownChoiceMorph >> drawOn: aCanvas [

	aCanvas drawString: contents in: (bounds insetBy: 2)  font: self fontToUse color: color.

	border ifNotNil: [aCanvas frameAndFillRectangle: bounds
		fillColor: Color transparent
		borderWidth: 1
		borderColor: Color black].

	aCanvas
			paintImage: SubMenuMarker
			at: (self right - 8 @ ((self top + self bottom - SubMenuMarker height) // 2))
]

{ #category : #'list access' }
DropDownChoiceMorph >> getCurrentSelectionIndex [
	^self items indexOf: contents
]

{ #category : #accessing }
DropDownChoiceMorph >> items [
	(target notNil and: [getItemsSelector notNil])
		ifTrue: [items := target perform: getItemsSelector withArguments: getItemsArgs].
	items ifNil: [items := #()].
	^items
]

{ #category : #accessing }
DropDownChoiceMorph >> items: someItems [
	items := someItems
]

{ #category : #drawing }
DropDownChoiceMorph >> maxExtent: listOfStrings [

	| h maxW |
	maxW := 0.
	listOfStrings do: [:str | | f w |
		f := self fontToUse.
		w := f widthOfString: str.
		h := f height.
		maxW := maxW max: w].
	self extent: (maxW + 4 + h) @ (h + 4).
	self changed
]

{ #category : #'event handling' }
DropDownChoiceMorph >> mouseUp: evt [

	| selectedItem |
	self items isEmpty ifTrue: [^ self].
	selectedItem := UIManager default chooseFrom: self items values: self items.
	selectedItem ifNil: [^ self].
	self contentsClipped: selectedItem.  "Client can override this if necess"
	actionSelector ifNotNil: [
		target
			perform: actionSelector
			withArguments: (arguments copyWith: selectedItem)].

]

{ #category : #'list access' }
DropDownChoiceMorph >> selection: val [
	self contentsClipped: val
]

{ #category : #copying }
DropDownChoiceMorph >> veryDeepInner: deepCopier [
	super veryDeepInner: deepCopier.
	items := items veryDeepCopyWith: deepCopier.
	border := border veryDeepCopyWith: deepCopier
]
