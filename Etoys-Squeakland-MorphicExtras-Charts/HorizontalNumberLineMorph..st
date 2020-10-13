"
A number line horizontally oriented.
"
Class {
	#name : #HorizontalNumberLineMorph,
	#superclass : #NumberLineMorph,
	#category : #'Etoys-Squeakland-MorphicExtras-Charts'
}

{ #category : #'parts bin' }
HorizontalNumberLineMorph class >> descriptionForPartsBin [
	"Answer a description for use in parts bins"

	^ self
		partName: 'H number line' translatedNoop
		categories: {'Graphing' translatedNoop}
		documentation: 'A horizontal number line.  One possible use is as an x-axis in a graph.' translatedNoop
]

{ #category : #initialization }
HorizontalNumberLineMorph >> addLegendsAndMarks [
	"Add legends and tick-marks."

	| index offset current n legendCenter markCenter aMark aLegend |
	minValue ifNil: ["too early" ^ self].

	index := 0.
	offset := self offset.
	(submorphs copyWithout: axis) do: [:m | m delete].
	current := self left + offset.
	[current < (self right - offset)] whileTrue:
		[n := minValue + index.
		(n isDivisibleBy: unitsPerMark) ifTrue:
			[markCenter := current @ (self top + (self marksHeight / 2)).
			aMark := self newMark.
			self addMorph: aMark.
			aMark center: markCenter; color: self color.

			(n isDivisibleBy: self marksPerLegend) ifTrue:
				[(n ~= 0 or: [showZero]) ifTrue:
					[legendCenter := current @ (self top + self marksHeight + (self legendsHeight / 2)) + (0 @ 2).
					aLegend := StringMorph contents: n asString.
					self addMorph: aLegend.
					aLegend center: legendCenter; color: self color]]].
			current := current + pixelsPerUnit.
			index := index + 1].
	^ index
]

{ #category : #initialization }
HorizontalNumberLineMorph >> asValidExtent: newExtent [ 
	^ (newExtent x max: 100)
		@ (self marksHeight + self legendsHeight)
]

{ #category : #initialization }
HorizontalNumberLineMorph >> centerOfAxisVertex: n [ 
	n = 1
		ifTrue: [^ self left @ (self top + self marksHeight)].
	n = 2
		ifTrue: [^ self right @ (self top + self marksHeight)].
	^ self error: 'Invalid vertex'
]

{ #category : #initialization }
HorizontalNumberLineMorph >> fitPlayfield [
	"Currently unused and not yet really correct... the idea is to have a command whose result will be that the number line will expand or contract as needed such that the line exactly fills the horizontal space of its containing playfield.   A similar item would be wanted for vertical axes as well..."

	| aPlayfield |
	aPlayfield := self referencePlayfield.
	"find a value that is currently on screen."
	self minValue: (self horizontalCoordinateForX: 0) ceiling.
	self maxValue: (self horizontalCoordinateForX: aPlayfield right) truncated
]

{ #category : #coordinates }
HorizontalNumberLineMorph >> horizontalCoordinateForX: xPixelValue [
	"Answer the horizontal coordinate, in the metric embodied in the number line at hand, corresponding to a given x pixel-coordinate."

	| start origin |
	start := self left + self offset.
	origin := start + (0 - minValue * pixelsPerUnit).
	^ xPixelValue - origin / pixelsPerUnit
]

{ #category : #coordinates }
HorizontalNumberLineMorph >> horizontalCoordinateOf: anObject [
	"Answer the horizontal coordinate of the center of a given object in the number-line's metric space."

	anObject ifNil:  [^ 0].
	^ self horizontalCoordinateForX: anObject center x
]

{ #category : #initialization }
HorizontalNumberLineMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self extent: 600 @ self allowance
]

{ #category : #accessing }
HorizontalNumberLineMorph >> maxValue [
	"Answer the maximum value represented at the positive end of the receiver."

	^ minValue + (self width - self allowance / pixelsPerUnit) rounded
]

{ #category : #accessing }
HorizontalNumberLineMorph >> maxValue: aNumber [
	"Establish the maximum value represented.  This is done by extending or contracting the receiver."

	self width: (aNumber - minValue * pixelsPerUnit) rounded + self allowance + ((self widthOfString: aNumber asString)
				/ 2)
]

{ #category : #accessing }
HorizontalNumberLineMorph >> minValue: aNumber [
	"Establish the value corresponding to the lowest end of the line."

	| diff |
	diff := self minValue - aNumber.
	self bounds: (self bounds withLeft: self bounds left - (self pixelsPerUnit * diff)).
	super minValue: aNumber
]

{ #category : #initialization }
HorizontalNumberLineMorph >> newMark [
	^ Morph new extent: 2 @ self marksHeight
]

{ #category : #initialization }
HorizontalNumberLineMorph >> registerGraphCoordinate: aGraphCoordinate atPlayfieldLocation: desiredPlayfieldCoordinate [
	"Fine-tuning for perfect registry."

	| itsCurrentOnPlayfield delta |
	itsCurrentOnPlayfield := ((aGraphCoordinate - minValue) * pixelsPerUnit) + self left + self offset. "relative to playfield's left edge"
	delta := (desiredPlayfieldCoordinate - itsCurrentOnPlayfield) + owner left.
	self left: self left + delta.
	self update
]

{ #category : #coordinates }
HorizontalNumberLineMorph >> setXOnGraphFor: aMorph to: aNumber [
	"Position a morph horizontally such that its xOnGraph, given the current horizontal axis in play, is as indicated."

	| start |
	start := self left + self offset.
	aMorph center: start + (aNumber - minValue * pixelsPerUnit) @ aMorph center y
]
