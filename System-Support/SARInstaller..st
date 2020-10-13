"
I am an object that handles the loading of SAR (Squeak ARchive) files.

A SAR file is a Zip file that follows certain simple conventions:

* it may have a member named ""install/preamble"".

This member, if present, will be filed in as Smalltalk source code at the beginning of installation.
Typically, the code in the preamble will make whatever installation preparations are necessary,
and will then call methods in the ""client services"" method category to extract or install other zip members.

* It may have a member named ""install/postscript"".

This member, if present, will be filed in as Smalltalk source code at the end of installation.
Typically, the code in the postscript will set up the operating environment,
and will perhaps put objects in flaps, open projects or README files, or launch samples.

Within the code in the preamble and postscript, ""self"" is set to the instance of the SARInstaller.

If neither an ""install/preamble"" nor an ""install/postscript"" file is present,
all the members will be installed after prompting the user,
based on a best guess of the member file types that is based on member filename extensions.

This is new behavior.
"
Class {
	#name : #SARInstaller,
	#superclass : #Model,
	#instVars : [
		'zip',
		'directory',
		'fileName',
		'installed'
	],
	#category : #'System-Support'
}

{ #category : #'change set utilities' }
SARInstaller class >> basicNewChangeSet: newName [
	Smalltalk at: #ChangesOrganizer ifPresent: [ :cs | ^cs basicNewChangeSet: newName ].
	(self changeSetNamed: newName) ifNotNil: [ self inform: 'Sorry that name is already used'. ^nil ].
	^ChangeSet basicNewNamed: newName.
]

{ #category : #SqueakMap }
SARInstaller class >> cardForSqueakMap: aSqueakMap [
	"Answer the current card or a new card."

	(aSqueakMap cardWithId: self squeakMapPackageID)
		ifNotNil: [ :card |
			(card installedVersion = self squeakMapPackageVersion) ifTrue: [ ^card ]
		].

	^self newCardForSqueakMap: aSqueakMap

]

{ #category : #'change set utilities' }
SARInstaller class >> changeSetNamed: newName [
	Smalltalk at: #ChangesOrganizer ifPresent: [ :cs | ^cs changeSetNamed: newName ].
	^ChangeSet allInstances detect: [ :cs | cs name = newName ] ifNone: [ nil ].
]

{ #category : #'change set utilities' }
SARInstaller class >> currentChangeSet [
	"Answer the current change set, in a way that should work in 3.5 as well"

	"SARInstaller currentChangeSet"

	^[ ChangeSet current ]
		on: MessageNotUnderstood
		do: [ :ex | ex return: Smalltalk changes ]
]

{ #category : #'instance creation' }
SARInstaller class >> directory: dir fileName: fn [
	^(self new) directory: dir; fileName: fn; yourself.
]

{ #category : #'package format support' }
SARInstaller class >> ensurePackageWithId: anIdString [

	self squeakMapDo: [ :sm | | newCS |
		self withCurrentChangeSetNamed: 'updates' do: [ :cs |
			| card |
			newCS := cs.
			card := sm cardWithId: anIdString.
			(card isNil or: [ card isInstalled not or: [ card isOld ]])
				ifTrue: [ sm installPackageWithId: anIdString ]
		].
		newCS isEmpty ifTrue: [ ChangeSet removeChangeSet: newCS ]
	].
]

{ #category : #'change set utilities' }
SARInstaller class >> fileIntoChangeSetNamed: aString fromStream: stream [ 
	"We let the user confirm filing into an existing ChangeSet
	or specify another ChangeSet name if
	the name derived from the filename already exists.
	Duplicated from SMSimpleInstaller.
	Should be a class-side method."

	^self withCurrentChangeSetNamed: aString
		do: [ :cs | | newName |
			newName := cs name.
			stream setConverterForCode.
			stream 
				fileInAnnouncing: 'Loading ' , newName , ' into change set ''' , newName, ''''.
			stream close]
]

{ #category : #'class initialization' }
SARInstaller class >> fileReaderServicesForFile: fullName suffix: suffix [ 

	^(suffix = 'sar') | (suffix = '*') 
		ifTrue: [Array with: self serviceFileInSAR]
		ifFalse: [#()]

]

{ #category : #'class initialization' }
SARInstaller class >> initialize [
	"SARInstaller initialize"
	FileServices registerFileReader: self.
]

{ #category : #'class initialization' }
SARInstaller class >> installSAR: relativeOrFullName [
	FileDirectory splitName: (FileDirectory default fullNameFor: relativeOrFullName)
		to: [ :dir :fileName | (self directory: (FileDirectory on: dir) fileName: fileName) fileIn ]
]

{ #category : #'package format support' }
SARInstaller class >> loadDVS [
	"Load the DVS support from SqueakMap"

	self ensurePackageWithId: '100d59d0-bf81-4e74-a4fe-5a2fd0c6b4ec'
]

{ #category : #'package format support' }
SARInstaller class >> loadMonticello [
	"Load Monticello support (MCInstaller and Monticello) from SqueakMap"

	self ensurePackageWithId: 'af9d090d-2896-4a4e-82d0-c61cf2fdf40e'.
	self ensurePackageWithId: '66236497-7026-45f5-bcf6-ad00ba7a8a4e'.
]

{ #category : #'package format support' }
SARInstaller class >> loadMonticelloCVS [
	"Load MonticelloCVS support from SqueakMap"

	self ensurePackageWithId: '2be9f7e2-1de2-4eb6-89bd-ec9b60593a93'.

]

{ #category : #SqueakMap }
SARInstaller class >> newCardForSqueakMap: aSqueakMap [
	"Answer a new card."

	^(aSqueakMap newCardWithId: self squeakMapPackageID)
	created: 3236292323
	updated:3236292323
	name: 'SARInstaller for 3.6'
	currentVersion:'16'
	summary: 'Lets you load SAR (Squeak ARchive) files from SqueakMap and the File List. For 3.6 and later images.'
	description:'Support for installing SAR (Squeak ARchive) packages from SqueakMap and the File List.
For 3.6 and later images.

SMSARInstaller will use this if it''s present to load SAR packages.

Use SARBuilder for making these packages easily.'
	url: 'http://bike-nomad.com/squeak/'
	downloadUrl:'http://bike-nomad.com/squeak/SARInstallerFor36-nk.16.cs.gz'
	author: 'Ned Konz <ned@bike-nomad.com>'
	maintainer:'Ned Konz <ned@bike-nomad.com>'
	registrator:'Ned Konz <ned@bike-nomad.com>'
	password:240495131608326995113451940367316491071470713347
	categories: #('6ba57b6e-946a-4009-beaa-0ac93c08c5d1' '94277ca9-4d8f-4f0e-a0cb-57f4b48f1c8a' 'a71a6233-c7a5-4146-b5e3-30f28e4d3f6b' '8209da9b-8d6e-40dd-b23a-eb7e05d4677b' );
	modulePath: ''
	moduleVersion:''
	moduleTag:''
	versionComment:'v16: same as v16 of SARInstaller for 3.4 but doesn''t include any classes other than SARInstaller.

To be loaded into 3.6 images only. Will de-register the 3.4 version if it''s registered.

Added a default (DWIM) mode in which SAR files that are missing both a preamble and postscript have all their members loaded in a default manner.

Changed the behavior of #extractMemberWithoutPath: to use the same directory as the SAR itself.

Added #extractMemberWithoutPath:inDirectory:

Moved several change set methods to the class side.

Made change set methods work with 3.5 or 3.6a/b

Now supports the following file types:

Projects (with or without construction of a ViewMorph)
Genie gesture dictionaries
Change sets
DVS packages
Monticello packages
Graphics files (loaded as SketchMorphs)
Text files (loaded as text editor windows)
Morph(s) in files

Now keeps track of installed members.'
]

{ #category : #'change set utilities' }
SARInstaller class >> newChanges: aChangeSet [
	"Change the current change set, in a way that should work in 3.5 as well"
	"SARInstaller newChanges: SARInstaller currentChangeSet"

	^[ ChangeSet newChanges: aChangeSet ]
		on: MessageNotUnderstood
		do: [ :ex | ex return: (Smalltalk newChanges: aChangeSet) ]
]

{ #category : #'class initialization' }
SARInstaller class >> serviceFileInSAR [
	"Answer a service for opening a changelist browser on a file"

	^ SimpleServiceEntry 
		provider: self 
		label: 'install SAR' translatedNoop
		selector: #installSAR:
		description: 'install this Squeak ARchive into the image.' translatedNoop
		buttonLabel: 'install' translatedNoop
]

{ #category : #'class initialization' }
SARInstaller class >> services [
	^Array with: self serviceFileInSAR

]

{ #category : #'package format support' }
SARInstaller class >> squeakMapDo: aBlock [
	"If SqueakMap is installed, evaluate aBlock with the default map.
	Otherwise, offer to install SqueakMap and continue."

	Smalltalk at: #SMSqueakMap ifPresent: [ :smClass | ^aBlock value: smClass default ].

	(self confirm: 'SqueakMap is not installed in this image.
Would you like to load it from the network?')
		ifTrue: [ TheWorldMenu loadSqueakMap.
			^self squeakMapDo: aBlock ].

	^nil
]

{ #category : #SqueakMap }
SARInstaller class >> squeakMapPackageID [
	^'75c970ab-dca7-48ee-af42-5a013912c880'
]

{ #category : #SqueakMap }
SARInstaller class >> squeakMapPackageVersion [
	^'16'
]

{ #category : #'class initialization' }
SARInstaller class >> unload [
	FileServices unregisterFileReader: self.
]

{ #category : #'change set utilities' }
SARInstaller class >> withCurrentChangeSetNamed: aString do: aOneArgumentBlock [ 
	"Evaluate the one-argument block aOneArgumentBlock while the named change set is active.
	We let the user confirm operating on an existing ChangeSet 
	or specify another ChangeSet name if 
	the name derived from the filename already exists. 
	Duplicated from SMSimpleInstaller. 
	Returns change set."

	| changeSet newName oldChanges |
	newName := aString.
	changeSet := self changeSetNamed: newName.
	changeSet ifNotNil: 
			[newName := UIManager default 
						request: 'ChangeSet already present, just confirm to overwrite or enter a new name:'
						initialAnswer: newName.
			newName isEmpty ifTrue: [self error: 'Cancelled by user'].
			changeSet := self changeSetNamed: newName].
	changeSet ifNil: [changeSet := self basicNewChangeSet: newName].
	changeSet 
		ifNil: [self error: 'User did not specify a valid ChangeSet name'].
	oldChanges := self currentChangeSet.
	
	[ self newChanges: changeSet.
	aOneArgumentBlock value: changeSet] 
			ensure: [ self newChanges: oldChanges].
	^changeSet
]

{ #category : #accessing }
SARInstaller >> directory [
	^directory
]

{ #category : #accessing }
SARInstaller >> directory: anObject [
	directory := anObject
]

{ #category : #private }
SARInstaller >> errorNoSuchMember: aMemberName [
	(self confirm: 'No member named ', aMemberName, '. Do you want to stop loading?')
		== true ifTrue: [ self error: 'aborted' ].
]

{ #category : #'client services' }
SARInstaller >> extractMember: aMemberOrName [
	"Extract aMemberOrName to a file using its filename"
	(self zip extractMember: aMemberOrName)
		ifNil: [ self errorNoSuchMember: aMemberOrName ]
		ifNotNil: [ self installed: aMemberOrName ].
]

{ #category : #'client services' }
SARInstaller >> extractMember: aMemberOrName toFileNamed: aFileName [
	"Extract aMemberOrName to a specified filename"
	(self zip extractMember: aMemberOrName toFileNamed: aFileName)
		ifNil: [ self errorNoSuchMember: aMemberOrName ]
		ifNotNil: [ self installed: aMemberOrName ].
]

{ #category : #'client services' }
SARInstaller >> extractMemberWithoutPath: aMemberOrName [
	"Extract aMemberOrName to its own filename, but ignore any directory paths, using my directory instead."
	self extractMemberWithoutPath: aMemberOrName inDirectory: self directory.

]

{ #category : #'client services' }
SARInstaller >> extractMemberWithoutPath: aMemberOrName inDirectory: aDirectory [
	"Extract aMemberOrName to its own filename, but ignore any directory paths, using aDirectory instead"
	| member |
	member := self memberNamed: aMemberOrName.
	member ifNil: [ ^self errorNoSuchMember: aMemberOrName ].
	self zip extractMemberWithoutPath: member inDirectory: aDirectory.
	self installed: member.
]

{ #category : #fileIn }
SARInstaller >> fileIn [
	"File in to a change set named like my file"
	directory readOnlyFileNamed: fileName do: [:stream |
		| newCS |
		newCS := self class withCurrentChangeSetNamed: fileName
			do: [:cs | self fileInFrom: stream].
		newCS isEmpty ifTrue: [ ChangeSet removeChangeSet: newCS ]]
]

{ #category : #fileIn }
SARInstaller >> fileInFrom: stream [
	"The zip has been saved already by the download.
	Read the zip into my instvar, then file in the correct members"

	

	[ | postscript preamble |
		stream position: 0.
		zip := ZipArchive new readFrom: stream.

		preamble := zip memberNamed: 'install/preamble'.
		preamble ifNotNil: [
			preamble contentStream text setConverterForCode fileInFor: self announcing: 'Preamble'.
			self class currentChangeSet preambleString: preamble contents.
		].

		postscript := zip memberNamed: 'install/postscript'.
		postscript ifNotNil: [
			postscript contentStream text setConverterForCode fileInFor: self announcing: 'Postscript'.
			self class currentChangeSet postscriptString: postscript contents.
		].

		preamble isNil & postscript isNil ifTrue: [
			(self confirm: 'No install/preamble or install/postscript member were found.
	Install all the members automatically?') ifTrue: [ self installAllMembers ]
		].

	] ensure: [ stream close ].


]

{ #category : #'client services' }
SARInstaller >> fileInGenieDictionaryNamed: memberName [ 
	"This is to be used from preamble/postscript code to file in zip 
	members as Genie gesture dictionaries.
	Answers a dictionary."

	| member object crDictionary stream |

	crDictionary := Smalltalk at: #CRDictionary ifAbsent: [ ^self error: 'Genie not installed' ].
	"don't know how to recursively load"

	member := self memberNamed: memberName.
	member ifNil: [ ^self errorNoSuchMember: memberName ].

	stream := ReferenceStream on: member contentStream.

	object := [ stream next ]
		on: Error do: 
		[:ex |  stream close.
		self inform: 'Error on loading: ' , ex description. ^ nil ].
	stream close.

	(object notNil and: [object name isEmptyOrNil])
		ifTrue: [object := crDictionary name: object storedName].

	self installed: member.

	^ object

]

{ #category : #private }
SARInstaller >> fileInMCVersion: member withBootstrap: mcBootstrap [
	"This will use the MCBootstrapLoader to load a (non-compressed) Monticello file (.mc or .mcv)"
	| newCS |
	self class withCurrentChangeSetNamed: member localFileName
		do: [ :cs | 
			newCS := cs.
			mcBootstrap loadStream: member contentStream ascii ].

	newCS isEmpty ifTrue: [ ChangeSet removeChangeSet: newCS ].

	Project current world doOneCycle.

	self installed: member.
]

{ #category : #'client services' }
SARInstaller >> fileInMemberNamed: csName [
	"This is to be used from preamble/postscript code to file in zip members as ChangeSets."
	| cs |
	cs := self memberNamed: csName.
	cs ifNil: [ ^self errorNoSuchMember: csName ].
	self class fileIntoChangeSetNamed: csName fromStream: cs contentStream text setConverterForCode.
	self installed: cs.

]

{ #category : #'client services' }
SARInstaller >> fileInMonticelloPackageNamed: memberName [ 
	"This is to be used from preamble/postscript code to file in zip 
	members as Monticello packages (.mc)."

	| member file mcPackagePanel mcRevisionInfo mcSnapshot mcFilePackageManager mcPackage mcBootstrap newCS |

	mcPackagePanel := Smalltalk at: #MCPackagePanel ifAbsent: [ ].
	mcRevisionInfo := Smalltalk at: #MCRevisionInfo ifAbsent: [ ].
	mcSnapshot := Smalltalk at: #MCSnapshot ifAbsent: [ ].
	mcFilePackageManager := Smalltalk at: #MCFilePackageManager ifAbsent: [ ].
	mcPackage := Smalltalk at: #MCPackage ifAbsent: [ ].
	member := self memberNamed: memberName.
	member ifNil: [ ^self errorNoSuchMember: memberName ].

	"We are missing MCInstaller, Monticello and/or MonticelloCVS.
	If the bootstrap is present, use it. Otherwise interact with the user."
	({ mcPackagePanel. mcRevisionInfo. mcSnapshot. mcFilePackageManager. mcPackage } includes: nil)
		ifTrue: [
			mcBootstrap := self getMCBootstrapLoaderClass.
			mcBootstrap ifNotNil: [ ^self fileInMCVersion: member withBootstrap: mcBootstrap ].

			(self confirm: ('Monticello support is not installed, but must be to load member named ', memberName, '.
Load it from SqueakMap?'))
				ifTrue: [ self class loadMonticello; loadMonticelloCVS.
					^self fileInMonticelloPackageNamed: memberName ]
				ifFalse: [ ^false ] ].

	member extractToFileNamed: member localFileName inDirectory: self directory.
	file := (Smalltalk at: #MCFile)
				name: member localFileName
				directory: self directory.

	self class withCurrentChangeSetNamed: file name do: [ :cs | | snapshot info |
		newCS := cs.
		file readStreamDo: [ :stream |
			info := mcRevisionInfo readFrom: stream nextChunk.
			snapshot := mcSnapshot fromStream: stream ].
			snapshot install.
			(mcFilePackageManager forPackage:
				(mcPackage named: info packageName))
					file: file
		].

	newCS isEmpty ifTrue: [ ChangeSet removeChangeSet: newCS ].

	mcPackagePanel allSubInstancesDo: [ :ea | ea refresh ].
	Project current world doOneCycle.

	self installed: member.

]

{ #category : #'client services' }
SARInstaller >> fileInMonticelloVersionNamed: memberName [ 
	"This is to be used from preamble/postscript code to file in zip 
	members as Monticello version (.mcv) files."

	| member newCS mcMcvReader |
	mcMcvReader := Smalltalk at: #MCMcvReader ifAbsent: [].
	member := self memberNamed: memberName.
	member ifNil: [^self errorNoSuchMember: memberName].

	"If we don't have Monticello, offer to get it."
	mcMcvReader ifNil:  [
		(self confirm: 'Monticello is not installed, but must be to load member named ', memberName , '.
Load it from SqueakMap?') 
			ifTrue:  [ self class loadMonticello.
						^self fileInMonticelloVersionNamed: memberName]
					ifFalse: [^false]].

	self class withCurrentChangeSetNamed: member localFileName
		do: 
			[:cs | 
			newCS := cs.
			(mcMcvReader versionFromStream: member contentStream ascii) load ].
	newCS isEmpty ifTrue: [ChangeSet removeChangeSet: newCS].
	Project current world doOneCycle.
	self installed: member
]

{ #category : #'client services' }
SARInstaller >> fileInMonticelloZipVersionNamed: memberName [ 
	"This is to be used from preamble/postscript code to file in zip 
	members as Monticello version (.mcz) files."

	| member mczInstaller newCS mcMczReader |
	mcMczReader := Smalltalk at: #MCMczReader ifAbsent: [].
	mczInstaller := Smalltalk at: #MczInstaller ifAbsent: [].
	member := self memberNamed: memberName.
	member ifNil: [^self errorNoSuchMember: memberName].

	"If we don't have Monticello, but have the bootstrap, use it silently."
	mcMczReader ifNil:  [
		mczInstaller ifNotNil: [ ^mczInstaller installStream: member contentStream ].
		(self confirm: 'Monticello is not installed, but must be to load member named ', memberName , '.
Load it from SqueakMap?') 
			ifTrue:  [ self class loadMonticello.
						^self fileInMonticelloZipVersionNamed: memberName]
					ifFalse: [^false]].

	self class withCurrentChangeSetNamed: member localFileName
		do: 
			[:cs | 
			newCS := cs.
			(mcMczReader versionFromStream: member contentStream) load ].
	newCS isEmpty ifTrue: [ChangeSet removeChangeSet: newCS].
	Project current world doOneCycle.
	self installed: member
]

{ #category : #'client services' }
SARInstaller >> fileInMorphsNamed: memberName addToWorld: aBoolean [
	"This will load the Morph (or Morphs) from the given member.
	Answers a Morph, or a list of Morphs, or nil if no such member or error.
	If aBoolean is true, also adds them and their models to the World."

	| member morphOrList |
	member := self memberNamed: memberName.
	member ifNil: [^ self errorNoSuchMember: memberName].
	self installed: member.
	
	morphOrList := member contentStream fileInObjectAndCode.
	morphOrList ifNil: [^ nil].
	aBoolean ifTrue: [Project current world addMorphsAndModel: morphOrList].
	
	^ morphOrList
]

{ #category : #'client services' }
SARInstaller >> fileInPackageNamed: memberName [ 
	"This is to be used from preamble/postscript code to file in zip 
	members as DVS packages."
	| member current new baseName imagePackageLoader packageInfo streamPackageLoader packageManager |
	member := self zip memberNamed: memberName.
	member ifNil: [ ^self errorNoSuchMember: memberName ].

	imagePackageLoader := Smalltalk at: #ImagePackageLoader ifAbsent: [].
	streamPackageLoader := Smalltalk at: #StreamPackageLoader ifAbsent: [].
	packageInfo := Smalltalk at: #PackageInfo ifAbsent: [].
	packageManager := Smalltalk at: #FilePackageManager ifAbsent: [].

	"If DVS isn't present, do a simple file-in"
	(packageInfo isNil or: [imagePackageLoader isNil or: [streamPackageLoader isNil]])
		ifTrue: [ ^ self fileInMemberNamed: memberName ].

	baseName := memberName copyReplaceAll: '.st' with: ''.
	(packageManager allManagers anySatisfy: [ :pm | pm packageName = baseName ])
		ifTrue: [
			current := imagePackageLoader new package: (packageInfo named: baseName).
			new := streamPackageLoader new stream: member contentStream ascii.
			(new changesFromBase: current) fileIn ]
		ifFalse: [ self class fileIntoChangeSetNamed: baseName fromStream: member contentStream ascii setConverterForCode. ].

	packageManager registerPackage: baseName.

	self installed: member.
]

{ #category : #'client services' }
SARInstaller >> fileInProjectNamed: projectOrMemberName createView: aBoolean [ 
	"This is to be used from preamble/postscript code to file in SAR members 
	as Projects. 
	Answers the loaded project, or nil. 
	Does not enter the loaded project. 
	If aBoolean is true, also creates a ProjectViewMorph 
	(possibly in a window, depending on your Preferences)."
	| member project triple memberName |
	member := self memberNamed: projectOrMemberName.
	member
		ifNotNil: [ memberName := member fileName ]
		ifNil: [ 	member := self memberNamed: (memberName := self memberNameForProjectNamed: projectOrMemberName) ].
	member ifNil: [ ^self errorNoSuchMember: projectOrMemberName ].
	triple := Project parseProjectFileName: memberName unescapePercents.
	project := nil.
	[[ProjectLoading
		openName: triple first
		stream: member contentStream
		fromDirectory: nil
		withProjectView: nil]
		on: ProjectViewOpenNotification
		do: [:ex | ex resume: aBoolean]]
		on: ProjectEntryNotification
		do: [:ex | 
			project := ex projectToEnter.
			ex resume].
	self installed: member.
	^ project
]

{ #category : #'client services' }
SARInstaller >> fileInTrueTypeFontNamed: memberOrName [

	| member description |
	member := self memberNamed: memberOrName.
	member ifNil: [^self errorNoSuchMember: memberOrName].

	description := TTFontDescription addFromTTStream: member contentStream.
	TTCFont newTextStyleFromTT: description.

	Project current world doOneCycle.
	self installed: member
]

{ #category : #fileIn }
SARInstaller >> fileIntoChangeSetNamed: aString fromStream: stream [
	"Not recommended for new code"
	^self class fileIntoChangeSetNamed: aString fromStream: stream
]

{ #category : #accessing }
SARInstaller >> fileName [
	^fileName
]

{ #category : #accessing }
SARInstaller >> fileName: anObject [
	fileName := anObject
]

{ #category : #'client services' }
SARInstaller >> getMCBootstrapLoaderClass [
	^Smalltalk at: #MCBootstrapLoader
		ifAbsent: 
			[(self memberNamed: 'MCBootstrapLoader.st') 
				ifNotNil: [:m | self fileInMemberNamed: m.
					Smalltalk at: #MCBootstrapLoader ifAbsent: []]]
]

{ #category : #'client services' }
SARInstaller >> importImage: memberOrName [
	| member form |
	member := self memberNamed: memberOrName.
	member ifNil: [ ^self errorNoSuchMember: memberOrName ].
	form := ImageReadWriter formFromStream: member contentStream binary.
	form ifNil: [ ^self ].
	Imports default importImage: form named: (FileDirectory localNameFor: member fileName) sansPeriodSuffix.
	self installed: member.
]

{ #category : #initialization }
SARInstaller >> initialize [
	installed := OrderedCollection new.
]

{ #category : #fileIn }
SARInstaller >> installAllMembers [
	"Try to install all the members, in order, based on their filenames and/or contents."
	| uninstalled |
	uninstalled := OrderedCollection new.
	zip members do: [ :member | self installMember: member ].
	uninstalled := self uninstalledMembers.
	uninstalled isEmpty ifTrue: [ ^self ].
	uninstalled inspect.
]

{ #category : #'client services' }
SARInstaller >> installMember: memberOrName [
	| memberName extension isGraphic stream member |
	member := self memberNamed: memberOrName.
	member ifNil: [ ^false ].
	memberName := member fileName.
	extension := (FileDirectory extensionFor: memberName) asLowercase.
	Smalltalk at: #CRDictionary ifPresent: [ :crDictionary |
		(extension = crDictionary fileNameSuffix) ifTrue: [  self fileInGenieDictionaryNamed: memberName. ^true ] ].
	extension caseOf: {
		[ Project projectExtension ] -> [ self fileInProjectNamed: memberName createView: true ].
		[ FileStream st ] -> [ self fileInPackageNamed: memberName ].
		[ FileStream cs ] -> [  self fileInMemberNamed: memberName  ].
"		[ FileStream multiSt ] -> [  self fileInMemberNamedAsUTF8: memberName  ].
		[ FileStream multiCs ] -> [  self fileInMemberNamedAsUTF8: memberName  ].
"
		[ 'mc' ] -> [ self fileInMonticelloPackageNamed: memberName ].
		[ 'mcv' ] -> [ self fileInMonticelloVersionNamed: memberName ].
		[ 'mcz' ] -> [ self fileInMonticelloZipVersionNamed: memberName ].
		[ 'morph' ] -> [ self fileInMorphsNamed: member addToWorld: true ].
		[ 'ttf' ] -> [ self fileInTrueTypeFontNamed: memberName ].
		[ 'translation' ] -> [  self fileInMemberNamed: memberName  ].
	} otherwise: [
		('t*xt' match: extension) ifTrue: [ self openTextFile: memberName ]
			ifFalse: [ stream := member contentStream.
		isGraphic := ImageReadWriter understandsImageFormat: stream.
		stream reset.
		isGraphic
			ifTrue: [ self openGraphicsFile: member ]
			ifFalse: [ "now what?" ^false ]]
	].
	^true

]

{ #category : #private }
SARInstaller >> installed: aMemberOrName [
	self installedMembers add: (self zip member: aMemberOrName)
]

{ #category : #accessing }
SARInstaller >> installedMemberNames [
	"Answer the names of the zip members that have been installed already."
	^self installedMembers collect: [ :ea | ea fileName ]
]

{ #category : #accessing }
SARInstaller >> installedMembers [
	"Answer the zip members that have been installed already."
	^installed ifNil: [ installed := OrderedCollection new ]
]

{ #category : #'client services' }
SARInstaller >> memberNameForProjectNamed: projectName [
	"Answer my member name for the given project, or nil.
	Ignores version numbers and suffixes, and also unescapes percents in filenames."

	^self zip memberNames detect: [ :memberName | | triple |
		triple := Project parseProjectFileName: memberName unescapePercents.
		triple first asLowercase = projectName asLowercase
	] ifNone: [ nil ].
]

{ #category : #'client services' }
SARInstaller >> memberNamed: aString [
	^(zip member: aString)
		ifNil: [ | matching |
			matching := zip membersMatching: aString.
			matching isEmpty ifFalse: [ matching last ]].
]

{ #category : #accessing }
SARInstaller >> memberNames [
	^self zip memberNames
]

{ #category : #'client services' }
SARInstaller >> membersMatching: aString [
	^self zip membersMatching: aString
]

{ #category : #'client services' }
SARInstaller >> openGraphicsFile: memberOrName [
	| member morph |
	member := self memberNamed: memberOrName.
	member ifNil: [ ^self errorNoSuchMember: memberOrName ].
	morph := (Project current world drawingClass fromStream: member contentStream binary).
	morph ifNotNil: [ morph openInWorld ].
	self installed: member.
]

{ #category : #'client services' }
SARInstaller >> openTextFile: memberOrName [
	"Open a text window on the given member"
	| member |
	member := self memberNamed: memberOrName.
	member ifNil: [ ^self errorNoSuchMember: memberOrName ].
	StringHolder new
		acceptContents: member contents;
		openLabel: member fileName.
	self installed: member.
]

{ #category : #'client services' }
SARInstaller >> prependedDataSize [
	^self zip prependedDataSize
]

{ #category : #accessing }
SARInstaller >> uninstalledMemberNames [
	"Answer the names of the zip members that have not yet been installed."
	^self uninstalledMembers collect: [ :ea | ea fileName ]
]

{ #category : #accessing }
SARInstaller >> uninstalledMembers [
	"Answer the zip members that haven't been installed or extracted yet."
	^zip members copyWithoutAll: self installedMembers
]

{ #category : #accessing }
SARInstaller >> zip [
	^zip
]

{ #category : #accessing }
SARInstaller >> zip: anObject [
	^zip := anObject
]

{ #category : #'client services' }
SARInstaller >> zipFileComment [
	^self zip zipFileComment
]
