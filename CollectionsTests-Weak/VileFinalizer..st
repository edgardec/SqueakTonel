Class {
	#name : #VileFinalizer,
	#superclass : #Object,
	#instVars : [
		'weakRegistry'
	],
	#category : #'CollectionsTests-Weak'
}

{ #category : #'as yet unclassified' }
VileFinalizer >> finalize [
	weakRegistry remove: self ifAbsent: [].
]

{ #category : #'as yet unclassified' }
VileFinalizer >> initialize: wr [
	weakRegistry := wr.
	weakRegistry add: self.
]
