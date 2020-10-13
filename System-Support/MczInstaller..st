Class {
	#name : #MczInstaller,
	#superclass : #Object,
	#instVars : [
		'stream',
		'zip'
	],
	#classVars : [
		'Versions'
	],
	#category : #'System-Support'
}

{ #category : #versionInfo }
MczInstaller class >> clearVersionInfo [
	Versions := Dictionary new
]

{ #category : #services }
MczInstaller class >> extension [
	^ 'mcz'
]

{ #category : #services }
MczInstaller class >> fileReaderServicesForFile: fileName suffix: suffix [
	^({ self extension. '*' } includes: suffix)
		ifTrue: [ self services ]
		ifFalse: [#()].

]

{ #category : #services }
MczInstaller class >> initialize [
	self clearVersionInfo.
	self registerForFileList.
]

{ #category : #installing }
MczInstaller class >> installFileNamed: aFileName [
	self installStream: (FileStream readOnlyFileNamed: aFileName)
]

{ #category : #installing }
MczInstaller class >> installStream: aStream [
	(self on: aStream) install
]

{ #category : #services }
MczInstaller class >> loadVersionFile: fileName [
	self installFileNamed: fileName

]

{ #category : #'instance creation' }
MczInstaller class >> on: aStream [
	^ self new stream: aStream
]

{ #category : #services }
MczInstaller class >> registerForFileList [
	Smalltalk at: #MCReader ifAbsent: [FileServices registerFileReader: self]
]

{ #category : #services }
MczInstaller class >> serviceLoadVersion [
	^ SimpleServiceEntry
		provider: self
		label: 'load' translatedNoop
		selector: #loadVersionFile:
		description: 'load a package version' translatedNoop
]

{ #category : #services }
MczInstaller class >> services [
	^ Array with: self serviceLoadVersion
]

{ #category : #versionInfo }
MczInstaller class >> storeVersionInfo: aVersion [
	Versions 
		at: aVersion package name
		put: aVersion info asDictionary
]

{ #category : #versionInfo }
MczInstaller class >> unloadMonticello [
	"self unloadMonticello"
	Utilities breakDependents.
	
	Smalltalk at: #MCWorkingCopy ifPresent:
		[:wc | 
		wc allInstances do:
			[:ea | 
			Versions at: ea package name put: ea currentVersionInfo asDictionary.
			ea breakDependents.
			Smalltalk at: #SystemChangeNotifier ifPresent: [:scn | scn uniqueInstance noMoreNotificationsFor: ea]]
	displayingProgress: 'Saving version info...'].
	
	"keep things simple and don't unload any class extensions"
	(ChangeSet superclassOrder: ((PackageInfo named: 'Monticello') classes)) reverseDo:
		[:ea | 
		ea removeFromSystem].
	
	self registerForFileList.
]

{ #category : #versionInfo }
MczInstaller class >> versionInfo [
	^ Versions
]

{ #category : #utilities }
MczInstaller >> associate: tokens [
	| result |
	result := Dictionary new.
	tokens pairsDo: [:key :value | 
					| overwrittenValue |
					overwrittenValue := value.
					value isString ifFalse: [overwrittenValue := value collect: [:ea | self associate: ea]].
					value == 'nil' ifTrue: [overwrittenValue := ''].
					result at: key put: overwrittenValue].
	^ result
]

{ #category : #utilities }
MczInstaller >> checkDependencies [
	| dependencies unmet |
	dependencies := (zip membersMatching: 'dependencies/*') 
			collect: [:member | self extractInfoFrom: (self parseMember: member)].
	unmet := dependencies reject: [:dep |
		self versions: Versions anySatisfy: (dep at: #id)].
	^ unmet isEmpty or: [
		self confirm: (String streamContents: [:s|
			s nextPutAll: 'The following dependencies seem to be missing:'; cr.
			unmet do: [:each | s nextPutAll: (each at: #name); cr].
			s nextPutAll: 'Do you still want to install this package?'])]
]

{ #category : #private }
MczInstaller >> contentsForMember: member [
	^[(member contentStreamFromEncoding: 'utf8') text contents] on: InvalidUTF8
		do: [:exc | 
			"Case of legacy encoding, presumably it is latin-1.
			But if contents starts with a null character, it might be a case of WideString encoded in UTF-32BE"
			| str |
			str := (member contentStreamFromEncoding: 'latin1') text..
			exc return: ((str peek = Character null and: [ str size \\ 4 = 0 ])
				ifTrue: [WideString fromByteArray: str contents asByteArray]
				ifFalse: [str contents])]
]

{ #category : #utilities }
MczInstaller >> extractInfoFrom: dict [
	dict at: #id put: (UUID fromString: (dict at: #id)).
	dict at: #date ifPresent: [:d | d isEmpty ifFalse: [dict at: #date put: (Date fromString: d)]].
	dict at: #time ifPresent: [:t | t isEmpty ifFalse: [dict at: #time put: (Time readFrom: t readStream)]].
	dict at: #ancestors ifPresent: [:a | dict at: #ancestors put: (a collect: [:ea | self extractInfoFrom: ea])].
	^ dict
]

{ #category : #accessing }
MczInstaller >> extractPackageName [
	^ (self parseMember: 'package') at: #name.
	
]

{ #category : #accessing }
MczInstaller >> extractVersionInfo [
	^ self extractInfoFrom: (self parseMember: 'version')
]

{ #category : #installation }
MczInstaller >> install [

	zip := ZipArchive new.
	zip readFrom: stream.
	self checkDependencies ifFalse: [^false].
	self recordVersionInfo.
	(zip membersMatching: 'snapshot/*') 
		sort: [:a :b | a fileName < b fileName];
		do: [:src | self installMember: src].
]

{ #category : #installation }
MczInstaller >> installMember: member [
	 
	self useNewChangeSetDuring:
		[ | contents |
		contents := self contentsForMember: member.
		contents readStream fileInAnnouncing: 'loading ', member fileName.
		]
]

{ #category : #utilities }
MczInstaller >> parseMember: memberOrName [
	| member contents tokens |
	member := zip member: memberOrName.
	contents := self contentsForMember: member.
	tokens := (self scanner scanTokens: contents) first.
	^ self associate: tokens
]

{ #category : #accessing }
MczInstaller >> recordVersionInfo [
	Versions 
		at: self extractPackageName 
		put: self extractVersionInfo
]

{ #category : #accessing }
MczInstaller >> scanner [
	^ Scanner new
]

{ #category : #accessing }
MczInstaller >> stream: aStream [
	stream := aStream
]

{ #category : #utilities }
MczInstaller >> useNewChangeSetDuring: aBlock [
	| changeHolder oldChanges newChanges |
	changeHolder := (ChangeSet respondsTo: #newChanges:)
						ifTrue: [ChangeSet]
						ifFalse: [Smalltalk].
	oldChanges := (ChangeSet respondsTo: #current)
						ifTrue: [ChangeSet current]
						ifFalse: [Smalltalk changes].

	newChanges := ChangeSet new name: (ChangeSet uniqueNameLike: self extractPackageName).
	changeHolder newChanges: newChanges.
	aBlock ensure: [changeHolder newChanges: oldChanges].
]

{ #category : #utilities }
MczInstaller >> versions: aVersionList anySatisfy: aDependencyID [
	^ aVersionList anySatisfy: [:version | 
			aDependencyID = (version at: #id)
				or: [self versions: (version at: #ancestors) anySatisfy: aDependencyID]]
]
