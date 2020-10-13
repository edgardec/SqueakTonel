Class {
	#name : #ListViewLine,
	#superclass : #ObjectRepresentativeMorph,
	#category : #'Etoys-Scripting'
}

{ #category : #'e-toy support' }
ListViewLine >> listViewLineForFieldList: aFieldList [
	"Answer a list view line containing data representing the items in aFieldList"

	^ objectRepresented == self
		ifFalse:
			[objectRepresented listViewLineForFieldList: aFieldList]
		ifTrue:
			[super listViewLineForFieldList: aFieldList]
]

{ #category : #thumbnail }
ListViewLine >> morphRepresented [
	"Answer the morph that I actually represent"

	^ objectRepresented
]

{ #category : #'object represented' }
ListViewLine >> objectRepresented: anObject [
	"Set the object represented by the receiver to be as requested"

	objectRepresented := anObject.
	self hResizing: #shrinkWrap.
	self vResizing: #shrinkWrap.
	self setNameTo: anObject name.
	self removeAllMorphs.

]
