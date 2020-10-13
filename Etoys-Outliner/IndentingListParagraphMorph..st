Class {
	#name : #IndentingListParagraphMorph,
	#superclass : #IndentingListItemMorph,
	#category : #'Etoys-Outliner'
}

{ #category : #'new-morph participation' }
IndentingListParagraphMorph class >> includeInNewMorphMenu [

	^ false
]

{ #category : #'as yet unclassified' }
IndentingListParagraphMorph >> desiredHeight [

	submorphs isEmpty ifTrue: [^self height].
	"isExpanded ifFalse: [^self height]."
	^complexContents withoutListWrapper height "max: self height"

]

{ #category : #drawing }
IndentingListParagraphMorph >> drawOn: aCanvas [

	self drawToggleOn: aCanvas in: self toggleRectangle.

]

{ #category : #drawing }
IndentingListParagraphMorph >> drawToggleOn: aCanvas in: aRectangle [

	| aForm |

	aCanvas 
		fillRectangle: (bounds withRight: aRectangle right)
		color: container color.
	complexContents hasContents ifFalse: [^self].
	aForm := isExpanded 
		ifTrue: [container expandedForm]
		ifFalse: [container notExpandedForm].
	^aCanvas 
		paintImage: aForm 
		at: aRectangle topLeft

]

{ #category : #initialization }
IndentingListParagraphMorph >> initWithContents: anObject prior: priorMorph forList: hostList indentLevel: newLevel [

	super initWithContents: anObject prior: priorMorph forList: hostList indentLevel: newLevel.
	self width: hostList width.
	complexContents withoutListWrapper firstDisplay ifTrue: [
		complexContents withoutListWrapper firstDisplayedOnLevel: indentLevel.
		isExpanded := true.
	].
	complexContents withoutListWrapper showInOpenedState ifTrue: [
		isExpanded := true.
	].
	self addMorph: self repositionText.


]

{ #category : #'as yet unclassified' }
IndentingListParagraphMorph >> isExpanded: aBoolean [

	| tm |
	super isExpanded: aBoolean.
	tm := self repositionText.
	isExpanded ifFalse: [
		self height: tm height.
	].
	self addMorph: tm.
	"tm clipToOwner: isExpanded not."		"not really working right yet"


]

{ #category : #'event handling' }
IndentingListParagraphMorph >> keyStroke: evt [

	| char |
	char := evt keyCharacter.
	evt controlKeyPressed ifTrue: [
		char = Character cr ifTrue: [
			container model addSibling.
			^true	"we did handle it"
		].
		char = Character tab ifTrue: [
			container model addNewChildAfter: 0.
			^true	"we did handle it"
		].
	].
	^false	"we did not handle it"

]

{ #category : #layout }
IndentingListParagraphMorph >> layoutChanged [

	super layoutChanged.
	submorphs isEmpty ifTrue: [^self].
	self desiredHeight = self height ifTrue: [^self].
	self height: self desiredHeight.
	container adjustSubmorphPositions.

]

{ #category : #'as yet unclassified' }
IndentingListParagraphMorph >> position: p andWidth: w [

	| widthChanged |

	widthChanged := self width ~= w.
	self position: p.
	self width: w.
	submorphs isEmpty ifTrue: [^self height].
	widthChanged ifTrue: [
		self repositionText.
	].
	self height: self desiredHeight.
	^self desiredHeight

]

{ #category : #'as yet unclassified' }
IndentingListParagraphMorph >> repositionText [

	| sRect tm |
	sRect := self textMorphBounds.
	(tm := complexContents withoutListWrapper)
		"clipToOwner: isExpanded not;"
		position: sRect origin;
		width: sRect width.
	isExpanded ifTrue: [
		tm extent: sRect width@10.
		tm contents: tm contents wrappedTo: sRect width.
		tm extent: sRect width@10.
	] ifFalse: [
		tm contentsAsIs: tm contents.
		tm extent: tm extent.		"force bounds recompute"
	].
	tm lock: isExpanded not.
"{tm. tm bounds. sRect} explore."
	^tm

]

{ #category : #'as yet unclassified' }
IndentingListParagraphMorph >> takeFocus [

	container setSelectedMorph: self
]

{ #category : #'as yet unclassified' }
IndentingListParagraphMorph >> textMorphBounds [

	^(bounds withRight: self right - 4)
		 withLeft: self textMorphLeft.

]

{ #category : #'as yet unclassified' }
IndentingListParagraphMorph >> textMorphLeft [
	
	^self toggleRectangle right + 3

]

{ #category : #'as yet unclassified' }
IndentingListParagraphMorph >> toggleExpandedState [

	super toggleExpandedState.
	self isExpanded: isExpanded.

]
