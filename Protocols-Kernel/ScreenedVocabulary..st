Class {
	#name : #ScreenedVocabulary,
	#superclass : #FullVocabulary,
	#instVars : [
		'methodScreeningBlock',
		'categoryScreeningBlock'
	],
	#category : #'Protocols-Kernel'
}

{ #category : #enumeration }
ScreenedVocabulary >> allMethodsInCategory: categoryName forInstance: anObject ofClass: aClass [
	"Answer a list of all methods in the vocabulary which are in the given category, on behalf of the given class and object"

	^ (super allMethodsInCategory: categoryName forInstance: anObject ofClass: aClass) select:
		[:aSelector | self includesSelector: aSelector]
]

{ #category : #enumeration }
ScreenedVocabulary >> categoryListForInstance: anObject ofClass: aClass limitClass: mostGenericClass [
	"Answer the category list for the given object/class, considering only code implemented in mostGenericClass and lower"

	^(super categoryListForInstance: anObject ofClass: aClass limitClass: mostGenericClass)
		select: categoryScreeningBlock
]

{ #category : #initialization }
ScreenedVocabulary >> categoryScreeningBlock: aBlock [
	"Set the receiver's categoryScreeningBlock to the block provided"

	categoryScreeningBlock := aBlock
]

{ #category : #queries }
ScreenedVocabulary >> includesSelector: aSelector [
	"Answer whether the given selector is known to the vocabulary"

	^ methodScreeningBlock value: aSelector
]

{ #category : #queries }
ScreenedVocabulary >> includesSelector: aSelector forInstance: anInstance ofClass: aTargetClass limitClass: mostGenericClass [
	"Answer whether the vocabulary includes the given selector for the given object, only considering method implementations in mostGenericClass and lower"

	^ (super includesSelector: aSelector forInstance: anInstance ofClass: aTargetClass limitClass: mostGenericClass) and:
		[self includesSelector: aSelector]
]

{ #category : #initialization }
ScreenedVocabulary >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	vocabularyName :=  #Public.
	self documentation: '"Public" is vocabulary that excludes categories that start with "private" and methods that start with "private" or "pvt"'
]

{ #category : #initialization }
ScreenedVocabulary >> methodScreeningBlock: aBlock [
	"Set the receiver's methodScreeningBlock to the block provided"

	methodScreeningBlock := aBlock
]
