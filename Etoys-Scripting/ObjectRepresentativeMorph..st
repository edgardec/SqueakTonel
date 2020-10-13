Class {
	#name : #ObjectRepresentativeMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'objectRepresented'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #scripting }
ObjectRepresentativeMorph >> categoriesForViewer [
	"Answer a list of symbols representing the categories to offer in the viewer, in order"

	^ objectRepresented class organization categories

]

{ #category : #naming }
ObjectRepresentativeMorph >> nameOfObjectRepresented [
	"Answer the external name of the object represented"

	^ objectRepresented externalName
]

{ #category : #macpal }
ObjectRepresentativeMorph >> objectRepresented [
	"Answer the object represented by the receiver"

	^ objectRepresented
]

{ #category : #'as yet unclassified' }
ObjectRepresentativeMorph >> objectRepresented: anObject [
	"Set the receiver's representee.  This clears out any preexisting state in the receiver"

	objectRepresented := anObject.
	self removeAllMorphs.
	self hResizing: #shrinkWrap.  
	self vResizing: #shrinkWrap.
	self addMorphBack: (StringMorph new contents: anObject name asString).
	self setNameTo: anObject name
	
]

{ #category : #'as yet unclassified' }
ObjectRepresentativeMorph >> objectRepresented: anObject labelString: aLabel [
	"Set the receiver's representee as indicated, and use the given label to tag it"

	objectRepresented := anObject.
	self removeAllMorphs.
	self hResizing: #shrinkWrap.  
	self vResizing: #shrinkWrap.
	self addMorphBack: (StringMorph new contents: aLabel asString).
	self setNameTo: aLabel asString
	
]
