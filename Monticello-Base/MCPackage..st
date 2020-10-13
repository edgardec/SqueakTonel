"
MCPackage uses PackageInfo to find out which methods and classes belong to a package.



"
Class {
	#name : #MCPackage,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #'Monticello-Base'
}

{ #category : #'instance creation' }
MCPackage class >> named: aString [
	^ self new name: aString
]

{ #category : #testing }
MCPackage >> = other [
	^ other species = self species and: [other name sameAs: name]
]

{ #category : #testing }
MCPackage >> hasWorkingCopy [
	^ MCWorkingCopy registry includesKey: self
]

{ #category : #testing }
MCPackage >> hash [
	^ name asLowercase hash
]

{ #category : #environments }
MCPackage >> inEnvironment: anEnvironment [
	"Answer a decorator for me that activates anEnvironment for certain operations."
	^ MCPackageInEnvironment decorating: self in: anEnvironment
]

{ #category : #accessing }
MCPackage >> name [
	^ name
]

{ #category : #accessing }
MCPackage >> name: aString [
	name := aString
]

{ #category : #accessing }
MCPackage >> packageInfo [
	"Activate my working copy's environment so the PackageInfo is added to the
	correct EnvironmentInfo's packages."
	| getPackageInfo |
	getPackageInfo := [PackageInfo named: name].
	^ self hasWorkingCopy
		ifTrue: [self workingCopy withEnvironmentActiveDo: getPackageInfo]
		ifFalse: getPackageInfo
]

{ #category : #printing }
MCPackage >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: name;
		nextPut: $)
]

{ #category : #'input\/output' }
MCPackage >> snapshot [
	| packageInfo definitions categories |
	packageInfo := self packageInfo.
	definitions := OrderedCollection new.
	categories := packageInfo systemCategories.
	categories isEmpty ifFalse: [ definitions add: (MCOrganizationDefinition categories: categories) ].
	CurrentReadOnlySourceFiles cacheDuring: [
		packageInfo methods do: [:ea | definitions add: ea asMethodDefinition] displayingProgress: 'Snapshotting methods...'.
		(packageInfo respondsTo: #overriddenMethods) ifTrue:
			[packageInfo overriddenMethods
				do: [:ea | definitions add:
						(packageInfo changeRecordForOverriddenMethod: ea) asMethodDefinition]
				displayingProgress: 'Searching for overrides...'].
		packageInfo classes do: [:ea | definitions addAll: ea classDefinitions] displayingProgress: 'Snapshotting classes...' ].
	(packageInfo respondsTo: #hasPreamble) ifTrue: [
		packageInfo hasPreamble ifTrue: [definitions add: (MCPreambleDefinition from: packageInfo)].
		packageInfo hasPostscript ifTrue: [definitions add: (MCPostscriptDefinition from: packageInfo)].
		packageInfo hasPreambleOfRemoval ifTrue: [definitions add: (MCRemovalPreambleDefinition from: packageInfo)].
		packageInfo hasPostscriptOfRemoval ifTrue: [definitions add: (MCRemovalPostscriptDefinition from: packageInfo)]]. 
	^ MCSnapshot fromDefinitions: definitions

]

{ #category : #'input\/output' }
MCPackage >> storeOn: aStream [
	aStream
		nextPutAll: 'MCPackage';
		space; nextPutAll: 'named: '; store: name.
]

{ #category : #'input\/output' }
MCPackage >> unload [
	^ self workingCopy unload
]

{ #category : #accessing }
MCPackage >> workingCopy [
	^ MCWorkingCopy forPackage: self.
]
