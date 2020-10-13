"
A scrolling help displayer.
"
Class {
	#name : #OLPCHelpDisplayer,
	#superclass : #AlignmentMorphBob1,
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #resizing }
OLPCHelpDisplayer >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed."

	submorphs second extent: (anExtent x @ (anExtent y - submorphs first height))
]
