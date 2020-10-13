Class {
	#name : #MCDirectoryRepositoryTest,
	#superclass : #MCRepositoryTest,
	#instVars : [
		'directory'
	],
	#category : #'Tests-Monticello'
}

{ #category : #actions }
MCDirectoryRepositoryTest >> addVersion: aVersion [
	| file |
	file := FileStream newFileNamed: (directory fullNameFor: aVersion fileName).
	aVersion fileOutOn: file.
	file close.
]

{ #category : #accessing }
MCDirectoryRepositoryTest >> directory [
	directory ifNil:
		[directory := FileDirectory default directoryNamed: 'mctest'.
		directory assureExistence].
	^ directory
]

{ #category : #running }
MCDirectoryRepositoryTest >> setUp [
	repository := MCDirectoryRepository directory: self directory
]

{ #category : #running }
MCDirectoryRepositoryTest >> tearDown [

	super tearDown.
	self directory recursiveDelete
]
