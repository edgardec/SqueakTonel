"
Serves as a model for a WorldView -- a morphic world viewed within an mvc project.
"
Class {
	#name : #WorldViewModel,
	#superclass : #Object,
	#instVars : [
		'initialExtent'
	],
	#category : #'Etoys-Squeakland-ST80-Morphic'
}

{ #category : #'user interface' }
WorldViewModel >> fullScreenSize [
	"Answer the size to which a window displaying the receiver should be set"

	^ (0@0 extent: DisplayScreen actualScreenSize) copy
]

{ #category : #'user interface' }
WorldViewModel >> initialExtent [
	initialExtent ifNotNil: [^ initialExtent].
	^ super initialExtent
]

{ #category : #'as yet unclassified' }
WorldViewModel >> initialExtent: anExtent [
	initialExtent := anExtent
]
