Class {
	#name : #SqueakFurtherCorePackagesHelp,
	#superclass : #SqueakCorePackagesHelp,
	#category : #'Help-Squeak-CorePackages'
}

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> balloonPackage [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #balloonPackage"
	^(HelpTopic
		title: 'Balloon'
		contents: 
'The Balloon package provides an engine for complex 2-D graphic objects and fast 2-D graphics rendering including anti-aliasing. It was originally written to render Flash. The main interface is BalloonCanvas which is used to render Morphs using the BalloonEngine. It also provides the FillStyle classes which enable gradient or form fill styles for Morphs.

It has nothing to do with the Balloon help concept which shows help texts on mouse over.!
]style[(193 13 239),dBalloonCanvas browse;;,!' readStream nextChunkText)
			key: #balloonPackage
]

{ #category : #accessing }
SqueakFurtherCorePackagesHelp class >> bookName [

	^ 'Further'
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> commandLine [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #commandLine"
	^(HelpTopic
		title: 'CommandLine'
		contents: 
'The CommandLine package provides classes for running Squeak in headless mode while dealing with events requiring user input. Essentially, it introduces a special ToolSet (CommandLineToolSet) which handles tool requests.!
]style[(162 7 2 18 30),dToolSet browse;;,,dCommandLineToolSet  browse;;,!' readStream nextChunkText)
			key: #commandLine
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> etoys [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #etoys"
	^HelpTopic
		title: 'Etoys'
		contents: 
'The Etoys package includes all of the Etoys system with extended Morphs, a tile-based scripting language user interface and interpreter, and several applications based upon that.

This package also includes the Kedama project which provides means to create simulations with large numbers of objects based on a columnar storage.!' readStream nextChunkText
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> monticello [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #monticello"
	^(HelpTopic
		title: 'Monticello'
		contents: 
'The Monticello package implements the infastructure and tools for working with the Monticello version control system. The package is split up into several categories: Monticello version control abstractions, serialization logic, repository management, tools, and monticello configuration management.

Monticello configurations denote a combination of version from different packages which form a consistent state together.!' readStream nextChunkText)
			key: #monticello
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> morphicExtras [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #morphicExtras"
	^(HelpTopic
		title: 'MorphicExtras'
		contents: 
'MorphicExtras contains a collection of additional Morphs which are either graphical tools or provide an extended API, such as the BookMorph class. Many of these can be found in the Objects tool. Additionally, it includes extensions to the Morphic UI such as Flaps.
!
]style[(130 9 42 12 72),dBookMorph browse;;,,dObjectsTool newStandAlone openInWorld;;,!' readStream nextChunkText)
			key: #morphicExtras
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> multilingual [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #multilingual"
	^(HelpTopic
		title: 'Multilingual'
		contents: 
'The Multilingual package adds support for multiple languages to Squeak. This includes the capabilities to import text in different encodings (think copy-and-paste), and render all kinds of fonts.

An interesting multilingual method of the String class is #encodedCharSetAt:.
!' readStream nextChunkText)
			key: #multilingual
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> nebraska [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #nebraska"
	^(HelpTopic
		title: 'Nebraska'
		contents: 
'Nebraska is a toolkit for building remote interactions with Morphic in Squeak. It is modelled somewhat after Kansas, although as yet it''s a much simpler system. There is a shared world on some server on a network, and other people can connect to that world from afar. Whenever the shared world tries to draw to its screen, it sends drawing commands across the network. Whenever a user tries to perform a mouse or keyboard interaction, those interactions are forwarded to the server where a RemoteControlledHand acts on their behalf.

See also http://wiki.squeak.org/squeak/1356!
]style[(543 34),Rhttp://wiki.squeak.org/squeak/1356;!' readStream nextChunkText)
			key: #nebraska
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> packageInfoPage [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #packageInfoPage"
	^(HelpTopic
		title: 'PackageInfo'
		contents: 
'The PackageInfo package provides classes providing a view on the classes in the system with respect to packages. These objects are only cached and represent no stored information. For more information look into the PackageInfo class.!
]style[(215 11 7),LPackageInfo Comment;,!' readStream nextChunkText)
			key: #packageInfoPage
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> preferenceBrowser [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #preferenceBrowser"
	^HelpTopic
		title: 'PreferenceBrowser'
		contents: 
'The PreferenceBrowser package contains the implementation of the preference browser tool which is currently only available in Morphic and thus does not reside with the ToolBuilder-based tools.!' readStream nextChunkText
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> protocols [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #protocols"
	^(HelpTopic
		title: 'Protocols'
		contents: 
'This package deals with vocabularies as they are used in Etoys. A vocabulary is the set of words understood by an object when viewed from Etoys. You can see examples of vocabularies in methods named ''additionsTo[some vocabulary category name]''.

Most of the methods behind a vocabulary term are implemented in Player which then often forward them to an implementation in its costume (often a Morph).

See also: http://wiki.squeak.org/squeak/3944!
]style[(411 34),Rhttp://wiki.squeak.org/squeak/3944;!' readStream nextChunkText)
			key: #protocols
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> releaseBuilder [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #releaseBuilder"
	^HelpTopic
		title: 'ReleaseBuilder'
		contents: 
'This package contains the script for preparing a new release from a trunk image.!' readStream nextChunkText
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> servicesPage [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #servicesPage"
	^(HelpTopic
		title: 'Services'
		contents: 
'Services are a concept for extending menus. You can register a service for a menu/application. A good starting point is the ServiceProvider.!
]style[(124 15 1),LServiceProvider Comment;,!' readStream nextChunkText)
			key: #servicesPage
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> shout [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit:  #introduction"
	^HelpTopic
		title: 'Shout'
		contents: 
'The Shout package provides parsing and syntax highlighting for Smalltalk code. It can be used to create alternative highlighting mechanisms. !
]style[(141)f1!' readStream nextChunkText
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> squeakSSL [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #squeakSSL"
	^HelpTopic
		title: 'SqueakSSL'
		contents: 
'The SqueakSSL provides the SecureSocket class which enables SSL encrpyted connections. For this to work the SqueakSSL plugin has to be installed. !' readStream nextChunkText
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> st80 [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit:  #st80"
	^HelpTopic
		title: 'ST80'
		contents: 
'The ST80 package bundles the MVC tool implementations in Squeak. They can be used through opening a MVC project. This is useful for example for debugging Morphic projects.!
]style[(171)f1!' readStream nextChunkText
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> systemReporter [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #systemReporter"
	^HelpTopic
		title: 'SystemReporter'
		contents: 
'SystemReporter provides the tool with the same name which provides information on the system such as VM or image versions, hardware information, or access to the debug log.!
]style[(28 4 140),dSystemReporter open;;,!' readStream nextChunkText
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> tests [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #tests"
	^(HelpTopic
		title: 'Tests'
		contents: 
'This package includes tests for many parts of the core system where core packages do not provide tests themselves.!' readStream nextChunkText)
			key: #tests
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> trueType [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #trueType"
	^(HelpTopic
		title: 'TrueType'
		contents: 
'The TrueType package includes classes for handling TrueType fonts. It provides domain abstractions as well as classes for importing TrueType fonts from files. A starting point is the TTCFont class.!
]style[(183 7 7),LTTCFont Comment;,!' readStream nextChunkText)
			key: #trueType
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> updateStream [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #updateStream"
	^(HelpTopic
		title: 'UpdateStream'
		contents: 
'This package provides scripts for updating all core packages within the image from a server. All these scripts are on the class side of UpdateStreamDownloader. !
]style[(136 22 2),dUpdateStreamDownloader browse;;,!' readStream nextChunkText)
			key: #updateStream
]

{ #category : #pages }
SqueakFurtherCorePackagesHelp class >> versionNumber [
	"This method was automatically generated. Edit it using:"
	"SqueakFurtherCorePackagesHelp edit: #versionNumber"
	^HelpTopic
		title: 'VersionNumber'
		contents: 
'This package includes domain specific code for handling version numbers either as a single VersionNumber or as a VersionHistory.

It is used in the SqueakMap package.!
]style[(91 13 9 14 39),LVersionNumber Comment;,,LVersionHistory Comment;,!' readStream nextChunkText
]
