Class {
	#name : #GeePrinter,
	#superclass : #Object,
	#instVars : [
		'pasteUp',
		'printSpecs',
		'geeMail',
		'computedBounds'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #'private - postscript canvases' }
GeePrinter >> allPages [

	| pageNumber allPages maxPages |

	maxPages := 9999.
	pageNumber := 0.
	allPages := self pageRectangles collect: [ :rect |
		pageNumber := pageNumber + 1.
		(self as: GeePrinterPage) pageNumber: pageNumber bounds: rect
	].
	allPages size > maxPages ifTrue: [allPages := allPages first: maxPages].
	allPages do: [ :each | each totalPages: allPages size].
	^allPages


]

{ #category : #geometry }
GeePrinter >> bounds [

	^computedBounds ifNil: [computedBounds := self computeBounds]
]

{ #category : #geometry }
GeePrinter >> computeBounds [

	| w ratio |

	w := pasteUp width.
	self printSpecs scaleToFitPage ifTrue: [
		^0@0 extent: w@(w * self hOverW) rounded.
	].
	ratio := 8.5 @ 11.
	self printSpecs landscapeFlag ifTrue: [
		ratio := ratio transposed
	].
	^0@0 extent: (ratio * 72) rounded
]

{ #category : #'postscript canvases' }
GeePrinter >> doPages [

	| dialog |
	(dialog := GeePrinterDialogMorph new) 
		printSpecs: self printSpecs 
		printBlock: [ :preview :specs |
			preview ifTrue: [self doPrintPreview] ifFalse: [self doPrintToPrinter]
		];
		fullBounds;
		position: Display extent - dialog extent // 2;
		openInWorld


]

{ #category : #'private - postscript canvases' }
GeePrinter >> doPrintPreview [

	| pageDisplay sz |

	sz := (85 @ 110) * 3.
	self printSpecs landscapeFlag ifTrue: [
		sz := sz transposed
	].
	pageDisplay := BookMorph new
		color: Color paleYellow;
		borderWidth: 1.
	self allPages withIndexDo: [ :each :index | | pic align newPage subBounds |
		pic := ImageMorph new image: (each pageThumbnailOfSize: sz).
		align := AlignmentMorph newColumn
			addMorph: pic;
			borderWidth: 1;
			layoutInset: 0;
			borderColor: Color blue.
		newPage := pageDisplay 
			insertPageLabel: 'Page ',index printString
			morphs: {align}.
		subBounds := newPage boundingBoxOfSubmorphs.
		newPage extent: subBounds corner - newPage topLeft + ((subBounds left - newPage left)@0).
	].
	pageDisplay 
		goToPage: 1;
		deletePageBasic;
		position: Display extent - pageDisplay extent // 2;
		openInWorld.

]

{ #category : #'postscript canvases' }
GeePrinter >> doPrintToPrinter [

	"fileName := ('gee.',Time millisecondClockValue printString,'.eps') asFileName."
	self pageRectangles.	"ensure bounds computed"
	DSCPostscriptCanvasToDisk 
		morphAsPostscript: self 
		rotated: self printSpecs landscapeFlag
		specs: self printSpecs

]

{ #category : #drawing }
GeePrinter >> drawOn: aCanvas [

	pasteUp drawOn: aCanvas


]

{ #category : #layout }
GeePrinter >> fullBounds [

	^self bounds
]

{ #category : #drawing }
GeePrinter >> fullDrawOn: aCanvas [

	pasteUp fullDrawOn: aCanvas


]

{ #category : #'postscript canvases' }
GeePrinter >> fullDrawPostscriptOn: aCanvas [

	aCanvas drawPages: self allPages.


]

{ #category : #accessing }
GeePrinter >> geeMail: aGeeMail [

	geeMail := aGeeMail
]

{ #category : #'private - postscript canvases' }
GeePrinter >> hOverW [

	^self printSpecs landscapeFlag ifTrue: [
		8.5 /  11.0
	] ifFalse: [
		11.0 / 8.5
	].

]

{ #category : #'private - postscript canvases' }
GeePrinter >> pageRectangles [

	| pageBounds allPageRects maxExtent |

	geeMail ifNotNil: [
		allPageRects := geeMail pageRectanglesForPrinting.
		allPageRects ifNotNil: [
			maxExtent := allPageRects inject: 0@0 into: [ :max :each |
				max max: each extent
			].
			computedBounds := 0@0 extent: maxExtent.
			^allPageRects
		].
	].
	pageBounds := self bounds.
	allPageRects := OrderedCollection new.
	[pageBounds top <= pasteUp bottom] whileTrue: [
		allPageRects add: pageBounds.
		pageBounds := pageBounds translateBy: 0 @ pageBounds height.
	].
	^allPageRects

]

{ #category : #printing }
GeePrinter >> pagesHandledAutomatically [

	^true
]

{ #category : #accessing }
GeePrinter >> pasteUp: x [

	pasteUp := x.
]

{ #category : #accessing }
GeePrinter >> printSpecs [

	^printSpecs ifNil: [printSpecs := PrintSpecifications defaultSpecs].

]

{ #category : #accessing }
GeePrinter >> printSpecs: aPrintSpecification [

	printSpecs := aPrintSpecification
]

{ #category : #rounding }
GeePrinter >> wantsRoundedCorners [

	^false
]
