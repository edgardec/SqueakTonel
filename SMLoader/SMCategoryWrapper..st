"
This is a wrapper for showing the SqueakMap categories (SMCategory) using the SimpleHierarchicalListMorph in the SMLoader, see SMLoader>>categoryWrapperList.
"
Class {
	#name : #SMCategoryWrapper,
	#superclass : #ListItemWrapper,
	#category : #SMLoader
}

{ #category : #comparing }
SMCategoryWrapper >> = anObject [
	^self withoutListWrapper = anObject withoutListWrapper
]

{ #category : #converting }
SMCategoryWrapper >> asString [
	^ item name , ' (' , self numberOfObjects printString , ')'
]

{ #category : #accessing }
SMCategoryWrapper >> category [
	^item
]

{ #category : #accessing }
SMCategoryWrapper >> contents [
	^ item subCategories
		collect: [:n | self class with: n model: n]
]

{ #category : #'model access' }
SMCategoryWrapper >> getList [
	^ Array
		with: (self class with: self contents model: model)
]

{ #category : #testing }
SMCategoryWrapper >> hasContents [
	^ item hasSubCategories
]

{ #category : #comparing }
SMCategoryWrapper >> hash [
	^self withoutListWrapper hash
]

{ #category : #accessing }
SMCategoryWrapper >> help [
	^ 'The categories are structured in a tree. Packages and package releases belong to several categories. You can add one or more categories as filters and enable them in the menu.'
]

{ #category : #accessing }
SMCategoryWrapper >> model [
	^model
]

{ #category : #accessing }
SMCategoryWrapper >> numberOfObjects [
"	| total |
	total := 0.
	model allCategoriesDo: [:c |
		total := total + c objects size].
	^total"
	^item objects size
]
