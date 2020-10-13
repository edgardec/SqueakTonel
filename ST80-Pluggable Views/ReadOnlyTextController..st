Class {
	#name : #ReadOnlyTextController,
	#superclass : #PluggableTextController,
	#category : #'ST80-Pluggable Views'
}

{ #category : #'menu messages' }
ReadOnlyTextController >> accept [ 
	"Overridden to allow accept of clean text"
	(view setText: paragraph text from: self) ifTrue:
		[initialText := paragraph text copy.
		view ifNotNil: [view hasUnacceptedEdits: false]].

]

{ #category : #'edit flag' }
ReadOnlyTextController >> userHasEdited [
	"Ignore this -- I stay clean"
]

{ #category : #private }
ReadOnlyTextController >> zapSelectionWith: aText [
	view flash  "no edits allowed"
]
