"
MCReorganizationPreloader ensures that definitions moved between two packages are not removed temporarily, independent of their load order.

Moves appear as deletion in one package and addition in another package. If the deletion precedes the addition, the entity will be removed from the system for a short period of time, and then recreated later. This is potentially fatal.

MCReorganizationPreloader detects these problematic definitions and combines them into MCModifications. They then get 'preloaded' (applied to the system) so when the actual packages are loaded later, they become no-ops (because the definition in the image is already in the right package).

Instance Variables
	preloads:	generated modifications
	currentRemovals:		definitions removed by the version currently being added
	previousRemovals:		definitions removed by previously added versions

"
Class {
	#name : #MCReorganizationPreloader,
	#superclass : #Object,
	#instVars : [
		'preloads',
		'previousRemovals',
		'currentRemovals'
	],
	#category : #'Monticello-Loading'
}

{ #category : #loading }
MCReorganizationPreloader class >> preloadMovesBetween: versions [
	| loader |
	loader := self new.
	versions do: [ :version |
		loader addVersion: version].
	^ loader preload
]

{ #category : #'patch ops' }
MCReorganizationPreloader >> addDefinition: new [
	previousRemovals definitionLike: new
		ifPresent: [ :old | preloads add: (MCModification of: old to: new) ]
		ifAbsent: [ "ignore" ].

]

{ #category : #accessing }
MCReorganizationPreloader >> addVersion: aVersion [
	| patch |
	previousRemovals addAll: currentRemovals definitions.
	currentRemovals := MCDefinitionIndex new.
	patch := aVersion canOptimizeLoading
		ifTrue: [aVersion patch]
		ifFalse: [aVersion snapshot patchRelativeToBase: aVersion package snapshot].
	patch applyTo: self.



]

{ #category : #'initialize-release' }
MCReorganizationPreloader >> initialize [
	preloads := Set new.
	previousRemovals := MCDefinitionIndex new.
	currentRemovals := MCDefinitionIndex new.

]

{ #category : #'patch ops' }
MCReorganizationPreloader >> modifyDefinition: old to: new [
	"ignore"
]

{ #category : #loading }
MCReorganizationPreloader >> preload [
	preloads ifNotEmpty: [ | loader |
		loader := MCPackageLoader new.
		(MCPatch operations: preloads) applyTo: loader.
		loader loadWithNameLike: 'mcPreload'].

]

{ #category : #'patch ops' }
MCReorganizationPreloader >> removeDefinition: old [
	currentRemovals add: old.

]
