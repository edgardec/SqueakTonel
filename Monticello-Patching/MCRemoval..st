Class {
	#name : #MCRemoval,
	#superclass : #MCPatchOperation,
	#instVars : [
		'definition'
	],
	#category : #'Monticello-Patching'
}

{ #category : #'instance creation' }
MCRemoval class >> of: aDefinition [
	^ self new intializeWithDefinition: aDefinition
]

{ #category : #comparing }
MCRemoval >> = other [
	^ other isRemoval and: [definition = other definition]
]

{ #category : #accessing }
MCRemoval >> applyTo: anObject [
	anObject removeDefinition: definition
]

{ #category : #accessing }
MCRemoval >> baseDefinition [
	^ definition
]

{ #category : #accessing }
MCRemoval >> definition [
	^ definition
]

{ #category : #accessing }
MCRemoval >> fromSource [
	^ definition source
]

{ #category : #comparing }
MCRemoval >> hash [
	^ definition hash
]

{ #category : #initializing }
MCRemoval >> intializeWithDefinition: aDefinition [
	definition := aDefinition
]

{ #category : #accessing }
MCRemoval >> inverse [
	^ MCAddition of: definition
]

{ #category : #testing }
MCRemoval >> isClassPatch [
	^definition isClassDefinition
]

{ #category : #testing }
MCRemoval >> isRemoval [
	^ true
]

{ #category : #accessing }
MCRemoval >> sourceString [
	^self fromSource asText
		addAttribute: TextEmphasis struckOut;
		addAttribute: TextColor blue;
		yourself
]

{ #category : #accessing }
MCRemoval >> summarySuffix [
	^ ' (removed)'
]

{ #category : #accessing }
MCRemoval >> targetClass [
	^ definition actualClass
]

{ #category : #accessing }
MCRemoval >> targetDefinition [
	^ nil
]

{ #category : #accessing }
MCRemoval >> toSource [
	^ ''
]
