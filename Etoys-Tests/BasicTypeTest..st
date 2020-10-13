Class {
	#name : #BasicTypeTest,
	#superclass : #TestCase,
	#category : #'Etoys-Tests'
}

{ #category : #tests }
BasicTypeTest >> testBasicType [
	
	self assert: (true basicType = #Boolean).
	self assert: (false basicType = #Boolean).
]
