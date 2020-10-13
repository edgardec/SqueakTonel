Class {
	#name : #AllNamePolicyTest,
	#superclass : #NamePolicyTest,
	#category : #'Tests-Environments'
}

{ #category : #running }
AllNamePolicyTest >> createPolicy [
	^ AllNamePolicy new
]

{ #category : #tests }
AllNamePolicyTest >> testPassesName [
	self assertIncludes: #Griffle 
]
