Class {
	#name : #ValueHolder,
	#superclass : #Model,
	#instVars : [
		'contents'
	],
	#category : #'Kernel-Models'
}

{ #category : #accessing }
ValueHolder >> contents [
	^contents
]

{ #category : #accessing }
ValueHolder >> contents: newContents [

	contents = newContents ifTrue: [^ self].
	contents := newContents.
	self contentsChanged
]
