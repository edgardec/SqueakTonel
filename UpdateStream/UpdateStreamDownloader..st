Class {
	#name : #UpdateStreamDownloader,
	#superclass : #Object,
	#classVars : [
		'PromptForUpdateServer',
		'UpdateDownloader',
		'UpdateSavesFile',
		'UpdateUrlLists'
	],
	#category : #UpdateStream
}

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> applyUpdatesFromDisk [
	"UpdateStreamDownloader applyUpdatesFromDisk"
	"compute highest update number"
	| updateDirectory updateNumbers |
	updateDirectory := self getUpdateDirectoryOrNil.
	updateDirectory
		ifNil: [^ self].
	updateNumbers := updateDirectory fileNames
				collect: [:fn | fn initialIntegerOrNil]
				thenSelect: [:fn | fn notNil].
	self
		applyUpdatesFromDiskToUpdateNumber: (updateNumbers
				inject: 0
				into: [:max :num | max max: num])
		stopIfGap: false
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> applyUpdatesFromDiskToUpdateNumber: lastUpdateNumber stopIfGap: stopIfGapFlag [ 
	"To use this mechanism, be sure all updates you want to have considered 
	are in a folder named 'updates' which resides in the same directory as  
	your image. Having done that, simply evaluate:  
	 
	UpdateStreamDownloader applyUpdatesFromDiskToUpdateNumber: 1234 stopIfGap: false  
	 
	and all numbered updates <= lastUpdateNumber not yet in the image will 
	be loaded in numerical order."
	| previousHighest currentUpdateNumber done fileNames aMessage updateDirectory loaded |
	updateDirectory := self getUpdateDirectoryOrNil.
	updateDirectory ifNil: [^ self].
	previousHighest := SystemVersion current highestUpdate.
	currentUpdateNumber := previousHighest.
	done := false.
	loaded := 0.
	[done]
		whileFalse: [currentUpdateNumber := currentUpdateNumber + 1.
			currentUpdateNumber > lastUpdateNumber
				ifTrue: [done := true]
				ifFalse: [fileNames := updateDirectory fileNamesMatching: currentUpdateNumber printString , '*'.
					fileNames size > 1
						ifTrue: [^ self inform: 'ambiguity -- two files both start with ' , currentUpdateNumber printString , '
(at this point it is probably best to remedy
the situation on disk, then try again.)'].
					fileNames size = 0
						ifTrue: [Transcript cr; show: 'gap in updates from disk for update number '; print: currentUpdateNumber; show: ' found...'.
							done := stopIfGapFlag]
						ifFalse: [ChangeSet
								newChangesFromStream: (updateDirectory readOnlyFileNamed: fileNames first)
								named: fileNames first.
							SystemVersion current registerUpdate: currentUpdateNumber.
							loaded := loaded + 1]]].
	aMessage := loaded = 0
				ifTrue: ['No new updates found.']
				ifFalse: [loaded printString , ' update(s) loaded.'].
	self inform: aMessage , '
Highest numbered update is now ' , (currentUpdateNumber - 1) printString , '.'
]

{ #category : #'server urls' }
UpdateStreamDownloader class >> assureAbsenceOfUnstableUpdateStream [
	"Check to see if the unstable Updates stream is in the list; if it is, *remove* it.  This is the *opposite* of #assureAvailabilityOfUnstableUpdateStream"

	UpdateUrlLists ifNil: [UpdateUrlLists := OrderedCollection new].
	UpdateUrlLists := UpdateUrlLists select:
		[:pair | pair first ~= 'Unstable Updates*']


"UpdateStreamDownloader assureAbsenceOfUnstableUpdateStream"
]

{ #category : #'server urls' }
UpdateStreamDownloader class >> assureAvailabilityOfSqueakPublicUpdateStream [
	"Check to see if the Squeak public Updates stream is in the list; if not, add it"

	UpdateUrlLists ifNil: [UpdateUrlLists := OrderedCollection new].
	UpdateUrlLists do:
		[:pair | (pair first =  'Squeak Public Updates') ifTrue: [^ self]].

	UpdateUrlLists addFirst: #('Squeak Public Updates' #('ftp.squeak.org/'))

"UpdateStreamDownloader assureAvailabilityOfSqueakPublicUpdateStream"
]

{ #category : #'server urls' }
UpdateStreamDownloader class >> assureAvailabilityOfUnstableUpdateStream [
	"Check to see if the unstable Updates stream is in the list; if not, add it"

	UpdateUrlLists ifNil: [UpdateUrlLists := OrderedCollection new].
	UpdateUrlLists do:
		[:pair | (pair first =  'Unstable Updates*') ifTrue: [^ self]].

	UpdateUrlLists addFirst: #('Unstable Updates*' #('squeak.cs.uiuc.edu/Squeak2.0/' 'update.squeakfoundation.org/external/'))

"UpdateStreamDownloader assureAvailabilityOfUnstableUpdateStream"
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> broadcastUpdatesFrom: n1 to: n2 except: skipList [
"
	Note:  This method takes its list of files from the directory named 'updates',
	which will have been created and filled by, eg,
		UpdateStreamDownloader readServerUpdatesSaveLocally: true updateImage: true.
	These can then be rebroadcast to any server using, eg,
		UpdateStreamDownloader broadcastUpdatesFrom: 1 to: 9999 except: #(223 224).
	If the files are already on the server, and it is only a matter
	of copying them to the index for a different version, then use...
		(ServerDirectory serverInGroupNamed: 'SqC Internal Updates*')
			exportUpdatesExcept: #().
"
	| fileNames names choice file updateDirectory |
	updateDirectory := FileDirectory default directoryNamed: 'updates'.
	fileNames := updateDirectory fileNames select:
		[:n | n first isDigit
			and: [(n initialIntegerOrNil between: n1 and: n2)
			and: [(skipList includes: n initialIntegerOrNil) not]]].
	(file := fileNames select: [:n | (n occurrencesOf: $.) > 1]) size > 0
		ifTrue: [self halt: file first , ' has multiple periods'].
	fileNames sort:
		[:a :b | a initialIntegerOrNil < b initialIntegerOrNil].

	names := ServerDirectory groupNames.
	choice := UIManager default chooseFrom: names values: names.
	choice == nil ifTrue: [^ self].
	(ServerDirectory serverInGroupNamed: choice)
		putUpdateMulti: fileNames fromDirectory: updateDirectory

]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> chooseUpdateList [
	"When there is more than one set of update servers, let the user choose which we will update from.  Put it at the front of the list. Return false if the user aborted.  If the preference #promptForUpdateServer is false, then suppress that prompt, in effect using the same server choice that was used the previous time (a convenience for those of us who always answer the same thing to the prompt.)"

	| index him |
	((UpdateUrlLists size > 1) and: [self promptForUpdateServer])
		ifTrue:
			[index := UIManager default 
				chooseFrom: (UpdateUrlLists collect: [:each | each first]) 
				lines: #()
				title: 'Choose a group of servers\from which to fetch updates.' translated withCRs.
			index > 0 ifTrue:
				[him := UpdateUrlLists at: index.
				UpdateUrlLists removeAt: index.
				UpdateUrlLists addFirst: him].
			^ index > 0].
	^ true
]

{ #category : #accessing }
UpdateStreamDownloader class >> default [
	"Answer the default downloader. Currently, all methods are at class side, so it'll be ourself"
	^self
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> extractThisVersion: list [
	"Pull out the part of the list that applies to this version."

	| listContents version versIndex |
	listContents := self parseListContents: list.
	version := SystemVersion current version.
	
	versIndex := (listContents collect: [:pair | pair first]) indexOf: version.
	versIndex = 0 ifTrue: [^ Array new].		"abort"
	^ (listContents at: versIndex) last
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> fileInFromUpdatesFolder: numberList [
	"File in a series of updates with the given updates numbers, from the updates folder in the default directory.  The file-ins are done in numeric order, even if numberList was not sorted upon entry.
	This is useful for test-driving the retrofitting of a possibly discontinguous list of updates from an alpha version back to a stable release.

	UpdateStreamDownloader fileInFromUpdatesFolder: #(4745 4746 4747 4748 4749 4750 4751 4752 4754 4755 4761 4762 4767 4769).
"
	| fileNames file updateDirectory |
	updateDirectory := FileDirectory default directoryNamed: 'updates'.
	fileNames := updateDirectory fileNames select:
		[:n | n first isDigit
			and: [numberList includes: n initialIntegerOrNil]].
	(file := fileNames select: [:n | (n occurrencesOf: $.) > 1]) size > 0
		ifTrue: [self error: file first , ' has multiple periods'].
	fileNames sort:
		[:a :b | a initialIntegerOrNil < b initialIntegerOrNil].

	fileNames do:
		[:aFileName | (updateDirectory readOnlyFileNamed: aFileName) fileIntoNewChangeSet]
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> getUpdateDirectoryOrNil [
	^ (FileDirectory default directoryNames includes: 'updates')
		ifTrue: [FileDirectory default directoryNamed: 'updates']
		ifFalse: [self inform: 'Error: cannot find "updates" folder'.
			nil]
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> lastUpdateNum: updatesFileStrm [
	"Look in the Updates file and see what the last sequence number is.  Warn the user if the version it is under is not this image's version."

	| verIndex seqIndex char ver seqNum |
	verIndex := seqIndex := 0.	 "last # starting a line and last digit starting a line"
	seqNum := 0.
	updatesFileStrm reset; ascii.
	[char := updatesFileStrm next.
	 updatesFileStrm atEnd] whileFalse: [
		char == Character cr ifTrue: [
			updatesFileStrm peek == $# ifTrue: [verIndex := updatesFileStrm position +1.
				seqIndex = 0 ifFalse: ["See if last num of old version if biggest so far"
					updatesFileStrm position: seqIndex.
					ver := SmallInteger readFrom: updatesFileStrm.
					seqNum := seqNum max: ver.
					updatesFileStrm position: verIndex-1]].
			updatesFileStrm peek isDigit ifTrue: [seqIndex := updatesFileStrm position]]].

	seqIndex = 0 ifFalse: ["See if last num of old version if biggest so far"
		updatesFileStrm position: seqIndex.
		ver := SmallInteger readFrom: updatesFileStrm.
		seqNum := seqNum max: ver.
		updatesFileStrm setToEnd].
	^ seqNum
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> newUpdatesOn: serverList special: indexPrefix throughNumber: aNumber [
	"Return a list of fully formed URLs of update files we do not yet have.  Go to the listed servers and look at the file 'updates.list' for the names of the last N update files.  We look backwards for the first one we have, and make the list from there.  tk 9/10/97
	No updates numbered higher than aNumber (if it is not nil) are returned " 

	| existing out maxNumber |
	maxNumber := aNumber ifNil: [99999].
	out := OrderedCollection new.
	existing := SystemVersion current updates.
	serverList do: [:server | | raw doc list char |
		doc := HTTPSocket httpGet: 'http://' , server,indexPrefix,'updates.list'.
		
		"test here for server being up"
		doc class == RWBinaryOrTextStream ifTrue:
			[raw := doc reset; contents.	"one file name per line"
			list := self extractThisVersion: raw.
			list reverseDo: [:fileName | | ff itsNumber |
				ff := (fileName findTokens: '/') last.	"allow subdirectories"
				itsNumber := ff initialIntegerOrNil. 
				(existing includes: itsNumber)
					ifFalse:
						[
						(itsNumber == nil or: [itsNumber <= maxNumber])
							ifTrue:
								[out addFirst: 'http://' , server, fileName]]
					ifTrue: [^ out]].
			((out size > 0) or: [char := doc reset; skipSeparators; next.
				(char == $*) | (char == $#)]) ifTrue:
					[^ out "we have our list"]].	"else got error msg instead of file"
		"Server was down, try next one"].
	self inform: 'All code update servers seem to be unavailable'.
	^ out
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> objectStrmFromUpdates: fileName [
	"Go to the known servers and look for this file in the updates folder.  It is an auxillery file, like .morph or a .gif.  Return a RWBinaryOrTextStream on it.    Meant to be called from during the getting of updates from the server.  That assures that (UpdateStreamDownloader serverUrls) returns the right group of servers."
	Cursor wait showWhile:
		[ | urls |
		urls := UpdateStreamDownloader serverUrls collect: [:url | url, 'updates/', fileName].
		urls do: [:aUrl | | doc |
			doc := HTTPSocket httpGet: aUrl accept: 'application/octet-stream'.
			"test here for server being up"
			doc class == RWBinaryOrTextStream ifTrue: [^ doc reset]]].

	self inform: 'All update servers are unavailable, or bad file name'.
	^ nil
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> parseListContents: listContents [
	| sections vers strm line fileNames |
	"Parse the contents of updates.list into {{vers. {fileNames*}}*}, and return it."

	sections := OrderedCollection new.
	fileNames := OrderedCollection new: 1000.
	vers := nil.
	strm := ReadStream on: listContents.
	[strm atEnd] whileFalse:
		[line := strm nextLine.
		line size > 0 ifTrue:
			[line first = $#
				ifTrue: [vers ifNotNil: [sections addLast: {vers. fileNames asArray}].
						"Start a new section"
						vers := line allButFirst.
						fileNames resetTo: 1]
				ifFalse: [line first = $* ifFalse: [fileNames addLast: line]]]].
	vers ifNotNil: [sections addLast: {vers. fileNames asArray}].
	^ sections asArray
" TEST:
 | list |
list := UpdateStreamDownloader parseListContents: (FileStream oldFileNamed: 'updates.list') contentsOfEntireFile.
list = (UpdateStreamDownloader parseListContents: (String streamContents: [:s | UpdateStreamDownloader writeList: list toStream: s]))
	ifFalse: [self error: 'test failed']
	ifTrue: [self inform: 'test OK']
"
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> position: updateStrm atVersion: version [
	"Set the stream to the end of the last line of updates names for this version.  Usually the end of the file.  We will add a new update name.   Return the contents of the rest of the file."

	| char foundIt where data |
	updateStrm reset; ascii.
	foundIt := false.
	[char := updateStrm next.
	 updateStrm atEnd] whileFalse: [
		(char == Character cr or: [char == Character lf]) ifTrue: [
			updateStrm peek == $# ifTrue: [
				foundIt ifTrue: ["Next section"
					where := updateStrm position.
					data := updateStrm upTo: (255 asCharacter).
					updateStrm position: where.
					^ data].	"won't be found -- copy all the way to the end"
				updateStrm next.
				(updateStrm nextMatchAll: version) ifTrue: [
					(updateStrm atEnd or: [(updateStrm peek = Character cr) | 
						(updateStrm peek = Character lf)]) ifTrue: [
							foundIt := true
					]]]]].
	foundIt ifTrue: [
		updateStrm setToEnd.
		^ ''].
	self error: 'The current version does not have a section in the Updates file'.

]

{ #category : #preferences }
UpdateStreamDownloader class >> promptForUpdateServer [
	<preference: 'Prompt for update server'
	category: 'updates'
	description: 'If true, the prompt for server choice when updating code from the server. Set this to false to leave the server choice unchanged from update to update.'
	type: #Boolean>
	^PromptForUpdateServer ifNil: [ false ]
]

{ #category : #preferences }
UpdateStreamDownloader class >> promptForUpdateServer: aBoolean [
	PromptForUpdateServer := aBoolean
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> readNextUpdateFromServer [
	"UpdateStreamDownloader readNextUpdateFromServer"
	self updateFromServerThroughUpdateNumber: (ChangeSet highestNumberedChangeSet + 1)
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> readNextUpdatesFromDisk: n [
	"Read the updates up through the current highest-update-number plus n.  Thus, 
	UpdateStreamDownloader readNextUpdatesFromDisk: 7
will read the next seven updates from disk"

	self applyUpdatesFromDiskToUpdateNumber: ChangeSet highestNumberedChangeSet + n
		stopIfGap: false
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> readServer: serverList special: indexPrefix updatesThrough: maxNumber saveLocally: saveLocally updateImage: updateImage [
	"Scan the update server(s) for unassimilated updates. If maxNumber is not nil, it represents the highest-numbered update to load.  This makes it possible to update only up to a particular point.   If saveLocally is true, then save local copies of the update files on disc.  If updateImage is true, then absorb the updates into the current image."

"UpdateStreamDownloader readServer: UpdateStreamDownloader serverUrls updatesThrough: 828 saveLocally: true updateImage: true"

	| str urls failed loaded |
	Cursor wait showWhile: [ | docQueue docQueueSema |

	urls := self newUpdatesOn: (serverList collect: [:url | url, 'updates/']) 
				special: indexPrefix
				throughNumber: maxNumber.
	loaded := 0.
	failed := nil.

	"send downloaded documents throuh this queue"
	docQueue := SharedQueue new.

	"this semaphore keeps too many documents from beeing queueed up at a time"
	docQueueSema := Semaphore new.
	5 timesRepeat: [ docQueueSema signal ].

	"fork a process to download the updates"
	self retrieveUrls: urls ontoQueue: docQueue withWaitSema: docQueueSema.

	"process downloaded updates in the foreground"
	'Processing updates' displayProgressFrom: 0 to: urls size during: [:bar | | nextDoc this updateName |
	[ this := docQueue next.
	  nextDoc := docQueue next.  
	  nextDoc = #failed ifTrue: [ failed := this ].
	  (failed isNil and: [ nextDoc ~= #finished ])
	] whileTrue: [
		failed ifNil: [
			nextDoc reset; text.
			nextDoc size = 0 ifTrue: [ failed := this ]. ].
		failed ifNil: [
			nextDoc peek asciiValue = 4	"pure object file"
				ifTrue: [failed := this]].	"Must be fileIn, not pure object file"
		failed ifNil: [
			"(this endsWith: '.html') ifTrue: [doc := doc asHtml]."
				"HTML source code not supported here yet"
			updateImage
				ifTrue: [
					updateName := (this findTokens: '/') last.
					ChangeSet newChangesFromStream: nextDoc named: updateName.
					SystemVersion current registerUpdate: updateName initialIntegerOrNil].
			saveLocally ifTrue:
				[self saveUpdate: nextDoc onFile: (this findTokens: '/') last].	"if wanted"
			loaded := loaded + 1.
			bar value: loaded].

		docQueueSema signal].
	]].

	failed ~~ nil & (urls size - loaded > 0) ifTrue: [
		str := loaded printString ,' new update file(s) processed.'.
		str := str, '\Could not load ' withCRs, 
			(urls size - loaded) printString ,' update file(s).',
			'\Starting with "' withCRs, failed, '".'.
		self inform: str].
	^ Array with: failed with: loaded

]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> readServerUpdatesSaveLocally: saveLocally updateImage: updateImage [
	^ self readServerUpdatesThrough: nil saveLocally: saveLocally updateImage: updateImage
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> readServerUpdatesThrough: maxNumber saveLocally: saveLocally updateImage: updateImage [
	"Scan the update server(s) for unassimilated updates. If maxNumber is not nil, it represents the highest-numbered update to load.  This makes it possible to update only up to a particular point.   If saveLocally is true, then save local copies of the update files on disc.  If updateImage is true, then absorb the updates into the current image.

A file on the server called updates.list has the names of the last N update files.  We look backwards for the first one we do not have, and start there"
"* To add a new update:  Name it starting with a new two-digit code.  
* Do not use %, /, *, space, or more than one period in the name of an update file.
* The update name does not need to have any relation to the version name.
* Figure out which versions of the system the update makes sense for.
* Add the name of the file to each version's category below.
* Put this file and the update file on all of the servers.
*
* To make a new version of the system:  Pick a name for it (no restrictions)
* Put # and exactly that name on a new line at the end of this file.
* During the release process, fill in exactly that name in the dialog box.
* Put this file on the server."
"When two sets of updates need to use the same directory, one of them has a * in its 
serverUrls description.  When that is true, the first word of the description is put on
the front of 'updates.list', and that is the index file used."

"UpdateStreamDownloader readServerUpdatesThrough: 3922 saveLocally: true updateImage: true"

	| failed loaded str res servers triple tryAgain indexPrefix |
	UpdateStreamDownloader chooseUpdateList ifFalse: [^ self].	"ask the user which kind of updates"

	servers := UpdateStreamDownloader serverUrls copy.
	indexPrefix := (UpdateStreamDownloader updateUrlLists first first includes: $*) 
		ifTrue: [(UpdateStreamDownloader updateUrlLists first first findTokens: ' ') first]
						"special for internal updates"
		ifFalse: ['']. 	"normal"
	[servers isEmpty] whileFalse: [
		triple := self readServer: servers special: indexPrefix 
					updatesThrough: maxNumber 
					saveLocally: saveLocally updateImage: updateImage.

		"report to user"
		failed := triple first.
		loaded := triple second.
		tryAgain := false.
		failed ifNil: ["is OK"
			loaded = 0 ifTrue: ["found no updates"
				servers size > 1 ifTrue: ["not the last server"
					res := UIManager default 
							chooseFrom: #('Stop looking' 'Try next server')
							title: 
'No new updates on the server
', servers first, '
Would you like to try the next server?
(Normally, all servers are identical, but sometimes a
server won''t let us store new files, and gets out of date.)' 
						.
					res = 2 ifFalse: [^ self]
						 ifTrue: [servers := servers allButFirst.	"try the next server"
							tryAgain := true]]]].
		tryAgain ifFalse: [
			str := loaded printString ,' new update file(s) processed.'.
			^ self inform: str].
	].
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> retrieveUrls: urls ontoQueue: queue withWaitSema: waitSema [ 
	"download the given list of URLs. The queue will be loaded alternately  
	with url's and with the retrieved contents. If a download fails, the  
	contents will be #failed. If all goes well, a special pair with an empty  
	URL and the contents #finished will be put on the queue. waitSema is  
	waited on every time before a new document is downloaded; this keeps 
	the downloader from getting too far  ahead of the main process"
	"kill the existing downloader if there is one"
	| updateCounter |
	UpdateDownloader
		ifNotNil: [UpdateDownloader terminate].
	updateCounter := 0.
	"fork a new downloading process"
	UpdateDownloader := [
		'Downloading updates' displayProgressFrom: 0 to: urls size during: [:bar |
			urls
				do: [:url | | front canPeek doc | 
					waitSema wait.
					queue nextPut: url.
					doc := HTTPSocket httpGet: url.
					doc isString
						ifTrue: [queue nextPut: #failed.
							UpdateDownloader := nil.
							Processor activeProcess terminate]
						ifFalse: [canPeek := 120 min: doc size.
							front := doc next: canPeek.  doc skip: -1 * canPeek.
							(front beginsWith: '<!DOCTYPE') ifTrue: [
								(front includesSubstring: 'Not Found') ifTrue: [
									queue nextPut: #failed.
									UpdateDownloader := nil.
									Processor activeProcess terminate]]].
						UpdateDownloader ifNotNil: [queue nextPut: doc. updateCounter := updateCounter + 1. bar value: updateCounter]]].
			queue nextPut: ''.
			queue nextPut: #finished.
			UpdateDownloader := nil] newProcess.
	UpdateDownloader priority: Processor userInterruptPriority.
	"start the process running"
	UpdateDownloader resume
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> saveUpdate: doc onFile: fileName [
	"Save the update on a local file.  With or without the update number on the front, depending on the preference #updateRemoveSequenceNum"

	| file fName pos updateDirectory |

	(FileDirectory default directoryNames includes: 'updates') ifFalse:
		[FileDirectory default createDirectory: 'updates'].
	updateDirectory := FileDirectory default directoryNamed: 'updates'.

	fName := fileName.
	self updateRemoveSequenceNum ifTrue:
		[pos := fName findFirst: [:c | c isDigit not].
		fName := fName copyFrom: pos to: fName size].
	doc reset; ascii.
	(updateDirectory fileExists: fName) ifFalse:
		[file := updateDirectory newFileNamed: fName.
		file nextPutAll: doc contents.
		file close].

]

{ #category : #'server urls' }
UpdateStreamDownloader class >> serverUrls [ 
	"Return the current list of server URLs.  For code updates.  Format of UpdateUrlLists is 
#( ('squeak updates' ('url1' 'url2'))
    ('some other updates' ('url3' 'url4')))"

	| list |
	list := UpdateUrlLists first last.

	"If there is a dead server, return a copy with that server last" 
	Socket deadServer ifNotNil: [
		list shallowCopy withIndexDo: [:aName :ind |
		(aName beginsWith: Socket deadServer) ifTrue: [
			list := list asOrderedCollection.	"and it's a copy"
			list removeAt: ind.
			list addLast: aName]]
	].

	^ list asArray
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> setUpdateServer: groupName [
	"UpdateStreamDownloader setUpdateServer: 'Squeakland' "
	| entry index |


	entry := UpdateUrlLists detect: [:each | each first = groupName] ifNone: [^self].
	index := UpdateUrlLists indexOf: entry.
	UpdateUrlLists removeAt: index.
	UpdateUrlLists addFirst: entry
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> summariesForUpdates: startNumber through: stopNumber [
	"Answer the concatenation of summary strings for updates numbered in the given range"

	^ String streamContents: [:aStream |
		((ChangeSet changeSetsNamedSuchThat:
			[:aName | aName first isDigit
						 and: [aName initialIntegerOrNil >= startNumber
						and: [aName initialIntegerOrNil <= stopNumber]]]) sorted:
				[:a :b | a name < b name]) do:
					[:aChangeSet | aStream cr; nextPutAll: aChangeSet summaryString]]

"UpdateStreamDownloader summariesForUpdates: 4899 through: 4903"


]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> updateComment [
"The following used to be at the beginning of the update file.
	Now it is here to simplify parsing the file...

* To add a new update:  Name it starting with a new four-digit code.  
* Do not use %, /, *, space, or more than one period in the name of an update file.
* The update name does not need to have any relation to the version name.
* Figure out which versions of the system the update makes sense for.
* Add the name of the file to each version's category below.
* Put this file and the update file on all of the servers.
*
* To make a new version of the system:  Pick a name for it (no restrictions)
* Put # and exactly that name on a new line at the end of this file.
* During the release process, fill in exactly that name in the dialog box.
* Put a copy of updates.list on the server.
*
* Special file with a different name for Disney Internal Updates.  
* No need to move or rename files to release them to external updates.
"
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> updateFromServer [
	"Update the image by loading all pending updates from the server.  Also save local copies of the update files if the #updateSavesFile preference is set to true"

	self readServerUpdatesSaveLocally: self updateSavesFile updateImage: true
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> updateFromServerThroughUpdateNumber: aNumber [
	"Update the image by loading all pending updates from the server.  Also save local copies of the update files if the #updateSavesFile preference is set to true"

	self readServerUpdatesThrough: aNumber saveLocally: self updateSavesFile updateImage: true
]

{ #category : #preferences }
UpdateStreamDownloader class >> updateRemoveSequenceNum [
	^false
]

{ #category : #preferences }
UpdateStreamDownloader class >> updateSavesFile [
	<preference: 'Update saves files'
	category: 'updates'
	description: 'If true, then when an update is loaded from the server, a copy of it will automatically be saved on a local file as well.'
	type: #Boolean>
	^UpdateSavesFile ifNil: [ false ]
]

{ #category : #preferences }
UpdateStreamDownloader class >> updateSavesFile: aBoolean [
	UpdateSavesFile := aBoolean
]

{ #category : #'server urls' }
UpdateStreamDownloader class >> updateUrlLists [

	UpdateUrlLists ifNil: [UpdateUrlLists := OrderedCollection new].
	^ UpdateUrlLists
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> writeList: listContents toStream: strm [
	"Write a parsed updates.list out as text.
	This is the inverse of parseListContents:"

	
	strm reset.
	listContents do:
		[:pair | | version fileNames |
		version := pair first.  fileNames := pair last.
		strm nextPut: $#; nextPutAll: version; cr.
		fileNames do: [:fileName | strm nextPutAll: fileName; cr]].
	strm close
]

{ #category : #'fetching updates' }
UpdateStreamDownloader class >> zapUpdateDownloader [

	UpdateDownloader ifNotNil: [UpdateDownloader terminate].
	UpdateDownloader := nil.
]
