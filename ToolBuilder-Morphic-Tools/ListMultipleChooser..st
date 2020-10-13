"
I am like the ListChooser but for multiple choices. I have no extra search field. Enable the preference #filterableLists if lists get too big to choose from. Also, I do not support adding new items to the choice.
"
Class {
	#name : #ListMultipleChooser,
	#superclass : #Model,
	#instVars : [
		'selection',
		'labels',
		'values',
		'title',
		'choice'
	],
	#category : #'ToolBuilder-Morphic-Tools'
}

{ #category : #'ui requests' }
ListMultipleChooser class >> chooseFrom: someLabels title: aString [

	^ self chooseIndexListFrom: someLabels title: aString
]

{ #category : #'ui requests' }
ListMultipleChooser class >> chooseIndexListFrom: someObjects title: aString [

	^ self new
		title: aString;
		labels: (someObjects collect: [:ea | ea asString]);
		choose
]

{ #category : #'ui requests' }
ListMultipleChooser class >> chooseItemListFrom: someObjects title: aString [

	^ self new
		title: aString;
		labels: (someObjects collect: [:ea | ea asString]);
		values: someObjects;
		choose
]

{ #category : #preferences }
ListMultipleChooser class >> themeProperties [

	^ super themeProperties,  {
		{ #okColor. 'Colors'. 'Color for the OK button.' }.
		{ #cancelColor. 'Colors'. 'Color for the Cancel button.' }.
	}
]

{ #category : #actions }
ListMultipleChooser >> accept [

	choice := #accepted.
	self changed: #close.
]

{ #category : #updating }
ListMultipleChooser >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	
	self
		changed: #okColor;
		changed: #cancelColor.
]

{ #category : #toolbuilder }
ListMultipleChooser >> buildWith: builder [

	| dialogSpec choicesSpec |
	dialogSpec := builder pluggableDialogSpec new
		model: self;
		extent: self initialExtent;
		title: #title;
		children: OrderedCollection new;
		buttons: OrderedCollection new.
		
	choicesSpec := builder pluggableMultiSelectionListSpec new
		model: self;
		list: #labels;
		setIndex: #selectedIndex:;
		getIndex: #selectedIndex;
		setSelectionList: #selectionAt:put:;
		getSelectionList: #selectionAt:;
		frame: (0@0 corner: 1@1).
	dialogSpec children add: choicesSpec.
	
	"Buttons"
	dialogSpec buttons add: (
		builder pluggableButtonSpec new
			model: self;
			label: 'accept';
			color: (self userInterfaceTheme okColor ifNil: [Color r: 0.49 g: 0.749 b: 0.49]);
			action: #accept).
			
	dialogSpec buttons add: (
		builder pluggableButtonSpec new
			model: self;
			label: 'cancel';
			color: (self userInterfaceTheme cancelColor ifNil: [Color r: 1 g: 0.6 b: 0.588]);
			action: #cancel).
				
	^ builder build: dialogSpec
]

{ #category : #actions }
ListMultipleChooser >> cancel [

	choice := #cancelled.
	self changed: #close.
]

{ #category : #actions }
ListMultipleChooser >> choose [

	
"	self changed: #inputRequested with: #selectedIndex.
"	
	ToolBuilder open: self.
	^ self selectedValues
]

{ #category : #toolbuilder }
ListMultipleChooser >> initialExtent [

	| listFont |
	listFont := Preferences standardListFont.
	^ (20 * (listFont widthOf: $m))@(15 * listFont height)
]

{ #category : #accessing }
ListMultipleChooser >> labels [

	^ labels
]

{ #category : #accessing }
ListMultipleChooser >> labels: someStrings [

	labels := someStrings.
	self changed: #labels.
]

{ #category : #accessing }
ListMultipleChooser >> selectedIndex [
	"Sigh. Required from widget..."
	^ 0
]

{ #category : #accessing }
ListMultipleChooser >> selectedIndex: anIndex [
	"Sigh. Required from widget..."
	self changed: #selectedIndex.
]

{ #category : #accessing }
ListMultipleChooser >> selectedValues [
	
	| i |
	choice ~~ #accepted ifTrue: [^ nil].
	
	i := 0.
	^ self values select: [:object | i := i + 1. self selection at: i]
]

{ #category : #accessing }
ListMultipleChooser >> selection [

	^ selection ifNil: [selection := Array new: self values size withAll: false]
]

{ #category : #accessing }
ListMultipleChooser >> selectionAt: index [

	^ self selection at: index
]

{ #category : #accessing }
ListMultipleChooser >> selectionAt: index put: boolean [

	self selection at: index put: boolean.
	self changed: #selectionAt:
]

{ #category : #accessing }
ListMultipleChooser >> title [

	^ (title isNil or: [title isEmpty])
		ifFalse: [title]
		ifTrue: ['Choose multiple:']
]

{ #category : #accessing }
ListMultipleChooser >> title: aString [

	title := aString.
	self changed: #title.
]

{ #category : #accessing }
ListMultipleChooser >> values [

	^ values ifNil: [values := (1 to: self labels size) asArray]
]

{ #category : #accessing }
ListMultipleChooser >> values: someObjects [

	values := someObjects.
]
