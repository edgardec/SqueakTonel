Class {
	#name : #GeePrinterDialogMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'printSpecs',
		'printBlock'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #'new-morph participation' }
GeePrinterDialogMorph class >> includeInNewMorphMenu [

	^ false
]

{ #category : #'user interface - constants' }
GeePrinterDialogMorph >> buttonColor [

	^color darker
]

{ #category : #private }
GeePrinterDialogMorph >> buttonNamed: aString action: aSymbol color: aColor help: helpString [ 
	| f col |
	f := SimpleButtonMorph new target: self;
				 label: aString;
				 color: aColor;
				 borderColor: aColor muchDarker;
				 actionSelector: aSymbol;
				 setBalloonText: helpString.
	col := self inAColumn: {f}.
	col hResizing: #shrinkWrap.
	^ col
]

{ #category : #'user interface' }
GeePrinterDialogMorph >> cancelButton [
	^ self
		buttonNamed: 'Cancel'
		action: #doCancel
		color: Color lightRed
		help: 'Cancel this printing operation.'
]

{ #category : #initialization }
GeePrinterDialogMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ self color darker
]

{ #category : #initialization }
GeePrinterDialogMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 8
]

{ #category : #initialization }
GeePrinterDialogMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color paleYellow
]

{ #category : #'user interface' }
GeePrinterDialogMorph >> doCancel [

	self delete
]

{ #category : #'user interface' }
GeePrinterDialogMorph >> doPreview [

	self delete.
	printBlock value: true value: printSpecs.
]

{ #category : #'user interface' }
GeePrinterDialogMorph >> doPrint [

	self delete.
	printBlock value: false value: printSpecs.
]

{ #category : #'user interface' }
GeePrinterDialogMorph >> getChoice: aSymbol [

	aSymbol == #landscapeFlag ifTrue: [^printSpecs landscapeFlag].
	aSymbol == #drawAsBitmapFlag ifTrue: [^printSpecs drawAsBitmapFlag].
	aSymbol == #scaleToFitPage ifTrue: [^printSpecs scaleToFitPage].

]

{ #category : #initialization }
GeePrinterDialogMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self vResizing: #shrinkWrap;
		 hResizing: #shrinkWrap;
		 layoutInset: 4;
		 useRoundedCorners.
	printSpecs
		ifNil: [printSpecs := PrintSpecifications defaultSpecs].
	self rebuild 
]

{ #category : #'user interface' }
GeePrinterDialogMorph >> previewButton [

	^self
		buttonNamed: 'Preview' 
		action: #doPreview 
		color: self buttonColor 
		help: 'Show a preview of the pages that will be printed on the screen.'
]

{ #category : #'user interface' }
GeePrinterDialogMorph >> printButton [

	^self
		buttonNamed: 'Print' 
		action: #doPrint 
		color: self buttonColor 
		help: 'Print me (a PostScript file will be created)'
]

{ #category : #accessing }
GeePrinterDialogMorph >> printSpecs: aPrintSpecification printBlock: aTwoArgBlock [

	printSpecs := aPrintSpecification.
	printBlock := aTwoArgBlock.
]

{ #category : #private }
GeePrinterDialogMorph >> rebuild [

	self removeAllMorphs.
	self addARow: {
		(StringMorph contents: 'PostScript Printing Options') lock.
	}.
	self addARow: {
		self
			simpleToggleButtonFor: self
			attribute: #landscapeFlag
			help: 'Print in landscape mode'.
		(StringMorph contents: ' Landscape') lock.
	}.
	self addARow: {
		self
			simpleToggleButtonFor: self
			attribute: #drawAsBitmapFlag
			help: 'Print as a bitmap'.
		(StringMorph contents: ' Bitmap') lock.
	}.
	self addARow: {
		self
			simpleToggleButtonFor: self
			attribute: #scaleToFitPage
			help: 'Scale printing to fill page'.
		(StringMorph contents: ' Scale to fit') lock.
	}.


	self addARow: {
		self printButton.
		self previewButton.
		self cancelButton.
	}.
]

{ #category : #'user interface' }
GeePrinterDialogMorph >> toggleChoice: aSymbol [

	aSymbol == #landscapeFlag ifTrue: [
		printSpecs landscapeFlag: printSpecs landscapeFlag not
	].
	aSymbol == #drawAsBitmapFlag ifTrue: [
		printSpecs drawAsBitmapFlag: printSpecs drawAsBitmapFlag not
	].
	aSymbol == #scaleToFitPage ifTrue: [
		printSpecs scaleToFitPage: printSpecs scaleToFitPage not
	].

]
