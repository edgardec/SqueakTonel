"
ProtoObject establishes minimal behavior required of any object in Squeak, even objects that should balk at normal object behavior. Generally these are proxy objects designed to read themselves in from the disk, or to perform some wrapper behavior, before responding to a message. Current examples are ObjectOut and ImageSegmentRootStub, and one could argue that ObjectTracer should also inherit from this class.

ProtoObject has no instance variables, nor should any be added.
"
Class {
	#name : #ProtoObject,
	#superclass : #nil,
	#category : #'Kernel-Objects'
}

{ #category : #'as yet unclassified' }
ProtoObject class >> initializedInstance [
	^ nil
]

{ #category : #comparing }
ProtoObject >> == anObject [ 
	"Primitive. Answer whether the receiver and the argument are the same 
	object (have the same object pointer). Do not redefine the message == in 
	any other class! Essential. No Lookup. Do not override in any subclass. 
	See Object documentation whatIsAPrimitive."

	<primitive: 110>
	self primitiveFailed
]

{ #category : #'system primitives' }
ProtoObject >> cannotInterpret: aMessage [ 
	 "Handle the fact that there was an attempt to send the given message to the receiver but a null methodDictionary was encountered while looking up the message selector.  Hopefully this is the result of encountering a stub for a swapped out class which induces this exception on purpose."

"If this is the result of encountering a swap-out stub, then simulating the lookup in Smalltalk should suffice to install the class properly, and the message may be resent."

	(self class lookupSelector: aMessage selector) == nil ifFalse:
		["Simulated lookup succeeded -- resend the message."
		^ aMessage sentTo: self].

	"Could not recover by simulated lookup -- it's an error"
	Error signal: 'MethodDictionary fault'.

	"Try again in case an error handler fixed things"
	^ aMessage sentTo: self
]

{ #category : #debugging }
ProtoObject >> doOnlyOnce: aBlock [
	"If the 'one-shot' mechanism is armed, evaluate aBlock once and disarm the one-shot mechanism.  To rearm the mechanism, evaluate  'self rearmOneShot' manually."

	(Smalltalk at: #OneShotArmed ifAbsent: [true])
		ifTrue:
			[Smalltalk at: #OneShotArmed put: false.
			aBlock value]
]

{ #category : #'system primitives' }
ProtoObject >> doesNotUnderstand: aMessage [

	^ MessageNotUnderstood new 
		message: aMessage;
		receiver: self;
		signal
]

{ #category : #debugging }
ProtoObject >> flag: aSymbol [
	"Send this message, with a relevant symbol as argument, to flag a message for subsequent retrieval.  For example, you might put the following line in a number of messages:
	self flag: #returnHereUrgently
	Then, to retrieve all such messages, browse all senders of #returnHereUrgently."
]

{ #category : #comparing }
ProtoObject >> identityHash [
	"Answer a SmallInteger whose value is related to the receiver's identity.
	This method must not be overridden, except by immediate values.
	Primitive. Fails if the receiver is immediate. Essential.
	See Object documentation whatIsAPrimitive.

	Do not override."

	<primitive: 75>
	self primitiveFailed
]

{ #category : #testing }
ProtoObject >> ifNil: nilBlock [
	"Return self, or evaluate the block if I'm == nil (q.v.)"

	^ self
]

{ #category : #testing }
ProtoObject >> ifNil: nilBlock ifNotNil: ifNotNilBlock [
	"Evaluate the block, unless I'm == nil (q.v.)"

	^ ifNotNilBlock cull: self
]

{ #category : #testing }
ProtoObject >> ifNotNil: ifNotNilBlock [
	"Evaluate the block, unless I'm == nil (q.v.)"

	^ ifNotNilBlock cull: self
]

{ #category : #testing }
ProtoObject >> ifNotNil: ifNotNilBlock ifNil: nilBlock [ 
	"If I got here, I am not nil, so evaluate the block ifNotNilBlock"

	^ ifNotNilBlock cull: self
]

{ #category : #'initialize-release' }
ProtoObject >> initialize [
	"Subclasses should redefine this method to perform initializations on instance creation"
]

{ #category : #'system primitives' }
ProtoObject >> instVarsInclude: anObject [
"Answers true if anObject is among my named or indexed instance variables, and false otherwise"

	<primitive: 132>
	1 to: self class instSize do:
		[:i | (self instVarAt: i) == anObject ifTrue: [^ true]].
	1 to: self basicSize do:
		[:i | (self basicAt: i) == anObject ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
ProtoObject >> isInMemory [
	"All normal objects are."
	^ true
]

{ #category : #testing }
ProtoObject >> isNil [
	"Coerces nil to true and everything else to false."

	^false
]

{ #category : #'system primitives' }
ProtoObject >> nextInstance [
	"Primitive. Answer the next instance after the receiver in the 
	enumeration of all instances of this class. Fails if all instances have been 
	enumerated. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 78>
	^nil
]

{ #category : #'system primitives' }
ProtoObject >> nextObject [
	"Primitive. Answer the next object after the receiver in the 
	enumeration of all objects. Return 0 when all objects have been 
	enumerated."

	<primitive: 139>
	self primitiveFailed.
]

{ #category : #testing }
ProtoObject >> notNil [
	"Coerces nil to false and everything else to true."

	^true
]

{ #category : #tracing }
ProtoObject >> pointsOnlyWeaklyTo: anObject [
	"Assume, we already know that receiver points to an object, answer true if receiver points only weakly to it."
	
	self class isWeak ifFalse: [ ^false ].
	1 to: self class instSize do: [ :i |
		(self instVarAt: i) == anObject ifTrue: [ ^false ] ].
	^true
]

{ #category : #tracing }
ProtoObject >> pointsTo: anObject [
"Answers true if I hold a reference to anObject, or false otherwise. Or stated another way:

Answers true if the garbage collector would fail to collect anObject because I hold a reference to it, or false otherwise"

	^ (self instVarsInclude: anObject)
		or: [self class == anObject]
]

{ #category : #debugging }
ProtoObject >> rearmOneShot [
	"Call this manually to arm the one-shot mechanism; use the mechanism in code by calling
		self doOnlyOnce: <a block>"

	Smalltalk at: #OneShotArmed put: true

	"self rearmOneShot"

]

{ #category : #'objects from disk' }
ProtoObject >> rehash [
	"Do nothing.  Here so sending this to a Set does not have to do a time consuming respondsTo:"
]

{ #category : #comparing }
ProtoObject >> scaledIdentityHash [
	"For identityHash values returned by primitive 75, answer
	 such values times 2^8.  Otherwise, match the existing
	 identityHash implementation"

	^self identityHash * 256 "bitShift: 8"
]

{ #category : #'apply primitives' }
ProtoObject >> tryPrimitive: primIndex withArgs: argumentArray [
	"Invoke the primitive with number primIndex, answering its result,
	 or, if the primiitve fails, the error code."

	<primitive: 118 error: errorCode>
	^Context primitiveFailTokenFor: errorCode
]

{ #category : #debugging }
ProtoObject >> withArgs: argArray executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver and args in argArray"

	<primitive: 188>
	self primitiveFailed
]

{ #category : #comparing }
ProtoObject >> ~~ anObject [
	"Answer whether the receiver and the argument are not the same object 
	(do not have the same object pointer).  Primitive.  Optional."
	<primitive: 169>
	self == anObject ifTrue: [^false].
	^true
]
