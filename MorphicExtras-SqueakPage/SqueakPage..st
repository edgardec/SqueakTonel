"
A SqueakPage is holder for a page of morphs that live on the disk or on a server.
A URLMorph is a thumbnail sized stand-in for the page.  Clicking on it gets the page.
An ObjectOut is a fake object that stands for an object that is out on the disk.  (Like ObjectTracer or ObjectViewer.)
A MorphObjectOut is a subclass that stands for a Morph that is out on the disk.

To find out how to make the pages of any BookMorph go out to the disk (or a server), see 	http://minnow.cc.gatech.edu/SqueakDoc.1 then go to 'SqueakPages'.

A SqueakPage is always in-memory.  Its contentsMorph will be 'become-ed' to a MorphObjectOut tombstone when it goes out.  (A page may or may not be in the cache.  First put it in, then ask it for the data.)  Sending any message to the contentsMorph triggers the fetch.  Many URLMorphs may hold onto one page.  A page has a thumbnail.  A URLMorph points at its page object.

States of a SqueakPage, and the transitions to another state:
1) have a url as a string.  Then: (URLMorph grabURL: 'file://Ted''s/books/tryThis/p1').  
	Drop it into any morph.
2) have a URLMorph, with page==nil.     Click it.  (makes an empty page, installs 
	it in the global page cache)
3) have a URLMorph with a SqueakPage, with contentsMorph==nil, 
	but page is not in the cache (this is a rare case).  ask page contentsMorph.
4) OUT: have a URLMorph with a SqueakPage, with contentsMorph being a MorphObjectOut, 
	and its page is in the cache.  Sending the contentsMorph any message brings it in and
	becomes it to the morph.  (fix up morph's pointer to the page.)
5) Totally IN:  a morph, owned by a SqueakPage, has a page in the cache.  
	The morph is clean.   
	Whenever someone triggers a purge (when?), contentsMorph is becomed
	to a MorphObjectOut. (go to 4)
	Causing the morph to execute layoutChanged marks the morph as dirty.
	(morph's property #pageDirty is set to true) (go to 6)
6) Totally IN and dirty.  
	Whenever any other page is fetched from the disk or the net, all other 
	dirty pages are written and marked clean.  (go to 5)

Note that the entire tree of submorphs goes out -- hundreds of objects.  Bringing the object back in brings in the SqueakPage, installs it in the cache.  Classes other than PasteUpMorph can easily be made to send their contents out if there is any need.

Note that every book is now automatically a WebBook.  We simply give a page a url and tell it to purge.

url		a string
title		
comment		
thumbnail		
contentsMorph		(1) a pasteUpMorph with other morphs in it.
					(2) a MorphObjectOut.  Sending any message brings it in. 
					(3) nil if the page has never been in this image.
creationTime		
creationAuthor		
lastChangeTime		
lastChangeAuthor 
policy		#alwaysWrite, #neverWrite, #ask.  (cache can override with a global policy)
			(Explicit writing by user has policy #neverWrite)
dirty 		(Morph>>layoutChanged sends changed: #SqueakPage. If policy==#check, 
				then the page sets dirty_true.)
			(If policy==#alwaysWrite, then set dirty when the page is retrieved from the cache.)

Class MorphObjectOut has an instance variable called page.
All messages to an MorphObjectOut cause it to be brought in.  Except the messages needed to write the MorphObjectOut on the disk as part of a parent's being sent out.  (size, class, instSize, instVar:at:.  Can rename these and call from its own version of the writing routine.)
	To purge, go through the clean pages, and any that have world not equal to this world, entomb them.  
	(If an object in the subtree is held by an object outside the tree, it will remain,  And will be duplicated when the tree comes back in.  This is a problem already in normal uses of SmartRefStream.)



"
Class {
	#name : #SqueakPage,
	#superclass : #Object,
	#instVars : [
		'url',
		'title',
		'comment',
		'thumbnail',
		'contentsMorph',
		'creationTime',
		'creationAuthor',
		'lastChangeTime',
		'lastChangeAuthor',
		'policy',
		'dirty'
	],
	#classVars : [
		'MaxThumbnailWidthOrHeight',
		'RecentMaxNum',
		'RecentStem'
	],
	#category : #'MorphicExtras-SqueakPage'
}

{ #category : #'class initialization' }
SqueakPage class >> initialize [
	"SqueakPage initialize"

	MaxThumbnailWidthOrHeight := 60.

]

{ #category : #'instance creation' }
SqueakPage class >> newURLAndPageFor: aMorph [
	"Create a new SqueakPage whose contents is the given morph. Assign a URL for that page, record it in the page cache, and answer its URL."

	| pg newURL stamp |
	pg := self new.
	stamp := Utilities authorInitialsPerSe.
	stamp isEmptyOrNil ifTrue: [ stamp := '*' ].
	pg saveMorph: aMorph author: stamp.
	newURL := SqueakPageCache generateURL.
	SqueakPageCache atURL: newURL put: pg.
	^ newURL
]

{ #category : #utilties }
SqueakPage class >> stemUrl: aUrlString [
	"Peel off the 'x5.sp'  or '.bo' from the end of a url of a SqueakPage or a BookMorph index file"

	| ll aUrl |
	ll := aUrlString findLast: [:char | char == $.].
	ll = 0 
		ifTrue: [aUrl := aUrlString]
		ifFalse: [aUrl := aUrlString copyFrom: 1 to: ll-1].	"remove .sp"
	aUrl := (aUrl stemAndNumericSuffix) at: 1.
			"remove trailing number"
	aUrl size = 0 ifTrue: [^ aUrl].	"empty"
	[aUrl last == $x] whileTrue: [aUrl := aUrl allButLast].
	^ aUrl
]

{ #category : #accessing }
SqueakPage >> asMorph [
	^ self fetchContents
]

{ #category : #accessing }
SqueakPage >> comment [

	comment ifNil: [^ ''] ifNotNil: [^ comment].

]

{ #category : #accessing }
SqueakPage >> comment: aString [

	aString isEmpty
		ifTrue: [comment := nil]
		ifFalse: [comment := aString].

]

{ #category : #private }
SqueakPage >> computeThumbnail [
	"Make a thumbnail from my morph."

	(contentsMorph isKindOf: PasteUpMorph) 
		ifTrue: [thumbnail := contentsMorph smallThumbnailForPageSorter]
		ifFalse: [self updateThumbnail]
]

{ #category : #accessing }
SqueakPage >> contentsMorph [
	"Return what it is now.  If the morph is out on the disk, return nil.  Use fetchContents to get the data for sure."

	^ contentsMorph

]

{ #category : #accessing }
SqueakPage >> contentsMorph: aPasteUpMorph [

	contentsMorph := aPasteUpMorph
]

{ #category : #accessing }
SqueakPage >> copyForSaving [
	"Make a copy and configure me to be put out on the disk.  When it is brought in and touched, it will turn into the object at the url."

	| forDisk holder |
	forDisk := self shallowCopy.
	holder := MorphObjectOut new xxxSetUrl: url page: forDisk.
	forDisk contentsMorph: holder.
	^ holder		"directly representing the object"
]

{ #category : #saving }
SqueakPage >> dirty: aBool [
	dirty := aBool
]

{ #category : #accessing }
SqueakPage >> fetchContents [
	"Make every effort to get contentsMorph."

	self isContentsInMemory ifTrue: [^ contentsMorph].
	^ self fetchInformIfError
]

{ #category : #accessing }
SqueakPage >> fetchContentsIfAbsent: failBlock [
	"Make every effort to get contentsMorph.  Assume I am in the cache already."
	| strm page temp temp2 |
	SqueakPageCache write.		"sorry about the pause"
	strm := Cursor wait showWhile: [
		(ServerFile new fullPath: url) asStream].
	strm isString ifTrue: [^ failBlock value].		
	page := strm fileInObjectAndCode.
	page isMorph ifTrue: [contentsMorph := page].	"may be a bare morph"
	"copy over the state"
	temp := url.
	temp2 := policy.
	self copyAddedStateFrom: page.
	url := temp.	"don't care what it says"
	temp2 ifNotNil: [policy := temp2].		"use mine"
	contentsMorph setProperty: #pageDirty toValue: nil.
	self dirty: false.
	^ contentsMorph
]

{ #category : #accessing }
SqueakPage >> fetchInformIfError [
	"Make every effort to get contentsMorph.  Put up a good notice if can't get it.  Assume page is in the cache already.  Overwrite the contentsMorph no matter what."
	| strm page temp temp2 |

	SqueakPageCache write.		"sorry about the pause"
	strm := Cursor wait showWhile: [
		(ServerFile new fullPath: url) asStream].
	strm isString ifTrue: [self inform: 'Sorry, ',strm. ^ nil].	"<<<<< Note Diff"
	(url beginsWith: 'file:') ifTrue: [Transcript show: 'Fetching  ', url; cr].	
	page := strm fileInObjectAndCode.
	page isMorph 
		ifTrue: [contentsMorph := page]	"may be a bare morph"
		ifFalse: ["copy over the state"
			temp := url.
			temp2 := policy.
			self copyFrom: page.	"including contentsMorph"
			url := temp.	"I know best!"
			temp2 ifNotNil: [policy := temp2]].		"use mine"
	contentsMorph setProperty: #pageDirty toValue: nil.
	contentsMorph setProperty: #SqueakPage toValue: self.
	self dirty: false.
	^ contentsMorph
]

{ #category : #accessing }
SqueakPage >> isContentsInMemory [
	"Is my contentsMorph in memory, or is it an ObjectOut tombstone?  Be careful not to send it any message."

	^ (contentsMorph xxxClass inheritsFrom: Object) and: [(contentsMorph == nil) not]
]

{ #category : #accessing }
SqueakPage >> lastChangeTime [
	^ lastChangeTime
]

{ #category : #saving }
SqueakPage >> policy [
	^ policy
]

{ #category : #saving }
SqueakPage >> policy: aSymbol [
	policy := aSymbol
]

{ #category : #private }
SqueakPage >> postChangeNotification [
	"Inform all thumbnails and books that this page has been updated."

	URLMorph allSubInstancesDo: [:m | m pageHasChanged: self].

]

{ #category : #saving }
SqueakPage >> prePurge [
	"Return self if ready to be purged, or nil if not"

	self isContentsInMemory ifFalse: [^ nil].
	contentsMorph ifNil: [^ nil].  "out already"
	url ifNil: [^ nil].	"just to be safe"
	^ (Project current world ~~ nil and: [contentsMorph world == Project current world]) 
		ifTrue: [nil "showing now"] ifFalse: [self]
]

{ #category : #saving }
SqueakPage >> purge [
	"Replace my morph with a tombstone, if I am not in a world that is being shown."

	(self prePurge) ifNotNil: [
		contentsMorph becomeForward: (MorphObjectOut new xxxSetUrl: url page: self)].
		"Simple, isn't it!"
]

{ #category : #accessing }
SqueakPage >> saveMorph: aMorph author: authorString [
	"Save the given morph as this page's contents. Update its thumbnail and inform references to this URL that the page has changed."
	"Details: updateThumbnail releases the cached state of the saved page contents after computing the thumbnail."

	| n |
	contentsMorph := aMorph.
	n := aMorph knownName.
	n ifNotNil: [self title: n].
	creationAuthor ifNil: [
		creationAuthor := authorString.
		creationTime := Time totalSeconds].
"	lastChangeAuthor := authorString.
	lastChangeTime := Time totalSeconds.	do it when actually write"
	self computeThumbnail.
	self postChangeNotification.

]

{ #category : #accessing }
SqueakPage >> thumbnail [

	^ thumbnail

]

{ #category : #accessing }
SqueakPage >> title [

	title ifNil: [^ ''] ifNotNil: [^ title].

]

{ #category : #accessing }
SqueakPage >> title: aString [

	aString isEmpty
		ifTrue: [title := nil]
		ifFalse: [title := aString].

]

{ #category : #private }
SqueakPage >> updateThumbnail [
	"Update my thumbnail from my morph."

	| f scale scaleX scaleY shrunkF |
	contentsMorph ifNil: [thumbnail := nil. ^ self].
	f := contentsMorph imageForm.
	scaleX := MaxThumbnailWidthOrHeight asFloat / f height.
	scaleY := MaxThumbnailWidthOrHeight asFloat/ f width.
	scale := scaleX min: scaleY.  "choose scale that maintains aspect ratio"
	shrunkF := (f magnify: f boundingBox by: scale@scale smoothing: 2).
	thumbnail := Form extent: shrunkF extent depth: 8.  "force depth to be 8"
	shrunkF displayOn: thumbnail.
	contentsMorph allMorphsDo: [:m | m releaseCachedState].

]

{ #category : #accessing }
SqueakPage >> url [

	^ url
]

{ #category : #accessing }
SqueakPage >> url: aString [

	| sd |
	aString isEmpty ifTrue: [url := nil. ^ self].

	"Expand ./ and store as an absolute url"
	sd := ServerFile new.
	sd fullPath: aString.
	url := sd realUrl.
]

{ #category : #saving }
SqueakPage >> urlNoOverwrite: suggested [
	"Look in the directory.  If there is a file of this name, create a new name.  Keep track of highest numbers used as a hint."

	| dir ll stem num local trial suffix |
	(suggested endsWith: '.sp') ifTrue: [suffix := '.sp'].
	(suggested endsWith: '.bo') ifTrue: [suffix := '.bo'].
	suffix ifNil: [self error: 'unknown suffix'].
	dir := ServerFile new fullPath: suggested.
	(dir includesKey: dir fileName) ifFalse: [^ url := suggested].
	"File already exists!  Create a new name"
	"Find the stem file name"
	stem := SqueakPage stemUrl: suggested.
	num := stem = RecentStem ifTrue: [RecentMaxNum+1] ifFalse: [1].

	local := dir fileName.	"ugh, take stem again..."
	ll := local findLast: [:char | char == $.].
	ll = 0 ifFalse: [local := local copyFrom: 1 to: ll-1].	"remove .sp"
	local := (local splitInteger) at: 1.		"remove trailing number"
	local last == $x ifFalse: [local := local , 'x'].
	[trial := local, num printString, suffix.
		dir includesKey: trial] whileTrue: [num := num + 1].
	RecentStem := stem.  RecentMaxNum := num.
	^ url := stem, 'x', num printString, suffix
]

{ #category : #saving }
SqueakPage >> write [
	"Decide whether to write this page on the disk."
	| sf |
	policy == #neverWrite ifTrue: [^ self].
		"demo mode, or write only when user explicitly orders it"

	"All other policies do write:   #now"
	contentsMorph ifNil: [^ self].
	dirty := dirty | ((contentsMorph valueOfProperty: #pageDirty) == true).
		"set by layoutChanged"
	dirty == true ifTrue: [ 
		sf := ServerDirectory new fullPath: url.
		"check for shared password"
		"contentsMorph allMorphsDo: [:m | m prepareToBeSaved].
				done in objectToStoreOnDataStream"
		lastChangeAuthor := Utilities authorInitialsPerSe.
		lastChangeAuthor isEmptyOrNil ifTrue: [ lastChangeAuthor := '*'].
		lastChangeTime := Time totalSeconds.
		Cursor wait showWhile: [ | remoteFile |
			remoteFile := sf fileNamed: url.	"no notification when overwriting"
			remoteFile dataIsValid.
			remoteFile fileOutClass: nil andObject: self.
			"remoteFile close"].
		contentsMorph setProperty: #pageDirty toValue: nil.
		dirty := false].
]
