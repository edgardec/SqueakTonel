Class {
	#name : #PluggableListViewByItem,
	#superclass : #PluggableListView,
	#instVars : [
		'itemList'
	],
	#category : #'ST80-Pluggable Views'
}

{ #category : #'model access' }
PluggableListViewByItem >> changeModelSelection: anInteger [
	"Change the model's selected item to be the one at the given index."
	| item |
	setSelectionSelector ifNotNil: [
		item := (anInteger = 0 ifTrue: [nil] ifFalse: [itemList at: anInteger]).
		model perform: setSelectionSelector with: item].

]

{ #category : #'model access' }
PluggableListViewByItem >> getCurrentSelectionIndex [
	"Answer the index of the current selection."
	| item |
	getSelectionSelector == nil ifTrue: [^ 0].
	item := model perform: getSelectionSelector.
	^ itemList findFirst: [ :x | x = item]

]

{ #category : #'model access' }
PluggableListViewByItem >> getList [
	"Ensure that there are only strings in that list."
	
	^ super getList collect: [:ea | ea asString]
]

{ #category : #initialization }
PluggableListViewByItem >> list: arrayOfStrings [
	"Set the receivers items to be the given list of strings."
	"Note: the instance variable 'items' holds the original list.
	 The instance variable 'list' is a paragraph constructed from
	 this list."

	itemList := arrayOfStrings.
	isEmpty := arrayOfStrings isEmpty.

	"add top and bottom delimiters"
	list := ListParagraph
		withArray:
			(Array streamContents: [:s |
				s nextPut: topDelimiter.
				arrayOfStrings do: [:item | item == nil ifFalse: [s nextPut: item]].
				s nextPut: bottomDelimiter])
		 style: self assuredTextStyle.

	selection := self getCurrentSelectionIndex.
	self positionList.
]
