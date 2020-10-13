Class {
	#name : #PluggableMenuSpec,
	#superclass : #ToolBuilderSpec,
	#instVars : [
		'label',
		'model',
		'items'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #'as yet unclassified' }
PluggableMenuSpec class >> withModel: aModel [
	^ self new model: aModel
]

{ #category : #construction }
PluggableMenuSpec >> add: aString action: aMessageSend [
	| item |
	item := self addMenuItem.
	item label: aString.
	item action: aMessageSend.
	^item
]

{ #category : #construction }
PluggableMenuSpec >> add: aString target: anObject selector: aSelector argumentList: anArray [
	^self add: aString action: (MessageSend 
				receiver: anObject 
				selector: aSelector
				arguments: anArray).
]

{ #category : #construction }
PluggableMenuSpec >> addList: aList [
	"Add the given items to this menu, where each item is a pair (<string> <actionSelector>)..  If an element of the list is simply the symobl $-, add a line to the receiver.  The optional third element of each entry, if present, provides balloon help."

	aList do: [:tuple |
		(tuple == #-)
			ifTrue: [self addSeparator]
			ifFalse:[ | item |
				item := self add: tuple first target: model selector: tuple second argumentList: #().
				tuple size > 2 ifTrue:[item help: tuple third]]]
]

{ #category : #construction }
PluggableMenuSpec >> addMenuItem [
	| item |
	item := self newMenuItem.
	self items add: item.
	^item
]

{ #category : #construction }
PluggableMenuSpec >> addSeparator [
	self items isEmpty ifTrue:[^nil].
	self items last separator: true.
]

{ #category : #construction }
PluggableMenuSpec >> analyzeItemLabels [
	"Analyze the item labels"
	items do:[:item| item analyzeLabel].

]

{ #category : #construction }
PluggableMenuSpec >> buildWith: builder [
	self analyzeItemLabels.
	^ builder buildPluggableMenu: self
]

{ #category : #accessing }
PluggableMenuSpec >> items [
	^ items ifNil: [items := OrderedCollection new]
]

{ #category : #accessing }
PluggableMenuSpec >> label [
	^label
]

{ #category : #accessing }
PluggableMenuSpec >> label: aString [
	label := aString.
]

{ #category : #accessing }
PluggableMenuSpec >> model [
	^ model
]

{ #category : #accessing }
PluggableMenuSpec >> model: anObject [ 
	model := anObject
]

{ #category : #construction }
PluggableMenuSpec >> newMenuItem [
	^PluggableMenuItemSpec new
]
