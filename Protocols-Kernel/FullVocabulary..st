"
The vocabulary that it all-encompassing.  Its categories consist of the union of all categories of a class and all its superclasses.  The methods in each category consist of those with selectors that are associated with that category.
"
Class {
	#name : #FullVocabulary,
	#superclass : #DataType,
	#category : #'Protocols-Kernel'
}

{ #category : #'method list' }
FullVocabulary >> allMethodsInCategory: categoryName forInstance: anObject ofClass: aClass [
	"Answer a list of all methods which are in the given category, on behalf of anObject"

	| classToUse |
	classToUse := aClass ifNil: [anObject class].
	^ classToUse allMethodsInCategory: categoryName
]

{ #category : #queries }
FullVocabulary >> categoriesContaining: aSelector forClass: aTargetClass [ 
	"Answer a list of category names (all symbols) of categories that contain 
	the given selector for the target object. Initially, this just returns one."
	| classDefiningSelector catName |
	classDefiningSelector := aTargetClass whichClassIncludesSelector: aSelector.
	classDefiningSelector
		ifNil: [^ OrderedCollection new].
	catName := classDefiningSelector whichCategoryIncludesSelector: aSelector.
	^ OrderedCollection with: catName
]

{ #category : #'category list' }
FullVocabulary >> categoryListForInstance: anObject ofClass: aClass limitClass: mostGenericClass [
	"Answer the category list for the given object, considering only code implemented in mostGeneric and lower (or higher, depending on which way you're facing"

	| classToUse |
	classToUse := anObject ifNil: [aClass] ifNotNil: [anObject class].
	^ mostGenericClass == classToUse
		ifTrue:
			[mostGenericClass organization categories]
		ifFalse:
			[classToUse allMethodCategoriesIntegratedThrough: mostGenericClass]
]

{ #category : #queries }
FullVocabulary >> categoryWithNameIn: categoryNames thatIncludesSelector: aSelector forInstance: targetInstance ofClass: targetClass [ 
	"Answer the name of a category, from among the provided 
	categoryNames, which defines the selector for the given class. Here, if 
	the category designated by the implementing class is acceptable it is the 
	one returned"
	| aClass catName result |
	(aClass := targetClass whichClassIncludesSelector: aSelector)
		ifNotNil: [(categoryNames includes: (catName := aClass whichCategoryIncludesSelector: aSelector))
				ifTrue: [catName ~~ #'as yet unclassified'
						ifTrue: [^ catName]]].
	result := super
				categoryWithNameIn: categoryNames
				thatIncludesSelector: aSelector
				forInstance: targetInstance
				ofClass: aClass.
	^ result
		ifNil: [#'as yet unclassified']
]

{ #category : #queries }
FullVocabulary >> encompassesAPriori: aClass [
	"Answer whether an object, by its very nature, is one that the receiver embraces"

	^ true
]

{ #category : #queries }
FullVocabulary >> includesDefinitionForSelector: aSelector [
	"Answer whether the given selector is known to the vocabulary.  Unsent at the moment, may disappear."

	^ true
]

{ #category : #queries }
FullVocabulary >> includesSelector: aSelector [
	"Answer whether the given selector is known to the vocabulary"

	^ true
]

{ #category : #queries }
FullVocabulary >> includesSelector: aSelector forInstance: anInstance ofClass: aTargetClass limitClass: mostGenericClass [
	"Answer whether the vocabulary includes the given selector for the given class, only considering method implementations in mostGenericClass and lower"

	| classToUse aClass |
	classToUse := self classToUseFromInstance: anInstance ofClass: aTargetClass.
	^ (aClass := classToUse whichClassIncludesSelector: aSelector)
		ifNil:
			[false]
		ifNotNil:
			[aClass includesBehavior: mostGenericClass]
]

{ #category : #initialization }
FullVocabulary >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')
Vocabulary initialize
"

	super initialize.
	vocabularyName := #Object.
	self documentation: '"Object" is all-encompassing vocabulary that embraces all methods understood by an object'.
	self rigAFewCategories
]

{ #category : #queries }
FullVocabulary >> representsAType [
	"Answer whether this vocabulary represents an end-user-sensible data type"

	^ false
]

{ #category : #initialization }
FullVocabulary >> rigAFewCategories [
	"Formerly used to rig generic categories, now seemingly disfunctional and in abeyance"

	true ifTrue: [^ self].

	self flag: #deferred.
"Vocabulary fullVocabulary rigAFewCategories "
	#(	(accessing	'Generally holds methods to read and write instance variables')
		(initialization	'messages typically sent when an object is created, to set up its initial state'))

		do:
			[:pair |
				| aMethodCategory |
				aMethodCategory := ElementCategory new categoryName: pair first.
				aMethodCategory documentation: pair second.
				self addCategory: aMethodCategory]
]
