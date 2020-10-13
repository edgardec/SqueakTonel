"
An installer takes care of installing SqueakMap packages represented by SMCards.
Deciding if a package is installable and instantiating the correct installer class is done on the class side, see implementors of #canInstall:. Two methods need to be implemented by subclasses - download and install. Upgrade can also be specialized by implementing #upgrade, otherwise it will default to #install.
"
Class {
	#name : #SMInstaller,
	#superclass : #Object,
	#instVars : [
		'packageRelease'
	],
	#category : #'SMBase-installer'
}

{ #category : #'changeset utilities' }
SMInstaller class >> basicNewChangeSet: newName [ 
	"This method copied here to ensure SqueakMap is independent of 
	ChangesOrganizer. "
	Smalltalk
		at: #ChangesOrganizer
		ifPresentAndInMemory: [:cs | ^ cs basicNewChangeSet: newName].
	(self changeSetNamed: newName)
		ifNotNil: [self error: 'The name ' , newName , ' is already used'].
	^ ChangeSet basicNewNamed: newName
]

{ #category : #testing }
SMInstaller class >> canInstall: aPackageRelease [
	"Nope, I am an abstract class and can not install anything.
	But my subclasses should reimplement this."

	^ false
]

{ #category : #'changeset utilities' }
SMInstaller class >> changeSetNamed: newName [
	"This method copied here to ensure SqueakMap is independent of ChangesOrganizer."

	Smalltalk at: #ChangesOrganizer ifPresentAndInMemory: [ :cs | ^cs changeSetNamed: newName ].
	^ChangeSet allInstances detect: [ :cs | cs name = newName ] ifNone: [ nil ].
]

{ #category : #'instance creation' }
SMInstaller class >> classForPackageRelease: aPackageRelease [
	"Decide which subclass to instantiate. 
	We detect and return the first subclass
	that wants to handle the release going
	recursively leaf first so that subclasses gets
	first chance if several classes compete over
	the same packages, like for example SMDVSInstaller
	that also uses the .st file extension."

	self subclasses do: [:ea |
		(ea classForPackageRelease: aPackageRelease)
			ifNotNil: [:class | ^ class]].
	^(self canInstall: aPackageRelease)
		ifTrue: [self]
]

{ #category : #deprecated }
SMInstaller class >> forPackageRelease: aPackageRelease [
	"Instantiate the first class suitable to install the package release.
	If no installer class is found we raise an Error."

	| class |
	aPackageRelease ifNil: [self error: 'No package release specified to find installer for.'].
	class := self classForPackageRelease: aPackageRelease.
	^class
		ifNil: [self error: 'No installer found for package ', aPackageRelease name, '.']
		ifNotNil: [class new packageRelease: aPackageRelease]
]

{ #category : #testing }
SMInstaller class >> isInstallable: aPackageRelease [
	"Detect if any subclass can handle the package release."

	aPackageRelease ifNil: [^false].
	^(self classForPackageRelease: aPackageRelease) notNil
]

{ #category : #testing }
SMInstaller class >> isUpgradeable: aPackageRelease [
	"Detect if any subclass can handle the release.
	Currently we assume that upgrade is the same as install."

	^self isInstallable: aPackageRelease
]

{ #category : #services }
SMInstaller >> download [
	"This service should bring the package release to
	the client and also unpack it on disk if needed.
	It will not install it into the running image though.
	Raises errors if operation does not succeed."

	self subclassResponsibility 
]

{ #category : #services }
SMInstaller >> install [
	"This service should bring the package release to the client,
	unpack it if necessary and install it into the image.
	The package release should be notified of the installation using
	'packageRelease noteInstalled'."

	self subclassResponsibility 
]

{ #category : #testing }
SMInstaller >> isCached [
	"Check if it is in the cache."

	^packageRelease isCached
]

{ #category : #accessing }
SMInstaller >> packageRelease: aPackageRelease [
	packageRelease := aPackageRelease
]

{ #category : #private }
SMInstaller >> silent [
	"Can we ask questions?"
	
	^packageRelease ifNotNil: [packageRelease map silent] ifNil: [false]
]

{ #category : #services }
SMInstaller >> upgrade [
	"This service performs an upgrade to the selected release.
	Currently it just defaults to the same operation as an install -
	which is handled fine by Monticello, but not necessarily for
	other formats."

	^self install
]
