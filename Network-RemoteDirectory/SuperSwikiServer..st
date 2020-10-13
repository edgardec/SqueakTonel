Class {
	#name : #SuperSwikiServer,
	#superclass : #ProjectSwikiServer,
	#category : #'Network-RemoteDirectory'
}

{ #category : #instances }
SuperSwikiServer class >> currentSuperSwiki [

	"make this return nil to disable SuperSwiki hack"

	^self defaultSuperSwiki


]

{ #category : #defaults }
SuperSwikiServer class >> defaultEncodingName [
	Locale current isoLanguage = 'ja' ifTrue: [^'shift_jis' copy] ifFalse: [^'latin1' copy].

]

{ #category : #instances }
SuperSwikiServer class >> defaultSuperSwiki [

	^SuperSwikiServer new 
		type: #http;
		server: self defaultSuperSwikiIPAddress;
		directory: '/super/SuperSwikiProj'
	

]

{ #category : #instances }
SuperSwikiServer class >> defaultSuperSwikiIPAddress [

	^'209.143.91.36'

]

{ #category : #tests }
SuperSwikiServer class >> testOnlySuperSwiki [

	^SuperSwikiServer new 
		type: #http;
		server: self defaultSuperSwikiIPAddress;
		directory: '/super/SuperSwikiProj'
	

]

{ #category : #'for real' }
SuperSwikiServer >> allEntries [

	| answer |

	answer := self sendToSwikiProjectServer: {
		'action: listallprojects'.
	}.
	(answer beginsWith: 'OK') ifFalse: [^#()].
	^self parseListEntries: answer
]

{ #category : #'for real' }
SuperSwikiServer >> directoryNames [

	^self entries select:[:each| each isDirectory] thenCollect: [ :each | each name]
]

{ #category : #'for real' }
SuperSwikiServer >> directoryWrapperClass [

	^SuperSwikiDirectoryWrapper
]

{ #category : #accessing }
SuperSwikiServer >> encodingName [
	(super encodingName) ifNil: [ ^SuperSwikiServer defaultEncodingName ] ifNotNil: [^super encodingName].
]

{ #category : #'for real' }
SuperSwikiServer >> entries [

	^self allEntries
]

{ #category : #'for real' }
SuperSwikiServer >> fastParseEntriesFrom: aString [

	| c first |

	c := OrderedCollection new.
	first := true.
	aString linesDo: [ :x | | xEntryName ch xIsDirectory strm xCreationTime xModificationTime xFileSize |
		first ifFalse: [
			strm := ReadStream on: x.
			(strm upTo: $ ) = '(DirectoryEntry' ifFalse: [^nil].
			(strm upTo: $ ) = 'name:' ifFalse: [^nil].
			xEntryName := WriteStream on: String new.
			strm next = $' ifFalse: [^nil].
			[
				ch := strm next.
				ch = $' and: [(strm peekFor: $') not]
			] whileFalse: [
				xEntryName nextPut: ch.
			].
			xEntryName := xEntryName contents.
			strm skipSeparators.
			(strm upTo: $ ) = 'creationTime:' ifFalse: [^nil].
			xCreationTime := (strm upTo: $ ) asNumber.
			(strm upTo: $ ) = 'modificationTime:' ifFalse: [^nil].
			xModificationTime := (strm upTo: $ ) asNumber.
			(strm upTo: $ ) = 'isDirectory:' ifFalse: [^nil].
			xIsDirectory := (strm upTo: $ ) = 'true'.
			(strm upTo: $ ) = 'fileSize:' ifFalse: [^nil].
			xFileSize := (strm upTo: $ ) asNumber.

			c add: (DirectoryEntry 
				name: (xEntryName convertFromEncoding: self encodingName)
				creationTime: xCreationTime 
				modificationTime: xModificationTime 
				isDirectory: xIsDirectory 
				fileSize: xFileSize
			)
		].
		first := false.
	].
	^c

]

{ #category : #'for real' }
SuperSwikiServer >> fileNames [

	^self entries select:[:each| each isDirectory not] thenCollect: [ :each | each name]
]

{ #category : #'for real' }
SuperSwikiServer >> getOnly: numberOfBytes from: aName [

	| answer |

	answer := self sendToSwikiProjectServer: {
		'action: readnamedfile'.
		'projectname: ',aName.
		'bytestoread: ',numberOfBytes printString.
	}.
	(answer beginsWith: 'OK') ifFalse: [ ^nil].
	^answer allButFirst: 3

]

{ #category : #testing }
SuperSwikiServer >> isSearchable [
	^true
]

{ #category : #'for real' }
SuperSwikiServer >> matchingEntries: criteria [
	| result |
	eToyUserListUrl ifNil:[^self entries].
	result := self sendToSwikiProjectServer: {
		'action: listmatchingprojects'.
	}  , criteria.
	(result beginsWith: 'OK')
		ifFalse: [^self entries]. "If command not supported"
	^self parseListEntries: result
]

{ #category : #'for real' }
SuperSwikiServer >> oldFileNamed: aName [

	| answer |

	answer := self sendToSwikiProjectServer: {
		'action: readnamedfile'.
		'projectname: ',aName convertToEncoding: self encodingName.
	}.
	(answer beginsWith: 'OK') ifFalse: [ ^nil].
	^(SwikiPseudoFileStream with: (answer allButFirst: 3))
		reset;
		directory: self;
		localName: (aName convertToEncoding: self encodingName);
		yourself

]

{ #category : #'for real' }
SuperSwikiServer >> oldFileOrNoneNamed: fullName [

	| answer aName |

	self flag: #bob.		"fix this up for full names"

	aName := fullName.
	answer := self sendToSwikiProjectServer: {
		'action: readnamedfile'.
		'projectname: ',(self localNameFor: aName).
	}.
	(answer beginsWith: 'OK') ifFalse: [^nil].
	^(SwikiPseudoFileStream with: (answer allButFirst: 3))
		reset;
		directory: self;
		localName: aName;
		yourself

]

{ #category : #private }
SuperSwikiServer >> parseListEntries: listResult [

	| c first |
	c := self fastParseEntriesFrom: listResult.
	c ifNotNil: [^c].
	c := OrderedCollection new.
	first := true.
	listResult linesDo: [ :x |
		first ifFalse: [c add: (Compiler evaluate: x)].
		first := false.
	].
	^c

]

{ #category : #testing }
SuperSwikiServer >> parseQueryResult: resultStream [

	| projectInfos projectName  downloadUrl |
	projectInfos := OrderedCollection new.
	downloadUrl := self downloadUrl.
	resultStream reset; nextLine.
	[resultStream atEnd] whileFalse: [
		projectName := resultStream nextLine.
		projectInfos add: projectName.
		"Transcript show: projectName; cr."
		].
	"Transcript show: 'done'; cr."
	^projectInfos

]

{ #category : #'for real' }
SuperSwikiServer >> putFile: fileStream named: fileNameOnServer [

	
	^(
		self sendToSwikiProjectServer: {
			'uploadproject: ',fileNameOnServer convertToEncoding: self encodingName.
			'password: ',ProjectPasswordNotification signal.
			fileStream contentsOfEntireFile.
		}
	) beginsWith: 'OK'

]

{ #category : #testing }
SuperSwikiServer >> queryAllProjects [

"answer a collection of DirectoryEntry objects for each file on server"

"SuperSwikiServer testOnlySuperSwiki queryAllProjects"

	^self sendToSwikiProjectServer: {
		'action: listallprojects'.
	}
]

{ #category : #testing }
SuperSwikiServer >> queryProjects: criteria [
	| result |
	"SuperSwikiServer defaultSuperSwiki queryProjects: #('submittedBy: mir' )"
	result := self sendToSwikiProjectServer: {
		'action: findproject'.
	}  , criteria.
	(result beginsWith: 'OK') ifFalse: [^self inform: result printString].
	^self parseQueryResult: (ReadStream on: result).

]

{ #category : #testing }
SuperSwikiServer >> queryProjectsAndShow [
	| result |
"SuperSwikiServer testOnlySuperSwiki queryProjectsAndShow"

	result := self sendToSwikiProjectServer: {
		'action: findproject'.
		"'projectname: *proj*'."
	}.
	(result beginsWith: 'OK') ifFalse: [^self inform: result printString].
	self showQueryAsPVM: (ReadStream on: result).

]

{ #category : #testing }
SuperSwikiServer >> queryProjectsAndShow: thingsToSearchFor [
	| result |
"SuperSwikiServer testOnlySuperSwiki queryProjectsAndShow"

	result := self sendToSwikiProjectServer: {
		'action: findproject'.
	}, thingsToSearchFor.
	(result beginsWith: 'OK') ifFalse: [^self inform: result printString].
	self showQueryAsPVM: (ReadStream on: result).

]

{ #category : #testing }
SuperSwikiServer >> queryPythagoras [
"SuperSwikiServer testOnlySuperSwiki queryPythagoras"

	^self sendToSwikiProjectServer: {
		'action: findproject'.
		'projectsubcategory: *geometry*'.
		"'projectname: *pythagoras*'."
	}
]

{ #category : #'for real' }
SuperSwikiServer >> readOnlyFileNamed: aName [

	^self oldFileNamed: aName

]

{ #category : #'for real' }
SuperSwikiServer >> sendToSwikiProjectServer: anArray [

	| argsDict answer buildStream |

	buildStream := WriteStream on: String new.
	anArray do: [ :each | 
		buildStream 
			nextPutAll: each size printString;
			space;
			nextPutAll: each
	].
	(argsDict := Dictionary new)
		at: 'swikicommands'
		put: {buildStream contents}.
	answer := HTTPSocket 
		httpPostToSuperSwiki: self url
		args: argsDict
		accept: 'application/octet-stream' 
		request: ''.
	^(answer isKindOf: MIMEDocument) ifTrue: [answer content] ifFalse: [answer]

]

{ #category : #testing }
SuperSwikiServer >> showQueryAsPVM: resultStream [
	| answer gif whatToShow projectName fileName firstURL wrapper currX currY maxX maxY rawProjectName |
"SuperSwikiServer testOnlySuperSwiki queryProjectsAndShow"

	resultStream reset; nextLine.
	answer := RectangleMorph new
		useRoundedCorners;
		borderWidth: 0;
		borderColor: Color blue;
		color: Color paleBlue.
	currX := currY := maxX := maxY := 10.
	[resultStream atEnd] whileFalse: [
		rawProjectName := resultStream nextLine.
		projectName := rawProjectName convertFromEncoding: self encodingName.
		fileName := resultStream nextLine convertFromEncoding: self encodingName.
		gif := self oldFileOrNoneNamed: rawProjectName,'.gif'.
		gif ifNotNil: [gif := GIFReadWriter formFromStream: gif].
		currX > 600 ifTrue: [
			currX := 10.
			currY := maxY + 10.
		].
		gif ifNil: [
			gif := AlignmentMorph newColumn
				hResizing: #shrinkWrap;
				vResizing: #shrinkWrap;
				borderWidth: 8;
				borderColor: Color red;
				color: Color lightRed;
				addMorph: (StringMorph contents: 'No GIF for ',projectName);
				fullBounds;
				imageForm
		].
		firstURL := self url.
		firstURL last == $/ ifFalse: [firstURL := firstURL, '/'].

		whatToShow := ProjectViewMorph new
			image: (gif asFormOfDepth: Display depth);
			lastProjectThumbnail: gif;
			setProperty: #SafeProjectName toValue: projectName;
			project: (DiskProxy 
				global: #Project 
				selector: #namedUrl: 
				args: {firstURL,fileName}
			).

		answer addMorphBack: (whatToShow position: currX @ currY).
		currX := currX + whatToShow width + 10.
		maxX := maxX max: currX.
		maxY := maxY max: currY + whatToShow height.
	].
	maxX = 10 ifTrue: [
		^self inform: 'No projects found for your criteria'
	].
	answer extent: (maxX @ maxY) + (0@10).
	wrapper := ScrollPane new extent: (answer width + 10) @ (answer height min: 400).
	wrapper color: Color white.
	wrapper scroller addMorph: answer.
	wrapper
		openCenteredInWorld;
		useRoundedCorners;
		setScrollDeltas.
]

{ #category : #testing }
SuperSwikiServer >> speedTest1 [

"SuperSwikiServer testOnlySuperSwiki speedTest1"

	| totalTime answer |

	totalTime := [
		answer := (1 to: 10) collect: [ :x | | t |
			t := [answer := self sendToSwikiProjectServer: {
				'action: readnamedfile'.
				'projectname: xyz.002.pr'.
			}] timeToRun.
			{t. answer size}
		].
	] timeToRun.
	^{totalTime. answer}

]

{ #category : #testing }
SuperSwikiServer >> speedTest2 [

"SuperSwikiServer testOnlySuperSwiki speedTest2"

"==observed results
10 forks of 10 reads of 88K in 12.7 seconds
100 * 88110 / 12.7 ===> 693779 bytes per second
---
10 forks of 10 reads of 88K in 10.7 seconds
100 * 88110 / 10.7 ===> 823457 bytes per second
---at priority 5
10 forks of 10 reads of 88K in 9.8 seconds
100 * 88110 / 9.8 ===> 899081 bytes per second
==="

	| bigAnswer tRealBegin tRealEnd |

	bigAnswer := SharedQueue new.
	tRealBegin := tRealEnd := Time millisecondClockValue.
	10 timesRepeat: [
		[ | answer |
			answer := SuperSwikiServer testOnlySuperSwiki speedTest1.
			tRealEnd := Time millisecondClockValue.
			bigAnswer nextPut: {
				{tRealBegin. tRealEnd. tRealEnd - tRealBegin}.
				answer
			}.
		] forkAt: Processor userInterruptPriority.
	].
	bigAnswer inspect.

]

{ #category : #testing }
SuperSwikiServer >> test1 [

	| localDirectory localFileName local resp |

	localDirectory := FileDirectory default.
	localFileName := 'superTest1.07Oct1611.cs'.
	local := localDirectory oldFileNamed: localFileName.
	resp := self putFile: local named: localFileName retry: false.
	local close.
	^resp

]

{ #category : #accessing }
SuperSwikiServer >> typeForPrefs [

	^'bss'
]

{ #category : #squeaklets }
SuperSwikiServer >> upLoadProject: projectName members: archiveMembers retry: aBool [
	
	archiveMembers do:[:entry| | answer |
		ProgressNotification signal: '4:uploadingFile' extra:'(uploading ' translated, entry fileName convertFromSystemString , '...)' translated.
		answer := self sendToSwikiProjectServer: {
			'uploadproject2: ', entry fileName convertFromSystemString convertToEncoding: self encodingName.
			'password: ',ProjectPasswordNotification signal.
			entry contents.
		}.
		answer = 'OK' ifFalse:[
			self inform:'Server responded ' translated, answer.
			^false].
	].
	ProgressNotification signal: '4:uploadingFile' extra:''.
	^true
]

{ #category : #'for real' }
SuperSwikiServer >> updateProjectInfoFor: aProject [

	| data details projectLinks linkString uploader |

	data := OrderedCollection new.
	data add: 'action: updatepage'.
	data add: 'password: ',ProjectPasswordNotification signal.
	data add: 'projectimage: ', (aProject name convertToEncoding: self encodingName) , '.gif'.
	uploader := Utilities authorNamePerSe.
	uploader isEmptyOrNil ifTrue: [uploader := Utilities authorInitialsPerSe].
	uploader isEmptyOrNil ifFalse: [
		data add: ('submittedBy: ',uploader convertToEncoding: self encodingName).
	].
	projectLinks := Set new.
	aProject world allMorphsDo: [ :each |
		(each isKindOf: ProjectViewMorph) ifTrue: [
			projectLinks add: each safeProjectName.
		].
	].
	details := aProject world valueOfProperty: #ProjectDetails ifAbsent: [Dictionary new].
	details at: 'projectname' ifAbsentPut: [aProject name].
	projectLinks isEmpty ifTrue: [
		details removeKey: 'projectlinks' ifAbsent: []
	] ifFalse: [
		linkString := String streamContents: [ :strm |
			projectLinks sorted do: [ :each |
				strm nextPutAll: each
			] separatedBy: [
				strm nextPut: $.
			].
		].
		details at: 'projectlinks' put: linkString
	].
	details keysAndValuesDo: [ :k :v |
		data add: k , ': ' , (v convertToEncoding: self encodingName). self flag: #yoFlag.
	].
	^self sendToSwikiProjectServer: data
]
