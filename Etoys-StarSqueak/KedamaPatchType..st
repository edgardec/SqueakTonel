"
EToys Patch type.

"
Class {
	#name : #KedamaPatchType,
	#superclass : #PlayerType,
	#category : #'Etoys-StarSqueak'
}

{ #category : #'tile protocol' }
KedamaPatchType >> defaultArgumentTile [
	"Answer a tile to represent the type"
	| patch ks k p |
	patch := KedamaPatchTile new typeColor: self typeColor.
	ks := self world allMorphs select: [:e | e isKindOf: KedamaMorph].
	ks isEmpty ifFalse: [
		k := ks first.
		p := k player getPatch.
	] ifTrue: [
		k := KedamaPatchMorph new.
		k assuredPlayer.
		p := k player.
	].
	patch usePatch: p.
	^ patch
]

{ #category : #'tile protocol' }
KedamaPatchType >> defaultArgumentTileFor: aPlayer [
	"Answer a tile to represent the type"
	| patch morph |
	patch := KedamaPatchTile new typeColor: self typeColor.
	morph := aPlayer costume renderedMorph.
	(morph isKindOf: KedamaTurtleMorph) ifTrue: [
		patch useDefaultPatch: aPlayer kedamaWorld defaultPatch player.
	].
	(morph isKindOf: KedamaMorph) ifTrue: [
		patch useDefaultPatch: morph defaultPatch player.
	].
	(morph isKindOf: KedamaPatchMorph) ifTrue: [
		patch useDefaultPatch: morph player.
	].
	^ patch.

]

{ #category : #'tile protocol' }
KedamaPatchType >> initialValueForASlotFor: aPlayer [
	"Answer the value to give initially to a newly created slot of the given type in the given player"

	^ aPlayer kedamaWorld defaultPatch
]

{ #category : #initialization }
KedamaPatchType >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	self vocabularyName: #Patch.

]

{ #category : #'tile protocol' }
KedamaPatchType >> typeColor [
	"Answer the color for tiles to be associated with objects of this type"

	^ self subduedColorFromTriplet: #(0.806 1.0 0.806)	
]

{ #category : #'tile protocol' }
KedamaPatchType >> updatingTileForTarget: aTarget partName: partName getter: getter setter: setter [

	| aTile displayer actualSetter |
	actualSetter := setter ifNotNil:
		[(#(none nil unused) includes: setter) ifTrue: [nil] ifFalse: [setter]].

	aTile := self newReadoutTile.

	displayer := UpdatingStringMorph new
		getSelector: #externalName;
		target: aTarget costume renderedMorph;
		growable: true;
		minimumWidth: 24;
		putSelector: nil.
	displayer stepTime: 1000.
	"Note that when typeSymbol = #number, the #target: call above will have dealt with floatPrecision details"

	self setFormatForDisplayer: displayer.
	aTile addMorphBack: displayer.
	(actualSetter notNil and: [self wantsArrowsOnTiles]) ifTrue: [aTile addArrows].	
	getter numArgs == 0 ifTrue:
		[aTile setLiteralInitially: (aTarget perform: getter)].
	displayer useStringFormat.

	^ aTile

]
