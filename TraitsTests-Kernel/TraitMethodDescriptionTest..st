Class {
	#name : #TraitMethodDescriptionTest,
	#superclass : #TraitsTestCase,
	#category : #'TraitsTests-Kernel'
}

{ #category : #running }
TraitMethodDescriptionTest >> testArgumentNames [
	"T5 combines both T1 and T2. For conflicting messages, T5 cannot know the correct argument names and thus falls back to a generic form 'arg1', 'arg2', etc."
	
	self t1 compile: 'zork1: myArgument zork2: mySecondArgument ^true'.
	self t2 compile: 'zork1: myArgument zork2: somethingElse ^false'.
	
	self assert: ((self t5 sourceCodeAt: #zork1:zork2:) asString 
				beginsWith: 'zork1: arg1 zork2: arg2').
	
	self t1 compile: 'zork1: myArgument zork2: mySecondArgument ^true'.
	self t2 compile: 'zork1: somethingElse zork2: myArgument ^false'.
	
	self assert: ((self t5 sourceCodeAt: #zork1:zork2:) asString 
				beginsWith: 'zork1: arg1 zork2: arg2')
]

{ #category : #running }
TraitMethodDescriptionTest >> testCategories [
	self assert: (self t4 organization categoryOfElement: #m21) = #cat1.
	self assert: (self t4 organization categoryOfElement: #m22) = #cat2.
	self assert: (self t4 organization categoryOfElement: #m11) = #catX.
	self assert: (self t4 organization categoryOfElement: #m12) = #cat2.
	self assert: (self t4 organization categoryOfElement: #m13) = #cat3.
	self assert: (self t6 organization categoryOfElement: #m22Alias) = #cat2.
	self t2 organization classify: #m22 under: #catX.
	self assert: (self t4 organization categoryOfElement: #m22) = #catX.
	self assert: (self t6 organization categoryOfElement: #m22Alias) = #catX.
	self t6 organization classify: #m22 under: #catY.
	self t6 organization classify: #m22Alias under: #catY.
	self t2 organization classify: #m22 under: #catZ.
	"XXX: The following test is commented out for now. The policy is to *always*
	reclassify the method if the base method is reclassified. That results from
	the requirement that the base construction should always be repeatable
	(in fact, one could argue that reclassification of methods from traits is
	invalid without some explicit transformation)."
false ifTrue:[
	self assert: (self t6 organization categoryOfElement: #m22) = #catY.
	self assert: (self t6 organization categoryOfElement: #m22Alias) = #catY.
].
	self t1 compile: 'mA' classified: #catA.
	self assert: (self t4 organization categoryOfElement: #mA) = #catA.
	self t1 organization classify: #mA under: #cat1.
	self assert: (self t4 organization categories includes: #catA) not
]

{ #category : #running }
TraitMethodDescriptionTest >> testConflictMethodCreation [
	"Generate conflicting methods between t1 and t2
	and check the resulting method in Trait t5 (or c2).
	Also test selectors like foo:x (without space) or selectors with CRs."

	"unary"
	self t2 compile: 'm12 ^false'.
	self assert: ((self t5 sourceCodeAt: #m12) asString beginsWith: 'm12').
	self should: [self c2 new m12] raise: Error.

	"binary"
	self t1 compile: '@ myArgument ^true'.
	self t2 compile: '@myArgument ^false'.
	self 
		assert: ((self t5 sourceCodeAt: #@) asString beginsWith: '@ arg1').
	self should: [self c2 new @ 17] raise: Error.

	"keyword"
	self t1 compile: 'zork: myArgument
		^true'.
	self t2 compile: 'zork: myArgument ^false'.
	self assert: ((self t5 sourceCodeAt: #zork:) asString 
				beginsWith: 'zork: arg1').
	self should: [self c2 new zork: 17] raise: Error.
	self t1 compile: 'zork:myArgument ^true'.
	self t2 compile: 'zork:myArgument ^false'.
	self assert: ((self t5 sourceCodeAt: #zork:) asString 
				beginsWith: 'zork: arg1').
	self should: [self c2 new zork: 17] raise: Error.
	self t1 compile: 'zork1: myArgument zork2: mySecondArgument ^true'.
	self t2 compile: 'zork1: anObject zork2: anotherObject ^false'.
	self assert: ((self t5 sourceCodeAt: #zork1:zork2:) asString 
				beginsWith: 'zork1: arg1 zork2: arg2').
	self should: [self c2 new zork1: 1 zork2: 2] raise: Error
]

{ #category : #running }
TraitMethodDescriptionTest >> testConflictingCategories [
	| t7 t8 |
	self t2 compile: 'm11' classified: #catY.
	self assert: (self t4 organization categoryOfElement: #m11) = #catX.
	self assert: (self t5 organization categoryOfElement: #m11) =  #'conflict methods'. "was: #cat1"
	t7 := self createTraitNamed: #T7 uses: self t1 + self t2.
	self assert: (t7 organization categoryOfElement: #m11) 
				=  #'conflict methods'. "was: ClassOrganizer ambiguous"

	self t1 removeSelector: #m11.
	self assert: (self t4 organization categoryOfElement: #m11) = #catX.
	self assert: (self t5 organization categoryOfElement: #m11) = #catY.
	self assert: (t7 organization categoryOfElement: #m11) = #catY.
	self deny: (t7 organization categories includes: #'conflict methods' "was: ClassOrganizer ambiguous").
	self t1 compile: 'm11' classified: #cat1.
	t8 := self createTraitNamed: #T8 uses: self t1 + self t2.
	t8 organization classify: #m11 under: #cat1.

	self t1 organization classify: #m11 under: #catZ.
	self assert: (self t4 organization categoryOfElement: #m11) = #catX.
	self assert: (self t5 organization categoryOfElement: #m11) =  #'conflict methods'. "was: #catY"
	self assert: (t8 organization categoryOfElement: #m11) =  #'conflict methods'. "was: #catZ"
]
