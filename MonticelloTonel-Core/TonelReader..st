"
I'm a monticello reader for tonel format repositories. I read
 - a package per directory
 - a class per file
 - a set of extensions to a single class per file (for example, all extensions of a package to String will be in a single file)

I'm created on a file reference to a directory where the package will be read and the name of the package to read.

[[[
TonelReader on: 'someDirectoryWithTonelPackages' asFileReference filename: 'MyPackageName'
]]]

My main method is
- ==#definitions== reads and parses the tonel file, returns a list of monticello definitions.
- ==#snapshot== returns a monticello snapshot with the read definitions.
- ==#version== returns a monticello version with the read snapshot.

! Implementation details

The monticello versions I return do have artificial information. Since I'm just meant to read versions from a directory, this directory has no information such as commit message, commit time, author, or ancestors. Check the method ==#loadVersionInfo== for more information.
"
Class {
	#name : #TonelReader,
	#superclass : #MCVersionReader,
	#instVars : [
		'packageDirectory'
	],
	#category : #'MonticelloTonel-Core'
}

{ #category : #testing }
TonelReader class >> canReadFileNamed: fileName [
	"We validate that fileName does not contains dot, but that's the only thing we can do 
	 at this point."
	| actualFileName |
	actualFileName := TonelRepository directoryNameFromFileName: fileName.
	^ actualFileName noneSatisfy: [ :each | each = $. ]
]

{ #category : #accessing }
TonelReader class >> definitionOrders [
	"Used to sort definitions inside a snapshot"
	^ Dictionary newFromPairs: { 
		MCOrganizationDefinition. 	0.
		MCMethodDefinition. 			1.
		MCClassDefinition. 			2.
		MCTraitDefinition. 			2.
		MCClassTraitDefinition. 		3 }
]

{ #category : #accessing }
TonelReader class >> extension [
	"This is needed because the implementation of MCCacheRepository assumes each package 
	 has an extension (which is a lame implementation) and then we need to provide one. 
	 Since tonel is not cached (because we have our oen cache in the form of a local repository), 
	 we put something that will not be found anyway"
	^ 'NOTUSED'
		
]

{ #category : #testing }
TonelReader class >> generatedVersionSuffix [
	^ '-tonel.1'
]

{ #category : #testing }
TonelReader class >> isAbstract [
	^ false
]

{ #category : #reading }
TonelReader class >> on: parentDirectoryReference fileName: fileName [
	"I will anster a reader for the package stored in 
	
		[repository]/parentDirectoryReference/packageName
	
	This operation will NOT read the package, but resulting instance will be prepared
	to doit, executing: #loadDefinitions"
	| packageName |
	packageName := TonelRepository directoryNameFromFileName: fileName.
	^ (self on: parentDirectoryReference)
		packageDirectory: packageName;
		yourself
]

{ #category : #private }
TonelReader >> canBeLoaded: aFileReference [
	| fileName |
	fileName := self fileUtils fileName: aFileReference. 
	^ fileName ~= 'package.st' and: [ fileName endsWith: '.st' ]
]

{ #category : #private }
TonelReader >> categoriesFrom: aCollection [
	^ ((aCollection select: #isClassDefinition)
		collect: #category
		as: Set)
		sorted: [ :a :b | a < b ]
]

{ #category : #accessing }
TonelReader >> fileUtils [
	^ TonelFileUtils current
]

{ #category : #loading }
TonelReader >> loadDefinitions [
	| definitionOrders newDefinitions newCategories organization |
	
	definitionOrders := self class definitionOrders.
	newDefinitions := ((self packageDirectory entries
		select: [ :each | self canBeLoaded: each ]) 
		collect: [ :each | each readStreamDo: [ :s | TonelParser parseStream: s ] ])
		flattened
		sort: [ :a :b | (definitionOrders at: a class) < (definitionOrders at: b class) ].

	newCategories := self categoriesFrom: newDefinitions.
	(newCategories includes: self package name asSymbol)
		ifFalse: [ newCategories := newCategories copyWithFirst: self package name ].
	organization := MCOrganizationDefinition categories: newCategories.
	
	definitions := (newDefinitions copyWithFirst: organization) sort
]

{ #category : #loading }
TonelReader >> loadDependencies [
	"There should not be dependencies"
	dependencies := #()
]

{ #category : #loading }
TonelReader >> loadPackage [
	package := MCPackage named: self packageNameFromPackageDirectory
]

{ #category : #loading }
TonelReader >> loadVersionInfo [
	info := MCVersionInfo
		name: self packageNameFromPackageDirectory, self class generatedVersionSuffix
		id: UUID new
		message: 'fabricated from a Tonel format repository'
		date: Date today
		time: Time now
		author: ''
		ancestors: #()
		stepChildren: #()
]

{ #category : #accessing }
TonelReader >> packageDirectory [
	^ packageDirectory
]

{ #category : #accessing }
TonelReader >> packageDirectory: aDirectoryName [
	packageDirectory := self fileUtils 
		directoryFromPath: aDirectoryName 
		relativeTo: stream
]

{ #category : #private }
TonelReader >> packageNameFromPackageDirectory [
    ^ packageDirectory basename
]
