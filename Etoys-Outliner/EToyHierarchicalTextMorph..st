Class {
	#name : #EToyHierarchicalTextMorph,
	#superclass : #SimpleHierarchicalListMorph,
	#category : #'Etoys-Outliner'
}

{ #category : #'instance creation' }
EToyHierarchicalTextMorph class >> new [

	| listMorph model |

	model := EToyHierarchicalTextGizmo new 
		topNode: EToyTextNode newNode.
	(listMorph := EToyHierarchicalTextMorph 
		on: model
		list: #getList
		selected: #getCurrentSelection
		changeSelected: #noteNewSelection:
		menu: #genericMenu:
		keystroke: nil).
	listMorph autoDeselect: false.
     ^ listMorph
]

{ #category : #'instance creation' }
EToyHierarchicalTextMorph class >> on: anObject list: getListSel selected: getSelectionSel changeSelected: setSelectionSel menu: getMenuSel keystroke: keyActionSel [
	"Create a 'pluggable' list view on the given model parameterized by the given message selectors."

	^ self basicNew initialize
		on: anObject
		list: getListSel
		selected: getSelectionSel
		changeSelected: setSelectionSel
		menu: getMenuSel
		keystroke: keyActionSel

]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextMorph >> adjustSubmorphPositions [

	| w p |

	p := 0@0.
	w := self width.
	scroller submorphsDo: [ :each | | h |
		h := each position: p andWidth: w.
		p := p + (0@h)
	].
	self 
		changed;
		layoutChanged;
		setScrollDeltas.

]

{ #category : #initialization }
EToyHierarchicalTextMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color white
]

{ #category : #geometry }
EToyHierarchicalTextMorph >> extent: aPoint [

	| wasDifferent |
	wasDifferent := self extent ~= aPoint.
	super extent: aPoint.
	wasDifferent ifTrue: [self adjustSubmorphPositions].
]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextMorph >> indentingItemClass [

	^IndentingListParagraphMorph
]

{ #category : #initialization }
EToyHierarchicalTextMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	self useRoundedCorners
]

{ #category : #'event handling' }
EToyHierarchicalTextMorph >> keyStroke: evt [

	selectedMorph ifNil: [^self].
	selectedMorph keyStroke: evt

]

{ #category : #selection }
EToyHierarchicalTextMorph >> selectedMorph: aMorph [

	selectedMorph == aMorph ifTrue: [^self].
	self unhighlightSelection.
	selectedMorph := aMorph.
	self highlightSelection
]
