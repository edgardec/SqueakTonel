"
EToyHierarchicalTextGizmo example
"
Class {
	#name : #EToyHierarchicalTextGizmo,
	#superclass : #AbstractHierarchicalList,
	#instVars : [
		'topNode'
	],
	#category : #'Etoys-Outliner'
}

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo class >> example [
"
EToyHierarchicalTextGizmo example
"

	(EToyHierarchicalTextGizmo new 
		topNode: EToyTextNode newNode;
		notInAWindow) openInWorld
]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo >> addChild [

	self addNewChildAfter: nil.

]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo >> addNewChildAfter: aNodeOrNil [

	currentSelection addNewChildAfter: aNodeOrNil.
	self changed: #getList.
]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo >> addSibling [

	currentSelection addSibling.
	self changed: #getList.
]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo >> deleteSelectedItem [

	currentSelection delete.
	self changed: #getList.
]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo >> expandAllBelow [

	currentSelection withoutListWrapper withAllChildrenDo: [ :each |
		each setProperty: #showInOpenedState toValue: true
	].
	self changed: #getList.
]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo >> genericMenu: aMenu [

	| menu |

	currentSelection ifNil: [
		aMenu add: '*nothing selected*' target: self selector: #yourself.
		^aMenu
	].
	menu := DumberMenuMorph new defaultTarget: self.
	menu 
		add: 'expand all below me' target: self selector: #expandAllBelow;
		add: 'addChild' target: self selector: #addChild;
		add: 'delete' target: self  selector: #deleteSelectedItem.
	^ menu
]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo >> getList [

	^Array with: (EToyTextNodeWrapper with: topNode model: self parent: nil)

]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo >> inAWindow [
	| window  |

	window := (SystemWindow labelled: 'HText') model: self.
	window 
		addMorph: self notInAWindow
		frame: (0@0 corner: 1@1).
     ^ window
]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo >> notInAWindow [
	| listMorph |

	(listMorph := EToyHierarchicalTextMorph 
		on: self
		list: #getList
		selected: #getCurrentSelection
		changeSelected: #noteNewSelection:
		menu: #genericMenu:
		keystroke: nil).
	listMorph autoDeselect: false.
     ^ listMorph
]

{ #category : #'as yet unclassified' }
EToyHierarchicalTextGizmo >> topNode: aTextNode [

	topNode := aTextNode
]
