Class {
	#name : #InstallerFile,
	#superclass : #Installer,
	#category : #'Installer-Core'
}

{ #category : #'basic interface' }
InstallerFile >> basicBrowse [
	
	self browse: self file from:  (FileDirectory readOnlyFileNamed: self file).

	
]

{ #category : #'basic interface' }
InstallerFile >> basicInstall [
	
	self install: self file from: (FileDirectory default readOnlyFileNamed: self file)

	
]

{ #category : #'basic interface' }
InstallerFile >> basicView [
	
	self view: self file from:  (FileDirectory readOnlyFileNamed: self file).

	
]

{ #category : #accessing }
InstallerFile >> file [

	^ self package
]

{ #category : #accessing }
InstallerFile >> file: f [
	self package: f
]
