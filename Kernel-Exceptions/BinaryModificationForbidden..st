"
A BinaryModificationForbidden is a variation of ModificationForbidden for messages that need neither fieldIndex nor newObject, such as elementsExchangeIdentityWith: and adoptInstance:. It overrides the retryModification method.

Instance Variables

"
Class {
	#name : #BinaryModificationForbidden,
	#superclass : #ModificationForbidden,
	#category : #'Kernel-Exceptions'
}

{ #category : #retrying }
BinaryModificationForbidden >> retryModification [
	mirror perform: retrySelector with: object.
	self resume: resumptionValue
]

{ #category : #retrying }
BinaryModificationForbidden >> retryModificationNoResume [
	mirror perform: retrySelector with: object
]
