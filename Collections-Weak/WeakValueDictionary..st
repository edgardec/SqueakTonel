"
I am a dictionary holding only weakly on my values. Clients may expect to get a nil value for any object they request.
"
Class {
	#name : #WeakValueDictionary,
	#superclass : #Dictionary,
	#category : #'Collections-Weak'
}

{ #category : #adding }
WeakValueDictionary >> add: anAssociation [
	self at: anAssociation key put: anAssociation value.
	^ anAssociation
]

{ #category : #accessing }
WeakValueDictionary >> associationClass [

	^WeakValueAssociation
]
