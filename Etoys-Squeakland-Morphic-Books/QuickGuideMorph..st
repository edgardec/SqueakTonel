"
A BookMorph that holds QuickGuides.

World
an AlignmentMorph (the flap)
an AlignmentMorph
a QuickGuideMorph  (one page per guide, 54 pages.  
		Page may be a stub if guide not in)
a QuickGuideHolderMorph
a BookMorph (4 pages)
a PasteUpMorph (a page)

QuickGuides are stored in Contents/Resources/QuickGuides/
or by language in Contents/Resources/locale/<id>/QuickGuides/
(see guidePath)

Categories = OrderedCollection of {catKey. catTitle}
	where catKey appears at the start of a file name 'Menu'
	catTitle may be UTF-8 full name.
PagesForCategory dictionary of (catKey -> list).  list has elements {guideName. guideTitle}.  guideName is last part of a file name and guideTitle may be in UTF-8.
"
Class {
	#name : #QuickGuideMorph,
	#superclass : #BookMorph,
	#instVars : [
		'control',
		'order'
	],
	#classVars : [
		'Categories',
		'FileNameStems',
		'HTMLJumpTo',
		'IndexPage',
		'IndexPageMimeString',
		'PagesForCategory'
	],
	#category : #'Etoys-Squeakland-Morphic-Books'
}

{ #category : #initialization }
QuickGuideMorph class >> buildDefaultIndex [
	| stems beg caps ind |
	self fileNameStems.	"used by defaultOrderIn:"
	Categories := OrderedCollection new.
	self suggestedCategoryOrder 
			do: [:cat | Categories add: {cat. cat}].
	stems := FileNameStems.
	stems do: [:fn | 
		(self categoryOf: fn) = '' ifTrue: ["new"
			"find first word"
			caps := fn collect: [:char | 
				char isUppercase ifTrue: [$c] ifFalse: [$l]].
			caps at: 1 put: $l.
			(ind := caps indexOf: $c) = 0 ifFalse: [
				beg := fn copyFrom: 1 to: ind-1.
				Categories add: {beg. beg}]]].
	PagesForCategory := self defaultIndex.

]

{ #category : #initialization }
QuickGuideMorph class >> categoryNamesDo: aBlock [
	"go through the categories in order"

	Categories do: [:catRec |
		aBlock value: catRec first].
]

{ #category : #defaults }
QuickGuideMorph class >> categoryOf: aName [

	^ Categories detect: [:e | aName beginsWith: e first] ifNone: [''].

]

{ #category : #initialization }
QuickGuideMorph class >> categoryTitleOf: catName [
	|catTitle|
	Categories do: [:catRec |
		(catRec first = catName )  
			ifTrue: [
				catTitle := catRec second.
				catTitle isNil ifTrue: [^catName]
									ifFalse: [^catTitle].
			].
	].
	^nil
]

{ #category : #'as yet unclassified' }
QuickGuideMorph class >> cleanUp [

	self indexPage: nil.
]

{ #category : #initialization }
QuickGuideMorph class >> defaultCatalog [
	| catalog | 
	catalog := Dictionary new.
	self fileNameStems.	"used by defaultOrderIn:"
	self suggestedCategoryOrder 
			do: [:catKey| |articles|
				articles := OrderedCollection new.
				(self defaultOrderIn: catKey) 
					do: [:guideName | | guideTitle |
						guideTitle := self getWordyName: guideName forCategory: catKey.
						articles add: {guideName. guideTitle}.
					].
				catalog at: catKey put: articles.
			].
	^catalog.
]

{ #category : #initialization }
QuickGuideMorph class >> defaultIndex [
	"Produce PagesForCategory.  Categories must already be initialized"
	| index | 
	index := Dictionary new.
	self categoryNamesDo: [:catKey | |articles|
				articles := OrderedCollection new.
				(self defaultOrderIn: catKey) 
					do: [:guideName | | guideTitle |
						guideTitle := self getWordyName: guideName forCategory: catKey.
						articles add: {guideName. guideTitle}.
					].
				index at: catKey put: articles.
			].
	^index.
]

{ #category : #defaults }
QuickGuideMorph class >> defaultOrderIn: helpCategory [

	| baseNames suggestedOrder ret last |
	baseNames := FileNameStems.	"don't reread every time"

	suggestedOrder := self suggestedOrder.
	helpCategory ifNotNil: [
		suggestedOrder := suggestedOrder select: [:e | e beginsWith: helpCategory].
		baseNames := baseNames select: [:e | e beginsWith: helpCategory]].

	ret := OrderedCollection new.
	baseNames := baseNames collect: [:bb | bb withoutTrailingDigits].
	suggestedOrder do: [:e |
		(baseNames includes: e) ifTrue: [
			baseNames remove: e.
			ret add: e.
		].
	].
	baseNames ifNotEmpty: [
		baseNames asArray do: [:e |
			last := ret reverse detect: [:b | 
					b beginsWith: helpCategory]
				ifNone: [ret ifEmpty: [nil] ifNotEmpty: [ret last]].
			last ifNil: [ret add: e]
				ifNotNil: [ret add: e after: last].
		].
	].
	^ ret asArray.

]

{ #category : #defaults }
QuickGuideMorph class >> fileNameStems [
	"Return a collection of the first part of all quickguide files on the disk.  trailing parts are removed (.sexp.data.gz  .xxx.pr)."

	| dir prs |
	dir := FileDirectory on: QuickGuideMorph guidePath.
	FileNameStems := ((dir fileNames select: [:f | f endsWith: '.sexp.data.gz']) collect: 
		[:f | f copyFrom: 1 to: f size - '.sexp.data.gz' size]) asSet.
	prs := ((dir fileNames select: [:f | f endsWith: '.pr']) collect: 
		[:f | f copyFrom: 1 to: f size - '.pr' size]).
	prs := prs collect: [:nn | (nn atWrap: nn size-3) = $. 
		ifTrue: [nn allButLast: 4]
		ifFalse: [nn]].
	^ FileNameStems addAll: prs

]

{ #category : #initialization }
QuickGuideMorph class >> getWordyName: guideName forCategory: guideCategory [
	"With guideName and category already filled in, make a name in words.  Remove the cat name, and trailing digits.  Separate words at capital letters.  NavBarHowToUse3 -> 'How To Use'  "

	| gn mm tt |
	gn := guideName allButFirst: guideCategory size.
	gn := gn withoutTrailingDigits.
	mm := gn size.
	gn reversed doWithIndex: [:cc :ind | 
		ind < mm  ifTrue: [
			cc isUppercase ifTrue: [ 
				tt := mm + 1 - ind.
				gn := (gn copyFrom: 1 to: tt-1), ' ', (gn copyFrom: tt to: gn size)].
			cc == $- ifTrue: [
				tt := mm + 1 - ind.
				gn at: tt put: $ ].	"convert dash to space"
			]].
	^ gn
]

{ #category : #defaults }
QuickGuideMorph class >> guidePath [
	| sepa localesPath langPath countryPath |
	sepa  := FileDirectory slash.
	localesPath := Smalltalk imagePath, sepa, 'locale'.

	"Look for current locale first"
	langPath := localesPath, sepa, LocaleID current isoLanguage.
	LocaleID current isoCountry ifNotNil: [
		countryPath := langPath, '_', LocaleID current isoCountry. 
		((FileDirectory on: countryPath ) directoryExists: 'QuickGuides') 
			ifTrue: [^ countryPath, sepa, 'QuickGuides' ]].
	((FileDirectory on: langPath) directoryExists: 'QuickGuides') 
		ifTrue: [^ langPath, sepa, 'QuickGuides' ].

	"Try English next"
	((FileDirectory on: localesPath, sepa, 'en') directoryExists: 'QuickGuides') 
		ifTrue: [^ localesPath, sepa, 'en', sepa, 'QuickGuides' ].

	"Old location"
	((FileDirectory on: Smalltalk imagePath) directoryExists: 'QuickGuides') 
		ifTrue: [^ Smalltalk imagePath, sepa, 'QuickGuides' ].

	"Any language"
	(FileDirectory on: localesPath) directoryNames do: [:dir |
		((FileDirectory on: localesPath, sepa, dir) directoryExists: 'QuickGuides')
			ifTrue: [^ localesPath, sepa, dir, sepa, 'QuickGuides']].

	"Give up"
	^ nil
]

{ #category : #initialization }
QuickGuideMorph class >> indexPage: anObject [

	IndexPage := anObject.
	IndexPage ifNotNil: [
		IndexPage setNamePropertyTo: 'index'].

]

{ #category : #initialization }
QuickGuideMorph class >> indexPageMimeString: aString [

	IndexPageMimeString := aString.

]

{ #category : #initialization }
QuickGuideMorph class >> loadIndex [
	"Optional catalog file 'catalog.txt' may be placed to where Quickguide contents resides.  Purpose is to allow UTF8 encoded titles and menu items for guides.  It also suggests an order for guides within a category.
:NavBar/Navigator                        <--- categoryName/title of category 
PaintBrushes/Brushes                  <--- guideName/title of guide
PaintColorPalette/Color Palette
    Titles for categories and guides can be translated.  
    The file is UTF8 encoded.
    File name for each guide contents is <guideName>.sexp.data.gz.
    <guideName> should be named only with ascii characters.
Template of catalog file can be generated by evaluating this:
        QuickGuideMorph buildDefaultIndex.
        QuickGuideMorph saveCatalog."

	| st line rec categoryRec catKey  catTitle guideName guideTitle|
	st := FileStream oldFileOrNoneNamed: QuickGuideMorph guidePath, (FileDirectory slash), 'index.txt'.
	st ifNil: [^ self buildDefaultIndex].
	st wantsLineEndConversion: true.
	st text.
     Categories := OrderedCollection new.
	PagesForCategory := Dictionary new.
	[st atEnd] whileFalse: [

		line := (st upTo: Character cr) withoutTrailingBlanks.
		(line first = $: ) ifTrue: [	"Category"
			rec := line allButFirst subStrings: '|'.
			catKey := ((rec at: 1) subStrings: '|') at: 1.
			rec size = 2
				ifTrue:  [ catTitle := rec second]
				ifFalse:[ catTitle := catKey].
			categoryRec := {catKey. catTitle}.
			self replaceInCategories: categoryRec.

			PagesForCategory at: catKey put: OrderedCollection new.
		] ifFalse: [
			rec := line subStrings: '|'.
			guideName := rec first.
			rec size = 2 
				ifTrue: [
					guideTitle := rec second]
				ifFalse: [
					guideTitle := self getWordyName: guideName forCategory: catKey].
			(PagesForCategory at: catKey ) add: {guideName. guideTitle}.
		]
	].
]

{ #category : #initialization }
QuickGuideMorph class >> loadIndexAndPeekOnDisk [
	"If index.txt is present, load it and then scan the actual folder for extra guides.  Add them to the list."

	| indCat indPages extras list indList |
	(FileStream concreteStream isAFileNamed: 
		QuickGuideMorph guidePath, (FileDirectory slash), 'index.txt')
			ifTrue: [self loadIndex]
			ifFalse: [^ self buildDefaultIndex].	"no index file"

	"Add in the guides on disk that are not in index.txt"
	indCat := Categories. 	"from index.txt"
	indPages := PagesForCategory.
	self buildDefaultIndex.	"from the file directory"
	Categories "from disk" do: [:categoryRec |
		indCat detect: [:pair | pair first = categoryRec first] 
			ifNone: [indCat addLast: categoryRec]].
	PagesForCategory "from disk" associationsDo: [:pair |
		 (indPages includesKey: pair key) 
			ifFalse: [indPages at: pair key put: pair value]
			ifTrue: [list := pair value.
				indList := indPages at: pair key.
				extras := OrderedCollection new.
				list do: [:diskPair |
					indList detect: [:indPair | indPair first = diskPair first]
						ifNone: [extras addLast: diskPair]].
				indPages at: pair key put: indList, extras]].
	Categories := indCat.
	PagesForCategory := indPages.
]

{ #category : #initialization }
QuickGuideMorph class >> preloadIndexPage [
	self new checkForIndexOnDisk
		ifFalse: [self error: 'index page not found'].

]

{ #category : #initialization }
QuickGuideMorph class >> purgeIndexProjects [
	"remove all projects that came from loading the index guide."

	| px nn |
	[px := Project allProjects detect: [:pp | pp name beginsWith: 'index'] ifNone: [nil].
	px ifNotNil: [
		nn := Project allProjects indexOf: px.
		Project allProjects removeAt: nn].
	px == nil] whileFalse.
	Smalltalk garbageCollect. 

]

{ #category : #initialization }
QuickGuideMorph class >> replaceInCategories: catPair [
	"Find an entry in Categories with the same first element (untranslated), and replace that entry.  If not found, put at end.  For translated name to replace default."

	Categories withIndexDo: [:oldPair :ind |
		oldPair first = catPair first ifTrue: [
			^ Categories at: ind put: catPair]].
	Categories add: catPair.
]

{ #category : #initialization }
QuickGuideMorph class >> saveIndex [
	"Note: file is put into Etoys folder.  A person must move it to resources/QuickGuides"
	|stream |
	stream := FileStream forceNewFileNamed: 'index.txt'.
	stream lineEndConvention: #lf.
	stream converter: UTF8TextConverter new.
	[
		Categories 
			do: [:catRecord |
				stream nextPut: $:.
				stream nextPutAll: catRecord first.  "category key"
				(catRecord second ) = (catRecord first) 
					ifFalse:[
						stream nextPut: $|.
						stream nextPutAll: catRecord second.  "category title (translated)"
					].
				stream cr.

				(PagesForCategory at: (catRecord first)) 
					do: [:rec |
						stream nextPutAll: rec first.	"guideName"
						stream nextPut: $|.
						stream nextPutAll: rec second.			"guide title (translated)"
						stream cr.
					]
			]
	]  ensure: [stream close].
]

{ #category : #defaults }
QuickGuideMorph class >> suggestedCategoryOrder [

	^ #(
	'NavBar'
	'Paint'
	'Halo'
	'Supplies'
	'ObjectCat'
	'Books'
	'ScriptTile'
	'Menu'
	)
]

{ #category : #defaults }
QuickGuideMorph class >> suggestedOrder [

	^ #(
	'BooksTopBorderIcons'
	'BooksExpandedControls'
	'BooksWorking-withLayers'
	'BooksViewerCategoryTiles'
	'HaloMake-theHandlesShow'
	'HaloViewer-ofScriptTiles'
	'HaloSizeColorCopy'
	'HaloMove-andPickUp'
	'HaloRotateHandle'
	'HaloTrash'
	'HaloArrow-atCenter'
	'HaloCenter-ofRotation'
	'HaloMenuTools'
	'HaloMake-aScriptTile'
	'HaloCollapse'
	'MenuNormalTicking'
	'MenuViewerIconsSet'
	'MenuScriptorIconsSet'
	'MenuButtonFires-aScript'
	'MenuGrabMeRevealMe'
	'MenuWatchers'
	'NavBarKeepFindProjects'
	'NavBarChoose-aLanguage'
	'ObjectCatSliderBar'
	'ObjectCatGrabPatchTool'
	'ObjectCatLassoTool'
	'ObjectCatDigitalImages'
	'ObjectCatMakerButton'
	'PaintBrushes'
	'PaintColorPalette'
	'PaintBucketTool'
	'PaintStraightLineTool'
	'PaintEllipseTool'
	'PaintRectangleTool'
	'PaintPolygonTool'
	'PaintColorPicker'
	'PaintStampsTool'
	'ScriptTileForward-by'
	'ScriptTileTurn-by'
	'ScriptTilesForward-andTurn'
	'ScriptTileBounceMotion'
	'ScriptTileX-andYTiles'
	'ScriptTilesTestsCategory'
	'ScriptTilePenUse'
	'ScriptTilePlayfieldTrail'
	'ScriptTileBatchTrail'
	'ScriptTileStamps'
	'ScriptTileHeading'
	'ScriptTileScaleFactor'
	'ScriptTileHide-andShow'
	'ScriptTileWorldInput'
	'ScriptTileSoundCategory'
	'SuppliesObjectCatalog'
	'SuppliesText'
	'SuppliesAllScripts'
	'SuppliesJoystickControl'
	'SuppliesSoundRecorder'
	)
]

{ #category : #'write web pages' }
QuickGuideMorph >> allGuidesToWeb [
	"Write out web pages for each of the Guides in the QuickGuides folder.  In an inspector on the current help flap, evaluate

	self allGuidesToWeb.

Write both a web page and the .jpegs for each guide page.
Method to write N new guides, and update the index for the others:
	self rewriteGuidesAndIndexInOthers: 'name name name'.

Return the text for the wiki page:  http://wiki.laptop.org/go/Etoys_QuickGuides_Index
	self guidesIndexForWiki.

To allow the text in Guides to show in other languages.
When the text of guides change, we need to write it out to the .pot and .po files.

To translate guides that are already written out in English:
In the folder po/quickguides/  copy an existing .po file and name it similar to pt-BR.po (pt for Portugese and BR for Brazil).
Edit the file in a UFT-8 aware editor (not the Squeak file list).  
Save As in UFT-8.
In the shell terminal.  (langCode is pt_BR in this example) execute
     msgfmt langCode.po -o quickguides.mo
(how add on to existing .mo with other languages?)
Move quickguides.mo to   lang/langCode/LC_MESSAGES/
Get into Etoys, set the language to the language you are working with, and look at a guide.
"
	self htmlForJumpTo.	"reset"
	1 to: pages size do: [:ii |
		self goToPage: ii.
		self guideToWebWithJPEGs: true ].
	self beep.
]

{ #category : #'write web pages' }
QuickGuideMorph >> allTextIn: aPage [
	"Return a string of all the text in all the textMorphs on this page. separated by period space space."

	| tt |
	^ String streamContents: [:strm |
		aPage allMorphsDo: [:mm |
			(mm isKindOf: TextMorph) ifTrue: [
				tt := mm contents string withBlanksTrimmed.
				strm nextPutAll: tt.
				(tt size > 0 and: [tt last ~= $.]) ifTrue: [strm nextPut: $.].
				strm space; space]]].
]

{ #category : #transition }
QuickGuideMorph >> checkForIndexOnDisk [
	"For localization.  Look on disk every time for a new Index. Overwrite IndexPage if found."

	| dir holder |
	dir := FileDirectory on: QuickGuideMorph guidePath.
	(dir fileExists: 'index.pr') ifFalse: [
		(dir fileExists: 'index.sexp.data.gz') ifFalse: [^ false]].
	holder := pages first.
	holder guideName: 'index'. 
	holder guideCategory: ''. 
	holder load.	"allow index.sexp.data.gz"
	IndexPage :=  holder submorphs first.
	^ true

"	IndexPage := QuickGuideHolderMorph new loadPR: 'index.pr' dir: dir.	"

]

{ #category : #'submorphs add\/remove' }
QuickGuideMorph >> delete [

	self unloadPages.
	super delete.

]

{ #category : #'menu actions' }
QuickGuideMorph >> descriptionReport [

	^ currentPage guideNameInWords

]

{ #category : #'menu actions' }
QuickGuideMorph >> goToCardNamed: cardName [

	| page inner |
	page := pages detect: [:p | p guideName = cardName] ifNone: [nil].
	page ifNotNil: [self goToPage: (self pageNumberOf: page).
		(inner := currentPage findA: BookMorph) ifNotNil: [
			inner currentPage player ifNotNil: [
				inner currentPage player runAllOpeningScripts]]].

]

{ #category : #'menu actions' }
QuickGuideMorph >> goToIndex [
	"Return to the index Guide"

	"(submorphs first isKindOf: QuickGuideHolderMorph) ifTrue: [submorphs first unload]."
	"do we need to unload in every page (new guide) transition?"
	self initializeIndexPage.
]

{ #category : #transition }
QuickGuideMorph >> goToPageMorph: newPage transitionSpec: transitionSpec [

	newPage load.
	super goToPageMorph: newPage transitionSpec: transitionSpec.

]

{ #category : #'write web pages' }
QuickGuideMorph >> guideToWeb [
	"Write all the info in this guide to a web page.  Pages are images (jPEGs).  Create a page to hold them."

	self guideToWebWithJPEGs: true.
]

{ #category : #'write web pages' }
QuickGuideMorph >> guideToWebWithJPEGs: withPics [
	"Write all the info in this guide to a web page.  Pages are images (jPEGs).  Create a page to hold them."

	| dir qgh bk strm ff allText thisText |
	dir := FileDirectory default directoryNamed: 'QG-web'.
	"picutres of guide pages"
	qgh := self submorphOfClass: QuickGuideHolderMorph.
	(bk := qgh submorphOfClass: BookMorph) ifNil: [^ self].
	strm := WriteStream on: (String new: 500).
	strm nextPutAll: (self htmlPreamble: qgh guideNameInWords).	"includes index side bar"
	allText := ''.

	1 to: bk pages size do: [:ii |
		withPics ifTrue: [	"Make images of pages"
			bk goToPage: ii.	"show it"
			self jPegOutDir: dir].
		thisText := self allTextIn: (bk pages at: ii).
		strm nextPutAll: '		  <tr><td>  <img  alt="'.
		strm nextPutAll: qgh guideName, ', page ', ii printString,'. ', thisText, '"  src="./'.
		strm nextPutAll: qgh guideName , '-', ii printString,'.jpg"> </tr></tc>
'.
		allText := allText, thisText].

	strm nextPutAll: '		</table>

</td></tc>
</table>

<p><a href="#thetop">Jump to Top</a></p>

<p>Squeak Etoys is a "media authoring tool"-- software that you can download to your computer <br>
and then use to create your own media.  You can write out your project and share it with others.  <br>
Etoys runs on any Mac or Windows machine, as well as on the OLPC XO machine.  <br>
It is free. &nbsp;&nbsp;
	<a href="http://www.squeakland.org/whatis/whatismain.html">Find out about Etoys.</a></p>

<p><br><br>Text of this guide (for searching): ', allText, '</p>
</body>
</html>                  '.
	ff := dir fileNamed: qgh guideName, '.html'.
	ff nextPutAll: strm contents; close.
]

{ #category : #'write web pages' }
QuickGuideMorph >> guidesIndexForWiki [
	"Create the html for a long list of guide categories and guides.  Each is a clickable link.  For the laptop.org wiki.  An index to the web pages for the Guides.
	Inspect a Guide and go up the owner chain to a QuickGuideMorph.   self  guidesIndexForWiki     "

	| strm |
	strm := WriteStream on: (String new: 6000).

	strm nextPutAll: 'At the top left of the screen in Etoys is a "?" button.  Clicking it brings up a help flap with more than 50 QuickGuides.  These tell how to use different parts of Etoys.  

[[Image:Help-icon.jpeg]]

The QuickGuides are also available on the web.  Note that the active buttons and Etoys controls will not work in the web version.
__NOTOC__'; cr.
	strm nextPutAll: '=== Guides about topics in EToys ==='; cr; cr.

	self class categoryNamesDo: [:catName |
		strm nextPutAll: '==== '; nextPutAll: catName translated; nextPutAll: ' ===='; cr.
		pages do: [:pp |
			pp guideCategory = catName ifTrue: [
				strm nextPutAll: '* [http://tinlizzie.org/olpc/QG-web/', pp guideName, '.html'.
				strm space; nextPutAll: pp guideNameInWords translated; nextPutAll: ']'; cr.
				]].
		].
	^ strm contents

	"&nbsp;"
]

{ #category : #'menu actions' }
QuickGuideMorph >> handCopyCard [

	^ self world primaryHand attachMorph: currentPage submorphs first veryDeepCopy.

]

{ #category : #'write web pages' }
QuickGuideMorph >> htmlForJumpTo [
	"Create the html for a long list of guide categories and guides.  Each is a clickable link.  Store in the class var HTMLJumpTo.  For creating web pages from the Guides."

	| strm ap |
	1 to: pages size do: [:ii | self goToPage: ii].	"create all pages" 
	strm := WriteStream on: (String new: 500).
	strm nextPutAll: '<b>Guides about topics in EToys</b><br>
<i>Help screens for the OLPC<br> XO machine.</i><br>'.

	Categories do: [:pair |
		strm nextPutAll: pair second translated; nextPutAll: '<br>'; cr.
		(PagesForCategory at: pair first) do: [:gPair |
			ap := pages detect: [:p | (p hasProperty: #quickGuideHolder) and: [p knownName = gPair first]] ifNone: [nil].
			(ap submorphOfClass: BookMorph) ifNotNil: ["exists"
				strm tab; tab.
				strm nextPutAll: '&nbsp;&nbsp;&nbsp;<a href="./', gPair first, '.html">'.
				strm nextPutAll: gPair second; nextPutAll: '</a><br>'; cr]]].
	^ HTMLJumpTo := strm contents
]

{ #category : #'write web pages' }
QuickGuideMorph >> htmlPreamble: theGuideName [
	"All the stuff at the beginning of an html file.  Includes the JumpTo menu of links to other Guides."

	| strm |
	strm := WriteStream on: (String new: 500).
	strm nextPutAll: '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
 <head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
 <title>'.

	strm nextPutAll: theGuideName.
	strm nextPutAll: ', an Etoys Quick Guide</title>
 </head>
 <body bgcolor="#cef2ff" text="#000000">
 <A NAME="thetop">
 <h1 align="center">'.
	strm nextPutAll: theGuideName.
	strm nextPutAll: '</h1>'.
	strm nextPutAll: '<h3 align="center">A Quick Guide for Etoys on the OLPC XO</h3>

<table border="0" cellspacing="0" cellpadding="6">
  <tc valign ="top"><td valign ="top"> 
<br>'.
	strm nextPutAll: HTMLJumpTo.	"Jump to menu"
	strm nextPutAll: '
 </td></tc>


 <tc> <td>
	<table border="0" cellspacing="0" cellpadding="12">
'.
	^ strm contents
]

{ #category : #initialization }
QuickGuideMorph >> initialize [

	| newPage |
	self beSticky.
	newPagePrototype := QuickGuideHolderMorph new.
	newPagePrototype guideName: 'empty'.
	newPagePrototype setProperty: #transitionSpec toValue: (Array with:  'silence' with: #none with: #none).
	super initialize.
	order := OrderedCollection with: 'index'.

	newPage := newPagePrototype veryDeepCopy.
	newPage guideName: 'index'.
	self insertPage: newPage pageSize: 100@100 atIndex: 1.
	self goToPage: 2.
	self deletePageBasic.
	self pageControlsAtTop: false.
	self jumpToAdjust: self pageControls.
]

{ #category : #initialization }
QuickGuideMorph >> initializeIndexPage [

	| indexPage firstPage |
	"debugging only -- look on disk"
	self checkForIndexOnDisk ifTrue: [
		self goToPage: 1.
		^ self]. 	"Done.  sets IndexPage every time if found"

	IndexPage ifNotNil: [
		indexPage := IndexPage veryDeepCopy.
		firstPage := pages first.
		indexPage position: firstPage position.
		indexPage beSticky.
		firstPage extent: indexPage extent.
		firstPage submorphs size > 0 ifTrue: [firstPage submorphs last delete].
		firstPage submorphs size > 0 ifTrue: [firstPage submorphs last delete].
		firstPage addMorph: indexPage.
		self goToPage: 1.
	].

]

{ #category : #'write web pages' }
QuickGuideMorph >> jPegOutDir: fileDir [
	"Write the current page of the current Guide as an image file on the directory"
	"Does it need to be showing?"

	| fName gn num qgh bk |

	qgh := self submorphOfClass: QuickGuideHolderMorph.
	bk := qgh submorphOfClass: BookMorph.
	num := (bk pages indexOf: bk currentPage) printString.
	gn := qgh guideName. 
	fName := fileDir pathName, fileDir pathNameDelimiter asString, gn, '-', num, '.jpg'.
	currentPage imageForm writeJPEGfileNamed: fName.
	"need to go deeper??"
	^ ''
]

{ #category : #'page controls' }
QuickGuideMorph >> jumpToAdjust: pageControlColumn [
	"Change look of JumpTo: button, since specs don't have enough options."

	| bar jump |
	bar := pageControlColumn firstSubmorph firstSubmorph.
	jump := bar submorphThat: [:mm |
		mm class == SimpleButtonMorph and: [mm actionSelector == #showJumpToMenu]
		]  ifNone: [^ nil].
	jump color: (Color r: 0.839 g: 1.0 b: 0.806);
		borderColor: (Color gray: 0.6);
		actWhen: #buttonUp.

]

{ #category : #initialization }
QuickGuideMorph >> loadPages [
	| pageCount newPages page unusedPages |
	pageCount := PagesForCategory inject: 0 into: [:arg :each | arg + (each size)].
	newPages := OrderedCollection new: pageCount.

	page := pages detect: [:p | (p hasProperty: #quickGuideHolder) and: [p knownName = 'index']] ifNone: [nil].
	page ifNil: [
		page := QuickGuideHolderMorph new.
		page guideName: 'index' translated.
		page setProperty: #transitionSpec toValue:  (Array with:  'silence' with: #none with: #none).
	].
	page guideNameInWords ifNil: [
			page guideNameInWords: 'Index' translated].
	newPages add: page.

     Categories do: [:categoryRec | | catKey  |
		catKey := categoryRec first.
		(PagesForCategory at: catKey) do:  [: rec || guideName guideTitle |
			guideName := rec first.
			guideTitle := rec second.
			page := pages detect: [:p | (p hasProperty: #quickGuideHolder) and: [p knownName = guideName]] ifNone: [nil].
			page ifNil: [
				page := QuickGuideHolderMorph new.
				page guideName: guideName.
				page guideNameInWords: guideTitle.
				page setProperty: #transitionSpec toValue:  (Array with:  'silence' with: #none with: #none).
			].
			newPages add: page.
		].
	].
		
	unusedPages := pages reject: [:e | (newPages includes: e)].
	self newPages: (newPages, unusedPages) currentIndex: 1.
]

{ #category : #'menu actions' }
QuickGuideMorph >> makeCategoryMenu: catName [
	"return a menu with all guides in this category.  No title"

	| subMenu |
	subMenu := MenuMorph new defaultTarget: self.
	PagesForCategory ifNil: [self class loadIndexAndPeekOnDisk].
	(PagesForCategory at: catName ifAbsent: [#()]) 
			do: [:articleRec |
				subMenu add: (articleRec second) 
							target: self 
							selector: #goToCardNamed: 
							argument: (articleRec first)].
	^ subMenu
]

{ #category : #'menu actions' }
QuickGuideMorph >> nextCard [

	^ super nextPage.

]

{ #category : #'menu actions' }
QuickGuideMorph >> nextPage [

	| b |
	b := currentPage findA: BookMorph.
	b ifNotNil: [b nextPage. ^ self].

]

{ #category : #initialization }
QuickGuideMorph >> order: names [

	| newPages page unusedPages |
	newPages := OrderedCollection new: names size.
	((Array with: 'index'), names asArray) do: [:n |
		page := pages detect: [:p | (p hasProperty: #quickGuideHolder) and: [p knownName = n]] ifNone: [nil].
		page ifNil: [
			page := QuickGuideHolderMorph new.
			page guideName: n.
			page setProperty: #transitionSpec toValue:  (Array with:  'silence' with: #none with: #none).
		].
		newPages add: page.
	].
		
	unusedPages := pages reject: [:e | (newPages includes: e)].
	self newPages: (newPages, unusedPages) currentIndex: 1.
	order := names.

]

{ #category : #'page controls' }
QuickGuideMorph >> pageNumberReport [

	| b |
	b := currentPage findA: BookMorph.
	b ifNotNil: [^ b pageNumberReport].
	^ super pageNumberReport.

]

{ #category : #'menu actions' }
QuickGuideMorph >> previousCard [

	^ super previousPage.

]

{ #category : #'menu actions' }
QuickGuideMorph >> previousPage [

	| b |
	b := currentPage findA: BookMorph.
	b ifNotNil: [b previousPage. ^ self].

]

{ #category : #'write web pages' }
QuickGuideMorph >> rewriteGuidesAndIndexInOthers: nameList [
	"Create new files for guides in list, including jpegs.  For all other guides, just redo the HTML to get a revised index column."

self htmlForJumpTo.	"reset"
nameList do: [:gg |
	self goToCardNamed: gg.
	self guideToWebWithJPEGs: true ].

	"Later could make entire html for a guide without loading it.  See htmlForJumpTo "
1 to: pages size do: [:ii |
	self goToPage: ii.
	self guideToWebWithJPEGs: false ].
self beep.
]

{ #category : #'page controls' }
QuickGuideMorph >> shortControlSpecs [

	^ {
		#spacer.
		#pageNumber.
		#variableSpacer.
		{#PrevPage. 		#previousPage.			'Previous page' translated}.
		#spacer.
		#showDescription.
		#spacer.
		{#NextPage.		#nextPage.				'Next page' translated}.
		#variableSpacer.
		{' ', 'Jump to...' translated, ' '.	#showJumpToMenu.		'Menu to see another Guide' translated.	#border}.
			"further adjusted in jumpToAdjust: "
		#spacer.
	}
]

{ #category : #'menu actions' }
QuickGuideMorph >> showDescriptionMenu: evt [
	"The Jump To menu.  Choose a guide to see next"
	| aMenu subMenu aWorld pos |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'Quick Guides' translated.

	self class categoryNamesDo: [:catName |
		subMenu := self makeCategoryMenu: catName.
		subMenu items ifNotEmpty: [
				aMenu add: (self class categoryTitleOf: catName)
							subMenu: subMenu]].
	aMenu add: 'Index' translated action: #goToIndex.
	aWorld := aMenu currentWorld.
	pos := aWorld primaryHand position - (aMenu fullBounds extent) + (-2@30).
	aMenu popUpAt: pos forHand: aWorld primaryHand in: aWorld.

]

{ #category : #'menu actions' }
QuickGuideMorph >> showJumpToMenu [

	self showDescriptionMenu: nil

]

{ #category : #'menu actions' }
QuickGuideMorph >> showMenuCategory: catName [
	"put up a menu with all guides in this category"

	| subMenu |
	subMenu := self makeCategoryMenu: catName.
	subMenu addTitle: (self class categoryTitleOf: catName).
	subMenu popUpInWorld.
]

{ #category : #'page controls' }
QuickGuideMorph >> showPageControls: controlSpecs [

	^ self showPageControls: controlSpecs allowDragging: false. 	"Do not drag Guide out of flap easily"

]

{ #category : #'submorphs add\/remove' }
QuickGuideMorph >> unloadPages [

	pages do: [:e | e unload].

]
