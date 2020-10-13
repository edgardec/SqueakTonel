Class {
	#name : #AssociationTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'a',
		'b'
	],
	#category : #'CollectionsTests-Support'
}

{ #category : #setup }
AssociationTest >> setUp [

	a := 1 -> 'one'.
	b := 1 -> 'een'.
]

{ #category : #tests }
AssociationTest >> testEquality [
	
	self 
		assert: (a key = b key);
		deny: (a value = b value);
		deny: (a = b)


]

{ #category : #tests }
AssociationTest >> testHash [

	self 
		assert: (a hash = a copy hash)
]

{ #category : #tests }
AssociationTest >> testStoreStringEvaluatesToEqualValue [
	self assert: 1 -> 2 equals: (Compiler evaluate: (1 -> 2) storeString).
	self assert: false -> true equals: (Compiler evaluate: (false -> true) storeString).
	self assert: #foo -> #bar equals: (Compiler evaluate: (#foo -> #bar) storeString).
	self assert: #foo -> #+ equals: (Compiler evaluate: (#foo -> #+) storeString).
	self assert: #+ -> #bar equals: (Compiler evaluate: (#+ -> #bar) storeString).
]
