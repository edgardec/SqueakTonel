"
I am a registry for objects needing finalization. When an object is added the object as well as its executor is stored. When the object is garbage collected, the executor can take the appropriate action for any resources associated with the object.

This kind of WeakRegistry is using a new VM feature, which allows a more robust finalization support. In contrast to the old implementation, it doesn't spend linear time checking which elements became garbage.

See also:
	Object executor
	Object actAsExecutor
	Object finalize
"
Class {
	#name : #WeakRegistry,
	#superclass : #Collection,
	#instVars : [
		'list',
		'valueDictionary',
		'sema',
		'executors'
	],
	#classVars : [
		'Default'
	],
	#category : #'System-Finalization'
}

{ #category : #accessing }
WeakRegistry class >> default [
	^Default ifNil:[Default := self new]
]

{ #category : #'instance creation' }
WeakRegistry class >> new [
	| registry |
	registry := super new.
	WeakArray addWeakDependent: registry.
	^registry

]

{ #category : #'instance creation' }
WeakRegistry class >> new: n [
	^ self new
]

{ #category : #recompilation }
WeakRegistry class >> postRecompileAction [
	"Reinitialize the finalizers in WeakRegistries to ensure the blocks don;t reference stale methods."

	self allSubInstancesDo:
		[:weakRegistry| weakRegistry installFinalizer]
]

{ #category : #adding }
WeakRegistry >> add: anObject [
	"Add anObject to the receiver. Store the object as well as the associated executor."
	
	^self add: anObject executor: anObject executor
]

{ #category : #adding }
WeakRegistry >> add: anObject executor: anExecutor [

	self protected: [ | finItem |
		finItem := valueDictionary at: anObject ifAbsentPut: [
			WeakFinalizerItem new list: list object: anObject ].
		finItem add: anExecutor ].
	^ anObject

]

{ #category : #enumerating }
WeakRegistry >> do: aBlock [
	^self protected: [
		valueDictionary keysDo: aBlock.
	].

]

{ #category : #'*System-Finalization' }
WeakRegistry >> finalizeValues [
	"Finalize any values, which happen to stocked in our list, due to some weak references become garbage"

	| finalizer |
	self protected:
		[valueDictionary finalizeValues.
		 finalizer := executors.
		 executors := nil ].
	finalizer ifNotNil: [finalizer do: [ :each | each finalizeValues]]
]

{ #category : #'initialize-release' }
WeakRegistry >> initialize [
	valueDictionary := WeakIdentityKeyDictionary new.
	list := WeakFinalizationList new.
	sema := Semaphore forMutualExclusion.
	self installFinalizer.
]

{ #category : #'initialize-release' }
WeakRegistry >> installFinalizer [

	valueDictionary finalizer:
		[:executor|
		 (executors ifNil: [executors := OrderedCollection new]) add: executor]
]

{ #category : #accessing }
WeakRegistry >> keys [

	^self protected: [ valueDictionary keys ]

]

{ #category : #copying }
WeakRegistry >> postCopy [
	"should we prohibit any attempts to copy receiver?"
	self protected: [ | oldDict |
		sema := Semaphore forMutualExclusion.
		oldDict := valueDictionary.
		list := WeakFinalizationList new.
		valueDictionary := WeakIdentityKeyDictionary new.
		self installFinalizer.
	
		oldDict keysAndValuesDo: [:key :value |
			valueDictionary at: key put: (value copyWithList: list)
		].
	]
]

{ #category : #printing }
WeakRegistry >> printElementsOn: aStream [
	sema ifNil: [^super printElementsOn: aStream].
	aStream nextPutAll: '(<this WeakRegistry is locked>)'
]

{ #category : #private }
WeakRegistry >> protected: aBlock [
	"Execute aBlock protected by the accessLock"

	^ sema
		critical: aBlock
		ifError: [ :msg :rcvr |
		rcvr error: msg ] 
]

{ #category : #printing }
WeakRegistry >> remove: oldObject ifAbsent: exceptionBlock [
	"Remove oldObject as one of the receiver's elements."
	
	oldObject ifNil: [ ^nil ].
	^(self protected: [ valueDictionary removeKey: oldObject ifAbsent: nil ])
		ifNil: [ exceptionBlock value ]
]

{ #category : #printing }
WeakRegistry >> removeAll [
	"See super"
	
	self protected:[
		valueDictionary removeAll.
	].
]

{ #category : #accessing }
WeakRegistry >> size [
	^ self protected: [valueDictionary slowSize]
]

{ #category : #private }
WeakRegistry >> species [
	^Set
]
