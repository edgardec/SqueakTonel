Class {
	#name : #PseudoClassOrganizer,
	#superclass : #BasicClassOrganizer,
	#category : #'System-FilePackage'
}

{ #category : #'comment accessing' }
PseudoClassOrganizer >> classComment [
	"Answer the comment associated with the object that refers to the receiver."
	classComment == nil ifTrue: [^''].
	^classComment
]

{ #category : #'comment accessing' }
PseudoClassOrganizer >> classComment: aChangeRecord [
	classComment := aChangeRecord
]

{ #category : #accessing }
PseudoClassOrganizer >> setDefaultList: aCollection [
	super setDefaultList: aCollection.
	self classComment: nil.
]
