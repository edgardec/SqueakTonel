Class {
	#name : #InstallerUrlTest,
	#superclass : #TestCase,
	#category : #'Tests-Installer-Core'
}

{ #category : #tests }
InstallerUrlTest >> testAddPackageShouldResultInCorrectUrl [
	| url |
	url := (Installer url: 'http://seaside.gemstone.com/ss/metacello')
	    addPackage: 'ConfigurationOfMetacello-dkh.754.mcz';
	    urlToDownload.
	"Note the insertion of a / in the URL."
	self
		assert: 'http://seaside.gemstone.com/ss/metacello/ConfigurationOfMetacello-dkh.754.mcz'
		equals: url.
]
