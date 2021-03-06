Class {
	#name : #ByteEncoderTest,
	#superclass : #TestCase,
	#category : #'MorphicExtrasTests-Postscript Filters'
}

{ #category : #testing }
ByteEncoderTest >> testIntegerByteEncoded [
	self assert: (ByteEncoder stream writeNumber: 2 base: 2; yourself) contents = '10'.
	self assert: (ByteEncoder stream writeNumber: 21 base: 3; yourself) contents = '210'.
	self assert: (ByteEncoder stream writeNumber: 228 base: 4; yourself) contents = '3210'.
	self assert: (ByteEncoder stream writeNumber: 2930 base: 5; yourself) contents = '43210'.
	self assert: (ByteEncoder stream writeNumber: 44790 base: 6; yourself) contents = '543210'.
	self assert: (ByteEncoder stream writeNumber: 800667 base: 7; yourself) contents = '6543210'.
	self assert: (ByteEncoder stream writeNumber: 16434824 base: 8; yourself) contents = '76543210'.
	self assert: (ByteEncoder stream writeNumber: 381367044 base: 9; yourself) contents = '876543210'.
	self assert: (ByteEncoder stream writeNumber: 9876543210 base: 10; yourself) contents = '9876543210'.
	self assert: (ByteEncoder stream writeNumber: 282458553905 base: 11; yourself) contents = 'A9876543210'.
	self assert: (ByteEncoder stream writeNumber: 8842413667692 base: 12; yourself) contents = 'BA9876543210'.
	self assert: (ByteEncoder stream writeNumber: 300771807240918 base: 13; yourself) contents = 'CBA9876543210'.
	self assert: (ByteEncoder stream writeNumber: 11046255305880158 base: 14; yourself) contents = 'DCBA9876543210'.
	self assert: (ByteEncoder stream writeNumber: 435659737878916215 base: 15; yourself) contents = 'EDCBA9876543210'.
	self assert: (ByteEncoder stream writeNumber: 18364758544493064720 base: 16; yourself) contents = 'FEDCBA9876543210'.

	self assert: (ByteEncoder stream writeNumber: -2 base: 2; yourself) contents = '-10'.
	self assert: (ByteEncoder stream writeNumber: -21 base: 3; yourself) contents = '-210'.
	self assert: (ByteEncoder stream writeNumber: -228 base: 4; yourself) contents = '-3210'.
	self assert: (ByteEncoder stream writeNumber: -2930 base: 5; yourself) contents = '-43210'.
	self assert: (ByteEncoder stream writeNumber: -44790 base: 6; yourself) contents = '-543210'.
	self assert: (ByteEncoder stream writeNumber: -800667 base: 7; yourself) contents = '-6543210'.
	self assert: (ByteEncoder stream writeNumber: -16434824 base: 8; yourself) contents = '-76543210'.
	self assert: (ByteEncoder stream writeNumber: -381367044 base: 9; yourself) contents = '-876543210'.
	self assert: (ByteEncoder stream writeNumber: -9876543210 base: 10; yourself) contents = '-9876543210'.
	self assert: (ByteEncoder stream writeNumber: -282458553905 base: 11; yourself) contents = '-A9876543210'.
	self assert: (ByteEncoder stream writeNumber: -8842413667692 base: 12; yourself) contents = '-BA9876543210'.
	self assert: (ByteEncoder stream writeNumber: -300771807240918 base: 13; yourself) contents = '-CBA9876543210'.
	self assert: (ByteEncoder stream writeNumber: -11046255305880158 base: 14; yourself) contents = '-DCBA9876543210'.
	self assert: (ByteEncoder stream writeNumber: -435659737878916215 base: 15; yourself) contents = '-EDCBA9876543210'.
	self assert: (ByteEncoder stream writeNumber: -18364758544493064720 base: 16; yourself) contents = '-FEDCBA9876543210'.
]
