"
A trait transformation representing the alias (->) operator.
"
Class {
	#name : #TraitAlias,
	#superclass : #TraitTransformation,
	#instVars : [
		'aliases'
	],
	#category : #'Traits-Composition'
}

{ #category : #'instance creation' }
TraitAlias class >> assertValidAliasDefinition: anArrayOfAssociations [
	"Throw an exceptions if the alias definition is not valid.
	It is expected to be a collection of associations and
	the number of arguments of the alias selector has to
	be the same as the original selector."

	((anArrayOfAssociations isKindOf: Collection) and: [
		anArrayOfAssociations allSatisfy: [:each |
			each isKindOf: Association]]) ifFalse: [
		self error: 'Invalid alias definition: Not a collection of associations.'].
	
	(anArrayOfAssociations allSatisfy: [:association |
		(association key numArgs = association value numArgs and: [
			(association key numArgs = -1) not])]) ifFalse: [
		TraitCompositionException signal: 'Invalid alias definition: Alias and original selector have to have the same number of arguments.']
]

{ #category : #'instance creation' }
TraitAlias class >> with: aTraitComposition aliases: anArrayOfAssociations [
	self assertValidAliasDefinition: anArrayOfAssociations.
	^self new
		subject: aTraitComposition;
		initializeFrom: anArrayOfAssociations;
		yourself
]

{ #category : #converting }
TraitAlias >> - anArrayOfSelectors [
	^TraitExclusion
		with: self
		exclusions: anArrayOfSelectors
]

{ #category : #converting }
TraitAlias >> @ anArrayOfAssociations [ 
	^TraitAlias 
		with: subject
		aliases: (anArrayOfAssociations, self aliases)
]

{ #category : #accessing }
TraitAlias >> aliases [
	"Collection of associations where key is the
	alias and value the original selector."
	^aliases
]

{ #category : #accessing }
TraitAlias >> aliases: aCollection [
	"Collection of associations where key is the
	alias and value the original selector."
	aliases := aCollection
]

{ #category : #operations }
TraitAlias >> copyTraitExpression [
	"Copy all except the actual traits"
	^TraitAlias 
		with: subject
		aliases: aliases
]

{ #category : #operations }
TraitAlias >> includesSelector: selector [
	"Answers true if the receiver provides the selector"
	^(subject includesSelector: selector) or:[aliases anySatisfy:[:assoc| assoc key == selector]]
]

{ #category : #'initialize-release' }
TraitAlias >> initialize [
	super initialize.
	aliases := #().
]

{ #category : #'initialize-release' }
TraitAlias >> initializeFrom: anArrayOfAssociations [
	| newNames |
	newNames := anArrayOfAssociations collect: [:each | each key] as: IdentitySet.
	newNames size < anArrayOfAssociations size ifTrue: [
		TraitCompositionException signal: 'Cannot use the same alias name twice'].
	anArrayOfAssociations do: [:each |
		(newNames includes: each value) ifTrue: [
			TraitCompositionException signal: 'Cannot define an alias for an alias']].
	aliases := anArrayOfAssociations.

]

{ #category : #testing }
TraitAlias >> isAliasSelector: selector [
	^(self isLocalAliasSelector: selector) or:[super isAliasSelector: selector]
]

{ #category : #testing }
TraitAlias >> isLocalAliasSelector: selector [
	^(aliases anySatisfy:[:assoc| assoc key == selector])
]

{ #category : #operations }
TraitAlias >> printOn: s [
	"Answer the trait composition string (used for class definitions)"
	s nextPutAll: '('.
	s nextPutAll: subject asString.
	s nextPutAll: ' @ {'.
	aliases do:[:assoc| s print: assoc] separatedBy:[s nextPutAll:'. '].
	s nextPutAll: '}'.
	s nextPutAll: ')'.
]

{ #category : #operations }
TraitAlias >> selectorsAndMethodsDo: aBlock [
	"enumerates all selectors and methods in a trait composition"

	subject selectorsAndMethodsDo: aBlock.
	aliases do:[:assoc| | method |
		"Method can be nil during removals"
		method := subject compiledMethodAt: assoc value ifAbsent:[nil].
		method ifNotNil:[aBlock value: assoc key value: method].
	].
]
