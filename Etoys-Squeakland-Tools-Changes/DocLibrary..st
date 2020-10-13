"
Method and Class shared documentation.  Pane in browser.  url for each official version of each method. Each update server group have a prefix (i=internal, e=external).  Point.x;.738.sp  Pane holds a pasteupmorph with comments and examples.  
	Must be very careful to give the right options for when to look for docs.  Could be annoying.  Look on disk.  If there, bring it in in background.  If not there, and network has been active this session, or within 15 mins, get from server (in background) and cache on disk.  
	When get updates, check for latest version of all comments in the cache.  
	Need quick registration of version of inst vars (less bulky and quick to check.)  If all inst var lists are the same as a certain release, mark it as that.  Each release (or update?) have an automatic known registration.
	Get doc, Get all docs for this class. //  Net: When you ask, If net has been used, Always (always gets in background) // From disk:  When you ask, always (laptop users do the former).
  	Security: Squeakers can write anything, including players.  Users can only add Morphic objects, not players.  (No new code)
	Mech:  Users write file to a server with open drop box.  Our server in Alan's office (the librarian) grabs the files once every two minutes, and scans them.  Code must be same as before.  Saves a copy.  Writes on official directory on two outside servers.
	Any combo of objects of existing classes that can crash the system, or deny service?  Should the librarian try all buttons first?  If it crashes, won't post it.
	Need another machine to check if the librarian is up, and beep Ted.  Could check a time stamp on the main server.  Users could also tell if librarian is up.  Number of docs in the queue.
	If we had mime really down, could have squeak email the page to the librarian.  What if the user does not know his pop server?  Use a standard one?  How keep spam out?
-----
[ ] set up folders, get reader going (no good interface yet)
group		Name of group of servers (internal/external)
lastUpdate	Number of last update we have.
lastUpdateName		File name without number for checking against ChangeSets.
methodVersions	Dictionary (class.method -> #(45 secs 120 secs 198 secs)) updates 
	that this method  appeared in.  From my version, check backwards till find a doc file on server.  secs is (Time totalSeconds) of file on the server (by its directory) of last version I have.  so can tell if have most recent one.  (use one day slop for older ones)
	point.x;.205.sp
	rectangle.205.sp
Names of this form that are too long are run through a dictionary and given a serial number.  It is (first two letters of class name), (crc16 of first half), (crc16 of second half).205.sp.  
	Can't store over a file in the drop box, so append random number to end of name.  Look at times to figure out which one is most recent when empty drop box.
			
localCachePath 	name of cache directory on local disk.  (Is shared between Squeaks on this machine, so might have things too new.)  In the form of a url 'file://disk/folder/'

Algorithm for finding the doc file:  
	Find my version
	Find version of current def of method relative to me.
	make file name.
	look locally
	check server, might have changed.

When put new update, no extra work needed.
When put a new version of the system, include External with methodVersions filled in.  If methods changed and not in a numbered update, must run a method to put them in the database.

When get updates, add new entries as we read updates.

Default method update number is 0.

AA _ DocLibrary new initialize.
AA scanFolder: 'file://Ted''s/Updates 328-/' from: 595.
DocLibrary classPool at: #External put: AA.

DocLibrary new setUp.

[How use internal updates, but do documentation for external?  Disable feature of adding to table when get updates.  Point to UIUC external directory and scan the latest ext updates.]
	When a docPane comes in, store property: #classAndMethod.  To put out, menu item ""Broadcast Documentation"" in PasteUpMorph that has the property.  DocLibrary puts out this morph.  Writes to drop box and local cache.
	In codePane, on more menu, ""Fetch Documentation"" (if none, ask if want blank one).  Creates a new pasteUpMorph after verifying that it doesn't have one.
	Later need preference and do fetch always and in the background.

	Crude review process -- a method here that brings up each pane that is in drop box (10 at a time).  First just shows code and text, not bring in.  Then bring in.  And a way for me to store it in the official directory.  (Do as menu items in file list?)  And archives and deletes for drop box.  (I do manually twice a day?)

	When write a file, take lastUpdateName and look for it in ChangeSet names.  When find, see if this method occurs in any newer changeSet.  If so, writing to an older version.  ""The documentation will be attached to the version of this method in xxx.cs.  You have a newer version of that method in yyy.cs.  If what you are storing applies only to the newer version, please do not broadcast it!  Wait until the new version is in an external update."" Broadcast to all Squeak users \ Cancel.  (Otherwise ""Make this documentation available to all Squeak users?"")

When fetch any updates, look for ""latest.ix""  Has format:
External   407   'aChangeSet.cs'
376.ix
'class method:' updateNumber
'class method' updateNumber
'class' updateNumber
	Keep local copy of updates.list and read it for files not mentioned yet in latest.ix.

·Warn the user if the method he is documenting is too new to be on the External updates server.
·Correcting the database of method versions when new External Updates are released.
·Create the file to put on the server with the database info for a new update.
·Methods to help the reviewer (me) scan files.  It will show me all the code, all the doits in text, and all the text.
·Allow documentation for classes, as opposed to methods. (written in file, in dict, just need interface)

self scanUpdatesIn: (ServerDirectory serverNamed: 'UpdatesExtUIUC') realUrl, '/'.

self updateMethodVersions.

[ ] When write, write to cache also.
[ ] If can't write to server, tell user to store again later.
[ ] Sparse database to tell if method has a docPane -- user fetches it explicitly.
[ ] Write to both servers.  Retrieve from either.  Drop box on just UIUC.

"
Class {
	#name : #DocLibrary,
	#superclass : #Object,
	#instVars : [
		'group',
		'lastUpdate',
		'lastUpdateName',
		'methodVersions'
	],
	#classVars : [
		'DocsCachePath',
		'DropBox',
		'External'
	],
	#category : #'Etoys-Squeakland-Tools-Changes'
}

{ #category : #'as yet unclassified' }
DocLibrary class >> external [
	"The dictionary for the External Updates"
	^ External
]

{ #category : #'as yet unclassified' }
DocLibrary class >> properStemFor: classAndMethod [
	"Put 'class method' into proper form as a file name.  Leave upper and lower case.  The fileName must be short enough and have proper characters for all platforms and servers."

	| sz |
	classAndMethod size > 23 ifTrue: ["too long"
		sz := classAndMethod size.
		"input contains space and :, not . and ;"
		^ (classAndMethod copyFrom: 1 to: 2), 
			((classAndMethod copyFrom: 3 to: sz//2) crc16 printString),
			((classAndMethod copyFrom: sz//2+1 to: sz) crc16 printString)
		].
	^ (classAndMethod copyReplaceAll: ' ' with: '.')
		copyReplaceAll: ':' with: ';'

]

{ #category : #'database of updates' }
DocLibrary >> absorbAfter: oldVersion from: fileName [
	"Read the .ix file and add to the methodVersions database.  See class comment."

	| server aUrl strm newUpdate newName prevFile classAndMethod updateID key verList new |
	server := ServerDirectory serverInGroupNamed: group.
		"later try multiple servers"
	aUrl := server altUrl, 'docpane/', fileName.
	strm := HTTPSocket httpGetNoError: aUrl
		args: nil accept: 'application/octet-stream'.
	strm class == RWBinaryOrTextStream ifFalse: [^ false].

	(strm upTo: $ ) = 'External' ifFalse: [strm close. ^ false].
	newUpdate := Integer readFrom: strm.
	newUpdate = oldVersion ifTrue: [strm close. ^ false].		"already have it"
 	strm upTo: $'.
	newName := strm nextDelimited: $'.  strm upTo: Character cr.
	prevFile := strm upTo: Character cr.
	"does this report on updates just after what I know?"
	oldVersion = (prevFile splitInteger first) ifFalse: [
		strm close. ^ prevFile].	"see earlier sucessor file"
	[strm atEnd] whileFalse: [
		strm upTo: $'.
		classAndMethod := strm nextDelimited: $'.  strm next.
		updateID := Integer readFrom: strm.
		key := DocLibrary properStemFor: classAndMethod.
		verList := methodVersions at: key ifAbsent: [#()].
		(verList includes: updateID) ifFalse: [
			new := verList, (Array with: updateID with: -1 "file date seen").
			methodVersions at: key put: new]].
	strm close.
	lastUpdate := newUpdate.
	lastUpdateName := newName.
	^ true
]

{ #category : #'doc pane' }
DocLibrary >> assureCacheFolder [
	"Make sure there is a folder docPaneCache and a file: url for it in DocsCachePath.  In local folder or one level up.  User may wish to install a different path and folder name (as a url).  Could be a url to a local server."

	| dir local |
	DocsCachePath ifNil: [
		dir := FileDirectory default.
		(dir includesKey: 'docPaneCache') ifTrue: [
			DocsCachePath := dir url, 'docPaneCache/']].
	DocsCachePath ifNil: [
		dir := FileDirectory default containingDirectory.
		DocsCachePath := dir url, 'docPaneCache/'.
		(dir includesKey: 'docPaneCache') ifFalse: [
			^ dir createDirectory: 'docPaneCache']].	"create the folder"
	local := ServerDirectory new fullPath: DocsCachePath.
	local exists ifFalse: [
		DocsCachePath := nil.	"we must be on a new disk"
		self assureCacheFolder].
]

{ #category : #'doc pane' }
DocLibrary >> cache: strm as: fileName [
	"Save the file locally in case the network is not available."

	| local |
	local := ServerDirectory new fullPath: DocsCachePath.
	(local fileNamed: fileName) nextPutAll: strm contents; close.
]

{ #category : #'doc pane' }
DocLibrary >> docNamesAt: classAndMethod [
	"Return a list of fileNames to try for this method.  'Point x:' is form of classAndMethod."

	| key verList fileNames |
	key := DocLibrary properStemFor: classAndMethod.
	verList := methodVersions at: key ifAbsent: [#()].
	fileNames := OrderedCollection new.
	1 to: verList size by: 2 do: [:ind |
		fileNames addFirst: key,'.',(verList at: ind) printString, '.sp'].
	fileNames addLast: key,'.0.sp'.
	^ fileNames
]

{ #category : #'doc pane' }
DocLibrary >> docNamesAt: classAndMethod asOf: currentUpdate [
	"Return a list of fileNames to try for this method.  'Point x:' is form of classAndMethod."

	| key verList fileNames |
	key := DocLibrary properStemFor: classAndMethod.
	verList := methodVersions at: key ifAbsent: [#()].
	fileNames := OrderedCollection new.
	1 to: verList size by: 2 do: [:ind |
		(verList at: ind) <= currentUpdate ifTrue: [
			fileNames addFirst: key,'.',(verList at: ind) printString, '.sp']].
	fileNames addLast: key,'.0.sp'.
	^ fileNames
]

{ #category : #'doc pane' }
DocLibrary >> docObjectAt: classAndMethod [
	"Return a morphic object that is the documentation pane for this method.  nil if none can be found.  Look on both the network and the disk."

	| fileNames server aUrl strm local obj |
	methodVersions size = 0 ifTrue: [self updateMethodVersions].	"first time"
	fileNames := self docNamesAt: classAndMethod.
	self assureCacheFolder.
	"server := (ServerDirectory serverInGroupNamed: group) clone."  "Note: directory ends with '/updates' which needs to be '/docpane', but altUrl end one level up"
	server := ServerDirectory serverInGroupNamed: group.
		"later try multiple servers"
	aUrl := server altUrl, 'docpane/'.
	fileNames do: [:aVersion | 
		strm := HTTPSocket httpGetNoError: aUrl,aVersion 
			args: nil accept: 'application/octet-stream'.
		strm class == RWBinaryOrTextStream ifTrue: [
			self cache: strm as: aVersion.
			strm reset.
			obj := strm fileInObjectAndCode asMorph.
			(obj valueOfProperty: #classAndMethod) = classAndMethod ifFalse: [
				self inform: 'suspicious object'.
				obj setProperty: #classAndMethod toValue: classAndMethod].
			^ obj].	"The pasteUpMorph itself"
		"If file not there, error 404, just keep going"].
	local := ServerDirectory new fullPath: DocsCachePath.
	"check that it is really there -- let user respecify"
	fileNames do: [:aVersion | 
		(local includesKey: aVersion) ifTrue: [
			strm := local readOnlyFileNamed: aVersion.
			obj := strm fileInObjectAndCode asMorph.
			(obj valueOfProperty: #classAndMethod) = classAndMethod ifFalse: [
				self inform: 'suspicious object'.
				obj setProperty: #classAndMethod toValue: classAndMethod].
			Transcript cr; show: 'local cache: ', aVersion.
			^ obj].	"The pasteUpMorph itself"
		"If file not there, just keep looking"].
	"Never been documented"
	^ nil
]

{ #category : #'doc pane' }
DocLibrary >> fetchDocSel: aSelector class: className [
	"Look on servers to see if there is documentation pane for the selected message. Take into account the current update number.  If not, ask the user if she wants to create a blank one."

	| key response docPane ext |
	key := aSelector size = 0 
		ifFalse: [className, ' ', aSelector]
		ifTrue: [className].
	(self openDocAt: key) ifNil: [
		response := (PopUpMenu labels: 'Create new page\Cancel' withCRs)
				startUpWithCaption: 'No documentation exists for this method.\
Would you like to write some?' withCRs.
		response = 1 ifTrue: [
			docPane := PasteUpMorph new.
			docPane color: Color white; borderWidth: 2; borderColor: Color green.
			docPane setProperty: #classAndMethod toValue: key.
			docPane setProperty: #initialExtent toValue: (ext := 200@200).
			docPane topLeft: (RealEstateAgent initialFrameFor: docPane world: Smalltalk currentWorld) origin.
			docPane extent: ext.
			docPane addMorph: (TextMorph new topLeft: docPane topLeft + (10@10);
					extent: docPane width - 15 @ 30).
			Smalltalk currentWorld addMorph: docPane]].

	"If found, openDocAt: put it on the screen"
]

{ #category : #initialize }
DocLibrary >> initialize [
	lastUpdate := 0.
	methodVersions := Dictionary new.
]

{ #category : #'doc pane' }
DocLibrary >> openDocAt: classAndMethod [

	| docPane |
	(docPane := self docObjectAt: classAndMethod) ifNotNil: [
		docPane setProperty: #initialExtent toValue: docPane bounds extent.
		docPane topLeft: (RealEstateAgent initialFrameFor: docPane world: Smalltalk currentWorld) origin.
		Smalltalk currentWorld addMorph: docPane].
	^ docPane
]

{ #category : #'doc pane' }
DocLibrary >> saveDoc: aMorph [
	"Broadcast this documentation to the Squeak community.  Associate it with the method it documents.  Send to a drop box, where it can be inspected before being posted on External servers."

	| classAndMethod fName remoteFile |
	classAndMethod := aMorph valueOfProperty: #classAndMethod.
	classAndMethod ifNil: [
		^ self error: 'need to know the class and method'].	"later let user set it"
	fName := (self docNamesAt: classAndMethod) first.
	DropBox user asLowercase = 'anonymous' ifTrue: [
		fName := fName, 1000 atRandom printString].	"trusted users store directly"
	DropBox password.	"In case user has to type it.  Avoid timeout from server"
	Cursor wait showWhile: [
		remoteFile := DropBox fileNamed: fName.
		remoteFile fileOutClass: nil andObject: aMorph.
		"remoteFile close"].

]

{ #category : #'doc pane' }
DocLibrary >> saveDocCheck: aMorph [
	"Make sure the document gets attached to the version of the code that the user was looking at.  Is there a version of this method in a changeSet beyond the updates we know about?  Works even when the user has internal update numbers and the documentation is for external updates (It always is)."

	| classAndMethod parts selector class lastUp beyond ours docFor unNum ok key verList ext response |
	classAndMethod := aMorph valueOfProperty: #classAndMethod.
	classAndMethod ifNil: [
		^ self error: 'need to know the class and method'].	"later let user set it"
	parts := classAndMethod findTokens: ' .'.
	selector := parts last asSymbol.
	class := Smalltalk at: (parts first asSymbol) ifAbsent: [^ self saveDoc: aMorph].
	parts size = 3 ifTrue: [class := class class].
	"Four indexes we are looking for:
		docFor = highest numbered below lastUpdate that has method.
		unNum = a higher unnumbered set that has method.
		lastUp = lastUpdate we know about in methodVersions
		beyond = any set about lastUp that has the method."
	ChangeSet allChangeSets doWithIndex: [:cs :ind | "youngest first"
		(cs name includesSubstring: lastUpdateName) ifTrue: [lastUp := ind].
		(cs atSelector: selector class: class) ~~ #none ifTrue: [
			lastUp ifNotNil: [beyond := ind. ours := cs name]
				ifNil: [cs name first isDigit ifTrue: [docFor := ind] 
						ifFalse: [unNum := ind. ours := cs name]]]].
	"See if version the user sees is the version he is documenting"
	ok := beyond == nil.
	unNum ifNotNil: [docFor ifNotNil: [ok := docFor > unNum]
						ifNil: [ok := false]].  "old changeSets gone"
	ok ifTrue: [^ self saveDoc: aMorph].

	key := DocLibrary properStemFor: classAndMethod.
	verList := (methodVersions at: key ifAbsent: [#()]), #(0 0).
	ext := verList first.	"external update number we will write to"
	response := (PopUpMenu labels: 'Cancel\Broadcast Page' withCRs)
				startUpWithCaption: 'You are documenting a method in External Update ', ext asString, '.\There is a more recent version of that method in ' withCRs, ours, 
'.\If you are explaining the newer version, please Cancel.\Wait until that version appears in an External Update.' withCRs.
	response = 2 ifTrue: [self saveDoc: aMorph].

]

{ #category : #'database of updates' }
DocLibrary >> scan: updateStream updateID: updateID [
	"Scan this update file and remember the update numbers of the methods."

	| changeList ee semi key verList new |
	updateStream reset; readOnly.
	Cursor read showWhile:
		[changeList := ChangeList new
			scanFile: updateStream from: 0 to: updateStream size].
	changeList list do: [:entry |
		ee := nil.
		(entry beginsWith: 'method: ') ifTrue: [
			(semi := entry indexOf: $;) = 0 
				ifTrue: [semi := entry size]
				ifFalse: [semi := semi-1].
			ee := entry copyFrom: 9 to: semi].
		(entry beginsWith: 'class comment for ') ifTrue: [
			(semi := entry indexOf: $;) = 0 
				ifTrue: [semi := entry size]
				ifFalse: [semi := semi-1].
			ee := entry copyFrom: 19 to: semi].	"comment for whole class"
		ee ifNotNil: [
			key := DocLibrary properStemFor: ee.
			Transcript show: key; cr.
			verList := methodVersions at: key ifAbsent: [#()].
			(verList includes: updateID) ifFalse: [
				new := verList, (Array with: updateID with: -1 "file date seen").
				methodVersions at: key put: new]].
		].
]

{ #category : #'database of updates' }
DocLibrary >> scan: updateStream updateID: updateID writeOn: strm [
	"Scan this update file and remember the update numbers of the methods."

	| changeList ee semi |
	updateStream reset; readOnly.
	Cursor read showWhile:
		[changeList := ChangeList new
			scanFile: updateStream from: 0 to: updateStream size].
	changeList list do: [:entry |
		ee := nil.
		(entry beginsWith: 'method: ') ifTrue: [
			(semi := entry indexOf: $;) = 0 
				ifTrue: [semi := entry size]
				ifFalse: [semi := semi-1].
			ee := entry copyFrom: 9 to: semi].
		(entry beginsWith: 'class comment for ') ifTrue: [
			(semi := entry indexOf: $;) = 0 
				ifTrue: [semi := entry size]
				ifFalse: [semi := semi-1].
			ee := entry copyFrom: 19 to: semi].	"comment for whole class"
		ee ifNotNil: [
			Transcript show: ee; cr.
			strm cr; nextPutAll: ee surroundedBySingleQuotes; space;
				nextPutAll: updateID asString].
		].
]

{ #category : #'database of updates' }
DocLibrary >> scanFolder: directoryUrl from: updateID [
	"Scan all update files in the directory starting at updateID+1.  updates.list must be present to tell us the file names."

	| updateList line num |
	updateList := (ServerFile new fullPath: directoryUrl,'updates.list') asStream.
	[line := updateList upTo: Character cr.
	updateList atEnd] whileFalse: [
		line first isDigit ifTrue: [
			num := line splitInteger first.
			num > updateID ifTrue: [
				self scan: (ServerFile new fullPath: directoryUrl,line) asStream
					updateID: num]
			]].
	lastUpdate <= num ifTrue: [
		lastUpdate := num.
		lastUpdateName := line splitInteger last].


]

{ #category : #'database of updates' }
DocLibrary >> scanUpdatesIn: directoryUrl [
	"Scan all update files in the directory starting at lastUpdate+1.  Create a .ix file on my local hard disk.  updates.list must be present to tell us the file names."

	| updateList line num temp out |
	updateList := (ServerFile new fullPath: directoryUrl,'updates.list') asStream.
	temp := WriteStream on: (String new: 2000).
	[line := updateList upTo: Character cr.
	updateList atEnd] whileFalse: [
		line first isDigit ifTrue: [
			num := line splitInteger first.
			num > lastUpdate ifTrue: [
				self scan: (ServerFile new fullPath: directoryUrl,line) asStream
					updateID: num writeOn: temp]
			]].
	num >= lastUpdate ifTrue: [
		out := FileStream newFileNamed: 'to', num asString, '.ix'.
		out nextPutAll: 'External ', num asString; space. 
		line splitInteger last storeOn: out.	"quoted"
		out cr; nextPutAll: lastUpdate asString, '.ix' "; cr".	"temp begins with cr"
		out nextPutAll: temp contents; close.
		self inform: 'Rename latest.ix to ', lastUpdate asString, 
			'.ix on both external servers.
Put to', num asString, '.ix on both and call it latest.ix'].
	
]

{ #category : #initialize }
DocLibrary >> setUp [
	"set up the External version"
	| email |
	self initialize.
	External := self.
	group := 'Squeak Public Updates'.	"right for http, but not for ftp"
	lastUpdate := 599.
	lastUpdateName := 'MTMcontainsPoint-ar.cs'.
	DropBox := ServerDirectory new.
	DropBox server: 'squeak.cs.uiuc.edu'; directory: 'incoming'.
	DropBox type: #ftp.
	email := nil.  "Celeste popUserName."	"If nil, we ask at drop time"
	DropBox user: 'anonymous'; password: email.
	DropBox moniker: 'Doc Pane DropBox'.
		"later allow a second server"

]

{ #category : #'database of updates' }
DocLibrary >> updateMethodVersions [
	"See if any new updates have occurred, and put their methods into the database."

	| indexFile list result |
	indexFile := 'latest.ix'.
	list := OrderedCollection new.
	[result := self absorbAfter: lastUpdate from: indexFile.
	"boolean if succeeded, or we are up to date, or server not available"
	 result isString] whileTrue: [
		"result is the prev file name"
		list addFirst: indexFile.
		indexFile := result].
	list do: [:aFile | self absorbAfter: lastUpdate from: aFile].
		"should always work this time"

]
