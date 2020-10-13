"
A package release refers to a specific version of the package.
Releases are auto numbered (with a VersionNumber) and also has a designated version name which can be whatever the maintainer wants.
There is also a release note and the URL for download. The inherited url is for any homepage for the release.
The instvar publisher refers to the SMAccount that owned the package at the time of the release and the instvar package refers to the owning package.
The instvar repository holds a String that is used to connect to the live repository for the package release, for example a Monticello repository.
"
Class {
	#name : #SMPackageRelease,
	#superclass : #SMCategorizableObject,
	#instVars : [
		'publisher',
		'automaticVersion',
		'version',
		'note',
		'downloadUrl',
		'package',
		'repository',
		'sha1sum'
	],
	#category : #'SMBase-domain'
}

{ #category : #'instance creation' }
SMPackageRelease class >> newFromRelease: aPackageRelease package: aPackage [
	"Create a new release from a given release."

	^super new initializeFromRelease: aPackageRelease package: aPackage
]

{ #category : #configurations }
SMPackageRelease >> addConfiguration [
	"Create and add a new SMPackageReleaseConfiguration and return it."

	^ self addResource: (SMPackageReleaseConfiguration newIn: map)
]

{ #category : #private }
SMPackageRelease >> addToLocalCache [
	self downloadUrl ifNotNil: [map cache add: self]
]

{ #category : #accessing }
SMPackageRelease >> automaticVersion [
	"Return the VersionNumber for me."

	^automaticVersion
]

{ #category : #accessing }
SMPackageRelease >> automaticVersionString [
	"Return my VersionNumber as a String."

	^automaticVersion versionString
]

{ #category : #accessing }
SMPackageRelease >> cacheDirectory [
	^ map cache directoryForPackageRelease: self
]

{ #category : #accessing }
SMPackageRelease >> calculateSha1sum [
	"Return the checksum of the currently cached file contents."

	^SecureHashAlgorithm new hashMessage: self contents
	
	
		
]

{ #category : #configurations }
SMPackageRelease >> configurations [
	"Return all SMPackageReleaseConfigurations attached to this release."


	^ self embeddedResources select: [:er | er isConfiguration]
]

{ #category : #accessing }
SMPackageRelease >> contents [
	"Return the contents of the cached file.
	If it is not downloadable, or if the file
	is not cached, return nil."

	^map cache contents: self
]

{ #category : #accessing }
SMPackageRelease >> correctSha1sum: content [
	"Return if the checksum of the content is correct.
	If we have none, then we consider that to be correct."
	
	^sha1sum isNil or: [sha1sum = (SecureHashAlgorithm new hashMessage: content)]
	
	
		
]

{ #category : #deletion }
SMPackageRelease >> delete [
	super delete.
	package removeRelease: self
]

{ #category : #services }
SMPackageRelease >> download [
	"Force a download into the cache regardless if it is already there."

	^map cache download: self
]

{ #category : #accessing }
SMPackageRelease >> downloadFileName [
	"Cut out the filename from the url."

	downloadUrl isEmpty ifTrue: [^nil].
	^downloadUrl asUrl path last
]

{ #category : #accessing }
SMPackageRelease >> downloadUrl [
	^downloadUrl
]

{ #category : #accessing }
SMPackageRelease >> downloadUrl: urlString [
	downloadUrl := urlString
]

{ #category : #services }
SMPackageRelease >> eitherVersion [
	"Return either version:
		1. If the maintainer entered a version then we use that.
		2. Otherwise we use the automatic version with an 'r' prepended."

	^version notEmpty
			ifTrue:[version]
			ifFalse:['r', automaticVersion versionString]
]

{ #category : #services }
SMPackageRelease >> ensureInCache [
	"Makes sure the file is in the cache.
	Return true on success, otherwise false."

	^map cache add: self
]

{ #category : #printing }
SMPackageRelease >> fullDescription [
	"Return a full textual description of the package release."

	| s |
	s := TextStream on: (Text new: 400).
	self describe: self package name withBoldLabel: 'Package Name: ' on: s.
	name isEmptyOrNil ifFalse:
		[self describe: self name withBoldLabel: 'Release Name: ' on: s].
	summary isEmptyOrNil ifFalse:
		[self describe: self summary withBoldLabel: 'Release Summary: ' on: s].

	self 
		describe: self version
		withBoldLabel: 'Version: '
		on: s.

	self note isEmptyOrNil 
		ifFalse: 
			[ s withAttribute: (TextIndent tabs: 1) do: [s nextPutAll: self note withSqueakLineEndings].
			s cr].

	categories isEmptyOrNil 
		ifFalse: 
			[s
				cr;
				withAttribute: TextEmphasis bold do: [s nextPutAll: 'Categories: '];
				cr.
			(self categories sorted: [:a :b | a path < b path])
				do: [:c | 
					s
						tab;
						withAttribute: TextEmphasis italic
							do: 
								[c parentsDo: 
										[:p | 
										s
											nextPutAll: p name;
											nextPutAll: '/'].
								s nextPutAll: c name];
						nextPutAll: ' - ' , c summary;
						cr].
			s cr].

	created ifNotNil: [
		s
			withAttribute: TextEmphasis bold do: [ s nextPutAll: 'Created: ' ];
			print: self created;
			cr].
	updated ifNotNil: [
		s
			withAttribute: TextEmphasis bold do: [ s nextPutAll: 'Modified: ' ];
			print: self updated;
			cr].
	publisher ifNotNil: [
		s
			withAttribute: TextEmphasis bold
			do: [s nextPutAll: 'Publisher: '].
		s
			withAttribute: (PluggableTextAttribute
					evalBlock: [self userInterface
									sendMailTo: self publisher email
									regardingPackageRelease: self])
			do: [s nextPutAll: self publisher nameAndEmail];	
			cr].

	url isEmptyOrNil 
		ifFalse: 
			[s
				withAttribute: TextEmphasis bold do: [s nextPutAll: 'Homepage:'];
				tab;
				withAttribute: (TextURL new url: url) do: [s nextPutAll: url];
				cr].
	self downloadUrl isEmptyOrNil 
		ifFalse: 
			[s
				withAttribute: TextEmphasis bold do: [s nextPutAll: 'Download:'];
				tab;
				withAttribute: (TextURL new url: self downloadUrl)
					do: [s nextPutAll: self downloadUrl];
				cr].
	^s contents.


]

{ #category : #services }
SMPackageRelease >> fullVersion [
	"Return version followed by the automatic version
	with r prepended in parenthesis."

	^version, ' (r', automaticVersion versionString, ')'
]

{ #category : #view }
SMPackageRelease >> getLink: aBuilder [
	"Return a link for using on the web."

	^self getLink: aBuilder view: aBuilder view
]

{ #category : #view }
SMPackageRelease >> getLink: aBuilder view: aView [
	"Return a link for using on the web."

	^aBuilder getLinkTop: self relativeUrl text: self packageNameWithVersion
]

{ #category : #view }
SMPackageRelease >> getShortLink: aBuilder [

	^aBuilder getLinkTop: self relativeUrl text: self listName
]

{ #category : #configurations }
SMPackageRelease >> hasFulfilledConfiguration [
	"Is any of the configurations already fulfilled?
	A fulfilled configuration has all required releases
	already installed, this means the release can be
	trivially installed."
	
	^self workingConfigurations anySatisfy: [:c | c isFulfilled]
]

{ #category : #configurations }
SMPackageRelease >> hasNoConfigurations [
	"Does this release lack configurations,
	both working or failed ones? This is interpreted
	as if the release has no dependencies."

	^self configurations isEmpty
]

{ #category : #'initialize-release' }
SMPackageRelease >> initializeFromRelease: parentRelease package: aPackage [ 
	"Initialize package release from a given parent.  Branch if needed."
	self
		map: aPackage map
		id: UUID new.
	package := aPackage.
	aPackage isCommunitySupported ifTrue: [ self beCommunitySupported ].
	automaticVersion := parentRelease
		ifNil: [ VersionNumber first ]
		ifNotNil:
			[ self downloadUrl: parentRelease downloadUrl.
			parentRelease nextOrBranch ].
	version := note := String empty
]

{ #category : #services }
SMPackageRelease >> install [
	"Install this package release."

	^map installPackageRelease: self
]

{ #category : #testing }
SMPackageRelease >> isCached [
	"Delegate to last release."

	^map cache includes: self
]

{ #category : #testing }
SMPackageRelease >> isCompatibleWithCurrentSystemVersion [
	"Return true if this release is listed as being compatible with the SystemVersion of the current image.  Only checks major/minor version number; does not differentiate between alpha/beta/gamma releases.  Checks version categories of both the SMPackageRelease and the parent SMPackage."

	| current |
	current := (self majorMinorVersionFrom: SystemVersion current version)
		copyWithout: Character space.
	self categories, self package categories do: [:c |
		((c parent name = 'Squeak versions') and: [
			((self majorMinorVersionFrom: c name)
				copyWithout: Character space) = current])
			ifTrue: [^true]].
	^ false

]

{ #category : #testing }
SMPackageRelease >> isDownloadable [
	"Answer if I can be downloaded.
	We simply verify that the download url
	ends with a filename."

	^self downloadFileName isEmptyOrNil not
]

{ #category : #testing }
SMPackageRelease >> isInstallable [
	"Answer if there is any installer for me.
	This depends typically on the filename of
	the download url, but can in the future
	depend on other things too.
	It does *not* say if the release is installed or not."

	^SMInstaller isInstallable: self
]

{ #category : #testing }
SMPackageRelease >> isInstalled [
	"Answer if this release is installed."

	^(map installedReleaseOf: package) == self
]

{ #category : #testing }
SMPackageRelease >> isPackageRelease [
	^true
]

{ #category : #testing }
SMPackageRelease >> isPublished [
	"It is published when the publisher is set."

	^publisher notNil
]

{ #category : #testing }
SMPackageRelease >> isUpgradeable [
	"Answer if there is any installer that can upgrade me.
	This depends typically on the filename of
	the download url, but can in the future
	depend on other things too.
	It does *not* say if the package is installed or not
	or if there is a newer version available or not."

	^SMInstaller isUpgradeable: self
]

{ #category : #printing }
SMPackageRelease >> listName [
	"Return something suitable for showing in lists.
	We list the manual version after a dash if it is available.
	We don't list the release name."

	^version isEmpty
		ifFalse: [self automaticVersion versionString , '-', version]
		ifTrue: [self automaticVersion versionString] 
]

{ #category : #private }
SMPackageRelease >> majorMinorVersionFrom: aVersionName [

	| start |
	start := aVersionName indexOf: $..
	start = 0 ifTrue: [^ aVersionName].
	aVersionName size = start ifTrue: [^ aVersionName].
	start + 1 to: aVersionName size do: [:i |
		(aVersionName at: i) isDigit ifFalse: [^aVersionName copyFrom: 1 to: i - 1]].
	^aVersionName
]

{ #category : #testing }
SMPackageRelease >> newerThan: aRelease [ 
	"Answer if this release was made after <aRelease>."
	^ (aRelease automaticVersion inSameBranchAs: automaticVersion)
		ifTrue: [ aRelease automaticVersion < automaticVersion ]
		ifFalse: [ aRelease automaticVersion numbers first > automaticVersion numbers first ]
]

{ #category : #services }
SMPackageRelease >> nextOrBranch [
	"Return a new automaticVersion that is either
	the next following my version, or if that is taken
	a branch, or if that is taken too - a branch from it and so on.
	Yes, it sucks, but I don't have time hacking VersionNumber right now."

	| nextVersion nextBranch |
	nextVersion := automaticVersion next.
	(package releaseWithAutomaticVersion: nextVersion) ifNil: [^nextVersion].
	nextBranch := automaticVersion branchNext.
	[(package releaseWithAutomaticVersion: nextBranch) notNil]
		whileTrue: [nextBranch := nextBranch branchNext].
	^nextBranch 

]

{ #category : #accessing }
SMPackageRelease >> note [
	^note
]

{ #category : #accessing }
SMPackageRelease >> note: aString [
	note := aString
]

{ #category : #services }
SMPackageRelease >> noteInstalled [
	"This package release was just successfully installed.
	We tell the map so that it can keep track of what
	package releases are installed."

	map noteInstalled: self
]

{ #category : #services }
SMPackageRelease >> noteUninstalled [
	"This package release was just successfully uninstalled.
	We tell the map so that it can keep track of what
	package releases are installed."

	self error: 'Uninstall is not working yet!'.
	map noteUninstalled: self
]

{ #category : #testing }
SMPackageRelease >> olderThan: aRelease [
	"Answer if this release was made before <aRelease>."
	
	^automaticVersion < aRelease automaticVersion
]

{ #category : #accessing }
SMPackageRelease >> package [
	"Get the package that I belong to."

	^package
]

{ #category : #private }
SMPackageRelease >> package: aPackage [
	"Set when I am created."

	package := aPackage
]

{ #category : #printing }
SMPackageRelease >> packageNameWithVersion [
	"Return '<packageName> <autoVersion>-<version>' like:
		'SqueakMap 5-0.92'	"

	^package name, ' ', self listName
]

{ #category : #services }
SMPackageRelease >> parentRelease [
	"Return my parent release based on the automatic
	version number."

	^package parentReleaseFor: self
]

{ #category : #services }
SMPackageRelease >> previousRelease [
	"Return the release before me.
	Returns nil if there is none.
	This is chronological order and not how they relate."

	^package previousReleaseFor: self
]

{ #category : #printing }
SMPackageRelease >> printName [
	"Return a String identifying object without context."

	^self packageNameWithVersion
]

{ #category : #printing }
SMPackageRelease >> printOn: aStream [

	aStream nextPutAll: self class name, '[', self packageNameWithVersion, ']'
]

{ #category : #accessing }
SMPackageRelease >> publisher [
	^publisher
]

{ #category : #accessing }
SMPackageRelease >> publisher: anObject [
	publisher := anObject
]

{ #category : #services }
SMPackageRelease >> refreshInCache [
	"Delete and re-download the file back into the cache.
	Return true on success, otherwise false."
	map cache remove: self.
	^ self 
		sha1sum: nil; 
		ensureInCache
]

{ #category : #services }
SMPackageRelease >> relativeUrl [
	"Return the relative url for this release on an SM server."
	
	^'package/', package id asString, '/autoversion/', automaticVersion versionString
]

{ #category : #private }
SMPackageRelease >> removeFromLocalCache [
	self downloadUrl ifNotNil: [map cache remove: self]
]

{ #category : #accessing }
SMPackageRelease >> repository [
	^repository
]

{ #category : #accessing }
SMPackageRelease >> repository: aString [
	repository := aString
]

{ #category : #accessing }
SMPackageRelease >> sha1sum [
	^sha1sum
]

{ #category : #accessing }
SMPackageRelease >> sha1sum: aString [
	sha1sum := aString
]

{ #category : #services }
SMPackageRelease >> smartVersion [
	"This method is used to ensure that we always have a
	version name for the package release even if the maintainer didn't
	bother to enter one. Is is calculated like this:
		1. If the maintainer entered a version then we use that.
		2. Otherwise we use the automatic version with an 'r' prepended.
		3. If the release is not published we enclose it in parenthesis."

	^ self isPublished ifTrue: [self eitherVersion] ifFalse: ['(', self eitherVersion, ')']
]

{ #category : #printing }
SMPackageRelease >> type [

	^'Package release'
]

{ #category : #services }
SMPackageRelease >> upgrade [
	"Upgrade this package release if there is a new release available."

	| newRelease |
	newRelease := package lastPublishedReleaseForCurrentSystemVersionNewerThan: self.
	newRelease ifNotNil: [(SMInstaller forPackageRelease: newRelease) upgrade]
]

{ #category : #accessing }
SMPackageRelease >> version [
	^version
]

{ #category : #accessing }
SMPackageRelease >> version: aString [ 
	version := aString
]

{ #category : #view }
SMPackageRelease >> viewFor: uiObject [
	"This is a double dispatch mechanism for multiple views
	for multiple uis."

	^uiObject packageReleaseViewOn: self
]

{ #category : #configurations }
SMPackageRelease >> workingConfigurations [
	"Return all working configurations."
	
	^ self configurations select: [:c | c isWorking ]
]
