"
A number line vertically oriented.
"
Class {
	#name : #VerticalNumberLineMorph,
	#superclass : #NumberLineMorph,
	#category : #'Etoys-Squeakland-MorphicExtras-Charts'
}

{ #category : #'parts bin' }
VerticalNumberLineMorph class >> descriptionForPartsBin [
	"Answer a description for use in parts bins"

	^ self
		partName: 'V number line' translatedNoop
		categories: {'Graphing' translatedNoop}
		documentation: 'A vertical number line.  One possible use is as a y-axis in a graph.' translatedNoop
]

{ #category : #initialization }
VerticalNumberLineMorph >> addLegendsAndMarks [
	"Add legends and tick-marks."

	| index offset current n legendCenter markCenter aMark aLegend |
	minValue ifNil: ["too early" ^ self].

	index := 0.
	offset := self offset.
	(submorphs copyWithout: axis) do: [:m | m delete].
	current := self bottom - offset.
	[current  > (self top + offset)] whileTrue:
		[n := minValue + index.
		(n isDivisibleBy: unitsPerMark) ifTrue:
			[markCenter := self left + self legendsWidth + (self marksWidth // 2) @ current.
			aMark := self newMark.
			self addMorph: aMark.
			aMark center: markCenter; color: self color.

			(n isDivisibleBy: (self marksPerLegend * self unitsPerMark)) ifTrue:
				[legendCenter := self left + self legendsWidth - ((self widthOfString: n asString)
									// 2) @ current + (-2 @ 0).
				(n = 0 and: [showZero not]) ifFalse:
					[aLegend := StringMorph contents: n asString.
					self addMorph: aLegend.
					aLegend center: legendCenter; color: self color]]].
			current := current - pixelsPerUnit.
			index := index + 1].
	^ index
]

{ #category : #initialization }
VerticalNumberLineMorph >> asValidExtent: newExtent [ 
	^ self marksWidth + self legendsWidth
		@ (newExtent y max: 100)
]

{ #category : #initialization }
VerticalNumberLineMorph >> centerOfAxisVertex: n [ 
	n = 1
		ifTrue: [^ self left + self legendsWidth @ self bottom].
	n = 2
		ifTrue: [^ self left + self legendsWidth @ self top].
	^ self error: 'Invalid vertex'
]

{ #category : #initialization }
VerticalNumberLineMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self extent: self allowance @ 600
]

{ #category : #accessing }
VerticalNumberLineMorph >> maxValue [
	"Answer the maximum value, in graph coordinates, represented by the point at the top of the receiver."

	^ minValue + (self height - self allowance / pixelsPerUnit) rounded
]

{ #category : #accessing }
VerticalNumberLineMorph >> maxValue: aNumber [ 
	"Set the max value as indicated; this will typically result in a change in actual bounds of the receiver."

	| newHeight |
	newHeight := (aNumber - minValue * pixelsPerUnit) rounded + self allowance.
	self bounds: (self bounds withTop: self bounds top - (newHeight - self height))
]

{ #category : #accessing }
VerticalNumberLineMorph >> minValue: aNumber [
	"Establish the value corresponding to the lowest end of the line."

	| diff |
	diff := self minValue - aNumber.
	self bounds: (self bounds withBottom: self bounds bottom + (self pixelsPerUnit * diff)).
	super minValue: aNumber
]

{ #category : #initialization }
VerticalNumberLineMorph >> newMark [
	^ Morph new extent: self marksWidth @ 2
]

{ #category : #coordinates }
VerticalNumberLineMorph >> registerGraphCoordinate: aGraphCoordinate atPlayfieldLocation: desiredPlayfieldCoordinate [
	"Fine-tuning for perfect registry."

	| itsCurrentOnPlayfield delta |
	itsCurrentOnPlayfield := self bottom - ((aGraphCoordinate - minValue) * pixelsPerUnit) + self offset. "relative to playfield's bottom edge"
	delta := (desiredPlayfieldCoordinate - itsCurrentOnPlayfield) + owner bottom.
	self bottom: self bottom + delta.
	self update
]

{ #category : #accessing }
VerticalNumberLineMorph >> setExtentFromHalo: anExtent [
	"The user having operated the yellow handle to resize the receiver, adjust the line accordingly."

	| diff |
 	diff := (anExtent y - self extent y / self pixelsPerUnit) rounded.
	self minValue: (self minValue - diff)
]

{ #category : #coordinates }
VerticalNumberLineMorph >> setYOnGraphFor: aMorph to: aNumber [
	"Interpreting the second argument as being in 'graph coordinates', as specified by the receiver serving as a y-axis, place the morph such that its yOnGraph is the given quantity."

	| start |
	start := self bottom - self offset.
	aMorph center: aMorph center x @ (start - (aNumber - minValue * pixelsPerUnit))
]

{ #category : #coordinates }
VerticalNumberLineMorph >> verticalCoordinateForY: aYValue [
	"Answer the vertical coordinate in the 'graph coordinate space' of a number interpreted as a vertical pixel coordinate."

	| start origin |
	start := self bottom - self offset.
	origin := start - (0 - minValue * pixelsPerUnit).
	^ (origin - aYValue) / pixelsPerUnit
]

{ #category : #coordinates }
VerticalNumberLineMorph >> verticalCoordinateOf: anObject [
	"Answer the yOnGraph, with respect to the receiver (used as a y-axis), of a morph."

	^ self verticalCoordinateForY: anObject center y
]
