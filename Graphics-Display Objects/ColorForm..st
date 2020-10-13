"
ColorForm is a normal Form plus a color map of up to 2^depth Colors. Typically, one reserves one entry in the color map for transparent. This allows 1, 3, 15, or 255 non-transparent colors in ColorForms of depths 1, 2, 4, and 8 bits per pixel. ColorForms don't support depths greater than 8 bits because that would require excessively large color maps with little real benefit, since 16-bit and 32-bit depths already support thousands and millions of colors.

ColorForms have several uses:
  1) Precise colors. You can have up to 256 true colors, instead being limited to the 8-bit color palette.
  2) Easy transparency. Just store (Color transparent) at the desired position in the color map.
  3) Cheap color remapping by changing the color map.

A color map is an Array of up to 2^depth Color objects. A Bitmap colorMap is automatically computed and cached for rapid display. Note that if you change the color map, you must resubmit it via the colors: method to flush this cache.

ColorForms can be a bit tricky. Note that:
  a) When you BitBlt from one ColorForm to another, you must remember to copy the color map of the source ColorForm to the destination ColorForm.
  b) A ColorForm's color map is an array of depth-independent Color objects. BitBlt requires a BitMap of actual pixel values, adjusted to the destination depth. These are different things! ColorForms automatically maintain a cache of the BitBlt-style color map corresponding to the colors array for the last depth on which the ColorForm was displayed, so there should be little need for clients to work with BitBlt-style color maps.
  c) The default map for 8 bit depth has black in the first entry, not transparent.  Say (cform colors at: 1 put: Color transparent).

"
Class {
	#name : #ColorForm,
	#superclass : #Form,
	#instVars : [
		'colors',
		'cachedDepth',
		'cachedColormap'
	],
	#classInstVars : [
		'grayScalePalette'
	],
	#category : #'Graphics-Display Objects'
}

{ #category : #constants }
ColorForm class >> grayScalePalette [
	grayScalePalette ifNil: [
		grayScalePalette := (0 to: 255) collect: [:brightness | Color gray: brightness asFloat / 255.0].
		grayScalePalette at: 1 put: Color transparent].
	^ grayScalePalette
]

{ #category : #'as yet unclassified' }
ColorForm class >> mappingWhiteToTransparentFrom: aFormOrCursor [
	"Return a ColorForm copied from the given Form or Cursor with white mapped to transparent."

	| f map |
	aFormOrCursor depth <= 8 ifFalse: [
		^ self error: 'argument depth must be 8-bits per pixel or less'].
	(aFormOrCursor isColorForm) ifTrue: [
		f := aFormOrCursor deepCopy.
		map := aFormOrCursor colors.
	] ifFalse: [
		f := ColorForm extent: aFormOrCursor extent depth: aFormOrCursor depth.
		f copyBits: aFormOrCursor boundingBox
			from: aFormOrCursor
			at: 0@0
			clippingBox: aFormOrCursor boundingBox
			rule: Form over
			fillColor: nil.
		map := Color indexedColors copyFrom: 1 to: (1 bitShift: aFormOrCursor depth)].
	map := map collect: [:c |
		c = Color white ifTrue: [Color transparent] ifFalse: [c]].
	f colors: map.
	^ f

]

{ #category : #'as yet unclassified' }
ColorForm class >> twoToneFromDisplay: aRectangle using: oldForm backgroundColor: bgColor [
	"Return a 1-bit deep ColorForm copied from the given rectangle of the display. All colors except the background color will be mapped to black."

	| f |
	((oldForm ~~ nil) and: [oldForm extent = aRectangle extent]) ifTrue: [
		f := oldForm fromDisplay: aRectangle.
	] ifFalse: [
		f := ColorForm extent: aRectangle extent depth: 1.
		f twoToneFromDisplay: aRectangle backgroundColor: bgColor.
		f colors: (Array
			with: bgColor
			with: Color black)].
	^ f

]

{ #category : #copying }
ColorForm >> asCursorForm [

	^ (self asFormOfDepth: 32) offset: offset; as: StaticForm
]

{ #category : #'postscript generation' }
ColorForm >> asFormWithSingleTransparentColors [
	| transparentIndexes |
	transparentIndexes := self transparentColorIndexes.
	transparentIndexes size <= 1 ifTrue:[^self]
		ifFalse:[^self mapTransparencies:transparentIndexes].
]

{ #category : #'color manipulation' }
ColorForm >> asGrayScale [
	"Return a grayscale ColorForm computed by mapping each color into its grayscale equivalent"
	^ self copy colors:
		(colors collect:
			[:c | c isTransparent ifTrue: [c]
						ifFalse: [Color gray: c luminance]])
]

{ #category : #copying }
ColorForm >> blankCopyOf: aRectangle scaledBy: scale [
	^Form extent: (aRectangle extent * scale) truncated depth: 32
]

{ #category : #private }
ColorForm >> clearColormapCache [

	cachedDepth := nil.
	cachedColormap := nil.

]

{ #category : #converting }
ColorForm >> collectColors: aBlock [

	^ (ColorForm extent: self extent depth: self depth bits: self bits)
		colors: (self colors collect: aBlock);
		yourself
]

{ #category : #'pixel accessing' }
ColorForm >> colorAt: aPoint [
	"Return the color of the pixel at aPoint."

	^ self colors at: (self pixelValueAt: aPoint) + 1

]

{ #category : #'pixel accessing' }
ColorForm >> colorAt: aPoint put: aColor [
	"Store the given color into the pixel at aPoint. The given color must match one of the colors in the receiver's colormap."

	| i |
	i := self colors indexOf: aColor
		ifAbsent: [^ self error: 'trying to use a color that is not in my colormap'].
	self pixelValueAt: aPoint put: i - 1.

]

{ #category : #'color mapping' }
ColorForm >> colormapIfNeededFor: destForm [
	| newMap color pv |
	(self hasNonStandardPalette or:[destForm hasNonStandardPalette]) ifFalse:[
		^self colormapIfNeededForDepth: destForm depth.
	].
	colors == nil ifTrue: [
		"use the standard colormap"
		^ super colormapIfNeededFor: destForm].

	(destForm depth = cachedDepth and:[cachedColormap isColormap]) 
		ifTrue: [^ cachedColormap].
	newMap := WordArray new: (1 bitShift: self depth).
	1 to: colors size do: [:i |
		color := colors at: i.
		pv := destForm pixelValueFor: color.
		(pv = 0 and:[color isTransparent not]) ifTrue:[pv := 1].
		newMap at: i put: pv].

	cachedDepth := destForm depth.
	^cachedColormap := ColorMap shifts: nil masks: nil colors: newMap.
]

{ #category : #'color manipulation' }
ColorForm >> colormapIfNeededForDepth: destDepth [
	"Return a colormap for displaying the receiver at the given depth, or nil if no colormap is needed."

	| newMap |
	colors == nil ifTrue: [
		"use the standard colormap"
		^ Color colorMapIfNeededFrom: self depth to: destDepth].

	(destDepth = cachedDepth and:[cachedColormap isColormap not]) 
		ifTrue: [^ cachedColormap].
	newMap := Bitmap new: colors size.
	1 to: colors size do: [:i |
		newMap
			at: i
			put: ((colors at: i) pixelValueForDepth: destDepth)].

	cachedDepth := destDepth.
	^ cachedColormap := newMap.

]

{ #category : #accessing }
ColorForm >> colors [
	"Return my color palette."

	self ensureColorArrayExists.
	^ colors

]

{ #category : #accessing }
ColorForm >> colors: colorList [
	"Set my color palette to the given collection."

	| colorArray colorCount newColors |
	colorList ifNil: [
		colors := cachedDepth := cachedColormap := nil.
		^ self].

	colorArray := colorList asArray.
	colorCount := colorArray size.
	newColors := Array new: (1 bitShift: self depth).
	1 to: newColors size do: [:i |
		i <= colorCount
			ifTrue: [newColors at: i put: (colorArray at: i)]
			ifFalse: [newColors at: i put: Color transparent]].

	colors := newColors.
	cachedDepth := nil.
	cachedColormap := nil.

]

{ #category : #accessing }
ColorForm >> colorsFromArray: colorArray [
	| colorList |
	colorList := colorArray collect: [:colorDef |
		Color fromArray: colorDef].
	self colors: colorList
]

{ #category : #'color manipulation' }
ColorForm >> colorsUsed [
	"Return a list of the colors actually used by this ColorForm."

	| myColor list |
	myColor := self colors.
	list := OrderedCollection new.
	self tallyPixelValues doWithIndex: [:count :i |
		count > 0 ifTrue: [list add: (myColor at: i)]].
	^ list asArray

]

{ #category : #copying }
ColorForm >> copy: aRect [
 	"Return a new ColorForm containing the portion of the receiver delineated by aRect."

	| newForm |
	newForm := self species extent: aRect extent depth: depth.
	((BitBlt
		destForm: newForm
		sourceForm: self
		fillColor: nil
		combinationRule: Form over
		destOrigin: 0@0
		sourceOrigin: aRect origin
		extent: aRect extent
		clipRect: newForm boundingBox)
		colorMap: nil) copyBits.
	colors ifNotNil: [newForm colors: colors copy].
	^ newForm

]

{ #category : #'postscript generation' }
ColorForm >> decodeArray [
	^self depth = 1 ifTrue:['[1 0]'] ifFalse:['[0 255]'].
]

{ #category : #private }
ColorForm >> depth: bitsPerPixel [

	bitsPerPixel > 8 ifTrue: [self error: 'ColorForms only support depths up to 8 bits'].
	super depth: bitsPerPixel.

]

{ #category : #displaying }
ColorForm >> displayOn: aDisplayMedium at: aDisplayPoint clippingBox: clipRectangle rule: rule fillColor: aForm [

	aDisplayMedium copyBits: self boundingBox
		from: self
		at: aDisplayPoint + self offset
		clippingBox: clipRectangle
		rule: rule
		fillColor: aForm
		map: (self colormapIfNeededFor: aDisplayMedium).

]

{ #category : #displaying }
ColorForm >> displayOnPort: port at: location [

	port copyForm: self to: location rule: Form paint
]

{ #category : #analyzing }
ColorForm >> dominantColor [
	"Overridden to consider color table"
	
	| tally max maxi |
	tally := self tallyPixelValues.
	max := maxi := 0.
	tally withIndexDo: [:n :i | n > max ifTrue: [max := n. maxi := i]].
	^ self colors at: maxi
]

{ #category : #private }
ColorForm >> ensureColorArrayExists [
	"Return my color palette."

	colors ifNil: [
		self depth > 8 ifTrue: [^ self error: 'ColorForms only support depths up to 8 bits'].
		self colors: (Color indexedColors copyFrom: 1 to: (1 bitShift: self depth))].

]

{ #category : #'color manipulation' }
ColorForm >> ensureTransparentColor [
	"Ensure that the receiver (a) includes Color transparent in its color map and (b) that the entry for Color transparent is the first entry in its color map."

	| i |
self error: 'not yet implemented'.
	(colors includes: Color transparent)
		ifTrue: [
			(colors indexOf: Color transparent) = 1 ifTrue: [^ self].
			"shift the entry for color transparent"]
		ifFalse: [
			i := self unusedColormapEntry.
			i = 0 ifTrue: [self error: 'no color map entry is available'].
			colors at: i put: Color transparent.
			"shift the entry for color transparent"].

]

{ #category : #'scaling, rotation' }
ColorForm >> flipBy: direction centerAt: aPoint [
	| oldColors newForm |
	oldColors := colors.
	self colors: nil.
	newForm := super flipBy: direction centerAt: aPoint.
	self colors: oldColors.
	newForm colors: oldColors.
	^newForm 
]

{ #category : #'postscript generation' }
ColorForm >> getTransparencyUnificationLUT [
	| lut transparentIndex |
	lut := Array new:colors size.
	transparentIndex := self indexOfColor:Color transparent.
	1 to: colors size do:
		[ :i | lut at:i put:(((colors at:i) = Color transparent) ifTrue:[transparentIndex] ifFalse:[i])].
 
]

{ #category : #'fileIn\/Out' }
ColorForm >> hibernate [
	"Make myself take up less space. See comment in Form>hibernate."

	super hibernate.
	self clearColormapCache.
	colors ifNotNil:[colors := colors asColorArray].
]

{ #category : #'color manipulation' }
ColorForm >> indexOfColor: aColor [
	"Return the index of aColor in my color array"

	self ensureColorArrayExists.
	^ colors indexOf: aColor
]

{ #category : #testing }
ColorForm >> isColorForm [
	^true
]

{ #category : #testing }
ColorForm >> isGrayScale [
	^ self colors = ColorForm grayScalePalette.
]

{ #category : #testing }
ColorForm >> isTranslucent [
	"Answer whether this form may be translucent"
	^true
]

{ #category : #'pixel accessing' }
ColorForm >> isTransparentAt: aPoint [ 
	"Return true if the receiver is transparent at the given point."

	^ (self colorAt: aPoint) isTransparent

]

{ #category : #'color manipulation' }
ColorForm >> mapColor: oldColor to: newColor [
	"Replace all occurances of the given color with the given new color in my color map."

	self ensureColorArrayExists.
	1 to: colors size do: [:i | 
		(colors at: i) = oldColor ifTrue: [colors at: i put: newColor]].
	self clearColormapCache.

]

{ #category : #'postscript generation' }
ColorForm >> mapTransparencies:transparentIndexes [
	^self deepCopy mapColors:transparentIndexes to:(transparentIndexes at:1).
]

{ #category : #displaying }
ColorForm >> maskingMap [
	"Return a color map that maps all colors except transparent to words of all ones. Used to create a mask for a Form whose transparent pixel value is zero."
	| maskingMap |
	maskingMap := Bitmap new: (1 bitShift: depth) withAll: 16rFFFFFFFF.
	1 to: colors size do:[:i|
		(colors at: i) isTransparent ifTrue:[maskingMap at: i put: 0].
	].
	colors size+1 to: maskingMap size do:[:i| maskingMap at: i put: 0].
	^maskingMap
]

{ #category : #copying }
ColorForm >> postCopy [
	super postCopy.
	colors := colors copy.

]

{ #category : #'fileIn\/Out' }
ColorForm >> readAttributesFrom: aBinaryStream [
	super readAttributesFrom: aBinaryStream.
	colors := ColorArray new: (2 raisedTo: depth).
	1 to: colors size do: [:idx | 
		colors basicAt: idx put: (aBinaryStream nextLittleEndianNumber: 4).
	]. 
	
]

{ #category : #'color manipulation' }
ColorForm >> replaceColor: oldColor with: newColor [
	"Replace all occurances of the given color with the given new color in my color map."

	self ensureColorArrayExists.
	1 to: colors size do: [:i | 
		(colors at: i) = oldColor ifTrue: [colors at: i put: newColor]].
	self clearColormapCache.

]

{ #category : #'color manipulation' }
ColorForm >> replaceColorAt: aPoint with: newColor [
	"Replace a color map entry with newColor.  The entry replaced is the one used by aPoint.  If there are are two entries in the colorMap for the oldColor, just replace ONE!!  There are often two whites or two blacks, and this is what you want, when replacing one."

	| oldIndex |
	self ensureColorArrayExists.
	oldIndex := self pixelValueAt: aPoint.
	colors at: oldIndex+1 put: newColor.
	self clearColormapCache.

]

{ #category : #'color manipulation' }
ColorForm >> replaceColorAtIndex: index with: newColor [
	"Replace a color map entry with newColor."

	self ensureColorArrayExists.
	colors at: index put: newColor.
	cachedColormap == nil ifFalse:
		[cachedColormap at: index put: (newColor pixelValueForDepth: cachedDepth)]
]

{ #category : #'scaling, rotation' }
ColorForm >> scaledIntoFormOfSize: aNumberOrPoint smoothing: factor [

	^ (self asFormOfDepth: 32) scaledIntoFormOfSize: aNumberOrPoint smoothing: factor
]

{ #category : #'scaling, rotation' }
ColorForm >> scaledToSize: newExtent smoothing: factor [
	"super method did not seem to work so well on ColorForms"

	^(self asFormOfDepth: 32) scaledToSize: newExtent smoothing: factor
]

{ #category : #private }
ColorForm >> setColors: colorArray cachedColormap: aBitmap depth: anInteger [
	"Semi-private. Set the color array, cached colormap, and cached colormap depth to avoid having to recompute the colormap when switching color palettes in animations."

	colors := colorArray.
	cachedDepth := anInteger.
	cachedColormap := aBitmap.

]

{ #category : #'postscript generation' }
ColorForm >> setColorspaceOn:aStream [
	self depth = 1 ifTrue:[
		aStream print:'/DeviceRGB setcolorspace 0 setgray'; cr.
	]
	ifFalse:[
	aStream print:'[ /Indexed /DeviceRGB ';
	write:self colors size-1;
	print:' <'.
	(self colormapIfNeededForDepth: 32 ) storeBits:20 to:0 on:aStream.
	aStream print:'> ] setcolorspace'; cr.].

]

{ #category : #private }
ColorForm >> setExtent: extent depth: bitsPerPixel [
	"Create a virtual bit map with the given extent and bitsPerPixel."

	bitsPerPixel > 8 ifTrue: [self error: 'ColorForms only support depths up to 8 bits'].
	super setExtent: extent depth: bitsPerPixel.

]

{ #category : #'fileIn\/Out' }
ColorForm >> storeOn: aStream [
	aStream nextPut: $(.
	super storeOn: aStream.
	aStream
		cr; tab;
		nextPutAll: 'colorsFromArray: #('.
	self colors do: [:color |
		color storeArrayOn: aStream].
	aStream nextPutAll: ' ))'.
]

{ #category : #'color manipulation' }
ColorForm >> transparentAllPixelsLike: aPoint [
	"Make all occurances of the given pixel value transparent.  Very useful when two entries in the colorMap have the same value.  This only changes ONE."

	self replaceColorAt: aPoint with: Color transparent.

]

{ #category : #'color manipulation' }
ColorForm >> transparentColor: aColor [
	"Make all occurances of the given color transparent.  Note: for colors like black and white, which have two entries in the colorMap, this changes BOTH of them.  Not always what you want."

	self replaceColor: aColor with: Color transparent.

]

{ #category : #'postscript generation' }
ColorForm >> transparentColorIndexes [
	^(1 to: colors size) select: [ :index | (colors at:index) isTransparent ].

]

{ #category : #'color manipulation' }
ColorForm >> twoToneFromDisplay: aRectangle backgroundColor: bgColor [
	"Copy one-bit deep ColorForm from the Display using a color map that maps all colors except the background color to black. Used for caching the contents of inactive MVC windows."

	| map |
	(width = aRectangle width and: [height = aRectangle height])
		ifFalse: [self setExtent: aRectangle extent depth: depth].

	"make a color map mapping the background color
	 to zero and all other colors to one"
	map := Bitmap new: (1 bitShift: (Display depth min: 9)).
	1 to: map size do: [:i | map at: i put: 16rFFFFFFFF].
	map at: (bgColor indexInMap: map) put: 0.

	(BitBlt toForm: self)
		destOrigin: 0@0;
		sourceForm: Display;
		sourceRect: aRectangle;
		combinationRule: Form over;
		colorMap: map;
		copyBits.

]

{ #category : #'fileIn\/Out' }
ColorForm >> unhibernate [
	colors ifNotNil:[colors := colors asArray].
	^super unhibernate.

]

{ #category : #private }
ColorForm >> unusedColormapEntry [
	"Return the index of an unused color map entry, or zero if there isn't one."

	| tallies |
	tallies := self tallyPixelValues.
	1 to: tallies size do: [:i |
		(tallies at: i) = 0 ifTrue: [^ i]].
	^ 0

]

{ #category : #'fileIn\/Out' }
ColorForm >> writeAttributesOn: file [
	| colorArray |
	super writeAttributesOn: file.
	colorArray := self colors asColorArray.
	1 to: (2 raisedTo: depth) do: [:idx |
		file nextLittleEndianNumber: 4 put: (colorArray basicAt: idx).
	] 
]
