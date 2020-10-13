"
This class tests the error handing of the notification mechanism to ensure that one client that receives a system change cannot lock up the complete system.
"
Class {
	#name : #SystemChangeErrorHandlingTest,
	#superclass : #SystemChangeTestRoot,
	#instVars : [
		'capturedEvents'
	],
	#category : #'SystemChangeNotification-Tests'
}

{ #category : #'Event Notifications' }
SystemChangeErrorHandlingTest >> handleEventWithError: event [

	self error: 'Example of event handling code that throws an error.'
]

{ #category : #'Event Notifications' }
SystemChangeErrorHandlingTest >> handleEventWithHalt: event [

	self halt: 'Example of event handling code that contains a halt.'
]

{ #category : #Running }
SystemChangeErrorHandlingTest >> setUp [

	super setUp.
	capturedEvents := OrderedCollection new
]

{ #category : #'Event Notifications' }
SystemChangeErrorHandlingTest >> storeEvent1: anEvent [

	capturedEvents add: anEvent
]

{ #category : #'Event Notifications' }
SystemChangeErrorHandlingTest >> storeEvent2: anEvent [

	capturedEvents add: anEvent
]

{ #category : #'Event Notifications' }
SystemChangeErrorHandlingTest >> storeEvent3: anEvent [

	capturedEvents add: anEvent
]

{ #category : #Running }
SystemChangeErrorHandlingTest >> tearDown [

	capturedEvents := nil.
	super tearDown
]

{ #category : #Testing }
SystemChangeErrorHandlingTest >> testErrorOperation [

	| notifier wasCaptured |
	notifier := self systemChangeNotifier.
	wasCaptured := false.
	notifier notify: self ofSystemChangesOfItem: #class change: #Added using: #storeEvent1:.
	notifier notify: self ofSystemChangesOfItem: #class change: #Added using: #storeEvent2:.
	notifier notify: self ofSystemChangesOfItem: #class change: #Added using: #handleEventWithError:.
	notifier notify: self ofSystemChangesOfItem: #class change: #Added using: #storeEvent3:.
	[notifier classAdded: self class inCategory: #FooCat] on: Error do: [:exc |
		wasCaptured := true.
		self assert: (capturedEvents size = 3)].
	self assert: wasCaptured.
]

{ #category : #Testing }
SystemChangeErrorHandlingTest >> testHaltOperation [
	
	| notifier wasCaptured |
	notifier := self systemChangeNotifier.
	wasCaptured := false.
	notifier notify: self ofAllSystemChangesUsing: #storeEvent1:.
	notifier notify: self ofAllSystemChangesUsing: #storeEvent2:.
	notifier notify: self ofAllSystemChangesUsing: #handleEventWithHalt:.
	notifier notify: self ofAllSystemChangesUsing: #storeEvent3:.
	[notifier classAdded: self class inCategory: #FooCat] on: Halt do: [:exc |
		wasCaptured := true.
		self assert: (capturedEvents size = 3)].
	self assert: wasCaptured.
]

{ #category : #Testing }
SystemChangeErrorHandlingTest >> testUnhandledEventOperation [

	| notifier wasCaptured |
	notifier := self systemChangeNotifier.
	wasCaptured := false.
	notifier notify: self ofSystemChangesOfItem: #class change: #Added using: #storeEvent1:.
	notifier notify: self ofSystemChangesOfItem: #class change: #Added using: #storeEvent2:.
	notifier notify: self ofSystemChangesOfItem: #class change: #Added using: #zork:.
	notifier notify: self ofSystemChangesOfItem: #class change: #Added using: #storeEvent3:.
	[notifier classAdded: self class inCategory: #FooCat] on: MessageNotUnderstood do: [:exc |
		wasCaptured := true.
		self assert: (capturedEvents size = 3)].
	self assert: wasCaptured.
]
