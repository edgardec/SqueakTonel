Class {
	#name : #ObjectFinalizerTests,
	#superclass : #TestCase,
	#instVars : [
		'log'
	],
	#category : #'Tests-Finalization'
}

{ #category : #'finalization handling' }
ObjectFinalizerTests >> finalize: anObject [
	log addLast: anObject asString, ' ', 'finalized'.
]

{ #category : #running }
ObjectFinalizerTests >> setUp [
	super setUp.
	log := OrderedCollection new.
]

{ #category : #tests }
ObjectFinalizerTests >> testFinalization [
	"self run: #testFinalization"
	
	| repetitions |
	repetitions := 100.
	1 to: repetitions
		do: [:i | 
			log addLast: 'o' , i asString , ' created'.
			Object new
				toFinalizeSend: #finalize:
				to: self
				with: 'o' , i asString].
	Smalltalk garbageCollect.
	self finalizationRegistry finalizeValues.
	1 to: repetitions
		do: [:i | 
			self assert: (log includes: 'o' , i asString , ' created').
			self assert: (log includes: 'o' , i asString , ' finalized')]
]
