Class {
	#name : #AllocationTest,
	#superclass : #TestCase,
	#category : #'KernelTests-Objects'
}

{ #category : #support }
AllocationTest >> setFreeSpaceLimitOf: bytes around: aBlock [
	"Attempt to evaluate aBlock with a limit of the requested ammount
	 of free old space, restoring the extant limit after the evaluation."

	| extantLimit |
	extantLimit := Smalltalk vmParameterAt: 67.
	Smalltalk vmParameterAt: 67 put: (Smalltalk vmParameterAt: 1) + bytes asInteger.
	^aBlock ensure: [Smalltalk vmParameterAt: 67 put: extantLimit]
]

{ #category : #tests }
AllocationTest >> testOneGigAllocation [
	"Documentating a weird bug in the allocator"
	| sz array failed |
	failed := false.
	sz := 1024*1024*1024.
	array := [Array new: sz] on: OutOfMemory do:[:ex| failed := true].
	self assert: (failed or:[array size = sz]).
	
]

{ #category : #tests }
AllocationTest >> testOneMegAllocation [
	"Documentating a weird bug in the allocator"
	| sz array failed |
	failed := false.
	sz := 1024*1024.
	array := [Array new: sz] on: OutOfMemory do:[:ex| failed := true].
	self assert: (failed or:[array size = sz]).
	
]

{ #category : #tests }
AllocationTest >> testOutOfMemorySignal [
	"Ensure that OutOfMemory is signaled eventually. Restrain the available memory first to not stress the machine too much."
	
	| sz |
	self setFreeSpaceLimitOf: 1024 * 1024 * 1024 * (Smalltalk wordSize = 8
														ifTrue: [4]
														ifFalse: [1.5])
		around:
			[sz := 512*1024*1024. "work around the 1GB alloc bug"
			 self should: [(1 to: 2000) collect: [:i| Array new: sz]] raise: OutOfMemory].
]

{ #category : #tests }
AllocationTest >> testOutOfMemorySignalExtreme [
	"Try to allocate a ridiculous amount of memory and check whether the expected error is signaled. Call Eliot when this test fails, he want your machine. :-)
	
	Note that current (2017) Spur VMs fail in #new: and #basicNew: with #'bad argument' if given other than a non-negative SmallInteger.
	
	Also note that this test can be quite stressful to your machine depending on how your operating system allocates the required memory behind the curtains. Better not triggering some robot fetching a tape from somewhere..."
	
	| sz |
	sz := 1024*1024*1024*1024. "= 1 TiB"
	self should: [Array new: sz]
		raise: OutOfMemory, Error
		withExceptionDo:
			[:ex|
			 ex class == Error ifTrue:
				[self assert: [ex messageText includesSubstring: 'basicNew: with invalid argument']]]
]
