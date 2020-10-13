"
A small picture representing a page of a BookMorph here or somewhere else.  When clicked, make that book turn to the page and do a visual effect and a noise.

page			either the morph of the page, or a url
pageNumber
bookMorph		either the book, or a url
flipOnClick
"
Class {
	#name : #BookPageThumbnailMorph,
	#superclass : #SketchMorph,
	#instVars : [
		'page',
		'pageNumber',
		'bookMorph',
		'flipOnClick'
	],
	#category : #'MorphicExtras-Books'
}

{ #category : #menus }
BookPageThumbnailMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu add: 'make a flex morph' translated selector: #makeFlexMorphFor: argument: aHandMorph.
	flipOnClick
		ifTrue: [aCustomMenu add: 'disable bookmark action' translated action: #toggleBookmark]
		ifFalse: [aCustomMenu add: 'enable bookmark action' translated action: #toggleBookmark].
	(bookMorph isKindOf: BookMorph)
		ifTrue:
			[aCustomMenu add: 'set page sound' translated action: #setPageSound:.
			aCustomMenu add: 'set page visual' translated action: #setPageVisual:]

]

{ #category : #accessing }
BookPageThumbnailMorph >> bookMorph [

	^bookMorph
]

{ #category : #private }
BookPageThumbnailMorph >> computeThumbnail [
	| f scale |
	self objectsInMemory.
	f := page imageForm.
	scale := (self height / f height).  "keep height invariant"
"(Sensor shiftPressed) ifTrue: [scale := scale * 1.4]."
	self form: (f magnify: f boundingBox by: scale@scale smoothing: 2).


]

{ #category : #initialization }
BookPageThumbnailMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #private }
BookPageThumbnailMorph >> doPageFlip [
	"Flip to this page"

	self objectsInMemory.
	bookMorph ifNil: [^ self].
	bookMorph goToPageMorph: page
			transitionSpec: (self valueOfProperty: #transitionSpec).
	(owner isKindOf: PasteUpMorph) ifTrue:
		[owner cursor: (owner submorphs indexOf: self ifAbsent: [1])]
]

{ #category : #'piano rolls' }
BookPageThumbnailMorph >> encounteredAtTime: ticks inScorePlayer: scorePlayer atIndex: index inEventTrack: track secsPerTick: secsPerTick [
	"Flip to this page with no extra sound"
	BookMorph turnOffSoundWhile: [self doPageFlip]
]

{ #category : #'event handling' }
BookPageThumbnailMorph >> handlesMouseDown: event [

	^ event shiftPressed or: [flipOnClick and: [event controlKeyPressed not]]
]

{ #category : #accessing }
BookPageThumbnailMorph >> inBook: book [
	bookMorph := book
]

{ #category : #initialization }
BookPageThumbnailMorph >> initialize [
	"initialize the state of the receiver"

	| f |
	super initialize.
	flipOnClick := false.
	
	f := Form extent: 160@120 depth: Display depth.
	f fill: f boundingBox fillColor: color.
	self form: f
]

{ #category : #private }
BookPageThumbnailMorph >> makeFlexMorphFor: aHand [

	aHand grabMorph: (FlexMorph new originalMorph: page)
]

{ #category : #'event handling' }
BookPageThumbnailMorph >> mouseDown: event [
	"turn the book to that page"

	"May need to lie to it so mouseUp won't go to menu that may come up during fetch of a page in doPageFlip.  (Is this really true? --tk)"

	self doPageFlip.

]

{ #category : #'fileIn\/Out' }
BookPageThumbnailMorph >> objectForDataStream: refStrm [
	"I am about to be written on an object file.  It would be bad to write a whole BookMorph out.  Store a string that is the url of the book or page in my inst var."

	| clone bookUrl bb stem ind |
	(bookMorph isString) & (page isString) ifTrue: [
		^ super objectForDataStream: refStrm].
	(bookMorph isNil) & (page isString) ifTrue: [
		^ super objectForDataStream: refStrm].
	(bookMorph isNil) & (page url notNil) ifTrue: [
		^ super objectForDataStream: refStrm].
	(bookMorph isNil) & (page url isNil) ifTrue: [
		self error: 'page should already have a url' translated.
		"find page's book, and remember it"
		"bookMorph := "].
	
	clone := self shallowCopy.
	(bookUrl := bookMorph url)
		ifNil: [bookUrl := self valueOfProperty: #futureUrl].
	bookUrl 
		ifNil: [	bb := RectangleMorph new.	"write out a dummy"
			bb bounds: bounds.
			refStrm replace: self with: bb.
			^ bb]
		ifNotNil: [clone instVarNamed: 'bookMorph' put: bookUrl].

	page url ifNil: [
			"Need to assign a url to a page that will be written later.
			It might have bookmarks too.  Don't want to recurse deeply.  
			Have that page write out a dummy morph to save its url on the server."
		stem := SqueakPage stemUrl: bookUrl.
		ind := bookMorph pages identityIndexOf: page.
		page reserveUrl: stem,(ind printString),'.sp'].
	clone instVarNamed: 'page' put: page url.
	refStrm replace: self with: clone.
	^ clone
]

{ #category : #'fileIn\/Out' }
BookPageThumbnailMorph >> objectsInMemory [
	"See if page or bookMorph need to be brought in from a server."
	| bookUrl bk wld try |
	bookMorph ifNil: ["fetch the page"
		page isString ifFalse: [^ self].	"a morph"
		try := (SqueakPageCache atURL: page) fetchContents.
		try ifNotNil: [page := try].
		^ self].
	bookMorph isString ifTrue: [
		bookUrl := bookMorph.
		(wld := self world) ifNil: [wld := Smalltalk currentWorld].
		bk := BookMorph isInWorld: wld withUrl: bookUrl.
		bk == #conflict ifTrue: [
			^ self inform: 'This book is already open in some other project' translated].
		bk == #out ifTrue: [
			(bk := BookMorph new fromURL: bookUrl) ifNil: [^ self]].
		bookMorph := bk].
	page isString ifTrue: [
		page := (bookMorph pages detect: [:pg | pg url = page] 
					ifNone: [bookMorph pages first])].

]

{ #category : #accessing }
BookPageThumbnailMorph >> page [

	^ page

]

{ #category : #accessing }
BookPageThumbnailMorph >> page: aMorph [

	page := aMorph.
	self computeThumbnail.
	self setNameTo: aMorph externalName.
	page fullReleaseCachedState.

]

{ #category : #accessing }
BookPageThumbnailMorph >> pageMorph: pageMorph inBook: book [
	page := pageMorph.
	bookMorph := book
]

{ #category : #accessing }
BookPageThumbnailMorph >> pageNumber: n inBook: b [
	pageNumber := n.
	bookMorph := b
]

{ #category : #menus }
BookPageThumbnailMorph >> setPageSound: event [

	^ bookMorph menuPageSoundFor: self event: event
]

{ #category : #menus }
BookPageThumbnailMorph >> setPageVisual: event [

	^ bookMorph menuPageVisualFor: self event: event
]

{ #category : #initialization }
BookPageThumbnailMorph >> smaller [
	self form: (self form copy: (0@0 extent: self form extent//2)).

]

{ #category : #menus }
BookPageThumbnailMorph >> toggleBookmark [
	"Enable or disable sensitivity as a bookmark
		enabled means that a normal click will cause a pageFlip
		disabled means this morph can be picked up normally by the hand."

	flipOnClick := flipOnClick not
]

{ #category : #copying }
BookPageThumbnailMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
page := deepCopier references at: page ifAbsent: [page].
bookMorph := deepCopier references at: bookMorph ifAbsent: [bookMorph].

]

{ #category : #copying }
BookPageThumbnailMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"page := page.		Weakly copied"
pageNumber := pageNumber veryDeepCopyWith: deepCopier.
"bookMorph := bookMorph.		All weakly copied"
flipOnClick := flipOnClick veryDeepCopyWith: deepCopier. 
]
