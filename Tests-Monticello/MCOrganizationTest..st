Class {
	#name : #MCOrganizationTest,
	#superclass : #MCTestCase,
	#category : #'Tests-Monticello'
}

{ #category : #tests }
MCOrganizationTest >> testReordering [
	|dec cats newCats |
	dec := MCOrganizationDefinition categories: #(A B C).
	cats := #(X Y B Z C A Q).
	newCats := dec reorderCategories: cats original: #(B C A).
	self assert: newCats asArray = #(X Y A B C Z Q).
]

{ #category : #tests }
MCOrganizationTest >> testReorderingWithNoCategoriesInVersion [
	|dec cats newCats |
	dec := MCOrganizationDefinition categories: #().
	cats := #(X Y B Z C A Q).
	newCats := dec reorderCategories: cats original: #().
	self assert: newCats asArray = cats.
]

{ #category : #tests }
MCOrganizationTest >> testReorderingWithRemovals [
	|dec cats newCats |
	dec := MCOrganizationDefinition categories: #(A B C).
	cats := #(X Y B Z C A Q).
	newCats := dec reorderCategories: cats original: #(Y B C A Q).
	self assert: newCats asArray = #(X A B C Z).
]
