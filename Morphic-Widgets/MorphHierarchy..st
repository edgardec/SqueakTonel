Class {
	#name : #MorphHierarchy,
	#superclass : #Object,
	#category : #'Morphic-Widgets'
}

{ #category : #opening }
MorphHierarchy class >> openOrDelete [
	| oldMorph |
	oldMorph := Project current world submorphs
				detect: [:each | each hasProperty: #morphHierarchy]
				ifNone: [| newMorph | 
					newMorph := self new asMorph.
					newMorph bottomLeft: self currentHand position.
					newMorph openInWorld.
					newMorph isFullOnScreen
						ifFalse: [newMorph goHome].
					^ self].
	""
	oldMorph delete
]

{ #category : #private }
MorphHierarchy >> asMorph [
	"Answer the morph version of the receiver"
	| morph |
	morph := MorphHierarchyListMorph
				on: self
				list: #roots
				selected: nil
				changeSelected: #selected:.
	""
	^ morph inAContainer
]

{ #category : #accessing }
MorphHierarchy >> roots [
	"Answer the roots for the Object Hierarchy, that means answer the world"
	^ {MorphListItemWrapper with: Project current world}
]

{ #category : #accessing }
MorphHierarchy >> selected: aMorphListItemWrapper [ 
	"Change the selected object"
	| newSelection |
	aMorphListItemWrapper isNil
		ifTrue: [^ self].
	newSelection := aMorphListItemWrapper withoutListWrapper.
	newSelection == Project current world selectedObject
		ifTrue: [newSelection removeHalo]
		ifFalse: [newSelection addHalo].
	self changed: #selected
]
