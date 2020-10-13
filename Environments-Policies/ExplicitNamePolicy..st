Class {
	#name : #ExplicitNamePolicy,
	#superclass : #NamePolicy,
	#instVars : [
		'aliases'
	],
	#category : #'Environments-Policies'
}

{ #category : #'instance creation' }
ExplicitNamePolicy class >> aliases: aCollection [
	^ self basicNew initializeWithAliases: aCollection
]

{ #category : #private }
ExplicitNamePolicy class >> flattenSpec: anObject into: names [
	anObject isSymbol ifTrue:
		[^ names at: anObject put: anObject].
	anObject isVariableBinding ifTrue:
		[^ names add: anObject].
	anObject isDictionary ifTrue:
		[^ names addAll: anObject].
	anObject do:
		[:ea | self flattenSpec: ea into: names]
]

{ #category : #'instance creation' }
ExplicitNamePolicy class >> spec: anObject [
	| aliases |
	(anObject isKindOf: NamePolicy) ifTrue: [^ anObject].
	aliases := IdentityDictionary new.
	self flattenSpec: anObject into: aliases.
	^ self aliases: aliases
]

{ #category : #'initialize-release' }
ExplicitNamePolicy >> initializeWithAliases: aCollection [
	self initialize.
	aliases := IdentityDictionary withAll: aCollection
]

{ #category : #naming }
ExplicitNamePolicy >> name: aSymbol do: aBlock [
	^ aBlock value: (aliases at: aSymbol ifAbsent: [^ nil])
]
