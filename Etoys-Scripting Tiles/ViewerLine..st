"
Serves as a wrapper around a line in a Viewer, enforcing the desired layout properties.
"
Class {
	#name : #ViewerLine,
	#superclass : #AlignmentMorph,
	#instVars : [
		'elementSymbol'
	],
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #slot }
ViewerLine >> addCommandFeedback [
	"Add screen feedback showing what would be torn off in a drag"

	| aMorph |
	aMorph := RectangleMorph new bounds: ((submorphs fourth topLeft - (2@1)) corner: (submorphs last bottomRight) + (2@0)).
	aMorph useRoundedCorners; beTransparent; borderWidth: 2; borderColor: (Color r: 1.0 g: 0.548 b: 0.452); lock.
	aMorph setProperty: #highlight toValue: true.
	^ Project current world addMorphFront: aMorph
]

{ #category : #slot }
ViewerLine >> addGetterFeedback [
	"Add feedback during mouseover of a getter"

	| aMorph |
	aMorph := RectangleMorph new
		bounds: (self firstTileMorph topLeft corner:
						(self firstAlignmentMorph ifNil: [self submorphs last bottomRight] ifNotNil: [:m | m bottomLeft])).
	aMorph beTransparent; borderWidth: 2; borderColor: ScriptingSystem getterFeedback; lock.
	^ Project current world addHighlightMorph: aMorph for: nil.

"
Color fromUser (Color r: 1.0 g: 0.355 b: 0.839)
"
]

{ #category : #slot }
ViewerLine >> addSetterFeedback [
	"Add screen feedback showing what would be torn off to make a setter"

	| aMorph |
	aMorph := RectangleMorph new bounds: (self firstTileMorph topLeft corner: self bounds bottomRight).
	aMorph beTransparent; borderWidth: 2; borderColor: ScriptingSystem setterFeedback; lock.
	^ Project current world addHighlightMorph: aMorph for: nil
]

{ #category : #initialization }
ViewerLine >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 1.0
		g: 0.985
		b: 0.985
]

{ #category : #access }
ViewerLine >> elementSymbol [
	"Answer the element symbol"

	^ elementSymbol
]

{ #category : #access }
ViewerLine >> elementSymbol: aSymbol [
	"Set the element symbol"

	elementSymbol := aSymbol
]

{ #category : #access }
ViewerLine >> entryType [
	"Answer one of: #systemSlot #userSlot #systemScript #userScript"

	^ self playerBearingCode elementTypeFor: elementSymbol vocabulary: self currentVocabulary
]

{ #category : #slot }
ViewerLine >> firstAlignmentMorph [

	^ self submorphs reverse detect: [:m | m isAlignmentMorph] ifNone: []
]

{ #category : #access }
ViewerLine >> firstMorphBearingKedamaPlayer [

	self allMorphsWithPlayersDo: [:e :p | (p isKindOf: KedamaExamplerPlayer) ifTrue: [^ e]].
	^ nil.

]

{ #category : #slot }
ViewerLine >> firstTileMorph [

	^ self submorphs detect: [:m | m isTileMorph]
]

{ #category : #initialization }
ViewerLine >> initialize [
	"Initialize the receiver"

	super initialize.
	self layoutInset: 0.
	self minCellSize: (0 @ (Preferences standardEToysFont height rounded + 10))
]

{ #category : #access }
ViewerLine >> morphBearingPlayer [

	self allMorphsWithPlayersDo:[:e :p | ^ e].
	^ nil.

]

{ #category : #access }
ViewerLine >> morphsBearingPlayers [

	| c |
	c := OrderedCollection new.
	self allMorphsWithPlayersDo: [:e :p | c add: e].
	^ c asArray.

]

{ #category : #access }
ViewerLine >> playerBearingCode [

	self allMorphsWithPlayersDo: [:e :p | ^ e playerBearingCode].
	^ nil.

]

{ #category : #slot }
ViewerLine >> removeGetterFeedback [
	"Remove any existing getter feedback.  Backward-compatibility only"

	self removeHighlightFeedback
]

{ #category : #slot }
ViewerLine >> removeHighlightFeedback [
	"Remove any existing highlight feedback"

	^ Project current world removeHighlightFeedback

]

{ #category : #slot }
ViewerLine >> removeSetterFeedback [
	"Remove any existing setter feedback"

	self removeHighlightFeedback  "backward compatibility with previously-launched viewer panes only"
]

{ #category : #access }
ViewerLine >> replacePlayerInReadoutWith: aPlayer [ 

	| tile |
	tile := self firstMorphBearingKedamaPlayer.
	tile ifNil: [^ self].
	(tile isMemberOf: TileMorph) ifFalse: [^ self].
	tile type = #objRef ifFalse: [^ self].
	tile referToSimilarObject: aPlayer.

	self allMorphsDo: [:e |
		((e isMemberOf: UpdatingStringMorph) or: [e isMemberOf: UpdatingRectangleMorph]) ifTrue: [
			e target isPlayerLike ifTrue: [
				e target: aPlayer
			].
		].
	].
]

{ #category : #access }
ViewerLine >> replacePlayerWith: aPlayer [

	| tile |
	tile := self firstMorphBearingKedamaPlayer.
	tile ifNil: [^ self].
	(tile isMemberOf: TileMorph) ifFalse: [^ self].
	tile type = #objRef ifFalse: [^ self].
	tile referToSimilarObject: aPlayer.

]

{ #category : #slot }
ViewerLine >> slotName [
	"Assuming the receiver represents a slot, return its name"

	^  self elementSymbol
]
