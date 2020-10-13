Class {
	#name : #SystemChangeNotifier,
	#superclass : #Object,
	#instVars : [
		'eventSource',
		'silenceLevel'
	],
	#classVars : [
		'UniqueInstance'
	],
	#category : #'System-Change Notification'
}

{ #category : #'item kinds' }
SystemChangeNotifier class >> categoryKind [

	^ AbstractEvent categoryKind
]

{ #category : #'item kinds' }
SystemChangeNotifier class >> classKind [

	^ AbstractEvent classKind
]

{ #category : #private }
SystemChangeNotifier class >> createInstance [

	^self basicNew initialize
]

{ #category : #'item kinds' }
SystemChangeNotifier class >> environmentKind [

	^ AbstractEvent environmentKind
]

{ #category : #'item kinds' }
SystemChangeNotifier class >> expressionKind [

	^ AbstractEvent expressionKind
]

{ #category : #private }
SystemChangeNotifier class >> instanceCreationErrorString [

	^'This is a singleton implementation, so you are not allowed to create instances yourself. Use #uniqueInstance to access the instance.'
]

{ #category : #'item kinds' }
SystemChangeNotifier class >> methodKind [

	^ AbstractEvent methodKind
]

{ #category : #'instance creation' }
SystemChangeNotifier class >> new [

	^self error: self instanceCreationErrorString
]

{ #category : #'item kinds' }
SystemChangeNotifier class >> protocolKind [

	^ AbstractEvent protocolKind
]

{ #category : #private }
SystemChangeNotifier class >> resetUniqueInstance [
	"self resetUniqueInstance"

	UniqueInstance
		ifNotNil: [:u | UniqueInstance releaseAll.
			UniqueInstance := nil]
]

{ #category : #public }
SystemChangeNotifier class >> uniqueInstance [

	UniqueInstance ifNil: [UniqueInstance := self createInstance].
	^UniqueInstance
]

{ #category : #'private-event lists' }
SystemChangeNotifier >> allSystemEvents [
	^AbstractEvent systemEvents
]

{ #category : #'system triggers' }
SystemChangeNotifier >> class: aClass recategorizedFrom: oldCategory to: newCategory [ 
	self trigger: (RecategorizedEvent 
				class: aClass
				category: newCategory
				oldCategory: oldCategory)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> classAdded: aClass inCategory: aCategoryName [ 
	self trigger: (AddedEvent class: aClass category: aCategoryName)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> classCategoryAdded: aClassCategoryName [

	self trigger: (AddedEvent
					classCategory: aClassCategoryName)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> classCategoryRemoved: aClassCategoryName [

	self trigger: (RemovedEvent
					classCategory: aClassCategoryName)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> classCategoryRenamedFrom: anOldClassCategoryName to: aNewClassCategoryName [

	self trigger: (RenamedEvent
					classCategoryRenamedFrom: anOldClassCategoryName 
					to: aNewClassCategoryName)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> classCommented: aClass [
	"A class with the given name was commented in the system."

	self trigger: (CommentedEvent class: aClass)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> classCommented: aClass inCategory: aCategoryName [ 
	"A class with the given name was commented in the system."

	self trigger: (CommentedEvent class: aClass category: aCategoryName)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> classDefinitionChangedFrom: oldClass to: newClass [
	self trigger: (ModifiedClassDefinitionEvent classDefinitionChangedFrom: oldClass to: newClass)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> classRemoved: aClass fromCategory: aCategoryName [ 
	self trigger: (RemovedEvent class: aClass category: aCategoryName)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> classRenamed: aClass from: oldClassName to: newClassName inCategory: aCategoryName [ 
	self trigger: (RenamedEvent 
				class: aClass
				category: aCategoryName
				oldName: oldClassName
				newName: newClassName)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> classReorganized: aClass [
	self trigger: (ReorganizedEvent class: aClass)
]

{ #category : #public }
SystemChangeNotifier >> doSilently: aBlock [
	"Perform the block, and ensure that no system notification are broadcasted while doing so."

	| result |
	silenceLevel := silenceLevel + 1.
	result := aBlock ensure: [silenceLevel > 0 ifTrue: [silenceLevel := silenceLevel - 1]].
	^ result.
]

{ #category : #'system triggers' }
SystemChangeNotifier >> evaluated: textOrStream [
	^ self evaluated: textOrStream context: nil.
]

{ #category : #'system triggers' }
SystemChangeNotifier >> evaluated: expression context: aContext [
	self trigger: (DoItEvent 
				expression: expression
				context: aContext)
]

{ #category : #initialize }
SystemChangeNotifier >> initialize [

	eventSource := SystemEventManager new.
	silenceLevel := 0.
]

{ #category : #public }
SystemChangeNotifier >> isBroadcasting [

	^ silenceLevel = 0
]

{ #category : #'system triggers' }
SystemChangeNotifier >> methodAdded: aMethod selector: aSymbol inClass: aClass [ 
	"A method with the given selector was added to aClass, but not put in a protocol."

	self trigger: (AddedEvent
				method: aMethod 
				selector: aSymbol
				class: aClass)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> methodAdded: aMethod selector: aSymbol inClass: aClass requestor: requestor [
	"A method with the given selector was added to aClass, but not put in a protocol."

	self trigger: (AddedEvent
				method: aMethod 
				selector: aSymbol
				class: aClass
				requestor: requestor)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> methodAdded: aMethod selector: aSymbol inProtocol: aCategoryName class: aClass [ 
	"A method with the given selector was added to aClass in protocol aCategoryName."

	self trigger: (AddedEvent
				method: aMethod
				selector: aSymbol
				protocol: aCategoryName
				class: aClass)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> methodAdded: aMethod selector: aSymbol inProtocol: aCategoryName class: aClass requestor: requestor [
	"A method with the given selector was added to aClass in protocol aCategoryName."

	self trigger: (AddedEvent
				method: aMethod
				selector: aSymbol
				protocol: aCategoryName
				class: aClass
				requestor: requestor)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass [
	self trigger: (ModifiedEvent
					methodChangedFrom: oldMethod
					to: newMethod
					selector: aSymbol 
					inClass: aClass)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> methodChangedFrom: oldMethod to: newMethod selector: aSymbol inClass: aClass requestor: requestor [
	self trigger: (ModifiedEvent
					methodChangedFrom: oldMethod
					to: newMethod
					selector: aSymbol 
					inClass: aClass
					requestor: requestor)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> methodRemoved: aMethod selector: aSymbol class: aClass [ 
	"A method with the given selector was removed from the class."

	self trigger: (RemovedEvent
				method: aMethod 
				selector: aSymbol
				class: aClass)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> methodRemoved: aMethod selector: aSymbol inProtocol: protocol class: aClass [ 
	"A method with the given selector was removed from the class."

	self trigger: (RemovedEvent
				method: aMethod 
				selector: aSymbol
				protocol: protocol
				class: aClass)
]

{ #category : #public }
SystemChangeNotifier >> noMoreNotificationsFor: anObject [
	"Stop sending system notifications to an object."

	eventSource removeActionsWithReceiver: anObject
]

{ #category : #public }
SystemChangeNotifier >> notify: anObject ofAllSystemChangesUsing: oneArgumentSelector [ 
	"Notifies an object of any system changes."

	self 
		notify: anObject
		ofEvents: self allSystemEvents
		using: oneArgumentSelector
]

{ #category : #private }
SystemChangeNotifier >> notify: anObject ofEvents: eventsCollection using: oneArgumentSelector [
	"Notifies an object of any events in the eventsCollection. Send it back a message #oneArgumentSelector, with as argument the particular system event instance."

	eventsCollection do: [:eachEvent |
		eventSource when: eachEvent send: oneArgumentSelector to: anObject]
]

{ #category : #public }
SystemChangeNotifier >> notify: anObject ofSystemChangesOfChange: changeKind using: oneArgumentSelector [ 
	"Notifies an object of system changes of the specified changeKind (#added, #removed, ...). Evaluate 'AbstractEvent allChangeKinds' to get the complete list."

	self 
		notify: anObject
		ofEvents: (self systemEventsForChange: changeKind)
		using: oneArgumentSelector
]

{ #category : #public }
SystemChangeNotifier >> notify: anObject ofSystemChangesOfItem: itemKind change: changeKind using: oneArgumentSelector [ 
	"Notifies an object of system changes of the specified itemKind (#class, #category, ...) and changeKind (#added, #removed, ...). This is the finest granularity possible.
	Evaluate 'AbstractEvent allChangeKinds' to get the complete list of change kinds, and 'AbstractEvent allItemKinds to get all the possible item kinds supported."

	self 
		notify: anObject
		ofEvents: (Bag with: (self systemEventsForItem: itemKind change: changeKind))
		using: oneArgumentSelector
]

{ #category : #public }
SystemChangeNotifier >> notify: anObject ofSystemChangesOfItem: itemKind  using: oneArgumentSelector [ 
	"Notifies an object of system changes of the specified itemKind (#class, #method, #protocol, ...). Evaluate 'AbstractEvent allItemKinds' to get the complete list."

	self 
		notify: anObject
		ofEvents: (self systemEventsForItem: itemKind)
		using: oneArgumentSelector
]

{ #category : #'system triggers' }
SystemChangeNotifier >> protocolAdded: aProtocol inClass: aClass [ 
	self trigger: (
		AddedEvent protocol: aProtocol class: aClass
	)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> protocolRemoved: aProtocol inClass: aClass [ 
	self trigger: (
		RemovedEvent protocol: aProtocol class: aClass
	)
]

{ #category : #'system triggers' }
SystemChangeNotifier >> protocolRenamedFrom: anOldProtocol to: aNewProtocol inClass: aClass [ 
	self trigger: (
		(RenamedEvent protocol: anOldProtocol class: aClass)
			oldName: anOldProtocol;
			newName: aNewProtocol
	)
]

{ #category : #private }
SystemChangeNotifier >> releaseAll [
	"Release all the dependents so that nobody receives notifications anymore."

	"Done for cleaning up the system."
	"self uniqueInstance releaseAll"

	eventSource releaseActionMap
]

{ #category : #'system triggers' }
SystemChangeNotifier >> selector: selector recategorizedFrom: oldCategory to: newCategory inClass: aClass [

	self trigger: (RecategorizedEvent 
				selector: selector
				method: (aClass compiledMethodAt: selector ifAbsent: [nil])
				protocol: newCategory
				class: aClass
				oldProtocol: oldCategory)
]

{ #category : #private }
SystemChangeNotifier >> setBroadcasting [
	silenceLevel := 0.
]

{ #category : #'private-event lists' }
SystemChangeNotifier >> systemEventsForChange: changeKind [ 
	| selectorBlock |
	selectorBlock := AbstractEvent eventSelectorBlock.
	^AbstractEvent allItemKinds 
		collect: [:itemKind | selectorBlock value: itemKind value: changeKind]
]

{ #category : #'private-event lists' }
SystemChangeNotifier >> systemEventsForItem: itemKind [ 
	| selectorBlock |
	selectorBlock := AbstractEvent eventSelectorBlock.
	^AbstractEvent allChangeKinds 
		collect: [:changeKind | selectorBlock value: itemKind value: changeKind]
]

{ #category : #'private-event lists' }
SystemChangeNotifier >> systemEventsForItem: itemKind change: changeKind [ 
	^AbstractEvent eventSelectorBlock value: itemKind value: changeKind
]

{ #category : #'system triggers' }
SystemChangeNotifier >> traitDefinitionChangedFrom: oldTrait to: newTrait [
	self trigger: (ModifiedTraitDefinitionEvent traitDefinitionChangedFrom: oldTrait to: newTrait)
]

{ #category : #private }
SystemChangeNotifier >> trigger: event [

	self isBroadcasting ifTrue: [event trigger: eventSource]

"	| caughtExceptions |
	caughtExceptions := OrderedCollection new.
	self isBroadcasting ifTrue: [
		[(eventSource actionForEvent: event eventSelector) valueWithArguments: (Array with: event)] on: Exception do: [:exc | caughtExceptions add: exc]].
	caughtExceptions do: [:exc | exc resignalAs: exc class new]"
]
