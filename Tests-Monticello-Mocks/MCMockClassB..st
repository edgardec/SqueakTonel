"
This comment has a bang! Bang! Bang!
"
Class {
	#name : #MCMockClassB,
	#superclass : #MCMock,
	#instVars : [
		'ivarb'
	],
	#classVars : [
		'CVar'
	],
	#pools : [
		'MCMockAPoolDictionary'
	],
	#classInstVars : [
		'ciVar'
	],
	#category : #'Tests-Monticello-Mocks'
}

{ #category : #numeric }
MCMockClassB >> two [

	^ 2
]
