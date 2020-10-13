"
The ResourceCollector collects resources that are encountered during project loading or publishing. It merely decouples the places where resources are held from the core object enumeration so that resources can be stored independently from what is enumerated for publishing.
"
Class {
	#name : #ResourceCollector,
	#superclass : #Object,
	#instVars : [
		'stubMap',
		'originalMap',
		'locatorMap',
		'localDirectory',
		'baseUrl',
		'resourceDirectory',
		'internalStubs'
	],
	#classVars : [
		'Current'
	],
	#category : #'System-Support'
}

{ #category : #accessing }
ResourceCollector class >> current [
	^Current
]

{ #category : #accessing }
ResourceCollector class >> current: aResourceManager [
	Current := aResourceManager
]

{ #category : #accessing }
ResourceCollector >> baseUrl [
	^baseUrl
]

{ #category : #accessing }
ResourceCollector >> baseUrl: aString [
	baseUrl := aString.
	baseUrl isEmpty ifFalse:[
		baseUrl last = $/ ifFalse:[baseUrl := baseUrl copyWith: $/].
	].
]

{ #category : #initialize }
ResourceCollector >> forgetObsolete [
	"Forget obsolete locators, e.g., those that haven't been referenced and not been stored on a file."
	locatorMap keys "copy" do:[:k|
		(locatorMap at: k) localFileName ifNil:[locatorMap removeKey: k]].
]

{ #category : #initialize }
ResourceCollector >> initialize [
	| fd pvt |
	originalMap := IdentityDictionary new.
	stubMap := IdentityDictionary new.
	locatorMap := IdentityDictionary new.
	internalStubs := IdentityDictionary new.
	fd := ScriptingSystem formDictionary.
	pvt := ScriptingSystem privateGraphics asSet.
	fd keysAndValuesDo:[:sel :form|
		(pvt includes: sel) ifFalse:[
			internalStubs at: form put:
				(DiskProxy 
					global: #ScriptingSystem
					selector: #formAtKey:extent:depth:
					args: {sel. form extent. form depth})]].
]

{ #category : #initialize }
ResourceCollector >> initializeFrom: aResourceManager [
	"Initialize the receiver from aResourceManager."
	aResourceManager resourceMap keysAndValuesDo:[:loc :res|
		(res notNil)
			ifTrue:[locatorMap at: res put:  loc.
					loc localFileName: nil].
	].
]

{ #category : #accessing }
ResourceCollector >> localDirectory [
	^localDirectory
]

{ #category : #accessing }
ResourceCollector >> localDirectory: aDirectory [
	localDirectory := aDirectory
]

{ #category : #accessing }
ResourceCollector >> locatorMap [
	"allow outsiders to store in it.  For files that are not resources that do want to live in the resource directory locally and on the server.  (.t files for example)"

	^locatorMap
]

{ #category : #accessing }
ResourceCollector >> locators [
	^locatorMap values
]

{ #category : #accessing }
ResourceCollector >> locatorsDo: aBlock [
	^locatorMap valuesDo: aBlock
]

{ #category : #accessing }
ResourceCollector >> noteResource: aResourceStub replacing: anObject [
	"Remember the fact that we need to load aResource which will replace anObject."
	stubMap at: aResourceStub put: anObject.
]

{ #category : #'objects from disk' }
ResourceCollector >> objectForDataStream: refStream [
	"This should never happen; when projects get written they must be decoupled from the resource collector. If you get the error message below something is seriously broken."
	self error:'Cannot write resource manager'
]

{ #category : #accessing }
ResourceCollector >> objectForDataStream: refStream fromForm: aForm [
	"Return a replacement for aForm to be stored instead"
	| stub fName copy loc fullSize nameAndSize |

	"First check if the form is one of the intrinsic Squeak forms"
	stub := internalStubs at: aForm ifAbsent:[nil].
	stub ifNotNil:[
		refStream replace: aForm with: stub. 
		^stub].

	"Now see if we have created the stub already 
	(this may happen if for instance some form is shared)"
	stub := originalMap at: aForm ifAbsent:[nil].
	stub ifNotNil:[^aForm].
	aForm hibernate.
	aForm bits class == FormStub ifTrue:[^nil].	"something is wrong"
	"too small to be of interest"
	"(aForm bits byteSize < 4096) ifTrue:[^aForm]."
	"We'll turn off writing out forms until we figure out how to reliably deal with resources"
	true ifTrue: [^aForm].

	"Create our stub form"
	stub := FormStub 
		extent: (aForm width min: 32) @ (aForm height min: 32) 
		depth: (aForm depth min: 8).
	aForm displayScaledOn: stub.
	aForm hibernate.

	"Create a copy of the original form which we use to store those bits"
	copy := Form extent: aForm extent depth: aForm depth bits: nil.
	copy setResourceBits: aForm bits.

	"Get the locator for the form (if we have any)"
	loc := locatorMap at: aForm ifAbsent:[nil].

	"Store the resource file"
	nameAndSize := self writeResourceForm: copy locator: loc.
	fName := nameAndSize first.
	fullSize := nameAndSize second.

	ProgressNotification signal: '2:resourceFound' extra: stub.
	stub hibernate.
	"See if we need to assign a new locator"
	(loc notNil and:[loc hasRemoteContents not]) ifTrue:[
		"The locator describes some local resource. 
		If we're preparing to upload the entire project to a
		remote server, make it a remote URL instead."
"		(baseUrl isEmpty not and:[baseUrl asUrl hasRemoteContents])
			ifTrue:[loc urlString: baseUrl, fName].
"
		baseUrl isEmpty not
			ifTrue:[loc urlString: self resourceDirectory , fName]].

	loc ifNil:[
		loc := ResourceLocator new urlString: self resourceDirectory , fName.
		locatorMap at: aForm put: loc].
	loc localFileName: (localDirectory fullNameFor: fName).
	loc resourceFileSize: fullSize.
	stub locator: loc.

	"Map old against stub form"
	aForm setResourceBits: stub.
	originalMap at: aForm put: copy.
	stubMap at: stub put: aForm.
	locatorMap at: aForm put: loc.
	"note: *must* force aForm in out pointers if 
	in IS or else won't get #comeFullyUpOnReload:"
	refStream replace: aForm with: aForm.
	^aForm
]

{ #category : #accessing }
ResourceCollector >> removeLocator: loc [
	locatorMap keys "copy" do:[:k|
		(locatorMap at: k) = loc ifTrue:[locatorMap removeKey: k]].
]

{ #category : #accessing }
ResourceCollector >> replaceAll [
	"Replace all resources by their originals. Done after the resource have been collected to get back to the original state."
	originalMap keysAndValuesDo:[:k :v|
		v ifNotNil:[k replaceByResource: v].
	].
]

{ #category : #accessing }
ResourceCollector >> resourceDirectory [
	resourceDirectory ifNil: [resourceDirectory := self baseUrl copyFrom: 1 to: (self baseUrl lastIndexOf: $/)].
	^resourceDirectory
]

{ #category : #accessing }
ResourceCollector >> resourceFileNames [
	"Return a list of all the resource files created"
	^locatorMap values asArray collect:[:loc| loc localFileName].
]

{ #category : #accessing }
ResourceCollector >> stubMap [
	^stubMap
]

{ #category : #'resource writing' }
ResourceCollector >> writeResourceForm: aForm fromLocator: aLocator [
	"The given form has been externalized before. If it was reasonably compressed, use the bits of the original data - this allows us to recycle GIF, JPEG, PNG etc. data without using the internal compression (which is in most cases inferior). If necessary the data will be retrieved from its URL location. This retrieval is done only if the resouce comes from either
		* the local disk (in which case the file has never been published)
		* the browser cache (in which case we don't cache the resource locally)
	In any other case we will *not* attempt to retrieve it, because doing so can cause the system to connect to the network which is probably not what we want. It should be a rare case anyways; could only happen if one clears the squeak cache selectively."
	| fName fStream url data |
	"Try to be smart about the name of the file"
	fName := (aLocator urlString includes: $:)
		ifTrue: [
			url := aLocator urlString asUrl.
			url path last]
		ifFalse: [aLocator urlString].
	fName isEmptyOrNil ifFalse:[fName := fName asFileName].
	(fName isEmptyOrNil or:[localDirectory isAFileNamed: fName]) ifTrue:[
		"bad luck -- duplicate name"
		fName := localDirectory 
				nextNameFor:'resource' 
				extension: (FileDirectory extensionFor: aLocator urlString)].
	"Let's see if we have cached it locally"
	ResourceManager
		lookupCachedResource: self baseUrl , aLocator urlString
		ifPresentDo:[:stream | data := stream upToEnd].
	"Check if the cache entry is without qualifying baseUrl. Workaround for older versions."
	data ifNil:[
		ResourceManager
			lookupCachedResource: aLocator urlString
			ifPresentDo:[:stream | data := stream upToEnd]].
	data ifNil:[
		"We don't have it cached locally. Retrieve it from its original location."
		(url notNil and: [url hasRemoteContents])
			ifTrue:[^nil]. "see note above"
		(Url schemeNameForString: aLocator urlString)
			ifNil: [^nil].
		data := HTTPLoader default retrieveContentsFor: aLocator urlString.
		data ifNil:[^nil].
		data := data content.
	].
	"data size > aForm bits byteSize ifTrue:[^nil]."
	fStream := localDirectory newFileNamed: fName.
	fStream binary.
	fStream nextPutAll: data.
	fStream close.
	^{fName. data size}
]

{ #category : #'resource writing' }
ResourceCollector >> writeResourceForm: aForm locator: aLocator [
	"Store the given form on a file. Return an array with the name and the size of the file"
	| fName fStream fullSize result writerClass |
	aLocator ifNotNil:[
		result := self writeResourceForm: aForm fromLocator: aLocator.
		result ifNotNil:[^result]
		"else fall through"
	].
	fName := localDirectory nextNameFor:'resource' extension:'form'.
	fStream := localDirectory newFileNamed: fName.
	fStream binary.
	aForm storeResourceOn: fStream.
false ifTrue:[
	"What follows is a Really, REALLY bad idea. I leave it in as a reminder of what you should NOT do. 
	PART I: Using JPEG or GIF compression on forms where we don't have the original data means loosing both quality and alpha information if present..."
	writerClass := ((Smalltalk includesKey: #JPEGReaderWriter2)
		and: [(Smalltalk at: #JPEGReaderWriter2) new isPluginPresent])
		ifTrue: [(Smalltalk at: #JPEGReaderWriter2)]
		ifFalse: [GIFReadWriter].
	writerClass putForm: aForm onStream: fStream.
	fStream open.
	fullSize := fStream size.
	fStream close.
].

	"Compress contents here"
true ifTrue:[
	"...PART II: Using the builtin compression which combines RLE+ZIP is AT LEAST AS GOOD as PNG and how much more would you want???"
	fStream position: 0.
	fStream compressFile.
	localDirectory deleteFileNamed: fName.
	localDirectory rename: fName, FileDirectory dot, 'gz' toBe: fName.
	fStream := localDirectory readOnlyFileNamed: fName.
	fullSize := fStream size.
	fStream close.
].
	^{fName. fullSize}
]
