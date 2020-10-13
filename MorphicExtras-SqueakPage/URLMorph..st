"
This morph represents a URL for a SqueakPage. It displays the thumbnail for the associated page, if available. Used in page sorters and for bookmarks.

This morph has several options:
  a. It can act like a thumbnail for sorting (in which case it can be picked up and dragged) or it acts as a bookmark (in which case shift clicking on it activates it).
  b. If it has book set to true, it is a page in a book.  Clicking fetches the index of the book, opens it to the first page, and puts it in the hand.

A thumbnail on a known book:
	(URLMorph grabURL: 'ftp://doltest1.disney.com/squeak/test/p1.sp')
		book: true.

A thumbnail on a single PasteUpMorph:
Make a PasteUpMorph with any morphs in it.
Decide where it should live, make a url string, and copy it.
	'file://HardDisk/books/book1/myPage.sp'
	'ftp://doltest1.disney.com/squeak/test/p1.sp'
Choose 'Save as Web Morph'
Paste in the url.
Drop the resulting thumbnail into some morph.

See SqueakPage's comment for the stages of in/out.

url 
page 		A SqueakPage
isBookmark 		Boolean
book 	A Boolean -- whether I represent a whole book or a page.

"
Class {
	#name : #URLMorph,
	#superclass : #BasicButton,
	#instVars : [
		'url',
		'page',
		'isBookmark',
		'book'
	],
	#category : #'MorphicExtras-SqueakPage'
}

{ #category : #'instance creation' }
URLMorph class >> grabForBook: bookMorph [
	"Create a URLMorph for this book.  Put it into the hand."

	| um bookUrl pageUrl pg |
	bookUrl := bookMorph valueOfProperty: #url.
	pageUrl := bookMorph currentPage url.	"should have one!"
	pg := SqueakPageCache atURL: pageUrl.
	(SqueakPage stemUrl: bookUrl) = (SqueakPage stemUrl: pageUrl) 
		ifTrue: [bookUrl := true].		"not a shared book"
	um := URLMorph newForURL: pageUrl.
	um setURL: pageUrl page: pg.
	pg isContentsInMemory ifTrue: [pg computeThumbnail].
	um isBookmark: true.
	um book: bookUrl.
	um removeAllMorphs.
	um color: Color transparent.
	Smalltalk currentHand attachMorph: um.
	^ um
]

{ #category : #'instance creation' }
URLMorph class >> grabURL: aURLString [
	"Create a URLMorph for this url.  Drop it and click it to get the SqueakPage."

	| um |
	(um := self new) isBookmark: true; setURL: aURLString page: nil.
	HandMorph attach: um.
	^ um
]

{ #category : #'instance creation' }
URLMorph class >> newBookmarkForURL: aURLString [

	^ (self newForURL: aURLString) isBookmark: true

]

{ #category : #'instance creation' }
URLMorph class >> newForURL: aURLString [

	| pg |
	pg := SqueakPageCache atURL: aURLString.
	^ self new setURL: aURLString page: pg

]

{ #category : #accessing }
URLMorph >> book [

	^ book

]

{ #category : #accessing }
URLMorph >> book: aUrl [
	"A notation about what book this page is in.  true means page is in same book as url strm says.  Set to the url of the Book if the book has a different stem url.  nil or false if not for a book page at all."

	book := aUrl
]

{ #category : #initialization }
URLMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #drawing }
URLMorph >> drawOn: aCanvas [
	"Draw thumbnail for my page, if it is available. Otherwise, just draw a rectangle." 

	| thumbnail oldExt |
	self color == Color transparent 
	ifTrue: ["show thumbnail"
		thumbnail := self thumbnailOrNil.
		thumbnail
			ifNil: [aCanvas frameRectangle: self bounds width: self borderWidth 
						color: self borderColor.
				aCanvas fillRectangle: (self bounds insetBy: self borderWidth) color: self color]
			ifNotNil: [oldExt := self bounds extent.
				bounds := self bounds origin extent: thumbnail extent + (2@2).
				aCanvas frameRectangle: self bounds width: self borderWidth color: self borderColor.
				aCanvas paintImage: thumbnail at: self bounds origin + self borderWidth.
				oldExt = thumbnail extent ifFalse: [self layoutChanged]]]
	ifFalse: ["show labeled button"
		^ super drawOn: aCanvas]

]

{ #category : #private }
URLMorph >> enclosingBook [
	"rethink this since class WebBookMorph is gone"
]

{ #category : #private }
URLMorph >> enclosingPage [
	"Answer the inner-most SqueakPage contents that contains this morph, or nil if there isn't one."

	self allOwnersDo:
		[:m | (m isKindOf: PasteUpMorph)
			ifTrue: [(SqueakPageCache pageForMorph: m) ifNotNil: [:pg | ^ pg]]].
	^ nil

]

{ #category : #'event handling' }
URLMorph >> handlesMouseDown: event [

	^ isBookmark & event shiftPressed

]

{ #category : #'event handling' }
URLMorph >> handlesMouseUp: evt [

	^ isBookmark

]

{ #category : #initialization }
URLMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	
	isBookmark := false
]

{ #category : #accessing }
URLMorph >> isBookmark [

	^ isBookmark

]

{ #category : #accessing }
URLMorph >> isBookmark: aBoolean [
	"Make this morph behave as a clickable bookmark if the argument is true."

	isBookmark := aBoolean.

]

{ #category : #private }
URLMorph >> label: aString font: aFontOrNil [

	| oldLabel m aFont |
	(oldLabel := self findA: StringMorph)
		ifNotNil: [oldLabel delete].
	(oldLabel := self findA: TextMorph)
		ifNotNil: [oldLabel delete].
	aFont := aFontOrNil ifNil: [Preferences standardButtonFont].
	m := TextMorph new contents: aString; beAllFont: aFont.
	self extent: (m width + 6) @ (m height + 6).
	m position: self center - (m extent // 2).
	self addMorph: m.
	m lock

]

{ #category : #'event handling' }
URLMorph >> mouseDown: evt [
	"do nothing"

]

{ #category : #'event handling' }
URLMorph >> mouseUp: evt [
	| pg ow newPage mm bookUrl bk |
	"If url of a book, open it to that page, or bring it in and open to that page."
	book ifNotNil: [book == false ifFalse: [
		(bookUrl := book) isString ifFalse: [
			bookUrl := (SqueakPage stemUrl: url), '.bo'].
		(bk := BookMorph isInWorld: self world withUrl: bookUrl) class ~~ Symbol 
			ifTrue: [^ bk goToPageUrl: url].
		bk == #conflict ifTrue: [
			^ self inform: 'This book is already open in some other project'].
		(bk := BookMorph new fromURL: bookUrl) ifNil: [^ self].
		bk goToPageUrl: url.	"turn to the page"
		^ HandMorph attach: bk]].

	"If inside a SqueakPage, replace it!"
	pg := self enclosingPage.
	pg ifNotNil: [
		(ow := pg contentsMorph owner) ifNotNil: [
			pg contentsMorph delete.	"from its owner"
			newPage := SqueakPageCache atURL: url.
			mm := newPage fetchContents.
			mm ifNotNil: [ow addMorph: mm.
				page := newPage].
			^ self]].
	"If I am a project, jump  -- not done yet"

	"For now, just put new page on the hand"
	newPage := SqueakPageCache atURL: url.
	mm := newPage fetchInformIfError.
	mm ifNotNil: [self primaryHand attachMorph: mm.
		page := newPage].


]

{ #category : #accessing }
URLMorph >> page [
	"Answer the cached page that this morph represents."

	^ page

]

{ #category : #updating }
URLMorph >> pageHasChanged: aSqueakPage [
	"The given page has changed. Update this morph if it refers to the given page."

	| thumbnail |
	page == aSqueakPage ifFalse: [^ self].  "this change does not affect me"
	thumbnail := self thumbnailOrNil.
	thumbnail ifNotNil: [
		self extent: (thumbnail extent + 2).
		self changed].

]

{ #category : #private }
URLMorph >> setURL: aURLString page: aSqueakPage [
	"Initialize the receiver for the given URL and page."

	url := aURLString.
	page := aSqueakPage.
	page ifNotNil: [self pageHasChanged: page].

]

{ #category : #private }
URLMorph >> thumbnailOrNil [
	"Answer the thumbnail Form for the page this morph represents. Answer nil if no thumbnail is available."

	| thum |
	page ifNil: [page := SqueakPageCache atURL: url].
	(thum := page thumbnail) ifNil: [^nil].
	^(thum isForm) 
		ifTrue: [thum]
		ifFalse: [thum form	"a BookPageThumbnailMorph"]
]

{ #category : #accessing }
URLMorph >> url [
	"Answer the URL for the page that this morph represents."

	^ url

]
