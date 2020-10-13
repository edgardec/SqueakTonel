"
Holds a record of data representing actor-like slots in the Morph, on behalf of an associated Player.  Presently also holds onto the scriptInstantion objects that represent active scripts in an instance, but this will probably change soon.
"
Class {
	#name : #ActorState,
	#superclass : #Object,
	#instVars : [
		'owningPlayer',
		'penDown',
		'penSize',
		'penColor',
		'fractionalPosition',
		'instantiatedUserScriptsDictionary',
		'penArrowheads',
		'trailStyle'
	],
	#category : #'Etoys-Scripting Support'
}

{ #category : #other }
ActorState >> addPlayerMenuItemsTo: aMenu hand: aHandMorph [
	self getPenDown
		ifTrue: [aMenu add: 'pen up' action: #liftPen]
		ifFalse: [aMenu add: 'pen down' action: #lowerPen].
	aMenu add: 'pen size' action: #choosePenSize.
	aMenu add: 'pen color' action: #choosePenColor:.
]

{ #category : #pen }
ActorState >> choosePenColor: evt [
	owningPlayer costume changeColorTarget: owningPlayer costume selector: #penColor: originalColor: owningPlayer getPenColor hand: evt hand.
]

{ #category : #pen }
ActorState >> choosePenSize [
	| sz |
	sz := UIManager default chooseFrom: (1 to: 10)  values: (1 to: 10).
	sz ifNotNil: [penSize := sz]
]

{ #category : #other }
ActorState >> costume [
	^ owningPlayer costume
]

{ #category : #pen }
ActorState >> defaultPenColor [
	^ Color blue
]

{ #category : #pen }
ActorState >> defaultPenSize [
	^ 1
]

{ #category : #position }
ActorState >> fractionalPosition [
	"Return my player's costume's position including the fractional part. This allows the precise position to be retained to avoid cummulative rounding errors, while letting Morphic do all its calculations with integer pixel coordinates. See the implementation of forward:."

	^ fractionalPosition

]

{ #category : #position }
ActorState >> fractionalPosition: aPoint [

	fractionalPosition := aPoint asFloatPoint.

]

{ #category : #pen }
ActorState >> getPenArrowheads [
	^ penArrowheads == true
]

{ #category : #pen }
ActorState >> getPenColor [
	penColor ifNil: [penColor := self defaultPenColor].
	^ penColor
]

{ #category : #pen }
ActorState >> getPenDown [
	^ penDown == true
]

{ #category : #pen }
ActorState >> getPenSize [
	penSize ifNil: [penSize := self defaultPenSize].
	^ penSize
]

{ #category : #initialization }
ActorState >> initializeFor: aPlayer [
	| aNewDictionary |
	owningPlayer := aPlayer.
	instantiatedUserScriptsDictionary ifNil: [^ self].
	aNewDictionary := IdentityDictionary new.
	instantiatedUserScriptsDictionary associationsDo: 
		[:assoc |
			aNewDictionary at: assoc key put: (assoc value shallowCopy player: aPlayer)].
	instantiatedUserScriptsDictionary := aNewDictionary.
]

{ #category : #'script instantiations' }
ActorState >> instantiatedUserScriptsDictionary [
	instantiatedUserScriptsDictionary ifNil: [instantiatedUserScriptsDictionary := IdentityDictionary new].
	^ instantiatedUserScriptsDictionary
]

{ #category : #pen }
ActorState >> liftPen [
	penDown := false
]

{ #category : #pen }
ActorState >> lowerPen [
	penDown := true
]

{ #category : #pen }
ActorState >> penColor: aColor [
	penColor := aColor
]

{ #category : #printing }
ActorState >> printOn: aStream [
	aStream nextPutAll: 'ActorState for ', owningPlayer externalName, ' '.
	penDown ifNotNil: [aStream cr; nextPutAll: 'penDown ', penDown printString].
	penColor ifNotNil: [aStream cr; nextPutAll: 'penColor ', penColor printString].
	penSize ifNotNil: [aStream cr; nextPutAll: 'penSize ', penSize printString].
	instantiatedUserScriptsDictionary ifNotNil:
		[aStream cr; nextPutAll:
			'+ ', instantiatedUserScriptsDictionary size printString, ' user scripts'].

]

{ #category : #pen }
ActorState >> setPenArrowheads: aBoolean [
	penArrowheads := aBoolean
]

{ #category : #pen }
ActorState >> setPenColor: aColor [
	penColor := aColor

]

{ #category : #pen }
ActorState >> setPenDown: aBoolean [
	penDown := aBoolean
]

{ #category : #pen }
ActorState >> setPenSize: aNumber [
	penSize := aNumber
]

{ #category : #pen }
ActorState >> trailStyle [
	"Answer the receiver's trailStyle.  For backward compatibility, if the old penArrowheads slot is in found to be set, use it as a guide for initialization"

	^ trailStyle ifNil: [trailStyle := penArrowheads == true ifTrue: [#arrows] ifFalse: [#lines]]
]

{ #category : #pen }
ActorState >> trailStyle: aSymbol [
	"Set the trail style to the given symbol"

	trailStyle := aSymbol
]
