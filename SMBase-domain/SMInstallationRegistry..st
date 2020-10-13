"
A registry instance keeps track of installations into an image. Typically used by the SMSqueakMap instance when installing package releases.
"
Class {
	#name : #SMInstallationRegistry,
	#superclass : #Object,
	#instVars : [
		'installedPackages',
		'installCounter',
		'map'
	],
	#category : #'SMBase-domain'
}

{ #category : #'instance creation' }
SMInstallationRegistry class >> map: aMap [
	"Create a new registry and make it use the given map."

	^self new map: aMap
]

{ #category : #queries }
SMInstallationRegistry >> clearInstalledPackageWithId: aPackageId [
	"Clear the fact that any release of this package is installed.
	Can be used even when the map isn't loaded."

	^installedPackages ifNotNil: [
		installedPackages removeKey: (UUID fromString: aPackageId) ifAbsent: [nil]]
]

{ #category : #services }
SMInstallationRegistry >> clearInstalledPackages [
	"Simply clear the dictionary with information on installed packages.
	Might be good if things get corrupted etc. Also see
	SMSqueakMap class>>recreateInstalledPackagesFromChangeLog"

	installedPackages := nil.
	installCounter := 0
]

{ #category : #private }
SMInstallationRegistry >> countInstall [
	"Increase the install counter."

	installCounter ifNil: [installCounter := 0].
	^installCounter := installCounter + 1

]

{ #category : #accessing }
SMInstallationRegistry >> installCounter: anInteger [
	"Set counter directly."

	installCounter := anInteger
]

{ #category : #queries }
SMInstallationRegistry >> installedPackages [
	"Answer all packages that we know are installed.
	Lazily initialize. The Dictionary contains the installed packages
	using their UUIDs as keys and the version string as the value."

	| result |
	result := OrderedCollection new.
	installedPackages ifNil: [^#()]
		ifNotNil: [installedPackages keys
					do: [:k | | p |
						p := map object: k.
						p ifNotNil: [result add: p]]].
	^result
]

{ #category : #accessing }
SMInstallationRegistry >> installedPackagesDictionary [
	"Access the dictionary directly. The UUID of the installed package is the key.
	The value is an OrderedCollection of Arrays.
	The arrays have the smartVersion of the package, the time of the
	installation in seconds and the sequence number (installCounter)."

	^installedPackages ifNil: [Dictionary new]
]

{ #category : #accessing }
SMInstallationRegistry >> installedPackagesDictionary: aDict [
	"Set dictionary directly."

	installedPackages := aDict
]

{ #category : #queries }
SMInstallationRegistry >> installedReleaseOf: aPackage [
	"If the package is installed, return the release.
	Otherwise return nil. SM2 stores the version as
	an Association to be able to distinguish it."

	| autoVersionOrOld |
	installedPackages ifNil: [^nil].
	autoVersionOrOld := (installedPackages at: aPackage id ifAbsent: [^nil]) last first.
	(autoVersionOrOld isKindOf: Association)
		ifTrue: [
			^aPackage releaseWithAutomaticVersion: autoVersionOrOld value]
		ifFalse: [
			^aPackage releaseWithVersion: autoVersionOrOld]
]

{ #category : #queries }
SMInstallationRegistry >> installedVersionOf: aPackage [
	"If the package is installed, return the version as a String.
	If it is a package installed during SM1 it will return the manual version String,
	for SM2 it returns the automatic version as a String.
	If package is not installed - return nil. If you want it to work without the map loaded you
	should instead use #installedVersionOfPackageWithId:."

	| versionOrString |
	versionOrString := self installedVersionOfPackageWithId: aPackage id.
	versionOrString ifNil: [^nil].
	^versionOrString isString
		ifTrue: [versionOrString]
		ifFalse: [versionOrString versionString]
]

{ #category : #queries }
SMInstallationRegistry >> installedVersionOfPackageWithId: anId [
	"If the package is installed, return the automatic version or version String.
	Otherwise return nil. This can be used without the map loaded."

	| autoVersionOrOld |
	installedPackages ifNil: [^nil].
	autoVersionOrOld := (installedPackages at: anId ifAbsent: [^nil]) last first.
	(autoVersionOrOld isKindOf: Association)
		ifTrue: [
			^autoVersionOrOld value]
		ifFalse: [
			^autoVersionOrOld]
]

{ #category : #accessing }
SMInstallationRegistry >> map: aMap [

	map := aMap
]

{ #category : #private }
SMInstallationRegistry >> markInstalled: uuid version: version time: time counter: num [
	"Private. Mark the installation. SM2 uses an Association
	to distinguish the automatic version from old versions."


	| installs |
	installedPackages ifNil: [installedPackages := Dictionary new].
	installs := installedPackages at: uuid ifAbsentPut: [OrderedCollection new].
	installs add:
		(Array with: 2->version
				with: time
				with: num)
]

{ #category : #'installation-changelog' }
SMInstallationRegistry >> noteInstalledPackage: uuidString version: version [
	"Mark a specific version of a package as installed.
	This method is called when replaying a logged installation
	from before SqueakMap 1.07. Such logged installations lacked
	a timestamp and a count. We take the current time and a
	count starting from -10000 and upwards. This should keep
	the sorting order correct."

	"Find the lowest installed count."
	| lowest |
	lowest := 0.
	installedPackages ifNotNil: [
		installedPackages valuesDo: [:oc |
			oc do: [:array |
				array last < lowest ifTrue: [lowest := array last]]]]
		ifNil: [lowest := -10000].
	lowest negative ifFalse: [lowest := -10000].
	^self noteInstalledPackage: uuidString version: version
		atSeconds: Time totalSeconds number: lowest + 1
]

{ #category : #'installation-changelog' }
SMInstallationRegistry >> noteInstalledPackage: uuidString version: version atSeconds: time number: num [
	"Mark a package as installed in the Dictionary.
	This method is called when replaying a logged installation.
	<time> is the point in time as totalSeconds of the installation.
	<num> is the installCount of the installation.
	This method is typically called from a doIt in the changelog
	in order to try to keep track of packages installed."

	num negative ifFalse: ["Not an emulated count from prior SM1.07"
		installCounter := num max: installCounter].
	self markInstalled: (UUID fromString: uuidString) version: version time: time counter: num
]

{ #category : #'installation-changelog' }
SMInstallationRegistry >> noteInstalledPackageWithId: uuidString autoVersion: version atSeconds: time number: num [
	"Mark a package as installed in the Dictionary.
	This method is called when replaying a logged installation.
	<time> is the point in time as totalSeconds of the installation.
	<num> is the installCount of the installation.
	This method is typically called from a doIt in the changelog
	in order to try to keep track of packages installed."

	num negative ifFalse: ["Not an emulated count from prior SM1.07"
		installCounter := num max: installCounter].
	self markInstalled: (UUID fromString: uuidString) version: version time: time counter: num
]

{ #category : #installation }
SMInstallationRegistry >> noteInstalledPackageWithId: aPackageId autoVersion: aVersion name: aName [
	"The package release was just successfully installed.
	Can be used to inform SM of an installation not been
	done using SM, even when the map isn't loaded.

	We record the fact in our Dictionary of installed packages
	and log a 'do it' to mark this in the changelog.
	The doit helps keeping track of the packages when
	recovering changes etc - not a perfect solution but should help.
	The map used is the default map.
	The id of the package is the key and the value is an OrderedCollection
	of Arrays with the release auto version, the point in time and the current installCounter."

	| time name id v |
	v := aVersion isString ifTrue: [aVersion asVersion] ifFalse: [aVersion].
	aName ifNil: [name := '<unknown package name>'] ifNotNil: [name := aName].
	id := UUID fromString: aPackageId.
	time := Time totalSeconds.
	self countInstall.
	self markInstalled: id version: v time: time counter: installCounter.
	(((Smalltalk classNamed: 'SmalltalkImage') ifNotNil: [:si | si current]) ifNil: [Smalltalk])
		logChange: '"Installed ', name, ' auto version ', v versionString, '".
(Smalltalk at: #SMSqueakMap ifAbsent: []) ifNotNil:[
	SMSqueakMap noteInstalledPackageWithId: ', id asString storeString, ' autoVersion: ', v storeString, ' atSeconds: ', time asString, ' number: ', installCounter asString, ']'
]

{ #category : #installation }
SMInstallationRegistry >> noteUninstalledPackageWithId: aPackageId autoVersion: aVersion name: aName [
	"The package release was just successfully uninstalled.
	Can be used to inform SM of an uninstallation not been
	done using SM, even when the map isn't loaded.

	We record the fact in our Dictionary of installed packages
	and log a 'do it' to mark this in the changelog.
	The doit helps keeping track of the packages when
	recovering changes etc - not a perfect solution but should help.
	The map used is the default map.
	The id of the package is the key and the value is an OrderedCollection
	of Arrays with the release auto version, the point in time and the current installCounter."

	| time name id v |
	v := aVersion isString ifTrue: [aVersion asVersion] ifFalse: [aVersion].
	aName ifNil: [name := '<unknown package name>'] ifNotNil: [name := aName].
	id := UUID fromString: aPackageId.
	time := Time totalSeconds.
	self countInstall. "Used for both installs and uninstalls"
	self clearInstalled: id version: v time: time counter: installCounter.
	(((Smalltalk classNamed: 'SmalltalkImage') ifNotNil: [:si | si current]) ifNil: [Smalltalk])
		logChange: '"Uninstalled ', name, ' auto version ', v versionString, '".
(Smalltalk at: #SMSqueakMap ifAbsent: []) ifNotNil:[
	SMSqueakMap noteUninstalledPackageWithId: ', id asString storeString, ' autoVersion: ', v storeString, ' atSeconds: ', time asString, ' number: ', installCounter asString, ']'
]
