Class {
	#name : #BorderedSubpaneDividerMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'resizingEdge'
	],
	#category : #'Morphic-Windows'
}

{ #category : #'instance creation' }
BorderedSubpaneDividerMorph class >> forBottomEdge [
	^self new horizontal resizingEdge: #bottom
]

{ #category : #'instance creation' }
BorderedSubpaneDividerMorph class >> forTopEdge [
	^self new horizontal resizingEdge: #top
]

{ #category : #'instance creation' }
BorderedSubpaneDividerMorph class >> horizontal [
	^self new horizontal
]

{ #category : #'instance creation' }
BorderedSubpaneDividerMorph class >> vertical [
	^self new vertical
]

{ #category : #initialization }
BorderedSubpaneDividerMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 0
]

{ #category : #initialization }
BorderedSubpaneDividerMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color black
]

{ #category : #private }
BorderedSubpaneDividerMorph >> firstEnter: evt [
	"The first time this divider is activated, find its window and redirect further interaction there."
	| window |

	window := self firstOwnerSuchThat: [:m | m respondsTo: #secondaryPaneTransition:divider:].
	window ifNil: [ self suspendEventHandler. ^ self ]. "not working out"
	window secondaryPaneTransition: evt divider: self.
	self on: #mouseEnter send: #secondaryPaneTransition:divider: to: window.

]

{ #category : #layout }
BorderedSubpaneDividerMorph >> horizontal [

	self hResizing: #spaceFill.
]

{ #category : #initialization }
BorderedSubpaneDividerMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
""
	self extent: 1 @ 1
]

{ #category : #accessing }
BorderedSubpaneDividerMorph >> resizingEdge [

	^resizingEdge

]

{ #category : #accessing }
BorderedSubpaneDividerMorph >> resizingEdge: edgeSymbol [

	(#(top bottom) includes: edgeSymbol) ifFalse:
		[ self error: 'resizingEdge must be #top or #bottom' ].
	resizingEdge := edgeSymbol.
	self on: #mouseEnter send: #firstEnter: to: self.

]

{ #category : #layout }
BorderedSubpaneDividerMorph >> vertical [

	self vResizing: #spaceFill.
]
