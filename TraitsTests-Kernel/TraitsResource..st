Class {
	#name : #TraitsResource,
	#superclass : #TestResource,
	#instVars : [
		'createdClassesAndTraits',
		't1',
		't2',
		't3',
		't4',
		't5',
		't6',
		'c1',
		'c2',
		'c3',
		'c4',
		'c5',
		'c6',
		'c7',
		'c8',
		'dirty'
	],
	#classVars : [
		'SetUpCount'
	],
	#category : #'TraitsTests-Kernel'
}

{ #category : #'as yet unclassified' }
TraitsResource class >> resetIfDirty [
	self current isDirty ifTrue: [self reset]
]

{ #category : #accessing }
TraitsResource >> c1 [
	^c1
]

{ #category : #accessing }
TraitsResource >> c1: anObject [
	^c1 := anObject
]

{ #category : #accessing }
TraitsResource >> c2 [
	^c2
]

{ #category : #accessing }
TraitsResource >> c2: anObject [
	^c2 := anObject
]

{ #category : #accessing }
TraitsResource >> c3 [
	^c3
]

{ #category : #accessing }
TraitsResource >> c3: anObject [
	^c3 := anObject
]

{ #category : #accessing }
TraitsResource >> c4 [
	^c4
]

{ #category : #accessing }
TraitsResource >> c4: anObject [
	^c4 := anObject
]

{ #category : #accessing }
TraitsResource >> c5 [
	^c5
]

{ #category : #accessing }
TraitsResource >> c5: anObject [
	^c5 := anObject
]

{ #category : #accessing }
TraitsResource >> c6 [
	^c6
]

{ #category : #accessing }
TraitsResource >> c6: anObject [
	^c6 := anObject
]

{ #category : #accessing }
TraitsResource >> c7 [
	^c7
]

{ #category : #accessing }
TraitsResource >> c7: anObject [
	^c7 := anObject
]

{ #category : #accessing }
TraitsResource >> c8 [
	^c8
]

{ #category : #accessing }
TraitsResource >> c8: anObject [
	^c8 := anObject
]

{ #category : #'as yet unclassified' }
TraitsResource >> categoryName [
	
	^ 'TraitsTestsTemporary'
]

{ #category : #'as yet unclassified' }
TraitsResource >> codeChangedEvent: anEvent [

	(anEvent isDoIt not
		and: [anEvent itemClass notNil
		and: [self createdClassesAndTraits includes: anEvent itemClass instanceSide]]) ifTrue: [self setDirty] 
]

{ #category : #'as yet unclassified' }
TraitsResource >> createClassNamed: aSymbol superclass: aClass uses: aTraitComposition [
	| class |
	class := aClass
		subclass: aSymbol
		uses: aTraitComposition
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''		
		category: self categoryName.
	self createdClassesAndTraits add: class.
	^class
]

{ #category : #'as yet unclassified' }
TraitsResource >> createTraitNamed: aSymbol uses: aTraitComposition [
	| trait |
	trait := Trait
		named: aSymbol
		uses: aTraitComposition
		category: self categoryName
		env: Smalltalk globals.
	self createdClassesAndTraits add: trait.
	^trait
]

{ #category : #'as yet unclassified' }
TraitsResource >> createdClassesAndTraits [
	createdClassesAndTraits ifNil: [
		createdClassesAndTraits := OrderedCollection new].
	^createdClassesAndTraits
]

{ #category : #accessing }
TraitsResource >> isDirty [
	^dirty
]

{ #category : #accessing }
TraitsResource >> setDirty [
	dirty := true
]

{ #category : #running }
TraitsResource >> setUp [

	super setUp.
	
	dirty := false.

	CurrentReadOnlySourceFiles cacheDuring: [
		SystemChangeNotifier uniqueInstance doSilently: [
			Utilities useAuthorInitials: self className during: [
				self setUpSilently]]].
]

{ #category : #running }
TraitsResource >> setUpSilently [
	"Please note, that most tests rely on this setup of traits and
	classes - and that especially the order of the definitions matters."
	"SetUpCount := SetUpCount + 1."

	self t1: (self createTraitNamed: #T1 uses: { }).
	self t1 comment: 'I am the trait T1'.
	self t2: (self createTraitNamed: #T2 uses: { }).
	self t2 compile: 'm21 ^21' classified: #cat1.
	self t2 compile: 'm22 ^22' classified: #cat2.
	self t2 classSide compile: 'm2ClassSide: a ^a'.
	self t3: (self createTraitNamed: #T3 uses: { }).
	self t3 compile: 'm31 ^31' classified: #cat1.
	self t3 compile: 'm32 ^32' classified: #cat2.
	self t3 compile: 'm33 ^33' classified: #cat3.
	self t4: (self createTraitNamed: #T4 uses: { (self t1). (self t2) }).
	self t4 compile: 'm11 ^41' classified: #catX.	"overrides T1>>m11"
	self t4 compile: 'm42 ^42' classified: #cat2.
	self t5: (self createTraitNamed: #T5 uses: self t1 + self t2).
	self t5 compile: 'm51 ^super foo' classified: #cat1.
	self t5 compile: 'm52 ^ self class bar' classified: #cat1.
	self t5 compile: 'm53 ^ self class bar' classified: #cat1.
	self t6: (self
		createTraitNamed: #T6
		uses: (self t1 + (self t2 @ { (#m22Alias -> #m22) }))).
	self c1: (
		self 
			createClassNamed: #C1
			superclass: Object
			uses: { }).
	self c1 compile: 'foo ^true' classified: #accessing.
	self t1 compile: 'm11 ^11' classified: #cat1.
	self t1 compile: 'm12 ^12' classified: #cat2.
	self t1 compile: 'm13 ^self m12' classified: #cat3.
	self c2: (self 
				createClassNamed: #C2
				superclass: self c1
				uses: self t5 - { #m11 }).
	self c2 compile: 'foo ^false' classified: #private.
	self c2 compile: 'bar ^self foo' classified: #private.
	
	self setUpTrivialRequiresFixture.
	self setUpTwoLevelRequiresFixture.
	self setUpTranslatingRequiresFixture.
		
	SystemChangeNotifier uniqueInstance notify: self ofAllSystemChangesUsing: #codeChangedEvent:
]

{ #category : #'as yet unclassified' }
TraitsResource >> setUpTranslatingRequiresFixture [
	self c6: (self 
				createClassNamed: #C6
				superclass: ProtoObject
				uses: { }).
	ProtoObject removeSubclass: self c6.
	self c6 superclass: nil.
	self c7: (self 
				createClassNamed: #C7
				superclass: self c6
				uses: { }).
	self c8: (self 
				createClassNamed: #C8
				superclass: self c7
				uses: { }).
	self c6 compile: 'foo ^self x' classified: #accessing.
	self c7 compile: 'foo ^3' classified: #accessing.
	self c7 compile: 'bar ^super foo' classified: #accessing.
	self c8 compile: 'bar ^self blah' classified: #accessing
]

{ #category : #'as yet unclassified' }
TraitsResource >> setUpTrivialRequiresFixture [
	self c3: (self 
				createClassNamed: #C3
				superclass: ProtoObject
				uses: { }).
	ProtoObject removeSubclass: self c3.
	self c3 superclass: nil.
	self c3 compile: 'foo ^self bla' classified: #accessing
]

{ #category : #'as yet unclassified' }
TraitsResource >> setUpTwoLevelRequiresFixture [
	self c4: (self 
				createClassNamed: #C4
				superclass: ProtoObject
				uses: { }).
	ProtoObject removeSubclass: self c4.
	self c4 superclass: nil.
	self c5: (self 
				createClassNamed: #C5
				superclass: self c4
				uses: { }).
	self c4 compile: 'foo ^self blew' classified: #accessing.
	self c5 compile: 'foo ^self blah' classified: #accessing
]

{ #category : #accessing }
TraitsResource >> t1 [
	^t1
]

{ #category : #accessing }
TraitsResource >> t1: anObject [
	^t1 := anObject
]

{ #category : #accessing }
TraitsResource >> t2 [
	^t2
]

{ #category : #accessing }
TraitsResource >> t2: anObject [
	^t2 := anObject
]

{ #category : #accessing }
TraitsResource >> t3 [
	^t3
]

{ #category : #accessing }
TraitsResource >> t3: anObject [
	^t3 := anObject
]

{ #category : #accessing }
TraitsResource >> t4 [
	^t4
]

{ #category : #accessing }
TraitsResource >> t4: anObject [
	^t4 := anObject
]

{ #category : #accessing }
TraitsResource >> t5 [
	^t5
]

{ #category : #accessing }
TraitsResource >> t5: anObject [
	^t5 := anObject
]

{ #category : #accessing }
TraitsResource >> t6 [
	^t6
]

{ #category : #accessing }
TraitsResource >> t6: anObject [
	^t6 := anObject
]

{ #category : #running }
TraitsResource >> tearDown [
	
	CurrentReadOnlySourceFiles cacheDuring: [
		SystemChangeNotifier uniqueInstance doSilently: [
			Utilities useAuthorInitials: self className during: [
				self tearDownSilently]]].
	
	super tearDown.
]

{ #category : #running }
TraitsResource >> tearDownSilently [
	
	SystemChangeNotifier uniqueInstance noMoreNotificationsFor: self.
	
	self createdClassesAndTraits do: 
			[:aClassOrTrait | | behaviorName | 
			behaviorName := aClassOrTrait name.
			Smalltalk at: behaviorName
				ifPresent: [:classOrTrait | classOrTrait removeFromSystem].
			ChangeSet current removeClassChanges: behaviorName].
		
	createdClassesAndTraits := self t1: (self 
						t2: (self t3: (self 
										t4: (self t5: (self 
														t6: (self c1: (self 
																		c2: (self c3: (self c4: (self c5: (self c6: (self c7: (self c8: nil)))))))))))))
]
