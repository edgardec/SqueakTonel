"
A PropertySortFunction is a SortFunction for sorting by a specific property.

Instance Variables
	collator	<SortFunction>	the SortFunction to be used for sorting the properties
	property <Symbol | Block> a valuable returning the value of property for objects to be sorted
"
Class {
	#name : #PropertySortFunction,
	#superclass : #ComposedSortFunction,
	#instVars : [
		'property'
	],
	#category : #'Collections-SortFunctions'
}

{ #category : #'instance creation' }
PropertySortFunction class >> property: selectorOrOneArgBlock [
	^self new 
		property: selectorOrOneArgBlock
]

{ #category : #'instance creation' }
PropertySortFunction class >> property: selectorOrOneArgBlock collatedWith: aSortFunction [
	^self new 
		property: selectorOrOneArgBlock;
		baseSortFunction: aSortFunction
]

{ #category : #comparing }
PropertySortFunction >> = anObject [
	"Answer whether the receiver and anObject represent the same object."

	self == anObject
		ifTrue: [ ^ true ].
	self class = anObject class
		ifFalse: [ ^ false ].
	^ baseSortFunction = anObject baseSortFunction
		and: [ property = anObject property ]
]

{ #category : #evaluating }
PropertySortFunction >> collate: anObject with: another [
	"Answer the collation order of anObject and another based on the property."
	^ baseSortFunction collate: (property value: anObject) with: (property value: another)
]

{ #category : #comparing }
PropertySortFunction >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ super hash bitXor: property hash
]

{ #category : #accessing }
PropertySortFunction >> property [
	^ property
]

{ #category : #accessing }
PropertySortFunction >> property: aValuable [
	property := aValuable
]

{ #category : #converting }
PropertySortFunction >> undefinedFirst [
	"apply on the property"
	^self class
		property: property
		collatedWith: baseSortFunction undefinedFirst
]

{ #category : #converting }
PropertySortFunction >> undefinedLast [
	"apply on the property"
	^self class
		property: property
		collatedWith: baseSortFunction undefinedLast
]
