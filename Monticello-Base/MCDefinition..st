"
A MCDefinition is a model for Smalltalk code. A package snapshot (MCSnapshot) is a collection of these definitions.


"
Class {
	#name : #MCDefinition,
	#superclass : #Object,
	#classInstVars : [
		'instances'
	],
	#category : #'Monticello-Base'
}

{ #category : #'class initialization' }
MCDefinition class >> cleanUp [
	"Flush caches"

	self clearInstances.
]

{ #category : #'as yet unclassified' }
MCDefinition class >> clearInstances [

	instances := nil.
	self subclassesDo: #clearInstances
]

{ #category : #'as yet unclassified' }
MCDefinition class >> instanceLike: aDefinition [

	^(instances ifNil: [ instances := WeakSet new ])
		like: aDefinition
		ifAbsent: [ instances add: aDefinition ]
]

{ #category : #comparing }
MCDefinition >> <= other [
	^ self sortKey <= other sortKey
]

{ #category : #comparing }
MCDefinition >> = aDefinition [
	^(aDefinition isKindOf: MCDefinition) and: [self isRevisionOf: aDefinition]
]

{ #category : #accessing }
MCDefinition >> actualClass [

	^nil
]

{ #category : #accessing }
MCDefinition >> actualClassIn: anEnvironment [

	^nil
]

{ #category : #installing }
MCDefinition >> addMethodAdditionTo: aCollection [
  Transcript show: self printString.
  self load
]

{ #category : #annotations }
MCDefinition >> annotations [
	^self annotations: Preferences defaultAnnotationRequests
]

{ #category : #annotations }
MCDefinition >> annotations: requests [
	"Answer a string for an annotation pane, trying to fulfill the annotation requests.
	These might include anything that
		Preferences defaultAnnotationRequests 
	might return. Which includes anything in
		Preferences annotationInfo
	To edit these, use:"
	"Preferences editAnnotations"

	^String streamContents: [ :s | self printAnnotations: requests on: s ].
]

{ #category : #comparing }
MCDefinition >> description [
	self subclassResponsibility
]

{ #category : #comparing }
MCDefinition >> fullTimeStamp [
	^TimeStamp current
]

{ #category : #renaming }
MCDefinition >> handlePackageRename: oldPackageName to: newPackageName [
	"Overridden as necessary in subclasses."
]

{ #category : #comparing }
MCDefinition >> hash [
	^ self description hash
]

{ #category : #testing }
MCDefinition >> isClassDefinition [
	^false
]

{ #category : #testing }
MCDefinition >> isClassDefinitionExtension [
	"Answer true if this definition extends the regular class definition"
	^false
]

{ #category : #testing }
MCDefinition >> isMethodDefinition [
	^false
]

{ #category : #testing }
MCDefinition >> isOrganizationDefinition [
	^false
]

{ #category : #comparing }
MCDefinition >> isRevisionOf: aDefinition [
	^ aDefinition description = self description
]

{ #category : #comparing }
MCDefinition >> isSameRevisionAs: aDefinition [
	^ self = aDefinition
]

{ #category : #testing }
MCDefinition >> isScriptDefinition [
	^false
]

{ #category : #installing }
MCDefinition >> load [
	
]

{ #category : #installing }
MCDefinition >> loadOver: aDefinition [
	self load
	
]

{ #category : #private }
MCDefinition >> mcModel [
	"Find my WorkingCopy, use the first mcModel-capable repository in its reposigoryGroup."
	self repositoryGroup ifNotNil:
		[ : group | group repositoriesDo:
			[ : each | each mcModel ifNotNil:
				[ : mcModel | ^ mcModel ] ] ].
	^ nil
]

{ #category : #renaming }
MCDefinition >> newCategoryNameFor: categoryName givenRenameFrom: oldPackageName to: newPackageName [ 
	^ oldPackageName size < categoryName size
		ifTrue:
			[ newPackageName ,
				(categoryName
					copyFrom: oldPackageName size + 1
					to: categoryName size) ]
		ifFalse: [ newPackageName ]
]

{ #category : #installing }
MCDefinition >> postload [
]

{ #category : #installing }
MCDefinition >> postloadOver: aDefinition [
	self postload
]

{ #category : #annotations }
MCDefinition >> printAnnotations: requests on: aStream [
	"Add a string for an annotation pane, trying to fulfill the annotation requests.
	These might include anything that
		Preferences defaultAnnotationRequests 
	might return. Which includes anything in
		Preferences annotationInfo
	To edit these, use:"
	"Preferences editAnnotations"

	aStream nextPutAll: 'not yet implemented'
]

{ #category : #printing }
MCDefinition >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '(', self summary, ')'
]

{ #category : #accessing }
MCDefinition >> provisions [
	^ #()
]

{ #category : #repositories }
MCDefinition >> repositoryGroup [
	"Answer the MCRepositoryGroup from which this this object was loaded."
	^ self workingCopy ifNotNil: [ : wc | wc repositoryGroup ]
]

{ #category : #accessing }
MCDefinition >> requirements [
	^ #()
]

{ #category : #comparing }
MCDefinition >> sortKey [
	self subclassResponsibility 
]

{ #category : #printing }
MCDefinition >> summary [
	self subclassResponsibility 
]

{ #category : #printing }
MCDefinition >> summaryAndRevision [
	^self summary
]

{ #category : #printing }
MCDefinition >> summarySuffixOver: previousDefinition [
	^self source = previousDefinition source
		ifTrue: [ ' (source same but rev changed)' ]
		ifFalse: [ ' (changed)' ]
]

{ #category : #installing }
MCDefinition >> unload [
]

{ #category : #testing }
MCDefinition >> wantsToBeOutermost [
	"Outermost definitions are installed after all other definitions. In particular, this hook is crucial for the correct behavior of removal preambles. See MCDependencySorter >> #addDeferred:."

	^ false
]

{ #category : #repositories }
MCDefinition >> workingCopy [
	self subclassResponsibility
]
