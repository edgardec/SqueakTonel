Class {
	#name : #AllNamePolicy,
	#superclass : #NamePolicy,
	#category : #'Environments-Policies'
}

{ #category : #naming }
AllNamePolicy >> name: aSymbol do: aBlock [
	^ aBlock value: aSymbol
]
