Class {
	#name : #BindingPolicy,
	#superclass : #Object,
	#instVars : [
		'policy',
		'environment',
		'addSelector',
		'removeSelector'
	],
	#category : #'Environments-Policies'
}

{ #category : #'instance creation' }
BindingPolicy class >> environment: anEnvironment policy: aNamePolicy addSelector: addSelector removeSelector: removeSelector [
	^ self basicNew 
		initializeWithEnvironment: anEnvironment 
		policy: aNamePolicy 
		addSelector: addSelector
		removeSelector: removeSelector
]

{ #category : #events }
BindingPolicy >> binding: aBinding addedTo: anEnvironment notify: anObject [
	environment == anEnvironment ifTrue: 
		[policy name: aBinding key do:
			[:name || binding |
			binding := aBinding asBinding: name.
			anObject perform: addSelector with: binding]].

]

{ #category : #events }
BindingPolicy >> binding: aBinding removedFrom: anEnvironment notify: anObject [
	environment == anEnvironment ifTrue: 
		[policy name: aBinding key do:
			[:name || binding |
			binding := aBinding asBinding: name.
			anObject perform: removeSelector with: binding]].

]

{ #category : #accessing }
BindingPolicy >> environment [
	^ environment
]

{ #category : #'initialize-release' }
BindingPolicy >> initializeWithEnvironment: anEnvironment 
policy: aNamePolicy 
addSelector: aSelector 
removeSelector: rSelector [
	self initialize.
	environment := anEnvironment.
	policy := aNamePolicy.
	addSelector := aSelector.
	removeSelector := rSelector
]

{ #category : #private }
BindingPolicy >> name: aSymbol do: aBlock [
	^ policy name: aSymbol do: aBlock
]

{ #category : #'initialize-release' }
BindingPolicy >> removeObserver: anEnvironment [
	environment removeObserver: anEnvironment 
]
