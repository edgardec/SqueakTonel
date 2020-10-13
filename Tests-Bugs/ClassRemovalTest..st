Class {
	#name : #ClassRemovalTest,
	#superclass : #TestCase,
	#instVars : [
		'isClean'
	],
	#category : #'Tests-Bugs'
}

{ #category : #utility }
ClassRemovalTest >> className1 [

	^#ClassToBeRemoved
]

{ #category : #utility }
ClassRemovalTest >> className2 [

	^#ReferringClass
]

{ #category : #private }
ClassRemovalTest >> performTest [

	Utilities
		useAuthorInitials: self className
		during: [ super performTest ]
]

{ #category : #running }
ClassRemovalTest >> setUp [

	isClean :=  (SystemOrganizer default listAtCategoryNamed: self systemCategoryName) isEmpty
		and: [ (Smalltalk hasClassNamed: self className1) not
		and: [ (Smalltalk hasClassNamed: self className2) not ] ]
]

{ #category : #utility }
ClassRemovalTest >> systemCategoryName [

	^'ReferencedClassRemoveTest'
]

{ #category : #running }
ClassRemovalTest >> tearDown [

	isClean ifTrue: [
		Smalltalk removeClassNamed: self className1.
		Smalltalk removeClassNamed: self className2.
		SystemOrganizer default removeCategory: self systemCategoryName ]
]

{ #category : #tests }
ClassRemovalTest >> testClassCanBeRemoved [
	self 
		assert: isClean
		description: 'The system category or the classes about to be created already exist.'.
	"Create a class"	
	Object subclass: self className1
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self systemCategoryName.
	self assert: (Smalltalk hasClassNamed: self className1) description: self className1, ' not created'.
	"Remove the class"
	(Smalltalk at: self className1) removeFromSystem.
	self deny: (Smalltalk hasClassNamed: self className1) description: self className1, ' not removed'.
]

{ #category : #tests }
ClassRemovalTest >> testClassRemovalAndRecompilationWontCreateDuplicateVariableBindings [

	self 
		assert: isClean
		description: 'The system category or the classes about to be created already exist.'.
	"Create a class"	
	Object subclass: self className1
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self systemCategoryName.
	"Create another"
	Object subclass: self className2
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self systemCategoryName.
	"Compile a method in the second which references the first"
	(Smalltalk at: self className2)
		compile: 'foo ^', self className1
		classified: 'accessing'.
	"Remove the first class"
	(Smalltalk at: self className1) removeFromSystem.
	"Compile the first class again"
	Object subclass: self className1
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self systemCategoryName.
	self
		deny: (Smalltalk at: self className2) new foo isObsolete
		description: '#foo refers to an obsolete class'.
	self
		assert: (Smalltalk at: self className1) ==
			(Smalltalk at: self className2) new foo
		description: '#foo refers to a different class'
]
