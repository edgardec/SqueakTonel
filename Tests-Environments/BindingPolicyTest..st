Class {
	#name : #BindingPolicyTest,
	#superclass : #TestCase,
	#instVars : [
		'environment',
		'policy',
		'value',
		'notified',
		'notifiedBinding'
	],
	#category : #'Tests-Environments'
}

{ #category : #emulating }
BindingPolicyTest >> addBinding: aBinding [
	notified := #add.
	notifiedBinding := aBinding
]

{ #category : #tests }
BindingPolicyTest >> bindingPolicyWithNamePolicy: aPolicy [
	^ BindingPolicy
		environment: environment
		policy: aPolicy
		addSelector: #addBinding:
		removeSelector: #removeBinding:
]

{ #category : #emulating }
BindingPolicyTest >> removeBinding: aBinding [
	notified := #remove.
	notifiedBinding := aBinding
]

{ #category : #running }
BindingPolicyTest >> setUp [
	environment := Environment withName: #test.
	value := Object new
]

{ #category : #running }
BindingPolicyTest >> tearDown [
	environment destroy.
	environment := nil.
	value := nil.
]

{ #category : #tests }
BindingPolicyTest >> testAddHonorsEnvironment [
	| binding other |
	other := Environment withName: #other.
	policy := self bindingPolicyWithNamePolicy: AllNamePolicy new.
	binding := #Griffle => value.
	policy binding: binding addedTo: other notify: self.
	self assert: notified = nil
]

{ #category : #tests }
BindingPolicyTest >> testAddHonorsName [
	| binding |
	policy := self bindingPolicyWithNamePolicy: (ExplicitNamePolicy spec: #Griffle -> #Nurp).
	binding := #Griffle => value.
	policy binding: binding addedTo: environment notify: self.
	self assert: notified == #add
]

{ #category : #tests }
BindingPolicyTest >> testAddHonorsPolicy [
	| binding |
	policy := self bindingPolicyWithNamePolicy: (ExplicitNamePolicy spec: #Nurp).
	binding := #Griffle => value.
	policy binding: binding addedTo: environment notify: self.
	self assert: notified = nil
]

{ #category : #tests }
BindingPolicyTest >> testAdded [
	| binding |
	policy := self bindingPolicyWithNamePolicy: AllNamePolicy new.
	binding := #Griffle => value.
	policy binding: binding addedTo: environment notify: self.
	self assert: notified = #add.
]

{ #category : #tests }
BindingPolicyTest >> testRemoveHonorsEnvironment [
	| binding other |
	other := Environment withName: #other.
	policy := self bindingPolicyWithNamePolicy: AllNamePolicy new.
	binding := #Griffle => value.
	policy binding: binding removedFrom: other notify: self. 
	self assert: notified = nil
]

{ #category : #tests }
BindingPolicyTest >> testRemoveHonorsName [
	| binding |
	policy := self bindingPolicyWithNamePolicy: (ExplicitNamePolicy spec: #Griffle -> #Nurp).
	binding := #Griffle => value.
	policy binding: binding removedFrom: environment notify: self.
	self assert: notified = #remove.
	self assert: notifiedBinding key = #Nurp.
	self assert: notifiedBinding source == binding
]

{ #category : #tests }
BindingPolicyTest >> testRemoveHonorsPolicy [
	| binding |
	policy := self bindingPolicyWithNamePolicy: (ExplicitNamePolicy spec: #Nurp).
	binding := #Griffle => value.
	policy binding: binding removedFrom: environment notify: self.
	self assert: notified = nil
]

{ #category : #tests }
BindingPolicyTest >> testRemoved [
	| binding |
	policy := self bindingPolicyWithNamePolicy: AllNamePolicy new.
	binding := #Griffle => value.
	policy binding: binding removedFrom: environment notify: self.
	self assert: notified = #remove
]
