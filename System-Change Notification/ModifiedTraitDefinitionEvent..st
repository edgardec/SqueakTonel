Class {
	#name : #ModifiedTraitDefinitionEvent,
	#superclass : #ModifiedEvent,
	#category : #'System-Change Notification'
}

{ #category : #accessing }
ModifiedTraitDefinitionEvent class >> supportedKinds [
	"All the kinds of items that this event can take."
	
	^ Array with: self classKind
]

{ #category : #'instance creation' }
ModifiedTraitDefinitionEvent class >> traitDefinitionChangedFrom: oldTrait to: newTrait [
	| instance |
	instance := self item: newTrait kind: self classKind.
	instance oldItem: oldTrait.
	^instance
]

{ #category : #testing }
ModifiedTraitDefinitionEvent >> anyChanges [
	^ self isTraitCompositionModified
]

{ #category : #testing }
ModifiedTraitDefinitionEvent >> isTraitCompositionModified [
	^self traitComposition printString ~= self oldTraitComposition printString
]

{ #category : #accessing }
ModifiedTraitDefinitionEvent >> oldTraitComposition [
	^ oldItem traitComposition
]

{ #category : #printing }
ModifiedTraitDefinitionEvent >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' TraitComposition: ';
		print: self isTraitCompositionModified
]

{ #category : #accessing }
ModifiedTraitDefinitionEvent >> traitComposition [

	^ self item traitComposition
]
