Class {
	#name : #WebCamOrientation,
	#superclass : #SymbolListType,
	#category : #'Etoys-Squeakland-MorphicExtras-WebCam'
}

{ #category : #'as yet unclassified' }
WebCamOrientation class >> initialize [
	Vocabulary initialize.
]

{ #category : #'as yet unclassified' }
WebCamOrientation class >> orientations [
	^ #( native natural )
]

{ #category : #'as yet unclassified' }
WebCamOrientation >> initialize [
	super initialize.
	self vocabularyName: #WebCamOrientation.
	
	self symbols: self class orientations.
]

{ #category : #'as yet unclassified' }
WebCamOrientation >> representsAType [
	^true
]
