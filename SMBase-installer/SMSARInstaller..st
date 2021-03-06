"
I am a SqueakMap installer that knows how to deal with Zip format change-set archives.
I recognize them by the file extension "".sar"" (Squeak Archive).

These have a couple of members with special names:

install/preamble
install/postscript

These are loaded in order. Either or both can further load other members using fileInMemberNamed:.

Inside a postscript or preamble, the pseudo-variable ""self"" is set to an instance of SARInstaller; you can then get to its ZipArchive using the method ""zip"". Or you can call its methods for filing in change sets, extracting files, etc.

You can test this loading with:
(SMSARInstaller new) directory: FileDirectory default; fileName: 'test.sar'; fileIn.

See ChangeSet>>fileOutAsZipNamed: for one way to make these files. Here is another way of creating a multi change set archive installable by SqueakMap:

""The following doit will create a .sar file with HVs preamble and postscript as
separate entries and the included changesets included as normal.
Given a preamble as described below this will autoinstall in SqueakMap.""
(ChangeSorter changeSetNamed: 'HV')
	fileOutAsZipNamed: 'httpview-021023.sar'
	including: {
		ChangeSorter changeSetNamed: 'HVFixes'.
		ChangeSorter changeSetNamed: 'kom412'}

Preamble in changeset HV that will install the changesets:

""Change Set:		HV
Date:			23 October 2002
Author:			Göran Hultgren

This is my latest developer code drop of HttpView packaged as a Squeak selfextracting archive (courtesy Ned Konz).""

""Standard SqueakMap installing code follows:""
(self isKindOf: SARInstaller) ifTrue:[
	self fileInMemberNamed: 'HVFixes'.
	self fileInMemberNamed: 'kom412'.
	self fileInMemberNamed: 'HV'
]


"
Class {
	#name : #SMSARInstaller,
	#superclass : #SMSimpleInstaller,
	#instVars : [
		'zip'
	],
	#category : #'SMBase-installer'
}

{ #category : #testing }
SMSARInstaller class >> canInstall: aPackage [
	"Answer if this class can install the package.
	We handle it if the filename has the extension
	.sar (upper and lowercase) and SARInstaller is
	present in the image to handle the install."

	| fileName |
	fileName := aPackage downloadFileName.
	fileName ifNil: [^false].
	Smalltalk at: #SARInstaller ifPresent: [ :installer |
			^'sar' = (FileDirectory extensionFor: fileName) asLowercase].
	^false
]

{ #category : #private }
SMSARInstaller >> fileIn [

	Smalltalk at: #SARInstaller ifPresent: [:installer |
		(installer directory: dir fileName: fileName) fileIn. ^self].
	self error: 'SAR support not installed in image, can not install.'
]

{ #category : #services }
SMSARInstaller >> install [
	"This service should bring the package to the client,
	unpack it if necessary and install it into the image.
	The package is notified of the installation."

	self cache; fileIn.
	packageRelease noteInstalled
]
