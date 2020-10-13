Class {
	#name : #SystemWindowTest,
	#superclass : #TestCase,
	#instVars : [
		'sut'
	],
	#category : #'MorphicTests-Widgets'
}

{ #category : #'as yet unclassified' }
SystemWindowTest >> setUp [

	super setUp.
	sut := SystemWindow new.
]

{ #category : #'as yet unclassified' }
SystemWindowTest >> test01Culling [
	"Check whether system windows follow the specs for occlusion culling. See WorldState >> #drawWorld:submorphs:invalidAreasOn: and Morph >> #areasRemainingToFill:."
	
	sut extent: 500@500; fullBounds.
	sut cornerStyle: #square.
	
	self assert: (sut areasRemainingToFill: (20@20 center: sut center)) isEmpty.
	self assert: (sut areasRemainingToFill: sut bounds) isEmpty.
	self assert: (sut areasRemainingToFill: sut outerBounds) isEmpty.
	self assert: (sut areasRemainingToFill: sut fullBounds) isEmpty.
]
