"
I am an inspector for bags. I specialize the inspector for dictionaries because I expose the internal dictionary all bags use.
"
Class {
	#name : #BagInspector,
	#superclass : #DictionaryInspector,
	#category : #'Tools-Inspector'
}

{ #category : #'menu commands' }
BagInspector >> addElement: anObject [

	self object add: anObject.
	self updateFields.
	self selectElementAt: anObject.
]

{ #category : #private }
BagInspector >> elementGetterAt: element [
	"Return a way to access the number of occurrences in the bag for the given element."
	
	^ [:bag | (bag instVarNamed: #contents) at: element]
]

{ #category : #initialization }
BagInspector >> elementIndices [

	^ [ (object instVarNamed: #contents) keysInOrder ] ifError: [
		"Can occur when debugging Bag new"
		Array empty ].
]

{ #category : #private }
BagInspector >> elementSetterAt: element [
	"Change the number of occurrences for the given element."
	
	^ [:bag :count | (bag instVarNamed: #contents) at: element put: count]
]

{ #category : #bindings }
BagInspector >> isBindingSelected [

	^ false
]

{ #category : #'menu commands' }
BagInspector >> removeSelectedElement [

	self object remove: self selectedKey.
]
