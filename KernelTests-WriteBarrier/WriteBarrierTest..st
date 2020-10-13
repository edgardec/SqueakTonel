"
My tests ensure the ReadOnly property of objects work properly.

#testMutateIVObject is a good start to understand what is going on.

The VM needs to be compiled with -DIMMUTABILTY= true for those tests to work.
"
Class {
	#name : #WriteBarrierTest,
	#superclass : #TestCase,
	#classVars : [
		'ContextInstance'
	],
	#category : #'KernelTests-WriteBarrier'
}

{ #category : #initialization }
WriteBarrierTest class >> initialize [
	
	ContextInstance := Context sender: nil receiver: self new method: self >> #alwaysWritableObjects arguments: #()
]

{ #category : #'guinea pigs' }
WriteBarrierTest >> alwaysReadOnlyObjects [
	"Immediates are always immutable"
	^ { 1 }
]

{ #category : #'guinea pigs' }
WriteBarrierTest >> alwaysWritableObjects [
	"Objects that currently can't be immutable"
	^ { ContextInstance . 
		Processor . 
		Processor activeProcess }
]

{ #category : #'expected failures' }
WriteBarrierTest >> expectedFailures [
	Smalltalk supportsReadOnlyObjects ifFalse:
		[^self class testSelectors].
	^#( testMutateByteArrayUsingDoubleAtPut testMutateByteArrayUsingFloatAtPut ),
	  ((Smalltalk classNamed: #MirrorPrimitives)
		ifNil: [#(testBasicProxyReadOnly testBasicProxyWritable testSetIsReadOnlySuccessProxy)]
		ifNotNil: [#()])
]

{ #category : #'guinea pigs' }
WriteBarrierTest >> maybeReadOnlyObjects [
	"ByteObject, Variable object, fixed sized object"
	^ { { 1 . 2 . 3 } asByteArray . { 1 . 2 . 3 } . (MessageSend receiver: 1 selector: #+ argument: 2) }
]

{ #category : #'tests - object' }
WriteBarrierTest >> testAttemptToMutateLiterals [
	| guineaPigs |
	guineaPigs := {#[1 2 3] . #(1 2 3) }.
	guineaPigs do:
		[ :guineaPig | 
		self should: [guineaPig at: 1 put: 4] 
			raise: ModificationForbidden].

	self should: [guineaPigs first become: guineaPigs second ]
		raise: ModificationForbidden.

	self should: [ByteString adoptInstance: guineaPigs first]
		raise: ModificationForbidden.

	self should: [WeakArray adoptInstance: guineaPigs last]
		raise: ModificationForbidden
]

{ #category : #'tests - proxy' }
WriteBarrierTest >> testBasicProxyReadOnly [
	self alwaysReadOnlyObjects do: [ :each |
		self assert: (MirrorPrimitives isObjectReadOnly: each) equals: true ]
]

{ #category : #'tests - proxy' }
WriteBarrierTest >> testBasicProxyWritable [
	self alwaysWritableObjects , self maybeReadOnlyObjects do: [ :each |
		self assert: (MirrorPrimitives isObjectReadOnly: each) equals: false ]
]

{ #category : #'tests - object' }
WriteBarrierTest >> testBasicReadOnly [
	self alwaysReadOnlyObjects do: [ :each |
		self assert: each isReadOnlyObject equals: true ]
]

{ #category : #'tests - object' }
WriteBarrierTest >> testBasicWritable [
	self alwaysWritableObjects , self maybeReadOnlyObjects do: [ :each |
		self assert: each isReadOnlyObject equals: false ]
]

{ #category : #'tests - object' }
WriteBarrierTest >> testBecomeReadOnly [
	| readOnlyArrays readOnlyByteArrays |
	readOnlyArrays := (1 to: 3) collect: [:n| (0 to: n) asArray beReadOnlyObject; yourself].
	"N.B. if the targets are read-only this fails, which is correct for elementsForwardIdentityTo: since copyHash is implicitly true;
	 we need to write a test for a putative elementsForwardIdentityNoCopyHashTo:"
	readOnlyByteArrays := (1 to: 3) collect: [:n| (0 to: n) asByteArray" beReadOnlyObject; yourself"].
	self should: [readOnlyArrays elementsForwardIdentityTo: readOnlyByteArrays]
		raise: ModificationForbidden.
	[readOnlyArrays elementsForwardIdentityTo: readOnlyByteArrays]
		on: ModificationForbidden
		do: [:ex|
			false
				ifTrue: "This fails, but should succeed.  I *think* it's to do with catching signals when resignalling"
					[(ex mirror detect: [:element| element isReadOnlyObject] ifNone: []) ifNotNil:
						[:readOnlyObj| readOnlyObj beWritableObject]]
				ifFalse:
					[ex mirror do: [:element| element beWritableObject]].
			ex retryModification].
	self assert: (readOnlyArrays allSatisfy: [:array| array class == ByteArray])
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateByteArrayUsingByteAtPut [
	| guineaPig |
	guineaPig := ByteArray new: 5.
	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig byteAt: 1 put: 12  ]
		raise: ModificationForbidden.
		
	[ guineaPig byteAt: 1 put: 12 ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig first equals: 12.
	self deny: guineaPig isReadOnlyObject.

	guineaPig beReadOnlyObject.
	self 
		should: [ guineaPig byteAt: 1 put: 13  ]
		raise: ModificationForbidden.

	[ guineaPig byteAt: 1 put: 13  ]
		on: ModificationForbidden 
		do: [ :modification |
			modification object beWritableObject.
			modification retryModificationNoResume.
			modification object beReadOnlyObject.
			modification resume].

	self assert: guineaPig first equals: 13.
	self assert: guineaPig isReadOnlyObject
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateByteArrayUsingDoubleAtPut [
	| guineaPig |
	guineaPig := ByteArray new: 8.
	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig doubleAt: 1 put: (2 raisedTo: 65) asFloat ]
		raise: ModificationForbidden.
		
	[ guineaPig doubleAt: 1 put: (2 raisedTo: 65) asFloat ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig first equals: (2 raisedTo: 65) asFloat.
	self deny: guineaPig isReadOnlyObject.

	guineaPig beReadOnlyObject.
	self 
		should: [ guineaPig doubleAt: 1 put: (2 raisedTo: 64) asFloat ]
		raise: ModificationForbidden.

	[ guineaPig doubleAt: 1 put: (2 raisedTo: 64) asFloat ]
		on: ModificationForbidden 
		do: [ :modification |
			modification object beWritableObject.
			modification retryModificationNoResume.
			modification object beReadOnlyObject.
			modification resume].

	self assert: guineaPig first equals: (2 raisedTo: 64) asFloat.
	self assert: guineaPig isReadOnlyObject
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateByteArrayUsingFloatAtPut [
	| guineaPig |
	guineaPig := ByteArray new: 5.
	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig floatAt: 1 put: 1.0  ]
		raise: ModificationForbidden.
		
	[ guineaPig floatAt: 1 put: 1.0 ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig first equals: 1.0.
	self deny: guineaPig isReadOnlyObject.

	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig floatAt: 1 put: 2.0  ]
		raise: ModificationForbidden.
		
	[ guineaPig floatAt: 1 put: 2.0 ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModificationNoResume.
			modification object beReadOnlyObject.
			modification resume].

	self assert: guineaPig first equals: 2.0.
	self assert: guineaPig isReadOnlyObject
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateByteStringyUsingAtPut [
	| guineaPig |
	guineaPig := ByteString new: 5.
	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig at: 1 put: $h  ]
		raise: ModificationForbidden.
		
	[ guineaPig at: 1 put: $h ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig first equals: $h.
	self deny: guineaPig isReadOnlyObject.

	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig at: 1 put: $g  ]
		raise: ModificationForbidden.
		
	[ guineaPig at: 1 put: $g ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModificationNoResume.
			modification object beReadOnlyObject.
			modification resume ].

	self assert: guineaPig first equals: $g.
	self assert: guineaPig isReadOnlyObject
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateByteStringyUsingByteAtPut [
	| guineaPig |
	guineaPig := ByteString new: 5.
	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig byteAt: 1 put: 100  ]
		raise: ModificationForbidden.
		
	[ guineaPig byteAt: 1 put: 100 ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig first asciiValue equals: 100
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateByteSymbolUsingPrivateAtPut [
	| guineaPig |
	[guineaPig := #hello.
	 guineaPig beReadOnlyObject.
	
	 self 
		should: ((guineaPig class includesSelector: #pvtAt:put:)
					ifTrue: [[ guineaPig perform: #pvtAt:put: with: 1 with: $q ]] "Squeak refuses to compile non-self sends of pvt* selectors."
					ifFalse: [[ guineaPig privateAt: 1 put: $q ]])
		raise: ModificationForbidden ]
	ensure:
		[ guineaPig beWritableObject ].
	
	self assert: guineaPig first equals: $h
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateIVObject [
	| guineaPig |
	guineaPig := MessageSend new.
	guineaPig beReadOnlyObject.
	[ guineaPig receiver: 1 ] 
		on: ModificationForbidden 
		do: [ :modification | "Surely a NoModification error" ].
	guineaPig
		beWritableObject;
		selector: #+;
		beReadOnlyObject.
	[ guineaPig arguments: #(2) ] 
		on: ModificationForbidden 
		do: [  :modification |"Surely a NoModification error" ].
	self assert: guineaPig receiver isNil.
	self assert: guineaPig arguments isNil.
	self assert: guineaPig selector == #+.
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateObjectClass [
	| guineaPig |
	guineaPig := WriteBarrierStub new.
	guineaPig beReadOnlyObject.

	self 
		should: [ guineaPig primitiveChangeClassTo: WriteBarrierAnotherStub new ]
		raise: ModificationForbidden.

	[ guineaPig primitiveChangeClassTo: WriteBarrierAnotherStub new ]
		on: ModificationForbidden 
		do: [ :modification |
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig class equals: WriteBarrierAnotherStub
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateObjectClassViaAdoption [
	| guineaPig |
	guineaPig := WriteBarrierStub new.
	guineaPig beReadOnlyObject.

	self 
		should: [ WriteBarrierAnotherStub adoptInstance: guineaPig ]
		raise: ModificationForbidden.

	[ WriteBarrierAnotherStub adoptInstance: guineaPig ]
		on: ModificationForbidden 
		do: [ :modification |
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig class equals: WriteBarrierAnotherStub.
	self deny: guineaPig isReadOnlyObject.

	guineaPig beReadOnlyObject.
	self 
		should: [ WriteBarrierAnotherStub adoptInstance: guineaPig ]
		raise: ModificationForbidden.

	[ WriteBarrierAnotherStub adoptInstance: guineaPig ]
		on: ModificationForbidden 
		do: [ :modification |
			modification object beWritableObject.
			modification retryModificationNoResume.
			modification object beReadOnlyObject.
			modification resume].

	self assert: guineaPig class equals: WriteBarrierAnotherStub.
	self assert: guineaPig isReadOnlyObject
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateObjectFirstInstVarWithManyVars [
	| guineaPig failure |
	guineaPig := WriteBarrierStub new.
	guineaPig beReadOnlyObject.
	failure := [ guineaPig var1: #test ] on: ModificationForbidden do: [:err | err].

	self assert: failure fieldIndex equals: 1
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateObjectInstVarShouldCatchRightFailure [
	| guineaPig failure |
	guineaPig := MessageSend new.
	guineaPig beReadOnlyObject.
	failure := [ guineaPig receiver: #test ] on: ModificationForbidden do: [:err | err].

	self assert: failure object == guineaPig.
	self assert: failure newValue equals: #test.
	self assert: failure fieldIndex equals: 1.
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateObjectInstVarUsingAtPut [
	| guineaPig |
	guineaPig := Array new: 5.
	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig at: 1 put: #test  ]
		raise: ModificationForbidden.
		
	[ guineaPig at: 1 put: #test ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig first equals: #test.
	self deny: guineaPig isReadOnlyObject.

	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig at: 1 put: #test  ]
		raise: ModificationForbidden.
		
	[ guineaPig at: 1 put: #test ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModificationNoResume.
			modification object beReadOnlyObject.
			modification resume ].

	self assert: guineaPig first equals: #test.
	self assert: guineaPig isReadOnlyObject

]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateObjectInstVarUsingBasicAtPut [
	| guineaPig |
	guineaPig := Array new: 5.
	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig basicAt: 1 put: #test  ]
		raise: ModificationForbidden.
		
	[ guineaPig at: 1 put: #test ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig first equals: #test
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateObjectInstVarUsingInstVarAtPut [
	| guineaPig |
	guineaPig := WriteBarrierStub new.
	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig instVarAt: 1 put: #test  ]
		raise: ModificationForbidden.
		
	[ guineaPig instVarAt: 1 put: #test ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig var1 equals: #test
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateObjectLastInstVarWithManyVars [
	| guineaPig failure |
	guineaPig := WriteBarrierStub new.
	guineaPig beReadOnlyObject.
	failure := [ guineaPig var10: #test ] on: ModificationForbidden do: [:err | err].

	self assert: failure fieldIndex equals: 10
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateVariableObject [
	| guineaPigs |
	guineaPigs := {#[1 2 3] . #(1 2 3) }.
	guineaPigs do: [ :guineaPig | 
		guineaPig beReadOnlyObject.
		[guineaPig at: 1 put: 4] 
			on: ModificationForbidden  
			do: [ "Surely a NoModification error" ].
		guineaPig
			beWritableObject;
			at: 2 put:  5;
			beReadOnlyObject.
		[guineaPig at: 3 put: 6] 
			on: ModificationForbidden  
			do: [ "Surely a NoModification error" ].
		self assert: guineaPig first = 1.
		self assert: guineaPig second = 5.
		self assert: guineaPig third = 3 ]
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateWideStringUsingAtPut [
	| guineaPig |
	guineaPig := 'hello' asWideString.
	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig at: 1 put: $q  ]
		raise: ModificationForbidden.
		
	[ guineaPig at: 1 put: $q ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig first equals: $q
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateWideStringUsingWordAtPut [
	| guineaPig |
	guineaPig := 'hello' asWideString.
	guineaPig beReadOnlyObject.
	
	self 
		should: [ guineaPig wordAt: 1 put: 65536  ]
		raise: ModificationForbidden.
		
	[ guineaPig wordAt: 1 put: 65536 ] 
		on: ModificationForbidden 
		do: [:modification | 
			self assert: modification fieldIndex equals: 1.
			modification object beWritableObject.
			modification retryModification ].

	self assert: guineaPig first asciiValue equals: 65536
]

{ #category : #'tests - object' }
WriteBarrierTest >> testMutateWideSymbolUsingPrivateAtPut [
	| guineaPig |
	[ guineaPig := ('hello', (Character codePoint: 8002) asString) asSymbol.
	guineaPig beReadOnlyObject.
	
	self 
		should: ((guineaPig class includesSelector: #pvtAt:put:)
					ifTrue: [[ guineaPig perform: #pvtAt:put: with: 1 with: $A ]] "Squeak refuses to compile non-self sends of pvt* selectors."
					ifFalse: [[ guineaPig privateAt: 1 put: $A ]])
		raise: ModificationForbidden ]
		ensure: [ guineaPig beWritableObject ].

	self assert: guineaPig first  equals: $h
]

{ #category : #'tests - helper' }
WriteBarrierTest >> testObject: object initialState: initialState tuples: tuples [
	self 
		testObject: object 
		initialState: initialState 
		tuples: tuples 
		setReadOnlyBlock: [ :value | object setIsReadOnlyObject: value ]
]

{ #category : #'tests - helper' }
WriteBarrierTest >> testObject: object initialState: initialState tuples: tuples setReadOnlyBlock: setImmutabilityBlock [
	self assert: object isReadOnlyObject equals: initialState.
	tuples do: [ :tuple |
		| stateToSet expectedResult expectedNewState |
		stateToSet := tuple first.
		expectedResult := tuple second.
		expectedNewState := tuple last.
		[self assert: (setImmutabilityBlock value: stateToSet) equals: expectedResult ]
				on: ((Smalltalk classNamed: #PrimitiveFailed) ifNil: [Error])
				do: [ self assert: (self alwaysReadOnlyObjects , self alwaysWritableObjects includes: object) ].
		self assert: object isReadOnlyObject equals: expectedNewState ]
]

{ #category : #'tests - helper' }
WriteBarrierTest >> testProxyObject: object initialState: initialState tuples: tuples [
	self 
		testObject: object 
		initialState: initialState 
		tuples: tuples 
		setReadOnlyBlock: [ :value | 
			MirrorPrimitives makeObject: object readOnly: value ]
]

{ #category : #'tests - object' }
WriteBarrierTest >> testRetryingInstVarModification [
	| guineaPig |
	guineaPig := MessageSend new.
	guineaPig beReadOnlyObject.

	[ guineaPig receiver: 1 ] on: ModificationForbidden do: [:err | 
		guineaPig beWritableObject.
		err retryModification ].

	self assert: guineaPig receiver equals: 1
]

{ #category : #'tests - object' }
WriteBarrierTest >> testRetryingPointInstVarModification [
	| guineaPig labRat |
	guineaPig := 1@2.
	labRat := guineaPig copy bitShiftPoint: 3.
	guineaPig beReadOnlyObject.

	[ guineaPig bitShiftPoint: 3 ]
		on: ModificationForbidden
		do: [:err | 
			guineaPig beWritableObject.
			err retryModification ].

	self assert: guineaPig equals: labRat.
	self deny: guineaPig isReadOnlyObject.

	guineaPig bitShiftPoint: -3; beReadOnlyObject.
	self assert: guineaPig equals: 1@2.

	[ guineaPig bitShiftPoint: 3 ]
		on: ModificationForbidden
		do: [:err | 
			guineaPig beWritableObject.
			err retryModificationNoResume.
			guineaPig beReadOnlyObject.
			err resume ].

	self assert: guineaPig equals: labRat.
	self assert: guineaPig isReadOnlyObject
]

{ #category : #'tests - object' }
WriteBarrierTest >> testSetIsReadOnlyFailure [
	self alwaysWritableObjects do: [ :each |
		self 
			testObject: each 
			initialState: false 
			tuples: #( (true false false) (false false false) ) ]
]

{ #category : #'tests - proxy' }
WriteBarrierTest >> testSetIsReadOnlyFailureProxy [
	self alwaysWritableObjects do: [ :each |
		self 
			testProxyObject: each 
			initialState: false 
			tuples: #( (true false false) (false false false) ) ]
]

{ #category : #'tests - object' }
WriteBarrierTest >> testSetIsReadOnlyImmediate [
	self alwaysReadOnlyObjects do: [ :each |
		self 
			testObject: each 
			initialState: true 
			tuples: #( (true true true) (false true true) ) ]
]

{ #category : #'tests - proxy' }
WriteBarrierTest >> testSetIsReadOnlyImmediateProxy [
	self alwaysReadOnlyObjects do: [ :each |
		self 
			testProxyObject: each 
			initialState: true 
			tuples: #( (true true true) (false true true) ) ]
]

{ #category : #'tests - object' }
WriteBarrierTest >> testSetIsReadOnlySuccess [
	self maybeReadOnlyObjects do: [ :each |
		self 
			testObject: each 
			initialState: false 
			tuples: #( (true false true) (false true false) ) ]
]

{ #category : #'tests - proxy' }
WriteBarrierTest >> testSetIsReadOnlySuccessProxy [
	self maybeReadOnlyObjects do: [ :each |
		self 
			testProxyObject: each 
			initialState: false 
			tuples: #( (true false true) (false true false) ) ]
]
