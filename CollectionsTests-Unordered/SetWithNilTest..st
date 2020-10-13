Class {
	#name : #SetWithNilTest,
	#superclass : #TestCase,
	#category : #'CollectionsTests-Unordered'
}

{ #category : #tests }
SetWithNilTest >> runSetWithNilTestOf: newSet [
	"Run the common tests for the given set class"
	
	| class collectClass |
	class := newSet value class.
	collectClass := class == WeakSet 
		ifTrue: [ WeakSet ]
		ifFalse: [ Set ].
	self assert: (newSet value add: nil; yourself) size = 1.
	self assert: (newSet value addAll: #(nil nil nil); yourself) size = 1.

	self assert: ((newSet value add: nil; yourself) includes: nil).
	self assert: ((newSet value addAll: #(nil nil nil); yourself) includes: nil).

	self assert: (newSet value add: nil; yourself) anyOne = nil.
	self assert: ((newSet value add: nil; yourself) remove: nil) == nil.
	self assert: ((newSet value add: nil; yourself) remove: nil; yourself) isEmpty.

	self assert: (newSet value addAll: #(1 nil foo); yourself) size = 3.
	self assert: ((newSet value addAll: #(1 nil foo); yourself) remove: nil; yourself) size = 2.

	self assert: ((newSet value add: nil; yourself) collect:[:x| x]) = (collectClass with: nil).
	self assert: ((newSet value add: nil; yourself) collect:[:x| x] as: Array) = #(nil).

	self deny: ((newSet value) includes: nil).
	self deny: ((newSet value add: 3; yourself) includes: nil).
	self deny: ((newSet value add: 3; remove: 3; yourself) includes: nil).

]

{ #category : #tests }
SetWithNilTest >> testIdentitySetWithNil [
	self runSetWithNilTestOf: [IdentitySet new]
]

{ #category : #tests }
SetWithNilTest >> testKeyedIdentitySetWithNil [
	| set |
	self runSetWithNilTestOf: [KeyedIdentitySet keyBlock:[:o| o]].
	set := KeyedIdentitySet keyBlock:[:o| o].
	set add: nil.
	self assert: (set at: nil) == nil.

]

{ #category : #tests }
SetWithNilTest >> testKeyedSetWithNil [
	| set |
	self runSetWithNilTestOf: [KeyedSet keyBlock:[:o| o]].
	set := KeyedSet keyBlock:[:o| o].
	set add: nil.
	self assert: (set at: nil) == nil.
	self assert: (set includes: nil)

]

{ #category : #tests }
SetWithNilTest >> testPluggableSetWithNil [
	self runSetWithNilTestOf: [PluggableSet new]
]

{ #category : #tests }
SetWithNilTest >> testSetWithNil [
	self runSetWithNilTestOf: [Set new]
]

{ #category : #tests }
SetWithNilTest >> testWeakSetWithNil [
	| set |
	self runSetWithNilTestOf: [WeakSet new].
	"Ensure that GCed entries don't count"
	set := WeakSet with: Object new.
	Smalltalk garbageCollect.
	set do:[:x| self assert: false]. 	"test for de facto emptyness"
	self deny: (set includes: nil).
	set add: nil.
	self assert: (set includes: nil).
	set remove: nil.
	self deny: (set includes: nil).
]
