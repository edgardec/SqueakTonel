"
WeakArray is an array which holds only weakly on its elements. This means whenever an object is only referenced by instances of WeakArray it will be garbage collected.
"
Class {
	#name : #WeakArray,
	#superclass : #Array,
	#type : #weak,
	#classVars : [
		'FinalizationDependents',
		'FinalizationLock',
		'FinalizationProcess',
		'FinalizationSemaphore'
	],
	#category : #'Collections-Weak'
}

{ #category : #accessing }
WeakArray class >> addWeakDependent: anObject [

	FinalizationLock
		critical: [
			| emptySlotIndex |
			emptySlotIndex := FinalizationDependents 
				identityIndexOf: nil
				ifAbsent: [ 
					| newIndex |
					newIndex := FinalizationDependents size + 1.
					"Grow linearly"
					FinalizationDependents := FinalizationDependents grownBy: 10.
					newIndex ].
			FinalizationDependents at: emptySlotIndex put: anObject ]
		ifError: [ :msg :rcvr | rcvr error: msg ]
]

{ #category : #'class initialization' }
WeakArray class >> initialize [
	"WeakArray initialize"

	"Do we need to initialize specialObjectsArray?"
	Smalltalk specialObjectsArray size < 42 
		ifTrue:[Smalltalk recreateSpecialObjectsArray].

	Smalltalk addToStartUpList: self.
	self restartFinalizationProcess.
]

{ #category : #accessing }
WeakArray class >> isFinalizationSupported [
	"This method is only here for backwards compatibility, all closure VMs support finalization"
	
	^true
]

{ #category : #private }
WeakArray class >> primitiveFetchMourner [
	"Answer the next mourner in the VM's queue of objects to be finalized.
	 The queue contains weak arrays and ephemerons.  If the primitive is
	 not implemented, raise an error telling people to upgrade the VM.  If
	 implemented, the primitive fails if the queue is empty, with the error
	 code #'not found'. Primitive.  Essential."

	<primitive: 172 error: ec>
	ec ifNil: [^self error: 'The primitiveFetchMourner primitive is missing.\Please upgrade your virtual machine to one that has the primitive.' withCRs].
	^nil
]

{ #category : #accessing }
WeakArray class >> removeWeakDependent: anObject [

	FinalizationLock critical:[
		1 to: FinalizationDependents size do:[:i|
			((FinalizationDependents at: i) == anObject) ifTrue:[
				FinalizationDependents at: i put: nil.
			].
		].
	] ifError:[:msg :rcvr| rcvr error: msg].
]

{ #category : #private }
WeakArray class >> restartFinalizationProcess [
	"kill any old process, just in case"
	FinalizationProcess ifNotNil:
		[FinalizationProcess terminate.
		 FinalizationProcess := nil].

	FinalizationSemaphore := Smalltalk specialObjectsArray at: 42.
	FinalizationDependents ifNil: [FinalizationDependents := WeakArray new: 10].
	FinalizationLock := Semaphore forMutualExclusion.
	FinalizationProcess := [self finalizationProcess]
								forkAt: Processor userInterruptPriority + 1
								named: 'the finalization process'
]

{ #category : #accessing }
WeakArray class >> runningFinalizationProcess [
	"Answer the FinalizationProcess I am running, if any"
	^FinalizationProcess
]

{ #category : #'system startup' }
WeakArray class >> startUp: resuming [
	resuming ifFalse: [ ^self ].
	self restartFinalizationProcess.
]

{ #category : #copying }
WeakArray >> copyWith: newElement [ 
	"Re-implemented to not return a strong copy."
	^ (super copyWith: newElement) as: self class
]

{ #category : #copying }
WeakArray >> copyWithout: oldElement [ 
	"Re-implemented to not return a strong copy."
	^ (super copyWithout: oldElement) as: self class
]

{ #category : #private }
WeakArray >> species [
	"More useful to have strongly-referenced results of #select: and #collect:."
	^ Array
]
