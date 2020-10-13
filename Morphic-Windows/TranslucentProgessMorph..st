Class {
	#name : #TranslucentProgessMorph,
	#superclass : #Morph,
	#instVars : [
		'opaqueBackgroundColor'
	],
	#category : #'Morphic-Windows'
}

{ #category : #drawing }
TranslucentProgessMorph >> drawOn: aCanvas [

	| revealPercentage revealingStyle revealingColor revealingBounds revealToggle x baseColor revealTimes secondsRemaining stringToDraw where fontToUse innerBounds |
	
	innerBounds := bounds.
	opaqueBackgroundColor ifNotNil: [
		aCanvas 
			frameAndFillRectangle: bounds
			fillColor: opaqueBackgroundColor
			borderWidth: 8
			borderColor: Color blue.
		innerBounds := innerBounds insetBy: 8.
	].
	revealTimes := (self valueOfProperty: #revealTimes) ifNil: [^self].
	revealPercentage := (revealTimes first / revealTimes second) asFloat.
	revealingStyle := self revealingStyle.
	x := self valueOfProperty: #progressStageNumber ifAbsent: [1].
	baseColor := Color perform: (#(red blue green magenta cyan yellow) atPin: x).
	revealingColor := baseColor alpha: 0.2.
	revealingStyle = 3 ifTrue: [	"wrap and change color"
		revealPercentage > 1.0 ifTrue: [
			revealingColor := baseColor alpha: (0.2 + (revealingStyle / 10) min: 0.5).
		].
		revealPercentage := revealPercentage fractionPart.
	].
	revealingStyle = 2 ifTrue: [	"peg at 75 and blink"
		revealPercentage > 0.75 ifTrue: [
			revealToggle := self valueOfProperty: #revealToggle ifAbsent: [true].
			self setProperty: #revealToggle toValue: revealToggle not.
			revealToggle ifTrue: [revealingColor := baseColor alpha: 0.8.].
		].
		revealPercentage := revealPercentage min: 0.75.
	].
	revealingBounds := innerBounds withLeft: innerBounds left + (innerBounds width * revealPercentage) truncated.
	aCanvas 
		fillRectangle: revealingBounds
		color: revealingColor.
	secondsRemaining := (revealTimes second - revealTimes first / 1000) rounded.
	secondsRemaining > 0 ifTrue: [
		fontToUse := StrikeFont familyName: Preferences standardEToysFont familyName size: 24.
		stringToDraw := secondsRemaining printString.
		where := innerBounds corner - ((fontToUse widthOfString: stringToDraw) @ fontToUse height).
		aCanvas 
			drawString: stringToDraw 
			in: (where corner: innerBounds corner)
			font: fontToUse
			color: Color black.
		aCanvas
			drawString: stringToDraw 
			in: (where - (1@1) corner: innerBounds corner)
			font: fontToUse
			color: Color white.
	]. 



]

{ #category : #'WiW support' }
TranslucentProgessMorph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^self valueOfProperty: #morphicLayerNumber ifAbsent: [12].

	"progress morphs are behind menus and balloons, but in front of most other stuff"
]

{ #category : #accessing }
TranslucentProgessMorph >> opaqueBackgroundColor: aColor [

	opaqueBackgroundColor := aColor
]

{ #category : #accessing }
TranslucentProgessMorph >> revealingStyle [

">>>>
	1 = original, no change after 100%
	2 = hold at last 25% and blink until done
	3 = wrap around from 100% back to 0 and go again. change color after first
<<<<"
	^3

]
