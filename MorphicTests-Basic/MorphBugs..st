Class {
	#name : #MorphBugs,
	#superclass : #MorphTest,
	#category : #'MorphicTests-Basic'
}

{ #category : #tests }
MorphBugs >> testAdhereToEdgeEternity [

	| r |
	r := RectangleMorph new openInWorld: self getWorld.

	self
		shouldnt: [ r adhereToEdge: #eternity ]
		raise: Exception.
]
