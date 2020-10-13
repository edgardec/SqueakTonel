"
Test that a class variable defined in a superclass takes precedence over a global variable of same name.

In #setUp:

Three classes are defined: parent, child and grandchild.
A class variable is defined in child.
A global with the same name is defined in Smalltalk globals.
Methods are defined in all classes getting and setting this class or global variable.

Test whether methods referencing the variable with that name
access the correct variable.
"
Class {
	#name : #ClassVarScopeTest,
	#superclass : #TestCase,
	#instVars : [
		'parent',
		'child',
		'grandchild',
		'foo',
		'environment'
	],
	#category : #'KernelTests-Classes'
}

{ #category : #private }
ClassVarScopeTest >> createClass: aSymbol superClass: superClass classVariableNames: aString [

	^SystemChangeNotifier uniqueInstance doSilently: [
		ClassBuilder new
			name: aSymbol
			inEnvironment: environment
			subclassOf: superClass
			type: #normal
			instanceVariableNames: ''
			classVariableNames: aString
			poolDictionaries: ''
			category: 'Test' ]
]

{ #category : #private }
ClassVarScopeTest >> performTest [

	Utilities
		useAuthorInitials: self className
		during: [ super performTest ]
]

{ #category : #running }
ClassVarScopeTest >> setUp [

	environment := Environment withName: 'test'.
	environment importSelf.
	parent := self createClass: #ClassVarScopeParent superClass: nil classVariableNames: ''.
	child := self createClass: #ClassVarScopeChild superClass: parent classVariableNames: 'ClassVarScopeFoo'.
	grandchild := self createClass: #ClassVarScopeGrandchild superClass: child classVariableNames: ''.
	foo := environment at: #ClassVarScopeFoo put: Object basicNew.
	
	parent compileSilently: self sourceOfParentGetFoo.
	parent compileSilently: self sourceOfParentSetFoo.

	parent class compileSilently: self sourceOfParentGetFoo.
	parent class compileSilently: self sourceOfParentSetFoo.

	child compileSilently: self sourceOfChildGetFoo.
	child compileSilently: self sourceOfChildSetFoo.

	child class compileSilently: self sourceOfChildGetFoo.
	child class compileSilently: self sourceOfChildSetFoo.

	grandchild compileSilently: self sourceOfGrandchildGetFoo.
	grandchild compileSilently: self sourceOfGrandchildSetFoo.

	grandchild class compileSilently: self sourceOfGrandchildGetFoo.
	grandchild class compileSilently: self sourceOfGrandchildSetFoo
]

{ #category : #query }
ClassVarScopeTest >> sourceOfChildGetFoo [
	^'childGetFoo
	^ClassVarScopeFoo'
]

{ #category : #query }
ClassVarScopeTest >> sourceOfChildSetFoo [
	^'childSetFoo: anObject
	ClassVarScopeFoo := anObject'
]

{ #category : #query }
ClassVarScopeTest >> sourceOfGrandchildGetFoo [
	^'grandchildGetFoo
	^ClassVarScopeFoo'
]

{ #category : #query }
ClassVarScopeTest >> sourceOfGrandchildSetFoo [
	^'grandchildSetFoo: anObject
	ClassVarScopeFoo := anObject'
]

{ #category : #query }
ClassVarScopeTest >> sourceOfParentGetFoo [
	^'parentGetFoo
	^ClassVarScopeFoo'
]

{ #category : #query }
ClassVarScopeTest >> sourceOfParentSetFoo [
	^'parentSetFoo: anObject
	ClassVarScopeFoo := anObject'
]

{ #category : #running }
ClassVarScopeTest >> tearDown [

	| classes |
	classes := { grandchild. child. parent }.
	grandchild := child := parent := nil.
	classes do: [ :each |
		each
			removeFromChanges;
			removeFromSystemUnlogged ].
	environment removeKey: #ClassVarScopeFoo ifAbsent: []
]

{ #category : #tests }
ClassVarScopeTest >> testDefinedClassMethodInChild [
	self assert: child childGetFoo == nil.
	child childSetFoo: #bar.
	self assert: child childGetFoo == #bar
]

{ #category : #tests }
ClassVarScopeTest >> testDefinedClassMethodInGrandchild [
	self assert: grandchild grandchildGetFoo == nil.
	grandchild grandchildSetFoo: #bar.
	self assert: grandchild grandchildGetFoo == #bar
]

{ #category : #tests }
ClassVarScopeTest >> testDefinedClassMethodInParent [
	self assert: parent parentGetFoo == foo.
	parent parentSetFoo: #bar.
	self assert: parent parentGetFoo = #bar
]

{ #category : #tests }
ClassVarScopeTest >> testDefinedInstanceMethodInChild [
	self assert: child basicNew childGetFoo == nil.
	child basicNew childSetFoo: #bar.
	self assert: child basicNew childGetFoo == #bar
]

{ #category : #tests }
ClassVarScopeTest >> testDefinedInstanceMethodInGrandchild [
	self assert: grandchild basicNew grandchildGetFoo == nil.
	grandchild basicNew grandchildSetFoo: #bar.
	self assert: grandchild basicNew grandchildGetFoo == #bar
]

{ #category : #tests }
ClassVarScopeTest >> testDefinedInstanceMethodInParent [
	self assert: parent basicNew parentGetFoo == foo.
	parent basicNew parentSetFoo: #bar.
	self assert: parent basicNew parentGetFoo == #bar
]

{ #category : #tests }
ClassVarScopeTest >> testInheritedClassMethodInChild [
	self assert: child parentGetFoo == foo.
	child parentSetFoo: #bar.
	self assert: child parentGetFoo == #bar
]

{ #category : #tests }
ClassVarScopeTest >> testInheritedClassMethodInGrandchild [
	self assert: grandchild childGetFoo == nil.
	grandchild childSetFoo: #bar.
	self assert: grandchild childGetFoo == #bar
]

{ #category : #tests }
ClassVarScopeTest >> testInheritedInstanceMethodInChild [
	self assert: child basicNew parentGetFoo == foo.
	child basicNew parentSetFoo: #bar.
	self assert: child basicNew parentGetFoo == #bar
]

{ #category : #tests }
ClassVarScopeTest >> testInheritedInstanceMethodInGrandchild [
	self assert: grandchild basicNew childGetFoo == nil.
	grandchild basicNew childSetFoo: #bar.
	self assert: grandchild basicNew childGetFoo == #bar
]
