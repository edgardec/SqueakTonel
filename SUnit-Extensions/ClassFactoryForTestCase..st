Class {
	#name : #ClassFactoryForTestCase,
	#superclass : #Object,
	#instVars : [
		'createdClasses'
	],
	#category : #'SUnit-Extensions'
}

{ #category : #cleaning }
ClassFactoryForTestCase >> cleanUp [
	| createdClassNames |
	createdClassNames := self createdClassNames.
	self deleteClasses.
	self deletePackage.
	self cleanUpChangeSetForClassNames: createdClassNames.
	self createdClasses: IdentitySet new
]

{ #category : #cleaning }
ClassFactoryForTestCase >> cleanUpChangeSetForClassNames: classeNames [
	| changeSet |
	changeSet := ChangeSet current.
	classeNames do: [:name|
		changeSet 
			removeClassChanges: name;
			removeClassChanges: name, ' class'].	
]

{ #category : #accessing }
ClassFactoryForTestCase >> createdClassNames [
	^self createdClasses collect: [:class| class name]
]

{ #category : #accessing }
ClassFactoryForTestCase >> createdClasses [
	^createdClasses
]

{ #category : #accessing }
ClassFactoryForTestCase >> createdClasses: classes [
	createdClasses := classes asIdentitySet 
]

{ #category : #accessing }
ClassFactoryForTestCase >> defaultCategory [
	^ (self packageName , '-', self defaultCategoryPostfix) asSymbol
]

{ #category : #accessing }
ClassFactoryForTestCase >> defaultCategoryPostfix [
	^ #Default
]

{ #category : #cleaning }
ClassFactoryForTestCase >> delete: aClass [
	aClass isObsolete ifTrue: [^self].
	aClass removeFromChanges.
	aClass removeFromSystemUnlogged

]

{ #category : #cleaning }
ClassFactoryForTestCase >> deleteClasses [
	self createdClasses do: [:class|
		self delete: class]
]

{ #category : #cleaning }
ClassFactoryForTestCase >> deletePackage [
	| categoriesMatchString |
	categoriesMatchString := self packageName, '-*'.
	SystemOrganization removeCategoriesMatching: categoriesMatchString
]

{ #category : #cleaning }
ClassFactoryForTestCase >> initialize [
	super initialize.
	self createdClasses: IdentitySet new
]

{ #category : #creating }
ClassFactoryForTestCase >> newClass [
	^self newSubclassOf: Object instanceVariableNames: '' classVariableNames: ''
]

{ #category : #creating }
ClassFactoryForTestCase >> newClassInCategory: category [
	^self newSubclassOf: Object instanceVariableNames: '' classVariableNames: '' category: category
]

{ #category : #creating }
ClassFactoryForTestCase >> newName [

	^String new: 23 + 22 streamContents: [ :stream |
		| random |
		stream nextPutAll: 'ClassForTestToBeDeleted'.
		random := ThreadSafeRandom value.
		"62 possible values, 5.95 bits / iteration, 22 iterations => more than 128 bits"
		22 timesRepeat: [
			stream nextPut: ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' atRandom: random) ] ]
]

{ #category : #creating }
ClassFactoryForTestCase >> newSubclassOf: aClass instanceVariableNames: ivNamesString classVariableNames:  classVarsString [ 
	^self 
		newSubclassOf: aClass 
		instanceVariableNames: ivNamesString 
		classVariableNames: classVarsString 
		category: self defaultCategoryPostfix
]

{ #category : #creating }
ClassFactoryForTestCase >> newSubclassOf: aClass instanceVariableNames: ivNamesString classVariableNames:  classVarsString category: category [
	| newClass |
	newClass := aClass 
		subclass: self newName asSymbol
		instanceVariableNames: ivNamesString 
		classVariableNames: classVarsString 
		poolDictionaries: '' 
		category: (self packageName, '-', category) asSymbol.
	self createdClasses add: newClass.
	^newClass
]

{ #category : #accessing }
ClassFactoryForTestCase >> packageName [
	^#CategoryForTestToBeDeleted
]
