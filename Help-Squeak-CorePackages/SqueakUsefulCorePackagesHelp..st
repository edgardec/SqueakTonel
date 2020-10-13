Class {
	#name : #SqueakUsefulCorePackagesHelp,
	#superclass : #SqueakCorePackagesHelp,
	#category : #'Help-Squeak-CorePackages'
}

{ #category : #'as yet unclassified' }
SqueakUsefulCorePackagesHelp class >> bookName [

	^ 'Commonly Used'
]

{ #category : #pages }
SqueakUsefulCorePackagesHelp class >> compression [
	"This method was automatically generated. Edit it using:"
	"SqueakUsefulCorePackagesHelp edit: #compression"
	^(HelpTopic
		title: 'Compression'
		contents: 
'The Compression package provides classes for dealing with compressed files or compressed data in general. Compression-Archives contains most of the file-handling classes (for example Archive). Compression-Streams provides streams which can compress data written to them. !
]style[(183 7 81),dArchive browse;;,!' readStream nextChunkText)
			key: #compression
]

{ #category : #pages }
SqueakUsefulCorePackagesHelp class >> installer [
	"This method was automatically generated. Edit it using:"
	"SqueakUsefulCorePackagesHelp edit: #installer"
	^(HelpTopic
		title: 'Installer'
		contents: 
'This package provides the Installer tool which can be used to install packages from various sources including Monticello or SqueakMap. !' readStream nextChunkText)
			key: #installer
]

{ #category : #pages }
SqueakUsefulCorePackagesHelp class >> morphic [
	"This method was automatically generated. Edit it using:"
	"SqueakUsefulCorePackagesHelp edit: #morphic"
	^HelpTopic
		title: 'Morphic'
		contents: 
'Morphic contains the Morphic UI framework including event handling, basic drawing of Morphs, and the implementation of the Morphic UI. The main API is in the Morph class and the event loop of the framework can be found in WorldState. 

The package also includes several example Morphs such as the ClickExerciser.

The main entrance point for working with Morphs is by composing or subclassing Morph subclasses.!
]style[(222 10 65 14 82 5 12),dWorldState browse;;,,dClickExerciser new openInWorld;;,,dMorph browse;;,!' readStream nextChunkText
]

{ #category : #pages }
SqueakUsefulCorePackagesHelp class >> regex [
	"This method was automatically generated. Edit it using:"
	"SqueakUsefulCorePackagesHelp edit: #regex"
	^HelpTopic
		title: 'Regex'
		contents: 
'Regex provides a regular expression matching engine. It is mainly used through the interface exposed on String objects. See the *Regex-Core category on String.

For the syntax of Squeak regular expressions see: RxParser class>>#a:introduction: and the subsequent methods on RxParser class. For more involved usages of regular expressions see the Regex-Core class category.!
]style[(152 6 53 32 129),dString browse;;,,LRxParser class>>#a:introduction:;,!' readStream nextChunkText
]

{ #category : #pages }
SqueakUsefulCorePackagesHelp class >> squeakMap [
	"This method was automatically generated. Edit it using:"
	"SqueakUsefulCorePackagesHelp edit: #squeakMap"
	^HelpTopic
		title: 'SM'
		contents: 
'This package contains the model and the UI of SqueakMap, which is a catalogue for packages and applications in Squeak. You can access the SqueakMap catalog from the Apps menu item.

Information on how to use SqueakMap can be found here: http://wiki.squeak.org/squeak/2726

The server resides at http://map.squeak.org/
You can get an account to publish packages at http://map.squeak.org/newaccount!
]style[(237 34 24 22 47 32),Rhttp://wiki.squeak.org/squeak/2726;,,Rhttp://map.squeak.org/;,,Rhttp://map.squeak.org/newaccount;!' readStream nextChunkText
]

{ #category : #pages }
SqueakUsefulCorePackagesHelp class >> sunit [
	"This method was automatically generated. Edit it using:"
	"SqueakUsefulCorePackagesHelp edit: #sunit"
	^(HelpTopic
		title: 'SUnit and SUnitGUI'
		contents: 
'The SUnit package provides testing abstractions for unit tests. These comply to the XUnit testing model.

The common use case is to subclass TestCase. However, SUnit-Extensions also contains TestCases for special use cases. The rest of the API is explained in SUnit-Tests.

SUnitGUI contains the definition of the SUnit TestRunner which you can find in the world menu or the docking bar under Tools.!
]style[(141 8 250),Rcode://TestCase;,!' readStream nextChunkText)
			key: #sunit
]

{ #category : #pages }
SqueakUsefulCorePackagesHelp class >> toolBuilder [
	"This method was automatically generated. Edit it using:"
	"SqueakUsefulCorePackagesHelp edit: #toolBuilder"
	^(HelpTopic
		title: 'ToolBuilder'
		contents: 
'ToolBuilder provides means to describe graphical user interfaces independently from the actual graphics framework used (e.g. MVC or Morphic). Examples of tools built with it are the Debugger, the system browser, or the monticello repository browser.

To read about how to build tools start reading the ToolBuilder class comment.!
]style[(182 8 112 11 15)f1,dDebugger browse;;,f1,LToolBuilder Comment;,f1!' readStream nextChunkText)
			key: #toolBuilder
]

{ #category : #pages }
SqueakUsefulCorePackagesHelp class >> traitsPage [
	"This method was automatically generated. Edit it using:"
	"SqueakUsefulCorePackagesHelp edit: #traitsPage"
	^(HelpTopic
		title: 'Traits'
		contents: 
'Traits are an additional composition and reuse concept in Squeak allowing sideways composition of behavior. Traits are similar to MixIns. You can read about them here: http://scg.unibe.ch/archive/papers/Scha03aTraits.pdf!
]style[(168 52)f1,Rhttp://scg.unibe.ch/archive/papers/Scha03aTraits.pdf;!' readStream nextChunkText)
			key: #traitsPage
]

{ #category : #pages }
SqueakUsefulCorePackagesHelp class >> xml [
	"This method was automatically generated. Edit it using:"
	"SqueakUsefulCorePackagesHelp edit: #xml"
	^(HelpTopic
		title: 'XML'
		contents: 
'This package provides classes for parsing XML files. You can implement your own Parser by subclassing the XMLParser class.!
]style[(106 9 7)f1,dXMLParser browse;;,f1!' readStream nextChunkText)
			key: #xml
]
