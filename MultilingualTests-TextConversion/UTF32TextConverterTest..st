Class {
	#name : #UTF32TextConverterTest,
	#superclass : #UTFTextConverterWithByteOrderTest,
	#category : #'MultilingualTests-TextConversion'
}

{ #category : #constants }
UTF32TextConverterTest >> characterWidthInBytes [

	^ 4
]

{ #category : #constants }
UTF32TextConverterTest >> converterClass [

	^ UTF32TextConverter
]
