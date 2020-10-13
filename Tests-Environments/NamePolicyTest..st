Class {
	#name : #NamePolicyTest,
	#superclass : #TestCase,
	#instVars : [
		'policy'
	],
	#category : #'Tests-Environments'
}

{ #category : #testing }
NamePolicyTest class >> isAbstract [
	^ self name = #NamePolicyTest
]

{ #category : #asserting }
NamePolicyTest >> assertIncludes: foreignName [ 
	^ self assertIncludes: foreignName as: foreignName
]

{ #category : #asserting }
NamePolicyTest >> assertIncludes: localName as: foreignName [
	| actual |
	policy name: localName do: [:foreign | actual := foreign].
	self assert: actual = foreignName
]

{ #category : #asserting }
NamePolicyTest >> denyIncludes: localName [ 
	| actual |
	policy name: localName do: [:foreign | actual := foreign].
	self assert: actual isNil
]

{ #category : #running }
NamePolicyTest >> setUp [
	policy := self createPolicy
]
