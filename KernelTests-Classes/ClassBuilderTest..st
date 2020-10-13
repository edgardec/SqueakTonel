Class {
	#name : #ClassBuilderTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'baseClass',
		'subClass',
		'baseClass2',
		'subSubClass'
	],
	#category : #'KernelTests-Classes'
}

{ #category : #utilities }
ClassBuilderTest >> baseClassName [
	^#DummyClassBuilderFormatTestSuperClass
]

{ #category : #utilities }
ClassBuilderTest >> categoryNameForTemporaryClasses [
	"Answer the category where to classify temporarily created classes"
	
	^'Dummy-Tests-ClassBuilder'
]

{ #category : #utilities }
ClassBuilderTest >> cleanup [
	subSubClass ifNotNil:[subSubClass removeFromSystem].
	subClass ifNotNil:[subClass removeFromSystem].
	baseClass ifNotNil:[baseClass removeFromSystem].
	baseClass2 ifNotNil: [baseClass2 removeFromSystem].
	(Smalltalk organization listAtCategoryNamed: self categoryNameForTemporaryClasses) isEmpty
		ifTrue: [Smalltalk organization removeCategory: self categoryNameForTemporaryClasses]
]

{ #category : #utilities }
ClassBuilderTest >> makeByteVariableSubclassOf: aClass [
	^ aClass variableByteSubclass: self subClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses
]

{ #category : #utilities }
ClassBuilderTest >> makeDoubleByteVariableSubclassOf: aClass [
	^ aClass variableDoubleByteSubclass: self subClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses
]

{ #category : #utilities }
ClassBuilderTest >> makeDoubleWordVariableSubclassOf: aClass [
	^ aClass variableDoubleWordSubclass: self subClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses
]

{ #category : #utilities }
ClassBuilderTest >> makeIVarsSubclassOf: aClass [
	^ aClass subclass: self subClassName
		instanceVariableNames: 'var3 var4'
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses
]

{ #category : #utilities }
ClassBuilderTest >> makeNormalSubclassOf: aClass [
	^ aClass subclass: self subClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses
]

{ #category : #utilities }
ClassBuilderTest >> makeVariableSubclassOf: aClass [
	^ aClass variableSubclass: self subClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses
]

{ #category : #utilities }
ClassBuilderTest >> makeWeakSubclassOf: aClass [
	^ aClass weakSubclass: self subClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses
]

{ #category : #utilities }
ClassBuilderTest >> makeWordVariableSubclassOf: aClass [
	^ aClass variableWordSubclass: self subClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses
]

{ #category : #private }
ClassBuilderTest >> performTest [

	Utilities
		useAuthorInitials: self className
		during: [ super performTest ]
]

{ #category : #utilities }
ClassBuilderTest >> subClassName [
	^#DummyClassBuilderFormatTestSubClass
]

{ #category : #utilities }
ClassBuilderTest >> subSubClassName [
	^#DummyClassBuilderFormatTestSubSubClass
]

{ #category : #running }
ClassBuilderTest >> tearDown [

	self cleanup.
	baseClass := nil.
	subClass := nil.
	baseClass2 := nil.
	subSubClass := nil
]

{ #category : #'tests - format' }
ClassBuilderTest >> testByteVariableSubclass [
	"Ensure that the invariants for superclass/subclass format are preserved"
	baseClass := Object variableByteSubclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	[

	subClass := self makeNormalSubclassOf: baseClass.
	self deny: (subClass isPointers).
	self assert: (subClass isVariable).
	self deny: (subClass isWeak).
	self assert: (subClass isBytes).
	self deny: (subClass isWords).
	self deny: (subClass isShorts).
	self deny: (subClass isLongs).
	subClass removeFromSystem.

	"pointer classes"
	self should:[self makeIVarsSubclassOf: baseClass] raise: Error.
	self should:[self makeVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeWeakSubclassOf: baseClass] raise: Error.

	"bit classes"
	subClass := self makeByteVariableSubclassOf: baseClass.
	self deny: (subClass isPointers).
	self assert: (subClass isVariable).
	self deny: (subClass isWeak).
	self assert: (subClass isBytes).
	self deny: (subClass isWords).
	self deny: (subClass isShorts).
	self deny: (subClass isLongs).
	subClass removeFromSystem.

	self should:[self makeWordVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeDoubleByteVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeDoubleWordVariableSubclassOf: baseClass] raise: Error.

	] ensure:[self cleanup].
]

{ #category : #'tests - format' }
ClassBuilderTest >> testChangeToVariableSubclass [
	"Ensure that the invariants for superclass/subclass format are preserved"
	baseClass := Object subclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	[
		baseClass := Object variableSubclass: self baseClassName
			instanceVariableNames: ''
			classVariableNames: ''
			poolDictionaries: ''
			category: self categoryNameForTemporaryClasses.

	] ensure:[self cleanup].
]

{ #category : #'tests - format' }
ClassBuilderTest >> testCompiledMethodSubclass [
	"Ensure that the invariants for superclass/subclass format are preserved"
	[self deny: (Smalltalk includesKey: self subClassName).
	 baseClass := CompiledMethod
						variableByteSubclass: self subClassName
						instanceVariableNames: ''
						classVariableNames: ''
						poolDictionaries: ''
						category: self categoryNameForTemporaryClasses.
	self deny: baseClass isPointers.
	self assert: baseClass isVariable.
	self deny: baseClass isWeak.
	self assert: baseClass isBytes.
	self assert: baseClass isCompiledMethodClass.
	self deny: baseClass isWords.
	self deny: baseClass isShorts.
	self deny: baseClass isLongs.
	"Now move it to be a sibling; test it maintains its CompiledMethod-ness"
	 baseClass := ByteArray
						variableByteSubclass: self subClassName
						instanceVariableNames: ''
						classVariableNames: ''
						poolDictionaries: ''
						category: self categoryNameForTemporaryClasses.
	self deny: baseClass isPointers.
	self assert: baseClass isVariable.
	self deny: baseClass isWeak.
	self assert: baseClass isBytes.
	self assert: baseClass isCompiledMethodClass.
	self deny: baseClass isWords.
	self deny: baseClass isShorts.
	self deny: baseClass isLongs]
		ensure: [self cleanup]
]

{ #category : #'tests - format' }
ClassBuilderTest >> testDoubleByteVariableSubclass [
	"Ensure that the invariants for superclass/subclass format are preserved"
	baseClass := Object variableDoubleByteSubclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	[
	subClass := self makeNormalSubclassOf: baseClass.
	self deny: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isShorts).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	self deny: (subClass isWords).
	self deny: (subClass isLongs).
	subClass removeFromSystem.

	"pointer classes"
	self should:[self makeIVarsSubclassOf: baseClass] raise: Error.
	self should:[self makeVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeWeakSubclassOf: baseClass] raise: Error.

	"bit classes"
	self should:[self makeByteVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeWordVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeDoubleWordVariableSubclassOf: baseClass] raise: Error.
	subClass := self makeDoubleByteVariableSubclassOf: baseClass.
	self deny: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isShorts).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	self deny: (subClass isWords).
	self deny: (subClass isLongs).
	subClass removeFromSystem.
	] ensure:[self cleanup].
]

{ #category : #'tests - format' }
ClassBuilderTest >> testDoubleWordVariableSubclass [
	"Ensure that the invariants for superclass/subclass format are preserved"
	baseClass := Object variableDoubleWordSubclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	[
	subClass := self makeNormalSubclassOf: baseClass.
	self deny: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isLongs).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	self deny: (subClass isShorts).
	self deny: (subClass isWords).
	subClass removeFromSystem.

	"pointer classes"
	self should:[self makeIVarsSubclassOf: baseClass] raise: Error.
	self should:[self makeVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeWeakSubclassOf: baseClass] raise: Error.

	"bit classes"
	self should:[self makeByteVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeDoubleByteVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeWordVariableSubclassOf: baseClass] raise: Error.
	subClass := self makeDoubleWordVariableSubclassOf: baseClass.
	self deny: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isLongs).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	self deny: (subClass isShorts).
	self deny: (subClass isWords).
	subClass removeFromSystem.
	] ensure:[self cleanup].
]

{ #category : #'tests - reshape' }
ClassBuilderTest >> testDuplicateClassVariableError [
	baseClass := Object subclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: 'TestVar'
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.

	self should:[
		subClass := baseClass subclass: self subClassName
			instanceVariableNames: ''
			classVariableNames: 'TestVar'
			poolDictionaries: ''
			category: self categoryNameForTemporaryClasses
	] raise: DuplicateVariableError.

	[subClass := baseClass subclass: self subClassName
			instanceVariableNames: ''
			classVariableNames: 'TestVar'
			poolDictionaries: ''
			category: self categoryNameForTemporaryClasses
	] on: DuplicateVariableError do:[:ex|
		self assert: ex superclass == baseClass.
		self assert: ex variable = 'TestVar'.
		ex resume.
	].

	baseClass := Object subclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.

	self should:[
		baseClass := Object subclass: self baseClassName
			instanceVariableNames: ''
			classVariableNames: 'TestVar'
			poolDictionaries: ''
			category: self categoryNameForTemporaryClasses.
	] raise: DuplicateVariableError.

	[baseClass := Object subclass: self baseClassName
			instanceVariableNames: ''
			classVariableNames: 'TestVar'
			poolDictionaries: ''
			category: self categoryNameForTemporaryClasses.
	] on: DuplicateVariableError do:[:ex|
		self assert: ex superclass == baseClass.
		self assert: ex variable = 'TestVar'.
		ex resume.
	].
]

{ #category : #'tests - reshape' }
ClassBuilderTest >> testDuplicateInstanceVariableError [
	| didRaise |
	"Define 'var' in a superclass."
	baseClass := Object 
		subclass: self baseClassName
		instanceVariableNames: 'var'
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	"Ensure trying to define a subclass with same var errors."
	didRaise := false.
	[baseClass subclass: self subClassName
			instanceVariableNames: 'var'
			classVariableNames: ''
			poolDictionaries: ''
			category: self categoryNameForTemporaryClasses ] 
		on: DuplicateVariableError do:
			[ : err |
			didRaise := true.
			self assert: err superclass == baseClass.
			self assert: err variable = 'var' ].
	self assert: didRaise.
	"Prepare for next test:  Remove 'var' from superclass."
	baseClass := Object 
		subclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	"Define a subclass without 'var'..."
	subClass := baseClass
		subclass: self subClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	"... but with a subclass of THAT, with 'var' defined."
	subSubClass := subClass subclass: self subSubClassName
		instanceVariableNames: 'var'
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	"... as well as a different base class with 'var' already defined..."
	baseClass2 := Object 
		subclass: (self baseClassName,'2') asSymbol
		instanceVariableNames: 'var'
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	"...and now try to move the middle subClass, whose subclass (a.k.a., subSubClass) defines 'var', to the new baseClass which also defines 'var'."
	didRaise := false.
	[baseClass2 subclass: self subClassName
			instanceVariableNames: ''
			classVariableNames: ''
			poolDictionaries: ''
			category: self categoryNameForTemporaryClasses ] 
		on: DuplicateVariableError do:
			[ : err |
			didRaise := true.
			self assert: err superclass == baseClass2.
			self assert: err variable = 'var' ].
	self assert: didRaise
]

{ #category : #'tests - reshape' }
ClassBuilderTest >> testMoveVarFromSubToSuperclass [
	| baseInst subInst |

	baseClass := Object subclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.

	subClass := baseClass subclass: self subClassName
		instanceVariableNames: 'var'
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	subClass compile: 'subGet ^var'.
	subClass compile: 'subSet: v var := v'.

	self assert:[baseClass instSize = 0].
	self assert:[subClass instSize = 1].

	baseInst := baseClass new.
	subInst := subClass new.
	subInst instVarAt: 1 put: 123.

	self assert: (subInst instVarAt: 1) = 123.
	self assert: (subInst subGet) = 123.

	[baseClass := Object subclass: self baseClassName
		instanceVariableNames: 'var'
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	] on: DuplicateVariableError do:[:ex| ex resume].
	baseClass compile: 'superGet ^var'.
	baseClass compile: 'superSet: v var := v'.

	self assert:[baseClass instSize = 1].
	self assert:[subClass instSize = 2].

	"the assumption here is that an existing value is propagated up"
	self assert: (baseInst instVarAt: 1) = nil.
	self assert: (subInst instVarAt: 1) = 123.
	self assert: (subInst instVarAt: 2) = 123.

	"the assumption below is that the subclass binds to the local scope not
	the outer one, which is in line with common name space approaches."
	subInst superSet: 666.
	subInst subSet: 321.

	self assert: (subInst instVarAt: 1) = 666.
	self assert: (subInst instVarAt: 2) = 321.
	self assert: (subInst superGet) = 666.
	self assert: (subInst subGet) = 321.

	subClass := baseClass subclass: self subClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.

	self assert:[baseClass instSize = 1].
	self assert:[subClass instSize = 1].

	"the assumption here is that the current (subclass) value is propagated up"
	self assert: (subInst instVarAt: 1) = 321.
	self assert: (subInst subGet) = 321.

]

{ #category : #'tests - reshape' }
ClassBuilderTest >> testMoveVarFromSuperToSubclass [
	| baseInst subInst |
	baseClass := Object subclass: self baseClassName
		instanceVariableNames: 'var'
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	baseClass compile: 'superGet ^var'.
	baseClass compile: 'superSet: v var := v'.

	subClass := baseClass subclass: self subClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	subClass compile: 'subGet ^var'.
	subClass compile: 'subSet: v var := v'.

	self assert:[baseClass instSize = 1].
	self assert:[subClass instSize = 1].

	baseInst := baseClass new.
	subInst := subClass new.
	baseInst instVarAt: 1 put: 42.
	subInst instVarAt: 1 put: 123.

	self assert: (baseInst instVarAt: 1) = 42.
	self assert: (subInst instVarAt: 1) = 123.
	self assert: (subInst subGet) = 123.

	[subClass := baseClass subclass: self subClassName
			instanceVariableNames: 'var'
			classVariableNames: ''
			poolDictionaries: ''
			category: self categoryNameForTemporaryClasses
	] on: DuplicateVariableError do:[:ex| ex resume].

	self assert:[baseClass instSize = 1].
	self assert:[subClass instSize = 2].

	self assert: (baseInst instVarAt: 1) = 42.

	"the assumption below is that for duplicate variables the values get duplicated too.
	this isn't strictly necessary; what we really need is that the old var doesn't get 
	nuked but it has some advantages when moving vars up the hierarchy"
	self assert: (subInst instVarAt: 1) = 123.
	self assert: (subInst instVarAt: 2) = 123.
	self assert: (subInst superGet) = 123.
	self assert: (subInst subGet) = 123.

	"the assumption below is that the subclass binds to the local scope not
	the outer one, which is in line with common name space approaches."
	subInst superSet: 666.
	subInst subSet: 321.

	self assert: (subInst instVarAt: 1) = 666.
	self assert: (subInst instVarAt: 2) = 321.
	self assert: (subInst superGet) = 666.
	self assert: (subInst subGet) = 321.

	baseClass removeSelector: #superGet.
	baseClass removeSelector: #superSet:.
	baseClass := Object subclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.

	self assert:[baseClass instSize = 0].
	self assert:[subClass instSize = 1].

	self assert: (subInst instVarAt: 1) = 321.
	self assert: (subInst subGet) = 321.

]

{ #category : #'tests - uniclass' }
ClassBuilderTest >> testNewUniclass [

	baseClass := Object subclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	"Note that you have to denote a new base class to be capable of spawning uni classes. See Object class >> #isUniClass for more information."
	baseClass class
		compile: ('isUniClass\	^ self ~~ {1}' withCRs format: {self baseClassName})
		classified: 'instance creation'.
		
	subClass := baseClass newSubclass.
	
	self
		assert: subClass isUniClass;
		assert: subClass environment ~~ baseClass environment;
		assert: subClass category = Object categoryForUniclasses;
		assert: (baseClass organization categoryOfElement: subClass name) isNil.
	
	self deny: subClass isObsolete.
	subClass removeFromSystem.
	self assert: subClass isObsolete.
]

{ #category : #'tests - format' }
ClassBuilderTest >> testSubclass [
	"Ensure that the invariants for superclass/subclass format are preserved"
	baseClass := Object subclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	[
	subClass := self makeNormalSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self deny: (subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	"pointer classes"
	subClass := self makeIVarsSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self deny: (subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeVariableSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert:(subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeWeakSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert:(subClass isVariable).
	self assert:(subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	"bit classes"
	subClass := self makeByteVariableSubclassOf: baseClass.
	self deny: (subClass isPointers).
	self assert: (subClass isVariable).
	self deny: (subClass isWeak).
	self assert: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeWordVariableSubclassOf: baseClass.
	self deny: (subClass isPointers).
	self assert: (subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.
	] ensure:[self cleanup].
]

{ #category : #'tests - format' }
ClassBuilderTest >> testSubclassWithInstanceVariables [
	"Ensure that the invariants for superclass/subclass format are preserved"
	baseClass := Object subclass: self baseClassName
		instanceVariableNames: 'var1 var2'
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	[
	subClass := self makeNormalSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self deny: (subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	"pointer classes"
	subClass := self makeIVarsSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self deny: (subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeVariableSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert: (subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeWeakSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	"bit classes"
	self should:[self makeByteVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeWordVariableSubclassOf: baseClass] raise: Error.
	] ensure:[self cleanup].
]

{ #category : #'tests - format' }
ClassBuilderTest >> testVariableSubclass [
	"Ensure that the invariants for superclass/subclass format are preserved"
	baseClass := Object variableSubclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	[
	"pointer classes"
	subClass := self makeNormalSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert: (subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeIVarsSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert: (subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeVariableSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert: (subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeWeakSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	"bit classes"
	self should:[self makeByteVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeWordVariableSubclassOf: baseClass] raise: Error.
	] ensure:[self cleanup].
]

{ #category : #'tests - format' }
ClassBuilderTest >> testWeakSubclass [
	"Ensure that the invariants for superclass/subclass format are preserved"
	baseClass := Object weakSubclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	[
	"pointer classes"
	subClass := self makeNormalSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeIVarsSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeVariableSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert: (subClass isVariable).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	subClass := self makeWeakSubclassOf: baseClass.
	self assert: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isWeak).
	self deny: (subClass isBytes).
	subClass removeFromSystem.

	"bit classes"
	self should:[self makeByteVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeWordVariableSubclassOf: baseClass] raise: Error.
	] ensure:[self cleanup].
]

{ #category : #'tests - format' }
ClassBuilderTest >> testWordVariableSubclass [
	"Ensure that the invariants for superclass/subclass format are preserved"
	baseClass := Object variableWordSubclass: self baseClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryNameForTemporaryClasses.
	[
	subClass := self makeNormalSubclassOf: baseClass.
	self deny: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isWords).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	self deny: (subClass isShorts).
	self deny: (subClass isLongs).
	subClass removeFromSystem.

	"pointer classes"
	self should:[self makeIVarsSubclassOf: baseClass] raise: Error.
	self should:[self makeVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeWeakSubclassOf: baseClass] raise: Error.

	"bit classes"
	self should:[self makeByteVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeDoubleByteVariableSubclassOf: baseClass] raise: Error.
	self should:[self makeDoubleWordVariableSubclassOf: baseClass] raise: Error.
	subClass := self makeWordVariableSubclassOf: baseClass.
	self deny: (subClass isPointers).
	self assert: (subClass isVariable).
	self assert: (subClass isWords).
	self deny: (subClass isWeak).
	self deny: (subClass isBytes).
	self deny: (subClass isShorts).
	self deny: (subClass isLongs).
	subClass removeFromSystem.
	] ensure:[self cleanup].
]
