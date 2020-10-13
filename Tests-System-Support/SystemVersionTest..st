"
I am an sunit test for SystemVersion.  Originally created to test SqueakMapSystemVersionFix change set.
I have no test fixtures.
"
Class {
	#name : #SystemVersionTest,
	#superclass : #TestCase,
	#category : #'Tests-System-Support'
}

{ #category : #tests }
SystemVersionTest >> testMajorMinorVersion [
	"
	SystemVersionTest run: #testMajorMinorVersion
	"
	self assert: (SystemVersion new version: 'Squeak3.7alpha') majorMinorVersion = 'Squeak3.7'.
	self assert: (SystemVersion new version: 'Squeak3.7') majorMinorVersion = 'Squeak3.7'.
	self assert: (SystemVersion new version: 'Squeak3') majorMinorVersion = 'Squeak3'.
	self assert: (SystemVersion new version: '') majorMinorVersion = ''.

]
