Class {
	#name : #ModifiedClassDefinitionEvent,
	#superclass : #ModifiedEvent,
	#category : #'System-Change Notification'
}

{ #category : #'instance creation' }
ModifiedClassDefinitionEvent class >> classDefinitionChangedFrom: oldClass to: newClass [
	| instance |
	instance := self item: newClass kind: self classKind.
	instance oldItem: oldClass.
	^instance
]

{ #category : #accessing }
ModifiedClassDefinitionEvent class >> supportedKinds [
	"All the kinds of items that this event can take."
	
	^ Array with: self classKind
]

{ #category : #'change logging' }
ModifiedClassDefinitionEvent >> anyChanges [
	^ self isSuperclassModified or: [self areInstVarsModified or: [self areClassVarsModified or: [self areSharedPoolsModified or: [self isTraitCompositionModified]]]]
]

{ #category : #testing }
ModifiedClassDefinitionEvent >> areClassVarsModified [
	^ self classVarNames ~= self oldClassVarNames
]

{ #category : #testing }
ModifiedClassDefinitionEvent >> areInstVarsModified [
	^ self instVarNames ~= self oldInstVarNames
]

{ #category : #testing }
ModifiedClassDefinitionEvent >> areSharedPoolsModified [
	^ self sharedPools ~= self oldSharedPools
]

{ #category : #accessing }
ModifiedClassDefinitionEvent >> classVarNames [

	^ self item classVarNames
]

{ #category : #accessing }
ModifiedClassDefinitionEvent >> instVarNames [

	^ self item instVarNames asSet
]

{ #category : #testing }
ModifiedClassDefinitionEvent >> isSuperclassModified [

	^ self item superclass ~~ self oldItem superclass
]

{ #category : #'trait composition' }
ModifiedClassDefinitionEvent >> isTraitCompositionModified [
	^self traitComposition printString ~= self oldTraitComposition printString
]

{ #category : #accessing }
ModifiedClassDefinitionEvent >> oldClassVarNames [
	^ oldItem classVarNames
]

{ #category : #accessing }
ModifiedClassDefinitionEvent >> oldInstVarNames [
	^ oldItem instVarNames asSet
]

{ #category : #accessing }
ModifiedClassDefinitionEvent >> oldSharedPools [
	^ oldItem sharedPools
]

{ #category : #accessing }
ModifiedClassDefinitionEvent >> oldSuperclass [
	^ oldItem superclass
]

{ #category : #'trait composition' }
ModifiedClassDefinitionEvent >> oldTraitComposition [
	^ oldItem traitComposition
]

{ #category : #printing }
ModifiedClassDefinitionEvent >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPutAll: ' Super: ';
		print: self isSuperclassModified;
		nextPutAll: ' TraitComposition: ';
		print: self isTraitCompositionModified;
		nextPutAll: ' InstVars: ';
		print: self areInstVarsModified;
		nextPutAll: ' ClassVars: ';
		print: self areClassVarsModified;
		nextPutAll: ' SharedPools: ';
		print: self areSharedPoolsModified.
]

{ #category : #accessing }
ModifiedClassDefinitionEvent >> sharedPools [

	^ self item sharedPools
]

{ #category : #accessing }
ModifiedClassDefinitionEvent >> superclass [
	
	^ self item superclass
]

{ #category : #'trait composition' }
ModifiedClassDefinitionEvent >> traitComposition [
	
	^ self item traitComposition
]
