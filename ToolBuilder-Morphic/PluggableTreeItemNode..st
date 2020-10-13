"
Tree item for PluggableTreeMorph. My model is the tree morph. I keep track of my parent item and the index in my parent's list of children to support selective refreshing.
"
Class {
	#name : #PluggableTreeItemNode,
	#superclass : #ListItemWrapper,
	#instVars : [
		'parent',
		'index'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #accessing }
PluggableTreeItemNode >> acceptDroppingObject: anotherItem [
	^model dropNode: anotherItem on: self
]

{ #category : #accessing }
PluggableTreeItemNode >> asString [
	^model printNode: self
]

{ #category : #accessing }
PluggableTreeItemNode >> balloonText [
	^model balloonTextForNode: self
]

{ #category : #accessing }
PluggableTreeItemNode >> canBeDragged [
	^model isDraggableNode: self
]

{ #category : #accessing }
PluggableTreeItemNode >> contents [
	^model contentsOfNode: self
]

{ #category : #accessing }
PluggableTreeItemNode >> hasContents [
	^model hasNodeContents: self
]

{ #category : #accessing }
PluggableTreeItemNode >> icon [
	^model iconOfNode: self
]

{ #category : #accessing }
PluggableTreeItemNode >> index [

	^ index
]

{ #category : #accessing }
PluggableTreeItemNode >> index: anInteger [

	index := anInteger.
]

{ #category : #accessing }
PluggableTreeItemNode >> item [
	^item
]

{ #category : #accessing }
PluggableTreeItemNode >> parent [
	^ parent
]

{ #category : #accessing }
PluggableTreeItemNode >> parent: aNode [
	parent := aNode.
]

{ #category : #'as yet unclassified' }
PluggableTreeItemNode >> refresh [
	
	self parent ifNil: [^ self].
	self setItem: (self parent contents
		at: self index
		ifAbsent: [self error: 'No support for changed child count yet!'])
			item.
]

{ #category : #accessing }
PluggableTreeItemNode >> wantsDroppedObject: anotherItem [
	^model wantsDroppedNode: anotherItem on: self
]
