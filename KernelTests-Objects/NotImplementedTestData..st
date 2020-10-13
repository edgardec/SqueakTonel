Class {
	#name : #NotImplementedTestData,
	#superclass : #Object,
	#category : #'KernelTests-Objects'
}

{ #category : #accessing }
NotImplementedTestData >> shouldBeImplementedMsg [
	^ self shouldBeImplemented.
]

{ #category : #accessing }
NotImplementedTestData >> shouldNotImplementMsg [
	^ self shouldNotImplement.
]
