"
A type whose values range across a finite set of symbols, which are held in the ""symbols"" instance variable.
"
Class {
	#name : #SymbolListType,
	#superclass : #DataType,
	#instVars : [
		'symbols'
	],
	#category : #'Protocols-Type Vocabularies'
}

{ #category : #tiles }
SymbolListType >> choices [
	"answer the list of choices to offer as variant values"

	^ symbols copy
]

{ #category : #'initial value' }
SymbolListType >> initialValueForASlotFor: aPlayer [
	"Answer the value to give initially to a newly created slot of the given type in the given player"

	^ self choices first
]

{ #category : #tiles }
SymbolListType >> representsAType [
	"Answer whether this vocabulary represents an end-user-sensible data type"

	^ #(BorderStyle ButtonPhase TrailStyle) includes: vocabularyName
]

{ #category : #tiles }
SymbolListType >> symbols: symbolList [
	"Set the receiver's list of symbols as indicated"

	symbols := symbolList
]
