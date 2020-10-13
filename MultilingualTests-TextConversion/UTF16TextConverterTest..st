Class {
	#name : #UTF16TextConverterTest,
	#superclass : #UTFTextConverterWithByteOrderTest,
	#category : #'MultilingualTests-TextConversion'
}

{ #category : #constants }
UTF16TextConverterTest >> characterWidthInBytes [
	"Only true for the test case. Beware of changing the unicode string"

	^ 2
]

{ #category : #constants }
UTF16TextConverterTest >> converterClass [

	^ UTF16TextConverter
]
