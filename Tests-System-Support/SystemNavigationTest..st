Class {
	#name : #SystemNavigationTest,
	#superclass : #TestCase,
	#instVars : [
		'sysNav',
		'env'
	],
	#category : #'Tests-System-Support'
}

{ #category : #helpers }
SystemNavigationTest >> createClass: aSymbol [
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

{ #category : #helpers }
SystemNavigationTest >> createTrait: aSymbol [
	^ Trait
		named: aSymbol
		uses: #()
		category: 'Traits'
		env: env.
]

{ #category : #running }
SystemNavigationTest >> setUp [
	| g p t |
	env := Environment named: 'test'.
	g := self createClass: #Griffle.
	p := self createClass: #Plonk.
	g compileSilently: 'foo ^ 1'.
	g class compileSilently: 'classFoo ^ 1'.
	g compileSilently: 'bar ^ 1'.
	p compileSilently: 'foo ^ 2'.
	t := self createTrait: #TGriffle.
	t compileSilently: 'baz ^ Griffle new foo + Plonk new bar'.
	self createClass: #Unused.
	sysNav := SystemNavigation for: env.
]

{ #category : #tests }
SystemNavigationTest >> testAllClassesDoShouldIterateOverClassesInAnEnvironment [
	| classes |
	classes := OrderedCollection new.
	sysNav allClassesDo: [:cls |
		classes add: cls].
	self assert: env allClasses equals: classes asArray.
]

{ #category : #tests }
SystemNavigationTest >> testAllClassesShouldReturnEnvironmentsClasses [
	self assert: env allClasses equals: sysNav allClasses.
]

{ #category : #tests }
SystemNavigationTest >> testAllImplementedMessagesWithout [

	self assert: #(bar baz classFoo) asIdentitySet
		equals: (sysNav allImplementedMessagesWithout: {{env at: #Griffle}. {#foo}}).
]

{ #category : #tests }
SystemNavigationTest >> testAllImplementorsOf [
	self assert: (OrderedCollection
			with: (MethodReference class: (env at: #Griffle) selector: #foo)
			with: (MethodReference class: (env at: #Plonk) selector: #foo))
		equals: (sysNav allImplementorsOf: #foo).
]

{ #category : #tests }
SystemNavigationTest >> testAllImplementorsOfClassSide [
	self assert: (OrderedCollection
			with: (MethodReference class: (env at: #Griffle) class selector: #classFoo))
		equals: (sysNav allImplementorsOf: #classFoo).
]

{ #category : #tests }
SystemNavigationTest >> testAllImplementorsOfLocalTo [
	| result |
	result := sysNav allImplementorsOf: #yourself localTo: Morph.
	self assert: [result size = 1].
	self assert: [result includes: (MethodReference class: Object selector: #yourself)].
]

{ #category : #tests }
SystemNavigationTest >> testAllSentMessagesWithout [

	self 
		assert: (#(foo bar) asIdentitySet
			addAll: Smalltalk presumedSentMessages;
			addAll: Smalltalk specialSelectorNames;
			yourself)
		equals: (sysNav allSentMessagesWithout: {{}. {}}).
		
	self 
		assert: (IdentitySet new
			addAll: Smalltalk presumedSentMessages;
			addAll: Smalltalk specialSelectorNames;
			yourself)
		equals: (sysNav allSentMessagesWithout: {{env at: #TGriffle}. {}}).
]

{ #category : #tests }
SystemNavigationTest >> testAllUnusedClassesWithout [
	
	self
		assert: (IdentitySet with: #Unused)
		equals: ((SystemNavigation for: env) allUnusedClassesWithout: {{}. {}}).
		
	"The classes passed to #allUnusedClassesWithout: are not filtered from the list. They're classes whose methods are not examined for global references."
	self
		deny: ((SystemNavigation for: env) allUnusedClassesWithout: {{#Unused}. {}}) isEmpty
		description: 'Where did Unused go?'.
]

{ #category : #tests }
SystemNavigationTest >> testDefaultAllClassesAndTraitsShouldReturnTopEnvironmentClassesAndTraits [
	self assert: Smalltalk allClassesAndTraits equals: SystemNavigation default allClassesAndTraits.
]

{ #category : #tests }
SystemNavigationTest >> testDefaultAllClassesShouldReturnTopEnvironmentClasses [
	self assert: Smalltalk allClasses equals: SystemNavigation default allClasses.
]
