"
Represents a variable held in a Player on behalf of a Morph.  When a new Player gets installed in the Morph, variables representing the old player need to be committed to the old player's storage, if not already done, and then new values for the variables need to be obtained from the new Player.  The VariableDock does the actual data transfer.

variableName 		A Symbol.  The name by which this variable known in the bearer,  a Card
type 				An object representing the variable's type.  Initially, we, like the rest
						use a Symbol to represent this.
						Presently #string #number #boolean #object #reference #sound etc.
definingMorph		The morph that requested storage of this variable
morphGetSelector	The message to be sent to the morph to obtain the variable's value
morphPutSelector	The message to be sent to the morph to put a new var value into it
owningClass			The Uniclass of which this is an instance variable
playerGetSelector 	The message to be sent to the Player to obtain its current stored value
playerPutSelector 	The message to be sent to the Player to set a new stored value
defaultValue		The value to set for the variable by default
floatPrecision		e.g. 0, 0.1, 0.001.  Only relevant for numeric-type variables

"
Class {
	#name : #VariableDock,
	#superclass : #Object,
	#instVars : [
		'variableName',
		'type',
		'definingMorph',
		'morphGetSelector',
		'morphPutSelector',
		'playerGetSelector',
		'playerPutSelector',
		'defaultValue'
	],
	#category : #'Etoys-Stacks'
}

{ #category : #'getters and setters' }
VariableDock >> computePlayerGetterAndSetterSelectors [
	"Compute and remember the getter and setter selectors for obtaining and setting values from the player instance"

	playerGetSelector := variableName asGetterSelector.
	playerPutSelector := variableName asSetterSelector.
]

{ #category : #accessing }
VariableDock >> definingMorph [
	"Answer the defining morph"

	^ definingMorph
]

{ #category : #initialization }
VariableDock >> dockMorphUpToInstance: anInstance [
	"Dock my defining morph up to the given player instance.  NB: The odious #cardInstance mechanism used here was a last-minute stopgap for some demo, which surely should not be allowed to survive."

	definingMorph setProperty: #cardInstance toValue: anInstance.
	definingMorph perform: morphPutSelector with: (anInstance perform: playerGetSelector)
]

{ #category : #accessing }
VariableDock >> playerGetSelector [
	^playerGetSelector
]

{ #category : #printing }
VariableDock >> printOn: aStream [
	"Print a description of the receiver onto the given stream"

	super printOn: aStream.
	variableName ifNotNil: [aStream nextPutAll: (' (var name = ', variableName, ')')].
	type ifNotNil: [aStream nextPutAll: (' (type = ', type, ')')]
]

{ #category : #initialization }
VariableDock >> storeMorphDataInInstance: anInstance [
	"Store the morph instance data represented by the receiver into the card instance provided.  This is done by retrieving the datum value from the morph that holds it on the card, and putting it into the card instance"

	anInstance perform: playerPutSelector with: (definingMorph perform: morphGetSelector) copy
]

{ #category : #accessing }
VariableDock >> type [
	^type
]

{ #category : #name }
VariableDock >> variableName [
	"Answer the variable name represented by the receiver"

	^ variableName
]

{ #category : #name }
VariableDock >> variableName: aSymbol [
	"Set the receiver's variableName as indicated, and recompute corresponding getters and setters"

	variableName := aSymbol asSymbol.
	self computePlayerGetterAndSetterSelectors
]

{ #category : #initialization }
VariableDock >> variableName: aSymbol type: aType definingMorph: aMorph morphGetSelector: getterSymbol morphPutSelector: putterSymbol [
	"Initialize the receiver as indicated"

	variableName := aSymbol asSymbol.
	type := aType.
	definingMorph := aMorph.
	morphGetSelector := getterSymbol.
	morphPutSelector := putterSymbol.
	self computePlayerGetterAndSetterSelectors
]

{ #category : #'type and default value' }
VariableDock >> variableType [
	"Answer the data type of the receiver"

	^ type
]
