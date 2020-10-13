Class {
	#name : #WeakOrderedCollection,
	#superclass : #OrderedCollection,
	#category : #'Collections-Weak'
}

{ #category : #private }
WeakOrderedCollection >> arrayType [
	^ WeakArray
]
