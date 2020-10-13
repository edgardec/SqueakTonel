Class {
	#name : #ByteArrayTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Arrayed'
}

{ #category : #'tests - platform independent access' }
ByteArrayTest >> byteArrayFor: signedValue bits: bits bigEndian: bigEndian [

	| unsignedValue size result |
	unsignedValue := signedValue negative
		ifTrue: [ signedValue + (1 bitShift: bits) ]
		ifFalse: [ signedValue ].
	size := bits // 8.
	result := ByteArray new: size.
	1 to: size do: [ :index |
		result at: index put: (unsignedValue digitAt: index) ].
	bigEndian ifTrue: [ result reverseInPlace ].
	^result
	
]

{ #category : #tests }
ByteArrayTest >> testEmpty [

	self
		assert: 0
		equals: ByteArray empty size
		description: 'The empty ByteArray should be empty indeed';
		
		assert: ByteArray
		equals: ByteArray empty species 
		description: 'The empty ByteArray should be a ByteArray';
		
		assert: ByteArray empty
		identical: ByteArray empty 
		description: 'The empty ByteArray should be canonical';
		
		yourself
		
		

]

{ #category : #tests }
ByteArrayTest >> testFallbackReplaceFromToWith [
	| teststring ba sz cm |
	teststring := 'Test string' asByteArray.
	sz := teststring byteSize.
	ba := ByteArray new: sz.
	cm := SequenceableCollection compiledMethodAt: #replaceFrom:to:with:startingAt:.
	self shouldnt: [cm valueWithReceiver: ba arguments: {1. sz. teststring. 1}]
		raise: Exception
		description: 'Primitive 105 should be optional for ByteArray'

]

{ #category : #'tests - hex' }
ByteArrayTest >> testHex [
	self assert: #[122 43 213 7] hex = '7a2bd507'.
	self assert: (UUID fromString: '97c1f2dd-f920-9948-b329-319a30c16386') hex
					= '97c1f2ddf9209948b329319a30c16386'.
]

{ #category : #'tests - hex' }
ByteArrayTest >> testIsLiteral [
	self assert: #[122 43 213 7] isLiteral description: 'ByteArray instances are literal'.
	self deny: thisContext method isLiteral description: 'ByteArray sub instances are not literal'
]

{ #category : #'tests - platform independent access' }
ByteArrayTest >> testPlatformIndependentIntegerAccessorsAtBitBorders [

	#(
		shortAt:put:bigEndian: shortAt:bigEndian: false 16
		longAt:put:bigEndian: longAt:bigEndian: false 32
		long64At:put:bigEndian: long64At:bigEndian: false 64
		unsignedShortAt:put:bigEndian: unsignedShortAt:bigEndian: true 16
		unsignedLongAt:put:bigEndian: unsignedLongAt:bigEndian: true 32
		unsignedLong64At:put:bigEndian: unsignedLong64At:bigEndian: true 64		
	) groupsDo: [ :setter :getter :unsigned :storageBits |
		self
			verifyPlatformIndependentIntegerAccessorsAtBitBordersSetter: setter
			getter: getter
			unsigned: unsigned
			storageBits: storageBits ]
]

{ #category : #'tests - platform independent access' }
ByteArrayTest >> testPlatformIndependentIntegerAccessorsWithRandomValues [

	| random |
	random := Random seed: 36rSqueak.
	#(
		shortAt:put:bigEndian: shortAt:bigEndian: false 16
		longAt:put:bigEndian: longAt:bigEndian: false 32
		long64At:put:bigEndian: long64At:bigEndian: false 64
		unsignedShortAt:put:bigEndian: unsignedShortAt:bigEndian: true 16
		unsignedLongAt:put:bigEndian: unsignedLongAt:bigEndian: true 32
		unsignedLong64At:put:bigEndian: unsignedLong64At:bigEndian: true 64		
	) groupsDo: [ :setter :getter :unsigned :storageBits |
		self
			verifyPlatformIndependentIntegerAccessorsWithRandomValuesSetter: setter
			getter: getter
			unsigned: unsigned
			storageBits: storageBits
			random: random ]
]

{ #category : #'tests - hex' }
ByteArrayTest >> testReadHexFrom [
	self assert: (ByteArray readHexFrom: '7a2bd507') = #[122 43 213 7].
	self assert: (UUID readHexFrom: '97c1f2ddf9209948b329319a30c16386')
					= (UUID fromString: '97c1f2dd-f920-9948-b329-319a30c16386').
]

{ #category : #'tests - platform independent access' }
ByteArrayTest >> verifyPlatformIndependentIntegerAccessorsAtBitBordersSetter: setter getter: getter unsigned: unsigned storageBits: storageBits [

	| byteArray minValue maxValue baseValues |
	byteArray := ByteArray new: storageBits // 8 * 2.
	unsigned
		ifTrue: [
			minValue := 0.
			maxValue := 1 << storageBits - 1.
			baseValues := #(0 1) ]
		ifFalse: [
			minValue := -1 << (storageBits - 1).
			maxValue := 1 << (storageBits - 1) - 1.
			baseValues := #(-1 0 1) ].
	#(true false) do: [ :bigEndian |
		0 to: storageBits - 1 do: [ :bits |
			baseValues do: [ :baseValue |
				| centerValue |
				centerValue := baseValue << bits.
				centerValue - 1 to: centerValue + 1 do: [ :value |
					(value between: minValue and: maxValue) ifTrue: [
						self
							verifyPlatformIndependentIntegerAccessorsMatch: byteArray
							for: value
							setter: setter
							getter: getter
							storageBits: storageBits
							bigEndian: bigEndian  ] ] ] ] ]
					
]

{ #category : #'tests - platform independent access' }
ByteArrayTest >> verifyPlatformIndependentIntegerAccessorsMatch: byteArray for: value setter: setter getter: getter storageBits: storageBits bigEndian: bigEndian [
	
	| expectedSetterResult getterResult bytes |
	expectedSetterResult := self byteArrayFor: value bits: storageBits bigEndian: bigEndian.
	bytes := storageBits // 8.
	1 to: byteArray size - bytes + 1 do: [ :index |
		byteArray
			perform: setter
			with: index
			with: value
			with: bigEndian.
		1 to: bytes do: [ :byteIndex |
			self
				assert: (expectedSetterResult at: byteIndex)
				equals: (byteArray at: index + byteIndex - 1) ].
		getterResult := byteArray
			perform: getter
			with: index
			with: bigEndian.
		self assert: value equals: getterResult ]
]

{ #category : #'tests - platform independent access' }
ByteArrayTest >> verifyPlatformIndependentIntegerAccessorsWithRandomValuesSetter: setter getter: getter unsigned: unsigned storageBits: storageBits random: random [

	| byteArray randomMax randomOffset |
	byteArray := ByteArray new: storageBits // 8 * 2.
	randomMax := 1 << storageBits.
	randomOffset := unsigned
		ifTrue: [ -1 ]
		ifFalse: [ -1 << (storageBits - 1) - 1 ].
	10000 timesRepeat: [
		| value |
		value := (random nextInt: randomMax) + randomOffset.
		#(true false) do: [ :bigEndian |
			self
				verifyPlatformIndependentIntegerAccessorsMatch: byteArray
				for: value
				setter: setter
				getter: getter
				storageBits: storageBits
				bigEndian: bigEndian ] ]
]
