Class {
	#name : #TestCoverage,
	#superclass : #ProtoObject,
	#instVars : [
		'hasRun',
		'reference',
		'method'
	],
	#category : #SUnitGUI
}

{ #category : #'instance creation' }
TestCoverage class >> on: aMethodReference [
	^ self new initializeOn: aMethodReference
]

{ #category : #private }
TestCoverage >> doesNotUnderstand: aMessage [
	^ method perform: aMessage selector withArguments: aMessage arguments
]

{ #category : #private }
TestCoverage >> flushCache [
]

{ #category : #testing }
TestCoverage >> hasRun [
	^ hasRun
]

{ #category : #initialization }
TestCoverage >> initializeOn: aMethodReference [
	hasRun := false.
	reference := aMethodReference.
	method := reference compiledMethod
]

{ #category : #actions }
TestCoverage >> install [
	reference actualClass methodDictionary
		at: reference methodSymbol
		put: self
]

{ #category : #private }
TestCoverage >> mark [
	hasRun := true
]

{ #category : #private }
TestCoverage >> reference [
	^ reference
]

{ #category : #evaluation }
TestCoverage >> run: aSelector with: anArray in: aReceiver [
	self mark; uninstall.
	^ aReceiver withArgs: anArray executeMethod: method
]

{ #category : #actions }
TestCoverage >> uninstall [
	reference actualClass methodDictionary
		at: reference methodSymbol
		put: method
]
