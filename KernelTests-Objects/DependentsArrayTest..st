"
This class is to test the special implementation of DependentsArray.

DependentsArray size will not count nil elements (the ones reclaimed by garbage collector).
Consequently, any message implemented with a construction like (1 to: self size do: [:i | ]) and sent to the dependents of any object might not behave as supposed to.
"
Class {
	#name : #DependentsArrayTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Objects'
}

{ #category : #tests }
DependentsArrayTest >> testAddingTwice [
	
	| test dep2 deps |
	test := Object new.
	dep2 := String with: $z with: $u with: $t.
	
	test addDependent: String new.
	test addDependent: dep2.
	
	Smalltalk garbageCollect. "this will make first dependent vanish, replaced by nil"
	
	test addDependent: dep2.
	
	deps := test dependents.
	self should: [deps asIdentitySet size = deps size] description: 'No object should be added twice in dependents'
]

{ #category : #tests }
DependentsArrayTest >> testCanDiscardEdits [
	"self debug: #testCanDiscardEdits."

	| anObject aView  |
	anObject := Object new.
	"A Project may always discard edits."
	aView := Project new.
	anObject addDependent: Object new. "this entry should be garbage collected"
	anObject addDependent: aView.

	Smalltalk garbageCollect. "force garbage collection"

	self
		should: [anObject dependents size = 1]
		description: 'first dependent of anObject should have been collected, second should not'.

	self
		shouldnt: [anObject canDiscardEdits]
		description: 'anObject cannot discard edits because aView is a dependent of anObject and aView has unaccepted edits'.
]

{ #category : #tests }
DependentsArrayTest >> testSize [

	self 
		assert: (DependentsArray with: nil) size = 0;
		assert: (DependentsArray with: nil with: 1 with: nil) size = 1;
		assert: (DependentsArray with: 1 with: 3) size = 2;
		assert: (DependentsArray with: nil with: nil with: nil) size = 0
]
