"
This class represents an identity dictionary with weak keys.
"
Class {
	#name : #WeakIdentityKeyDictionary,
	#superclass : #WeakKeyDictionary,
	#category : #'Collections-Weak'
}

{ #category : #private }
WeakIdentityKeyDictionary >> scanFor: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or raise an error if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."

	| index start size |
	index := start := anObject scaledIdentityHash \\ (size := array size) + 1.
	[ 
		| element |
		((element := array at: index) == nil or: [ element key == anObject ])
			ifTrue: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #private }
WeakIdentityKeyDictionary >> scanForEmptySlotFor: anObject [
	"Scan the key array for the first slot containing an empty slot (indicated by a nil). Answer the index of that slot. This method will be overridden in various subclasses that have different interpretations for matching elements."
	
	| index start size |
	index := start := anObject scaledIdentityHash \\ (size := array size) + 1.
	[ 
		(array at: index) ifNil: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]
