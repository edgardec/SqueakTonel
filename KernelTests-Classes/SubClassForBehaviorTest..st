Class {
	#name : #SubClassForBehaviorTest,
	#superclass : #ClassForBehaviorTest,
	#instVars : [
		'iv3'
	],
	#classVars : [
		'CV3'
	],
	#category : #'KernelTests-Classes'
}

{ #category : #accessing }
SubClassForBehaviorTest class >> install [
	civ1 := true
]

{ #category : #accessing }
SubClassForBehaviorTest >> iv2: anyObject [
	iv2 := anyObject printString
]

{ #category : #accessing }
SubClassForBehaviorTest >> resetIV1 [
	iv1 := nil
]
