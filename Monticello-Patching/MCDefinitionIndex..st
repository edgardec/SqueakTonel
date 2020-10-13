"
I'm just a wrapper for a KeyedSet with keyBlock [ :definition | definition description ] translating #add: to #put:.
"
Class {
	#name : #MCDefinitionIndex,
	#superclass : #Object,
	#instVars : [
		'definitions'
	],
	#category : #'Monticello-Patching'
}

{ #category : #'instance creation' }
MCDefinitionIndex class >> definitions: aCollection [

	^self basicNew
		initialize: aCollection size;
		addAll: aCollection;
		yourself
]

{ #category : #adding }
MCDefinitionIndex >> add: aDefinition [

	^definitions put: aDefinition
]

{ #category : #adding }
MCDefinitionIndex >> addAll: aCollection [

	aCollection do: [ :each |
		definitions put: each ]
]

{ #category : #accessing }
MCDefinitionIndex >> definitionLike: aDefinition ifPresent: foundBlock ifAbsent: absentBlock [

	^(definitions like: aDefinition ifAbsent: nil)
		ifNil: [ absentBlock value ]
		ifNotNil: [ :definition |
			foundBlock value: definition ]
]

{ #category : #accessing }
MCDefinitionIndex >> definitions [
	
	^definitions asArray
]

{ #category : #enumerating }
MCDefinitionIndex >> definitionsDo: aBlock [
	
	definitions do: aBlock
]

{ #category : #'initialize-release' }
MCDefinitionIndex >> initialize [

	self initialize: 10
]

{ #category : #'initialize-release' }
MCDefinitionIndex >> initialize: initialCapacity [

	definitions := (KeyedSet new: initialCapacity)
		keyBlock: [ :object | object description ];
		yourself
]

{ #category : #removing }
MCDefinitionIndex >> remove: aDefinition [

	^definitions remove: aDefinition ifAbsent: nil
]
