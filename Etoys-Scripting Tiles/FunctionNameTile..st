"
An operator tile holding the name of a function; used in conjunction with a FunctionTile which is always its owner.
"
Class {
	#name : #FunctionNameTile,
	#superclass : #TileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #arrows }
FunctionNameTile >> arrowAction: delta [ 
	"Do what is appropriate when an arrow on the tile is pressed; delta will be +1 or -1"

	| index operatorList |
	operatorList := self options second.
	index := (operatorList indexOf: self value) + delta.
	self setOperator: (operatorList atWrap: index).
	self scriptEdited.
	self layoutChanged
]

{ #category : #'menu commands' }
FunctionNameTile >> grouped [
	"The user chose grouped from the menu.  Establish the special-case null function call."

	self setOperator: #grouped
]

{ #category : #initialization }
FunctionNameTile >> operator: anOperator wording: aWording helpString: aHelpString [
	"Set the operator as per aString, and add up/down arrows"

	type := #operator.
	operatorOrExpression := anOperator asSymbol.
	operatorOrExpression = #grouped
		ifTrue:
			[self line1: ' ']
		ifFalse:
			[self line1: aWording].
	self addArrows..
	aHelpString ifNotNil: [submorphs last setBalloonText: aHelpString]
]

{ #category : #'choice of function' }
FunctionNameTile >> options [
	"Answer the options of the tile for an arrow"

	| aTable |
	aTable := ScriptingSystem tableOfNumericFunctions reversed.

	^ Array with:
				(aTable collect: [:pr | pr first] ), #(grouped)
			with:
				(aTable collect: [:pr | pr second]), #(grouped)
]

{ #category : #'menu commands' }
FunctionNameTile >> removeFunction [
	"Remove the function-call... this is forwarded to owner."

	^ owner removeFunction
]

{ #category : #'choice of function' }
FunctionNameTile >> setOperator: anOperatorSymbol [
	"The user chose an entry with the given inherent operator symbol (this may differ from what the user sees in the pop-up or on the tile."

	| aTable |
	operatorOrExpression := anOperatorSymbol.
	operatorOrExpression = #grouped
		ifTrue:
			[self line1: ' '.
			self setBalloonText: 'parenthesized' translated]
		ifFalse:
			[aTable := ScriptingSystem tableOfNumericFunctions.
			(aTable detect: [:m | m second = anOperatorSymbol] ifNone: [nil]) ifNotNil:
				[:aTriplet |
					self line1: aTriplet first translated.
					self setBalloonText: aTriplet third translated]].
	self addArrows.
	self scriptEdited.
	self layoutChanged
]

{ #category : #'choice of function' }
FunctionNameTile >> showOptions [
	"Put up a pop-up menu of options for the operator tile within me."

	| aMenu aTable |
	aMenu := MenuMorph new defaultTarget: self.
	aTable := ScriptingSystem tableOfNumericFunctions.
	aTable do:
		[:triplet |
			aMenu add: triplet first translated target: self  selector:  #setOperator: argument: triplet second.
			triplet second = operatorOrExpression ifTrue:
				[aMenu lastItem color: Color red].
			aMenu balloonTextForLastItem: triplet third translated].

	aMenu addTranslatedList:
		#(-
		('parentheses'  grouped 'enclose within parentheses')) translatedNoop.
	operatorOrExpression = #grouped ifTrue:
		[aMenu lastItem color: Color red].

	(owner owner isKindOf: TilePadMorph) ifTrue:
		[aMenu addLine.
		operatorOrExpression = #grouped
			ifFalse:			
				[aMenu addTranslatedList:
					#(('remove function' removeFunction  'strip away the function call, leaving just its former argument in its place')) translatedNoop.]
			ifTrue:
				[aMenu addTranslatedList:
					#(('remove parentheses' removeFunction  'strip away the parenthesises')) translatedNoop]].

	aMenu position: self position.
	aMenu invokeModal

]

{ #category : #'code generation' }
FunctionNameTile >> storeCodeOn: aStream indent: tabCount [ 
	"Store the receiver's code on the stream, honoring indentation."

	operatorOrExpression = #grouped
		ifTrue:
			[aStream nextPutAll: ' yourself']
		ifFalse:
			[super storeCodeOn: aStream indent: tabCount]
]

{ #category : #updating }
FunctionNameTile >> updateLiteralLabel [
	 "Update the wording emblazoned on the tile, if needed"
	| myLabel functionTriplet |
	(myLabel := self labelMorph)
	     ifNil: [^ self].
	operatorOrExpression == #grouped
		ifTrue: [myLabel acceptValue: ' ']
		ifFalse: [functionTriplet := ScriptingSystem tableOfNumericFunctions
						detect: [:triplet | triplet second = operatorOrExpression].
			myLabel acceptValue: functionTriplet first].
	self addArrows.
	self changed
]
