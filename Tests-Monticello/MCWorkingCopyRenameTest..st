Class {
	#name : #MCWorkingCopyRenameTest,
	#superclass : #MCTestCase,
	#instVars : [
		'savedInitials',
		'workingCopy',
		'repositoryGroup',
		'versions',
		'versions2'
	],
	#category : #'Tests-Monticello'
}

{ #category : #running }
MCWorkingCopyRenameTest >> mockPackage [

	^MCPackage named: self mockCategoryName
]

{ #category : #running }
MCWorkingCopyRenameTest >> setUp [
	| repos1 repos2 |
	repositoryGroup := MCRepositoryGroup new.
	workingCopy := MCWorkingCopy forPackage: self mockPackage.
	versions := Dictionary new.
	versions2 := Dictionary new.
	repos1 := MCDictionaryRepository new dictionary: versions.
	repos2 := MCDictionaryRepository new dictionary: versions2.
	repositoryGroup addRepository: repos1.
	repositoryGroup addRepository: repos2.
	MCRepositoryGroup default removeRepository: repos1; removeRepository: repos2.
	workingCopy repositoryGroup: repositoryGroup.
	savedInitials := Utilities authorInitialsPerSe.
	Utilities authorInitials: 'abc'.
]

{ #category : #running }
MCWorkingCopyRenameTest >> tearDown [
	super tearDown.
	workingCopy unregister.
	SystemOrganizer default removeEmptyCategories.
	MCSnapshotTest organization removeEmptyCategories.
	Utilities authorInitials: savedInitials
]

{ #category : #tests }
MCWorkingCopyRenameTest >> testRenamePrefix [

	self verifyRenameTo: 'Renamed-' , workingCopy packageName
]

{ #category : #tests }
MCWorkingCopyRenameTest >> testRenameSuffix [

	self verifyRenameTo: workingCopy packageName, '-Renamed'
]

{ #category : #tests }
MCWorkingCopyRenameTest >> verifyRenameTo: newName [ 
	
	| oldWorkingCopy oldDefinitions newWorkingCopy |
	oldWorkingCopy := workingCopy.
	oldDefinitions := workingCopy package snapshot definitions.
	[ 
		newWorkingCopy := workingCopy renameToBe: newName.
		self
			 assert: oldWorkingCopy ancestors = newWorkingCopy ancestors ;
			 assert: newWorkingCopy needsSaving ;
			 assert: newWorkingCopy requiredPackages = oldWorkingCopy requiredPackages ;
			 assert: newWorkingCopy repositoryGroup repositories = oldWorkingCopy repositoryGroup repositories ;
			 assert: newWorkingCopy package snapshot definitions size = oldDefinitions size ;
			 assert: (MCWorkingCopy registry includesKey: newWorkingCopy package) ;
			 assert: (MCWorkingCopy registry includes: newWorkingCopy) ;
			 deny: (MCWorkingCopy registry includes: oldWorkingCopy).
		workingCopy := newWorkingCopy ] ensure: [ 
			" ensure that we rename the category back to the original name "
			(SystemOrganizer default categories includes: newName) ifTrue: [
				SystemOrganizer default
					renameCategory: newName
					toBe: oldWorkingCopy packageName ] ]
]
