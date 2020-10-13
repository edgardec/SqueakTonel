"
I represent the current image and runtime environment, including system organization, the virtual machine, object memory, plugins and source files. My instance variable #globals is a reference to the system dictionary of global variables and class names.

My singleton instance is called Smalltalk.
"
Class {
	#name : #SmalltalkImage,
	#superclass : #Object,
	#instVars : [
		'globals'
	],
	#classVars : [
		'EndianCache',
		'LastImageName',
		'LastQuitLogPosition',
		'LastStats',
		'LowSpaceProcess',
		'LowSpaceSemaphore',
		'MemoryHogs',
		'ShutDownList',
		'SourceFileVersionString',
		'StartUpList',
		'StartupStamp',
		'WordSize'
	],
	#category : #'System-Support'
}

{ #category : #'class initialization' }
SmalltalkImage class >> cleanUp [
	"Flush caches.  This used to flush obsolete classes from the compactClassesArray.  But Spur doesn't use compact classes so currently this method is empty."
]

{ #category : #'instance creation' }
SmalltalkImage class >> current [
	"Deprecated. Use Smalltalk instead."
	^Smalltalk
]

{ #category : #'class initialization' }
SmalltalkImage class >> initialize [
	"SmalltalkImage initialize"

	self initializeStartUpList.
	self initializeShutDownList.

]

{ #category : #'class initialization' }
SmalltalkImage class >> initializeShutDownList [
	"SmalltalkImage initialize"

	| oldList |
	oldList := ShutDownList.
	ShutDownList := OrderedCollection new.
	"These get processed from the bottom up..."
	#(
		Delay
		EventSensor
		Form
		StrikeFont
		Color
		FileDirectory
		SoundPlayer
		HttpUrl
		Password
		PWS
		MailDB
		ImageSegment
	) do:[:clsName|
		Smalltalk at: clsName ifPresent:[:cls| Smalltalk addToShutDownList: cls].
	].

	oldList ifNotNil: [oldList reverseDo: [:className | Smalltalk at: className
						ifPresent: [:theClass | Smalltalk addToShutDownList: theClass]]].

]

{ #category : #'class initialization' }
SmalltalkImage class >> initializeStartUpList [
	"SmalltalkImage initialize"
	
	| oldList |
	oldList := StartUpList.
	StartUpList := OrderedCollection new.
	"These get processed from the top down..."
	#(
		SmallInteger
		Delay
		Time
		DateAndTime
		Cursor
		EventSensor
		ProcessorScheduler  "Starts low space watcher and background."
		FileDirectory  "Enables file stack dump and opens sources."
		ShortIntegerArray
		ShortRunArray
	) do:[:clsName|
		Smalltalk at: clsName ifPresent:[:cls| Smalltalk addToStartUpList: cls].
	].
	oldList ifNotNil: [oldList do: [:className | Smalltalk at: className
						ifPresent: [:theClass | Smalltalk addToStartUpList: theClass]]].
	#(
		ImageSegment
		Project
		AutoStart
		ReleaseBuilder
	) do:[:clsName|
		Smalltalk at: clsName ifPresent:[:cls| Smalltalk addToStartUpList: cls].
	].

]

{ #category : #'instance creation' }
SmalltalkImage class >> new [

	self error: 'Use Smalltalk'.
]

{ #category : #'class initialization' }
SmalltalkImage class >> startUp: resuming [
	resuming ifTrue:
		[LastStats := nil.
		 SystemChangeNotifier uniqueInstance notify: Smalltalk ofAllSystemChangesUsing: #event:]
]

{ #category : #shrinking }
SmalltalkImage >> abandonSources [
	"Smalltalk abandonSources"
	"Replaces every method by a copy with the 4-byte source pointer 
	 replaced by a string of all arg and temp names, followed by its
	 length. These names can then be used to inform the decompiler."
	"wod 11/3/1998: zap the organization before rather than after
	 condensing changes."
	"eem 7/1/2009 13:59 update for the closure schematic temp names regime"
	| oldMethods newMethods bTotal bCount |
	(self confirm: 'This method will preserve most temp names
(up to about 15k characters of temporaries)
while allowing the sources file to be discarded.
-- CAUTION --
If you have backed up your system and
are prepared to face the consequences of
abandoning source code files, choose Yes.
If you have any doubts, you may choose No
to back out with no harm done.')
			== true
		ifFalse: [^ self inform: 'Okay - no harm done'].
	oldMethods := OrderedCollection new: CompiledMethod instanceCount.
	newMethods := OrderedCollection new: CompiledMethod instanceCount.
	bTotal := 0.
	bCount := 0.
	self systemNavigation allBehaviorsDo: [:b | bTotal := bTotal + 1].
	'Saving temp names for better decompilation...'
		displayProgressFrom: 0
		to: bTotal
		during:
			[:bar |
			self systemNavigation allBehaviorsDo:
				[:cl |  "for test: (Array with: Arc with: Arc class) do:"
				bar value: (bCount := bCount + 1).
				cl selectorsAndMethodsDo:
					[:selector :m |
					| oldCodeString methodNode |
					m fileIndex > 0 ifTrue:
						[oldCodeString := cl sourceCodeAt: selector.
						methodNode := cl newCompiler
											parse: oldCodeString
											in: cl
											notifying: nil.
						oldMethods addLast: m.
						newMethods addLast: (m copyWithTempsFromMethodNode: methodNode)]]]].
	oldMethods asArray elementsExchangeIdentityWith: newMethods asArray.
	self systemNavigation allBehaviorsDo: [:b | b zapOrganization].
	self condenseChanges.
	Preferences disable: #warnIfNoSourcesFile
]

{ #category : #shrinking }
SmalltalkImage >> abandonTempNames [
	"Replaces every method by a copy with no source pointer or
	encoded temp names."
	"Smalltalk abandonTempNames"
	| continue oldMethods newMethods n |
	continue := self confirm: '-- CAUTION --
If you have backed up your system and
are prepared to face the consequences of
abandoning all source code, hit Yes.
If you have any doubts, hit No,
to back out with no harm done.'.
	continue
		ifFalse: [^ self inform: 'Okay - no harm done'].
	self garbageCollect.
	oldMethods := OrderedCollection new.
	newMethods := OrderedCollection new.
	n := 0.
	'Removing temp names to save space...'
		displayProgressFrom: 0
		to: CompiledMethod instanceCount "This is just a rough guess."
		during: [:bar | self systemNavigation
			allBehaviorsDo: [:cl | cl methodsDo: [:m | 
				bar value: (n := n + 1).
				oldMethods addLast: m.
				newMethods
					addLast: (m copyWithTrailerBytes: CompiledMethodTrailer empty)]]].
	oldMethods asArray elementsExchangeIdentityWith: newMethods asArray.
	self closeSourceFiles.
	self flag: #shouldUseAEnsureBlockToBeSureThatTheFileIsClosed.
	"sd: 17 April 2003"
	Preferences disable: #warnIfNoChangesFile.
	Preferences disable: #warnIfNoSourcesFile
]

{ #category : #miscellaneous }
SmalltalkImage >> aboutThisSystem [ 
	"Identify software version"

	^self globals
		at: #SystemReporter
		ifPresent: [:sys | sys open]
		ifAbsent: [self inform: self systemInformationString withCRs]
]

{ #category : #'startup and shutdown list' }
SmalltalkImage >> add: aClass toList: startUpOrShutDownList after: predecessor [
	"Add the name of aClass to the startUp or shutDown list.
	Add it after the name of predecessor"

	(Smalltalk globals includes: aClass) 
		ifFalse: [self error: aClass name , ' cannot be found in Smalltalk dictionary.'].

	"Add after predecessor, moving it if already there."
	(Smalltalk globals includes: predecessor)  
		ifFalse: [self error: predecessor name , ' cannot be found in Smalltalk dictionary.'].
	(startUpOrShutDownList includes: predecessor name) 
		ifFalse: [self error: predecessor name , ' cannot be found in the list.'].
	startUpOrShutDownList remove: aClass name ifAbsent:[].
	startUpOrShutDownList add: aClass name after: predecessor name
]

{ #category : #'startup and shutdown list' }
SmalltalkImage >> add: aClass toList: startUpOrShutDownList before: successor [
	"Add the name of aClass to the startUp or shutDown list.
	Add it before the name of successor"

	(Smalltalk globals includes: aClass) 
		ifFalse: [self error: aClass name , ' cannot be found in Smalltalk dictionary.'].
		
	"Add before successor, moving it if already there."
	(Smalltalk globals includes: successor)  
		ifFalse: [self error: successor name , ' cannot be found in Smalltalk dictionary.'].
	(startUpOrShutDownList includes: successor name) 
		ifFalse: [self error: successor name , ' cannot be found in the list.'].
	startUpOrShutDownList remove: aClass name ifAbsent: [].
	startUpOrShutDownList add: aClass name before: successor name.
]

{ #category : #'startup and shutdown list' }
SmalltalkImage >> addToShutDownList: aClass [
	"This will add a ref to this class at the BEGINNING of the shutDown list."
	"No-op if already in the list."
	
	(ShutDownList includes: aClass name) ifFalse: [ShutDownList addFirst: aClass name]
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> addToShutDownList: aClass after: predecessor [

	self add: aClass toList: ShutDownList after: predecessor
]

{ #category : #'startup and shutdown list' }
SmalltalkImage >> addToShutDownList: aClass before: predecessor [

	self add: aClass toList: ShutDownList before: predecessor
]

{ #category : #'startup and shutdown list' }
SmalltalkImage >> addToStartUpList: aClass [
	"This will add a ref to this class at the END of the startUp list."
	"No-op if already in the list."

	(StartUpList includes: aClass name) ifFalse: [StartUpList addLast: aClass name]
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> addToStartUpList: aClass after: predecessor [

	self add: aClass toList: StartUpList after: predecessor
]

{ #category : #'startup and shutdown list' }
SmalltalkImage >> addToStartUpList: aClass before: predecessor [

	self add: aClass toList: StartUpList before: predecessor
]

{ #category : #'classes and traits' }
SmalltalkImage >> allClasses [  
	"Return all the class defined in the system"

	^globals allClasses
]

{ #category : #'classes and traits' }
SmalltalkImage >> allClassesAndTraits [
	"Return all the classes and traits defined in the system"

	^globals allClassesAndTraits
]

{ #category : #'classes and traits' }
SmalltalkImage >> allClassesAndTraitsDo: aBlock [
	"Evaluate the argument, aBlock, for each class and trait in the system."

	globals allClassesAndTraitsDo: aBlock
]

{ #category : #'classes and traits' }
SmalltalkImage >> allClassesDo: aBlock [
	"Evaluate the argument, aBlock, for each class in the system."

	globals allClassesDo: aBlock
]

{ #category : #'classes and traits' }
SmalltalkImage >> allTraits [
	"Return all traits defined in the system"

	^globals allTraits
]

{ #category : #'classes and traits' }
SmalltalkImage >> allTraitsDo: aBlock [
	"Evaluate the argument, aBlock, for each trait in the system."

	globals allTraitsDo: aBlock
]

{ #category : #'sources, changes log' }
SmalltalkImage >> appendChangesTo: sourcesName [

	"Condense changes to the end of the given sources file.
	If the file is the same as Smalltalk sourcesName, then just append
	the changes. If the file is different, then copy the sources file and
	append the changes afterwards."

	"Smalltalk appendChangesTo: 'test123.sources'"

	"To verify correctness of the operation run the following code:
	[	| sourceMap |
		sourceMap := Dictionary new.

		(CompiledMethod allInstances select:[:cm| cm isInstalled]) do:[:cm|
			sourceMap at: cm methodReference put: 
				(cm getSourceFor: cm selector in: cm methodClass)].
		Smalltalk allClassesAndTraitsDo:[:aClass|
			sourceMap at: aClass put: aClass comment].

		Smalltalk appendChangesTo: 'verify.sources'.

		(CompiledMethod allInstances select:[:cm| cm isInstalled]) do:[:cm|
			self assert: (sourceMap at: cm methodReference) =
				(cm getSourceFor: cm selector in: cm methodClass)].
		Smalltalk allClassesAndTraitsDo:[:aClass|
			self assert: (sourceMap at: aClass) = aClass comment].
	]"

	| fullName sourcesFile |
	fullName := FileDirectory default fullNameFor: sourcesName.
	(fullName endsWith: '.sources') ifFalse: [ fullName := fullName , '.sources' ].
	fullName = Smalltalk sourcesName ifFalse:[
		"Copy sources file; change file name accordingly"
		FileStream forceNewFileNamed: fullName do: [ :newFile |
			sourcesFile := (SourceFiles at: 1) readOnlyCopy.
			FileDirectory default copyFile: sourcesFile toFile: newFile.
			sourcesFile position: 0 ].
		self setMacFileInfoOn: fullName.
		"Change to the new sources file and reopen"
		self 
			closeSourceFiles ;
			sourceFileVersionString: ((FileDirectory localNameFor: fullName) allButLast: '.sources' size) ;
			openSourceFiles.
	].

	"We've copied the old to the new sources file; reopen the sources file read/write"
	sourcesFile := SourceFiles at: 1.
	sourcesFile close; open: sourcesFile fullName forWrite: true. "should be openReadWrite"
	sourcesFile setToEnd; timeStamp "remember when we did this".

	"Copy method sources from changes to sources"
	CompiledMethod allInstances do:[:method|
		(method isInstalled and:[method fileIndex = 2]) ifTrue:[
			| class selector category preamble changeList index chgRec string source |
			class := method methodClass.
			selector := method selector.
			source := class sourceCodeAt: selector.
			category := class organization categoryOfElement: selector.
			preamble := class name, ' methodsFor: ', category asString printString,
							' stamp: ', method timeStamp printString.

			"Find the last version in the sources file; link up the prior: version"
			changeList := ChangeSet scanVersionsOf: method 
				class: class meta: class isMeta category: category  selector: selector.
			index := changeList findLast:[:any| any fileIndex = 1].
			index > 0 ifTrue:[
				chgRec := changeList at: index.
				preamble := preamble, ' prior: ', (SourceFiles 
					sourcePointerFromFileIndex: chgRec fileIndex 
					andPosition: chgRec position) printString].

			"append to sources file"
			sourcesFile setToEnd; cr; nextPut: $!; nextChunkPut: preamble; cr.
			string := RemoteString newString: source onFileNumber: 1 toFile: sourcesFile.
			sourcesFile nextChunkPut: ' '.
			method setSourcePosition: string position inFile: 1
		].
	] displayingProgress: 'Moving changes...'.

	"Copy class comments from changes to sources"
	self  allClassesAndTraitsDo: [:classOrTrait | 
		classOrTrait moveClassCommentTo: sourcesFile fileIndex: 1.
	].

	"We've moved everything; reopen the source files"
	self closeSourceFiles; openSourceFiles.

	"Former changes are now in .sources, no need for them in .changes.  Condense them."
	self condenseChanges
]

{ #category : #'command line' }
SmalltalkImage >> argumentAt: argumentIndex [ 
	"Answer the i-th argument of the command line, or nil if not so many argument."
	^ self arguments at: argumentIndex ifAbsent: [].

]

{ #category : #'command line' }
SmalltalkImage >> arguments [
	"Answer an array with all the command line arguments.
	This does not include imagePath, documentPath nor any option."
	
	"Smalltalk commandLine arguments"
	
	| args strm |
	args := self rawArguments.
	(args includes: '--')
		ifTrue: [ ^args copyAfter: self imageArgumentsMarker ].
	strm := args readStream.
	strm atEnd ifFalse: [ strm next. "skip image name"
		(Preferences readDocumentAtStartup and: [ strm atEnd not ])
			ifTrue: [ strm next "skip startup document name" ]].
	^ strm upToEnd.

]

{ #category : #'dictionary access' }
SmalltalkImage >> associationAt: aKey [
	"DO NOT DEPRECATE - used by ImageSegments"

	^globals associationAt: aKey
]

{ #category : #'dictionary access' }
SmalltalkImage >> associationAt: key ifAbsent: aBlock [
	"Obsoleted."

	self deprecated: 'Use Smalltalk globals'.
	^globals associationAt: key ifAbsent: aBlock
]

{ #category : #'dictionary access' }
SmalltalkImage >> associationDeclareAt: aKey [
	"DO NOT DEPRECATE - used by ImageSegments"
	self flag: #environments.
	^globals associationDeclareAt: aKey
]

{ #category : #'dictionary access' }
SmalltalkImage >> associationOrUndeclaredAt: aKey [
	"DO NOT DEPRECATE - used by binary storage"

	^globals associationOrUndeclaredAt: aKey
]

{ #category : #'sources, changes log' }
SmalltalkImage >> assureStartupStampLogged [
	"If there is a startup stamp not yet actually logged to disk, do it now."
	| changesFile |
	StartupStamp ifNil: [^ self].
	(SourceFiles isNil or: [(changesFile := SourceFiles at: 2) == nil]) ifTrue: [^ self].
	changesFile isReadOnly ifTrue:[^self].
	changesFile setToEnd; cr; cr.
	changesFile nextChunkPut: StartupStamp asString; cr.
	StartupStamp := nil.
	self forceChangesToDisk.
]

{ #category : #accessing }
SmalltalkImage >> at: aKey [
	"Answer the global associated with the key."

	^globals at: aKey
]

{ #category : #accessing }
SmalltalkImage >> at: key ifAbsent: aBlock [
	"Answer the global associated with the key or, if key isn't found,
	answer the result of evaluating aBlock."

	^globals at: key ifAbsent: aBlock
]

{ #category : #accessing }
SmalltalkImage >> at: aKey ifAbsentPut: aBlock [ 
	"Return the global at the given key. 
	If key is not included in the receiver store the result 
	of evaluating aBlock as new value."

	^globals at: aKey ifAbsentPut: aBlock
]

{ #category : #accessing }
SmalltalkImage >> at: key ifPresent: aBlock [
	"Lookup the given key in the globals. If it is present, answer the value of evaluating the given block with the value associated with the key. Otherwise, answer nil."

	^globals at: key ifPresent: aBlock
]

{ #category : #accessing }
SmalltalkImage >> at: key ifPresent: aBlock ifAbsent: anotherBlock [
	"Lookup the given key in the globals. If it is present, answer the value of evaluating the given block with the value associated with the key. Otherwise, evaluate anotherBlock and answer its result."
	
	^globals at: key ifPresent: aBlock ifAbsent: anotherBlock
]

{ #category : #accessing }
SmalltalkImage >> at: key ifPresentAndInMemory: aBlock [
	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the given block with the value associated with the key. Otherwise, answer nil."

	^globals at: key ifPresentAndInMemory: aBlock
]

{ #category : #accessing }
SmalltalkImage >> at: aKey put: anObject [ 
	"Set the global at key to be anObject.  If key is not found, create a
	new entry for key and set is value to anObject. Answer anObject."

	^globals at: aKey put: anObject
]

{ #category : #accessing }
SmalltalkImage >> bindingOf: varName [
	"Answer the binding of some variable resolved in the scope of the receiver"

	^globals bindingOf: varName
]

{ #category : #'system attributes' }
SmalltalkImage >> buildDate [			
	"Return a String reflecting the build date of the VM"
	"Smalltalk buildDate"

	^self getSystemAttribute: 1006
]

{ #category : #'memory space' }
SmalltalkImage >> bytesLeft [
	"Answer the number of bytes of space available. Does a full garbage collection."

	self garbageCollect.
	^self bytesLeft: true
]

{ #category : #'memory space' }
SmalltalkImage >> bytesLeft: aBool [
	"Return the amount of available space. If aBool is true, include possibly available swap space.
	 If aBool is false, include possibly available physical memory. For a report on the largest free
	 block currently available within Squeak memory but not counting extra memory use #primBytesLeft."
	<primitive: 112>
	^self primBytesLeft
]

{ #category : #'memory space' }
SmalltalkImage >> bytesLeftString [
	"Answer a string describing the amount of memory available."
	"Smalltalk bytesLeftString"
	| largestFree availInternal availPhysical availTotal |
	largestFree := self garbageCollect.
	availInternal := self primBytesLeft.
	availPhysical := self bytesLeft: false.
	availTotal := self bytesLeft: true.
	(availTotal > (availInternal + 10000)) "compensate for mini allocations inbetween"
		ifFalse:[^availInternal asStringWithCommas, ' bytes available'].
	^String streamContents:
		[:s|
		{availInternal. availPhysical. largestFree. availTotal}
			with: #('old space' 'physical' 'largest free chunk' 'total')
			do: [:value :name|
				s nextPutAll: value asStringWithCommas; nextPutAll: ' bytes ('; nextPutAll: name; nextPutAll: ') '; cr]]
]

{ #category : #'system attributes' }
SmalltalkImage >> calcEndianness [
	"What endian-ness is the current hardware?  The String '1234' will be stored into a machine word.  On BigEndian machines (the Mac), $1 will be the high byte if the word.  On LittleEndian machines (the PC), $4 will be the high byte."
	"Smalltalk endianness"
	| wordThenBytes |
	wordThenBytes := WordArray with: 16r01020304.
	ByteArray adoptInstance: wordThenBytes.
	wordThenBytes first = 1 ifTrue: [^#big].
	wordThenBytes first = 4 ifTrue: [^#little].
	self error: 'The author is confused'
]

{ #category : #'image, changes names' }
SmalltalkImage >> changeImageNameTo: aString [
	
	self imageName: aString asSqueakPathName.
	LastImageName := self imageName
]

{ #category : #'image, changes names' }
SmalltalkImage >> changesName [
	"Answer the name for the changes file corresponding to the image file name."
	"Smalltalk changesName"

	| imName |
	imName := FileDirectory baseNameFor: self imageName.
	^ imName, FileDirectory dot, 'changes'
]

{ #category : #'classes and traits' }
SmalltalkImage >> classNamed: className [ 
	"Answer the global with the given name."

	^globals classNamed: className
]

{ #category : #'classes and traits' }
SmalltalkImage >> classNames [
	"Answer a collection of all class names in the system."

	^globals classNames
]

{ #category : #'classes and traits' }
SmalltalkImage >> classOrTraitNamed: aString [
	"Answer the global with the given name"

	^globals classOrTraitNamed: aString
]

{ #category : #housekeeping }
SmalltalkImage >> cleanOutUndeclared [ 
	"This should be deprecated, and senders rewritten to deal with environments directly"
	self flag: #environments.
	
	globals purgeUndeclared.
]

{ #category : #housekeeping }
SmalltalkImage >> cleanUp [	"Smalltalk cleanUp"
	"Gently clean up"
	^self cleanUp: false
]

{ #category : #housekeeping }
SmalltalkImage >> cleanUp: aggressive [
	"Clean up. When aggressive is true, this will destroy projects, change sets, etc."
	"Smalltalk cleanUp: false"
	"Smalltalk cleanUp: true"

	^self cleanUp: aggressive except: #()
]

{ #category : #housekeeping }
SmalltalkImage >> cleanUp: aggressive except: exclusions [ 
	"Clean up. When aggressive is true, this will destroy projects, change sets, etc.
	Leave out any classes specifically listed in exclusions."
	"Smalltalk cleanUp: true except: {Project. ChangeSet}"
	"Find all classes implementing #cleanUp or cleanUp:"
	| classes |
	classes := Smalltalk allClasses select:
		[ : eachClass | (eachClass class includesSelector: #cleanUp) or:
			[ (eachClass class includesSelector: #cleanUp:) and: [ (exclusions includes: eachClass) not ] ] ].
	"Arrange classes in superclass order, superclasses before subclasses, so that specific cleanup (like MethodDictionary compaction) will run after generic superclass cleanup (HashedCollection rehashing). Otherwise generic superclass cleanup might undo specific one (in this case rehashing will undo a good bit of MD compaction)."
	(ChangeSet superclassOrder: classes)
		do: [ : aClass | aClass cleanUp: aggressive ]
		displayingProgress: [ : aClass | 'Cleaning up in ' , aClass name ]
]

{ #category : #'external objects' }
SmalltalkImage >> clearExternalObjects [
	"Clear the array of objects that have been registered for use in non-Smalltalk code."
	"Smalltalk clearExternalObjects"

	ExternalObjectTable current clearExternalObjects

]

{ #category : #'vm profiling' }
SmalltalkImage >> clearProfile [
	"Clear the profile database."

	<primitive: 250>

]

{ #category : #'sources, changes log' }
SmalltalkImage >> closeSourceFiles [
	"Shut down the source files if appropriate.  1/29/96 sw: changed so that the closing and nilification only take place if the entry was a FileStream, thus allowing stringified sources to remain in the saved image file"

	1 to: 2 do: [:i |
		((SourceFiles at: i) isKindOf: FileStream)
			ifTrue:
				[(SourceFiles at: i) close.
				SourceFiles at: i put: nil]]
]

{ #category : #vm }
SmalltalkImage >> cogitClass [
	^self getSystemAttribute: 1008
]

{ #category : #'command line' }
SmalltalkImage >> commandLine [
	"Answer the object to query about command line."
	
	^self
]

{ #category : #'special objects' }
SmalltalkImage >> compactClassesArray [
	"Smalltalk compactClassesArray"
	"Backward-compatibility support.  Spur does not have compact classes."
	^{}
]

{ #category : #housekeeping }
SmalltalkImage >> compressSources [	
	"Copy all the source file to a compressed file. Usually preceded by Smalltalk condenseSources."
	"The new file will be created in the default directory, and the code in openSources
	will try to open it if it is there, otherwise it will look for normal sources."
	"Smalltalk compressSources"

	| f cfName cf |
	f := SourceFiles first readOnlyCopy binary.	"binary to preserve utf8 encoding"
	(f localName endsWith: 'sources')
		ifTrue: [cfName := (f localName allButLast: 7) , 'stc']
		ifFalse: [self error: 'Hey, I thought the sources name ended with ''.sources''.'].
	cf := (CompressedSourceStream on: (FileStream newFileNamed: cfName))
				segmentSize: 65536 maxSize: f size.

	"Copy the sources"
'Compressing Sources File...'
	displayProgressFrom: 0 to: f size
	during:
		[:bar | f position: 0.
		[f atEnd] whileFalse:
			[cf nextPutAll: (f next: 65536).
			bar value: f position]].
	cf close.
	self setMacFileInfoOn: cfName.
	self inform: 'You now have a compressed sources file!
Squeak will use it the next time you start.'
]

{ #category : #housekeeping }
SmalltalkImage >> condenseChanges [
	"Move all the changes onto a compacted sources file."
	"Smalltalk condenseChanges"
	| f oldChanges |
	f := FileStream fileNamed: 'ST80.temp'.
	f header; timeStamp.
	'Condensing Changes File...'
		displayProgressFrom: 0
		to: self classNames size + self traitNames size
		during: [:bar | | count | 
			count := 0.
			self
				allClassesAndTraitsDo: [:classOrTrait | 
					bar value: (count := count + 1).
					classOrTrait moveChangesTo: f.
					classOrTrait putClassCommentToCondensedChangesFile: f.
					classOrTrait classSide moveChangesTo: f]].
	self lastQuitLogPosition: f position.
	f trailer; close.
	oldChanges := SourceFiles at: 2.
	oldChanges close.
	FileDirectory default deleteFileNamed: oldChanges name , '.old';
		 rename: oldChanges name toBe: oldChanges name , '.old';
		 rename: f name toBe: oldChanges name.
	self setMacFileInfoOn: oldChanges name.
	SourceFiles
		at: 2
		put: (FileStream oldFileNamed: oldChanges name)
]

{ #category : #housekeeping }
SmalltalkImage >> condenseSources [
	"Move all the changes onto a compacted sources file."
	"Smalltalk condenseSources"

	| newSourcesFile defaultDirectory newVersion currentVersion |
	Utilities fixUpProblemsWithAllCategory.
	"The above removes any concrete, spurious '-- all --' categories, which mess up the process."
	defaultDirectory := FileDirectory default.
	currentVersion := self sourceFileVersionString.
	newVersion := UIManager default 
		request: 'Please designate the version\for the new source code file...' withCRs
		initialAnswer: currentVersion.
	newVersion ifEmpty: [ ^ self ].
	newVersion = currentVersion ifTrue: [ ^ self error: 'The new source file must not be the same as the old.' ].
	self sourceFileVersionString: newVersion.

	"Write all sources with fileIndex 1"
	newSourcesFile := defaultDirectory newFileNamed: (defaultDirectory localNameFor: self sourcesName).
	newSourcesFile ifNil: [ ^ self error: 'Couldn''t create source code file in\' withCRs,  defaultDirectory name].
	newSourcesFile
		header;
		timeStamp.
	'Condensing Sources File...' 
		displayProgressFrom: 0
		to: self classNames size + self traitNames size
		during: 
			[ :bar | 
			| count |
			count := 0.
			Smalltalk allClassesAndTraitsDo: 
				[ :classOrTrait | 
				bar value: (count := count + 1).
				classOrTrait 
					fileOutOn: newSourcesFile
					moveSource: #historically
					toFile: 1 ] ].
	newSourcesFile
		trailer;
		close.
		
	"Make a new empty changes file"
	self closeSourceFiles.
	defaultDirectory 
		rename: self changesName
		toBe: self changesName , '.old'.
	(FileStream newFileNamed: self changesName)
		header;
		timeStamp;
		close.
	self lastQuitLogPosition: 0.
	self setMacFileInfoOn: self changesName.
	self setMacFileInfoOn: newSourcesFile name.
	self openSourceFiles.
	self inform: 'Source files have been rewritten to\' withCRs, newSourcesFile name, '\Check that all is well,\and then save/quit.' withCRs
]

{ #category : #'sources, changes log' }
SmalltalkImage >> copyright [
	"The Smalltalk copyright."

	^'Copyright (c) Xerox Corp. 1981, 1982 All rights reserved.
Copyright (c) Apple Computer, Inc. 1985-1996 All rights reserved.'
]

{ #category : #'memory space' }
SmalltalkImage >> createStackOverflow [
	"For testing the low space handler..."
	"Smalltalk installLowSpaceWatcher; createStackOverflow"

	self createStackOverflow.  "infinite recursion"
]

{ #category : #'image, changes names' }
SmalltalkImage >> currentChangeSetString [
	"Smalltalk currentChangeSetString"
	^ 'Current Change Set: ' translated, ChangeSet current name
]

{ #category : #miscellaneous }
SmalltalkImage >> currentProjectDo: aBlock [ 
	"So that code can work after removal of Projects"
	self
		at: #Project
		ifPresent: [:projClass | aBlock value: projClass current]
]

{ #category : #'sources, changes log' }
SmalltalkImage >> datedVersion [
	"Answer the version of this release."

	^SystemVersion current datedVersion
]

{ #category : #'command line' }
SmalltalkImage >> documentPath [
	"Answer the absolute path of the document passed to the VM or nil if none."
	"Smalltalk commandLine documentPath"
	^ (self getSystemAttribute: 2)
		ifNotNil: [ :arg | arg = self imageArgumentsMarker
			ifTrue: [nil] ifFalse: [arg]].


]

{ #category : #miscellaneous }
SmalltalkImage >> dumpException: ex [

	self 
		logSqueakError: ex description 
		inContext: ex signalerContext .

]

{ #category : #miscellaneous }
SmalltalkImage >> dumpException: ex to: aFilename [

	self 
		logError: ex description 
		inContext: ex signalerContext
		to: aFilename

]

{ #category : #'vm profiling' }
SmalltalkImage >> dumpProfile [
	"Dump the profile database to a file."

	<primitive: 251>

]

{ #category : #'system attributes' }
SmalltalkImage >> endianness [
	^EndianCache ifNil: [EndianCache := self calcEndianness]
]

{ #category : #accessing }
SmalltalkImage >> environment [
	"For conversion from Smalltalk to SystemDictionary"

	^globals
]

{ #category : #'sources, changes log' }
SmalltalkImage >> event: anEvent [
	"Hook for SystemChangeNotifier"

	anEvent isDoIt ifTrue: [^self logChange: anEvent item].
	(anEvent itemKind = SystemChangeNotifier categoryKind) ifTrue: [
		anEvent isAdded
			ifTrue: [^self logChange: 'SystemOrganization addCategory: ', anEvent item storeString].
		anEvent isRemoved
			ifTrue: [^self logChange: 'SystemOrganization removeSystemCategory: ', anEvent item storeString].
		anEvent isRenamed
			ifTrue: [^self logChange: 'SystemOrganization renameCategory: ', anEvent oldName storeString, ' toBe: ', anEvent newName storeString].
	].

	(anEvent itemKind = SystemChangeNotifier classKind) ifTrue: [
		anEvent item acceptsLoggingOfCompilation ifFalse: [^self].
		anEvent isAdded ifTrue: [
			self logChange: anEvent item definition.
		].
		anEvent isModified
			ifTrue: [^self logChange: anEvent item definition].
		anEvent isRemoved
			ifTrue: [^self logChange: 'Smalltalk removeClassNamed: ' , anEvent item name storeString].
		anEvent isRenamed
			ifTrue: [^self logChange: 'Smalltalk renameClassNamed: ', anEvent oldName storeString, ' as: ', anEvent newName storeString].
		anEvent isRecategorized
			ifTrue: [^self logChange: 'SystemOrganization classify: ', anEvent item name storeString, ' under: ', anEvent itemCategory storeString].
	].

	(anEvent itemKind = SystemChangeNotifier protocolKind) ifTrue: [
		anEvent isAdded
			ifTrue: [^self logChange: anEvent itemClass name , ' organization addCategory: ' , anEvent itemProtocol storeString].
		anEvent isRemoved
			ifTrue: [^self logChange: anEvent itemClass name , ' organization removeCategory: ' , anEvent itemProtocol storeString].
		anEvent isRenamed
			ifTrue: [^self logChange: anEvent itemClass name , ' organization renameCategory: ' , anEvent oldName storeString, ' toBe: ', anEvent newName storeString].
	].

	(anEvent itemKind = SystemChangeNotifier methodKind) ifTrue: [
		anEvent itemClass acceptsLoggingOfCompilation ifFalse: [^self].
		anEvent isRemoved
			ifTrue: [^self logChange: anEvent itemClass name , ' removeSelector: ' , anEvent itemSelector storeString].
		anEvent isRecategorized
			ifTrue: [
				^self logChange: anEvent itemClass name , ' organization classify: ', anEvent itemSelector storeString, ' under: ', anEvent itemProtocol storeString.
		].
	].
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> exitToDebugger [
	"Primitive. Enter the machine language debugger, if one exists. Essential.
	See Object documentation whatIsAPrimitive. This primitive is to access the
	debugger when debugging the vm or a plugging in C"

	<primitive: 114>
	self primitiveFailed
]

{ #category : #'external objects' }
SmalltalkImage >> externalObjects [
	"Return an array of objects that have been registered for use in non-Smalltalk code. Smalltalk objects should be referrenced by external code only via indirection through this array, thus allowing the objects to move during compaction. This array can be cleared when the VM re-starts, since variables in external code do not survive snapshots. Note that external code should not attempt to access a Smalltalk object, even via this mechanism, while garbage collection is in progress."
	"Note that this is just a copy of the array used by the VM."
	"Smalltalk externalObjects"

	^ExternalObjectTable current externalObjects

]

{ #category : #'vm parameters' }
SmalltalkImage >> extraVMMemory [
	"Answer the current setting of the 'extraVMMemory' VM parameter. See the comment in extraVMMemory: for details."

	^ self vmParameterAt: 23

]

{ #category : #'vm parameters' }
SmalltalkImage >> extraVMMemory: extraBytesToReserve [
	"Request that the given amount of extra memory be reserved for use by the virtual machine to leave extra C heap space available for things like plugins, network and file buffers, and so on. This request is stored when the image is saved and honored when the image is next started up. Answer the previous value of this parameter."

	extraBytesToReserve < 0
		ifTrue: [self error: 'VM memory reservation must be non-negative'].
	^ self vmParameterAt: 23 put: extraBytesToReserve

]

{ #category : #'command line' }
SmalltalkImage >> extractParameters [
self deprecated: 'Use #namedArguments'.
	^ self namedArguments
]

{ #category : #housekeeping }
SmalltalkImage >> fixObsoleteReferences [
	"Smalltalk fixObsoleteReferences"
	

	Smalltalk garbageCollect; garbageCollect.

	Preference allInstances do: [:each || informee realName newInformee | 
		informee := each instVarNamed: #changeInformee.
		((informee isKindOf: Behavior)
			and: [informee isObsolete])
			ifTrue: [
				Transcript show: 'Preference: '; show: each name; cr.
				realName := (informee name copyReplaceAll: 'AnObsolete' with: '') asSymbol.
				newInformee := (informee environment declarationOf: realName) value.
				each instVarNamed: #changeInformee put: newInformee]].
 
	CompiledMethod allInstances do: [:method |
		| obsoleteBindings |
		obsoleteBindings := method literals select: [:literal |
			literal isVariableBinding
				and: [literal value isBehavior
				and: [literal value isObsolete]]].
		obsoleteBindings do: [:binding |
			| obsName realName realClass |
			obsName := binding value name.
			Transcript show: 'Binding: '; show: obsName; cr.
			realName := obsName copyReplaceAll: 'AnObsolete' with: ''.
			realClass := Smalltalk at: realName asSymbol ifAbsent: [UndefinedObject].
			binding isSpecialWriteBinding
				ifTrue: [binding privateSetKey: binding key value: realClass]
				ifFalse: [binding key: binding key value: realClass]]].

	Behavior flushObsoleteSubclasses.
	Smalltalk garbageCollect; garbageCollect.
	

]

{ #category : #'system attributes' }
SmalltalkImage >> flagInterpretedMethods: aBoolean [
	"The Cog VM can be instructed to set the flag bit of CompiledMethods that
	 it executes but will only interpret.  This can be used e.g. to profile startup.
	 See CompiledMethod>>#flag & CompiledMethod>>#clearFlag.  
	 This flag persists across snapshots, stored in the image header."

	self vmParameterAt: 48 put: ((self vmParameterAt: 48) bitClear: 2) + (aBoolean ifTrue: [2] ifFalse: [0])
]

{ #category : #'classes and traits' }
SmalltalkImage >> flushClassNameCache [
	"Forse recomputation of the cached list of class names."

	^globals flushClassNameCache
]

{ #category : #'sources, changes log' }
SmalltalkImage >> forceChangesToDisk [
	"Ensure that the changes file has been fully written to disk by closing and re-opening it. This makes the system more robust in the face of a power failure or hard-reboot."

	| changesFile |
	changesFile := SourceFiles at: 2.
	(changesFile isKindOf: FileStream) ifTrue: [
		changesFile flush.
		SecurityManager default hasFileAccess ifTrue:[
			changesFile close.
			changesFile open: changesFile name forWrite: true].
		changesFile setToEnd.
	].

]

{ #category : #'memory space' }
SmalltalkImage >> forceTenure [
	"Primitive. Tell the GC logic to force a tenure on the next increment GC."
	<primitive: 'primitiveForceTenure'>
	^self primitiveFailed
]

{ #category : #'classes and traits' }
SmalltalkImage >> forgetClass: aClass logged: aBool [ 
	"Delete the class, aClass, from the system."

	^globals forgetClass: aClass logged: aBool
]

{ #category : #modules }
SmalltalkImage >> forgetModule: aString [
	"Primitive. If the module named aString is loaded, unloaded. If not, and it is marked an unloadable, unmark it so the VM will try to load it again next time. See comment for #unloadModule:."
	<primitive: 571>
	^self primitiveFailed
]

{ #category : #'vm statistics' }
SmalltalkImage >> formatVMParameter: aNumber [
	"Format a VM parameter that may have been reported either as a Float or
	an Integer. If a VM parameter is defined in units of milliseconds but internally
	measured to microsecond precision by the VM, the VM may choose to return
	the value as a Float in order to retain full precision. Otther representations
	such as Fraction may seem more natural but are difficult to instantiate in
	the VM, hence the presumption of Float for representation of higher precision
	millisecond values."

	^ aNumber isFloat
		ifTrue: [ aNumber < 1000
			ifTrue: [ aNumber printShowingMaxDecimalPlaces: 5 ]
			ifFalse: [ aNumber rounded asStringWithCommas ] ]
		ifFalse: [ aNumber asInteger asStringWithCommas ].
]

{ #category : #'image, changes names' }
SmalltalkImage >> fullNameForChangesNamed: aName [
	| imgName |
	imgName := self fullNameForImageNamed: aName.
	^FileDirectory fileName: (FileDirectory baseNameFor: imgName) extension: FileDirectory changeSuffix.
]

{ #category : #'image, changes names' }
SmalltalkImage >> fullNameForImageNamed: aName [
	| imgDir |
	imgDir := FileDirectory on: self imagePath.
	^FileDirectory fileName: (imgDir fullNameFor: aName) extension: FileDirectory imageSuffix.
]

{ #category : #'memory space' }
SmalltalkImage >> garbageCollect [
	"Reclaims all garbage and answers the number of bytes of available space in the largest free chunk."
	Object flushDependents.
	EventManager flushEvents.
	^self primitiveGarbageCollect
]

{ #category : #'memory space' }
SmalltalkImage >> garbageCollectMost [
	"Primitive. Reclaims recently created garbage (which is usually most of it) fairly quickly and answers the number of bytes of available space."

	<primitive: 131>
	^ self primBytesLeft
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> getFileNameFromUser [
	"Ask the user for a new image name"
	^self getFileNameFromUserSuggesting: (FileDirectory localNameFor: self imageName)
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> getFileNameFromUserSuggesting: aName [
	"Ask the user for a new image name"
	| newName |
	newName := UIManager default
		saveFilenameRequest: 'Save Image as new name...' translated
		initialAnswer: aName.
	newName ifNil: [^nil].
	((FileDirectory default fileOrDirectoryExists: (self fullNameForImageNamed: newName)) or:
	 [FileDirectory default fileOrDirectoryExists: (self fullNameForChangesNamed: newName)]) ifTrue: [
		(self confirm: ('{1} already exists. Overwrite?' translated format: {newName})) ifFalse: [^nil]].
	^newName

]

{ #category : #private }
SmalltalkImage >> getSystemAttribute: attributeID [ 
	"Optional. Answer the string for the system attribute with the given 
	integer ID. Answer nil if the given attribute is not defined on this 
	platform. On platforms that support invoking programs from command 
	lines (e.g., Unix), this mechanism can be used to pass command line 
	arguments to programs written in Squeak.

	By convention, the first command line argument that is not a VM
	configuration option is considered a 'document' to be filed in. Such a
	document can add methods and classes, can contain a serialized object,
	can include code to be executed, or any combination of these.

	Currently defined attributes include: 
	-1000	1000th command line argument that specify VM options
	...
	-1		first command line argument that specify VM options
	0		the full path name for currently executing VM
			(or, on some platforms, just the path name of the VM's directory) 
	1		full path name of this image (better use primImageName instead)
	2		first command-line argument for Squeak programs.
			Note: if Preferences readDocumentAtStartup is set, this first argument is treated as a URL to a Squeak document to open.
	3		second command-line argument for Squeak programs
	...
	1000	1000th command line argument for Squeak programs
	1001	this platform's operating system 'Mac OS', 'Win32', 'unix', ...
	1002	operating system version
	1003	this platform's processor type
	1004	vm version
	1005	window system name
	1006	vm build id
	1007	Interpreter class (Cog VM only)
	1008	Cogit class (Cog VM only)
	1009	Platform source version (Cog VM only?)
	1201	max filename length (Mac OS only)
	1202	file last error (Mac OS only)
	10001	hardware details (Win32 only)
	10002	operating system details (Win32 only)
	10003	graphics hardware details (Win32 only)
	"

	<primitive: 149>
	^ nil
]

{ #category : #'vm parameters' }
SmalltalkImage >> getVMParameters [	
	"Answer an Array containing the current values of the VM's internal
	parameter/metric registers.  Each value is stored in the array at the
	index corresponding to its VM register.  (See #vmParameterAt: and
	#vmParameterAt:put:.)"
	"Smalltalk getVMParameters"
	
	<primitive: 254>
	self primitiveFailed
]

{ #category : #accessing }
SmalltalkImage >> globals [
	"Answer the global SystemDictionary"

	^globals
]

{ #category : #accessing }
SmalltalkImage >> globals: aSystemDictionary [
	"Sets the system-wide globals"

	globals ifNotNil:[self error: 'Cannot overwrite existing globals'].
	globals := aSystemDictionary
]

{ #category : #'memory space' }
SmalltalkImage >> growMemoryByAtLeast: numBytes [
	"Grow memory by at least the requested number of bytes.
	 Primitive.  Fail if no memory is available.  Essential.
	 N.B. In Spur, the heap is composed of segments. Growing memory adds a new
	 segment; it does not extend existing segments. Growth is by at least that
	 established by SmalltalkImage current vmParameterAt: 25, which defaults to 16Mb."
	<primitive: 180>
	^(numBytes isInteger and: [numBytes > 0])
		ifTrue: [OutOfMemory signal]
		ifFalse: [self primitiveFailed]
]

{ #category : #miscellaneous }
SmalltalkImage >> handleUserInterrupt [
	[ToolSet handleUserInterruptRequest: 'User Interrupt'] fork.
]

{ #category : #'classes and traits' }
SmalltalkImage >> hasClassNamed: aString [
	"Answer whether there is a class of the given name"

	^globals hasClassNamed: aString
]

{ #category : #miscellaneous }
SmalltalkImage >> hasMorphic [
	"Answer whether the Morphic classes are available in the
	system (they may have been stripped, such as by a call to
	Smalltalk removeMorphic"
	^ (self
		at: #Morph
		ifAbsent: [])
		isKindOf: Class
]

{ #category : #image }
SmalltalkImage >> image [
	"Answer the object to query about the current object memory and execution environment."
	
	^self
]

{ #category : #'command line' }
SmalltalkImage >> imageArgumentsMarker [
	"The '--' token on the command line indicates that remaining arguments should
	be passed to the image without interpretation, and should not be treated as e.g.
	specification of a start script." 

	^ '--'
]

{ #category : #image }
SmalltalkImage >> imageFormatVersion [
	"Answer an integer identifying the type of image in memory. The image version number may
	identify the format of the image (e.g. 32 or 64-bit word size) or specific requirements
	of the image (e.g. block closure support required). This invokes an optional primitive
	that may not be available on all virtual machines."

	"Smalltalk image imageFormatVersion"

	<primitive: 'primitiveImageFormatVersion'>

	"Cog provides a VM parameter"
	^[Smalltalk vm vmParameterAt: 41]
		on: Error
		do: [self notify: 'This virtual machine does not support the optional ',
				'primitive #primitiveImageFormatVersion' translated.
			nil]

]

{ #category : #image }
SmalltalkImage >> imageFormatVersionFromFile [
	"Answer an integer identifying the type of image on file. The image version number may
	identify the format of the image (e.g. 32 or 64-bit word size) or specific requirements
	of the image (e.g. block closure support required)"

	"Smalltalk image imageFormatVersionFromFile"

	| format |
	format := self imageFormatVersionFromFileAsIs.
	^format <= 16r00FFFFFF
		ifTrue: [  "same endianness as VM"
			format ]
		ifFalse: [ "convert endianness"
			((format bitAnd: 16rFF000000) >> 24)
			+ ((format bitAnd: 16r00FF0000) >> 8)
			+ ((format bitAnd: 16r0000FF00) << 8)
			+ ((format bitAnd: 16r000000FF) << 16)]
]

{ #category : #image }
SmalltalkImage >> imageFormatVersionFromFileAsIs [
	"Answer an integer identifying the type of image on file. The image version number may
	identify the format of the image (e.g. 32 or 64-bit word size) or specific requirements
	of the image (e.g. block closure support required). If the image file has a different
	endianness than the VM, the format version will appear byte-swapped."

	"Smalltalk image imageFormatVersionFromFileAsIs"

	^(FileStream readOnlyFileNamed: Smalltalk imageName do: [ :file | file binary; next: 4 ])
		unsignedLongAt: 1 bigEndian: Smalltalk isBigEndian
]

{ #category : #'image, changes names' }
SmalltalkImage >> imageName [
	"Answer the full path name for the current image."
	"Smalltalk imageName"

	^ self primImageName vmPathToSqueakPath

]

{ #category : #'image, changes names' }
SmalltalkImage >> imageName: newName [
	"Set the the full path name for the current image.  All further snapshots will use this."

	self primImageName: newName asVmPathName.

]

{ #category : #'image, changes names' }
SmalltalkImage >> imagePath [
	"Answer the path for the directory containing the image file."
	"Smalltalk imagePath"

	^ FileDirectory dirPathFor: self imageName

]

{ #category : #'dictionary access' }
SmalltalkImage >> includesKey: key [
	"Answer whether the receiver has a key equal to the argument, key."

	^globals includesKey: key
]

{ #category : #'memory space' }
SmalltalkImage >> installLowSpaceWatcher [
	"Start a process to watch for low-space conditions."
	"Smalltalk installLowSpaceWatcher"

	self primSignalAtBytesLeft: 0.  "disable low-space interrupts"
	LowSpaceProcess == nil ifFalse: [LowSpaceProcess terminate].
	LowSpaceProcess := [self lowSpaceWatcher] newProcess.
	LowSpaceProcess priority: Processor lowIOPriority.
	LowSpaceProcess resume.


]

{ #category : #vm }
SmalltalkImage >> interpreterClass [
	^self getSystemAttribute: 1007
]

{ #category : #vm }
SmalltalkImage >> interpreterSourceVersion [
	"Answer a string corresponding to the version of the interpreter source.
	This represents the version level of the Smalltalk source code (interpreter
	and various plugins) that is translated to C by a CCodeGenerator, as distinct
	from the external platform source code, typically written in C and managed
	separately for each platform. An optional primitive is invoked that may not
	be available on all virtual machines."

	"Smalltalk vm interpreterSourceVersion"

	<primitive: 'primitiveInterpreterSourceVersion'>
	self notify: 'This virtual machine does not support the optional primitive #primitiveInterpreterSourceVersion' translated.
	^''
]

{ #category : #'system attributes' }
SmalltalkImage >> isBigEndian [
	^self endianness == #big
]

{ #category : #'vm parameters' }
SmalltalkImage >> isHeadless [
	"Answer whether the command-line specified to launch the VM headless."
	self optionsDo:
		[ : each | (#('display=none' '-headless' '-nodisplay' '-vm-display-null' ) includes: each) ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'system attributes' }
SmalltalkImage >> isLittleEndian [
	^self endianness == #little
]

{ #category : #'system attributes' }
SmalltalkImage >> isLowerPerformance [
	"Some operations - TestCases for example - need an idea of the typical performance of the system on which they are being performed. For now we will simply assert that running on an ARM cpu or as a SqueakJS instance is enough of a discriminator. Options for the future might also involve whether the vm is a full Cog or Sisata system, even actually measuring the performance at some point to be sure"
	^ (self platformSubtype beginsWith: 'arm') "Raspberry PI for example"
		or: [self platformName = 'Web'] "SqueakJS"
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> isMorphic [
       
	^ Project current isMorphic
]

{ #category : #'memory space' }
SmalltalkImage >> isRoot: oop [
	"Primitive. Answer whether the object is currently a root for youngSpace."
	<primitive: 'primitiveIsRoot'>
	^self primitiveFailed
]

{ #category : #'system attributes' }
SmalltalkImage >> isRunningCog [
	"Answers if we're running on a Cog VM (JIT or StackInterpreter)"

	^(self vmParameterAt: 42)
		ifNil: [false]
		ifNotNil: [:numStackPages| numStackPages > 0]
]

{ #category : #'system attributes' }
SmalltalkImage >> isRunningCogit [
	"Answers if we're running on the Cog JIT"

	^(self vmParameterAt: 46)
		ifNil: [false]
		ifNotNil: [:machineCodeZoneSize| machineCodeZoneSize > 0]
]

{ #category : #'system attributes' }
SmalltalkImage >> isRunningSpur [
	"Answers if we're running on the Spur memory manager.  Spur has immediate characters.
	 (vmParameterAt: 41 is the image format version for the VM)"

	^Character instSize = 0
	"a.k.a. (self vmParameterAt: 41) anyMask: 16"
]

{ #category : #'memory space' }
SmalltalkImage >> isYoung: oop [
	"Primitive. Answer whether the object currently resides in youngSpace."
	<primitive: 'primitiveIsYoung'>
	^self primitiveFailed
]

{ #category : #'sources, changes log' }
SmalltalkImage >> lastQuitLogPosition [
	^ LastQuitLogPosition
]

{ #category : #'sources, changes log' }
SmalltalkImage >> lastQuitLogPosition: aNumber [
	"should be only use to ensure the transition from SystemDictionary to SmalltalkImage, then  	be removed"
		
	LastQuitLogPosition := aNumber
]

{ #category : #'sources, changes log' }
SmalltalkImage >> lastUpdateString [
	"Smalltalk lastUpdateString"
	^'latest update: #' translated, SystemVersion current highestUpdate printString
]

{ #category : #license }
SmalltalkImage >> license [
	"This method was automatically generated. Edit it using:"
	"SqueakLicenseHelp edit: #officialLicense"
	^ (
'The current release of Squeak is a combination of source code originating from Apple which Apple agreed to license under the Apache License and more recent contributions licensed under the MIT license. The vast majority of the code is under the MIT License:

MIT License

Copyright (c) The individual, corporate, and institutional contributors who have collectively contributed elements to this software ("The Squeak Community"), 1996-2020 All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Portions of Squeak are covered by the Apache License:

Apache License, Version 2.0

Copyright (c) Xerox Corp. 1981, 1982 All rights reserved.
Copyright (c) Apple Computer, Inc. 1985-1996 All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
!
]style[(258 1 11 1216 53 2 27 297 42 308)c159159159,,b,,c159159159,,b,,Rhttp://www.apache.org/licenses/LICENSE-2.0;,!' readStream nextChunkText)
]

{ #category : #modules }
SmalltalkImage >> listBuiltinModule: index [
	"Return the name of the n-th builtin module.
	This list is not sorted!"
	<primitive: 572>
	^self primitiveFailed
]

{ #category : #modules }
SmalltalkImage >> listBuiltinModules [
	"Smalltalk listBuiltinModules"
	"Return a list of all builtin modules (e.g., plugins). Builtin plugins are those that are 	compiled with the VM directly, as opposed to plugins residing in an external shared library. 	The list will include all builtin plugins regardless of whether they are currently loaded 
	or not. Note that the list returned is not sorted!"

	| modules index name |
	modules := WriteStream on: (Array new: 20).
	index := 1.
	[
		name := self listBuiltinModule: index.
		name ifNil:[^modules contents].
		modules nextPut: name.
		index := index + 1 ] repeat
]

{ #category : #modules }
SmalltalkImage >> listLoadedModule: index [
	"Return the name of the n-th loaded module.
	This list is not sorted!"
	<primitive: 573>
	^self primitiveFailed
]

{ #category : #modules }
SmalltalkImage >> listLoadedModules [
	"Smalltalk listLoadedModules"
	"Return a list of all currently loaded modules (e.g., plugins). Loaded modules are those that currently in use (e.g., active). The list returned will contain all currently active modules regardless of whether they're builtin (that is compiled with the VM) or external (e.g., residing in some external shared library). Note that the returned list is not sorted!"
	| modules index name |
	modules := WriteStream on: (Array new: 20).
	index := 1.
	[
		name := self listLoadedModule: index.
		name ifNil:[^modules contents].
		modules nextPut: name.
		index := index + 1 ] repeat
]

{ #category : #'image, changes names' }
SmalltalkImage >> locateSourcesEntry [
	| sourcesFilename |
	sourcesFilename := SourceFileVersionString , FileDirectory dot , 'sources'.
	^ {Smalltalk vmPath. 
	FileDirectory default fullName, FileDirectory slash}
		detect: [ : each | (each , sourcesFilename) asDirectoryEntry notNil ]
		ifFound: [ : foundPath | (foundPath , sourcesFilename) asDirectoryEntry ]
		ifNone: [ nil ]
]

{ #category : #'sources, changes log' }
SmalltalkImage >> logChange: aStringOrText [ 
	"Write the argument, aString, onto the changes file."
	| aString changesFile |
	(SourceFiles isNil or: [(SourceFiles at: 2) == nil]) ifTrue: [^ self].
	self assureStartupStampLogged.

	aString := aStringOrText asString.
	(aString findFirst: [:char | char isSeparator not]) = 0
		ifTrue: [^ self].  "null doits confuse replay"
	(changesFile := SourceFiles at: 2).
	changesFile isReadOnly ifTrue:[^self].
	changesFile setToEnd; cr; cr.
	changesFile nextChunkPut: aString.
		"If want style changes in DoIt, use nextChunkPutWithStyle:, and allow Texts to get here"
	self forceChangesToDisk.
]

{ #category : #miscellaneous }
SmalltalkImage >> logError: errMsg inContext: aContext to: aFilename [
	"Log the error message and a stack trace to the given file."

	| ff |
	FileDirectory default deleteFileNamed: aFilename ifAbsent: [].
	(ff := FileStream fileNamed: aFilename) ifNil: [^ self "avoid recursive errors"].

  	ff nextPutAll: errMsg; cr.
	aContext errorReportOn: ff.
	ff close.
]

{ #category : #miscellaneous }
SmalltalkImage >> logSqueakError: errMsg inContext: aContext [ 
	"Log the error message and a stack trace to the usual file."

	^self logError: errMsg inContext: aContext to: self squeakErrorFileName

]

{ #category : #'memory space' }
SmalltalkImage >> lowSpaceChoices [
	"Return a notifier message string to be presented when space is running low."

	^ 'Warning! Squeak is almost out of memory!

Low space detection is now disabled. It will be restored when you close or proceed from this error notifier. Don''t panic, but do proceed with caution.

Here are some suggestions:

 If you suspect an infinite recursion (the same methods calling each other again and again), then close this debugger, and fix the problem.

 If you want this computation to finish, then make more space available (read on) and choose "proceed" in this debugger. Here are some ways to make more space available...
   > Close any windows that are not needed.
   > Get rid of some large objects (e.g., images).
   > Leave this window on the screen, choose "save as..." from the screen menu, quit, restart the Squeak VM with a larger memory allocation, then restart the image you just saved, and choose "proceed" in this window.

 If you want to investigate further, choose "debug" in this window.  Do not use the debugger "fullStack" command unless you are certain that the stack is not very deep. (Trying to show the full stack will definitely use up all remaining memory if the low-space problem is caused by an infinite recursion!).

'

]

{ #category : #'memory space' }
SmalltalkImage >> lowSpaceThreshold [ 
	"Answer the low space threshold. When the amount of free memory (after garbage collection)
	 falls below this limit, the system is in serious danger of completely exhausting memory and
	 crashing. This limit should be made high enough to allow the user open a debugger to diagnose
	 a problem or to save the image.  In a stack-based VM such as Cog contexts for activations in
	 the stack zone will have to be created as the debugger opens, requiring additional headroom."

	| slotsForDebugger slotsForContextsOnStackPages |
	slotsForDebugger := 65536. "Arbitrary guess"
	slotsForContextsOnStackPages :=
		(self vmParameterAt: 42)
			ifNil: [0]
			ifNotNil:
				[:numStackPages| | headerSize numActivationsPerPage maxContextSize |
				numActivationsPerPage := 40. "Design goal of the Cog & Stack VMs"
				headerSize := 8 / self wordSize. "64-bits for Spur"
				maxContextSize := thisContext class instSize + CompiledMethod fullFrameSize + headerSize.
				numStackPages * numActivationsPerPage * maxContextSize].
	^slotsForDebugger + slotsForContextsOnStackPages * self wordSize
]

{ #category : #'memory space' }
SmalltalkImage >> lowSpaceWatcher [
	"Wait until the low space semaphore is signalled, then take appropriate actions."

	| free preemptedProcess |
	self garbageCollectMost <= self lowSpaceThreshold
		ifTrue: [self garbageCollect <= self lowSpaceThreshold
				ifTrue: ["free space must be above threshold before
					starting low space watcher"
					^ Beeper beep]].

	Smalltalk specialObjectsArray at: 23 put: nil.  "process causing low space will be saved here"
	LowSpaceSemaphore := Semaphore new.
	self primLowSpaceSemaphore: LowSpaceSemaphore.
	self primSignalAtBytesLeft: self lowSpaceThreshold.  "enable low space interrupts"

	LowSpaceSemaphore wait.  "wait for a low space condition..."

	self primSignalAtBytesLeft: 0.  "disable low space interrupts"
	self primLowSpaceSemaphore: nil.
	LowSpaceProcess := nil.

	"The process that was active at the time of the low space interrupt."
	preemptedProcess := Smalltalk specialObjectsArray at: 23.
	Smalltalk specialObjectsArray at: 23 put: nil.

	"Note: user now unprotected until the low space watcher is re-installed"

	self memoryHogs isEmpty
		ifFalse: [free := self bytesLeft.
			self memoryHogs
				do: [ :hog | hog freeSomeSpace ].
			self bytesLeft > free
				ifTrue: [ ^ self installLowSpaceWatcher ]].

	Preferences logDebuggerStackToFile ifTrue: [
		self
			logError: 'Space is low'
			inContext: preemptedProcess suspendedContext
			to: 'LowSpaceDebug.log'].
			
	Project current
			interruptName: 'Space is low'
			message: self lowSpaceChoices
			preemptedProcess: preemptedProcess

]

{ #category : #'memory space' }
SmalltalkImage >> lowSpaceWatcherProcess [
	^LowSpaceProcess
]

{ #category : #'vm parameters' }
SmalltalkImage >> maxExternalSemaphores [
	"The size of table where external semaphores are registered. Only in Cog"
	self isRunningCog ifFalse: [^nil].
	^self vmParameterAt: 49
]

{ #category : #'vm parameters' }
SmalltalkImage >> maxExternalSemaphores: aSize [
	"Changes the size of table where external semaphores are registered. 
	The size can only grow, and will always be the next power of two larger than the parameter.
	
	Setting this at any time other than start-up can potentially lose requests.
	 i.e. during the realloc new storage is allocated,
	the old contents are copied and then pointers are switched. 
	 Requests occurring during copying won't be seen if they occur to indices already copied. 
	The intended use is to set the table to some adequate maximum at start-up"
	
	self isRunningCog ifFalse: [^0].
	"The vm-header field is a short, maximum 64k entries. Well, on most platforms anyways "
	(aSize < 0 or: [aSize > 16rFFFF]) ifTrue: [^self error: 'maxExternalSemaphores: is limited to 16rFFFF'].
	^self vmParameterAt: 49 put: aSize
]

{ #category : #'system attributes' }
SmalltalkImage >> maxIdentityHash [
	"Answer the maximum identityHash value supported by the VM."
	<primitive: 176>
	^self primitiveFailed
]

{ #category : #'memory space' }
SmalltalkImage >> memoryHogs [
	"Answer the list of objects to notify with #freeSomeSpace if memory gets full."

	^ MemoryHogs ifNil: [MemoryHogs := OrderedCollection new]
]

{ #category : #housekeeping }
SmalltalkImage >> moveChanges [
	"Move the current version of every method in .changes to my .sources file."
	self appendChangesTo:
		((UIManager default
			request: 'Please specify the name of the\.sources file to move changes to.' withCRs
			initialAnswer: self sourceFileVersionString) ifEmpty: [ ^ self inform: 'Aborted.' ])
]

{ #category : #'command line' }
SmalltalkImage >> namedArguments [
	"Assume arguments passed to the image are key->value pairs, answer a Dictionary of the argument names and their values."
	| argName value index paramNameValueDictionary |
	paramNameValueDictionary := Dictionary new.
	index := 1.
	[ argName := self argumentAt: index.
	argName isEmptyOrNil ] whileFalse:
		[ index := index + 1.
		value := (self argumentAt: index) ifNil: [ String empty ].
		paramNameValueDictionary
			at: argName asUppercase
			put: value.
		index := index + 1 ].
	^ paramNameValueDictionary
]

{ #category : #'external objects' }
SmalltalkImage >> newExternalSemaphore [
	"Create and register a new Semaphore, and return an array containing itself and its index."

	^ExternalObjectTable current newExternalSemaphore
]

{ #category : #'external objects' }
SmalltalkImage >> newExternalSemaphoreDo: aBlock [ 
	"Create and register a new Semaphore, then evaluate aBlock with it and its index."

	^ExternalObjectTable current newExternalSemaphoreDo: aBlock
]

{ #category : #'external objects' }
SmalltalkImage >> newExternalSemaphores: count [ 
	"Create and register multiple Semaphores, and return an array containing the semaphores and their indexes in separate arrays."

	^ExternalObjectTable current newExternalSemaphores: count
]

{ #category : #miscellaneous }
SmalltalkImage >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a reference to Smalltalk instead."

	dp := DiskProxy global: #Smalltalk selector: #yourself
			args: #().
	refStrm replace: self with: dp.
	^ dp
]

{ #category : #'memory space' }
SmalltalkImage >> okayToProceedEvenIfSpaceIsLow [
	"Return true if either there is enough memory to do so safely or if the user gives permission after being given fair warning."

	self garbageCollectMost > self lowSpaceThreshold ifTrue: [^ true].  "quick"
	self garbageCollect > self lowSpaceThreshold ifTrue: [^ true].  "work harder"

	^ self confirm:
'WARNING: There is not enough space to start the low space watcher.
If you proceed, you will not be warned again, and the system may
run out of memory and crash. If you do proceed, you can start the
low space notifier when more space becomes available simply by
opening and then closing a debugger (e.g., by hitting Cmd-period.)
Do you want to proceed?'

]

{ #category : #'sources, changes log' }
SmalltalkImage >> openSourceFiles [

	self imageName = LastImageName ifFalse:
		["Reset the author initials to blank when the image gets moved"
		LastImageName := self imageName.
		Utilities authorInitials: ''].
	FileDirectory
		openSources: self sourcesName
		andChanges: self changesName
		forImage: LastImageName.
	SourceFileArray install
]

{ #category : #'command line' }
SmalltalkImage >> optionAt: i [
	"Answer the i-th option of the command line, or nil if not so many options."
	
	^self getSystemAttribute: i negated
]

{ #category : #'command line' }
SmalltalkImage >> options [
	"Answer an array with all the command line options."
	"Smalltalk commandLine options"
	^ Array streamContents:
		[ : stream | self optionsDo:
			[ : each | stream nextPut: each ] ]
]

{ #category : #'command line' }
SmalltalkImage >> optionsDo: aBlock [ 
	"Enumerate the command-line arguments passed to the vm only.  This does not include arguments passed to the image."
	1
		to: 1000
		by: 1
		do:
			[ : n | 
			(self optionAt: n)
				ifNil: [ ^ self ]
				ifNotNil: [ : opt | aBlock value: opt ] ]
]

{ #category : #accessing }
SmalltalkImage >> organization [
	"Return the organizer for the receiver"

	^globals organization
]

{ #category : #os }
SmalltalkImage >> os [
	"Answer the object to query about os."
	
	^self
]

{ #category : #os }
SmalltalkImage >> osVersion [
	"Return the version number string of the platform we're running on"
	
	"Smalltalk osVersion"

	^(self getSystemAttribute: 1002) asString
]

{ #category : #'command line' }
SmalltalkImage >> patchSystem [
	'patch.st' asDirectoryEntry ifNotNil:
		[ : patchEntry | patchEntry modificationTime > Smalltalk imageName asDirectoryEntry modificationTime
			ifTrue:
				[ Notification signal: 'Patching system...'.
				FileStream
					fileNamed: 'patch.st'
					do:
						[ : stream | stream fileIn ] ]
			ifFalse: [ self error: 'patch.st file is older than the image file.  Aborting.' ] ]
]

{ #category : #os }
SmalltalkImage >> platformName [
	"Return the name of the platform we're running on."
	
	"Smalltalk os platformName"

	^self getSystemAttribute: 1001
]

{ #category : #vm }
SmalltalkImage >> platformSourceVersion [
	"Answer a string corresponding to the version of the external platform source
	code, typically written in C and managed separately for each platform. This
	invokes an optional primitive that may not be available on all virtual machines."

	"Smalltalk vm platformSourceVersion"

	<primitive: 'primitivePlatformSourceVersion'>
	(self getSystemAttribute: 1009) ifNotNil:
		[:platformSourceVersion| ^platformSourceVersion].
	self notify: 'This virtual machine supports neither the optional primitive #primitivePlatformSourceVersion nor the optional system attribute 1009' translated.
	^''
]

{ #category : #os }
SmalltalkImage >> platformSubtype [
	"Return the subType of the platform we're running on."

	"Smalltalk os platformSubtype"
	
	^self getSystemAttribute: 1003
]

{ #category : #shrinking }
SmalltalkImage >> presumedSentMessages [   | sent |
"Smalltalk presumedSentMessages"

	"The following should be preserved for doIts, etc"
	sent := IdentitySet new.
	#(compactSymbolTable rebuildAllProjects
		browseAllSelect:  lastRemoval
		scrollBarValue: vScrollBarValue: scrollBarMenuButtonPressed: 
		withSelectionFrom:  to: removeClassNamed:
		dragon: hilberts: mandala: web test3 factorial tinyBenchmarks benchFib
		newDepth: restoreAfter: zapAllMethods obsoleteClasses
		removeAllUnSentMessages abandonSources removeUnreferencedKeys
		reclaimDependents zapOrganization condenseChanges browseObsoleteReferences
		subclass:instanceVariableNames:classVariableNames:poolDictionaries:category:
		methodsFor:stamp: methodsFor:stamp:prior: instanceVariableNames:
		unusedClasses) do:
		[:sel | sent add: sel].
	"The following may be sent by perform: in dispatchOnChar..."
	Smalltalk at: #ParagraphEditor ifPresent: [:paragraphEditor |
		(paragraphEditor classPool at: #CmdActions) asSet do:
			[:sel | sent add: sel].
		(paragraphEditor classPool at: #ShiftCmdActions) asSet do:
			[:sel | sent add: sel]].
	^ sent
]

{ #category : #'memory space' }
SmalltalkImage >> primBytesLeft [
	"Primitive. Answer the number of free bytes available in old space.
	 Not accurate unless preceded by
		Smalltalk garbageCollectMost (for reasonable accuracy), or
		Smalltalk garbageCollect (for real accuracy).
	 See Object documentation whatIsAPrimitive."

	<primitive: 112>
	^0
]

{ #category : #'image, changes names' }
SmalltalkImage >> primImageName [
	"Answer the full path name for the current image."
	"Smalltalk imageName"

	<primitive: 121>
	self primitiveFailed
]

{ #category : #'image, changes names' }
SmalltalkImage >> primImageName: newName [
	"Set the the full path name for the current image.  All further snapshots will use this."

	<primitive: 121>
	^ self primitiveFailed
]

{ #category : #'memory space' }
SmalltalkImage >> primLowSpaceSemaphore: aSemaphore [
	"Primitive. Register the given Semaphore to be signalled when the
	number of free bytes drops below some threshold. Disable low-space
	interrupts if the argument is nil."

	<primitive: 124>
	self primitiveFailed
]

{ #category : #'memory space' }
SmalltalkImage >> primSignalAtBytesLeft: numBytes [
	"Tell the interpreter the low-space threshold in bytes. When the free
	space falls below this threshold, the interpreter will signal the low-space
	semaphore, if one has been registered.  Disable low-space interrupts if the
	argument is zero.  Fail if numBytes is not an Integer."

	<primitive: 125>
	self primitiveFailed
]

{ #category : #'image, changes names' }
SmalltalkImage >> primVmFileName [
	"Answer the absolute file name of the the Smalltalk virtual machine"

	^ self getSystemAttribute: 0
]

{ #category : #'image, changes names' }
SmalltalkImage >> primVmPath [
	"Answer the path for the directory containing the Smalltalk virtual machine. Return the 	empty string if this primitive is not implemented."
	"Smalltalk vmPath"

	<primitive: 142>
	^ ''
]

{ #category : #'special objects' }
SmalltalkImage >> primitiveErrorTable [
	"Smalltalk primitiveErrorTable"
	^self specialObjectsArray at: 52
]

{ #category : #'memory space' }
SmalltalkImage >> primitiveGarbageCollect [
	"Primitive. Reclaims all garbage and answers the size of the largest free chunk in old space.."

	<primitive: 130>
	^self primitiveFailed
]

{ #category : #miscellaneous }
SmalltalkImage >> printOn: aStream [
	self == Smalltalk
		ifTrue: [aStream nextPutAll: #Smalltalk]
		ifFalse: [super printOn: aStream]
]

{ #category : #'system attributes' }
SmalltalkImage >> processHasThreadIdInstVar: aBoolean [
	"The threaded VM needs to know if the 4th inst var of Process
	 is threadId which it uses to control process-to-thread binding.
	 This flag persists across snapshots, stored in the image header."
	aBoolean ifTrue: [self assert: (Process instVarNames at: 4) = 'threadId'].
	self vmParameterAt: 48 put: ((self vmParameterAt: 48) bitClear: 1) + (aBoolean ifTrue: [1] ifFalse: [0])
]

{ #category : #'system attributes' }
SmalltalkImage >> processPreemptionYields [
	"Answer whether the VM causes a process to yield on process preemption,
	 i.e. to put a preempted process at the back of its run queue.  If the parameter
	 is unavailable (non-Cog VMs) or bit 2 (4) is 0 then preemption yields."

	^(([self vmParameterAt: 48]
			on: Error
			do: [:ex| ^true]) allMask: 4) not
]

{ #category : #'system attributes' }
SmalltalkImage >> processPreemptionYields: aBoolean [
	"The Cog VM can be instructed not to yield on process preemption,
	 i.e. not to put a preempted process at the back of its run queue.  By
	 default preempting a process causes it to yield (Blue Book semantics)
	 which can have unfortunate effects.
	 This flag persists across snapshots, stored in the image header."

	[self vmParameterAt: 48 put: ((self vmParameterAt: 48) bitClear: 4) + (aBoolean ifTrue: [0] ifFalse: [4])]
		on: Error
		do: ["no VM parameter 48, do nothing"]
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> processShutDownList: quitting [
	"Send #shutDown to each class that needs to wrap up before a snapshot.
	 Also void the endianness chace;  this can't safely be done on start-up because
	 Smalltalk is too late in the start-up sequence."

	EndianCache := nil.
	self send: #shutDown: toClassesNamedIn: ShutDownList with: quitting
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> processStartUpList: resuming [
	"Send #startUp to each class that needs to run initialization after a snapshot."

	self send: #startUp: toClassesNamedIn: StartUpList with: resuming.

]

{ #category : #'vm profiling' }
SmalltalkImage >> profile: aBlock [
	"Make a virtual machine profile of the given block."
	"Note: Profiling support is provided so that VM implementors
	 can better understand and improve the efficiency of the virtual
	 machine. To use it, you must be running a version of the
	 virtual machine compiled with profiling enabled (which
	 makes it much slower than normal even when not profiling).
	 You will also need the CodeWarrior profile reader application."

	self stopProfiling.
	self clearProfile.
	self startProfiling.
	aBlock value.
	self stopProfiling.
	self dumpProfile.
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> quitPrimitive [
	"Primitive. Exit to another operating system on the host machine, if one
	exists. All state changes in the object space since the last snapshot are lost.
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 113>
	self primitiveFailed
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> quitPrimitive: exitCode [
	"Primitive. Exit with exitCode to another operating system on the host machine, if one exists. All state changes in the object space since the last snapshot are lost. Ignore exitCode if it's not supported by the VM."

	<primitive: 113>
	self quitPrimitive
]

{ #category : #private }
SmalltalkImage >> rawArguments [
	"Answer an array with all the command line arguments as delivered
	from the VM. Any arguments for the VM itself will have been removed
	(these are accessed with optionAt:)."
	
	"Smalltalk commandLine rawArguments"
	
	^Array streamContents: [:str |
		| arg i |
		i := 1.
		[i > 998 or: [(arg := self getSystemAttribute: i) == nil]]
			whileFalse:
				[str nextPut: arg.
				i := i + 1]].
]

{ #category : #housekeeping }
SmalltalkImage >> reclaimDependents [
	"No-opped due to weak dictionary in use"
	self garbageCollect
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> recordStartupStamp [
	
	StartupStamp := '----STARTUP----', Time dateAndTimeNow printString, ' as ', self imageName.

]

{ #category : #'special objects' }
SmalltalkImage >> recreateSpecialObjectsArray [
	"Smalltalk recreateSpecialObjectsArray"
	
	"To external package developers:
	**** DO NOT OVERRIDE THIS METHOD.  *****
	If you are writing a plugin and need additional special object(s) for your own use, 
	use addGCRoot() function and use own, separate special objects registry "
	
	"The Special Objects Array is an array of objects used by the Squeak virtual machine.
	 Its contents are critical and accesses to it by the VM are unchecked, so don't even
	 think of playing here unless you know what you are doing."
	| newArray |
	newArray := Array new: 60.
	"Nil false and true get used throughout the VM"
	newArray at: 1 put: nil.
	newArray at: 2 put: false.
	newArray at: 3 put: true.
	"This association holds the active process (a ProcessScheduler)"
	newArray at: 4 put: (self specialObjectsArray at: 4) "(self bindingOf: #Processor) but it answers an Alias".
	"Numerous classes below used for type checking and instantiation"
	newArray at: 5 put: Bitmap.
	newArray at: 6 put: SmallInteger.
	newArray at: 7 put: ByteString.
	newArray at: 8 put: Array.
	newArray at: 9 put: Smalltalk.
	newArray at: 10 put: BoxedFloat64.
	newArray at: 11 put: (self globals at: #Context).
	newArray at: 12 put: WideString. "Was BlockContext"
	newArray at: 13 put: Point.
	newArray at: 14 put: LargePositiveInteger.
	newArray at: 15 put: Display.
	newArray at: 16 put: Message.
	newArray at: 17 put: CompiledMethod.
	newArray at: 18 put: ((self specialObjectsArray at: 18) ifNil: [Semaphore new]). "low space Semaphore"
	newArray at: 19 put: Semaphore.
	newArray at: 20 put: Character.
	newArray at: 21 put: #doesNotUnderstand:.
	newArray at: 22 put: #cannotReturn:.
	newArray at: 23 put: nil. "This is the process signalling low space."
	"An array of the 32 selectors that are compiled as special bytecodes,
	 paired alternately with the number of arguments each takes."
	newArray at: 24 put: #(+ 1 - 1 < 1 > 1 <= 1 >= 1 = 1 ~= 1
							* 1 / 1 \\ 1 @ 1 bitShift: 1 // 1 bitAnd: 1 bitOr: 1
							at: 1 at:put: 2 size 0 next 0 nextPut: 1 atEnd 0 == 1 class 0
							~~ 1 value 0 value: 1 do: 1 new 0 new: 1 x 0 y 0 ).
	newArray at: 25 put: nil. "Was an array of the 255 Characters in ascii order. This is nil in Spur, which has immediate Characters."
	newArray at: 26 put: #mustBeBoolean.
	newArray at: 27 put: ByteArray.
	newArray at: 28 put: Process.
	"An array of up to 31 classes whose instances will have compact headers; an empty array in Spur"
	newArray at: 29 put: self compactClassesArray.
	newArray at: 30 put: ((self specialObjectsArray at: 30) ifNil: [Semaphore new]). "delay Semaphore"
	newArray at: 31 put: ((self specialObjectsArray at: 31) ifNil: [Semaphore new]). "user interrupt Semaphore"
	"Entries 32 - 34 unreferenced. Previously these contained prototype instances to be copied for fast initialization"
	newArray at: 32 put: DoubleByteArray. "was the prototype Float"
	newArray at: 33 put: WordArray. "was the prototype 4-byte LargePositiveInteger"
	newArray at: 34 put: DoubleWordArray. "was the prototype Point"
	newArray at: 35 put: #cannotInterpret:.
	newArray at: 36 put: nil. "was the prototype MethodContext"
	newArray at: 37 put: BlockClosure.
	newArray at: 38 put: (self at: #FullBlockClosure ifAbsent: []). "was the prototype BlockContext"
	"array of objects referred to by external code"
	newArray at: 39 put: (self specialObjectsArray at: 39).	"external semaphores"
	newArray at: 40 put: nil. "Reserved for Mutex in Cog VMs"
	newArray at: 41 put: ((self specialObjectsArray at: 41) ifNil: [LinkedList new]). "Reserved for a LinkedList instance for overlapped calls in CogMT"
	newArray at: 42 put: ((self specialObjectsArray at: 42) ifNil: [Semaphore new]). "finalization Semaphore"
	newArray at: 43 put: LargeNegativeInteger.
	"External objects for callout.
	 Note: Written so that one can actually completely remove the FFI."
	newArray at: 44 put: (self at: #ExternalAddress ifAbsent: []).
	newArray at: 45 put: (self at: #ExternalStructure ifAbsent: []).
	newArray at: 46 put: (self at: #ExternalData ifAbsent: []).
	newArray at: 47 put: (self at: #ExternalFunction ifAbsent: []).
	newArray at: 48 put: (self at: #ExternalLibrary ifAbsent: []).
	newArray at: 49 put: #aboutToReturn:through:.
	newArray at: 50 put: #run:with:in:.
	"51 reserved for immutability message"
	newArray at: 51 put: #attemptToAssign:withIndex:.
	newArray at: 52 put: #(nil "nil => generic error" #'bad receiver'
							#'bad argument' #'bad index'
							#'bad number of arguments'
							#'inappropriate operation'  #'unsupported operation'
							#'no modification' #'insufficient object memory'
							#'insufficient C memory' #'not found' #'bad method'
							#'internal error in named primitive machinery'
							#'object may move' #'resource limit exceeded'
							#'object is pinned' #'primitive write beyond end of object'
							#'object moved' #'object not pinned' #'callback error'),
							{PrimitiveError new errorName: #'operating system error'; yourself.
							 ExceptionInFFICallError new errorName: #'exception in FFI call'; yourself}.
	"53 to 55 are for Alien"
	newArray at: 53 put: (self at: #Alien ifAbsent: []).
	newArray at: 54 put: #invokeCallbackContext:. "use invokeCallback:stack:registers:jmpbuf: for old Alien callbacks."
	newArray at: 55 put: (self at: #UnsafeAlien ifAbsent: []).

	"Used to be WeakFinalizationList for WeakFinalizationList hasNewFinalization, obsoleted by ephemeron support."
	newArray at: 56 put: nil.

	"reserved for foreign callback process"
	newArray at: 57 put: (self specialObjectsArray at: 57 ifAbsent: []).

	newArray at: 58 put: #unusedBytecode.
	"59 reserved for Sista counter tripped message"
	newArray at: 59 put: #conditionalBranchCounterTrippedOn:.
	"60 reserved for Sista class trap message"
	newArray at: 60 put: #classTrapFor:.

	"Now replace the virtual machine's reference in one atomic operation"
	self specialObjectsArray becomeForward: newArray
]

{ #category : #'external objects' }
SmalltalkImage >> registerExternalObject: anObject [
	"Register the given object in the external objects array and return its index. If it is already there, just return its index."

	^ExternalObjectTable current registerExternalObject: anObject
]

{ #category : #shrinking }
SmalltalkImage >> removeAllUnSentMessages [
	"Smalltalk removeAllUnSentMessages"
	"[Smalltalk unusedClasses do: [:c | (Smalltalk at: c) removeFromSystem]. 
	Smalltalk removeAllUnSentMessages > 0] whileTrue."
	"Remove all implementations of unsent messages."
	| sels n |
	sels := self systemNavigation allUnSentMessages.
	"The following should be preserved for doIts, etc"
	"needed even after #majorShrink is pulled"
	#(#compactSymbolTable #rebuildAllProjects #browseAllSelect:  #lastRemoval #scrollBarValue: vScrollBarValue: #scrollBarMenuButtonPressed: #withSelectionFrom: #to: #removeClassNamed: #dragon: #hilberts: #mandala: #web #test3 #factorial #tinyBenchmarks #benchFib #newDepth: #restoreAfter: #zapAllMethods #obsoleteClasses #removeAllUnSentMessages #abandonSources #removeUnreferencedKeys #reclaimDependents #zapOrganization #condenseChanges #browseObsoleteReferences #subclass:instanceVariableNames:classVariableNames:poolDictionaries:category: #methodsFor:stamp: #methodsFor:stamp:prior: #instanceVariableNames: #unusedClasses )
		do: [:sel | sels
				remove: sel
				ifAbsent: []].
	"The following may be sent by perform: in dispatchOnChar..."
	(Smalltalk at: #ParagraphEditor) ifNotNil: [:paragraphEditor |
		(paragraphEditor classPool at: #CmdActions) asSet
			do: [:sel | sels
					remove: sel
					ifAbsent: []].
		(paragraphEditor classPool at: #ShiftCmdActions) asSet
			do: [:sel | sels
					remove: sel
					ifAbsent: []]].
	sels size = 0
		ifTrue: [^ 0].
	n := 0.
	self systemNavigation
		allBehaviorsDo: [:x | n := n + 1].
	'Removing ' , sels size printString , ' messages . . .'
		displayProgressFrom: 0
		to: n
		during: [:bar | 
			n := 0.
			self systemNavigation
				allBehaviorsDo: [:class | 
					bar value: (n := n + 1).
					sels
						do: [:sel | class basicRemoveSelector: sel]]].
	^ sels size
]

{ #category : #shrinking }
SmalltalkImage >> removeChangeSets [
	self deprecated: 'Use ChangeSet cleanUp: true'.
	ChangeSet cleanUp: true.
]

{ #category : #'classes and traits' }
SmalltalkImage >> removeClassNamed: aName [
	"DO NOT DEPRECATE - Invoked from fileouts. If there is currently a class in the system named aName, then remove it.  If anything untoward happens, report it in the Transcript.  "

	^globals removeClassNamed: aName
]

{ #category : #housekeeping }
SmalltalkImage >> removeEmptyMessageCategories [
	"Smalltalk removeEmptyMessageCategories"
	self garbageCollect.
	(ClassOrganizer allInstances copyWith: SystemOrganization)
		do: [:org | org removeEmptyCategories]
]

{ #category : #'startup and shutdown list' }
SmalltalkImage >> removeFromShutDownList: aClass [

	ShutDownList remove: aClass name ifAbsent: []
]

{ #category : #'startup and shutdown list' }
SmalltalkImage >> removeFromStartUpList: aClass [

	StartUpList remove: aClass name ifAbsent: []
]

{ #category : #shrinking }
SmalltalkImage >> removeSelector: descriptor [ 
	"Safely remove a selector from a class (or metaclass). If the
	class or the method doesn't exist anymore, never mind and
	answer nil.
	This method should be used instead of 'Class removeSelector:
	#method' to omit global class references."
	| class sel |
	class := self
				at: descriptor first
				ifAbsent: [^ nil].
	(descriptor size > 2
			and: [descriptor second == #class])
		ifTrue: [class := class class.
			sel := descriptor third]
		ifFalse: [sel := descriptor second].
	^ class removeSelector: sel
]

{ #category : #'classes and traits' }
SmalltalkImage >> renameClass: aClass as: newName [ 
	"Rename the class, aClass, to have the title newName."

	^globals renameClass: aClass as: newName
]

{ #category : #'classes and traits' }
SmalltalkImage >> renameClass: aClass from: oldName [
	"Rename the class, aClass, to have the title newName."

	^globals renameClass: aClass from: oldName
]

{ #category : #'classes and traits' }
SmalltalkImage >> renameClassNamed: oldName as: newName [
	"DO NOT DEPRECATE - Invoked from fileouts.  If there is currently a class in the system named oldName, then rename it to newName.  If anything untoward happens, report it in the Transcript.  "

	^globals renameClassNamed: oldName as: newName
]

{ #category : #'classes and traits' }
SmalltalkImage >> renamedClass: aClass from: oldName to: newName [
	"Inform Smalltalk that aClass has been renamed"
	(Array with: StartUpList with: ShutDownList) do:[:list | | index |  
		index := list indexOf: oldName.
		index > 0 ifTrue: [list at: index put: newName].
	].

]

{ #category : #'memory space' }
SmalltalkImage >> rootTable [
	"Primitive. Answer a snapshot of the VMs root table. 
	Keep in mind that the primitive may itself cause GC."
	<primitive: 'primitiveRootTable'>
	^self primitiveFailed
]

{ #category : #'memory space' }
SmalltalkImage >> rootTableAt: index [
	"Primitive. Answer the nth element of the VMs root table"
	<primitive: 'primitiveRootTableAt'>
	^nil
]

{ #category : #'command line' }
SmalltalkImage >> run: aBlock [
	[ [ self patchSystem.
	(aBlock numArgs = 1 and: [ self arguments size > 1 ])
		ifTrue: [ "Allow a large, variable number of arguments to be passed as an Array to aBlock."
			aBlock value: self arguments ]
		ifFalse: [ aBlock valueWithEnoughArguments: self arguments ] ]
		on: ProgressInitiationException
		do:
			[ : pie | "Don't want to log this notification."
			pie defaultAction ] ]
		on: Notification , Warning
		do:
			[ : noti | FileStream stdout
				 nextPutAll: DateAndTime now asString ;
				 space ;
				 nextPutAll: noti description ;
				 cr.
			noti resume ]
		on: SyntaxErrorNotification
		do:
			[ : err | FileStream stdout
				 nextPutAll: err errorCode ;
				 cr; flush.
			self isHeadless
				ifTrue: [ self snapshot: false andQuit: true ]
				ifFalse: [ err pass ] ]
		on: Error
		do:
			[ : err | err printVerboseOn: FileStream stderr.
			FileStream stderr flush.
			self isHeadless
				ifTrue: [ self snapshot: false andQuit: true ]
				ifFalse: [ err pass ] ]
]

{ #category : #'command line' }
SmalltalkImage >> run: aBlock snapshotAs: imageName andQuit: shouldQuit [ 
	self run: aBlock.
	imageName
		ifNil:
			[ shouldQuit ifTrue:
				[ self
					snapshot: false
					andQuit: shouldQuit ] ]
		ifNotNil:
			[ | correctName |
			correctName := (imageName endsWith: '.image')
				ifTrue: [ imageName ]
				ifFalse: [ imageName , '.image' ].
			(FileDirectory default fullNameFor: correctName) = self imageName
				ifTrue:
					[ self
						snapshot: true
						andQuit: shouldQuit ]
				ifFalse:
					[ self saveAs: imageName.
					"Avoid instant-quit when relaunching by resaving."
					shouldQuit ifTrue:
						[ self
							snapshot: true
							andQuit: shouldQuit ] ] ]
]

{ #category : #'command line' }
SmalltalkImage >> runAndQuit: aBlock [ 
	self
		run: aBlock
		snapshotAs: nil
		andQuit: true
]

{ #category : #'sources, changes log' }
SmalltalkImage >> saveAs [
	"Put up the 'saveAs' prompt, obtain a name, and save the image  under that new name."
	^self saveAs: self getFileNameFromUser.

]

{ #category : #'sources, changes log' }
SmalltalkImage >> saveAs: newName [
	"Save the image  under that new name."
	newName ifNil:[^ self].
	(SourceFiles at: 2) ifNotNil:
		[self closeSourceFiles; "so copying the changes file will always work"
			 saveChangesInFileNamed: (self fullNameForChangesNamed: newName)].
	self saveImageInFileNamed: (self fullNameForImageNamed: newName)
]

{ #category : #'sources, changes log' }
SmalltalkImage >> saveAsEmbeddedImage [
	"Save the current state of the system as an embedded image"

	| dir newName newImageName oldImageSegDir haveSegs |
	dir := FileDirectory default.
	newName := UIManager default request: 'Select existing VM file'
				initialAnswer: (FileDirectory localNameFor: '').
	newName = '' ifTrue: [^Smalltalk].
	newName := FileDirectory baseNameFor: newName asFileName.
	newImageName := newName.
	(dir includesKey: newImageName) 
		ifFalse: 
			[^self 
				inform: 'Unable to find name ' , newName , ' Please choose another name.'].
	haveSegs := false.
	Smalltalk at: #NativeImageSegment
		ifPresent: 
			[:theClass | 
			(haveSegs := theClass instanceCount ~= 0) 
				ifTrue: [oldImageSegDir := theClass segmentDirectory]].
	self logChange: '----SAVEAS (EMBEDDED) ' , newName , '----' 
				, Date dateAndTimeNow printString.
	self imageName: (dir fullNameFor: newImageName) asSqueakPathName.
	LastImageName := self imageName.
	self closeSourceFiles.
	haveSegs 
		ifTrue: 
			[Smalltalk at: #NativeImageSegment
				ifPresent: 
					[:theClass | | newImageSegDir | 
					newImageSegDir := theClass segmentDirectory.	"create the folder"
					oldImageSegDir fileNames do: 
							[:theName | 
							"copy all segment files"

							newImageSegDir 
								copyFileNamed: oldImageSegDir pathName , FileDirectory slash , theName
								toFileNamed: theName]]].
	self 
		snapshot: true
		andQuit: true
		embedded: true
]

{ #category : #'sources, changes log' }
SmalltalkImage >> saveAsNewVersion [
	"Save the image/changes using the next available version number."
	"Smalltalk saveAsNewVersion"
	
	| newName changesName aName anIndex |
	aName := FileDirectory baseNameFor: (FileDirectory default localNameFor: self imageName).
	anIndex := aName lastIndexOf: FileDirectory dot asCharacter ifAbsent: [nil].
	(anIndex notNil and: [(aName copyFrom: anIndex + 1 to: aName size) isAllDigits])
		ifTrue:
			[aName := aName copyFrom: 1 to: anIndex - 1].

	newName := FileDirectory default nextNameFor: aName extension: FileDirectory imageSuffix.
	changesName := self fullNameForChangesNamed: newName.

	"Check to see if there is a .changes file that would cause a problem if we saved a new .image file with the new version number"
	(FileDirectory default fileOrDirectoryExists: changesName)
		ifTrue:
			[^ self inform:
'There is already .changes file of the desired name,
', newName, '
curiously already present, even though there is
no corresponding .image file.   Please remedy
manually and then repeat your request.'].

	(SourceFiles at: 2) ifNotNil:
		[self closeSourceFiles; "so copying the changes file will always work"
			saveChangesInFileNamed: (self fullNameForChangesNamed: newName)].
	self saveImageInFileNamed: (self fullNameForImageNamed: newName)



]

{ #category : #'snapshot and quit' }
SmalltalkImage >> saveAsSuggesting: aName [
	"Put up the 'saveAs' prompt, obtain a name, and save the image  under that new name."
	^self saveAs: (self getFileNameFromUserSuggesting: aName)
]

{ #category : #'sources, changes log' }
SmalltalkImage >> saveChangesInFileNamed: aString [
	| fullChangesName |
	fullChangesName := (FileDirectory default fullNameFor: aString).
	(FileDirectory default directoryNamed:(FileDirectory dirPathFor: fullChangesName )) assureExistence.
	FileDirectory default 
		copyFileWithoutOverwriteConfirmationNamed: self changesName 
		toFileNamed: fullChangesName.
	Smalltalk setMacFileInfoOn: fullChangesName.
]

{ #category : #'sources, changes log' }
SmalltalkImage >> saveImageInFileNamed: aString [
	| fullImageName |
	fullImageName := (FileDirectory default fullNameFor: aString).
	(FileDirectory default directoryNamed:(FileDirectory dirPathFor: fullImageName )) assureExistence.
	self
		changeImageNameTo: fullImageName;
		closeSourceFiles;
		openSourceFiles;  "so SNAPSHOT appears in new changes file"
		saveImageSegments;
		snapshot: true andQuit: false
]

{ #category : #'sources, changes log' }
SmalltalkImage >> saveImageSegments [

	| haveSegs oldImageSegDir |
	haveSegs := false.
	Smalltalk at: #NativeImageSegment ifPresent: [:theClass | 
		(haveSegs := theClass instanceCount ~= 0) ifTrue: [
			oldImageSegDir := theClass segmentDirectory]].
	haveSegs ifTrue: [
		Smalltalk at: #NativeImageSegment ifPresent: [:theClass | | newImageSegDir |
			newImageSegDir := theClass segmentDirectory.	"create the folder"
			oldImageSegDir fileNames do: [:theName | "copy all segment files"
				| imageSegmentName |
				imageSegmentName := oldImageSegDir pathName, FileDirectory slash, theName.
				newImageSegDir 
					copyFileWithoutOverwriteConfirmationNamed: imageSegmentName
					toFileNamed: theName]]].

]

{ #category : #'snapshot and quit' }
SmalltalkImage >> saveSession [
	self snapshot: true andQuit: false
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> send: startUpOrShutDown toClassesNamedIn: startUpOrShutDownList with: argument [
	"Send the message #startUp: or #shutDown: to each class named in the list.
	The argument indicates if the system is about to quit (for #shutDown:) or if
	the image is resuming (for #startUp:).
	If any name cannot be found, then remove it from the list."

	| removals |
	removals := OrderedCollection new.
	startUpOrShutDownList do:
		[:name | | class |
		class := self at: name ifAbsent: [nil].
		class == nil
			ifTrue: [removals add: name]
			ifFalse: [class isInMemory ifTrue:
						[class perform: startUpOrShutDown with: argument]]].

	"Remove any obsolete entries, but after the iteration"
	startUpOrShutDownList removeAll: removals
]

{ #category : #'system attributes' }
SmalltalkImage >> sendMouseWheelEvents [
	"The Cog VM can be instructed to deliver mouse wheel events as mouse wheel events.
	 By default mouse wheel events are mapped to arrow events.
	 This flag persists across snapshots, stored in the image header."

	^(self vmParameterAt: 48) anyMask: 32
]

{ #category : #'system attributes' }
SmalltalkImage >> sendMouseWheelEvents: aBoolean [
	"The Cog VM can be instructed to deliver mouse wheel events as mouse wheel events.
	 By default mouse wheel events are mapped to arrow events.
	 This flag persists across snapshots, stored in the image header."

	self vmParameterAt: 48 put: ((self vmParameterAt: 48) bitClear: 32) + (aBoolean ifTrue: [32] ifFalse: [0])
]

{ #category : #'memory space' }
SmalltalkImage >> setGCBiasToGrow: aNumber [
	"Primitive. Indicate that the GC logic should be bias to grow"
	<primitive: 'primitiveSetGCBiasToGrow'>
	^self primitiveFailed
"Example:
	Smalltalk setGCBiasToGrowGCLimit: 16*1024*1024.
	Smalltalk setGCBiasToGrow: 1.
"
]

{ #category : #'memory space' }
SmalltalkImage >> setGCBiasToGrowGCLimit: aNumber [
	"Primitive. Indicate that the bias to grow logic should do a GC after aNumber Bytes"
	<primitive: 'primitiveSetGCBiasToGrowGCLimit'>
	^self primitiveFailed
"Example:
	Smalltalk setGCBiasToGrowGCLimit: 16*1024*1024.
"
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> setGCParameters [
	"Adjust the VM's default GC parameters to avoid too much tenuring.
	 Maybe this should be left to the VM?"

	| proportion edenSize survivorSize averageObjectSize numObjects |
	proportion := 0.9. "tenure when 90% of pastSpace is full"
	edenSize := SmalltalkImage current vmParameterAt: 44.
	survivorSize := edenSize / 5.0. "David's paper uses 140Kb eden + 2 x 28kb survivor spaces; Spur uses the same ratios :-)"
	averageObjectSize := 8 * self wordSize. "a good approximation"
	numObjects := (proportion * survivorSize / averageObjectSize) rounded.
	SmalltalkImage current vmParameterAt: 6 put: numObjects  "tenure when more than this many objects survive the GC"
]

{ #category : #'memory space' }
SmalltalkImage >> setGCSemaphore: semaIndex [
	"Primitive. Indicate the GC semaphore index to be signaled on GC occurance."
	<primitive: 'primitiveSetGCSemaphore'>
	^self primitiveFailed
"Example:

	| index sema process |
	sema := Semaphore new.
	index := Smalltalk registerExternalObject: sema.
	Smalltalk setGCSemaphore: index.
	process := [
		[[true] whileTrue:[
			sema wait.
			Smalltalk beep.
		]] ensure:[
			Smalltalk setGCSemaphore: 0.
			Smalltalk unregisterExternalObject: sema.
		].
	] fork.
	process inspect.
"
]

{ #category : #'sources, changes log' }
SmalltalkImage >> setMacFileInfoOn: aString [
	"On Mac, set the file type and creator (noop on other platforms)"
	FileDirectory default
		setMacFileNamed: aString
		type: 'STch'
		creator: 'FAST'.
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> setPlatformPreferences [
	"Set some platform specific preferences on system startup"
	| platform specs |
	Preferences automaticPlatformSettings ifFalse:[^self].
	platform := self platformName.
	specs := 	#().
	platform = 'Win32' ifTrue:[
		specs := #()].
	platform = 'Mac OS' ifTrue:[
		specs := #()].
	specs do:[:tuple|
		Preferences setPreference: tuple first toValue: (tuple last == true).
	].

]

{ #category : #shrinking }
SmalltalkImage >> shrink [
	"Clean up everything we know how to clean up that can be restored."
	"Prepare unloading"
	self zapMVCprojects.
	Flaps disableGlobalFlaps: false.
	self unloadReloadablePackages.
	"Post-unload aggressive cleanup"
	Smalltalk cleanUp: true.
	SystemOrganization removeSystemCategory: Object categoryForUniclasses.
	Smalltalk at: #ScheduledControllers ifPresent: [Smalltalk at: #ScheduledControllers put: nil].
	Smalltalk garbageCollect
]

{ #category : #shrinking }
SmalltalkImage >> shrinkAndCleanDesktop [
	| world |
	world := Project current world.
	world removeAllMorphs.
	self shrink.
	MorphicProject defaultFill: (Color gray: 0.9).
	world color: (Color gray: 0.9)
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> shutDown [

	^ self closeSourceFiles
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> shutDownSound [
	"No longer used in the release, but retained for backward compatibility."

	SoundService default shutDown

]

{ #category : #'memory space' }
SmalltalkImage >> signalLowSpace [
	"Signal the low-space semaphore to alert the user that space is running low."

	LowSpaceSemaphore signal.
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> snapshot: save andQuit: quit [
	^self snapshot: save andQuit: quit embedded: false
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> snapshot: save andQuit: quit embedded: embeddedFlag [

	^self	
		snapshot: save
		andQuit: quit
		withExitCode: nil
		embedded: embeddedFlag
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> snapshot: save andQuit: quit withExitCode: exitCode embedded: embeddedFlag [
	"Mark the changes file and close all files as part of #processShutdownList.
	If save is true, save the current state of this Smalltalk in the image file.
	If quit is true, then exit to the outer OS shell.
	If exitCode is not nil, then use it as exit code.
	The latter part of this method runs when resuming a previously saved image. This resume logic checks for a document file to process when starting up."

	| resuming msg |
	Object flushDependents.
	Object flushEvents.

	(SourceFiles at: 2) ifNotNil:[
		msg := String streamContents: [ :s |
			s nextPutAll: '----';
			nextPutAll: (save ifTrue: [ quit ifTrue: [ 'QUIT' ] ifFalse: [ 'SNAPSHOT' ] ]
							ifFalse: [quit ifTrue: [ 'QUIT/NOSAVE' ] ifFalse: [ 'NOP' ]]);
			nextPutAll: '----';
			print: Date dateAndTimeNow; space;
			nextPutAll: (FileDirectory default localNameFor: self imageName);
			nextPutAll: ' priorSource: ';
			print: LastQuitLogPosition ].
		self assureStartupStampLogged.
		save ifTrue: [ LastQuitLogPosition := (SourceFiles at: 2) setToEnd; position ].
		self logChange: msg.
		Transcript cr; show: msg
	].

	Smalltalk processShutDownList: quit.
	Cursor write show.
	save ifTrue: [resuming := embeddedFlag 
					ifTrue: [self snapshotEmbeddedPrimitive] 
					ifFalse: [self snapshotPrimitive]]  "<-- PC frozen here on image file"
		ifFalse: [resuming := false].
	quit & (resuming == false) ifTrue: [
		exitCode
			ifNil: [ self quitPrimitive ]
			ifNotNil: [ self quitPrimitive: exitCode ] ].
	Cursor normal show.
	Smalltalk setGCParameters.
	resuming == true ifTrue: [Smalltalk clearExternalObjects].
	Smalltalk processStartUpList: resuming == true.
	resuming == true ifTrue:[
		self setPlatformPreferences.
		self recordStartupStamp].
	Project current wakeUpTopWindow.
	"Now it's time to raise an error"
	resuming == nil ifTrue: [self error:'Failed to write image file (disk full?)'].
	^ resuming
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> snapshot: save andQuitWithExitCode: exitCode [

	^self
		snapshot: save
		andQuit: true
		withExitCode: exitCode
		embedded: false
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> snapshotEmbeddedPrimitive [
	<primitive: 247>
	^nil "indicates error writing embedded image file"
]

{ #category : #'snapshot and quit' }
SmalltalkImage >> snapshotPrimitive [
	"Primitive. Write the current state of the object memory on a file in the
	same format as the Smalltalk-80 release. The file can later be resumed,
	returning you to this exact state. Return normally after writing the file.
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 97>
	^nil "indicates error writing image file"
]

{ #category : #'image, changes names' }
SmalltalkImage >> sourceFileVersionString [

	^ SourceFileVersionString
]

{ #category : #'image, changes names' }
SmalltalkImage >> sourceFileVersionString: aString [

	SourceFileVersionString := aString
]

{ #category : #'image, changes names' }
SmalltalkImage >> sourcesName [
	"Answer the full path to the version-stable source code if it exists, otherwise the desired location"
	^ self locateSourcesEntry
		ifNil: [ self vmPath , SourceFileVersionString , FileDirectory dot , 'sources' ]
		ifNotNil: [ : entry | entry fullName ]
]

{ #category : #'special objects' }
SmalltalkImage >> specialNargsAt: anInteger [ 
	"Answer the number of arguments for the special selector at: anInteger."

	^ (self specialObjectsArray at: 24) at: anInteger * 2
]

{ #category : #'special objects' }
SmalltalkImage >> specialObjectsArray [  "Smalltalk specialObjectsArray at: 1"
	<primitive: 129>
	^ self primitiveFailed
]

{ #category : #'special objects' }
SmalltalkImage >> specialSelectorAt: anInteger [ 
	"Answer the special message selector from the interleaved specialSelectors array."

	^ (self specialObjectsArray at: 24) at: anInteger * 2 - 1
]

{ #category : #'special objects' }
SmalltalkImage >> specialSelectorNames [
	"Return a collection with the names of the special selectors."
	
	| arrayOfPairs |
	arrayOfPairs := self specialSelectors.
	^Array new: arrayOfPairs size // 2 streamContents: [ :stream |
		arrayOfPairs pairsDo: [ :selector :numArgs |
			stream nextPut: selector ] ]

]

{ #category : #'special objects' }
SmalltalkImage >> specialSelectorSize [
	"Answer the number of special selectors in the system."

	^ (self specialObjectsArray at: 24) size // 2
]

{ #category : #'special objects' }
SmalltalkImage >> specialSelectors [
	"Return an array with flattened special selector - argument count pairs. VMMaker relies on this."
	
	^self specialObjectsArray at: 24
]

{ #category : #miscellaneous }
SmalltalkImage >> squeakErrorFileName [
	"Answer the file name used to dump error reports"

	^ Preferences debugLogTimestamp
		ifTrue: ['SqueakDebug-' , Time totalSeconds printString , '.log']
		ifFalse: ['SqueakDebug.log'].
]

{ #category : #'vm profiling' }
SmalltalkImage >> startProfiling [
	"Start profiling the virtual machine."

	<primitive: 252>

]

{ #category : #'vm profiling' }
SmalltalkImage >> stopProfiling [
	"Stop profiling the virtual machine."

	<primitive: 253>

]

{ #category : #miscellaneous }
SmalltalkImage >> storeDataOn: aDataStream [
	"I don't get stored.  Use a DiskProxy"

	self error: 'use a DiskProxy to store me'
]

{ #category : #'system attributes' }
SmalltalkImage >> supportsMultipleBytecodeSets [
	"Answer whether the VM supports multiple bytecodeSets."
	"SmalltalkImage current supportsMultipleBytecodeSets"

	^(self vmParameterAt: 65)
		ifNil: [false]
		ifNotNil:
			[:param| "In older VMs this is a boolean answering the vm-internal MULTIPLE_BYTECODE_SETS define"
			 param isInteger "In newer VMs it is a set of integer flags, bit 0 of which is the vm-internal MULTIPLE_BYTECODE_SETS define"
				ifTrue: [param anyMask: 1]
				ifFalse: [param]]
]

{ #category : #'system attributes' }
SmalltalkImage >> supportsQueueingFinalization [
	"Answer whether the VM queues individual weak arrays for finalization, instead
	 of signalling the finalization semaphore once for all arrays and having the
	 WeakRegistry mechanism finalize all weak arrays, whether they need to or not."
	"SmalltalkImage current supportsQueueingFinalization"

	^(self vmParameterAt: 48) anyMask: 16
]

{ #category : #'system attributes' }
SmalltalkImage >> supportsQueueingFinalization: aBoolean [
	"Determine whether the VM queues individual weak arrays for finalization, instead
	 of signalling the finalization semaphore once for all arrays and having the
	 WeakRegistry mechanism finalize all weak arrays, whether they need to or not.
	 This flag persists across snapshots, stored in the image header."
	"SmalltalkImage current supportsQueueingFinalization: true"

	self vmParameterAt: 48 put: ((self vmParameterAt: 48) bitClear: 16) + (aBoolean ifTrue: [16] ifFalse: [0])
]

{ #category : #'system attributes' }
SmalltalkImage >> supportsReadOnlyObjects [
	"Answer whether the VM observes the per-object read-only flag and consequently aborts
	 writes to inst vars of, and fails primitives that attempt to modify, read-only objects."
	"SmalltalkImage current supportsReadOnlyObjects"

	^(self vmParameterAt: 65)
		ifNil: [false]
		ifNotNil:
			[:param| "In older VMs this is a boolean answering the vm-internal MULTIPLE_BYTECODE_SETS define"
			 param isInteger "In newer VMs it is a set of integer flags, bit 1 of which is the vm-internal IMMUTABILITY define"
				ifTrue: [param anyMask: 2]
				ifFalse: [false]]
]

{ #category : #'sources, changes log' }
SmalltalkImage >> systemInformationString [
	"Identify software version"
	^ SystemVersion current version, String cr, self lastUpdateString, String cr, self currentChangeSetString

"
	(eToySystem := self at: #EToySystem ifAbsent: [nil]) ifNotNil:
		[aString := aString, '
Squeak-Central version: ', eToySystem version, ' of ', eToySystem versionDate]."
]

{ #category : #'vm statistics' }
SmalltalkImage >> textMarkerForShortReport [

	^  'Since last view	'
]

{ #category : #'sources, changes log' }
SmalltalkImage >> timeStamp: aStream [ 
	"Writes system version and current time on stream aStream."

	| dateTime |
	dateTime := Time dateAndTimeNow.
	aStream nextPutAll: 'From ', self datedVersion, ' [', self lastUpdateString, '] on ', (dateTime at: 1) printString,
						' at ', (dateTime at: 2) printString
]

{ #category : #'classes and traits' }
SmalltalkImage >> traitNames [
	"Answer a SortedCollection of all traits (not including class-traits) names."

	^globals traitNames
]

{ #category : #modules }
SmalltalkImage >> unbindExternalPrimitives [
	"Primitive. Force all external primitives to be looked up again afterwards. Since external primitives that have not found are bound for fast failure this method will force the lookup of all primitives again so that after adding some plugin the primitives may be found."
	<primitive: 570>
	"Do nothing if the primitive fails for compatibility with older VMs"

]

{ #category : #shrinking }
SmalltalkImage >> unloadFonts [	"Smalltalk unloadFonts"

	"Unloads all fonts except the style specified initially."

	| fontName fontSize textStyle |
	"Three good choices here:
		* Atlanta 11: Absolutely minimal font.
		* Accuny 10: A few extra sizes over Atlanta.
		* Bitmap DejaVu Sans 9: Nicest fonts but relatively large.
	"
	fontName := #'Bitmap DejaVu Sans'.
	fontSize := 9.

	"Nuke everything other than the desired text style"
	textStyle := TextStyle named: fontName.
	TextStyle defaultFamilyNames do:[:styleName| 
		TextConstants at: styleName put: textStyle
	].
	TextStyle actualTextStyles keys do:[:styleName| 
		TextConstants removeKey: styleName
	].
	TextConstants at: fontName put: textStyle.

	"Use it everywhere"
	Preferences setDefaultFonts: {
		{#setSystemFontTo:.		fontName.	fontSize}.
		{#setListFontTo:.			fontName.	fontSize}.
		{#setFlapsFontTo:.			fontName.	fontSize}.
		{#setEToysFontTo:.			fontName.	fontSize}.
		{#setEToysTitleFontTo:	.	fontName.	fontSize}.
		{#setPaintBoxButtonFontTo:. fontName.	fontSize}.
		{#setMenuFontTo:.			fontName.	fontSize}.
		{#setWindowTitleFontTo:.	fontName.	fontSize}.
		{#setBalloonHelpFontTo:.	fontName.	fontSize}.
		{#setCodeFontTo:.			fontName.	fontSize}.
		{#setButtonFontTo:.		fontName.	fontSize}.
	}.

	"Clean out afterwards"
	Smalltalk at: #TextEditor ifPresent:[:aClass| aClass initialize].
	Smalltalk at: #SmalltalkEditor ifPresent:[:aClass| aClass initialize].
	Smalltalk at: #SystemProgressMorph ifPresent:[:aClass| aClass reset].
	Smalltalk at: #TTCFont ifPresent:[:aClass| aClass registry removeAll].
	Smalltalk at: #Flaps ifPresent:[:aClass | aClass disableGlobalFlaps: false].
	Smalltalk at: #TTFontDescription ifPresent:[:aClass| aClass clearDefault].
	Smalltalk at: #TTFontDescription ifPresent:[:aClass| aClass clearDescriptions].

]

{ #category : #modules }
SmalltalkImage >> unloadModule: aString [
	"Primitive. Unload the given module.
	This primitive is intended for development only since some
	platform do not implement unloading of DLL's accordingly.
	Also, the mechanism for unloading may not be supported
	on all platforms."
	<primitive: 571>
	^self primitiveFailed
]

{ #category : #shrinking }
SmalltalkImage >> unloadReloadablePackages [
	"Unload packages which can be reloaded."

	"One special case to make Services-Base unload"
	Smalltalk
		at: #ServiceRegistry
		ifPresent: [ : aClass | SystemChangeNotifier uniqueInstance noMoreNotificationsFor: aClass ].

	#('CompressionTests'
'CollectionsTests'
'GraphicsTests'
'BalloonTests'
'HelpSystem-Tests'
'KernelTests'
'MorphicExtrasTests'
'MorphicTests'
'MultilingualTests'
'NetworkTests'
'ToolsTests'
'TraitsTests'
'SystemChangeNotification-Tests'
'VersionNumberTests'
'ST80Tests'
"'Tests'" "Currently not unloadable"

'FlexibleVocabularies'
'ReleaseBuilder'
'ScriptLoader'
'UpdateStream'
'CommandLine'
'45Deprecated'
'311Deprecated'
'39Deprecated'
'Universes'
'SMLoader'
'SMBase'
'Services-Base'
'Nebraska'
'ToolBuilder-MVC'
'ST80Tools'
'ST80'
"'EToys'" "Currently not unloadable"
"'PreferenceBrowser'" "Etoys needs them, hence not unloadable"
"'Protocols'" "Etoys needs them, hence not unloadable"
'XML-Parser'
'Help-Squeak-TerseGuide'
'Help-Squeak-Project'
'HelpSystem-Core'
'SystemReporter'
'SUnitGUI'
'VersionNumber' ) do: [ : pkgName | Installer mc unload: pkgName ].
	"Traits use custom unload"
	Smalltalk
		at: #Trait
		ifPresent: [ : aClass | aClass unloadTraits ]
]

{ #category : #'external objects' }
SmalltalkImage >> unregisterExternalObject: anObject [
	"Unregister the given object in the external objects array. Do nothing if it isn't registered."

	ExternalObjectTable current unregisterExternalObject: anObject
]

{ #category : #'external objects' }
SmalltalkImage >> unregisterExternalObjects: aCollection [
	"Unregister the given objects from the external objects array. Do nothing if they aren't registered."

	ExternalObjectTable current unregisterExternalObjects: aCollection
]

{ #category : #shrinking }
SmalltalkImage >> unusedClasses [
	"Enumerates all classes in the system and returns a list of those that are 
	apparently unused. A class is considered in use if it (a) has subclasses 
	or (b) is referred to by some method or (c) has its name in use as a 
	literal. "
	"Smalltalk unusedClasses asSortedCollection"
	^ self systemNavigation allUnusedClassesWithout: {{}. {}}
]

{ #category : #'memory space' }
SmalltalkImage >> useUpMemory [
	"For testing the low space handler..."
	"Smalltalk installLowSpaceWatcher; useUpMemory"

	| lst |
	lst := nil.
	[ lst := Link nextLink: lst ] repeat
]

{ #category : #'memory space' }
SmalltalkImage >> useUpMemoryWithArrays [ 
	"For testing the low space handler..."
	"Smalltalk installLowSpaceWatcher; useUpMemoryWithArrays"

	| b |  "First use up most of memory."
	b := String new: self bytesLeft - self lowSpaceThreshold - 100000.
	b := b.  "Avoid unused value warning"
	(1 to: 10000) collect: [:i | Array new: 10000]
]

{ #category : #'memory space' }
SmalltalkImage >> useUpMemoryWithContexts [ 
	"For testing the low space handler..."
	"Smalltalk installLowSpaceWatcher; useUpMemoryWithContexts"

	self useUpMemoryWithContexts
]

{ #category : #'memory space' }
SmalltalkImage >> useUpMemoryWithTinyObjects [ 
	"For testing the low space handler..."
	"Smalltalk installLowSpaceWatcher; useUpMemoryWithTinyObjects"

	| b |  "First use up most of memory."
	b := String new: self bytesLeft - self lowSpaceThreshold - 100000.
	b := b.  "Avoid unused value warning"
	(1 to: 10000) collect: [:i | BitBlt new]
]

{ #category : #housekeeping }
SmalltalkImage >> verifyChanges [		"Smalltalk verifyChanges"
	"Recompile all methods in the changes file."
	self systemNavigation allBehaviorsDo: [:class | class recompileChanges].

]

{ #category : #miscellaneous }
SmalltalkImage >> verifyMorphicAvailability [
	"If Morphic is available, return true; if not, put up an informer and return false"
	self hasMorphic ifFalse:
		[Beeper beep.
		self inform: 'Sorry, Morphic must
be present to use this feature'.
		^ false].
	^ true
]

{ #category : #image }
SmalltalkImage >> version [
	"Answer the version of this release."

	^SystemVersion current version
]

{ #category : #vm }
SmalltalkImage >> versionLabel [
	"Answer a string corresponding to the version of virtual machine. This
	represents the version level of the Smalltalk source code (interpreter
	and various plugins) that is translated to C by a CCodeGenerator,  in
	addition to the external platform source code, typically written in C and
	managed separately for each platform.
	
	This invokes an optional primitive that may not be available on all virtual
	machines. See also vmVersion, which answers a string identifying the image
	from which virtual machine sources were generated."

	"Smalltalk vm versionLabel"

	<primitive: 'primitiveVMVersion'>
	self notify: 'This virtual machine does not support the optional primitive #primitiveVMVersion' translated.
	^''
]

{ #category : #miscellaneous }
SmalltalkImage >> veryDeepCopyWith: deepCopier [
	"Return self.  I can't be copied.  Do not record me."
]

{ #category : #vm }
SmalltalkImage >> vm [
	"Answer the object to query about virtual machine."
	
	^self
]

{ #category : #'command line' }
SmalltalkImage >> vmFileName [
	"Answer the absolute file name of the the Smalltalk virtual machine"
	"Smalltalk vmFileName"

	^ self primVmFileName vmPathToSqueakPath

]

{ #category : #'vm parameters' }
SmalltalkImage >> vmParameterAt: parameterIndex [
	"parameterIndex is a positive integer corresponding to one of the VM's internal parameter/metric registers.
	 Answer with the current value of that register.  Fail if parameterIndex has no corresponding register.
	 VM parameters are numbered as follows:
		1	byte size of old-space (read-only)
		2	byte size of young-space (read-only)
		3	byte size of object memory (read-only)
		4	allocationCount (read-only; nil in Cog VMs)
		5	allocations between GCs (read-write; nil in Cog VMs)
		6	survivor count tenuring threshold (read-write)
		7	full GCs since startup (read-only)
		8	total milliseconds in full GCs since startup (read-only)
		9	incremental GCs since startup (read-only; scavenging GCs on Spur)
		10	total milliseconds in incremental/scavenging GCs since startup (read-only)
		11	tenures of surving objects since startup (read-only)
		12-15 specific to the translating VM
		16	total microseconds in idle since startup
		17	proportion of code zone available for use (Sista VMs only; read-write)
		18	total milliseconds in full GC compaction since startup (a portion of parameter 8)
		19	scavenge threshold; the effective size of eden
		20	utc microseconds at VM start-up (actually at time initialization, which precedes image load) (newer Cog VMs only).
		21	root (remembered) table size (read-only)
		22	root (remembered) table overflows since startup (read-only)
		23	bytes of extra memory to reserve for VM buffers, plugins, etc.
		24	memory threshold above which to shrink object memory (read-write)
		25	ammount to grow by when growing object memory (read-write)
		26	interruptChecksEveryNms - force an ioProcessEvents every N milliseconds (read-write)
		27	number of times mark loop iterated for current IGC/FGC (read-only) includes ALL marking
		28	number of times sweep loop iterated for current IGC/FGC (read-only)
		29	number of times make forward loop iterated for current IGC/FGC (read-only)
		30	number of times compact move loop iterated for current IGC/FGC (read-only)
		31	number of grow memory requests (read-only)
		32	number of shrink memory requests (read-only)
		33	number of root table entries used for current IGC/FGC (read-only)
		34	bytes allocated in total since start-up or reset (read-write)
		35	number of survivor objects after current IGC/FGC (read-only)
		36	millisecond clock when current IGC/FGC completed (read-only)
		37	number of marked objects for Roots of the world, not including Root Table entries for current IGC/FGC (read-only)
		38	milliseconds taken by current IGC (read-only)
		39	Number of finalization signals for Weak Objects pending when current IGC/FGC completed (read-only)
		40	BytesPerWord for this image
		41	imageFormatVersion for the VM
		42	number of stack pages in use (Cog Stack VM only, otherwise nil)
		43	desired number of stack pages (stored in image file header, max 65535; Cog VMs only, otherwise nil)
		44	size of eden, in bytes (Cog VMs only, otherwise nil)
		45	desired size of eden, in bytes (stored in image file header; Cog VMs only, otherwise nil)
		46	size of machine code zone, in bytes (stored in image file header; Cog JIT VM only, otherwise nil)
		47	desired size of machine code zone, in bytes (applies at startup only, stored in image file header; Cog JIT VM only)
		48	various properties stored in the image header (that instruct the VM) as an integer encoding an array of bit flags.
			Bit 0: tells the VM that the image's Process class has threadId as its 5th inst var (after nextLink, suspendedContext, priority & myList)
			Bit 1: on Cog JIT VMs asks the VM to set the flag bit in interpreted methods
			Bit 2: if set, preempting a process puts it to the head of its run queue, not the back,
					i.e. preempting a process by a higher priority one will not cause the preempted process to yield
						to others at the same priority.
			Bit 3: in a muilt-threaded VM, if set, the Window system will only be accessed from the first VM thread
			Bit 4: in a Spur vm, if set, causes weaklings and ephemerons to be queued individually for finalization
			Bit 5: if set, implies wheel events will be delivered as such and not mapped to arrow key events
			Bit 6: if set, implies arithmetic primitives will fail if given arguments of different types (float vs int)
		49	the size of the external semaphore table (read-write; Cog VMs only)
		50-51 reserved for VM parameters that persist in the image (such as eden above)
		52	root (remembered) table maximum size (read-only)
		53	the number of oldSpace segments (Spur only, otherwise nil)
		54	total size of free old space (Spur only, otherwise nil)
		55	ratio of growth and image size at or above which a GC will be performed post scavenge (Spur only, otherwise nil)
		56	number of process switches since startup (read-only)
		57	number of ioProcessEvents calls since startup (read-only)
		58	number of forceInterruptCheck (Cog VMs) or quickCheckInterruptCalls (non-Cog VMs) calls since startup (read-only)
		59	number of check event calls since startup (read-only)
		60	number of stack page overflows since startup (read-only; Cog VMs only)
		61	number of stack page divorces since startup (read-only; Cog VMs only)
		62	number of machine code zone compactions since startup (read-only; Cog VMs only)
		63	milliseconds taken by machine code zone compactions since startup (read-only; Cog VMs only)
		64	current number of machine code methods (read-only; Cog VMs only)
		65	In newer Cog VMs a set of flags describing VM features,
				if non-zero bit 0 implies multiple bytecode set support;
				if non-zero bit 1 implies read-only object support;
				if non-zero bit 2 implies the VM suffers from using an ITIMER heartbeat (if 0 it has a thread that provides the heartbeat)
			(read-only; Cog VMs only; nil in older Cog VMs, a boolean answering multiple bytecode support in not so old Cog VMs)
		66	the byte size of a stack page in the stack zone  (read-only; Cog VMs only)
		67	the maximum allowed size of old space in bytes, 0 implies no internal limit (Spur VMs only).
		68	the average number of live stack pages when scanned by GC (at scavenge/gc/become et al)
		69	the maximum number of live stack pages when scanned by GC (at scavenge/gc/become et al)
		70	the value of VM_PROXY_MAJOR (the interpreterProxy major version number)
		71	the value of VM_PROXY_MINOR (the interpreterProxy minor version number)
		72 total milliseconds in full GCs Mark phase since startup (read-only)
		73 total milliseconds in full GCs Sweep phase since startup (read-only, can be 0 depending on compactors)
		74 maximum pause time due to segment allocation"

	<primitive: 254>
	self primitiveFailed
]

{ #category : #'vm parameters' }
SmalltalkImage >> vmParameterAt: parameterIndex put: newValue [
	"parameterIndex is a positive integer corresponding to one of the VM's internal
	parameter/metric registers.  Store newValue (a positive integer) into that
	register and answer with the previous value that was stored there.
	Fail if newValue is out of range, if parameterIndex has no corresponding
	register, or if the corresponding register is read-only.

	As of mid 2017 the parameters which can be set are
		5	allocations between GCs (read-write; nil in Cog VMs)
		6	survivor count tenuring threshold (read-write)
		17	proportion of code zone available for use (Sista VMs only)
		23	bytes of extra memory to reserve for VM buffers, plugins, etc.
		24	memory threshold above whichto shrink object memory (read-write)
		25	memory headroom when growing object memory (read-write)
		26	interruptChecksEveryNms - force an ioProcessEvents every N milliseconds (read-write)
		34	bytes allocated in total since start-up or reset (read-write)
		43	desired number of stack pages (stored in image file header, max 65535; Cog VMs only, otherwise nil)
		45	desired size of eden, in bytes (stored in image file header; Cog VMs only, otherwise nil)
		47	desired size of machine code zone, in bytes (applies at startup only, stored in image file header; Cog JIT VM only)
		48	various properties of the Cog VM as an integer encoding an array of bit flags.
			Bit 0: tells the VM that the image's Process class has threadId as its 5th inst var (after nextLink, suspendedContext, priority & myList)
			Bit 1: on Cog JIT VMs asks the VM to set the flag bit in interpreted methods
			Bit 2: if set, preempting a process puts it to the head of its run queue, not the back,
					i.e. preempting a process by a higher priority one will not cause the preempted process to yield
						to others at the same priority.
			Bit 3: in a muilt-threaded VM, if set, the Window system will only be accessed from the first VM thread
			Bit 4: in a Spur vm, if set, causes weaklings and ephemerons to be queued individually for finalization
		49	the size of the external semaphore table (read-write; Cog VMs only)
		55	ratio of growth and image size at or above which a GC will be performed post scavenge (Spur only, otherwise nil)
		67	the maximum allowed size of old space in bytes, 0 implies no internal limit (Spur only)."

	<primitive: 254>
	self primitiveFailed
]

{ #category : #'command line' }
SmalltalkImage >> vmPath [
	"Answer the path for the directory containing the Smalltalk virtual machine, making sure to convert the vm string to a Squeak string as required."
	"Smalltalk vmPath"

	^self primVmPath vmPathToSqueakPath

]

{ #category : #'vm statistics' }
SmalltalkImage >> vmStatisticsReportOn: str [
	"(Workspace new contents: Smalltalk vmStatisticsReportString)
		openLabel: 'VM Statistics'"
	"StringHolderView
		open: (StringHolder new contents: Smalltalk vmStatisticsReportString)
		label: 'VM Statistics'"

	| params oldSpaceEnd youngSpaceEnd memorySize fullGCs fullGCTime fullGCCompactionTime incrGCs incrGCTime tenureCount upTime
	  upTime2 fullGCs2 fullGCTime2  incrGCs2 incrGCTime2 tenureCount2 freeSize youngSize used spur timeReporter idleMs idleMs2 codeCompactionTime codeCompactionsOrNil codeCompactionTime2 codeCompactions2 maxParams |
	"Pad to protect for a VM that does not answer the expected parameter array"
	maxParams := 63. "max position referenced in this method"
	params := Array streamContents: [ :strm |
				strm nextPutAll: Smalltalk getVMParameters.
				[strm position < maxParams] whileTrue: [strm nextPut: nil]].
	oldSpaceEnd			:= params at: 1.
	youngSpaceEnd		:= params at: 2.
	memorySize			:= params at: 3.
	fullGCs				:= params at: 7.
	fullGCTime			:= params at: 8.
	incrGCs				:= params at: 9.
	incrGCTime			:= params at: 10.
	tenureCount			:= params at: 11.
	fullGCCompactionTime	:= params at: 18.
	codeCompactionsOrNil	:= params at: 62.
	codeCompactionTime	:= params at: 63.
	
	upTime := (params at: 20) ~= 0 "utcMicrosecondClock at startup in later Spur VMs"
				ifTrue: [Time utcMicrosecondClock - (params at: 20) + 500 // 1000]
				ifFalse: [Time eventMillisecondClock]. "Fall back on old microsecond clock; Good for 47.5 days"
	spur := (params at: 41)
				ifNotNil: [ :p | p anyMask: 16]
				ifNil: [false].
	timeReporter := [:time| | seconds |
					seconds := time / 1000.
					seconds >= (60*60*24)
						ifTrue:
							[str print: seconds / 60 // 60 // 24; nextPut: $d; space;
								print: seconds / 60 // 60 \\ 24; nextPut: $h; space]
						ifFalse:
							[seconds >= (60*60) ifTrue:
								[str print: (seconds / 60 // 60); nextPut: $h; space]].
					str
						print: (seconds / 60 \\ 60) asInteger; nextPut: $m; space;
						print: (seconds \\ 60) asInteger; nextPut: $s].
	str	nextPutAll: 'uptime		'.
	timeReporter value: upTime.
	(idleMs := params at: 16) ~= 0 ifTrue:
		[str tab; nextPutAll: '(runtime '.
		 idleMs := idleMs // 1000.
		 timeReporter value: upTime - idleMs.
		 str nextPutAll: ', idletime '.
		 timeReporter value: idleMs.
		 str nextPut: $)].
	str cr.

	str	nextPutAll: 'memory		';
		nextPutAll: (self formatVMParameter: memorySize); nextPutAll: ' bytes'; cr.
	str	nextPutAll:	'	old			';
		nextPutAll: (self formatVMParameter: oldSpaceEnd); nextPutAll: ' bytes (';
		print: oldSpaceEnd / memorySize * 100 maxDecimalPlaces: 1; nextPutAll: '%)'; cr.

	spur ifTrue:
		[(youngSize := (params at: 19)  * 7 // 5) = 0 ifTrue: [params at: 44].
		 youngSize := youngSize roundUpTo: 1024.
		 str	nextPutAll: '	young		';
			nextPutAll: (self formatVMParameter: youngSize); nextPutAll: ' bytes (';
			print: youngSize / memorySize * 100 maxDecimalPlaces: 1; nextPutAll: '%)'; cr.
		youngSize := youngSpaceEnd. "used eden"
		freeSize := (params at: 54) + (params at: 44) - youngSize.
		used := youngSize + oldSpaceEnd - freeSize.
		str	nextPutAll: '	used		';
			nextPutAll: (self formatVMParameter: used); nextPutAll: ' bytes (';
			print: used / memorySize * 100 maxDecimalPlaces: 1; nextPutAll: '%)'; cr.
		str	nextPutAll: '	free		';
			nextPutAll: (self formatVMParameter: freeSize); nextPutAll: ' bytes (';
			print: freeSize / memorySize * 100 maxDecimalPlaces: 1; nextPutAll: '%)'; cr]
		ifFalse: "Earlier VM and V3 object memory"
		[str	nextPutAll: '	young		';
			nextPutAll: (self formatVMParameter: (youngSpaceEnd - oldSpaceEnd)); nextPutAll: ' bytes (';
			print: (youngSpaceEnd - oldSpaceEnd / memorySize * 100) maxDecimalPlaces: 1; nextPutAll: '%)'; cr.
		str	nextPutAll: '	used		';
			nextPutAll: (self formatVMParameter: youngSpaceEnd); nextPutAll: ' bytes (';
			print: (youngSpaceEnd / memorySize * 100) maxDecimalPlaces: 1; nextPutAll: '%)'; cr.
		str	nextPutAll: '	free		';
			nextPutAll: (self formatVMParameter: (memorySize - youngSpaceEnd)); nextPutAll: ' bytes (';
			print: (memorySize - youngSpaceEnd / memorySize * 100) maxDecimalPlaces: 1; nextPutAll: '%)'; cr].

	str	nextPutAll: 'GCs			';
		nextPutAll: (self formatVMParameter: (fullGCs + incrGCs)).
	fullGCs + incrGCs > 0 ifTrue:
		[str
			nextPutAll: ' ('; 
			print: upTime / (fullGCs + incrGCs) maxDecimalPlaces: 1; 
			nextPutAll: ' ms between GCs'.
		 idleMs > 0 ifTrue:
			[str
				space;
				print: upTime - idleMs / (fullGCs + incrGCs) maxDecimalPlaces: 1; 
				nextPutAll: ' ms runtime between GCs'].
		 str nextPut: $)].
	str cr.
	str	nextPutAll: '	full		';
		nextPutAll: (self formatVMParameter: fullGCs); nextPutAll: ' totalling '; nextPutAll: (self formatVMParameter: fullGCTime); nextPutAll: ' ms (';
		print: fullGCTime / (upTime - idleMs) * 100 maxDecimalPlaces: 2;
		nextPutAll: '% runtime)';
		nextPutAll: ', avg '; print: (fullGCTime / (fullGCs max: 1)) maxDecimalPlaces: 1; nextPutAll: ' ms'.
	(spur and: [fullGCCompactionTime ~= 0]) ifTrue:
		[str	cr; nextPutAll: '				marking		';
			nextPutAll: (self formatVMParameter: (fullGCTime - fullGCCompactionTime)); nextPutAll: ' ms (';
			print: (fullGCTime - fullGCCompactionTime) / fullGCTime * 100 maxDecimalPlaces: 1;
			nextPutAll: '%) avg '; print: (fullGCTime - fullGCCompactionTime / (fullGCs max: 1)) maxDecimalPlaces: 1;
			nextPutAll: ' ms,'; cr;
			nextPutAll: '				compacting	';
			nextPutAll: (self formatVMParameter: fullGCCompactionTime); nextPutAll: ' ms (';
			print: fullGCCompactionTime / fullGCTime * 100 maxDecimalPlaces: 1;
			nextPutAll: '%) avg '; print: fullGCCompactionTime / (fullGCs max: 1) maxDecimalPlaces: 1;
			nextPutAll: ' ms'].
	str	cr.
	str	nextPutAll: (spur ifTrue: ['	scavenges	'] ifFalse: ['	incr			']);
		nextPutAll: (self formatVMParameter: incrGCs); nextPutAll: ' totalling '; nextPutAll: (self formatVMParameter: incrGCTime); nextPutAll: ' ms (';
		print: incrGCTime / (upTime - idleMs) * 100 maxDecimalPlaces: 2;
		nextPutAll: '% runtime), avg '; print: incrGCTime / incrGCs maxDecimalPlaces: 1; nextPutAll: ' ms'; cr.
	str	nextPutAll: '	tenures		';
		nextPutAll: (self formatVMParameter: tenureCount).
	tenureCount = 0 ifFalse:
		[spur
			ifTrue: [str nextPutAll: ' (avg '; print: tenureCount // (incrGCs max: 1); nextPutAll: ' tenures per scavenge)']
			ifFalse: [str nextPutAll: ' (avg '; print: incrGCs // tenureCount; nextPutAll: ' GCs/tenure)']].
	str	cr.

	codeCompactionsOrNil ifNotNil:
		[str
			nextPutAll: 'Code compactions	'; crtab.
		codeCompactionsOrNil = 0
			ifTrue: [str
				nextPutAll: codeCompactionsOrNil asString; cr]
			ifFalse: [str
				nextPutAll: (self formatVMParameter: codeCompactionsOrNil); nextPutAll: ' totalling '; nextPutAll: (self formatVMParameter: codeCompactionTime); nextPutAll: ' ms (';
				print: codeCompactionTime / (upTime - idleMs) * 100 maxDecimalPlaces: 3;
				nextPutAll: '% runtime), avg '; print: codeCompactionTime / codeCompactionsOrNil maxDecimalPlaces: 1; nextPutAll: ' ms'; cr]].

LastStats ifNil: [LastStats := Array new: 9]
ifNotNil: [
	LastStats size < 9 ifTrue:
		[LastStats := LastStats, (Array new: 9 - LastStats size withAll: 0)].
	upTime2 := upTime - (LastStats at: 1).
	fullGCs2 := fullGCs - (LastStats at: 2).
	fullGCTime2 := fullGCTime - (LastStats at: 3).
	incrGCs2 := incrGCs - (LastStats at: 4).
	incrGCTime2 := incrGCTime - (LastStats at: 5).
	tenureCount2 := tenureCount - (LastStats at: 6).
	idleMs2 := idleMs - (LastStats at: 7).
	codeCompactionsOrNil ifNotNil:
		[codeCompactions2	:= codeCompactionsOrNil - (LastStats at: 8).
		 codeCompactionTime2	:= codeCompactionTime - (LastStats at: 9)].

	str	nextPutAll: self textMarkerForShortReport ;
		nextPutAll: (self formatVMParameter: (fullGCs2 + incrGCs2)).
	fullGCs2 + incrGCs2 > 0 ifTrue:
		[str
			nextPutAll: ' ('; 
			print: upTime2 // (fullGCs2 + incrGCs2); 
			nextPutAll: ' ms between GCs'.
			idleMs2 > 0 ifTrue:
				[str
					nextPutAll: ', ';
					print: upTime2 - idleMs2 // (fullGCs2 + incrGCs2);
					nextPutAll: ' ms runtime between GCs'].
		 str nextPut: $)].
	str	cr.
	str	nextPutAll: '	uptime				'; print: (upTime2 / 1000.0) maxDecimalPlaces: 1;
		nextPutAll: ' s, runtime ';		   print: (upTime2 - idleMs2 / 1000.0) maxDecimalPlaces: 1;
		nextPutAll: ' s, idletime ';		   print: (idleMs2 / 1000.0) maxDecimalPlaces: 1; nextPutAll: ' s'; cr.
	str	nextPutAll: '	full					';
		nextPutAll: (self formatVMParameter: fullGCs2).
	fullGCs2 + fullGCTime2 > 0 ifTrue:
		[str	nextPutAll: ' totalling '; nextPutAll: (self formatVMParameter: fullGCTime2); nextPutAll: ' ms (';
			print: fullGCTime2 / (upTime2 - idleMs2) * 100 maxDecimalPlaces: 1;
			nextPutAll: '% runtime)'.
		 str	nextPutAll: ', avg '; print: fullGCTime2 / (fullGCs2 max: 1) maxDecimalPlaces: 1; nextPutAll: ' ms'].
	str	cr.
	str	nextPutAll: (spur ifTrue: ['	scavenge				'] ifFalse: ['	incr			']);
		nextPutAll: (self formatVMParameter: incrGCs2); nextPutAll: ' totalling '; nextPutAll: (self formatVMParameter: incrGCTime2); nextPutAll: ' ms (';
		print: incrGCTime2 / (upTime2 - idleMs2) * 100 maxDecimalPlaces: 1;
		nextPutAll: '% runtime), avg '; print: incrGCTime2 / (incrGCs2 max: 1) maxDecimalPlaces: 1; nextPutAll: ' ms'.
	str	cr.
	str	nextPutAll: '	tenures				';
		nextPutAll: (self formatVMParameter: tenureCount2).
	tenureCount2 = 0 ifFalse:
		[spur
			ifTrue: [str nextPutAll: ' (avg '; print: tenureCount2 // (incrGCs2 max: 1); nextPutAll: ' tenures per scavenge)']
			ifFalse: [str nextPutAll: ' (avg '; print: incrGCs2 // tenureCount2; nextPutAll: ' GCs/tenure)']].
	str	cr.
	codeCompactionsOrNil ifNotNil:
		[str	nextPutAll: '	code compactions	';
			nextPutAll: (self formatVMParameter: codeCompactions2); nextPutAll: ' totalling '; nextPutAll: (self formatVMParameter: codeCompactionTime2); nextPutAll: ' ms (';
			print: codeCompactionTime2 / (upTime2 - idleMs2) * 100 maxDecimalPlaces: 3;
			nextPutAll: '% runtime)'.
		 codeCompactions2 > 0 ifTrue:
			[str nextPutAll: ', avg '; print: codeCompactionTime2 / codeCompactions2 maxDecimalPlaces: 1; nextPutAll: ' ms'; cr.]]
].
	LastStats := { upTime. fullGCs. fullGCTime. incrGCs. incrGCTime. tenureCount. idleMs. codeCompactionsOrNil. codeCompactionTime }.

	^str contents

]

{ #category : #'vm statistics' }
SmalltalkImage >> vmStatisticsReportString [
	"(Workspace new contents: Smalltalk vmStatisticsReportString)
		openLabel: 'VM Statistics'"
	"StringHolderView
		open: (StringHolder new contents: Smalltalk vmStatisticsReportString)
		label: 'VM Statistics'"

	^String new: 2048 streamContents: [:s| self vmStatisticsReportOn: s]
]

{ #category : #'vm statistics' }
SmalltalkImage >> vmStatisticsShortString [
	"Convenience item for access to recent statistics only"
	"StringHolderView open: (StringHolder new contents: Smalltalk vmStatisticsShortString)
		label: 'VM Recent Statistics'"

	^ (ReadStream on: self vmStatisticsReportString) upToAll: 'Since'; nextLine; upToEnd

]

{ #category : #'system attributes' }
SmalltalkImage >> vmVMMakerVersion [	
	"Answer the version number of the VMMaker package from which the main VM was compiled."
	"Smalltalk vmVMMakerVersion"

	| vmMakerID |
	vmMakerID := self vmVersion substrings detect: [:token| token beginsWith: 'VMMaker'].
	^Integer readFrom: (vmMakerID subStrings: '.') last
]

{ #category : #'system attributes' }
SmalltalkImage >> vmVersion [	
	"Return a string identifying the interpreter version"
	"Smalltalk vmVersion"

	^self getSystemAttribute: 1004
]

{ #category : #miscellaneous }
SmalltalkImage >> voidCogVMState [
	"Void any internal caches the VM maintains other than the method lookup caches.
	 These comprise
		- the stack zone, where method activations are stored, and
		- the machine code zone, where the machine code form of CompiledMethods is held."
	<primitive: 214>
	^self primitiveFailed

	"Time millisecondsToRun: [Smalltalk voidCogVMState]"
	"(1 to: 10) collect: [:ign| Time millisecondsToRun: [Smalltalk voidCogVMState]]"
]

{ #category : #os }
SmalltalkImage >> windowSystemName [			
	"Return the name of the window system currently being used for display."
	
	"Smalltalk os windowSystemName"

	^self getSystemAttribute: 1005
]

{ #category : #image }
SmalltalkImage >> wordSize [
	"Answer the size in bytes of an object pointer or word in the object memory.
	The value does not change for a given image, but may be modified by a SystemTracer
	when converting the image to another format. The value is cached in WordSize to
	avoid the performance overhead of repeatedly consulting the VM."

	"Smalltalk wordSize"

	^ WordSize ifNil: [WordSize := [self vmParameterAt: 40] on: Error do: [4]]
]

{ #category : #'sources, changes log' }
SmalltalkImage >> writeRecentCharacters: nCharacters toFileNamed: aFilename [
	"Schedule an editable text view on the last n characters of changes."
	| changes |
	changes := SourceFiles at: 2.
	changes setToEnd; skip: nCharacters negated.
	(FileStream newFileNamed: aFilename) nextPutAll: (changes next: nCharacters); close; open; edit
]

{ #category : #'sources, changes log' }
SmalltalkImage >> writeRecentToFile [
	"Smalltalk writeRecentToFile"
	| numChars aDirectory aFileName |
	aDirectory := FileDirectory default.
	aFileName := Utilities
				keyLike: 'squeak-recent.01'
				withTrailing: '.log'
				satisfying: [:aKey | (aDirectory includesKey: aKey) not].
	numChars := ChangeSet getRecentLocatorWithPrompt: 'copy logged source as far back as...'.
	numChars
		ifNotNil: [self writeRecentCharacters: numChars toFileNamed: aFileName]
]

{ #category : #shrinking }
SmalltalkImage >> zapAllOtherProjects [ 
	"Smalltalk zapAllOtherProjects"

	Project current removeAllOtherProjects

]

{ #category : #shrinking }
SmalltalkImage >> zapMVCprojects [
	"Smalltalk zapMVCprojects"

	(Smalltalk classNamed: #MVCProject)
		ifNotNil: [:mvc | mvc removeProjectsFromSystem]

]
