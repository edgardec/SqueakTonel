Class {
	#name : #TextPrinter,
	#superclass : #Object,
	#instVars : [
		'form',
		'para',
		'paperSize',
		'landscape',
		'resolution',
		'depth',
		'offset',
		'columns',
		'docTitle',
		'noHeader',
		'noFooter'
	],
	#classVars : [
		'DefaultPaperSize',
		'DefaultTextPrinter'
	],
	#category : #'Graphics-Text'
}

{ #category : #accessing }
TextPrinter class >> defaultPaperSize [
	^DefaultPaperSize
]

{ #category : #accessing }
TextPrinter class >> defaultPaperSize: aPoint [
	DefaultPaperSize := aPoint
]

{ #category : #accessing }
TextPrinter class >> defaultTextPrinter [
	"This is the global default TextPrinter instance."
	DefaultTextPrinter isNil ifTrue: [DefaultTextPrinter := self new].
	^DefaultTextPrinter
]

{ #category : #'class initialization' }
TextPrinter class >> initialize [
	"TextPrinter initialize"
	self defaultPaperSize: self paperSizeA4.
]

{ #category : #'paper sizes' }
TextPrinter class >> mm2in: aPoint [
	"Convert aPoint from millimeters to inches"
	^aPoint / 25.4
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSize10x14 [
	^10.0@14.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSize11x17 [
	^11.0@17.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeA3 [
	^self mm2in: 297@420
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeA4 [
	^self mm2in: 210@297
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeA5 [
	^self mm2in: 148@210
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeB4 [
	^self mm2in: 250@354
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeB5 [
	^self mm2in: 182@257
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeCSheet [
	^17.0@22.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeDSheet [
	^22.0@34.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeESheet [
	^34.0@44.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelope10 [
	^4.125@9.5

]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelope11 [
	^4.5@10.375
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelope12 [
	^4.75@11
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelope14 [
	^5.0@11.5
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelope9 [
	^3.875@8.875
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelopeB4 [
	^self mm2in: 250@353
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelopeB5 [
	^self mm2in: 176@250
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelopeB6 [
	^self mm2in: 176@125
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelopeC3 [
	^self mm2in: 324@458
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelopeC4 [
	^self mm2in: 229@324
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelopeC5 [
	^self mm2in: 162@229
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelopeC6 [
	^self mm2in: 114@162
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeEnvelopeC65 [
	^self mm2in: 114@229
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeFanfoldGerman [
	"German standard fanfold"
	^8.5@12.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeFanfoldLegalGerman [
	"German legal fanfold"
	^8.5@13.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeFanfoldUS [
	"US standard fanfold"
	^14.875@11.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeFolio [
	^8.5@13.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeLegal [
	^8.5@14.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeLetter [
	^8.5@11.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeNote [
	^8.5@11.0
]

{ #category : #'paper sizes' }
TextPrinter class >> paperSizeTabloid [
	^11.0@17.0
]

{ #category : #accessing }
TextPrinter >> bestColor [
	"Set the reproduction quality to true color"
	depth := 32.
]

{ #category : #accessing }
TextPrinter >> blackAndWhite [
	"Set the reproduction quality to black and white"
	depth := 1.
]

{ #category : #formatting }
TextPrinter >> columnRect: n [
	"Return a rectangle describing the n-th column"
	| area left right |
	area := self textArea.
	left := area left + ((n-1) * self columnWidth).
	left := left + ((n-1) * self columnSkip).
	right := left + self columnWidth.
	^(self in2pix: left @ area top) corner: 
		(self in2pix: right @ area bottom)
]

{ #category : #formatting }
TextPrinter >> columnSkip [
	"Return the separating space between two columns in inches"
	^0.2
]

{ #category : #formatting }
TextPrinter >> columnWidth [
	^(self textWidth - ((self columns-1) * self columnSkip)) / self columns
]

{ #category : #accessing }
TextPrinter >> columns [
	^columns
]

{ #category : #accessing }
TextPrinter >> columns: aNumber [
	columns := aNumber asInteger max: 1.
]

{ #category : #initialize }
TextPrinter >> defaultPaperSize [
	"Return the default paper size (inches) for printing"
	^self class defaultPaperSize
]

{ #category : #initialize }
TextPrinter >> defaultResolution [
	"Return the default resolution (DPI) for printing"
	^TextStyle pixelsPerInch asPoint
]

{ #category : #accessing }
TextPrinter >> documentTitle [
	^docTitle
]

{ #category : #accessing }
TextPrinter >> documentTitle: aString [
	docTitle := aString
]

{ #category : #printing }
TextPrinter >> flushPage [
	"The current page has been set up. Send it to the printer."
	form primPrintHScale: self resolution x vScale: self resolution y landscape: self landscape.
	"Uncomment the following for testing"
	"form displayOn: Display. (Delay forSeconds: 5) wait."

]

{ #category : #footer }
TextPrinter >> footerHeight [
	"Return the (additional) height of the footer in inches."
	self noFooter ifTrue:[^0.0].
	^(self pix2in: 0@TextStyle default lineGrid) y * 2
]

{ #category : #footer }
TextPrinter >> footerParagraph [
	"Return a paragraph for the footer"
	| fPara rect paragraphClass |
	paragraphClass := Smalltalk at: #Paragraph
				ifAbsent: [^ self notify: 'MVC class Paragraph not present'].
	fPara := paragraphClass new.
	fPara destinationForm: form.
	rect := (self in2pix: self textArea bottomLeft) corner: 
				(self in2pix: self textArea bottomRight + (0.0@self footerHeight)).
	fPara clippingRectangle: rect.
	fPara compositionRectangle: rect.
	^fPara
]

{ #category : #formatting }
TextPrinter >> formatColumn: columnNum startingWith: anIndex [
	"Format a new column starting at the given string index. Return the string index indicating the start of the next column or nil if no more columns need printing."
	| colRect blk |
	colRect := self columnRect: columnNum.
	anIndex > 1 ifTrue:[para text: (para text copyFrom: anIndex to: para text size)].
	para compositionRectangle: colRect.
	para clippingRectangle: colRect.
	para composeAll.
	para displayOn: form.
	para visibleRectangle corner y <= colRect extent y ifTrue:[^nil].
	"More columns -- find the character block of the last line and adjust clip rect"
	blk := para characterBlockAtPoint: para visibleRectangle bottomLeft.
	para clearVisibleRectangle. "Make sure that the background is clean"
	para clippingRectangle: (colRect topLeft corner: colRect right@blk top).
	para displayOn: form.
	^blk stringIndex.
]

{ #category : #formatting }
TextPrinter >> formatPage: pageNum startingWith: anIndex [
	"Format a new page starting at the given string index. Return the string index indicating the start of the next page or nil if no more pages need printing."
	| nextIndex |
	nextIndex := anIndex.
	1 to: self columns do:[:i|
		nextIndex := self formatColumn: i startingWith: nextIndex.
		nextIndex isNil ifTrue:[^nil].
	].
	^nextIndex
]

{ #category : #accessing }
TextPrinter >> goodColor [
	"Set the reproduction quality to 8 bit color depth"
	depth := 8.
]

{ #category : #header }
TextPrinter >> headerHeight [
	"Return the (additional) height of the header in inches."
	self noHeader ifTrue:[^0.0].
	^(self pix2in: 0@TextStyle default lineGrid) y * 2
]

{ #category : #header }
TextPrinter >> headerParagraph [
	"Return a paragraph for the footer"
	| hPara rect paragraphClass |
	paragraphClass := Smalltalk at: #Paragraph
				ifAbsent: [^ self notify: 'MVC class Paragraph not present'].
	hPara := paragraphClass new.
	hPara destinationForm: form.
	rect := (self in2pix: self textArea topLeft - (0.0@self headerHeight)) corner: 
				(self in2pix: self textArea topRight).
	hPara clippingRectangle: rect.
	hPara compositionRectangle: rect.
	^hPara
]

{ #category : #other }
TextPrinter >> in2mm: aPoint [
	"Convert aPoint from millimeters to inches"
	^aPoint * 25.4
]

{ #category : #other }
TextPrinter >> in2pix: aPoint [
	"Convert aPoint from inches to actual pixels"
	^(aPoint * self resolution) rounded
]

{ #category : #initialize }
TextPrinter >> initialize [
	self paperSize: self defaultPaperSize.
	self resolution: self defaultResolution.
	self blackAndWhite.
	self landscape: false.
	self offsetRect: (1.0@1.0 corner: 1.0@1.0).
	self columns: 1.
	self noHeader: false.
	self noFooter: false.
	self documentTitle: 'Squeak Document (from ', Date today printString,')'.
]

{ #category : #accessing }
TextPrinter >> landscape [
	^landscape
]

{ #category : #accessing }
TextPrinter >> landscape: aBoolean [
	landscape := aBoolean
]

{ #category : #other }
TextPrinter >> mm2in: aPoint [
	"Convert aPoint from millimeters to inches"
	^aPoint / 25.4
]

{ #category : #other }
TextPrinter >> mm2pix: aPoint [
	"Convert aPoint from millimeters to actual pixels"
	^self in2pix: (self mm2in: aPoint)
]

{ #category : #accessing }
TextPrinter >> noFooter [
	^noFooter
]

{ #category : #accessing }
TextPrinter >> noFooter: aBoolean [
	"Turn off footer printing"
	noFooter := aBoolean.
]

{ #category : #accessing }
TextPrinter >> noHeader [
	^noHeader
]

{ #category : #accessing }
TextPrinter >> noHeader: aBoolean [
	"Turn off header printing"
	noHeader := aBoolean.
]

{ #category : #accessing }
TextPrinter >> offsetRect [
	^offset
]

{ #category : #accessing }
TextPrinter >> offsetRect: aRectangle [
	"Set the offset rectangle"
	offset := aRectangle
]

{ #category : #accessing }
TextPrinter >> paperSize [
	^paperSize
]

{ #category : #accessing }
TextPrinter >> paperSize: aPoint [
	paperSize := aPoint
]

{ #category : #other }
TextPrinter >> pix2in: aPoint [
	"Convert aPoint from a pixel value to inches"
	^aPoint / self resolution
]

{ #category : #other }
TextPrinter >> pix2mm: aPoint [
	"Convert aPoint from a pixel value to millimeters"
	^self in2mm: (self pix2in: aPoint)
]

{ #category : #private }
TextPrinter >> pixelSize [
	"Return the size of the page in pixels"
	^self in2pix: (self realPaperSize)
]

{ #category : #footer }
TextPrinter >> printFooter: pageNumber [
	"Print the footer for the given page number"
	| fPara |
	self noFooter ifTrue:[^self].
	fPara := self footerParagraph.
	fPara centered.
	fPara text: ('Page ', pageNumber printString) asText.
	fPara displayOn: form.
]

{ #category : #header }
TextPrinter >> printHeader: pageNumber [
	"Print the header for the given page number"
	| fPara |
	self noHeader ifTrue:[^self].
	fPara := self headerParagraph.
	fPara centered.
	fPara text: self documentTitle asText.
	fPara displayOn: form.
]

{ #category : #printing }
TextPrinter >> printParagraph [
	| pageNum nextIndex |
	para destinationForm: form.
	pageNum := 1.
	nextIndex := 1.
	[form fillColor: Color white.
	self printHeader: pageNum.
	self printFooter: pageNum.
	nextIndex := self formatPage: pageNum startingWith: nextIndex.
	self flushPage.
	nextIndex isNil] whileFalse:[pageNum := pageNum + 1].
]

{ #category : #printing }
TextPrinter >> printText: aText [
	"Print aText"
	| paragraphClass |
	form isNil ifTrue:[
		form := Form extent: self pixelSize depth: depth.
	].
	paragraphClass := Smalltalk at: #Paragraph
				ifAbsent: [^ self notify: 'MVC class Paragraph not present'].
	para := paragraphClass withText: aText asText.
	Cursor wait showWhile:[
		self printParagraph.
	].
]

{ #category : #private }
TextPrinter >> realPaperSize [
	^self landscape
		ifTrue:[self paperSize y @ self paperSize x]
		ifFalse:[self paperSize]
]

{ #category : #accessing }
TextPrinter >> resolution [
	^resolution
]

{ #category : #accessing }
TextPrinter >> resolution: aPoint [
	resolution := aPoint
]

{ #category : #formatting }
TextPrinter >> textArea [
	^(self offsetRect origin + (0.0@self headerHeight)) corner:
		(self realPaperSize - self offsetRect corner - (0.0@self footerHeight))
]

{ #category : #formatting }
TextPrinter >> textWidth [
	^self textArea extent x
]
