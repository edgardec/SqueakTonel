Class {
	#name : #NoConverterFound,
	#superclass : #Error,
	#instVars : [
		'encoding'
	],
	#category : #'Multilingual-TextConversion'
}

{ #category : #exceptionInstantiator }
NoConverterFound class >> signalFor: encodingName [

	self new
		encoding: encodingName;
		signal
]

{ #category : #accessing }
NoConverterFound >> encoding [

	^ encoding
]

{ #category : #accessing }
NoConverterFound >> encoding: anObject [

	encoding := anObject
]
