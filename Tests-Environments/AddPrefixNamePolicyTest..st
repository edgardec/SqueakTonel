Class {
	#name : #AddPrefixNamePolicyTest,
	#superclass : #NamePolicyTest,
	#category : #'Tests-Environments'
}

{ #category : #running }
AddPrefixNamePolicyTest >> createPolicy [
	^ AddPrefixNamePolicy prefix: 'XX'
]

{ #category : #tests }
AddPrefixNamePolicyTest >> testAddsPrefix [
	self assertIncludes: #Griffle as: #XXGriffle.
	
]

{ #category : #tests }
AddPrefixNamePolicyTest >> testDoesntDuplicatePrefix [
	self denyIncludes: #XXGriffle
]
