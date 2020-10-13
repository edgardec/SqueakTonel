Class {
	#name : #SystemDictionaryTest,
	#superclass : #TestCase,
	#category : #'Tests-System-Support'
}

{ #category : #'tests - classes and traits' }
SystemDictionaryTest >> testClassOrTraitNamedReturnsClassForClasses [
	self assert: Object ==  (Smalltalk globals classOrTraitNamed: 'Object').
	self assert: Object ==  (Smalltalk globals classOrTraitNamed: #Object).
]

{ #category : #'tests - classes and traits' }
SystemDictionaryTest >> testClassOrTraitNamedReturnsNilForGlobals [
	self assert: nil = (Smalltalk globals classOrTraitNamed: 'Undeclared').
	self assert: nil = (Smalltalk globals classOrTraitNamed: #Undeclared).
]
