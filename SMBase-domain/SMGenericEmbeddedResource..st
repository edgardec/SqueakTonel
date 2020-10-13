"
A generic embedded resource is simply some kind of object, held in instvar #contents, that is stored inside the map. No download is needed.
Embedded resources should be ""small"" and typically only be used for resources that
are needed to be available at all times without downloading. A typical example is meta data for other SMObjects.


"
Class {
	#name : #SMGenericEmbeddedResource,
	#superclass : #SMEmbeddedResource,
	#instVars : [
		'contents'
	],
	#category : #'SMBase-domain'
}

{ #category : #'as yet unclassified' }
SMGenericEmbeddedResource >> contents [
	"Answers the contents object."

	^contents
]

{ #category : #'as yet unclassified' }
SMGenericEmbeddedResource >> contents: obj [
	"Sets the actual contents of this resource.
	SM does not know what it is."
	
	contents := obj
]
