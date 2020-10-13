Class {
	#name : #MCNoChangesException,
	#superclass : #Exception,
	#category : #'Monticello-Versioning'
}

{ #category : #handling }
MCNoChangesException >> defaultAction [
	self inform: 'No changes'
]
