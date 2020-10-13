Class {
	#name : #MCOrganizationDefinition,
	#superclass : #MCDefinition,
	#instVars : [
		'categories'
	],
	#category : #'Monticello-Modeling'
}

{ #category : #'instance creation' }
MCOrganizationDefinition class >> categories: anArray [
	^ self instanceLike: (self new categories: anArray)
]

{ #category : #testing }
MCOrganizationDefinition >> = aDefinition [
	^ (super = aDefinition)
		and: [categories = aDefinition categories]
]

{ #category : #actions }
MCOrganizationDefinition >> accept: aVisitor [
	^ aVisitor visitOrganizationDefinition: self
]

{ #category : #accessing }
MCOrganizationDefinition >> categories [
	^ categories
]

{ #category : #accessing }
MCOrganizationDefinition >> categories: anArray [
	categories := anArray
]

{ #category : #accessing }
MCOrganizationDefinition >> commonPrefix [
	| stream |
	categories isEmpty ifTrue: [^ ''].
	
	stream := String new writeStream.
	categories first withIndexDo:
		[:c :i|
		categories do:
			[:ea |
			(ea at: i ifAbsent: []) = c ifFalse: [^ stream contents]].
		stream nextPut: c].
	^ stream contents
]

{ #category : #accessing }
MCOrganizationDefinition >> description [
	^{ #organization }

]

{ #category : #actions }
MCOrganizationDefinition >> handlePackageRename: oldPackageName to: newPackageName [ 
	categories do:
		[ : each | (each beginsWith: newPackageName) ifFalse:
			[ | newCategoryName |
			newCategoryName := self
				newCategoryNameFor: each
				givenRenameFrom: oldPackageName
				to: newPackageName.
			(SystemOrganizer default categories includes: newCategoryName) ifTrue: [ SystemOrganizer default removeCategory: newCategoryName ].
			SystemOrganizer default
				renameCategory: each
				toBe: newCategoryName ] ]
]

{ #category : #testing }
MCOrganizationDefinition >> isOrganizationDefinition [
	^ true
]

{ #category : #actions }
MCOrganizationDefinition >> postloadOver: oldDefinition [
	SystemOrganization categories:
		(self
			reorderCategories: SystemOrganization categories
			original: (oldDefinition ifNil: [#()] ifNotNil: [oldDefinition categories]))
]

{ #category : #actions }
MCOrganizationDefinition >> reorderCategories: allCategories original: oldCategories [
	| first locallyAddedCategories |
	first := allCategories detect: [:ea | categories includes: ea]
		ifNone: [^ allCategories, categories].
	locallyAddedCategories := (oldCategories copyWithoutAll: categories) select: [:cat |
		(SystemOrganization listAtCategoryNamed: cat) notEmpty].
	^ 	((allCategories copyUpTo: first) copyWithoutAll: oldCategories, categories),
		categories,
		locallyAddedCategories,
		((allCategories copyAfter: first) copyWithoutAll: oldCategories, categories)

]

{ #category : #accessing }
MCOrganizationDefinition >> sortKey [
	^ '<organization>'
]

{ #category : #accessing }
MCOrganizationDefinition >> source [
	^ String streamContents:
		[:s |
		categories do: [:ea | s nextPutAll: ea] separatedBy: [s cr]]
]

{ #category : #accessing }
MCOrganizationDefinition >> summary [
	^ categories asArray printString
]

{ #category : #actions }
MCOrganizationDefinition >> unload [
	| empty |
	empty := categories select: [:ea |
		(SystemOrganization listAtCategoryNamed: ea) isEmpty].
	SystemOrganization categories:
		(SystemOrganization categories copyWithoutAll: empty)
]
