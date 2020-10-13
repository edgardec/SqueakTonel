Class {
	#name : #MCMczReader,
	#superclass : #MCVersionReader,
	#instVars : [
		'zip',
		'infoCache'
	],
	#category : #'Monticello-Storing'
}

{ #category : #accessing }
MCMczReader class >> extension [
	^ 'mcz'
]

{ #category : #testing }
MCMczReader class >> supportsDependencies [
	^ true
]

{ #category : #testing }
MCMczReader class >> supportsVersions [
	^ true
]

{ #category : #utilities }
MCMczReader >> associate: tokens [
	| result |
	result := Dictionary new.
	tokens pairsDo: [:key :value | 
					result at: key put: (value isString
						ifTrue: [value]
						ifFalse: [value collect: [:ea | self associate: ea]])].
	^ result
]

{ #category : #private }
MCMczReader >> contentsForMember: member [
	^[(member contentStreamFromEncoding: 'utf8') text contents] on: InvalidUTF8
		do: [:exc | 
			"Case of legacy encoding, presumably it is latin-1.
			But if contents starts with a null character, it might be a case of WideString encoded in UTF-32BE"
			| str |
			str := (member contentStreamFromEncoding: 'latin1') text.
			exc return: ((str peek = Character null and: [ str size \\ 4 = 0 ])
				ifTrue: [WideString fromByteArray: str contents asByteArray]
				ifFalse: [str contents])]
]

{ #category : #'private-loading' }
MCMczReader >> extractDefinitionsFrom: member [
	| reader |
	(MCSnapshotReader readerClassForFileNamed: member fileName)
		ifNotNil: [:rc |
			reader := rc on: (self contentsForMember: member) readStream.
			definitions addAll: reader definitions]

]

{ #category : #'private-loading' }
MCMczReader >> extractDependencyFrom: zipMember [
	^ MCVersionDependency
		package: (MCPackage named: (zipMember fileName copyAfterLast: $/))
		info: (self extractInfoFrom: (self parseMember: zipMember))
]

{ #category : #'private-loading' }
MCMczReader >> extractInfoFrom: dict [
	^MCWorkingCopy infoFromDictionary: dict cache: self infoCache
]

{ #category : #accessing }
MCMczReader >> infoCache [
	^ infoCache ifNil: [infoCache := Dictionary new]
]

{ #category : #loading }
MCMczReader >> loadDefinitions [
	definitions := OrderedCollection new.
	(self zip memberNamed: 'snapshot.bin') ifNotNil:
		[:m | [^ definitions := (DataStream on: m contentStream) next definitions]
			on: Error do: [:fallThrough ]].
	"otherwise"
	(self zip membersMatching: 'snapshot/*')
		do: [:m | self extractDefinitionsFrom: m].

]

{ #category : #loading }
MCMczReader >> loadDependencies [
	dependencies := (self zip membersMatching: 'dependencies/*') collect: [:m | self extractDependencyFrom: m].
	dependencies := dependencies asArray.

]

{ #category : #loading }
MCMczReader >> loadPackage [
	| dict |
	dict := self parseMember: 'package'.
	package := MCPackage named: (dict at: #name)
]

{ #category : #loading }
MCMczReader >> loadVersionInfo [
	info := self extractInfoFrom: (self parseMember: 'version')
]

{ #category : #utilities }
MCMczReader >> parseMember: memberOrName [
	| member contents tokens |
	member := self zip member: memberOrName.
	contents := self contentsForMember: member.
	tokens := (self scanner scanTokens: contents) first.
	^ self associate: tokens
]

{ #category : #constants }
MCMczReader >> scanner [
	^ MCScanner
]

{ #category : #accessing }
MCMczReader >> zip [
	zip ifNil:
		[zip := ZipArchive new.
		zip readFrom: stream].
	^ zip
]
