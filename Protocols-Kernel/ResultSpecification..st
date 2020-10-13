Class {
	#name : #ResultSpecification,
	#superclass : #ObjectWithDocumentation,
	#instVars : [
		'type',
		'companionSetterSelector',
		'refetchFrequency'
	],
	#category : #'Protocols-Kernel'
}

{ #category : #'companion setter' }
ResultSpecification >> companionSetterSelector [
	"Answer the companion setter, nil if none"

	^ companionSetterSelector
]

{ #category : #'companion setter' }
ResultSpecification >> companionSetterSelector: aSetterSelector [
	"Set the receiver's companionSetterSelector as indicated"

	companionSetterSelector := aSetterSelector
]

{ #category : #refetch }
ResultSpecification >> refetchFrequency [
	"Answer the frequency with which the receiver should be refetched by a readout polling values from it, as in a Viewer.  Answer nil if not ever to be refetched automatically"

	^ refetchFrequency
]

{ #category : #refetch }
ResultSpecification >> refetchFrequency: aFrequency [
	"Set the refetch frequency"

	refetchFrequency := aFrequency
]

{ #category : #'result type' }
ResultSpecification >> resultType [
	"Answer the reciever's result type"

	^ type
]

{ #category : #'result type' }
ResultSpecification >> resultType: aType [
	"Set the receiver's resultType as specified"

	type := aType
]

{ #category : #'result type' }
ResultSpecification >> type [
	"Answer the reciever's type"

	^ type
]
