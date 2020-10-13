Class {
	#name : #EventManagerTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'eventSource',
		'eventListener',
		'succeeded'
	],
	#category : #'Tests-Object Events'
}

{ #category : #private }
EventManagerTest >> addArg1: arg1
addArg2: arg2 [

	eventListener
		add: arg1;
		add: arg2
]

{ #category : #private }
EventManagerTest >> getFalse [

	^false
]

{ #category : #private }
EventManagerTest >> getFalse: anArg [

	^false
]

{ #category : #private }
EventManagerTest >> getTrue [

	^true
]

{ #category : #private }
EventManagerTest >> getTrue: anArg [

	^true
]

{ #category : #private }
EventManagerTest >> heardEvent [

	succeeded := true
]

{ #category : #running }
EventManagerTest >> setUp [

	super setUp.
	eventSource := EventManager new.
	eventListener := Bag new.
	succeeded := false
]

{ #category : #running }
EventManagerTest >> tearDown [

	eventSource releaseActionMap.
	eventSource := nil.
	eventListener := nil.
	super tearDown.

]

{ #category : #'tests-dependent action' }
EventManagerTest >> testBlockReceiverNoArgs [
	eventSource when: #anEvent evaluate:[self heardEvent].
	eventSource triggerEvent: #anEvent.
	self should: [succeeded]
]

{ #category : #'tests-dependent action' }
EventManagerTest >> testBlockReceiverOneArg [
	eventSource when: #anEvent: evaluate:[:arg1| eventListener add: arg1].
	eventSource triggerEvent: #anEvent: with: 9.
	self should: [eventListener includes: 9]
]

{ #category : #'tests-dependent action' }
EventManagerTest >> testBlockReceiverTwoArgs [
	eventSource when: #anEvent:info: evaluate:[:arg1 :arg2| self addArg1: arg1 addArg2: arg2].
	eventSource triggerEvent: #anEvent:info: withArguments: #( 9 42 ).
	self should: [(eventListener includes: 9) and: [eventListener includes: 42]]
]

{ #category : #'tests-copying' }
EventManagerTest >> testCopy [
	"Ensure that the actionMap is zapped when
	you make a copy of anEventManager"

	eventSource when: #blah send: #yourself to: eventListener.
	self assert: eventSource actionMap keys isEmpty not.
	self assert: eventSource copy actionMap keys isEmpty
]

{ #category : #'tests-broadcast query' }
EventManagerTest >> testMultipleValueSuppliers [

	eventSource
		when: #needsValue
		send: #getFalse
		to: self.
	eventSource
		when: #needsValue
		send: #getTrue
		to: self.
	succeeded := eventSource triggerEvent: #needsValue.
	self should: [succeeded]
]

{ #category : #'tests-broadcast query' }
EventManagerTest >> testMultipleValueSuppliersEventHasArguments [

	eventSource
		when: #needsValue:
		send: #getFalse:
		to: self.
	eventSource
		when: #needsValue:
		send: #getTrue:
		to: self.
	succeeded := eventSource triggerEvent: #needsValue: with: 'kolme'.
	self should: [succeeded]
]

{ #category : #'tests-dependent action' }
EventManagerTest >> testNoArgumentEvent [

	eventSource when: #anEvent send: #heardEvent to: self.
	eventSource triggerEvent: #anEvent.
	self should: [succeeded]
]

{ #category : #'tests-dependent action supplied arguments' }
EventManagerTest >> testNoArgumentEventDependentSuppliedArgument [

	eventSource when: #anEvent send: #add: to: eventListener with: 'boundValue'.
	eventSource triggerEvent: #anEvent.
	self should: [eventListener includes: 'boundValue']
]

{ #category : #'tests-dependent action supplied arguments' }
EventManagerTest >> testNoArgumentEventDependentSuppliedArguments [

	eventSource 
		when: #anEvent 
		send: #addArg1:addArg2: 
		to: self 
		withArguments: #('hello' 'world').
	eventSource triggerEvent: #anEvent.
	self should: [(eventListener includes: 'hello') and: [eventListener includes: 'world']]
]

{ #category : #'tests-broadcast query' }
EventManagerTest >> testNoValueSupplier [

	succeeded := eventSource 
		triggerEvent: #needsValue
		ifNotHandled: [true].
	self should: [succeeded]
]

{ #category : #'tests-broadcast query' }
EventManagerTest >> testNoValueSupplierHasArguments [

	succeeded := eventSource 
		triggerEvent: #needsValue:
		with: 'nelja'
		ifNotHandled: [true].
	self should: [succeeded]
]

{ #category : #'tests-dependent action' }
EventManagerTest >> testOneArgumentEvent [

	eventSource when: #anEvent: send: #add: to: eventListener.
	eventSource triggerEvent: #anEvent: with: 9.
	self should: [eventListener includes: 9]
]

{ #category : #'tests-remove actions' }
EventManagerTest >> testRemoveActionsForEvent [

	eventSource
		when: #anEvent send: #size to: eventListener;
		when: #anEvent send: #getTrue to: self;
		when: #anEvent: send: #fizzbin to: self.
	eventSource removeActionsForEvent: #anEvent.
	self shouldnt: [eventSource hasActionForEvent: #anEvent]
]

{ #category : #'tests-remove actions' }
EventManagerTest >> testRemoveActionsTwiceForEvent [

	eventSource
		when: #anEvent send: #size to: eventListener;
		when: #anEvent send: #getTrue to: self;
		when: #anEvent: send: #fizzbin to: self.
	eventSource removeActionsForEvent: #anEvent.
	self assert: (eventSource hasActionForEvent: #anEvent) not.
	eventSource removeActionsForEvent: #anEvent.
	self assert: (eventSource hasActionForEvent: #anEvent) not.
]

{ #category : #'tests-remove actions' }
EventManagerTest >> testRemoveActionsWithReceiver [

	| action |
	eventSource
		when: #anEvent send: #size to: eventListener;
		when: #anEvent send: #getTrue to: self;
		when: #anEvent: send: #fizzbin to: self.
	eventSource removeActionsWithReceiver: self.
	action := eventSource actionForEvent: #anEvent.
	self assert: (action respondsTo: #receiver).
	self assert: ((action receiver == self) not)
]

{ #category : #'tests-dependent value' }
EventManagerTest >> testReturnValueWithManyListeners [

	| value newListener |
	newListener := 'busybody'.
	eventSource
		when: #needsValue
		send: #yourself
		to: eventListener.
	eventSource
		when: #needsValue
		send: #yourself
		to: newListener.
	value := eventSource triggerEvent: #needsValue.
	self should: [value == newListener]
]

{ #category : #'tests-dependent value' }
EventManagerTest >> testReturnValueWithNoListeners [

	| value |
	value := eventSource triggerEvent: #needsValue.
	self should: [value == nil]
]

{ #category : #'tests-dependent value' }
EventManagerTest >> testReturnValueWithOneListener [

	| value |
	eventSource
		when: #needsValue
		send: #yourself
		to: eventListener.
	value := eventSource triggerEvent: #needsValue.
	self should: [value == eventListener]
]

{ #category : #'tests-broadcast query' }
EventManagerTest >> testSingleValueSupplier [

	eventSource
		when: #needsValue
		send: #getTrue
		to: self.
	succeeded := eventSource triggerEvent: #needsValue.
	self should: [succeeded]
]

{ #category : #'tests-dependent action' }
EventManagerTest >> testTwoArgumentEvent [

	eventSource when: #anEvent:info: send: #addArg1:addArg2: to: self.
	eventSource triggerEvent: #anEvent:info: withArguments: #( 9 42 ).
	self should: [(eventListener includes: 9) and: [eventListener includes: 42]]
]
