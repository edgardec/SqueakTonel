Class {
	#name : #UTFTextConverterWithByteOrderTest,
	#superclass : #TestCase,
	#category : #'MultilingualTests-TextConversion'
}

{ #category : #testing }
UTFTextConverterWithByteOrderTest class >> isAbstract [

	^ self = UTFTextConverterWithByteOrderTest
]

{ #category : #constants }
UTFTextConverterWithByteOrderTest >> characterWidthInBytes [

	self subclassResponsibility
]

{ #category : #constants }
UTFTextConverterWithByteOrderTest >> converterClass [

	self subclassResponsibility
]

{ #category : #tests }
UTFTextConverterWithByteOrderTest >> testByteOrders [
	|converter originalText bytes decodedText |
	originalText := 'test'.
	converter := self converterClass new.
	
	"Default (ie useLittleEndian instvar nil)"
	bytes := (originalText convertToWithConverter: converter).
	decodedText := bytes convertFromWithConverter: converter.
	
	self assert: originalText equals: decodedText.
	
	"Little-endian"
	converter useLittleEndian: true.

	bytes := (originalText convertToWithConverter: converter).
	decodedText := bytes convertFromWithConverter: converter.
	
	self assert: originalText equals: decodedText.
	
	"Big-endian"
	converter useLittleEndian: false.

	bytes := (originalText convertToWithConverter: converter).
	decodedText := bytes convertFromWithConverter: converter.
	
	self assert: originalText equals: decodedText.
	
	
]

{ #category : #tests }
UTFTextConverterWithByteOrderTest >> testByteOrdersMarks [
	|converter originalText bytes decodedText |
	originalText := self unicodeString.
	converter := self converterClass new.
	
	converter useByteOrderMark: true.
	bytes := (originalText convertToWithConverter: converter).
	self assert: (self characterWidthInBytes * (self unicodeString size + 1)) equals: bytes size. 
	decodedText := bytes convertFromWithConverter: converter.
	
	self assert: originalText equals: decodedText.
	
]

{ #category : #tests }
UTFTextConverterWithByteOrderTest >> testByteOrdersWithNonLatin [
	|converter originalText bytes decodedText |
	originalText := self unicodeString.
	converter := self converterClass new.
	
	"Default (ie useLittleEndian instvar nil)"
	bytes := (originalText convertToWithConverter: converter).
	decodedText := bytes convertFromWithConverter: converter.
	
	self assert: originalText equals: decodedText.
	
	"Little-endian"
	converter useLittleEndian: true.

	bytes := (originalText convertToWithConverter: converter).
	decodedText := bytes convertFromWithConverter: converter.
	
	self assert: originalText equals: decodedText.
	
	"Big-endian"
	converter useLittleEndian: false.

	bytes := (originalText convertToWithConverter: converter).
	decodedText := bytes convertFromWithConverter: converter.
	
	self assert: originalText equals: decodedText.
	
	
]

{ #category : #fixtures }
UTFTextConverterWithByteOrderTest >> unicodeString [

	^ String newFrom: (#(19335 12403) collect: [:n | Character codePoint: n])
]
