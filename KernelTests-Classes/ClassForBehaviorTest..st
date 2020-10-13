Class {
	#name : #ClassForBehaviorTest,
	#superclass : #Object,
	#instVars : [
		'iv1',
		'iv2'
	],
	#classVars : [
		'CV1',
		'CV2'
	],
	#classInstVars : [
		'civ1'
	],
	#category : #'KernelTests-Classes'
}

{ #category : #accessing }
ClassForBehaviorTest class >> civ1 [
	^civ1 ifNil: [civ1 := false]
]

{ #category : #'class initialization' }
ClassForBehaviorTest class >> initialize [
	CV1 := 1.
	CV2 := 2
]

{ #category : #accessing }
ClassForBehaviorTest >> initialize [
	iv1 := CV1 ifNil: [CV1 := 1]
]

{ #category : #accessing }
ClassForBehaviorTest >> iv1 [
	^iv1
]

{ #category : #accessing }
ClassForBehaviorTest >> iv1: anyObject [
	iv1 := anyObject
]

{ #category : #accessing }
ClassForBehaviorTest >> iv2 [
	^iv2
]

{ #category : #accessing }
ClassForBehaviorTest >> iv2: anyObject [
	iv2 := anyObject
]

{ #category : #accessing }
ClassForBehaviorTest >> reset [
	iv1 := iv2 := nil
]
