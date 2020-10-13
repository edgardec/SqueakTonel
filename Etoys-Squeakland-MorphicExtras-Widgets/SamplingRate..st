Class {
	#name : #SamplingRate,
	#superclass : #SymbolListType,
	#category : #'Etoys-Squeakland-MorphicExtras-Widgets'
}

{ #category : #'as yet unclassified' }
SamplingRate >> initialize [
	"Vocabulary initialize"
	super initialize.
	self vocabularyName: #SamplingRate.
	symbols := #('11025' '22050' '44100')
	

]

{ #category : #'as yet unclassified' }
SamplingRate >> representsAType [
	^true
]
