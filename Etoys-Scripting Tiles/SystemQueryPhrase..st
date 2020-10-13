Class {
	#name : #SystemQueryPhrase,
	#superclass : #PhraseTileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #miscellaneous }
SystemQueryPhrase >> actualObject [
	^ nil
]

{ #category : #miscellaneous }
SystemQueryPhrase >> associatedPlayer [
	^ nil
]

{ #category : #initialization }
SystemQueryPhrase >> initialize [
	"Initialize the receiver.  In this case we primarily seek to undo the damage done by inherited implementors of #initialize"

	super initialize.
	self removeAllMorphs.
	resultType := #Boolean.
	self vResizing: #shrinkWrap
]

{ #category : #access }
SystemQueryPhrase >> isBooleanType [
	^ true
]

{ #category : #'code generation' }
SystemQueryPhrase >> storeCodeOn: aStream indent: tabCount [
	submorphs first storeCodeOn: aStream indent: tabCount
]
