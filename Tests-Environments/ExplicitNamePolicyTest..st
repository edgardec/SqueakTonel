Class {
	#name : #ExplicitNamePolicyTest,
	#superclass : #NamePolicyTest,
	#category : #'Tests-Environments'
}

{ #category : #running }
ExplicitNamePolicyTest >> createPolicy [
	^ ExplicitNamePolicy spec: #Griffle -> #Plonk
]

{ #category : #tests }
ExplicitNamePolicyTest >> testAssociationSpec [
	policy := ExplicitNamePolicy spec: #Griffle -> #Plonk.
	self assertIncludes: #Griffle as: #Plonk
]

{ #category : #tests }
ExplicitNamePolicyTest >> testDictionarySpec [
	| aliases |
	aliases := IdentityDictionary new
		at: #Griffle put: #Plonk;
		yourself.
	policy := ExplicitNamePolicy spec: aliases.
	self assertIncludes: #Griffle as: #Plonk
]

{ #category : #tests }
ExplicitNamePolicyTest >> testDoesntIncludeOriginal [
	self denyIncludes: #Plonk 
]

{ #category : #tests }
ExplicitNamePolicyTest >> testDoesntIncludeOther [
	self denyIncludes: #Nurp 
]

{ #category : #tests }
ExplicitNamePolicyTest >> testMixedSpec [
	policy := ExplicitNamePolicy spec: {#Nurp. #Griffle->#Plonk. #(Ziffy)}.
	self assertIncludes: #Griffle as: #Plonk.
	self assertIncludes: #Nurp.
	self assertIncludes: #Ziffy.
]

{ #category : #tests }
ExplicitNamePolicyTest >> testPolicySpec [
	| again |
	policy := ExplicitNamePolicy spec: #Griffle.
	again := ExplicitNamePolicy spec: policy.
	self assert: policy == again
]

{ #category : #tests }
ExplicitNamePolicyTest >> testSymbolSpec [
	policy := ExplicitNamePolicy spec: #Griffle.
	self assertIncludes: #Griffle
]

{ #category : #tests }
ExplicitNamePolicyTest >> testTransformsName [
	self assertIncludes: #Griffle as: #Plonk.
]
