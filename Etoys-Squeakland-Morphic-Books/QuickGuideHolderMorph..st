"
This is the Flap that holds the Guides.  Shows one guide at a time, 
"
Class {
	#name : #QuickGuideHolderMorph,
	#superclass : #PasteUpMorph,
	#instVars : [
		'guideName',
		'guideNameInWords',
		'guideCategory'
	],
	#category : #'Etoys-Squeakland-Morphic-Books'
}

{ #category : #accessing }
QuickGuideHolderMorph >> guideCategory [
	"Answer the value of guideCategory"

	^ guideCategory
]

{ #category : #accessing }
QuickGuideHolderMorph >> guideCategory: anObject [
	"Set the value of guideCategory"

	guideCategory := anObject
]

{ #category : #accessing }
QuickGuideHolderMorph >> guideName [

	^ guideName

]

{ #category : #accessing }
QuickGuideHolderMorph >> guideName: aString [

	guideName := aString.
	self setNamePropertyTo: aString.

]

{ #category : #accessing }
QuickGuideHolderMorph >> guideNameInWords [
	"Answer the value of guideNameInWords"

	^ guideNameInWords
]

{ #category : #accessing }
QuickGuideHolderMorph >> guideNameInWords: anObject [
	"Set the value of guideNameInWords"

	guideNameInWords := anObject
]

{ #category : #initialization }
QuickGuideHolderMorph >> initialize [

	super initialize.
	self setProperty: #quickGuideHolder toValue: true.
	self beSticky.

]

{ #category : #'file in\/file out' }
QuickGuideHolderMorph >> load [
	"If 'guide.00x.pr' is present, take the one with the largest x.  If only '.sexp.data.gz', then use it"
	| dir m fileName f unzipped zipped ours proj tm |
	self submorphs size > 0 ifTrue: [^ self].
	dir := FileDirectory on: QuickGuideMorph guidePath.
	"#('xxx.001.pr' 'xxx.035.pr'  'xxx.sexp.data.gz') sort   ('xxx.001.pr' 'xxx.035.pr' 'xxx.sexp.data.gz')"
	ours := dir fileNames select: [:fName | 
		(fName beginsWith: guideName) and: [(fName endsWith: '.pr') or: [fName endsWith: '.sexp.data.gz']]].
	ours := ours sort.
	ours size = 0 ifTrue: [
		submorphs size = 0 ifTrue: [
			tm := TextMorph new contents: 'guide is missing' translated.
			tm topLeft: self topLeft + (4@4).
			self width: (self width max: 200).
			self addMorphFront: tm].
		^ self].
	fileName := ours size > 1 ifTrue: [ours at: (ours size - 1) "most recent .pr file"] ifFalse: [ours last "sexp"].
	proj := fileName endsWith: '.pr'.
	Cursor wait showWhile: [
		proj ifFalse: [
			unzipped := WriteStream on: ByteArray new.
			f := dir readOnlyFileNamed: fileName.
			zipped := GZipReadStream on: f.
			unzipped nextPutAll: zipped contents.
			m := BookMorph bookFromPagesInSISSFormat: (DataStream on: (ReadStream on: (unzipped contents))) next.
			f close].
		proj ifTrue: [
			m := self loadPR: fileName dir: dir.
			m ifNil: [^ self]].
		m position: 0@0.
		self position: 0@0.
		self extent: m extent.
		m setNamePropertyTo: guideName.
		m beSticky.
		self translateGuide: m.
		self addMorph: m.
	].

]

{ #category : #'file in\/file out' }
QuickGuideHolderMorph >> loadPR: fileName dir: dir [
	"load a guide from a .pr file"

	| p book texts desc |
	p := ProjectLoading loadName: fileName 
			stream: (dir readOnlyFileNamed: fileName) 
			fromDirectory: dir withProjectView: #none.	"don't create project view"
	book := p world submorphs detect: [:b | b isMemberOf: BookMorph] ifNone: [nil].
	book ifNotNil: [
		texts := book currentPage submorphs select: [:e | e isKindOf: TextMorph].
		desc := texts isEmpty
			ifTrue: [^ nil]
			ifFalse: [(texts detectMin: [ :each | each top]) contents asString].
"		Descriptions at: p name put: desc.
		Thumbnails at: p name put: (book imageForm magnifyBy: 0.25).
		Colors at: p name put: book color.
"
		book hidePageControls.
		].
	^ book
]

{ #category : #'file in\/file out' }
QuickGuideHolderMorph >> prepareToBeSaved [

	self unload.
	super prepareToBeSaved.

]

{ #category : #'file in\/file out' }
QuickGuideHolderMorph >> translateGuide: guideBook [
	"Look at the current language, and translate every string in the book.  Does change the book.  A new translation will happen every time the book is loaded from disk.  Version on the disk is the master in English."

	true ifTrue: [^ self].	"turned off for now"

	guideBook allMorphsDo: [:mm |
		(mm isKindOf: TextMorph) ifTrue: [
			mm wrapFlag: true.	"want wrap to bounds" "What if user does not want this?"
			mm contents: mm contents string translated]].
]

{ #category : #'file in\/file out' }
QuickGuideHolderMorph >> unload [

	self submorphs size = 0 ifTrue: [^ self].
	(submorphs first isKindOf: BookMorph) ifTrue: [submorphs first deleteAlongWithPlayers].
	2 to: submorphs size do: [:s | submorphs last delete].

]
