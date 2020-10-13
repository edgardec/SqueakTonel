Class {
	#name : #ProjectLoading,
	#superclass : #Object,
	#category : #'System-Support'
}

{ #category : #utilities }
ProjectLoading class >> bestAccessToFileName: aFileName andDirectory: aDirectoryOrUrlString [
	"Answer an array with a stream and a directory. The directory can be nil."
	
	| dir url |
	dir := Project squeakletDirectory.
	(dir fileExists: aFileName) ifTrue: [
		^{dir readOnlyFileNamed: aFileName. dir}].

	aDirectoryOrUrlString isString ifFalse: [
		^{aDirectoryOrUrlString readOnlyFileNamed: aFileName. aDirectoryOrUrlString}].

	url := Url absoluteFromFileNameOrUrlString: aDirectoryOrUrlString.

	(url scheme = 'file') ifTrue: [
		dir := FileDirectory on: url pathForDirectory.
		^{dir readOnlyFileNamed: aFileName. dir}].

	(url path anySatisfy: [:each | each = 'SuperSwikiProj']) ifTrue: [
		dir := SuperSwikiServer new fullPath: url directoryUrl asString.
		^{dir readOnlyFileNamed: url fileName. nil}].

	^{ServerFile new fullPath: aDirectoryOrUrlString. nil}
]

{ #category : #loading }
ProjectLoading class >> installRemoteNamed: remoteFileName from: aServer named: otherProjectName in: currentProject [

	| fileAndDir |

	"Find the current ProjectViewMorph, fetch the project, install in ProjectViewMorph without changing size, and jump into new project."

	ProgressNotification signal: '1:foundMostRecent'.
	fileAndDir := self bestAccessToFileName: remoteFileName andDirectory: aServer.
	^self 
		openName: remoteFileName 
		stream: fileAndDir first 
		fromDirectory: fileAndDir second
		withProjectView: (currentProject findProjectView: otherProjectName).

]

{ #category : #loading }
ProjectLoading class >> openFromDirectory: aDirectory andFileName: aFileName [

	Project current
		do: [| fileAndDir |
			ProgressNotification signal: '1:foundMostRecent'.
			fileAndDir := self bestAccessToFileName: aFileName andDirectory: aDirectory.
			self 
				openName: aFileName 
				stream: fileAndDir first 
				fromDirectory: fileAndDir second
				withProjectView: nil]
		withProgressInfoOn: nil
		label: 'project loading'
		
]

{ #category : #loading }
ProjectLoading class >> openFromFile: preStream fromDirectory: aDirectoryOrNil withProjectView: existingView [


	self error: 'use #openFromFile:fromDirectory:withProjectView:'

]

{ #category : #loading }
ProjectLoading class >> openName: aFileName stream: preStream fromDirectory: aDirectoryOrNil
withProjectView: existingView [

	^ self openName: aFileName stream: preStream fromDirectory: aDirectoryOrNil
withProjectView: existingView clearOriginFlag: false.
]

{ #category : #loading }
ProjectLoading class >> openName: aFileName stream: preStream fromDirectory: aDirectoryOrNil
withProjectView: existingView clearOriginFlag: clearOriginFlag [
	"Reconstitute a Morph from the selected file, presumed to
represent a Morph saved via the SmartRefStream mechanism, and open it
in an appropriate Morphic world."

   	| morphOrList archive mgr substituteFont numberOfFontSubstitutes resultArray anObject project manifests dict |
	(self checkStream: preStream) ifTrue: [^ self].
	ProgressNotification signal: '0.2'.
	archive := preStream isZipArchive
		ifTrue:[ZipArchive new readFrom: preStream]
		ifFalse:[nil].
	archive ifNotNil:[
	manifests := (archive membersMatching: '*manifest').
	(manifests size = 1 and: [((dict := self parseManifest: manifests first contents) at: 'Project-Format' ifAbsent: []) = 'S-Expression'])
		ifTrue: [
			^ (self respondsTo: #openSexpProjectDict:stream:fromDirectory:withProjectView:)
				ifTrue: [self openSexpProjectDict: dict stream: preStream fromDirectory: aDirectoryOrNil withProjectView: existingView]
				ifFalse: [self inform: 'Cannot load S-Expression format projects without Etoys' translated]]].

	morphOrList := self morphOrList: aFileName stream: preStream fromDirectory: aDirectoryOrNil archive: archive.
	morphOrList ifNil: [^ self].
	ProgressNotification  signal: '0.4'.
	resultArray := self fileInName: aFileName archive: archive morphOrList: morphOrList.
	anObject := resultArray first.
	numberOfFontSubstitutes := resultArray second.
	substituteFont := resultArray third.
	mgr := resultArray fourth.
	preStream close.
	ProgressNotification  signal: '0.7'.
		"the hard part is over"
	(anObject isKindOf: ImageSegment) ifTrue: [
		project := self loadImageSegment: anObject
			fromDirectory: aDirectoryOrNil
			withProjectView: existingView
			numberOfFontSubstitutes: numberOfFontSubstitutes
			substituteFont: substituteFont
			mgr: mgr.
		project noteManifestDetailsIn: dict.
		project removeParameter: #sugarProperties.
		Smalltalk at: #SugarPropertiesNotification ifPresent: [:sp |
			sp signal ifNotNil: [:props | 
				project keepSugarProperties: props monitor: true]].
		clearOriginFlag ifTrue: [project forgetExistingURL].
		ProgressNotification  signal: '0.8'.
			^ project
				ifNil: [self inform: 'No project found in this file' translated]
				ifNotNil: [ProjectEntryNotification signal: project]].
	Project current openViewAndEnter: anObject
]

{ #category : #loading }
ProjectLoading class >> openOn: aStream [ 
	'Loading a Project...' displaySequentialProgress: [self
				openName: nil
				stream: aStream
				fromDirectory: nil
				withProjectView: nil]
]

{ #category : #accessing }
ProjectLoading class >> projectStreamFromArchive: archive [
	| ext prFiles entry unzipped |
	ext := FileDirectory dot, Project projectExtension.
	prFiles := archive members select:[:any| any fileName endsWith: ext].
	prFiles isEmpty ifTrue:
		[ext := FileDirectory dot, 'sexp'.
		prFiles := archive members select:[:any| any fileName endsWith: ext]].
	prFiles isEmpty ifTrue: [''].
	entry := prFiles first.
	unzipped := MultiByteBinaryOrTextStream on: (ByteArray new: entry uncompressedSize).
	entry extractTo: unzipped.
	^unzipped reset
]

{ #category : #accessing }
ProjectLoading class >> thumbnailFromUrl: urlString [
	"Load the project, and make a thumbnail to it in the current project.
ProjectLoading thumbnailFromUrl: 'http://www.squeak.org/Squeak2.0/2.7segments/SqueakEasy.extSeg'.
"

	Project canWeLoadAProjectNow ifFalse: [^ self].
	Project current
		do: [| fileName fileAndDir |
			ProgressNotification signal: '1:foundMostRecent'.
			fileName := (urlString findTokens: '/') last.
			fileAndDir := self bestAccessToFileName: fileName andDirectory: urlString.
			self
				openName: fileName 
				stream: fileAndDir first 
				fromDirectory: fileAndDir second
				withProjectView: nil]
		withProgressInfoOn: nil
		label: 'project loading'

]

{ #category : #utilities }
ProjectLoading class >> useTempChangeSet [
	"While reading the project in, use the temporary change set zzTemp"

	| zz |
	zz := ChangeSet named: 'zzTemp'.
	zz ifNil: [zz := ChangeSet basicNewChangeSet: 'zzTemp'].
	ChangeSet  newChanges: zz.
]
