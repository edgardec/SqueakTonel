"
An EventTimeline is the scrollable surface on which the events are laid out in the EventRoll.
"
Class {
	#name : #EventTimeline,
	#superclass : #PasteUpMorph,
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #'dropping\/grabbing' }
EventTimeline >> acceptDroppingMorph: aMorph event: evt [
	"Accept the drop of a morph."

	| aRect anEventRoll itsDuration itsWidthAfterDrop |
	self flag: #deferred.  "This is a possible place for discovering whether the drop would have damaging effects on the mouse track..."

	(aMorph isKindOf: MouseEventSequenceMorph)
		ifTrue:
			[itsDuration := aMorph durationInMilliseconds.
			itsWidthAfterDrop := itsDuration // self eventRoll millisecondsPerPixel.
			super acceptDroppingMorph: aMorph event: evt.
			aMorph bounds: ((aMorph left @ 6) extent: (itsWidthAfterDrop @ aMorph height)).
			submorphs do:
				[:m |
					((m ~~ aMorph) and: [m isKindOf: MouseEventSequenceMorph])
						ifTrue:
							[(m bounds intersects: aMorph bounds)
								ifTrue:
									["Eureka"
									aMorph delete.
									aMorph position: 100@100.
									aMorph openInWorld.
									aMorph flash.
									^ self]]]]
		ifFalse:
			[super acceptDroppingMorph: aMorph event: evt]
.
	aRect := (((aMorph left + 10) max: 10) @ 0) extent: 100@ 10.

	(anEventRoll  := self eventRoll) pushChangesBackToEventTheatre.  "Note that will ultimately result in replacement of the receiver by a new timeline"
	aMorph delete.
	self currentWorld abandonAllHalos.
	anEventRoll scrollPaneForRoll scrollHorizontallyToShow: aRect
]

{ #category : #'dropping\/grabbing' }
EventTimeline >> defaultNameStemForInstances [
	"Answer the default name on which to base names."

	^ 'event timeline' translatedNoop
]

{ #category : #'dropping\/grabbing' }
EventTimeline >> wantsDroppedMorph: aMorph event: evt [
	"Return true if the receiver wishes to accept the given morph, which is being dropped by a hand in response to the given event. Note that for a successful drop operation both parties need to agree. The symmetric check is done automatically via aMorph wantsToBeDroppedInto: self."

	^ aMorph suitableForDroppingIntoEventRoll
]
