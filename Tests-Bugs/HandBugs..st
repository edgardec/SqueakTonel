Class {
	#name : #HandBugs,
	#superclass : #TestCase,
	#category : #'Tests-Bugs'
}

{ #category : #tests }
HandBugs >> testTargetPoint [
"self new testTargetPoint"
"self run: #testTargetPoint"

	"This should not throw an exception."
	self currentHand targetPoint


]
