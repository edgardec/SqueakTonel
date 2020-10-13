Class {
	#name : #MCModification,
	#superclass : #MCPatchOperation,
	#instVars : [
		'obsoletion',
		'modification'
	],
	#category : #'Monticello-Patching'
}

{ #category : #'instance creation' }
MCModification class >> of: base to: target [
	^ self new initializeWithBase: base target: target
]

{ #category : #comparing }
MCModification >> = other [
	^ other isModification 
	and: [obsoletion = other obsoletion
	and: [modification = other modification]]
]

{ #category : #applying }
MCModification >> applyTo: anObject [
	anObject modifyDefinition: obsoletion to: modification
]

{ #category : #accessing }
MCModification >> baseDefinition [
	^ obsoletion
]

{ #category : #accessing }
MCModification >> definition [
	^ modification
]

{ #category : #accessing }
MCModification >> fromSource [
	^ obsoletion source
]

{ #category : #comparing }
MCModification >> hash [
	^ obsoletion hash bitXor: modification hash
]

{ #category : #initializing }
MCModification >> initializeWithBase: base target: target [
	obsoletion := base.
	modification := target.
]

{ #category : #accessing }
MCModification >> inverse [
	^ MCModification of: modification to: obsoletion
]

{ #category : #testing }
MCModification >> isClassPatch [
	^obsoletion isClassDefinition
]

{ #category : #testing }
MCModification >> isModification [
	^ true
]

{ #category : #testing }
MCModification >> isUnchangedMethod [
	"true if this is a modification of a method where only the timestamp changed"
	^ obsoletion isMethodDefinition
		and: [obsoletion source = modification source
			and: [obsoletion category = modification category] ]
]

{ #category : #accessing }
MCModification >> modification [
	^ modification
]

{ #category : #accessing }
MCModification >> obsoletion [
	^ obsoletion
]

{ #category : #accessing }
MCModification >> printAnnotations: request on: aStream [
	aStream nextPutAll: 'old: '.
	obsoletion printAnnotations: request on: aStream.
	aStream cr.
	aStream nextPutAll: 'new: '.
	modification printAnnotations: request on: aStream.
]

{ #category : #accessing }
MCModification >> summarySuffix [
	^ modification summarySuffixOver: obsoletion

]

{ #category : #accessing }
MCModification >> targetClass [
	^ obsoletion actualClass
]

{ #category : #accessing }
MCModification >> targetDefinition [
	^ modification
]

{ #category : #accessing }
MCModification >> toSource [
	^ modification source
]
