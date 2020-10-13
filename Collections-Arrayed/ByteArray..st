"
I represent an ArrayedCollection whose elements are integers between 0 and 255.

"
Class {
	#name : #ByteArray,
	#superclass : #UnsignedIntegerArray,
	#type : #bytes,
	#category : #'Collections-Arrayed'
}

{ #category : #'instance creation' }
ByteArray class >> empty [
	"A canonicalized empty ByteArray instance."
	^ #[]
]

{ #category : #'byte based hash' }
ByteArray class >> hashBytes: aByteArray startingWith: speciesHash [
	"Answer the hash of a byte-indexed collection, using speciesHash as the initial value.
	 See SmallInteger>>hashMultiply.

	 The primitive should be renamed at a suitable point in the future"
	<primitive: 'primitiveStringHash' module: 'MiscPrimitivePlugin'>
	
	^String stringHash: aByteArray initialHash: speciesHash
]

{ #category : #'instance creation' }
ByteArray class >> readHexFrom: aString [
	"Create a byte array from a hexadecimal representation"
	^(self new: aString size // 2) readHexFrom: aString readStream
]

{ #category : #converting }
ByteArray >> asByteArray [
	^ self
]

{ #category : #converting }
ByteArray >> asString [
	"Convert to a String with Characters for each byte.
	Fast code uses primitive that avoids character conversion"

	^ (String new: self size) replaceFrom: 1 to: self size with: self
]

{ #category : #accessing }
ByteArray >> asWideString [

	^ WideString fromByteArray: self.

]

{ #category : #converting }
ByteArray >> ascii85Encoded [
	"Encode the receiver as Ascii85"
	"'Hello World' asByteArray ascii85Encoded"

	^ (Ascii85Converter encode: self readStream) contents
]

{ #category : #converting }
ByteArray >> base64Encoded [
	"Encode the receiver as base64"
	"'Hello World' asByteArray base64Encoded"
	^(Base64MimeConverter mimeEncode: self readStream) contents
]

{ #category : #accessing }
ByteArray >> byteAt: index [
	<primitive: 60>
	^ super at: index
]

{ #category : #accessing }
ByteArray >> byteAt: index put: value [
	<primitive: 61>
	^ super at: index put: value
]

{ #category : #accessing }
ByteArray >> bytesPerElement [
	"Number of bytes in each item.  This multiplied by (self size)*8 gives the number of bits stored."
	^ 1
]

{ #category : #private }
ByteArray >> defaultElement [

	^0
]

{ #category : #'platform independent access' }
ByteArray >> doubleAt: index bigEndian: bool [ 
	"Return a 64 bit float starting from the given byte index"
	| w1 w2 dbl |
	w1 := self unsignedLongAt: index bigEndian: bool.
	w2 := self unsignedLongAt: index + 4 bigEndian: bool.
	dbl := Float new: 2. 
	bool
		ifTrue: [dbl basicAt: 1 put: w1.
			dbl basicAt: 2 put: w2]
		ifFalse: [dbl basicAt: 1 put: w2.
			dbl basicAt: 2 put: w1].
	^ dbl
]

{ #category : #'platform independent access' }
ByteArray >> doubleAt: index put: value bigEndian: bool [ 
	"Store a 64 bit float starting from the given byte index"
	| w1 w2 |
	bool
		ifTrue: [w1 := value basicAt: 1.
			w2 := value basicAt: 2]
		ifFalse: [w1 := value basicAt: 2.
			w2 := value basicAt: 1]. 
	self unsignedLongAt: index put: w1 bigEndian: bool.
	self unsignedLongAt: index + 4 put: w2 bigEndian: bool.
	^ value
]

{ #category : #comparing }
ByteArray >> hash [
	"#hash is implemented, because #= is implemented"

	^self hashWithInitialHash: self species hash
]

{ #category : #private }
ByteArray >> hashWithInitialHash: speciesHash [
	"Answer the hash of a byte-indexed array, using speciesHash as the initial value.
	 See SmallInteger>>hashMultiply."
	<primitive: 'primitiveStringHash' module: 'MiscPrimitivePlugin'>

	^String stringHash: self initialHash: speciesHash
]

{ #category : #converting }
ByteArray >> hex [
	"Answer a hexa decimal representation of the receiver"
	| string v index map |
	map := '0123456789abcdef'.
	string := String new: self size * 2. "hex"
	index := 0.
	1 to: self size do:[:i| 
		v := self at: i.
		string at: (index := index + 1) put: (map at: (v bitShift: -4) + 1). 
		string at: (index := index + 1) put: (map at: (v bitAnd: 15) + 1).
	].
	^string
]

{ #category : #accessing }
ByteArray >> indexOf: anInteger startingAt: start [

	anInteger isInteger ifFalse: [ ^0 ].
	0 <= anInteger ifFalse: [ ^0 ].
	anInteger <= 255 ifFalse: [ ^0 ].
	^ByteString indexOfAscii: anInteger inString: self startingAt: start
]

{ #category : #testing }
ByteArray >> isLiteral [
	"so that #(1 #[1 2 3] 5) prints itself"
	^self class == ByteArray
]

{ #category : #'platform independent access' }
ByteArray >> long64At: index bigEndian: bigEndian [
	"Return a 64-bit signed integer quantity starting from the given byte index."

	| value |
	value := self unsignedLong64At: index bigEndian: bigEndian.
	value digitLength < 8 ifTrue: [ ^value ].
	(value digitAt: 8) < 16r80 ifTrue: [ ^value ].
	^value - 16r10000000000000000
]

{ #category : #'platform independent access' }
ByteArray >> long64At: index put: value bigEndian: bigEndian [
	"Store a 64-bit signed integer quantity starting from the given byte index."
	
	^self
		unsignedLong64At: index
		put: (value negative
			ifFalse: [ value ]
			ifTrue: [ value + 16r10000000000000000 ])
		bigEndian: bigEndian
]

{ #category : #'platform independent access' }
ByteArray >> longAt: index bigEndian: bigEndian [
	"Return a 32-bit integer quantity starting from the given byte index. Use #normalize where necessary to ensure compatibility with non-30-bit SmallIntegers."
	
	| byte result |
	bigEndian ifFalse: [
		(byte := self at: index + 3) <= 16r7F ifTrue: [ "Is the result non-negative?"
			byte <= 16r3F ifTrue: [
				^(((byte bitShift: 8) + (self at: index + 2) bitShift: 8) + (self at: index + 1) bitShift: 8) + (self at: index) ].
			^(LargePositiveInteger new: 4)
				replaceFrom: 1
					to: 4
					with: self
					startingAt: index;
				normalize ].
		"Negative"
		byte >= 16rC0 ifTrue: [
			^-1 - (((((byte bitShift: 8) + (self at: index + 2) bitShift: 8) + (self at: index + 1) bitXor: 16rFFFFFF) bitShift: 8) + ((self at: index) bitXor: 16rFF)) ].
		(result := LargeNegativeInteger new: 4)
			digitAt: 4 put: ((self at: index + 3) bitXor: 16rFF);
			digitAt: 3 put: ((self at: index + 2) bitXor: 16rFF);
			digitAt: 2 put: ((self at: index + 1) bitXor: 16rFF).
		(byte := ((self at: index) bitXor: 16rFF) + 1) <= 16rFF ifTrue: [
			^result
				digitAt: 1 put: byte;
				normalize ].
		^result
			digitAt: 1 put: 16rFF;
			- 1 "It's tempting to do the subtraction in a loop to avoid the LargeInteger creation, but it's actually slower than this." ].
	(byte := self at: index) <= 16r7F ifTrue: [ "Is the result non-negative?"
		byte <= 16r3F ifTrue: [
			^(((byte bitShift: 8) + (self at: index + 1) bitShift: 8) + (self at: index + 2) bitShift: 8) + (self at: index + 3) ].
		^(LargePositiveInteger new: 4)
			digitAt: 1 put: (self at: index + 3);
			digitAt: 2 put: (self at: index + 2);
			digitAt: 3 put: (self at: index + 1);
			digitAt: 4 put: byte;
			normalize ].
	"Negative"
	16rC0 <= byte ifTrue: [
		^-1 - (((((byte bitShift: 8) + (self at: index + 1) bitShift: 8) + (self at: index + 2) bitXor: 16rFFFFFF) bitShift: 8) + ((self at: index + 3) bitXor: 16rFF)) ].
	(result := LargeNegativeInteger new: 4)
		digitAt: 4 put: (byte bitXor: 16rFF);
		digitAt: 3 put: ((self at: index + 1) bitXor: 16rFF);
		digitAt: 2 put: ((self at: index + 2) bitXor: 16rFF).
	(byte := ((self at: index + 3) bitXor: 16rFF) + 1) <= 16rFF ifTrue: [
		^result
			digitAt: 1 put: byte;
			normalize ].
	^result 
		digitAt: 1 put: 16rFF;
		- 1 "It's tempting to do the subtraction in a loop to avoid the LargeInteger creation, but it's actually slower than this."
]

{ #category : #'platform independent access' }
ByteArray >> longAt: index put: value bigEndian: bigEndian [
	"Store a 32-bit signed integer quantity starting from the given byte index"
	
	| v v2 |
	value isLarge ifTrue: [
		bigEndian ifFalse: [
			value positive ifTrue: [
				self 
					replaceFrom: index
					to: index + 3
					with: value
					startingAt: 1.
				^value ].
			v := 0.
			[ v <= 3 and: [ (v2 := ((value digitAt: v + 1) bitXor: 16rFF) + 1) = 16r100 ] ] whileTrue: [
				self at: index + v put: 0.
				v := v + 1 ].
			self at: index + v put: v2.
			v := v + 1.
			[ v <= 3 ] whileTrue: [
				self at: index + v put: ((value digitAt: (v := v + 1)) bitXor: 16rFF) ].
			^value ].
		value positive ifTrue: [
			self
				at: index put: (value digitAt: 4);
				at: index + 1 put: (value digitAt: 3);
				at: index + 2 put: (value digitAt: 2);
				at: index + 3 put: (value digitAt: 1).
			^value ].
		v := 3.
		[ 0 <= v and: [ (v2 := ((value digitAt: 4 - v) bitXor: 16rFF) + 1) = 16r100 ] ] whileTrue: [
			self at: index + v put: 0.
			v := v - 1 ].
		self at: index + v put: v2.
		[ 0 <= (v := v - 1) ] whileTrue: [
			self at: index + v put: ((value digitAt: 4 - v) bitXor: 16rFF) ].
		^value ].
	v := value bitShift: -24.
	0 <= (v := (v bitAnd: 16r7F) - (v bitAnd: 16r80)) ifFalse: [
		v := v + 16r100 ].
	bigEndian ifFalse: [
		self 
			at: index put: (value bitAnd: 16rFF);
			at: index + 1 put: ((value bitShift: -8) bitAnd: 16rFF);
			at: index + 2 put: ((value bitShift: -16) bitAnd: 16rFF);
			at: index + 3 put: v.
		^value ].
	self
		at: index put: v;
		at: index + 1 put: ((value bitShift: -16) bitAnd: 16rFF);
		at: index + 2 put: ((value bitShift: -8) bitAnd: 16rFF);
		at: index + 3 put: (value bitAnd: 16rFF).
	^value
]

{ #category : #enumerating }
ByteArray >> occurrencesOf: anObject [ 
	"Answer how many of the receiver's elements are equal to anObject. Optimized version."

	| tally |
	anObject isInteger ifFalse: [ ^0 ].
	anObject negative ifTrue: [ ^0 ].
	anObject > 255 ifTrue: [ ^0 ].
	tally := 0.
	1 to: self size do: [ :index |
		(self at: index) = anObject ifTrue: [ tally := tally + 1 ] ].
	^tally
]

{ #category : #printing }
ByteArray >> printAsLiteralOn: aStream [
	aStream nextPut: $#; nextPut: $[.
	self do: [:each| each storeOn: aStream]
		separatedBy: [aStream nextPut: $ ].
	aStream nextPut: $]
]

{ #category : #printing }
ByteArray >> printOn: aStream [
	self shouldBePrintedAsLiteral ifFalse:
		[super printOn: aStream.
		 aStream space].
	self printAsLiteralOn: aStream
]

{ #category : #streaming }
ByteArray >> putOn: aStream [

	aStream nextPutAll: self

]

{ #category : #initialize }
ByteArray >> readHexFrom: aStream [
	"Initialize the receiver from a hexadecimal string representation"
	
	1 to: self size do:
		[:i| | n v1 v2 |
		 n := aStream next asInteger.
		 v1 := n > 57						"$9 asInteger = 57"
				ifTrue:
					[n > 96					"$a asInteger 97"
						ifTrue: [n - 87]
						ifFalse: [n > 64		"$A asInteger = 65"
								ifTrue: [n - 55]
								ifFalse: [-1]]]	
			 	ifFalse: [n - 48].				"$0 asInteger = 48"
		 (v1 between: 0 and: 15) ifFalse: [^self error: 'Hex digit expected'].
		 n := aStream next asInteger.
		 v2 := n > 57						"$9 asInteger = 57"
				ifTrue:
					[n > 96					"$a asInteger 97"
						ifTrue: [n - 87]
						ifFalse: [n > 64		"$A asInteger = 65"
								ifTrue: [n - 55]
								ifFalse: [-1]]]
			 	ifFalse: [n - 48].				"$0 asInteger = 48"
		(v2 between: 0 and: 15) ifFalse: [^self error: 'Hex digit expected'].
		self at: i put: (v1 bitShift: 4) + v2]

	"Proof that our filter selects only hexadecimal characters:
	(0 to: 255)
		select:
			[:n|
			(n > 57
				ifTrue:
					[n > 96	
						ifTrue: [n - 87]
						ifFalse: [n > 64
								ifTrue: [n - 55]
								ifFalse: [-1]]]
			 	ifFalse: [n - 48]) between: 0 and: 15]
		thenCollect:
			[:n| Character value: n]"
]

{ #category : #private }
ByteArray >> replaceFrom: start to: stop with: replacement startingAt: repStart [ 
	"Primitive. This destructively replaces elements from start to stop in the receiver starting at index, repStart, in the collection, replacement. Answer the receiver. Range checks are performed in the primitive only. Optional. See Object documentation whatIsAPrimitive."
	<primitive: 105>
	replacement isString
		ifFalse:
			[super replaceFrom: start to: stop with: replacement startingAt: repStart]
		ifTrue:
			[ "use String>>byteAt: to mimic prim 105"
			| index repOff |
			repOff := repStart - start.
			index := start - 1.
			[(index := index + 1) <= stop]
				whileTrue: [self at: index put: (replacement byteAt: repOff + index)]]

]

{ #category : #'platform independent access' }
ByteArray >> shortAt: index bigEndian: bigEndian [
	"Return a 16-bit signed integer quantity starting from the given byte index"

	| result |
	result := bigEndian
		ifFalse: [ ((self at: index + 1) bitShift: 8) + (self at: index) ]
		ifTrue: [ ((self at: index) bitShift: 8) + (self at: index + 1) ].
	result < 16r8000 ifTrue: [ ^result ].
	^result - 16r10000
]

{ #category : #'platform independent access' }
ByteArray >> shortAt: index put: value bigEndian: bigEndian [
	"Store a 16-bit signed integer quantity starting from the given byte index"
	
	| unsignedValue |
	(unsignedValue := value) < 0 ifTrue: [
		unsignedValue := unsignedValue + 16r10000 ].
	bigEndian ifFalse: [
		self 
			at: index + 1 put: (unsignedValue bitShift: -8);
			at: index put: (unsignedValue bitAnd: 16rFF).
		^value ].
	self
		at: index put: (unsignedValue bitShift: -8);
		at: index + 1 put: (unsignedValue bitAnd: 16rFF).
	^value
]

{ #category : #'platform independent access' }
ByteArray >> signedByteAt: index [
	"Answer an 8-bit signed integer quantity from the given byte index."
	<primitive: 165>
	| byte |
	(byte := self at: index) <= 16r7F ifTrue: [ ^byte ].
	^byte - 16r100
]

{ #category : #'platform independent access' }
ByteArray >> signedByteAt: index put: anInteger [
	"Store an 8-bit signed integer quantity at the given byte index."
	<primitive: 166>
	anInteger >= 0 ifTrue: [ ^self at: index put: anInteger ].
	self at: index put: anInteger + 16r100.
	^anInteger
]

{ #category : #printing }
ByteArray >> storeOn: aStream [
	self shouldBePrintedAsLiteral
		ifTrue: [self printAsLiteralOn: aStream]
		ifFalse: [super storeOn: aStream]
]

{ #category : #'platform independent access' }
ByteArray >> unsignedLong64At: index bigEndian: bigEndian [
	"Return a 64-bit unsigned integer quantity starting from the given byte index. Use #normalize where necessary to ensure compatibility with non-30-bit SmallIntegers."

	| byte |
	SmallInteger maxVal >  1073741823 ifTrue:
		[bigEndian
			ifTrue: "64-bit SmallIntegers have a 3 bit tag and a sign bit, so the most positive value has 16rF as its top byte."
				[(byte := self at: index) <= 16rF ifTrue:
					[^((((((((byte bitShift: 8) + (self at: index + 1) bitShift: 8) + (self at: index + 2) bitShift: 8) + (self at: index + 3)) bitShift: 8)
						+ (self at: index + 4) bitShift: 8) + (self at: index + 5) bitShift: 8) + (self at: index + 6) bitShift: 8) + (self at: index + 7)]]
			ifFalse:
				[(byte := self at: index + 7) <= 16rF ifTrue:
					[^((((((((byte bitShift: 8) + (self at: index + 6) bitShift: 8) + (self at: index + 5) bitShift: 8) + (self at: index + 4)) bitShift: 8)
						+ (self at: index + 3) bitShift: 8) + (self at: index + 2) bitShift: 8) + (self at: index + 1) bitShift: 8) + (self at: index)]]].
	bigEndian ifFalse: [
		(byte := self at: index + 7) = 0 ifFalse: [
			^(LargePositiveInteger new: 8)
				replaceFrom: 1 to: 8 with: self startingAt: index;
				normalize ].
		(byte := self at: index + 6) = 0 ifFalse: [
			^(LargePositiveInteger new: 7)
				replaceFrom: 1 to: 7 with: self startingAt: index;
				normalize ].
		(byte := self at: index + 5) = 0 ifFalse: [
			^(LargePositiveInteger new: 6)
				replaceFrom: 1 to: 6 with: self startingAt: index;
				normalize ].
		(byte := self at: index + 4) = 0 ifFalse: [
			^(LargePositiveInteger new: 5)
				replaceFrom: 1 to: 5 with: self startingAt: index;
				normalize ].
		(byte := self at: index + 3) <= 16r3F ifFalse: [
			^(LargePositiveInteger new: 4)
				replaceFrom: 1 to: 4 with: self startingAt: index;
				normalize ].
		^(((byte bitShift: 8) + (self at: index + 2) bitShift: 8) + (self at: index + 1) bitShift: 8) + (self at: index) ].
	(byte := self at: index) = 0 ifFalse: [
		^(LargePositiveInteger new: 8)
			digitAt: 1 put: (self at: index + 7);
			digitAt: 2 put: (self at: index + 6);
			digitAt: 3 put: (self at: index + 5);
			digitAt: 4 put: (self at: index + 4);
			digitAt: 5 put: (self at: index + 3);
			digitAt: 6 put: (self at: index + 2);
			digitAt: 7 put: (self at: index + 1);
			digitAt: 8 put: byte;
			normalize ].
	(byte := self at: index + 1) = 0 ifFalse: [	
		^(LargePositiveInteger new: 7)
			digitAt: 1 put: (self at: index + 7);
			digitAt: 2 put: (self at: index + 6);
			digitAt: 3 put: (self at: index + 5);
			digitAt: 4 put: (self at: index + 4);
			digitAt: 5 put: (self at: index + 3);
			digitAt: 6 put: (self at: index + 2);
			digitAt: 7 put: byte;
			normalize ].
	(byte := self at: index + 2) = 0 ifFalse: [	
		^(LargePositiveInteger new: 6)
			digitAt: 1 put: (self at: index + 7);
			digitAt: 2 put: (self at: index + 6);
			digitAt: 3 put: (self at: index + 5);
			digitAt: 4 put: (self at: index + 4);
			digitAt: 5 put: (self at: index + 3);
			digitAt: 6 put: byte;
			normalize ].
	(byte := self at: index + 3) = 0 ifFalse: [	
		^(LargePositiveInteger new: 5)
			digitAt: 1 put: (self at: index + 7);
			digitAt: 2 put: (self at: index + 6);
			digitAt: 3 put: (self at: index + 5);
			digitAt: 4 put: (self at: index + 4);
			digitAt: 5 put: byte;
			normalize ].		
	(byte := self at: index + 4) <= 16r3F ifFalse: [
		^(LargePositiveInteger new: 4)
			digitAt: 1 put: (self at: index + 7);
			digitAt: 2 put: (self at: index + 6);
			digitAt: 3 put: (self at: index + 5);
			digitAt: 4 put: byte;
			normalize ].
	^(((byte bitShift: 8) + (self at: index + 5) bitShift: 8) + (self at: index + 6) bitShift: 8) + (self at: index + 7)
]

{ #category : #'platform independent access' }
ByteArray >> unsignedLong64At: index put: value bigEndian: bigEndian [
	"Store a 64-bit unsigned integer quantity starting from the given byte index"
	
	| i j |
	value isLarge ifTrue: [
		i := value digitLength.
		bigEndian ifFalse: [
			self
				replaceFrom: index
					to: index + i - 1
					with: value 
					startingAt: 1;
				replaceFrom: index + i
					to: index + 7
					with: #[0 0 0 0 0 0 0 0]
					startingAt: 1.
			^value ].
		j := index + 8.
		i <= 7 ifTrue: [
			self
				replaceFrom: index
				to: j - i - 1
				with: #[0 0 0 0 0 0 0 0]
				startingAt: 1 ].
		[ 1 <= i ] whileTrue: [
			self at: j - i put: (value digitAt: i).
			i := i - 1 ].
		^value ].
	bigEndian ifFalse: [
		j := index - 1.
		i := value.
		[ 1 <= i ] whileTrue: [
			self at: (j := j + 1) put: (i bitAnd: 16rFF).
			i := i bitShift: -8 ].
		self replaceFrom: j + 1
			to: index + 7
			with: #[0 0 0 0 0 0 0 0]
			startingAt: 1.
		^value ].
	j := index + 8.
	i := value.
	[ 1 <= i ] whileTrue: [
		self at: (j := j - 1) put: (i bitAnd: 16rFF).
		i := i bitShift: -8 ].
	self replaceFrom: index
		to: j - 1
		with: #[0 0 0 0 0 0 0 0]
		startingAt: 1.
	^value
]

{ #category : #'platform independent access' }
ByteArray >> unsignedLongAt: index bigEndian: bigEndian [
	"Return a 32-bit unsigned integer quantity starting from the given byte index. Use #normalize where necessary to ensure compatibility with non-30-bit SmallIntegers."
	| byte |
	bigEndian ifTrue:
		[((byte := self at: index) <= 16r3F
		 or: [SmallInteger maxVal >  1073741823]) ifTrue:
			[^(((byte bitShift: 8) + (self at: index + 1) bitShift: 8) + (self at: index + 2) bitShift: 8) + (self at: index + 3)].
		^(LargePositiveInteger new: 4)
			digitAt: 1 put: (self at: index + 3);
			digitAt: 2 put: (self at: index + 2);
			digitAt: 3 put: (self at: index + 1);
			digitAt: 4 put: byte;
			normalize].
	((byte := self at: index + 3) <= 16r3F
	 or: [SmallInteger maxVal >  1073741823]) ifTrue:
		[^(((byte bitShift: 8) + (self at: index + 2) bitShift: 8) + (self at: index + 1) bitShift: 8) + (self at: index)].
	^(LargePositiveInteger new: 4)
		replaceFrom: 1 to: 4 with: self startingAt: index;
		normalize
]

{ #category : #'platform independent access' }
ByteArray >> unsignedLongAt: index put: value bigEndian: bigEndian [
	"Store a 32-bit unsigned integer quantity starting from the given byte index"
	
	value isLarge
		ifTrue: [
			bigEndian ifFalse: [
				self
					replaceFrom: index
					to: index + 3
					with: value
					startingAt: 1.
				^value ].
			self
				at: index put: (value digitAt: 4);
				at: index + 1 put: (value digitAt: 3);
				at: index + 2 put: (value digitAt: 2);
				at: index +3 put: (value digitAt: 1) ]
		ifFalse: [
			bigEndian ifFalse: [
				self 
					at: index put: (value bitAnd: 16rFF);
					at: index + 1 put: ((value bitShift: -8) bitAnd: 16rFF);
					at: index + 2 put: ((value bitShift: -16) bitAnd: 16rFF);
					at: index + 3 put: (value bitShift: -24).
				^value ].
			self 
				at: index put: (value bitShift: -24);
				at: index + 1 put: ((value bitShift: -16) bitAnd: 16rFF);
				at: index + 2 put: ((value bitShift: -8) bitAnd: 16rFF);
				at: index + 3 put: (value bitAnd: 16rFF) ].
	^value
]

{ #category : #'platform independent access' }
ByteArray >> unsignedShortAt: index bigEndian: bigEndian [
	"Return a 16-bit unsigned integer quantity starting from the given byte index"

	bigEndian ifFalse: [ ^((self at: index + 1) bitShift: 8) + (self at: index) ].
	^((self at: index) bitShift: 8) + (self at: index + 1)
	
]

{ #category : #'platform independent access' }
ByteArray >> unsignedShortAt: index put: value bigEndian: bigEndian [
	"Store a 16-bit unsigned integer quantity starting from the given byte index"
	
	bigEndian ifFalse: [
		self 
			at: index + 1 put: (value bitShift: -8);
			at: index put: (value bitAnd: 16rFF).
		^value ].
	self
		at: index put: (value bitShift: -8);
		at: index+1 put: (value bitAnd: 16rFF).
	^value
]
