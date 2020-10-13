"
I am an abstract View of a list of items. I provide support for storing a selection of one item, as well as formatting the list for presentation on the screen. My instances' default controller is ListController.
"
Class {
	#name : #ListView,
	#superclass : #View,
	#instVars : [
		'list',
		'selection',
		'topDelimiter',
		'bottomDelimiter',
		'isEmpty',
		'textStyle'
	],
	#category : #'ST80-Support'
}

{ #category : #'list access' }
ListView >> assuredTextStyle [
	^ textStyle ifNil:
		[textStyle :=  ListParagraph standardListStyle]

]

{ #category : #delimiters }
ListView >> bottomDelimiter [
	"Answer the string used to indicate the bottom of the list."

	^bottomDelimiter
]

{ #category : #delimiters }
ListView >> bottomDelimiter: aString [ 
	"Set the string used to indicate the bottom of the list."

	bottomDelimiter := aString
]

{ #category : #'display box access' }
ListView >> boundingBox [ 
	"Refer to the comment in View|boundingBox."

	^list boundingBox
]

{ #category : #'clipping box access' }
ListView >> clippingBox [
	"Answer the rectangle in which the model can be displayed--this is the 
	insetDisplayBox inset by the height of a line for an item."

	^self insetDisplayBox insetBy: 
		(Rectangle
			left: 0
			right: 0
			top: 0
			bottom: self insetDisplayBox height \\ list lineGrid)
]

{ #category : #displaying }
ListView >> deEmphasizeSelectionBox [
	self displaySelectionBox
]

{ #category : #deEmphasizing }
ListView >> deEmphasizeView [ 
	"Refer to the comment in View|deEmphasizeView."
	^ self deEmphasizeSelectionBox
]

{ #category : #'controller access' }
ListView >> defaultControllerClass [ 
	"Refer to the comment in View|defaultControllerClass."

	^ListController
]

{ #category : #selecting }
ListView >> deselect [
	"If the receiver has a selection, then it is highlighted. Remove the 
	highlighting."

	selection ~= 0 ifTrue: [Display reverse: (self selectionBox intersect: self clippingBox)]
]

{ #category : #displaying }
ListView >> display [ 
	"Refer to the comment in View.display."
	(self isUnlocked and: [self clippingBox ~= list clippingRectangle])
		ifTrue:  "Recompose the list if the window changed"
			[selection isNil ifTrue: [selection := 0].
			self positionList].
	super display
]

{ #category : #displaying }
ListView >> displaySelectionBox [
	"If the receiver has a selection and that selection is visible on the display 
	screen, then highlight it."
	selection ~= 0 ifTrue:
		[Display reverse: (self selectionBox intersect: self clippingBox)]
]

{ #category : #displaying }
ListView >> displayView [ 
	"Refer to the comment in View|displayView."

	self clearInside.
	list foregroundColor: self foregroundColor
		backgroundColor: self backgroundColor.
	list displayOn: Display
]

{ #category : #deEmphasizing }
ListView >> emphasizeView [ 
	"List emphasis is its own inverse."
	^ self deEmphasizeView
]

{ #category : #selecting }
ListView >> findSelection: aPoint [ 
	"Determine which selection is displayed in an area containing the point, 
	aPoint. Answer the selection if one contains the point, answer nil 
	otherwise."

	| trialSelection |
	(self clippingBox containsPoint: aPoint) ifFalse: [^nil].
	trialSelection := aPoint y - list compositionRectangle top // list lineGrid + 1.
	topDelimiter == nil ifFalse: [trialSelection := trialSelection - 1].
	(trialSelection < 1) | (trialSelection > self maximumSelection)
		ifTrue: [^ nil]
		ifFalse: [^ trialSelection]
]

{ #category : #private }
ListView >> firstShown [
	"Return the index of the top item currently visible"
	| trial |
	trial := self findSelection: self insetDisplayBox topLeft.
	^ trial == nil
		ifTrue: [1]
		ifFalse: [trial]
]

{ #category : #'font access' }
ListView >> font [
	^ self assuredTextStyle fontNamed: textStyle fontNames first

]

{ #category : #'font access' }
ListView >> font: aFontOrNil [

	aFontOrNil
		ifNil: [textStyle := nil]
		ifNotNil: [
			textStyle := TextStyle fontArray: (Array with: aFontOrNil).
			textStyle gridForFont: 1 withLead: 1].
	self changed: #list.  "update display"

]

{ #category : #'initialize-release' }
ListView >> initialize [ 
	"Refer to the comment in View|initialize."

	super initialize.
	topDelimiter := '------------'.
	bottomDelimiter := '------------'.
	isEmpty := true.
	self list: Array new
]

{ #category : #'display box access' }
ListView >> isSelectionBoxClipped [
        "Answer whether there is a selection and whether the selection is visible 
        on the screen."

        ^ selection ~= 0 and:
			[(self selectionBox intersects: 
                       (self clippingBox insetBy: (Rectangle left: 0 right: 0 top: 1 bottom: 0))) not]
]

{ #category : #private }
ListView >> lastShown [
	"Return the index of the bottom item currently visible"
	| trial bottomMargin |
	bottomMargin := self insetDisplayBox height \\ list lineGrid.
	trial := self findSelection: self insetDisplayBox bottomLeft - (0@bottomMargin).
	trial == nil
		ifTrue: [trial := self findSelection: self insetDisplayBox bottomLeft
					- (0@(list lineGrid+bottomMargin))].
	^ trial == nil
		ifTrue: [list numberOfLines - 2]
		ifFalse: [trial]
]

{ #category : #'list access' }
ListView >> list [
	"Answer the list of items the receiver displays."

	^list
]

{ #category : #'list access' }
ListView >> list: anArray [ 
	"Set the list of items the receiver displays to be anArray."
	| arrayCopy i |
	isEmpty := anArray isEmpty.
	arrayCopy := Array new: (anArray size + 2).
	arrayCopy at: 1 put: topDelimiter.
	arrayCopy at: arrayCopy size put: bottomDelimiter.
	i := 2.
	anArray do: [:el | arrayCopy at: i put: el. i := i+1].
	arrayCopy := arrayCopy copyWithout: nil.
	list := ListParagraph withArray: arrayCopy style: self assuredTextStyle.
	selection := 0.
	self positionList.

]

{ #category : #'lock access' }
ListView >> lock [
	"Refer to the comment in view|lock.  Must do at least what display would do to lock the view."

	(self isUnlocked and: [self clippingBox ~= list clippingRectangle])
		ifTrue:  "Recompose the list if the window changed"
			[self positionList].
	super lock
]

{ #category : #selecting }
ListView >> maximumSelection [
	"Answer which selection is the last possible one."
	^ list numberOfLines
		- (topDelimiter == nil ifTrue: [0] ifFalse: [1])
		- (bottomDelimiter == nil ifTrue: [0] ifFalse: [1])
]

{ #category : #selecting }
ListView >> minimumSelection [
	"Answer which selection is the first possible one."
	^ 1
]

{ #category : #selecting }
ListView >> moveSelectionBox: anInteger [ 
	"Presumably the selection has changed to be anInteger. Deselect the 
	previous selection and display the new one, highlighted."

	selection ~= anInteger
		ifTrue: 
			[self deselect.
			selection := anInteger.
			self displaySelectionBox].
	self isSelectionBoxClipped
		ifTrue: [self scrollSelectionIntoView]
]

{ #category : #delimiters }
ListView >> noBottomDelimiter [
	"Set the string used to indicate the bottom of the list to be nothing."

	bottomDelimiter := nil
]

{ #category : #delimiters }
ListView >> noTopDelimiter [
	"Set the string used to indicate the top of the list to be nothing."

	topDelimiter := nil
]

{ #category : #selecting }
ListView >> numSelectionsInView [
	^ self clippingBox height // self list lineGrid
]

{ #category : #private }
ListView >> positionList [

	list wrappingBox: self wrappingBox clippingBox: self clippingBox 
]

{ #category : #'list access' }
ListView >> reset [
	"Set the list of items displayed to be empty."

	isEmpty := true.
	self list: Array new
]

{ #category : #'list access' }
ListView >> resetAndDisplayView [
	"Set the list of items displayed to be empty and redisplay the receiver."

	isEmpty
		ifFalse: 
			[self reset.
			self displayView]
]

{ #category : #displaying }
ListView >> scrollBy: anInteger [ 
	"Scroll up by this amount adjusted by lineSpacing and list limits"
	| maximumAmount minimumAmount amount wasClipped |
	maximumAmount := 0 max:
		list clippingRectangle top - list compositionRectangle top.
	minimumAmount := 0 min:
		list clippingRectangle bottom - list compositionRectangle bottom.
	amount := (anInteger min: maximumAmount) max: minimumAmount.
	amount ~= 0
		ifTrue: [list scrollBy: amount negated.  ^ true]
		ifFalse: [^ false]  "Return false if no scrolling took place"
]

{ #category : #displaying }
ListView >> scrollSelectionIntoView [
	"Selection is assumed to be on and clipped out of view.
	Uses controller scrollView to keep selection right"
	| delta |
	(delta := self insetDisplayBox bottom - self selectionBox bottom) < 0
		ifTrue: [^ self controller scrollView: delta - (list lineGrid-1)]. "up"
	(delta := self insetDisplayBox top - self selectionBox top) > 0
		ifTrue: [^ self controller scrollView: delta + 1] "down"
]

{ #category : #selecting }
ListView >> selection [
	"Answer the receiver's current selection."

	^selection
]

{ #category : #'list access' }
ListView >> selection: selIndex [
	selection := selIndex
]

{ #category : #selecting }
ListView >> selectionBox [
	"Answer the rectangle in which the current selection is displayed."

	^(self insetDisplayBox left @ (list compositionRectangle top + self selectionBoxOffset) 
		extent: self insetDisplayBox width @ list lineGrid)
		insetBy: (Rectangle left: 1 right: 1 top: 1 bottom: 0)
]

{ #category : #selecting }
ListView >> selectionBoxOffset [
	"Answer an integer that determines the y position for the display box of 
	the current selection."

	^ (selection - 1 + (topDelimiter == nil ifTrue: [0] ifFalse: [1]))
		* list lineGrid
]

{ #category : #delimiters }
ListView >> topDelimiter [
	"Answer the string used to indicate the top of the list."

	^topDelimiter
]

{ #category : #delimiters }
ListView >> topDelimiter: aString [ 
	"Set the string used to indicate the top of the list."

	topDelimiter := aString
]

{ #category : #updating }
ListView >> update: aSymbol [ 
	"Refer to the comment in View|update:."

	aSymbol == #list
		ifTrue: 
			[self list: model list.
			self displayView.
			^self].
	aSymbol == #listIndex
		ifTrue: 
			[self moveSelectionBox: model listIndex.
			^self]
]

{ #category : #private }
ListView >> wrappingBox [

	| aRectangle |
	aRectangle := self insetDisplayBox. 
	selection = 0
		ifTrue: [^aRectangle topLeft + (4 @ 0) extent: list compositionRectangle extent]
		ifFalse: [^aRectangle left + 4 @ 
					(aRectangle top - 
						(self selectionBoxOffset 
							min: ((list height - aRectangle height 
									+ list lineGrid truncateTo: list lineGrid)
							max: 0))) 
					extent: list compositionRectangle extent]
]
