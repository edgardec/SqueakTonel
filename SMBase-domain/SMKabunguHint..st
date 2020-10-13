Class {
	#name : #SMKabunguHint,
	#superclass : #SMGenericEmbeddedResource,
	#instVars : [
		'type'
	],
	#category : #'SMBase-domain'
}

{ #category : #'as yet unclassified' }
SMKabunguHint >> account [
	
	^ self owner
]

{ #category : #'as yet unclassified' }
SMKabunguHint >> type [

	^ type
]

{ #category : #'as yet unclassified' }
SMKabunguHint >> type: t [

	type := t
]
