Class {
	#name : #MCPatchOperation,
	#superclass : #Object,
	#category : #'Monticello-Patching'
}

{ #category : #comparing }
MCPatchOperation >> <= other [
	^ self definition <= other definition
]

{ #category : #accessing }
MCPatchOperation >> annotations [
	^self annotations: Preferences defaultAnnotationRequests
]

{ #category : #accessing }
MCPatchOperation >> annotations: requests [
	"Answer a string for an annotation pane, trying to fulfill the annotation requests.
	These might include anything that
		Preferences defaultAnnotationRequests 
	might return. Which includes anything in
		Preferences annotationInfo
	To edit these, use:"
	"Preferences editAnnotations"

	^String streamContents: [ :s | self printAnnotations: requests on: s ].
]

{ #category : #accessing }
MCPatchOperation >> definition [
	^ self subclassResponsibility 
]

{ #category : #accessing }
MCPatchOperation >> inverse [
	self subclassResponsibility
]

{ #category : #testing }
MCPatchOperation >> isAddition [
	^ false
]

{ #category : #testing }
MCPatchOperation >> isClassPatch [
	^false
]

{ #category : #testing }
MCPatchOperation >> isModification [
	^ false
]

{ #category : #testing }
MCPatchOperation >> isRemoval [
	^ false
]

{ #category : #testing }
MCPatchOperation >> isUnchangedMethod [
	"true if this is a modification of a method where only the timestamp changed"
	^false
]

{ #category : #accessing }
MCPatchOperation >> prefixForOperation: aSymbol [
	aSymbol == #insert ifTrue: [^ '+'].
	aSymbol == #remove ifTrue: [^ '-'].
	^ ' '
]

{ #category : #accessing }
MCPatchOperation >> printAnnotations: requests on: aStream [
	"Add a string for an annotation pane, trying to fulfill the annotation requests.
	These might include anything that
		Preferences defaultAnnotationRequests 
	might return. Which includes anything in
		Preferences annotationInfo
	To edit these, use:"
	"Preferences editAnnotations"

	self definition printAnnotations: requests on: aStream.
]

{ #category : #accessing }
MCPatchOperation >> source [
	^ self sourceText
]

{ #category : #accessing }
MCPatchOperation >> sourceString [
	^self sourceText asString
]

{ #category : #accessing }
MCPatchOperation >> sourceText [

	^(self isClassPatch
		ifFalse: [ TextDiffBuilder ]
		ifTrue: [ ClassDiffBuilder ])
			buildDisplayPatchFrom: self fromSource
			to: self toSource
			inClass: self targetClass
			prettyDiffs: (
				Preferences diffsWithPrettyPrint and: [
					self targetClass notNil and: [
					self isClassPatch not ] ])
]

{ #category : #accessing }
MCPatchOperation >> summary [
	^ self definition summary, self summarySuffix
]

{ #category : #accessing }
MCPatchOperation >> summaryAndRevision [
	^ self definition summaryAndRevision, self summarySuffix
]

{ #category : #accessing }
MCPatchOperation >> summarySuffix [
	^ ''
]

{ #category : #accessing }
MCPatchOperation >> targetClass [
	self subclassResponsibility.
]
