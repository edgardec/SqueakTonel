Class {
	#name : #GeePrinterPage,
	#superclass : #GeePrinter,
	#instVars : [
		'pageNumber',
		'bounds',
		'totalPages'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #'postscript canvases' }
GeePrinterPage >> fullDrawPostscriptOn: aCanvas [

	| s |
	s := TextMorph new 
		beAllFont: (TextStyle default fontOfSize: 30);
		contentsAsIs: '   Drawing page ',pageNumber printString,' of ',totalPages printString,'     '.
	s layoutChanged; fullBounds.
	s := AlignmentMorph newRow
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		addMorph: s;
		color: Color yellow.
	s position: Display center - (s width // 2 @ 0).
	Project current world addMorphFront: s;
		displayWorld.
	printSpecs drawAsBitmapFlag ifTrue: [
		aCanvas paintImage: self pageAsForm at: 0@0
	] ifFalse: [
		aCanvas 
			translateTo: bounds origin negated 
			clippingTo: (0@0 extent: bounds extent) 
			during: [ :c |
				pasteUp fullDrawForPrintingOn: c
			].
	].
	s delete.


]

{ #category : #'private - postscript canvases' }
GeePrinterPage >> pageAsForm [

	| f canvas |
	f := Form extent: bounds extent depth: 16.
	canvas := f getCanvas.
	canvas fillColor: pasteUp color.
	canvas translateTo: bounds origin negated clippingTo: f boundingBox during: [ :c |
		pasteUp fullDrawForPrintingOn: c
	].
	^f


]

{ #category : #'private - accessing' }
GeePrinterPage >> pageNumber: anInteger bounds: aRect [

	pageNumber := anInteger.
	bounds := aRect.
]

{ #category : #'private - postscript canvases' }
GeePrinterPage >> pageThumbnailOfSize: aPoint [

	^self pageAsForm scaledToSize: aPoint


]

{ #category : #'private - accessing' }
GeePrinterPage >> totalPages: x [

	totalPages := x
]
