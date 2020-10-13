Class {
	#name : #ClassTest,
	#superclass : #TestCase,
	#instVars : [
		'className',
		'renamedName'
	],
	#category : #'KernelTests-Classes'
}

{ #category : #setup }
ClassTest >> categoryNameForTemporaryClasses [
	"Answer the category where to classify temporarily created classes"
	
	^'Dummy-Tests-Class'
]

{ #category : #setup }
ClassTest >> deleteClass [
	| cl |
	cl := Smalltalk at: className ifAbsent: [^self].
	cl removeFromChanges; removeFromSystemUnlogged 
	
]

{ #category : #setup }
ClassTest >> deleteRenamedClass [
	| cl |
	cl := Smalltalk at: renamedName ifAbsent: [^self].
	cl removeFromChanges; removeFromSystemUnlogged 
	
]

{ #category : #private }
ClassTest >> performTest [

	Utilities
		useAuthorInitials: self className
		during: [ super performTest ]
]

{ #category : #setup }
ClassTest >> setUp [
	className := #TUTU.
	renamedName := #RenamedTUTU.
	self deleteClass.
	self deleteRenamedClass.
	Object subclass: className
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	#('foo' 'bar self foo' 'baz self bar') do:
		[:s| (Smalltalk at: className) compileSilently: s]
]

{ #category : #setup }
ClassTest >> tearDown [
	self deleteClass.
	self deleteRenamedClass.
	(Smalltalk organization listAtCategoryNamed: self categoryNameForTemporaryClasses) isEmpty
		ifTrue: [Smalltalk organization removeCategory: self categoryNameForTemporaryClasses]
]

{ #category : #tests }
ClassTest >> testAddInstVarName [
	"self run: #testAddInstVarName"
	
	
	| tutu |
	tutu := Smalltalk at: className.
	tutu addInstVarName: 'x'.
	self assert: (tutu instVarNames = #('x')).
	tutu addInstVarName: 'y'.
	self assert: (tutu instVarNames = #('x' 'y')).
	tutu selectorsAndMethodsDo:
		[:s :m|
		self assert: m methodClassAssociation == (Smalltalk bindingOf: className)]
	
	
]

{ #category : #tests }
ClassTest >> testChangeClassOf [
	"Exercise primitiveChangeClass (primitive 115) for a common use case. This should pass
	for any Squeak image format (but failed for image format 68002 prior to VM fix)"

	self shouldnt: [Exception new primitiveChangeClassTo: Error new] raise: Error
]

{ #category : #'tests - compiling' }
ClassTest >> testCompileAll [
	"We expect this to succeed."
	ClassTest compileAll.
]

{ #category : #tests }
ClassTest >> testRenaming [
	"self debug: #testRenaming"
	"self run: #testRenaming"
	
	| oldName newMetaclassName class |
	oldName := className.
	newMetaclassName := (renamedName, #' class') asSymbol.
	class := Smalltalk at: oldName.
	class class compile: 'dummyMeth'.
	class rename: renamedName.
	self assert: class name = renamedName.
	self assert: (ChangeSet current changedClassNames includes: renamedName). 
	self assert: (ChangeSet current changedClassNames includes: newMetaclassName).
	
]
