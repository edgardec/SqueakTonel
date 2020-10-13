Class {
	#name : #MCInitializationTest,
	#superclass : #MCTestCase,
	#category : #'Tests-Monticello'
}

{ #category : #'as yet unclassified' }
MCInitializationTest class >> isAbstract [
	^ (Smalltalk hasClassNamed: #MczInstaller) not
		
]

{ #category : #running }
MCInitializationTest >> tearDown [

	super tearDown.
	(MCWorkingCopy forPackage: self mockPackage) unregister
]

{ #category : #tests }
MCInitializationTest >> testWorkingCopy [
	MczInstaller storeVersionInfo: self mockVersion.
	MCWorkingCopy initialize.
	MCWorkingCopy allManagers
						detect: [:man | man package name = self mockPackage name]
						ifNone: [self assert: false]
]
