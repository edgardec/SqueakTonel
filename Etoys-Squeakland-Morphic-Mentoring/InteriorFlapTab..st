"
A Flap Tab that clings to an edge of a PasteUpMorph that is not a World.
"
Class {
	#name : #InteriorFlapTab,
	#superclass : #FlapTab,
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #'show & hide' }
InteriorFlapTab >> hideFlap [
	"Close the flap."

	self privateDeleteReferent.
	flapShowing := false.
	self adjustPositionAfterHidingFlap
]

{ #category : #'show & hide' }
InteriorFlapTab >> maybeHideFlapOnMouseLeaveDragging [
	"After the mouse leaves, having dragged something out, perhaps close the flap."

	| aPasteUpMorph |
	self hasHalo ifTrue: [^ self].
	referent isInWorld ifFalse: [^ self].
	(dragged or: [referent bounds containsPoint: self cursorPoint])
		ifTrue:	[^ self].
	aPasteUpMorph := self pasteUpMorph.
	self privateDeleteReferent.  "could make me worldless if I'm inboard"
	aPasteUpMorph ifNotNil: [aPasteUpMorph removeAccommodationForFlap: self].
	flapShowing := false.
	self isInWorld ifFalse: [aPasteUpMorph  ifNotNil: [aPasteUpMorph addMorphFront: self]].
	self adjustPositionAfterHidingFlap
]

{ #category : #'event handling' }
InteriorFlapTab >> mouseMove: evt [
	"Handle a mouseMove event in the flap tab."

	| aPosition newReferentThickness adjustedPosition thick relativePosition |
	dragged ifFalse: [(thick := self referentThickness) > 0
			ifTrue: [lastReferentThickness := thick]].
	((self containsPoint: (aPosition := evt cursorPoint)) and: [dragged not])
		ifFalse:
			[flapShowing ifFalse: [self showFlap].
			relativePosition := aPosition - evt hand targetOffset.
			adjustedPosition := aPosition - (owner position + evt hand targetOffset).
			(edgeToAdhereTo == #bottom)
				ifTrue:
					[newReferentThickness := inboard
						ifTrue:
							[owner height - adjustedPosition y]
						ifFalse:
							[owner height - adjustedPosition y - self height]].

			(edgeToAdhereTo == #left)
					ifTrue:
						[newReferentThickness :=
							inboard
								ifTrue:
									[adjustedPosition x + self width]
								ifFalse:
									[adjustedPosition x]].

			(edgeToAdhereTo == #right)
					ifTrue:
						[newReferentThickness :=
							inboard
								ifTrue:
									[owner width - adjustedPosition x]
								ifFalse:
									[owner width - adjustedPosition x - self width]].

			(edgeToAdhereTo == #top)
					ifTrue:
						[newReferentThickness :=
							inboard
								ifTrue:
									[adjustedPosition y + self height]
								ifFalse:
									[adjustedPosition y]].
		
			self isCurrentlySolid ifFalse:
				[(#(left right) includes: edgeToAdhereTo)
					ifFalse:
						[self left: relativePosition x]
					ifTrue:
						[self top: relativePosition y]].

			self applyThickness: newReferentThickness.
			dragged := true.
			self fitOnScreen.
			self computeEdgeFraction]
]

{ #category : #positioning }
InteriorFlapTab >> positionObject: anObject atEdgeOf: container [
        "anObject could be myself (the flap tab) or my referent (the flap body)."

	anObject == self ifTrue: [^ super positionObject: anObject atEdgeOf: container].  "The tab itself"

	(#(top left) includes: edgeToAdhereTo) ifTrue:
		[^ anObject topLeft: container innerBounds topLeft].

	(edgeToAdhereTo = #bottom) ifTrue:
		[^ anObject bottomLeft: container innerBounds bottomLeft].

	anObject topRight: container innerBounds topRight
]
