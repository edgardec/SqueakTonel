"
I present an ArrayedCollection whose elements are objects.
"
Class {
	#name : #Array,
	#superclass : #ArrayedCollection,
	#type : #variable,
	#category : #'Collections-Arrayed'
}

{ #category : #'brace support' }
Array class >> braceStream: nElements [
	"This method is used in compilation of brace constructs.
	It MUST NOT be deleted or altered."

	^ WriteStream basicNew braceArray: (self new: nElements)

]

{ #category : #'instance creation' }
Array class >> empty [
	"A canonicalized empty Array instance."
	^ #()
]

{ #category : #'instance creation' }
Array class >> new: sizeRequested [ 
	"Answer an instance of this class with the number of indexable
	variables specified by the argument, sizeRequested.
	
	This is a shortcut (direct call of primitive, no #initialize, for performance"

	<primitive: 71>  "This method runs primitively if successful"
	^ self basicNew: sizeRequested  "Exceptional conditions will be handled in basicNew:"

]

{ #category : #arithmetic }
Array >> +* aCollection [
	"Premultiply aCollection by self.  aCollection should be an Array or Matrix.
	 The name of this method is APL's +.x squished into Smalltalk syntax."

	^aCollection preMultiplyByArray: self

]

{ #category : #literals }
Array >> allLiteralsDo: aBlock [

	"I am a literal."
	aBlock value: self.
	
	"All my elements are literals."
	self do: [:each | each allLiteralsDo: aBlock].
]

{ #category : #converting }
Array >> asArray [
	"Answer with the receiver itself."

	^ self
]

{ #category : #accessing }
Array >> atWrap: index [ 
	"Optimized to go through the primitive if possible"
	<primitive: 60>
	^ self at: index - 1 \\ self size + 1
]

{ #category : #accessing }
Array >> atWrap: index put: anObject [
	"Optimized to go through the primitive if possible"
	<primitive: 61>
	^ self at: index - 1 \\ self size + 1 put: anObject
]

{ #category : #'filter streaming' }
Array >> byteEncode:aStream [
	aStream writeArray:self.

]

{ #category : #copying }
Array >> copyWithDependent: newElement [
	self size = 0 ifTrue:[^DependentsArray with: newElement].
	^self copyWith: newElement
]

{ #category : #converting }
Array >> elementsExchangeIdentityWith: otherArray [
	"This primitive performs a bulk mutation, causing all pointers to the elements of the
	 receiver to be replaced by pointers to the corresponding elements of otherArray.
	 At the same time, all pointers to the elements of otherArray are replaced by
	 pointers to the corresponding elements of this array.  The identityHashes remain
	 with the pointers rather than with the objects so that objects in hashed structures
	 should still be properly indexed after the mutation."

	<primitive: 128 error: ec>
	ec == #'no modification' ifTrue:
		[^self modificationForbiddenFor: otherArray becomeSelector: #elementsExchangeIdentityWith:].
	ec == #'bad receiver' ifTrue:
		[^self error: 'receiver must be of class Array'].
	ec == #'bad argument' ifTrue:
		[^self error: (otherArray class == Array
						ifFalse: ['arg must be of class Array']
						ifTrue: ['receiver and argument must have the same size'])].
	ec == #'inappropriate operation' ifTrue:
		[^self error: 'can''t become immediates such as SmallIntegers or Characters'].
	ec == #'object is pinned' ifTrue:
		[^self error: 'can''t become pinned objects'].
	ec == #'insufficient object memory' ifTrue:
		[| maxRequired |
		 "In Spur, two-way become may involve making each pair of objects into a forwarder into a copy of the other.
		 So if become fails with #'insufficient object memory', garbage collect, and if necessary, grow memory."
		 maxRequired := (self detectSum: [:obj | obj class byteSizeOfInstanceOfSize: obj basicSize])
						+ (otherArray detectSum: [:obj | obj class byteSizeOfInstanceOfSize: obj basicSize]).
		 (Smalltalk garbageCollectMost < maxRequired
		  and: [Smalltalk garbageCollect < maxRequired]) ifTrue:
			[Smalltalk growMemoryByAtLeast: maxRequired].
		 ^self elementsExchangeIdentityWith: otherArray].
	self primitiveFailed
]

{ #category : #converting }
Array >> elementsForwardIdentityAndHashTo: otherArray [
	"This primitive performs a bulk mutation, causing all pointers to the elements of the
	 receiver to be replaced by pointers to the corresponding elements of otherArray.
	 The identityHashes remain with the pointers rather than with the objects so that
	 the objects in this array should still be properly indexed in any existing hashed
	 structures after the mutation."
	<primitive: 72 error: ec>
	ec == #'no modification' ifTrue:
		[^self modificationForbiddenFor: otherArray becomeSelector: #elementsForwardIdentityAndHashTo:].
	ec == #'bad receiver' ifTrue:
		[^self error: 'receiver must be of class Array'].
	ec == #'bad argument' ifTrue:
		[^self error: (otherArray class == Array
						ifFalse: ['arg must be of class Array']
						ifTrue: ['receiver and argument must have the same size'])].
	ec == #'inappropriate operation' ifTrue:
		[^self error: 'can''t become immediates such as SmallIntegers or Characters'].
	ec == #'object is pinned' ifTrue:
		[^self error: 'can''t become pinned objects'].
	ec == #'insufficient object memory' ifTrue:
		[self error: 'The virtual machine is out-of-date.  Please upgrade.'].
	self primitiveFailed
]

{ #category : #converting }
Array >> elementsForwardIdentityTo: otherArray [
	"This primitive performs a bulk mutation, causing all pointers to the elements of the
	 receiver to be replaced by pointers to the corresponding elements of otherArray.
	 The identityHashes are not copied to the target objects so that the objects in otherArray
	 should still be properly indexed in any existing hashed structures after the mutation."
	<primitive: 248 error: ec>
	ec == #'no modification' ifTrue:
		[^self modificationForbiddenFor: otherArray becomeSelector: #elementsForwardIdentityTo:].
	ec == #'bad receiver' ifTrue:
		[^self error: 'receiver must be of class Array'].
	ec == #'bad argument' ifTrue:
		[^self error: (otherArray class == Array
						ifFalse: ['arg must be of class Array']
						ifTrue: ['receiver and argument must have the same size'])].
	ec == #'inappropriate operation' ifTrue:
		[^self error: 'can''t become immediates such as SmallIntegers or Characters'].
	ec == #'object is pinned' ifTrue:
		[^self error: 'can''t become pinned objects'].
	ec == #'insufficient object memory' ifTrue:
		[self error: 'The virtual machine is out-of-date.  Please upgrade.'].
	self primitiveFailed
]

{ #category : #converting }
Array >> elementsForwardIdentityTo: otherArray copyHash: copyHash [
	"This primitive performs a bulk mutation, causing all pointers to the elements of the
	 receiver to be replaced by pointers to the corresponding elements of otherArray.
	 If copyHash is true, the identityHashes remain with the pointers rather than with the
	 objects so that the objects in the receiver should still be properly indexed in any
	 existing hashed structures after the mutation.  If copyHash is false, then the hashes
	 of the objects in otherArray remain unchanged.  If you know what you're doing this
	 may indeed be what you want."
	<primitive: 249 error: ec>
	ec == #'no modification' ifTrue:
		[^self modificationForbiddenFor: otherArray argument: copyHash becomeSelector: #elementsForwardIdentityTo:copyHash:].
	ec == #'bad receiver' ifTrue:
		[^self error: 'receiver must be of class Array'].
	ec == #'bad argument' ifTrue:
		[^self error: (otherArray class == Array
						ifFalse: ['arg must be of class Array']
						ifTrue: ['receiver and argument must have the same size'])].
	ec == #'inappropriate operation' ifTrue:
		[^self error: 'can''t become immediates such as SmallIntegers or Characters'].
	ec == #'object is pinned' ifTrue:
		[^self error: 'can''t become pinned objects'].
	self primitiveFailed
]

{ #category : #converting }
Array >> evalStrings [
	   "Allows you to construct literal arrays.
    #(true false nil '5@6' 'Set new' '''text string''') evalStrings
    gives an array with true, false, nil, a Point, a Set, and a String
    instead of just a bunch of Symbols"
    

    ^ self collect: [:each | | it |
        it := each.
        each == #true ifTrue: [it := true].
		      each == #false ifTrue: [it := false].
        each == #nil ifTrue: [it := nil].
        (each isString and:[each isSymbol not]) ifTrue: [
			it := Compiler evaluate: each].
        each class == Array ifTrue: [it := it evalStrings].
        it]
]

{ #category : #testing }
Array >> isArray [
	^true
]

{ #category : #testing }
Array >> isLiteral [
	
	^self class == Array and: [
		self isLiteralIfContainedBy: IdentitySet new ]
]

{ #category : #testing }
Array >> isLiteralIfContainedBy: parents [
	" Answer whether the receiver has a literal text form recognized by the compiler. Precondition: the receiver is an instance of Array. "

	(parents includes: self) ifTrue: [ ^false ].
	parents add: self.
	1 to: self size do: [ :index |
		| element |
		element := self at: index.
		(element class == Array
			ifTrue: [ element isLiteralIfContainedBy: parents ]
			ifFalse: [ element isLiteral ]) ifFalse: [ ^false ] ].
	parents remove: self.
	^true
]

{ #category : #literals }
Array >> literalEqual: other [

	self class == other class ifFalse: [^ false].
	self size = other size ifFalse: [^ false].
	self with: other do: [:e1 :e2 |
		(e1 literalEqual: e2) ifFalse: [^ false]].
	^ true
]

{ #category : #'read-only objects' }
Array >> modificationForbiddenFor: otherArray argument: argument becomeSelector: retrySelector [
	"Raise a ModificationForbidden error for an attempt to modify a read-only object through a become operation."
	^(ModificationForbidden new
		mirror: self
		object: otherArray
		index: nil
		newValue: argument
		resumptionValue: self
		retrySelector: retrySelector) signal
]

{ #category : #'read-only objects' }
Array >> modificationForbiddenFor: otherArray becomeSelector: retrySelector [
	"Raise a ModificationForbidden error for an attempt to modify a read-only object through a become operation."
	^(BinaryModificationForbidden new
		mirror: self
		object: otherArray
		index: nil
		newValue: nil
		resumptionValue: self
		retrySelector: retrySelector) signal
]

{ #category : #arithmetic }
Array >> preMultiplyByArray: a [
	"Answer a+*self where a is an Array.  Arrays are always understood as column vectors,
	 so an n element Array is an n*1 Array.  This multiplication is legal iff self size = 1."

	self size = 1 ifFalse: [self error: 'dimensions do not conform'].
	^a * self first
]

{ #category : #arithmetic }
Array >> preMultiplyByMatrix: m [
	"Answer m+*self where m is a Matrix."
	m columnCount = self size ifFalse: [self error: 'dimensions do not conform'].
	^(1 to: m rowCount) collect: [:row |
		| s |
		s := 0.
		1 to: self size do: [:k | s := (m at: row at: k) * (self at: k) + s].
		s]
]

{ #category : #printing }
Array >> printAsBraceFormOn: aStream [
	aStream nextPut: ${.
	self do: [:el | el printOn: aStream] separatedBy: [ aStream nextPutAll: ' . '].
	aStream nextPut: $}
]

{ #category : #printing }
Array >> printAsLiteralOn: aStream [
	aStream nextPut: $#; nextPut: $(.
	self do: [:each| each printAsLiteralOn: aStream] separatedBy: [aStream space].
	aStream nextPut: $)

]

{ #category : #printing }
Array >> printOn: aStream [
	self class == Array ifFalse:
		[^super printOn: aStream].
	self shouldBePrintedAsLiteral
		ifTrue: [self printAsLiteralOn: aStream]
		ifFalse: [self printAsBraceFormOn: aStream]
]

{ #category : #private }
Array >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	super replaceFrom: start to: stop with: replacement startingAt: repStart
]

{ #category : #testing }
Array >> shouldBePrintedAsLiteral [

	^self class == Array
	  and: [self shouldBePrintedAsLiteralVisiting: (IdentitySet new: 8)]
]

{ #category : #testing }
Array >> shouldBePrintedAsLiteralVisiting: aSet [
	self class == Array ifFalse:
		[^false].
	(aSet includes: self) ifTrue:
		[^false].
	aSet add: self.
	^self allSatisfy: [:each | each shouldBePrintedAsLiteralVisiting: aSet]
]

{ #category : #sorting }
Array >> sorted: aSortBlockOrNil [
	"Return a new sequenceable collection which contains the same elements as self but its elements are sorted by aSortBlockOrNil. The block should take two arguments and return true if the first element should preceed the second one. If aSortBlock is nil then <= is used for comparison."
	
	^self copy sort: aSortBlockOrNil
]

{ #category : #printing }
Array >> storeOn: aStream [
	"Use the literal form if possible."
	self shouldBePrintedAsLiteral
		ifTrue:  [self printAsLiteralOn: aStream]
		ifFalse: [super storeOn: aStream]
]
