Class {
	#name : #ListStub,
	#superclass : #WidgetStub,
	#instVars : [
		'list',
		'index'
	],
	#category : #'ToolBuilder-SUnit'
}

{ #category : #simulating }
ListStub >> click: aString [
	self clickItemAt: (self list indexOf: aString)
]

{ #category : #simulating }
ListStub >> clickItemAt: anInteger [
	| selector |
	selector := spec setIndex.
	selector
		ifNil: [self model perform: spec setSelected with: (self list at: anInteger)]
		ifNotNil: [self model perform: selector with: anInteger]

]

{ #category : #simulating }
ListStub >> list [
	^ list ifNil: [Array new]
]

{ #category : #simulating }
ListStub >> menu [
	^ MenuStub fromSpec:
		(self model 
			perform: spec menu 
			with: (PluggableMenuSpec withModel: self model))
]

{ #category : #events }
ListStub >> refresh [
	self refreshList.
	self refreshIndex
]

{ #category : #events }
ListStub >> refreshIndex [
	| selector |
	selector := spec getIndex.
	index := selector
		ifNil: [self list indexOf: (self model perform: spec getSelected)]
		ifNotNil: [spec model perform: selector]

]

{ #category : #events }
ListStub >> refreshList [
	list := self model perform: spec list
]

{ #category : #simulating }
ListStub >> selectedIndex [
	^ index ifNil: [0]
]

{ #category : #simulating }
ListStub >> selectedItem [
	| items idx |
	(items  := self list) isEmpty ifTrue: [^ nil].
	(idx := self selectedIndex) = 0 ifTrue: [^ nil].
	^ items at: idx
	
]

{ #category : #events }
ListStub >> update: aSelector [
	aSelector = spec list ifTrue: [^ self refreshList].
	aSelector = spec getSelected ifTrue: [^ self refreshIndex].
	aSelector = spec getIndex ifTrue: [^ self refreshIndex].
	^ super update: aSelector
]
