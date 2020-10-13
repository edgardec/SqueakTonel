"
I am an inspector for bit sets. I display bits with zero based indexing corresponding to the bit numbering conventions of a bit field.
"
Class {
	#name : #BitsetInspector,
	#superclass : #CollectionInspector,
	#category : #'Tools-Inspector'
}

{ #category : #'menu - commands' }
BitsetInspector >> addElement: anInteger [
	"Flip the specified bit to 1 and select it. Note that there is no need to #updateFields here because of the bitset's semantics for #add:."

	self object add: anInteger.
	self selectElementAt: anInteger.
]

{ #category : #private }
BitsetInspector >> elementIndices [

	^ 0 to: self objectSize - 1
]

{ #category : #fields }
BitsetInspector >> fieldSize [

	^ (self newFieldForType: #misc key: #size)
		name: 'num 1 bits' translated; emphasizeName;
		valueGetter: [:bitset | bitset size];
		yourself
]

{ #category : #private }
BitsetInspector >> objectSize [

	^ self object capacity
]

{ #category : #'menu - commands' }
BitsetInspector >> removeSelectedElement [
	"Flip the selected bit back to 0."

	self selectedField setValueFor: self to: 0.
]

{ #category : #'fields - streaming' }
BitsetInspector >> streamBaseFieldsOn: aStream [

	super streamBaseFieldsOn: aStream.
	aStream nextPut: self fieldSize.
]
