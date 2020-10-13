Class {
	#name : #TextOnCurvePS,
	#superclass : #TextOnCurve,
	#category : #'MorphicExtras-Text Support'
}

{ #category : #display }
TextOnCurvePS >> displayOn: aCanvas using: displayScanner at: somePosition [
	"Send all visible lines to the displayScanner for display"

	self textSegmentsDo:
		[:line :destRect :segStart :segAngle |
		self displaySelectionInLine: line on: aCanvas.
		line first <= line last ifTrue:
			[displayScanner displayLine: line offset: destRect topLeft leftInRun: 999]]


]
