Class {
	#name : #TraitCompositionTest,
	#superclass : #TraitsTestCase,
	#category : #'TraitsTests-Kernel'
}

{ #category : #'testing-basic' }
TraitCompositionTest >> testAliasCompositionsRaisesErrorBinary [

	"binary"
	self t1 compile: '= anObject'.
	self 
		shouldnt: [self t2 uses: self t1 @ { (#equals: -> #=) }]
		raise: TraitCompositionException.
	self shouldnt: [self t2 uses: self t1 @ { (#% -> #=) }]
		raise: TraitCompositionException.
	self 
		should: [self t2 uses: self t1 @ { (#equals -> #=) }]
		raise: TraitCompositionException.
	self 
		should: [self t2 uses: self t1 @ { (#equals:x: -> #=) }]
		raise: TraitCompositionException.
]

{ #category : #'testing-basic' }
TraitCompositionTest >> testAliasCompositionsRaisesErrorKeyword [

	"keyword"
	self t1 compile: 'x: a y: b z: c'.
	self 
		should: [self t2 uses: self t1 @ { (#'==' -> #x:y:z:) }]
		raise: TraitCompositionException.
	self 
		should: [self t2 uses: self t1 @ { (#x -> #x:y:z:) }]
		raise: TraitCompositionException.
	self 
		should: [self t2 uses: self t1 @ { (#x: -> #x:y:z:) }]
		raise: TraitCompositionException.
	self 
		should: [self t2 uses: self t1 @ { (#x:y: -> #x:y:z:) }]
		raise: TraitCompositionException.
	self shouldnt: 
			[self t2 uses: self t1 @ { (#myX:y:z: -> #x:y:z:) }]
		raise: TraitCompositionException.
]

{ #category : #'testing-basic' }
TraitCompositionTest >> testAliasCompositionsRaisesErrorSpecial [
	
	"alias same as selector"
	self 
		should: [self t2 uses: self t1 @ { (#m11 -> #m11) }]
		raise: TraitCompositionException.

	"same alias name used twice"
	self should: 
			[self t2 
				uses: self t1 @ { (#alias -> #m11). (#alias -> #m12) }]
		raise: TraitCompositionException.

	"aliasing an alias"
	self should: 
			[self t2 
				uses: self t1 @ { (#alias -> #m11). (#alias2 -> #alias) }]
		raise: TraitCompositionException
]

{ #category : #'testing-basic' }
TraitCompositionTest >> testAliasCompositionsRaisesErrorUnary [

"unary"
	self 
		shouldnt: [self t2 uses: self t1 @ { (#aliasM11 -> #m11) }]
		raise: TraitCompositionException.
	self 
		should: [self t2 uses: self t1 @ { (#alias: -> #m11) }]
		raise: TraitCompositionException.
	self 
		should: [self t2 uses: self t1 @ { (#alias:x:y: -> #m11) }]
		raise: TraitCompositionException.
]

{ #category : #'testing-enquiries' }
TraitCompositionTest >> testClassMethodsTakePrecedenceOverTraitsMethods [
	| keys |
	keys := Set new.
	self t4 methodDict bindingsDo: [:each | keys add: each key].
	self assert: keys size = 6.
	self 
		assert: (keys includesAllOf: #(
						#m12
						#m13
						#m13
						#m21
						#m22
						#m11
						#m42
					)).
	self assert: (self t4 methodDict at: #m11) decompileString = 'm11
	^ 41'
]

{ #category : #'testing-basic' }
TraitCompositionTest >> testCollectAsTraitComposition [

	| composition collectedComposition |
	composition := TraitComposition withAll: { self t1. self t2 }.
	collectedComposition := composition collectAsTraitComposition: [ :each | each ].
	self assert: TraitComposition equals: collectedComposition class.
	self assert: composition equals: collectedComposition
]

{ #category : #'testing-basic' }
TraitCompositionTest >> testCompositionFromArray [
	| composition |
	composition := TraitComposition withAll: { (self t1) }.
	self assert: (composition isKindOf: TraitComposition).
	self assert: (composition traits includes: self t1).
	self assert: composition traits size = 1.
	composition := TraitComposition withAll: { (self t1). self t2 }.
	self assert: (composition isKindOf: TraitComposition).
	self assert: (composition traits includes: self t1).
	self assert: (composition traits includes: self t2).
	self assert: composition traits size = 2
]

{ #category : #'testing-basic' }
TraitCompositionTest >> testEmptyTrait [
	| composition |
	composition := TraitComposition withAll: {}.
	
	self assert: (composition isKindOf: TraitComposition).
"	self assert: composition transformations isEmpty.	"
	self assert: composition traits isEmpty
]

{ #category : #'testing-basic' }
TraitCompositionTest >> testInvalidComposition [
	self shouldnt: [self t1 @ { (#a -> #b) } @ { (#x -> #y) }]
		raise: TraitCompositionException.
	self shouldnt: [(self t1 + self t2) @ { (#a -> #b) } @ { (#x -> #y) }]
		raise: TraitCompositionException.
	self shouldnt: [self t1 - { #a } - { #b }] raise: TraitCompositionException.
	self shouldnt: [self t1 + self t2 - { #a } - { #b }]
		raise: TraitCompositionException.
	self should: [(self t1 - { #x }) @ { (#a -> #b) }]
		raise: TraitCompositionException.
	self should: [(self t1 + (self t2 - { #x } @ { (#a -> #b) }))]
		raise: TraitCompositionException.
	self should: [self t1 + self t1] raise: TraitCompositionException.
	self should: [(self t1 + self t2) @ { (#a -> #b) } + self t1]
		raise: TraitCompositionException.
	self should: [self t1 @ { (#a -> #m11). (#a -> #m12) }]
		raise: TraitCompositionException.
	self should: [self t1 @ { (#a -> #m11). (#b -> #a) }]
		raise: TraitCompositionException
]

{ #category : #'testing-basic' }
TraitCompositionTest >> testPrinting [
	| composition1 composition2 |
	composition1 := ((self t1 - { #a } + (self t2 @ { (#z -> #c) } - { #b. #c }))
				+ (self t3 - { #d. #e })
				+ (self t4 @ { (#x -> #a). (#y -> #b) })).
	composition2 := (self t4 @ { (#x -> #a). (#y -> #b) }) + (self t1 - { #a }) 
				+ (self t3 - { #d. #e }) 
				+ (self t2 - { #b. #c }).
	self assertPrints: composition1 printString
		like: '(T1 - {#a}) + ((T2 @ {#z->#c}) - {#b. #c}) + (T3 - {#d. #e}) + (T4 @ {#x->#a. #y->#b})'.
	self assertPrints: composition2 printString
		like: '(T4 @ {#x->#a. #y->#b}) + (T1 - {#a}) + (T3 - {#d. #e}) + (T2 - {#b. #c})'
]

{ #category : #'testing-enquiries' }
TraitCompositionTest >> testProvidedMethodBindingsWithConflicts [
	| traitWithConflict methodDict |
	traitWithConflict := self createTraitNamed: #TraitsTestTraitWithConflict
				uses: self t1 + self t4.
	methodDict := traitWithConflict methodDict.
	self assert: methodDict size = 6.
	self 
		assert: (methodDict keys includesAllOf: #(
						#m11
						#m12
						#m13
						#m21
						#m22
						#m42
					)).
	self 
		assert: (methodDict at: #m11) decompileString = 'm11
	^ self traitConflict'
]

{ #category : #'testing-basic' }
TraitCompositionTest >> testSum [
	| composition |
	composition := self t1 + self t2 + self t3.
	self assert: (composition isKindOf: TraitComposition).
	self assert: (composition traits includes: self t1).
	self assert: (composition traits includes: self t2).
	self assert: (composition traits includes: self t3).
	self assert: composition traits size = 3
]

{ #category : #'testing-basic' }
TraitCompositionTest >> testSumWithParenthesis [
	| composition |
	composition := self t1 + (self t2 + self t3).
	self assert: (composition isKindOf: TraitComposition).
	self assert: (composition traits includes: self t1).
	self assert: (composition traits includes: self t2).
	self assert: (composition traits includes: self t3).
	self assert: composition traits size = 3.
	self assert: composition size = 3
]
