"
SqueakMap is a Squeak meta catalog, primarily a catalog of all available Squeak packages.
SMSqueakMap is the class for the domain model.

One master instance lives on a server on the Internet at map1.squeakfoundation.org (but there are fallback servers too). Then each Squeak connected to the Internet has one instance that is synchronized against the master. This way every user can have an updated catalog of all available Squeak software on the planet locally on their machine. :-)

Typically you only need one instance of SMSqueakMap per image and it is held by a singleton class variable reached with ""SMSqueakMap default"". If it is not there it will then be created together with it's own directory on disk by default the ""sm"" directory created in your default directory.

Synching with the master is the only action that affects the map so you can actually use the same map from multiple images (they will by default use the same snapshot files if the images have the same default directory) and multiple tools (SMLoader, SMBrowser or others).

An instance of SMSqueakMap contains instances of SMPackage which which represent Squeak packages and SMCategories which are centrally registered values that can be included as attributes in an SMPackage. An example of such a category would be different kinds of licenses, topic etc. etc.

It also contains instances of SMAccount which are registered Squeak developers, the maintainers of the packages.

Finally SMSqueakMap also refers to a registry object (SMInstallationRegistry) which records what packages and releases of them have been installed in the image
--------------------
""Simplest use of SMSqueakMap - this will create a map if you don't have one and open a simple UI""""
SMLoader open

Use these doits to play ""hands on"" with a SqueakMap.

""Creating another SqueakMap in directory 'slavemap' instead of default 'sm'""
Smalltalk at: #AnotherSqueakMap put: (SMSqueakMap newIn: 'slavemap')

""Update the default map by synching it with the master - check Transcript for some numbers.""
SMSqueakMap default loadUpdates

""If the map is broken in some way, reload it from disk""
SMSqueakMap default reload

""Clear out the contents of the map to save image space, this does not remove the registry.""
SMSqueakMap default purge

"
Class {
	#name : #SMSqueakMap,
	#superclass : #Object,
	#instVars : [
		'packages',
		'accounts',
		'objects',
		'categories',
		'dir',
		'adminPassword',
		'fileCache',
		'users',
		'mutex',
		'isDirty',
		'checkpointNumber',
		'silent',
		'registry'
	],
	#classVars : [
		'DefaultMap',
		'ServerList'
	],
	#category : #'SMBase-domain'
}

{ #category : #'changelog replay' }
SMSqueakMap class >> askUser [
	"Ask user about how to handle a replayed installation note
	when there is no current SqueakMap in the image."

	| choice |
	[choice := UIManager default chooseFrom: #('Yes' 'No' 'More info')
				title:
'There is no SqueakMap in this image,
do you wish to create/recreate it? (typical answer is Yes)' .
			choice = 3] whileTrue: [self inform:
'When packages are installed using SqueakMap a little mark is made
in the change log. When an image is reconstructed from the changelog
these marks are intended to keep your map informed about what packages
are installed. You probably already have a map on disk which will automatically be
reloaded if you choose ''Yes'', otherwise an new empty map will be created.
If you choose ''No'', it will only result in that SqueakMap will not know that this package
is installed in your image.
If you are still unsure - answer ''Yes'' since that is probably the best.'].
	^choice = 1
]

{ #category : #'bootstrap upgrade' }
SMSqueakMap class >> bootStrap [
	"Bootstrap upgrade. Only used when SqueakMap itself is too old to
	communicate with the server. This relies on the existence of a package
	called SqueakMap that is a .st loadscript. The loadscript needs to do its
	own changeset management."

	| server url |
	server := self findServer.
	server ifNotNil: ["Ok, found a SqueakMap server"
		url := (('http://', server, '/packagebyname/squeakmap/downloadurl')
				asUrl retrieveContents content) asUrl.
		(url retrieveContents content unzipped readStream)
				fileInAnnouncing: 'Upgrading SqueakMap...']
]

{ #category : #'class initialization' }
SMSqueakMap class >> cleanUp: aggressive [
	"Nuke the default map when performing aggressive cleanup"

	aggressive ifTrue:[self clear].

]

{ #category : #'instance creation' }
SMSqueakMap class >> clear [
	"Clear out the model in the image. This will forget
	about what packages are installed and what versions.
	The map is itself on disk though and will be reloaded.
	
	If you only want to reload the map and not forget about
	installed packages then use 'SMSqueakMap default reload'.

	If you want to throw out the map perhaps when shrinking
	an image, then use 'SMSqueakMap default purge'."

	"SMSqueakMap clear"

	DefaultMap := nil
]

{ #category : #'instance creation' }
SMSqueakMap class >> default [
	"Return the default map, create one if missing."

	"SMSqueakMap default"

	^DefaultMap ifNil: [DefaultMap := self new]
]

{ #category : #'instance creation' }
SMSqueakMap class >> defaultNoCreate [
	"Return the default map or nil if there is none."

	"SMSqueakMap defaultNoCreate"

	^DefaultMap
]

{ #category : #discarding }
SMSqueakMap class >> discardSM [
	"Discard SqueakMapBase. All the map state is kept in
	the class var DefaultMap in SMSqueakMap and is thus also removed."

	"SMSqueakMap discardSM"

	SystemOrganization removeCategoriesMatching: 'SM-domain'.
]

{ #category : #'server detection' }
SMSqueakMap class >> findServer [
	"Go through the list of known master servers, ping 
	each one using simple http get on a known 'ping'-url 
	until one responds return the server name. 
	If some servers are bypassed we write that to Transcript. 
	If all servers are down we inform the user and return nil."

	| notAnswering deafServers |
	Socket initializeNetwork.
	notAnswering := OrderedCollection new.
	Cursor wait
		showWhile: [ServerList
				do: [:server | (self pingServer: server)
						ifTrue: [notAnswering isEmpty
								ifFalse: [deafServers := String
												streamContents: [:str | notAnswering
														do: [:srvr | str nextPutAll: srvr printString;
																 nextPut: Character cr]].
									Transcript show: ('These SqueakMap master servers did not respond:\' , deafServers , 'Falling back on ' , server printString , '.') withCRs].
							^ server]
						ifFalse: [notAnswering add: server]]].
	deafServers := String
				streamContents: [:str | notAnswering
						do: [:srvr | str nextPutAll: srvr printString;
								 nextPut: Character cr]].
	self error: ('All SqueakMap master servers are down:\' , deafServers , '\ \Can not update SqueakMap...') withCRs.
	^ nil
]

{ #category : #'class initialization' }
SMSqueakMap class >> initialize [
	"Initialize the list of master servers.
	The last one is for debugging/development."

	"self initialize"

	ServerList := #('map.squeak.org' 'map1.squeakfoundation.org' 'map2.squeakfoundation.org' '127.0.0.1:8080')
]

{ #category : #'instance creation' }
SMSqueakMap class >> new [
	"Create a new server in a new directory
	under the default directory called 'sm'."

	^super new initializeOn: 'sm'
]

{ #category : #'instance creation' }
SMSqueakMap class >> newIn: directoryName [
	"Create a new server in a new directory
	under the default directory called <directoryName>."

	^super new initializeOn: directoryName
]

{ #category : #'changelog replay' }
SMSqueakMap class >> noteInstalledPackage: uuidString version: version [
	"We are replaying a change that indicates that a package
	was just installed. If there is a map we let it record this,
	otherwise we ask the user if we should create/recreate the map."

	| choice |
	DefaultMap
		ifNotNil: [DefaultMap noteInstalledPackage: uuidString version: version]
		ifNil: [
			[choice := UIManager default chooseFrom: #('Yes' 'No' 'More info')
				title:
'There is no SqueakMap in this image,
do you wish to create/recreate it? (typical answer is Yes)' .
			choice = 3] whileTrue: [self inform:
'When packages are installed using SqueakMap a little mark is made
in the change log. When an image is reconstructed from the changelog
these marks are intended to keep your map informed about what packages
are installed. You probably already have a map on disk which will automatically be
reloaded if you choose ''Yes'', otherwise an new empty map will be created.
If you choose ''No'', it will only result in that SqueakMap will not know that this package
is installed in your image.
If you are still unsure - answer ''Yes'' since that is probably the best.'].
			choice = 1
				ifTrue:[self default noteInstalledPackage: uuidString version: version]]
]

{ #category : #'changelog replay' }
SMSqueakMap class >> noteInstalledPackage: uuidString version: version atSeconds: sec number: num [
	"We are replaying a change that indicates that a package
	was just installed. If there is a map we let it record this,
	otherwise we ask the user if we should create/recreate the map."

	DefaultMap
		ifNotNil: [DefaultMap noteInstalledPackage: uuidString version: version
					atSeconds: sec number: num]
		ifNil: [
			self askUser
				ifTrue:[self default noteInstalledPackage: uuidString version: version
							atSeconds: sec number: num]]
]

{ #category : #'changelog replay' }
SMSqueakMap class >> noteInstalledPackageWithId: uuidString autoVersion: version atSeconds: sec number: num [
	"We are replaying a change that indicates that a package release
	was just installed using SM2. If there is a map we let it record this,
	otherwise we ask the user if we should create/recreate the map."

	DefaultMap
		ifNotNil: [DefaultMap noteInstalledPackageWithId: uuidString autoVersion: version
					atSeconds: sec number: num]
		ifNil: [
			self askUser
				ifTrue:[self default noteInstalledPackageWithId: uuidString autoVersion: version
							atSeconds: sec number: num]]
]

{ #category : #'changelog replay' }
SMSqueakMap class >> noteInstalledPackageWithId: uuidString version: version atSeconds: sec number: num [
	"We are replaying a change that indicates that a package release
	was just installed using SM2. If there is a map we let it record this,
	otherwise we ask the user if we should create/recreate the map."

	DefaultMap
		ifNotNil: [DefaultMap noteInstalledPackageWithId: uuidString version: version
					atSeconds: sec number: num]
		ifNil: [
			self askUser
				ifTrue:[self default noteInstalledPackageWithId: uuidString version: version
							atSeconds: sec number: num]]
]

{ #category : #'server detection' }
SMSqueakMap class >> pingServer: aServerName [
	"Check if the SqueakMap server is responding.
	For an old image we first make sure the name resolves -
	the #httpGet: had such a long timeout (and hanging?)
	for resolving the name."

	"Only test name lookup first if image is before the network rewrite,
	after the rewrite it works."
	^[ | answer url |
	(SystemVersion current highestUpdate < 5252)
		ifTrue: [NetNameResolver addressForName: (aServerName upTo: $:) timeout: 5].
	url := 'http://', aServerName, '/ping'.
	answer := HTTPSocket httpGet: url.
	answer isString not and: [answer contents = 'pong']]
		on: Error do: [ false ].
	
]

{ #category : #migration }
SMSqueakMap class >> recreateInstalledPackagesFromChangeLog [
	"Clear and recreate the Dictionary with information on installed packages.

	NOTE: This takes some time to run and will only find packages installed using SM
	and since the last changelog condense.

	For packages installed prior to SqueakMap 1.07 there is no timestamp nor counter
	logged. These packages will be given the time of the replay and a separate count
	(from -10000 upwards) maintaining correct order of installation."

	"SMSqueakMap recreateInstalledPackagesFromChangeLog"

	| changesFile chunk |
	SMSqueakMap default clearInstalledPackages.
	changesFile := (SourceFiles at: 2) readOnlyCopy.
	[changesFile atEnd]
		whileFalse: [
			chunk := changesFile nextChunk.
			((chunk beginsWith: '"Installed') and: [
				(chunk indexOfSubCollection: 'SMSqueakMap noteInstalledPackage:'
					startingAt: 10) > 0])
				ifTrue: [Compiler evaluate: chunk]].
	changesFile close
]

{ #category : #constants }
SMSqueakMap class >> version [
	"This is the protocol version number used for clients to decide if
	they need to update SMSqueakMap before synching with
	the master. In short - only increase this if changes have made
	the clients incompatible so that they need to be updated.

	2.0: Removed Module stuff and added Package releases.
	2.1: Various changes/additions and class shape changes.
	2.2: Various 3.9 related fixes and bug fix in segment compression etc.
	2.3: Moving to SmartRefStream when preparing to release Squeak 4.1."

	^'2.3'
]

{ #category : #queries }
SMSqueakMap >> accountForEmail: email [
	"Find account given email."

	^self accounts detect: [:a | a email = email] ifNone: [nil]
]

{ #category : #queries }
SMSqueakMap >> accountForName: name [
	"Find account given full name. Disregarding case
	and allows up to 2 different characters.
	Size must match though, someone else can be smarter -
	this is just for migrating accounts properly."

	| lowerName size |
	lowerName := name asLowercase.
	size := lowerName size.
	^self accounts
		detect: [:a |
			| aName |
			aName := a name asLowercase.
			(aName size = size) and: [| errors |
				errors := 0.
				aName with: lowerName do: [:c1 :c2 |
					c1 ~= c2 ifTrue: [errors := errors + 1]].
				errors < 3
			]]
		ifNone: [nil]
		
]

{ #category : #queries }
SMSqueakMap >> accountForUsername: username [
	"Find account given username. The username used
	is the developer initials of the account."

	^self users at: username ifAbsent: [nil]
]

{ #category : #queries }
SMSqueakMap >> accountWithId: anIdString [ 
	"Look up an account. Return nil if missing.
	Raise error if it is not an account."

	| account |
	account := self objectWithId: anIdString.
	account ifNil: [^nil].
	account isAccount ifTrue:[^account].
	self error: 'UUID did not map to a account.'
]

{ #category : #queries }
SMSqueakMap >> accountWithName: aName [
	"Look up an account by name. Return nil if missing."

	^self accounts detect: [:a | a name = aName ] ifNone: [nil]
]

{ #category : #accessing }
SMSqueakMap >> accounts [
	"Lazily maintain a cache of all known account objects."

	accounts ifNotNil: [^accounts].
	accounts := objects select: [:o | o isAccount].
	^accounts
]

{ #category : #queries }
SMSqueakMap >> accountsByInitials [
	"Return the accounts sorted by the developer initials."

	^self accounts sorted: [:x :y | x initials caseInsensitiveLessOrEqual: y initials]
]

{ #category : #queries }
SMSqueakMap >> accountsByName [
	"Return the accounts sorted by their name."

	^self accounts sorted: [:x :y | x name caseInsensitiveLessOrEqual: y name].
]

{ #category : #'public-master' }
SMSqueakMap >> addCategory: category inObject: object [
	"Add a category in an object."

	^object addCategory: category

]

{ #category : #transactions }
SMSqueakMap >> addDirty: anSMObject [
	"Add the SMObject to the dirty list making
	sure it gets committed when transaction ends."

"In first SM2 version we do nothing"

"	dirtyList add: anSMObject"
]

{ #category : #'public-master' }
SMSqueakMap >> addObject: anSMObject [ 
	"Add a new object, only if not already added."

	(self object: anSMObject id) ifNil: [
		self transaction: [self newObject: anSMObject]]
]

{ #category : #accessing }
SMSqueakMap >> adminPassword: aString [
	"We store the password as a SHA hash so that we can let the slave maps
	have it too."

	adminPassword := SecureHashAlgorithm new hashMessage: aString
]

{ #category : #'public-packages' }
SMSqueakMap >> allPackages [
	"Answer all packages."

	^self packages
]

{ #category : #'public-packages' }
SMSqueakMap >> availablePackages [
	"Answer all packages that are old or not installed."

	^self packages select: [:package | package isAvailable]
]

{ #category : #accessing }
SMSqueakMap >> cache [
	^ fileCache
]

{ #category : #accessing }
SMSqueakMap >> categories [
	"Lazily maintain a cache of all known category objects."

	categories ifNotNil: [^categories].
	objects isNil ifTrue: [ ^ #() ].
	categories := objects select: [:o | o isCategory].
	^categories
]

{ #category : #queries }
SMSqueakMap >> categoryWithId: anIdString [ 
	"Look up a category. Return nil if missing.
	Raise error if it is not a category."

	| cat |
	cat := self objectWithId: anIdString.
	cat ifNil: [^nil].
	cat isCategory ifTrue:[^cat].
	self error: 'UUID did not map to a category.'
]

{ #category : #queries }
SMSqueakMap >> categoryWithNameBeginning: aString [
	"Look up a category beginning with <aString>. Return nil if missing.
	We return the shortest matching one. We also strip out spaces and
	ignore case in both <aString> and the names."

	| candidates shortest answer searchString |
	searchString := (aString asLowercase) copyWithout: Character space.
	candidates := self categories select: [:cat |
		((cat name asLowercase) copyWithout: Character space)
			beginsWith: searchString ].
	shortest := 1000.
	candidates do: [:ca |
		ca name size < shortest ifTrue:[answer := ca. shortest := ca name size]].
	^answer	
]

{ #category : #'public-master' }
SMSqueakMap >> changeCategoriesTo: newCategories inObject: object [
	"Remove or add categories in an object such that
	it belongs to the categories in <newCategories>.
	Logs the changes."

	newCategories do: [:cat |
		(object hasCategory: cat)
			ifFalse:[self addCategory: cat inObject: object]].
	object categories do: [:cat |
		(newCategories includes: cat)
			ifFalse: [self removeCategory: cat inObject: object]]

]

{ #category : #queries }
SMSqueakMap >> check [
	"Sanity checks."

	"SMSqueakMap default check"
	
	(((self packages inject: 0 into: [:sum :p | sum + p releases size]) +
	self accounts size +
	self packages size +
	self categories size) = SMSqueakMap default objects size)
		ifFalse: [self error: 'Count inconsistency in map'].
	
	objects do: [:o |
		o map == self
			ifFalse: [self error: 'Object with wrong map']].
	self packages do: [:p |
		(p releases allSatisfy: [:r | r map == self])
			ifFalse: [self error: 'Package with release pointing to wrong map']].
		
	self packageReleases do: [:r |
		r package map == self ifFalse: [self error: 'Release pointing to package in wrong map']]
]

{ #category : #private }
SMSqueakMap >> checkVersion: string [
	"Check the content for a SqueakMap version conflict notification.
	Return true if no conflict is reported, otherwise ask user if we
	should upgrade SqueakMap using the bootstrap method."

	(string beginsWith: 'Server version:')
		ifTrue:[(self confirm: ('The SqueakMap master server is running another version (', (string last: (string size - 15)), ') than the client (', SMSqueakMap version, ').
You need to upgrade the SqueakMap package, would you like to do that now?'))
			ifTrue: [self class bootStrap. ^false]
			ifFalse: [^false]
	].
	^true
]

{ #category : #accessing }
SMSqueakMap >> checkpointNumber [

	^checkpointNumber
]

{ #category : #private }
SMSqueakMap >> clearCaches [
	"Clear the caches."

	packages := accounts := users := categories := nil

]

{ #category : #private }
SMSqueakMap >> clearCachesFor: anObject [ 
	"Clear the valid caches."

	anObject isPackage ifTrue:[packages := nil].
	anObject isAccount ifTrue:[accounts := users := nil].
	anObject isCategory ifTrue:[categories := nil]

]

{ #category : #'public-installation' }
SMSqueakMap >> clearInstalledPackageWithId: aPackageId [
	"Clear the fact that any release of this package is installed.
	Can be used even when the map isn't loaded."

	^self registry clearInstalledPackageWithId: aPackageId
]

{ #category : #'public-installation' }
SMSqueakMap >> clearInstalledPackages [
	"Simply clear the dictionary with information on installed packages.
	Might be good if things get corrupted etc. Also see
	SMSqueakMap class>>recreateInstalledPackagesFromChangeLog"

	^self registry clearInstalledPackages
]

{ #category : #private }
SMSqueakMap >> clearUsernames [
	"Clear the username cache."

	users := nil
]

{ #category : #checkpoints }
SMSqueakMap >> compressFile: aFileStream [
	"Shamelessly copied and modified from StandardFileStream>>compressFile."
	
	| zipped buffer |
	aFileStream binary.
	zipped := StandardFileStream newFileNamed: (self directory fullNameFor: (aFileStream name, 'gz')).
	zipped binary; setFileTypeToObject.
	"Type and Creator not to be text, so can be enclosed in an email"
	zipped := GZipWriteStream on: zipped.
	buffer := ByteArray new: 50000.
	[[aFileStream atEnd] whileFalse: [
		zipped nextPutAll: (aFileStream nextInto: buffer)]]
		ensure: [zipped close. aFileStream close].
	self directory deleteFileNamed: aFileStream name
]

{ #category : #private }
SMSqueakMap >> copyFrom: aMap [
	"Copy all relevant info from the other map."

	objects := aMap objects.
	objects do: [:o | o map: self].
	objects rehash.
	accounts := users := packages := categories := nil.
	checkpointNumber := aMap checkpointNumber
]

{ #category : #checkpoints }
SMSqueakMap >> createCheckpoint [
	"Export a new checkpoint of me using an ImageSegment."

	^self createCheckpointNumber: 
		(self nextFileNameForCheckPoint findTokens: '.') second asNumber.

]

{ #category : #checkpoints }
SMSqueakMap >> createCheckpointNumber: number [
	"Export me using an ImageSegment or SmartRefStream.
	This is used for checkpointing the map on disk
	in a form that can be brought into an independent image.
	We do not overwrite older versions."

	| fname stream oldMutex |
	fname := self filename, '.', number asString, '.r'.
	(self directory fileExists: fname, 'gz') ifTrue: [self error: 'Checkpoint already exists!'].
	stream := StandardFileStream newFileNamed: (self directory fullNameFor: fname).
	checkpointNumber := number.
	oldMutex := mutex.
	mutex := nil. self clearCaches.
	[| smartStream |
	[smartStream := SmartRefStream on: stream.
	smartStream nextPut: self] ensure: [smartStream close].
	self compressFile: (StandardFileStream oldFileNamed: (self directory fullNameFor: fname)).
	isDirty := false]
		ensure: [mutex := oldMutex]
]

{ #category : #private }
SMSqueakMap >> deleteObject: anObject [ 
	"Delete an object, remove it from objects.
	This method is called from the #delete method of
	anObject so it will take care of the rest of the
	cleaning up. Clear the valid caches."

	objects removeKey: anObject id.
	self clearCachesFor: anObject

]

{ #category : #accessing }
SMSqueakMap >> directory [
	"Return the subdirectory that SqueakMap uses."
	
	(FileDirectory default directoryExists: dir)
		ifFalse:[FileDirectory default createDirectory: dir].
	^FileDirectory default directoryNamed: dir
]

{ #category : #private }
SMSqueakMap >> emailOccupied: aUsername [
	"Return true if email already taken."

	^(self accountForEmail: aUsername) notNil
]

{ #category : #checkpoints }
SMSqueakMap >> extension [
	^'rgz'
]

{ #category : #checkpoints }
SMSqueakMap >> filename [
	^'map'
]

{ #category : #checkpoints }
SMSqueakMap >> getLastCheckpointWithFilename [
	"Return a readstream on a fresh checkpoint gzipped imagesegment.
	First we check if we are dirty and must create a new checkpoint.
	The filename is tacked on at the end so that the checkpoint number
	can be used on the client side too."

	| directory fname |
	isDirty ifTrue: [self createCheckpoint].
	directory := self directory.
	fname := self lastCheckpointFilename.
	fname ifNil: [self error: 'No checkpoint available'].
	^((StandardFileStream oldFileNamed: (directory fullNameFor: fname))
		contentsOfEntireFile), ':', fname
]

{ #category : #'initialize-release' }
SMSqueakMap >> initializeOn: directoryName [
	"Create the local directory for SqueakMap."

	dir := directoryName.
	(FileDirectory default directoryExists: dir)
		ifFalse:[FileDirectory default createDirectory: dir].
	fileCache := SMFileCache newFor: self.
	checkpointNumber := 1
]

{ #category : #'public-installation' }
SMSqueakMap >> installPackage: aPackage [
	"Install the package.

	Note: This method should not be used anymore, better
	to specify a specific release."

	| rel |
	rel := aPackage lastPublishedReleaseForCurrentSystemVersion
			ifNil: [self error: 'No published release for this system version found to install.'].
	^self installPackageRelease: rel
]

{ #category : #'public-installation' }
SMSqueakMap >> installPackage: aPackage autoVersion: version [
	"Install the release <version> of <aPackage.
	<version> is the automatic version name."

	| r |
	r := aPackage releaseWithAutomaticVersionString: version.
	r ifNil: [self error: 'No package release found with automatic version ', version].
	^self installPackageRelease: r
]

{ #category : #'public-installation' }
SMSqueakMap >> installPackageNamed: aString [
	"Install the last published release
	for this Squeak version of the package with a name
	beginning with aString (see method comment
	of #packageWithNameBeginning:).

	Note: This method should not be used anymore.
	Better to specify a specific release."

	| p |
	p := self packageWithNameBeginning: aString.
	p ifNil: [self error: 'No package found with name beginning with ', aString].
	^self installPackage: p
]

{ #category : #'public-installation' }
SMSqueakMap >> installPackageNamed: aString autoVersion: version [
	"Install the release <version> of the package with a name
	beginning with aString (see method comment
	of #packageWithNameBeginning:). <version> is the
	automatic version name."

	| p r |
	p := self packageWithNameBeginning: aString.
	p ifNil: [self error: 'No package found with name beginning with ', aString].
	r := p releaseWithAutomaticVersionString: version.
	r ifNil: [self error: 'No package release found with automatic version ', version].
	^self installPackageRelease: r
]

{ #category : #'public-installation' }
SMSqueakMap >> installPackageNamed: aString version: version [
	"Install the release <version> of the package with a name
	beginning with aString (see method comment
	of #packageWithNameBeginning:). <version> is the
	user-specified version name."
	| package release |
	package := self packageWithNameBeginning: aString.
	package ifNil: [self error: 'No package found with name beginning with ', aString].
	release := package releaseWithVersion: version.
	release ifNil: [self error: 'No package release found with version ', version].
	^self installPackageRelease: release
]

{ #category : #'public-installation' }
SMSqueakMap >> installPackageRelease: aPackageRelease [
	"Install the given package release, no checks made."

	(SMInstaller forPackageRelease: aPackageRelease) install
]

{ #category : #'public-installation' }
SMSqueakMap >> installPackageReleaseWithId: anUUIDString [
	"Look up and install the given release."

	| r |
	r := self packageReleaseWithId: anUUIDString.
	r ifNil: [self error: 'No package release available with id: ''', anUUIDString, ''''].
	^self installPackageRelease: r
]

{ #category : #'public-installation' }
SMSqueakMap >> installPackageWithId: anUUIDString [
	"Look up and install the latest release of the given package.	

	Note: This method should not be used anymore.
	Better to specify a specific release."

	| package |
	package := self packageWithId: anUUIDString.
	package ifNil: [self error: 'No package available with id: ''', anUUIDString, ''''].
	^self installPackage: package
]

{ #category : #'public-installation' }
SMSqueakMap >> installPackageWithId: anUUIDString autoVersion: version [
	"Install the release <version> of the package with id <anUUIDString>.
	<version> is the automatic version name."

	| p |
	p := self packageWithId: anUUIDString.
	p ifNil: [self error: 'No package available with id: ''', anUUIDString, ''''].
	^self installPackage: p autoVersion: version
]

{ #category : #'public-packages' }
SMSqueakMap >> installableAndNotInstalledPackages [
	"Answer all installable but not installed packages."

	^self packages select: [:package | package isInstallableAndNotInstalled]
]

{ #category : #'public-packages' }
SMSqueakMap >> installablePackages [
	"Answer all packages that can be (auto)installed -
	we have installers that can install them."

	^self packages select: [:package | package isInstallable]
]

{ #category : #'public-installation' }
SMSqueakMap >> installedPackageReleases [
	"Answer all package releases that we know are installed.
	Lazily initialize. The Dictionary contains the installed packages
	using their UUIDs as keys and the version string as the value."

	^self installedPackages collect: [:p | self installedReleaseOf: p]
]

{ #category : #'public-installation' }
SMSqueakMap >> installedPackages [
	"Answer all packages that we know are installed."

	^self registry installedPackages
]

{ #category : #'public-installation' }
SMSqueakMap >> installedPackagesDictionary [
	"Access the dictionary directly. The UUID of the installed package is the key.
	The value is an OrderedCollection of Arrays.
	The arrays have the smartVersion of the package, the time of the
	installation in seconds and the sequence number (installCounter)."

	^self registry installedPackagesDictionary
]

{ #category : #'public-installation' }
SMSqueakMap >> installedPackagesDictionary: aDict [
	"Set dictionary directly."

	^self registry installedPackagesDictionary: aDict
]

{ #category : #'public-installation' }
SMSqueakMap >> installedReleaseOf: aPackage [
	"If the package is installed, return the release.
	Otherwise return nil. SM2 stores the version as
	an Association to be able to distinguish it."

	^self registry installedReleaseOf: aPackage
]

{ #category : #'public-installation' }
SMSqueakMap >> installedVersionOf: aPackage [
	"If the package is installed, return the version as a String.
	If it is a package installed during SM1 it will return the manual version String,
	for SM2 it returns the automatic version as a String.
	If package is not installed - return nil. If you want it to work without the map loaded you
	should instead use #installedVersionOfPackageWithId:."

	^self registry installedVersionOf: aPackage
]

{ #category : #'public-installation' }
SMSqueakMap >> installedVersionOfPackageWithId: anId [
	"If the package is installed, return the automatic version or version String.
	Otherwise return nil. This can be used without the map loaded."

	^self registry installedVersionOfPackageWithId: anId
]

{ #category : #checkpoints }
SMSqueakMap >> isCheckpointAvailable [
	"Check that there is an 'sm' directory
	and that it contains at least one checkpoint."

	[^self lastCheckpointFilename notNil] on: Error do: [:ex | ^false]
]

{ #category : #transactions }
SMSqueakMap >> isDirty [
	"Is the map modified but not yet checkpointed to disk?"

	^isDirty
]

{ #category : #public }
SMSqueakMap >> isPurged [
	"Is this instance purged (empty)?

	ar 4/13/2010: Added the test for object isNil as a workaround for 4.1.
	Without the test 'SMSqueakMap new syncWithDisk' creates an invalid
	checkpoint file and fails forever after."

	^checkpointNumber isZero or:[objects isNil]
]

{ #category : #checkpoints }
SMSqueakMap >> lastCheckpointFilename [
	"Return the filename for the newest checkpoint."

	^self directory lastNameFor: self filename extension: self extension
]

{ #category : #checkpoints }
SMSqueakMap >> lastCheckpointNumberOnDisk [
	"Return the last checkpoint number on disk."

	^(self nextFileNameForCheckPoint findTokens: '.') second asNumber - 1
]

{ #category : #public }
SMSqueakMap >> loadFull [
	"Go through the list of known master servers, ping
	each one using simple http get on a known 'ping'-url
	until one responds and then load the full map from it."
 
	self loadUpdatesFull: true
]

{ #category : #private }
SMSqueakMap >> loadFullFrom: aServerName [ 
	"Contact the SqueakMap at aServerName, building the the url for this version and load a full map from scratch.
	Allow several retries in case of net slowness etc."
	| url zipped attempts mapContents |
	url := 'http://' , aServerName , '/loadgz?mapversion=' , SMSqueakMap version , '&checkpoint=' , checkpointNumber asString.
	attempts := 0.

	[attempts := attempts + 1.
	zipped := HTTPSocket httpGet: url.
	zipped isString
		ifTrue: ["awful legacy way to detect net error - use a proper technique
			when the httpsocket can be replaced with a webclient. For now, raise a generic exception"
			NetworkError signal]]
		on: NetworkError
		do: [:ex | 
			attempts >= 3
				ifTrue: [self halt: 'Unable to load SqueakMap map update after ' , attempts asString , ' attempts'].
			ex retry].
		
	mapContents := zipped contents.
	((self checkVersion: mapContents)
			and: [mapContents ~= 'UPTODATE'])
		ifTrue: [self saveCheckpoint: mapContents.
			self reload]
]

{ #category : #public }
SMSqueakMap >> loadUpdates [
	"Go through the list of known master servers, ping
	each one using simple http get on a known 'ping'-url
	until one responds and then load updates from it."

	"SM2 starts with using full always"

	self loadFull
]

{ #category : #private }
SMSqueakMap >> loadUpdatesFull: full [
	"Find a server and load updates from it."
 
	| server |
	server := self class findServer.
	server ifNotNil: [
		self synchWithDisk.
		full ifTrue: [self loadFullFrom: server]
			ifFalse:[self error: 'Not supported yet!'."self loadUpdatesFrom: server"]]
]

{ #category : #private }
SMSqueakMap >> mandatoryCategoriesFor: aClass [
	"Return the categories that are mandatory for instances of <aClass>."

	^self categories select: [:c | c mandatoryFor: aClass]
]

{ #category : #'private-installation' }
SMSqueakMap >> markInstalled: uuid version: version time: time counter: num [
	"Private. Mark the installation. SM2 uses an Association
	to distinguish the automatic version from old versions."

	^self registry markInstalled: uuid version: version time: time counter: num
]

{ #category : #'public-master' }
SMSqueakMap >> moveCategory: category toAfter: categoryBefore inParent: parent [
	"Move a category to be listed after <categoryBefore> in <parent>."

	parent move: category toAfter: categoryBefore.
	^category
	

]

{ #category : #'public-master' }
SMSqueakMap >> moveCategory: category toParent: parentCategory [
	"Move a category into another parent category."

	parentCategory
		ifNil: [category parent: nil]
		ifNotNil: [parentCategory addCategory: category].
	^category
	

]

{ #category : #transactions }
SMSqueakMap >> mutex [
	"Lazily initialize the Semaphore."

	^mutex ifNil: [mutex := Semaphore forMutualExclusion]
]

{ #category : #private }
SMSqueakMap >> newAccount [
	"Create a new account."

	^SMAccount newIn: self
]

{ #category : #'public-master' }
SMSqueakMap >> newAccount: name username: username email: email [
	"Create an account. Checking for previous account should already have been done.
	To add the account to the map, use SMSqueakMap>>addObject:"

	| account |
	account := self newAccount
					name: name;
					initials: username;
					email: email.
	^account
	

]

{ #category : #private }
SMSqueakMap >> newObject: anSMObject [ 
	"Add an SMObject to me. Clear the valid caches."

	self addDirty: anSMObject.
	self clearCachesFor: anSMObject.
	^objects at: anSMObject id put: anSMObject
]

{ #category : #checkpoints }
SMSqueakMap >> nextFileNameForCheckPoint [
	"Return the next available filename for a checkpoint."

	^self directory nextNameFor: self filename extension: self extension
]

{ #category : #'public-packages' }
SMSqueakMap >> notInstalledPackages [
	"Answer all packages that are not installed."

	^self packages reject: [:package | package isInstalled]
]

{ #category : #'public-installation' }
SMSqueakMap >> noteInstalled: aPackageRelease [
	"The package release was just successfully installed using SM.
	This is the method being called by SM upon a successful installation.

	We record this in our Dictionary of installed package releases
	and log a 'do it' to mark this in the changelog.
	The map used is the default map."

	^self noteInstalledPackageWithId: aPackageRelease package id asString
		autoVersion: aPackageRelease automaticVersion
		name: aPackageRelease package name
]

{ #category : #'public-installation' }
SMSqueakMap >> noteInstalledPackage: aPackage autoVersion: aVersion [
	"Mark that the package release was just successfully installed.
	Can be used to inform SM of an installation not been done using SM."

	
^self noteInstalledPackageWithId: aPackage id asString
		autoVersion: aVersion
		name: aPackage name
]

{ #category : #'private-installation' }
SMSqueakMap >> noteInstalledPackage: uuidString version: version [
	"Mark a specific version of a package as installed.
	This method is called when replaying a logged installation
	from before SqueakMap 1.07. Such logged installations lacked
	a timestamp and a count. We take the current time and a
	count starting from -10000 and upwards. This should keep
	the sorting order correct."

	^self registry noteInstalledPackage: uuidString version: version
]

{ #category : #'private-installation' }
SMSqueakMap >> noteInstalledPackage: uuidString version: version atSeconds: time number: num [
	"Mark a package as installed in the Dictionary.
	This method is called when replaying a logged installation.
	<time> is the point in time as totalSeconds of the installation.
	<num> is the installCount of the installation.
	This method is typically called from a doIt in the changelog
	in order to try to keep track of packages installed."

	^self registry noteInstalledPackage: uuidString version: version atSeconds: time number: num
]

{ #category : #'public-installation' }
SMSqueakMap >> noteInstalledPackageNamed: aString autoVersion: aVersion [
	"Mark that the package release was just successfully installed.
	<aVersion> is the automatic version as a String.
	Can be used to inform SM of an installation not been done using SM."

	| p |
	p := self packageWithNameBeginning: aString.
	p ifNil: [self error: 'No package found with name beginning with ', aString].
	
^self noteInstalledPackage: p autoVersion: aVersion asVersion
]

{ #category : #'public-installation' }
SMSqueakMap >> noteInstalledPackageWithId: aPackageId autoVersion: aVersion [
	"The package release was just successfully installed.
	Can be used to inform SM of an installation not been
	done using SM, even when the map isn't loaded."

	
^self noteInstalledPackageWithId: aPackageId
		autoVersion: aVersion
		name: '<unknown name>'
]

{ #category : #'private-installation' }
SMSqueakMap >> noteInstalledPackageWithId: uuidString autoVersion: version atSeconds: time number: num [
	"Mark a package as installed in the Dictionary.
	This method is called when replaying a logged installation.
	<time> is the point in time as totalSeconds of the installation.
	<num> is the installCount of the installation.
	This method is typically called from a doIt in the changelog
	in order to try to keep track of packages installed."

	^self registry noteInstalledPackageWithId: uuidString autoVersion: version atSeconds: time number: num
]

{ #category : #'public-installation' }
SMSqueakMap >> noteInstalledPackageWithId: aPackageId autoVersion: aVersion name: aName [
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

	^self registry noteInstalledPackageWithId: aPackageId autoVersion: aVersion name: aName
]

{ #category : #'private-installation' }
SMSqueakMap >> noteUninstalled: aPackageRelease [
	"The package release was just successfully uninstalled using SM.
	This is the method being called by SM upon a successful uninstallation.

	We record this in our Dictionary of installed package releases
	and log a 'do it' to mark this in the changelog.
	The map used is the default map."

	^self noteUninstalledPackageWithId: aPackageRelease package id asString
		autoVersion: aPackageRelease automaticVersion
		name: aPackageRelease package name
]

{ #category : #'private-installation' }
SMSqueakMap >> noteUninstalledPackageWithId: aPackageId autoVersion: aVersion name: aName [
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

	^self registry noteUninstalledPackageWithId: aPackageId autoVersion: aVersion name: aName
]

{ #category : #queries }
SMSqueakMap >> object: aUUID [
	"Look up a categorizable object. Return nil if missing."

	^objects at: aUUID ifAbsent: [nil]
]

{ #category : #queries }
SMSqueakMap >> objectWithId: anIdString [
	"Look up a categorizable object. Return nil if missing."

	^objects at: (UUID fromString: anIdString) ifAbsent: [nil]
]

{ #category : #accessing }
SMSqueakMap >> objects [
	^objects
]

{ #category : #'public-packages' }
SMSqueakMap >> oldPackages [
	"Answer all packages that are installed with a
	newer published version for this Squeak version available."

	^self installedPackages select: [:package | package isSafelyOld]
]

{ #category : #private }
SMSqueakMap >> oldReload [
	"Reload the map from the latest checkpoint on disk.
	The opposite of #purge."

	| fname stream map |
	fname := self directory lastNameFor: self filename extension: 'sgz'.
	fname ifNil: [self error: 'No ImageSegment checkpoint available!'].
	stream := (StandardFileStream oldFileNamed: (self directory fullNameFor: fname)) asUnZippedStream.
	stream ifNil: [self error: 'Couldn''t open stream on checkpoint file!'].
	[map := (stream fileInObjectAndCode) install arrayOfRoots first] ensure: [stream close].
	self copyFrom: map
]

{ #category : #accessing }
SMSqueakMap >> packageCacheDirectory [
	"Return a FileDirectory for the package cache of the map.
	Creates it if it is missing."

	| dirName baseDir |
	dirName := self packageCacheDirectoryName.
	baseDir := self directory.
	(baseDir fileOrDirectoryExists: dirName)
		ifFalse:[baseDir createDirectory: dirName].
	^baseDir directoryNamed: dirName
]

{ #category : #private }
SMSqueakMap >> packageCacheDirectoryName [
	"What is the name of the cache directory?"

	^'cache'
]

{ #category : #queries }
SMSqueakMap >> packageReleaseWithId: anIdString [ 
	"Look up a package release. Return nil if missing.
	Raise error if it is not a package release."

	| r |
	r := self objectWithId: anIdString.
	r ifNil: [^nil].
	r isPackageRelease ifTrue:[^r].
	self error: 'UUID did not map to a package release.'
]

{ #category : #accessing }
SMSqueakMap >> packageReleases [
	"Return subset of objects."

	objects ifNil: [^#()].
	^objects select: [:o | o isPackageRelease]
]

{ #category : #queries }
SMSqueakMap >> packageWithId: anIdString [ 
	"Look up a package. Return nil if missing.
	Raise error if it is not a package."

	| package |
	package := self objectWithId: anIdString.
	package ifNil: [^nil].
	package isPackage ifTrue:[^package].
	self error: 'UUID did not map to a package.'
]

{ #category : #queries }
SMSqueakMap >> packageWithName: aName [ 
	"Look up a package by exact match on name. Signal an exception if missing."
	^ self
		packageWithName: aName
		ifAbsent: [ self error: aName , ' is not in the cached catalog.' ]
]

{ #category : #queries }
SMSqueakMap >> packageWithName: aName ifAbsent: aBlock [ 
	"Look up a package by exact match on name. Answer the value of aBlock if missing."
	^ self packages
		detect: [ : package | package name = aName ]
		ifNone: aBlock
]

{ #category : #queries }
SMSqueakMap >> packageWithNameBeginning: aString [
	"Look up a package beginning with <aString>. Return nil if missing.
	We return the shortest matching one. We also strip out spaces and
	ignore case in both <aString> and the names."

	| candidates shortest answer searchString |
	searchString := (aString asLowercase) copyWithout: Character space.
	candidates := self packages select: [:package |
		((package name asLowercase) copyWithout: Character space)
			beginsWith: searchString ].
	shortest := 1000.
	candidates do: [:package |
		package name size < shortest ifTrue:[answer := package. shortest := package name size]].
	^answer	
]

{ #category : #queries }
SMSqueakMap >> packageWithPI: aPIName [
	"Look up a package by exact match on PackageInfo name. Return nil if missing."

	aPIName isEmptyOrNil ifTrue: [^nil].
	^self packages detect: [:package | package packageInfoName = aPIName ] ifNone: [nil]
]

{ #category : #accessing }
SMSqueakMap >> packages [
	"Lazily maintain a cache of all known package objects."

	packages ifNotNil: [^packages].
	objects ifNil: [^#()].
	packages := objects select: [:o | o isPackage].
	^packages
]

{ #category : #queries }
SMSqueakMap >> packagesByName [
	"Return the packages sorted by their name."

	^self packages sorted: [:x :y | x name caseInsensitiveLessOrEqual: y name]
]

{ #category : #private }
SMSqueakMap >> pingServer: aServerName [

	^self class pingServer: aServerName
]

{ #category : #public }
SMSqueakMap >> purge [
	"Clear out the map from memory. Use this to reclaim space,
	no information is lost because it does not remove information
	about what packages are installed, and the map itself is checkpointed
	to disk. Use #reload to get it back from the latest checkpoint on disk."

	objects := accounts := users := packages := categories := nil.
	checkpointNumber := 0.
]

{ #category : #accessing }
SMSqueakMap >> registry [
	^registry ifNil: [registry := SMInstallationRegistry map: self]
]

{ #category : #public }
SMSqueakMap >> reload [
	"Reload the map from the latest checkpoint on disk.
	The opposite of #purge."

	| fname stream map |
	fname := self lastCheckpointFilename.
	fname ifNil: [self error: 'No checkpoint available!'].
	"Code below uses good ole StandardFileStream to avoid m17n issues (this is binary data) and
	also uses #unzipped since it works in older Squeaks"
	stream := (StandardFileStream oldFileNamed: (self directory fullNameFor: fname)) asUnZippedStream.
	stream ifNil: [self error: 'Couldn''t open stream on checkpoint file!'].
	[map := stream fileInObjectAndCode] ensure: [stream close].
	self copyFrom: map
]

{ #category : #'public-master' }
SMSqueakMap >> removeCategory: category inObject: object [
	"Remove a category from an object."

	^object removeCategory: category

]

{ #category : #'public-master' }
SMSqueakMap >> repair [
	"Integrity repairs. This should not be neeed, but
	for some reason the map can obviously get messed up,
	not sure how."

	"SMSqueakMap default repair"
	
	"all objects should point back to me and not at another map"
	objects do: [:o | o map: self].
	
	"all releases should point back at the package they are in"
	self packages do: [:p | p releases do: [:r | r package: p]].
	
	"all releases in this map should point at a package in this map"
	self packageReleases do: [:r | | p |
		p := self object: r package id.
		p ifNil: [self error: 'Unknown package'].
		r package: p]
]

{ #category : #checkpoints }
SMSqueakMap >> saveCheckpoint: contentWithFilename [
	"Save the map checkpoint to disk if it is not there already."

	| file directory sz fname content |
	directory := self directory.
	sz := contentWithFilename size.
	fname := contentWithFilename last: sz - (contentWithFilename lastIndexOf: $:).
	content := contentWithFilename first: sz - fname size - 1.
	(directory fileExists: fname) ifFalse: [
		"Please do not upgrade the following to use Squeak 4.0 or later API's (e.g., #newFileNamed:do:) until we can convert the SMServer code to latest Squeaks."
		[file := StandardFileStream newFileNamed: (directory fullNameFor: fname).
		file nextPutAll: content]
			ensure: [file close]]
]

{ #category : #transactions }
SMSqueakMap >> setDirty [
	"Set the map modified so that it will get written to disk."

	isDirty := true
]

{ #category : #accessing }
SMSqueakMap >> silent [
	"Can installations ask questions or should they be silent
	and us good defaults?"

	^ silent ifNil: [false] ifNotNil: [true]
]

{ #category : #'public-installation' }
SMSqueakMap >> silentlyDo: aBlock [
	"Execute <aBlock> with the Silent flag set.
	This is a crude way of avoiding user interaction
	during batch operations, like loading updates."

	[silent := true.
	aBlock value]
		ensure: [silent := nil]
]

{ #category : #accessing }
SMSqueakMap >> sortedCategories [
	"Lazily maintain a cache of all known category objects."
	^ self categories
		sorted: [:a :b | (a name compare: b name caseSensitive: true)
				= 1]
]

{ #category : #private }
SMSqueakMap >> synchWithDisk [
	"Synchronize myself with the checkpoints on disk.
	If there is a newer checkpoint than I know of, load it.
	If there is no checkpoint or if I have a higher checkpoint number,
	create a new checkpoint from me.

	The end result is that I am in synch with the disk and we are both as
	updated as possible."

	| checkpointNumberOnDisk |
	 "If there is no checkpoint, save one from me."
	(self isCheckpointAvailable) ifFalse: [
		"If I am purged - don't checkpoint, no point"
		self isPurged ifTrue: [^self].
		^self createCheckpointNumber: checkpointNumber].
	"If the one on disk is newer, load it"
	checkpointNumberOnDisk := self lastCheckpointNumberOnDisk.
	(checkpointNumber < checkpointNumberOnDisk)
		ifTrue: [^self reload].
	"If I am newer, recreate me on disk"
	(checkpointNumberOnDisk < checkpointNumber)
		ifTrue: [^self createCheckpointNumber: checkpointNumber]
]

{ #category : #queries }
SMSqueakMap >> topCategories [
	^self categories select: [:cat | cat isTopCategory]
]

{ #category : #transactions }
SMSqueakMap >> transaction: aBlock [
	"Execute aBlock and then make sure any modified SMObjects
	are committed to disk. We do this inside a mutex in order to
	serialize transactions. Transactions must be initiated from
	service methods in this class and not from inside the domain
	objects - otherwise they could get nested and a deadlock occurs."

"In first version of SM2 we simply set the isDirty flag,
when next client asks for updates, or 30 minutes has passed,
we checkpoint."

"	self mutex critical: ["
		aBlock value.
		isDirty := true
"	]"

"	self mutex critical: [
		dirtyList := OrderedCollection new.
		aBlock value.
		dirtyList do: [:obj | obj commit].
		dirtyList := nil
	]"
]

{ #category : #'public-installation' }
SMSqueakMap >> upgradeOldPackages [
	"Upgrade all upgradeable old packages without confirmation on each."

	^self upgradeOldPackagesConfirmBlock: [:package | true ]
]

{ #category : #'public-installation' }
SMSqueakMap >> upgradeOldPackagesConfirmBlock: aBlock [
	"First we find out which of the installed packages are upgradeable and old.
	Then we upgrade them if confirmation block yields true.
	The block will be called with each SMPackage to upgrade.
	We return a Dictionary with the packages we tried to upgrade as keys
	and the value being the result of the upgrade, true or false."

	| result |
	result := Dictionary new.
	self upgradeableAndOldPackages
		do: [:package |
			(aBlock value: package)
				ifTrue:[ result at: package put: package upgrade]].
	^result

]

{ #category : #'public-installation' }
SMSqueakMap >> upgradeOrInstallPackage: aPackage [
	"Upgrade package (or install) to the latest published release for this Squeak version."

	^aPackage upgradeOrInstall
]

{ #category : #'public-installation' }
SMSqueakMap >> upgradeOrInstallPackageWithId: anUUIDString [
	"Upgrade package (or install) to the latest published release for this Squeak version."

	| package |
	package := self packageWithId: anUUIDString.
	package ifNil: [self error: 'No package available with id: ''', anUUIDString, ''''].
	^package upgradeOrInstall
]

{ #category : #'public-installation' }
SMSqueakMap >> upgradeOrInstallPackageWithId: anUUIDString asOf: aTimeStamp [
	"Upgrade package (or install) to the latest published release as it was
	on <aTimeStamp> for this Squeak version. This ensures that the same
	release will be installed (for all Squeak versions) as when it was tested."

	| package |
	package := self packageWithId: anUUIDString.
	package ifNil: [self error: 'No package available with id: ''', anUUIDString, ''''].
	^package upgradeOrInstall
]

{ #category : #'public-installation' }
SMSqueakMap >> upgradePackage: aPackage [
	"Upgrade package to the latest published release for this Squeak version."

	^aPackage upgrade
]

{ #category : #'public-installation' }
SMSqueakMap >> upgradePackageWithId: anUUIDString [
	"Upgrade package to the latest published release for this Squeak version.
	Will raise error if there is no release installed, otherwise use
	#upgradeOrInstallPackageWithId: "

	| package |
	package := self packageWithId: anUUIDString.
	package ifNil: [self error: 'No package available with id: ''', anUUIDString, ''''].
	^package upgrade
]

{ #category : #'public-packages' }
SMSqueakMap >> upgradeableAndOldOrInstallableAndNotInstalledPackages [
	"This would give you all packages that are available now
	for automatic install or automatic upgrade."

	^self upgradeableAndOldPackages union: self installableAndNotInstalledPackages
]

{ #category : #'public-packages' }
SMSqueakMap >> upgradeableAndOldPackages [
	"Answer all packages that are installed and which have a
	newer published release for this Squeak version that also
	can be to by an installer."

	^self installedPackages select: [:package | package isSafelyOldAndUpgradeable]
]

{ #category : #private }
SMSqueakMap >> usernameOccupied: aUsername [
	"Return true if name already taken."

	^(self accountForUsername: aUsername) notNil
]

{ #category : #accessing }
SMSqueakMap >> users [
	"Lazily maintain a cache of all known account objects
	keyed by their developer initials."

	users ifNotNil: [^users].
	users := Dictionary new.
	self accounts do: [:a | users at: a initials put: a].
	^users
]

{ #category : #private }
SMSqueakMap >> verifyAdminPassword: aString [
	"Answer true if it is the correct password."

	^adminPassword = (SecureHashAlgorithm new hashMessage: aString)
]

{ #category : #views }
SMSqueakMap >> viewFor: uiObject [
	"This is a double dispatch mechanism for multiple views
	for multiple uis. Used primarily by the web frontend."

	^uiObject squeakMapViewOn: self
]
