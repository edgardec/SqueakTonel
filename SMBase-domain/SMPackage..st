"
An SMPackage represents a named piece of an installable ""thing"" in the image. Typically it is a code package, but it can be other things too.
It owns a collection of SMPackageReleases. Each release represents a version of the package, and each release has a URL that refers to the actual content that can be installed.

An SMPackage also knows its packageInfoName which can tie it into the image.
"
Class {
	#name : #SMPackage,
	#superclass : #SMDocument,
	#instVars : [
		'releases',
		'packageInfoName',
		'repository'
	],
	#category : #'SMBase-domain'
}

{ #category : #private }
SMPackage >> addRelease: aSMPackageRelease [ 
	"Add the release. Make sure package is set."
	(releases includes: aSMPackageRelease) ifFalse: [ releases add: aSMPackageRelease ].
	aSMPackageRelease package: self.
	^ aSMPackageRelease
]

{ #category : #cache }
SMPackage >> cacheDirectory [
	^ self lastRelease cacheDirectory
]

{ #category : #accessing }
SMPackage >> currentVersion [
	^self isPublished ifTrue: [self lastPublishedRelease version]
]

{ #category : #private }
SMPackage >> delete [
	"Delete me. Delete my releases."

	super delete.
	self deleteReleases
]

{ #category : #private }
SMPackage >> deleteReleases [
	"Delete my releases."

	releases copy do: [:release | release delete]
]

{ #category : #cache }
SMPackage >> download [
	"Force download into cache."

	self isReleased ifFalse: [self error: 'There is no release for this package to download.'].
	^self lastRelease download
]

{ #category : #cache }
SMPackage >> ensureInCache [
	"Makes sure all release files are in the cache."

	self releases do: [:rel | rel ensureInCache ]
]

{ #category : #services }
SMPackage >> firstRelease [
	"Return the first release."

	^releases isEmpty ifTrue: [nil] ifFalse: [releases first]
]

{ #category : #accessing }
SMPackage >> fullDescription [
	"Return a full textual description of the package. 
	Most of the description is taken from the last release."
	| s publishedRelease sqDescription |
	s := TextStream on: (Text new: 400).

	self
		describe: name
		withBoldLabel: 'Name:		'
		on: s.

	summary isEmptyOrNil
		ifFalse: [self
				describe: summary
				withBoldLabel: 'Summary:	'
				on: s ].

	author isEmptyOrNil
		ifFalse: [s
				withAttribute: TextEmphasis bold
				do: [s nextPutAll: 'Author:'];
				 tab;
				 tab.
			s
				withAttribute: (PluggableTextAttribute
						evalBlock: [self userInterface
										sendMailTo: (SMUtilities stripEmailFrom: author)
										regardingPackageRelease: self lastRelease])
				do: [s nextPutAll: author];
				 cr].
	self owner
		ifNotNil: [s
				withAttribute: TextEmphasis bold
				do: [s nextPutAll: 'Owner:'];
				 tab; tab.
			s
				withAttribute: (PluggableTextAttribute
						evalBlock: [self userInterface
										sendMailTo: self owner email
										regardingPackageRelease: self lastRelease])
				do: [s nextPutAll: self owner nameAndEmail];	
				 cr].

	self maintainers isEmpty ifFalse: [
		s withAttribute: TextEmphasis bold do: [s nextPutAll: 'Co-Maintainers:']; tab.
		self maintainers do: [:com |
			com = self maintainers first ifFalse: [s nextPutAll: ', '].
			s
				withAttribute:
					(PluggableTextAttribute
						evalBlock: [self userInterface
									sendMailTo: com email
									regardingPackageRelease: self lastRelease])
				do: [s nextPutAll: com nameAndEmail]].
				s cr].

	description isEmptyOrNil
		ifFalse: [sqDescription := description withSqueakLineEndings.
			s cr.
			s
				withAttribute: TextEmphasis bold
				do: [s nextPutAll: 'Description:'].
			s cr.
			s
				withAttribute: (TextIndent tabs: 1)
				do: [s next: (sqDescription findLast: [ :c | c isSeparator not ]) putAll: sqDescription].
			s cr ].

	self describeCategoriesOn: s indent: 1.

	s cr.
	publishedRelease := self lastPublishedRelease.
	self
		describe: (self publishedVersion ifNil: ['<not published>'])
		withBoldLabel: 'Published Version: '
		on: s.
	self isPublished ifTrue: [
		s
			withAttribute: TextEmphasis bold do: [ s nextPutAll: 'Created: ' ];
			print: publishedRelease created;
			cr.
			self note isEmptyOrNil
				ifFalse: [s
					withAttribute: TextEmphasis bold
					do: [s nextPutAll: 'Release Note:'].
			s cr.
			s
				withAttribute: (TextIndent tabs: 1)
				do: [s nextPutAll: publishedRelease note withSqueakLineEndings].
			s cr ]].

	url isEmptyOrNil
		ifFalse: [s cr;
				withAttribute: TextEmphasis bold
				do: [s nextPutAll: 'Homepage: '];
				withAttribute: (TextURL new url: url)
				do: [s nextPutAll: url];
				 cr].
	packageInfoName isEmptyOrNil
		ifFalse: [self
				describe: packageInfoName
				withBoldLabel: 'Package Info: '
				on: s ].

	^ s contents
]

{ #category : #view }
SMPackage >> getCoEditLink: aBuilder [
	"Return a link for using on the web.
	Relative to the current view."

	^self getCoEditLink: aBuilder view: aBuilder view
]

{ #category : #view }
SMPackage >> getCoEditLink: aBuilder view: aView [
	"Return a link for using on the web."

	^aBuilder getLink: 'copackage/', id asString, '/edit' text: 'edit' view: aView
]

{ #category : #view }
SMPackage >> getCoEditReleasesLink: aBuilder [
	"Return a link for using on the web.
	Relative to the current view."

	^self getCoEditReleasesLink: aBuilder view: aBuilder view
]

{ #category : #view }
SMPackage >> getCoEditReleasesLink: aBuilder view: aView [
	"Return a link for using on the web."

	^aBuilder getLink: 'copackage/', id asString, '/editreleases' text: 'edit releases' view: aView
]

{ #category : #view }
SMPackage >> getCoLink: aBuilder [
	"Return a link for using on the web.
	Relative to the current view."

	^self getCoLink: aBuilder view: aBuilder view
]

{ #category : #view }
SMPackage >> getCoLink: aBuilder view: aView [
	"Return a link for using on the web."

	^aBuilder getLink: 'copackage/', id asString text: name view: aView
]

{ #category : #view }
SMPackage >> getEditLink: aBuilder [
	"Return a link for using on the web.
	Relative to the current view."

	^self getEditLink: aBuilder view: aBuilder view
]

{ #category : #view }
SMPackage >> getEditLink: aBuilder view: aView [
	"Return a link for using on the web."

	^aBuilder getLink: 'package/', id asString, '/edit' text: 'edit' view: aView
]

{ #category : #view }
SMPackage >> getEditReleasesLink: aBuilder [
	"Return a link for using on the web.
	Relative to the current view."

	^self getEditReleasesLink: aBuilder view: aBuilder view
]

{ #category : #view }
SMPackage >> getEditReleasesLink: aBuilder view: aView [
	"Return a link for using on the web."

	^aBuilder getLink: 'package/', id asString, '/editreleases' text: 'edit releases' view: aView
]

{ #category : #view }
SMPackage >> getLink: aBuilder [
	"Return a link for using on the web.
	Relative to the current view."

	^self getLink: aBuilder view: aBuilder view
]

{ #category : #view }
SMPackage >> getLink: aBuilder view: aView [
	"Return a link for using on the web."

	^aBuilder getLink: 'package/', id asString text: name view: aView
]

{ #category : #'initialize-release' }
SMPackage >> initialize [
	"Initialize package."

	super initialize.
	packageInfoName := ''.
	releases := OrderedCollection new
]

{ #category : #installation }
SMPackage >> install [
	"Install the latest newer published version for this version of Squeak."

	^map installPackage: self
]

{ #category : #installation }
SMPackage >> installedRelease [
	"Return the installed release.
	We ask the map. Return nil if this package is not installed."

	^map installedReleaseOf: self
]

{ #category : #printing }
SMPackage >> installedVersion [
	"Return the version String for the installed version.
	We ask the map. Return nil if this package is not installed."

	^self installedRelease ifNotNil: [:r | r smartVersion]
]

{ #category : #testing }
SMPackage >> isAvailable [
	"Answer if I am old or not installed regardless of
	if there is installer support for me. It also does
	not care if the newer release is not published
	or no for this Squeak version."

	^self isOld or: [self isInstalled not]
]

{ #category : #testing }
SMPackage >> isCached [
	"Is the last release corresponding to me in the local file cache?
	NOTE: This doesn't honour #published nor if the release is
	intended for the current Squeak version."

	^self isReleased and: [self lastRelease isCached]
]

{ #category : #testing }
SMPackage >> isInstallable [
	"Answer if any of my releases can be installed."

	^ releases anySatisfy: [:rel | rel isInstallable]
]

{ #category : #testing }
SMPackage >> isInstallableAndNotInstalled [
	"Answer if there is any installer that
	can install me and I am not yet installed."

	^self isInstallable and: [self isInstalled not]
]

{ #category : #testing }
SMPackage >> isInstalled [
	"Answer if any version of me is installed."

	^(map installedReleaseOf: self) notNil
]

{ #category : #testing }
SMPackage >> isOld [
	"Answer if I am installed and there also is a
	newer version available *regardless* if it is
	not published or not for this Squeak version.
	This is for people who want to experiment!"

	| installed |
	installed := map installedReleaseOf: self.
	^installed
		ifNil: [false]
		ifNotNil: [
			self releases anySatisfy: [:r |
				r newerThan: installed ]]
]

{ #category : #testing }
SMPackage >> isPackage [
	^true
]

{ #category : #testing }
SMPackage >> isPublished [
	"Answer if I have public releases."

	^releases anySatisfy: [:rel | rel isPublished]
]

{ #category : #testing }
SMPackage >> isReleased [
	^ releases isEmpty not
]

{ #category : #testing }
SMPackage >> isSafeToInstall [
	"Answer if I am NOT installed and there also is a
	published version for this version of Squeak available."
	^ self isInstalled not
		and: [self lastReleaseForCurrentSystemVersion notNil]
]

{ #category : #testing }
SMPackage >> isSafelyAvailable [
	"Answer if I am old or not installed regardless of
	if there is installer support for me. The
	newer release should be published
	and meant for this Squeak version."

	^self isSafeToInstall or: [self isSafelyOld]
]

{ #category : #testing }
SMPackage >> isSafelyOld [
	"Answer if I am installed and there also is a
	newer published version for this version of Squeak available."

	| installed |
	installed := self installedRelease.
	^installed ifNil: [false] ifNotNil: [
		^(self lastPublishedReleaseForCurrentSystemVersionNewerThan: installed) notNil]
]

{ #category : #testing }
SMPackage >> isSafelyOldAndUpgradeable [
	"Answer if I am installed and there also is a
	newer published version for this version of Squeak available
	that can be upgraded to (installer support)."

	| installed newRelease |
	installed := self installedRelease.
	^installed ifNil: [false] ifNotNil: [
		newRelease := self lastPublishedReleaseForCurrentSystemVersionNewerThan: installed.
		^newRelease ifNil: [false] ifNotNil: [newRelease isUpgradeable]]
]

{ #category : #services }
SMPackage >> lastPublishedRelease [
	"Return the latest published release."

	^releases isEmpty ifTrue: [nil] ifFalse: [
		releases reversed detect: [:r | r isPublished] ifNone:[nil]]
]

{ #category : #services }
SMPackage >> lastPublishedReleaseForCurrentSystemVersion [
	"Return the latest published release marked
	as compatible with the current SystemVersion."

	^releases isEmpty ifTrue: [nil] ifFalse: [
		releases reversed detect: [:r |
			r isPublished and: [r isCompatibleWithCurrentSystemVersion]]
				ifNone:[nil]]
]

{ #category : #services }
SMPackage >> lastPublishedReleaseForCurrentSystemVersionNewerThan: aRelease [
	"Return the latest published release marked
	as compatible with the current SystemVersion
	that is newer than the given release."

	^releases isEmpty ifTrue: [nil] ifFalse: [
		releases reversed detect: [:r |
			(r isPublished and: [r newerThan: aRelease])
				and: [r isCompatibleWithCurrentSystemVersion]]
				 	ifNone:[nil]]
]

{ #category : #services }
SMPackage >> lastRelease [
	"Return the latest release."

	^releases isEmpty ifTrue: [nil] ifFalse: [releases last]
]

{ #category : #services }
SMPackage >> lastReleaseForCurrentSystemVersion [
	"Return the latest published release marked
	as compatible with the current SystemVersion."
	^ releases isEmpty
		ifFalse: [releases reversed
				detect: [:r | r isCompatibleWithCurrentSystemVersion]
				ifNone: []]
]

{ #category : #accessing }
SMPackage >> maintainer [
	"Deprecated"

	^self owner
]

{ #category : #deprecated }
SMPackage >> modulePath: p moduleVersion: v moduleTag: t versionComment: vc [
	"Deprecated. Only kept for migration from SM 1.0x.
	Method used when recreating from storeOn: format."

	self isReleased ifTrue: [self lastRelease note: vc]
]

{ #category : #installation }
SMPackage >> nameWithVersionLabel [
	^name, ' (', self versionLabel, ')'
]

{ #category : #private }
SMPackage >> newChildReleaseFrom: aRelease [
	"Create a new release."

	^self addRelease: (map newObject: (SMPackageRelease newFromRelease: aRelease package: self))
]

{ #category : #private }
SMPackage >> newRelease [
	"Create a new release. Just use the last
	chronological release as parent, if this is the first release
	that is nil."

	^self newChildReleaseFrom: self lastRelease
]

{ #category : #accessing }
SMPackage >> note [
	^self isPublished ifTrue: [self lastPublishedRelease note]
]

{ #category : #accessing }
SMPackage >> packageInfoName [
	^packageInfoName
]

{ #category : #accessing }
SMPackage >> packageInfoName: aString [
	packageInfoName := aString
]

{ #category : #services }
SMPackage >> parentReleaseFor: aPackageRelease [
	"If there is none (the given release is automaticVersion '1'), return nil."

	| previousVersion |
	previousVersion := aPackageRelease automaticVersion previous.
	^releases detect: [:r | r automaticVersion = previousVersion] ifNone: [nil]
]

{ #category : #services }
SMPackage >> previousReleaseFor: aPackageRelease [
	"If there is none, return nil."
	
	^releases before: aPackageRelease ifAbsent: [nil]
]

{ #category : #accessing }
SMPackage >> publishedVersion [
	^self isPublished ifTrue: [self lastPublishedRelease version]
]

{ #category : #services }
SMPackage >> releaseWithAutomaticVersion: aVersion [
	"Look up a specific package release of mine. Return nil if missing.
	They are few so we just do a #select:."

	^releases detect: [:rel | rel automaticVersion = aVersion ] ifNone: [nil]
]

{ #category : #services }
SMPackage >> releaseWithAutomaticVersionString: aVersionString [
	"Look up a specific package release of mine. Return nil if missing.
	They are few so we just do a #select:."

	^self releaseWithAutomaticVersion: aVersionString asVersion
]

{ #category : #services }
SMPackage >> releaseWithId: anIdString [ 
	| anId |
	anId := UUID fromString: anIdString.
	^ releases
		detect: [ : each | each id = anId ]
		ifNone: [ nil ]
]

{ #category : #services }
SMPackage >> releaseWithVersion: aVersionString [
	"Look up a specific package release of mine. Return nil if missing.
	They are few so we just do a #select:."

	^releases detect: [:rel | rel version = aVersionString ] ifNone: [nil]
]

{ #category : #accessing }
SMPackage >> releases [
	^releases
]

{ #category : #private }
SMPackage >> removeRelease: aRelease [
	"Remove the release."

	releases remove: aRelease
]

{ #category : #accessing }
SMPackage >> repository [
	^repository
]

{ #category : #accessing }
SMPackage >> repository: aString [
	repository := aString
]

{ #category : #services }
SMPackage >> smartVersion [
	"Delegate to last release for this SystemVersion."
	| r |
	r := self lastReleaseForCurrentSystemVersion.
	^r ifNotNil: [r smartVersion] ifNil: ['']
]

{ #category : #printing }
SMPackage >> type [

	^'Package'
]

{ #category : #installation }
SMPackage >> upgrade [
	"Upgrade to the latest newer published version for this version of Squeak."

	| installed |
	installed := self installedRelease.
	installed
		ifNil: [self error: 'No release installed, can not upgrade.']
		ifNotNil: [^installed upgrade]
]

{ #category : #installation }
SMPackage >> upgradeOrInstall [
	"Upgrade to or install the latest newer published version for this version of Squeak."

	| installed |
	installed := self installedRelease.
	installed
		ifNil: [^self install]
		ifNotNil: [^installed upgrade]
]

{ #category : #installation }
SMPackage >> versionLabel [
	"Return a label indicating installed and available version as:
		'1.0'      = 1.0 is installed and no new published version for this version of Squeak is available
		'1.0->1.1' = 1.0 is installed and 1.1 is published for this version of Squeak
		'->1.1'    = No version is installed and 1.1 is published for this version of Squeak
		'->(1.1)	 = No version is installed and there is only a non published version available for this version of Squeak

	The version showed is the one that #smartVersion returns.
	If a version name is in parenthesis it is not published."

	| installedVersion r r2 |
	r := self installedRelease.
	r ifNotNil: [
		installedVersion := r smartVersion.
		r2 := self lastPublishedReleaseForCurrentSystemVersionNewerThan: r]
	ifNil: [
		installedVersion := ''.
		r2 := self lastPublishedReleaseForCurrentSystemVersion ].
	^r2 ifNil: [installedVersion ] ifNotNil: [installedVersion, '->', r2 smartVersion].
]

{ #category : #view }
SMPackage >> viewFor: uiObject [
	"This is a double dispatch mechanism for multiple views
	for multiple uis."

	^uiObject packageViewOn: self
]
