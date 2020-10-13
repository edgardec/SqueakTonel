"
I am a SMInstaller that knows how to install .mcz (Monticello) files. If Monticello is installed I use that (MCMczReader), otherwise I file in the code more simply using the package MCInstaller (MczInstaller).
"
Class {
	#name : #SMMcInstaller,
	#superclass : #SMSimpleInstaller,
	#category : #'SMBase-installer'
}

{ #category : #testing }
SMMcInstaller class >> canInstall: aPackage [
	"Is this a Monticello package and do I have MCInstaller
	or Monticello available?"

	| fileName |
	((Smalltalk includesKey: #MCMczReader) or: [
		 Smalltalk includesKey: #MczInstaller])
			ifTrue: [
				fileName := aPackage downloadFileName.
				fileName ifNil: [^false].
				^ 'mcz' = (FileDirectory extensionFor: fileName) asLowercase].
	^false
]

{ #category : #private }
SMMcInstaller >> fileIn [
	| extension |
	extension := (FileDirectory extensionFor: fileName) asLowercase.
	extension = 'mcz'
		ifTrue: [self installMcz]
		ifFalse: [self error: 'Cannot install file of type .', extension]
]

{ #category : #private }
SMMcInstaller >> fullFileName [ 
	^ dir fullNameFor: fileName
]

{ #category : #services }
SMMcInstaller >> install [
	"This service should bring the package to the client,
	unpack it if necessary and install it into the image.
	The package is notified of the installation."

	self cache; fileIn.
	packageRelease noteInstalled
]

{ #category : #private }
SMMcInstaller >> installMcz [
	"Install the package, we already know that either MCInstaller or Monticello is available."

	| installer monticello |
	installer := MczInstaller.
	(Smalltalk hasClassNamed: #MCMczReader) ifFalse: [
		packageRelease package isInstalled ifTrue: [
			(self silent ifFalse: [
				(self confirm:
'A release of package ''', packageRelease package name, ''' is already installed.
You only have MCInstaller and not Monticello
installed and MCInstaller can not properly upgrade packages.
Do you wish to install Monticello first and then proceed?
If you answer no MCInstaller will be used - but at your own risk.
Cancel cancels the installation.' orCancel: [self error: 'Installation cancelled.'])]
			ifTrue: [false])
				ifTrue: [
					monticello := packageRelease map packageWithName: 'Monticello'.
					monticello lastPublishedRelease
						ifNotNil: [monticello lastPublishedRelease install]
						ifNil: [monticello lastRelease install].
					installer := (Smalltalk at: #MCMczReader)]]
	] ifTrue: [installer := (Smalltalk at: #MCMczReader)].
	installer loadVersionFile: self fullFileName
]
