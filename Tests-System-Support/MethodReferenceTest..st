Class {
	#name : #MethodReferenceTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'env'
	],
	#category : #'Tests-System-Support'
}

{ #category : #private }
MethodReferenceTest >> createClass: aSymbol [
	| builder |
	builder := ClassBuilder new.
	^ builder
		name: aSymbol
		inEnvironment: env
		subclassOf: Object
		type: #normal
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Test'.
]

{ #category : #running }
MethodReferenceTest >> setUp [
	| g p |
	env := Environment withName: 'test'.
	g := self createClass: #Griffle.
	p := self createClass: #Plonk.
	g compileSilently: 'foo ^ 1'.
	g organization classify: #foo under: #accessing.
	g class compileSilently: 'classFoo ^ 1'.
	g compileSilently: 'bar ^ 1'.
	p compileSilently: 'foo ^ 2'.
	self createClass: #Unused.
]

{ #category : #running }
MethodReferenceTest >> tearDown [
	env destroy.
	env := nil
]

{ #category : #tests }
MethodReferenceTest >> testActualClassIsScopedToEnvironment [
	| mref |
	mref := MethodReference class: (env at: #Griffle) selector: #foo environment: env.
	self assert: (env at: #Griffle) equals: mref actualClass.
]

{ #category : #tests }
MethodReferenceTest >> testCanReferToMethodInSpecificEnvironment [
	| mref |
	mref := MethodReference class: self class selector: #testReferencedEnvironmentDefaultsToSmalltalkGlobals environment: env.
	self assert: env equals: mref environment.
]

{ #category : #tests }
MethodReferenceTest >> testCategory [
	| mref |
	mref := MethodReference class: (env at: #Griffle) selector: #foo environment: env.
	self assert: #accessing equals: mref category.
]

{ #category : #tests }
MethodReferenceTest >> testEquals [
	| aMethodReference anotherMethodReference |
	aMethodReference := MethodReference new.
	anotherMethodReference := MethodReference new.
	"Two fresh instances should be equals between them"
	self assert: MethodReference new equals: MethodReference new.
	self assert: MethodReference new hash equals: MethodReference new hash.

	"Two instances representing the same method (same class and  
	same selector) should be equals"
	self assert: (MethodReference class: String selector: #foo) equals: (MethodReference class: String selector: #foo).
	self assert: (MethodReference class: String selector: #foo) hash equals: (MethodReference class: String selector: #foo) hash.
]

{ #category : #tests }
MethodReferenceTest >> testNotEquals [
	self
		deny: (MethodReference class: String selector: #foo) = (MethodReference class: String class selector: #foo)
		description: 'Different classes, same selector -> no more equals'.
	self
		deny: (MethodReference class: String selector: #foo) = (MethodReference class: String selector: #bar)
		description: 'Same class, different selectors -> no more equals'.
]

{ #category : #tests }
MethodReferenceTest >> testReferencedEnvironmentDefaultsToSmalltalkGlobals [
	| mref |
	mref := MethodReference class: self class selector: #testReferencedEnvironmentDefaultsToSmalltalkGlobals.
	self assert: Smalltalk globals equals: mref environment.
]
