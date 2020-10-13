Class {
	#name : #MCSnapshotBrowserTest,
	#superclass : #MCTestCase,
	#instVars : [
		'model',
		'morph',
		'originalAnnotationPanePref'
	],
	#category : #'Tests-Monticello'
}

{ #category : #private }
MCSnapshotBrowserTest >> allCategories [
	
	^{ 
		model extensionsCategory.
		self mockCategoryName },
		MCSnapshotResource mockPackage packageInfo systemCategories
]

{ #category : #private }
MCSnapshotBrowserTest >> allMethods [
	^ MCSnapshotResource current definitions
		select: [:def | def isMethodDefinition]
		thenCollect: [:def | def selector]		
]

{ #category : #private }
MCSnapshotBrowserTest >> allProtocols [
	^ MCSnapshotResource current definitions
		select: [:def | def isMethodDefinition]
		thenCollect: [:def | def category]		
]

{ #category : #morphic }
MCSnapshotBrowserTest >> annotationTextMorph [
	^ (self morphsOfClass: TextMorph) first
]

{ #category : #asserting }
MCSnapshotBrowserTest >> assertAListIncludes: anArrayOfStrings [
	self assert: (self listMorphs 
			anySatisfy: [:m | m getList includesAllOf: anArrayOfStrings]).
]

{ #category : #asserting }
MCSnapshotBrowserTest >> assertAListMatches: strings [
	| listMorphs |
	listMorphs := self listMorphs.
	self assert: (listMorphs 
		anySatisfy: [:m | | list |
			list := m getList. (list size = strings size) and: [list includesAllOf: strings]])
]

{ #category : #asserting }
MCSnapshotBrowserTest >> assertButtonExists: aString [
	self assert: (self buttonMorphs anySatisfy: [:m | m label = aString])
]

{ #category : #asserting }
MCSnapshotBrowserTest >> assertButtonOn: aString [
	self assert: (self findButtonWithLabel: aString) getModelState.
	
]

{ #category : #asserting }
MCSnapshotBrowserTest >> assertTextIs: aString [
	self assert: self textMorph contents = aString.
]

{ #category : #morphic }
MCSnapshotBrowserTest >> buildWindow [

	Smalltalk at: #ToolBuilder ifPresent: [:tb | 
		morph := tb build: model. 
		^self ].
	morph := model buildWindow.
]

{ #category : #morphic }
MCSnapshotBrowserTest >> buttonMorphs [
	^ self morphsOfClass: PluggableButtonMorph
]

{ #category : #private }
MCSnapshotBrowserTest >> classABooleanMethods [
	^ #(falsehood moreTruth truth)
]

{ #category : #private }
MCSnapshotBrowserTest >> classAClassProtocols [
	^ self protocolsForClass: self mockClassA class.
]

{ #category : #private }
MCSnapshotBrowserTest >> classAComment [
	^ self mockClassA organization classComment.
]

{ #category : #private }
MCSnapshotBrowserTest >> classADefinitionString [
	^ self mockClassA definition
]

{ #category : #private }
MCSnapshotBrowserTest >> classAProtocols [
	^ self protocolsForClass: self mockClassA.
]

{ #category : #simulating }
MCSnapshotBrowserTest >> clickOnButton: aString [
	(self findButtonWithLabel: aString) performAction.
]

{ #category : #simulating }
MCSnapshotBrowserTest >> clickOnListItem: aString [
	| listMorph |
	listMorph := self findListContaining: aString.
	listMorph changeModelSelection: (listMorph getList indexOf: aString).
]

{ #category : #private }
MCSnapshotBrowserTest >> definedClasses [
	^ MCSnapshotResource current definitions 
		select: [:def | def isClassDefinition] 
		thenCollect: [:def | def className].
]

{ #category : #asserting }
MCSnapshotBrowserTest >> denyAListHasSelection: aString [
	self deny: (self listMorphs 
			anySatisfy: [:m | m selection = aString])
]

{ #category : #asserting }
MCSnapshotBrowserTest >> denyAListIncludesAnyOf: anArrayOfStrings [
	self deny: (self listMorphs 
			anySatisfy: [:m | m getList includesAnyOf: anArrayOfStrings])
]

{ #category : #asserting }
MCSnapshotBrowserTest >> denyButtonOn: aString [
	self deny: (self findButtonWithLabel: aString) getModelState.
	
]

{ #category : #private }
MCSnapshotBrowserTest >> falsehoodMethodSource [
	^ 'falsehood
	^ false'
]

{ #category : #morphic }
MCSnapshotBrowserTest >> findButtonWithLabel: aString [
	^ self buttonMorphs detect: [:m | m label = aString]
]

{ #category : #morphic }
MCSnapshotBrowserTest >> findListContaining: aString [
	^ self listMorphs detect: [:m | m getList includes: aString]
]

{ #category : #morphic }
MCSnapshotBrowserTest >> listMorphs [
	^ self morphsOfClass: PluggableListMorph
]

{ #category : #morphic }
MCSnapshotBrowserTest >> morphsOfClass: aMorphClass [
	| morphs |
	morphs := OrderedCollection new.
	morph allMorphsDo: [:m | (m isKindOf: aMorphClass) ifTrue: [morphs add: m]].
	^ morphs
]

{ #category : #private }
MCSnapshotBrowserTest >> protocolsForClass: aClass [
	| protocols |
	protocols := aClass organization categories.
	protocols size > 1 ifTrue: [protocols := protocols copyWith: '-- all --'].
	^ protocols.
]

{ #category : #selecting }
MCSnapshotBrowserTest >> selectMockClassA [
	self clickOnListItem: self mockCategoryName.
	self clickOnListItem: 'MCMockClassA'.
	
]

{ #category : #running }
MCSnapshotBrowserTest >> setUp [
	"to not disturb the tests"
	originalAnnotationPanePref := Preferences annotationPanes.
	Preferences disable: #annotationPanes.
	model := MCSnapshotBrowser forSnapshot: MCSnapshotResource current snapshot.
	self buildWindow
]

{ #category : #running }
MCSnapshotBrowserTest >> tearDown [
	originalAnnotationPanePref ifTrue: [Preferences enable: #annotationPanes].
	super tearDown.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testAnnotationPane [
	| oldPref |
	oldPref := Preferences annotationPanes.

	Preferences disable: #annotationPanes.
	self buildWindow.
	self assert: (self morphsOfClass: TextMorph) size = 1.

	Preferences enable: #annotationPanes.
	self buildWindow.
	self assert: (self morphsOfClass: TextMorph) size = 2.

	Preferences setPreference: #annotationPanes toValue: oldPref
]

{ #category : #tests }
MCSnapshotBrowserTest >> testCategorySelected [
	self clickOnListItem: self mockCategoryName.
	
	self assertAListMatches: self allCategories.
	self assertAListMatches: self definedClasses.
	self denyAListIncludesAnyOf: self allProtocols.
	self denyAListIncludesAnyOf: self allMethods.
	self assertTextIs: ''.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testClassSelected [
	self selectMockClassA.
	
	self assertAListMatches: self allCategories.
	self assertAListMatches: self definedClasses.
	self assertAListMatches: self classAProtocols.
	self denyAListIncludesAnyOf: self allMethods.
	self assertTextIs: self classADefinitionString.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testClassSideClassSelected [
	self clickOnButton: 'class'.
	self selectMockClassA.
	
	self assertAListMatches: self allCategories.
	self assertAListMatches: self definedClasses.
	self assertAListMatches: self classAClassProtocols.
	self denyAListIncludesAnyOf: self allMethods.
	self assertTextIs: self classADefinitionString.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testComment [
	self clickOnButton: '?'.
	self assertTextIs: ''.
	
	self clickOnListItem: self mockCategoryName.
	self assertTextIs: ''.
	
	self clickOnListItem: 'MCMockClassA'.
	self assertTextIs: self classAComment.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testFourColumns [
	self assert: self listMorphs size = 4.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testMethodIsCleared [
	self clickOnListItem: self mockCategoryName.
	self clickOnListItem: 'MCMockClassA'.
	self clickOnListItem: 'boolean'.
	self clickOnListItem: 'falsehood'.
	self clickOnListItem: '-- all --'.
	
	self denyAListHasSelection: 'falsehood'.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testMethodSelected [
	self clickOnListItem: self mockCategoryName.
	self clickOnListItem: 'MCMockClassA'.
	self clickOnListItem: 'boolean'.
	self clickOnListItem: 'falsehood'.
	
	self assertAListMatches: self allCategories.
	self assertAListMatches: self definedClasses.
	self assertAListMatches: self classAProtocols.
	self assertAListMatches: self classABooleanMethods.
	self assertTextIs: self falsehoodMethodSource.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testNoSelection [
	self assertAListMatches: self allCategories.
	self denyAListIncludesAnyOf: self definedClasses.
	self denyAListIncludesAnyOf: self allProtocols.
	self denyAListIncludesAnyOf: self allMethods.
	"and if there I need to see the packages scripts (or none)"
	self assertTextIs: '(package defines no scripts)'.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testProtocolIsCleared [
	self clickOnListItem: self mockCategoryName.
	self clickOnListItem: 'MCMockASubclass'.
	self clickOnListItem: 'as yet unclassified'.
	self clickOnListItem: 'MCMockClassA'.
	
	self denyAListHasSelection: 'as yet unclassified'.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testProtocolSelected [
	self clickOnListItem: self mockCategoryName.
	self clickOnListItem: 'MCMockClassA'.
	self clickOnListItem: 'boolean'.
	
	self assertAListMatches: self allCategories.
	self assertAListMatches: self definedClasses.
	self assertAListMatches: self classAProtocols.
	self assertAListMatches: self classABooleanMethods.
	self assertTextIs: ''.		
]

{ #category : #tests }
MCSnapshotBrowserTest >> testTextPane [
	"This shouldn't raise an exception."
	self textMorph.
]

{ #category : #tests }
MCSnapshotBrowserTest >> testThreeButtons [
	self assertButtonExists: 'instance'.
	self assertButtonExists: '?'.
	self assertButtonExists: 'class'.
]

{ #category : #morphic }
MCSnapshotBrowserTest >> textMorph [
	^ (self morphsOfClass: TextMorph) last
]
