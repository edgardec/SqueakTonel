Class {
	#name : #ClassTraitTest,
	#superclass : #TraitsTestCase,
	#category : #'TraitsTests-Kernel'
}

{ #category : #testing }
ClassTraitTest >> testChanges [
	"Test the most important features to ensure that
	general functionality of class traits are working."

	"self run: #testChanges"

	| classTrait |
	classTrait := self t1 classTrait.
	classTrait compile: 'm1ClassSide ^17' classified: 'mycategory'.

	"local selectors"
	self assert: (classTrait includesLocalSelector: #m1ClassSide).
	self deny: (classTrait includesLocalSelector: #otherSelector).

	"propagation"
	self assert: (self t5 classSide methodDict includesKey: #m1ClassSide).
	self assert: (self c2 class methodDict includesKey: #m1ClassSide).
	self assert: self c2 m1ClassSide = 17.

	"category"
	self assert: (self c2 class organization categoryOfElement: #m1ClassSide) 
				= 'mycategory'.

	"conflicts"
	self t2 classSide compile: 'm1ClassSide' classified: 'mycategory'.
	self assert: (self c2 class methodDict includesKey: #m1ClassSide).
	self deny: (self c2 class includesLocalSelector: #m1ClassSide).
	self should: [self c2 m1ClassSide] raise: Error.

	"conflict category"
	self assert: (self c2 class organization categoryOfElement: #m1ClassSide) 
				=  #mycategory
]

{ #category : #testing }
ClassTraitTest >> testConflictsAliasesAndExclusions [
	"conflict"

	self t1 classTrait compile: 'm2ClassSide: x ^99' classified: 'mycategory'.
	self assert: (self t1 classTrait includesLocalSelector: #m2ClassSide:).
	self assert: (self t5 classTrait >> #m2ClassSide:) isConflict.
	self assert: (self c2 class >> #m2ClassSide:) isConflict.

	"exclusion and alias"
	self assert: self t5 classSide traitComposition asString 
				= 'T1 classTrait + T2 classTrait'.
	self t5 classSide 
		uses: (self t1 classTrait @ { (#m2ClassSideAlias1: -> #m2ClassSide:) } 
				+ (self t2 classTrait @ { (#m2ClassSideAlias2: -> #m2ClassSide:) } - { #m2ClassSide: })).
	self deny: (self t5 classTrait >> #m2ClassSide:) isConflict.
	self deny: (self c2 class >> #m2ClassSide:) isConflict.
	self assert: (self c2 m2ClassSideAlias1: 13) = 99.
	self assert: (self c2 m2ClassSideAlias2: 13) = 13
]

{ #category : #testing }
ClassTraitTest >> testInitialization [
	"self run: #testInitialization"

	| classTrait |
	classTrait := self t1 classTrait.
	self assert: self t1 hasClassTrait.
	self assert: self t1 classTrait == classTrait.
	self assert: classTrait isClassTrait.
	self assert: classTrait classSide == classTrait.
	self deny: classTrait isBaseTrait.
	self assert: classTrait baseTrait == self t1.

	"assert classtrait methods are propagated to users when setting traitComposition"
	self assert: self t4 hasClassTrait.
	self assert: self t5 hasClassTrait.
	self assert: (self t2 classSide includesLocalSelector: #m2ClassSide:).
	self assert: (self t4 classSide methodDict includesKey: #m2ClassSide:).
	self assert: (self t5 classSide methodDict includesKey: #m2ClassSide:).
	self assert: (self c2 m2ClassSide: 17) = 17
]

{ #category : #testing }
ClassTraitTest >> testUsers [
	self assert: self t2 classSide users size = 3.
	self assert: (self t2 classSide users includesAllOf: {				
		(self t4 classTrait).
		(self t5 classTrait).
		(self t6 classTrait) }).
	self assert: self t5 classSide users size = 1.
	self assert: self t5 classSide users anyOne = self c2 class.
	self c2 uses: self t1 + self t5.
	self assert: self t5 classSide users size = 1.
	self assert: self t5 classSide users anyOne = self c2 class.
	self c2 uses: self t2 asTraitComposition.
	self assert: self t5 classSide users isEmpty
]
