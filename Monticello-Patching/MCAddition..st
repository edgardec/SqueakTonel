Class {
	#name : #MCAddition,
	#superclass : #MCPatchOperation,
	#instVars : [
		'definition'
	],
	#category : #'Monticello-Patching'
}

{ #category : #'instance creation' }
MCAddition class >> of: aDefinition [
	^ self new intializeWithDefinition: aDefinition
]

{ #category : #comparing }
MCAddition >> = other [
	^ other isAddition and: [definition = other definition]
]

{ #category : #applying }
MCAddition >> applyTo: anObject [
	anObject addDefinition: definition
]

{ #category : #accessing }
MCAddition >> baseDefinition [
	^ nil
]

{ #category : #accessing }
MCAddition >> definition [
	^ definition
]

{ #category : #accessing }
MCAddition >> fromSource [
	^ ''
]

{ #category : #comparing }
MCAddition >> hash [
	^ definition hash
]

{ #category : #initializing }
MCAddition >> intializeWithDefinition: aDefinition [
	definition := aDefinition
]

{ #category : #accessing }
MCAddition >> inverse [
	^ MCRemoval of: definition
]

{ #category : #testing }
MCAddition >> isAddition [
	^ true
]

{ #category : #testing }
MCAddition >> isClassPatch [
	^definition isClassDefinition
]

{ #category : #accessing }
MCAddition >> sourceString [
	^(self toSource asText)
		addAttribute: TextColor red;
		yourself
]

{ #category : #accessing }
MCAddition >> summary [
	^ definition summary
]

{ #category : #accessing }
MCAddition >> targetClass [
	^definition actualClass 
]

{ #category : #accessing }
MCAddition >> targetDefinition [
	^ definition
]

{ #category : #accessing }
MCAddition >> toSource [
	^ definition source
]
