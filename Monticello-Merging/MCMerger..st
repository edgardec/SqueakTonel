Class {
	#name : #MCMerger,
	#superclass : #Object,
	#instVars : [
		'conflicts'
	],
	#category : #'Monticello-Merging'
}

{ #category : #accessing }
MCMerger >> addConflictWithOperation: anOperation [
	self conflicts add: (MCConflict operation: anOperation)
]

{ #category : #applying }
MCMerger >> applyTo: anObject [
	self isMerged ifFalse: [self error: 'You must resolve all the conflicts first'].
	conflicts do: [:ea | ea applyTo: anObject]
]

{ #category : #accessing }
MCMerger >> conflicts [
	^ conflicts ifNil: [conflicts := OrderedCollection new]
]

{ #category : #testing }
MCMerger >> isMerged [
	^ self conflicts allSatisfy: [:ea | ea isResolved]
]

{ #category : #loading }
MCMerger >> load [
	| loader |
	loader := MCPackageLoader new.
	loader provisions addAll: self provisions.
	self applyTo: loader.
	loader load
]

{ #category : #loading }
MCMerger >> loadWithNameLike: baseName [
	| loader |
	loader := MCPackageLoader new.
	loader provisions addAll: self provisions.
	self applyTo: loader.
	loader loadWithNameLike: baseName
]

{ #category : #accessing }
MCMerger >> mergedSnapshot [
	^ MCPatcher apply: self to: self baseSnapshot
]

{ #category : #accessing }
MCMerger >> operations [
	^ #()
]

{ #category : #accessing }
MCMerger >> provisions [
	^ #()
]
