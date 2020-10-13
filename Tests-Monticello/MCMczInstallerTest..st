Class {
	#name : #MCMczInstallerTest,
	#superclass : #MCTestCase,
	#instVars : [
		'expected',
		'diff'
	],
	#category : #'Tests-Monticello'
}

{ #category : #'as yet unclassified' }
MCMczInstallerTest class >> isAbstract [
	^ (Smalltalk hasClassNamed: #MczInstaller) not
		
]

{ #category : #'as yet unclassified' }
MCMczInstallerTest class >> suite [
	^ (Smalltalk hasClassNamed: #MczInstaller)
		ifTrue: [super suite]
		ifFalse: [TestSuite new name: self name asString]
]

{ #category : #asserting }
MCMczInstallerTest >> assertDict: dict matchesInfo: info [
	#(name id message date time author)
		do: [:sel |  (info perform: sel) ifNotNil: [:i | dict at: sel ifPresent: [:d | self assert: i = d]]].
	info ancestors 
			with: (dict at: #ancestors) 
			do: [:i :d | self assertDict: d matchesInfo: i]
]

{ #category : #asserting }
MCMczInstallerTest >> assertNoChange [
	| actual |
	actual := MCSnapshotResource takeSnapshot.
	diff := actual patchRelativeToBase: expected snapshot.
	self assert: diff isEmpty
]

{ #category : #asserting }
MCMczInstallerTest >> assertVersionInfoPresent [
	| dict info |
	dict := MczInstaller versionInfo at: self mockPackage name.
	info := expected info.
	self assertDict: dict matchesInfo: info.
]

{ #category : #accessing }
MCMczInstallerTest >> defaultTimeout [

	^ super defaultTimeout * 10 "seconds"
]

{ #category : #actions }
MCMczInstallerTest >> deleteFile [
	(FileDirectory default fileExists: self fileName)
		ifTrue: [FileDirectory default deleteFileNamed: self fileName]
]

{ #category : #accessing }
MCMczInstallerTest >> fileName [
	^ 'InstallerTest.mcz' asMCVersionName
]

{ #category : #accessing }
MCMczInstallerTest >> fileStream [
	^ FileStream forceNewFileNamed: self fileName.
]

{ #category : #running }
MCMczInstallerTest >> setUp [
	expected := self mockVersion.
	self change: #one toReturn: 2.
]

{ #category : #running }
MCMczInstallerTest >> tearDown [

	super tearDown.
	expected snapshot updatePackage: self mockPackage.
	self deleteFile.
]

{ #category : #tests }
MCMczInstallerTest >> testInstallFromFile [
	MCMczWriter fileOut: expected on: self fileStream.
	MczInstaller installFileNamed: self fileName.
	self assertNoChange.
]

{ #category : #tests }
MCMczInstallerTest >> testInstallFromStream [
	| stream |
	stream := RWBinaryOrTextStream on: String new.
	MCMczWriter fileOut: expected on: stream.
	MczInstaller installStream: stream reset.
	self assertNoChange.
	self assertVersionInfoPresent.
	
]
