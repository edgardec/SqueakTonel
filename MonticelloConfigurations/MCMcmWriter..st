"
An MCMcmWriter stores an MCConfiguration on a stream in the form of an array specification.

"
Class {
	#name : #MCMcmWriter,
	#superclass : #MCWriter,
	#category : #MonticelloConfigurations
}

{ #category : #writing }
MCMcmWriter class >> fileOut: aConfiguration on: aStream [
	| inst |
	inst := self on: aStream.
	inst writeConfiguration: aConfiguration.
	inst close.
	

]

{ #category : #accessing }
MCMcmWriter class >> readerClass [
	^ MCMcmReader
]

{ #category : #writing }
MCMcmWriter >> close [
	stream close
]

{ #category : #writing }
MCMcmWriter >> writeConfiguration: aConfiguration [
	aConfiguration fileOutOn: stream.

]
