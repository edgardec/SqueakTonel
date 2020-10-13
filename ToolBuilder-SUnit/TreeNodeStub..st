Class {
	#name : #TreeNodeStub,
	#superclass : #WidgetStub,
	#instVars : [
		'item'
	],
	#category : #'ToolBuilder-SUnit'
}

{ #category : #'instance creation' }
TreeNodeStub class >> fromSpec: aSpec item: anObject [
	^ self new setSpec: aSpec item: anObject
]

{ #category : #simulating }
TreeNodeStub >> children [
	^ (self model perform: spec getChildren with: item)
		collect: [:ea | TreeNodeStub fromSpec: spec item: ea]
]

{ #category : #simulating }
TreeNodeStub >> item [
	^ item
]

{ #category : #simulating }
TreeNodeStub >> label [
	^ self model perform: spec label with: item
]

{ #category : #private }
TreeNodeStub >> matches: aString [
	^ self label = aString
]

{ #category : #private }
TreeNodeStub >> matchesItem: anItem [
	^ self item = anItem
]

{ #category : #events }
TreeNodeStub >> openPath: anArray [
	| child |
	anArray isEmpty 
		ifTrue: [self select]
		ifFalse: [child := self children 
								detect: [:ea | ea matches: anArray first] 
								ifNone: [^ self select].
				child openPath: anArray allButFirst]
	
]

{ #category : #printing }
TreeNodeStub >> printOn: aStream [
	aStream
		print: self class;
		nextPut: $<;
		print: item;
		nextPut: $>
]

{ #category : #simulating }
TreeNodeStub >> select [
	self model perform: spec setSelected with: item
]

{ #category : #private }
TreeNodeStub >> selectPath: anArray [
	| child |
	anArray isEmpty ifTrue: [^ self select].
	child := self children detect: [:ea | ea matchesItem: anArray first] ifNone: [^ self select].
	child selectPath: anArray allButFirst.
]

{ #category : #'initialize-release' }
TreeNodeStub >> setSpec: aSpec item: anObject [
	super setSpec: aSpec.
	item := anObject
]
