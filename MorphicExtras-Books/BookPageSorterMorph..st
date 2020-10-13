Class {
	#name : #BookPageSorterMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'book',
		'pageHolder'
	],
	#category : #'MorphicExtras-Books'
}

{ #category : #buttons }
BookPageSorterMorph >> acceptSort [

	book acceptSortedContentsFrom: pageHolder.
	self delete.

]

{ #category : #initialization }
BookPageSorterMorph >> addControls [
	"Add the control bar at the top of the tool."

	| bb r str aCheckbox aWrapper |
	r := AlignmentMorph newRow color: Color transparent; borderWidth: 0; layoutInset: 0.
	r wrapCentering: #center; cellPositioning: #leftCenter; 
			hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	r addMorphBack: (self wrapperFor: (bb label: 'Okay' translated font: ScriptingSystem fontForEToyButtons;	actionSelector: #acceptSort)).
	bb setBalloonText: 'Accept the changes made here as the new page-order for this book' translated.
	r addTransparentSpacerOfSize: 12.
	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	r addMorphBack: (self wrapperFor: (bb label: 'Cancel' translated font: ScriptingSystem fontForEToyButtons;	actionSelector: #delete)).
	bb setBalloonText: 'Forgot any changes made here, and dismiss this sorter' translated.

	"eliminate the parts-bin button on the book-page sorters...
	r addTransparentSpacerOfSize: 24 @ 0.

	aCheckbox :=  UpdatingThreePhaseButtonMorph checkBox.
	aCheckbox 
		target: self;
		actionSelector: #togglePartsBinStatus;
		arguments: #();
		getSelector: #getPartsBinStatus.
	str := StringMorph contents: 'Parts bin' translated font: ScriptingSystem fontForEToyButtons.
	aWrapper := AlignmentMorph newRow beTransparent.
	aWrapper cellInset: 0; layoutInset: 0; borderWidth: 0.
	aWrapper
		addMorphBack: (self wrapperFor: aCheckbox);
		addMorphBack: (self wrapperFor: str lock).
	r addMorphBack: aWrapper."

	self addMorphFront: r

]

{ #category : #initialization }
BookPageSorterMorph >> book: aBookMorph morphsToSort: morphList [

	| innerBounds scrollPane newHeight |
	book := aBookMorph.
	newHeight := self currentWorld height.
	pageHolder removeAllMorphs.
	pageHolder addAllMorphs: morphList.
	pageHolder extent: pageHolder width@pageHolder fullBounds height.
	innerBounds := Rectangle merging: (morphList collect: [:m | m bounds]).
	pageHolder extent: innerBounds extent + pageHolder borderWidth + 6.
	(pageHolder height > newHeight) ifTrue: [
		scrollPane := ScrollPane new.

		self height: newHeight.
		scrollPane model: pageHolder.
		scrollPane extent: pageHolder width@(newHeight - aBookMorph submorphs first height - 28).
		self addMorph: scrollPane inFrontOf: pageHolder.
		scrollPane scroller addMorph: pageHolder.
		scrollPane scrollBarOnLeft: false.
		scrollPane retractable: false.
		scrollPane hScrollBarPolicy: #never.
		scrollPane borderWidth: 1; borderColor: Color gray.
	].

]

{ #category : #private }
BookPageSorterMorph >> changeExtent: aPoint [ 
	self extent: aPoint.
	pageHolder extent: self extent - self borderWidth
]

{ #category : #private }
BookPageSorterMorph >> closeButtonOnly [
	"Replace my default control panel with one that has only a close button."

	| b r |
	self firstSubmorph delete.  "remove old control panel"
	b := SimpleButtonMorph new target: self; borderColor: Color black.
	r := AlignmentMorph newRow.
	r color: b color; borderWidth: 0; layoutInset: 0.
	r hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	r wrapCentering: #topLeft.
	r addMorphBack: (b label: 'Close' translated; actionSelector: #delete).
	self addMorphFront: r.

]

{ #category : #private }
BookPageSorterMorph >> columnWith: aMorph [

	^AlignmentMorph newColumn
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		wrapCentering: #center;
		cellPositioning: #topCenter;
		layoutInset: 1;
		addMorph: aMorph

]

{ #category : #initialization }
BookPageSorterMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 2
]

{ #category : #initialization }
BookPageSorterMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #buttons }
BookPageSorterMorph >> getPartsBinStatus [

	^pageHolder isPartsBin
]

{ #category : #initialization }
BookPageSorterMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self extent: Display extent - 100;
		 listDirection: #topToBottom;
		 wrapCentering: #topLeft;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 layoutInset: 3.
	pageHolder := PasteUpMorph new behaveLikeHolder extent: self extent -self borderWidth.
	pageHolder hResizing: #shrinkWrap.
	pageHolder wantsMouseOverHalos: false.
	"pageHolder cursor: 0."
	"causes a walkback as of 5/25/2000"
	self addControls.
	self addMorphBack: pageHolder
]

{ #category : #accessing }
BookPageSorterMorph >> pageHolder [

	^ pageHolder

]

{ #category : #private }
BookPageSorterMorph >> rowWith: aMorph [

	^AlignmentMorph newColumn
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		wrapCentering: #center;
		cellPositioning: #topCenter;
		layoutInset: 1;
		addMorph: aMorph

]

{ #category : #buttons }
BookPageSorterMorph >> togglePartsBinStatus [

	pageHolder isPartsBin: pageHolder isPartsBin not
]

{ #category : #copying }
BookPageSorterMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

super veryDeepFixupWith: deepCopier.
book := deepCopier references at: book ifAbsent: [book].

]

{ #category : #copying }
BookPageSorterMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"book := book.		Weakly copied"
pageHolder := pageHolder veryDeepCopyWith: deepCopier.
]

{ #category : #'dropping\/grabbing' }
BookPageSorterMorph >> wantsToBeDroppedInto: aMorph [
	"Return true if it's okay to drop the receiver into aMorph"
	^aMorph isWorldMorph "only into worlds"
]

{ #category : #private }
BookPageSorterMorph >> wrapperFor: aMorph [

	^self columnWith: (self rowWith: aMorph)

]
