Class {
	#name : #SMLanguageInstaller,
	#superclass : #SMSimpleInstaller,
	#category : #'SMBase-installer'
}

{ #category : #testing }
SMLanguageInstaller class >> canInstall: aPackage [
	"Answer if this class can install the package.
	We handle .translation files optionally compressed."

	| fileName |
	((Smalltalk includesKey: #Language)
		or: [Smalltalk includesKey: #NaturalLanguageTranslator]) ifFalse: [^false].
	fileName := aPackage downloadFileName.
	fileName ifNil: [^false].
	fileName := fileName asLowercase.
	^(fileName endsWith: '.translation') or: [
		(fileName endsWith: '.tra') or: [
			(fileName endsWith: '.tra.gz') or: [
				fileName endsWith: '.translation.gz']]]
]

{ #category : #services }
SMLanguageInstaller >> install [
	"This service should bring the package to the client, 
	unpack it if necessary and install it into the image. 
	The package is notified of the installation."

	| translator |
	self cache; unpack.
	translator := Smalltalk at: #Language ifAbsent: [Smalltalk at: #NaturalLanguageTranslator].
	[translator mergeTranslationFileNamed: unpackedFileName]
			ensure: [packageRelease noteInstalled]
]
