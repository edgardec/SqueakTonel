"
This class represents abstract color, regardless of the depth of bitmap it will be shown in.  At the very last moment a Color is converted to a pixelValue that depends on the depth of the actual Bitmap inside the Form it will be used with.  The supported depths (in bits) are 1, 2, 4, 8, 16, and 32.  The number of actual colors at these depths are: 2, 4, 16, 256, 32768, and 16 million.  (See comment in BitBlt.)  To change the depth of the Display and set how many colors you can see, execute: (Display newDepth: 8).  (See comment in DisplayMedium)
	Color is represented as the amount of light in red, green, and blue.  White is (1.0, 1.0, 1.0) and black is (0, 0, 0).  Pure red is (1.0, 0, 0).  These colors are ""additive"".  Think of Color's instance variables as:
	r	amount of red, a Float between 0.0 and 1.0.
	g	amount of green, a Float between 0.0 and 1.0.
	b	amount of blue, a Float between 0.0 and 1.0.
(But, in fact, the three are encoded as values from 0 to 1023 and combined in a single integer, rgb.  The user does not need to know this.)
	Many colors are named.  You find a color by name by sending a message to class Color, for example (Color lightBlue).  Also, (Color red: 0.2 green: 0.6 blue: 1.0) or (Color r: 0.2 g: 0.6 b: 1.0) creates a color. (see below)
	A color is essentially immutable.  Once you set red, green, and blue, you cannot change them.  Instead, create a new Color and use it.
	Applications such as contour maps and bar graphs will want to display one of a set of shades based on a number.  Convert the range of this number to an integer from 1 to N.  Then call (Color green lightShades: N) to get an Array of colors from white to green.  Use the Array messages at:, atPin:, or atWrap: to pull out the correct color from the array.  atPin: gives the first (or last) color if the index is out of range.  atWrap: wraps around to the other end if the index is out of range.
	Here are some fun things to run in when your screen has color:
		Pen new mandala: 30 diameter: Display height-100.
		Pen new web  ""Draw with the mouse, opt-click to end""
		Display fillWhite.  Pen new hilberts: 5.
		Form toothpaste: 30  ""Draw with mouse, opt-click to end""
You might also want to try the comment in
	Form>class>examples>tinyText...


Messages:
	mixed: proportion with: aColor	Answer this color mixed with the given color additively. The proportion, a number between 0.0 and 1.0, determines what what fraction of the receiver to use in the mix.

	+ 	add two colors
	- 	subtract two colors
	*	multiply the values of r, g, b by a number or an Array of factors.  ((Color named: #white) * 0.3) gives a darkish gray.  (aColor * #(0 0 0.9)) gives a color with slightly less blue.
	/	divide a color by a factor or an array of three factors.

	errorForDepth: d     How close the nearest color at this depth is to this abstract color.  Sum of the squares of the RGB differences, square rooted and normalized to 1.0.  Multiply by 100 to get percent.

	hue			Returns the hue of the color. On a wheel from 0 to 360 with pure red at 0 and again at 360.
	saturation	Returns the saturation of the color.  0.0 to 1.0
	brightness	Returns the brightness of the color.  0.0 to 1.0

	name    Look to see if this Color has a name.
	display	Show a swatch of this color tracking the cursor.

	lightShades: thisMany		An array of thisMany colors from white to the receiver. 
	darkShades: thisMany		An array of thisMany colors from black to the receiver.  Array is of length num.
	mix: color2 shades: thisMany		An array of thisMany colors from the receiver to color2.
	wheel: thisMany			An array of thisMany colors around the color wheel starting and ending at the receiver.

	pixelValueForDepth: d    Returns the bits that appear be in a Bitmap of this depth for this color.  Represents the nearest available color at this depth.  Normal users do not need to know which pixelValue is used for which color. 

Messages to Class Color.
	red: r green: g blue: b		Return a color with the given r, g, and b components.
	r: g: b:		Same as above, for fast typing.

 	hue: h saturation: s brightness: b		Create a color with the given hue, saturation, and brightness.

	pink
 	blue
	red ...	Many colors have messages that return an instance of Color.
	canUnderstand: #brown	  Returns true if #brown is a defined color.
	names		An OrderedCollection of the names of the colors.
	named: #notAllThatGray put: aColor    Add a new color to the list and create an access message and a class variable for it.
	fromUser	Shows the palette of colors available at this display depth.  Click anywhere to return the color you clicked on.

	hotColdShades: thisMany	An array of thisMany colors showing temperature from blue to red to white hot.

    stdColorsForDepth: d        An Array of colors available at this depth.  For 16 bit and 32 bits, returns a ColorGenerator.  It responds to at: with a Color for that index, simulating a very big Array. 

   colorFromPixelValue: value depth: d    Returns a Color whose bit pattern (inside a Bitmap) at this depth is the number specified.  Normal users do not need to use this.

(See also comments in these classes: Form, Bitmap, BitBlt, Pattern, MaskedForm.)
"
Class {
	#name : #Color,
	#superclass : #Object,
	#instVars : [
		'rgb',
		'cachedDepth',
		'cachedBitPattern'
	],
	#classVars : [
		'Black',
		'Blue',
		'BlueShift',
		'Brown',
		'CachedColormaps',
		'ColorChart',
		'ColorNames',
		'ComponentMask',
		'ComponentMax',
		'Cyan',
		'DarkGray',
		'Gray',
		'GrayToIndexMap',
		'Green',
		'GreenShift',
		'HalfComponentMask',
		'HighLightBitmaps',
		'IndexedColors',
		'LightBlue',
		'LightBrown',
		'LightCyan',
		'LightGray',
		'LightGreen',
		'LightMagenta',
		'LightOrange',
		'LightRed',
		'LightYellow',
		'Magenta',
		'MaskingMap',
		'Orange',
		'PaleBlue',
		'PaleBuff',
		'PaleGreen',
		'PaleMagenta',
		'PaleOrange',
		'PalePeach',
		'PaleRed',
		'PaleTan',
		'PaleYellow',
		'PantonePurpleU',
		'PureBlue',
		'PureCyan',
		'PureGreen',
		'PureMagenta',
		'PureRed',
		'PureYellow',
		'RGBToNames',
		'RandomStream',
		'Red',
		'RedShift',
		'TranslucentPatterns',
		'Transparent',
		'VeryDarkGray',
		'VeryLightGray',
		'VeryPaleRed',
		'VeryVeryDarkGray',
		'VeryVeryLightGray',
		'White',
		'Yellow'
	],
	#category : #'Graphics-Primitives'
}

{ #category : #'named colors - crayons' }
Color class >> aluminum [

	^ Color r: 153/255 g: 153/255 b: 153/255
]

{ #category : #'named colors - crayons' }
Color class >> aqua [

	^ Color r: 0.0 g: 128/255 b: 1.0
]

{ #category : #'named colors - crayons' }
Color class >> asparagus [

	^ Color r: 128/255 g: 128/255 b: 0.0
]

{ #category : #'named colors - crayons' }
Color class >> banana [

	^ Color r: 1.0 g: 1.0 b: 102/255
]

{ #category : #'named colors' }
Color class >> black [
	^Black
]

{ #category : #'named colors' }
Color class >> blue [
	^Blue
]

{ #category : #'named colors - crayons' }
Color class >> blueberry [

	^ Color r: 0.0 g: 0.0 b: 1.0
]

{ #category : #'named colors' }
Color class >> brown [
	^Brown
]

{ #category : #'named colors - crayons' }
Color class >> bubblegum [

	^ Color r: 1.0 g: 102/255 b: 1.0
]

{ #category : #colormaps }
Color class >> cachedColormapFrom: sourceDepth to: destDepth [
	"Return a cached colormap for mapping between the given depths. Always return a real colormap, not nil; this allows the client to get an identity colormap that can then be copied and modified to do color transformations."
	"Note: This method returns a shared, cached colormap to save time and space. Clients that need to modify a colormap returned by this method should make a copy and modify that!"
	"Note: The colormap cache may be cleared by evaluating 'Color shutDown'."

	| srcIndex map |
	CachedColormaps class == Array ifFalse: [CachedColormaps := (1 to: 9) collect: [:i | Array new: 32]].
	srcIndex := sourceDepth.
	sourceDepth > 8 ifTrue: [srcIndex := 9].
	(map := (CachedColormaps at: srcIndex) at: destDepth) ~~ nil ifTrue: [^ map].

	map := self computeColormapFrom: sourceDepth to: destDepth.
	(CachedColormaps at: srcIndex) at: destDepth put: map.
	^ map

]

{ #category : #'named colors - crayons' }
Color class >> cantaloupe [

	^ Color r: 1.0 g: 204/255 b: 102/255
]

{ #category : #'named colors - crayons' }
Color class >> carnation [

	^ Color r: 1.0 g: 111/255 b: 207/255
]

{ #category : #'named colors - crayons' }
Color class >> cayenne [

	^ Color r: 128/255 g: 0.0 b: 0.0
]

{ #category : #'class initialization' }
Color class >> cleanUp: aggressive [
	self initializeNamesMap
]

{ #category : #'named colors - crayons' }
Color class >> clover [

	^ Color r: 0.0 g: 128/255 b: 0.0
]

{ #category : #'instance creation' }
Color class >> colorFrom: parm [
	"Return an instantiated color from parm.  If parm is already a color, return it, else return the result of my performing it if it's a symbol or, if it is a list, it can either be an array of three numbers, which will be interpreted as RGB values, or a list of symbols, the first of which is sent to me and then the others of which are in turn sent to the prior result, thus allowing entries of the form #(blue darker).  Else just return the thing"

	| aColor firstParm |
	(parm isKindOf: Color) ifTrue: [^ parm].
	(parm isSymbol) ifTrue: [^ self perform: parm].
	(parm isString) ifTrue: [^ self fromString: parm].
	((parm isKindOf: SequenceableCollection) and: [parm size > 0])
		ifTrue:
			[firstParm := parm first.
			(firstParm isKindOf: Number) ifTrue:
				[^ self fromRgbTriplet: parm].
			aColor := self colorFrom: firstParm.
			parm doWithIndex:
				[:sym :ind | ind > 1 ifTrue:
					[aColor := aColor perform: sym]].
			^ aColor].
	^ parm

"
Color colorFrom: #(blue darker)
Color colorFrom: Color blue darker
Color colorFrom: #blue
Color colorFrom: #(0.0 0.0 1.0)
"
]

{ #category : #'instance creation' }
Color class >> colorFromPixelValue: p depth: d [
	"Convert a pixel value for the given display depth into a color."
	"Details: For depths of 8 or less, the pixel value is simply looked up in a table. For greater depths, the color components are extracted and converted into a color."

	| r g b alpha |
	d = 8 ifTrue: [^ IndexedColors at: (p bitAnd: 16rFF) + 1].
	d = 4 ifTrue: [^ IndexedColors at: (p bitAnd: 16r0F) + 1].
	d = 2 ifTrue: [^ IndexedColors at: (p bitAnd: 16r03) + 1].
	d = 1 ifTrue: [^ IndexedColors at: (p bitAnd: 16r01) + 1].

	(d = 16) | (d = 15) ifTrue: [
		"five bits per component"
		r := (p bitShift: -10) bitAnd: 16r1F.
		g := (p bitShift: -5) bitAnd: 16r1F.
		b := p bitAnd: 16r1F.
		(r = 0 and: [g = 0]) ifTrue: [
			b = 0 ifTrue: [^Color transparent].
			b = 1 ifTrue: [^Color black]].
		^ Color r: r g: g b: b range: 31].

	d = 32 ifTrue: [
		"eight bits per component; 8 bits of alpha"
		r := (p bitShift: -16) bitAnd: 16rFF.
		g := (p bitShift: -8) bitAnd: 16rFF.
		b := p bitAnd: 16rFF.
		alpha := p bitShift: -24.
		alpha = 0 ifTrue: [^Color transparent].
		(r = 0 and: [g = 0 and: [b = 0]])  ifTrue: [^Color transparent].
		alpha < 255
			ifTrue: [^ (Color r: r g: g b: b range: 255) alpha: (alpha asFloat / 255.0)]
			ifFalse: [^ (Color r: r g: g b: b range: 255)]].

	d = 12 ifTrue: [
		"four bits per component"
		r := (p bitShift: -8) bitAnd: 16rF.
		g := (p bitShift: -4) bitAnd: 16rF.
		b := p bitAnd: 16rF.
		^ Color r: r g: g b: b range: 15].

	d = 9 ifTrue: [
		"three bits per component"
		r := (p bitShift: -6) bitAnd: 16r7.
		g := (p bitShift: -3) bitAnd: 16r7.
		b := p bitAnd: 16r7.
		^ Color r: r g: g b: b range: 7].

	self error: 'unknown pixel depth: ', d printString

]

{ #category : #colormaps }
Color class >> colorMapIfNeededFrom: sourceDepth to: destDepth [
	"Return a colormap for mapping between the given depths, or nil if no colormap is needed."
	"Note: This method returns a shared, cached colormap to save time and space. Clients that need to modify a colormap returned by this method should make a copy and modify that!"

	sourceDepth = destDepth ifTrue: [^ nil].  "not needed if depths are the same"

	(sourceDepth >= 16) & (destDepth >= 16) ifTrue: [
		"mapping is done in BitBlt by zero-filling or truncating each color component"
		^ nil].

	^ Color cachedColormapFrom: sourceDepth to: destDepth

]

{ #category : #other }
Color class >> colorNames [
	"Return a collection of color names."

	^ ColorNames asArray, self orderedCrayonColorNames
]

{ #category : #examples }
Color class >> colorRampForDepth: depth extent: aPoint [
	"Returns a form of the given size showing R, G, B, and gray ramps for the given depth. Useful for testing color conversions between different depths."
	"(Color colorRampForDepth: Display depth extent: 256@80) display"
	"(Color colorRampForDepth: 32 extent: 256@80) displayOn: Display at: 0@0 rule: Form paint"

	| f dx dy r |
	f := Form extent: aPoint depth: depth.
	dx := aPoint x // 256.
	dy := aPoint y // 4.
	0 to: 255 do: [:i |
		r := (dx * i)@0 extent: dx@dy.
		f fill: r fillColor: (Color r: i g: 0 b: 0 range: 255).
		r := r translateBy: 0@dy.
		f fill: r fillColor: (Color r: 0 g: i b: 0 range: 255).
		r := r translateBy: 0@dy.
		f fill: r fillColor: (Color r: 0 g: 0 b: i range: 255).
		r := r translateBy: 0@dy.
		f fill: r fillColor: (Color r: i g: i b: i range: 255)].
	^ f

]

{ #category : #'color from user' }
Color class >> colorTest: depth extent: chartExtent colorMapper: colorMapper [
	"Create a palette of colors sorted horizontally by hue and vertically by lightness. Useful for eyeballing the color gamut of the display, or for choosing a color interactively."
	"Note: It is slow to build this palette, so it should be cached for quick access."
	"(Color colorTest: 32 extent: 570@180 colorMapper: [:c | c]) display"
	"(Color colorTest: 32 extent: 570@180 colorMapper:
		[:c | Color
			r: (c red * 7) asInteger / 7
			g: (c green * 7) asInteger / 7
			b: (c blue * 3) asInteger / 3]) display"
	"(Color colorTest: 32 extent: 570@180 colorMapper:
		[:c | Color
			r: (c red * 5) asInteger / 5
			g: (c green * 5) asInteger / 5
			b: (c blue * 5) asInteger / 5]) display"
	"(Color colorTest: 32 extent: 570@180 colorMapper:
		[:c | Color
			r: (c red * 15) asInteger / 15
			g: (c green * 15) asInteger / 15
			b: (c blue * 15) asInteger / 15]) display"
	"(Color colorTest: 32 extent: 570@180 colorMapper:
		[:c | Color
			r: (c red * 31) asInteger / 31
			g: (c green * 31) asInteger / 31
			b: (c blue * 31) asInteger / 31]) display"

	| startHue palette transHt vSteps transCaption grayWidth hSteps y c x |
	palette := Form extent: chartExtent depth: depth.
	transCaption := "(DisplayText text: 'no color' asText textStyle: (TextConstants at: #ComicPlain)) form storeString"
		(Form extent: 34@9 depth: 1
			fromArray: #(0 0 256 0 256 0 3808663859 2147483648 2491688266 2147483648 2491688266 0 2491688266 0 2466486578 0 0 0)
			offset: 0@0).
	transHt := transCaption height.
	palette fillWhite: (0@0 extent: palette width@transHt).
	palette fillBlack: (0@transHt extent: palette width@1).
	transCaption displayOn: palette at: palette boundingBox topCenter - ((transCaption width // 2)@0).
	grayWidth := 10.
	startHue := 338.0.
	vSteps := palette height - transHt // 2.
	hSteps := palette width - grayWidth.
	x := 0.
	startHue to: startHue + 360.0 by: 360.0/hSteps do: [:h | | basicHue |
		basicHue := Color h: h asFloat s: 1.0 v: 1.0.
		y := transHt+1.
		0 to: vSteps do: [:n |
 			c := basicHue mixed: (n asFloat / vSteps asFloat) with: Color white.
			c := colorMapper value: c.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y := y + 1].
		1 to: vSteps do: [:n |
 			c := Color black mixed: (n asFloat / vSteps asFloat) with: basicHue.
			c := colorMapper value: c.
			palette fill: (x@y extent: 1@1) fillColor: c.
			y := y + 1].
		x := x + 1].
	y := transHt + 1.
	1 to: vSteps * 2 do: [:n |
 		c := Color black mixed: (n asFloat / (vSteps*2) asFloat) with: Color white.
		c := colorMapper value: c.
		palette fill: (x@y extent: 10@1) fillColor: c.
		y := y + 1].
	^ palette

]

{ #category : #colormaps }
Color class >> computeColorConvertingMap: targetColor from: sourceDepth to: destDepth keepSubPixelAA: keepSubPix [

	sourceDepth < 16 ifTrue: [
		"source is 1-, 2-, 4-, or 8-bit indexed color.
		Assumed not to include subpixelAA"
		^ self computeIndexedColorConvertingMap: targetColor from: sourceDepth to: destDepth
	] ifFalse: [
		"source is 16-bit or 32-bit RGB.
		Might include subpixelAA"
		^ self computeRGBColorConvertingMap: targetColor to: destDepth keepSubPixelAA: keepSubPix
	]
]

{ #category : #colormaps }
Color class >> computeColormapFrom: sourceDepth to: destDepth [
	"Compute a colorMap for translating between the given depths. A colormap is a Bitmap whose entries contain the pixel values for the destination depth. Typical clients use cachedColormapFrom:to: instead."

	| map bitsPerColor |
	sourceDepth < 16 ifTrue: [
		"source is 1-, 2-, 4-, or 8-bit indexed color"
		map := (IndexedColors copyFrom: 1 to: (1 bitShift: sourceDepth))
					collect: [:c | c pixelValueForDepth: destDepth].
		map := map as: Bitmap.
	] ifFalse: [
		"source is 16-bit or 32-bit RGB"
		destDepth > 8
			ifTrue: [bitsPerColor := 5]  "retain maximum color resolution"
			ifFalse: [bitsPerColor := 4].
		map := self computeRGBColormapFor: destDepth bitsPerColor: bitsPerColor].

	"Note: zero is transparent except when source depth is one-bit deep"
	sourceDepth > 1 ifTrue: [map at: 1 put: 0].
	^ map

]

{ #category : #colormaps }
Color class >> computeIndexedColorConvertingMap: targetColor from: sourceDepth to: destDepth [
	| map |
	
	map := (IndexedColors copyFrom: 1 to: (1 bitShift: sourceDepth)) collect: [ :cc | | f c | 
		f := 1.0 - (cc red + cc green + cc blue / 3.0 ).
		c := targetColor notNil
			ifTrue: [
				destDepth = 32
					ifTrue: [ targetColor * f alpha: f]
					ifFalse: [ targetColor alphaMixed: f*1.5 with: Color white ]]
			ifFalse: [ cc ].
		destDepth = 32
			ifTrue: [ c pixelValueForDepth: destDepth]
			ifFalse: [
				f = 0.0
					ifTrue: [ 0 ]
					ifFalse: [ c pixelValueForDepth: destDepth ]]].
	map := map as: Bitmap.
	^map
]

{ #category : #colormaps }
Color class >> computeRGBColorConvertingMap: targetColor to: destDepth keepSubPixelAA: keepSubPix [
	"Builds a colormap intended to convert from subpixelAA black values to targetColor values.
	keepSubPix
		ifTrue: [ Answer colors that also include subpixelAA ]
		ifFalse: [ 
			Take fullpixel luminance level. Apply it to targetColor.
			I.e. answer colors with NO subpixelAA ]"

	| mask map c bitsPerColor r g b f v |

	destDepth > 8
		ifTrue: [bitsPerColor := 5]  "retain maximum color resolution"
		ifFalse: [bitsPerColor := 4].
	"Usually a bit less is enough, but make it configurable"
	bitsPerColor := bitsPerColor min: Preferences aaFontsColormapDepth.
	mask := (1 bitShift: bitsPerColor) - 1.
	map := Bitmap new: (1 bitShift: (3 * bitsPerColor)).
	0 to: map size - 1 do: [:i |
		r := (i bitShift: 0 - (2 * bitsPerColor)) bitAnd: mask.
		g := (i bitShift: 0 - bitsPerColor) bitAnd: mask.
		b := (i bitShift: 0) bitAnd: mask.
		f := 1.0 - (r + g + b / 3.0 / mask).
		c := targetColor notNil
			ifTrue: [
				(keepSubPix and: [destDepth > 8]) ifTrue: [
						Color
							r: 1.0 - (r/mask) * targetColor red
							g: 1.0 - (g/mask) * targetColor green
							b: 1.0 - (b/mask) * targetColor blue
							alpha: f	* targetColor alpha "alpha will be ignored below, in #pixelValueForDepth: if destDepth ~= 32" ]
				ifFalse: [
					destDepth = 32
						ifTrue: [ targetColor * f alpha: f * targetColor alpha ]
						ifFalse: [ targetColor alphaMixed: f*1.5 with: Color white ]]]
			ifFalse: [ Color r: r g: g b: b range: mask].	"This is currently used only to keep some SubPixelAA on destDepth = 8, using a single pass of rule 25"
		v := destDepth = 32
			ifTrue: [ c pixelValueForDepth: destDepth]
			ifFalse: [
				f < 0.1
					ifTrue: [ 0 ]
					ifFalse: [ c pixelValueForDepth: destDepth ]].
		map at: i + 1 put: v ].
	^ map
]

{ #category : #colormaps }
Color class >> computeRGBColormapFor: destDepth bitsPerColor: bitsPerColor [
	"Compute a colorMap for translating from 16-bit or 32-bit RGB color to the given depth, using the given number of of bits per color component."

	| mask map c |
	(#(3 4 5) includes: bitsPerColor)
		ifFalse: [self error: 'BitBlt only supports 3, 4, or 5 bits per color component'].
	mask := (1 bitShift: bitsPerColor) - 1.
	map := Bitmap new: (1 bitShift: (3 * bitsPerColor)).
	0 to: map size - 1 do: [:i |
		c := Color
			r: ((i bitShift: 0 - (2 * bitsPerColor)) bitAnd: mask)
			g: ((i bitShift: 0 - bitsPerColor) bitAnd: mask)
			b: ((i bitShift: 0) bitAnd: mask)
			range: mask.
		map at: i + 1 put: (c pixelValueForDepth: destDepth)].

	map at: 1 put: (Color transparent pixelWordForDepth: destDepth).  "zero always transparent"
	^ map

]

{ #category : #'named colors' }
Color class >> cyan [
	^Cyan
]

{ #category : #'named colors' }
Color class >> darkGray [
	^DarkGray
]

{ #category : #'named colors - crayons' }
Color class >> eggplant [

	^ Color r: 64/255 g: 0.0 b: 128/255
]

{ #category : #'named colors - crayons' }
Color class >> fern [

	^ Color r: 64/255 g: 128/255 b: 0.0
]

{ #category : #'named colors - crayons' }
Color class >> flora [

	^ Color r: 102/255 g: 1.0 b: 102/255
]

{ #category : #'instance creation' }
Color class >> fromArray: colorDef [
	colorDef size = 3
			ifTrue: [^self r: (colorDef at: 1) g: (colorDef at: 2) b: (colorDef at: 3)].
	colorDef size = 0
			ifTrue: [^Color transparent].
	colorDef size = 4
			ifTrue: [^(TranslucentColor r: (colorDef at: 1) g: (colorDef at: 2) b: (colorDef at: 3)) alpha: (colorDef at: 4)].
	self error: 'Undefined color definition'
]

{ #category : #'instance creation' }
Color class >> fromColorref: aColorref [ 
	| red green blue |
	red := aColorref bitAnd: 16rFF.
	green := (aColorref bitAnd: 16rFF00)
				>> 8.
	blue := (aColorref bitAnd: 16rFF0000)
				>> 16.
	^ self r: red g: green b: blue range: 255.
]

{ #category : #other }
Color class >> fromHTMLString: aColorHex [
	"Do not call this method directly, call Color>>#fromString: instead as it is more generic"

	| green red blue resultColor |
	red := (Integer readFrom: (aColorHex first: 2) base: 16).
	green := (Integer readFrom: (aColorHex copyFrom: 3 to: 4) base: 16).
	blue := (Integer readFrom: (aColorHex copyFrom: 5 to: 6) base: 16).
	resultColor := self r: red g: green b: blue range: 255.
	^ (aColorHex size = 8) 
		ifTrue: [resultColor alpha: ((Integer readFrom: (aColorHex last: 2) base: 16) / 255)]
		ifFalse: [resultColor]
]

{ #category : #other }
Color class >> fromRGBString: rgb [
	"Do not call this method directly, call Color>>#fromString: instead as it is more generic"
	
	| green red blue |
	red := (Integer readFrom:(rgb at: 1)) min: 255 max: 0.
	green := (Integer readFrom:(rgb at: 2)) min: 255 max: 0.
	blue := (Integer readFrom:(rgb at: 3)) min: 255 max: 0.
	^self r: red g: green b: blue range: 255
]

{ #category : #'instance creation' }
Color class >> fromRgbTriplet: list [
	^ self r: list first g: list second b: list last
]

{ #category : #'instance creation' }
Color class >> fromString: aString [
	"for HTML color spec: #FFCCAA or white/black/red/other name, or an r,g,b triplet string"
	"Color fromString: '#FFCCAA'.
	 Color fromString: 'white'.
	 Color fromString: 'orange'
	 Color fromString: '126,42,33' "
	
	| aColorHex rgb|
	aString isEmptyOrNil ifTrue: [ ^self white ].
	aString first = $#
		ifTrue: [ aColorHex := aString allButFirst ]
		ifFalse: [ aColorHex := aString ].
	
	"is the string a 6 digit hex number?"
	((aColorHex size = 6 or: [aColorHex size = 8]) and: [ 
		aColorHex allSatisfy: [ :each | '0123456789ABCDEFabcdef' includes: each ] ])
			ifTrue: [^ self fromHTMLString: aColorHex ].
	
	"is the string in the form a,b,c ?"
	rgb := aColorHex findTokens: $, .
	rgb size = 3 ifTrue: [^ self fromRGBString: rgb].
	
	"try to match aColorHex with known named colors, case insensitive"
	^self perform: (ColorNames detect: [:colorSymbol | aColorHex sameAs: colorSymbol] ifNone: [ #white ])
]

{ #category : #'color from user' }
Color class >> fromUser [
	"Displays a color palette of colors, waits for a mouse click, and returns the selected color. Any pixel on the Display can be chosen, not just those in the color palette."
	"Note: Since the color chart is cached, you may need to do 'ColorChart := nil' after changing the oldColorPaletteForDepth:extent: method."
	"Color fromUser"

	| d startPt save tr oldColor c here s |
	d := Display depth.
	((ColorChart == nil) or: [ColorChart depth ~= Display depth]) 
		ifTrue: [ColorChart := self oldColorPaletteForDepth: d extent: (2 * 144)@80].
	Sensor cursorPoint y < Display center y 
		ifTrue: [startPt := 0@(Display boundingBox bottom - ColorChart height)]
		ifFalse: [startPt := 0@0].

	save := Form fromDisplay: (startPt extent: ColorChart extent).
	ColorChart displayAt: startPt.
	tr := ColorChart extent - (50@19) corner: ColorChart extent.
	tr := tr translateBy: startPt.

	oldColor := nil.
	[Sensor anyButtonPressed] whileFalse: [
		c := Display colorAt: (here := Sensor cursorPoint).
		(tr containsPoint: here)
			ifFalse: [Display fill: (0@61+startPt extent: 20@19) fillColor: c]
			ifTrue: [
				c := Color transparent.
				Display fill: (0@61+startPt extent: 20@19) fillColor: Color white].
		c = oldColor ifFalse: [
			Display fillWhite: (20@61 + startPt extent: 135@19).
			c isTransparent
				ifTrue: [s := 'transparent']
				ifFalse: [s := c shortPrintString.
						s := s copyFrom: 7 to: s size - 1].
			s displayAt: 20@61 + startPt.
			oldColor := c]].
	save displayAt: startPt.
	Sensor waitNoButton.
	^ c

]

{ #category : #'named colors - crayons' }
Color class >> grape [

	^ Color r: 128/255 g: 0.0 b: 1.0
]

{ #category : #'named colors' }
Color class >> gray [
	^Gray
]

{ #category : #'instance creation' }
Color class >> gray: brightness [
	"Return a gray shade with the given brightness in the range [0.0..1.0]."

	^ self basicNew setRed: brightness green: brightness blue: brightness

]

{ #category : #'named colors' }
Color class >> green [
	^Green
]

{ #category : #'instance creation' }
Color class >> h: hue s: saturation v: brightness [
	"Create a color with the given hue, saturation, and brightness. Hue is given as the angle in degrees of the color on the color circle where red is zero degrees. Saturation and brightness are numbers in [0.0..1.0] where larger values are more saturated or brighter colors. For example, (Color h: 0 s: 1 v: 1) is pure red."
	"Note: By convention, brightness is abbreviated 'v' to to avoid confusion with blue."

	^ self basicNew setHue: hue saturation: saturation brightness: brightness
]

{ #category : #'instance creation' }
Color class >> h: h s: s v: v alpha: alpha [

	^ (self h: h s: s v: v) alpha: alpha
]

{ #category : #'named colors - crayons' }
Color class >> honeydew [

	^ Color r: 204/255 g: 1.0 b: 102/255
]

{ #category : #examples }
Color class >> hotColdShades: thisMany [
	"An array of thisMany colors showing temperature from blue to red to white hot.  (Later improve this by swinging in hue.)  "
	"Color showColors: (Color hotColdShades: 25)"

	| n s1 s2 s3 s4 s5 |
	thisMany < 5 ifTrue: [^ self error: 'must be at least 5 shades'].
	n := thisMany // 5.
	s1 := self white mix: self yellow shades: (thisMany - (n*4)).
	s2 := self yellow mix: self red shades: n+1.
	s2 := s2 copyFrom: 2 to: n+1.
	s3 := self red mix: self green darker shades: n+1.
	s3 := s3 copyFrom: 2 to: n+1.
	s4 := self green darker mix: self blue shades: n+1.
	s4 := s4 copyFrom: 2 to: n+1.
	s5 := self blue mix: self black shades: n+1.
	s5 := s5 copyFrom: 2 to: n+1.
	^ s1, s2, s3, s4, s5

]

{ #category : #'named colors - crayons' }
Color class >> ice [

	^ Color r: 102/255 g: 1.0 b: 1.0
]

{ #category : #other }
Color class >> indexedColors [

	^ IndexedColors
]

{ #category : #'class initialization' }
Color class >> initialize [
	"Color initialize"

	"Details: Externally, the red, green, and blue components of color
	are floats in the range [0.0..1.0]. Internally, they are represented
	as integers in the range [0..ComponentMask] packing into a
	small integer to save space and to allow fast hashing and
	equality testing.

	For a general description of color representations for computer
	graphics, including the relationship between the RGB and HSV
	color models used here, see Chapter 17 of Foley and van Dam,
	Fundamentals of Interactive Computer Graphics, Addison-Wesley,
	1982."

	ComponentMask := 1023.
	HalfComponentMask := 512.  "used to round up in integer calculations"
	ComponentMax := 1023.0.  "a Float used to normalize components"
	RedShift := 20.
	GreenShift := 10.
	BlueShift := 0.

	PureRed		 := self r: 1 g: 0 b: 0.
	PureGreen	 := self r: 0 g: 1 b: 0.
	PureBlue	 := self r: 0 g: 0 b: 1.
	PureYellow	 := self r: 1 g: 1 b: 0.
	PureCyan	 := self r: 0 g: 1 b: 1.
	PureMagenta := self r: 1 g: 0 b: 1.

	RandomStream := Random new.

	self initializeIndexedColors.
	self initializeGrayToIndexMap.
	self initializeNames.
	self initializeHighLights.

]

{ #category : #'class initialization' }
Color class >> initializeGrayToIndexMap [
	"Build an array of gray values available in the 8-bit colormap. This array is indexed by a gray level between black (1) and white (256) and returns the pixel value for the corresponding gray level."
	"Note: This method must be called after initializeIndexedColors, since it uses IndexedColors."
	"Color initializeGrayToIndexMap"

	| grayLevels grayIndices c distToClosest dist indexOfClosest |
	"record the level and index of each gray in the 8-bit color table"
	grayLevels := OrderedCollection new.
	grayIndices := OrderedCollection new.
	"Note: skip the first entry, which is reserved for transparent"
	2 to: IndexedColors size do: [:i |
		c := IndexedColors at: i.
		c saturation = 0.0 ifTrue: [  "c is a gray"
			grayLevels add: (c privateBlue) >> 2.  "top 8 bits; R, G, and B are the same"
			grayIndices add: i - 1]].  "pixel values are zero-based"
	grayLevels := grayLevels asArray.
	grayIndices := grayIndices asArray.

	"for each gray level in [0..255], select the closest match"
	GrayToIndexMap := ByteArray new: 256.
	0 to: 255 do: [:level |
		distToClosest := 10000.  "greater than distance to any real gray"
		1 to: grayLevels size do: [:i |
			dist := (level - (grayLevels at: i)) abs.
			dist < distToClosest ifTrue: [
				distToClosest := dist.
				indexOfClosest := grayIndices at: i]].
		GrayToIndexMap at: (level + 1) put: indexOfClosest].

]

{ #category : #'class initialization' }
Color class >> initializeHighLights [
	"Create a set of Bitmaps for quickly reversing areas of the screen without converting colors. "
	"Color initializeHighLights"

	| t |
	t := Array new: 32.
	t at: 1 put: (Bitmap with: 16rFFFFFFFF).
	t at: 2 put: (Bitmap with: 16rFFFFFFFF).
	t at: 4 put: (Bitmap with: 16r55555555).
	t at: 8 put: (Bitmap with: 16r7070707).
	t at: 16 put: (Bitmap with: 16rFFFFFFFF).
	t at: 32 put: (Bitmap with: 16rFFFFFFFF).
	HighLightBitmaps := t.

]

{ #category : #'class initialization' }
Color class >> initializeIndexedColors [
	"Build an array of colors corresponding to the fixed colormap used
	 for display depths of 1, 2, 4, or 8 bits."
	"Color initializeIndexedColors"

	| a index grayVal |
	a := Array new: 256.

	"1-bit colors (monochrome)"
	a at: 1 put: (Color r: 1.0 g: 1.0 b: 1.0).		"white or transparent"
	a at: 2 put: (Color r: 0.0 g: 0.0 b: 0.0).	"black"

	"additional colors for 2-bit color"
	a at: 3 put: (Color r: 1.0 g: 1.0 b: 1.0).	"opaque white"
	a at: 4 put: (Color r: 0.5 g: 0.5 b: 0.5).	"1/2 gray"

	"additional colors for 4-bit color"
	a at:  5 put: (Color r: 1.0 g: 0.0 b: 0.0).	"red"
	a at:  6 put: (Color r: 0.0 g: 1.0 b: 0.0).	"green"
	a at:  7 put: (Color r: 0.0 g: 0.0 b: 1.0).	"blue"
	a at:  8 put: (Color r: 0.0 g: 1.0 b: 1.0).	"cyan"
	a at:  9 put: (Color r: 1.0 g: 1.0 b: 0.0).	"yellow"
	a at: 10 put: (Color r: 1.0 g: 0.0 b: 1.0).	"magenta"

	a at: 11 put: (Color r: 0.125 g: 0.125 b: 0.125).		"1/8 gray"
	a at: 12 put: (Color r: 0.25 g: 0.25 b: 0.25).		"2/8 gray"
	a at: 13 put: (Color r: 0.375 g: 0.375 b: 0.375).		"3/8 gray"
	a at: 14 put: (Color r: 0.625 g: 0.625 b: 0.625).		"5/8 gray"
	a at: 15 put: (Color r: 0.75 g: 0.75 b: 0.75).		"6/8 gray"
	a at: 16 put: (Color r: 0.875 g: 0.875 b: 0.875).		"7/8 gray"

	"additional colors for 8-bit color"
	"24 more shades of gray (1/32 increments but not repeating 1/8 increments)"
	index := 17.
	1 to: 31 do: [:v |
		(v \\ 4) = 0 ifFalse: [
			grayVal := v / 32.0.
			a at: index put: (Color r: grayVal g: grayVal b: grayVal).
			index := index + 1]].

	"The remainder of color table defines a color cube with six steps
	 for each primary color. Note that the corners of this cube repeat
	 previous colors, but this simplifies the mapping between RGB colors
	 and color map indices. This color cube spans indices 40 through 255
	 (indices 41-256 in this 1-based array)."
	0 to: 5 do: [:r |
		0 to: 5 do: [:g |
			0 to: 5 do: [:b |
				index := 41 + ((36 * r) + (6 * b) + g).
				index > 256 ifTrue: [
					self error: 'index out of range in color table compuation'].
				a at: index put: (Color r: r g: g b: b range: 5)]]].

	IndexedColors := a.

]

{ #category : #'class initialization' }
Color class >> initializeNames [
	"Name some colors."
	"Color initializeNames"

	ColorNames := Set new.
	self named: #black put: (Color r: 0 g: 0 b: 0).
	self named: #veryVeryDarkGray put: (Color r: 0.125 g: 0.125 b: 0.125).
	self named: #veryDarkGray put: (Color r: 0.25 g: 0.25 b: 0.25).
	self named: #darkGray put: (Color r: 0.375 g: 0.375 b: 0.375).
	self named: #gray put: (Color r: 0.5 g: 0.5 b: 0.5).
	self named: #lightGray put: (Color r: 0.625 g: 0.625 b: 0.625).
	self named: #veryLightGray put: (Color r: 0.75 g: 0.75 b: 0.75).
	self named: #veryVeryLightGray put: (Color r: 0.875 g: 0.875 b: 0.875).
	self named: #white put: (Color r: 1.0 g: 1.0 b: 1.0).
	self named: #red put: (Color r: 1.0 g: 0 b: 0).
	self named: #yellow put: (Color r: 1.0 g: 1.0 b: 0).
	self named: #green put: (Color r: 0 g: 1.0 b: 0).
	self named: #cyan put: (Color r: 0 g: 1.0 b: 1.0).
	self named: #blue put: (Color r: 0 g: 0 b: 1.0).
	self named: #magenta put: (Color r: 1.0 g: 0 b: 1.0).
	self named: #brown put: (Color r: 0.6 g: 0.2 b: 0).
	self named: #orange put: (Color r: 1.0 g: 0.6 b: 0).
	self named: #lightRed put: (Color r: 1.0 g: 0.8 b: 0.8).
	self named: #lightYellow put: (Color r: 1.0 g: 1.0 b: 0.8).
	self named: #lightGreen put: (Color r: 0.8 g: 1.0 b: 0.6).
	self named: #lightCyan put: (Color r: 0.4 g: 1.0 b: 1.0).
	self named: #lightBlue put: (Color r: 0.8 g: 1.0 b: 1.0).
	self named: #lightMagenta put: (Color r: 1.0 g: 0.8 b: 1.0).
	self named: #lightBrown put: (Color r: 1.0 g: 0.6 b: 0.2).
	self named: #lightOrange put: (Color r: 1.0 g: 0.8 b: 0.4).
	self named: #transparent put: (TranslucentColor new alpha: 0.0).
	self named: #paleBuff put: (Color r: 254 g: 250 b: 235 range: 255).
	self named: #paleBlue put: (Color r: 222 g: 249 b: 254 range: 255).
	self named: #paleYellow put: (Color r: 255 g: 255 b: 217 range: 255).
	self named: #paleGreen put: (Color r: 223 g: 255 b: 213 range: 255).
	self named: #paleRed put: (Color r: 255 g: 230 b: 230 range: 255).
	self named: #veryPaleRed put: (Color r: 255 g: 242 b: 242 range: 255).
	self named: #paleTan put: (Color r: 235 g: 224 b: 199 range: 255).
	self named: #paleMagenta put: (Color r: 255 g: 230 b: 255 range: 255).
	self named: #paleOrange put: (Color r: 253 g: 237 b: 215 range: 255).
	self named: #palePeach put: (Color r: 255 g: 237 b: 213 range: 255).
	self named: #pantonePurpleU put: (Color r: 193 g: 81 b: 184 range: 255).
	self initializeNamesMap


]

{ #category : #'class initialization' }
Color class >> initializeNamesMap [
	"enable mapping a color to its name"
	"Color initializeNamesMap"

	RGBToNames := Dictionary new.
	self colorNames do: [:sym | (self perform: sym) addName: sym]
]

{ #category : #'class initialization' }
Color class >> initializeTranslucentPatterns [
	"Color initializeTranslucentPatterns"
	
	TranslucentPatterns := Array new: 8.
	#(1 2 4 8) do:[:d| | pattern patternList mask bits |
		patternList := Array new: 5.
		mask := (1 bitShift: d) - 1.
		bits := 2 * d.
		[bits >= 32] whileFalse: [
			mask := mask bitOr: (mask bitShift: bits).  "double the length of mask"
			bits := bits + bits].
		"0% pattern"
		pattern := Bitmap with: 0 with: 0.
		patternList at: 1 put: pattern.
		"25% pattern"
		pattern := Bitmap with: mask with: 0.
		patternList at: 2 put: pattern.
		"50% pattern"
		pattern := Bitmap with: mask with: mask bitInvert32.
		patternList at: 3 put: pattern.
		"75% pattern"
		pattern := Bitmap with: mask with: 16rFFFFFFFF.
		patternList at: 4 put: pattern.
		"100% pattern"
		pattern := Bitmap with: 16rFFFFFFFF with: 16rFFFFFFFF.
		patternList at: 5 put: pattern.
		TranslucentPatterns at: d put: patternList.
	].
]

{ #category : #'named colors - crayons' }
Color class >> iron [

	^ Color r: 76/255 g: 76/255 b: 76/255
]

{ #category : #'named colors - crayons' }
Color class >> lavender [

	^ Color r: 204/255 g: 102/255 b: 1.0
]

{ #category : #'named colors - crayons' }
Color class >> lead [

	^ Color r: 25/255 g: 25/255 b: 25/255
]

{ #category : #'named colors - crayons' }
Color class >> lemon [

	^ Color r: 1.0 g: 1.0 b: 0.0
]

{ #category : #'named colors - crayons' }
Color class >> licorice [

	^ Color r: 0.0 g: 0.0 b: 0.0
]

{ #category : #'named colors' }
Color class >> lightBlue [
	^LightBlue
]

{ #category : #'named colors' }
Color class >> lightBrown [
	^LightBrown
]

{ #category : #'named colors' }
Color class >> lightCyan [
	^LightCyan
]

{ #category : #'named colors' }
Color class >> lightGray [
	^LightGray
]

{ #category : #'named colors' }
Color class >> lightGreen [
	^LightGreen
]

{ #category : #'named colors' }
Color class >> lightMagenta [
	^LightMagenta
]

{ #category : #'named colors' }
Color class >> lightOrange [
	^LightOrange
]

{ #category : #'named colors' }
Color class >> lightRed [
	^LightRed
]

{ #category : #'named colors' }
Color class >> lightYellow [
	^LightYellow
]

{ #category : #'named colors - crayons' }
Color class >> lime [

	^ Color r: 128/255 g: 1.0 b: 0.0
]

{ #category : #'named colors' }
Color class >> magenta [
	^Magenta
]

{ #category : #'named colors - crayons' }
Color class >> magnesium [

	^ Color r: 179/255 g: 179/255 b: 179/255
]

{ #category : #'named colors - crayons' }
Color class >> maraschino [

	^ Color r: 1.0 g: 0.0 b: 0.0
]

{ #category : #'named colors - crayons' }
Color class >> maroon [

	^ Color r: 128/255 g: 0.0 b: 64/255
]

{ #category : #other }
Color class >> maskingMap: depth [
	"Return a color map that maps all colors except transparent to words of all ones. Used to create a mask for a Form whose transparent pixel value is zero. Cache the most recently used map."

	| sizeNeeded |
	depth <= 8
		ifTrue: [sizeNeeded := 1 bitShift: depth]
		ifFalse: [sizeNeeded := 4096].

	(MaskingMap == nil or: [MaskingMap size ~= sizeNeeded]) ifTrue:
		[MaskingMap := Bitmap new: sizeNeeded withAll: 16rFFFFFFFF.
		MaskingMap at: 1 put: 0.  "transparent"].

	^ MaskingMap

]

{ #category : #'named colors - crayons' }
Color class >> mercury [

	^ Color r: 230.0 g: 230.0 b: 230.0
]

{ #category : #'named colors - crayons' }
Color class >> midnight [

	^ Color r: 0.0 g: 0.0 b: 128/255
]

{ #category : #'named colors - crayons' }
Color class >> mocha [

	^ Color r: 128/255 g: 64/255 b: 0.0
]

{ #category : #'named colors - crayons' }
Color class >> moss [

	^ Color r: 0.0 g: 128/255 b: 64/255
]

{ #category : #'class initialization' }
Color class >> named: newName put: aColor [
	"Add a new color to the list and create an access message and a class variable for it.  The name should start with a lowercase letter.  (The class variable will start with an uppercase letter.)  (Color colorNames) returns a list of all color names.  "
	| str cap sym accessor csym |
	(aColor isKindOf: self) ifFalse: [^ self error: 'not a Color'].
	str := newName asString.
	sym := str asSymbol.
	cap := str capitalized.
	csym := cap asSymbol.
	(self class canUnderstand: sym) ifFalse: [
		"define access message"
		accessor := str, (String with: Character cr with: Character tab), 			'^', cap.
		self class compile: accessor
			classified: 'named colors'].
	(self classPool includesKey: csym) ifFalse: [
		self addClassVarName: cap].
	ColorNames add: sym.
	^ self classPool at: csym put: aColor
]

{ #category : #'instance creation' }
Color class >> new [

	^ self r: 0.0 g: 0.0 b: 0.0
]

{ #category : #'named colors - crayons' }
Color class >> nickel [

	^ Color r: 128/255 g: 128/255 b: 128/255
]

{ #category : #'named colors - crayons' }
Color class >> ocean [

	^ Color r: 0.0 g: 64/255 b: 128/255
]

{ #category : #'color from user' }
Color class >> oldColorPaletteForDepth: depth extent: paletteExtent [
	"Returns a form of the given size showing a color palette for the given depth."
	"(Color oldColorPaletteForDepth: Display depth extent: 720@100) display"

	| c p f nSteps rect w h q |
	f := Form extent: paletteExtent depth: depth.
	f fill: f boundingBox fillColor: Color white.
	nSteps := depth > 8 ifTrue: [12] ifFalse: [6].
	w := paletteExtent x // (nSteps * nSteps).
	h := paletteExtent y - 20 // nSteps.
	0 to: nSteps-1 do: [:r |
		0 to: nSteps-1 do: [:g |
			0 to: nSteps-1 do: [:b |
				c := Color r: r g: g b: b range: nSteps - 1.
				rect := ((r * nSteps * w) + (b * w)) @ (g * h) extent: w@(h + 1).
				f fill: rect fillColor: c]]].
	q := Quadrangle origin: paletteExtent - (50@19) corner: paletteExtent.
	q displayOn: f.
	'Trans.' displayOn: f at: q origin + (9@1).

	w := ((paletteExtent x - q width - 130) // 64) max: 1.
	p := paletteExtent x - q width - (64 * w) - 1 @ (paletteExtent y - 19).
	0 to: 63 do:
		[:v | c := Color r: v g: v b: v range: 63.
		f fill: ((v * w)@0 + p extent: (w + 1)@19) fillColor: c].
	^ f

]

{ #category : #'named colors' }
Color class >> orange [
	^Orange
]

{ #category : #'named colors - crayons' }
Color class >> orchid [

	^ Color r: 102/255 g: 102/255 b: 1.0
]

{ #category : #other }
Color class >> orderedCrayonColorNames [
	
	^ #(cantaloupe honeydew spindrift sky lavender carnation licorice snow salmon banana flora ice orchid bubblegum lead mercury tangerine lime seaFoam aqua grape strawberry tungsten silver maraschino lemon spring turquoise blueberry magenta iron magnesium mocha fern moss ocean eggplant maroon steel aluminum cayenne asparagus clover teal midnight plum tin nickel)
]

{ #category : #other }
Color class >> orderedCrayonColors [
	"self orderedCrayonColors explore."
	
	^ OrderedDictionary newFrom: (self orderedCrayonColorNames collect: [:ea | ea -> (self perform: ea)])
]

{ #category : #'named colors' }
Color class >> paleBlue [
	^PaleBlue
]

{ #category : #'named colors' }
Color class >> paleBuff [
	^PaleBuff
]

{ #category : #'named colors' }
Color class >> paleGreen [
	^PaleGreen
]

{ #category : #'named colors' }
Color class >> paleMagenta [
	^PaleMagenta
]

{ #category : #'named colors' }
Color class >> paleOrange [
	^PaleOrange
]

{ #category : #'named colors' }
Color class >> palePeach [
	^PalePeach
]

{ #category : #'named colors' }
Color class >> paleRed [
	^PaleRed
]

{ #category : #'named colors' }
Color class >> paleTan [
	^PaleTan
]

{ #category : #'named colors' }
Color class >> paleYellow [
	^PaleYellow
]

{ #category : #'named colors' }
Color class >> pantonePurpleU [
	^PantonePurpleU
]

{ #category : #other }
Color class >> pixelScreenForDepth: depth [
	"Return a 50% stipple containing alternating pixels of all-zeros and all-ones to be used as a mask at the given depth."

	| mask bits |
	mask := (1 bitShift: depth) - 1.
	bits := 2 * depth.
	[bits >= 32] whileFalse: [
		mask := mask bitOr: (mask bitShift: bits).  "double the length of mask"
		bits := bits + bits].
	^ Bitmap with: mask with: mask bitInvert32

]

{ #category : #'named colors - crayons' }
Color class >> plum [

	^ Color r: 128/255 g: 0.0 b: 128/255
]

{ #category : #other }
Color class >> quickHighLight: depth [
	"Quickly return a Bitblt-ready raw colorValue for highlighting areas.  6/22/96 tk"

	^ HighLightBitmaps at: depth
]

{ #category : #'instance creation' }
Color class >> r: r g: g b: b [
	"Return a color with the given r, g, and b components in the range [0.0..1.0]."

	^ self basicNew setRed: r green: g blue: b

]

{ #category : #'instance creation' }
Color class >> r: r g: g b: b alpha: alpha [

	^ (self r: r g: g b: b) alpha: alpha
]

{ #category : #'instance creation' }
Color class >> r: r g: g b: b range: range [
	"Return a color with the given r, g, and b components specified as integers in the range [0..r]. This avoids the floating point arithmetic in the red:green:blue: message and is thus a bit faster for certain applications (such as computing a sequence of colors for a palette)."

	^ self basicNew setRed: r green: g blue: b range: range
]

{ #category : #'instance creation' }
Color class >> random [
	"Return a random color that isn't too dark or under-saturated."

	^ self basicNew
		setHue: (360.0 * RandomStream next)
		saturation: (0.3 + (RandomStream next * 0.7))
		brightness: (0.4 + (RandomStream next * 0.6))
]

{ #category : #'named colors' }
Color class >> red [
	^Red
]

{ #category : #'named colors - crayons' }
Color class >> salmon [

	^ Color r: 1.0 g: 102/255 b: 102/255
]

{ #category : #'named colors - crayons' }
Color class >> seaFoam [

	^ Color r: 0.0 g: 1.0 b: 128/255
]

{ #category : #examples }
Color class >> showColorCube [
	"Show a 12x12x12 color cube."
	"Color showColorCube"

	0 to: 11 do: [:r |
		0 to: 11 do: [:g |
			0 to: 11 do: [:b |	
				Display fill: (((r*60) + (b*5)) @ (g*5) extent: 5@5)
					fillColor: (Color r: r g: g b: b range: 11)]]].

]

{ #category : #examples }
Color class >> showColors: colorList [
	"Display the given collection of colors across the top of the Display."

	| w r |
	w := Display width // colorList size.
	r := 0@0 extent: w@((w min: 30) max: 10).
	colorList do: [:c |
		Display fill: r fillColor: c.
		r := r translateBy: w@0].

]

{ #category : #examples }
Color class >> showHSVPalettes [
	"Shows a palette of hues, varying the saturation and brightness for each one. Best results are with depths 16 and 32."
	"Color showHSVPalettes"

	| left top c |
	left := top := 0.
	0 to: 179 by: 15 do: [:h |
		0 to: 10 do: [:s |
			left := (h * 4) + (s * 4).
			0 to: 10 do: [:v |
				c := Color h: h s: s asFloat / 10.0 v: v asFloat / 10.0.
				top := (v * 4).
				Display fill: (left@top extent: 4@4) fillColor: c.

				c := Color h: h + 180 s: s asFloat / 10.0 v: v asFloat / 10.0.
				top := (v * 4) + 50.
				Display fill: (left@top extent: 4@4) fillColor: c]]].

]

{ #category : #examples }
Color class >> showHuesInteractively [
	"Shows a palette of hues at a (saturation, brightness) point determined by the mouse position. Click the mouse button to exit and return the selected (saturation, brightness) point."
	"Color showHuesInteractively"

	| p s v |
	[Sensor anyButtonPressed] whileFalse: [
		p := Sensor cursorPoint.
		s := p x asFloat / 300.0.
		v := p y asFloat / 300.0.
		self showColors: (self wheel: 12 saturation: s brightness: v)].
	^ (s min: 1.0) @ (v min: 1.0)
]

{ #category : #other }
Color class >> shutDown [
	"Color shutDown"

	ColorChart := nil.		"Palette of colors for the user to pick from"
	CachedColormaps := nil.	"Maps to translate between color depths"
	MaskingMap := nil.		"Maps all colors except transparent to black for creating a mask"

]

{ #category : #'named colors - crayons' }
Color class >> silver [

	^ Color r: 204/255 g: 204/255 b: 204/255
]

{ #category : #'named colors - crayons' }
Color class >> sky [

	^ Color r: 102/255 g: 204/255 b: 1.0
]

{ #category : #'named colors - crayons' }
Color class >> snow [

	^ Color r: 1.0 g: 1.0 b: 1.0
]

{ #category : #'named colors - crayons' }
Color class >> spindrift [

	^ Color r: 102/255 g: 1.0 b: 204/255
]

{ #category : #'named colors - crayons' }
Color class >> spring [

	^ Color r: 0.0 g: 1.0 b: 0.0
]

{ #category : #'named colors - crayons' }
Color class >> steel [

	^ Color r: 102/255 g: 102/255 b: 102/255
]

{ #category : #'named colors - crayons' }
Color class >> strawberry [

	^ Color r: 1.0 g: 0.0 b: 128/255
]

{ #category : #'named colors' }
Color class >> tan [
	^  Color r: 0.8 g: 0.8 b: 0.5
]

{ #category : #'named colors - crayons' }
Color class >> tangerine [

	^ Color r: 1.0 g: 128/255 b: 0.0
]

{ #category : #'named colors - crayons' }
Color class >> teal [

	^ Color r: 0.0 g: 128/255 b: 128/255
]

{ #category : #'named colors - crayons' }
Color class >> tin [

	^ Color r: 127/255 g: 127/255 b: 127/255
]

{ #category : #other }
Color class >> translucentMaskFor: alphaValue depth: d [
	"Return a pattern representing a mask usable for stipple transparency"
	^(TranslucentPatterns at: d) at: ((alphaValue min: 1.0 max: 0.0) * 4) rounded + 1
]

{ #category : #'named colors' }
Color class >> transparent [
	^Transparent
]

{ #category : #'named colors - crayons' }
Color class >> tungsten [

	^ Color r: 51/255 g: 51/255 b: 51/255
]

{ #category : #'named colors - crayons' }
Color class >> turquoise [

	^ Color r: 0.0 g: 1.0 b: 1.0
]

{ #category : #'named colors' }
Color class >> veryDarkGray [
	^VeryDarkGray
]

{ #category : #'named colors' }
Color class >> veryLightGray [
	^VeryLightGray
]

{ #category : #'named colors' }
Color class >> veryPaleRed [
	^VeryPaleRed
]

{ #category : #'named colors' }
Color class >> veryVeryDarkGray [
	^VeryVeryDarkGray
]

{ #category : #'named colors' }
Color class >> veryVeryLightGray [
	^VeryVeryLightGray
]

{ #category : #examples }
Color class >> wheel: thisMany [
	"Return a collection of thisMany colors evenly spaced around the color wheel."
	"Color showColors: (Color wheel: 12)"

	^ Color wheel: thisMany saturation: 0.9 brightness: 0.7

]

{ #category : #examples }
Color class >> wheel: thisMany saturation: s brightness: v [
	"Return a collection of thisMany colors evenly spaced around the color wheel, all of the given saturation and brightness."
	"Color showColors: (Color wheel: 12 saturation: 0.4 brightness: 1.0)"
	"Color showColors: (Color wheel: 12 saturation: 0.8 brightness: 0.5)"

	^ (Color h: 0.0 s: s v: v) wheel: thisMany

]

{ #category : #'named colors' }
Color class >> white [
	^White
]

{ #category : #'named colors' }
Color class >> yellow [
	^Yellow
]

{ #category : #transformations }
Color >> * aNumberOrArray [
	"Answer this color with its RGB multiplied by the given number, or
	 multiply this color's RGB values by the corresponding entries in the
	given array."
	"(Color brown * 2) display"
	"(Color brown * #(1 0 1)) display"
	| multipliers |
	multipliers := aNumberOrArray isCollection
		ifTrue: [aNumberOrArray]
		ifFalse:
			[Array
				with: aNumberOrArray
				with: aNumberOrArray
				with: aNumberOrArray].

	^ Color basicNew
		setPrivateRed: (self privateRed * multipliers first) asInteger
		green: (self privateGreen * multipliers second) asInteger
		blue: (self privateBlue * multipliers third) asInteger.
]

{ #category : #transformations }
Color >> + aColor [
	"Answer this color mixed with the given color in an additive color space.  "
	"(Color blue + Color green) display"

	^ Color basicNew
		setPrivateRed: self privateRed + aColor privateRed
		green: self privateGreen + aColor privateGreen
		blue: self privateBlue + aColor  privateBlue

]

{ #category : #transformations }
Color >> - aColor [
	"Answer aColor is subtracted from the given color in an additive color space.  "
	"(Color white - Color red) display"

	^ Color basicNew
		setPrivateRed: self privateRed - aColor privateRed
		green: self privateGreen - aColor privateGreen
		blue: self privateBlue - aColor  privateBlue

]

{ #category : #transformations }
Color >> / aNumber [
	"Answer this color with its RGB divided by the given number. "
	"(Color red / 2) display"

	^ Color basicNew
		setPrivateRed: (self privateRed / aNumber) asInteger
		green: (self privateGreen / aNumber) asInteger
		blue: (self privateBlue / aNumber) asInteger

]

{ #category : #comparing }
Color >> = aColor [
	"Return true if the receiver equals the given color. This method handles TranslucentColors, too."

	aColor isColor ifFalse: [^ false].
	^ aColor privateRGB = rgb and:
		[aColor privateAlpha = self privateAlpha]

]

{ #category : #'Morphic menu' }
Color >> addFillStyleMenuItems: aMenu hand: aHand from: aMorph [
	"Add the items for changing the current fill style of the receiver"
	aMenu add: 'change color...' translated target: self selector: #changeColorIn:event: argument: aMorph
]

{ #category : #other }
Color >> addName: aSymbol [
	"private - associate a name to this color."
	
	| knownNames |
	[(self class respondsTo: aSymbol) and: [(self class perform: aSymbol) = self]] assert.
	knownNames := RGBToNames at: rgb ifAbsent: [#()].
	(knownNames includes: aSymbol)
		ifFalse: [ RGBToNames at: rgb put: (knownNames copyWith: aSymbol)]
]

{ #category : #transformations }
Color >> adjustBrightness: brightness [
	"Adjust the relative brightness of this color. (lowest value is 0.005 so that hue information is not lost)"

	^ Color
		h: self hue
		s: self saturation
		v: (self brightness + brightness min: 1.0 max: 0.005)
		alpha: self alpha
]

{ #category : #transformations }
Color >> adjustSaturation: saturation brightness: brightness [
	"Adjust the relative saturation and brightness of this color. (lowest value is 0.005 so that hue information is not lost)"

	^ Color
		h: self hue
		s: (self saturation + saturation min: 1.0 max: 0.005)
		v: (self brightness + brightness min: 1.0 max: 0.005)
		alpha: self alpha
]

{ #category : #accessing }
Color >> alpha [
	"Return the opacity ('alpha') value of opaque so that normal colors can be compared to TransparentColors."

	^ 1.0

]

{ #category : #transformations }
Color >> alpha: alphaValue [ 
	"Answer a new Color with the given amount of opacity ('alpha')."

	alphaValue = 1.0
		ifFalse: [^ TranslucentColor basicNew setRgb: rgb alpha: alphaValue]
]

{ #category : #transformations }
Color >> alphaMixed: proportion with: aColor [ 
	"Answer this color mixed with the given color. The proportion, a number 
	between 0.0 and 1.0, determines what what fraction of the receiver to  
	use in the mix. For example, 0.9 would yield a color close to the  
	receiver. This method uses RGB interpolation; HSV interpolation can lead 
	to surprises.  Mixes the alphas (for transparency) also."

	| frac1 frac2 |
	frac1 := proportion asFloat min: 1.0 max: 0.0.
	frac2 := 1.0 - frac1.
	^ Color
		r: self red * frac1 + (aColor red * frac2)
		g: self green * frac1 + (aColor green * frac2)
		b: self blue * frac1 + (aColor blue * frac2)
		alpha: self alpha * frac1 + (aColor alpha * frac2)
]

{ #category : #conversions }
Color >> asColor [
	"Convert the receiver into a color"
	^self
]

{ #category : #conversions }
Color >> asColorref [
	"Convert the receiver into a colorref"
	^ (self red * 255) rounded + ((self green * 255) rounded << 8) + ((self blue * 255) rounded << 16)
]

{ #category : #conversions }
Color >> asHTMLColor [
	| s |
	s := '#000000' copy.
	s at: 2 put: (Character digitValue: ((rgb bitShift: -6 - RedShift) bitAnd: 15)).
	s at: 3 put: (Character digitValue: ((rgb bitShift: -2 - RedShift) bitAnd: 15)).
	s at: 4 put: (Character digitValue: ((rgb bitShift: -6 - GreenShift) bitAnd: 15)).
	s at: 5 put: (Character digitValue: ((rgb bitShift: -2 - GreenShift) bitAnd: 15)).
	s at: 6 put: (Character digitValue: ((rgb bitShift: -6 - BlueShift) bitAnd: 15)).
	s at: 7 put: (Character digitValue: ((rgb bitShift: -2 - BlueShift) bitAnd: 15)).
	^ s
]

{ #category : #conversions }
Color >> asNontranslucentColor [
	^ self
]

{ #category : #transformations }
Color >> atLeastAsLuminentAs: aFloat [

	| revisedColor |
	revisedColor := self.
	[revisedColor luminance < aFloat] whileTrue: [revisedColor := revisedColor slightlyLighter].
	^revisedColor

]

{ #category : #transformations }
Color >> atMostAsLuminentAs: aFloat [

	| revisedColor |
	revisedColor := self.
	[revisedColor luminance > aFloat] whileTrue: [revisedColor := revisedColor slightlyDarker].
	^revisedColor

]

{ #category : #private }
Color >> attemptToMutateError [
	"A color is immutable. Once a color's red, green, and blue have been initialized, you cannot change them. Instead, create a new Color and use it."

	self error: 'Color objects are immutable once created'

]

{ #category : #conversions }
Color >> balancedPatternForDepth: depth [
	"A generalization of bitPatternForDepth: as it exists.  Generates a 2x2 stipple of color.
	The topLeft and bottomRight pixel are closest approx to this color"
	| pv1 pv2 mask1 mask2 pv3 c |
	(depth == cachedDepth and:[cachedBitPattern size = 2]) ifTrue: [^ cachedBitPattern].
	(depth between: 4 and: 16) ifFalse: [^ self bitPatternForDepth: depth].
	cachedDepth := depth.
	pv1 := self pixelValueForDepth: depth.
"
	Subtract error due to pv1 to get pv2.
	pv2 := (self - (err1 := (Color colorFromPixelValue: pv1 depth: depth) - self))
						pixelValueForDepth: depth.
	Subtract error due to 2 pv1's and pv2 to get pv3.
	pv3 := (self - err1 - err1 - ((Color colorFromPixelValue: pv2 depth: depth) - self))
						pixelValueForDepth: depth.
"
	"Above two statements computed faster by the following..."
	pv2 := (c := self - ((Color colorFromPixelValue: pv1 depth: depth) - self))
						pixelValueForDepth: depth.
	pv3 := (c + (c - (Color colorFromPixelValue: pv2 depth: depth)))
						pixelValueForDepth: depth.

	"Return to a 2-word bitmap that encodes a 2x2 stipple of the given pixelValues."
	mask1 := (#(- - -	
			16r01010101 - - -			"replicates every other 4 bits"
			16r00010001 - - - - - - -	"replicates every other 8 bits"
			16r00000001) at: depth).	"replicates every other 16 bits"
	mask2 := (#(- - -	
			16r10101010 - - -			"replicates the other 4 bits"
			16r01000100 - - - - - - -	"replicates the other 8 bits"
			16r00010000) at: depth).	"replicates the other 16 bits"
	^ cachedBitPattern := Bitmap with: (mask1*pv1) + (mask2*pv2) with: (mask1*pv3) + (mask2*pv1)
]

{ #category : #conversions }
Color >> bitPatternForDepth: depth [
	"Return a Bitmap, possibly containing a stipple pattern, that best represents this color at the given depth. BitBlt calls this method to convert colors into Bitmaps. The resulting Bitmap may be multiple words to represent a stipple pattern of several lines.  "
	"See also:	pixelValueAtDepth:	-- value for single pixel
				pixelWordAtDepth:	-- a 32-bit word filled with the pixel value"
	"Details: The pattern for the most recently requested depth is cached."
	"Note for depths > 2, there are stippled and non-stippled versions (generated with #balancedPatternForDepth: and #bitPatternForDepth:, respectively). The stippled versions don't work with the window bit caching of StandardSystemView, so we make sure that for these depths, only unstippled patterns are returned"

	(depth == cachedDepth and: [depth <= 2 or: [cachedBitPattern size = 1]]) ifTrue: [^ cachedBitPattern].
	cachedDepth := depth.

	depth > 2 ifTrue: [^ cachedBitPattern := Bitmap with: (self pixelWordForDepth: depth)].
	depth = 1 ifTrue: [^ cachedBitPattern := self halfTonePattern1].
	depth = 2 ifTrue: [^ cachedBitPattern := self halfTonePattern2].

]

{ #category : #transformations }
Color >> blacker [

	^ self alphaMixed: 0.8333 with: Color black

]

{ #category : #accessing }
Color >> blue [
	"Return the blue component of this color, a float in the range [0.0..1.0]."

	^ self privateBlue asFloat / ComponentMax
]

{ #category : #accessing }
Color >> brightness [
	"Return the brightness of this color, a float in the range [0.0..1.0]."

	^ ((self privateRed max:
	    self privateGreen) max:
	    self privateBlue) asFloat / ComponentMax
]

{ #category : #printing }
Color >> byteEncode: aStream [

	aStream
		print: '(';
		print: self species name;
		print: ' r: ';
		write: (self red roundTo: 0.001);
		print: ' g: ';
		write: (self green roundTo: 0.001);
		print: ' b: ';
		write: (self blue roundTo: 0.001) ;
		print: ')'.

]

{ #category : #'Morphic menu' }
Color >> changeColorIn: aMorph event: evt [
	"Note: This is just a workaround to make sure we don't use the old color inst var"
	aMorph changeColorTarget: aMorph selector: #fillStyle: originalColor: self hand: evt hand
]

{ #category : #conversions }
Color >> closestPixelValue1 [
	"Return the nearest approximation to this color for a monochrome Form."

	"fast special cases"
	rgb = 0 ifTrue: [^ 1].  "black"
	rgb = 16r3FFFFFFF ifTrue: [^ 0].  "white"

	self luminance > 0.5
		ifTrue: [^ 0]  "white"
		ifFalse: [^ 1].  "black"

]

{ #category : #conversions }
Color >> closestPixelValue2 [
	"Return the nearest approximation to this color for a 2-bit deep Form."

	| lum |
	"fast special cases"
	rgb = 0 ifTrue: [^ 1].  "black"
	rgb = 16r3FFFFFFF ifTrue: [^ 2].  "opaque white"

	lum := self luminance.
	lum < 0.2 ifTrue: [^ 1].  "black"
	lum > 0.6 ifTrue: [^ 2].  "opaque white"
	^ 3  "50% gray"

]

{ #category : #conversions }
Color >> closestPixelValue4 [
	"Return the nearest approximation to this color for a 4-bit deep Form."

	| bIndex |
	"fast special cases"
	rgb = 0 ifTrue: [^ 1].  "black"
	rgb = 16r3FFFFFFF ifTrue: [^ 2].  "opaque white"

	rgb = PureRed privateRGB ifTrue: [^ 4].
	rgb = PureGreen privateRGB ifTrue: [^ 5].
	rgb = PureBlue privateRGB ifTrue: [^ 6].
	rgb = PureCyan privateRGB ifTrue: [^ 7].
	rgb = PureYellow privateRGB ifTrue: [^ 8].
	rgb = PureMagenta privateRGB ifTrue: [^ 9].

	bIndex := (self luminance * 8.0) rounded.  "bIndex in [0..8]"
	^ #(
		1	"black"
		10	"1/8 gray"
		11	"2/8 gray"
		12	"3/8 gray"
		3	"4/8 gray"
		13	"5/8 gray"
		14	"6/8 gray"
		15	"7/8 gray"
		2	"opaque white"
	) at: bIndex + 1.

]

{ #category : #conversions }
Color >> closestPixelValue8 [
	"Return the nearest approximation to this color for an 8-bit deep Form."

	"fast special cases"
	rgb = 0 ifTrue: [^ 1].  "black"
	rgb = 16r3FFFFFFF ifTrue: [^ 255].  "white"

	self saturation < 0.2 ifTrue: [
		^ GrayToIndexMap at: (self privateGreen >> 2) + 1.  "nearest gray"
	] ifFalse: [
		"compute nearest entry in the color cube"
		^ 40 +
		  ((((self privateRed * 5) + HalfComponentMask) // ComponentMask) * 36) +
		  ((((self privateBlue * 5) + HalfComponentMask) // ComponentMask) * 6) +
		  (((self privateGreen * 5) + HalfComponentMask) // ComponentMask)].

]

{ #category : #other }
Color >> colorForInsets [
	^ self
]

{ #category : #transformations }
Color >> dansDarker [
	"Return a darker shade of the same color.
	An attempt to do better than the current darker method.
	(now obsolete, since darker has been changed to do this. -dew)"
	^ Color h: self hue s: self saturation
		v: (self brightness - 0.16 max: 0.0)
]

{ #category : #'groups of shades' }
Color >> darkShades: thisMany [
	"An array of thisMany colors from black to the receiver.  Array is of length num. Very useful for displaying color based on a variable in your program.  "
	"Color showColors: (Color red darkShades: 12)"

	^ self class black mix: self shades: thisMany

]

{ #category : #transformations }
Color >> darker [
	"Answer a darker shade of this color."

	^ self adjustBrightness: -0.08
]

{ #category : #comparing }
Color >> diff: theOther [
	"Returns a number between 0.0 and 1.0"

	^ ((self privateRed - theOther privateRed) abs
		+ (self privateGreen - theOther privateGreen) abs
		+ (self privateBlue - theOther privateBlue) abs)
		/ 3.0 / ComponentMax
]

{ #category : #other }
Color >> display [
	"Show a swatch of this color tracking the cursor until the next mouseClick. "
	"Color red display"
	| f |
	f := Form extent: 40@20 depth: Display depth.
	f fillColor: self.
	Cursor blank showWhile:
		[f follow: [Sensor cursorPoint] while: [Sensor noButtonPressed]]
]

{ #category : #conversions }
Color >> dominantColor [
	^ self
]

{ #category : #transformations }
Color >> duller [
	"Answer a darker, desaturated color.  If the original color isn't very saturated, desaturate it by less (otherwise will just end up with grey). If the original color is a grey, don't try to be smart."
	| sat adjust |
	(sat := self saturation) > 0.3
		ifTrue: [adjust := -0.1]
		ifFalse: [adjust := 0.1 - sat max: 0.0].
	^ sat isZero 
		ifTrue: [self adjustBrightness: -0.1]
		ifFalse: [self adjustSaturation: adjust brightness: -0.1]
]

{ #category : #private }
Color >> flushCache [
	"Flush my cached bit pattern."

	cachedDepth := nil.
	cachedBitPattern := nil.

]

{ #category : #accessing }
Color >> green [
	"Return the green component of this color, a float in the range [0.0..1.0]."

	^ self privateGreen asFloat / ComponentMax
]

{ #category : #conversions }
Color >> halfTonePattern1 [
	"Return a halftone-pattern to approximate luminance levels on 1-bit deep Forms."

	| lum |
	lum := self luminance.
	lum < 0.1 ifTrue: [^ Bitmap with: 16rFFFFFFFF]. "black"
	lum < 0.4 ifTrue: [^ Bitmap with: 16rBBBBBBBB with: 16rEEEEEEEE]. "dark gray"
	lum < 0.6 ifTrue: [^ Bitmap with: 16r55555555 with: 16rAAAAAAAA]. "medium gray"
	lum < 0.9 ifTrue: [^ Bitmap with: 16r44444444 with: 16r11111111]. "light gray"
	^ Bitmap with: 0  "1-bit white"

]

{ #category : #conversions }
Color >> halfTonePattern2 [
	"Return a halftone-pattern to approximate luminance levels on 2-bit deep Forms."

	| lum |
	lum := self luminance.
	lum < 0.125 ifTrue: [^ Bitmap with: 16r55555555].  "black"
	lum < 0.25 ifTrue: [^ Bitmap with: 16r55555555 with: 16rDDDDDDDD].  "1/8 gray"
	lum < 0.375 ifTrue: [^ Bitmap with: 16rDDDDDDDD with: 16r77777777].  "2/8 gray"
	lum < 0.5 ifTrue: [^ Bitmap with: 16rFFFFFFFF with: 16r77777777].  "3/8 gray"
	lum < 0.625 ifTrue: [^ Bitmap with: 16rFFFFFFFF].  "4/8 gray"
	lum < 0.75 ifTrue: [^ Bitmap with: 16rFFFFFFFF with: 16rBBBBBBBB].  "5/8 gray"
	lum < 0.875 ifTrue: [^ Bitmap with: 16rEEEEEEEE with: 16rBBBBBBBB].  "6/8 gray"
	lum < 1.0 ifTrue: [^ Bitmap with: 16rAAAAAAAA with: 16rBBBBBBBB].  "7/8 gray"
	^ Bitmap with: 16rAAAAAAAA  "opaque white"

"handy expression for computing patterns for 2x2 tiles;
 set p to a string of 4 letters (e.g., 'wggw' for a gray-and-
 white checkerboard) and print the result of evaluating:
| p d w1 w2 |
p := 'wggw'.
d := Dictionary new.
d at: $b put: '01'.
d at: $w put: '10'.
d at: $g put: '11'.
w1 := (d at: (p at: 1)), (d at: (p at: 2)).
w1 := '2r', w1, w1, w1, w1, w1, w1, w1, w1, ' hex'.
w2 := (d at: (p at: 3)), (d at: (p at: 4)).
w2 := '2r', w2, w2, w2, w2, w2, w2, w2, w2, ' hex'.
Array with: (Compiler evaluate: w1) with: (Compiler evaluate: w2) 
"
]

{ #category : #comparing }
Color >> hash [

	^ rgb
]

{ #category : #accessing }
Color >> hue [
	"Return the hue of this color, an angle in the range [0.0..360.0]."

	| r g b max min span h |
	r := self privateRed.
	g := self privateGreen.
	b := self privateBlue. 

	max := ((r max: g) max: b).
	min := ((r min: g) min: b).
	span := (max - min) asFloat.
	span = 0.0 ifTrue: [ ^ 0.0 ].

	r = max ifTrue: [
		h := ((g - b) asFloat / span) * 60.0.
	] ifFalse: [
		g = max
			ifTrue: [ h := 120.0 + (((b - r) asFloat / span) * 60.0). ]
			ifFalse: [ h := 240.0 + (((r - g) asFloat / span) * 60.0). ].
	].

	h < 0.0 ifTrue: [ h := 360.0 + h ].
	^ h
]

{ #category : #conversions }
Color >> indexInMap: aColorMap [
	"Return the index corresponding to this color in the given color map. RGB colors are truncated to 3-, 4-, or 5-bits per color component when indexing into such a colorMap.  "

	aColorMap size = 2 ifTrue: [^ (self pixelValueForDepth: 1) + 1].
	aColorMap size = 4 ifTrue: [^ (self pixelValueForDepth: 2) + 1].
	aColorMap size = 16 ifTrue: [^ (self pixelValueForDepth: 4) + 1].
	aColorMap size = 256 ifTrue: [^ (self pixelValueForDepth: 8) + 1].
	aColorMap size = 512 ifTrue: [^ (self pixelValueForDepth: 9) + 1].
	aColorMap size = 4096 ifTrue: [^ (self pixelValueForDepth: 12) + 1].
	aColorMap size = 32768 ifTrue: [^ (self pixelValueForDepth: 16) + 1].
	self error: 'unknown pixel depth'.

]

{ #category : #testing }
Color >> isBitmapFill [
	^false
]

{ #category : #testing }
Color >> isBlack [
	"Return true if the receiver represents black"
	^rgb = 0
]

{ #category : #testing }
Color >> isColor [

	^ true

]

{ #category : #testing }
Color >> isGradientFill [
	^false
]

{ #category : #testing }
Color >> isGray [
	"Return true if the receiver represents a shade of gray"
	^(self privateRed = self privateGreen) and:[self privateRed = self privateBlue]
]

{ #category : #testing }
Color >> isOpaque [
	^true
]

{ #category : #testing }
Color >> isOrientedFill [
	"Return true if the receiver keeps an orientation (e.g., origin, direction, and normal)"
	^false
]

{ #category : #testing }
Color >> isSolidFill [
	^true
]

{ #category : #testing }
Color >> isTranslucent [

	^ false

]

{ #category : #testing }
Color >> isTranslucentColor [
	"This means: self isTranslucent, but isTransparent not"
	^ false
]

{ #category : #testing }
Color >> isTransparent [

	^ false

]

{ #category : #'groups of shades' }
Color >> lightShades: thisMany [
	"An array of thisMany colors from white to self. Very useful for displaying color based on a variable in your program.  "
	"Color showColors: (Color red lightShades: 12)"

	^ self class white mix: self shades: thisMany

]

{ #category : #transformations }
Color >> lighter [
	"Answer a lighter shade of this color."

	^ self adjustSaturation: -0.03 brightness: 0.08
]

{ #category : #accessing }
Color >> luminance [
	"Return the luminance of this color, a brightness value weighted by the human eye's color sensitivity."

	^ ((299 * self privateRed) +
	   (587 * self privateGreen) +
	   (114 * self privateBlue)) / (1000 * ComponentMax)

]

{ #category : #conversions }
Color >> makeForegroundColor [
        "Make a foreground color contrasting with me"
        ^self luminance >= 0.5
                ifTrue: [Color black]
                ifFalse: [Color white]
]

{ #category : #'groups of shades' }
Color >> mix: color2 shades: thisMany [
	"Return an array of thisMany colors from self to color2. Very useful for displaying color based on a variable in your program.  "
	"Color showColors: (Color red mix: Color green shades: 12)"

	| redInc greenInc blueInc out rr gg bb |
	thisMany = 1 ifTrue: [^ Array with: color2].
	redInc := color2 red - self red / (thisMany-1).
	greenInc := color2 green - self green / (thisMany-1).
	blueInc := color2 blue - self blue / (thisMany-1).
	rr := self red.  gg := self green.  bb := self blue.
	out := (1 to: thisMany) collect: [:num | | c |
		c := Color r: rr g: gg b: bb.
		rr := rr + redInc.
		gg := gg + greenInc.
		bb := bb + blueInc.
		c].
	out at: out size put: color2.	"hide roundoff errors"
	^ out

]

{ #category : #transformations }
Color >> mixed: proportion with: aColor [ 
	"Mix with another color and do not preserve transpareny.  Only use this for extracting the RGB value and mixing it.  All other callers should use instead: 
	aColor alphaMixed: proportion with: anotherColor
	"

	| frac1 frac2 |
	frac1 := proportion asFloat min: 1.0 max: 0.0.
	frac2 := 1.0 - frac1.
	^ Color
		r: self red * frac1 + (aColor red * frac2)
		g: self green * frac1 + (aColor green * frac2)
		b: self blue * frac1 + (aColor blue * frac2)
]

{ #category : #transformations }
Color >> muchDarker [

	^ self alphaMixed: 0.5 with: Color black

]

{ #category : #transformations }
Color >> muchLighter [

	^ self alphaMixed: 0.233 with: Color white

]

{ #category : #other }
Color >> name [
	"Return this color's name, or nil if it has no name."

	^ (RGBToNames at: rgb ifAbsent: [nil]) ifNotNil: [:names | names at: 1 ifAbsent: [nil]]
]

{ #category : #other }
Color >> names [
	"Return a collection of all known names for this color.
	These are Symbol that can be used as message send to Color."

	^ RGBToNames at: rgb ifAbsent: [Array new]
]

{ #category : #transformations }
Color >> negated [
	"Return an RGB inverted color"
	^Color
		r: 1.0 - self red
		g: 1.0 - self green
		b: 1.0 - self blue
]

{ #category : #transformations }
Color >> orColorUnlike: theOther [
	"If this color is a lot like theOther, then return its complement, otherwide, return self"

	(self diff: theOther) < 0.3
		ifTrue: [^ theOther negated]
		ifFalse: [^ self]
]

{ #category : #transformations }
Color >> paler [
	"Answer a paler shade of this color."

	^ self adjustSaturation: -0.09 brightness: 0.09

]

{ #category : #conversions }
Color >> pixelValue32 [
	"Note: pixelWord not pixelValue so we include translucency"
	^self pixelWordForDepth: 32
]

{ #category : #conversions }
Color >> pixelValueForDepth: d [
	"Answers an integer representing the bits that appear in a single pixel of this color in a Form of the given depth.
	 The depth must be one of 1, 2, 4, 8, 16, or 32. Contrast with pixelWordForDepth: and bitPatternForDepth:, which
	 answer either a 32-bit word packed with the given pixel value or a multiple-word Bitmap containing a pattern.
	 The inverse is the class message colorFromPixelValue:depth:"
	"Details:
		For depths of 8 or less, the result is a colorMap index.
		For depths of 16 and 32, it is a direct color value with 5 or 8 bits per color component."
	"Transparency:
		The pixel value zero is reserved for transparent.
		For depths greater than 8, black maps to the darkest possible blue."

	| val |
	d > 8 ifTrue: "most common case"
		[d = 32 ifTrue: "eight bits per component; top 8 bits set to all ones (opaque alpha)"
			["this subexpression is a SmallInteger in both 32- and 64-bits."
			 val :=	((rgb bitShift: -6) bitAnd: 16rFF0000) bitOr:
					(((rgb bitShift: -4) bitAnd: 16rFF00) bitOr:
					((rgb bitShift: -2) bitAnd: 16rFF)).
			"16rFF000000 & 16rFF000001 are LargeIntegers in 32-bits, SmallIntegers in 64-bits."
			^val = 0 ifTrue: [16rFF000001] ifFalse: [16rFF000000 + val]].
			
		d = 16 ifTrue: "five bits per component; top bits ignored"
			[val := (((rgb bitShift: -15) bitAnd: 16r7C00) bitOr:
					 ((rgb bitShift: -10) bitAnd: 16r03E0)) bitOr:
					 ((rgb bitShift: -5) bitAnd: 16r001F).
			^val = 0 ifTrue: [1] ifFalse: [val]].

		d = 12 ifTrue: "for indexing a color map with 4 bits per color component"
			[val := (((rgb bitShift: -18) bitAnd: 16r0F00) bitOr:
					 ((rgb bitShift: -12) bitAnd: 16r00F0)) bitOr:
					 ((rgb bitShift: -6) bitAnd: 16r000F).
			^val = 0 ifTrue: [1] ifFalse: [val]].

		d = 9 ifTrue: "for indexing a color map with 3 bits per color component"
			[val := (((rgb bitShift: -21) bitAnd: 16r01C0) bitOr:
				 ((rgb bitShift: -14) bitAnd: 16r0038)) bitOr:
				 ((rgb bitShift: -7) bitAnd: 16r0007).
			^val = 0 ifTrue: [1] ifFalse: [val]]].
	d = 8 ifTrue: [^ self closestPixelValue8].
	d = 4 ifTrue: [^ self closestPixelValue4].
	d = 2 ifTrue: [^ self closestPixelValue2]..
	d = 1 ifTrue: [^ self closestPixelValue1].

	self error: 'unknown pixel depth: ', d printString

]

{ #category : #conversions }
Color >> pixelWordFor: depth filledWith: pixelValue [
	"Return to a 32-bit word that concatenates enough copies of the given pixel value to fill the word (i.e., 32/depth copies). Depth should be one of 1, 2, 4, 8, 16, or 32. The pixel value should be an integer in 0..2^depth-1."
	| halfword |
	depth = 32 ifTrue: [^ pixelValue].
	depth = 16
		ifTrue: [halfword := pixelValue]
		ifFalse: [halfword := pixelValue * 
					(#(16rFFFF				"replicates at every bit"
						16r5555 -			"replicates every 2 bits"
						16r1111 - - -			"replicates every 4 bits"
						16r0101) at: depth)	"replicates every 8 bits"].
	^ halfword bitOr: (halfword bitShift: 16)
]

{ #category : #conversions }
Color >> pixelWordForDepth: depth [
	"Return to a 32-bit word that concatenates enough copies of the receiver's pixel value to fill the word (i.e., 32/depth copies). Depth should be one of 1, 2, 4, 8, 16, or 32. The pixel value should be an integer in 0..2^depth-1."

	| pixelValue |
	pixelValue := self pixelValueForDepth: depth.
	^ self pixelWordFor: depth filledWith: pixelValue

]

{ #category : #html }
Color >> printHtmlString [
	"answer a string whose characters are the html representation  
	of the receiver"
	^ ((self red * 255) rounded printStringBase: 16 length: 2 padded: true)
		, ((self green * 255) rounded printStringBase: 16 length: 2 padded: true)
		, ((self blue * 255) rounded printStringBase: 16 length: 2 padded: true)
]

{ #category : #printing }
Color >> printOn: aStream [
	| name |
	(name := self name) ifNotNil:
		[^ aStream
			nextPutAll: 'Color ';
			nextPutAll: name].
	self storeOn: aStream.

]

{ #category : #private }
Color >> privateAlpha [
	"Private! Return the raw alpha value for opaque. Used only for equality testing."

	^ 255
]

{ #category : #private }
Color >> privateBlue [
	"Private! Return the internal representation of my blue component."

	^ rgb bitAnd: ComponentMask
]

{ #category : #private }
Color >> privateGreen [
	"Private! Return the internal representation of my green component.
	Replaced >> by bitShift: 0 -. SqR! 2/25/1999 23:08"

	^ (rgb bitShift: 0 - GreenShift) bitAnd: ComponentMask
]

{ #category : #private }
Color >> privateRGB [
	"Private! Return the internal representation of my RGB components."

	^ rgb

]

{ #category : #private }
Color >> privateRed [
	"Private! Return the internal representation of my red component."

	^ (rgb bitShift: 0 - RedShift) bitAnd: ComponentMask
]

{ #category : #other }
Color >> raisedColor [
	^ self
]

{ #category : #accessing }
Color >> red [
	"Return the red component of this color, a float in the range [0.0..1.0]."

	^ self privateRed asFloat / ComponentMax
]

{ #category : #other }
Color >> rgbTriplet [
	"Color fromUser rgbTriplet"

	^ Array
		with: (self red roundTo: 0.01)
		with: (self green roundTo: 0.01)
		with: (self blue roundTo: 0.01)

]

{ #category : #accessing }
Color >> saturation [
	"Return the saturation of this color, a value between 0.0 and 1.0."

	| r g b max min |
	r := self privateRed.
	g := self privateGreen.
	b := self privateBlue. 

	max := min := r.
	g > max ifTrue: [max := g].
	b > max ifTrue: [max := b].
	g < min ifTrue: [min := g].
	b < min ifTrue: [min := b].

	max = 0
		ifTrue: [ ^ 0.0 ]
		ifFalse: [ ^ (max - min) asFloat / max asFloat ].

]

{ #category : #conversions }
Color >> scaledPixelValue32 [
	"Return the alpha scaled pixel value for depth 32"
	^self pixelWordForDepth: 32
]

{ #category : #private }
Color >> setHue: hue saturation: saturation brightness: brightness [
	"Initialize this color to the given hue, saturation, and brightness. See the comment in the instance creation method for details."

	| s v hf i f p q t | 
	s := (saturation asFloat max: 0.0) min: 1.0.
	v := (brightness asFloat max: 0.0) min: 1.0.

	"zero saturation yields gray with the given brightness"
	s = 0.0 ifTrue: [ ^ self setRed: v green: v blue: v ].

	hf := hue asFloat.
	(hf < 0.0 or: [hf >= 360.0])
		ifTrue: [hf := hf \\ 360].
	hf := hf / 60.0.
	i := hf asInteger.  "integer part of hue"
	f := hf fractionPart.         "fractional part of hue"
	p := (1.0 - s) * v.
	q := (1.0 - (s * f)) * v.
	t := (1.0 - (s * (1.0 - f))) * v.

	0 = i ifTrue: [ ^ self setRed: v green: t blue: p ].
	1 = i ifTrue: [ ^ self setRed: q green: v blue: p ].
	2 = i ifTrue: [ ^ self setRed: p green: v blue: t ].
	3 = i ifTrue: [ ^ self setRed: p green: q blue: v ].
	4 = i ifTrue: [ ^ self setRed: t green: p blue: v ].
	5 = i ifTrue: [ ^ self setRed: v green: p blue: q ].

	self error: 'implementation error'.

]

{ #category : #private }
Color >> setPrivateRed: r green: g blue: b [
	"Initialize this color's r, g, and b components to the given values in the range [0..ComponentMax].  Encoded in a single variable as 3 integers in [0..1023]."

	rgb == nil ifFalse: [self attemptToMutateError].
	rgb := ((r min: ComponentMask max: 0) bitShift: RedShift) +
		((g min: ComponentMask max: 0) bitShift: GreenShift) +
		 (b min: ComponentMask max: 0).
	cachedDepth := nil.
	cachedBitPattern := nil.

]

{ #category : #private }
Color >> setRGB: rgb0 [
	rgb == nil ifFalse: [self attemptToMutateError].
	rgb := rgb0
]

{ #category : #private }
Color >> setRed: r green: g blue: b [
	"Initialize this color's r, g, and b components to the given values in the range [0.0..1.0].  Encoded in a single variable as 3 integers in [0..1023]."

	rgb == nil ifFalse: [self attemptToMutateError].
	rgb :=
		(((r * ComponentMax) rounded bitAnd: ComponentMask) bitShift: RedShift) +
		(((g * ComponentMax) rounded bitAnd: ComponentMask) bitShift: GreenShift) +
		 ((b * ComponentMax) rounded bitAnd: ComponentMask).
	cachedDepth := nil.
	cachedBitPattern := nil.

]

{ #category : #private }
Color >> setRed: r green: g blue: b range: range [
	"Initialize this color's r, g, and b components to the given values in the range [0..r]."

	^ self setRed: r / range green: g / range blue: b / range
]

{ #category : #printing }
Color >> shortPrintString [
	"Return a short (but less precise) print string for use where space is tight."

	^String streamContents: [:s | s
		nextPutAll: '(';
		print: self class;
		nextPutAll: ' r: '; print: self red maxDecimalPlaces: 2;
		nextPutAll: ' g: '; print: self green maxDecimalPlaces: 2;
		nextPutAll: ' b: '; print: self blue maxDecimalPlaces: 2;
		nextPutAll: ')']
]

{ #category : #transformations }
Color >> slightlyDarker [

	^ self adjustBrightness: -0.03

]

{ #category : #transformations }
Color >> slightlyLighter [

	^ self adjustSaturation: -0.01 brightness: 0.03
]

{ #category : #transformations }
Color >> slightlyWhiter [

	^ self alphaMixed: 0.85 with: Color white

]

{ #category : #printing }
Color >> storeArrayOn: aStream [

	aStream nextPutAll: '#('.
	self storeArrayValuesOn: aStream.
	aStream nextPutAll: ') '

]

{ #category : #printing }
Color >> storeArrayValuesOn: aStream [

	aStream
		print: self red maxDecimalPlaces: 3;
		space;
		print: self green maxDecimalPlaces: 3;
		space;
		print: self blue maxDecimalPlaces: 3.

]

{ #category : #printing }
Color >> storeOn: aStream [

	aStream
		nextPutAll: '(' , self species name;
		nextPutAll: ' r: '; print: self red maxDecimalPlaces: 3;
		nextPutAll: ' g: '; print: self green maxDecimalPlaces: 3;
		nextPutAll: ' b: '; print: self blue maxDecimalPlaces: 3;
		nextPutAll: ')'.

]

{ #category : #transformations }
Color >> thriceDarker [
	"Answer a significantly darker shade of this color."

	^ self adjustSaturation: 0.09 brightness: -0.22
]

{ #category : #transformations }
Color >> thriceLighter [
	"Answer a significantly lighter shade of this color."

	^ self adjustSaturation: -0.09 brightness: 0.22
]

{ #category : #transformations }
Color >> twiceDarker [
	"Answer a significantly darker shade of this color."

	^ self adjustSaturation: 0.075 brightness: -0.15
]

{ #category : #transformations }
Color >> twiceLighter [
	"Answer a significantly lighter shade of this color."

	^ self adjustSaturation: -0.06 brightness: 0.15
]

{ #category : #copying }
Color >> veryDeepCopyWith: deepCopier [
	"I am immutable in the Morphic world. Do not record me."
	^ self
]

{ #category : #transformations }
Color >> veryMuchLighter [

	^ self alphaMixed: 0.1165 with: Color white

]

{ #category : #'groups of shades' }
Color >> wheel: thisMany [
	"An array of thisMany colors around the color wheel starting at self and ending all the way around the hue space just before self.  Array is of length thisMany.  Very useful for displaying color based on a variable in your program.  "

	| sat bri step hue |
	sat := self saturation.
	bri := self brightness.
	hue := self hue.
	step := 360.0 / (thisMany max: 1).
	^ (1 to: thisMany) collect: [:num | | c |
		c := Color h: hue s: sat v: bri.  "hue is taken mod 360"
		hue := hue + step.
		c].
"
(Color wheel: 8) withIndexDo: [:c :i | Display fill: (i*10@20 extent: 10@20) fillColor: c]
"
]

{ #category : #transformations }
Color >> whiter [

	^ self alphaMixed: 0.8333 with: Color white

]
