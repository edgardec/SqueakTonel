"
A categorizable object can be associated with one or more SMCategories.
The relation between the categories and the SMCategorizableObject is bidirectional.
A categorizable object can also have attached resources, see SMResource.

The categories are used to classify the categorizable object for different purposes.
Package and package releases are classified in different ways, but so can resources and accounts be.

"
Class {
	#name : #SMCategorizableObject,
	#superclass : #SMObject,
	#instVars : [
		'categories',
		'resources'
	],
	#category : #'SMBase-domain'
}

{ #category : #private }
SMCategorizableObject >> addCategory: aCategory [
	"Add <aCategory> to me. If I already have it do nothing."

	categories ifNil: [categories := OrderedCollection new].
	(categories includes: aCategory) ifFalse:[
		aCategory addObject: self.
		categories add: aCategory].
	^aCategory
]

{ #category : #resources }
SMCategorizableObject >> addResource: aResource [
	"Lazily initialize the resources collection."
	
	resources ifNil: [resources := OrderedCollection new].
	aResource object: self.
	^resources add: aResource
]

{ #category : #testing }
SMCategorizableObject >> beCommunitySupported [
	self addCategory: (self map categoryWithNameBeginning: 'Community Supported')
]

{ #category : #accessing }
SMCategorizableObject >> categories [
	"Lazily initialized."

	^categories ifNil: [OrderedCollection new]
]

{ #category : #categories }
SMCategorizableObject >> categoriesDo: aBlock [
	"Evaluate aBlock for each of the categories."

	categories ifNil: [^self].
	categories do: aBlock
]

{ #category : #categories }
SMCategorizableObject >> categoryForParent: aCategory [
	"Answer one of my categories with parent <aCategory>, if I have it."

	categories ifNil: [^nil].
	^categories detect: [:cat | cat parent = aCategory ] ifNone: [nil]
]

{ #category : #accessing }
SMCategorizableObject >> communitySupportedCategory [
	^ self categories
		detect: [:each | each name = 'Community Supported']
		ifNone: []
]

{ #category : #private }
SMCategorizableObject >> delete [
	"Delete me. Disconnect me from my categories."

	super delete.
	self removeFromCategories
]

{ #category : #printing }
SMCategorizableObject >> describeCategoriesOn: aStream indent: tabs [ 
	"Show a full listing of categories and their dscription on aStream, indented by the given number of tabs."

	categories isEmptyOrNil
		ifFalse: [aStream cr;
				withAttribute: TextEmphasis bold
				do: [aStream nextPutAll: 'Categories: ']; cr.
			(self categories sorted: [:a :b | a path < b path])
				do: [:c | 
					aStream tab: tabs.
					c
						parentsDo: [:p | aStream nextPutAll: p name;
								 nextPut: $/].
					aStream nextPutAll: c name;
						 nextPutAll: ' - ';
						
						withAttributes: {TextEmphasis italic. TextIndent tabs: tabs + 1 }
						do: [aStream nextPutAll: c summary];
						 cr]]
]

{ #category : #resources }
SMCategorizableObject >> embeddedResources [
	"Return all embedded resources."
	
	^resources ifNil: [#()]
		ifNotNil: [resources select: [:r | r isEmbedded ]]
	
]

{ #category : #categories }
SMCategorizableObject >> hasCategory: aCategory [
	"Answer true if I am in it."

	^categories notNil and: [categories includes: aCategory]
]

{ #category : #categories }
SMCategorizableObject >> hasCategoryOrSubCategoryOf: aCategory [
	"Answer true if I am in aCategory or if I am in any
	of its sub categories recursively."

	aCategory allCategoriesDo: [:cat |
		(self hasCategory: cat) ifTrue: [^ true]].
	^false
]

{ #category : #testing }
SMCategorizableObject >> isCommunitySupported [
	^ self communitySupportedCategory notNil
]

{ #category : #private }
SMCategorizableObject >> removeCategory: aCategory [
	"Remove category from me if I am in it."

	(categories notNil and: [categories includes: aCategory]) ifTrue:[
		aCategory removeObject: self.
		categories remove: aCategory].
	^aCategory
]

{ #category : #private }
SMCategorizableObject >> removeFromCategories [
	"Remove me from all my categories."

	categories ifNotNil:[
		categories copy do: [:cat | self removeCategory: cat ]]
]

{ #category : #resources }
SMCategorizableObject >> removeResource: aResource [
	"Disconnect and remove the resource."
	
	aResource object: nil.
	^resources remove: aResource
]

{ #category : #accessing }
SMCategorizableObject >> resources [
	"Lazily initialized."

	^resources ifNil: [OrderedCollection new]
]
