"
A pluggable system window. Fixes the issues with label retrieval and adds support for changing children.
"
Class {
	#name : #PluggableSystemWindow,
	#superclass : #SystemWindow,
	#instVars : [
		'getLabelSelector',
		'getChildrenSelector',
		'children',
		'closeWindowSelector'
	],
	#category : #'ToolBuilder-Morphic'
}

{ #category : #accessing }
PluggableSystemWindow >> addPaneMorph: aMorph [
	self addMorph: aMorph fullFrame: aMorph layoutFrame
]

{ #category : #accessing }
PluggableSystemWindow >> closeWindowSelector [
	^closeWindowSelector
]

{ #category : #accessing }
PluggableSystemWindow >> closeWindowSelector: aSymbol [
	closeWindowSelector := aSymbol
]

{ #category : #initialization }
PluggableSystemWindow >> delete [
	(model notNil and: [ closeWindowSelector notNil ]) ifTrue: [ model perform: closeWindowSelector ].
	super delete
]

{ #category : #accessing }
PluggableSystemWindow >> getChildrenSelector [
	^getChildrenSelector
]

{ #category : #accessing }
PluggableSystemWindow >> getChildrenSelector: aSymbol [
	getChildrenSelector := aSymbol
]

{ #category : #accessing }
PluggableSystemWindow >> getLabelSelector [
	^getLabelSelector
]

{ #category : #accessing }
PluggableSystemWindow >> getLabelSelector: aSymbol [
	getLabelSelector := aSymbol.
	self update: aSymbol.
]

{ #category : #accessing }
PluggableSystemWindow >> label [
	^label contents
]

{ #category : #accessing }
PluggableSystemWindow >> label: aString [
	self setLabel: aString.
]

{ #category : #updating }
PluggableSystemWindow >> update: what [
	what ifNil:[^self].
	what == getLabelSelector ifTrue:[self setLabel: (model perform: getLabelSelector)].
	what == getChildrenSelector ifTrue:[
		children ifNil:[children := #()].
		self removeAllMorphsIn: children.
		children := model perform: getChildrenSelector.
		self addAllMorphs: children.
		children do:[:m| m hResizing: #spaceFill; vResizing: #spaceFill].
	].
	^super update: what
]
