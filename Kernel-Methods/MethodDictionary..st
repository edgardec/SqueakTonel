"
I am a special dictionary holding methods. I am just like a normal Dictionary, except that I am implemented differently.  Each Class has an instance of MethodDictionary to hold the correspondence between selectors (names of methods) and methods themselves.

In a normal Dictionary, the instance variable 'array' holds an array of Associations.  Since there are thousands of methods in the system, these Associations waste space.  

Each MethodDictionary is a variable object, with the list of keys (selector Symbols) in the variable part of the instance.  The variable 'array' holds the values, which are CompiledMethods.

I also maintain the following invariant: (self basicAt: index) isNil = (array at: index) isNil.
"
Class {
	#name : #MethodDictionary,
	#superclass : #Dictionary,
	#type : #variable,
	#category : #'Kernel-Methods'
}

{ #category : #'initialize-release' }
MethodDictionary class >> compactAllInstances [

	| instancesToExchange newInstances |
	instancesToExchange := Array streamContents: [ :oldStream |
		newInstances := Array streamContents: [ :newStream |
			self allInstances do: [ :each |
				| newInstance |
				newInstance := each compactWithoutBecome.
				newInstance capacity = each capacity 
					ifTrue: [ each copyFrom: newInstance ]
					ifFalse: [
						oldStream nextPut: each.
						newStream nextPut: newInstance ] ] ] ].
	instancesToExchange elementsForwardIdentityTo: newInstances
]

{ #category : #'instance creation' }
MethodDictionary class >> new [
	"Create a new instance with 32 slots, which can hold at most 24 methods before growing is necessary."
	
	^self newForCapacity: 32
]

{ #category : #'instance creation' }
MethodDictionary class >> new: numberOfElements [
	"Create an instance large enough to hold numberOfElements methods without growing."
	
	^self newForCapacity: (self sizeFor: numberOfElements)
]

{ #category : #private }
MethodDictionary class >> newForCapacity: capacity [
	"Create an instance with the given capacity which must be a power of two."
	
	^(self basicNew: capacity) initialize: capacity
]

{ #category : #sizing }
MethodDictionary class >> sizeFor: numberOfElements [
	"Return the minimum capacity of a dictionary that can hold numberOfElements elements. At least 25% of the array must be empty and the return value must be a power of 2."

	^(numberOfElements * 4 // 3 max: 1) asLargerPowerOfTwo
]

{ #category : #accessing }
MethodDictionary >> associationAt: key ifAbsent: aBlock [ 
	"Answer the association with the given key.
	If key is not found, return the result of evaluating aBlock."

	^(array at: (self scanFor: key)) 
		ifNil: [ aBlock value ]
		ifNotNil: [ :value | key -> value ]
]

{ #category : #enumeration }
MethodDictionary >> associationsDo: aBlock [ 
	
	tally = 0 ifTrue: [ ^self ].
	1 to: self basicSize do: [ :i |
		(self basicAt: i) ifNotNil: [ :key |
			aBlock value: (Association key: key value: (array at: i)) ] ]
]

{ #category : #accessing }
MethodDictionary >> at: key ifAbsent: aBlock [

	^(array at: (self scanFor: key)) ifNil: [ aBlock value ]
]

{ #category : #accessing }
MethodDictionary >> at: key ifPresent: oneArgBlock ifAbsent: absentBlock [
	"Lookup the given key in the receiver. If it is present, answer the
	 value of evaluating the oneArgBlock with the value associated
	 with the key, otherwise answer the value of absentBlock."
	^(array at: (self scanFor: key))
		ifNil: [absentBlock value]
		ifNotNil: [:method| oneArgBlock value: method]
]

{ #category : #accessing }
MethodDictionary >> at: key put: value [
	"Set the value at key to be value."
	
	| index |
	index := self scanFor: key.
	(self basicAt: index)
		ifNil: [
			self
				basicAt: index put: key;
				atNewIndex: index put: value ]
		ifNotNil: [ 
			(array at: index) flushCache.
			array at: index put: value ].
	^value
]

{ #category : #private }
MethodDictionary >> compact [
	"Make sure that I have the highest possible load factor (between 37.5% and 75%)."
	
	| newInstance |
	newInstance := self compactWithoutBecome.
	newInstance capacity = self capacity
		ifTrue: [ self copyFrom: newInstance ]
		ifFalse: [ self becomeForward: newInstance ]
]

{ #category : #private }
MethodDictionary >> compactWithoutBecome [
	"Return a copy of self which has the highest possible load factor (between 37.5% and 75%)."
	
	| newInstance |
	newInstance := self species new: self size.
	1 to: self basicSize do: [ :index | 
		(self basicAt: index) ifNotNil: [ :key |
			newInstance at: key put: (array at: index) ] ].
	^newInstance
]

{ #category : #private }
MethodDictionary >> fixCollisionsFrom: start [
	"The element at start has been removed and replaced by nil.
	This method moves forward from there, relocating any entries
	that had been placed below due to collisions with this one."

	| key index |
	index := start.
	[ (key := self basicAt: (index := index \\ array size + 1)) == nil ] whileFalse: [
		| newIndex |
		(newIndex := self scanFor: key) = index ifFalse: [
			self swap: index with: newIndex ] ]
]

{ #category : #private }
MethodDictionary >> grow [

	| newSelf |
	newSelf := self species newForCapacity: self basicSize * 2.
	1 to: self basicSize do: [ :i | 
		(self basicAt: i) ifNotNil: [ :key |
			newSelf at: key put: (array at: i) ] ].
	self becomeForward: newSelf
]

{ #category : #accessing }
MethodDictionary >> keyAtIdentityValue: value ifAbsent: exceptionBlock [
	"Answer the key whose value equals the argument, value. If there is
	none, answer the result of evaluating exceptionBlock."

	value ifNotNil: [
		1 to: self basicSize do: [ :index |
			(array at: index) == value ifTrue: [
				^self basicAt: index ] ] ].
	^exceptionBlock value
]

{ #category : #accessing }
MethodDictionary >> keyAtValue: value ifAbsent: exceptionBlock [
	"Answer the key whose value equals the argument, value. If there is
	none, answer the result of evaluating exceptionBlock."
	
	value ifNotNil: [
		1 to: self basicSize do: [ :index |
			(array at: index) = value ifTrue: [
				^self basicAt: index ] ] ].
	^exceptionBlock value
]

{ #category : #enumeration }
MethodDictionary >> keysAndValuesDo: aBlock [ 
	"Enumerate the receiver with all the keys and values passed to the block"
	
	tally = 0 ifTrue: [^ self].
	1 to: self basicSize do: [ :i |
		(self basicAt: i) ifNotNil: [ :key |
			aBlock value: key value: (array at: i) ] ]
]

{ #category : #enumeration }
MethodDictionary >> keysDo: aBlock [

	tally = 0 ifTrue: [ ^self ].
	1 to: self basicSize do: [ :i |
		(self basicAt: i) ifNotNil: [ :key |
			aBlock value: key ] ]
]

{ #category : #copying }
MethodDictionary >> postCopy [

	array := array copy
]

{ #category : #private }
MethodDictionary >> rehash [ 
	
	| newInstance |
	newInstance := self species newForCapacity: self basicSize.
	1 to: self basicSize do: [ :index | 
		(self basicAt: index) ifNotNil: [ :key |
			newInstance at: key put: (array at: index) ] ].
	self copyFrom: newInstance
]

{ #category : #removing }
MethodDictionary >> removeAll [
	"Remove all elements from this collection. Preserve the capacity"
	
	| newSelf |
	tally = 0 ifTrue: [^self].
	newSelf := self species newForCapacity: self basicSize.
	self copyFrom: newSelf
]

{ #category : #private }
MethodDictionary >> removeDangerouslyKey: key ifAbsent: aBlock [
	"This is not really dangerous.  But if normal removal
	were done WHILE a MethodDict were being used, the
	system might crash.  So instead we make a copy, then do
	this operation (which is NOT dangerous in a copy that is
	not being used), and then use the copy after the removal."

	| index element |
	index := self scanFor: key.
	(element := array at: index) ifNil: [ ^aBlock value ].
	array at: index put: nil.
	self basicAt: index put: nil.
	tally := tally - 1.
	self fixCollisionsFrom: index.
	^element
]

{ #category : #removing }
MethodDictionary >> removeKey: key ifAbsent: errorBlock [ 
	"The interpreter might be using this MethodDict while
	this method is running!  Therefore we perform the removal
	in a copy, and then atomically copy that copy"

	| copy |
	copy := self copy.
	copy removeDangerouslyKey: key ifAbsent: [^ errorBlock value].
	self copyFrom: copy
]

{ #category : #private }
MethodDictionary >> scanFor: anObject [
	"Scan the key array for the first slot containing either a nil (indicating an empty slot) or an element that matches anObject. Answer the index of that slot or raise an error if no slot is found. This method will be overridden in various subclasses that have different interpretations for matching elements."

	| index start size |
	index := start := anObject identityHash \\ (size := array size) + 1.
	[ 
		| element |
		((element := self basicAt: index) == nil or: [ element == anObject ])
			ifTrue: [ ^index ].
		(index := index \\ size + 1) = start ] whileFalse.
	self errorNoFreeSpace
]

{ #category : #private }
MethodDictionary >> swap: oneIndex with: otherIndex [

	| element |
	element := self basicAt: oneIndex.
	self basicAt: oneIndex put: (self basicAt: otherIndex).
	self basicAt: otherIndex put: element.
	array swap: oneIndex with: otherIndex

]

{ #category : #enumeration }
MethodDictionary >> valuesDo: aBlock [ 
	
	tally = 0 ifTrue: [ ^self ].
	1 to: self basicSize do: [ :i | 
		(array at: i) ifNotNil: [ :value |
			aBlock value: value ] ]
]
