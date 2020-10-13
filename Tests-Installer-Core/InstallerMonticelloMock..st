"
An InstallerMonticelloMock is a Monticello installer with dummy methods
to mock the behavior of InstallerMonticello without connection to an
actual repository.

Some related classes are mocked as instances of InstallerTest, which
is sufficent to support the tests in InstallerTest.

"
Class {
	#name : #InstallerMonticelloMock,
	#superclass : #InstallerMonticello,
	#category : #'Tests-Installer-Core'
}

{ #category : #'initialize-release' }
InstallerMonticelloMock >> initialize [
	super initialize.
	"Let a new instance of InstallerTest serve as a mock for the default MCRepositoryGroup"
	mc := InstallerTest new.
]

{ #category : #'initialize-release' }
InstallerMonticelloMock >> setMockCache: fileNames [
	"Set the mock cache with file names similar to what might be expected
	in a MCRepositoryGroup."
	mc allFileNames: fileNames
]
