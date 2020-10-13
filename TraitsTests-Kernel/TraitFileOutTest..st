Class {
	#name : #TraitFileOutTest,
	#superclass : #TraitsTestCase,
	#instVars : [
		'ca',
		'cb',
		'ta',
		'tb',
		'tc',
		'td'
	],
	#category : #'TraitsTests-Kernel'
}

{ #category : #running }
TraitFileOutTest >> categoryName [
	^'TraitsTestsTemporary-FileOut'
]

{ #category : #testing }
TraitFileOutTest >> fileIn: fileName [
	| prior file result |
	prior := ClassDescription traitImpl.
	[
		ClassDescription traitImpl: Trait.
		file := FileStream readOnlyFileNamed: fileName.
		result := file fileIn
	] ensure: [
		file ifNotNil:[file close].
		ClassDescription traitImpl: prior.
	].
	^result
]

{ #category : #running }
TraitFileOutTest >> setUpSilently [

	super setUpSilently.

	SystemOrganization addCategory: self categoryName.

	td := self createTraitNamed: #TD uses: {}.		
	td compile: 'd' classified: #cat1.
	tc := self createTraitNamed: #TC uses: td.		
	tc compile: 'c' classified: #cat1.
	tb := self createTraitNamed: #TB uses: td.		
	tb compile: 'b' classified: #cat1.
	ta := self createTraitNamed: #TA uses: tb + ((tc @ {#cc->#c}) - {#c}).
	ta compile: 'a' classified: #cat1.

	ca := self createClassNamed: #CA superclass: Object uses: {}.
	ca compile: 'ca' classified: #cat1.
	cb := self createClassNamed: #CB superclass: ca uses: ta.
	cb compile: 'cb' classified: #cat1.

	"make the class of cb also use tc:"
	cb class uses: ta classTrait + tc instanceVariableNames: ''.
]

{ #category : #running }
TraitFileOutTest >> tearDownSilently [

	| dir |
	dir := FileDirectory default.
	self createdClassesAndTraits, self resourceClassesAndTraits  do: [:each |
		dir deleteFileNamed: each asString , '.st' ifAbsent: []].
	dir deleteFileNamed: self categoryName , '.st' ifAbsent: [].
	SystemOrganization removeSystemCategory: self categoryName.
	ca := cb := ta := tb := tc := td := nil.

	super tearDownSilently.
]

{ #category : #testing }
TraitFileOutTest >> testCondenseChanges [
	"Tests moveChangesTo: in the face of aliases and other trait manipulations"
	| file classOrTrait originals copy |
	file := FileStream forceNewFileNamed: 'TraitFileOutTest.changes'.
	[originals := IdentityDictionary new.
	#(t1 t2 t3 t4 t5 t6 c1 c2) do:[:clsName|
		classOrTrait := self perform: clsName.
		classOrTrait methodsDo:[:each|
			originals at: each put: each getSourceFromFile.
		].
		file setToEnd.
		classOrTrait moveChangesTo: file.
		originals keysAndValuesDo:[:method :source| 
			"we need the upfront assertion to avoid a current bug 
			in #nextChunk when using out of bounds indexes"
			self assert: method filePosition < file size.
			copy := file position: method filePosition; nextChunkText.
			self assert: copy = source.
		].
	].
	] ensure:[
		TraitsResource current setDirty.
		file close. 
		FileDirectory default deleteFileNamed: file name ifAbsent:[].
	].
]

{ #category : #testing }
TraitFileOutTest >> testFileOutCategory [
	"File out whole system category, delete all classes and traits and then
	file them in again."

	"self run: #testFileOutCategory"

	SystemOrganization fileOutCategory: self categoryName.
	SystemOrganization removeSystemCategory: self categoryName.
	self deny: (Smalltalk globals keys includesAnyOf: #(CA CB TA TB TC TD)).
	
	self fileIn: self categoryName , '.st'..

	self assert: (Smalltalk globals keys includesAllOf: #(CA CB TA TB TC TD)).

	ta := Smalltalk at: #TA.
	self assert: (ta isKindOf: Trait).
	self assert: 'TB + ((TC @ {#cc->#c}) - {#c})' equals: ta traitComposition asString.
	self assert: (ta methodDict keys includesAllOf: #(a b cc)).

	cb := Smalltalk at: #CB.
	self assert: (cb isKindOf: Class).
	self assert: 'TA' equals: cb traitComposition asString.
	self assert: (cb methodDict keys includesAllOf: #(cb a b cc)).

	"test classSide traitComposition of CB"

	self assert: 'TA classTrait + TC' equals: cb classSide traitComposition asString.
	self assert: (cb classSide methodDict keys includesAllOf: #(d c))

]

{ #category : #testing }
TraitFileOutTest >> testFileOutTrait [
	"fileOut trait T6, remove it from system and then file it in again"

	"self run: #testFileOutTrait"

	| fileName |
	self t6 compile: 'localMethod: argument ^argument'.
	self t6 classSide compile: 'localClassSideMethod: argument ^argument'.
	self t6 fileOut.
	fileName := self t6 asString , '.st'.
	self resourceClassesAndTraits remove: self t6.
	self t6 removeFromSystem.
	
	self fileIn: fileName.

	self assert: (Smalltalk includesKey: #T6).
	TraitsResource current t6: (Smalltalk at: #T6).
	self resourceClassesAndTraits add: self t6.
	self assert: (self t6 isKindOf: Trait).
	self assert: 'T1 + (T2 @ {#m22Alias->#m22})' equals: self t6 traitComposition asString.
	self assert: (self t6 methodDict keys includesAllOf: #(
						#localMethod:
						#m11
						#m12
						#m13
						#m21
						#m22
						#m22Alias
					)).
	self assert: 2 equals: self t6 classSide methodDict size.
	self assert: (self t6 classSide methodDict keys includes: #localClassSideMethod:) description: 'Missing selector #localClassSideMethod:'.
	self assert: (self t6 classSide methodDict keys includes: #m2ClassSide:) description: 'Missing selector #m2ClassSide:'.
]

{ #category : #testing }
TraitFileOutTest >> testRemovingMethods [
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
