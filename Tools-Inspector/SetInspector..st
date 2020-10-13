"
I am an inspector that is specialized for inspecting Sets. I display the elements of the set like elements of an array. Note that the indices, being phyical locations in the hash table, are not meaningful outside of the set.
"
Class {
	#name : #SetInspector,
	#superclass : #CollectionInspector,
	#category : #'Tools-Inspector'
}

{ #category : #private }
SetInspector >> elementGetterAt: index [

	^ [:set | (set array at: index) enclosedSetElement]
]

{ #category : #private }
SetInspector >> elementIndices [
	"In the set's internal array, extract the indices that point to actual elements."
	
	| numIndices |
	(numIndices := self objectSize) = 0
		ifTrue: [^#()].
	
	^ Array
		new: numIndices
		streamContents: [:stream |
			self object array doWithIndex: [:element :index |
				(self isElementValid: element) ifTrue: [stream nextPut: index]]]
]

{ #category : #private }
SetInspector >> elementSetterAt: index [
	"Because of sets are hashed collections, we have to use the public interface, which means removing the element the index is pointing to first -- and only then can we add the new element."

	^ [:set :element | 
			set remove: (set array at: index) enclosedSetElement.
			set add: element]
]

{ #category : #private }
SetInspector >> isElementValid: anElement [

	^ anElement notNil
]

{ #category : #selection }
SetInspector >> replaceSelectionValue: anObject [
	"After replacing the value, we have to scan for the field that now contains anObject."
	
	(super replaceSelectionValue: anObject) ifTrue: [
		self updateFields.
		self selectFieldSuchThat: [:field | [(field getValueFor: self) == anObject] ifError: [false] ]].
]
