Class {
	#name : #PlayerType,
	#superclass : #DataType,
	#category : #'Etoys-Protocols-Type Vocabularies'
}

{ #category : #tiles }
PlayerType >> addExtraItemsToMenu: aMenu forSlotSymbol: slotSym [
	"If the receiver has extra menu items to add to the slot menu, here is its chance to do it"

	aMenu add: 'tiles to get...' translated selector: #offerGetterTiles: argument: slotSym.
	aMenu balloonTextForLastItem: 'useful shortcut for obtaining the value of a variable belonging to the player that is the current value of this player-valued variable'
]

{ #category : #tiles }
PlayerType >> defaultArgumentTile [
	"Answer a tile to represent the type"

	^ Project current world presenter standardPlayer tileToRefer
]

{ #category : #'initial value' }
PlayerType >> initialValueForASlotFor: aPlayer [
	"Answer the value to give initially to a newly created slot of the given type in the given player"

	^ aPlayer costume presenter standardPlayer
]

{ #category : #initialization }
PlayerType >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	self vocabularyName: #Player
]

{ #category : #color }
PlayerType >> typeColor [
	"Answer the color for tiles to be associated with objects of this type"

	^ self subduedColorFromTriplet: #(1.0  0 0.065)
]

{ #category : #tiles }
PlayerType >> updatingTileForTarget: aTarget partName: partName getter: getter setter: setter [
	"Answer, for classic tiles, an updating readout tile for a part with the receiver's type, with the given getter and setter"

	^ PlayerReferenceReadout new objectToView: aTarget viewSelector: getter putSelector: setter
]

{ #category : #tiles }
PlayerType >> wantsArrowsOnTiles [
	"Answer whether this data type wants up/down arrows on tiles representing its values"

	^ false
]
