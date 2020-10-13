Class {
	#name : #PureBehaviorTest,
	#superclass : #TraitsTestCase,
	#category : #'TraitsTests-Kernel'
}

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testChangeSuperclass [
	"self run: #testChangeSuperclass"

	"Test that when the superclass of a class is changed the non-local methods
	of the class sending super are recompiled to correctly store the new superclass."

	| aC2 newSuperclass |
	aC2 := self c2 new.

	"C1 is current superclass of C2"
	self assert: aC2 m51.
	self assert: self c2 superclass == self c1.
	self deny: (self c2 localSelectors includes: #m51).
	self deny: (self c2 >> #m52) == (self t5 >> #m52). "no sharing!"

	self assert: self c2 traitCompositionString = '(T5 - {#m11})'.
	self assert: self c2 selectors sort =  #(bar foo m12 m13 m21 m22 m51 m52 m53).
	self assert: self c2 localSelectors sort =  #(bar foo).


	"change superclass of C2 from C1 to X"
	newSuperclass := self createClassNamed: #X superclass: Object uses: {}.
	newSuperclass
		subclass: self c2 name
		uses: self c2 traitComposition
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self c2 category.

	self assert: self c2 superclass == newSuperclass.

	newSuperclass compile: 'foo ^17'.
	self assert: aC2 m51 = 17.
	self deny: (self c2 localSelectors includes: #m51).

	self c2 compile: 'm51 ^19'.
	self assert: aC2 m51 = 19.

	self deny: (self c2 >> #m52) == (self t5 >> #m52). "no sharing!"

	self assert: self c2 traitCompositionString = '(T5 - {#m11})'.
	self assert: self c2 selectors sort =  #(bar foo m12 m13 m21 m22 m51 m52 m53).
	self assert: self c2 localSelectors sort =  #(bar foo m51).
	
	"change superclass of C2 back to C1"
	self c1
		subclass: self c2 name
		uses: self c2 traitComposition
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self c2 category.

	self assert: (aC2 m51 = 19).
	self assert: self c2 superclass == self c1.
	self assert: (self c2 localSelectors includes: #m51).
	self deny: (self c2 >> #m52) == (self t5 >> #m52). "no sharing!"

	self assert: self c2 traitCompositionString = '(T5 - {#m11})'.
	self assert: self c2 selectors sort =  #(bar foo m12 m13 m21 m22 m51 m52 m53).
	self assert: self c2 localSelectors sort =  #(bar foo m51).

]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testClassesWithTraits [
	"self debug: #testClassesWithTraits"

	self assert: (self c1 methodDict includesKey: #foo).
	self assert: (self c2 methodDict includesKey: #bar).
	self assert: (self c2 methodDict includesKey: #m51).
	self assert: (self c2 methodDict includesKey: #m12).
	self assert: (self c2 methodDict includesKey: #m13).
	self assert: (self c2 methodDict includesKey: #m21).
	self assert: (self c2 methodDict includesKey: #m22).
	
	self deny: self c1 class hasTraitComposition.
	self assert: self c2 class hasTraitComposition.

	self assert: (self c2 class traitComposition size = 1).
	self assert: (self c2 class includesTrait: self t5 classTrait)
]

{ #category : #testing }
PureBehaviorTest >> testIsAliasSelector [
	self deny: (self t1 isAliasSelector: #m11).
	self deny: (self t1 isAliasSelector: #foo).

	"directly"
	self assert: (self t6 isAliasSelector: #m22Alias).
	self deny: (self t6 isAliasSelector: #m22).

	"indirectly"
	self c1 uses: self t6.
	self assert: (self c1 isAliasSelector: #m22Alias).
	self deny: (self c1 isAliasSelector: #m22)
]

{ #category : #testing }
PureBehaviorTest >> testIsLocalAliasSelector [
	self deny: (self t1 isLocalAliasSelector: #m11).
	self deny: (self t1 isLocalAliasSelector: #foo).

	"directly"
	self assert: (self t6 isLocalAliasSelector: #m22Alias).
	self deny: (self t6 isLocalAliasSelector: #m22).

	"indirectly"
	self c1 uses: self t6 asTraitComposition.
	self deny: (self c1 isLocalAliasSelector: #m22Alias).
	self deny: (self c1 isLocalAliasSelector: #m22)
]

{ #category : #testing }
PureBehaviorTest >> testLocalSelectors [
	"self run: #testLocalSelectors"

	self assert: self t3 localSelectors size = 3.
	self assert: (self t3 localSelectors includesAllOf: #(#m31 #m32 #m33 )).
	self assert: (self t3 includesLocalSelector: #m32).
	self deny: (self t3 includesLocalSelector: #inexistantSelector).
	self assert: self t5 localSelectors size = 3.
	self assert: (self t5 localSelectors includes: #m51).
	self assert: (self t5 includesLocalSelector: #m51).
	self deny: (self t5 includesLocalSelector: #m11).
	self t5 removeSelector: #m51.
	self deny: (self t3 includesLocalSelector: #m51).
	self deny: (self t5 includesLocalSelector: #m11).
	self assert: self t5 localSelectors size = 2.
	self t5 compile: 'm52 ^self'.
	self assert: self t5 localSelectors size = 2.
	self assert: (self t5 localSelectors includes: #m52).

	"test that propagated methods do not get in as local methods"
	self t2 compile: 'local2 ^self'.
	self deny: (self t5 includesLocalSelector: #local2).
	self assert: self t5 localSelectors size = 2.
	self assert: (self t5 localSelectors includes: #m52).
	self assert: self c2 localSelectors size = 2.
	self assert: (self c2 localSelectors includesAllOf: #(#foo #bar ))
]

{ #category : #testing }
PureBehaviorTest >> testMethodCategoryReorganization [
	"self run: #testMethodCategory"

	self t1 compile: 'm1' classified: 'category1'.
	self assert: (self t5 organization categoryOfElement: #m1) = #category1.
	self assert: (self c2 organization categoryOfElement: #m1) = #category1.
	self t1 organization 
		classify: #m1
		under: #category2
		suppressIfDefault: true.
	self assert: (self t5 organization categoryOfElement: #m1) = #category2.
	self assert: (self c2 organization categoryOfElement: #m1) = #category2
]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testOwnMethodsTakePrecedenceOverTraitsMethods [
	"First create a trait with no subtraits and then
	add subtrait t1 which implements m11 as well."

	| trait |
	trait := self createTraitNamed: #TraitsTestTrait
				uses: { }.
	trait compile: 'm11 ^999'.
	self assert: trait methodDict size = 1.
	self assert: (trait methodDict at: #m11) decompileString = 'm11
	^ 999'.
	self createTraitNamed: #TraitsTestTrait uses: self t1.
	self assert: trait methodDict size = 3.
	self assert: (trait methodDict keys includesAllOf: #(#m11 #m12 #m13 )).
	self assert: (trait methodDict at: #m11) decompileString = 'm11
	^ 999'.
	self assert: (trait methodDict at: #m12) decompileString = 'm12
	^ 12'
]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testPropagationOfChangesInTraits [
	| aC2 |
	aC2 := self c2 new.
	self assert: self c2 methodDict size = 9.
	self t1 compile: 'zork ^false'.
	self assert: self c2 methodDict size = 10.
	self deny: aC2 zork.
	self t1 removeSelector: #m12.
	self assert: self c2 methodDict size = 9.
	self should: [aC2 m12] raise: MessageNotUnderstood.
	self assert: aC2 m21 = 21.
	self t2 compile: 'm21 ^99'.
	self assert: aC2 m21 = 99
]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testPropagationOfChangesInTraitsToAliasMethods [
	| anObject |
	anObject := (self 
				createClassNamed: #TraitsTestAliasTestClass
				superclass: Object
				uses: self t6) new.
	self assert: anObject m22Alias = 22.

	"test update alias method"
	self t2 compile: 'm22 ^17'.
	self assert: anObject m22Alias = 17.

	"removing original method should also remove alias method"
	self t2 removeSelector: #m22.
	self should: [anObject m22Alias] raise: MessageNotUnderstood
]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testPropagationOfChangesInTraitsToAliasMethodsWhenOriginalMethodIsExcluded [
	"Assert that alias method is updated although
	the original method is excluded from this user."

	| anObject |
	anObject := (self 
				createClassNamed: #TraitsTestAliasTestClass
				superclass: Object
				uses: self t1 @ { (#aliasM11 -> #m11) } - { #m11 }) new.
	self assert: anObject aliasM11 = 11.
	self deny: (anObject class methodDict includesKey: #m11).
	self t1 compile: 'm11 ^17'.
	self assert: anObject aliasM11 = 17
]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testPropagationWhenTraitCompositionModifications [
	"Test that the propagation mechanism works when
	setting new traitCompositions."

	self assert: self c2 methodDict size = 9.	"2 + (3+(3+2))-1"

	"removing methods"
	self createTraitNamed: #T5
		uses: self t1 + (self t2 - { #m21. #m22 }).
	self assert: self c2 methodDict size = 7.

	"adding methods"
	self createTraitNamed: #T2 uses: self t3.
	self assert: self c2 methodDict size = 10.
	self assert: (self c2 methodDict keys includesAllOf: #(#m31 #m32 #m33 ))
]

{ #category : #testing }
PureBehaviorTest >> testRemovingMethods [
	"When removing a local method, assure that the method
	from the trait is installed instead and that the users are 
	updated."

	"self run: #testRemovingMethods"

	"Classes"

	self c2 compile: 'm12 ^0' classified: #xxx.
	self assert: (self c2 includesLocalSelector: #m12).
	self c2 removeSelector: #m12.
	self deny: (self c2 includesLocalSelector: #m12).
	self assert: (self c2 selectors includes: #m12).

	"Traits"
	self t5 compile: 'm12 ^0' classified: #xxx.
	self assert: self c2 new m12 = 0.
	self t5 removeSelector: #m12.
	self deny: (self t5 includesLocalSelector: #m12).
	self assert: (self t5 selectors includes: #m12).
	self assert: self c2 new m12 = 12
]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testReshapeClass [
	"self run: #testReshapeClass"

	"Ensure that reshaping a class has no impact on its traits"

	self assert: self c2 traitCompositionString = '(T5 - {#m11})'.
	self assert: self c2 selectors sort =  #(bar foo m12 m13 m21 m22 m51 m52 m53).
	self assert: self c2 localSelectors sort =  #(bar foo).

	self c2 addInstVarName: 'foobar'.

	self assert: self c2 traitCompositionString = '(T5 - {#m11})'.
	self assert: self c2 selectors sort =  #(bar foo m12 m13 m21 m22 m51 m52 m53).
	self assert: self c2 localSelectors sort =  #(bar foo).

	self c2 removeInstVarName: 'foobar'.

	self assert: self c2 traitCompositionString = '(T5 - {#m11})'.
	self assert: self c2 selectors sort =  #(bar foo m12 m13 m21 m22 m51 m52 m53).
	self assert: self c2 localSelectors sort =  #(bar foo).

]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testSuperSends [
	| aC2 |
	aC2 := self c2 new.
	self assert: aC2 m51.
	self deny: aC2 foo.
	self deny: aC2 bar
]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testTraitCompositionModifications [
	self assert: self t6 methodDict size = 6.
	self assert: (self t6 sourceCodeAt: #m22Alias) asString = 'm22Alias ^22'.
	self t6 uses: self t2 asTraitComposition.
	self assert: self t6 methodDict size = 2.
	self deny: (self t6 methodDict includesKey: #m22Alias).
	self t6 uses: self t1 @ { (#m13Alias -> #m13) } - { #m11. #m12 } 
				+ self t2.
	self assert: self t6 methodDict size = 4.
	self assert: (self t6 methodDict keys includesAllOf: #(#m13 #m13Alias #m21 #m22 )).
	self assert: (self t6 sourceCodeAt: #m13Alias) asString = 'm13Alias ^self m12'
]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testTraitCompositionWithCycles [
	self should: [self t1 uses: self t1 asTraitComposition]
		raise: Error.
	self t2 uses: self t3 asTraitComposition.
	self should: [self t3 uses: self t5 asTraitComposition]
		raise: Error
]

{ #category : #'testing-applying trait composition' }
PureBehaviorTest >> testUpdateWhenLocalMethodRemoved [
	| aC2 |
	aC2 := self c2 new.
	self t5 compile: 'foo ^123'.
	self deny: aC2 foo.
	self c2 removeSelector: #foo.
	self assert: aC2 foo = 123
]

{ #category : #testing }
PureBehaviorTest >> traitOrClassOfSelector [
	"self run: #traitOrClassOfSelector"

	"locally defined in trait or class"

	self assert: (self t1 >> #m12) originalTraitOrClass = self t1.
	self assert: (self c1 >> #foo) originalTraitOrClass = self c1.

	"not locally defined - simple"
	self assert: (self t4 >> #m21) originalTraitOrClass = self t2.
	self assert: (self c2 >> #m51) originalTraitOrClass = self t5.

	"not locally defined - into nested traits"
	self assert: (self c2 >> #m22) originalTraitOrClass = self t2.

	"not locally defined - aliases"
	self assert: (self t6 >> #m22Alias) originalTraitOrClass = self t2.

	"class side"
	self assert: (self t2 classSide >> #m2ClassSide:) originalTraitOrClass
				= self t2 classSide.
	self assert: (self t6 classSide >> #m2ClassSide:) originalTraitOrClass
				= self t2 classSide
]
