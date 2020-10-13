Class {
	#name : #InstallerTestSuite,
	#superclass : #TestSuite,
	#category : #'Tests-Installer-Core'
}

{ #category : #'initialize-release' }
InstallerTestSuite >> ensureTestMethods [
	"Ensure InstallerTest has test methods for each externally-loadable package defined by Installer.  By generating these methods, they don't have to be maintained separately."
	^ (Installer methodsInCategory: 'package-definitions') do:
		[ : each | (InstallerTest canUnderstand: each) ifFalse:
			[ InstallerTest 
				compile:
					(String streamContents:
						[ : stream | stream
							 nextPutAll: 'test'; nextPutAll: each;
							 cr; tab;
							 nextPutAll: 'Installer new merge: #'; nextPutAll: each ])
				classified: '*generated' ] ]
]

{ #category : #'initialize-release' }
InstallerTestSuite >> initialize [
	super initialize.
	self ensureTestMethods
]
