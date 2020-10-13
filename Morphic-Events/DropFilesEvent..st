Class {
	#name : #DropFilesEvent,
	#superclass : #DropEvent,
	#category : #'Morphic-Events'
}

{ #category : #dispatching }
DropFilesEvent >> sentTo: anObject [
	"Dispatch the receiver into anObject"
	self type == #dropFilesEvent ifTrue:[^anObject handleDropFiles: self].
]

{ #category : #accessing }
DropFilesEvent >> type [
	^#dropFilesEvent
]
