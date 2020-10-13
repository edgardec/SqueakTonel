"
A verison of the SetInspector specialized for inspecting WeakSets.  It knows about the flag object used to indicate empty locations in the hash table.
"
Class {
	#name : #WeakSetInspector,
	#superclass : #SetInspector,
	#category : #'Tools-Inspector'
}

{ #category : #private }
WeakSetInspector >> isElementValid: anElement [
	"Consider the #flag object, which is used to mark GC'ed elements in the WeakSet."

	^ anElement notNil and: [anElement ~~ (self object instVarNamed: #flag)]
]
