Class {
	#name : #CRCError,
	#superclass : #Error,
	#category : #'Compression-Streams'
}

{ #category : #'as yet unclassified' }
CRCError >> isResumable [
	^true
]
