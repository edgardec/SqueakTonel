Class {
	#name : #MCPatch,
	#superclass : #MCOperationsList,
	#category : #'Monticello-Patching'
}

{ #category : #'instance creation' }
MCPatch class >> fromBase: baseSnapshot target: targetSnapshot [
	^ self new initializeWithBase: baseSnapshot target: targetSnapshot
]

{ #category : #applying }
MCPatch >> applyTo: anObject [
	operations do: [:ea | ea applyTo: anObject].

]

{ #category : #ui }
MCPatch >> browse [
	(self browserClass forPatch: self) show
]

{ #category : #ui }
MCPatch >> browserClass [
	^ MCPatchBrowser
]

{ #category : #accessing }
MCPatch >> ignoring: ignoredOperations [
	^ MCPatch operations: (operations difference: ignoredOperations)
]

{ #category : #'initialize-release' }
MCPatch >> initializeWithBase: baseSnapshot target: targetSnapshot [
	| base target |	
	operations := OrderedCollection new.
	base := MCDefinitionIndex definitions: baseSnapshot definitions.
	target := MCDefinitionIndex definitions: targetSnapshot definitions.
	
	target definitionsDo:
		[:t |
		base
			definitionLike: t
			ifPresent: [:b | (b isSameRevisionAs: t) ifFalse: [operations add: (MCModification of: b to: t)]]
			ifAbsent: [operations add: (MCAddition of: t)]].
		
	base definitionsDo:
		[:b |
		target
			definitionLike: b
			ifPresent: [:t]
			ifAbsent: [operations add: (MCRemoval of: b)]]		
]
