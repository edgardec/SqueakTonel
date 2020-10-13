"
TestDynamicVariable is a test class using in ProcessSpecificTest.


"
Class {
	#name : #TestDynamicVariable,
	#superclass : #DynamicVariable,
	#classInstVars : [
		'defaultValue'
	],
	#category : #'KernelTests-Processes'
}

{ #category : #accessing }
TestDynamicVariable class >> default [

	^ defaultValue
]

{ #category : #accessing }
TestDynamicVariable class >> default: anObject [

	defaultValue := anObject.
]
