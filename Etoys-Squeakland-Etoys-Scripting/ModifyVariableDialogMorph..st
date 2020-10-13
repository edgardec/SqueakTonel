Class {
	#name : #ModifyVariableDialogMorph,
	#superclass : #NewVariableDialogMorph,
	#instVars : [
		'slot'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting'
}

{ #category : #'as yet unclassified' }
ModifyVariableDialogMorph class >> on: aMorph slot: aByteSymbol [
	^ self basicNew initializeWith: aMorph slot: aByteSymbol
]

{ #category : #accessing }
ModifyVariableDialogMorph >> chooseType [
	(self targetPlayer okayToRemoveSlotNamed: slot) ifFalse:
		[^ self inform: ('Sorry, {1} is in
use in a script.' translated format: {slot})].
	super chooseType
]

{ #category : #actions }
ModifyVariableDialogMorph >> doAccept [
	| newName |
	self delete.
	self varName isEmpty ifTrue: [^ self].
	"If the original slot was modified while this dialog was still open, we add a new variable"
	(self targetPlayer slotInfo includesKey: slot)
		ifFalse: [self addNewVariable.
			^ self].
	"Change slot type"
	self varType = (self targetPlayer typeForSlot: slot)
		ifFalse: [self targetPlayer
					changeSlotTypeOf: slot
					to: self varType].
	"Change slot name"
	(newName := self varAcceptableName) = slot
		ifFalse: [self targetPlayer
					renameSlot: slot
					newSlotName: newName].
	"Change decimal places"
	(#(#Number #Point) includes: self varType)
		ifTrue: [
			self targetPlayer
				setPrecisionFor: newName
				precision: self decimalPlaces]
]

{ #category : #initialization }
ModifyVariableDialogMorph >> initializeWith: aMorph slot: aSymbolOrNil [
	myTarget := aMorph.
	slot := aSymbolOrNil.
	self initialize
]

{ #category : #accessing }
ModifyVariableDialogMorph >> title [
	^ 'Modify variable' translated
]

{ #category : #accessing }
ModifyVariableDialogMorph >> varAcceptableName [
	^ ScriptingSystem
		acceptableSlotNameFrom: self varName
		forSlotCurrentlyNamed: slot
		asSlotNameIn: self targetPlayer
		world: self targetPlayer costume world
]

{ #category : #accessing }
ModifyVariableDialogMorph >> varName [
	^ varNameText
		ifNil: [slot]
		ifNotNil: [:text | text contents string]
]

{ #category : #accessing }
ModifyVariableDialogMorph >> varType [
	"Answer the symbol representing the chosen value type for the variable."

	^ varTypeButton
		ifNil: [self targetPlayer typeForSlot: slot]
		ifNotNil: [:button| 
			Vocabulary typeChoicesForUserVariables
				detect: [:each |
					each translated = button label]
				ifNone: [button label asSymbol]]
]
