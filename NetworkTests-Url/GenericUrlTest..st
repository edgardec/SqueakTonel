Class {
	#name : #GenericUrlTest,
	#superclass : #ClassTestCase,
	#category : #'NetworkTests-Url'
}

{ #category : #tests }
GenericUrlTest >> testAsString [
	| url |
	url := GenericUrl new schemeName: 'sip' locator: 'foo@bar'.
	self assert: url asString = 'sip:foo@bar'.
]
