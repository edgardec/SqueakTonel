Class {
	#name : #MessageSetTest,
	#superclass : #TestCase,
	#instVars : [
		'browser',
		'updates'
	],
	#category : #'ToolsTests-Browser'
}

{ #category : #'initialize-release' }
MessageSetTest >> initialize [
	super initialize.
	
	"Contains the triggers sent by the model during its updates."
	updates := OrderedCollection new.
]

{ #category : #running }
MessageSetTest >> setUp [
	browser := (MessageSet
		openMessageList: (SystemNavigation default allImplementorsOf: #browseAllImplementorsOf:)
		name: 'Test MessageSet'
		autoSelect: nil) model.

	browser addDependent: self.
]

{ #category : #running }
MessageSetTest >> tearDown [
	ToolBuilder default close: browser topView.
]

{ #category : #tests }
MessageSetTest >> testAutoSelectString [
	browser autoSelectString: 'browseAllImplementorsOf:'.
	self assert: browser autoSelectString = 'browseAllImplementorsOf:'.
	browser messageListIndex: 2.
	self assert: (updates includes: #autoSelect).
]

{ #category : #tests }
MessageSetTest >> testContents [
	browser messageListIndex: 0.
	self assert: browser contents = ''.
	
	browser messageListIndex: 1.
	self deny: browser contents = ''.
	
]

{ #category : #tests }
MessageSetTest >> testHasMessageSelected [
	browser messageListIndex: 1.
	self assert: browser hasMessageSelected.
	
	browser messageListIndex: 0.
	self deny: browser hasMessageSelected.
	
	"And just to be sure:"
	browser messageListIndex: 1.
	self assert: browser hasMessageSelected.
]

{ #category : #tests }
MessageSetTest >> testRemoveMessageFromBrowser [
	| count sel |
	browser messageListIndex: 1.
	sel := browser selection.
	
	browser removeMessageFromBrowser.
	self deny: (browser messageList includes: sel) description: 'Method not removed'.

	browser messageListIndex: 0.
	count := browser messageList size.
	browser removeMessageFromBrowser.
	self assert: count = browser messageList size description: 'Some method was removed'.
]

{ #category : #tests }
MessageSetTest >> testSelectedClassOrMetaClass [
	| firstClass |
	firstClass := browser messageList first actualClass.
	
	browser messageListIndex: 1.
	self assert: browser selectedClassOrMetaClass = firstClass.
	
	browser messageListIndex: 0.
	self assert: browser selectedClassOrMetaClass isNil.
	
	"And just to be sure:"
	browser messageListIndex: 1.
	self assert: browser selectedClassOrMetaClass = firstClass.
]

{ #category : #tests }
MessageSetTest >> testSelectedMessageCategoryName [
	| firstCat methodRef |
	methodRef := browser messageList first.
	firstCat := methodRef actualClass organization categoryOfElement: methodRef selector.
	
	browser messageListIndex: 1.
	self assert: browser selectedMessageCategoryName = firstCat.
	
	browser messageListIndex: 0.
	self assert: browser selectedMessageCategoryName isNil.
	
	"And just to be sure:"
	browser messageListIndex: 1.
	self assert: browser selectedMessageCategoryName = firstCat.
]

{ #category : #tests }
MessageSetTest >> testSelectedMessageName [
	| firstSel |
	firstSel := browser messageList first selector.
	
	browser messageListIndex: 1.
	self assert: browser selectedMessageName = firstSel.
	
	browser messageListIndex: 0.
	self assert: browser selectedMessageName isNil.
	
	"And just to be sure:"
	browser messageListIndex: 1.
	self assert: browser selectedMessageName = firstSel.
]

{ #category : #tests }
MessageSetTest >> testSelection [
	| firstRef |
	firstRef := browser messageList first.
	
	browser messageListIndex: 1.
	self assert: browser selection = firstRef.
	
	browser messageListIndex: 0.
	self assert: browser selection isNil.
	
	"And just to be sure:"
	browser messageListIndex: 1.
	self assert: browser selection = firstRef.
]

{ #category : #private }
MessageSetTest >> update: aSelector [
	updates addLast: aSelector.
]
