Class {
	#name : #MCVersionLoader,
	#superclass : #Object,
	#instVars : [
		'versions'
	],
	#category : #'Monticello-Loading'
}

{ #category : #loading }
MCVersionLoader class >> loadVersion: aVersion [
	self new
		addVersion: aVersion;
		load
]

{ #category : #'instance creation' }
MCVersionLoader class >> new [
	^ self basicNew initialize
]

{ #category : #loading }
MCVersionLoader >> addDependency: aDependency [
	| dep |
	aDependency isCurrent ifTrue: [^ self].
	(self depAgeIsOk: aDependency) ifFalse: [^ self].
	dep := aDependency resolve.
	dep
		ifNil: [self confirmMissingDependency: aDependency]
		ifNotNil: [(versions includes: dep) ifFalse: [self addVersion: dep]]
]

{ #category : #loading }
MCVersionLoader >> addVersion: aVersion [
	aVersion dependencies do: [ :ea | self addDependency: ea].
	versions add: aVersion.

]

{ #category : #checking }
MCVersionLoader >> checkForModifications [
	| modifications |
	modifications := versions select: [:ea | ea package workingCopy modified].
	modifications isEmpty ifFalse: [self warnAboutLosingChangesTo: modifications].
]

{ #category : #checking }
MCVersionLoader >> checkIfDepIsOlder: aDependency [
	^ aDependency isOlder not 
		or: [self confirm: 'load older dependency ', aDependency versionInfo name , '?']
]

{ #category : #checking }
MCVersionLoader >> confirmMissingDependency: aDependency [
	| name |
	name := aDependency versionInfo name.
	(self confirm: 'Can''t find dependency ', name, '. ignore?')
		ifFalse: [self error: 'Can''t find dependency ', name]
]

{ #category : #checking }
MCVersionLoader >> depAgeIsOk: aDependency [
	^ aDependency isOlder not 
		or: [self confirm: 'load older dependency ', aDependency versionInfo name , '?']
]

{ #category : #'initialize-release' }
MCVersionLoader >> initialize [
	versions := OrderedCollection new
]

{ #category : #loading }
MCVersionLoader >> load [
	| loader |
	self checkForModifications.
	loader := MCPackageLoader new.
	versions do: [:ea |
		loader appendToPreamble: (String streamContents: [:s | ea logLoadingOn: s]).
		ea canOptimizeLoading
			ifTrue: [ea patch applyTo: loader]
			ifFalse: [loader updatePackage: ea package withSnapshot: ea snapshot]].
	loader loadWithNameLike: versions first info name.
	versions do: [:ea | ea workingCopy loaded: ea]
]

{ #category : #checking }
MCVersionLoader >> warnAboutLosingChangesTo: versionCollection [
	self notify: (String streamContents: [:s |
		s nextPutAll: 'You are about to load new versions of the following packages that have unsaved changes in the image.  If you continue, you will lose these changes.'; cr.
		versionCollection do:
			[:ea |
			s cr; space; space; nextPutAll: ea package name]])
]
