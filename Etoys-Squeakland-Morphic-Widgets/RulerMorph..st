Class {
	#name : #RulerMorph,
	#superclass : #RectangleMorph,
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #'parts bin' }
RulerMorph class >> descriptionForPartsBin [
	^ self partName:	'Ruler' translatedNoop
		categories:		#()
		documentation:	'A rectangle which continuously reports its size in pixels' translatedNoop
]

{ #category : #initialization }
RulerMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
RulerMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color
		r: 0.8
		g: 1.0
		b: 1.0
]

{ #category : #drawing }
RulerMorph >> drawOn: aCanvas [

	| s |
	super drawOn: aCanvas.
	s := self width printString, 'x', self height printString.
	aCanvas drawString: s in: (self bounds insetBy: self borderWidth + 5) font: nil color: Color red.

]
