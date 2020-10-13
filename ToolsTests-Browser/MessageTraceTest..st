Class {
	#name : #MessageTraceTest,
	#superclass : #MessageSetTest,
	#category : #'ToolsTests-Browser'
}

{ #category : #running }
MessageTraceTest >> setUp [
	browser := (MessageTrace
		openMessageList: (SystemNavigation default allImplementorsOf: #browseAllImplementorsOf:)
		name: 'Test MessageSet'
		autoSelect: nil) model.
		
	browser addDependent: self.
]

{ #category : #tests }
MessageTraceTest >> testRemoveMessageFromBrowser [
	| count sel |
	browser messageListIndex: 1.
	sel := browser selection.
	
	browser removeMessageFromBrowser.
	self deny: (browser messageList includes: sel) description: 'Method not removed'.

	"In a MessageTrace, having an unselected message and then removing it means 'remove the first message'."
	browser messageListIndex: 0.
	count := browser messageList size.
	browser removeMessageFromBrowser.
	self assert: count - 1 = browser messageList size description: 'Method not removed'.
]
