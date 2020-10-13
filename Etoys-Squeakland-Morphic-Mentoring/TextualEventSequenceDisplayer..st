"
A tool that displays the events comprising a mouse-event-sequence in a scrolling textual list.  This is not an editor, not yet anyway...  Consider it a tantalizing loose end at the moment.
"
Class {
	#name : #TextualEventSequenceDisplayer,
	#superclass : #AlignmentMorph,
	#instVars : [
		'mouseEventSequenceMorph'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #initialization }
TextualEventSequenceDisplayer >> mouseEventSequenceMorph: aMorph [
	"Set the mouseEventSequenceMorph, and hence build the receiver."

	| aString ptm |
	mouseEventSequenceMorph := aMorph.
	self hResizing: #shrinkWrap.
	self vResizing: #shrinkWrap.
	aString := String streamContents:
		[:aStream | 
			aMorph events do:
				[:evt | aStream nextPutAll: evt printString.  aStream cr]].

	ptm := PluggableTextMorph new.
	ptm borderWidth: 2.
	ptm extent: 400 @ 100.
	ptm setBalloonText: 'Each line represents an event in the event sequence I represent' translated.
	ptm color: (Color r: 0.806 g: 1.0 b: 1.0).
	ptm editString: aString.
	ptm retractable: false; scrollBarOnLeft: false.
	ptm borderWidth: 2.
	ptm borderColor: ptm color muchDarker; cornerStyle: #rounded.
	
	self addMorphCentered: ptm
]

{ #category : #resizing }
TextualEventSequenceDisplayer >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed."

	submorphs first setExtentFromHalo: anExtent
]

{ #category : #'drag and drop' }
TextualEventSequenceDisplayer >> wantsToBeDroppedInto: aMorph [
	"Return true if it's okay to drop the receiver into a prospective recipient."

	^ aMorph isWorldMorph "only into worlds"
]
