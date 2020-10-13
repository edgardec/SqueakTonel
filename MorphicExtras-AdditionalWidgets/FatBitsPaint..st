"
Extensions to FatBitsPaint

With the goal of making FatBitsPaint a fairly nifty Form fixer-upper in the Squeak/morphic environment, I have started this set of extensions. It will probably be updated as the mood strikes, so keep an eye out for new versions.

First, some basic operating instructions:

Get a Form and send it the message #morphEdit. To get started, you can try:

        (Form fromUser) morphEdit

And there is the form in all its glory. Control click on the form to get theFatBitsPaint menu and choose the ""keep this menu up"" item. This will be your main tool/command palette. With it you can:
¥ Change the magnification
¥ Change the brush size (in original scale pixels)
¥ Change the brush color (via a ColorPickerMorph)

Now to some of the enhancements:

(25 September 1999 2:38:25 pm )

¥ ColorPickerMorphs now have a label below that indicates their use (you might have more than one open)
¥ A quirk that could get the brush size out of alignment with the pixel size is fixed.
¥ A background has been added so that you can see the full extent of the Form and so that you can observe the effect of translucent pixels in the form.
¥ A menu item has been added to change the background color so that you can simulate the real environment the form will be displayed in.
¥ The magnification and brush size menus now highlight their current value.
¥ An inspect option has been added to the menu so that you can do arbitrary things to the form.
¥ A file out option has been added to write the form to a file.

(25 September 1999 10:02:13 pm ) 

¥ New menu item: Tools allows you to choose between (for now) Paint Brush (all there was before) and Selections. Selections allows you to select rectangular regions of the form where the next menu takes over.
¥ New menu item: Selections gives you choices:
        ¥ edit separately - opens a new editor on the selected rectangle. Useful for cropping.
        ¥ copy - copies the selection rectangle to a clipboard. Can be pasted to this or another FatBitsPaint.
        ¥ cut - does a copy and clears the selection to transparent.
        ¥ paste - paints the contents of the clipboard over the current selection. Only the starting point of the selection matters - the extent is controlled by the clipboard.


"
Class {
	#name : #FatBitsPaint,
	#superclass : #SketchMorph,
	#instVars : [
		'formToEdit',
		'magnification',
		'brush',
		'brushSize',
		'brushColor',
		'lastMouse',
		'currentTools',
		'currentSelectionMorph',
		'selectionAnchor',
		'backgroundColor'
	],
	#classVars : [
		'FormClipboard'
	],
	#category : #'MorphicExtras-AdditionalWidgets'
}

{ #category : #menu }
FatBitsPaint >> accept [
	| f |
	f := self unmagnifiedForm.
	f boundingBox = formToEdit boundingBox
		ifFalse: [^ self error: 'implementation error; form dimensions should match'].
	f displayOn: formToEdit.  "modify formToEdit in place"
]

{ #category : #menu }
FatBitsPaint >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

        super addCustomMenuItems: aCustomMenu hand: aHandMorph.
        aCustomMenu 
                add: 'background color' translated action: #setBackgroundColor:;
                add: 'pen color' translated action: #setPenColor:;
                add: 'pen size' translated action: #setPenSize:;
                add: 'fill' translated action: #fill;
                add: 'magnification' translated action: #setMagnification:;
                add: 'accept' translated action: #accept;
                add: 'revert' translated action: #revert;
                add: 'inspect' translated action: #inspectForm;
                add: 'file out' translated action: #fileOut;
                add: 'selection...' translated action: #selectionMenu:;
                add: 'tools...' translated action: #toolMenu:
]

{ #category : #menu }
FatBitsPaint >> backgroundColor: aColor [

        backgroundColor := aColor.
        self changed
]

{ #category : #menu }
FatBitsPaint >> brushColor: aColor [

	brushColor := aColor.
	brush color: aColor.

]

{ #category : #'geometry testing' }
FatBitsPaint >> containsPoint: aPoint [

        ^ self bounds containsPoint: aPoint     "even if we are transparent"

]

{ #category : #menu }
FatBitsPaint >> copySelection [

        | relativeBounds scaledBounds |
        currentSelectionMorph ifNil: [^ nil].
        relativeBounds := currentSelectionMorph bounds translateBy: self position negated.
        scaledBounds := relativeBounds scaleBy: 1 / magnification.
        FormClipboard := (self unmagnifiedForm copy: scaledBounds).
        ^ relativeBounds
]

{ #category : #menu }
FatBitsPaint >> cutSelection [

        | relativeBounds |
        relativeBounds := self copySelection ifNil: [^ nil].
        originalForm fill: relativeBounds rule: Form over fillColor: Color transparent.
        self revealPenStrokes
]

{ #category : #initialization }
FatBitsPaint >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color veryVeryLightGray
]

{ #category : #drawing }
FatBitsPaint >> drawOn: aCanvas [
	| f |
	f := self rotatedForm.
	backgroundColor ifNotNil: [aCanvas fillRectangle: bounds fillStyle: backgroundColor].
	aCanvas translucentImage: f at: bounds origin.
]

{ #category : #initialization }
FatBitsPaint >> editForm: aForm [

        formToEdit := aForm.
        brushSize := magnification := 64 // (aForm height min: aForm width) max: 4.
        self revert
]

{ #category : #menu }
FatBitsPaint >> editSelection [

       FatBitsPaint new openWith: (self selectionAsForm ifNil: [^ nil])
]

{ #category : #menu }
FatBitsPaint >> fileOut [

        | fileName |

	fileName := FileSaverDialog openOn: FileDirectory default.
	fileName ifNil: [^Beeper beep].
	
 	Cursor normal showWhile:  [self unmagnifiedForm writeOnFileNamed: fileName]
]

{ #category : #menu }
FatBitsPaint >> fill [

	| fillPt |
	Cursor blank show.
	fillPt := Cursor crossHair showWhile:
		[Sensor waitButton - self position].
	originalForm shapeFill: brushColor interiorPoint: fillPt.
	self changed.

]

{ #category : #'event handling' }
FatBitsPaint >> handlesMouseDown: evt [

	^ true

]

{ #category : #initialization }
FatBitsPaint >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self setCurrentToolTo: self toolsForPaintBrush.
	formToEdit := Form extent: 50 @ 40 depth: 8.
	formToEdit fill: formToEdit boundingBox fillColor: Color veryVeryLightGray.
	brushSize := magnification := 4.
	
	brushColor := Color red.
	backgroundColor := Color white.
	self revert
]

{ #category : #menu }
FatBitsPaint >> inspectForm [

        self unmagnifiedForm inspect
]

{ #category : #menu }
FatBitsPaint >> magnification: aNumber [

        | oldPenSize oldForm |
        oldPenSize := brushSize / magnification.
        oldForm := self unmagnifiedForm.
        magnification := aNumber asInteger max: 1.
        self form: (oldForm magnify: oldForm boundingBox by: magnification).
        brush := Pen newOnForm: originalForm.
        self penSize: oldPenSize.
        brush color: brushColor
]

{ #category : #'event handling' }
FatBitsPaint >> mouseDown: evt [

        ^ self
                perform: (currentTools at: #mouseDown: ifAbsent: [^nil])
                with: evt
]

{ #category : #events }
FatBitsPaint >> mouseDownDefault: evt [
	lastMouse := nil.
	formToEdit depth = 1 ifTrue:
		[self brushColor: (originalForm colorAt: (self pointGriddedFromEvent: evt)) negated]
]

{ #category : #events }
FatBitsPaint >> mouseDownSelection: evt [

        lastMouse := nil.
        currentSelectionMorph ifNotNil: [currentSelectionMorph delete. currentSelectionMorph := nil].
        selectionAnchor := self pointGriddedFromEvent: evt
]

{ #category : #'event handling' }
FatBitsPaint >> mouseMove: evt [

        ^ self
                perform: (currentTools at: #mouseMove: ifAbsent: [^nil])
                with: evt
]

{ #category : #events }
FatBitsPaint >> mouseMovePaintBrushMode: evt [

        | p p2 |
        p := self pointGriddedFromEvent: evt.
        lastMouse = p ifTrue: [^ self].
        lastMouse ifNil: [lastMouse := p].  "first point in a stroke"
        "draw etch-a-sketch style-first horizontal, then vertical"
        p2 := p x@lastMouse y.
        brush drawFrom: lastMouse to: p2.
        brush drawFrom: p2 to: p.
                        
        self revealPenStrokes.
        lastMouse := p
]

{ #category : #menu }
FatBitsPaint >> mouseMoveSelectionMode: evt [

        | p |
        p := self pointGriddedFromEvent: evt.
        lastMouse = p ifTrue: [^ self].

        currentSelectionMorph ifNil:
                [currentSelectionMorph := MarqueeMorph new 
                        color: Color transparent;
                        borderWidth: 2;
                        lock.
                self addMorphFront: currentSelectionMorph.
                currentSelectionMorph startStepping].
        currentSelectionMorph 
                bounds: ((Rectangle encompassing: {p. selectionAnchor}) translateBy: self position).

        lastMouse := p
]

{ #category : #initialization }
FatBitsPaint >> openWith: aForm [

        self editForm: aForm; openInWorld
]

{ #category : #menu }
FatBitsPaint >> pasteSelection [

        | relativeBounds tempForm |
        currentSelectionMorph ifNil: [^ nil].
        FormClipboard ifNil: [^nil].
        relativeBounds := currentSelectionMorph bounds translateBy: self position negated.
        tempForm := (FormClipboard magnify: FormClipboard boundingBox by: magnification).
        self form
                copy: (relativeBounds origin extent: tempForm boundingBox extent)
                from: 0@0
                in: tempForm
                rule: Form over. 
        self revealPenStrokes
]

{ #category : #menu }
FatBitsPaint >> penSize: aNumber [

	brushSize := (aNumber * magnification) asInteger.
	brush squareNib: brushSize.

]

{ #category : #events }
FatBitsPaint >> pointGriddedFromEvent: evt [

	| relativePt |
	relativePt := evt cursorPoint - self position.
	^ (relativePt x truncateTo: magnification)@(relativePt y truncateTo: magnification)

]

{ #category : #menu }
FatBitsPaint >> revert [
"since WarpBits may mangle an 8-bit ColorForm, make it 32 first"
        self form: ((formToEdit asFormOfDepth: 32) 
                magnify: formToEdit boundingBox 
                by: magnification 
                smoothing: 1).
        brush := Pen newOnForm: originalForm.
        brush squareNib: brushSize.
        brush color: brushColor
]

{ #category : #menu }
FatBitsPaint >> selectionAsForm [

        | relativeBounds scaledBounds |
        currentSelectionMorph ifNil: [^nil].
        relativeBounds := currentSelectionMorph bounds translateBy: self position negated.
        scaledBounds := relativeBounds scaleBy: 1 / magnification.
        ^ self unmagnifiedForm copy: scaledBounds
]

{ #category : #menu }
FatBitsPaint >> selectionMenu: evt [

        | menu |
 
        (menu := MenuMorph new)
                addTitle: 'Edit';
                addStayUpItem.

        {
                {'edit separately'. #editSelection}.
                {'copy'. #copySelection}.
                {'cut'. #cutSelection}.
                {'paste'. #pasteSelection}
        } do: [:each |
                menu add: each first
                        target: self
                        selector: each second
                        argumentList: #()].
        menu toggleStayUp: evt.
        menu popUpEvent: evt in: self world
]

{ #category : #menu }
FatBitsPaint >> setBackgroundColor: evt [

	self
		changeColorTarget: self 
		selector: #backgroundColor: 
		originalColor: backgroundColor
		hand: evt hand
]

{ #category : #initialization }
FatBitsPaint >> setCurrentToolTo: aDictionary [

        currentTools := aDictionary.
        currentSelectionMorph ifNotNil: [currentSelectionMorph delete. currentSelectionMorph := nil]
]

{ #category : #menu }
FatBitsPaint >> setMagnification: evt [
	| menu |
	menu := MenuMorph new.
	((1 to: 8), #(16 24 32)) do: [:w |
		menu add: w printString
			target: self
			selector: #magnification:
			argumentList: (Array with: w).
		magnification = w ifTrue: [menu lastSubmorph color: Color red]].
	menu popUpEvent: evt in: self world
]

{ #category : #menu }
FatBitsPaint >> setPenColor: evt [

	self changeColorTarget: self selector: #brushColor: originalColor: brushColor hand: evt hand.
]

{ #category : #menu }
FatBitsPaint >> setPenSize: evt [
	| menu sizes |
 
	menu := MenuMorph new.
	sizes := (1 to: 5), (6 to: 12 by: 2), (15 to: 40 by: 5).
	sizes do: [:w |
		menu add: w printString
			target: self
			selector: #penSize:
			argumentList: (Array with: w).
		(brushSize // magnification) = w ifTrue: [menu lastSubmorph color: Color red]].
	menu popUpEvent: evt in: self world
]

{ #category : #events }
FatBitsPaint >> toolMenu: evt [
	| menu |
	menu := MenuMorph new.
	menu
		addTitle: 'Tools';
		addStayUpItem.
	{
		{'paint brush'. self toolsForPaintBrush}.
		{'selections'. self toolsForSelection}
	} do: [:each |
		menu add: each first
			target: self
			selector: #setCurrentToolTo:
			argumentList: {each second}].
	menu toggleStayUp: evt.
	menu popUpEvent: evt in: self world
]

{ #category : #initialization }
FatBitsPaint >> toolsForPaintBrush [

        ^Dictionary new
                at: #mouseMove: put: #mouseMovePaintBrushMode:;
                at: #mouseDown: put: #mouseDownDefault:;
                yourself
]

{ #category : #initialization }
FatBitsPaint >> toolsForSelection [

        ^ Dictionary new
                at: #mouseMove: put: #mouseMoveSelectionMode:;
                at: #mouseDown: put: #mouseDownSelection:;
                yourself
]

{ #category : #menu }
FatBitsPaint >> unmagnifiedForm [

        ^ self form shrink: self form boundingBox by: magnification
]
