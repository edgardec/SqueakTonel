Class {
	#name : #RemovePrefixNamePolicyTest,
	#superclass : #NamePolicyTest,
	#category : #'Tests-Environments'
}

{ #category : #running }
RemovePrefixNamePolicyTest >> createPolicy [
	^ RemovePrefixNamePolicy prefix: 'XX'
]

{ #category : #tests }
RemovePrefixNamePolicyTest >> testOnlyRemovesPrefix [
	self denyIncludes: #XAGriffle
]

{ #category : #tests }
RemovePrefixNamePolicyTest >> testRemovesPrefix [
	self assertIncludes: #XXGriffle as: #Griffle
]
