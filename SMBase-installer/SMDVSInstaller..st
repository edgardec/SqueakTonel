"
This is an installer class for DVS packages. It handles packages categorized with package
format as DVS and with a download filename with extensions .st or .st.gz.

This class can function without DVS installed, needed classes are looked up dynamically.
"
Class {
	#name : #SMDVSInstaller,
	#superclass : #SMDefaultInstaller,
	#category : #'SMBase-installer'
}

{ #category : #testing }
SMDVSInstaller class >> canInstall: aPackage [
	"Can I install this? First we check if class StreamPackageLoader
	is available, otherwise DVS isn't installed.
	Then we check if the package is categorized with package
	format DVS - currently we have hardcoded the id of that category."

	
	Smalltalk at: #StreamPackageLoader ifPresent: [ :loader | | fileName |
		fileName := aPackage downloadFileName.
		fileName ifNil: [^false].
		fileName := fileName asLowercase.
		^((fileName endsWith: '.st') or: [fileName endsWith: '.st.gz'])
			and: [aPackage categories includes: "The DVS format category"
					(SMSqueakMap default
						categoryWithId: 'b02f51f4-25b4-4117-9b65-f346215a8e41')]].
	^false
]

{ #category : #loading }
SMDVSInstaller class >> loadDVS [
	"Load the DVS package from SqueakMap."

	SMSqueakMap default installPackageWithId: '100d59d0-bf81-4e74-a4fe-5a2fd0c6b4ec'
]

{ #category : #services }
SMDVSInstaller >> install [
	"Install using DVS."

	| imagePackageLoader streamPackageLoader packageInfo packageManager baseName current new manager |
	self cache; unpack.
	imagePackageLoader := Smalltalk at: #ImagePackageLoader ifAbsent: [].
	streamPackageLoader := Smalltalk at: #StreamPackageLoader ifAbsent: [].
	packageInfo := Smalltalk at: #PackageInfo ifAbsent: [].
	packageManager := Smalltalk at: #FilePackageManager ifAbsent: [].

	({ imagePackageLoader. streamPackageLoader. packageInfo. packageManager } includes: nil)
		ifTrue: [ (self confirm: ('DVS support is not loaded, but would be helpful in loading ', unpackedFileName, '.
It isn''t necessary, but if you intend to use DVS later it would be a good idea to load it now.
Load it from SqueakMap?'))
			ifTrue: [ self class loadDVS. ^self install ]
			ifFalse: [ ^self fileIn ]].

	baseName := packageRelease name.
	dir rename: unpackedFileName toBe: (baseName, '.st').
	unpackedFileName := baseName, '.st'.

	(manager := packageManager allManagers detect: [ :pm | pm packageName = baseName ] ifNone: [])
		ifNotNil: [
			current := imagePackageLoader new package: (packageInfo named: baseName).
			new := streamPackageLoader new stream: (dir readOnlyFileNamed: unpackedFileName).
			(new changesFromBase: current) fileIn ]
		ifNil: [
			self fileIn.
			manager := packageManager named: baseName. ].

	manager directory: dir.
	packageManager changed: #allManagers.
	packageRelease noteInstalled
]
