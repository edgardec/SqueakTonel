Class {
	#name : #GeeBookPageMorph,
	#superclass : #PasteUpMorph,
	#instVars : [
		'geeMail',
		'geeMailRectangle'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #'new-morph participation' }
GeeBookPageMorph class >> includeInNewMorphMenu [

	^ false
]

{ #category : #drawing }
GeeBookPageMorph >> fullDrawOn: aCanvas [

	aCanvas 
		translateTo: self topLeft + aCanvas origin - geeMailRectangle origin 
		clippingTo: (bounds translateBy: aCanvas origin) 
		during: [ :c |
			geeMail disablePageBreaksWhile: [geeMail fullDrawOn: c].
		].

]

{ #category : #initialization }
GeeBookPageMorph >> geeMail: aGeeMail geeMailRectangle: aRectangle [

	geeMail := aGeeMail.
	geeMailRectangle := aRectangle.
	self extent: aRectangle extent.
]

{ #category : #'event handling' }
GeeBookPageMorph >> mouseDown: evt [
	"Handle a mouse down event."

	
	"{evt. self recipientForMouseDown: evt. self} explore."

]
