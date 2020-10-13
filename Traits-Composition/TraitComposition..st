"
A trait composition is a collection of Traits or TraitTransformations.
"
Class {
	#name : #TraitComposition,
	#superclass : #OrderedCollection,
	#category : #'Traits-Composition'
}

{ #category : #converting }
TraitComposition >> + aTrait [
	self traitsDo:[:t| (t == aTrait trait) ifTrue:[^TraitCompositionException
			signal: 'Trait ' , aTrait trait asString, ' already in composition']].
	self addLast: aTrait.
	^self
]

{ #category : #converting }
TraitComposition >> - anArray [
	
	self updateTraits: (self traitsCollect: [:aTrait | aTrait - anArray ])
]

{ #category : #converting }
TraitComposition >> @ anArrayOfAssociations [
	
	self updateTraits: (self traitsCollect: [:aTrait | aTrait @ anArrayOfAssociations ])
]

{ #category : #accessing }
TraitComposition >> allTraits [
	^self gather:[:each| each allTraits copyWith: each trait]
]

{ #category : #converting }
TraitComposition >> asTraitComposition [
	^self
]

{ #category : #accessing }
TraitComposition >> collectAsTraitComposition: aBlock [

	^self collect: aBlock as: TraitComposition
]

{ #category : #operations }
TraitComposition >> copyTraitExpression [
	"Copy all except the actual traits"
	^self collectAsTraitComposition:[:each| each copyTraitExpression].
]

{ #category : #operations }
TraitComposition >> isAliasSelector: selector [
	"enumerates all selectors and methods in a trait composition"
	^self anySatisfy:[:any| any isAliasSelector: selector]
]

{ #category : #operations }
TraitComposition >> isLocalAliasSelector: selector [
	"Return true if the selector aSymbol is an alias defined in the receiver."
	^self anySatisfy:[:any| any isTraitTransformation and:[any isLocalAliasSelector: selector]]
]

{ #category : #testing }
TraitComposition >> isTraitTransformation [
	"Polymorphic with TraitTransformation"
	^false
]

{ #category : #converting }
TraitComposition >> printOn: aStream [
	"Answer the trait composition string (used for class definitions)"
	aStream nextPutAll: self traitCompositionString.

]

{ #category : #operations }
TraitComposition >> selectorsAndMethodsDo: aBlock [
	"enumerates all selectors and methods in a trait composition"
	self do:[:each| each selectorsAndMethodsDo: aBlock].
]

{ #category : #operations }
TraitComposition >> traitCompositionString [
	"Answer the trait composition string (used for class definitions)"
	self size = 0 ifTrue:[^'{}'].
	self  size = 1 ifTrue:[^self first asString].
	^String streamContents:[:s|
		self do:[:each| s nextPutAll: each asString] separatedBy:[s nextPutAll: ' + '].
	].
]

{ #category : #accessing }
TraitComposition >> traits [
	^Array streamContents:[:s| self traitsDo:[:t| s nextPut: t]]
]

{ #category : #accessing }
TraitComposition >> traitsCollect: aBlock [
	^self collectAsTraitComposition: [:each| each traitsDo: aBlock]
]

{ #category : #accessing }
TraitComposition >> traitsDo: aBlock [
	^self do: [:each| each traitsDo: aBlock]
]

{ #category : #converting }
TraitComposition >> updateTraits: aCollection [

	self
		removeAll;
		addAll: aCollection
]
