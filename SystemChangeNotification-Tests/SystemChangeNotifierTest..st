"
A SystemChangeNotifierTest is a test class that tests whether the triggering of changes indeed results in the intended changes to be sent to registered object. The basic mechanism for each test is fairly simple:
	- register the receiver as the one to get the change notifier.
	- manually trigger a change (so the system is not polluted just to see whether we get the needed event).
	- the method #event: is invoked and remembers the change event.
	- the change event is checked to see whether it was the intended one.

Instance Variables
	capturedEvent:		Remembers the captured event
"
Class {
	#name : #SystemChangeNotifierTest,
	#superclass : #SystemChangeTestRoot,
	#instVars : [
		'capturedEvent',
		'notifier'
	],
	#category : #'SystemChangeNotification-Tests'
}

{ #category : #Private }
SystemChangeNotifierTest >> capturedEvent: eventOrNil [
	"Remember the event being sent."

	capturedEvent := eventOrNil
]

{ #category : #Private }
SystemChangeNotifierTest >> checkEventForClass: aClass category: cat change: changeKind [ 

	self assert: (capturedEvent perform: ('is' , changeKind) asSymbol).
	self assert: capturedEvent item = aClass.
	self assert: capturedEvent itemKind = AbstractEvent classKind.
	self assert: capturedEvent itemClass = aClass.
	self assert: capturedEvent itemCategory = cat
]

{ #category : #Private }
SystemChangeNotifierTest >> checkEventForMethod: aMethod protocol: prot change: changeKind [ 

	self assert: (capturedEvent perform: ('is' , changeKind) asSymbol).
	self assert: capturedEvent item = aMethod.
	self assert: capturedEvent itemKind = AbstractEvent methodKind.
	self assert: capturedEvent itemClass = self class.
	self assert: capturedEvent itemMethod = aMethod.
	self assert: capturedEvent itemProtocol = prot
]

{ #category : #Private }
SystemChangeNotifierTest >> checkEventForMethod: aMethod protocol: prot change: changeKind oldMethod: oldMethod [

	self checkEventForMethod: aMethod protocol: prot change: changeKind.
	self assert: capturedEvent oldItem == oldMethod
	
]

{ #category : #'Event Notifications' }
SystemChangeNotifierTest >> event: event [
	"The notification message being sent to me when an event is captured. Remember it."

"	capturedEvent isNil ifTrue: [	self capturedEvent: event] ifFalse: [self assert: false]"

	self capturedEvent: event
]

{ #category : #Running }
SystemChangeNotifierTest >> setUp [

	super setUp.
	notifier := SystemChangeNotifier createInstance.
]

{ #category : #Private }
SystemChangeNotifierTest >> systemChangeNotifier [
	"The notifier to use. Do not use the one in the system so that the fake events triggered in the tests perturb clients of the system's change notifier (e.g. the changes file then shows fake entries)."

	^notifier
]

{ #category : #Running }
SystemChangeNotifierTest >> tearDown [

	super tearDown.
	self capturedEvent: nil.
	notifier releaseAll.
	notifier := nil
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testClassAddedEvent [

	self systemChangeNotifier notify: self ofAllSystemChangesUsing: #event:.
	self systemChangeNotifier classAdded: self class inCategory: #FooCat.
	self
		checkEventForClass: self class
		category: #FooCat
		change: #Added
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testClassAddedEvent2 [

	self systemChangeNotifier notify: self ofSystemChangesOfItem: #class change: #Added using: #event:.
	self systemChangeNotifier classAdded: self class inCategory: #FooCat.
	self
		checkEventForClass: self class
		category: #FooCat
		change: #Added
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testClassCommentedEvent [

	self systemChangeNotifier notify: self ofAllSystemChangesUsing: #event:.
	self systemChangeNotifier classCommented: self class inCategory: #FooCat.
	self
		checkEventForClass: self class
		category: #FooCat
		change: #Commented
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testClassRecategorizedEvent [

	self systemChangeNotifier notify: self ofAllSystemChangesUsing: #event:.
	self systemChangeNotifier 
		class: self class
		recategorizedFrom: #FooCat
		to: #FooBar.
	self
		checkEventForClass: self class
		category: #FooBar
		change: #Recategorized.
	self assert: capturedEvent oldCategory = #FooCat
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testClassRemovedEvent [

	self systemChangeNotifier notify: self ofAllSystemChangesUsing: #event:.
	self systemChangeNotifier classRemoved: self class fromCategory: #FooCat.
	self
		checkEventForClass: self class
		category: #FooCat
		change: #Removed
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testClassRenamedEvent [
	"self run: #testClassRenamedEvent"

	self systemChangeNotifier notify: self ofAllSystemChangesUsing: #event:.
	self systemChangeNotifier 
		classRenamed: self class
		from: #OldFooClass
		to: #NewFooClass
		inCategory: #FooCat.
	self
		checkEventForClass: self class
		category: #FooCat
		change: #Renamed.
"	self assert: capturedEvent oldName = #OldFooClass.
	self assert: capturedEvent newName = #NewFooClass"
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testDoItEvent [

	self systemChangeNotifier notify: self ofAllSystemChangesUsing: #event:.
	self systemChangeNotifier 
		evaluated: '1 + 2'
		context: self.
	self assert: capturedEvent isDoIt.
	self assert: capturedEvent item = '1 + 2'.
	self assert: capturedEvent itemKind = AbstractEvent expressionKind.
	self assert: capturedEvent itemClass = nil.
	self assert: capturedEvent itemMethod = nil.
	self assert: capturedEvent itemProtocol = nil.
	self assert: capturedEvent itemExpression = '1 + 2'.
	self assert: capturedEvent context = self.
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testMethodAddedEvent1 [

	self systemChangeNotifier notify: self ofAllSystemChangesUsing: #event:.
	self systemChangeNotifier 
		methodAdded: self class >> #testMethodAddedEvent1
		selector: #testMethodAddedEvent1
		inProtocol: #FooCat
		class: self class.
	self 
		checkEventForMethod: self class >> #testMethodAddedEvent1
		protocol: #FooCat
		change: #Added
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testMethodAddedEvent2 [

	self systemChangeNotifier notify: self ofAllSystemChangesUsing: #event:.
	self systemChangeNotifier 
		methodAdded: self class >> #testMethodAddedEvent1
		selector: #testMethodAddedEvent1
		inClass: self class.
	self 
		checkEventForMethod: self class >> #testMethodAddedEvent1
		protocol: nil
		change: #Added
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testMethodAddedEvent3 [

	self systemChangeNotifier notify: self ofAllSystemChangesUsing: #event:.
	self systemChangeNotifier 
		methodChangedFrom: self class >> #testMethodAddedEvent1
		to: self class >> #testMethodAddedEvent2
		selector: #testMethodAddedEvent2
		inClass: self class.
	self 
		checkEventForMethod: self class >> #testMethodAddedEvent2
		protocol: nil
		change: #Modified
		oldMethod: self class >> #testMethodAddedEvent1.
]

{ #category : #'Testing-system triggers' }
SystemChangeNotifierTest >> testMethodRemovedEvent [

	self systemChangeNotifier notify: self ofAllSystemChangesUsing: #event:.
	self systemChangeNotifier 
		methodRemoved: self class>> #testMethodRemovedEvent
		selector: #testMethodRemovedEvent
		inProtocol: #FooCat
		class: self class.
	self
		checkEventForMethod: self class>> #testMethodRemovedEvent
		protocol: #FooCat
		change: #Removed.
]
