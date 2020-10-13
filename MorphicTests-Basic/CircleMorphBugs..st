Class {
	#name : #CircleMorphBugs,
	#superclass : #TestCase,
	#category : #'MorphicTests-Basic'
}

{ #category : #tests }
CircleMorphBugs >> testCircleInstance [
""
"self run: #testCircleInstance" 

| circ |
self assert: (circ := CircleMorph initializedInstance) extent = circ extent x asPoint


]
