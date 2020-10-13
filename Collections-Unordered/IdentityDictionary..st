"
Like a Dictionary, except that keys are compared with #== instead of #= .

See the comment of IdentitySet for more information.
"
Class {
	#name : #IdentityDictionary,
	#superclass : #Dictionary,
	#category : #'Collections-Unordered'
}

{ #category : #accessing }
IdentityDictionary >> keyAtValue: value ifAbsent: exceptionBlock [
	"Answer the key that is the external name for the argument, value. If 
	there is none, answer the result of evaluating exceptionBlock."
 
	^self keyAtIdentityValue: value ifAbsent: exceptionBlock
]

{ #category : #private }
IdentityDictionary >> scanFor: anObject [
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
IdentityDictionary >> scanForEmptySlotFor: anObject [
	"Scan the key array for the first slot containing an empty slot (indicated by a nil). Answer the index of that slot. This method will be overridden in various subclasses that have different interpretations for matching elements."
	
	| index start size |
	index := start := anObject scaledIdentityHash \\ (size := array size) + 1.
	[ 
		(array at: index) ifNil: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]
