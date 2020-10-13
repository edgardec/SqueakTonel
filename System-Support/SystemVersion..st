"
I am responsible for maintaining what version of Squeak and the VM is running.  I also track all of the update items that have been included in the image.

I'm invoked at auto start to get the latest plugins, etc.
"
Class {
	#name : #SystemVersion,
	#superclass : #Object,
	#instVars : [
		'version',
		'date',
		'highestUpdate',
		'updates'
	],
	#classVars : [
		'Current'
	],
	#category : #'System-Support'
}

{ #category : #accessing }
SystemVersion class >> current [
	Current ifNil: [Current := SystemVersion new].
	^Current
]

{ #category : #updating }
SystemVersion class >> currentPluginVersion [
	^Smalltalk vmVersion
]

{ #category : #'instance creation' }
SystemVersion class >> newVersion: versionName [
	| newVersion |
	
	self assert: (versionName beginsWith: 'Squeak').
	
	newVersion := self new version: versionName.

	self assert: newVersion majorVersionNumber notNil.
	self assert: newVersion minorVersionNumber notNil.
	self assert: newVersion isSqueak.
	
	self assert: (#(isRelease isAlpha isFeatureFreeze isCodeFreeze isReleaseCandidate)
		anySatisfy: [:sel | newVersion perform: sel]).
	
	newVersion highestUpdate: self current highestUpdate.
	Current := newVersion

]

{ #category : #accessing }
SystemVersion class >> parseVersionString: versionString [
	"Answer the version of this release as version, date, update."
	"SystemVersion parseVersionString: 'Squeak3.1alpha of 28 February 2001 [latest update: #3966]' "

	| version date update |

	[ | stream |
	stream := ReadStream on: versionString.
	version := stream upToAll: ' of '.
	date := Date readFrom: stream.
	stream upToAll: ' #'.
	update := Number readFrom: stream]
		on: Error
		do: [^nil].
	^{version. date. update.}
]

{ #category : #accessing }
SystemVersion class >> pluginVersion: availableVersionString newerThan: currentVersionString [
	| currentVersion availableVersion |
	(currentVersionString isEmptyOrNil
		or: [availableVersionString isEmptyOrNil])
		ifTrue: [^true].
	currentVersion := self parseVersionString: currentVersionString.
	availableVersion := self parseVersionString: availableVersionString.
	(currentVersion isNil
		or: [availableVersion isNil])
		ifTrue: [^false].
	^(currentVersion at: 2) < (availableVersion at: 2)
]

{ #category : #'class initialization' }
SystemVersion class >> setVersion [
	"SystemVersion setVersion"

	| newName |
	newName := UIManager default
		request: ('Please name this system version.\The old version is:\',
					self current version, '\set on ', self current date asString) withCRs
 		initialAnswer: self current version.
	newName size > 0 ifTrue:
		[self newVersion: newName]
]

{ #category : #'continuous integration' }
SystemVersion >> ciStatusBadgeUrl [

	| branch |
	branch := 'squeak-{1}{2}{3}' format: {
		self isRelease ifTrue: [self majorVersionNumber] ifFalse: [''].
		self isRelease ifTrue: ['.'] ifFalse: ['trunk'].
		self isRelease ifTrue: [self minorVersionNumber] ifFalse: [''] }.
	
	^ 'https://api.travis-ci.org/squeak-smalltalk/squeak-app.png?branch=', branch
]

{ #category : #'continuous integration' }
SystemVersion >> ciStatusPageUrl [
	"In a release image, let the user see the overview of branches to choose from. I am not aware of a permanent link for a specific branch. In a trunk image, just let Travis report the state of the main branch, which is usually for trunk builds."

	^ 'http://travis-ci.org/squeak-smalltalk/squeak-app{1}' format: {
		self isRelease ifFalse: [''] ifTrue: ['/branches'] }
]

{ #category : #accessing }
SystemVersion >> date [
	^date
]

{ #category : #accessing }
SystemVersion >> date: newDate [
	date := newDate
]

{ #category : #accessing }
SystemVersion >> datedVersion [
	"Answer the version of this release."

	^ self version asString , ' of ' , self date printString
]

{ #category : #printing }
SystemVersion >> description [

	self isAlpha ifTrue: [^ 'ALPHA. New features which are not stable yet may come in\with each update. Also, existing features might not work reliably\due to updates and related changes.' translated withCRs].
	
	(self isFeatureFreeze and: [self isCodeFreeze not]) ifTrue: [^ 'FEATURE FREEZE. A new release is being prepared.\There will be only bugfixes, but no new features.' translated withCRs].
	
	self isCodeFreeze ifTrue: [^ 'RELEASE CANDIDATE. The new release is almost ready.\There will be only bugfixes, if any.' translated withCRs].
		
	self isRelease ifTrue: [^ ''].
]

{ #category : #accessing }
SystemVersion >> highestUpdate [

	^highestUpdate ifNil: [
		highestUpdate := self updates isEmpty
			ifTrue: [ 0 ]
			ifFalse: [ self updates max ] ]
]

{ #category : #accessing }
SystemVersion >> highestUpdate: anInteger [
	highestUpdate := anInteger
]

{ #category : #accessing }
SystemVersion >> includesUpdate: anUpdate [
	^self updates includes: anUpdate
]

{ #category : #initialize }
SystemVersion >> initialize [
	version := 'No version set'.
	date := Date today.
	updates := Set new.

]

{ #category : #testing }
SystemVersion >> isAlpha [
	^ (version endsWith: #alpha)
]

{ #category : #testing }
SystemVersion >> isCodeFreeze [
	^ self isFeatureFreeze and: [(version endsWith: #beta) not]
]

{ #category : #testing }
SystemVersion >> isFeatureFreeze [
	^ self isAlpha not and: [self isRelease not]
]

{ #category : #testing }
SystemVersion >> isPharo [
	^ version includesSubstring: 'Pharo'
]

{ #category : #testing }
SystemVersion >> isRelease [
	^ self isReleaseCandidate not and: [version last isDigit]
]

{ #category : #testing }
SystemVersion >> isReleaseCandidate [
	^ (version findTokens: 'rc') size > 1
]

{ #category : #testing }
SystemVersion >> isSqueak [
	^ version includesSubstring: 'Squeak'
]

{ #category : #accessing }
SystemVersion >> majorMinorVersion [
	"Return the major/minor version number of the form X.Y, without any 'alpha' or 'beta' or other suffix."
	
	| char stream |
	^ (version includes: $.)
		ifTrue:
			[stream := ReadStream on: version, 'x'.
			stream upTo: $..
			char := stream next.
			[char isDigit]
				whileTrue: [char := stream next].
			version copyFrom: 1 to: stream position - 1]
		ifFalse:
			[version]

"
(SystemVersion new version: 'Squeak3.7alpha') majorMinorVersion
(SystemVersion new version: 'Testing') majorMinorVersion
SystemVersion current majorMinorVersion
"


]

{ #category : #accessing }
SystemVersion >> majorVersionNumber [

	(version indexOf: $.) = 0 ifTrue: [^ nil].
	^ (version copyFrom: 'Squeak' size to: (version indexOf: $.)) asInteger
]

{ #category : #accessing }
SystemVersion >> minorVersionNumber [

	| pointIndex |
	pointIndex := version indexOf: $..
	pointIndex = 0 ifTrue: [^ nil].
	^ (version
		copyFrom: pointIndex
		to: (self isRelease
			"e.g. Squeak5.1"
			ifTrue: [version size]
			"e.g. Squeak5.1rc5"
			ifFalse: [(pointIndex+1 to: version size) detect: [:ea | (version at: ea) isDigit not]])) asInteger
]

{ #category : #printing }
SystemVersion >> printOn: stream [
	stream
		nextPutAll: self datedVersion;
		nextPutAll: ' update ' , self highestUpdate printString
]

{ #category : #accessing }
SystemVersion >> registerUpdate: update [
	self updates add: update.
	self resetHighestUpdate
]

{ #category : #accessing }
SystemVersion >> releaseCandidateNumber [
	^ self isReleaseCandidate
		ifFalse: [0]
		ifTrue: [(version findTokens: 'rc') last asInteger]
]

{ #category : #accessing }
SystemVersion >> resetHighestUpdate [
	highestUpdate := nil
]

{ #category : #accessing }
SystemVersion >> unregisterUpdate: update [
	self updates remove: update ifAbsent: []
]

{ #category : #accessing }
SystemVersion >> updates [
	^updates
]

{ #category : #accessing }
SystemVersion >> version [
	^version
]

{ #category : #accessing }
SystemVersion >> version: newVersion [
	version := newVersion
]
