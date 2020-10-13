"
A trait transformation representing the exclusion (-) operator.
"
Class {
	#name : #TraitExclusion,
	#superclass : #TraitTransformation,
	#instVars : [
		'exclusions'
	],
	#category : #'Traits-Composition'
}

{ #category : #'instance creation' }
TraitExclusion class >> with: aTraitComposition exclusions: anArrayOfSelectors [
	^self new
		subject: aTraitComposition;
		exclusions: anArrayOfSelectors;
		yourself

]

{ #category : #converting }
TraitExclusion >> - anArrayOfSelectors [
	^TraitExclusion
		with: subject
		exclusions: (anArrayOfSelectors, exclusions asArray)
]

{ #category : #converting }
TraitExclusion >> @ anArrayOfAssociations [ 

	TraitCompositionException signal: 'Invalid trait exclusion. Aliases have to be specified before exclusions.'

]

{ #category : #composition }
TraitExclusion >> copyTraitExpression [
	"Copy all except the actual traits"
	^TraitExclusion 
		with: subject
		exclusions: exclusions asArray
]

{ #category : #accessing }
TraitExclusion >> exclusions [
	^exclusions
]

{ #category : #accessing }
TraitExclusion >> exclusions: aCollection [
	exclusions := Set withAll: aCollection
]

{ #category : #composition }
TraitExclusion >> includesSelector: selector [
	"Answers true if the receiver provides the selector"
	^(subject includesSelector: selector) and:[(exclusions includes: selector) not]
]

{ #category : #initialize }
TraitExclusion >> initialize [
	super initialize.
	exclusions := Set new.

]

{ #category : #composition }
TraitExclusion >> printOn: aStream [
	"Answer the trait composition string (used for class definitions)"
	aStream nextPutAll: '('.
	aStream nextPutAll: subject asString.
	aStream nextPutAll: ' - {'.
	exclusions asArray sort do:[:exc| aStream store: exc] separatedBy:[aStream nextPutAll: '. '].
	aStream nextPutAll: '}'.
	aStream nextPutAll: ')'.
]

{ #category : #composition }
TraitExclusion >> selectorsAndMethodsDo: aBlock [
	"enumerates all selectors and methods in a trait composition"
	^subject selectorsAndMethodsDo:[:sel :meth|
		(exclusions includes: sel) ifFalse:[aBlock value: sel value: meth].
	].
]
