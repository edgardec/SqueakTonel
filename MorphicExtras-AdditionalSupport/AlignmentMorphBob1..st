"
A quick and easy way to space things vertically in absolute or proportional amounts.
"
Class {
	#name : #AlignmentMorphBob1,
	#superclass : #AlignmentMorph,
	#category : #'MorphicExtras-AdditionalSupport'
}

{ #category : #'dropping\/grabbing' }
AlignmentMorphBob1 >> acceptDroppingMorph: aMorph event: evt [

	| handlerForDrops |

	handlerForDrops := self valueOfProperty: #handlerForDrops ifAbsent: [
		^super acceptDroppingMorph: aMorph event: evt
	].
	(handlerForDrops acceptDroppingMorph: aMorph event: evt inMorph: self) ifFalse: [
		aMorph rejectDropMorphEvent: evt.		"send it back where it came from"
	].
]

{ #category : #'ui construction' }
AlignmentMorphBob1 >> addAColumn: aCollectionOfMorphs [

	| col |
	col := self inAColumn: aCollectionOfMorphs.
	self addMorphBack: col.
	^col
]

{ #category : #'ui construction' }
AlignmentMorphBob1 >> addARow: aCollectionOfMorphs [

	| row |
	row := self inARow: aCollectionOfMorphs.
	self addMorphBack: row.
	^row
]

{ #category : #'ui construction' }
AlignmentMorphBob1 >> addARowCentered: aCollectionOfMorphs [

	^(self addARow: aCollectionOfMorphs)
		hResizing: #shrinkWrap;
		wrapCentering: #center;
		cellPositioning: #leftCenter
]

{ #category : #'ui construction' }
AlignmentMorphBob1 >> addARowCentered: aCollectionOfMorphs cellInset: cellInsetInteger [

	^(self addARow: aCollectionOfMorphs)
		hResizing: #shrinkWrap;
		wrapCentering: #center;
		cellPositioning: #leftCenter;
		cellInset: cellInsetInteger
]

{ #category : #'ui construction' }
AlignmentMorphBob1 >> fancyText: aString font: aFont color: aColor [ 
	| answer tm col |
	col := Preferences menuAppearance3d
				ifTrue: [aColor]
				ifFalse: [aColor negated].
	tm := TextMorph new.
	tm beAllFont: aFont;
		 color: col;
		 contents: aString.
	answer := self inAColumn: {tm}.
	Preferences menuAppearance3d
		ifTrue: [""
			tm addDropShadow.
			tm shadowPoint: 5 @ 5 + tm bounds center].
	tm lock.
	^ answer
]

{ #category : #drawing }
AlignmentMorphBob1 >> fullDrawOn: aCanvas [

	| mask |
	(aCanvas isVisible: self fullBounds) ifFalse:[^self].
	super fullDrawOn: aCanvas.
	mask := self valueOfProperty: #disabledMaskColor ifAbsent: [^self].
	aCanvas fillRectangle: bounds color: mask.

]

{ #category : #'ui construction' }
AlignmentMorphBob1 >> inAColumn: aCollectionOfMorphs [

	| col |
	col := AlignmentMorph newColumn
		color: Color transparent;
		vResizing: #shrinkWrap;
		layoutInset: 1;
		wrapCentering: #center;
		cellPositioning: #topCenter.
	aCollectionOfMorphs do: [ :each | col addMorphBack: each].
	^col
]

{ #category : #'ui construction' }
AlignmentMorphBob1 >> inARightColumn: aCollectionOfMorphs [ 
	| col |
	col := AlignmentMorph newColumn color: Color transparent;
				 vResizing: #shrinkWrap;
				 layoutInset: 1;
				 wrapCentering: #bottomRight;
				 cellPositioning: #topCenter.
	aCollectionOfMorphs
		do: [:each | col addMorphBack: each].
	^ col
]

{ #category : #'ui construction' }
AlignmentMorphBob1 >> inARow: aCollectionOfMorphs [ 
	| row |
	row := AlignmentMorph newRow color: Color transparent;
				 vResizing: #shrinkWrap;
				 layoutInset: 2;
				 wrapCentering: #center;
				 cellPositioning: #leftCenter.
	aCollectionOfMorphs
		do: [:each | each ifNotNil: [row addMorphBack: each]].
	^ row
]

{ #category : #initialization }
AlignmentMorphBob1 >> initialize [
	super initialize.
	self listDirection: #topToBottom.
	self layoutInset: 0.
	self hResizing: #rigid. "... this is very unlikely..."
	self vResizing: #rigid
]

{ #category : #'ui construction' }
AlignmentMorphBob1 >> simpleToggleButtonFor: target attribute: attribute help: helpText [

	^(Smalltalk at: #EtoyUpdatingThreePhaseButtonMorph ifAbsent:[^Morph new])
		checkBox
		target: target;
		actionSelector: #toggleChoice:;
		arguments: {attribute};
		getSelector: #getChoice:;
		setBalloonText: helpText;
		step


]

{ #category : #'dropping\/grabbing' }
AlignmentMorphBob1 >> wantsDroppedMorph: aMorph event: evt [

	| handlerForDrops |

	handlerForDrops := self valueOfProperty: #handlerForDrops ifAbsent: [
		^super wantsDroppedMorph: aMorph event: evt
	].
	^handlerForDrops wantsDroppedMorph: aMorph event: evt inMorph: self
]
