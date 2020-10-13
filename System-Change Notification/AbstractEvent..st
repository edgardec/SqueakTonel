"
An AbstractEvent is used by the system change notification framework to indicate that something happened with code - a class was recategorised, a method was added, and so on.

My environment instance variable is a Dictionary containing all the relevant information for an event - selector, class, and so on. It is not an Environment instance!
"
Class {
	#name : #AbstractEvent,
	#superclass : #Object,
	#instVars : [
		'item',
		'itemKind',
		'environment'
	],
	#category : #'System-Change Notification'
}

{ #category : #accessing }
AbstractEvent class >> allChangeKinds [
	"AbstractEvent allChangeKinds"

	^AbstractEvent allSubclasses collect: [:cl | cl changeKind]
]

{ #category : #accessing }
AbstractEvent class >> allItemKinds [
	"self allItemKinds"

	^(AbstractEvent class organization listAtCategoryNamed: #'item kinds') 
		collect: [:sel | self perform: sel]
]

{ #category : #'item kinds' }
AbstractEvent class >> categoryKind [
	"Also known as 'class categories'."
	
	^#category
]

{ #category : #accessing }
AbstractEvent class >> changeKind [
	"Return a symbol, with a : as last character, identifying the change kind."

	self subclassResponsibility
]

{ #category : #'instance creation - specific' }
AbstractEvent class >> class: aClass [
	^ self item: aClass kind: AbstractEvent classKind.
]

{ #category : #'instance creation - specific' }
AbstractEvent class >> class: aClass category: cat [ 
	| instance |
	instance := self class: aClass.
	instance itemCategory: cat.
	^instance
]

{ #category : #'instance creation - specific' }
AbstractEvent class >> classCategory: aName [
	^ self item: aName kind: AbstractEvent categoryKind.
]

{ #category : #'item kinds' }
AbstractEvent class >> classKind [

	^#class
]

{ #category : #'item kinds' }
AbstractEvent class >> environmentKind [

	^#environment
]

{ #category : #accessing }
AbstractEvent class >> eventSelectorBlock [

	^[:itemKind :changeKind | itemKind, changeKind, 'Event:']
]

{ #category : #'item kinds' }
AbstractEvent class >> expressionKind [

	^#expression
]

{ #category : #'instance creation' }
AbstractEvent class >> item: anItem kind: anItemKind [

	^self basicNew item: anItem kind: anItemKind
]

{ #category : #accessing }
AbstractEvent class >> itemChangeCombinations [

	^self supportedKinds collect: [:itemKind | self eventSelectorBlock value: itemKind value: self changeKind]
]

{ #category : #'instance creation - specific' }
AbstractEvent class >> method: aMethod class: aClass [

	| instance |
	instance := self item: aMethod kind: self methodKind.
	instance itemClass: aClass.
	^instance
]

{ #category : #'instance creation - specific' }
AbstractEvent class >> method: aMethod protocol: prot class: aClass [

	| instance |
	instance := self method: aMethod class: aClass.
	instance itemProtocol: prot.
	^instance
]

{ #category : #'instance creation - specific' }
AbstractEvent class >> method: aMethod selector: aSymbol class: aClass [

	| instance |
	instance := self item: aMethod kind: self methodKind.
	instance itemSelector: aSymbol.
	instance itemClass: aClass.
	^instance
]

{ #category : #'instance creation - specific' }
AbstractEvent class >> method: aMethod selector: aSymbol class: aClass requestor: requestor [

	| instance |
	instance := self method: aMethod selector: aSymbol class: aClass.
	instance itemRequestor: requestor.
	^instance
]

{ #category : #'instance creation - specific' }
AbstractEvent class >> method: aMethod selector: aSymbol protocol: prot class: aClass [

	| instance |
	instance := self method: aMethod selector: aSymbol class: aClass.
	instance itemProtocol: prot.
	^instance
]

{ #category : #'instance creation - specific' }
AbstractEvent class >> method: aMethod selector: aSymbol protocol: prot class: aClass requestor: requestor [

	| instance |
	instance := self method: aMethod selector: aSymbol protocol: prot class: aClass.
	instance itemRequestor: requestor.
	^instance
]

{ #category : #'item kinds' }
AbstractEvent class >> methodKind [

	^#method
]

{ #category : #'instance creation' }
AbstractEvent class >> new [
	"Override new to trigger an error, since we want to use specialized methods to create basic and higher-level events."

	^self error: 'Instances can only be created using specialized instance creation methods.'
]

{ #category : #'instance creation - specific' }
AbstractEvent class >> protocol: aProtocol class: aClass [

	| instance |
	instance := self item: aProtocol kind: self protocolKind.
	instance itemClass: aClass.
	^instance
]

{ #category : #'item kinds' }
AbstractEvent class >> protocolKind [
	"Also known as 'message categories'."
	
	^#protocol
]

{ #category : #accessing }
AbstractEvent class >> supportedKinds [
	"All the kinds of items that this event can take. By default this is all the kinds in the system. But subclasses can override this to limit the choices. For example, the SuperChangedEvent only works with classes, and not with methods, instance variables, ..."

	^self allItemKinds
]

{ #category : #accessing }
AbstractEvent class >> systemEvents [
	"Return all the possible events in the system. Make a cross product of 
	the items and the change types."
	"self systemEvents"

	^self allSubclasses
		inject: OrderedCollection new
		into: [:allEvents :eventClass | allEvents addAll: eventClass itemChangeCombinations; yourself]
]

{ #category : #'private-accessing' }
AbstractEvent >> changeKind [

	^self class changeKind
]

{ #category : #'private-accessing' }
AbstractEvent >> environmentAt: anItemKind [

	^ self environmentAt: anItemKind ifAbsent: [nil]
]

{ #category : #'private-accessing' }
AbstractEvent >> environmentAt: anItemKind ifAbsent: aBlock [

	^ self itemKind = anItemKind
		ifTrue: [self item]
		ifFalse: [environment at: anItemKind ifAbsent: aBlock]
]

{ #category : #'private-accessing' }
AbstractEvent >> environmentAt: anItemKind put: anItem [

	self itemKind = anItemKind
		ifTrue: [item := anItem]
		ifFalse: [environment at: anItemKind put: anItem].
]

{ #category : #'private-accessing' }
AbstractEvent >> eventSelector [

	^self class eventSelectorBlock
		value: self itemKind
		value: self changeKind
]

{ #category : #testing }
AbstractEvent >> isAdded [

	^false
]

{ #category : #testing }
AbstractEvent >> isCategoryKnown [

	^self itemCategory notNil
]

{ #category : #testing }
AbstractEvent >> isCommented [

	^false
]

{ #category : #testing }
AbstractEvent >> isDoIt [

	^false
]

{ #category : #testing }
AbstractEvent >> isModified [

	^false
]

{ #category : #testing }
AbstractEvent >> isProtocolKnown [

	^self itemCategory notNil
]

{ #category : #testing }
AbstractEvent >> isRecategorized [

	^false
]

{ #category : #testing }
AbstractEvent >> isRemoved [

	^false
]

{ #category : #testing }
AbstractEvent >> isRenamed [

	^false
]

{ #category : #testing }
AbstractEvent >> isReorganized [
	^ false
]

{ #category : #accessing }
AbstractEvent >> item [
	"Return the item that triggered the event (typically the name of a class, a category, a protocol, a method)."

	^item
]

{ #category : #initialization }
AbstractEvent >> item: anItem kind: anItemKind [

	item := anItem.
	itemKind := anItemKind.
	environment := Dictionary new
]

{ #category : #'accessing - specific' }
AbstractEvent >> itemCategory [

	^ self environmentAt: self class categoryKind
]

{ #category : #'private-accessing' }
AbstractEvent >> itemCategory: aCategory [

	self environmentAt: self class categoryKind put: aCategory.
]

{ #category : #'accessing - specific' }
AbstractEvent >> itemClass [

	^ self environmentAt: self class classKind
]

{ #category : #'private-accessing' }
AbstractEvent >> itemClass: aClass [

	self environmentAt: self class classKind put: aClass.
]

{ #category : #'accessing - specific' }
AbstractEvent >> itemEnvironment [
	
	^ self
		environmentAt: self class environmentKind
		ifAbsent: [Smalltalk globals]
]

{ #category : #'private-accessing' }
AbstractEvent >> itemEnvironment: anEnvironment [
	
	self environmentAt: self class environmentKind put: anEnvironment.
]

{ #category : #'accessing - specific' }
AbstractEvent >> itemExpression [

	^ self environmentAt: self class expressionKind
]

{ #category : #'private-accessing' }
AbstractEvent >> itemExpression: anExpression [

	self environmentAt: self class expressionKind put: anExpression.
]

{ #category : #accessing }
AbstractEvent >> itemKind [
	"Return the kind of the item of the event (#category, #class, #protocol, #method, ...)"

	^itemKind
]

{ #category : #'accessing - specific' }
AbstractEvent >> itemMethod [

	^ self environmentAt: self class methodKind
]

{ #category : #'private-accessing' }
AbstractEvent >> itemMethod: aMethod [

	self environmentAt: self class methodKind put: aMethod.
]

{ #category : #'accessing - specific' }
AbstractEvent >> itemProtocol [

	^ self environmentAt: self class protocolKind
]

{ #category : #'private-accessing' }
AbstractEvent >> itemProtocol: aProtocol [

	self environmentAt: self class protocolKind put: aProtocol.
]

{ #category : #'accessing - specific' }
AbstractEvent >> itemRequestor [

	^ self environmentAt: #requestor
]

{ #category : #'private-accessing' }
AbstractEvent >> itemRequestor: anObject [

	self environmentAt: #requestor put: anObject.
]

{ #category : #'accessing - specific' }
AbstractEvent >> itemSelector [

	^ self environmentAt: #selector
]

{ #category : #'private-accessing' }
AbstractEvent >> itemSelector: aSymbol [

	self environmentAt: #selector put: aSymbol.
]

{ #category : #printing }
AbstractEvent >> printOn: aStream [

	self printEventKindOn: aStream.
	aStream
		nextPutAll: ' Event for item: ';
		print: self item;
		nextPutAll: ' of kind: ';
		print: self itemKind
]

{ #category : #triggering }
AbstractEvent >> trigger: anEventManager [ 
	"Trigger the event manager."

	anEventManager triggerEvent: self eventSelector with: self.
]
