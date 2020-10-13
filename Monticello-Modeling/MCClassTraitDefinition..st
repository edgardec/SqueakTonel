Class {
	#name : #MCClassTraitDefinition,
	#superclass : #MCDefinition,
	#instVars : [
		'baseTrait',
		'classTraitComposition'
	],
	#category : #'Monticello-Modeling'
}

{ #category : #'instance creation' }
MCClassTraitDefinition class >> baseTraitName: aString classTraitComposition: classTraitCompositionString [
	^self instanceLike: (
		self new
			initializeWithBaseTraitName: aString
			classTraitComposition: classTraitCompositionString).
]

{ #category : #accessing }
MCClassTraitDefinition >> = aDefinition [
	^ (super = aDefinition)
		and: [baseTrait = aDefinition baseTrait
		and: [self classTraitCompositionString = aDefinition classTraitCompositionString]]


]

{ #category : #visiting }
MCClassTraitDefinition >> accept: aVisitor [
	^ aVisitor visitClassTraitDefinition: self.
]

{ #category : #accessing }
MCClassTraitDefinition >> baseTrait [
	^baseTrait

]

{ #category : #accessing }
MCClassTraitDefinition >> className [
	^self baseTrait
]

{ #category : #accessing }
MCClassTraitDefinition >> classTraitComposition [
	^classTraitComposition


]

{ #category : #accessing }
MCClassTraitDefinition >> classTraitCompositionString [
	^self classTraitComposition ifNil: ['{}'].


]

{ #category : #accessing }
MCClassTraitDefinition >> definitionString [
	^self baseTrait , ' classTrait
	uses: ' , self classTraitCompositionString.

]

{ #category : #accessing }
MCClassTraitDefinition >> description [
	^{
		baseTrait .
		classTraitComposition }
]

{ #category : #accessing }
MCClassTraitDefinition >> hash [

	| hash |
	hash := baseTrait hashWithInitialHash: 0.
	hash := self classTraitCompositionString hashWithInitialHash: hash.
	^hash

]

{ #category : #initialization }
MCClassTraitDefinition >> initializeWithBaseTraitName: aTraitName classTraitComposition: aString [
	baseTrait := aTraitName.
	classTraitComposition := aString.
]

{ #category : #installing }
MCClassTraitDefinition >> load [	
	Compiler evaluate: self definitionString environment: Environment current
]

{ #category : #accessing }
MCClassTraitDefinition >> requirements [
	^{ baseTrait }
]

{ #category : #accessing }
MCClassTraitDefinition >> sortKey [
	^ self baseTrait name , '.classTrait'
]

{ #category : #accessing }
MCClassTraitDefinition >> source [
	^self definitionString
]

{ #category : #accessing }
MCClassTraitDefinition >> summary [
	^self baseTrait , ' classTrait'

]
