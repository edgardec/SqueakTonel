Class {
	#name : #NamePolicy,
	#superclass : #Object,
	#category : #'Environments-Policies'
}

{ #category : #naming }
NamePolicy >> name: aSymbol do: aBlock [
	self subclassResponsibility
]
