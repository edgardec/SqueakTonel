"
I am a SMInstaller that knows how to install .pr (Project) files.
"
Class {
	#name : #SMProjectInstaller,
	#superclass : #SMSimpleInstaller,
	#category : #'SMBase-installer'
}

{ #category : #testing }
SMProjectInstaller class >> canInstall: aPackage [
	"Answer if this class can install the package.
	We handle .pr files (upper and lowercase)"

	| fileName |
	fileName := aPackage downloadFileName.
	fileName ifNil: [^false].
	^'pr' = (FileDirectory extensionFor: fileName) asLowercase
]

{ #category : #services }
SMProjectInstaller >> install [
	"This service should bring the package to the client, 
	unpack it if necessary and install it into the image. 
	The package is notified of the installation."

	Project canWeLoadAProjectNow ifFalse: [self error: 'Can not load Project now, probably because not in Morphic.'].
	self cache.
	[[ ProjectLoading openFromDirectory: dir andFileName: fileName ]
		on: ProgressTargetRequestNotification do: [ :ex | ex resume ]]
			ensure: [packageRelease noteInstalled]
]
