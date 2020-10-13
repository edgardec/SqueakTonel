Class {
	#name : #TraitTest,
	#superclass : #TraitsTestCase,
	#category : #'TraitsTests-Kernel'
}

{ #category : #testing }
TraitTest >> testAddAndRemoveMethodsFromSubtraits [
	| aC2 |
	aC2 := self c2 new.
	self assert: aC2 m51.
	self t5 removeSelector: #m51.
	self should: [aC2 m51] raise: MessageNotUnderstood.
	self t1 compile: 'foo ^true'.
	self deny: aC2 foo.
	self t1 compile: 'm51 ^self'.
	self shouldnt: [aC2 m51] raise: MessageNotUnderstood.
	self assert: aC2 m51 == aC2
]

{ #category : #testing }
TraitTest >> testAddAndRemoveMethodsInClassOrTrait [
	| aC2 |
	aC2 := self c2 new.
	self assert: aC2 m51.
	self c2 compile: 'm51 ^123'.
	self assert: aC2 m51 = 123.
	self c2 removeSelector: #m51.
	self shouldnt: [aC2 m51] raise: MessageNotUnderstood.
	self assert: aC2 m51.
	self t4 removeSelector: #m11.
	self assert: (self t4 methodDict includesKey: #m11)
]

{ #category : #testing }
TraitTest >> testAllClassVarNames [
	
	
	self assert: self t1 allClassVarNames isEmpty
]

{ #category : #testing }
TraitTest >> testCompositionCopy [

	| t6compositionCopyFirst c2compositionCopy |
	self assert: (self t1 + self t2) allTraits 
				= (self t1 + self t2) copyTraitExpression allTraits.
	self assert: (self t1 classTrait + self t2 classTrait) allTraits 
				= (self t1 classTrait + self t2 classTrait) copyTraitExpression allTraits.
	self assert: self t6 traitComposition allTraits 
				= self t6 traitComposition copyTraitExpression allTraits.
	self 
		assert: self t6 asTraitComposition copyTraitExpression allTraits = { (self t1). (self t2). (self t6) }.
	"make no undue sharing happens of exclusions and aliases after an expression copy"
	t6compositionCopyFirst := self t6 traitComposition copyTraitExpression.
	t6compositionCopyFirst at: 1 put: #m22Alias -> #m33.
	self 
		assert: self t6 traitComposition second aliases first value 
				= #m22.
	c2compositionCopy := self c2 traitComposition copyTraitExpression.
	c2compositionCopy first exclusions add: #m4.
	self assert: self c2 traitComposition first exclusions = #(#m11) asSet.
]

{ #category : #testing }
TraitTest >> testExplicitRequirement [
	"self run: #testExplicitRequirement"

	self t1 compile: 'm self explicitRequirement'.
	self t2 compile: 'm ^true'.
	self deny: (self t4 >> #m) == (self t2 >> #m). "no sharing!"
	self assert: self c2 new m.
	self t2 removeSelector: #m.
	self deny: (self t5 >> #m) == (self t1 >> #m). "no sharing!"
	self should: [self c2 new m] raise: Error
]

{ #category : #testing }
TraitTest >> testMarkerMethods [
	"self debug: #testMarkerMethods"

	self t1 compile: 'm1 self foo bar'.
	self assert: (self t1 >> #m1) markerOrNil isNil.


	self t1 compile: 'm2 self requirement'.
	self assert: (self t1 >> #m2) markerOrNil == #requirement.
	
	self t1 compile: 'm3 ^self requirement'.
	self assert: (self t1 >> #m3) markerOrNil == #requirement.
]

{ #category : #testing }
TraitTest >> testPrinting [
	self assertPrints: self t6 definition
		like: 'Trait named: #T6
	uses: T1 + (T2 @ {#m22Alias->#m22})
	category: ''', self categoryName, ''''
]

{ #category : #testing }
TraitTest >> testPrintingClassSide [
	"self run: #testPrintingClassSide"
	
	self assertPrints: self t6 classSide definition
		like: 'T6 classTrait
	uses: T1 classTrait + T2 classTrait'
]

{ #category : #testing }
TraitTest >> testRemoveFromSystem [
	self t4 removeFromSystem.
	self deny: (Smalltalk includesKey: #T4).
	self assert: self t4 name = 'AnObsoleteT4'.
	self assert: self t4 methodDict isEmpty.
	self deny: (self t1 users includes: self t4)
]

{ #category : #testing }
TraitTest >> testRequirement [
	"self run: #testRequirement"

	self t1 compile: 'm self requirement'.
	self t2 compile: 'm ^true'.
	self deny: (self t4 >> #m) == (self t2 >> #m). "no sharing!"
	self assert: self c2 new m.
	self t2 removeSelector: #m.
	self deny: (self t5 >> #m) == (self t1 >> #m). "no sharing!"
	self should: [self c2 new m] raise: Error
]

{ #category : #testing }
TraitTest >> testTraitFromPattern [
	| newTrait |
	newTrait := self createTraitNamed: #TTraitTestBaseTrait uses: {}.
	self assert: newTrait equals: (SystemNavigation default allClassesAndTraitsMatching: 'TTraitTestBaseT') first.
]

{ #category : #testing }
TraitTest >> testTraitMethodClass [
	"Tests that the #methodClass of a trait method isn't screwed up"
	| baseTrait classA methodA classB methodB traitMethod |
	baseTrait := self createTraitNamed: #TraitTestBaseTrait uses:{}.
	baseTrait compileSilently: 'traitMethod' classified: 'tests'.
	traitMethod := baseTrait compiledMethodAt: #traitMethod.
	self assert: traitMethod methodClass == baseTrait.

	classA := self createClassNamed: #TraitTestMethodClassA superclass: Object uses: baseTrait.
	methodA := classA compiledMethodAt: #traitMethod.

	self assert: traitMethod methodClass == baseTrait.
	self assert: methodA methodClass == classA.

	classB := self createClassNamed: #TraitTestMethodClassB superclass: Object uses: baseTrait.
	methodB := classB compiledMethodAt: #traitMethod.


	self assert: traitMethod methodClass == baseTrait.
	self assert: methodA methodClass == classA.
	self assert: methodB methodClass == classB.
]

{ #category : #testing }
TraitTest >> testTraitMethodSelector [
	"Tests that the #selector of a trait method isn't screwed up when aliasing traits"
	| baseTrait classA methodA classB methodB traitMethod |
	baseTrait := self createTraitNamed: #TraitTestBaseTrait uses:{}.
	baseTrait compileSilently: 'traitMethod' classified: 'tests'.
	traitMethod := baseTrait compiledMethodAt: #traitMethod.
	self assert: traitMethod selector == #traitMethod.

	classA := self createClassNamed: #TraitTestMethodClassA superclass: Object
					uses: {baseTrait @ {#methodA -> #traitMethod}}.
	methodA := classA compiledMethodAt: #methodA.

	self assert: traitMethod selector == #traitMethod.
	self assert: methodA selector == #methodA.

	classB := self createClassNamed: #TraitTestMethodClassB superclass: Object
					uses: {baseTrait @ {#methodB -> #traitMethod}}.
	methodB := classB compiledMethodAt: #methodB.

	self assert: traitMethod selector == #traitMethod.
	self assert: methodA selector == #methodA.
	self assert: methodB selector == #methodB.
]

{ #category : #testing }
TraitTest >> testUsers [
	self assert: self t1 users size = 3.
	self assert: (self t1 users includesAllOf: {self t4. self t5. self t6 }).
	self assert: self t3 users isEmpty.
	self assert: self t5 users size = 1.
	self assert: self t5 users anyOne = self c2.
	self c2 uses: self t1 + self t5.
	self assert: self t5 users size = 1.
	self assert: self t5 users anyOne = self c2.
	self c2 uses: self t2 asTraitComposition.
	self assert: self t5 users isEmpty
]
