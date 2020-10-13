"
This class implements the Secure Hash Algorithm (SHA) described in the U.S. government's Secure Hash Standard (SHS). This standard is described in FIPS PUB 180-1, ""SECURE HASH STANDARD"", April 17, 1995.

The Secure Hash Algorithm is also described on p. 442 of 'Applied Cryptography: Protocols, Algorithms, and Source Code in C' by Bruce Scheier, Wiley, 1996.

See the comment in class DigitalSignatureAlgorithm for details on its use.

Implementation notes:
The secure hash standard was created with 32-bit hardware in mind. All arithmetic in the hash computation must be done modulo 2^32. This implementation uses ThirtyTwoBitRegister objects to simulate hardware registers; this implementation is about six times faster than using LargePositiveIntegers (measured on a Macintosh G3 Powerbook). Implementing a primitive to process each 64-byte buffer would probably speed up the computation by a factor of 20 or more.

"
Class {
	#name : #SecureHashAlgorithm,
	#superclass : #Object,
	#instVars : [
		'totalA',
		'totalB',
		'totalC',
		'totalD',
		'totalE',
		'totals'
	],
	#classVars : [
		'K1',
		'K2',
		'K3',
		'K4',
		'TA',
		'TB',
		'TC',
		'TD',
		'TE',
		'TI'
	],
	#category : #'System-Digital Signatures'
}

{ #category : #'class initialization' }
SecureHashAlgorithm class >> initialize [
	"SecureHashAlgorithm initialize"
	"For the curious, here's where these constants come from:
	  #(2 3 5 10) collect: [:x | ((x sqrt / 4.0) * (2.0 raisedTo: 32)) truncated hex]"

	K1 := ThirtyTwoBitRegister fromInteger: 16r5A827999.
	K2 := ThirtyTwoBitRegister fromInteger: 16r6ED9EBA1.
	K3 := ThirtyTwoBitRegister fromInteger: 16r8F1BBCDC.
	K4 := ThirtyTwoBitRegister fromInteger: 16rCA62C1D6.
	
	TA := ThirtyTwoBitRegister fromInteger: 16r67452301.
	TB := ThirtyTwoBitRegister fromInteger: 16rEFCDAB89.
	TC := ThirtyTwoBitRegister fromInteger: 16r98BADCFE.
	TD := ThirtyTwoBitRegister fromInteger: 16r10325476.
	TE := ThirtyTwoBitRegister fromInteger: 16rC3D2E1F0.
	(TI := Bitmap new: 5)
		at: 1 put: 16r67452301;	
		at: 2 put: 16rEFCDAB89;
		at: 3 put: 16r98BADCFE;
		at: 4 put: 16r10325476;
		at: 5 put: 16rC3D2E1F0
]

{ #category : #private }
SecureHashAlgorithm >> constantForStep: i [
	"Answer the constant for the i-th step of the block hash loop. We number our steps 1-80, versus the 0-79 of the standard."

	i <= 20 ifTrue: [^ K1].
	i <= 40 ifTrue: [^ K2].
	i <= 60 ifTrue: [^ K3].
	^ K4

]

{ #category : #private }
SecureHashAlgorithm >> expandedBlock: aByteArray [
	"Convert the given 64 byte buffer into 80 32-bit registers and answer the result."

	| out src |
	out := Array new: 80.
	src := 1.
	1 to: 16 do: [:i |
		out at: i put: (ThirtyTwoBitRegister fromByteArray: aByteArray at: src).
		src := src + 4].

	17 to: 80 do: [:i |
		out at: i put: (
			(out at: i - 3) copy
				bitXor: (out at: i - 8);
				bitXor: (out at: i - 14);
				bitXor: (out at: i - 16);
				leftRotateBy: 1) ].
	^ out

]

{ #category : #private }
SecureHashAlgorithm >> finalHash [
	"Concatenate the final totals to build the 160-bit integer result."
	"Details: If the primitives are supported, the results are in the totals array. Otherwise, they are in the instance variables totalA through totalE."

	| result |
	result := ByteArray new: 20.
	totals 
		ifNil: [ "compute final hash when not using primitives"
			result
				unsignedShortAt: 1 put: totalE low bigEndian: false;
				unsignedShortAt: 3 put: totalE hi bigEndian: false;
				unsignedShortAt: 5 put: totalD low bigEndian: false;
				unsignedShortAt: 7 put: totalD hi bigEndian: false;
				unsignedShortAt: 9 put: totalC low bigEndian: false;
				unsignedShortAt: 11 put: totalC hi bigEndian: false;
				unsignedShortAt: 13 put: totalB low bigEndian: false;
				unsignedShortAt: 15 put: totalB hi bigEndian: false;
				unsignedShortAt: 17 put: totalA low bigEndian: false;
				unsignedShortAt: 19 put: totalA hi bigEndian: false ]
		ifNotNil: [ "compute final hash when using primitives"
			result
				unsignedLongAt: 1 put: (totals at: 5) bigEndian: false;
				unsignedLongAt: 5 put: (totals at: 4) bigEndian: false;
				unsignedLongAt: 9 put: (totals at: 3) bigEndian: false;
				unsignedLongAt: 13 put: (totals at: 2) bigEndian: false;
				unsignedLongAt: 17 put: (totals at: 1) bigEndian: false ].
	LargePositiveInteger adoptInstance: result.
	^result normalize
]

{ #category : #private }
SecureHashAlgorithm >> hashFunction: i of: x with: y with: z using: t1 and: t2 [
	"Compute the hash function for the i-th step of the block hash loop. We number our steps 1-80, versus the 0-79 of the standard."
	"Details: There are four functions, one for each 20 iterations. The second and fourth are the same."

	t1 loadFrom: x.
	i <= 20 ifTrue: [
		t2
			loadFrom: x;
			bitInvert;
			bitAnd: z.
		^t1
			bitAnd: y;
			bitOr: t2 ].
	i <= 40 ifTrue: [
		^t1
			bitXor: y;
			bitXor: z ].
	i <= 60 ifTrue: [
		t2
			loadFrom: x;
			bitOr: y;
			bitAnd: z.
		^t1
			bitAnd: y;
			bitOr: t2 ].
	^t1
		bitXor: y;
		bitXor: z

]

{ #category : #public }
SecureHashAlgorithm >> hashInteger: aPositiveInteger [
	"Hash the given positive integer. The integer to be hashed should have 512 or fewer bits. This entry point is used in key generation."

	| buffer dstIndex |
	self initializeTotals.

	"pad integer with zeros"
	aPositiveInteger highBit <= 512
		ifFalse: [self error: 'integer cannot exceed 512 bits'].
	buffer := ByteArray new: 64.
	dstIndex := 0.
	aPositiveInteger digitLength to: 1 by: -1 do: [:i |
		buffer at: (dstIndex := dstIndex + 1) put: (aPositiveInteger digitAt: i)].

	"process that one block"
	self processBuffer: buffer.

	^ self finalHash

]

{ #category : #public }
SecureHashAlgorithm >> hashInteger: aPositiveInteger seed: seedInteger [
	"Hash the given positive integer. The integer to be hashed should have 512 or fewer bits. This entry point is used in the production of random numbers"

	| buffer dstIndex |
	"Initialize totalA through totalE to their seed values."
	totals
		ifNil: [
			totalA := ThirtyTwoBitRegister
				fromInteger: ((seedInteger bitShift: -128) bitAnd: 16rFFFFFFFF).
			totalB := ThirtyTwoBitRegister
				fromInteger: ((seedInteger bitShift: -96) bitAnd: 16rFFFFFFFF).
			totalC := ThirtyTwoBitRegister
				fromInteger: ((seedInteger bitShift: -64) bitAnd: 16rFFFFFFFF).
			totalD := ThirtyTwoBitRegister
				fromInteger: ((seedInteger bitShift: -32) bitAnd: 16rFFFFFFFF).
			totalE := ThirtyTwoBitRegister
				fromInteger: (seedInteger bitAnd: 16rFFFFFFFF) ]
		ifNotNil: [
			totals
				at: 1 put: ((seedInteger bitShift: -128) bitAnd: 16rFFFFFFFF);
				at: 2 put: ((seedInteger bitShift: -96) bitAnd: 16rFFFFFFFF);
				at: 3 put: ((seedInteger bitShift: -64) bitAnd: 16rFFFFFFFF);
				at: 4 put: ((seedInteger bitShift: -32) bitAnd: 16rFFFFFFFF);
				at: 5 put: (seedInteger bitAnd: 16rFFFFFFFF) ].
	"pad integer with zeros"
	buffer := ByteArray new: 64.
	dstIndex := 0.
	aPositiveInteger digitLength to: 1 by: -1 do: [:i |
		buffer at: (dstIndex := dstIndex + 1) put: (aPositiveInteger digitAt: i)].

	"process that one block"
	self processBuffer: buffer.

	^ self finalHash

]

{ #category : #public }
SecureHashAlgorithm >> hashMessage: aStringOrByteArray [
	"Hash the given message using the Secure Hash Algorithm."

	^ self hashStream: (ReadStream on: aStringOrByteArray asByteArray)

]

{ #category : #public }
SecureHashAlgorithm >> hashStream: aPositionableStream [
	"Hash the contents of the given stream from the current position to the end using the Secure Hash Algorithm. The SHA algorithm is defined in FIPS PUB 180-1. It is also described on p. 442 of 'Applied Cryptography: Protocols, Algorithms, and Source Code in C' by Bruce Scheier, Wiley, 1996."
	"SecureHashAlgorithm new hashStream: (ReadStream on: 'foo')"

	| startPosition buf bitLength |
	self initializeTotals.

	"(SecureHashAlgorithm new hashMessage: '') radix: 16 	
	=> 'DA39A3EE5E6B4B0D3255BFEF95601890AFD80709'"
	aPositionableStream atEnd ifTrue: [self processFinalBuffer: #[] bitLength: 0].

	startPosition := aPositionableStream position.
	buf := ByteArray new: 64.
	[aPositionableStream atEnd] whileFalse: [
		buf := aPositionableStream next: 64 into: buf startingAt: 1.
		(aPositionableStream atEnd not and: [buf size = 64])
			ifTrue: [self processBuffer: buf]
			ifFalse: [
				bitLength := (aPositionableStream position - startPosition) * 8.
				self processFinalBuffer: buf bitLength: bitLength]].

	^ self finalHash

]

{ #category : #'initialize-release' }
SecureHashAlgorithm >> initialize [

	self primHasSecureHashPrimitive
		ifTrue: [ totals := Bitmap new: 5 ]
		ifFalse: [
			totalA := ThirtyTwoBitRegister new.
			totalB := ThirtyTwoBitRegister new.
			totalC := ThirtyTwoBitRegister new.
			totalD := ThirtyTwoBitRegister new.
			totalE := ThirtyTwoBitRegister new ]
]

{ #category : #private }
SecureHashAlgorithm >> initializeTotals [
	"Initialize totalA through totalE to their seed values."

	totals
		ifNil: [
			"total registers for use when primitives are absent"
			totalA loadFrom: TA.
			totalB loadFrom: TB.
			totalC loadFrom: TC.
			totalD loadFrom: TD.
			totalE loadFrom: TE ]
		ifNotNil: [
			totals
				replaceFrom: 1
				to: totals size
				with: TI
				startingAt: 1 ]
]

{ #category : #primitives }
SecureHashAlgorithm >> primExpandBlock: aByteArray into: wordBitmap [
	"Expand the given 64-byte buffer into the given Bitmap of length 80."

	<primitive: 'primitiveExpandBlock' module: 'DSAPrims'>
	^ self primitiveFailed

]

{ #category : #primitives }
SecureHashAlgorithm >> primHasSecureHashPrimitive [
	"Answer true if this platform has primitive support for the Secure Hash Algorithm."

	<primitive: 'primitiveHasSecureHashPrimitive' module: 'DSAPrims'>
	^ false

]

{ #category : #primitives }
SecureHashAlgorithm >> primHashBlock: blockBitmap using: workingTotalsBitmap [
	"Hash the given block (a Bitmap) of 80 32-bit words, using the given workingTotals."

	<primitive: 'primitiveHashBlock' module: 'DSAPrims'>
	^ self primitiveFailed

]

{ #category : #private }
SecureHashAlgorithm >> processBuffer: aByteArray [
	"Process given 64-byte buffer, accumulating the results in totalA through totalE."

	| a b c d e t tmp w tmp2 tmp3 |
	totals ifNotNil: [ ^self processBufferUsingPrimitives: aByteArray ].

	"initialize registers a through e from the current totals" 
	a := totalA copy.
	b := totalB copy.
	c := totalC copy.
	d := totalD copy.
	e := totalE copy.

	"expand and process the buffer"
	w := self expandedBlock: aByteArray.
	tmp := ThirtyTwoBitRegister new.
	tmp2 := ThirtyTwoBitRegister new.
	tmp3 := ThirtyTwoBitRegister new.
	1 to: 80 do: [:i |
		tmp
			loadFrom: a;
			leftRotateBy: 5;
			+= (self hashFunction: i of: b with: c with: d using: tmp2 and: tmp3);
			+= e;
			+= (w at: i);
			+= (self constantForStep: i).
		t := e.
		e := d.
		d := c.
		c := b leftRotateBy: 30.
		b := a.
		a := tmp.
		tmp := t ].

	"add a through e into total accumulators"
	totalA += a.
	totalB += b.
	totalC += c.
	totalD += d.
	totalE += e.

]

{ #category : #private }
SecureHashAlgorithm >> processBufferUsingPrimitives: aByteArray [
	"Process given 64-byte buffer using the primitives, accumulating the results in totals."

	| w |
	"expand and process the buffer"
	w := Bitmap new: 80.
	self primExpandBlock: aByteArray into: w.
	self primHashBlock: w using: totals.

]

{ #category : #private }
SecureHashAlgorithm >> processFinalBuffer: buffer bitLength: bitLength [
	"Process given buffer, whose length may be <= 64 bytes, accumulating the results in totalA through totalE. Also process the final padding bits and length."

	| out |
	out := ByteArray new: 64.
	out replaceFrom: 1 to: buffer size with: buffer startingAt: 1.
	buffer size < 56 ifTrue: [  "padding and length fit in last data block"
		out at: buffer size + 1 put: 128.  "trailing one bit"
		self storeLength: bitLength in: out.  "end with length"
		self processBuffer: out.
		^ self].

	"process the final data block"
	buffer size < 64 ifTrue: [
		out at: buffer size + 1 put: 128].  "trailing one bit"
	self processBuffer: out.

	"process one additional block of padding ending with the length"
	out := ByteArray new: 64.  "filled with zeros"
	buffer size = 64 ifTrue: [
		"add trailing one bit that didn't fit in final data block"
		out at: 1 put: 128].
	self storeLength: bitLength in: out.
	self processBuffer: out.

]

{ #category : #private }
SecureHashAlgorithm >> storeLength: bitLength in: aByteArray [
	"Fill in the final 8 bytes of the given ByteArray with a 64-bit big-endian representation of the original message length in bits."

	| n i |
	n := bitLength.
	i := aByteArray size.
	[n > 0] whileTrue: [
		aByteArray at: i put: (n bitAnd: 16rFF).
		n := n bitShift: -8.
		i := i - 1].

]
