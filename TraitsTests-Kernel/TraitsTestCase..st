Class {
	#name : #TraitsTestCase,
	#superclass : #TestCase,
	#instVars : [
		'createdClassesAndTraits'
	],
	#category : #'TraitsTests-Kernel'
}

{ #category : #'as yet unclassified' }
TraitsTestCase class >> isAbstract [

	^ self = TraitsTestCase
]

{ #category : #'as yet unclassified' }
TraitsTestCase class >> resources [
	^{TraitsResource}
]

{ #category : #utility }
TraitsTestCase >> assertPrints: aString like: anotherString [ 
	self assert: (aString copyWithout: $ )
		= (anotherString copyWithout: $ )
]

{ #category : #accessing }
TraitsTestCase >> c1 [
	^TraitsResource current c1
]

{ #category : #accessing }
TraitsTestCase >> c2 [
	^TraitsResource current c2
]

{ #category : #accessing }
TraitsTestCase >> c3 [
	^TraitsResource current c3
]

{ #category : #accessing }
TraitsTestCase >> c4 [
	^TraitsResource current c4
]

{ #category : #accessing }
TraitsTestCase >> c5 [
	^TraitsResource current c5
]

{ #category : #accessing }
TraitsTestCase >> c6 [
	^TraitsResource current c6
]

{ #category : #accessing }
TraitsTestCase >> c7 [
	^TraitsResource current c7
]

{ #category : #accessing }
TraitsTestCase >> c8 [
	^TraitsResource current c8
]

{ #category : #running }
TraitsTestCase >> categoryName [

	^ TraitsResource current categoryName
]

{ #category : #utility }
TraitsTestCase >> createClassNamed: aSymbol superclass: aClass uses: aTraitComposition [
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

{ #category : #utility }
TraitsTestCase >> createTraitNamed: aSymbol uses: aTraitComposition [
	| trait |
	trait := Trait
		named: aSymbol
		uses: aTraitComposition
		category: self categoryName
		env: Smalltalk globals.
	self createdClassesAndTraits add: trait.
	^trait
]

{ #category : #utility }
TraitsTestCase >> createdClassesAndTraits [
	createdClassesAndTraits ifNil: [
		createdClassesAndTraits := OrderedCollection new].
	^createdClassesAndTraits
]

{ #category : #private }
TraitsTestCase >> performTest [

	CurrentReadOnlySourceFiles cacheDuring: [
		Utilities useAuthorInitials: self className during: [
			self performTestSilently]].
]

{ #category : #private }
TraitsTestCase >> performTestSilently [
	"Perform the test without making too much noise."
	
	super performTest.
]

{ #category : #utility }
TraitsTestCase >> resourceClassesAndTraits [
	^TraitsResource current createdClassesAndTraits
]

{ #category : #running }
TraitsTestCase >> setUp [

	super setUp.
	self timeout: 90. "pre: This is necessary to account for the TraitsResrouce setup"

	CurrentReadOnlySourceFiles cacheDuring: [
		SystemChangeNotifier uniqueInstance doSilently: [
			Utilities useAuthorInitials: self className during: [
				self setUpSilently]]].
]

{ #category : #running }
TraitsTestCase >> setUpSilently [
	"Prepare the system without making too much noise."
]

{ #category : #accessing }
TraitsTestCase >> t1 [
	^TraitsResource current t1
]

{ #category : #accessing }
TraitsTestCase >> t2 [
	^TraitsResource current t2
]

{ #category : #accessing }
TraitsTestCase >> t3 [
	^TraitsResource current t3
]

{ #category : #accessing }
TraitsTestCase >> t4 [
	^TraitsResource current t4
]

{ #category : #accessing }
TraitsTestCase >> t5 [
	^TraitsResource current t5
]

{ #category : #accessing }
TraitsTestCase >> t6 [
	^TraitsResource current t6
]

{ #category : #running }
TraitsTestCase >> tearDown [
	
	CurrentReadOnlySourceFiles cacheDuring: [
		SystemChangeNotifier uniqueInstance doSilently: [
			Utilities useAuthorInitials: self className during: [
				self tearDownSilently]]].
	
	super tearDown.
]

{ #category : #running }
TraitsTestCase >> tearDownSilently [
	"Clean up the system without making too much noise."
	
	TraitsResource resetIfDirty.
	
	self createdClassesAndTraits do: [:aClassOrTrait | | behaviorName | 
		behaviorName := aClassOrTrait name.
		Smalltalk at: behaviorName
			ifPresent: [:classOrTrait | classOrTrait removeFromSystem].
		ChangeSet current removeClassChanges: behaviorName].
		
	createdClassesAndTraits := nil.
]
