"
A rectangular array of pixels, used for holding images.  All pictures, including character images are Forms.  The depth of a Form is how many bits are used to specify the color at each pixel.  The actual bits are held in a Bitmap, whose internal structure is different at each depth.  Class Color allows you to deal with colors without knowing how they are actually encoded inside a Bitmap.
	  The supported depths (in bits) are 1, 2, 4, 8, 16, and 32.  The number of actual colors at these depths are: 2, 4, 16, 256, 32768, and 16 million.
	Forms are indexed starting at 0 instead of 1; thus, the top-left pixel of a Form has coordinates 0@0.
	Forms are combined using BitBlt.  See the comment in class BitBlt.  Forms that repeat many times to fill a large destination are InfiniteForms.

	colorAt: x@y		Returns the abstract Color at this location
	displayAt: x@y		shows this form on the screen
	displayOn: aMedium at: x@y	shows this form in a Window, a Form, or other DisplayMedium
	fillColor: aColor		Set all the pixels to the color.
	edit		launch an editor to change the bits of this form.
	pixelValueAt: x@y	The encoded color.  The encoding depends on the depth.

Note: If you want to hook up other external forms/displayScreens, please look at the (successful) Graphics-External package in http://www.squeaksource.com/Balloon3D.
"
Class {
	#name : #Form,
	#superclass : #DisplayMedium,
	#instVars : [
		'bits',
		'width',
		'height',
		'depth',
		'offset'
	],
	#category : #'Graphics-Display Objects'
}

{ #category : #'file list services' }
Form class >> allTypicalFileExtensions [

	^ImageReadWriter allTypicalFileExtensions add: 'form'; yourself
]

{ #category : #'mode constants' }
Form class >> and [
	"Answer the integer denoting the logical 'and' combination rule."

	^1
]

{ #category : #'mode constants' }
Form class >> blend [
	"Answer the integer denoting BitBlt's alpha blend combination rule."
	^24
]

{ #category : #'mode constants' }
Form class >> blendAlpha [
	"Answer the integer denoting BitBlt's blend-with-constant-alpha rule."

	^ 30
]

{ #category : #'mode constants' }
Form class >> blendAlphaScaled [
	"Answer the integer denoting BitBlt's blend-with-alpha-scaled rule."

	^ 34
]

{ #category : #'mode constants' }
Form class >> compareMatchColor [
	"The primCompare test id values are
	compareMatchColors -> 0
	compareNotColorANotColorB -> 1
	compareNotColorAMatchColorB -> 2"
	^0
]

{ #category : #'mode constants' }
Form class >> compareNotColorAMatchColorB [
	"The primCompare test id values are
	compareMatchColors -> 0
	compareNotColorANotColorB -> 1
	compareNotColorAMatchColorB -> 2"
	^2
]

{ #category : #'mode constants' }
Form class >> compareNotColorANotColorB [
	"The primCompare test id values are
	compareMatchColors -> 0
	compareNotColorANotColorB -> 1
	compareNotColorAMatchColorB -> 2"
	^1
]

{ #category : #'mode constants' }
Form class >> compareTallyFlag [
	"The primCompare test id values are ORR'd with 8 to indicate tallying rather than simply reporting the first hit"
	^8
]

{ #category : #'instance creation' }
Form class >> dotOfSize: diameter [
	"Create a form which contains a round black dot."
	| radius form bb rect centerX centerY centerYBias centerXBias radiusSquared xOverY maxy dx |
	radius := diameter//2.
	form := self extent: diameter@diameter offset: (0@0) - (radius@radius).	
	bb := (BitBlt toForm: form)
		sourceX: 0; sourceY: 0;
		combinationRule: Form over;
		fillColor: Color black.
	rect := form boundingBox.
	centerX := rect center x.
	centerY := rect center y.
	centerYBias := rect height odd ifTrue: [0] ifFalse: [1].
	centerXBias := rect width odd ifTrue: [0] ifFalse: [1].
	radiusSquared := (rect height asFloat / 2.0) squared - 0.01.
	xOverY := rect width asFloat / rect height asFloat.
	maxy := rect height - 1 // 2.

	"First do the inner fill, and collect x values"
	0 to: maxy do:
		[:dy |
		dx := ((radiusSquared - (dy * dy) asFloat) sqrt * xOverY) truncated.
		bb	destX: centerX - centerXBias - dx
			destY: centerY - centerYBias - dy
			width: dx + dx + centerXBias + 1
			height: 1;
			copyBits.
		bb	destY: centerY + dy;
			copyBits].
	^ form
"
Time millisecondsToRun:
	[1 to: 20 do: [:i | (Form dotOfSize: i) displayAt: (i*20)@(i*20)]]
"
]

{ #category : #examples }
Form class >> dotOfSize: diameter color: color [

	| form |
	form := self extent: diameter asPoint depth: Display depth.
	form getCanvas fillOval: form boundingBox color: color.
	^form
]

{ #category : #'mode constants' }
Form class >> erase [
	"Answer the integer denoting mode erase."

	^4
]

{ #category : #'mode constants' }
Form class >> erase1bitShape [
	"Answer the integer denoting mode erase."

	^ 26
]

{ #category : #examples }
Form class >> exampleBorder [    "Form exampleBorder"
	"This example demonstrates the border finding algorithm. Start
	by having the user sketch on the screen (end with option-click) and then select a rectangular
	area of the screen which includes all of the area to be filled. Finally,
	(with crosshair cursor), the user points at the interior of the region to be
	outlined, and the region begins with that place as its seed."
	| f r interiorPoint |
	Form exampleSketch.		"sketch a little area with an enclosed region"
	r := Rectangle fromUser.
	f := Form fromDisplay: r.
	interiorPoint := Cursor crossHair showWhile:
		[Sensor waitButton - r origin].
	Cursor execute showWhile:
		[f shapeBorder: Color blue width: 2 interiorPoint: interiorPoint
			sharpCorners: false internal: false].
	f displayOn: Display at: r origin	
]

{ #category : #examples }
Form class >> exampleEdits [
	"In Form category editing are messages edit and bitEdit that make it possible to 
	create editors on instances of Form. 
	 
	This is the general form editor:
	| f | 
	f := Form fromUser. 
	f edit. 
	 
	This is the general bit editor:
	| f | 
	f := Form fromUser. 
	f bitEdit."
]

{ #category : #examples }
Form class >> exampleMagnify [

	| f m |
	f := Form fromUser.
	m := f magnify: f boundingBox by: 5 @ 5.
	m displayOn: Display at: Sensor waitButton

	"Form exampleMagnify."
]

{ #category : #examples }
Form class >> exampleShrink [

	| f s |
	f := Form fromUser.
	s := f shrink: f boundingBox by: 2 @ 5.
	s displayOn: Display at: Sensor waitButton	

	"Form exampleShrink."
]

{ #category : #examples }
Form class >> exampleSketch [
	"This is a simple drawing algorithm to get a sketch on the display screen.
	Draws whenever mouse button down.  Ends with option-click."
	| aPen color |
	aPen := Pen new.
	color := 0.
	[Sensor yellowButtonPressed]
		whileFalse:
		[aPen place: Sensor cursorPoint; color: (color := color + 1).
		[Sensor redButtonPressed]
			whileTrue: [aPen goto: Sensor cursorPoint]].
	Sensor waitNoButton.

	"Form exampleSketch"
]

{ #category : #examples }
Form class >> exampleSpaceFill [    "Form exampleSpaceFill"
	"This example demonstrates the area filling algorithm. Starts by having
	the user sketch on the screen (ended by option-click) and then select a rectangular
	area of the screen which includes all of the area to be filled. Finally,
	(with crosshair cursor), the user points at the interior of some region to be
	filled, and the filling begins with that place as its seed."
	| f r interiorPoint |
	Form exampleSketch.		"sketch a little area with an enclosed region"
	r := Rectangle fromUser.
	f := Form fromDisplay: r.
	interiorPoint := Cursor crossHair showWhile:
		[Sensor waitButton - r origin].
	Cursor execute showWhile:
		[f shapeFill: Color gray interiorPoint: interiorPoint].
	f displayOn: Display at: r origin	
]

{ #category : #'instance creation' }
Form class >> extent: extentPoint [
	"Answer an instance of me with a blank bitmap of depth 1."

	^ self extent: extentPoint depth: 1

]

{ #category : #'instance creation' }
Form class >> extent: extentPoint depth: bitsPerPixel [
	"Answer an instance of me with blank bitmap of the given dimensions and depth."

	^ self basicNew setExtent: extentPoint depth: bitsPerPixel

]

{ #category : #'instance creation' }
Form class >> extent: extentPoint depth: bitsPerPixel bits: aBitmap [
	"Answer an instance of me with blank bitmap of the given dimensions and depth."

	^ self basicNew setExtent: extentPoint depth: bitsPerPixel bits: aBitmap
]

{ #category : #'instance creation' }
Form class >> extent: extentPoint depth: bitsPerPixel fromArray: anArray offset: offsetPoint [ 
	"Answer an instance of me with a pixmap of the given depth initialized from anArray."

	^ (self extent: extentPoint depth: bitsPerPixel)
		offset: offsetPoint;
		initFromArray: anArray

]

{ #category : #'instance creation' }
Form class >> extent: extentPoint fromArray: anArray offset: offsetPoint [ 
	"Answer an instance of me of depth 1 with bitmap initialized from anArray."

	^ (self extent: extentPoint depth: 1)
		offset: offsetPoint;
		initFromArray: anArray

]

{ #category : #'instance creation' }
Form class >> extent: extentPoint fromStipple: fourNibbles [
	"Answer an instance of me with bitmap initialized from
	a repeating 4x4 bit stipple encoded in a 16-bit constant."
	
	^ (self extent: extentPoint depth: 1)
		initFromArray: ((1 to: 4) collect:
				[:i | | nibble |
				nibble := (fourNibbles bitShift: -4*(4-i)) bitAnd: 16rF.
				16r11111111 * nibble])  "fill 32 bits with each 4-bit nibble"

]

{ #category : #'instance creation' }
Form class >> extent: extentPoint offset: offsetPoint [ 
	"Answer an instance of me with a blank bitmap of depth 1."

	^ (self extent: extentPoint depth: 1) offset: offsetPoint

]

{ #category : #'file list services' }
Form class >> fileReaderServicesForDirectory: aFileDirectory [
	^{
		self serviceImageImportDirectory.
		self serviceImageImportDirectoryWithSubdirectories.
	}
]

{ #category : #'file list services' }
Form class >> fileReaderServicesForFile: fullName suffix: suffix [

	^(self  allTypicalFileExtensions 
		includes: suffix)
		ifTrue: [ self services ]
		ifFalse: [#()]

]

{ #category : #'BMP file reading' }
Form class >> fromBMPFile: aBinaryStream [
	"Obsolete"
	^self fromBinaryStream: aBinaryStream.
]

{ #category : #'BMP file reading' }
Form class >> fromBMPFileNamed: fileName [
	"Obsolete"
	^self fromFileNamed: fileName

]

{ #category : #'instance creation' }
Form class >> fromBinaryStream: aBinaryStream [
	"Read a Form or ColorForm from given file, using the first byte of the file to guess its format. Currently handles: GIF, uncompressed BMP, and both old and new DisplayObject writeOn: formats, JPEG, and PCX. Return nil if the file could not be read or was of an unrecognized format."

	| firstByte |
	aBinaryStream binary.
	firstByte := aBinaryStream next.
	firstByte = 1 ifTrue: [
		"old Squeakform format"
		^ self new readFromOldFormat: aBinaryStream].
	firstByte = 2 ifTrue: [
		"new Squeak form format"
		^ self new readFrom: aBinaryStream].

	"Try for JPG, GIF, or PCX..."
	"Note: The following call closes the stream."
	^ ImageReadWriter formFromStream: aBinaryStream

]

{ #category : #'instance creation' }
Form class >> fromDisplay: aRectangle [ 
	"Answer an instance of me with bitmap initialized from the area of the 
	display screen defined by aRectangle."

	^ (self extent: aRectangle extent depth: Display depth)
		fromDisplay: aRectangle
]

{ #category : #'instance creation' }
Form class >> fromDisplay: aRectangle using: oldForm [
	"Like fromDisplay: only if oldForm is the right size, copy into it and answer it instead."

	((oldForm ~~ nil) and: [oldForm extent = aRectangle extent])
		ifTrue:
			[oldForm fromDisplay: aRectangle.
			 ^ oldForm]
		ifFalse:
			[^ self fromDisplay: aRectangle]
]

{ #category : #'instance creation' }
Form class >> fromFileNamed: fileName [
	"Read a Form or ColorForm from the given file."

	| file form |
	file := (FileStream readOnlyFileNamed: fileName) binary.
	form := self fromBinaryStream: file.
	Smalltalk isMorphic ifTrue:[
		Project current resourceManager
			addResource: form
			url: (FileDirectory urlForFileNamed: file name) asString].
	file close.
	^ form

]

{ #category : #'instance creation' }
Form class >> fromUser [
	"Answer an instance of me with bitmap initialized from the area of the 
	display screen designated by the user. The grid for selecting an area is 
	1@1."

	^self fromUser: 1 @ 1
]

{ #category : #'instance creation' }
Form class >> fromUser: gridPoint [
	"Answer an instance of me with bitmap initialized from the area of the 
	display screen designated by the user. The grid for selecting an area is 
	aPoint. Ensures that the returned form has positive extent."
	| rect |
	rect := Rectangle fromUser: gridPoint.
	^ self fromDisplay: (rect origin extent: (rect extent max: gridPoint))
]

{ #category : #'instance creation' }
Form class >> fromUserWithExtent: anExtent [
	"Answer an instance of me with bitmap initialized from the area of the 
	display screen whose origin is designated by the user and whose size is anExtent"

	^ self fromDisplay: (Rectangle originFromUser: anExtent)

"(Form fromUserWithExtent: 50@50) displayAt: 10@10"
]

{ #category : #'fileIn\/Out' }
Form class >> importImage: fullName [
	"Import the given image file and store the resulting Form in the default Imports.
	The image is named with the short filename up to the first period, possibly with additions from the directory path to make it unique."

	Imports default importImageFromFileNamed: fullName.

]

{ #category : #'file list services' }
Form class >> importImageAndShowImports: fullName [

	self importImage: fullName.
	Imports default explore.
]

{ #category : #'fileIn\/Out' }
Form class >> importImageDirectory: dir [
	"Import the given image file and store the resulting Form in the default Imports.
	The image is named with the short filename up to the first period, possibly with additions from the directory path to make it unique."

	Imports default importImageDirectory: dir

]

{ #category : #'fileIn\/Out' }
Form class >> importImageDirectoryWithSubdirectories: dir [
	"Import the given image file and store the resulting Form in the default Imports.
	The image is named with the short filename up to the first period, possibly with additions from the directory path to make it unique."

	Imports default importImageDirectoryWithSubdirectories: dir

]

{ #category : #'initialize-release' }
Form class >> initialize [

	FileServices registerFileReader: self
]

{ #category : #examples }
Form class >> makeStar [  "See the similar example in OpaqueForm"
	| sampleForm pen |
	sampleForm := Form extent: 50@50.  "Make a form"
	pen := Pen newOnForm: sampleForm.
	pen place: 24@50; turn: 18.		"Draw a 5-pointed star on it."
	1 to: 5 do: [:i | pen go: 19; turn: 72; go: 19; turn: -144].
	^ sampleForm
"
Form makeStar follow: [Sensor cursorPoint]
				while: [Sensor noButtonPressed]
"
]

{ #category : #'mode constants' }
Form class >> oldErase1bitShape [
	"Answer the integer denoting mode erase."

	^ 17
]

{ #category : #'mode constants' }
Form class >> oldPaint [
	"Answer the integer denoting the 'paint' combination rule."

	^16
]

{ #category : #'file list services' }
Form class >> openAsBackground: fullName [
	"Set an image as a background image.  Support Squeak's common file format 
	(GIF, JPG, PNG, 'Form stoteOn: (run coded)' and BMP)"

	(self fromFileNamed: fullName) setAsBackground
]

{ #category : #'file list services' }
Form class >> openImageInWindow: fullName [
	"Handle five file formats: GIF, JPG, PNG, Form storeOn: (run coded), and BMP.
	Fail if file format is not recognized."

	| image myStream |

	myStream := (FileStream readOnlyFileNamed: fullName) binary.
	[image := self fromBinaryStream: myStream.
	Project current openImage: image name: fullName saveResource: true]
		ensure: [myStream close]
]

{ #category : #'mode constants' }
Form class >> over [
	"Answer the integer denoting mode over."

	^3
]

{ #category : #'mode constants' }
Form class >> paint [
	"Answer the integer denoting the 'paint' combination rule."

	^25
]

{ #category : #'mode constants' }
Form class >> paintAlpha [
	"Answer the integer denoting BitBlt's paint-with-constant-alpha rule."

	^ 31
]

{ #category : #'mode constants' }
Form class >> reverse [
	"Answer the integer denoting mode reverse."

	^6
]

{ #category : #'mode constants' }
Form class >> rgbMul [
	"Answer the integer denoting 'Multiply each color component, 
	 their values regarded as fractions of 1' rule."

	^ 37
]

{ #category : #'file list services' }
Form class >> serviceImageAsBackground [
	"Answer a service for setting the desktop background from a given graphical file's contents"

	^ SimpleServiceEntry 
		provider: self 
		label: 'use graphic as background' translatedNoop
		selector: #openAsBackground:
		description: 'use the graphic as the background for the desktop' translatedNoop
		buttonLabel: 'background' translatedNoop
]

{ #category : #'file list services' }
Form class >> serviceImageImportAndShowImports [
	"Answer a service for reading a graphic into ImageImports"

	^	SimpleServiceEntry
			provider: self 
			label: 'read graphic into and show ImageImports'
			selector: #importImageAndShowImports:
			description: 'Load a graphic, placing it in the ImageImports repository and browse that repository.'
			buttonLabel: 'import'
]

{ #category : #'file list services' }
Form class >> serviceImageImportDirectory [
	"Answer a service for reading a graphic into ImageImports"

	^(SimpleServiceEntry
			provider: self 
			label: 'import all images from this directory' translatedNoop
			selector: #importImageDirectory:
			description: 'Load all graphics found in this directory, adding them to the ImageImports repository.' translatedNoop
			buttonLabel: 'import dir' translatedNoop)
			argumentGetter: [ :fileList | fileList directory ];
			yourself

]

{ #category : #'file list services' }
Form class >> serviceImageImportDirectoryWithSubdirectories [
	"Answer a service for reading all graphics from a directory and its subdirectories into ImageImports"

	^(SimpleServiceEntry
			provider: self 
			label: 'import all images from here and subdirectories' translatedNoop
			selector: #importImageDirectoryWithSubdirectories:
			description: 'Load all graphics found in this directory and its subdirectories, adding them to the ImageImports repository.' translatedNoop
			buttonLabel: 'import subdirs' translatedNoop)
			argumentGetter: [ :fileList | fileList directory ];
			yourself

]

{ #category : #'file list services' }
Form class >> serviceImageImports [
	"Answer a service for reading a graphic into ImageImports"

	^	SimpleServiceEntry
			provider: self 
			label: 'read graphic into ImageImports'
			selector: #importImage:
			description: 'Load a graphic, placing it in the ImageImports repository.'
			buttonLabel: 'import'
]

{ #category : #'file list services' }
Form class >> serviceOpenImageInWindow [
	"Answer a service for opening a graphic in a window"

	^ SimpleServiceEntry 
		provider: self 
		label: 'open graphic in a window' translatedNoop
		selector: #openImageInWindow:
		description: 'open a graphic file in a window' translatedNoop
		buttonLabel: 'open' translatedNoop
]

{ #category : #'file list services' }
Form class >> services [

	^ Array 
		with: self serviceImageImports
		with: self serviceImageImportAndShowImports
		with: self serviceOpenImageInWindow
		with: self serviceImageAsBackground 
]

{ #category : #'shut down' }
Form class >> shutDown [  "Form shutDown"
	"Compress all instances in the system.  Will decompress on demand..."
	Form allInstancesDo: [:f | f hibernate].
	ColorForm allInstancesDo: [:f | f hibernate].
]

{ #category : #examples }
Form class >> toothpaste: diam [		"Display restoreAfter: [Form toothpaste: 30]"
	"Draws wormlike lines by laying down images of spheres.
	See Ken Knowlton, Computer Graphics, vol. 15 no. 4 p352.
	Draw with mouse button down; terminate by option-click."
	| facade ball filter point queue port color q colors colr colr2 |
	colors := Display depth = 1
		ifTrue: [Array with: Color black]
		ifFalse: [Color red wheel: 12].
	facade := Form extent: diam@diam offset: (diam // -2) asPoint.
	(Form dotOfSize: diam) displayOn: facade
			at: (diam // 2) asPoint clippingBox: facade boundingBox
			rule: Form under fillColor: Color white.
	#(1 2 3) do:
		[:x |  "simulate facade by circles of gray"
		(Form dotOfSize: x * diam // 5) displayOn: facade
			at: (diam * 2 // 5) asPoint clippingBox: facade boundingBox
			rule: Form under
			fillColor: (Color perform: 
					(#(black gray lightGray) at: x)).
		"facade displayAt: 50*x@50"].
	ball := Form dotOfSize: diam.
	color := 8.
	[port := BitBlt toForm: Display.
	"Expand 1-bit forms to any pixel depth"
	port colorMap: (Bitmap with: 0 with: 16rFFFFFFFF).
	queue := OrderedCollection new: 32.
	16 timesRepeat: [queue addLast: -20 @ -20].
	Sensor waitButton.
	Sensor yellowButtonPressed ifTrue: [^ self].
	filter := Sensor cursorPoint.
	colr := colors atWrap: (color := color + 5).  "choose increment relatively prime to colors size"
	colr2 := colr alphaMixed: 0.3 with: Color white.
	[Sensor redButtonPressed or: [queue size > 0]] whileTrue:
		[filter := filter * 4 + Sensor cursorPoint  //  5.
		point := Sensor redButtonPressed
			ifTrue: [filter] ifFalse: [-20 @ -20].
		port copyForm: ball to: point rule: Form paint fillColor: colr.
		(q := queue removeFirst) == nil ifTrue: [^ self].	"exit"
		Display depth = 1
			ifTrue: [port copyForm: facade to: q rule: Form erase]
			ifFalse: [port copyForm: facade to: q rule: Form paint fillColor: colr2].
		Sensor redButtonPressed ifTrue: [queue addLast: point]]] repeat.

]

{ #category : #'mode constants' }
Form class >> under [
	"Answer the integer denoting mode under."

	^7
]

{ #category : #'class initialization' }
Form class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #examples }
Form class >> xorHack: size [  "Display restoreAfter: [Form xorHack: 256]"
	"Draw a smiley face or stick figure, and end with option-click.
	Thereafter image gets 'processed' as long as you have button down.
	If you stop at just the right time, you'll see you figure upside down,
	and at the end of a full cycle, you'll see it perfectly restored.
	Dude -- this works in color too!"
	| rect form i bb |
	rect := 5 @ 5 extent: size @ size.
	Display fillWhite: rect; border: (rect expandBy: 2) width: 2.
	Display border: (rect topRight - (0 @ 2) extent: rect extent * 2 + 4) width: 2.
	Form exampleSketch.
	form := Form fromDisplay: rect.
	bb := form boundingBox.
	i := 0.
	[Sensor yellowButtonPressed] whileFalse:
		[[Sensor redButtonPressed] whileTrue:
			[i := i + 1.
			(Array with: 0 @ 1 with: 0 @ -1 with: 1 @ 0 with: -1 @ 0) do:
				[:d | form copyBits: bb from: form at: d
					clippingBox: bb rule: Form reverse fillColor: nil].
			form displayAt: rect topLeft.
			i+2\\size < 4 ifTrue: [(Delay forMilliseconds: 300) wait]].
		(form magnify: form boundingBox by: 2 @ 2) displayAt: rect topRight + (2 @ 0).
		Sensor waitButton].
]

{ #category : #converting }
Form >> adjustBrightness: brightness [

	^ self collectColors: [:color | color adjustSaturation: 0 brightness: brightness]
]

{ #category : #converting }
Form >> adjustSaturation: saturation [

	^ self collectColors: [:color | color adjustSaturation: saturation brightness: 0]
]

{ #category : #'initialize-release' }
Form >> allocateForm: extentPoint [
	"Allocate a new form which is similar to the receiver and can be used for accelerated blts"
	^Form extent: extentPoint depth: self nativeDepth
]

{ #category : #filling }
Form >> anyShapeFill [
	"Fill the interior of the outermost outlined region in the receiver, a 1-bit deep form.  Typically the resulting form is used with fillShape:fillColor: to paint a solid color.  See also convexShapeFill:"

	| shape |
	"Draw a seed line around the edge and fill inward from the outside."
	shape := self findShapeAroundSeedBlock: [:f | f borderWidth: 1].
	"Reverse so that this becomes solid in the middle"
	shape := shape reverse.
	"Finally erase any bits from the original so the fill is only elsewhere"
	shape copy: shape boundingBox from: self to: 0@0 rule: Form erase.
	^ shape
]

{ #category : #processing }
Form >> approxGaussianBlur [

	^ self processUsingKernel: (Matrix rows: 3 columns: 3 contents: #(
		 1 2 1
		 2 4 2
		 1 2 1
	) *  0.0625)
]

{ #category : #converting }
Form >> as8BitColorForm [
	"Simple conversion of zero pixels to transparent.  Force it to 8 bits."

	| f map |
	f := ColorForm extent: self extent depth: 8.
	self displayOn: f at: self offset negated.
	map := Color indexedColors copy.
	map at: 1 put: Color transparent.
	f colors: map.
	f offset: self offset.
	^ f

]

{ #category : #converting }
Form >> asCursorForm [

	^ self as: StaticForm
]

{ #category : #converting }
Form >> asFormOfDepth: d [
	"Create a copy of me with depth 'd'. Includes a correction for some bitmaps that when imported have poorly set up transparency"
	| newForm |
	d = self depth ifTrue:[^self].
	newForm := Form extent: self extent depth: d.
	(BitBlt toForm: newForm)
		colorMap: (self colormapIfNeededFor: newForm);
		copy: (self boundingBox)
		from: 0@0 in: self
		fillColor: nil rule: Form over.
	"Special case: For a 16 -> 32 bit conversion fill the alpha channel because it gets lost in translation."
	d = 32 ifTrue:[newForm fixAlpha].
	^newForm
]

{ #category : #converting }
Form >> asGrayScale [
	"Assume the receiver is a grayscale image. Return a grayscale ColorForm computed by extracting the brightness levels of one color component. This technique allows a 32-bit Form to be converted to an 8-bit ColorForm to save space while retaining a full 255 levels of gray. (The usual colormapping technique quantizes to 8, 16, or 32 levels, which loses information.)"
	| f32 srcForm result map bb |
	self depth = 32 ifFalse: [
		f32 := Form extent: width@height depth: 32.
		self displayOn: f32.
		^ f32 asGrayScale].
	self unhibernate.
	srcForm := Form extent: (width * 4)@height depth: 8.
	srcForm bits: bits.
	result := ColorForm extent: width@height depth: 8.
	map := Bitmap new: 256.
	2 to: 256 do: [:i | map at: i put: i - 1].
	map at: 1 put: 1.  "map zero pixel values to near-black"
	bb := (BitBlt toForm: result)
		sourceForm: srcForm;
		combinationRule: Form over;
		colorMap: map.
	0 to: width - 1 do: [:dstX |
		bb  sourceRect: (((dstX * 4) + 2)@0 extent: 1@height);
			destOrigin: dstX@0;
			copyBits].

	"final BitBlt to zero-out pixels that were truely transparent in the original"
	map := Bitmap new: 512.
	map at: 1 put: 16rFF.
	(BitBlt toForm: result)
		sourceForm: self;
		sourceRect: self boundingBox;
		destOrigin: 0@0;
		combinationRule: Form erase;
		colorMap: map;
		copyBits.
	
	
	result colors: ColorForm grayScalePalette.
	^ result

]

{ #category : #converting }
Form >> asSourceForm [
	^self
]

{ #category : #converting }
Form >> asTextAnchor [
	"Convert the receiver to be embedded in text."

	self flag: #refactor. "mt: Text anchors should work outside of Morphic, too. Any instance of Form could be embedded in Text."
	^ (Smalltalk classNamed: 'TextAnchor')
		ifNil: [TextColor black "Fall back"]
		ifNotNil: [:cls | cls new anchoredMorph: self]
]

{ #category : #'color mapping' }
Form >> balancedPatternFor: aColor [
	"Return the pixel word for representing the given color on the receiver"
	^aColor balancedPatternForDepth: self depth
]

{ #category : #editing }
Form >> bitEdit [
	"Create and schedule a view located in an area designated by the user 
	that contains a view of the receiver magnified by 8@8 that can be 
	modified using the Bit Editor. It also contains a view of the original 
	form."

	Project current bitEdit: self

]

{ #category : #editing }
Form >> bitEditAt: magnifiedFormLocation scale: scaleFactor [ 
	"Create and schedule a view whose top left corner is magnifiedLocation 
	and that contains a view of the receiver magnified by scaleFactor that 
	can be modified using the Bit Editor. It also contains a view of the 
	original form."

	Project current bitEdit: self at: magnifiedFormLocation scale: scaleFactor 

]

{ #category : #'color mapping' }
Form >> bitPatternFor: aColor [
	"Return the pixel word for representing the given color on the receiver"
	^aColor bitPatternForDepth: self depth
]

{ #category : #filling }
Form >> bitPatternForDepth: suspectedDepth [
	"Only called when a Form is being used as a fillColor.  Use a Pattern or InfiniteForm instead for this purpose.
	Interpret me as an array of (32/depth) Color pixelValues.  BitBlt aligns the first element of this array with the top scanline of the destinationForm, the second with the second, and so on, cycling through the color array as necessary. 6/18/96 tk"

	^ self
]

{ #category : #accessing }
Form >> bits [
	"Answer the receiver's Bitmap containing its bits."

	^ bits
]

{ #category : #accessing }
Form >> bits: aBitmap [ 
	"Reset the Bitmap containing the receiver's bits."

	bits := aBitmap
]

{ #category : #'postscript generation' }
Form >> bitsPerComponent [
	^self depth <= 8 ifTrue:[self depth] ifFalse:[8].

]

{ #category : #accessing }
Form >> bitsSize [
	| pixPerWord |
	depth == nil ifTrue: [depth := 1].
	pixPerWord := 32 // self depth.
	^ width + pixPerWord - 1 // pixPerWord * height
]

{ #category : #copying }
Form >> blankCopyOf: aRectangle scaledBy: scale [ 
	^ self species
		extent: (aRectangle extent * scale) truncated
		depth: depth
]

{ #category : #bordering }
Form >> border: rect width: borderWidth rule: rule fillColor: fillColor [
        "Paint a border whose rectangular area is defined by rect. The
width of the border of each side is borderWidth. Uses fillColor for drawing
the border."
        | blt |
        blt := (BitBlt toForm: self) combinationRule: rule; fillColor: fillColor.
        blt sourceOrigin: 0@0.
        blt destOrigin: rect origin.
        blt width: rect width; height: borderWidth; copyBits.
        blt destY: rect corner y - borderWidth; copyBits.
        blt destY: rect origin y + borderWidth.
        blt height: rect height - borderWidth - borderWidth; width:
borderWidth; copyBits.
        blt destX: rect corner x - borderWidth; copyBits
]

{ #category : #bordering }
Form >> borderFormOfWidth: borderWidth sharpCorners: sharpen [
	"Smear this form around and then subtract the original to produce
	an outline.  If sharpen is true, then cause right angles to be outlined
	by right angles (takes an additional diagonal smears ANDed with both
	horizontal and vertical smears)."
	| smearForm bigForm smearPort all cornerForm cornerPort nbrs |
	self depth > 1 ifTrue: [self halt]. "Only meaningful for B/W forms."
	bigForm := self deepCopy.
	all := bigForm boundingBox.
	smearForm := Form extent: self extent.
	smearPort := BitBlt toForm: smearForm.
	sharpen ifTrue:
		[cornerForm := Form extent: self extent.
		cornerPort := BitBlt toForm: cornerForm].
	nbrs := (0@0) fourNeighbors.
	1 to: borderWidth do:
		[:i |  "Iterate to get several layers of 'skin'"
		nbrs do:
			[:d |  "Smear the self in 4 directions to grow each layer of skin"
			smearPort copyForm: bigForm to: d rule: Form under].
		sharpen ifTrue:
			["Special treatment to smear sharp corners"
			nbrs with: ((2 to: 5) collect: [:i2 | nbrs atWrap: i2]) do:
				[:d1 :d2 |
				"Copy corner points diagonally"
				cornerPort copyForm: bigForm to: d1+d2 rule: Form over.
				"But only preserve if there were dots on either side"
				cornerPort copyForm: bigForm to: d1+d1+d2 rule: Form and.
				cornerPort copyForm: bigForm to: d1+d2+d2 rule: Form and.
				smearPort copyForm: cornerForm to: 0@0 rule: Form under].
			].
		bigForm copy: all from: 0@0 in: smearForm rule: Form over.
		].
	"Now erase the original shape to obtain the outline"
	bigForm copy: all from: 0@0 in: self rule: Form erase.
	^ bigForm
]

{ #category : #bordering }
Form >> borderWidth: anInteger [ 
	"Set the width of the border for the receiver to be anInteger and paint it 
	using black as the border color."

	self border: self boundingBox width: anInteger fillColor: Color black
]

{ #category : #bordering }
Form >> borderWidth: anInteger color: aMask [
	"Set the width of the border for the receiver to be anInteger and paint it 
	using aMask as the border color."

	self border: self boundingBox width: anInteger fillColor: aMask
]

{ #category : #bordering }
Form >> borderWidth: anInteger fillColor: aMask [
	"Set the width of the border for the receiver to be anInteger and paint it 
	using aMask as the border color."

	self border: self boundingBox width: anInteger fillColor: aMask
]

{ #category : #'display box access' }
Form >> boundingBox [
	^ Rectangle origin: 0 @ 0
			corner: width @ height
]

{ #category : #'postscript generation' }
Form >> bytesPerRow [
	^ self numComponents * self paddedWidth * self bitsPerComponent / 8.
]

{ #category : #'display box access' }
Form >> center [
	"Note that offset is ignored here.  Are we really going to embrace offset?  "
	^ (width @ height) // 2
]

{ #category : #analyzing }
Form >> cgForPixelValue: pv orNot: not [
	"Return the center of gravity for all pixels of value pv.
	Note:  If orNot is true, then produce the center of gravity for all pixels
	that are DIFFERENT from the supplied (background) value"
	| xAndY |
	xAndY := (Array with: (self xTallyPixelValue: pv orNot: not)
					with: (self yTallyPixelValue: pv orNot: not)) collect:
		[:profile | | pixCount weighted |	"For both x and y profiles..."
		pixCount := 0.  weighted := 0.
		profile doWithIndex:
			[:t :i | pixCount := pixCount + t.
			weighted := weighted + (t*i)].
		pixCount = 0  "Produce average of nPixels weighted by coordinate"
			ifTrue: [0.0]
			ifFalse: [weighted asFloat / pixCount asFloat - 1.0]].

	^ xAndY first @ xAndY last
"
| f cg |
[Sensor anyButtonPressed] whileFalse:
	[f := Form fromDisplay: (Sensor cursorPoint extent: 50@50).
	cg := f cgForPixelValue: (Color black pixelValueForDepth: f depth) orNot: false.
	f displayAt: 0@0.
	Display fill: (cg extent: 2@2) fillColor: Color red].
	ScheduledControllers restore
"
]

{ #category : #'scaling, rotation' }
Form >> clippedToSize: aPoint [
 	"Return a copy of this form that is clipped to the given size around the center."
	
	| newForm |
	newForm := self class extent: aPoint depth: depth.
	^ newForm copyBits: ((0@0 corner: aPoint) translateBy: (self extent - aPoint) // 2) from: self at: 0@0
		clippingBox: newForm boundingBox rule: Form over fillColor: nil
]

{ #category : #converting }
Form >> collectColors: aBlock [
	"Create a new copy of the receiver with all the colors transformed by aBlock"
	^self collectPixels:[:pv|
		(aBlock value: (Color colorFromPixelValue: pv depth: self depth)) 
			pixelValueForDepth: self depth.
	].
]

{ #category : #converting }
Form >> collectPixels: aBlock [
	"Create a new copy of the receiver with all the pixels transformed by aBlock"
	self depth = 32 ifFalse:[
		"Perform the operation in 32bpp"
		^((self asFormOfDepth: 32) collectPixels: aBlock) asFormOfDepth: self depth].
	self unhibernate. "ensure unhibernated before touching bits"
	^Form 
		extent: self extent 
		depth: self depth
		bits: (self bits collect: aBlock)
]

{ #category : #'pixel access' }
Form >> colorAt: aPoint [
	"Return the color in the pixel at the given point.  "

	^ Color 
		colorFromPixelValue: (self pixelValueAt: aPoint)
		depth: self depth

]

{ #category : #'pixel access' }
Form >> colorAt: aPoint put: aColor [
	"Store a Color into the pixel at coordinate aPoint.  "

	self pixelValueAt: aPoint put: (self pixelValueFor: aColor).

"[Sensor anyButtonPressed] whileFalse:
	[Display colorAt: Sensor cursorPoint put: Color red]"

]

{ #category : #converting }
Form >> colorReduced [
	"Return a color-reduced ColorForm version of the receiver, if possible, or the receiver itself if not."

	| tally tallyDepth colorCount newForm cm oldPixelValues newFormColors nextColorIndex c |
	tally := self tallyPixelValues asArray.
	tallyDepth := (tally size log: 2) asInteger.
	colorCount := 0.
	tally do: [:n | n > 0 ifTrue: [colorCount := colorCount + 1]].
	(tally at: 1) = 0 ifTrue: [colorCount := colorCount + 1].  "include transparent"
	colorCount > 256 ifTrue: [^ self].  "cannot reduce"
	newForm := self formForColorCount: colorCount.

	"build an array of just the colors used, and a color map to translate
	 old pixel values to their indices into this color array"
	cm := Bitmap new: tally size.
	oldPixelValues := self colormapIfNeededForDepth: 32.
	newFormColors := Array new: colorCount.
	newFormColors at: 1 put: Color transparent.
	nextColorIndex := 2.
	2 to: cm size do: [:i |
		(tally at: i) > 0 ifTrue: [
			oldPixelValues = nil
				ifTrue: [c := Color colorFromPixelValue: i - 1 depth: tallyDepth]
				ifFalse: [c := Color colorFromPixelValue: (oldPixelValues at: i) depth: 32].
			newFormColors at: nextColorIndex put: c.
			cm at: i put: nextColorIndex - 1.  "pixel values are zero-based indices"
			nextColorIndex := nextColorIndex + 1]].

	"copy pixels into new ColorForm, mapping to new pixel values"
	newForm copyBits: self boundingBox
		from: self
		at: 0@0
		clippingBox: self boundingBox
		rule: Form over
		fillColor: nil
		map: cm.
	newForm colors: newFormColors.
	newForm offset: offset.
	^ newForm

]

{ #category : #'color mapping' }
Form >> colormapFromARGB [
	"Return a ColorMap mapping from canonical ARGB space into the receiver.
	Note: This version is optimized for Squeak forms."
	| map nBits |
	self depth <= 8 ifTrue:[
		map := Color colorMapIfNeededFrom: 32 to: self depth.
		map size = 512 ifTrue:[nBits := 3].
		map size = 4096 ifTrue:[nBits := 4].
		map size = 32768 ifTrue:[nBits := 5].
		^ColorMap
			shifts: (Array 
						with: 3 * nBits - 24
						with: 2 * nBits - 16
						with: 1 * nBits - 8
						with: 0)
			masks: (Array
						with: (1 << nBits) - 1 << (24 - nBits)
						with: (1 << nBits) - 1 << (16 - nBits)
						with: (1 << nBits) - 1 << (8 - nBits)
						with: 0)
			colors: map].
	self depth = 16 ifTrue:[
		^ColorMap
			shifts: #(-9 -6 -3 0)
			masks: #(16rF80000 16rF800 16rF8 0)].
	self depth = 32 ifTrue:[
		^ColorMap
			shifts: #(0 0 0 0)
			masks: #(16rFF0000 16rFF00 16rFF 16rFF000000)].
	self error:'Bad depth'
]

{ #category : #'color mapping' }
Form >> colormapIfNeededFor: destForm [
	"Return a ColorMap mapping from the receiver to destForm."
	(self hasNonStandardPalette or:[destForm hasNonStandardPalette]) 
		ifTrue:[^self colormapFromARGB mappingTo: destForm colormapFromARGB]
		ifFalse:[^self colormapIfNeededForDepth: destForm depth]
]

{ #category : #'color mapping' }
Form >> colormapIfNeededForDepth: destDepth [
	"Return a colormap for displaying the receiver at the given depth, or nil if no colormap is needed."

	self depth = destDepth ifTrue: [^ nil].  "not needed if depths are the same"
	^ Color colorMapIfNeededFrom: self depth to: destDepth

]

{ #category : #'color mapping' }
Form >> colormapToARGB [
	"Return a ColorMap mapping from the receiver into canonical ARGB space."
	self depth <= 8 ifTrue:[
		^ColorMap
			shifts: #(0 0 0 0)
			masks: #(16rFF0000 16rFF00 16rFF 16rFF000000)
			colors: (Color colorMapIfNeededFrom: self depth to: 32)].
	self depth = 16 ifTrue:[
		^ColorMap 
			shifts: #( 9 6 3 0) 
			masks: #(16r7C00 16r3E0 16r1F 0)].
	self depth = 32 ifTrue:[
		^ColorMap
			shifts: #(0 0 0 0) 
			masks: #(16rFF0000 16rFF00 16rFF 16rFF000000)].
	self error:'Bad depth'
]

{ #category : #analyzing }
Form >> colorsUsed [
	"Return a list of the Colors this form uses."

	| tallies tallyDepth usedColors |
	tallies := self tallyPixelValues.
	tallyDepth := (tallies size log: 2) asInteger.
	usedColors := OrderedCollection new.
	tallies doWithIndex: [:count :i |
		count > 0 ifTrue: [
			usedColors add: (Color colorFromPixelValue: i - 1 depth: tallyDepth)]].
	^ usedColors asArray

]

{ #category : #'fileIn\/Out' }
Form >> comeFullyUpOnReload: smartRefStream [
	bits isForm ifFalse:[^self].
	"make sure the resource gets loaded afterwards"
	ResourceCollector current ifNil:[^self].
	ResourceCollector current noteResource: bits replacing: self.

]

{ #category : #'display box access' }
Form >> computeBoundingBox [
	^ Rectangle origin: 0 @ 0
			corner: width @ height
]

{ #category : #copying }
Form >> contentsOfArea: aRect [
 	"Return a new form which derives from the portion of the original form delineated by aRect."
	^self contentsOfArea: aRect 
		into: (self species extent: aRect extent depth: depth).
]

{ #category : #copying }
Form >> contentsOfArea: aRect into: newForm [
 	"Return a new form which derives from the portion of the original form delineated by aRect."
	^ newForm copyBits: aRect from: self at: 0@0
		clippingBox: newForm boundingBox rule: Form over fillColor: nil
]

{ #category : #filling }
Form >> convexShapeFill: aMask [ 
	"Fill the interior of the outtermost outlined region in the receiver.  The outlined region must not be concave by more than 90 degrees.  Typically aMask is Color black, to produce a solid fill. then the resulting form is used with fillShape: to paint a solid color.  See also anyShapeFill"
	| destForm tempForm |
	destForm := Form extent: self extent.  destForm fillBlack.
	tempForm := Form extent: self extent.
	(0@0) fourNeighbors do:
		[:dir |  "Smear self in all 4 directions, and AND the result"
		self displayOn: tempForm at: (0@0) - self offset.
		tempForm smear: dir distance: (dir dotProduct: tempForm extent) abs.
		tempForm displayOn: destForm at: 0@0
			clippingBox: destForm boundingBox
			rule: Form and fillColor: nil].
	destForm displayOn: self at: 0@0
		clippingBox: self boundingBox
		rule: Form over fillColor: aMask
]

{ #category : #copying }
Form >> copy: aRect [
 	"Return a new form which derives from the portion of the original form delineated by aRect."
	| newForm |
	newForm := self species extent: aRect extent depth: depth.
	^ newForm copyBits: aRect from: self at: 0@0
		clippingBox: newForm boundingBox rule: Form over fillColor: nil
]

{ #category : #copying }
Form >> copy: destRectangle from: sourcePt in: sourceForm rule: rule [ 
	"Make up a BitBlt table and copy the bits."
	(BitBlt toForm: self)
		copy: destRectangle
		from: sourcePt in: sourceForm
		fillColor: nil rule: rule
]

{ #category : #copying }
Form >> copy: sourceRectangle from: sourceForm to: destPt rule: rule [
	^ self copy: (destPt extent: sourceRectangle extent)
		from: sourceRectangle topLeft in: sourceForm rule: rule
]

{ #category : #copying }
Form >> copyBits: sourceForm at: destOrigin translucent: factor [
	"Make up a BitBlt table and copy the bits with the given colorMap."
	(BitBlt 
		destForm: self
		sourceForm: sourceForm
		halftoneForm: nil
		combinationRule: 30
		destOrigin: destOrigin
		sourceOrigin: 0@0
		extent: sourceForm extent
		clipRect: self boundingBox)
		copyBitsTranslucent: ((0 max: (factor*255.0) asInteger) min: 255)
"
 | f f2 f3 | f := Form fromUser. f2 := Form fromDisplay: (0@0 extent: f extent). f3 := f2 deepCopy.
0.0 to: 1.0 by: 1.0/32 do:
	[:t | f3 := f2 deepCopy. f3 copyBits: f at: 0@0 translucent: t.
	f3 displayAt: 0@0. (Delay forMilliseconds: 100) wait].
"
]

{ #category : #copying }
Form >> copyBits: sourceRect from: sourceForm at: destOrigin clippingBox: clipRect rule: rule fillColor: aForm [ 
	"Make up a BitBlt table and copy the bits."

	(BitBlt 
		destForm: self
		sourceForm: sourceForm
		fillColor: aForm
		combinationRule: rule
		destOrigin: destOrigin
		sourceOrigin: sourceRect origin
		extent: sourceRect extent
		clipRect: clipRect) copyBits
]

{ #category : #copying }
Form >> copyBits: sourceRect from: sourceForm at: destOrigin clippingBox: clipRect rule: rule fillColor: aForm map: map [
	"Make up a BitBlt table and copy the bits.  Use a colorMap."

	((BitBlt 
		destForm: self
		sourceForm: sourceForm
		fillColor: aForm
		combinationRule: rule
		destOrigin: destOrigin
		sourceOrigin: sourceRect origin
		extent: sourceRect extent
		clipRect: clipRect) colorMap: map) copyBits
]

{ #category : #copying }
Form >> copyBits: sourceRect from: sourceForm at: destOrigin colorMap: map [ 
	"Make up a BitBlt table and copy the bits with the given colorMap."
	((BitBlt 
		destForm: self
		sourceForm: sourceForm
		halftoneForm: nil
		combinationRule: Form over
		destOrigin: destOrigin
		sourceOrigin: sourceRect origin
		extent: sourceRect extent
		clipRect: self boundingBox) colorMap: map) copyBits
]

{ #category : #converting }
Form >> copyWithColorsReducedTo: nColors [
	"Note: this has not been engineered.
	There are better solutions in the literature."
	| palette colorMap |
	palette := self reducedPaletteOfSize: nColors.
	colorMap := (1 to: (1 bitShift: depth)) collect:
		[:i | | pc closest |
		pc := Color colorFromPixelValue: i-1 depth: depth.
		closest := palette detectMin: [:c | c diff: pc].
		closest pixelValueForDepth: depth].
	^ self deepCopy copyBits: self boundingBox from: self at: 0@0 colorMap: (colorMap as: Bitmap)
		
]

{ #category : #converting }
Form >> darker [
	"Answer a darker variant of this form."
	^self collectColors:[:color| color darker darker]
]

{ #category : #'postscript generation' }
Form >> decodeArray [
	^self depth <= 8 ifTrue:['[1 0]'] ifFalse:['[0 1 0 1 0 1 ]'].

]

{ #category : #copying }
Form >> deepCopy [
	^self copy
]

{ #category : #accessing }
Form >> defaultCanvasClass [
	"Return the default canvas used for drawing onto the receiver"
	^Display defaultCanvasClass
]

{ #category : #accessing }
Form >> depth [
	^ depth < 0 ifTrue:[0-depth] ifFalse:[depth]
]

{ #category : #accessing }
Form >> depth: bitsPerPixel [
	(bitsPerPixel > 32 or:
		[(bitsPerPixel bitAnd: bitsPerPixel-1) ~= 0])
		ifTrue: [self halt: 'bitsPerPixel must be 1, 2, 4, 8, 16 or 32'].
	depth := bitsPerPixel
]

{ #category : #converting }
Form >> dimmed [
	"Answer a dimmed variant of this form."
	^self collectColors:[:color| (color alpha: (color alpha min: 0.2)) ]
]

{ #category : #displaying }
Form >> displayInterpolatedIn: aRectangle on: aForm [
	"Display the receiver on aForm, using interpolation if necessary.
		Form fromUser displayInterpolatedOn: Display.
	Note: When scaling we attempt to use bilinear interpolation based
	on the 3D engine. If the engine is not there then we use WarpBlt.
	"
	| engine adjustedR |
	self extent = aRectangle extent ifTrue:[^self displayOn: aForm at: aRectangle origin].
	engine := Smalltalk at: #B3DRenderEngine 
		ifPresent: [:engineClass | (engineClass defaultForPlatformOn: aForm)].
	engine ifNil:[
		"We've got no bilinear interpolation. Use WarpBlt instead"
		(WarpBlt toForm: aForm)
			sourceForm: self destRect: aRectangle;
			combinationRule: 3;
			cellSize: 2;
			warpBits.
		^self
	].

	"Otherwise use the 3D engine for our purposes"

	"there seems to be a slight bug in B3D which the following adjusts for"
	adjustedR := (aRectangle withRight: aRectangle right + 1) translateBy: 0@1.
	engine viewport: adjustedR.
	engine material: ((Smalltalk at: #B3DMaterial) new emission: Color white).
	engine texture: self.
	engine render: ((Smalltalk at: #B3DIndexedQuadMesh) new plainTextureRect).
	engine finish.
]

{ #category : #displaying }
Form >> displayInterpolatedOn: aForm [
	"Display the receiver on aForm, using interpolation if necessary.
		Form fromUser displayInterpolatedOn: Display.
	Note: When scaling we attempt to use bilinear interpolation based
	on the 3D engine. If the engine is not there then we use WarpBlt.
	"
	| engine |
	self extent = aForm extent ifTrue:[^self displayOn: aForm].
	engine := Smalltalk at: #B3DRenderEngine 
		ifPresent:[:engineClass| (engineClass defaultForPlatformOn: aForm)].
	engine ifNil:[
		"We've got no bilinear interpolation. Use WarpBlt instead"
		(WarpBlt toForm: aForm)
			sourceForm: self destRect: aForm boundingBox;
			combinationRule: 3;
			cellSize: 2;
			warpBits.
		^self
	].
	"Otherwise use the 3D engine for our purposes"
	engine viewport: aForm boundingBox.
	engine material: ((Smalltalk at: #B3DMaterial) new emission: Color white).
	engine texture: self.
	engine render: ((Smalltalk at: #B3DIndexedQuadMesh) new plainTextureRect).
	engine finish.
]

{ #category : #displaying }
Form >> displayOn: aDisplayMedium at: aDisplayPoint clippingBox: clipRectangle rule: rule fillColor: aForm [

	aDisplayMedium copyBits: self boundingBox
		from: self
		at: aDisplayPoint + self offset
		clippingBox: clipRectangle
		rule: rule
		fillColor: aForm
		map: (self colormapIfNeededFor: aDisplayMedium).

]

{ #category : #displaying }
Form >> displayOn: aDisplayMedium transformation: displayTransformation clippingBox: clipRectangle align: alignmentPoint with: relativePoint rule: ruleInteger fillColor: aForm [ 
	"Graphically, it means nothing to scale a Form by floating point values.  
	Because scales and other display parameters are kept in floating point to 
	minimize round off errors, we are forced in this routine to round off to the 
	nearest integer."

	| absolutePoint scale magnifiedForm |
	absolutePoint := displayTransformation applyTo: relativePoint.
	absolutePoint := absolutePoint x asInteger @ absolutePoint y asInteger.
	displayTransformation noScale
		ifTrue: [magnifiedForm := self]
		ifFalse: 
			[scale := displayTransformation scale.
			scale := scale x @ scale y.
			(1@1 = scale)
					ifTrue: [scale := nil. magnifiedForm := self]
					ifFalse: [magnifiedForm := self magnify: self boundingBox by: scale]].
	magnifiedForm
		displayOn: aDisplayMedium
		at: absolutePoint - alignmentPoint
		clippingBox: clipRectangle
		rule: ruleInteger
		fillColor: aForm
]

{ #category : #displaying }
Form >> displayOnPort: port at: location [
	port copyForm: self to: location rule: Form over
]

{ #category : #displaying }
Form >> displayResourceFormOn: aForm [
	"a special display method for blowing up resource thumbnails"
	| engine tx cmap blitter |
	self extent = aForm extent ifTrue:[^self displayOn: aForm].
	engine := Smalltalk at: #B3DRenderEngine ifPresent:
		[:engineClass | engineClass defaultForPlatformOn: aForm].
	engine ifNil:[
		"We've got no bilinear interpolation. Use WarpBlt instead"
		(WarpBlt toForm: aForm)
			sourceForm: self destRect: aForm boundingBox;
			combinationRule: 3;
			cellSize: 2;
			warpBits.
		^self
	].
	tx := self asTexture.
	(blitter := BitBlt toForm: tx)
		sourceForm: self; destRect: aForm boundingBox;
		sourceOrigin: 0@0;
		combinationRule: Form paint.
	"map transparency to current World background color"
	(Project current world color respondsTo: #pixelWordForDepth:) ifTrue: [
		cmap := Bitmap new: (self depth <= 8 ifTrue: [1 << self depth] ifFalse: [4096]).
		cmap at: 1 put: (tx pixelWordFor: Project current world color).
		blitter colorMap: cmap.
	].
	blitter copyBits.
	engine viewport: aForm boundingBox.
	engine material: ((Smalltalk at: #B3DMaterial) new emission: Color white).
	engine texture: tx.
	engine render: ((Smalltalk at: #B3DIndexedQuadMesh) new plainTextureRect).
	engine finish.
	"the above, using bilinear interpolation doesn't leave transparent pixel values intact"
	(WarpBlt toForm: aForm)
		sourceForm: self destRect: aForm boundingBox;
		combinationRule: Form and;
		colorMap: (Color maskingMap: self depth);
		warpBits.
]

{ #category : #displaying }
Form >> displayScaledOn: aForm [
	"Display the receiver on aForm, scaling if necessary.
		Form fromUser displayScaledOn: Display.
	"
	self extent = aForm extent ifTrue:[^self displayOn: aForm].
	(WarpBlt toForm: aForm)
		sourceForm: self destRect: aForm boundingBox;
		combinationRule: Form paint;
		cellSize: 2;
		warpBits.
]

{ #category : #analyzing }
Form >> dominantColor [
	| tally max maxi |
	self depth > 16 ifTrue:
		[^(self asFormOfDepth: 16) dominantColor].
	tally := self tallyPixelValues.
	max := maxi := 0.
	tally withIndexDo: [:n :i | n > max ifTrue: [max := n. maxi := i]].
	^ Color colorFromPixelValue: maxi - 1 depth: self depth
]

{ #category : #displaying }
Form >> drawLine: sourceForm from: beginPoint to: endPoint clippingBox: clipRect rule: anInteger fillColor: aForm [ 
	"Refer to the comment in 
	DisplayMedium|drawLine:from:to:clippingBox:rule:mask:." 
	
	| dotSetter |
	"set up an instance of BitBlt for display"
	dotSetter := BitBlt
		destForm: self
		sourceForm: sourceForm
		fillColor: aForm
		combinationRule: anInteger
		destOrigin: beginPoint
		sourceOrigin: 0 @ 0
		extent: sourceForm extent
		clipRect: clipRect.
	dotSetter drawFrom: beginPoint to: endPoint
]

{ #category : #converting }
Form >> dyed: aColor [
	"Dye this form with the given color. For now, the alpha channel should be sufficient to preserve the meaning of the form."
	
	^ self collectColors: [:ea | aColor alpha: ea alpha]
]

{ #category : #processing }
Form >> edgeDetect [

	^ self processUsingKernel: (Matrix rows: 3 columns: 3 contents: #(
		-1 -1 -1
		-1  8 -1
		-1 -1 -1
	))
]

{ #category : #editing }
Form >> edit [
	"Open a form editor on this form. "
 
	Project current formEdit: self
]

{ #category : #processing }
Form >> emboss [

	^ self processUsingKernel: (Matrix rows: 3 columns: 3 contents: #(
		-2 -1  0
		-1  1  1
		 0  1  2
	))
]

{ #category : #filling }
Form >> eraseShape: bwForm [
	"use bwForm as a mask to clear all pixels where bwForm has 1's"
	((BitBlt destForm: self sourceForm: bwForm 
		fillColor: nil
		combinationRule: Form erase1bitShape	"Cut a hole in the picture with my mask"
		destOrigin: bwForm offset 
		sourceOrigin: 0@0
		extent: self extent clipRect: self boundingBox)
		colorMap: (Bitmap with: 0 with: 16rFFFFFFFF))
		copyBits.

]

{ #category : #accessing }
Form >> extent [
	^ width @ height
]

{ #category : #transitions }
Form >> fadeImage: otherImage at: topLeft
	indexAndMaskDo: indexAndMaskBlock [
	
	"This fade uses halftones as a blending hack.
	Zeros in the halftone produce the original image (self), and 
	ones in the halftone produce the 'otherImage'.
	IndexAndMaskBlock gets evaluated prior to each cycle,
	and the resulting boolean determines whether to continue cycling."
	| index imageRect maskForm resultForm pix returnPix|
	imageRect := otherImage boundingBox.
	resultForm := self copy: (topLeft extent: imageRect extent).
	maskForm := Form extent: 32@32.
	index := 0.

	[indexAndMaskBlock value: (index := index+1) value: maskForm]
	whileTrue:
		[maskForm reverse.
		resultForm copyBits: imageRect from: resultForm at: 0@0
			clippingBox: imageRect rule: Form over fillColor: maskForm.
		maskForm reverse.
		resultForm copyBits: imageRect from: otherImage at: 0@0
			clippingBox: imageRect rule: Form under fillColor: maskForm.
		self copyBits: imageRect from: resultForm at: topLeft
				clippingBox: self boundingBox rule: Form over fillColor: nil.
		Display forceDisplayUpdate]
]

{ #category : #transitions }
Form >> fadeImageCoarse: otherImage at: topLeft [
	"Display fadeImageCoarse: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40"
	| d pix|
	d := self depth.
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask | | j |
		i=1 ifTrue: [pix := (1 bitShift: d) - 1.
					1 to: 8//d-1 do: [:q | pix := pix bitOr: (pix bitShift: d*4)]]			.
		i <= 16 ifTrue:[
		j := i-1//4+1.
		(0 to: 28 by: 4) do: [:k |
			mask bits at: j+k
				put: (pix bitOr: (mask bits at: j+k))].
		true]
		ifFalse: [false]]
]

{ #category : #transitions }
Form >> fadeImageFine: otherImage at: topLeft [
	"Display fadeImageFine: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40"
	| d pix|
	d := self depth.
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask | | j ii  |
		i=1 ifTrue: [pix := (1 bitShift: d) - 1.
					1 to: 8//d-1 do:
						[:q | pix := pix bitOr: (pix bitShift: d*4)]].
		i <= 16 ifTrue:
		[ii := #(0 10 2 8 7 13 5 15 1 11 3 9 6 12 4 14) at: i.
		j := ii//4+1.
		(0 to: 28 by: 4) do:
			[:k | mask bits at: j+k put:
				((mask bits at: j+k) bitOr: (pix))].
		true]
		ifFalse: [false]]
]

{ #category : #transitions }
Form >> fadeImageHor: otherImage at: topLeft [
	"Display fadeImageHor: (Form fromDisplay: (10@10 extent: 300@300)) reverse at: 10@10"
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask |
		mask fill: (0@(mask height//2-i) extent: mask width@(i*2)) fillColor: Color black.
		(i*2) <= mask width]
]

{ #category : #transitions }
Form >> fadeImageHorFine: otherImage at: topLeft [
	"Display fadeImageHorFine: (Form fromDisplay: (10@10 extent: 300@300)) reverse at: 10@10"
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask |
		mask fill: (0@(i-1) extent: mask width@1) fillColor: Color black.
		mask fill: (0@(i-1+16) extent: mask width@1) fillColor: Color black.
		(i*2) <= mask width]
]

{ #category : #transitions }
Form >> fadeImageSquares: otherImage at: topLeft [ 
	"Display fadeImageSquares: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40"
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask |
		mask fill: ((16-i) asPoint extent: (i*2) asPoint) fillColor: Color black.
		i <= 16]
]

{ #category : #transitions }
Form >> fadeImageVert: otherImage at: topLeft [
	"Display fadeImageVert: (Form fromDisplay: (10@10 extent: 300@300)) reverse at: 10@10"
	| d |
	d := self depth.
	^ self fadeImage: otherImage at: topLeft indexAndMaskDo:
		[:i :mask |
		mask fill: ((mask width//2//d-i*d)@0 extent: i*2*d@mask height) fillColor: Color black.
		i <= (mask width//d)]
]

{ #category : #filling }
Form >> fill: aRectangle rule: anInteger fillColor: aForm [ 
	"Replace a rectangular area of the receiver with the pattern described by aForm 
	according to the rule anInteger."
	(BitBlt toForm: self)
		copy: aRectangle
		from: 0@0 in: nil
		fillColor: aForm rule: anInteger
]

{ #category : #other }
Form >> fillAlpha: alphaValue [
	"Fill a 32bit form with a constant alpha value"
	| bb |
	self depth = 32 ifFalse:[^self error: 'Only valid for 32 bit forms'].
	bb := BitBlt toForm: self.
	bb combinationRule: 7. "bitOr:with:".
	bb fillColor: (Bitmap with: alphaValue << 24).
	bb copyBits.

]

{ #category : #filling }
Form >> fillFromXColorBlock: colorBlock [
	"Horizontal Gradient Fill.
	Supply relative x in [0.0 ... 1.0] to colorBlock,
	and paint each pixel with the color that comes back"
	| xRel |
	0 to: width-1 do:
		[:x |  xRel := x asFloat / (width-1) asFloat.
		self fill: (x@0 extent: 1@height) 
			fillColor: (colorBlock value: xRel)]
"
((Form extent: 100@100 depth: Display depth)
	fillFromXColorBlock: [:x | Color r: x g: 0.0 b: 0.5]) display
"
]

{ #category : #filling }
Form >> fillFromXYColorBlock: colorBlock [
	"General Gradient Fill.
	Supply relative x and y in [0.0 ... 1.0] to colorBlock,
	and paint each pixel with the color that comes back"
	| poker yRel xRel |
	poker := BitBlt bitPokerToForm: self.
	0 to: height-1 do:
		[:y | yRel := y asFloat / (height-1) asFloat.
		0 to: width-1 do:
			[:x |  xRel := x asFloat / (width-1) asFloat.
			poker pixelAt: x@y
				put: ((colorBlock value: xRel value: yRel) pixelWordForDepth: self depth)]]
"
 | d |
((Form extent: 100@20 depth: Display depth)
	fillFromXYColorBlock:
	[:x :y | d := 1.0 - (x - 0.5) abs - (y - 0.5) abs.
	Color r: d g: 0 b: 1.0-d]) display
"
]

{ #category : #filling }
Form >> fillFromYColorBlock: colorBlock [
	"Vertical Gradient Fill.
	Supply relative y in [0.0 ... 1.0] to colorBlock,
	and paint each pixel with the color that comes back"
	| yRel |
	0 to: height-1 do:
		[:y |  yRel := y asFloat / (height-1) asFloat.
		self fill: (0@y extent: width@1) 
			fillColor: (colorBlock value: yRel)]
"
((Form extent: 100@100 depth: Display depth)
	fillFromYColorBlock: [:y | Color r: y g: 0.0 b: 0.5]) display
"
]

{ #category : #filling }
Form >> findShapeAroundSeedBlock: seedBlock [
	"Build a shape that is black in any region marked by seedBlock. 
	SeedBlock will be supplied a form, in which to blacken various
	pixels as 'seeds'.  Then the seeds are smeared until 
	there is no change in the smear when it fills the region, ie,
	when smearing hits a black border and thus goes no further."
	| smearForm previousSmear all count smearPort |
	self depth > 1 ifTrue: [self halt]. "Only meaningful for B/W forms."
	all := self boundingBox.
	smearForm := Form extent: self extent.
	smearPort := BitBlt toForm: smearForm.
	seedBlock value: smearForm.		"Blacken seeds to be smeared"
	smearPort copyForm: self to: 0 @ 0 rule: Form erase.  "Clear any in black"
	previousSmear := smearForm deepCopy.
	count := 1.
	[count = 10 and:   "check for no change every 10 smears"
		[count := 1.
		previousSmear copy: all from: 0 @ 0 in: smearForm rule: Form reverse.
		previousSmear isAllWhite]]
		whileFalse: 
			[smearPort copyForm: smearForm to: 1 @ 0 rule: Form under.
			smearPort copyForm: smearForm to: -1 @ 0 rule: Form under.
			"After horiz smear, trim around the region border"
			smearPort copyForm: self to: 0 @ 0 rule: Form erase.
			smearPort copyForm: smearForm to: 0 @ 1 rule: Form under.
			smearPort copyForm: smearForm to: 0 @ -1 rule: Form under.
			"After vert smear, trim around the region border"
			smearPort copyForm: self to: 0 @ 0 rule: Form erase.
			count := count + 1.
			count = 9 ifTrue: "Save penultimate smear for comparison"
				[previousSmear copy: all from: 0 @ 0 in: smearForm rule: Form over]].
	"Now paint the filled region in me with aHalftone"
	^ smearForm
]

{ #category : #'initialize-release' }
Form >> finish [
	"If there are any pending operations on the receiver complete them. Do not return before all modifications have taken effect."
]

{ #category : #other }
Form >> fixAlpha [
	"Fix the alpha channel if the receiver is 32bit"
	| bb |
	self depth = 32 ifFalse:[^self].
	bb := BitBlt toForm: self.
	bb combinationRule: 40 "fixAlpha:with:".
	bb copyBits.
]

{ #category : #'scaling, rotation' }
Form >> flipBy: direction centerAt: aPoint [
	"Return a copy of the receiver flipped either #vertical or #horizontal."
	| newForm quad |
	newForm := self class extent: self extent depth: depth.
	quad := self boundingBox innerCorners.
	quad := (direction = #vertical ifTrue: [#(2 1 4 3)] ifFalse: [#(4 3 2 1)])
		collect: [:i | quad at: i].
	(WarpBlt toForm: newForm)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: newForm);
		combinationRule: 3;
		copyQuad: quad toRect: newForm boundingBox.
	newForm offset: (self offset flipBy: direction centerAt: aPoint).
	^ newForm
"
[Sensor anyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor cursorPoint extent: 130@66))
			flipBy: #vertical centerAt: 0@0) display]
"
"Consistency test...
 | f f2 p | [Sensor anyButtonPressed] whileFalse:
	[f := Form fromDisplay: ((p := Sensor cursorPoint) extent: 31@41).
	Display fillBlack: (p extent: 31@41).
	f2 := f flipBy: #vertical centerAt: 0@0.
	(f2 flipBy: #vertical centerAt: 0@0) displayAt: p]
"

]

{ #category : #converting }
Form >> flipVertically [
	"Flip the image along the y axis"
	| rowLen row topIndex botIndex |
	self unhibernate.
	rowLen := bits size // height.
	row := Bitmap new: rowLen.
	topIndex := 1.
	botIndex := bits size - rowLen + 1.
	1 to: height // 2 do: [:i |
		self assert:[topIndex+rowLen <= botIndex].
		row replaceFrom: 1 to: rowLen with: bits startingAt: topIndex.
		bits replaceFrom: topIndex to: topIndex+rowLen-1 with: bits startingAt: botIndex.
		bits replaceFrom: botIndex to: botIndex+rowLen-1 with: row startingAt: 1.
		topIndex := topIndex + rowLen.
		botIndex := botIndex - rowLen.
	].

]

{ #category : #filling }
Form >> floodFill2: aColor at: interiorPoint [
	"Fill the shape (4-connected) at interiorPoint.  The algorithm is based on Paul Heckbert's 'A Seed Fill Algorithm', Graphic Gems I, Academic Press, 1990.
	NOTE: This is a less optimized variant for flood filling which is precisely along the lines of Heckbert's algorithm. For almost all cases #floodFill:at: will be faster (see the comment there) but this method is left in both as reference and as a fallback if such a strange case is encountered in reality."
	| poker stack old new x y top x1 x2 dy left goRight |
	poker := BitBlt bitPokerToForm: self.
	stack := OrderedCollection new: 50.
	"read old pixel value"
	old := self pixelValueAt: interiorPoint.
	"compute new value"
	new := self pixelValueFor: aColor.
	old = new ifTrue:[^self]. "no point, is there?!"

	x := interiorPoint x.
	y := interiorPoint y.
	(y >= 0 and:[y < height]) ifTrue:[
		stack addLast: {y. x. x. 1}. "y, left, right, dy"
		stack addLast: {y+1. x. x. -1}].
	[stack isEmpty] whileFalse:[
		top := stack removeLast.
		y := top at: 1. x1 := top at: 2. x2 := top at: 3. dy := top at: 4.
		y := y + dy.
		"Segment of scanline (y-dy) for x1 <= x <= x2 was previously filled.
		Now explore adjacent pixels in scanline y."
		x := x1.
		[x >= 0 and:[(self pixelValueAt: x@y) = old]] whileTrue:[
			poker pixelAt: x@y put: new.
			x := x - 1].
		goRight := x < x1.
		left := x+1.
		(left < x1 and:[y-dy >= 0 and:[y-dy < height]]) 
			ifTrue:[stack addLast: {y. left. x1-1. 0-dy}].
		goRight ifTrue:[x := x1 + 1].
		[
			goRight ifTrue:[
				[x < width and:[(self pixelValueAt: x@y) = old]] whileTrue:[
					poker pixelAt: x@y put: new.
					x := x + 1].
				(y+dy >= 0 and:[y+dy < height]) 
					ifTrue:[stack addLast: {y. left. x-1. dy}].
				(x > (x2+1) and:[y-dy >= 0 and:[y-dy >= 0]]) 
					ifTrue:[stack addLast: {y. x2+1. x-1. 0-dy}]].
			[(x := x + 1) <= x2 and:[(self pixelValueAt: x@y) ~= old]] whileTrue.
			left := x.
			goRight := true.
		x <= x2] whileTrue.
	].

]

{ #category : #filling }
Form >> floodFill: aColor at: interiorPoint [
	Preferences areaFillsAreVeryTolerant ifTrue:
		[^ self floodFill: aColor at: interiorPoint tolerance: 0.2].
	Preferences areaFillsAreTolerant ifTrue:
		[^ self floodFill: aColor at: interiorPoint tolerance: 0.1].
	^ self floodFill: aColor at: interiorPoint tolerance: 0

]

{ #category : #filling }
Form >> floodFill: aColor at: interiorPoint tolerance: tolerance [
	"Fill the shape (4-connected) at interiorPoint.  The algorithm is based on Paul Heckbert's 'A Seed Fill Algorithm', Graphic Gems I, Academic Press, 1990.
	NOTE (ar): This variant has been heavily optimized to prevent the overhead of repeated calls to BitBlt. Usually this is a really big winner but the runtime now depends a bit on the complexity of the shape to be filled. For extremely complex shapes (say, a Hilbert curve) with very few pixels to fill it can be slower than #floodFill2:at: since it needs to repeatedly read the source bits. However, in all practical cases I found this variant to be 15-20 times faster than anything else.
	Further note (di):  I have added a feature that allows this routine to fill areas of approximately constant color (such as  photos, scans, and jpegs).  It does this by computing a color map for the peeker that maps all colors close to 'old' into colors identical to old.  This mild colorblindness achieves the desired effect with no further change or degradation of the algorithm.  tolerance should be 0 (exact match), or a value corresponding to those returned by Color>>diff:, with 0.1 being a reasonable starting choice."

	| peeker poker stack old new x y top x1 x2 dy left goRight span spanBits w box debug |
	debug := false. "set it to true to see the filling process"
	box := interiorPoint extent: 1@1.
	span := Form extent: width@1 depth: 32.
	spanBits := span bits.

	peeker := BitBlt toForm: span.
	peeker 
		sourceForm: self; 
		combinationRule: 3; 
		width: width; 
		height: 1.

	"read old pixel value"
	peeker sourceOrigin: interiorPoint; destOrigin: interiorPoint x @ 0; width: 1; copyBits.
	old := spanBits at: interiorPoint x + 1.

	"compute new value (take care since the algorithm will fail if old = new)"
	new := self privateFloodFillValue: aColor.
	old = new ifTrue: [^ box].
	tolerance > 0 ifTrue:
		["Set up color map for approximate fills"
		peeker colorMap: (self floodFillMapFrom: self to: span mappingColorsWithin: tolerance to: old)].

	poker := BitBlt toForm: self.
	poker 
		fillColor: aColor;
		combinationRule: 3;
		width: width;
		height: 1.

	stack := OrderedCollection new: 50.
	x := interiorPoint x.
	y := interiorPoint y.
	(y >= 0 and:[y < height]) ifTrue:[
		stack addLast: {y. x. x. 1}. "y, left, right, dy"
		stack addLast: {y+1. x. x. -1}].

	[stack isEmpty] whileFalse:[
		debug ifTrue:[self displayOn: Display].
		top := stack removeLast.
		y := top at: 1. x1 := top at: 2. x2 := top at: 3. dy := top at: 4.
		y := y + dy.
		debug ifTrue:[
			Display 
				drawLine: (Form extent: 1@1 depth: 8) fillWhite
				from: (x1-1)@y to: (x2+1)@y 
				clippingBox: Display boundingBox
				rule: Form over fillColor: nil].
		"Segment of scanline (y-dy) for x1 <= x <= x2 was previously filled.
		Now explore adjacent pixels in scanline y."
		peeker sourceOrigin: 0@y; destOrigin: 0@0; width: width; copyBits.
			"Note: above is necessary since we don't know where we'll end up filling"
		x := x1.
		w := 0.
		[x >= 0 and:[(spanBits at: x+1) = old]] whileTrue:[
			w := w + 1.
			x := x - 1].
		w > 0 ifTrue:[
			"overwrite pixels"
			poker destOrigin: x+1@y; width: w; copyBits.
			box := box quickMerge: ((x+1@y) extent: w@1)].
		goRight := x < x1.
		left := x+1.
		(left < x1 and:[y-dy >= 0 and:[y-dy < height]]) 
			ifTrue:[stack addLast: {y. left. x1-1. 0-dy}].
		goRight ifTrue:[x := x1 + 1].
		[
			goRight ifTrue:[
				w := 0.
				[x < width and:[(spanBits at: x+1) = old]] whileTrue:[
					w := w + 1.
					x := x + 1].
				w > 0 ifTrue:[
					"overwrite pixels"
					poker destOrigin: (x-w)@y; width: w; copyBits.
					box := box quickMerge: ((x-w@y) extent: w@1)].
				(y+dy >= 0 and:[y+dy < height]) 
					ifTrue:[stack addLast: {y. left. x-1. dy}].
				(x > (x2+1) and:[y-dy >= 0 and:[y-dy >= 0]]) 
					ifTrue:[stack addLast: {y. x2+1. x-1. 0-dy}]].
			[(x := x + 1) <= x2 and:[(spanBits at: x+1) ~= old]] whileTrue.
			left := x.
			goRight := true.
		x <= x2] whileTrue.
	].
	^box
]

{ #category : #filling }
Form >> floodFillMapFrom: sourceForm to: scanlineForm mappingColorsWithin: dist to: centerPixVal [
	"This is a helper routine for floodFill.  It's written for clarity (scanning the entire
	map using colors) rather than speed (which would require hacking rgb components
	in the nieghborhood of centerPixVal.  Note that some day a better proximity metric
	would be (h s v) where tolerance could be reduced in hue."

	| colorMap centerColor |
	scanlineForm depth = 32 ifFalse: [self error: 'depth 32 assumed'].
	"First get a modifiable identity map"
	colorMap := 	(Color cachedColormapFrom: sourceForm depth to: scanlineForm depth) copy.
	centerColor := Color colorFromPixelValue: (centerPixVal bitOr: 16rFFe6) depth: scanlineForm depth.
	"Now replace all entries that are close to the centerColor"
	1 to: colorMap size do:
		[:i | ((Color colorFromPixelValue: ((colorMap at: i) bitOr: 16rFFe6) depth: scanlineForm depth)
				diff: centerColor) <= dist ifTrue: [colorMap at: i put: centerPixVal]].
	^ colorMap
]

{ #category : #'initialize-release' }
Form >> flush [
	"If there are any pending operations on the receiver start doing them. In time, they will show up on the receiver but not necessarily immediately after this method returns."
]

{ #category : #accessing }
Form >> form [
	"Answer the receiver's form.  For vanilla Forms, this degenerates to self.  Makes several methods that operate on both Forms and MaskedForms much more straightforward.   6/1/96 sw"

	^ self
]

{ #category : #other }
Form >> formForColorCount: colorCount [
	"Return a ColorForm of sufficient depth to represent the given number of colors. The maximum number of colors is 256."

	colorCount > 256 ifTrue: [^ self error: 'too many colors'].

	colorCount > 16 ifTrue: [^ ColorForm extent: self extent depth: 8].
	colorCount > 4 ifTrue: [^ ColorForm extent: self extent depth: 4].
	colorCount > 2 ifTrue: [^ ColorForm extent: self extent depth: 2].
	^ ColorForm extent: self extent depth: 1

]

{ #category : #'initialize-release' }
Form >> fromDisplay: aRectangle [ 
	"Create a virtual bit map from a user specified rectangular area on the 
	display screen. Reallocates bitmap only if aRectangle ~= the receiver's 
	extent."

	(width = aRectangle width and: [height = aRectangle height])
		ifFalse: [self setExtent: aRectangle extent depth: depth].
	self
		copyBits: (aRectangle origin extent: self extent)
		from: Display
		at: 0 @ 0
		clippingBox: self boundingBox
		rule: Form over
		fillColor: nil
]

{ #category : #accessing }
Form >> getCanvas [
	"Return a Canvas that can be used to draw onto the receiver"
	^self defaultCanvasClass on: self
]

{ #category : #private }
Form >> hackBits: bitThing [
	"This method provides an initialization so that BitBlt may be used, eg, to 
	copy ByteArrays and other non-pointer objects efficiently.
	The resulting form looks 4 wide, 8 deep, and bitThing-size-in-words high."
	width := 4.
	depth := 8.
	bitThing class isBits ifFalse: [self error: 'bitThing must be a non-pointer object'].
	height := bitThing basicSize * bitThing bytesPerBasicElement // width.
	bits := bitThing
]

{ #category : #accessing }
Form >> hasBeenModified [
	"Return true if something *might* have been drawn into the receiver"
	^(bits == nil or:[bits class == ByteArray]) not
	"Read the above as: If the receiver has forgotten its contents (bits == nil) 
	or is still hibernated it can't be modified."
]

{ #category : #accessing }
Form >> hasBeenModified: aBool [
	"Change the receiver to reflect the modification state"
	aBool ifTrue:[^self unhibernate].
	self shouldPreserveContents
		ifTrue:[self hibernate]
		ifFalse:[bits := nil]
]

{ #category : #testing }
Form >> hasNonStandardPalette [
	"Return true if the receiver has a non-standard palette.
	Non-standard means that RGBA components may be located
	at positions differing from the standard Squeak RGBA layout
	at the receiver's depth."
	^false
]

{ #category : #'display box access' }
Form >> height [
	^ height
]

{ #category : #'fileIn\/Out' }
Form >> hibernate [
	"Replace my bitmap with a compactly encoded representation (a ByteArray).  It is vital that BitBlt and any other access to the bitmap (such as writing to a file) not be used when in this state.  Since BitBlt will fail if the bitmap size is wrong (not = bitsSize), we do not allow replacement by a byteArray of the same (or larger) size."

	"NOTE: This method copies code from Bitmap compressToByteArray so that it can
	nil out the old bits during the copy, thus avoiding 2x need for extra storage."
	| compactBits lastByte |
	(bits isMemberOf: Bitmap) ifFalse: [^ self  "already hibernated or weird state"].
	compactBits := ByteArray new: (bits size*4) + 7 + (bits size//1984*3).
	lastByte := bits compress: bits toByteArray: compactBits.
	lastByte < (bits size*4) ifTrue:
		[bits := nil.  "Let GC reclaim the old bits before the copy if necessary"
		bits := compactBits copyFrom: 1 to: lastByte]
]

{ #category : #private }
Form >> initFromArray: array [
	"Fill the bitmap from array.  If the array is shorter,
	then cycle around in its contents until the bitmap is filled."
	| ax aSize array32 i j word16 |
	ax := 0.
	aSize := array size.
	aSize > bits size ifTrue:
		["backward compatibility with old 16-bit bitmaps and their forms"
		array32 := Array new: height * (width + 31 // 32).
		i := j := 0.
		1 to: height do:
			[:y | 1 to: width+15//16 do:
				[:x16 | word16 := array at: (i := i + 1).
				x16 odd ifTrue: [array32 at: (j := j+1) put: (word16 bitShift: 16)]
						ifFalse: [array32 at: j put: ((array32 at: j) bitOr: word16)]]].
		^ self initFromArray: array32].
	1 to: bits size do:
		[:index |
		(ax := ax + 1) > aSize ifTrue: [ax := 1].
		bits at: index put: (array at: ax)]
]

{ #category : #analyzing }
Form >> innerPixelRectFor: pv orNot: not [
	"Return a rectangle describing the smallest part of me that includes 
	all pixels of value pv.
	Note:  If orNot is true, then produce a copy that includes all pixels
	that are DIFFERENT from the supplied (background) value"

	| xTally yTally |
	xTally := self xTallyPixelValue: pv orNot: not.
	yTally := self yTallyPixelValue: pv orNot: not.
	^ ((xTally findFirst: [:t | t>0]) - 1) @ ((yTally findFirst: [:t | t>0]) - 1)
		corner:
			(xTally findLast: [:t | t>0])@(yTally findLast: [:t | t>0])
]

{ #category : #testing }
Form >> isAllWhite [
	"Answer whether all bits in the receiver are white"
	| word |
	self unhibernate.
	word := Color white pixelWordForDepth: self depth.
	1 to: bits size do: [:i | (bits at: i) = word ifFalse: [^ false]].
	^ true
]

{ #category : #testing }
Form >> isBigEndian [
	"Return true if the receiver contains big endian pixels, meaning the left-most pixel is stored in the most significant bits of a word."
	^depth > 0
]

{ #category : #testing }
Form >> isDisplayScreen [
	^false
]

{ #category : #testing }
Form >> isForm [
	^true
]

{ #category : #testing }
Form >> isGrayScale [
	^ false
]

{ #category : #testing }
Form >> isLittleEndian [
	"Return true if the receiver contains little endian pixels, meaning the left-most pixel is stored in the least significant bits of a word."
	^depth < 0
]

{ #category : #testing }
Form >> isStatic [

	^false
]

{ #category : #testing }
Form >> isTranslucent [
	"Answer whether this form may be translucent"
	^self depth = 32
]

{ #category : #'pixel access' }
Form >> isTransparentAt: aPoint [ 
	"Return true if the receiver is transparent at the given point."

	self depth = 1 ifTrue: [^ false].  "no transparency at depth 1"
	^ (self pixelValueAt: aPoint) = (self pixelValueFor: Color transparent)

]

{ #category : #converting }
Form >> lighter [
	"Answer a lighter variant of this form"
	^self collectColors:[:color| color lighter lighter].
]

{ #category : #'scaling, rotation' }
Form >> magnify: aRectangle by: scale [ 
	"Answer a Form created as a scaling of the receiver.
	Scale may be a Float, and may be greater or less than 1.0."
	^ self magnify: aRectangle by: scale smoothing: 1

"Dynamic test...
[Sensor anyButtonPressed] whileFalse:
	[(Display magnify: (Sensor cursorPoint extent: 31@41) by: 5@3) display]
"
"Scaling test...
| f cp | f := Form fromDisplay: (Rectangle originFromUser: 100@100).
Display restoreAfter: [Sensor waitNoButton.
[Sensor anyButtonPressed] whileFalse:
	[cp := Sensor cursorPoint.
	(f magnify: f boundingBox by: (cp x asFloat@cp y asFloat)/f extent) display]]
"
"Consistency test...
 | f f2 p | [Sensor anyButtonPressed] whileFalse:
	[f := Form fromDisplay: ((p := Sensor cursorPoint) extent: 31@41).
	Display fillBlack: (p extent: 31@41).
	f2 := f magnify: f boundingBox by: 5@3.
	(f2 shrink: f2 boundingBox by: 5@3) displayAt: p]
"

]

{ #category : #'scaling, rotation' }
Form >> magnify: aRectangle by: scale smoothing: cellSize [
        "Answer a Form created as a scaling of the receiver.
        Scale may be a Float or even a Point, and may be greater or less than 1.0."
        | newForm |
        newForm := self blankCopyOf: aRectangle scaledBy: scale.
        (WarpBlt toForm: newForm)
                sourceForm: self;
                colorMap: (self colormapIfNeededFor: newForm);
                cellSize: cellSize;  "installs a new colormap if cellSize > 1"
                combinationRule: 3;
                copyQuad: aRectangle innerCorners toRect: newForm boundingBox.
        ^ newForm

"Dynamic test...
[Sensor anyButtonPressed] whileFalse:
        [(Display magnify: (Sensor cursorPoint extent: 131@81) by: 0.5 smoothing: 2) display]
"
"Scaling test...
| f cp | f := Form fromDisplay: (Rectangle originFromUser: 100@100).
Display restoreAfter: [Sensor waitNoButton.
[Sensor anyButtonPressed] whileFalse:
        [cp := Sensor cursorPoint.
        (f magnify: f boundingBox by: (cp x asFloat@cp y asFloat)/f extent smoothing: 2) display]]
"
]

{ #category : #'scaling, rotation' }
Form >> magnifyBy: scale [ 
	"Answer a Form created as a scaling of the receiver.
	Scale may be a Float or even a Point, and may be greater or less than 1.0."
	| effectiveScale |
	effectiveScale := scale isPoint ifTrue: [scale r] ifFalse: [scale].
	^ self magnify: self boundingBox by: scale
			smoothing: (effectiveScale < 1 ifTrue: [2] ifFalse: [1])
]

{ #category : #'color mapping' }
Form >> makeBWForm: foregroundColor [
	"Map this form into a B/W form with 1's in the foreground regions."
	| bwForm map |
	bwForm := Form extent: self extent.
	map := self newColorMap.  "All non-foreground go to 0's"
	map at: (foregroundColor indexInMap: map) put: 1.
	bwForm copyBits: self boundingBox from: self at: 0@0 colorMap: map.
	^ bwForm
]

{ #category : #'color mapping' }
Form >> mapColor: oldColor to: newColor [
	"Make all pixels of the given color in this Form to the given new color."
	"Warnings: This method modifies the receiver. It may lose some color accuracy on 32-bit Forms, since the transformation uses a color map with only 15-bit resolution."

	| map |
	map := (Color cachedColormapFrom: self depth to: self depth) copy.
	map at: (oldColor indexInMap: map) put: (newColor pixelWordForDepth: self depth).
	(BitBlt toForm: self)
		sourceForm: self;
		sourceOrigin: 0@0;
		combinationRule: Form over;
		destX: 0 destY: 0 width: width height: height;
		colorMap: map;
		copyBits.

]

{ #category : #'color mapping' }
Form >> mapColors: oldColorBitsCollection to: newColorBits [
	"Make all pixels of the given color in this Form to the given new color."
	"Warnings: This method modifies the receiver. It may lose some color accuracy on 32-bit Forms, since the transformation uses a color map with only 15-bit resolution."

	| map |
	self depth < 16
		ifTrue: [map := (Color cachedColormapFrom: self depth to: self depth) copy]
		ifFalse: [
			"use maximum resolution color map"
			"source is 16-bit or 32-bit RGB; use colormap with 5 bits per color component"
			map := Color computeRGBColormapFor: self depth bitsPerColor: 5].
	oldColorBitsCollection do:[ :oldColor | map at: oldColor put: newColorBits].

	(BitBlt toForm: self)
		sourceForm: self;
		sourceOrigin: 0@0;
		combinationRule: Form over;
		destX: 0 destY: 0 width: width height: height;
		colorMap: map;
		copyBits.

]

{ #category : #'color mapping' }
Form >> maskingMap [
	"Return a color map that maps all colors except transparent to words of all ones. Used to create a mask for a Form whose transparent pixel value is zero."
	^Color maskingMap: self depth
]

{ #category : #accessing }
Form >> nativeDepth [
	"Return the 'native' depth of the receiver, e.g., including the endianess"
	^depth
]

{ #category : #'color mapping' }
Form >> newColorMap [ 
	"Return an uninitialized color map array appropriate to this Form's depth."

	^ Bitmap new: (1 bitShift: (self depth min: 15))

]

{ #category : #'postscript generation' }
Form >> numComponents [
	^self depth <= 8 ifTrue:[1] ifFalse:[3].

]

{ #category : #'fileIn\/Out' }
Form >> objectForDataStream: refStream [
	| prj repl |
	prj := refStream project.
	prj ifNil:[^super objectForDataStream: refStream].
	ResourceCollector current ifNil:[^super objectForDataStream: refStream].
	repl := ResourceCollector current objectForDataStream: refStream fromForm: self.
	^repl
]

{ #category : #accessing }
Form >> offset [
	^offset ifNil:[0@0]
]

{ #category : #accessing }
Form >> offset: aPoint [

	offset := aPoint
]

{ #category : #converting }
Form >> orderedDither32To16 [
	"Do an ordered dithering for converting from 32 to 16 bit depth."
	| ditherMatrix ii out inBits outBits index pv dmv r di dmi dmo g b pvOut outIndex |
	self depth = 32 ifFalse:[^self error:'Must be 32bit for this'].
	ditherMatrix := #(	0	8	2	10
						12	4	14	6
						3	11	1	9
						15	7	13	5).
	ii := (0 to: 31) collect:[:i| i].
	out := Form extent: self extent depth: 16.
	inBits := self bits.
	outBits := out bits.
	index := outIndex := 0.
	pvOut := 0.
	0 to: self height-1 do:[:y|
		0 to: self width-1 do:[:x|
			pv := inBits at: (index := index + 1).
			dmv := ditherMatrix at: (y bitAnd: 3) * 4 + (x bitAnd: 3) + 1.
			r := pv bitAnd: 255.	di := r * 496 bitShift: -8.
			dmi := di bitAnd: 15.	dmo := di bitShift: -4.
			r := dmv < dmi ifTrue:[ii at: 2+dmo] ifFalse:[ii at: 1+dmo].
			g := (pv bitShift: -8) bitAnd: 255.	di := g * 496 bitShift: -8.
			dmi := di bitAnd: 15.	dmo := di bitShift: -4.
			g := dmv < dmi ifTrue:[ii at: 2+dmo] ifFalse:[ii at: 1+dmo].
			b := (pv bitShift: -16) bitAnd: 255.	di := b * 496 bitShift: -8.
			dmi := di bitAnd: 15.	dmo := di bitShift: -4.
			b := dmv < dmi ifTrue:[ii at: 2+dmo] ifFalse:[ii at: 1+dmo].
			pvOut := (pvOut bitShift: 16) + 
						(b bitShift: 10) + (g bitShift: 5) + r.
			(x bitAnd: 1) = 1 ifTrue:[
				outBits at: (outIndex := outIndex+1) put: pvOut.
				pvOut := 0].
		].
		(self width bitAnd: 1) = 1 ifTrue:[
			outBits at: (outIndex := outIndex+1) put: (pvOut bitShift: -16).
			pvOut := 0].
	].
	^out
]

{ #category : #'postscript generation' }
Form >> paddedWidth [
	^ (self width + (self rowPadding-1)// self rowPadding) * self rowPadding.
]

{ #category : #transitions }
Form >> pageImage: otherImage at: topLeft corner: corner [
	"Produce a page-turning illusion that gradually reveals otherImage
	located at topLeft in this form.  Corner specifies which corner, as
		1=topLeft, 2=topRight, 3=bottomRight, 4=bottomLeft."
	| bb maskForm resultForm delta maskLoc maskRect stepSize cornerSel smallRect |
	stepSize := 10.
	bb := otherImage boundingBox.
	resultForm := self copy: (topLeft extent: bb extent).
	maskForm := Form extent: ((otherImage width min: otherImage height) + stepSize) asPoint.

	"maskLoc := starting loc rel to topLeft"
	otherImage width > otherImage height
		ifTrue: ["wide image; motion is horizontal."
				(corner between: 2 and: 3) not ifTrue:
					["motion is to the right"
					delta := 1 @ 0.
					maskLoc := bb topLeft - (corner = 1
						ifTrue: [maskForm width @ 0]
						ifFalse: [maskForm width @ stepSize])]
					ifFalse:
					["motion is to the left"
					delta := -1 @ 0.
					maskLoc := bb topRight - (corner = 2
						ifTrue: [0 @ 0]
						ifFalse: [0 @ stepSize])]]
		ifFalse: ["tall image; motion is vertical."
				corner <= 2 ifTrue:
					["motion is downward"
					delta := 0 @ 1.
					maskLoc := bb topLeft - (corner = 1
						ifTrue: [0 @ maskForm height]
						ifFalse: [stepSize @ maskForm height])]
					ifFalse:
					["motion is upward"
					delta := 0 @ -1.
					maskLoc := bb bottomLeft - (corner = 3
						ifTrue: [stepSize @ 0]
						ifFalse: [0 @ 0])]].

	"Build a solid triangle in the mask form"
	(Pen newOnForm: maskForm) in: [:p |
		corner even  "Draw 45-degree line"
			ifTrue: [p place: 0 @ 0; turn: 135; go: maskForm width * 3 // 2]
			ifFalse: [p place: 0 @ (maskForm height - 1); turn: 45; go: maskForm width * 3 // 2]].
	maskForm smear: delta negated distance: maskForm width.
	"Copy the mask to full resolution for speed.  Make it be the reversed
	so that it can be used for ORing in the page-corner color"
	maskForm := (Form extent: maskForm extent depth: otherImage depth)
		copyBits: maskForm boundingBox from: maskForm at: 0 @ 0
		colorMap: (Bitmap with: 16rFFFFFFFF with: 0).

	"Now move the triangle maskForm across the resultForm selecting the
	triangular part of otherImage to display, and across the resultForm,
	selecting the part of the original image to erase."
	cornerSel := #(topLeft topRight bottomRight bottomLeft) at: corner.
	1 to: (otherImage width + otherImage height // stepSize) + 1 do:
		[:i |		"Determine the affected square"
		maskRect := (maskLoc extent: maskForm extent) intersect: bb.
		((maskLoc x * delta x) + (maskLoc y * delta y)) < 0 ifTrue:
			[smallRect := 0 @ 0 extent: (maskRect width min: maskRect height) asPoint.
			maskRect := smallRect align: (smallRect perform: cornerSel)
								with: (maskRect perform: cornerSel)].

		"AND otherForm with triangle mask, and OR into result"
		resultForm copyBits: bb from: otherImage at: 0 @ 0
				clippingBox: maskRect rule: Form over fillColor: nil.
		resultForm copyBits: maskForm boundingBox from: maskForm at: maskLoc
				clippingBox: maskRect rule: Form erase fillColor: nil.
		resultForm copyBits: maskForm boundingBox from: maskForm at: maskLoc
				clippingBox: maskRect rule: Form under fillColor: Color lightBrown.

		"Now update Display in a single BLT."
		self copyBits: maskRect from: resultForm at: topLeft + maskRect topLeft
				clippingBox: self boundingBox rule: Form over fillColor: nil.
		Display forceDisplayUpdate.
		maskLoc := maskLoc + (delta * stepSize)]
"
1 to: 4 do: [:corner | Display pageImage:
				(Form fromDisplay: (10@10 extent: 200@300)) reverse
			at: 10@10 corner: corner]
"

]

{ #category : #transitions }
Form >> pageWarp: otherImage at: topLeft forward: forward [
	"Produce a page-turning illusion that gradually reveals otherImage
	located at topLeft in this form.
	forward == true means turn pages toward you, else away. [ignored for now]"
	| pageRect oldPage nSteps buffer p leafRect sourceQuad warp oldBottom d |
	pageRect := otherImage boundingBox.
	oldPage := self copy: (pageRect translateBy: topLeft).
	(forward ifTrue: [oldPage] ifFalse: [otherImage])
		border: pageRect
		widthRectangle: (Rectangle
				left: 0
				right: 2
				top: 1
				bottom: 1)
		rule: Form over
		fillColor: Color black.
	oldBottom := self copy: ((pageRect bottomLeft + topLeft) extent: (pageRect width@(pageRect height//4))).
	nSteps := 8.
	buffer := Form extent: otherImage extent + (0@(pageRect height//4)) depth: self depth.
	d := pageRect topLeft + (0@(pageRect height//4)) - pageRect topRight.
	1 to: nSteps-1 do:
		[:i | forward
			ifTrue: [buffer copy: pageRect from: otherImage to: 0@0 rule: Form over.
					p := pageRect topRight + (d * i // nSteps)]
			ifFalse: [buffer copy: pageRect from: oldPage to: 0@0 rule: Form over.
					p := pageRect topRight + (d * (nSteps-i) // nSteps)].
		buffer copy: oldBottom boundingBox from: oldBottom to: pageRect bottomLeft rule: Form over.
		leafRect := pageRect topLeft corner: p x @ (pageRect bottom + p y).
		sourceQuad := Array with: pageRect topLeft
			with: pageRect bottomLeft + (0@p y)
			with: pageRect bottomRight
			with: pageRect topRight - (0@p y).
		warp := (WarpBlt toForm: buffer)
				clipRect: leafRect;
				sourceForm: (forward ifTrue: [oldPage] ifFalse: [otherImage]);
				combinationRule: Form paint.
		warp copyQuad: sourceQuad toRect: leafRect.
		self copy: buffer boundingBox from: buffer to: topLeft rule: Form over.
		Display forceDisplayUpdate].

	buffer copy: pageRect from: otherImage to: 0@0 rule: Form over.
	buffer copy: oldBottom boundingBox from: oldBottom to: pageRect bottomLeft rule: Form over.
	self copy: buffer boundingBox from: buffer to: topLeft rule: Form over.
	Display forceDisplayUpdate.
"
1 to: 4 do: [:corner | Display pageWarp:
				(Form fromDisplay: (10@10 extent: 200@300)) reverse
			at: 10@10 forward: false]
"

]

{ #category : #displaying }
Form >> paintBits: sourceForm at: destOrigin translucent: factor [
	"Make up a BitBlt table and copy the bits with the given colorMap."
	(BitBlt destForm: self
		sourceForm: sourceForm
		halftoneForm: nil
		combinationRule: 31
		destOrigin: destOrigin
		sourceOrigin: 0@0
		extent: sourceForm extent
		clipRect: self boundingBox)
		copyBitsTranslucent: ((0 max: (factor*255.0) asInteger) min: 255)
"
 | f f2 f3 | f := Form fromUser. f replaceColor: f peripheralColor withColor: Color transparent.
f2 := Form fromDisplay: (0@0 extent: f extent). f3 := f2 deepCopy.
0.0 to: 1.0 by: 1.0/32 do:
	[:t | f3 := f2 deepCopy. f3 paintBits: f at: 0@0 translucent: t.
	f3 displayAt: 0@0. (Delay forMilliseconds: 100) wait].
"
]

{ #category : #analyzing }
Form >> pixelCompare: aRect with: otherForm at: otherLoc [
	"Compare the selected bits of this form (those within aRect) against
	those in a similar rectangle of otherFrom.  Return the sum of the
	absolute value of the differences of the color values of every pixel.
	Obviously, this is most useful for rgb (16- or 32-bit) pixels but,
	in the case of 8-bits or less, this will return the sum of the differing
	bits of the corresponding pixel values (somewhat less useful)"
	| pixPerWord temp |
	pixPerWord := 32//self depth.
	(aRect left\\pixPerWord = 0 and: [aRect right\\pixPerWord = 0]) ifTrue:
		["If word-aligned, use on-the-fly difference"
		^ (BitBlt toForm: self) copy: aRect from: otherLoc in: otherForm
				fillColor: nil rule: 32].
	"Otherwise, combine in a word-sized form and then compute difference"
	temp := self copy: aRect.
	temp copy: aRect from: otherLoc in: otherForm rule: 21.
	^ (BitBlt toForm: temp) copy: aRect from: otherLoc in: nil
				fillColor: (Bitmap with: 0) rule: 32
"  Dumb example prints zero only when you move over the original rectangle...
 | f diff | f := Form fromUser.
[Sensor anyButtonPressed] whileFalse:
	[diff := f pixelCompare: f boundingBox
		with: Display at: Sensor cursorPoint.
	diff printString , '        ' displayAt: 0@0]
"
]

{ #category : #'pixel access' }
Form >> pixelValueAt: aPoint [ 
	"Return the raw pixel value at the given point. This pixel value depends on the receiver's depth. Typical clients use colorAt: to get a Color.  "

	^ self primPixelValueAtX: aPoint x y: aPoint y
]

{ #category : #'pixel access' }
Form >> pixelValueAt: aPoint put: pixelValue [
	"Store the given raw pixel value at the given point. Typical clients use colorAt:put: to store a color. "

	(BitBlt bitPokerToForm: self) pixelAt: aPoint put: pixelValue.

]

{ #category : #'color mapping' }
Form >> pixelValueFor: aColor [
	"Return the pixel word for representing the given color on the receiver"
	^aColor pixelValueForDepth: self depth
]

{ #category : #'color mapping' }
Form >> pixelWordFor: aColor [
	"Return the pixel word for representing the given color on the receiver"
	^aColor pixelWordForDepth: self depth
]

{ #category : #copying }
Form >> postCopy [
	super postCopy.
	bits := bits copy

]

{ #category : #other }
Form >> preMultiplyAlpha [
	"Pre-multiply each pixel by its alpha, for proper alpha compositing (BitBlt rule 34).
	E.g., half-transparent green 16r7F00FF00 becomes 16r7F007F00"

	depth = 32 ifFalse: [^self].
	1 to: bits size do: [:i |
		| v a r g b |
		v := bits at: i.
		a := v bitShift: -24.
		r := ((v bitShift: -16) bitAnd: 255) * a // 255.
		g := ((v bitShift: -8) bitAnd: 255) * a // 255.
		b := (v bitAnd: 255) * a // 255.
		bits at: i put: (a bitShift: 24) + (r bitShift: 16) + (g bitShift: 8) + b].
]

{ #category : #analyzing }
Form >> primCountBits [
	"Count the non-zero pixels of this form."
	self depth > 8 ifTrue:
		[^(self asFormOfDepth: 8) primCountBits].
	^ (BitBlt toForm: self)
		fillColor: (Bitmap with: 0);
		destRect: (0@0 extent: width@height);
		combinationRule: 32;
		copyBits
]

{ #category : #'pixel access' }
Form >> primPixelValueAtX: x y: y [ 
	"Return the raw pixel value at the given point. This pixel value depends on the receiver's depth. Typical clients use colorAt: to get a Color. Make sure the colorMap is nil for ColorForms "

	<primitive: 'primitivePixelValueAt' module:'BitBltPlugin'>
	^(BitBlt bitPeekerFromForm: self) colorMap: nil;  pixelAt: x@y
]

{ #category : #other }
Form >> primPrintHScale: hScale vScale: vScale landscape: aBoolean [
	"On platforms that support it, this primitive prints the receiver, assumed to be a Form, to the default printer."
	"(Form extent: 10@10) primPrintHScale: 1.0 vScale: 1.0 landscape: true"

	<primitive: 232>
	self primitiveFailed

]

{ #category : #'fileIn\/Out' }
Form >> printOn: aStream [
    aStream
        nextPutAll: self class name;
        nextPut: $(; print: width;
        nextPut: $x; print: height;
        nextPut: $x; print: depth;
        nextPut: $).

]

{ #category : #'postscript generation' }
Form >> printPostscript: aStream operator: operator [ 
	aStream preserveStateDuring: 
			[:inner | 
			inner rectclip: (0 @ 0 extent: width @ height).
			self setColorspaceOn: inner.
			inner
				print: '[ ';
				cr;
				print: '/ImageType 1';
				cr;
				print: '/ImageMatrix [1 0 0 1 0 0]';
				cr;
				print: '/MultipleDataSources false';
				cr;
				print: '/DataSource level1 { { currentfile ';
				write: self bytesPerRow;
				print: ' string readhexstring pop }} bind { currentfile /ASCIIHexDecode filter } ifelse';
				cr;
				print: '/Width ';
				write: self paddedWidth;
				cr;
				print: '/Height ';
				write: self height;
				cr;
				print: '/Decode ';
				print: self decodeArray;
				cr;
				print: '/BitsPerComponent ';
				write: self bitsPerComponent;
				cr;
				print: 'makeDict ';
				print: operator;
				cr.
			self storePostscriptHexOn: inner.
			inner
				print: $>;
				cr.
			inner cr].
	aStream cr
]

{ #category : #private }
Form >> privateFloodFillValue: aColor [
	"Private. Compute the pixel value in the receiver's depth but take into account implicit color conversions by BitBlt."
	| f1 f2 bb |
	f1 := Form extent: 1@1 depth: depth.
	f2 := Form extent: 1@1 depth: 32.
	bb := BitBlt toForm: f1.
	bb fillColor: aColor; 
		destRect: (0@0 corner: 1@1); 
		combinationRule: 3; 
		copyBits.
	bb := BitBlt toForm: f2.
	bb sourceForm: f1; 
		sourceOrigin: 0@0;
		destRect: (0@0 corner: 1@1);
		combinationRule: 3;
		copyBits.
	^f2 pixelValueAt: 0@0.
]

{ #category : #processing }
Form >> processUsingKernel: filter [

	^ self processUsingKernel: filter factor: 1.0 bias: 0.0
]

{ #category : #processing }
Form >> processUsingKernel: filter factor: factor bias: bias [
	| image result |

	image := self.
	result := Form extent: image extent depth: image depth.

	0 to: image height - 1 do: [:y |
		0 to: image width - 1 do: [:x |
			| r g b |
			r := g := b := 0.0.

			0 to: filter rowCount - 1 do: [:filterY |
				0 to: filter columnCount - 1 do: [:filterX |
					| imageX imageY |
					imageX := (x - (filter columnCount // 2) + filterX + image width) \\
								image width.
					imageY := (y - (filter rowCount // 2) + filterY + image height) \\
								image height.
					r := r + ((image colorAt: imageX@imageY) red *
								(filter at: filterY + 1 at: filterX + 1)).
					g := g + ((image colorAt: imageX@imageY) green *
								(filter at: filterY + 1 at: filterX + 1)).
					b := b + ((image colorAt: imageX@imageY) blue *
								(filter at: filterY + 1 at: filterX + 1))]].

			result colorAt: x@y put: (Color
				r: ((factor * r + bias) min: 1.0 max: 0.0)
				g: ((factor * g + bias) min: 1.0 max: 0.0)
				b: ((factor * b + bias) min: 1.0 max: 0.0))]].
	^ result

]

{ #category : #'fileIn\/Out' }
Form >> readAttributesFrom: aBinaryStream [
	| offsetX offsetY |
	depth := aBinaryStream next.
	(self depth isPowerOfTwo and: [self depth between: 1 and: 32])
		ifFalse: [self error: 'invalid depth; bad Form file?'].
	width := aBinaryStream nextWord.
	height := aBinaryStream nextWord.
	offsetX  := aBinaryStream nextWord.
	offsetY := aBinaryStream nextWord.
	offsetX > 32767 ifTrue: [offsetX := offsetX - 65536].
	offsetY > 32767 ifTrue: [offsetY := offsetY - 65536].
	offset := Point x: offsetX y: offsetY.
	

]

{ #category : #'fileIn\/Out' }
Form >> readBitsFrom: aBinaryStream [
	
	bits := Bitmap newFromStream: aBinaryStream.
	bits size = self bitsSize ifFalse: [self error: 'wrong bitmap size; bad Form file?'].
	^ self

]

{ #category : #'fileIn\/Out' }
Form >> readFrom: aBinaryStream [
	"Reads the receiver from the given binary stream with the format:
		depth, extent, offset, bits."
	self readAttributesFrom: aBinaryStream.
	self readBitsFrom: aBinaryStream
]

{ #category : #'fileIn\/Out' }
Form >> readFromOldFormat: aBinaryStream [
	"Read a Form in the original ST-80 format."

	| w h offsetX offsetY newForm theBits pos |
	self error: 'this method must be updated to read into 32-bit word bitmaps'.
	w := aBinaryStream nextWord.
	h := aBinaryStream nextWord.
	offsetX  := aBinaryStream nextWord.
	offsetY := aBinaryStream nextWord.
	offsetX > 32767 ifTrue: [offsetX := offsetX - 65536].
	offsetY > 32767 ifTrue: [offsetY := offsetY - 65536].
	newForm := Form extent: w @ h offset: offsetX @ offsetY.
	theBits := newForm bits.
	pos := 0.
	1 to: w + 15 // 16 do: [:j |
		1 to: h do: [:i |
			theBits at: (pos := pos+1) put: aBinaryStream nextWord]].
	newForm bits: theBits.
	^ newForm

]

{ #category : #resources }
Form >> readNativeResourceFrom: byteStream [
	| img aStream |
	aStream := byteStream.
	img := [ImageReadWriter formFromStream: aStream] on: Error do:[:ex| nil].
	img ifNil:[^nil].
	(img isColorForm and:[self isColorForm]) ifTrue:[
		| cc |
		cc := img colors.
		img colors: nil.
		img displayOn: self.
		img colors: cc.
	] ifFalse:[
		img displayOn: self.
	].
	img := nil.
]

{ #category : #resources }
Form >> readResourceFrom: aStream [ 
	"Store a resource representation of the receiver on aStream.
	Must be specific to the receiver so that no code is filed out."

	| bitsSize msb |
	(aStream next: 4) asString = self resourceTag 
		ifFalse: 
			[aStream position: aStream position - 4.
			^self readNativeResourceFrom: aStream].
	width := aStream nextNumber: 4.
	height := aStream nextNumber: 4.
	depth := aStream nextNumber: 4.
	bitsSize := aStream nextNumber: 4.
	bitsSize = 0 
		ifFalse: 
			[bits := aStream next: bitsSize.
			^self].
	msb := (aStream nextNumber: 4) = 1.
	bitsSize := aStream nextNumber: 4.
	bits := Bitmap new: self bitsSize.
	(Form 
		extent: width @ height
		depth: depth
		bits: (aStream next: bitsSize * 4)) displayOn: self.
	msb = Smalltalk isBigEndian 
		ifFalse: 
			[Bitmap 
				swapBytesIn: bits
				from: 1
				to: bits size]
]

{ #category : #analyzing }
Form >> rectangleEnclosingPixelsNotOfColor: aColor [
	"Answer the smallest rectangle enclosing all the pixels of me that are different from the given color. Useful for extracting a foreground graphic from its background."

	| cm slice copyBlt countBlt top bottom newH left right |
	"map the specified color to 1 and all others to 0"
	cm := Bitmap new: (1 bitShift: (self depth min: 15)).
	cm primFill: 1.
	cm at: (aColor indexInMap: cm) put: 0.

	"build a 1-pixel high horizontal slice and BitBlts for counting pixels of interest"
	slice := Form extent: width@1 depth: 1.
	copyBlt := (BitBlt toForm: slice)
		sourceForm: self;
		combinationRule: Form over;
		destX: 0 destY: 0 width: width height: 1;
		colorMap: cm.
	countBlt := (BitBlt toForm: slice)
		fillColor: (Bitmap with: 0);
		destRect: (0@0 extent: slice extent);
		combinationRule: 32.

	"scan in from top and bottom"
	top := (0 to: height)
		detect: [:y |
			copyBlt sourceOrigin: 0@y; copyBits.
			countBlt copyBits > 0]
		ifNone: [^ 0@0 extent: 0@0].
	bottom := (height - 1 to: top by: -1)
		detect: [:y |
			copyBlt sourceOrigin: 0@y; copyBits.
			countBlt copyBits > 0].

	"build a 1-pixel wide vertical slice and BitBlts for counting pixels of interest"
	newH := bottom - top + 1.
	slice := Form extent: 1@newH depth: 1.
	copyBlt := (BitBlt toForm: slice)
		sourceForm: self;
		combinationRule: Form over;
		destX: 0 destY: 0 width: 1 height: newH;
		colorMap: cm.
	countBlt := (BitBlt toForm: slice)
		fillColor: (Bitmap with: 0);
		destRect: (0@0 extent: slice extent);
		combinationRule: 32.

	"scan in from left and right"
	left := (0 to: width)
		detect: [:x |
			copyBlt sourceOrigin: x@top; copyBits.
			countBlt copyBits > 0].
	right := (width - 1 to: left by: -1)
		detect: [:x |
			copyBlt sourceOrigin: x@top; copyBits.
			countBlt copyBits > 0].

	^ left@top corner: (right + 1)@(bottom + 1)

]

{ #category : #'color mapping' }
Form >> reducedPaletteOfSize: nColors [
	"Return an array of colors of size nColors, such that those colors
	represent well the pixel values actually found in this form."
	| threshold tallies colorTallies dist delta palette cts top cluster |
	tallies := self tallyPixelValues.  "An array of tallies for each pixel value"
	threshold := width * height // 500.

	"Make an array of (color -> tally) for all tallies over threshold"
	colorTallies := Array streamContents:
		[:s | tallies withIndexDo:
			[:v :i | v >= threshold ifTrue:
				[s nextPut: (Color colorFromPixelValue: i-1 depth: depth) -> v]]].

	"Extract a set of clusters by picking the top tally, and then removing all others
	whose color is within dist of it.  Iterate the process, adjusting dist until we get nColors."
	dist := 0.2.  delta := dist / 2.
		[cts := colorTallies copy.
		palette := Array streamContents: [:s |
			[cts isEmpty] whileFalse:
				[top := cts detectMax: [:a | a value].
				cluster := cts select: [:a | (a key diff: top key) < dist].
				s nextPut: top key -> (cluster detectSum: [:a | a value]).
				cts := cts copyWithoutAll: cluster]].
		palette size = nColors or: [delta < 0.001]]
		whileFalse:
			[palette size > nColors
				ifTrue: [dist := dist + delta]
				ifFalse: [dist := dist - delta].
			delta := delta / 2].
	^ palette collect: [:a | a key]

]

{ #category : #other }
Form >> relativeTextAnchorPosition [

	^nil		"so forms can be in TextAnchors"
]

{ #category : #'fileIn\/Out' }
Form >> replaceByResource: aForm [
	"Replace the receiver by some resource that just got loaded"
	(self extent = aForm extent and:[self depth = aForm depth]) ifTrue:[
		bits := aForm bits.
	].
]

{ #category : #'image manipulation' }
Form >> replaceColor: oldColor withColor: newColor [
	"Replace one color with another everywhere is this form"

	| cm newInd target ff |
	self depth = 32
		ifTrue: [cm := (Color  cachedColormapFrom: 16 to: 32) copy]
		ifFalse: [cm := Bitmap new: (1 bitShift: (self depth min: 15)).
				1 to: cm size do: [:i | cm at: i put: i - 1]].
	newInd := newColor pixelValueForDepth: self depth.
	cm at: (oldColor pixelValueForDepth: (self depth min: 16))+1 put: newInd.
	target := newColor isTransparent 
		ifTrue: [ff := Form extent: self extent depth: depth.
			ff fillWithColor: newColor.  ff]
		ifFalse: [self].
	(BitBlt toForm: target)
		sourceForm: self;
		sourceOrigin: 0@0;
		combinationRule: Form paint;
		destX: 0 destY: 0 width: width height: height;
		colorMap: cm;
		copyBits.
	newColor = Color transparent 
		ifTrue: [target displayOn: self].
]

{ #category : #resources }
Form >> resourceTag [
	^'FORM'
]

{ #category : #'color mapping' }
Form >> rgbaBitMasks [
	"Return the masks for specifying the R,G,B, and A components in the receiver"
	self depth <= 8
		ifTrue:[^#(16rFF0000 16rFF00 16rFF 16rFF000000)].
	self depth = 16
		ifTrue:[^#(16r7C00 16r3E0 16r1F 16r0)].
	self depth = 32
		ifTrue:[^#(16rFF0000 16rFF00 16rFF 16rFF000000)].
	self error:'Bad depth for form'
]

{ #category : #'scaling, rotation' }
Form >> rotateBy: deg [
	"Rotate the receiver by the indicated number of degrees."
	"rot is the destination form, bit enough for any angle."

	^ self rotateBy: deg smoothing: 1
"
 | a f |  f := Form fromDisplay: (0@0 extent: 200@200).  a := 0.
[Sensor anyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor cursorPoint extent: 130@66))
		rotateBy: (a := a+5)) display].
f display
"
]

{ #category : #'scaling, rotation' }
Form >> rotateBy: direction centerAt: aPoint [
	"Return a rotated copy of the receiver. 
	direction = #none, #right, #left, or #pi"
	| newForm quad rot scale |
	direction == #none ifTrue: [^ self].
	scale :=  (direction = #pi ifTrue: [width@height] ifFalse: [height@width]) / self extent .
	newForm := self blankCopyOf: self boundingBox scaledBy: scale.
	quad := self boundingBox innerCorners.
	rot := #(right pi left) indexOf: direction.
	(WarpBlt toForm: newForm)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: newForm);
		combinationRule: 3;
		copyQuad: ((1+rot to: 4+rot) collect: [:i | quad atWrap: i])
			 toRect: newForm boundingBox.
	newForm offset: (self offset rotateBy: direction centerAt: aPoint).
	^ newForm
"
[Sensor anyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor cursorPoint extent: 130@66))
		rotateBy: #left centerAt: 0@0) display]
"
"Consistency test...
 | f f2 p | [Sensor anyButtonPressed] whileFalse:
	[f := Form fromDisplay: ((p := Sensor cursorPoint) extent: 31@41).
	Display fillBlack: (p extent: 31@41).
	f2 := f rotateBy: #left centerAt: 0@0.
	(f2 rotateBy: #right centerAt: 0@0) displayAt: p]
"

]

{ #category : #'scaling, rotation' }
Form >> rotateBy: deg magnify: scale smoothing: cellSize [
	"Rotate the receiver by the indicated number of degrees and magnify. scale can be a Point to make for interesting 3D effects "
	"rot is the destination form, big enough for any angle."

	| side rot warp r1 pts bigSide |
	side := 1 + self extent r asInteger.
	bigSide := (side asPoint * scale) rounded.
	rot := self blankCopyOf: self boundingBox scaledBy: ( bigSide / self extent ).
	warp := (WarpBlt toForm: rot)
		sourceForm: self;
		colorMap: (self colormapIfNeededFor: rot);
		cellSize: cellSize;  "installs a new colormap if cellSize > 1"
		combinationRule: Form paint.
	r1 := (0@0 extent: side@side) align: (side@side)//2 with: self boundingBox center.

	"Rotate the corners of the source rectangle." 
	pts := r1 innerCorners collect:
		[:pt | | p |
		p := pt - r1 center.
		(r1 center x asFloat + (p x asFloat*deg degreeCos) + (p y asFloat*deg degreeSin)) @
		(r1 center y asFloat - (p x asFloat*deg degreeSin) + (p y asFloat*deg degreeCos))].
	warp copyQuad: pts toRect: rot boundingBox.
	^ rot
"
 | a f |  f := Form fromDisplay: (0@0 extent: 200@200).  a := 0.
[Sensor anyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor cursorPoint extent: 130@66))
		rotateBy: (a := a+5) magnify: 0.75@2 smoothing: 2) display].
f display
"
]

{ #category : #'scaling, rotation' }
Form >> rotateBy: deg smoothing: cellSize [
	"Rotate the receiver by the indicated number of degrees."
	^self rotateBy: deg magnify: 1 smoothing: cellSize
"
 | a f |  f := Form fromDisplay: (0@0 extent: 200@200).  a := 0.
[Sensor anyButtonPressed] whileFalse:
	[((Form fromDisplay: (Sensor cursorPoint extent: 130@66))
		rotateBy: (a := a+5) smoothing: 2) display].
f display
"
]

{ #category : #'postscript generation' }
Form >> rowPadding [
	^ 32 // self depth
]

{ #category : #'scaling, rotation' }
Form >> scaledToSize: numberOrPoint [

	^ self scaledToSize: numberOrPoint smoothing: 2
]

{ #category : #'scaling, rotation' }
Form >> scaledToSize: numberOrPoint smoothing: factor [

	| scale newExtent |
	newExtent := numberOrPoint asPoint.
	
	newExtent = self extent ifTrue: [^ self copy].
	
	(self height isZero or: [self width isZero])
		ifTrue: [^ self species extent: newExtent depth: self depth].
		
	scale := newExtent x / self width min: newExtent y / self height.
	^ self magnify: self boundingBox by: scale smoothing: factor
]

{ #category : #other }
Form >> setAsBackground [
	"Set this form as a background image."

	Project current setAsBackground: self

]

{ #category : #'postscript generation' }
Form >> setColorspaceOn:aStream [
	self numComponents = 1 ifTrue:[aStream print:'/DeviceGray setcolorspace 0 setgray'; cr.]
		ifFalse:[aStream print:'/DeviceRGB setcolorspace'; cr.].
]

{ #category : #private }
Form >> setExtent: extent depth: bitsPerPixel [
	"Create a virtual bit map with the given extent and bitsPerPixel."

	width := extent x asInteger.
	width < 0 ifTrue: [width := 0].
	height := extent y asInteger.
	height < 0 ifTrue: [height := 0].
	depth := bitsPerPixel.
	bits := Bitmap new: self bitsSize
]

{ #category : #private }
Form >> setExtent: extent depth: bitsPerPixel bits: bitmap [
	"Create a virtual bit map with the given extent and bitsPerPixel."

	width := extent x asInteger.
	width < 0 ifTrue: [width := 0].
	height := extent y asInteger.
	height < 0 ifTrue: [height := 0].
	depth := bitsPerPixel.
	depth := bitsPerPixel.
	(bits isNil
		or:[(bitmap class isWords and: [self bitsSize = bitmap size])
		or: [bitmap class isBytes and: [self bitsSize * 4 = bitmap size]]])
			ifFalse:[^self error:'Bad dimensions'].
	bits := bitmap
]

{ #category : #private }
Form >> setResourceBits: aForm [
	"Private. Really. Used for setting the 'resource bits' when externalizing some form"
	bits := aForm.
]

{ #category : #bordering }
Form >> shapeBorder: aColor width: borderWidth [
	"A simplified version for shapes surrounded by transparency (as SketchMorphs).
	Note also this returns a new form that may be larger, and does not affect the original."
	| shapeForm borderForm newForm |
	newForm := Form extent: self extent + (borderWidth*2) depth: self depth.
	newForm fillColor: Color transparent.
	self displayOn: newForm at: (0@0) + borderWidth.
	"First identify the shape in question as a B/W form"
	shapeForm := (newForm makeBWForm: Color transparent) reverse.
	"Now find the border of that shape"
	borderForm := shapeForm borderFormOfWidth: borderWidth sharpCorners: false.
	"Finally use that shape as a mask to paint the border with color"
	^ newForm fillShape: borderForm fillColor: aColor
]

{ #category : #bordering }
Form >> shapeBorder: aColor width: borderWidth interiorPoint: interiorPoint
	sharpCorners: sharpen internal: internal [
	"Identify the shape (region of identical color) at interiorPoint,
	and then add an outline of width=borderWidth and color=aColor.
	If sharpen is true, then cause right angles to be outlined by
	right angles.  If internal is true, then produce a border that lies
	within the identified shape.  Thus one can put an internal border
	around the whole background, thus effecting a normal border
	around every other foreground image."
	| shapeForm borderForm interiorColor |
	"First identify the shape in question as a B/W form"
	interiorColor := self colorAt: interiorPoint.
	shapeForm := (self makeBWForm: interiorColor) reverse
				findShapeAroundSeedBlock:
					[:form | form pixelValueAt: interiorPoint put: 1].
	"Reverse the image to grow the outline inward"
	internal ifTrue: [shapeForm reverse].
	"Now find the border fo that shape"
	borderForm := shapeForm borderFormOfWidth: borderWidth sharpCorners: sharpen.
	"Finally use that shape as a mask to paint the border with color"
	self fillShape: borderForm fillColor: aColor
]

{ #category : #filling }
Form >> shapeFill: aColor interiorPoint: interiorPoint [
	"Identify the shape (region of identical color) at interiorPoint,
	and then fill that shape with the new color, aColor
	: modified di's original method such that it returns the bwForm, for potential use by the caller"

	| bwForm interiorPixVal map ppd color ind |
	self depth = 1 ifTrue:
		[^ self shapeFill: aColor
			seedBlock: [:form | form pixelValueAt: interiorPoint put: 1]].

	"First map this form into a B/W form with 0's in the interior region."
		"bwForm := self makeBWForm: interiorColor."	"won't work for two whites"
	interiorPixVal := self pixelValueAt: interiorPoint.
	bwForm := Form extent: self extent.
	map := Bitmap new: (1 bitShift: (self depth min: 12)).  "Not calling newColorMap.  All 
			non-foreground go to 0.  Length is 2 to 4096."
	ppd := self depth.	"256 long color map in depth 8 is not one of the following cases"
	3 to: 5 do: [:bitsPerColor | 
		(2 raisedTo: bitsPerColor*3) = map size 
			ifTrue: [ppd := bitsPerColor*3]].	"ready for longer maps than 512"

	ppd <= 8
		ifTrue: [map at: interiorPixVal+1 put: 1]
		ifFalse: [interiorPixVal = 0 
			ifFalse: [color := Color colorFromPixelValue: interiorPixVal depth: self depth.
				ind := color pixelValueForDepth: ppd.
				map at: ind+1 put: 1]
			ifTrue: [map at: 1 put: 1]].
	bwForm copyBits: self boundingBox from: self at: 0@0 colorMap: map.
	bwForm reverse.  "Make interior region be 0's"

	"Now fill the interior region and return that shape"
	bwForm := bwForm findShapeAroundSeedBlock:
					[:form | form pixelValueAt: interiorPoint put: 1].

	"Finally use that shape as a mask to flood the region with color"
	self eraseShape: bwForm.
	self fillShape: bwForm fillColor: aColor.
	^ bwForm
]

{ #category : #filling }
Form >> shapeFill: aColor seedBlock: seedBlock [
	self depth > 1 ifTrue: [self error: 'This call only meaningful for B/W forms'].
	(self findShapeAroundSeedBlock: seedBlock)
		displayOn: self at: 0@0 clippingBox: self boundingBox
		rule: Form under fillColor: aColor 
]

{ #category : #processing }
Form >> sharpen [

	^ self processUsingKernel: (Matrix rows: 3 columns: 3 contents: #(
		 0 -1  0
		-1  5 -1
		 0 -1  0
	))
]

{ #category : #testing }
Form >> shouldPreserveContents [
	"Return true if the receiver should preserve it's contents when flagged to be clean. Most forms can not be trivially restored by some drawing operation but some may."
	^true
]

{ #category : #'scaling, rotation' }
Form >> shrink: aRectangle by: scale [ 
	| scalePt |
	scalePt := scale asPoint.
	^ self magnify: aRectangle by: (1.0 / scalePt x asFloat) @ (1.0 / scalePt y asFloat)
]

{ #category : #'initialize-release' }
Form >> shutDown [
	"The system is going down. Try to preserve some space"
	self hibernate
]

{ #category : #accessing }
Form >> size [
	"Should no longer be used -- use bitsSize instead.  length of variable part of instance."
	^ super size
]

{ #category : #transitions }
Form >> slideImage: otherImage at: topLeft delta: delta [
	"Display slideImage: (Form fromDisplay: (40@40 extent: 300@300)) reverse
		at: 40@40 delta: 3@-4"
	| bb nSteps clipRect |
	bb := otherImage boundingBox.
	clipRect := topLeft extent: otherImage extent.
	nSteps := 1.
	delta x = 0 ifFalse: [nSteps := nSteps max: (bb width//delta x abs) + 1].
	delta y = 0 ifFalse: [nSteps := nSteps max: (bb height//delta y abs) + 1].
	1 to: nSteps do:
			[:i | self copyBits: bb from: otherImage
				at: delta*(i-nSteps) + topLeft
				clippingBox: clipRect rule: Form paint fillColor: nil.
			Display forceDisplayUpdate]
]

{ #category : #'image manipulation' }
Form >> smear: dir distance: dist [
	"Smear any black pixels in this form in the direction dir in Log N steps"
	| skew bb |
	bb := BitBlt destForm: self sourceForm: self fillColor: nil
		combinationRule: Form under destOrigin: 0@0 sourceOrigin: 0@0
		extent: self extent clipRect: self boundingBox.
	skew := 1.
	[skew < dist] whileTrue:
		[bb destOrigin: dir*skew; copyBits.
		skew := skew+skew]
]

{ #category : #'postscript generation' }
Form >> store15To24HexBitsOn:aStream [

	| buf lineWidth |

	"write data for 16-bit form, optimized for encoders writing directly to files to do one single file write rather than 12. I'm not sure I understand the significance of the shifting pattern, but I think I faithfully translated it from the original"

	lineWidth := 0.
	buf := String new: 12.
	self unhibernate.
	bits do: [:word | | i | 
		i := 0.
		"upper pixel"
		buf at: (i := i + 1) put: ((word bitShift: -27) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -32) bitAnd: 8) asHexDigit.

		buf at: (i := i + 1) put: ((word bitShift: -22) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -27) bitAnd: 8) asHexDigit.

		buf at: (i := i + 1) put: ((word bitShift: -17) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -22) bitAnd: 8) asHexDigit.

		"lower pixel"

		buf at: (i := i + 1) put: ((word bitShift: -11) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -16) bitAnd: 8) asHexDigit.

		buf at: (i := i + 1) put: ((word bitShift: -6) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -11) bitAnd: 8) asHexDigit.

		buf at: (i := i + 1) put: ((word bitShift: -1) bitAnd: 15) asHexDigit.
		buf at: (i := i + 1) put: ((word bitShift: -6) bitAnd: 8) asHexDigit.
		aStream nextPutAll: buf.
		lineWidth := lineWidth + 12.
		lineWidth > 100 ifTrue: [ aStream cr. lineWidth := 0 ].
		"#( 31 26 21 15 10 5 )  do:[:startBit | ]"
	].
]

{ #category : #'postscript generation' }
Form >> store32To24HexBitsOn:aStream [
	^self storeBits:20 to:0 on:aStream.
]

{ #category : #'postscript generation' }
Form >> storeBits:startBit to:stopBit on:aStream [
	self unhibernate.
	bits storeBits:startBit to:stopBit on:aStream.
]

{ #category : #'fileIn\/Out' }
Form >> storeBitsOn:aStream base:anInteger [
	self unhibernate.
	bits do: [:word | 
		anInteger = 10
			ifTrue: [aStream space]
			ifFalse: [aStream crtab: 2].
		word storeOn: aStream base: anInteger].

]

{ #category : #'postscript generation' }
Form >> storeHexBitsOn:aStream [
	^self storeBits:28 to:0 on:aStream.
]

{ #category : #'fileIn\/Out' }
Form >> storeOn: aStream [

	self storeOn: aStream base: 10
]

{ #category : #'fileIn\/Out' }
Form >> storeOn: aStream base: anInteger [ 
	"Store the receiver out as an expression that can be evaluated to recreate a Form with the same contents as the original."

	self unhibernate.
	aStream nextPut: $(.
	aStream nextPutAll: self species name.
	aStream crtab: 1.
	aStream nextPutAll: 'extent: '.
	self extent printOn: aStream.
	aStream crtab: 1.
	aStream nextPutAll: 'depth: '.
	self depth printOn: aStream.
	aStream crtab: 1.
	aStream nextPutAll: 'fromArray: #('.
	self storeBitsOn:aStream base:anInteger.
	aStream nextPut: $).
	aStream crtab: 1.
	aStream nextPutAll: 'offset: '.
	self offset printOn: aStream.
	aStream nextPut: $).

]

{ #category : #'postscript generation' }
Form >> storePostscriptHexOn: inner [ 
	self depth <= 8 ifTrue: [self storeHexBitsOn: inner].
	self depth = 16 ifTrue: [self store15To24HexBitsOn: inner].
	self depth = 32 ifTrue: [self store32To24HexBitsOn: inner]
]

{ #category : #resources }
Form >> storeResourceOn: aStream [
	"Store a resource representation of the receiver on aStream.
	Must be specific to the receiver so that no code is filed out."
	self hibernate.
	aStream nextPutAll: self resourceTag asByteArray. "tag"
	aStream nextNumber: 4 put: width.
	aStream nextNumber: 4 put: height.
	aStream nextNumber: 4 put: depth.
	(bits isMemberOf: ByteArray) ifFalse:[
		"must store bitmap"
		aStream nextNumber: 4 put: 0. "tag"
		aStream nextNumber: 4 put: (Smalltalk isBigEndian ifTrue:[1] ifFalse:[0]).
	].
	aStream nextNumber: 4 put: bits size.
	aStream nextPutAll: bits.

]

{ #category : #'initialize-release' }
Form >> swapEndianness [
	"Swap from big to little endian pixels and vice versa"
	depth := 0 - depth.
]

{ #category : #analyzing }
Form >> tallyPixelValues [
	"Answer a Bitmap whose elements contain the number of pixels in this Form with the pixel value corresponding to their index. Note that the pixels of multiple Forms can be tallied together using tallyPixelValuesInRect:into:."

	^ self tallyPixelValuesInRect: self boundingBox
		into: (Bitmap new: (1 bitShift: (self depth min: 15)))
"
Move a little rectangle around the screen and print its tallies...
 | r tallies nonZero |
Cursor blank showWhile: [
[Sensor anyButtonPressed] whileFalse:
	[r := Sensor cursorPoint extent: 10@10.
	Display border: (r expandBy: 2) width: 2 rule: Form reverse fillColor: nil.
	tallies := (Display copy: r) tallyPixelValues.
	nonZero := (1 to: tallies size) select: [:i | (tallies at: i) > 0]
			thenCollect: [:i | (tallies at: i) -> (i-1)].
	nonZero printString , '          ' displayAt: 0@0.
	Display border: (r expandBy: 2) width: 2 rule: Form reverse fillColor: nil]]
"

]

{ #category : #analyzing }
Form >> tallyPixelValuesInRect: destRect into: valueTable [
	"Tally the selected pixels of this Form into valueTable, a Bitmap of depth 2^depth similar to a color map. Answer valueTable."

	(BitBlt toForm: self)
		sourceForm: self;  "src must be given for color map ops"
		sourceOrigin: 0@0;
		tallyMap: valueTable;
		combinationRule: 33;
		destRect: destRect;
		copyBits.
	^ valueTable

"
Move a little rectangle around the screen and print its tallies...
 | r tallies nonZero |
Cursor blank showWhile: [
[Sensor anyButtonPressed] whileFalse:
	[r := Sensor cursorPoint extent: 10@10.
	Display border: (r expandBy: 2) width: 2 rule: Form reverse fillColor: nil.
	tallies := (Display copy: r) tallyPixelValues.
	nonZero := (1 to: tallies size) select: [:i | (tallies at: i) > 0]
			thenCollect: [:i | (tallies at: i) -> (i-1)].
	nonZero printString , '          ' displayAt: 0@0.
	Display border: (r expandBy: 2) width: 2 rule: Form reverse fillColor: nil]]
"
]

{ #category : #'image manipulation' }
Form >> trimBordersOfColor: aColor [
	"Answer a copy of this Form with each edge trimmed in to the first pixel that is not of the given color. (That is, border strips of the given color are removed)."

	| r |
	r := self rectangleEnclosingPixelsNotOfColor: aColor.
	^ self copy: r

]

{ #category : #'fileIn\/Out' }
Form >> unhibernate [
	"If my bitmap has been compressed into a ByteArray,
	then expand it now, and return true."
	| resBits |
	bits isForm ifTrue:[
		resBits := bits.
		bits := Bitmap new: self bitsSize.
		resBits displayResourceFormOn: self.
		^true].
	bits == nil ifTrue:[bits := Bitmap new: self bitsSize. ^true].
	(bits isMemberOf: ByteArray)
		ifTrue: [bits := Bitmap decompressFromByteArray: bits. ^ true].
	^ false
]

{ #category : #copying }
Form >> veryDeepCopyWith: deepCopier [
	"Return self.  I am immutable in the Morphic world.  Do not record me."
	^ self
]

{ #category : #'display box access' }
Form >> width [
	^ width
]

{ #category : #transitions }
Form >> wipeImage: otherImage at: topLeft clippingBox: clipBox rectForIndex: rectForIndexBlock [

	| i clipRect t rectOrList waitTime |
	i := 0.
	clipRect := topLeft extent: otherImage extent.
	clipBox ifNotNil: [clipRect := clipRect intersect: clipBox].
	[rectOrList := rectForIndexBlock value: (i := i + 1).
	 rectOrList == nil]
		whileFalse: [
			t := Time millisecondClockValue.
			rectOrList asOrderedCollection do: [:r |
				self copyBits: r from: otherImage at: topLeft + r topLeft
					clippingBox: clipRect rule: Form over fillColor: nil].
			Display forceDisplayUpdate.
			waitTime := 3 - (Time millisecondClockValue - t).
			waitTime > 0 ifTrue:
				["(Delay forMilliseconds: waitTime) wait"]].

]

{ #category : #transitions }
Form >> wipeImage: otherImage at: topLeft delta: delta [
	"Display wipeImage: (Form fromDisplay: (40@40 extent: 300@300)) reverse
		at: 40@40 delta: 0@-2"

	self wipeImage: otherImage at: topLeft delta: delta clippingBox: nil.

]

{ #category : #transitions }
Form >> wipeImage: otherImage at: topLeft delta: delta clippingBox: clipBox [

	| wipeRect bb nSteps |
	bb := otherImage boundingBox.
	wipeRect := delta x = 0
		ifTrue:
		[delta y = 0 ifTrue: [nSteps := 1. bb "allow 0@0"] ifFalse: [
		nSteps := bb height//delta y abs + 1.  "Vertical movement"
		delta y > 0
			ifTrue: [bb topLeft extent: bb width@delta y]
			ifFalse: [bb bottomLeft+delta extent: bb width@delta y negated]]]
		ifFalse:
		[nSteps := bb width//delta x abs + 1.  "Horizontal movement"
		delta x > 0
			ifTrue: [bb topLeft extent: delta x@bb height]
			ifFalse: [bb topRight+delta extent: delta x negated@bb height]].
	^ self wipeImage: otherImage at: topLeft clippingBox: clipBox rectForIndex:
		[:i | i <= nSteps
			ifTrue: [wipeRect translateBy: (delta* (i-1))]
			ifFalse: [nil]]
]

{ #category : #'fileIn\/Out' }
Form >> writeAttributesOn: file [
	self unhibernate.
	file nextPut: depth.
	file nextWordPut: width.
	file nextWordPut: height.
	file nextWordPut: ((self offset x) >=0
					ifTrue: [self offset x]
					ifFalse: [self offset x + 65536]).
	file nextWordPut: ((self offset y) >=0
					ifTrue: [self offset y]
					ifFalse: [self offset y + 65536]).
	
]

{ #category : #'fileIn\/Out' }
Form >> writeBMPfileNamed: fName [  "Display writeBMPfileNamed: 'display.bmp'"
	BMPReadWriter putForm: self onFileNamed: fName
]

{ #category : #'fileIn\/Out' }
Form >> writeBitsOn: file [
	bits writeOn: file
]

{ #category : #'fileIn\/Out' }
Form >> writeJPEGfileNamed: fileName [ 
	"Write a JPEG file to the given filename using default settings"

	self writeJPEGfileNamed: fileName progressive: false

"
Display writeJPEGfileNamed: 'display.jpeg'
Form fromUser writeJPEGfileNamed: 'yourPatch.jpeg'
"
]

{ #category : #'fileIn\/Out' }
Form >> writeJPEGfileNamed: fileName  progressive: aBoolean [
	"Write a JPEG file to the given filename using default settings.  Make it progressive or not, depending on the boolean argument"

	JPEGReadWriter2 putForm: self quality: -1 "default" progressiveJPEG: aBoolean onFileNamed: fileName

"
Display writeJPEGfileNamed: 'display.jpeg' progressive: false.
Form fromUser writeJPEGfileNamed: 'yourPatch.jpeg' progressive: true
"
]

{ #category : #'fileIn\/Out' }
Form >> writeOn: file [
	"Write the receiver on the file in the format
		depth, extent, offset, bits."
	self writeAttributesOn: file.
	self writeBitsOn: file
]

{ #category : #'fileIn\/Out' }
Form >> writeOnMovie: file [
	"Write just my bits on the file."
	self unhibernate.
	bits writeUncompressedOn: file
]

{ #category : #'fileIn\/Out' }
Form >> writePNGfileNamed: fName [  "Display writePNGfileNamed: 'display.png'"
	PNGReadWriter putForm: self onFileNamed: fName
]

{ #category : #'fileIn\/Out' }
Form >> writeUncompressedOn: file [
	"Write the receiver on the file in the format depth, extent, offset, bits.  Warning:  Caller must put header info on file!  Use writeUncompressedOnFileNamed: instead."
	self unhibernate.
	file binary.
	file nextPut: depth.
	file nextWordPut: width.
	file nextWordPut: height.
	file nextWordPut: ((self offset x) >=0
					ifTrue: [self offset x]
					ifFalse: [self offset x + 65536]).
	file nextWordPut: ((self offset y) >=0
					ifTrue: [self offset y]
					ifFalse: [self offset y + 65536]).
	bits writeUncompressedOn: file
]

{ #category : #analyzing }
Form >> xTallyPixelValue: pv orNot: not [
	"Return an array of the number of pixels with value pv by x-value.
	Note that if not is true, then this will tally those different from pv."
	| cm slice countBlt copyBlt |
	cm := self newColorMap.		"Map all colors but pv to zero"
	not ifTrue: [cm atAllPut: 1].		"... or all but pv to one"
	cm at: pv+1 put: 1 - (cm at: pv+1).
	slice := Form extent: 1@height.
	copyBlt := (BitBlt destForm: slice sourceForm: self
				halftoneForm: nil combinationRule: Form over
				destOrigin: 0@0 sourceOrigin: 0@0 extent: 1 @ slice height
				clipRect: slice boundingBox) colorMap: cm.
	countBlt := (BitBlt toForm: slice)
				fillColor: (Bitmap with: 0);
				destRect: (0@0 extent: slice extent);
				combinationRule: 32.
	^ (0 to: width-1) collect:
		[:x |
		copyBlt sourceOrigin: x@0; copyBits.
		countBlt copyBits]
]

{ #category : #analyzing }
Form >> yTallyPixelValue: pv orNot: not [
	"Return an array of the number of pixels with value pv by y-value.
	Note that if not is true, then this will tally those different from pv."
	| cm slice copyBlt countBlt |
	cm := self newColorMap.		"Map all colors but pv to zero"
	not ifTrue: [cm atAllPut: 1].		"... or all but pv to one"
	cm at: pv+1 put: 1 - (cm at: pv+1).
	slice := Form extent: width@1.
	copyBlt := (BitBlt destForm: slice sourceForm: self
				halftoneForm: nil combinationRule: Form over
				destOrigin: 0@0 sourceOrigin: 0@0 extent: slice width @ 1
				clipRect: slice boundingBox) colorMap: cm.
	countBlt := (BitBlt toForm: slice)
				fillColor: (Bitmap with: 0);
				destRect: (0@0 extent: slice extent);
				combinationRule: 32.
	^ (0 to: height-1) collect:
		[:y |
		copyBlt sourceOrigin: 0@y; copyBits.
		countBlt copyBits]
]

{ #category : #transitions }
Form >> zoomIn: goingIn orOutTo: otherImage at: topLeft vanishingPoint: vp [ 
	"Display zoomInTo: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40.
	Display zoomOutTo: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40."
	| nSteps minTime startTime |
	nSteps := 16.
	minTime := 500.  "milliseconds"
	startTime := Time millisecondClockValue.
	^ self wipeImage: otherImage at: topLeft clippingBox: nil rectForIndex:
		[:i | | lead bigR j lilR | "i runs from 1 to nsteps"
		i > nSteps
			ifTrue: [nil "indicates all done"]
			ifFalse:
			["If we are going too fast, delay for a bit"
			lead := startTime + (i-1*minTime//nSteps) - Time millisecondClockValue.
			lead > 10 ifTrue: [(Delay forMilliseconds: lead) wait].

			"Return an array with the difference rectangles for this step."
			j := goingIn ifTrue: [i] ifFalse: [nSteps+1-i].
			bigR := vp - (vp*(j)//nSteps) corner:
				vp + (otherImage extent-vp*(j)//nSteps).
			lilR := vp - (vp*(j-1)//nSteps) corner:
				vp + (otherImage extent-vp*(j-1)//nSteps).
			bigR areasOutside: lilR]]
]

{ #category : #transitions }
Form >> zoomInTo: otherImage at: topLeft [
	"Display zoomInTo: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40"
	^ self zoomIn: true orOutTo: otherImage at: topLeft
		vanishingPoint: otherImage extent//2+topLeft
]

{ #category : #transitions }
Form >> zoomOutTo: otherImage at: topLeft [
	"Display zoomOutTo: (Form fromDisplay: (40@40 extent: 300@300)) reverse at: 40@40"
	^ self zoomIn: false orOutTo: otherImage at: topLeft
		vanishingPoint: otherImage extent//2+topLeft
]
