"
A MCPackageLoader is responsible for loading packages.  It gets used by VersionLoader, so it is eventually responsible for loading everything.

Instance Variables
	additions:		<Definitions>  Definitions that need to be added
	errorDefinitions:		<Object>
	obsoletions:		<Object>
	provisions:		<Object>
	removals:		<Object>
	requirements:		<Object>
	unloadableDefinitions:		<Object>
	methodAdditions  <MethodAdditions> MethodDefinitions corresponding to the Definitions in ""additions"" that have been added so far.

additions
	- xxxxx

errorDefinitions
	- xxxxx

obsoletions
	- xxxxx

provisions
	- xxxxx

removals
	- xxxxx

requirements
	- xxxxx

unloadableDefinitions
	- xxxxx

"
Class {
	#name : #MCPackageLoader,
	#superclass : #Object,
	#instVars : [
		'requirements',
		'unloadableDefinitions',
		'obsoletions',
		'additions',
		'removals',
		'errorDefinitions',
		'provisions',
		'methodAdditions',
		'preamble'
	],
	#category : #'Monticello-Loading'
}

{ #category : #loading }
MCPackageLoader class >> installSnapshot: aSnapshot [
	self new
		installSnapshot: aSnapshot;
		load
]

{ #category : #'instance creation' }
MCPackageLoader class >> new [
	^ self basicNew initialize
]

{ #category : #unloading }
MCPackageLoader class >> unloadPackage: aPackage [
	self new
		unloadPackage: aPackage;
		loadWithNameLike: aPackage name, '-unload'
]

{ #category : #loading }
MCPackageLoader class >> updatePackage: aPackage withSnapshot: aSnapshot [
	self new
		updatePackage: aPackage withSnapshot: aSnapshot;
		load
]

{ #category : #'patch ops' }
MCPackageLoader >> addDefinition: aDefinition [
	additions add: aDefinition
]

{ #category : #private }
MCPackageLoader >> analyze [
	| sorter |
	sorter := self sorterForItems: additions.
	additions := sorter orderedItems.
	requirements := sorter externalRequirements.
	unloadableDefinitions := sorter itemsWithMissingRequirements sorted.
	
	self forgetSuperfluousMethodRemovals.
	sorter := self sorterForItems: removals.
	removals := sorter orderedItems reversed.
]

{ #category : #public }
MCPackageLoader >> appendToPreamble: aString [
	preamble
		ifNil: [preamble := aString]
		ifNotNil: [preamble := preamble, aString].

]

{ #category : #private }
MCPackageLoader >> basicLoad [
	"Load the contents of some package. This is the core loading method
	in Monticello. Be wary about modifying it unless you understand the details
	and dependencies of the various entities being modified."
	| pkgName |
	errorDefinitions := OrderedCollection new.
	"Obviously this isn't the package name but we don't have anything else
	to use here. ChangeSet current name will generally work since a CS is 
	usually installed prior to installation."
	pkgName := ChangeSet current name.
	preamble ifNotNil: [ChangeSet current preambleString: (self preambleAsCommentNamed: pkgName)].

RecentMessages default suspendWhile: [
	[CurrentReadOnlySourceFiles cacheDuring: [[
	"Pass 1: Load everything but the methods,  which are collected in methodAdditions."
	additions do: [:ea | 
		ea isMethodDefinition 
			ifTrue:[methodAdditions add: ea asMethodAddition]
			ifFalse:[[ea load]on: Error do: [errorDefinitions add: ea]].
	] displayingProgress: 'Reshaping ', pkgName.

	"Try again any delayed definitions"
	self shouldWarnAboutErrors ifTrue: [self warnAboutErrors].
	errorDefinitions do: [:ea | ea load] 
		displayingProgress: 'Reloading ', pkgName.

	"Pass 2: We compile new / changed methods"
	methodAdditions do:[:ea| ea createCompiledMethod] 
		displayingProgress: 'Compiling ', pkgName.

	'Installing ', pkgName displayProgressFrom: 0 to: 2 during:[:bar|
		"There is no progress *during* installation since a progress bar update
		will redraw the world and potentially call methods that we're just trying to install."
		bar value: 1.

		"Pass 3: Install the new / changed methods
		(this is a separate pass to allow compiler changes to be loaded)"
		methodAdditions do:[:ea| ea installMethod].

		"Pass 4: Remove the obsolete methods"
		removals do:[:ea| ea unload].
	].

	"Finally, notify observers for the method additions"
	methodAdditions do: [:each | each notifyObservers] 
		"the message is fake but actually telling people how much time we spend
		in the notifications is embarrassing so lie instead"
		displayingProgress: 'Installing ', pkgName.

	additions do: [:ea | ea postloadOver: (self obsoletionFor: ea)] 
		displayingProgress: 'Initializing ', pkgName.

	] on: InMidstOfFileinNotification do: [:n | n resume: true]
	]] ensure: [self flushChangesFile]
]
]

{ #category : #private }
MCPackageLoader >> dependencyWarning [
	^ String streamContents:
		[:s |
		s nextPutAll: 'This package depends on the following classes:'; cr.
		requirements do: [:ea | s space; space; nextPutAll: ea; cr].
		s nextPutAll: 'You must resolve these dependencies before you will be able to load these definitions: '; cr.
		unloadableDefinitions do: [:ea | s space; space; nextPutAll: ea summary; cr]] 
]

{ #category : #private }
MCPackageLoader >> errorDefinitionWarning [
	^ String streamContents:
		[:s |
		s nextPutAll: 'The following definitions had errors while loading.  Press Proceed to try to load them again (they may work on a second pass):'; cr.
		errorDefinitions do: [:ea | s space; space; nextPutAll: ea summary; cr]] 
]

{ #category : #private }
MCPackageLoader >> flushChangesFile [
	"The changes file is second in the SourceFiles array"

	(SourceFiles at: 2) flush
]

{ #category : #private }
MCPackageLoader >> forgetSuperfluousMethodRemovals [
	|  removedClasses |
	removedClasses := (removals select: #isClassDefinition) collect: #actualClass.
	removedClasses addAll: (removedClasses collect: #class).
	removals := removals reject: [:e | e isMethodDefinition and: [removedClasses includes: e actualClass]]
]

{ #category : #private }
MCPackageLoader >> initialize [
	additions := OrderedCollection new.
	removals := OrderedCollection new.
	obsoletions := Dictionary new.
	methodAdditions := OrderedCollection new. 

]

{ #category : #public }
MCPackageLoader >> installSnapshot: aSnapshot [
	| patch |
	patch := aSnapshot patchRelativeToBase: MCSnapshot empty.
	patch applyTo: self.

]

{ #category : #public }
MCPackageLoader >> load [
	self analyze.
	unloadableDefinitions isEmpty ifFalse: [self warnAboutDependencies].
	self useNewChangeSetDuring: [self basicLoad]
]

{ #category : #private }
MCPackageLoader >> loadClassDefinition: aDefinition [
	[aDefinition isClassDefinition ifTrue:[aDefinition load]] on: Error do: [errorDefinitions add: aDefinition].
]

{ #category : #public }
MCPackageLoader >> loadWithName: baseName [
	self analyze.
	unloadableDefinitions isEmpty ifFalse: [self warnAboutDependencies].
	self useChangeSetNamed: baseName during: [self basicLoad]
]

{ #category : #public }
MCPackageLoader >> loadWithNameLike: baseName [
	self analyze.
	unloadableDefinitions isEmpty ifFalse: [self warnAboutDependencies].
	self useNewChangeSetNamedLike: baseName during: [self basicLoad]
]

{ #category : #'patch ops' }
MCPackageLoader >> modifyDefinition: old to: new [
	self addDefinition: new.
	obsoletions at: new put: old.
]

{ #category : #private }
MCPackageLoader >> obsoletionFor: aDefinition [
	^ obsoletions at: aDefinition ifAbsent: [nil]
]

{ #category : #private }
MCPackageLoader >> orderDefinitionsForLoading: aCollection [
	^ (self sorterForItems: aCollection) orderedItems
]

{ #category : #private }
MCPackageLoader >> orderedAdditions [
	^ additions
]

{ #category : #private }
MCPackageLoader >> preambleAsCommentNamed: pkgName [
	^
'"Changeset:	{1}
Date:	{2}
Author:	(generated by MC)

{3}
"' format: {pkgName. Date today. preamble copyReplaceAll: '"' with: ''''''}
]

{ #category : #private }
MCPackageLoader >> provisions [
	^ provisions ifNil: [provisions := Set withAll: Environment current provisions] 
]

{ #category : #'patch ops' }
MCPackageLoader >> removeDefinition: aDefinition [
	removals add: aDefinition
]

{ #category : #private }
MCPackageLoader >> shouldWarnAboutErrors [
	^ errorDefinitions isEmpty not and: [false "should make this a preference"]
]

{ #category : #private }
MCPackageLoader >> sorterForItems: aCollection [
	| sorter |
	sorter := MCDependencySorter items: aCollection.
	sorter addExternalProvisions: self provisions.
	^ sorter
]

{ #category : #private }
MCPackageLoader >> tryToLoad: aDefinition [
	[aDefinition addMethodAdditionTo: methodAdditions] on: Error do: [errorDefinitions add: aDefinition].
]

{ #category : #public }
MCPackageLoader >> unloadPackage: aPackage [
	self updatePackage: aPackage withSnapshot: MCSnapshot empty
]

{ #category : #public }
MCPackageLoader >> updatePackage: aPackage withSnapshot: aSnapshot [
	|  patch packageSnap |
	packageSnap := aPackage snapshot.
	patch := aSnapshot patchRelativeToBase: packageSnap.
	patch applyTo: self.
	packageSnap definitions do: [:ea | self provisions addAll: ea provisions]

]

{ #category : #private }
MCPackageLoader >> useChangeSetNamed: baseName during: aBlock [
	"Use the named change set, or create one with the given name."
	| changeHolder oldChanges newChanges |
	changeHolder := (ChangeSet respondsTo: #newChanges:)
						ifTrue: [ChangeSet]
						ifFalse: [Smalltalk].
	oldChanges := (ChangeSet respondsTo: #current)
						ifTrue: [ChangeSet current]
						ifFalse: [Smalltalk changes].

	newChanges := (ChangeSet named: baseName) ifNil: [ ChangeSet new name: baseName ].
	changeHolder newChanges: newChanges.
	aBlock ensure: [changeHolder newChanges: oldChanges].

]

{ #category : #private }
MCPackageLoader >> useNewChangeSetDuring: aBlock [
	^self useNewChangeSetNamedLike: 'MC' during: aBlock
]

{ #category : #private }
MCPackageLoader >> useNewChangeSetNamedLike: baseName during: aBlock [
	^self useChangeSetNamed: (ChangeSet uniqueNameLike: baseName) during: aBlock
]

{ #category : #private }
MCPackageLoader >> warnAboutDependencies [ 
	self notify: self dependencyWarning
]

{ #category : #private }
MCPackageLoader >> warnAboutErrors [
	self notify: self errorDefinitionWarning.

]
