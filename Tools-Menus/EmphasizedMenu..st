"
A selection menu in which individual selections are allowed to have different emphases.  Emphases allowed are: bold, italic, struckThrough, and plain.  Provide an emphasis array, with one element per selection, to use.  Refer to the class method #example.
"
Class {
	#name : #EmphasizedMenu,
	#superclass : #SelectionMenu,
	#instVars : [
		'emphases'
	],
	#category : #'Tools-Menus'
}

{ #category : #examples }
EmphasizedMenu class >> example1 [
	"EmphasizedMenu example1"

	^ (self
		selections: #('how' 'well' 'does' 'this' 'work?' ) 
		emphases: #(#bold #normal #italic #struckOut #normal ))
			startUpWithCaption: 'A Menu with Emphases'
]

{ #category : #examples }
EmphasizedMenu class >> example2 [
	"EmphasizedMenu example2"

	| aMenu |
	aMenu := EmphasizedMenu selections: #('One' 'Two' 'Three' 'Four').
	aMenu onlyBoldItem: 3.
	^ aMenu startUpWithCaption: 'Only the Bold'
]

{ #category : #examples }
EmphasizedMenu class >> example3 [
	"EmphasizedMenu example3"

	^ (self
		selectionAndEmphasisPairs: #('how' #bold 'well' #normal 'does' #italic 'this' #struckOut 'work' #normal))
		startUpWithCaption: 'A Menu with Emphases'
]

{ #category : #'instance creation' }
EmphasizedMenu class >> selectionAndEmphasisPairs: interleavedList [
	"An alternative form of call.  "
	| selList  emphList |
	selList := OrderedCollection new.
	emphList := OrderedCollection new.
	interleavedList pairsDo:
		[:aSel :anEmph |
			selList add: aSel.
			emphList add: anEmph].
	^ self selections:selList emphases: emphList
]

{ #category : #'instance creation' }
EmphasizedMenu class >> selections: selList emphases: emphList [
	"Answer an instance of the receiver with the given selections and 
	emphases."

	^ (self selections: selList) emphases: emphList

"Example:
	(EmphasizedMenu
		selections: #('how' 'well' 'does' 'this' 'work?') 
		emphases: #(bold plain italic struckOut plain)) startUp"
]

{ #category : #emphasis }
EmphasizedMenu >> emphases: emphasisArray [
	emphases := emphasisArray
]

{ #category : #emphasis }
EmphasizedMenu >> onlyBoldItem: itemNumber [
	"Set up emphasis such that all items are plain except for the given item number.  "

	emphases := (Array new: selections size) atAllPut: #normal.
	emphases at: itemNumber put: #bold
]

{ #category : #private }
EmphasizedMenu >> setEmphasis [
	"Set up the receiver to reflect the emphases in the emphases array.  "

	| selStart selEnd currEmphasis |
	
	labelString := labelString asText.
	emphases isEmptyOrNil ifTrue: [^ self].
	selStart := 1.
	1 to: selections size do:
		[:line |
			selEnd := selStart + (selections at: line) size - 1.
			((currEmphasis := emphases at: line) size > 0 and: [currEmphasis ~~ #normal]) ifTrue:
				[labelString addAttribute: (TextEmphasis perform: currEmphasis)
					from: selStart to: selEnd].
			selStart := selEnd + 2]
]

{ #category : #display }
EmphasizedMenu >> startUpWithCaption: captionOrNil [
	self setEmphasis.
	^ super startUpWithCaption: captionOrNil
]
