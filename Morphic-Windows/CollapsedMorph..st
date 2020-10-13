Class {
	#name : #CollapsedMorph,
	#superclass : #SystemWindow,
	#instVars : [
		'uncollapsedMorph'
	],
	#category : #'Morphic-Windows'
}

{ #category : #'instance creation' }
CollapsedMorph class >> createReplacementFor: aMorph in: anOwner [

	^ self new
		beReplacementFor: aMorph in: anOwner;
		yourself
]

{ #category : #'collapse\/expand' }
CollapsedMorph >> beReplacementFor: aMorph [
	"Encapsulate aMorph with the CollapsedMorph and display the latter"

	| itsWorld |
	(itsWorld := aMorph world) ifNil: [^self].
	self beReplacementFor: aMorph in: itsWorld.
]

{ #category : #'collapse\/expand' }
CollapsedMorph >> beReplacementFor: aMorph in: anOwner [
	"Encapsulate aMorph with the CollapsedMorph and display the latter in anOwner"

	| priorPosition |
	uncollapsedMorph := aMorph.
	
	self setLabel: aMorph externalName.
	aMorph delete.
	self privateOwner: anOwner. "lest RealEstateAgent fail at positioning me"
	self collapseOrExpand.
	anOwner addMorphFront: self.
	(priorPosition := aMorph valueOfProperty: #collapsedPosition ifAbsent: [nil])
		ifNotNil: [self position: priorPosition].
]

{ #category : #menu }
CollapsedMorph >> buildWindowMenu [
	"Answer the menu to be put up in response to the user's clicking on the window-menu control in the window title.  Specialized for CollapsedMorphs."

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu add: 'change name...' translated action: #relabel.
	aMenu addLine.
	aMenu add: 'send to back' translated action: #sendToBack.
	aMenu add: 'make next-to-topmost' translated action: #makeSecondTopmost.
	aMenu addLine.
	self mustNotClose
		ifFalse:
			[aMenu add: 'make unclosable' translated action: #makeUnclosable]
		ifTrue:
			[aMenu add: 'make closable' translated action: #makeClosable].
	aMenu
		add: (self isSticky ifTrue: ['make draggable'] ifFalse: ['make undraggable']) translated 
		action: #toggleStickiness.
	^aMenu
]

{ #category : #adjusting }
CollapsedMorph >> centerWithWrappees: aPoint [

	self center: aPoint.
	uncollapsedMorph center: aPoint.
]

{ #category : #'resize\/collapse' }
CollapsedMorph >> collapseOrExpand [
	"Toggle the expand/collapsd state of the receiver.  If expanding, copy the window title back to the name of the expanded morph"

	| aWorld |
	isCollapsed
		ifTrue: 
			[uncollapsedMorph setProperty: #collapsedPosition toValue: self position.
			labelString ifNotNil: [uncollapsedMorph setNameTo: labelString].
			mustNotClose := false.	"We're not closing but expanding"
			self delete.
			(aWorld := self currentWorld) addMorphFront: uncollapsedMorph.
			aWorld startSteppingSubmorphsOf: uncollapsedMorph]
		ifFalse:
			[super collapseOrExpand]
]

{ #category : #'collapse\/expand' }
CollapsedMorph >> uncollapseToHand [
	"Hand the uncollapsedMorph to the user, placing it in her hand, after remembering appropriate state for possible future use"

	| nakedMorph |
	nakedMorph := uncollapsedMorph.
	uncollapsedMorph := nil.
	nakedMorph setProperty: #collapsedPosition toValue: self position.
	mustNotClose := false.  "so the delete will succeed"
	self delete.
	self currentHand attachMorph: nakedMorph.
]

{ #category : #accessing }
CollapsedMorph >> uncollapsedMorph [

	^ uncollapsedMorph
]

{ #category : #'resize\/collapse' }
CollapsedMorph >> wantsExpandBox [
	"Answer whether I'd like an expand box"

	^ false
]
