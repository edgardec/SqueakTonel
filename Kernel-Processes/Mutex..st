"
A Mutex is a light-weight MUTual EXclusion object being used when two or more processes need to access a shared resource concurrently. A Mutex grants ownership to a single process and will suspend any other process trying to aquire the mutex while in use. Waiting processes are granted access to the mutex in the order the access was requested.

A Mutex allows the owning process to reenter as many times as desired.  For example a Mutex will not block when trying the following:
	| m |
	m := Mutex new.
	m critical: [m critical: [#yes]]
whereas a Semaphore will deadlock:
	| s |
	s := Semaphore forMutualExclusion.
	s critical: [s critical: [#no]]

Instance variables:
	owner		<Process|UndefinedObject>		The process owning the mutex
"
Class {
	#name : #Mutex,
	#superclass : #LinkedList,
	#instVars : [
		'owner'
	],
	#category : #'Kernel-Processes'
}

{ #category : #'mutual exclusion' }
Mutex >> critical: aBlock [
	"Evaluate aBlock protected by the receiver."
	<criticalSection>
	^self primitiveEnterCriticalSection
		ifTrue: [aBlock value]
		ifFalse: [aBlock ensure: [self primitiveExitCriticalSection]]
]

{ #category : #'mutual exclusion' }
Mutex >> critical: aBlock ifLocked: lockedBlock [
	"Answer the evaluation of aBlock protected by the receiver.  If it is already in a critical
	 section on behalf of some other process answer the evaluation of lockedBlock."
	<criticalSection>
	^self primitiveTestAndSetOwnershipOfCriticalSection
		ifNil: [lockedBlock value]
		ifNotNil:
			[:alreadyOwner|
			 alreadyOwner
				ifTrue: [aBlock value]
				ifFalse: [aBlock ensure: [self primitiveExitCriticalSection]]]
]

{ #category : #testing }
Mutex >> isOwned [
	"Answer if the receiver is owned.  DO NOT USE THIS IN NORMAL CODE.
	 This exists for the MutexTests so they don't have to use e.g. instVarNamed:.
	 N.B. don't use notNil because that is a real send and preemptable."
	^nil ~~ owner
]

{ #category : #'private-primitives' }
Mutex >> primitiveEnterCriticalSection [
	"Primitive. The receiver must be unowned or owned by the current process to proceed.
	 Answer if the process is owned by the current process.

	 Copyright (c) 2016 - 3D Immersive Collaboration Consulting, LLC."
	<primitive: 186>
	self primitiveFailed
	"In the spirit of the following"
	"[owner ifNil:
		[owner := Processor activeProcess.
		 ^false].
	  owner = Processor activeProcess ifTrue:
		[^true].
	  self addLast: Processor activeProcess.
	  Processor activeProcess suspend] valueUnpreemptively"
]

{ #category : #'system simulation' }
Mutex >> primitiveEnterCriticalSectionOnBehalfOf: effectiveProcess [
	"Primitive. Simulate primitiveEnterCriticalSection.  The receiver
	 must be unowned or owned by the effectiveProcess to proceed.
	 Answer if the process is already owned by the current process."
	<primitive: 186>
	^Context primitiveFailTokenFor: nil
]

{ #category : #'private-primitives' }
Mutex >> primitiveExitCriticalSection [
	"Primitive. Set the receiver to unowned and if any processes are waiting on
	 the receiver then proceed the first one, indicating that the receiver is unowned.

	 Copyright (c) 2016 - 3D Immersive Collaboration Consulting, LLC."
	<primitive: 185>
	self primitiveFailed
	"In the spirit of the following"
	"[owner := nil.
	  self isEmpty ifFalse:
		[process := self removeFirst.
		 process resume]] valueUnpreemptively"
]

{ #category : #'private-primitives' }
Mutex >> primitiveTestAndSetOwnershipOfCriticalSection [
	"Primitive. Attempt to set the ownership of the receiver.
	 If the receiver is unowned set its owningProcess to the
	 activeProcess and answer false.  If the receiver is owned
	 by the activeProcess answer true.  If the receiver is owned
	 by some other process answer nil.

	 Copyright (c) 2016 - 3D Immersive Collaboration Consulting, LLC."
	<primitive: 187>
	self primitiveFailed
	"In the spirit of the following"
	"[owner ifNil:
		[owningProcess := Processor activeProcess.
		 ^false].
	  owner = Processor activeProcess ifTrue: [^true].
	  ^nil] valueUnpreemptively"
]

{ #category : #'system simulation' }
Mutex >> primitiveTestAndSetOwnershipOfCriticalSectionOnBehalfOf: effectiveProcess [
	"Primitive. Simulate primitiveEnterCriticalSection.  Attempt to set the ownership
	 of the receiver.  If the receiver is unowned set its owningProcess to the
	 effectiveProcess and answer false.  If the receiver is owned by the effectiveProcess
	 answer true.  If the receiver is owned by some other process answer nil."
	<primitive: 187>
	^Context primitiveFailTokenFor: nil
]
