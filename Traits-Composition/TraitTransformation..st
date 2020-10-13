"
A trait transformation is an instance of one of my concrete subclasses, TraitAlias or TraitExclusion. These represent a transformation of a trait, specified by the alias and exclusion operators. 

I define an instance variable named subject which holds the object that is transformed.  Thus, an alias transformation has as its subject a trait, and a trait exclusion has as its subject either a trait alias or a trait. Each of the concrete transformation classes implement the method allSelectors according to the transformation it represents. 

"
Class {
	#name : #TraitTransformation,
	#superclass : #Object,
	#instVars : [
		'subject',
		'users'
	],
	#category : #'Traits-Composition'
}

{ #category : #converting }
TraitTransformation >> + aTrait [
	"Just like ordered collection"
	^TraitComposition withAll: {self. aTrait}
]

{ #category : #converting }
TraitTransformation >> - anArrayOfSelectors [
	^self subclassResponsibility
]

{ #category : #converting }
TraitTransformation >> @ anArrayOfAssociations [
	^self subclassResponsibility
]

{ #category : #accessing }
TraitTransformation >> addTraitUser: aTrait [
	users := users copyWith: aTrait.
	subject addTraitUser: aTrait.

]

{ #category : #accessing }
TraitTransformation >> allTraits [
	^subject allTraits
]

{ #category : #converting }
TraitTransformation >> asTraitComposition [
	^TraitComposition with: self
]

{ #category : #converting }
TraitTransformation >> asTraitTransform [
	^self
]

{ #category : #operations }
TraitTransformation >> copyTraitExpression [
	"Copy all except the actual traits"
	^self subclassResponsibility
]

{ #category : #testing }
TraitTransformation >> includesTrait: aTrait [
	^subject includesTrait: aTrait
]

{ #category : #initialize }
TraitTransformation >> initialize [
	super initialize.
	users := #().
]

{ #category : #testing }
TraitTransformation >> isAliasSelector: selector [
	^subject isAliasSelector: selector
]

{ #category : #testing }
TraitTransformation >> isLocalAliasSelector: selector [
	^false
]

{ #category : #testing }
TraitTransformation >> isTraitTransformation [
	"Polymorphic with Trait"
	^true
]

{ #category : #accessing }
TraitTransformation >> removeTraitUser: aTrait [
	users := users copyWithout: aTrait.
	subject removeTraitUser: aTrait.
]

{ #category : #operations }
TraitTransformation >> selectorsAndMethodsDo: aBlock [
	"enumerates all selectors and methods in a trait composition"
	^self subclassResponsibility
]

{ #category : #accessing }
TraitTransformation >> subject: aSubject [
	subject := aSubject.
]

{ #category : #accessing }
TraitTransformation >> trait [
	^subject trait
]

{ #category : #accessing }
TraitTransformation >> traitsDo: aBlock [
	^subject traitsDo: aBlock
]

{ #category : #operations }
TraitTransformation >> updateSelector: aSelector withTraitMethod: compiledMethod from: aTrait [
	"broadcasts the change of a selector to all users of a trait"
	^self subclassResponsibility
]

{ #category : #operations }
TraitTransformation >> updateTraits [
	"Recompute my users traits composition"
	users do:[:each| each updateTraits].
]
