"
The class of some trait. Just like the Class - Metaclass relationship.
"
Class {
	#name : #ClassTrait,
	#superclass : #TraitDescription,
	#instVars : [
		'baseTrait'
	],
	#category : #'Traits-Kernel'
}

{ #category : #'instance creation' }
ClassTrait class >> for: baseTrait [
	^self new baseTrait: baseTrait
]

{ #category : #monticello }
ClassTrait >> asMCDefinition [
	^Smalltalk at: #MCClassTraitDefinition ifPresent:[:aClass|
		aClass
			baseTraitName: self baseTrait name
			classTraitComposition: self traitCompositionString
	].
]

{ #category : #accessing }
ClassTrait >> baseTrait [
	^baseTrait
]

{ #category : #accessing }
ClassTrait >> baseTrait: aTrait [
	baseTrait ifNotNil:[self error: 'Already initialized'].
	baseTrait := aTrait.
]

{ #category : #compiling }
ClassTrait >> bindingOf: varName [
	"Answer the binding of some variable resolved in the scope of the receiver"
	^baseTrait bindingOf: varName
]

{ #category : #accessing }
ClassTrait >> category [
	"Answer the category used for classifying this ClassTrait.
	The category is shared between a Trait and its associated ClassTrait."
	
	^baseTrait category
]

{ #category : #accessing }
ClassTrait >> definition [
	^String streamContents: [:stream |
		stream nextPutAll: self name.
		stream cr; tab; nextPutAll: 'uses: ';
				nextPutAll: self traitComposition asString.
	].
]

{ #category : #accessing }
ClassTrait >> environment [
	^ baseTrait environment
]

{ #category : #accessing }
ClassTrait >> instanceSide [
	^self baseTrait
]

{ #category : #testing }
ClassTrait >> isClassTrait [
	^true
]

{ #category : #testing }
ClassTrait >> isMeta [
	^true
]

{ #category : #testing }
ClassTrait >> isObsolete [
	^baseTrait == nil or:[baseTrait isObsolete]
]

{ #category : #accessing }
ClassTrait >> name [
	^baseTrait name, ' classTrait'
]

{ #category : #accessing }
ClassTrait >> soleInstance [
	^baseTrait
]

{ #category : #accessing }
ClassTrait >> theMetaClass [
	^self
]

{ #category : #accessing }
ClassTrait >> theNonMetaClass [
	"Sent to a class or metaclass, always return the class"
	^baseTrait
]

{ #category : #initialize }
ClassTrait >> uses: aTraitComposition [
	| newTraits copyOfOldTrait |
	copyOfOldTrait := self shallowCopy.
	newTraits := aTraitComposition asTraitComposition.
	newTraits traitsDo:[:t|
		(t isBaseTrait and:[t classSide hasMethods]) 
			ifTrue:[self error: 'Cannot add: ', t].
		(t isClassTrait and:[(baseTrait includesTrait: t baseTrait) not]) 
			ifTrue:[self error: 'Cannot add: ', t].
	].
	self installTraitsFrom: newTraits.
	SystemChangeNotifier uniqueInstance
		traitDefinitionChangedFrom: copyOfOldTrait to: self.
]
