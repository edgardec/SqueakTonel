"
A ClassReference is is a lightweight proxy for a Class's definition.  Allows class definitions to be viewed in MessageLists

Instance Variables
	classSymbol:		Symbol for method's class (without class keyword if meta)
	stringVersion:		the class's definition


"
Class {
	#name : #ClassReference,
	#superclass : #Object,
	#instVars : [
		'classSymbol',
		'stringVersion',
		'classIsMeta',
		'environment'
	],
	#classVars : [
		'InvalidReference'
	],
	#category : #'System-Tools'
}

{ #category : #'instance creation' }
ClassReference class >> class: aClass [
	^ self new setStandardClass: aClass
]

{ #category : #'class initialization' }
ClassReference class >> cleanUp: aggressive [

	aggressive ifTrue: [InvalidReference := nil].
]

{ #category : #'instance creation' }
ClassReference class >> invalid [
	"Returns an invalid class reference to avoid the usage of nil."
	
	^ InvalidReference ifNil: [
		InvalidReference := self new
			setClassSymbol: #NonExistentClass
			classIsMeta: false
			environment: Environment default
			stringVersion: '<The Invalid Class Reference>']
]

{ #category : #comparisons }
ClassReference >> <= anotherMethodOrClassReference [

	classSymbol < anotherMethodOrClassReference classSymbol ifTrue: [^true].
	classSymbol > anotherMethodOrClassReference classSymbol ifTrue: [^false].
	classIsMeta = anotherMethodOrClassReference classIsMeta ifFalse: [^classIsMeta not].
	"i.e. if anotherMethodOrClassReference is a MethodReference then we're < it, and so <= to it"
	^true
]

{ #category : #comparisons }
ClassReference >> = anotherMethodReference [ 
	"Answer whether the receiver and the argument represent the 
	 same object."
	^ self species == anotherMethodReference species
	   and: [self classSymbol = anotherMethodReference classSymbol
	   and: [self classIsMeta = anotherMethodReference classIsMeta
	   and: [self environment == anotherMethodReference environment]]]
]

{ #category : #accessing }
ClassReference >> actualClass [ 
	| actualClass |
	environment ifNil: [^ nil].
	actualClass := environment at: classSymbol ifAbsent: [^nil].
	^classIsMeta ifTrue: [actualClass theMetaClass] ifFalse: [actualClass]
]

{ #category : #converting }
ClassReference >> asCodeReference [

	^ self
]

{ #category : #converting }
ClassReference >> asString [

	^(stringVersion ifNil: [ self stringVersionDefault ]) asString
]

{ #category : #accessing }
ClassReference >> asStringOrText [

	^stringVersion
]

{ #category : #accessing }
ClassReference >> classIsMeta [

	^classIsMeta
]

{ #category : #accessing }
ClassReference >> classSymbol [
	^classSymbol
]

{ #category : #accessing }
ClassReference >> compiledMethod [
	^nil
]

{ #category : #accessing }
ClassReference >> environment [

	^ environment
]

{ #category : #comparisons }
ClassReference >> hash [
	"Answer a SmallInteger whose value is related to the receiver's  
	identity."
	^ (self species hash bitXor: self classSymbol hash)
		bitXor: self environment hash
]

{ #category : #testing }
ClassReference >> isClassReference [

	^ true
]

{ #category : #testing }
ClassReference >> isMethodReference [

	^ false
]

{ #category : #testing }
ClassReference >> isValid [

	^ self actualClass notNil
]

{ #category : #printing }
ClassReference >> printOn: aStream [
	| actualClass |
	"Print the receiver on a stream"
	actualClass := classSymbol asString.
	classIsMeta ifTrue: [actualClass := actualClass, ' class'].
	super printOn: aStream.
	aStream nextPutAll: ' ', actualClass
]

{ #category : #setting }
ClassReference >> setClassAndSelectorIn: csBlock [

	^csBlock value: self actualClass value: #Definition
]

{ #category : #'initialize-release' }
ClassReference >> setClassSymbol: classSym classIsMeta: isMeta environment: anEnvironment stringVersion: aString [ 

	classSymbol := classSym.
	classIsMeta := isMeta.
	stringVersion := aString.
	environment := anEnvironment
]

{ #category : #'initialize-release' }
ClassReference >> setClassSymbol: classSym classIsMeta: isMeta stringVersion: aString [ 

	classSymbol := classSym.
	classIsMeta := isMeta.
	stringVersion := aString.
]

{ #category : #'initialize-release' }
ClassReference >> setStandardClass: aClass [

	self
		setClassSymbol:  aClass theNonMetaClass name
		classIsMeta: aClass isMeta
		environment: aClass environment
		stringVersion: aClass name, ' (definition)'
]

{ #category : #queries }
ClassReference >> sourceString [
	^self actualClass definition
]

{ #category : #accessing }
ClassReference >> stringVersion [

	^stringVersion
]

{ #category : #accessing }
ClassReference >> stringVersion: aString [

	stringVersion := aString
]

{ #category : #accessing }
ClassReference >> stringVersionDefault [

	^classSymbol, (classIsMeta ifTrue: [ ' class' ] ifFalse: [''])  
]
