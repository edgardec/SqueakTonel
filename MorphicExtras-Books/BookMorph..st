"
A collection of pages, each of which is a place to put morphs.  Allows one or another page to show; orchestrates the page transitions; offers control panel for navigating among pages and for adding and deleting pages.

To write a book out to the disk or to a file server, decide what folder it goes in.  Construct a url to a typical page:
	file://myDisk/folder/myBook1.sp
or
	ftp://aServer/folder/myBook1.sp

Choose ""send all pages to server"" from the book's menu (press the <> part of the controls).  Choose ""use page numbers"".  Paste in the url.

To load an existing book, find its "".bo"" file in the file list browser.  Choose ""load as book"".

To load an existing book from its url, execute:
¦(URLMorph grabURL: 'ftp://aServer/folder/myBook1.sp') book: true.

Multiple people may modify a book.  If other people may have changed a book you have on your screen, choose ""reload all from server"".

Add or modify a page, and choose ""send this page to server"".

The polite thing to do is to reload before changing a book.  Then write one or all pages soon after making your changes.  If you store a stale book, it will wipe out changes that other people made in the mean time.

Pages may be linked to each other.  To create a named link to a new page, type the name of the page in a text area in a page.  Select it and do Cmd-6.  Choose 'link to'.  A new page of that name will be added at the back of the book.  Clicking on the blue text flips to that page.  
	To create a link to an existing page, first name the page.  Go to that page and Cmd-click on it.  The name of the page is below the page.  Click in it and backspace and type.  Return to the page you are linking from.  Type the name. Cmd-6, 'link to'.  

Text search:  Search for a set of fragments.  allStrings collects text of fields.  Turn to page with all fragments on it and highlight the first one.  Save the container and offset in properties: #searchContainer, #searchOffset, #searchKey.  Search again from there.  Clear those at each page turn, or change of search key.  

[rules about book indexes and pages:  Index and pages must live in the same directory. They have the same file prefix, followed by .bo for the index or 4.sp for a page (or x4.sp).  When a book is moved to a new directory, the load routine gets the new urls for all pages and saves those in the index.  Book stores index url in property #url.  
    Allow mulitple indexes (books) on the same shared set of pages.  If book has a url in same directory as pages, allow them to have different prefixes.
	save all pages first time, save one page first time, fromRemoteStream: (first time)
	save all pages normal , save one page normal, reload
	where I check if same dir]
URLMorph holds url of both page and book.
"
Class {
	#name : #BookMorph,
	#superclass : #BooklikeMorph,
	#instVars : [
		'pages',
		'currentPage'
	],
	#classVars : [
		'MethodHolders',
		'VersionNames',
		'VersionTimes'
	],
	#category : #'MorphicExtras-Books'
}

{ #category : #url }
BookMorph class >> alreadyInFromUrl: aUrl [
	"Does a bookMorph living in some world in this image represent the same set of server pages? If so, don't create another one.  It will steal pages from the existing one.  Go delete the first one."
	
	self withAllSubclassesDo: [:cls |
		cls allInstancesDo: [:aBook | 
			 (aBook valueOfProperty: #url) = aUrl ifTrue: [
				aBook world ifNotNil: [
					self inform: 'This book is already open in some project' translated.
					^ true]]]].
	^ false
]

{ #category : #scripting }
BookMorph class >> authoringPrototype [
	"Answer an instance of the receiver suitable for placing in a parts bin for authors"
	
	| book |
	book := self new initializeToStandAlone.
	book markAsPartsDonor.
	^ book
]

{ #category : #'parts bin' }
BookMorph class >> descriptionForPartsBin [
	^ self partName:	'Book' translatedNoop
		categories:		{'Multimedia' translatedNoop}
		documentation:	'Multi-page structures' translatedNoop
		sampleImageForm: (PNGReadWriter on: (Base64MimeConverter mimeDecodeToBytes: 'iVBORw0KGgoAAAANSUhEUgAAAMgAAACgCAYAAABJ/yOpAAAABHNCSVQFBQUBSsjp7wAABMtJ
REFUeF7l3S2S4kAAgFEkEonkCEiOgEQikUgkEolEcgSOgEQiOcYcAZfdniqmpnaBkE43JHni
7dZuzWR7m3z5ISHT6/X6hc/ne+TvL9fr1efz/cMPxOfzA/H5/EB8Pj8Qn88PxOfzA/H5OhLI
19eXz9dZfiA+nx+Iz+cH4vN1K5Dz+fxUEyaoCWP0xwAF8ntSy94l+NQL0IQx+mMAA3llop+9
AO+K49Nj9MeABfLqVujVrVTOvcYnx+iPAQwkxWTn3kI1YYz+GMBAckx4kw4lUo3RH4MfiB9I
hTHU/ZSbH0gLAsk54akmvuoYY+5LKxvjvTGkDCR2DKnnoq2RZAkkNo4cK2DKOGJv3Hw0xkdj
SB1IzBhyzEedSC6XS7Hf74vFYlGMx+Nit9uVfs9yufz++jrLaFwg75r0KmMsW/nkQKrMSexr
dTgc/vs/rlar0u/r9/vfkdRZRiMDecekvzrGV1Y+PZBX5yX2tTqdTsVmsymOx+PPir5er0uj
CoGE74ldRpZA6px7xK6Mud7OrLtSPhvjszHkCKTqGHLMQYpzkdvKXbb1D3uO0WhUaxmNDyTX
pKdeMXIFkvoQNXcgMfMQG0jZ1n84HP4cXsUuoxWB5Jj0sjGm3GprgZSN+x17kHA4Fb4mfG3n
9yA5Jj3H4Y1/iBU3hhx7kHCuMRgMau+F/ED8QFobyLOt/2QyKebzee3zGP8Qyz/Eau0h1qOt
f7jWEd69Ctc7iD2If5Lun6RX2fqHi3/PDq86tQfx3+b13+atuvUPh1az2SzJO2H+hUL/QmEr
LhTermuELX5Y+cO/F84zwp/D34d3rX5fPd9ut7WW4d9q0pJbTVLOX5tvNbmdeIf7p+79frta
ftszhPOQ2GX4Nyu26GbFNgTSpDt6w02I0+nUv93dv93dv9390Qn6o4uD/gem/A9M+R+Y8j9R
6H/k1v/Irf/QBv+hDf5DG/zH/viP/fHH4AfiPzjOH4MfiP/oUf/Ro/6jR/2HV/sPr/YfXu3/
+AOfzw/E5/MD8fn8QHy+pgfi8/k/BtqfDJ/PD8Tn8wPx+fxAfD4/EJ/PD8Tn8wPx+fxAfD4/
EJ/PD8Tn8/mB+Hx+ID6fH4jP5wfi8/mB+Hx+ID6fH4jP5wfi8/mB+Hx+ID6fzw/E5/MD8fn8
QHw+PxCfzw/E5/MD8fn8QHw+PxCfzw/E5/MD8QPx+fxAfD4/EJ/PD8Tn8wPx+fxAfL47ro3i
B+Lz+YH4fH4gPp8fiM/nB+Lz+YH4fH4gPp8fiM/nB+Lz+YH4fD4/EJ/PD8Tn8wPx+fxAfD4/
EJ/PD8Tn8wPx+fxAfD4/EJ/PD8QPxOfzA/H5/EB8Pj8Qn88PxOfzA/H5/EB8Pj8Qn88PxOfz
A/H5fH4gPp8fiM/nB+Lz+YH4fH4gPp8fiM/nB+Lz+YH4fH4gPp8fiB+Iz+cH4vP5gfg+o6P8
QHw+PxCfzw/E5/MD8fn8QHw+PxCfzw/E5/MD8fn8QHw+PxCfz+cH4vP5gfh8fiA+nx+Iz+cH
4vP5gfh8fiA+nx+Iz+cH4vP5gfiB+Hx+ID6fH4jP5wfi8/mB+Hx+ID6fH4jP5wfi8/mB+Hx+
ID6fzw/E5/MD8fn8QHw+PxCfzw/E5/MD8fn8QHy+jgXi8/nu+wM79mpMjbRBXAAAAABJRU5E
rkJggg==' readStream) readStream) nextImage
]

{ #category : #'fileIn\/Out' }
BookMorph class >> fileReaderServicesForFile: fullName suffix: suffix [

	^(suffix = 'bo') | (suffix = '*') 
		ifTrue: [ Array with: self serviceLoadAsBook]
		ifFalse: [#()]

]

{ #category : #url }
BookMorph class >> grabURL: aURLString [
	"Create a BookMorph for this url and put it in the hand."

	| book |
	book := self new fromURL: aURLString.
	"If this book is already in, we will steal the pages out of it!!!!"
	book goToPage: 1.	"install it"
	HandMorph attach: book
]

{ #category : #'class initialization' }
BookMorph class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #url }
BookMorph class >> isInWorld: aWorld withUrl: aUrl [
	| urls bks short |
	"If a book with this url is in the that (current) world, return it.  Say if it is out or in another world."

	urls := OrderedCollection new.
	bks := OrderedCollection new.
	aWorld allMorphsDo: [:aBook | (aBook isKindOf: BookMorph) ifTrue: [
			bks add: aBook.
			 (urls add: (aBook valueOfProperty: #url)) = aUrl ifTrue: [
				aBook world == aWorld 
					ifTrue: [^ aBook]]]]. 	"shortcut"
		
	self withAllSubclassesDo: [:cls |
		cls allInstancesDo: [:aBook | 
			 (aBook valueOfProperty: #url) = aUrl ifTrue: [
				aBook world == aWorld 
					ifTrue: [^ aBook]
					ifFalse: [
						self inform: 'Book may be open in some other project' translated.
						^ aBook]]]].

	"if same book name, use it"
	short := (aUrl findTokens: '/') last.
	urls withIndexDo: [:kk :ind | (kk findTokens: '/') last = short ifTrue: [
			^ bks at: ind]].
	^ #out
]

{ #category : #booksAsProjects }
BookMorph class >> makeBookOfProjects: aListOfProjects named: aString [
"
BookMorph makeBookOfProjects: (Project allProjects select: [ :each | each world isMorph])
"
	| book |

	book := self new.
	book setProperty: #transitionSpec toValue: {'silence'. #none. #none}.
	aListOfProjects do: [ :each | | pvm page |
		pvm := ProjectViewMorph on: each.
		page := PasteUpMorph new addMorph: pvm; extent: pvm extent.
		book insertPage: page pageSize: page extent
	].
	book goToPage: 1.
	book deletePageBasic.
	book setProperty: #nameOfThreadOfProjects toValue: aString.
	book removeProperty: #transitionSpec.
	book openInWorld
]

{ #category : #scripting }
BookMorph class >> nextPageButton [
	"Answer a button that will take the user to the next page of its
	enclosing book"
	| aButton |
	aButton := ThreePhaseButtonMorph labelSymbol: #NextPage.
	aButton target: aButton.
	aButton actionSelector: #nextOwnerPage.
	aButton arguments: #().
	aButton setNameTo: 'previous'.
	^ aButton
]

{ #category : #'fileIn\/Out' }
BookMorph class >> openFromFile: fullName [
	"Reconstitute a Morph from the selected file, presumed to be represent
	a Morph saved via the SmartRefStream mechanism, and open it in an
	appropriate Morphic world"

	| book aFileStream |
	Smalltalk verifyMorphicAvailability ifFalse: [^ self].

	aFileStream := FileStream readOnlyFileNamed: fullName.
	book := BookMorph new.
	book setProperty: #url toValue: aFileStream url.
	book fromRemoteStream: aFileStream.
	aFileStream close.

	Smalltalk isMorphic 
		ifTrue: [self currentWorld addMorphsAndModel: book]
		ifFalse: [book isMorph ifFalse: [^self inform: 'Can only load a single morph\into an mvc project via this mechanism.' withCRs translated].
			book openInWorld].
	book goToPage: 1
]

{ #category : #scripting }
BookMorph class >> previousPageButton [
	"Answer a button that will take the user to the previous page of its
	enclosing book"
	| aButton |
	aButton := ThreePhaseButtonMorph labelSymbol: #PrevPage.
	aButton target: aButton.
	aButton actionSelector: #previousOwnerPage.
	aButton arguments: #().
	aButton setNameTo: 'previous'.
	^ aButton
]

{ #category : #'class initialization' }
BookMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#BookMorph	. #nextPageButton. 'NextPage' translatedNoop. 'A button that takes you to the next page' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#BookMorph. #previousPageButton. 'PreviousPage' translatedNoop. 'A button that takes you to the previous page' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#BookMorph. #authoringPrototype. 'Book' translatedNoop. 'A multi-paged structure' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#BookMorph. #nextPageButton. 'NextPage' translatedNoop. 'A button that takes you to the next page' translatedNoop}
						forFlapNamed: 'Supplies'.
						cl registerQuad: {#BookMorph. #previousPageButton. 'PreviousPage' translatedNoop. 'A button that takes you to the previous page' translatedNoop}
						forFlapNamed: 'Supplies'.
						cl registerQuad: {#BookMorph. #authoringPrototype. 'Book' translatedNoop. 'A multi-paged structure' translatedNoop}
						forFlapNamed: 'Supplies']
]

{ #category : #'fileIn\/Out' }
BookMorph class >> serviceLoadAsBook [

	^ SimpleServiceEntry 
			provider: self 
			label: 'load as book' translatedNoop
			selector: #openFromFile:
			description: 'open as bookmorph' translatedNoop
]

{ #category : #'fileIn\/Out' }
BookMorph class >> services [

	^ Array with: self serviceLoadAsBook
]

{ #category : #'initialize-release' }
BookMorph class >> unload [
	"Unload the receiver from global registries"

	self environment
		at: #FileServices
		ifPresent: [:cl | cl unregisterFileReader: self].
	self environment
		at: #Flaps
		ifPresent: [:cl | cl unregisterQuadsWithReceiver: self]
]

{ #category : #'submorphs-add\/remove' }
BookMorph >> abandon [
	"Like delete, but we really intend not to use this morph again.  Make the page cache release the page object."

	
	self delete.
	pages do: [:aPage | | pg |
		(pg := aPage sqkPage) ifNotNil: [
			pg contentsMorph == aPage ifTrue: [
					pg contentsMorph: nil]]].
]

{ #category : #layout }
BookMorph >> acceptDroppingMorph: aMorph event: evt [
	"Allow the user to add submorphs just by dropping them on this morph."

	(currentPage allMorphs includes: aMorph)
		ifFalse: [currentPage addMorph: aMorph]
]

{ #category : #sorting }
BookMorph >> acceptSortedContentsFrom: aHolder [ 
	"Update my page list from the given page sorter."

	| goodPages rejects |
	goodPages := OrderedCollection new.
	rejects := OrderedCollection new.
	aHolder submorphs doWithIndex: 
			[:m :i | | toAdd sqPage | 
			toAdd := nil.
			(m isKindOf: PasteUpMorph) ifTrue: [toAdd := m].
			(m isKindOf: BookPageThumbnailMorph) 
				ifTrue: 
					[toAdd := m page.
					m bookMorph == self 
						ifFalse: 
							["borrowed from another book. preserve the original"

							toAdd := toAdd veryDeepCopy.

							"since we came from elsewhere, cached strings are wrong"
							self removeProperty: #allTextUrls.
							self removeProperty: #allText]].
			toAdd isString 
				ifTrue: 
					["a url"

					toAdd := pages detect: [:aPage | aPage url = toAdd] ifNone: [toAdd]].
			toAdd isString 
				ifTrue: 
					[sqPage := SqueakPageCache atURL: toAdd.
					toAdd := sqPage contentsMorph 
								ifNil: [sqPage copyForSaving	"a MorphObjectOut"]
								ifNotNil: [sqPage contentsMorph]].
			toAdd ifNil: [rejects add: m] ifNotNil: [goodPages add: toAdd]].
	self newPages: goodPages.
	goodPages isEmpty ifTrue: [self insertPage].
	rejects notEmpty 
		ifTrue: 
			[self 
				inform: rejects size printString , ' objects vanished in this process.']
]

{ #category : #menu }
BookMorph >> addBookMenuItemsTo: aMenu hand: aHandMorph [
	| controlsShowing subMenu |
	subMenu := MenuMorph new defaultTarget: self.
	subMenu add: 'previous page' translated action: #previousPage.
	subMenu add: 'next page' translated action: #nextPage.
	subMenu add: 'goto page' translated action: #goToPage.
	subMenu add: 'insert a page' translated action: #insertPage.
	subMenu add: 'delete this page' translated action: #deletePage.

	controlsShowing := self hasSubmorphWithProperty: #pageControl.
	controlsShowing
		ifTrue:
			[subMenu add: 'hide page controls' translated action: #hidePageControls.
			subMenu add: 'fewer page controls' translated action: #fewerPageControls]
		ifFalse:
			[subMenu add: 'show page controls' translated action: #showPageControls].
	self isInFullScreenMode ifTrue: [
		subMenu add: 'exit full screen' translated action: #exitFullScreen.
	] ifFalse: [
		subMenu add: 'show full screen' translated action: #goFullScreen.
	].
	subMenu addLine.
	subMenu add: 'sound effect for all pages' translated action: #menuPageSoundForAll:.
	subMenu add: 'sound effect this page only' translated action: #menuPageSoundForThisPage:.
	subMenu add: 'visual effect for all pages' translated action: #menuPageVisualForAll:.
	subMenu add: 'visual effect this page only' translated action: #menuPageVisualForThisPage:.

	subMenu addLine.
	subMenu add: 'sort pages' translated action: #sortPages:.
	subMenu add: 'uncache page sorter' translated action: #uncachePageSorter.
	(self hasProperty: #dontWrapAtEnd)
		ifTrue: [subMenu add: 'wrap after last page' translated selector: #setWrapPages: argument: true]
		ifFalse: [subMenu add: 'stop at last page' translated selector: #setWrapPages: argument: false].

	subMenu addLine.
	subMenu add: 'search for text' translated action: #textSearch.
	(aHandMorph pasteBuffer class isKindOf: PasteUpMorph class) ifTrue:
		[subMenu add: 'paste book page' translated	action: #pasteBookPage].

	subMenu add: 'send all pages to server' translated action: #savePagesOnURL.
	subMenu add: 'send this page to server' translated action: #saveOneOnURL.
	subMenu add: 'reload all from server' translated action: #reload.
	subMenu add: 'copy page url to clipboard' translated action: #copyUrl.
	subMenu add: 'keep in one file' translated action: #keepTogether.
	subMenu add: 'save as new-page prototype' translated action: #setNewPagePrototype.
	newPagePrototype ifNotNil:
		[subMenu add: 'clear new-page prototype' translated action: #clearNewPagePrototype].

	aMenu add: 'book...' translated subMenu: subMenu

]

{ #category : #other }
BookMorph >> adjustCurrentPageForFullScreen [
	"Adjust current page to conform to whether or not I am in full-screen mode.  Also, enforce uniform page size constraint if appropriate"

	self isInFullScreenMode
		ifTrue:
			[(currentPage hasProperty: #sizeWhenNotFullScreen) ifFalse:
				[currentPage setProperty: #sizeWhenNotFullScreen toValue: currentPage extent].
			currentPage extent: Display extent]
		ifFalse:
			[(currentPage hasProperty: #sizeWhenNotFullScreen) ifTrue:
				[currentPage extent: (currentPage valueOfProperty: #sizeWhenNotFullScreen).
				currentPage removeProperty: #sizeWhenNotFullScreen].
			self uniformPageSize ifNotNil:
				[:anExtent | currentPage extent: anExtent]].
	(self valueOfProperty: #floatingPageControls) ifNotNil:
		[:pc | pc isInWorld ifFalse: [pc openInWorld]]
]

{ #category : #'submorphs-accessing' }
BookMorph >> allNonSubmorphMorphs [
	"Return a collection containing all morphs in this morph which are not currently in the submorph containment hierarchy.  Especially the non-showing pages in BookMorphs.    (As needed, make a variant of this that brings in all pages that are not in memory.)"

	| coll |
	coll := OrderedCollection new.
	pages do: [:pg |
		pg isInMemory ifTrue: [
			pg == currentPage ifFalse: [coll add: pg]]].
	^ coll
]

{ #category : #'dropping\/grabbing' }
BookMorph >> allowSubmorphExtraction [

	^ false
]

{ #category : #'Postscript Canvases' }
BookMorph >> asPostscript [
	^self asPostscriptPrintJob.

]

{ #category : #menu }
BookMorph >> bookmarkForThisPage [
	"If this book exists on a server, make the reference via a URL"
	| bb url um |
	(url := self url) ifNil: [
		bb := SimpleButtonMorph new target: self.
		bb actionSelector: #goToPageMorph:fromBookmark:.
		bb label: 'Bookmark' translated.
		bb arguments: (Array with: currentPage with: bb).
		self primaryHand attachMorph: bb.
		^ bb].
	currentPage url ifNil: [currentPage saveOnURLbasic].
	um := URLMorph newForURL: currentPage url.
	um setURL: currentPage url page: currentPage sqkPage.
	(SqueakPage stemUrl: url) = (SqueakPage stemUrl: currentPage url) 
		ifTrue: [um book: true]
		ifFalse: [um book: url].  	"remember which book"
	um isBookmark: true; label: 'Bookmark' translated.
	um borderStyle: (BorderStyle raised width: 1).
	um color: (Color r: 0.4 g: 0.8 b: 0.6).
	self primaryHand attachMorph: um.
	^ um
]

{ #category : #navigation }
BookMorph >> buildFloatingPageControls [

	| pageControls |
	pageControls := self makePageControlsFrom: self fullControlSpecs.
	pageControls borderWidth: 0; layoutInset: 4.
	pageControls  setProperty: #pageControl toValue: true.
	pageControls setNameTo: 'Page Controls'.
	pageControls color: Color yellow.
	^FloatingBookControlsMorph new addMorph: pageControls.

]

{ #category : #menu }
BookMorph >> buildThreadOfProjects [

	| projectNames threadName |

	projectNames := pages collect: [ :each | | thisPVM |
		(thisPVM := each findA: ProjectViewMorph) ifNil: [
			nil
		] ifNotNil: [
			{thisPVM project name}.
		].
	].
	projectNames := projectNames reject: [ :each | each isNil].
	threadName := UIManager default 
		request: 'Please name this thread.' translated 
		initialAnswer: (
			self valueOfProperty: #nameOfThreadOfProjects ifAbsent: ['Projects on Parade' translated]
		).
	threadName isEmptyOrNil ifTrue: [^self].
	InternalThreadNavigationMorph 
		know: projectNames as: threadName;
		openThreadNamed: threadName atIndex: nil.

]

{ #category : #accessing }
BookMorph >> cardsOrPages [
	"The turnable and printable entities"

	^ pages
]

{ #category : #menu }
BookMorph >> copyUrl [
	"Copy this page's url to the clipboard"
	| str |
	str := currentPage url ifNil: [str := 'Page does not have a url.  Send page to server first.' translated].
	Clipboard clipboardText: str asText.

]

{ #category : #accessing }
BookMorph >> currentPage [
	(submorphs includes: currentPage) ifFalse: [currentPage := nil].
	^ currentPage
]

{ #category : #initialization }
BookMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color white
]

{ #category : #'insert and delete' }
BookMorph >> defaultNameStemForNewPages [
	"Answer a stem onto which to build default names for fresh pages"

	^ 'page'

]

{ #category : #'halos and balloon help' }
BookMorph >> defersHaloOnClickTo: aSubMorph [
	"If a cmd-click on aSubMorph would make it a preferred recipient of the halo, answer true"
	^ currentPage notNil and:
		[aSubMorph hasOwner: currentPage]
	
]

{ #category : #'insert and delete' }
BookMorph >> deletePage [

	| message |
	message := 
'Are you certain that you
want to delete this page and
everything that is on it? ' translated.
	(self confirm: message) ifTrue: 
			[self deletePageBasic].
	
]

{ #category : #'insert and delete' }
BookMorph >> deletePageBasic [
	| thisPage |
	thisPage := self pageNumberOf: currentPage.
	pages remove: currentPage.
	currentPage delete.
	currentPage := nil.
	pages isEmpty ifTrue: [^ self insertPage].
	self goToPage: (thisPage min: pages size)

]

{ #category : #other }
BookMorph >> exitFullScreen [
	| floater |
	self isInFullScreenMode ifFalse: [ ^ self ].
	self
		setProperty: #fullScreenMode
		toValue: false.
	(self hasProperty: #showWorldMainDockingBarWhenNotFullScreen) ifTrue:
		[ MorphicProject current showWorldMainDockingBar: (self valueOfProperty: #showWorldMainDockingBarWhenNotFullScreen).
		self removeProperty: #showWorldMainDockingBarWhenNotFullScreen ].
	floater := self
		valueOfProperty: #floatingPageControls
		ifAbsent: [  ].
	floater ifNotNil:
		[ floater delete.
		self removeProperty: #floatingPageControls ].
	self position: 0 @ 0.
	self adjustCurrentPageForFullScreen
]

{ #category : #menu }
BookMorph >> findText: wants [
	"Turn to the next page that has all of the strings mentioned on it.  Highlight where it is found.  allText and allTextUrls have been set.  Case insensitive search.
	Resuming a search.  If container's text is still in the list and secondary keys are still in the page, (1) search rest of that container.  (2) search rest of containers on that page (3) pages till end of book, (4) from page 1 to this page again."

	"Later sort wants so longest key is first"
	| allText here fromHereOn startToHere oldContainer oldIndex otherKeys strings good |
	allText := self valueOfProperty: #allText ifAbsent: [#()].
	here := pages identityIndexOf: currentPage ifAbsent: [1].
	fromHereOn := here+1 to: pages size.
	startToHere := 1 to: here.		"repeat this page"
	(self valueOfProperty: #searchKey ifAbsent: [#()]) = wants ifTrue: [
		"does page have all the other keys?  No highlight if found!"
		otherKeys := wants allButFirst.
		strings := allText at: here.
		good := true.
		otherKeys do: [:searchString | | thisWord | "each key"
			good ifTrue: [thisWord := false.
				strings do: [:longString |
					(longString findString: searchString startingAt: 1 
						caseSensitive: false) > 0 ifTrue: [
							thisWord := true]].
				good := thisWord]].
		good ifTrue: ["all are on this page.  Look in rest for string again."
			oldContainer := self valueOfProperty: #searchContainer.
			oldIndex := self valueOfProperty: #searchOffset.
			(self findText: (OrderedCollection with: wants first) inStrings: strings	
				startAt: oldIndex+1 container: oldContainer 
				pageNum: here) ifTrue: [
					self setProperty: #searchKey toValue: wants.
					^ true]]]
		ifFalse: [fromHereOn := here to: pages size].	"do search this page"
	"other pages"
	allText ifNotEmpty: [
		fromHereOn do: [:pageNum |
			(self findText: wants inStrings: (allText at: pageNum) startAt: 1 container: nil 
					pageNum: pageNum) 
					ifTrue: [^ true]].
		startToHere do: [:pageNum |
			(self findText: wants inStrings: (allText at: pageNum) startAt: 1 container: nil 
					pageNum: pageNum) 
						ifTrue: [^ true]]].
	"if fail"
	self setProperty: #searchContainer toValue: nil.
	self setProperty: #searchOffset toValue: nil.
	self setProperty: #searchKey toValue: nil.
	^ false
]

{ #category : #menu }
BookMorph >> findText: keys inStrings: rawStrings startAt: startIndex container: oldContainer pageNum: pageNum [ 
	"Call once to search a page of the book.  Return true if found and highlight the text.  oldContainer should be NIL.  
	(oldContainer is only non-nil when (1) doing a 'search again' and (2) the page is in memory and (3) keys has just one element.  oldContainer is a TextMorph.)"

	| container wasIn strings old good insideOf place start |
	good := true.
	start := startIndex.
	strings := oldContainer ifNil: 
					["normal case"

					rawStrings]
				ifNotNil: 
					[(pages at: pageNum) isInMemory 
						ifFalse: [rawStrings]
						ifTrue: [(pages at: pageNum) allStringsAfter: oldContainer]].
	keys do: 
			[:searchString | | thisWord | 
			"each key"

			good 
				ifTrue: 
					[thisWord := false.
					strings do: 
							[:longString | | index | 
							(index := longString 
										findString: searchString
										startingAt: start
										caseSensitive: false) > 0 
								ifTrue: 
									[thisWord not & (searchString == keys first) 
										ifTrue: 
											[insideOf := longString.
											place := index].
									thisWord := true].
							start := 1].	"only first key on first container"
					good := thisWord]].
	good 
		ifTrue: 
			["all are on this page"

			wasIn := (pages at: pageNum) isInMemory.
			self goToPage: pageNum.
			wasIn 
				ifFalse: 
					["search again, on the real current text.  Know page is in."

					^self 
						findText: keys
						inStrings: ((pages at: pageNum) allStringsAfter: nil)
						startAt: startIndex
						container: oldContainer
						pageNum: pageNum	"recompute"]].
	(old := self valueOfProperty: #searchContainer) ifNotNil: 
			[(old respondsTo: #editor) 
				ifTrue: 
					[old editor selectFrom: 1 to: 0.	"trying to remove the previous selection!"
					old changed]].
	good 
		ifTrue: 
			["have the exact string object"

			(container := oldContainer) ifNil: 
					[container := self 
								highlightText: keys first
								at: place
								in: insideOf]
				ifNotNil: 
					[container userString == insideOf 
						ifFalse: 
							[container := self 
										highlightText: keys first
										at: place
										in: insideOf]
						ifTrue: 
							[(container isTextMorph) 
								ifTrue: 
									[container editor selectFrom: place to: keys first size - 1 + place.
									container changed]]].
			self setProperty: #searchContainer toValue: container.
			self setProperty: #searchOffset toValue: place.
			self setProperty: #searchKey toValue: keys.	"override later"
			self currentHand newKeyboardFocus: container.
			^true].
	^false
]

{ #category : #menu }
BookMorph >> forgetURLs [
	"About to save these objects in a new place.  Forget where stored now.  Must bring in all pages we don't have."


pages do: [:aPage | | pg |
	aPage yourself.	"bring it into memory"
	(pg := aPage valueOfProperty: #SqueakPage) ifNotNil: [
		SqueakPageCache removeURL: pg url.
		pg contentsMorph setProperty: #SqueakPage toValue: nil]].
self setProperty: #url toValue: nil.
]

{ #category : #initialization }
BookMorph >> fromRemoteStream: strm [ 
	"Make a book from an index and a bunch of pages on a server.  NOT showing any page!  Index and pages must live in the same directory.  If the book has moved, save the current correct urls for each of the pages.  Self must already have a url stored in property #url."

	| remote dict bookUrl oldStem stem oldUrl endPart |
	remote := strm fileInObjectAndCode.
	bookUrl := (SqueakPage new)
				url: (self valueOfProperty: #url);
				url.
	"expand a relative url"
	oldStem := SqueakPage stemUrl: (remote second) url.
	oldStem := oldStem copyUpToLast: $/.
	stem := SqueakPage stemUrl: bookUrl.
	stem := stem copyUpToLast: $/.
	oldStem = stem 
		ifFalse: 
			["Book is in new directory, fix page urls"

			2 to: remote size
				do: 
					[:ii | 
					oldUrl := (remote at: ii) url.
					endPart := oldUrl copyFrom: oldStem size + 1 to: oldUrl size.
					(remote at: ii) url: stem , endPart]].
	self initialize.
	pages := OrderedCollection new.
	2 to: remote size do: [:ii | pages add: (remote at: ii)].
	currentPage
		fullReleaseCachedState;
		delete.	"the blank one"
	currentPage := remote second.
	dict := remote first.
	self setProperty: #modTime toValue: (dict at: #modTime).
	dict at: #allText
		ifPresent: [:val | self setProperty: #allText toValue: val].
	dict at: #allTextUrls
		ifPresent: [:val | self setProperty: #allTextUrls toValue: val].
	#(#color #borderWidth #borderColor #pageSize) 
		with: #(#color: #borderWidth: #borderColor: #pageSize:)
		do: [:key :sel | dict at: key ifPresent: [:val | self perform: sel with: val]].
	^self
]

{ #category : #initialization }
BookMorph >> fromURL: url [
	"Make a book from an index and a bunch of pages on a server.  NOT showing any page!"

	| strm |
	strm := Cursor wait showWhile: [
		(ServerFile new fullPath: url) asStream].
	strm isString ifTrue: [self inform: 'Sorry, ',strm. ^ nil].
	self setProperty: #url toValue: url.
	self fromRemoteStream: strm.
	^ self
]

{ #category : #'Postscript Canvases' }
BookMorph >> fullDrawPostscriptOn:aCanvas [
	^aCanvas fullDrawBookMorph:self.

]

{ #category : #menu }
BookMorph >> getAllText [
	"Collect the text for each page.  Just point at strings so don't have to recopy them.  Parallel array of urls for ID of pages.
	allText = Array (pages size) of arrays (fields in it) of strings of text.
	allTextUrls = Array (pages size) of urls or page numbers.
	For any page that is out, text data came from .bo file on server.  
	Is rewritten when one or all pages are stored."

	| oldUrls oldStringLists allText allTextUrls |
	oldUrls := self valueOfProperty: #allTextUrls ifAbsent: [#()].
	oldStringLists := self valueOfProperty: #allText ifAbsent: [#()].
	allText := pages collect: [:pg | OrderedCollection new].
	allTextUrls := Array new: pages size.
	pages doWithIndex: [:aPage :ind | | which aUrl |
		aUrl := aPage url.  aPage isInMemory 
			ifTrue: [(allText at: ind) addAll: (aPage allStringsAfter: nil).
				aUrl ifNil: [aUrl := ind].
				allTextUrls at: ind put: aUrl]
			ifFalse: ["Order of pages on server may be different.  (later keep up to date?)"
				which := oldUrls indexOf: aUrl.
				allTextUrls at: ind put: aUrl.
				which = 0 ifFalse: [allText at: ind put: (oldStringLists at: which)]]].
	self setProperty: #allText toValue: allText.
	self setProperty: #allTextUrls toValue: allTextUrls.
	^ allText
]

{ #category : #menu }
BookMorph >> getStemUrl [
	"Try to find the old place where this book was stored. Confirm with the 
	user. Else ask for new place."
	| initial pg url knownURL |

	knownURL := false.
	initial := ''.
	(pg := currentPage valueOfProperty: #SqueakPage)
		ifNotNil: [pg contentsMorph == currentPage
				ifTrue: [initial := pg url.
					knownURL := true]].
	"If this page has a url"
	pages
		doWithIndex: [:aPage :ind | initial isEmpty
				ifTrue: [aPage isInMemory
						ifTrue: [(pg := aPage valueOfProperty: #SqueakPage)
								ifNotNil: [initial := pg url]]]].
	"any page with a url"
	initial isEmpty
		ifTrue: [initial := ServerDirectory defaultStemUrl , '1.sp'].
	"A new legal place"
	url := knownURL
		ifTrue: [initial]
		ifFalse: [UIManager default request: 'url of the place to store a typical page in this book.
Must begin with file:// or ftp://' translated initialAnswer: initial].
	^ SqueakPage stemUrl: url
]

{ #category : #other }
BookMorph >> goFullScreen [
	| floater |
	self isInFullScreenMode ifTrue: [ ^ self ].
	self
		setProperty: #fullScreenMode
		toValue: true.
	self
		setProperty: #showWorldMainDockingBarWhenNotFullScreen
		toValue: Project current showWorldMainDockingBar.
	Project current showWorldMainDockingBar: false.
	self position: (currentPage topLeft - self topLeft) negated.
	self adjustCurrentPageForFullScreen.
	floater := self buildFloatingPageControls.
	self
		setProperty: #floatingPageControls
		toValue: floater.
	floater openInWorld
]

{ #category : #menu }
BookMorph >> goToPage [
	| pageNum |
	pageNum := UIManager default request: 'Page?' translated initialAnswer: '0'.
	pageNum isEmptyOrNil ifTrue: [^true].
	self goToPage: pageNum asNumber.

]

{ #category : #navigation }
BookMorph >> goToPage: pageNumber [

	^ self goToPage: pageNumber transitionSpec: nil
]

{ #category : #navigation }
BookMorph >> goToPage: pageNumber transitionSpec: transitionSpec [

	| pageMorph |
	pages isEmpty ifTrue: [^ self].
	pageMorph := (self hasProperty: #dontWrapAtEnd)
		ifTrue: [pages atPin: pageNumber]
		ifFalse: [pages atWrap: pageNumber].
	^ self goToPageMorph: pageMorph transitionSpec: transitionSpec
]

{ #category : #navigation }
BookMorph >> goToPage: pageNumber transitionSpec: transitionSpec runTransitionScripts: aBoolean [
	"Go the the given page number; use the transitionSpec supplied, and if the boolean parameter is true, run opening and closing scripts as appropriate"

	| pageMorph |
	pages isEmpty ifTrue: [^ self].
	pageMorph := (self hasProperty: #dontWrapAtEnd)
		ifTrue: [pages atPin: pageNumber]
		ifFalse: [pages atWrap: pageNumber].
	^ self goToPageMorph: pageMorph transitionSpec: transitionSpec runTransitionScripts: aBoolean
]

{ #category : #navigation }
BookMorph >> goToPageMorph: aMorph [
	"Set the given morph as the current page; run closing and opening scripts as appropriate"

	self goToPageMorph: aMorph runTransitionScripts: true
]

{ #category : #navigation }
BookMorph >> goToPageMorph: aMorph fromBookmark: aBookmark [
	"This protocol enables sensitivity to a transitionSpec on the bookmark"
	
	self goToPageMorph: aMorph
		transitionSpec: (aBookmark valueOfProperty: #transitionSpec).

]

{ #category : #navigation }
BookMorph >> goToPageMorph: aMorph runTransitionScripts: aBoolean [
	"Set the given morph as the current page.  If the boolean parameter is true, then opening and closing scripts will be run"

	self goToPage: (pages identityIndexOf: aMorph ifAbsent: [^ self "abort"]) transitionSpec: nil runTransitionScripts: aBoolean

]

{ #category : #navigation }
BookMorph >> goToPageMorph: newPage transitionSpec: transitionSpec [ 
	"Go to a page, which is assumed to be an element of my pages array (if it is not, this method returns quickly.  Apply the transitionSpec provided."

	| pageIndex aWorld oldPageIndex ascending tSpec readIn |
	pages isEmpty ifTrue: [^self].
	self setProperty: #searchContainer toValue: nil.	"forget previous search"
	self setProperty: #searchOffset toValue: nil.
	self setProperty: #searchKey toValue: nil.
	pageIndex := pages identityIndexOf: newPage ifAbsent: [^self	"abort"].
	readIn := newPage isInMemory not.
	oldPageIndex := pages identityIndexOf: currentPage ifAbsent: [nil].
	ascending := (oldPageIndex isNil or: [newPage == currentPage]) 
				ifTrue: [nil]
				ifFalse: [oldPageIndex < pageIndex].
	tSpec := transitionSpec ifNil: 
					["If transition not specified by requestor..."

					newPage valueOfProperty: #transitionSpec
						ifAbsent: 
							[" ... then consult new page"

							self transitionSpecFor: self	" ... otherwise this is the default"]].
	self flag: #arNote.	"Probably unnecessary"
	(aWorld := self world) ifNotNil: [self primaryHand releaseKeyboardFocus].
	currentPage ifNotNil: [currentPage updateCachedThumbnail].
	self currentPage notNil 
		ifTrue: 
			[(((pages at: pageIndex) owner isKindOf: TransitionMorph) 
				and: [(pages at: pageIndex) isInWorld]) 
					ifTrue: [^self	"In the process of a prior pageTurn"].
			self currentPlayerDo: [:aPlayer | aPlayer runAllClosingScripts].
			self removeViewersOnSubsIn: self currentWorld presenter.
			ascending ifNotNil: 
					["Show appropriate page transition and start new page when done"

					currentPage stopStepping.
					(pages at: pageIndex) position: currentPage position.
					^(TransitionMorph 
						effect: tSpec second
						direction: tSpec third
						inverse: (ascending or: [transitionSpec notNil]) not) 
							showTransitionFrom: currentPage
							to: (pages at: pageIndex)
							in: self
							whenStart: [self playPageFlipSound: tSpec first]
							whenDone: 
								[currentPage
									delete;
									fullReleaseCachedState.
								self insertPageMorphInCorrectSpot: (pages at: pageIndex).
								self adjustCurrentPageForFullScreen.
								self snapToEdgeIfAppropriate.
								aWorld ifNotNil: [self world startSteppingSubmorphsOf: currentPage].
								self currentPlayerDo: [:aPlayer | aPlayer runAllOpeningScripts].
								(aWorld := self world) ifNotNil: 
										["WHY??"

										aWorld displayWorld].
								readIn 
									ifTrue: 
										[currentPage updateThumbnailUrlInBook: self url.
										currentPage sqkPage computeThumbnail	"just store it"]]].

			"No transition, but at least decommission current page"
			currentPage
				delete;
				fullReleaseCachedState].
	self insertPageMorphInCorrectSpot: (pages at: pageIndex). 	"sets currentPage"
	self adjustCurrentPageForFullScreen.
	self snapToEdgeIfAppropriate.
	aWorld ifNotNil: [self world startSteppingSubmorphsOf: currentPage].
	self currentPlayerDo: [:aPlayer | aPlayer runAllOpeningScripts].
	(aWorld := self world) ifNotNil: 
			["WHY??"
			aWorld displayWorld].
	readIn 
		ifTrue: 
			[currentPage updateThumbnailUrl.
			currentPage sqkPage computeThumbnail	"just store it"].
	self currentWorld presenter flushPlayerListCache.
]

{ #category : #navigation }
BookMorph >> goToPageMorph: newPage transitionSpec: transitionSpec runTransitionScripts: aBoolean [ 
	"Install the given page as the new current page; use the given transition spec, and if the boolean parameter is true, run closing and opening scripts on the outgoing and incoming players"

	| pageIndex aWorld oldPageIndex ascending tSpec readIn |
	pages isEmpty ifTrue: [^self].
	self setProperty: #searchContainer toValue: nil.	"forget previous search"
	self setProperty: #searchOffset toValue: nil.
	self setProperty: #searchKey toValue: nil.
	pageIndex := pages identityIndexOf: newPage ifAbsent: [^self	"abort"].
	readIn := newPage isInMemory not.
	oldPageIndex := pages identityIndexOf: currentPage ifAbsent: [nil].
	ascending := (oldPageIndex isNil or: [newPage == currentPage]) 
				ifTrue: [nil]
				ifFalse: [oldPageIndex < pageIndex].
	tSpec := transitionSpec ifNil: 
					["If transition not specified by requestor..."

					newPage valueOfProperty: #transitionSpec
						ifAbsent: 
							[" ... then consult new page"

							self transitionSpecFor: self	" ... otherwise this is the default"]].
	self flag: #arNote.	"Probably unnecessary"
	(aWorld := self world) ifNotNil: [self primaryHand releaseKeyboardFocus].
	currentPage ifNotNil: [currentPage updateCachedThumbnail].
	self currentPage notNil 
		ifTrue: 
			[(((pages at: pageIndex) owner isKindOf: TransitionMorph) 
				and: [(pages at: pageIndex) isInWorld]) 
					ifTrue: [^self	"In the process of a prior pageTurn"].
			aBoolean 
				ifTrue: [self currentPlayerDo: [:aPlayer | aPlayer runAllClosingScripts]].
			ascending ifNotNil: 
					["Show appropriate page transition and start new page when done"

					currentPage stopStepping.
					(pages at: pageIndex) position: currentPage position.
					^(TransitionMorph 
						effect: tSpec second
						direction: tSpec third
						inverse: (ascending or: [transitionSpec notNil]) not) 
							showTransitionFrom: currentPage
							to: (pages at: pageIndex)
							in: self
							whenStart: [self playPageFlipSound: tSpec first]
							whenDone: 
								[currentPage
									delete;
									fullReleaseCachedState.
								self insertPageMorphInCorrectSpot: (pages at: pageIndex).
								self adjustCurrentPageForFullScreen.
								self snapToEdgeIfAppropriate.
								aWorld ifNotNil: [self world startSteppingSubmorphsOf: currentPage].
								aBoolean 
									ifTrue: [self currentPlayerDo: [:aPlayer | aPlayer runAllOpeningScripts]].
								(aWorld := self world) ifNotNil: 
										["WHY??"

										aWorld displayWorld].
								readIn 
									ifTrue: 
										[currentPage updateThumbnailUrlInBook: self url.
										currentPage sqkPage computeThumbnail	"just store it"]]].

			"No transition, but at least decommission current page"
			currentPage
				delete;
				fullReleaseCachedState].
	self insertPageMorphInCorrectSpot: (pages at: pageIndex).
	self adjustCurrentPageForFullScreen.
	self snapToEdgeIfAppropriate.
	aWorld ifNotNil: [self world startSteppingSubmorphsOf: currentPage].
	self currentPlayerDo: [:aPlayer | aPlayer runAllOpeningScripts].
	(aWorld := self world) ifNotNil: 
			["WHY??"

			aWorld displayWorld].
	readIn 
		ifTrue: 
			[currentPage updateThumbnailUrl.
			currentPage sqkPage computeThumbnail	"just store it"]
]

{ #category : #navigation }
BookMorph >> goToPageUrl: aUrl [ 
	| pp short |
	pp := pages detect: [:pg | pg url = aUrl] ifNone: [nil].
	pp ifNil: 
			[short := (aUrl findTokens: '/') last.
			pp := pages detect: 
							[:pg | 
							pg url ifNil: [false] ifNotNil: [(pg url findTokens: '/') last = short]	"it moved"]
						ifNone: [pages first]].
	self goToPageMorph: pp
]

{ #category : #navigation }
BookMorph >> goto: aPlayer [
	self goToPageMorph: aPlayer costume
]

{ #category : #menu }
BookMorph >> highlightText: stringToHilite at: index in: insideOf [ 
	"Find the container with this text and highlight it.  May not be able to do it for stringMorphs."

	"Find the container with that text"

	| container |
	self 
		allMorphsDo: [:sub | insideOf == sub userString ifTrue: [container := sub]].
	container ifNil: 
			[self 
				allMorphsDo: [:sub | insideOf = sub userString ifTrue: [container := sub]]].	"any match"
	container ifNil: [^nil].

	"Order it highlighted"
	(container isTextMorph) 
		ifTrue: 
			[container editor selectFrom: index to: stringToHilite size - 1 + index].
	container changed.
	^container
]

{ #category : #initialization }
BookMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	self setInitialState.
	pages := OrderedCollection new.
	self showPageControls.
	self class
		turnOffSoundWhile: [self insertPage]
]

{ #category : #'parts bin' }
BookMorph >> initializeToStandAlone [
	super initializeToStandAlone.
	self removeEverything; pageSize: 360@228; color: Color white.
	self borderWidth: 1; borderColor: Color black.
	self beSticky.
	self showPageControls; insertPage.
	^ self
]

{ #category : #'insert and delete' }
BookMorph >> insertPage: aPage pageSize: aPageSize [
	^ self insertPage: aPage pageSize: aPageSize atIndex: (pages size + 1)
]

{ #category : #'insert and delete' }
BookMorph >> insertPage: aPage pageSize: aPageSize atIndex: anIndex [ 
	| sz predecessor |
	sz := aPageSize 
				ifNil: [currentPage isNil ifTrue: [pageSize] ifFalse: [currentPage extent]]
				ifNotNil: [aPageSize].
	aPage extent: sz.
	(pages isEmpty | anIndex isNil or: [anIndex > pages size]) 
		ifTrue: [pages add: aPage]
		ifFalse: 
			[anIndex <= 1 
				ifTrue: [pages addFirst: aPage]
				ifFalse: 
					[predecessor := anIndex isNil 
								ifTrue: [currentPage]
								ifFalse: [pages at: anIndex].
					self pages add: aPage after: predecessor]].
	self goToPageMorph: aPage
]

{ #category : #'insert and delete' }
BookMorph >> insertPageColored: aColor [ 
	"Insert a new page for the receiver, using the given color as its background color"

	| pageExtent newPage borderWidth backgroundColor |
	backgroundColor := currentPage isNil 
				ifTrue: 
					[pageExtent := pageSize.
					borderWidth := 0.
					Color blue muchLighter]
				ifFalse: 
					[pageExtent := currentPage extent.
					borderWidth := currentPage borderWidth.
					currentPage borderColor].
	newPagePrototype ifNil: 
			[newPage := (PasteUpMorph new)
						extent: pageExtent;
						color: aColor.
			newPage
				borderWidth: borderWidth;
				borderColor: backgroundColor]
		ifNotNil: [newPage := Cursor wait showWhile: [newPagePrototype veryDeepCopy]].
	newPage setNameTo: self defaultNameStemForNewPages.
	newPage vResizeToFit: false.
	pages isEmpty 
		ifTrue: [pages add: (currentPage := newPage)]
		ifFalse: [pages add: newPage after: currentPage].
	self nextPage
]

{ #category : #'insert and delete' }
BookMorph >> insertPageLabel: labelString morphs: morphList [

	| m c labelAllowance |
	self insertPage.
	labelString ifNotNil:
			[m := labelString asMorph.
		m lock.
		m position: currentPage position + (((currentPage width - m width) // 2) @ 5).
		currentPage addMorph: m.
		labelAllowance := 40]
		ifNil:
			[labelAllowance := 0].

	"use a column to align the given morphs, then add them to the page"
	c := AlignmentMorph newColumn wrapCentering: #center; cellPositioning: #topCenter.
	c addAllMorphs: morphList.
	c position: currentPage position + (0 @ labelAllowance).
	currentPage addAllMorphs: morphList.
	^ currentPage

]

{ #category : #navigation }
BookMorph >> insertPageMorphInCorrectSpot: aPageMorph [

	self addMorphBack: (currentPage := aPageMorph).

]

{ #category : #'insert and delete' }
BookMorph >> insertPageSilentlyAtEnd [
	"Create a new page at the end of the book.  Do not turn to it."

	| sz newPage bw bc cc |
	cc := currentPage isNil 
				ifTrue: 
					[sz := pageSize.
					bw := 0.
					bc := Color blue muchLighter.
					color]
				ifFalse: 
					[sz := currentPage extent.
					bw := currentPage borderWidth.
					bc := currentPage borderColor.
					currentPage color].
	newPagePrototype ifNil: 
			[newPage := (PasteUpMorph new)
						extent: sz;
						color: cc.
			newPage
				borderWidth: bw;
				borderColor: bc]
		ifNotNil: [newPage := Cursor wait showWhile: [newPagePrototype veryDeepCopy]].
	newPage setNameTo: self defaultNameStemForNewPages.
	newPage vResizeToFit: false.
	pages isEmpty 
		ifTrue: [pages add: (currentPage := newPage)	"had been none"]
		ifFalse: [pages add: newPage after: pages last].
	^newPage
]

{ #category : #menu }
BookMorph >> invokeBookMenu [
	"Invoke the book's control panel menu."
	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'Book' translated.
	Preferences noviceMode
		ifFalse:[aMenu addStayUpItem].
	aMenu add: 'find...' translated action: #textSearch.
	aMenu add: 'go to page...' translated action: #goToPage.
	aMenu addLine.

	aMenu addList: {
		{'sort pages' translated.		#sortPages}.
		{'uncache page sorter' translated.	#uncachePageSorter}}.
	(self hasProperty: #dontWrapAtEnd)
		ifTrue: [aMenu add: 'wrap after last page' translated selector: #setWrapPages: argument: true]
		ifFalse: [aMenu add: 'stop at last page' translated selector: #setWrapPages: argument: false].
	aMenu addList: {
		{'make bookmark' translated.		#bookmarkForThisPage}.
		{'make thumbnail' translated.		#thumbnailForThisPage}}.
	aMenu addUpdating: #showingPageControlsString action: #toggleShowingOfPageControls.
	aMenu addUpdating: #showingFullScreenString action: #toggleFullScreen.

	aMenu addLine.
	aMenu add: 'sound effect for all pages' translated action: #menuPageSoundForAll:.
	aMenu add: 'sound effect this page only' translated action: #menuPageSoundForThisPage:.
	aMenu add: 'visual effect for all pages' translated action: #menuPageVisualForAll:.
	aMenu add: 'visual effect this page only' translated action: #menuPageVisualForThisPage:.

	aMenu addLine.
	(self primaryHand pasteBuffer class isKindOf: PasteUpMorph class) ifTrue:
		[aMenu add: 'paste book page' translated   action: #pasteBookPage].

	aMenu add: 'save as new-page prototype' translated action: #setNewPagePrototype.
	newPagePrototype ifNotNil: [
		aMenu add: 'clear new-page prototype' translated action: #clearNewPagePrototype].

	aMenu add: (self dragNDropEnabled ifTrue: ['close dragNdrop'] ifFalse: ['open dragNdrop']) translated
			action: #changeDragAndDrop.
	aMenu add: 'make all pages this size' translated action: #makeUniformPageSize.
	
	aMenu
		addUpdating: #keepingUniformPageSizeString
		target: self
		action: #toggleMaintainUniformPageSize.
	aMenu addLine.

	aMenu add: 'send all pages to server' translated action: #savePagesOnURL.
	aMenu add: 'send this page to server' translated action: #saveOneOnURL.
	aMenu add: 'reload all from server' translated action: #reload.
	aMenu add: 'copy page url to clipboard' translated action: #copyUrl.
	aMenu add: 'keep in one file' translated action: #keepTogether.

	aMenu addLine.
	aMenu add: 'load PPT images from slide #1' translated action: #loadImagesIntoBook.
	aMenu add: 'background color for all pages...' translated action: #setPageColor.
	aMenu add: 'make a thread of projects in this book' translated action: #buildThreadOfProjects.

	aMenu popUpEvent: self world activeHand lastEvent in: self world

]

{ #category : #other }
BookMorph >> isInFullScreenMode [

	^self valueOfProperty: #fullScreenMode ifAbsent: [false]
]

{ #category : #menu }
BookMorph >> keepTogether [
	"Mark this book so that each page will not go into a separate file.  Do this when pages share referenes to a common Player.  Don't want many copies of that Player when bring in.  Do not write pages of book out.  Write the PasteUpMorph that the entire book lives in."

	self setProperty: #keepTogether toValue: true.
]

{ #category : #'uniform page size' }
BookMorph >> keepingUniformPageSizeString [
	"Answer a string characterizing whether I am currently maintaining uniform page size"

	^ (self maintainsUniformPageSize
		ifTrue: ['<yes>']
		ifFalse: ['<no>']), 'keep all pages the same size' translated
]

{ #category : #navigation }
BookMorph >> lastPage [
	self goToPage: pages size

]

{ #category : #menu }
BookMorph >> loadImagesIntoBook [
	"PowerPoint stores GIF presentations as individual slides named Slide1, Slide2, etc.
	Load these into the book.  mjg 9/99"

	| directory filenumber form newpage |
	directory :=DirectoryChooserDialog openOn: FileDirectory default label: 'Select the directory to load pages from'.
	directory ifNil: [^ self].

	"Start loading 'em up!"
	filenumber := 1.
	[directory fileExists: 'Slide' , filenumber asString] whileTrue: 
			[Transcript
				show: 'Slide' , filenumber asString;
				cr.
			Smalltalk bytesLeft < 1000000 
				ifTrue: 
					["Make some room"

					(self valueOfProperty: #url) isNil 
						ifTrue: [self savePagesOnURL]
						ifFalse: [self saveAsNumberedURLs]].
			form := Form 
						fromFileNamed: (directory fullNameFor: 'Slide' , filenumber asString).
			newpage := PasteUpMorph new extent: form extent.
			newpage addMorph: (self world drawingClass withForm: form).
			self pages addLast: newpage.
			filenumber := filenumber + 1].

	"After adding all, delete the first page."
	self goToPage: 1.
	self deletePageBasic.

	"Save the book"
	(self valueOfProperty: #url) isNil 
		ifTrue: [self savePagesOnURL]
		ifFalse: [self saveAsNumberedURLs]
]

{ #category : #'uniform page size' }
BookMorph >> maintainsUniformPageSize [
	"Answer whether I am currently set up to maintain uniform page size"

	^ self uniformPageSize notNil
]

{ #category : #'uniform page size' }
BookMorph >> maintainsUniformPageSize: aBoolean [
	"Set the property governing whether I maintain uniform page size"

	aBoolean
		ifFalse:
			[self removeProperty: #uniformPageSize]
		ifTrue:
			[self setProperty: #uniformPageSize toValue: currentPage extent]
]

{ #category : #other }
BookMorph >> makeMinimalControlsWithColor: aColor title: aString [

	| aButton aColumn aRow but |
	aButton := SimpleButtonMorph new target: self; borderColor: Color black; 
				color: aColor; borderWidth: 0.
	aColumn := AlignmentMorph newColumn.
	aColumn color: aButton color; borderWidth: 0; layoutInset: 0.
	aColumn hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.

	aRow := AlignmentMorph newRow.
	aRow color: aButton color; borderWidth: 0; layoutInset: 0.
	aRow hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	aRow addTransparentSpacerOfSize: 40@0.
	aRow addMorphBack: (but := aButton label: ' < ' ; actionSelector: #previousPage).
		"copy is OK, since we just made it and it can't own any Players"
	but setBalloonText: 'Go to previous page'.
	aRow addTransparentSpacerOfSize: 82@0.
	aRow addMorphBack: (StringMorph contents: aString) lock.
	aRow addTransparentSpacerOfSize: 82@0.
	aButton := SimpleButtonMorph new target: self; borderColor: Color black; 
				color: aColor; borderWidth: 0.
	aRow addMorphBack: (but := aButton label: ' > ' ; actionSelector: #nextPage).
	but setBalloonText: 'Go to next page'.
	aRow addTransparentSpacerOfSize: 40@0.

	aColumn addMorphBack: aRow.

	aColumn setNameTo: 'Page Controls'.
	
	^ aColumn
]

{ #category : #menu }
BookMorph >> makeUniformPageSize [
	"Make all pages be of the same size as the current page."
	currentPage ifNil: [^ Beeper beep].
	self resizePagesTo: currentPage extent.
	newPagePrototype ifNotNil:
		[newPagePrototype extent: currentPage extent]
]

{ #category : #menu }
BookMorph >> menuPageSoundFor: target event: evt [
	| tSpec menu |
	tSpec := self transitionSpecFor: target.
	menu := (MenuMorph entitled: 'Choose a sound
(it is now ' translated, tSpec first translated, ')') defaultTarget: target.
	SoundService default sampledSoundChoices do:
		[:soundName |
		menu add: soundName translated target: target
			selector: #setProperty:toValue:
			argumentList: (Array with: #transitionSpec
								with: (tSpec copy at: 1 put: soundName; yourself))].

	menu popUpEvent: evt in: self world
]

{ #category : #menu }
BookMorph >> menuPageSoundForAll: evt [

	^ self menuPageSoundFor: self event: evt
]

{ #category : #menu }
BookMorph >> menuPageSoundForThisPage: evt [

	currentPage ifNotNil:
		[^ self menuPageSoundFor: currentPage event: evt]
]

{ #category : #menu }
BookMorph >> menuPageVisualFor: target event: evt [
	| tSpec menu |
	tSpec := self transitionSpecFor: target.
	menu := (MenuMorph entitled: ('Choose an effect
(it is now {1})' translated format:{tSpec second asString translated})) defaultTarget: target.
	TransitionMorph allEffects do:
		[:effect | | subMenu directionChoices |
		directionChoices := TransitionMorph directionsForEffect: effect.
		directionChoices isEmpty
		ifTrue: [menu add: effect asString translated target: target
					selector: #setProperty:toValue:
					argumentList: (Array with: #transitionSpec
									with: (Array with: tSpec first with: effect with: #none))]
		ifFalse: [subMenu := MenuMorph new.
				directionChoices do:
					[:dir |
					subMenu add: dir asString translated target: target
						selector: #setProperty:toValue:
						argumentList: (Array with: #transitionSpec
									with: (Array with: tSpec first with: effect with: dir))].
				menu add: effect asString translated subMenu: subMenu]].

	menu popUpEvent: evt in: self world
]

{ #category : #menu }
BookMorph >> menuPageVisualForAll: evt [

	^ self menuPageVisualFor: self event: evt
]

{ #category : #menu }
BookMorph >> menuPageVisualForThisPage: evt [

	currentPage ifNotNil:
		[^ self menuPageVisualFor: currentPage event: evt]
]

{ #category : #scripting }
BookMorph >> methodHolderVersions [
	| arrayOfVersions vTimes |
	"Create lists of times of older versions of all code in MethodMorphs in this book."

	arrayOfVersions := MethodHolders collect: [:mh | 
		mh versions].	"equality, hash for MethodHolders?"
	vTimes := OrderedCollection new.
	arrayOfVersions do: [:versionBrowser |  
		versionBrowser changeList do: [:cr | | strings | 
			(strings := cr stamp findTokens: ' ') size > 2 ifTrue: [
				vTimes add: strings second asDate asSeconds + 
						strings third asTime asSeconds]]].
	VersionTimes := Time condenseBunches: vTimes.
	VersionNames := Time namesForTimes: VersionTimes.

]

{ #category : #sorting }
BookMorph >> morphsForPageSorter [
	| thumbnails |
	'Assembling thumbnail images...'
		displayProgressFrom: 0 to: pages size
		during:
			[:bar | | i |
			i := 0.
			thumbnails := pages collect:
				[:p | bar value: (i:= i+1).
				pages size > 40 
					ifTrue: [p smallThumbnailForPageSorter inBook: self]
					ifFalse: [p thumbnailForPageSorter inBook: self]]].
	^ thumbnails
]

{ #category : #initialization }
BookMorph >> newPages: pageList [
	"Replace all my pages with the given list of BookPageMorphs.  After this call, currentPage may be invalid."

	pages := pages species new.
	pages addAll: pageList
]

{ #category : #initialization }
BookMorph >> newPages: pageList currentIndex: index [
	"Replace all my pages with the given list of BookPageMorphs. Make the current page be the page with the given index."

	pages := pages species new.
	pages addAll: pageList.
	pages isEmpty ifTrue: [^ self insertPage].
	self goToPage: index.

]

{ #category : #navigation }
BookMorph >> nextPage [
	currentPage isNil ifTrue: [^self goToPage: 1].
	self goToPage: (self pageNumberOf: currentPage) + 1
]

{ #category : #menu }
BookMorph >> pageControlsVisible [
	^ self hasSubmorphWithProperty: #pageControl
]

{ #category : #accessing }
BookMorph >> pageNamed: aName [
	^ pages detect: [:p | p knownName = aName] ifNone: [nil]
]

{ #category : #navigation }
BookMorph >> pageNumber [

	^ self pageNumberOf: currentPage
]

{ #category : #accessing }
BookMorph >> pageNumberOf: aMorph [
	"Modified so that if the page IS in memory, other pages don't have to be brought in.  (This method may wrongly say a page is not here if pages has a tombstone (MorphObjectOut) and that tombstone would resolve to an object already in this image.  This is an unlikely case, and callers just have to tolerate it.)"

	^ pages identityIndexOf: aMorph

]

{ #category : #accessing }
BookMorph >> pages [

	^ pages

]

{ #category : #accessing }
BookMorph >> pages: aMorphList [

	pages := aMorphList asOrderedCollection.

	"It is tempting to force the first page to be the current page.  But then, two pages might be shown at once!  Just trust the copying mechanism and let currentPage be copied correctly. --Ted."
]

{ #category : #printing }
BookMorph >> pagesHandledAutomatically [

	^true
]

{ #category : #menu }
BookMorph >> pasteBookPage [
	"If the paste buffer has something to paste, paste it as a book page."

	| aPage |
	aPage := self primaryHand objectToPaste.
	aPage removeProperty: #revertKey.

	self insertPage: aPage pageSize: aPage extent atIndex: ((pages indexOf: currentPage) - 1).
	"self goToPageMorph: aPage"
]

{ #category : #navigation }
BookMorph >> previousPage [
	currentPage isNil ifTrue: [^self goToPage: 1].
	self goToPage: (self pageNumberOf: currentPage) - 1
]

{ #category : #menus }
BookMorph >> printPSToFile [
	"Ask the user for a filename and print this morph as postscript."

	| fileName rotateFlag |
	fileName := 'MyBook' translated asFileName.
	fileName := UIManager default
					saveFilenameRequest: 'Filename to save BookMorph' translated 
					initialAnswer: fileName.
	fileName isEmptyOrNil ifTrue: [^ Beeper beep].
	(fileName endsWith: '.ps') ifFalse: [fileName := fileName,'.ps'].

	rotateFlag := (UIManager default chooseFrom: {
		'portrait (tall)' translated.
		'landscape (wide)' translated
	} title: 'Choose orientation...' translated) = 2.

	FileStream newFileNamed: fileName do: [:file|
		file nextPutAll: (DSCPostscriptCanvas morphAsPostscript: self rotated: rotateFlag)]
]

{ #category : #caching }
BookMorph >> releaseCachedState [
	"Release the cached state of all my pages."

	super releaseCachedState.
	self removeProperty: #allText.	"the cache for text search"
	pages do: [:page | 
		page == currentPage ifFalse: [page fullReleaseCachedState].
		page removeProperty: #cachedThumbnail].
]

{ #category : #menu }
BookMorph >> reload [
	"Fetch the pages of this book from the server again.  For all pages that have not been modified, keep current ones.  Use new pages.  For each, look up in cache, if time there is equal to time of new, and its in, use the current morph.
	Later do fancy things when a page has changed here, and also on the server."

	| url onServer onPgs which |
	(url := self valueOfProperty: #url) ifNil: ["for .bo index file"
	url := UIManager default 
		request: 'url of the place where this book''s index is stored.
Must begin with file:// or ftp://' translated
		initialAnswer: (self getStemUrl, '.bo').
	url notEmpty ifTrue: [self setProperty: #url toValue: url]
				ifFalse: [^ self]].
	onServer := self class new fromURL: url.
	"Later: test book times?"
	onPgs := onServer pages collect: [:out | | sq |
		sq := SqueakPageCache pageCache at: out url ifAbsent: [nil].
		(sq notNil and: [sq contentsMorph isInMemory])
			ifTrue: [((out sqkPage lastChangeTime > sq lastChangeTime) or: 
					  [sq contentsMorph isNil]) 
						ifTrue: [SqueakPageCache atURL: out url put: out sqkPage.
							out]
						ifFalse: [sq contentsMorph]]
			ifFalse: [SqueakPageCache atURL: out url put: out sqkPage.
				out]].
	which := (onPgs findFirst: [:pg | pg url = currentPage url]) max: 1.
	self newPages: onPgs currentIndex: which.
		"later stay at current page"
	self setProperty: #modTime toValue: (onServer valueOfProperty: #modTime).
	self setProperty: #allText toValue: (onServer valueOfProperty: #allText).
	self setProperty: #allTextUrls toValue: (onServer valueOfProperty: #allTextUrls).

]

{ #category : #initialization }
BookMorph >> removeEverything [
	currentPage := nil.
	pages := OrderedCollection new.
	self removeAllMorphs
]

{ #category : #menu }
BookMorph >> reserveUrls [
	"Save a dummy version of the book first, assign all pages URLs, write dummy files to reserve the url, and write the index.  Good when I have pages with interpointing bookmarks."

	| stem |
	(stem := self getStemUrl) isEmpty ifTrue: [^self].
	pages doWithIndex: 
			[:pg :ind | 
			"does write the current page too"

			pg url ifNil: [pg reserveUrl: stem , ind printString , '.sp']]

	"self saveIndexOnURL."
]

{ #category : #menu }
BookMorph >> reserveUrlsIfNeeded [
	"See if this book needs to pre-allocate urls.  Harmless if have urls already.  Actually writes dummy files to reserve names."

| baddies bad2 |
pages size > 25 ifTrue: [^ self reserveUrls].
baddies := BookPageThumbnailMorph withAllSubclasses.
bad2 := FlexMorph withAllSubclasses.
pages do: [:aPage |
	aPage allMorphsDo: [:mm | 
		(baddies includes: mm class) ifTrue: [^ self reserveUrls].
		(bad2 includes: mm class) ifTrue: [
			mm originalMorph class == aPage class ifTrue: [
				^ self reserveUrls]]]].
		

]

{ #category : #other }
BookMorph >> resizePagesTo: anExtent [
	pages do:
		[:aPage | aPage extent: anExtent]
]

{ #category : #scripting }
BookMorph >> revertToCheckpoint: secsSince1901 [
	
	"Put all scripts (that appear in MethodPanes) back to the way they were at an earlier time."

	MethodHolders do: [:mh | | cngRecord | 
		cngRecord := mh versions versionFrom: secsSince1901.
		cngRecord ifNotNil: [
			(cngRecord stamp: Utilities changeStamp) fileIn]].
		"does not delete method if no earlier version"


]

{ #category : #menu }
BookMorph >> saveAsNumberedURLs [
	"Write out all pages in this book that are not showing, onto a server.  The local disk could be the server.  For any page that does not have a SqueakPage and a url already, name that page file by its page number.  Any pages that are already totally out will stay that way."

	| stem list firstTime |
	firstTime := (self valueOfProperty: #url) isNil.
	stem := self getStemUrl.	"user must approve"
	stem isEmpty ifTrue: [^self].
	firstTime ifTrue: [self setProperty: #futureUrl toValue: stem , '.bo'].
	self reserveUrlsIfNeeded.
	pages doWithIndex: 
			[:aPage :ind | 
			"does write the current page too"

			aPage isInMemory 
				ifTrue: 
					["not out now"

					aPage presenter ifNotNil: [aPage presenter flushPlayerListCache].
					aPage saveOnURL: stem , ind printString , '.sp']].
	list := pages collect: [:aPage | aPage sqkPage prePurge].
	"knows not to purge the current page"
	list := (list select: [:each | each notNil]) asArray.
	"do bulk become:"
	(list collect: [:each | each contentsMorph]) 
		elementsExchangeIdentityWith: (list 
				collect: [:spg | MorphObjectOut new xxxSetUrl: spg url page: spg]).
	self saveIndexOnURL.
	self presenter ifNotNil: [self presenter flushPlayerListCache].
	firstTime 
		ifTrue: 
			["Put a thumbnail into the hand"

			URLMorph grabForBook: self.
			self setProperty: #futureUrl toValue: nil	"clean up"]
]

{ #category : #menu }
BookMorph >> saveIndexOfOnly: aPage [
	"Modify the index of this book on a server.  Read the index, modify the entry for just this page, and write back.  See saveIndexOnURL. (page file names must be unique even if they live in different directories.)"

	| mine sf remote pageURL num pre index after dict allText allTextUrls fName strm |
	mine := self valueOfProperty: #url.
	mine ifNil: [^ self saveIndexOnURL].
	strm := Cursor wait showWhile: [ServerFile new fullPath: mine].
	strm ifNil: [^ self saveIndexOnURL].
	strm isString ifTrue: [^ self saveIndexOnURL].
	strm exists ifFalse: [^ self saveIndexOnURL].	"write whole thing if missing"
	strm := strm asStream.
	strm isString ifTrue: [^ self saveIndexOnURL].
	remote := strm fileInObjectAndCode.
	dict := remote first.
	allText := dict at: #allText ifAbsent: [nil].	"remote, not local"
	allTextUrls := dict at: #allTextUrls ifAbsent: [nil].
	allText size + 1 ~= remote size ifTrue: [self error: '.bo size mismatch.  Please tell Ted what you just did to this book.' translated].


	(pageURL := aPage url) ifNil: [self error: 'just had one!' translated].
	fName := pageURL copyAfterLast: $/.
	2 to: remote size do: [:ii | 
		((remote at: ii) url findString: fName startingAt: 1 
						caseSensitive: false) > 0 ifTrue: [index := ii].	"fast"
		(remote at: ii) xxxReset].
	index ifNil: ["new page, what existing page does it follow?"
		num := self pageNumberOf: aPage.
		1 to: num-1 do: [:ii | (pages at: ii) url ifNotNil: [pre := (pages at: ii) url]].
		pre ifNil: [after := remote size+1]
			ifNotNil: ["look for it on disk, put me after"
				pre := pre copyAfterLast: $/.
				2 to: remote size do: [:ii | 
					((remote at: ii) url findString: pre startingAt: 1 
								caseSensitive: false) > 0 ifTrue: [after := ii+1]].
				after ifNil: [after := remote size+1]].
		remote := remote copyReplaceFrom: after to: after-1 with: #(1).
		allText ifNotNil: [
			dict at: #allText put: (allText copyReplaceFrom: after-1 to: after-2 with: #(())).
			dict at: #allTextUrls put: (allTextUrls copyReplaceFrom: after-1 to: after-2 with: #(()))].
		index := after].

	remote at: index put: (aPage sqkPage copyForSaving).

	(dict at: #modTime ifAbsent: [0]) < Time totalSeconds ifTrue:
		[dict at: #modTime put: Time totalSeconds].
	allText ifNotNil: [
		(dict at: #allText) at: index-1 put: (aPage allStringsAfter: nil).
		(dict at: #allTextUrls) at: index-1 put: pageURL].

	sf := ServerDirectory new fullPath: mine.
	Cursor wait showWhile: [ | remoteFile |
		remoteFile := sf fileNamed: mine.
		remoteFile fileOutClass: nil andObject: remote.
		"remoteFile close"].

]

{ #category : #menu }
BookMorph >> saveIndexOnURL [
	"Make up an index to the pages of this book, with thumbnails, and store it on the server.  (aDictionary, aMorphObjectOut, aMorphObjectOut, aMorphObjectOut).  The last part corresponds exactly to what pages looks like when they are all out.  Each holds onto a SqueakPage, which holds a url and a thumbnail."

	| dict mine sf urlList list |
	pages isEmpty ifTrue: [^self].
	dict := Dictionary new.
	dict at: #modTime put: Time totalSeconds.
	"self getAllText MUST have been called at start of this operation."
	dict at: #allText put: (self valueOfProperty: #allText).
	#(#color #borderWidth #borderColor #pageSize) 
		do: [:sel | dict at: sel put: (self perform: sel)].
	self reserveUrlsIfNeeded.	"should already be done"
	list := pages copy.	"paste dict on front below"
	"Fix up the entries, should already be done"
	list doWithIndex: 
			[:out :ind | 
			out isInMemory 
				ifTrue: 
					[(out valueOfProperty: #SqueakPage) ifNil: [out saveOnURLbasic].
					list at: ind put: out sqkPage copyForSaving]].
	urlList := list collect: [:ppg | ppg url].
	self setProperty: #allTextUrls toValue: urlList.
	dict at: #allTextUrls put: urlList.
	list := (Array with: dict) , list.
	mine := self valueOfProperty: #url.
	mine ifNil: 
			[mine := self getStemUrl , '.bo'.
			self setProperty: #url toValue: mine].
	sf := ServerDirectory new fullPath: mine.
	Cursor wait showWhile: 
			[ | remoteFile |
			remoteFile := sf fileNamed: mine.
			remoteFile dataIsValid.
			remoteFile fileOutClass: nil andObject: list
			"remoteFile close"]
]

{ #category : #menu }
BookMorph >> saveOnUrlPage: pageMorph [
	"Write out this single page in this book onto a server.  See savePagesOnURL.  (Don't compute the texts, only this page's is written.)"
	| stem ind response rand newPlace dir |
	(self valueOfProperty: #keepTogether) ifNotNil: [
		self inform: 'This book is marked ''keep in one file''. 
Several pages use a common Player.
Save the owner of the book instead.' translated.
		^ self].
	"Don't give the chance to put in a different place.  Assume named by number"
	((self valueOfProperty: #url) isNil and: [pages first url notNil]) ifTrue: [
		response := UIManager default chooseFrom: {
			'Old book' translated.
			'New book sharing old pages' translated
		} title: 'Modify the old book, or make a new
book sharing its pages?' translated.
		response = 2 ifTrue: [
			"Make up new url for .bo file and confirm with user."  "Mark as shared"
			[rand := String new: 4.
			1 to: rand size do: [:ii |
				rand at: ii put: ('bdfghklmnpqrstvwz' at: 17 atRandom)].
			(newPlace := self getStemUrl) isEmpty ifTrue: [^ self].
			newPlace := (newPlace copyUpToLast: $/), '/BK', rand, '.bo'.
			dir := ServerFile new fullPath: newPlace.
			(dir includesKey: dir fileName)] whileTrue.	"keep doing until a new file"
			self setProperty: #url toValue: newPlace].
		response = 0 ifTrue: [^ self]].

	stem := self getStemUrl.	"user must approve"
	stem isEmpty ifTrue: [^ self].
	ind := pages identityIndexOf: pageMorph ifAbsent: [self error: 'where is the page?' translated].
	pageMorph isInMemory ifTrue: ["not out now"
			pageMorph saveOnURL: stem,(ind printString),'.sp'].
	self saveIndexOfOnly: pageMorph.
]

{ #category : #menu }
BookMorph >> saveOneOnURL [
	"Write out this single page onto a server.  See savePagesOnURL.  (Don't compute the texts, only this page's is written.)"

	^ self saveOnUrlPage: currentPage
]

{ #category : #menu }
BookMorph >> savePagesOnURL [
	"Write out all pages in this book onto a server.  For any page that does not have a SqueakPage and a url already, ask the user for one.  Give the option of naming all page files by page number.  Any pages that are not in memory will stay that way.  The local disk could be the server."

	| response list firstTime newPlace rand dir bookUrl |
	(self valueOfProperty: #keepTogether) ifNotNil: [
		self inform: 'This book is marked ''keep in one file''. 
Several pages use a common Player.
Save the owner of the book instead.' translated.
		^ self].
	self getAllText.	"stored with index later"
	response := UIManager default chooseFrom:  {
		'Use page numbers' translated.
		'Type in file names' translated.
		'Save in a new place (using page numbers)' translated.
		'Save in a new place (typing names)' translated.
		'Save new book sharing old pages' translated.
	} title:  'Each page will be a file on the server.  
Do you want to page numbers be the names of the files? 
or name each one yourself?' translated.
	response = 1 ifTrue: [self saveAsNumberedURLs. ^ self].
	response = 3 ifTrue: [self forgetURLs; saveAsNumberedURLs. ^ self].
	response = 4 ifTrue: [self forgetURLs].
	response = 5 ifTrue: [
		"Make up new url for .bo file and confirm with user."  "Mark as shared"
		[rand := String new: 4.
		1 to: rand size do: [:ii |
			rand at: ii put: ('bdfghklmnpqrstvwz' at: 17 atRandom)].
		(newPlace := self getStemUrl) isEmpty ifTrue: [^ self].
		newPlace := (newPlace copyUpToLast: $/), '/BK', rand, '.bo'.
		dir := ServerFile new fullPath: newPlace.
		(dir includesKey: dir fileName)] whileTrue.	"keep doing until a new file"

		self setProperty: #url toValue: newPlace.
		self saveAsNumberedURLs. 
		bookUrl := self valueOfProperty: #url.
		(SqueakPage stemUrl: bookUrl) = 
			(SqueakPage stemUrl: currentPage url) ifTrue: [
				bookUrl := true].		"not a shared book"
		(URLMorph grabURL: currentPage url) book: bookUrl.
		^ self].
	response = 0 ifTrue: [^ self].

"self reserveUrlsIfNeeded.	Need two passes here -- name on one, write on second"
pages do: [:aPage |	"does write the current page too"
	aPage isInMemory ifTrue: ["not out now"
		aPage presenter ifNotNil: [aPage presenter flushPlayerListCache].
		aPage saveOnURLbasic.
		]].	"ask user if no url"

list := pages collect: [:aPage |	 aPage sqkPage prePurge].
	"knows not to purge the current page"
list := (list select: [:each | each notNil]) asArray.
"do bulk become:"
(list collect: [:each | each contentsMorph])
	elementsExchangeIdentityWith:
		(list collect: [:spg | MorphObjectOut new xxxSetUrl: spg url page: spg]).

firstTime := (self valueOfProperty: #url) isNil.
self saveIndexOnURL.
self presenter ifNotNil: [self presenter flushPlayerListCache].
firstTime ifTrue: ["Put a thumbnail into the hand"
	URLMorph grabForBook: self.
	self setProperty: #futureUrl toValue: nil].	"clean up"

]

{ #category : #accessing }
BookMorph >> setAllPagesColor: aColor [
	"Set the color of all the pages to a new color"

	self pages do: [:page | page color: aColor].
]

{ #category : #other }
BookMorph >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed.  For a BookMorph, we assume any resizing attempt is a request that the book-page currently being viewed be resized accoringly; this will typically not affect unseen book pages, though there is a command that can be issued to harmonize all book-page sizes, and also an option to set that will maintain all pages at the same size no matter what."

	currentPage isInWorld
		ifFalse: "doubtful case mostly"
			[super setExtentFromHalo: anExtent]
		ifTrue:
			[currentPage width: anExtent x.
			currentPage height: (anExtent y - (self innerBounds height - currentPage height)).
			self maintainsUniformPageSize ifTrue:
				[self setProperty: #uniformPageSize toValue: currentPage extent]]
]

{ #category : #initialization }
BookMorph >> setInitialState [
	self listDirection: #topToBottom;
	  wrapCentering: #topLeft;
	  hResizing: #shrinkWrap;
	  vResizing: #shrinkWrap;
	  layoutInset: 5.
	pageSize := 160 @ 300.
	self enableDragNDrop
]

{ #category : #menu }
BookMorph >> setNewPagePrototype [
	"Record the current page as the prototype to be copied when inserting new pages."

	currentPage ifNotNil:
		[newPagePrototype := currentPage veryDeepCopy.
		 newPagePrototype removeProperty: #revertKey].
		"When a new page is inserted, it will not have any original page to revert to.  After author improves the new page, he can save it for later revert."

]

{ #category : #menu }
BookMorph >> setPageColor [
	"Get a color from the user, then set all the pages to that color"
	self currentPage ifNil: [ ^ self ].
	NewColorPickerMorph useIt
		ifTrue:
			[ (NewColorPickerMorph
				on: self
				originalColor: self currentPage color
				setColorSelector: #setAllPagesColor:) openNear: self fullBoundsInWorld ]
		ifFalse:
			[ ColorPickerMorph new
				 choseModalityFromPreference ;
				 sourceHand: self activeHand ;
				 target: self ;
				 selector: #setAllPagesColor: ;
				 originalColor: self currentPage color ;
				
				putUpFor: self
				near: self fullBoundsInWorld ]
]

{ #category : #navigation }
BookMorph >> setWrapPages: doWrap [
	doWrap
		ifTrue: [self removeProperty: #dontWrapAtEnd]
		ifFalse: [self setProperty: #dontWrapAtEnd toValue: true].

]

{ #category : #navigation }
BookMorph >> showMoreControls [
	self currentEvent shiftPressed
		ifTrue:
			[self hidePageControls]
		ifFalse:
			[self showPageControls: self fullControlSpecs]
]

{ #category : #'menu commands' }
BookMorph >> sortPages [

	currentPage ifNotNil: [currentPage updateCachedThumbnail].
	^ super sortPages
]

{ #category : #sorting }
BookMorph >> sortPages: evt [

	^ self sortPages
]

{ #category : #menu }
BookMorph >> textSearch [
	"search the text on all pages of this book"

	| wanted wants list str |
	list := self valueOfProperty: #searchKey ifAbsent: [#()].
	str := String streamContents: [:strm | 
			list do: [:each | strm nextPutAll: each; space]].
	wanted := UIManager default request: 'words to search for.  Order is not important.
Beginnings of words are OK.' translated
		initialAnswer: str.
	wants := wanted findTokens: Character separators.
	wants isEmpty ifTrue: [^ self].
	self getAllText.		"save in allText, allTextUrls"
	^ self findText: wants	"goes to the page and highlights the text"
]

{ #category : #menu }
BookMorph >> textSearch: stringWithKeys [ 
	"search the text on all pages of this book"

	| wants |
	wants := stringWithKeys findTokens: Character separators.
	wants isEmpty ifTrue: [^self].
	self getAllText.	"save in allText, allTextUrls"
	^self findText: wants	"goes to the page and highlights the text"
]

{ #category : #menu }
BookMorph >> thumbnailForThisPage [
	self primaryHand attachMorph:
		(currentPage thumbnailForPageSorter pageMorph: currentPage inBook: self)

]

{ #category : #menu }
BookMorph >> toggleFullScreen [
	self isInFullScreenMode
		ifTrue:	[self exitFullScreen]
		ifFalse:	[self goFullScreen]
]

{ #category : #'uniform page size' }
BookMorph >> toggleMaintainUniformPageSize [
	"Toggle whether or not the receiver should maintain uniform page size"

	self maintainsUniformPageSize: self maintainsUniformPageSize not
]

{ #category : #menu }
BookMorph >> toggleShowingOfPageControls [
	self pageControlsVisible
		ifTrue:	[self hidePageControls]
		ifFalse:	[self showPageControls]
]

{ #category : #navigation }
BookMorph >> transitionSpecFor: aMorph [
	^ aMorph valueOfProperty: #transitionSpec  " check for special propety"
		ifAbsent: [Array with: 'camera'  " ... otherwise this is the default"
						with: #none
						with: #none]
]

{ #category : #menu }
BookMorph >> uncachePageSorter [
	pages do: [:aPage | aPage removeProperty: #cachedThumbnail].
]

{ #category : #'uniform page size' }
BookMorph >> uniformPageSize [
	"Answer the uniform page size to maintain, or nil if the option is not set"

	^ self valueOfProperty: #uniformPageSize ifAbsent: [nil]
]

{ #category : #copying }
BookMorph >> updateReferencesUsing: aDictionary [

	super updateReferencesUsing: aDictionary.
	pages do: [:page |
		page allMorphsDo: [:m | m updateReferencesUsing: aDictionary]].

]

{ #category : #accessing }
BookMorph >> userString [
	"Do I have a text string to be searched on?"

	| list |
	self getAllText.
	list := OrderedCollection new.
	(self valueOfProperty: #allText ifAbsent: #()) do: [:aList |
		list addAll: aList].
	^ list
]

{ #category : #'dropping\/grabbing' }
BookMorph >> wantsDroppedMorph: aMorph event: evt [
	(currentPage bounds containsPoint: (self pointFromWorld: evt cursorPoint)) ifFalse: [^ false].
	^ super wantsDroppedMorph: aMorph event: evt
]
