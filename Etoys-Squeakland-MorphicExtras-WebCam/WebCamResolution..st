Class {
	#name : #WebCamResolution,
	#superclass : #SymbolListType,
	#category : #'Etoys-Squeakland-MorphicExtras-WebCam'
}

{ #category : #'as yet unclassified' }
WebCamResolution class >> initialize [
	Vocabulary initialize.
]

{ #category : #'as yet unclassified' }
WebCamResolution class >> resolutions [
	^ #(#'low' #'medium' #'high' #'hd')

]

{ #category : #'as yet unclassified' }
WebCamResolution >> initialize [
	super initialize.
	self vocabularyName: #WebCamResolution.
	
	self symbols: self class resolutions

]

{ #category : #'as yet unclassified' }
WebCamResolution >> representsAType [
	^true
]
