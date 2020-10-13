"
GeeMail is a scrolling playfield with a text morph (typically on the left) and room on the right for other morphs to be placed. The morphs on the right can be linked to text selections on the left so that they remain positioned beside the pertinent text as the text is reflowed. Probably the best thing is and example and Alan will be making some available soon.
"
Class {
	#name : #GeeMailMorph,
	#superclass : #ScrollPane,
	#instVars : [
		'theTextMorph',
		'thePasteUp'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #'new-morph participation' }
GeeMailMorph class >> includeInNewMorphMenu [

	^ false		"to encourage the use of GeeMail instead"
]

{ #category : #menus }
GeeMailMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	self addGeeMailMenuItemsTo: aCustomMenu.
]

{ #category : #menus }
GeeMailMorph >> addGeeMailMenuItemsTo: menu [

	menu 
		addUpdating: #showPageBreaksString action: #togglePageBreaks;
		addUpdating: #keepScrollbarString action: #toggleKeepScrollbar;
		addLine;
		add: 'Print...' translated action: #printPSToFile;
		addLine.
	thePasteUp allTextPlusMorphs size = 1 ifTrue: [
		menu add: 'make 1-column book' translated selector: #makeBookStyle: argument: 1.
		menu add: 'make 2-column book' translated selector: #makeBookStyle: argument: 2.
		menu add: 'make 3-column book' translated selector: #makeBookStyle: argument: 3.
		menu add: 'make 4-column book' translated selector: #makeBookStyle: argument: 4.
	] ifFalse: [
		menu add: 'make a galley of me' translated action: #makeGalleyStyle.
	].
	^menu
]

{ #category : #private }
GeeMailMorph >> adjustPasteUpSize [

	| newBottom |

	thePasteUp ifNil: [^self].
	newBottom := thePasteUp bottom max: thePasteUp boundingBoxOfSubmorphs bottom + 20.
	thePasteUp height: (newBottom - thePasteUp top max: self height).
	thePasteUp width: (thePasteUp width max: scroller innerBounds width - 5).
]

{ #category : #accessing }
GeeMailMorph >> allTextPlusMorphs [

	^thePasteUp allTextPlusMorphs
]

{ #category : #initialization }
GeeMailMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color white
]

{ #category : #layout }
GeeMailMorph >> doLayoutIn: layoutBounds [
	"layout has changed. update scroll deltas or whatever else"

	self adjustPasteUpSize.
	scroller ifNotNil: [self setScrollDeltas].
	super doLayoutIn: layoutBounds.

]

{ #category : #geometry }
GeeMailMorph >> extraScrollRange [
	^ bounds height

]

{ #category : #menus }
GeeMailMorph >> getMenu: shiftKeyState [

	| menu |
	menu := MenuMorph new defaultTarget: self.
	self addGeeMailMenuItemsTo: menu.
	^menu
]

{ #category : #'event handling' }
GeeMailMorph >> handlesMouseDown: evt [

	^evt yellowButtonPressed 
]

{ #category : #initialization }
GeeMailMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self initializeThePasteUp.
	self position: 100@100.
	self extent: Display extent // 3.
	self useRoundedCorners.
	
]

{ #category : #initialization }
GeeMailMorph >> initializeThePasteUp [
"initialize the receiver's thePasteUp"
	thePasteUp := TextPlusPasteUpMorph new borderWidth: 0;
				 color: color.
	scroller addMorph: thePasteUp
]

{ #category : #menus }
GeeMailMorph >> keepScrollBarAlways [

	^self valueOfProperty: #keepScrollBarAlways ifAbsent: [false]
]

{ #category : #menus }
GeeMailMorph >> keepScrollbarString [

	^self keepScrollBarAlways ifTrue: ['<on>scrollbar stays up'] ifFalse: ['<off>scrollbar stays up']
]

{ #category : #menus }
GeeMailMorph >> makeBookStyle: nColumns [

	| all totalWidth second columnWidth currY prev columnHeight currX currColumn pageBreakRectangles r rm columnGap pageGap starter |

	pageBreakRectangles := OrderedCollection new.
	all := thePasteUp allTextPlusMorphs.
	all size = 1 ifFalse: [^self].
	Cursor wait show.
	starter := prev := all first.
	totalWidth := self width - 16.
	columnGap := 32.
	pageGap := 16.
	columnWidth := totalWidth - (columnGap * (nColumns - 1)) // nColumns.
	columnHeight := self height - 12.
	currY := 4.
	currX := 4.
	currColumn := 1.
	prev
		position: currX@currY;
		width: columnWidth.
	[
		second := prev makeSuccessorMorph.
		thePasteUp addMorphBack: second.
		prev 
			setProperty: #autoFitContents toValue: false;
			height: columnHeight.
		(currColumn := currColumn + 1) <= nColumns ifTrue: [
			currX := currX + columnWidth + columnGap.
		] ifFalse: [
			r := 4@(prev bottom + 4) corner: (self right - 4 @ (prev bottom + pageGap - 4)).
			rm := RectangleMorph new bounds: r; color: (Color gray alpha: 0.3); borderWidth: 0.
			pageBreakRectangles add: rm beSticky.
			thePasteUp addMorphBack: rm.
			currColumn := 1.
			currX := 4.
			currY := prev bottom + pageGap.
		].
		second 
			autoFit: true;
			position: currX@currY;
			width: columnWidth.
		prev recomposeChain.		"was commented"
		prev := second.
		prev height > columnHeight
	] whileTrue.
	prev autoFit: true.
	thePasteUp height: (prev bottom + 20 - self top).
	self layoutChanged.
	self setProperty: #pageBreakRectangles toValue: pageBreakRectangles.
	thePasteUp allTextPlusMorphs do: [ :each |
		each repositionAnchoredMorphs
	].
	Cursor normal show.

]

{ #category : #menus }
GeeMailMorph >> makeGalleyStyle [

	| all first theRest |

	(self valueOfProperty: #pageBreakRectangles ifAbsent: [#()]) do: [ :each |
		each delete
	].
	self removeProperty: #pageBreakRectangles.
	all := thePasteUp allTextPlusMorphs.
	first := all select: [ :x | x predecessor isNil].
	first size = 1 ifFalse: [^self].
	Cursor wait show.
	first := first first.
	theRest := all reject: [ :x | x predecessor isNil].
	theRest do: [ :each | each delete].
	first autoFit: true.
	first width: self width - 8.
	first recomposeChain.
	first repositionAnchoredMorphs.
	Cursor normal show.

]

{ #category : #'event handling' }
GeeMailMorph >> mouseUp: evt inMorph: aMorph [

	evt hand grabMorph: aMorph	"old instances may have a handler we no longer use"
]

{ #category : #printing }
GeeMailMorph >> pageRectanglesForPrinting [

	| pageBreaks pageRects prevBottom |

	pageBreaks := self valueOfProperty: #pageBreakRectangles ifAbsent: [^nil].
	prevBottom := 0.
	pageRects := pageBreaks collect: [ :each | | r |
		r := 0@prevBottom corner: self width @ each top.
		prevBottom := each bottom.
		r
	].
	pageRects add: (0@prevBottom corner: self width @ thePasteUp bottom).
	^pageRects
]

{ #category : #'Postscript Canvases' }
GeeMailMorph >> printPSToFile [

	thePasteUp printer
		geeMail: self;
		doPages
]

{ #category : #'scroll bar events' }
GeeMailMorph >> scrollBarValue: scrollValue [

	| newPt pageBreaks topOfPage |

	scroller hasSubmorphs ifFalse: [^ self].
	newPt := -3 @ (self vLeftoverScrollRange * scrollValue).

	pageBreaks := self valueOfProperty: #pageBreakRectangles ifAbsent: [#()].
	pageBreaks isEmpty ifTrue: [
		^scroller offset: newPt.
	].
	topOfPage := pageBreaks inject: (0@0 corner: 0@0) into: [ :closest :each |
		(each bottom - newPt y) abs < (closest bottom - newPt y) abs ifTrue: [
			each 
		] ifFalse: [
			closest 
		].
	].
	topOfPage ifNotNil: [
		newPt := newPt x @ topOfPage bottom.
		scrollBar value: newPt y / self vLeftoverScrollRange.
	].
	scroller offset: newPt.
]

{ #category : #scrolling }
GeeMailMorph >> scrollSelectionIntoView: event alignTop: alignTop inTextMorph: tm [
	"Scroll my text into view if necessary and return true, else return false"

	| selRects delta selRect rectToTest transform cpHere |

	selRects := tm paragraph selectionRects.
	selRects isEmpty ifTrue: [^ false].
	rectToTest := selRects first merge: selRects last.
	transform := scroller transformFrom: self.
	(event notNil and: [event isMouse and: [event anyButtonPressed]]) ifTrue:  "Check for autoscroll"
		[cpHere := transform localPointToGlobal: event cursorPoint.
		cpHere y <= self top
			ifTrue: [rectToTest := selRects first topLeft extent: 2@2]
			ifFalse: [cpHere y >= self bottom
					ifTrue: [rectToTest := selRects last bottomRight extent: 2@2]
					ifFalse: [^ false]]].
	selRect := transform localBoundsToGlobal: rectToTest.
	selRect height > bounds height
		ifTrue: [^ false].  "Would not fit, even if we tried to scroll"
	alignTop ifTrue: [
		self scrollBy: 0@(bounds top - selRect top).
		^ true
	].
	selRect bottom > bounds bottom ifTrue: [
		self scrollBy: 0@(bounds bottom - selRect bottom - 30).
		^ true
	].
	(delta := selRect amountToTranslateWithin: self bounds) y ~= 0 ifTrue: [
		"Scroll end of selection into view if necessary"
		self scrollBy: 0@delta y.
		^ true].
	^ false
]

{ #category : #scrolling }
GeeMailMorph >> scrollToPage: pageNumber [

	| rects oneRect |

	rects := self valueOfProperty: #pageBreakRectangles ifAbsent: [#()].
	oneRect := rects at: pageNumber - 1 ifAbsent: [0@0 extent: 0@0].
	self scrollToYAbsolute: oneRect bottom.

]

{ #category : #scrolling }
GeeMailMorph >> scrollToYAbsolute: yValue [

	| transform transformedPoint |

	transform := scroller transformFrom: self.
	transformedPoint := transform localPointToGlobal: 0@yValue.

	self scrollBy: 0@(bounds top - transformedPoint y).

]

{ #category : #menus }
GeeMailMorph >> showPageBreaksString [

	^(thePasteUp ifNil: [^'???']) showPageBreaksString
]

{ #category : #menus }
GeeMailMorph >> toggleKeepScrollbar [

	self setProperty: #keepScrollBarAlways toValue: self keepScrollBarAlways not
]

{ #category : #menus }
GeeMailMorph >> togglePageBreaks [

	(thePasteUp ifNil: [^self]) togglePageBreaks
]

{ #category : #scrolling }
GeeMailMorph >> vHideScrollBar [

	self keepScrollBarAlways ifTrue: [^self].
	^super vHideScrollBar
]

{ #category : #'dropping\/grabbing' }
GeeMailMorph >> wantsDroppedMorph: aMorph event: evt [
	"Return true if the receiver wishes to accept the given morph, which is being dropped by a hand in response to the given event. The default implementation returns false.
NOTE: the event is assumed to be in global (world) coordinates."

	^false
]

{ #category : #accessing }
GeeMailMorph >> wantsSlot [

	^false
]
