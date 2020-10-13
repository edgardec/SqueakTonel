"
Contributed by Bob Arning as part of the ObjectExplorer package.

"
Class {
	#name : #AbstractHierarchicalList,
	#superclass : #Model,
	#instVars : [
		'currentSelection',
		'myBrowser'
	],
	#category : #'Morphic-Explorer'
}

{ #category : #menus }
AbstractHierarchicalList >> genericMenu: aMenu [

	aMenu add: 'no menu yet' target: self selector: #yourself.
	^aMenu
]

{ #category : #selection }
AbstractHierarchicalList >> getCurrentSelection [

	^currentSelection
]

{ #category : #selection }
AbstractHierarchicalList >> noteNewSelection: x [

	currentSelection := x.
	self changed: #getCurrentSelection.
	currentSelection ifNil: [^self].
	currentSelection sendSettingMessageTo: self.

]

{ #category : #'message handling' }
AbstractHierarchicalList >> perform: selector orSendTo: otherTarget [
	"Selector was just chosen from a menu by a user.  If can respond, then
perform it on myself. If not, send it to otherTarget, presumably the
editPane from which the menu was invoked."

	(self respondsTo: selector)
		ifTrue: [^ self perform: selector]
		ifFalse: [^ otherTarget perform: selector]
]

{ #category : #updating }
AbstractHierarchicalList >> update: aSymbol [

	aSymbol == #hierarchicalList ifTrue: [
		^self changed: #getList
	].
	super update: aSymbol
]
