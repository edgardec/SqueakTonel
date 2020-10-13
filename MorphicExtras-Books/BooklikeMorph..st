"
A common superclass for BookMorph and WebBookMorph
"
Class {
	#name : #BooklikeMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'pageSize',
		'newPagePrototype'
	],
	#classVars : [
		'PageFlipSoundOn'
	],
	#category : #'MorphicExtras-Books'
}

{ #category : #'class initialization' }
BooklikeMorph class >> initialize [
	"BooklikeMorph initialize"
	PageFlipSoundOn := true

]

{ #category : #'as yet unclassified' }
BooklikeMorph class >> turnOffSoundWhile: aBlock [
	"Turn off page flip sound during the given block."
	| old |
	old := PageFlipSoundOn.
	PageFlipSoundOn := false.
	aBlock value.
	PageFlipSoundOn := old
]

{ #category : #misc }
BooklikeMorph >> addBookMenuItemsTo: aCustomMenu hand: aHandMorph [
	(self hasSubmorphWithProperty: #pageControl)
		ifTrue: [aCustomMenu add: 'hide page controls' translated action: #hidePageControls]
		ifFalse: [aCustomMenu add: 'show page controls' translated action: #showPageControls]
]

{ #category : #menus }
BooklikeMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"This factoring allows subclasses to have different menu yet still use the super call for the rest of the metamenu."

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'book...' translated target: self action: #invokeBookMenu.
	
	"self addBookMenuItemsTo: aCustomMenu hand: aHandMorph"
]

{ #category : #'page controls' }
BooklikeMorph >> addPageControlMorph: aMorph [
	"Add the morph provided as a page control, at the appropriate place"

	aMorph setProperty: #pageControl toValue: true.
	self addMorph: aMorph asElementNumber: self indexForPageControls
]

{ #category : #'menu commands' }
BooklikeMorph >> clearNewPagePrototype [
	newPagePrototype := nil

]

{ #category : #'e-toy support' }
BooklikeMorph >> currentPlayerDo: aBlock [
	| aPlayer aPage |
	(aPage := self currentPage) ifNil: [^ self].
	aPage allMorphsDo:[ :m|
	(aPlayer := m player) ifNotNil:
		[aBlock value: aPlayer]]
]

{ #category : #'page controls' }
BooklikeMorph >> fewerPageControls [
	self currentEvent shiftPressed
		ifTrue:
			[self hidePageControls]
		ifFalse:
			[self showPageControls: self shortControlSpecs]
]

{ #category : #'menu commands' }
BooklikeMorph >> firstPage [
	self goToPage: 1
]

{ #category : #'page controls' }
BooklikeMorph >> fullControlSpecs [

	^ {
		#spacer.
		#variableSpacer.
		{'-'.		#deletePage.				'Delete this page' translated}.
		#spacer.
		{'«'.		#firstPage.				'First page' translated}.
		#spacer.
		{'<'. 		#previousPage.			'Previous page' translated}.
		#spacer.
		{'·'.		#invokeBookMenu. 		'Click here to get a menu of options for this book.' translated}.
		#spacer.
		{'>'.		#nextPage.				'Next page' translated}.
		#spacer.
		{ '»'.		#lastPage.				'Final page' translated}.
		#spacer.
		{'+'.		#insertPage.				'Add a new page after this one' translated}.
		#variableSpacer.
		{'o'.		#fewerPageControls.	'Fewer controls' translated}
}

]

{ #category : #'page controls' }
BooklikeMorph >> hidePageControls [
	"Delete all submorphs answering to the property #pageControl"
	self deleteSubmorphsWithProperty: #pageControl
]

{ #category : #'page controls' }
BooklikeMorph >> indexForPageControls [
	"Answer which submorph should hold the page controls"

	^ (submorphs size > 0 and: [submorphs first hasProperty: #header])
		ifTrue:	[2]
		ifFalse:	[1]
]

{ #category : #'menu commands' }
BooklikeMorph >> insertPage [
	self insertPageColored: self color
]

{ #category : #'page controls' }
BooklikeMorph >> makePageControlsFrom: controlSpecs [
	"From the controlSpecs, create a set of page control and return them -- this method does *not* add the controls to the receiver."

	| c col row |
	c := (color saturation > 0.4) ifTrue: [color slightlyLighter] ifFalse: [color slightlyDarker].
	col := AlignmentMorph newColumn.
	col color: c; borderWidth: 0; layoutInset: 0.
	col hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.

	row := AlignmentMorph newRow.
	row color: c; borderWidth: 0; layoutInset: 0.
	row hResizing: #spaceFill; vResizing: #shrinkWrap; extent: 5@5.
	controlSpecs do: [:spec | | lastGuy b |
		spec == #showDescription ifTrue: [row addMorphBack: self makeDescriptionViewer].
		spec == #pageNumber ifTrue: [row addMorphBack: self makePageNumberItem].
		spec == #spacer ifTrue: [row addTransparentSpacerOfSize: (10 @ 0)].
		spec == #variableSpacer ifTrue: [
			row addMorphBack: AlignmentMorph newVariableTransparentSpacer].
		spec class == Array ifTrue: [
			spec first isSymbol
				ifTrue: [b := ThreePhaseButtonMorph labelSymbol: spec first]
				ifFalse: [b := SimpleButtonMorph new borderWidth: 2; 
							borderColor: Color black; color: Color white.
							b label: spec first font: Preferences standardMenuFont].
				b target: self;  actionSelector: spec second;  setBalloonText: spec third.
				(spec atPin: 4) = #border 
					ifTrue: [b actWhen: #buttonDown]
					ifFalse: [b borderWidth: 0].	"default is none"
				row addMorphBack: b.
				(((lastGuy := spec last asLowercase) includesSubstring: 'menu') or:
						[lastGuy includesSubstring: 'designations'])
					ifTrue: [b actWhen: #buttonDown]]].  "pop up menu on mouseDown"
		col addMorphBack: row.
	^ col
]

{ #category : #misc }
BooklikeMorph >> move [
	(owner isWorldMorph and:[self isSticky not]) ifTrue: [self activeHand grabMorph: self]
]

{ #category : #misc }
BooklikeMorph >> pageSize [
	^ pageSize

]

{ #category : #misc }
BooklikeMorph >> pageSize: aPoint [
	pageSize := aPoint
]

{ #category : #misc }
BooklikeMorph >> playPageFlipSound: soundName [
	self presenter ifNil: [^ self].  "Avoid failures when called too early"
	PageFlipSoundOn  "mechanism to suppress sounds at init time"
			ifTrue: [self playSoundNamed: soundName].

]

{ #category : #'page controls' }
BooklikeMorph >> setEventHandlerForPageControls: controls [
	"Set the controls' event handler if appropriate.  Default is to let the tool be dragged by the controls"

	controls eventHandler: (EventHandler new on: #mouseDown send: #move to: self)
]

{ #category : #'page controls' }
BooklikeMorph >> shortControlSpecs [
	"Answer  specs defining the widgets in the short form of the control panel."

^ {
		{#MenuIcon.		#invokeShortBookMenu. 		'Click here to get a menu of options for this book.' translated}.
		#variableSpacer.
		{#PrevPage. 		#previousPage.			'Previous page' translated}.
		#spacer.
		#pageNumber.
		#spacer.
		{#NextPage.		#nextPage.				'Next page' translated}.
		#spacer.
		#variableSpacer.
		{'...'.		#showMoreControls.		'More controls' translated}
}

]

{ #category : #'page controls' }
BooklikeMorph >> showPageControls [
	self showPageControls: self shortControlSpecs
]

{ #category : #'page controls' }
BooklikeMorph >> showPageControls: controlSpecs [  
	"Remove any existing page controls, and add fresh controls at the top of the receiver (or in position 2 if the receiver's first submorph is one with property #header).  Add a single column of controls."

	| pageControls column |
	self hidePageControls.
	column := AlignmentMorph newColumn beTransparent.
	pageControls := self makePageControlsFrom: controlSpecs.
	pageControls borderWidth: 0; layoutInset: 4.
	pageControls beSticky.
	pageControls setNameTo: 'Page Controls'.
	self setEventHandlerForPageControls: pageControls.
	column addMorphBack: pageControls.
	self addPageControlMorph: column
]

{ #category : #misc }
BooklikeMorph >> showingFullScreenString [
	"Answer a string characterizing whether the receiver is operating in full-screen mode."

	^ (self isInFullScreenMode ifTrue: ['<yes>'] ifFalse: ['<no>']), 'view pages full-screen' translated
]

{ #category : #misc }
BooklikeMorph >> showingPageControlsString [
	"Answer a string characterizing whether page controls are currently showing."

	^ (self pageControlsVisible ifTrue: ['<yes>'] ifFalse: ['<no>']),
		'page controls visible' translated
]

{ #category : #'menu commands' }
BooklikeMorph >> sortPages [
	| sorter |
	sorter := BookPageSorterMorph new
		book: self morphsToSort: self morphsForPageSorter.
	sorter pageHolder cursor: self pageNumber.
	"Align at bottom right of screen, but leave 20-pix margin."
	self bottom + sorter height < Display height ifTrue: "Place it below if it fits"
		[^ self world addMorphFront: (sorter align: sorter topLeft with: self bottomLeft)].
	self right + sorter width < Display width ifTrue: "Place it below if it fits"
		[^ self world addMorphFront: (sorter align: sorter bottomLeft with: self bottomRight)].
	"Otherwise, place it at lower right of screen"
	self world addMorphFront: (sorter position: Display extent - (20@20) - sorter extent).

]
