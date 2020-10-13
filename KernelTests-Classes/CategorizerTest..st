Class {
	#name : #CategorizerTest,
	#superclass : #TestCase,
	#instVars : [
		'categorizer'
	],
	#category : #'KernelTests-Classes'
}

{ #category : #running }
CategorizerTest >> setUp [
	categorizer := Categorizer defaultList: #(a b c d e).
	categorizer classifyAll: #(a b c) under: 'abc'.
	categorizer addCategory: 'unreal'.
]

{ #category : #tests }
CategorizerTest >> testClassifyNewElementNewCategory [
	categorizer classify: #f under: #nice.
	self assert: categorizer printString =
'(''as yet unclassified'' d e)
(''abc'' a b c)
(''unreal'')
(''nice'' f)
'
]

{ #category : #tests }
CategorizerTest >> testClassifyNewElementOldCategory [
	categorizer classify: #f under: #unreal.
	self assert: categorizer printString =
'(''as yet unclassified'' d e)
(''abc'' a b c)
(''unreal'' f)
'
]

{ #category : #tests }
CategorizerTest >> testClassifyOldElementNewCategory [
	categorizer classify: #e under: #nice.
	self assert: categorizer printString =
'(''as yet unclassified'' d)
(''abc'' a b c)
(''unreal'')
(''nice'' e)
'
]

{ #category : #tests }
CategorizerTest >> testClassifyOldElementOldCategory [
	categorizer classify: #e under: #unreal.
	self assert: categorizer printString =
'(''as yet unclassified'' d)
(''abc'' a b c)
(''unreal'' e)
'
]

{ #category : #tests }
CategorizerTest >> testDefaultCategoryIsTransient [
	"Test that category 'as yet unclassified' disapears when all it's elements are removed'"
	categorizer classifyAll: #(d e) under: #abc.
	self assert: categorizer printString =
'(''abc'' a b c d e)
(''unreal'')
'
]

{ #category : #tests }
CategorizerTest >> testNoSpecialCategories [

	SystemNavigation allClasses do: [:class |
		{class. class class} do: [:classOrMetaClass |
			self
				assert: (classOrMetaClass organization categories includes: Categorizer allCategory) not
				description: ('{1} must not have the all-category in its organization.' format: {class name}).
			self
				assert: (classOrMetaClass organization isEmpty or: [
					 (classOrMetaClass organization categories includes: Categorizer nullCategory) not])
				description: ('{1} must not have the null-category in its organization.' format: {class name}).]].
]

{ #category : #tests }
CategorizerTest >> testNullCategory [
	"Test that category 'as yet unclassified' disapears when all it's elements are removed'"
	| aCategorizer |
	aCategorizer := Categorizer defaultList: #().
	self assert: aCategorizer printString =
'(''as yet unclassified'')
'.
	self assert: aCategorizer categories = #('no messages').
	aCategorizer classify: #a under: #b.
	self assert: aCategorizer printString =
'(''b'' a)
'.
	self assert: aCategorizer categories = #(b).
]

{ #category : #tests }
CategorizerTest >> testRemoveEmptyCategory [
	categorizer removeCategory: #unreal.
	self assert: categorizer printString =
'(''as yet unclassified'' d e)
(''abc'' a b c)
'
]

{ #category : #tests }
CategorizerTest >> testRemoveExistingElement [
	categorizer removeElement: #a.
	self assert: categorizer printString =
'(''as yet unclassified'' d e)
(''abc'' b c)
(''unreal'')
'
]

{ #category : #tests }
CategorizerTest >> testRemoveNonEmptyCategory [
	self should: [categorizer removeCategory: #abc] raise: Error.
	self assert: categorizer printString =
'(''as yet unclassified'' d e)
(''abc'' a b c)
(''unreal'')
'
]

{ #category : #tests }
CategorizerTest >> testRemoveNonExistingCategory [
	categorizer removeCategory: #nice.
	self assert: categorizer printString =
'(''as yet unclassified'' d e)
(''abc'' a b c)
(''unreal'')
'
]

{ #category : #tests }
CategorizerTest >> testRemoveNonExistingElement [
	categorizer removeElement: #f.
	self assert: categorizer printString =
'(''as yet unclassified'' d e)
(''abc'' a b c)
(''unreal'')
'
]

{ #category : #tests }
CategorizerTest >> testRemoveThenRename [
	categorizer removeCategory: #unreal.
	categorizer renameCategory: #abc toBe: #unreal.
	self assert: categorizer printString =
'(''as yet unclassified'' d e)
(''unreal'' a b c)
'
]

{ #category : #tests }
CategorizerTest >> testUnchanged [
	self assert: categorizer printString =
'(''as yet unclassified'' d e)
(''abc'' a b c)
(''unreal'')
'
]
