Class {
	#name : #GraphicalMenu,
	#superclass : #AlignmentMorph,
	#instVars : [
		'target',
		'selector',
		'argument',
		'currentIndex',
		'formChoices',
		'formDisplayMorph',
		'coexistWithOriginal'
	],
	#category : #'MorphicExtras-AdditionalWidgets'
}

{ #category : #accessing }
GraphicalMenu >> argument [
	^argument
]

{ #category : #accessing }
GraphicalMenu >> argument: anObject [
	argument := anObject
]

{ #category : #'event handling' }
GraphicalMenu >> cancel [
	coexistWithOriginal
		ifTrue:
			[self delete]
		ifFalse:
			[owner replaceSubmorph: self topRendererOrSelf by: target]
]

{ #category : #initialization }
GraphicalMenu >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color blue darker
]

{ #category : #initialization }
GraphicalMenu >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
GraphicalMenu >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color white
]

{ #category : #'event handling' }
GraphicalMenu >> downArrowHit [
	currentIndex := currentIndex - 1.
	(currentIndex < 1) ifTrue:  [currentIndex := formChoices size].
	self updateThumbnail
	

]

{ #category : #initialization }
GraphicalMenu >> initialize [
	super initialize.
	selector := #newForm:.
]

{ #category : #initialization }
GraphicalMenu >> initializeFor: aTarget withForms: formList coexist: aBoolean [ 
	"World primaryHand attachMorph:
		(GraphicalMenu new initializeFor: nil  
		withForms: Form allInstances coexist: true)"
	| buttons bb anIndex buttonCage |
	target := aTarget.
	coexistWithOriginal := aBoolean.
	formChoices := formList.
	currentIndex := 1.
	self borderWidth: 1;
		 cellPositioning: #center;
		 color: Color white;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap.
	buttons := AlignmentMorph newRow.
	buttons borderWidth: 0;
		 layoutInset: 0.
	buttons hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 extent: 5 @ 5.
	buttons wrapCentering: #topLeft.
	buttonCage := AlignmentMorph newColumn.
	buttonCage hResizing: #shrinkWrap;
		 vResizing: #spaceFill.
	buttonCage addTransparentSpacerOfSize: 0 @ 10.
	bb := SimpleButtonMorph new target: self;
				 borderColor: Color black.
	buttons addMorphBack: (bb label: 'Prev' translated;
			 actionSelector: #downArrowHit;
			 actWhen: #whilePressed).
	buttons addTransparentSpacerOfSize: 9 @ 0.
	bb := SimpleButtonMorph new target: self;
				 borderColor: Color black.
	buttons addMorphBack: (bb label: 'Next' translated;
			 actionSelector: #upArrowHit;
			 actWhen: #whilePressed).
	buttons addTransparentSpacerOfSize: 5 @ 0.
	buttons submorphs last color: Color white.
	buttonCage addMorphBack: buttons.
	buttonCage addTransparentSpacerOfSize: 0 @ 12.
	buttons := AlignmentMorph newRow.
	bb := SimpleButtonMorph new target: self;
				 borderColor: Color black.
	buttons addMorphBack: (bb label: 'OK' translated;
			 actionSelector: #okay).
	buttons addTransparentSpacerOfSize: 5 @ 0.
	bb := SimpleButtonMorph new target: self;
				 borderColor: Color black.
	buttons addMorphBack: (bb label: 'Cancel' translated;
			 actionSelector: #cancel).
	buttonCage addMorphBack: buttons.
	buttonCage addTransparentSpacerOfSize: 0 @ 10.
	self addMorphFront: buttonCage.
	formDisplayMorph := Thumbnail new extent: 100 @ 100;
				 maxWidth: 100 minHeight: 30;
				 yourself.
	self addMorphBack: (Morph new color: Color white;
			 layoutPolicy: TableLayout new;
			 layoutInset: 4 @ 4;
			 hResizing: #spaceFill;
			 vResizing: #spaceFill;
			 listCentering: #center;
			 addMorphBack: formDisplayMorph;
			 yourself).
	target
		ifNotNil: [(anIndex := formList
						indexOf: target form
						ifAbsent: [])
				ifNotNil: [currentIndex := anIndex]].
	self updateThumbnail
]

{ #category : #'event handling' }
GraphicalMenu >> okay [
	| nArgs |
	target ifNotNil:[
		nArgs := selector numArgs.
		nArgs = 1 ifTrue:[target perform: selector with: (formChoices at: currentIndex)].
		nArgs = 2 ifTrue:[target perform: selector with: (formChoices at: currentIndex) with: argument]].
	coexistWithOriginal
		ifTrue:
			[self delete]
		ifFalse:
			[owner replaceSubmorph: self topRendererOrSelf by: target]
]

{ #category : #accessing }
GraphicalMenu >> selector [
	^selector
]

{ #category : #accessing }
GraphicalMenu >> selector: aSymbol [
	selector := aSymbol
]

{ #category : #'event handling' }
GraphicalMenu >> upArrowHit [
	currentIndex := currentIndex + 1.
	(currentIndex > formChoices size) ifTrue: [currentIndex := 1].
	self updateThumbnail
	

]

{ #category : #'event handling' }
GraphicalMenu >> updateThumbnail [
	| f |
	f := formChoices at: currentIndex.
	formDisplayMorph 
		makeThumbnailFromForm: f.

]
