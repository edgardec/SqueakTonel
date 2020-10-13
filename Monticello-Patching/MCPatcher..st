Class {
	#name : #MCPatcher,
	#superclass : #Object,
	#instVars : [
		'definitions'
	],
	#category : #'Monticello-Patching'
}

{ #category : #applying }
MCPatcher class >> apply: aPatch to: aSnapshot [
	| loader |
	loader := self snapshot: aSnapshot.
	aPatch applyTo: loader.
	^ loader patchedSnapshot
]

{ #category : #'instance creation' }
MCPatcher class >> snapshot: aSnapshot [
	^ self new initializeWithSnapshot: aSnapshot
]

{ #category : #accessing }
MCPatcher >> addDefinition: aDefinition [
	definitions add: aDefinition
]

{ #category : #'initialize-release' }
MCPatcher >> initializeWithSnapshot: aSnapshot [
	definitions := MCDefinitionIndex definitions: aSnapshot definitions
]

{ #category : #applying }
MCPatcher >> modifyDefinition: baseDefinition to: targetDefinition [
	self addDefinition: targetDefinition
]

{ #category : #applying }
MCPatcher >> patchedSnapshot [
	^ MCSnapshot fromDefinitions: definitions definitions
]

{ #category : #accessing }
MCPatcher >> removeDefinition: aDefinition [
	definitions remove: aDefinition
]
