"
A subclass of WiWPasteUpMorph that supports Morphic worlds embedded in MVC Views.
"
Class {
	#name : #MVCWiWPasteUpMorph,
	#superclass : #WiWPasteUpMorph,
	#category : #'Etoys-Squeakland-ST80-Morphic'
}

{ #category : #activation }
MVCWiWPasteUpMorph >> becomeTheActiveWorldWith: evt [

	worldState canvas: nil.	"safer to start from scratch"
	self installFlaps.


]

{ #category : #'change reporting' }
MVCWiWPasteUpMorph >> invalidRect: damageRect from: aMorph [

	worldState ifNil: [^self].
	worldState recordDamagedRect: damageRect

]

{ #category : #geometry }
MVCWiWPasteUpMorph >> position: aPoint [
	"Change the position of this morph and and all of its submorphs."

	| delta |
	delta := aPoint - bounds topLeft.
	(delta x = 0 and: [delta y = 0]) ifTrue: [^ self].  "Null change"
	self changed.
	self privateFullMoveBy: delta.
	self changed.

]

{ #category : #project }
MVCWiWPasteUpMorph >> project [
	^ Project current
]

{ #category : #geometry }
MVCWiWPasteUpMorph >> resetViewBox [
	| c |
	(c := worldState canvas) isNil ifTrue: [^self resetViewBoxForReal].
	c form == Display ifFalse: [^self resetViewBoxForReal].
	c origin = (0 @ 0) ifFalse: [^self resetViewBoxForReal].
	c clipRect extent = self viewBox extent 
		ifFalse: [^self resetViewBoxForReal]
]

{ #category : #geometry }
MVCWiWPasteUpMorph >> resetViewBoxForReal [

	self viewBox ifNil: [^self].
	worldState canvas: (
		(Display getCanvas)
			copyOffset:  0@0
			clipRect: self viewBox
	)
]

{ #category : #activation }
MVCWiWPasteUpMorph >> revertToParentWorldWithEvent: evt [

">>unused, but we may want some of this later
	self damageRecorder reset.
	World := parentWorld.
	World assuredCanvas.
	World installFlaps.
	owner changed.
	hostWindow setStripeColorsFrom: Color red.
	World restartWorldCycleWithEvent: evt.
<<<"


]

{ #category : #'project state' }
MVCWiWPasteUpMorph >> viewBox: newViewBox [ 
	| vb |
	worldState resetDamageRecorder.	"since we may have moved, old data no longer valid"
	((vb := self viewBox) isNil or: [vb ~= newViewBox]) 
		ifTrue: [worldState canvas: nil].
	worldState viewBox: newViewBox.
	self bounds: newViewBox.	"works better here than simply storing into bounds"
	worldState assuredCanvas.
	"Paragraph problem workaround; clear selections to avoid screen droppings:"
	self flag: #arNote.	"Probably unnecessary"
	worldState handsDo: [:h | h releaseKeyboardFocus].
	self fullRepaintNeeded
]

{ #category : #'as yet unclassified' }
MVCWiWPasteUpMorph >> worldUnderCursor [

        ^self
]
