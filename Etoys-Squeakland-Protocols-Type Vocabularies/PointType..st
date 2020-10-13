"
A value type whose representing Point-valued variables.
"
Class {
	#name : #PointType,
	#superclass : #DataType,
	#category : #'Etoys-Squeakland-Protocols-Type Vocabularies'
}

{ #category : #defaults }
PointType >> addExtraItemsToMenu: aMenu forSlotSymbol: slotSym [
	"If the receiver has extra menu items to add to the slot menu, here is its chance to do it.  The defaultTarget of the menu is the player concerned."

	aMenu add: 'decimal places...' translated selector: #setPrecisionFor: argument: slotSym.
	aMenu balloonTextForLastItem: 'Lets you choose how many decimal places should be shown in readouts for this variable' translated
]

{ #category : #defaults }
PointType >> defaultArgumentTile [
	"Answer a tile to represent the type"

	^ (0@0) newTileMorphRepresentative typeColor: self typeColor
]

{ #category : #defaults }
PointType >> initialValueForASlotFor: aPlayer [
	"Answer the value to give initially to a newly created slot of the given type in the given player"

	^  0@0
]

{ #category : #defaults }
PointType >> initialize [
	"Initialize the receiver"

	super initialize.
	self vocabularyName: #Point
]

{ #category : #tiles }
PointType >> newReadoutTile [
	"Answer a tile that can serve as a readout for data of this type"

	| aTile |
	aTile := NumericReadoutTile new typeColor: Color lightGray lighter.
	aTile setProperty: #PointValued toValue: true.
	^ aTile
]

{ #category : #defaults }
PointType >> wantsArrowsOnTiles [
	"Answer whether this data type wants up/down arrows on tiles representing its values"

	^ false
]

{ #category : #tiles }
PointType >> wantsAssignmentTileVariants [
	"Answer whether an assignment tile for a variable of this type should show variants to increase-by, decrease-by, multiply-by."

	^ true
]

{ #category : #defaults }
PointType >> wantsSuffixArrow [
	"Answer whether a tile showing data of this type would like to have a suffix arrow"

	^ true
]
