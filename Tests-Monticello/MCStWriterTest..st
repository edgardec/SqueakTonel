Class {
	#name : #MCStWriterTest,
	#superclass : #MCTestCase,
	#instVars : [
		'stream',
		'writer'
	],
	#category : #'Tests-Monticello'
}

{ #category : #asserting }
MCStWriterTest >> assertAllChunksAreWellFormed [
	stream reset.
	stream 
		untilEnd: [self assertChunkIsWellFormed: stream nextChunk]
		displayingProgress: 'Checking syntax...'
]

{ #category : #asserting }
MCStWriterTest >> assertChunkIsWellFormed: chunk [
	self class newParser
		parse: chunk readStream 
		class: UndefinedObject 
		noPattern: true
		notifying: nil
		ifFail: [self assert: false]
]

{ #category : #asserting }
MCStWriterTest >> assertContentsOf: strm match: expected [ 
	| actual |
	actual := strm contents.
	self assert: actual size = expected size.
	actual with: expected do: [:a :e | self assert: a = e]
]

{ #category : #asserting }
MCStWriterTest >> assertMethodChunkIsWellFormed: chunk [
	self class newParser
		parse: chunk readStream 
		class: UndefinedObject 
		noPattern: false
		notifying: nil
		ifFail: [self assert: false]
]

{ #category : #data }
MCStWriterTest >> expectedClassDefinitionA [
 ^ '
MCMock subclass: #MCMockClassA
	instanceVariableNames: ''ivar''
	classVariableNames: ''CVar''
	poolDictionaries: ''''
	category: ''Tests-Monticello-Mocks''!

!MCMockClassA commentStamp: ''cwp 8/10/2003 16:43'' prior: 0!
This is a mock class. The Monticello tests manipulated it to simulate a developer modifying code in the image.!
'
]

{ #category : #data }
MCStWriterTest >> expectedClassDefinitionB [
 ^ '
MCMock subclass: #MCMockClassB
	instanceVariableNames: ''ivarb''
	classVariableNames: ''CVar''
	poolDictionaries: ''MCMockAPoolDictionary''
	category: ''Tests-Monticello-Mocks''!

MCMockClassB class
	instanceVariableNames: ''ciVar''!

!MCMockClassB commentStamp: '''' prior: 0!
This comment has a bang!! Bang!! Bang!!!
'
]

{ #category : #data }
MCStWriterTest >> expectedClassMethodDefinition [
	^ '
!MCMockClassA class methodsFor: ''as yet unclassified'' stamp: ''ab 7/7/2003 23:21''!
one

	^ 1! !
'
]

{ #category : #data }
MCStWriterTest >> expectedInitializerA [
	^ 'MCMockClassA initialize'
]

{ #category : #data }
MCStWriterTest >> expectedMethodDefinition [
	^ '
!MCMockClassA methodsFor: ''numeric'' stamp: ''cwp 8/2/2003 17:26''!
one
	^ 1! !
'
]

{ #category : #data }
MCStWriterTest >> expectedMethodDefinitionWithBangs [
	^'
!MCStWriterTest methodsFor: ''data'' stamp: ''ar 1/4/2010 18:03''!
methodWithBangs
	^ ''
	^ ReadStream on: 
''''MCRevisionInfo packageName: ''''MonticelloCompatibilityTest''''!!!!
MCOrganizationDeclaration categories: 
  #(
  ''''Tests-Monticello-Mocks'''')!!!!

MCClassDeclaration
  name: #MCMockClassD
  superclassName: #Object
  category: #''''Tests-Monticello-Mocks''''
  instVarNames: #()
  comment: ''''''''!!!!

MCMethodDeclaration className: #MCMockClassD selector: #one category: #''''as yet unclassified'''' timeStamp: ''''cwp 7/8/2003 21:21'''' source: 
''''one
	^ 1''''!!!!
''''
''
! !
'
]

{ #category : #data }
MCStWriterTest >> expectedOrganizationDefinition [
	^ 'SystemOrganization addCategory: ''Tests-MonticelloMocks''!
'
]

{ #category : #data }
MCStWriterTest >> methodWithBangs [
	^ '
	^ ReadStream on: 
''MCRevisionInfo packageName: ''MonticelloCompatibilityTest''!!
MCOrganizationDeclaration categories: 
  #(
  ''Tests-Monticello-Mocks'')!!

MCClassDeclaration
  name: #MCMockClassD
  superclassName: #Object
  category: #''Tests-Monticello-Mocks''
  instVarNames: #()
  comment: ''''!!

MCMethodDeclaration className: #MCMockClassD selector: #one category: #''as yet unclassified'' timeStamp: ''cwp 7/8/2003 21:21'' source: 
''one
	^ 1''!!
''
'

]

{ #category : #running }
MCStWriterTest >> setUp [
	stream := RWBinaryOrTextStream on: String new.
	writer := MCStWriter on: stream.

]

{ #category : #running }
MCStWriterTest >> tearDown [

	SystemOrganizer default removeEmptyCategories.
	super tearDown	
]

{ #category : #tests }
MCStWriterTest >> testClassDefinitionA [
	writer visitClassDefinition: (self mockClassA asClassDefinition).
	self assertContentsOf: stream match: self expectedClassDefinitionA.
	stream reset.
	2 timesRepeat: [self assertChunkIsWellFormed: stream nextChunk]
]

{ #category : #tests }
MCStWriterTest >> testClassDefinitionB [
	writer visitClassDefinition: (self mockClassB asClassDefinition).
	self assertContentsOf: stream match: self expectedClassDefinitionB.
	
]

{ #category : #tests }
MCStWriterTest >> testClassMethodDefinition [
	writer visitMethodDefinition: (MethodReference class: self mockClassA class selector: #one) 									asMethodDefinition.
	self assertContentsOf: stream match: self expectedClassMethodDefinition.
	stream reset.
	self assert: stream nextChunk isAllSeparators.
	self assertChunkIsWellFormed: stream nextChunk.
	self assertMethodChunkIsWellFormed: stream nextChunk.
	self assert: stream nextChunk isAllSeparators 
]

{ #category : #tests }
MCStWriterTest >> testInitializerDefinition [
	|chunk lastChunk|
	writer writeSnapshot: self mockSnapshot.
	stream reset.
	[stream atEnd] whileFalse:
		[chunk := stream nextChunk.
		chunk isAllSeparators ifFalse: [lastChunk := chunk]].
	self assertContentsOf: lastChunk readStream match: self expectedInitializerA
]

{ #category : #tests }
MCStWriterTest >> testMethodDefinition [
	writer visitMethodDefinition: (MethodReference class: self mockClassA selector: #one) 									asMethodDefinition.
	self assertContentsOf: stream match: self expectedMethodDefinition.
	stream reset.
	self assert: stream nextChunk isAllSeparators.
	self assertChunkIsWellFormed: stream nextChunk.
	self assertMethodChunkIsWellFormed: stream nextChunk.
	self assert: stream nextChunk isAllSeparators 
]

{ #category : #tests }
MCStWriterTest >> testMethodDefinitionWithBangs [
	writer visitMethodDefinition: (MethodReference 
									class: self class 
									selector: #methodWithBangs) asMethodDefinition.
	self assertContentsOf: stream match: self expectedMethodDefinitionWithBangs.
	stream reset.
	self assert: stream nextChunk isAllSeparators.
	self assertChunkIsWellFormed: stream nextChunk.
	self assertMethodChunkIsWellFormed: stream nextChunk.
	self assert: stream nextChunk isAllSeparators 
]

{ #category : #tests }
MCStWriterTest >> testOrganizationDefinition [
	| definition |
	definition := MCOrganizationDefinition categories: 
					(self mockPackage packageInfo systemCategories).
	writer visitOrganizationDefinition: definition.
	self assertContentsOf: stream match: self expectedOrganizationDefinition.
	self assertAllChunksAreWellFormed.
]
