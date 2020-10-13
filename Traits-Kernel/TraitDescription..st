"
TraitDescription combines common behavior for both (instance) traits and (meta) class traits.
"
Class {
	#name : #TraitDescription,
	#superclass : #TraitBehavior,
	#instVars : [
		'users'
	],
	#category : #'Traits-Kernel'
}

{ #category : #'conflict methods' }
TraitDescription class >> conflict [
	"This method has a trait conflict"
	^self traitConflict
]

{ #category : #'conflict methods' }
TraitDescription class >> conflict: arg1 [
	"This method has a trait conflict"
	^self traitConflict
]

{ #category : #'conflict methods' }
TraitDescription class >> conflict: arg1 with: arg2 [
	"This method has a trait conflict"
	^self traitConflict
]

{ #category : #'conflict methods' }
TraitDescription class >> conflict: arg1 with: arg2 with: arg3 [
	"This method has a trait conflict"
	^self traitConflict
]

{ #category : #'conflict methods' }
TraitDescription class >> conflict: arg1 with: arg2 with: arg3 with: arg4 [
	"This method has a trait conflict"
	^self traitConflict
]

{ #category : #'conflict methods' }
TraitDescription class >> conflict: arg1 with: arg2 with: arg3 with: arg4 with: arg5 [
	"This method has a trait conflict"
	^self traitConflict
]

{ #category : #'conflict methods' }
TraitDescription class >> conflict: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 [
	"This method has a trait conflict"
	^self traitConflict
]

{ #category : #'conflict methods' }
TraitDescription class >> conflict: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 [
	"This method has a trait conflict"
	^self traitConflict
]

{ #category : #'conflict methods' }
TraitDescription class >> conflict: arg1 with: arg2 with: arg3 with: arg4 with: arg5 with: arg6 with: arg7 with: arg8 [
	"This method has a trait conflict"
	^self traitConflict
]

{ #category : #operations }
TraitDescription >> + aTrait [
	"Creates a composition with the receiver and aTrait"
	aTrait traitsDo:[:t| self == t ifTrue:[TraitCompositionException
			signal: 'Trait ' , self asString, ' already in composition']].
	^TraitComposition withAll: {self}, aTrait asTraitComposition
]

{ #category : #operations }
TraitDescription >> - anArrayOfSelectors [
	"Creates an exclusion"
	^TraitExclusion
		with: self
		exclusions: anArrayOfSelectors
]

{ #category : #operations }
TraitDescription >> @ anArrayOfAssociations [ 
	"Creates an alias"
	^TraitAlias with: self aliases: anArrayOfAssociations
]

{ #category : #operations }
TraitDescription >> addSelectorSilently: selector withMethod: compiledMethod [
	"Overridden to update the users of this trait"
	CurrentReadOnlySourceFiles cacheDuring: [
		super addSelectorSilently: selector withMethod: compiledMethod.
		self users do:[:each| each updateTraits]]
]

{ #category : #accessing }
TraitDescription >> addTraitUser: aTrait [
	users := self users copyWith: aTrait.

]

{ #category : #accessing }
TraitDescription >> allClassVarNames [
	"Traits have no class var names"
	^#()
]

{ #category : #converting }
TraitDescription >> asTraitComposition [
	^TraitComposition with: self
]

{ #category : #accessing }
TraitDescription >> classPool [
	"Traits have no class pool"
	^ Dictionary new
]

{ #category : #copying }
TraitDescription >> copy [ 
	self error: 'Traits cannot be trivially copied'
]

{ #category : #copying }
TraitDescription >> copyTraitExpression [
	"Copy all except the actual traits"
	^self
]

{ #category : #'fileIn\/Out' }
TraitDescription >> fileOut [
	"Create a file whose name is the name of the receiver with '.st' as the 
	extension, and file a description of the receiver onto it."
	^ self fileOutAsHtml: false
]

{ #category : #'fileIn\/Out' }
TraitDescription >> fileOutAsHtml: useHtml [
	"File a description of the receiver onto a new file whose base name is the name of the receiver."

	| internalStream |
	internalStream := WriteStream on: (String new: 100).
	internalStream header; timeStamp.

	self fileOutOn: internalStream moveSource: false toFile: 0.
	internalStream trailer.

	FileStream writeSourceCodeFrom: internalStream baseName: self name isSt: true useHtml: useHtml.

]

{ #category : #testing }
TraitDescription >> includesTrait: aTrait [
	^self == aTrait or:[super includesTrait: aTrait]
]

{ #category : #operations }
TraitDescription >> installTraitsFrom: aTraitComposition [
	super installTraitsFrom: aTraitComposition.
	self users do:[:each| each updateTraits].
]

{ #category : #testing }
TraitDescription >> isBaseTrait [
	^false
]

{ #category : #testing }
TraitDescription >> isClassTrait [
	^false
]

{ #category : #testing }
TraitDescription >> isTrait [
	^true
]

{ #category : #testing }
TraitDescription >> isTraitTransformation [
	"Polymorphic with TraitTransformation"
	^false
]

{ #category : #operations }
TraitDescription >> notifyOfRecategorizedSelector: element from: oldCategory to: newCategory [
	super notifyOfRecategorizedSelector: element from: oldCategory to: newCategory.
	self users do:[:each| each classify: element under: newCategory from: oldCategory trait: self].
]

{ #category : #printing }
TraitDescription >> printHierarchy [
	"For hierarchy view in the browser; print the users of a trait"
	^String streamContents:[:s| self printUsersOf: self on: s level: 0].
]

{ #category : #printing }
TraitDescription >> printUsersOf: aClass on: aStream level: indent [
	aStream crtab: indent.
	aStream nextPutAll: aClass name.
	aClass isTrait ifTrue:[
		aClass users do:[:each| self printUsersOf: each on: aStream level: indent+1].
	].

]

{ #category : #accessing }
TraitDescription >> removeTraitUser: aTrait [
	users := self users copyWithout: aTrait.

]

{ #category : #accessing }
TraitDescription >> sharedPools [
	"Traits have no shared pools"
	^ Dictionary new
]

{ #category : #accessing }
TraitDescription >> trait [
	^self
]

{ #category : #operations }
TraitDescription >> traitsDo: aBlock [
	aBlock value: self.
]

{ #category : #accessing }
TraitDescription >> users [
	^users ifNil:[#()]
]

{ #category : #accessing }
TraitDescription >> users: aCollection [
	users := aCollection
]
