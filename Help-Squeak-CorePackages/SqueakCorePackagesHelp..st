"
SqueakCorePackagesHelp is an attempt at gathering some important core classes together for the Help system; with the two subclasses it kinda-sorta pulls together the barest of package doc.
It's arguable whether this really works out very well; perhaps a better organisation can be found?
"
Class {
	#name : #SqueakCorePackagesHelp,
	#superclass : #CustomHelp,
	#category : #'Help-Squeak-CorePackages'
}

{ #category : #accessing }
SqueakCorePackagesHelp class >> bookName [

	^ 'Core Packages'
]

{ #category : #pages }
SqueakCorePackagesHelp class >> chronology [
	"This method was automatically generated. Edit it using:"
	"SqueakCorePackagesHelp edit: #chronology"
	^(HelpTopic
		title: 'Chronology'
		contents: 
'Everything related to time, time spans, durations, time stamps, etc. For the subtleties of the single classes read the class comments of: Duration, Timespan, and DateAndTime.
!
]style[(138 8 2 8 6 11 2),LDuration Comment;,,LTimespan Comment;,,LDateAndTime Comment;,!' readStream nextChunkText)
			key: #chronology
]

{ #category : #pages }
SqueakCorePackagesHelp class >> collections [
	"This method was automatically generated. Edit it using:"
	"SqueakCorePackagesHelp edit: #collections"
	^(HelpTopic
		title: 'Collections'
		contents: 
'Everything related to working with multiple objects such as Array, String (Collection of characters), Stream, Set, and Dictionary.!
]style[(60 5 2 6 29 6 2 3 6 10 1),dArray browse;;,,dString browse;;,,dStream browse;;,,dSet browse;;,,dDictionary browse;;,!' readStream nextChunkText)
			key: #collections
]

{ #category : #pages }
SqueakCorePackagesHelp class >> compiler [
	"This method was automatically generated. Edit it using:"
	"SqueakCorePackagesHelp edit: #compiler"
	^(HelpTopic
		title: 'Compiler'
		contents: 
'This package contains the Squeak Smalltalk compiler. It includes a Scanner, Parser, and Compiler. In order to restore source code from byte code., it also includes a Decompiler. !
]style[(67 7 2 6 6 8 70 10 2),dScanner browse;;,,dParser browse;;,,dCompiler browse;;,,dDecompiler browse;;,!' readStream nextChunkText)
			key: #compiler
]

{ #category : #pages }
SqueakCorePackagesHelp class >> files [
	"This method was automatically generated. Edit it using:"
	"SqueakCorePackagesHelp edit: #files"
	^(HelpTopic
		title: 'Files'
		contents: 
'The Files package provides access to the local file system through streams. It contains the FileDirectory class for listing and navigating folders.

Besides the usual synchronous API it also provides a AsyncFile class for asynchronous reading from files.!
]style[(92 14 96 9 43),dFileDirectory browse;;,,LAsyncFile Comment;,!' readStream nextChunkText)
			key: #files
]

{ #category : #pages }
SqueakCorePackagesHelp class >> graphics [
	"This method was automatically generated. Edit it using:"
	"SqueakCorePackagesHelp edit: #graphics"
	^(HelpTopic
		title: 'Graphics'
		contents: 
'This package includes core classes for Smalltalk graphic objects as well as facilities and applications for operating on graphic objects. Key classes include Form and BitBlt.

It further includes classes for rendering fonts and reading png, gif, or jpeg files.!
]style[(158 4 5 6 87),dForm browse;;,,dBitBlt browse;;,!' readStream nextChunkText)
			key: #graphics
]

{ #category : #pages }
SqueakCorePackagesHelp class >> kernel [
	"This method was automatically generated. Edit it using:"
	"SqueakCorePackagesHelp edit: #kernel"
	^HelpTopic
		title: 'Kernel'
		contents: 
'This package provides the most basic Smalltalk objects. It contains classes for: Code compilation, class (hierarchy) (re-)definition, basic exception handling, process scheduling and synchronization, user input events, and primitive types such as numbers and Boolean values.!' readStream nextChunkText
]

{ #category : #pages }
SqueakCorePackagesHelp class >> network [
	"This method was automatically generated. Edit it using:"
	"SqueakCorePackagesHelp edit: #network"
	^(HelpTopic
		title: 'Network'
		contents: 
'The network package provides means to fetch network resources. Includes support for UDP, TCP, HTTP, FTP, Telnet, SMTP, and POP3. Some of them are implemented as Sockets, others are implemented as Protocol clients. Additionally, it includes classes for handling URIs, Urls, email addresses, and UUIDs. 

If SqueakSSL is installed properly it can also provide HTTPS support.!
]style[(161 6 94 3 30 5 73),LSocket Hierarchy;,,LURI Comment;,,dUUID browse;;,!' readStream nextChunkText)
			key: #network
]

{ #category : #accessing }
SqueakCorePackagesHelp class >> pages [

	^ self class methodsInCategory: #pages
]

{ #category : #pages }
SqueakCorePackagesHelp class >> sound [
	"This method was automatically generated. Edit it using:"
	"SqueakCorePackagesHelp edit: #sound"
	^(HelpTopic
		title: 'Sound'
		contents: 
'The sound package manages audible output and reading various sound file formats. It includes support for FM, WAVE, and MIDI. It also includes classes for synthesizing sound. Try for example:
(AbstractSound majorScaleOn: PluckedSound default) play!
]style[(191 55),d(AbstractSound majorScaleOn: PluckedSound default) play;;!' readStream nextChunkText)
			key: #sound
]

{ #category : #pages }
SqueakCorePackagesHelp class >> system [
	"This method was automatically generated. Edit it using:"
	"SqueakCorePackagesHelp edit: #system"
	^(HelpTopic
		title: 'System'
		contents: 
'The System package includes classes dealing with code change notifications, object events, weak arrays and finalization, object serialization, and the concept of projects.

It also provides general system infrastructure such as the AppRegistry or classes for localization.

Additionally, it includes the SmalltalkImage class which can be accessed through Smalltalk.!
]style[(232 11 61 14 37 9 1),LAppRegistry Comment;,,LSmalltalkImage Comment;,,dSmalltalk inspect;;,!' readStream nextChunkText)
			key: #system
]
