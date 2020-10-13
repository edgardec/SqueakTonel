"
Contributed by Bob Arning as part of the ObjectExplorer package.

"
Class {
	#name : #VeryPickyMorph,
	#superclass : #Morph,
	#instVars : [
		'passengerMorph'
	],
	#category : #'Etoys-Squeakland-Tools-Explorer'
}

{ #category : #converting }
VeryPickyMorph >> complexContents [

	^passengerMorph complexContents
]

{ #category : #'submorphs-add\/remove' }
VeryPickyMorph >> delete [

	passengerMorph ifNotNil: [passengerMorph delete].
	super delete
]

{ #category : #drawing }
VeryPickyMorph >> drawOn: aCanvas [

	aCanvas frameRectangle: bounds width: 1 color: Color red
]

{ #category : #initialization }
VeryPickyMorph >> initialize [

	super initialize.
	bounds := 0@0 extent: 8@10
	"bounds := 0@0 extent: 17@22"

]

{ #category : #'dropping\/grabbing' }
VeryPickyMorph >> justDroppedInto: targetMorph event: evt [

	passengerMorph ifNil: [^self "delete"].
	passengerMorph noLongerBeingDragged.
	(targetMorph isKindOf: IndentingListItemMorph) ifFalse: [
		passengerMorph changed.
		passengerMorph := nil.
		owner removeMorph: self.
		self privateOwner: nil.
	].
]

{ #category : #'as yet unclassified' }
VeryPickyMorph >> passengerMorph: anotherMorph [

	passengerMorph := anotherMorph
]
