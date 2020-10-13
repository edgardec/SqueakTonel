"
WARNING: BitBlt's shape cannot be modified since WarpBlt relies on the exact layout. Important primitives will break if you fail to heed this warning.

I represent a block transfer (BLT) of pixels from one Form ( the sourceForm) into a rectangle (destX, destY, width, height) of the destinationForm, as modified by a combination rule, a possible halftoneForm and a possible color map.

The source of pixels may be a similar rectangle (at sourceX, sourceY) in the sourceForm, or the halftoneForm, or both.  If both are specified, their pixel values are combined by a logical AND function prior to any further combination rule processing. The halftoneForm may be an actual Form or a simple WordArray of 32 bit values usually intended to represent Color values. In either case the 'top' of the form is effectively aligned with the top of the destinationForm and for each scanline the destination y modulo the size of the halftoneForm gives the index of the word to use. This makes it easy to make horizontal stripes, for example.

In any case, the pixels from the source (AND'd with the halftone, remember) are combined with those of the destination by as specified by the combinationRules below- 
	name	rule		result 

					0	always 0
	and				1	src AND dst
					2	src AND not(dst)
	over			3	src only
	erase			4	not(src) AND& dst
					5 	dst only
	reverse		6	src XOR dst
	under			7	src OR dst
					8	not(src) AND not(dst)
					9	not(src) XOR dst
					10	not(dst)
					11	src OR not(dst)
					12	not(src)
					13	not(src) OR dst
					14	not(src) OR not(dst)
					15	always 1
(You can find an interesting explanation of how this comes to be in http://dev-docs.atariforge.org/files/BLiTTER_1-25-1990.pdf - which interestingly fails to mention any connection to Smalltalk and PARC.)
 Forms may be of different depths, see the comment in class Form.

In addition to the original 16 combination rules invented for monochrome Forms, this BitBlt supports
					16	fails (to simulate paint bits)
					17	fails (to simulate erase bits)
					18	sourceWord + destinationWord
					19	sourceWord - destinationWord
					20	rgbAdd: sourceWord with: destinationWord.  Sum of color components
					21	rgbSub: sourceWord with: destinationWord.  Difference of color components
					22	OLDrgbDiff: sourceWord with: destinationWord.  Sum of abs of differences in components
					23	OLDtallyIntoMap: destinationWord.  Tallies pixValues into a colorMap
							these old versions don't do bitwise dest clipping.  Use 32 and 33 now.
	blend			24	alphaBlend: sourceWord with: destinationWord.  32-bit source and dest only. Blend sourceWord 
							with destinationWord, assuming both are 32-bit pixels. The source is assumed to have 255*alpha
							in the high 8 bits of each pixel, while the high 8 bits of the destinationWord will be ignored.
							The blend produced is alpha*source + (1-alpha)*dest, with the computation being performed
							independently on each color component.  The high byte of the result will be 0.
	paint			25	pixPaint: sourceWord with: destinationWord.  Wherever the sourceForm is non-zero, it replaces
							the destination.  Can be used with a 1-bit source color mapped to (0, FFFFFFFF), and a fillColor 
							to fill the dest with that color wherever the source is 1.
	erase1BitShape	26	pixMask: sourceWord with: destinationWord.  Like pixPaint, but fills with 0.
					27	rgbMax: sourceWord with: destinationWord.  Max of each color component.
					28	rgbMin: sourceWord with: destinationWord.  Min of each color component.
					29	rgbMin: sourceWord bitInvert32 with: destinationWord.  Min with (max-source)
	blendAlpha		30	alphaBlendConst: sourceWord with: destinationWord.  alpha is an arg. works in 16 bits. Blend
							sourceWord with destinationWord using a constant alpha. Alpha is encoded as 0 meaning
							0.0, and 255 meaning 1.0. The blend produced is alpha*source + (1.0-alpha)*dest, with
							the computation being performed independently on each color component. 
	paintAlpha		31	alphaPaintConst: sourceWord with: destinationWord.  alpha is an arg. works in 16 bits.
					32	rgbDiff: sourceWord with: destinationWord.  Sum of abs of differences in components
					33	tallyIntoMap: destinationWord.  Tallies pixValues into a colorMap - Those tallied are exactly 
							those in the destination rectangle.  Note that the source should be specified == destination,
							in order for the proper color map checks  be performed at setup.
	blendAlphaScaled	34	alphaBlendScaled: srcWord with: dstWord. Alpha blend of scaled srcWord and destWord. In contrast
							to alphaBlend:with: the color produced is srcColor + (1-srcAlpha) * dstColor
					35	& 36 not used
	rgbMul			37	rgbMul: srcWord with: dstWord. 
					38	pixSwap: srcWord with: dstWord.
					39	pixClear: srcWord with: dstWord. Clear all pixels in destinationWord for which the pixels of 
							sourceWord have the same values. Used to clear areas of some constant color to zero.
					40	fixAlpha: srcWord with: dstWord. For any non-zero pixel value in destinationWord with zero alpha 
							channel take the alpha from sourceWord and fill it in. Intended for fixing alpha channels left at 
							zero during 16->32 bpp conversions.
					41	rgbComponentAlpha: srcWord with: dstWord.

Any transfer specified is further clipped by the specified clipping rectangle (clipX, clipY, clipWidth, clipHeight), and also by the bounds of the source and destination forms.
	To make a small Form repeat and fill a big form, use an InfiniteForm as the source.

Pixels copied from a source to a destination whose pixels have a different depth are converted based on the optional colorMap.  If colorMap is nil, then conversion to more bits is done by filling the new high-order bits with zero, and conversion to fewer bits is done by truncating the lost high-order bits.  

The colorMap, if specified, must be a either word array (ie Bitmap) with 2^n elements, where n is the pixel depth of the source, or a fully specified ColorMap which may contain a lookup table (ie Bitmap) and/or four separate masks and shifts which are applied to the pixels. For every source pixel, BitBlt will first perform masking and shifting and then index the lookup table, and select the corresponding pixelValue and mask it to the destination pixel size before storing.
	When blitting from a 32 or 16 bit deep Form to one 8 bits or less, the default is truncation.  This will produce very strange colors, since truncation of the high bits does not produce the nearest encoded color.  Supply a 512 long colorMap, and red, green, and blue will be shifted down to 3 bits each, and mapped.  The message copybits...stdColors will use the best map to the standard colors for destinations of depths 8, 4, 2 and 1.  Two other sized of colorMaps are allowed, 4096 (4 bits per color) and 32786 (five bits per color).
	Normal blits between 16 and 32 bit forms truncates or pads the colors automatically to provide the best preservation of colors.
	Colors can be remapped at the same depth.  Sometimes a Form is in terms of colors that are not the standard colors for this depth, for example in a GIF file.  Convert the Form to a MaskedForm and send colorMap: the list of colors that the picture is in terms of. (Note also that a Form can be copied to itself, and transformed in the process, if a non-nil colorMap is supplied.)
"
Class {
	#name : #BitBlt,
	#superclass : #Object,
	#instVars : [
		'destForm',
		'sourceForm',
		'halftoneForm',
		'combinationRule',
		'destX',
		'destY',
		'width',
		'height',
		'sourceX',
		'sourceY',
		'clipX',
		'clipY',
		'clipWidth',
		'clipHeight',
		'colorMap'
	],
	#classVars : [
		'CachedFontColorMaps',
		'ColorConvertingMaps',
		'SubPixelRenderColorFonts',
		'SubPixelRenderFonts'
	],
	#category : #'Graphics-Primitives'
}

{ #category : #examples }
BitBlt class >> alphaBlendDemo [
	"To run this demo, use...
		Display restoreAfter: [BitBlt alphaBlendDemo]	
	Displays 10 alphas, then lets you paint.  Option-Click to stop painting."

	"This code exhibits alpha blending in any display depth by performing
	the blend in an off-screen buffer with 32-bit pixels, and then copying
	the result back onto the screen with an appropriate color map. - tk 3/10/97"
	
	"This version uses a sliding buffer for painting that keeps pixels in 32 bits
	as long as they are in the buffer, so as not to lose info by converting down
	to display resolution and back up to 32 bits at each operation. - di 3/15/97"

	| brush buff dispToBuff buffToDisplay mapDto32 map32toD prevP p brushToBuff theta buffRect buffSize buffToBuff brushRect delta newBuffRect updateRect |  

	"compute color maps if needed"
	Display depth <= 8 ifTrue: [
		mapDto32 := Color cachedColormapFrom: Display depth to: 32.
		map32toD := Color cachedColormapFrom: 32 to: Display depth].

	"display 10 different alphas, across top of screen"
	buff := Form extent: 500@50 depth: 32.
	dispToBuff := BitBlt toForm: buff.
	dispToBuff colorMap: mapDto32.
	dispToBuff copyFrom: (50@10 extent: 500@50) in: Display to: 0@0.
	1 to: 10 do: [:i | dispToBuff fill: (50*(i-1)@0 extent: 50@50)
						fillColor: (Color red alpha: i/10)
						rule: Form blend].
	buffToDisplay := BitBlt toForm: Display.
	buffToDisplay colorMap: map32toD.
	buffToDisplay copyFrom: buff boundingBox in: buff to: 50@10.

	"Create a brush with radially varying alpha"
	brush := Form extent: 30@30 depth: 32.
	1 to: 5 do: 
		[:i | brush fillShape: (Form dotOfSize: brush width*(6-i)//5)
				fillColor: (Color red alpha: 0.02 * i - 0.01)
				at: brush extent // 2].

	"Now paint with the brush using alpha blending."
	buffSize := 100.
	buff := Form extent: brush extent + buffSize depth: 32.  "Travelling 32-bit buffer"
	dispToBuff := BitBlt toForm: buff.  "This is from Display to buff"
	dispToBuff colorMap: mapDto32.
	brushToBuff := BitBlt toForm: buff.  "This is from brush to buff"
	brushToBuff sourceForm: brush; sourceOrigin: 0@0.
	brushToBuff combinationRule: Form blend.
	buffToBuff := BitBlt toForm: buff.  "This is for slewing the buffer"

	[Sensor yellowButtonPressed] whileFalse:
		[prevP := nil.
		buffRect := Sensor cursorPoint - (buffSize // 2) extent: buff extent.
		dispToBuff copyFrom: buffRect in: Display to: 0@0.
		[Sensor redButtonPressed] whileTrue:
			["Here is the painting loop"
			p := Sensor cursorPoint - (brush extent // 2).
			(prevP == nil or: [prevP ~= p]) ifTrue:
				[prevP == nil ifTrue: [prevP := p].
				(p dist: prevP) > buffSize ifTrue:
					["Stroke too long to fit in buffer -- clip to buffer,
						and next time through will do more of it"
					theta := (p-prevP) theta.
					p := ((theta cos@theta sin) * buffSize asFloat + prevP) truncated].
				brushRect := p extent: brush extent.
				(buffRect containsRect: brushRect) ifFalse:
					["Brush is out of buffer region.  Scroll the buffer,
						and fill vacated regions from the display"
					delta := brushRect amountToTranslateWithin: buffRect.
					buffToBuff copyFrom: buff boundingBox in: buff to: delta.
					newBuffRect := buffRect translateBy: delta negated.
					(newBuffRect areasOutside: buffRect) do:
						[:r | dispToBuff copyFrom: r in: Display to: r origin - newBuffRect origin].
					buffRect := newBuffRect].

				"Interpolate from prevP to p..."
				brushToBuff drawFrom: prevP - buffRect origin
									to: p - buffRect origin
									withFirstPoint: false.

				"Update (only) the altered pixels of the destination"
				updateRect := (p min: prevP) corner: (p max: prevP) + brush extent.
				buffToDisplay copy: updateRect from: updateRect origin - buffRect origin in: buff.
				prevP := p]]]
]

{ #category : #examples }
BitBlt class >> antiAliasDemo [ 
	"To run this demo, use...
		Display restoreAfter: [BitBlt antiAliasDemo]
	Goes immediately into on-screen paint mode.  Option-Click to stop painting."

	"This code exhibits alpha blending in any display depth by performing
	the blend in an off-screen buffer with 32-bit pixels, and then copying
	the result back onto the screen with an appropriate color map. - tk 3/10/97"
	
	"This version uses a sliding buffer for painting that keeps pixels in 32 bits
	as long as they are in the buffer, so as not to lose info by converting down
	to display resolution and back up to 32 bits at each operation. - di 3/15/97"
	
	"This version also uses WarpBlt to paint into twice as large a buffer,
	and then use smoothing when reducing back down to the display.
	In fact this same routine will now work for 3x3 soothing as well.
	Remove the statements 'buff displayAt: 0@0' to hide the buffer. - di 3/19/97"

	| brush buff dispToBuff buffToDisplay mapDto32 map32toD prevP p brushToBuff theta buffRect buffSize buffToBuff brushRect delta newBuffRect updateRect scale p0 |  
	"compute color maps if needed"
	Display depth <= 8 ifTrue: [
		mapDto32 := Color cachedColormapFrom: Display depth to: 32.
		map32toD := Color cachedColormapFrom: 32 to: Display depth].

	"Create a brush with radially varying alpha"
	brush := Form extent: 3@3 depth: 32.
	brush fill: brush boundingBox fillColor: (Color red alpha: 0.05).
	brush fill: (1@1 extent: 1@1) fillColor: (Color red alpha: 0.2).

	scale := 2.  "Actual drawing happens at this magnification"
	"Scale brush up for painting in magnified buffer"
	brush := brush magnify: brush boundingBox by: scale.

	"Now paint with the brush using alpha blending."
	buffSize := 100.
	buff := Form extent: (brush extent + buffSize) * scale depth: 32.  "Travelling 32-bit buffer"
	dispToBuff := (WarpBlt toForm: buff)  "From Display to buff - magnify by 2"
		sourceForm: Display;
		colorMap: mapDto32;
		combinationRule: Form over.
	brushToBuff := (BitBlt toForm: buff)  "From brush to buff"
		sourceForm: brush;
		sourceOrigin: 0@0;
		combinationRule: Form blend.
	buffToDisplay := (WarpBlt toForm: Display)  "From buff to Display - shrink by 2"
		sourceForm: buff;
		colorMap: map32toD;
		cellSize: scale;  "...and use smoothing"
		combinationRule: Form over.
	buffToBuff := BitBlt toForm: buff.  "This is for slewing the buffer"

	[Sensor yellowButtonPressed] whileFalse:
		[prevP := nil.
		buffRect := Sensor cursorPoint - (buff extent // scale // 2) extent: buff extent // scale.
		p0 := (buff extent // 2) - (buffRect extent // 2).
		dispToBuff copyQuad: buffRect innerCorners toRect: buff boundingBox.
buff displayAt: 0@0.  "** remove to hide sliding buffer **"
		[Sensor redButtonPressed] whileTrue:
			["Here is the painting loop"
			p := Sensor cursorPoint - buffRect origin + p0.  "p, prevP are rel to buff origin"
			(prevP == nil or: [prevP ~= p]) ifTrue:
				[prevP == nil ifTrue: [prevP := p].
				(p dist: prevP) > (buffSize-1) ifTrue:
					["Stroke too long to fit in buffer -- clip to buffer,
						and next time through will do more of it"
					theta := (p-prevP) theta.
					p := ((theta cos@theta sin) * (buffSize-2) asFloat + prevP) truncated].
				brushRect := p extent: brush extent.
				((buff boundingBox insetBy: scale) containsRect: brushRect) ifFalse:
					["Brush is out of buffer region.  Scroll the buffer,
						and fill vacated regions from the display"
					delta := (brushRect amountToTranslateWithin: (buff boundingBox insetBy: scale)) // scale.
					buffToBuff copyFrom: buff boundingBox in: buff to: delta*scale.
					newBuffRect := buffRect translateBy: delta negated.
					p := p translateBy: delta*scale.
					prevP := prevP translateBy: delta*scale.
					(newBuffRect areasOutside: buffRect) do:
						[:r | dispToBuff copyQuad: r innerCorners toRect: (r origin - newBuffRect origin*scale extent: r extent*scale)].
					buffRect := newBuffRect].

				"Interpolate from prevP to p..."
				brushToBuff drawFrom: prevP to: p withFirstPoint: false.
buff displayAt: 0@0.  "** remove to hide sliding buffer **"

				"Update (only) the altered pixels of the destination"
				updateRect := (p min: prevP) corner: (p max: prevP) + brush extent.
				updateRect := updateRect origin // scale * scale
						corner: updateRect corner + scale // scale * scale.
				buffToDisplay copyQuad: updateRect innerCorners
							toRect: (updateRect origin // scale + buffRect origin
										extent: updateRect extent // scale).
				prevP := p]]]
]

{ #category : #benchmarks }
BitBlt class >> benchDiffsFrom: before to: afterwards [
	"Given two outputs of BitBlt>>benchmark show the relative improvements."
	| old new log oldLine newLine oldVal newVal improvement |
	log := WriteStream on: String new.
	old := ReadStream on: before.
	new := ReadStream on: afterwards.
	[old atEnd or:[new atEnd]] whileFalse:[
		oldLine := old nextLine.
		newLine := new nextLine.
		(oldLine includes: Character tab) ifTrue:[
			oldLine := ReadStream on: oldLine.
			newLine := ReadStream on: newLine.
			Transcript cr; show: (oldLine upTo: Character tab); tab.
			log cr; nextPutAll: (newLine upTo: Character tab); tab.

			[oldLine skipSeparators. newLine skipSeparators.
			oldLine atEnd] whileFalse:[
				oldVal := Integer readFrom: oldLine.
				newVal := Integer readFrom: newLine.
				improvement := oldVal asFloat / newVal asFloat roundTo: 0.01.
				Transcript show: improvement printString; tab; tab.
				log print: improvement; tab; tab].
		] ifFalse:[
			Transcript cr; show: oldLine.
			log cr; nextPutAll: oldLine.
		].
	].
	^log contents
]

{ #category : #benchmarks }
BitBlt class >> benchmark [		"BitBlt benchmark"
	"Run a benchmark on different combinations rules, source/destination depths and BitBlt modes. Note: This benchmark doesn't give you any 'absolute' value - it is intended only for benchmarking improvements in the bitblt code and nothing else.
	Attention: *this*may*take*a*while*"
	| destRect log |
	log := WriteStream on: String new.
	destRect := 0@0 extent: 600@600.
	"Form paint/Form over - the most common rules"
	#( 25 3 ) do:[:rule|
		Transcript cr; show:'---- Combination rule: ', rule printString,' ----'.
		log cr; nextPutAll:'---- Combination rule: ', rule printString,' ----'.
		#(1 2 4 8 16 32) do:[:destDepth| | dest |
			dest := nil.
			dest := Form extent: destRect extent depth: destDepth.
			Transcript cr.
			log cr.
			#(1 2 4 8 16 32) do:[:sourceDepth| | t source bb |
				Transcript cr; show: sourceDepth printString, ' => ', destDepth printString.
				log cr; nextPutAll: sourceDepth printString, ' => ', destDepth printString.
				source := nil. bb := nil.
				source := Form extent: destRect extent depth: sourceDepth.
				(source getCanvas) fillOval: dest boundingBox color: Color yellow borderWidth: 30 borderColor: Color black.
				bb := WarpBlt toForm: dest.
				bb sourceForm: source.
				bb sourceRect: source boundingBox.
				bb destRect: dest boundingBox.
				bb colorMap: (source colormapIfNeededFor: dest).
				bb combinationRule: rule.

				"Measure speed of copyBits"
				t := Time millisecondsToRun:[bb copyBits].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.

				bb sourceForm: source destRect: source boundingBox.

				"Measure speed of 1x1 warpBits"
				bb cellSize: 1.
				t := Time millisecondsToRun:[bb warpBits].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.

				"Measure speed of 2x2 warpBits"
				bb cellSize: 2.
				t := Time millisecondsToRun:[bb warpBits].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.

				"Measure speed of 3x3 warpBits"
				bb cellSize: 3.
				t := Time millisecondsToRun:[bb warpBits].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.
			].
		].
	].
	^log contents
]

{ #category : #benchmarks }
BitBlt class >> benchmark2 [		"BitBlt benchmark"
	"Run a benchmark on different combinations rules, source/destination depths and BitBlt modes. Note: This benchmark doesn't give you any 'absolute' value - it is intended only for benchmarking improvements in the bitblt code and nothing else.
	Attention: *this*may*take*a*while*"
	| destRect log |
	log := WriteStream on: String new.
	destRect := 0@0 extent: 600@600.
	"Form paint/Form over - the most common rules"
	#( 25 3 ) do:[:rule|
		Transcript cr; show:'---- Combination rule: ', rule printString,' ----'.
		log cr; nextPutAll:'---- Combination rule: ', rule printString,' ----'.
		#(1 2 4 8 16 32) do:[:destDepth| | dest |
			dest := nil.
			dest := Form extent: destRect extent depth: destDepth.
			Transcript cr.
			log cr.
			#(1 2 4 8 16 32) do:[:sourceDepth| | t bb source |
				Transcript cr; show: sourceDepth printString, ' => ', destDepth printString.
				log cr; nextPutAll: sourceDepth printString, ' => ', destDepth printString.
				source := nil. bb := nil.
				source := Form extent: destRect extent depth: sourceDepth.
				(source getCanvas) fillOval: dest boundingBox color: Color yellow borderWidth: 30 borderColor: Color black.
				bb := WarpBlt toForm: dest.
				bb sourceForm: source.
				bb sourceRect: source boundingBox.
				bb destRect: dest boundingBox.
				bb colorMap: (source colormapIfNeededFor: dest).
				bb combinationRule: rule.

				"Measure speed of copyBits"
				t := Time millisecondsToRun:[1 to: 10 do:[:i| bb copyBits]].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.

				bb sourceForm: source destRect: source boundingBox.

				"Measure speed of 1x1 warpBits"
				bb cellSize: 1.
				t := Time millisecondsToRun:[1 to: 4 do:[:i| bb warpBits]].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.

				"Measure speed of 2x2 warpBits"
				bb cellSize: 2.
				t := Time millisecondsToRun:[bb warpBits].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.

				"Measure speed of 3x3 warpBits"
				bb cellSize: 3.
				t := Time millisecondsToRun:[bb warpBits].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.
			].
		].
	].
	^log contents
]

{ #category : #benchmarks }
BitBlt class >> benchmark3 [		"BitBlt benchmark"
	"Run a benchmark on different combinations rules, source/destination depths and BitBlt modes. Note: This benchmark doesn't give you any 'absolute' value - it is intended only for benchmarking improvements in the bitblt code and nothing else.
	Attention: *this*may*take*a*while*"
	| destRect log |
	log := WriteStream on: String new.
	destRect := 0@0 extent: 600@600.
	"Form paint/Form over - the most common rules"
	#( 25 3 ) do:[:rule|
		Transcript cr; show:'---- Combination rule: ', rule printString,' ----'.
		log cr; nextPutAll:'---- Combination rule: ', rule printString,' ----'.
		#(1 2 4 8 16 32) do:[:destDepth| | dest |
			dest := nil.
			dest := Form extent: destRect extent depth: destDepth.
			Transcript cr.
			log cr.
			#(1 2 4 8 16 32) do:[:sourceDepth| | t source bb |
				Transcript cr; show: sourceDepth printString, ' => ', destDepth printString.
				log cr; nextPutAll: sourceDepth printString, ' => ', destDepth printString.
				source := nil. bb := nil.
				source := Form extent: destRect extent depth: sourceDepth.
				(source getCanvas) fillOval: dest boundingBox color: Color yellow borderWidth: 30 borderColor: Color black.
				bb := WarpBlt toForm: dest.
				bb sourceForm: source.
				bb sourceRect: source boundingBox.
				bb destRect: dest boundingBox.
				bb colorMap: (source colormapIfNeededFor: dest).
				bb combinationRule: rule.

				"Measure speed of copyBits"
				t := Time millisecondsToRun:[1 to: 10 do:[:i| bb copyBits]].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.

				bb sourceForm: source destRect: source boundingBox.

				"Measure speed of 1x1 warpBits"
				bb cellSize: 1.
				t := Time millisecondsToRun:[1 to: 4 do:[:i| bb warpBits]].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.

				"Measure speed of 2x2 warpBits"
				bb cellSize: 2.
				t := Time millisecondsToRun:[bb warpBits].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.

				"Measure speed of 3x3 warpBits"
				bb cellSize: 3.
				t := Time millisecondsToRun:[bb warpBits].
				Transcript tab; show: t printString.
				log tab; nextPutAll: t printString.
			].
		].
	].
	^log contents
]

{ #category : #'instance creation' }
BitBlt class >> bitPeekerFromForm: sourceForm [
	"Answer an instance to be used extract individual pixels from the given Form. The destination for a 1x1 copyBits will be the low order bits of (bits at: 1)."
	| pixPerWord |
	pixPerWord := 32 // sourceForm depth.
	sourceForm unhibernate.
	^ self destForm: (Form extent: pixPerWord@1 depth: sourceForm depth)
	 	sourceForm: sourceForm
		halftoneForm: nil
		combinationRule: Form over
		destOrigin: (pixPerWord - 1)@0
		sourceOrigin: 0@0
		extent: 1@1
		clipRect: (0@0 extent: pixPerWord@1)

]

{ #category : #'instance creation' }
BitBlt class >> bitPokerToForm: destForm [
	"Answer an instance to be used for valueAt: aPoint put: pixValue.
	The source for a 1x1 copyBits will be the low order of (bits at: 1)"
	| pixPerWord |
	pixPerWord := 32//destForm depth.
	destForm unhibernate.
	^ self destForm: destForm
	 	sourceForm: (Form extent: pixPerWord@1 depth: destForm depth)
		halftoneForm: nil combinationRule: Form over
		destOrigin: 0@0 sourceOrigin: (pixPerWord-1)@0
		extent: 1@1 clipRect: (0@0 extent: destForm extent)

]

{ #category : #'class initialization' }
BitBlt class >> cleanUp [
	"Flush caches"

	self recreateColorMaps.
]

{ #category : #'instance creation' }
BitBlt class >> current [
	"Return the class currently to be used for BitBlt"
	^self
]

{ #category : #'instance creation' }
BitBlt class >> destForm: df sourceForm: sf fillColor: hf combinationRule: cr destOrigin: destOrigin sourceOrigin: sourceOrigin extent: extent clipRect: clipRect [ 
	"Answer an instance of me with values set according to the arguments."

	^ self new
		setDestForm: df
		sourceForm: sf
		fillColor: hf
		combinationRule: cr
		destOrigin: destOrigin
		sourceOrigin: sourceOrigin
		extent: extent
		clipRect: clipRect
]

{ #category : #'instance creation' }
BitBlt class >> destForm: df sourceForm: sf halftoneForm: hf combinationRule: cr destOrigin: destOrigin sourceOrigin: sourceOrigin extent: extent clipRect: clipRect [ 
	"Answer an instance of me with values set according to the arguments."

	^ self new
		setDestForm: df
		sourceForm: sf
		fillColor: hf
		combinationRule: cr
		destOrigin: destOrigin
		sourceOrigin: sourceOrigin
		extent: extent
		clipRect: clipRect
]

{ #category : #private }
BitBlt class >> exampleAt: originPoint rule: rule fillColor: mask [ 
	"This builds a source and destination form and copies the source to the
	destination using the specifed rule and mask. It is called from the method
	named exampleOne. Only works with Display depth of 1"

	^self exampleOn: Display at: originPoint rule: rule fillColor: mask

	"BitBlt exampleAt: 100@100 rule: 0 fillColor: nil"
]

{ #category : #examples }
BitBlt class >> exampleColorMap [	"BitBlt exampleColorMap"
	"This example shows what one can do with the fixed part of a color map. The color map, as setup below, rotates the bits of a pixel all the way around. Thus you'll get a (sometime strange looking ;-) animation of colors which will end up exactly the way it looked at the beginning. The example is given to make you understand that the masks and shifts can be used for a lot more than simply color converting pixels. In this example, for instance, we use only two of the four independent shifters."
	| cc bb |
	cc := ColorMap masks: {
		1 << (Display depth-1). "mask out high bit of color component"
		1 << (Display depth-1) - 1. "mask all other bits"
		0.
		0}
		shifts: {
			1 - Display depth. "shift right to bottom most position"
			1. "shift all other pixels one bit left"
			0.
			0}.
	bb := BitBlt toForm: Display.
	bb 
		sourceForm: Display;
		combinationRule: 3;
		colorMap: cc.
	1 to: Display depth do:[:i|
		bb copyBits.
		Display forceDisplayUpdate.
	].

]

{ #category : #private }
BitBlt class >> exampleOn: destinationForm at: originPoint rule: rule fillColor: mask [ 
	"This builds a source and destination form and copies the source to the
	destination using the specifed rule and mask. It is called from the method
	named exampleOne. Only works with Display depth of 1"

	| s d border aBitBlt | 
	border:=Form extent: 32@32.
	border fillBlack.
	border fill: (1@1 extent: 30@30) fillColor: Color white.
	s := Form extent: 32@32.
	s fillWhite.
	s fillBlack: (7@7 corner: 25@25).
	d := Form extent: 32@32.
	d fillWhite.
	d fillBlack: (0@0 corner: 32@16).

	s displayOn: destinationForm at: originPoint.
	border displayOn: destinationForm at: originPoint rule: Form under.
	d displayOn: destinationForm at: originPoint + (s width @0).
	border displayOn: destinationForm at: originPoint + (s width @0) rule: Form under.

	d displayOn: destinationForm at: originPoint + (s extent // (2 @ 1)). 
	aBitBlt := BitBlt
				destForm: destinationForm
				sourceForm: s
				fillColor: mask
				combinationRule: rule
				destOrigin: originPoint + (s extent // (2 @ 1))
				sourceOrigin: 0 @ 0
				extent: s extent
				clipRect: destinationForm computeBoundingBox.
	aBitBlt copyBits.
	border 
		displayOn: destinationForm at: originPoint + (s extent // (2 @ 1))
		rule: Form under.

	"BitBlt exampleOn: Display at: 100@100 rule: 0 fillColor: nil"  
]

{ #category : #examples }
BitBlt class >> exampleOne [
	"This tests BitBlt by displaying the result of all sixteen combination rules that BitBlt is capable of using. (Please see the comment in BitBlt for the meaning of the combination rules). This only works at Display depth of 1. (Rule 15 does not work?)"
	| pathClass path displayDepth destination |

	(Display supportsDisplayDepth: 1)
		ifTrue:
			[displayDepth := Display depth.
			 Display newDepth: 1.
			 destination := Display]
		ifFalse:
			[destination := Form extent: 480 @ 400 depth: 1].

	(Smalltalk hasClassNamed: #Path)
		ifTrue: [pathClass := Smalltalk at: #Path]
		ifFalse: [^self inform: 'MVC class Path not present in this image'].
	path := pathClass new.
	0 to: 3 do: [:i | 0 to: 3 do: [:j | path add: j * 100 @ (i * 75)]].
	destination fillWhite.
	path := path translateBy: 60 @ 40.
	1 to: 16 do:
		[:index |
		BitBlt
			exampleOn: destination
			at: (path at: index)
			rule: index - 1
			fillColor: nil].

	destination ~~ Display ifTrue:
		[destination displayOn: Display at: 0 asPoint].
	[Sensor anyButtonPressed] whileFalse: [].
	displayDepth ifNotNil: [Display newDepth: displayDepth].

	"BitBlt exampleOne"
]

{ #category : #examples }
BitBlt class >> exampleTwo [
	"This is to test painting with a gray tone. It also tests that the seaming with gray patterns is correct in the microcode. Lets you paint for a while and then automatically stops. This only works at Depth of 1."
	| f aBitBlt displayDepth |
	"create a small black Form source as a brush. "
	displayDepth := Display depth.
	Display newDepth: 1.
	f := Form extent: 20 @ 20.
	f fillBlack.
	"create a BitBlt which will OR gray into the display. "
	aBitBlt := BitBlt
		destForm: Display
		sourceForm: f
		fillColor: Color gray
		combinationRule: Form over
		destOrigin: Sensor cursorPoint
		sourceOrigin: 0 @ 0
		extent: f extent
		clipRect: Display computeBoundingBox.
	"paint the gray Form on the screen for a while. "
	[Sensor anyButtonPressed] whileFalse: 
		[aBitBlt destOrigin: Sensor cursorPoint.
		aBitBlt copyBits].
	Display newDepth: displayDepth.
	"BitBlt exampleTwo"
]

{ #category : #'class initialization' }
BitBlt class >> initialize [
	self recreateColorMaps
]

{ #category : #private }
BitBlt class >> recreateColorMaps [
	CachedFontColorMaps := ColorConvertingMaps := nil
]

{ #category : #preferences }
BitBlt class >> subPixelRenderColorFonts [

	<preference: 'Subpixel font rendering for color fonts'
	category: 'Graphics'
	description: 'If true, non-black opaque fonts are rendered using subpixel combination rules by BitBlt. Subpixel font rendering has to be enabled to take effect.'
	type: #Boolean>
	^SubPixelRenderColorFonts ifNil: [ true ]

	
]

{ #category : #preferences }
BitBlt class >> subPixelRenderColorFonts: aBoolean [

	SubPixelRenderColorFonts := aBoolean

	
]

{ #category : #preferences }
BitBlt class >> subPixelRenderFonts [

	<preference: 'Subpixel font rendering'
	category: 'Graphics'
	description: 'If true, black fonts are rendered using subpixel combination rules by BitBlt.'
	type: #Boolean>
	^SubPixelRenderFonts ifNil: [ true ]

	
]

{ #category : #preferences }
BitBlt class >> subPixelRenderFonts: aBoolean [

	SubPixelRenderFonts := aBoolean

	
]

{ #category : #'instance creation' }
BitBlt class >> toForm: aForm [
	^ self new setDestForm: aForm
]

{ #category : #copying }
BitBlt >> basicDisplayString: aString from: startIndex to: stopIndex at: aPoint strikeFont: font kern: kernDelta [

	destY := aPoint y.
	destX := aPoint x.

	"the following are not really needed, but theBitBlt primitive will fail if not set"
	sourceX ifNil: [sourceX := 100].
	width ifNil: [width := 100].

	self primDisplayString: aString from: startIndex to: stopIndex
			map: font characterToGlyphMap xTable: font xTable
			kern: kernDelta.
	^ destX@destY.

]

{ #category : #private }
BitBlt >> cachedFontColormapFrom: sourceDepth to: destDepth [

	| srcIndex map |
	CachedFontColorMaps class == Array 
		ifFalse: [CachedFontColorMaps := (1 to: 9) collect: [:i | Array new: 32]].
	srcIndex := sourceDepth.
	sourceDepth > 8 ifTrue: [srcIndex := 9].
	(map := (CachedFontColorMaps at: srcIndex) at: destDepth) ~~ nil ifTrue: [^ map].

	map := (Color cachedColormapFrom: sourceDepth to: destDepth) copy.
	(CachedFontColorMaps at: srcIndex) at: destDepth put: map.
	^ map

]

{ #category : #accessing }
BitBlt >> clipBy: aRectangle [
	| aPoint right bottom |
	right := clipX + clipWidth.
	bottom := clipY + clipHeight.
	aPoint := aRectangle origin.
	aPoint x > clipX ifTrue:[clipX := aPoint x].
	aPoint y > clipY ifTrue:[clipY := aPoint y].
	aPoint := aRectangle corner.
	aPoint x < right ifTrue:[right := aPoint x].
	aPoint y < bottom ifTrue:[bottom := aPoint y].
	clipWidth := right - clipX.
	clipHeight := bottom - clipY.
	clipWidth < 0 ifTrue:[clipWidth := 0].
	clipHeight < 0 ifTrue:[clipHeight := 0].
]

{ #category : #accessing }
BitBlt >> clipByX1: x1 y1: y1 x2: x2 y2: y2 [
	| right bottom |
	right := clipX + clipWidth.
	bottom := clipY + clipHeight.
	x1 > clipX ifTrue:[clipX := x1].
	y1 > clipY ifTrue:[clipY := y1].
	x2 < right ifTrue:[right := x2].
	y2 < bottom ifTrue:[bottom := y2].
	clipWidth := right - clipX.
	clipHeight := bottom - clipY.
	clipWidth < 0 ifTrue:[clipWidth := 0].
	clipHeight < 0 ifTrue:[clipHeight := 0].
]

{ #category : #accessing }
BitBlt >> clipHeight [
	^clipHeight
]

{ #category : #accessing }
BitBlt >> clipHeight: anInteger [ 
	"Set the receiver's clipping area height to be the argument, anInteger."

	clipHeight := anInteger
]

{ #category : #private }
BitBlt >> clipRange [
	"clip and adjust source origin and extent appropriately"
	"first in x"
	| sx sy dx dy bbW bbH |
	"fill in the lazy state if needed"
	destX ifNil:[destX := 0].
	destY ifNil:[destY := 0].
	width ifNil:[width := destForm width].
	height ifNil:[height := destForm height].
	sourceX ifNil:[sourceX := 0].
	sourceY ifNil:[sourceY := 0].
	clipX ifNil:[clipX := 0].
	clipY ifNil:[clipY := 0].
	clipWidth ifNil:[clipWidth := destForm width].
	clipHeight ifNil:[clipHeight := destForm height].

	destX >= clipX
		ifTrue: [sx := sourceX.
				dx := destX.
				bbW := width]
		ifFalse: [sx := sourceX + (clipX - destX).
				bbW := width - (clipX - destX).
				dx := clipX].
	(dx + bbW) > (clipX + clipWidth)
		ifTrue: [bbW := bbW - ((dx + bbW) - (clipX + clipWidth))].
	"then in y"
	destY >= clipY
		ifTrue: [sy := sourceY.
				dy := destY.
				bbH := height]
		ifFalse: [sy := sourceY + clipY - destY.
				bbH := height - (clipY - destY).
				dy := clipY].
	(dy + bbH) > (clipY + clipHeight)
		ifTrue: [bbH := bbH - ((dy + bbH) - (clipY + clipHeight))].
	sourceForm ifNotNil:[
		sx < 0
			ifTrue: [dx := dx - sx.
					bbW := bbW + sx.
					sx := 0].
		sx + bbW > sourceForm width
			ifTrue: [bbW := bbW - (sx + bbW - sourceForm width)].
		sy < 0
			ifTrue: [dy := dy - sy.
					bbH := bbH + sy.
					sy := 0].
		sy + bbH > sourceForm height
			ifTrue: [bbH := bbH - (sy + bbH - sourceForm height)].
	].
	(bbW <= 0 or:[bbH <= 0]) ifTrue:[
		sourceX := sourceY := destX := destY := clipX := clipY := width := height := clipWidth := clipHeight := 0.
		^true].
	(sx = sourceX 
		and:[sy = sourceY 
		and:[dx = destX 
		and:[dy = destY 
		and:[bbW = width 
		and:[bbH = height]]]]]) ifTrue:[^false].
	sourceX := sx.
	sourceY := sy.
	destX := dx.
	destY := dy.
	width := bbW.
	height := bbH.
	^true
]

{ #category : #accessing }
BitBlt >> clipRect [
	"Answer the receiver's clipping area rectangle."

	^clipX @ clipY extent: clipWidth @ clipHeight
]

{ #category : #accessing }
BitBlt >> clipRect: aRectangle [ 
	"Set the receiver's clipping area rectangle to be the argument, aRectangle."

	clipX := aRectangle left truncated.
	clipY := aRectangle top truncated.
	clipWidth := aRectangle right truncated - clipX.
	clipHeight := aRectangle bottom truncated - clipY.
]

{ #category : #accessing }
BitBlt >> clipWidth [
	^clipWidth
]

{ #category : #accessing }
BitBlt >> clipWidth: anInteger [ 
	"Set the receiver's clipping area width to be the argument, anInteger."

	clipWidth := anInteger
]

{ #category : #accessing }
BitBlt >> clipX [
	^clipX
]

{ #category : #accessing }
BitBlt >> clipX: anInteger [ 
	"Set the receiver's clipping area top left x coordinate to be the argument, 
	anInteger."

	clipX := anInteger
]

{ #category : #accessing }
BitBlt >> clipY [
	^clipY
]

{ #category : #accessing }
BitBlt >> clipY: anInteger [ 
	"Set the receiver's clipping area top left y coordinate to be the argument, 
	anInteger."

	clipY := anInteger
]

{ #category : #accessing }
BitBlt >> color [
	"Return the current fill color as a Color.  
	 Gives the wrong answer if the halftoneForm is a complex pattern of more than one word."

	halftoneForm ifNil: [^ Color black].
	^ Color colorFromPixelValue: halftoneForm first depth: destForm depth
]

{ #category : #private }
BitBlt >> colorConvertingMap: targetColor from: sourceDepth to: destDepth keepSubPixelAA: keepSubPix [

	| srcIndex map mapsForSource mapsForSourceAndDest |
	ColorConvertingMaps class == Array 
		ifFalse: [ColorConvertingMaps := (1 to: 10) collect: [:i | Array new: 32]].
		
	srcIndex := sourceDepth.
	sourceDepth > 8 ifTrue: [ srcIndex := keepSubPix ifTrue: [9] ifFalse: [10] ].
	mapsForSource := ColorConvertingMaps at: srcIndex.
	mapsForSourceAndDest := (mapsForSource at: destDepth) ifNil: [ mapsForSource at: destDepth put: Dictionary new ].
	
	map := mapsForSourceAndDest at: targetColor ifAbsentPut: [
		Color computeColorConvertingMap: targetColor from: sourceDepth to: destDepth keepSubPixelAA: keepSubPix ].

	^ map
]

{ #category : #accessing }
BitBlt >> colorMap [
	^ colorMap
]

{ #category : #accessing }
BitBlt >> colorMap: map [
	"See last part of BitBlt comment. 6/18/96 tk"
	colorMap := map.
]

{ #category : #accessing }
BitBlt >> combinationRule [
	"Answer the receiver's combinationRule"
	
	^combinationRule
]

{ #category : #accessing }
BitBlt >> combinationRule: anInteger [ 
	"Set the receiver's combination rule to be the argument, anInteger, a 
	number in the range 0-15."

	combinationRule := anInteger
]

{ #category : #copying }
BitBlt >> copy: destRectangle from: sourcePt in: srcForm [
	| destOrigin |
	sourceForm := srcForm.
	halftoneForm := nil.
	combinationRule := 3.  "store"
	destOrigin := destRectangle origin.
	destX := destOrigin x.
	destY := destOrigin y.
	sourceX := sourcePt x.
	sourceY := sourcePt y.
	width := destRectangle width.
	height := destRectangle height.
	self copyBits
]

{ #category : #copying }
BitBlt >> copy: destRectangle from: sourcePt in: srcForm fillColor: hf rule: rule [
	"Specify a Color to fill, not a Form. 6/18/96 tk"  
	| destOrigin |
	sourceForm := srcForm.
	self fillColor: hf.	"sets halftoneForm"
	combinationRule := rule.
	destOrigin := destRectangle origin.
	destX := destOrigin x.
	destY := destOrigin y.
	sourceX := sourcePt x.
	sourceY := sourcePt y.
	width := destRectangle width.
	height := destRectangle height.
	srcForm == nil ifFalse:
		[colorMap := srcForm colormapIfNeededFor: destForm].
	^ self copyBits
]

{ #category : #copying }
BitBlt >> copy: destRectangle from: sourcePt in: srcForm halftoneForm: hf rule: rule [ 
	| destOrigin |
	sourceForm := srcForm.
	self fillColor: hf.		"sets halftoneForm"
	combinationRule := rule.
	destOrigin := destRectangle origin.
	destX := destOrigin x.
	destY := destOrigin y.
	sourceX := sourcePt x.
	sourceY := sourcePt y.
	width := destRectangle width.
	height := destRectangle height.
	self copyBits
]

{ #category : #copying }
BitBlt >> copyBits [
	"Primitive. Perform the movement of bits from the source form to the 
	destination form. Fail if any variables are not of the right type (Integer, 
	Float, or Form) or if the combination rule is not implemented. 
	In addition to the original 16 combination rules, this BitBlt supports
	16	fail (to simulate paint)
	17	fail (to simulate mask)
	18	sourceWord + destinationWord
	19	sourceWord - destinationWord
	20	rgbAdd: sourceWord with: destinationWord
	21	rgbSub: sourceWord with: destinationWord
	22	rgbDiff: sourceWord with: destinationWord
	23	tallyIntoMap: destinationWord
	24	alphaBlend: sourceWord with: destinationWord
	25	pixPaint: sourceWord with: destinationWord
	26	pixMask: sourceWord with: destinationWord
	27	rgbMax: sourceWord with: destinationWord
	28	rgbMin: sourceWord with: destinationWord
	29	rgbMin: sourceWord bitInvert32 with: destinationWord
"
	<primitive: 'primitiveCopyBits' module: 'BitBltPlugin' error: ec>

	(combinationRule >= 30 and: [combinationRule <= 31]) ifTrue:
		["No alpha specified -- re-run with alpha = 1.0"
		^ self copyBitsTranslucent: 255].
	"Check for object movement during a surface callback, compressed source, destination or halftone forms.
	 Simply retry."
	(ec == #'object moved'
	 or: [(sourceForm isForm and: [sourceForm unhibernate])
	 or: [(destForm isForm and: [destForm unhibernate])
	 or: [halftoneForm isForm and: [halftoneForm unhibernate]]]]) ifTrue:
		[^self copyBits].

	"Check for unimplmented rules"
	combinationRule = Form oldPaint ifTrue: [^self paintBits].
	combinationRule = Form oldErase1bitShape ifTrue: [^self eraseBits].

	"Check if BitBlt doesn't support full color maps"
	(colorMap notNil and: [colorMap isColormap]) ifTrue:
		[colorMap := colorMap colors.
		^self copyBits].
	"Check if clipping got way out of range"
	self clipRange.
	"Convert all numeric parameters to integers and try again."
	self roundVariables.
	^self copyBitsAgain
]

{ #category : #private }
BitBlt >> copyBitsAgain [
	"Primitive. See BitBlt|copyBits, also a Primitive. Essential. See Object
	documentation whatIsAPrimitive."

	<primitive: 'primitiveCopyBits' module: 'BitBltPlugin' error: ec>
	self primitiveFailed
]

{ #category : #private }
BitBlt >> copyBitsFrom: x0 to: x1 at: y [
	destX := x0.
	destY := y.
	sourceX := x0.
	width := (x1 - x0).
	self copyBits.
]

{ #category : #copying }
BitBlt >> copyBitsTranslucent: factor [
	"This entry point to BitBlt supplies an extra argument to specify translucency
	for operations 30 and 31.  The argument must be an integer between 0 and 255."

	<primitive: 'primitiveCopyBits' module: 'BitBltPlugin'>

	"Check for compressed source, destination or halftone forms"
	((sourceForm isForm) and: [sourceForm unhibernate])
		ifTrue: [^ self copyBitsTranslucent: factor].
	((destForm isForm) and: [destForm unhibernate])
		ifTrue: [^ self copyBitsTranslucent: factor].
	((halftoneForm isForm) and: [halftoneForm unhibernate])
		ifTrue: [^ self copyBitsTranslucent: factor].

	self primitiveFailed  "Later do nicer error recovery -- share copyBits recovery"
]

{ #category : #copying }
BitBlt >> copyForm: srcForm to: destPt rule: rule [
	^ self copyForm: srcForm to: destPt rule: rule
		colorMap: (srcForm colormapIfNeededFor: destForm)
]

{ #category : #copying }
BitBlt >> copyForm: srcForm to: destPt rule: rule color: color [
	sourceForm := srcForm.
	halftoneForm := color.
	combinationRule := rule.
	destX := destPt x + sourceForm offset x.
	destY := destPt y + sourceForm offset y.
	sourceX := 0.
	sourceY := 0.
	width := sourceForm width.
	height := sourceForm height.
	self copyBits
]

{ #category : #copying }
BitBlt >> copyForm: srcForm to: destPt rule: rule colorMap: map [
	sourceForm := srcForm.
	halftoneForm := nil.
	combinationRule := rule.
	destX := destPt x + sourceForm offset x.
	destY := destPt y + sourceForm offset y.
	sourceX := 0.
	sourceY := 0.
	width := sourceForm width.
	height := sourceForm height.
	colorMap := map.
	self copyBits
]

{ #category : #copying }
BitBlt >> copyForm: srcForm to: destPt rule: rule fillColor: color [
	sourceForm := srcForm.
	self fillColor: color.	"sets halftoneForm"
	combinationRule := rule.
	destX := destPt x + sourceForm offset x.
	destY := destPt y + sourceForm offset y.
	sourceX := 0.
	sourceY := 0.
	width := sourceForm width.
	height := sourceForm height.
	self copyBits
]

{ #category : #copying }
BitBlt >> copyFrom: sourceRectangle in: srcForm to: destPt [
	| sourceOrigin |
	sourceForm := srcForm.
	halftoneForm := nil.
	combinationRule := 3.  "store"
	destX := destPt x.
	destY := destPt y.
	sourceOrigin := sourceRectangle origin.
	sourceX := sourceOrigin x.
	sourceY := sourceOrigin y.
	width := sourceRectangle width.
	height := sourceRectangle height.
	colorMap := srcForm colormapIfNeededFor: destForm.
	self copyBits
]

{ #category : #accessing }
BitBlt >> destForm [
	^ destForm
]

{ #category : #accessing }
BitBlt >> destOrigin: aPoint [ 
	"Set the receiver's destination top left coordinates to be those of the 
	argument, aPoint."

	destX := aPoint x.
	destY := aPoint y
]

{ #category : #accessing }
BitBlt >> destRect [
	"The rectangle we are about to blit to or just blitted to.  "

	^ destX @ destY extent: width @ height
]

{ #category : #accessing }
BitBlt >> destRect: aRectangle [ 
	"Set the receiver's destination form top left coordinates to be the origin of 
	the argument, aRectangle, and set the width and height of the receiver's 
	destination form to be the width and height of aRectangle."

	destX := aRectangle left.
	destY := aRectangle top.
	width := aRectangle width.
	height := aRectangle height
]

{ #category : #accessing }
BitBlt >> destX: anInteger [ 
	"Set the top left x coordinate of the receiver's destination form to be the 
	argument, anInteger."

	destX := anInteger
]

{ #category : #accessing }
BitBlt >> destX: x destY: y width: w height: h [
	"Combined init message saves 3 sends from DisplayScanner"
	destX := x.
	destY := y.
	width := w.
	height := h.
]

{ #category : #accessing }
BitBlt >> destY: anInteger [ 
	"Set the top left y coordinate of the receiver's destination form to be the 
	argument, anInteger."

	destY := anInteger
]

{ #category : #copying }
BitBlt >> displayGlyph: aForm at: aPoint left: leftX right: rightX font: aFont [
	"Display a glyph in a multi-lingual font. Do 2 pass rendering if necessary.
	This happens when #installStrikeFont:foregroundColor:backgroundColor: sets rule 37 (rgbMul).
	the desired effect is to do two bitblt calls. The first one is with rule 37 and special colormap.
	The second one is rule 34, with a colormap for applying the requested foreground color.
	This two together do component alpha blending, i.e. alpha blend red, green and blue separatedly.
	This is needed for arbitrary color over abitrary background text with subpixel AA."

	| prevRule secondPassMap |
	self sourceForm: aForm.
	destX := aPoint x.
	destY := aPoint y.
	sourceX := leftX.
	sourceY := 0.
	width := rightX - leftX.
	height := aFont height.
	combinationRule = 37 ifTrue:[
		"We need to do a second pass. The colormap set is for use in the second pass."
		secondPassMap := colorMap.
		colorMap := sourceForm depth = destForm depth
			ifFalse: [ self cachedFontColormapFrom: sourceForm depth to: destForm depth ].
		self copyBits.
		prevRule := combinationRule.
		combinationRule := 20. "rgbAdd"
		colorMap := secondPassMap.
		self copyBits.
		combinationRule := prevRule.
	] ifFalse:[self copyBits].
]

{ #category : #copying }
BitBlt >> displayString: aString from: startIndex to: stopIndex at: aPoint strikeFont: font kern: kernDelta [
	"If required, do a second pass with new rule and colorMap.
	This happens when #installStrikeFont:foregroundColor:backgroundColor: sets rule 37 (rgbMul).
	the desired effect is to do two bitblt calls. The first one is with rule 37 and special colormap.
	The second one is rule 34, with a colormap for applying the requested foreground color.
	This two together do component alpha blending, i.e. alpha blend red, green and blue separatedly.
	This is needed for arbitrary color over abitrary background text with subpixel AA."

	| answer prevRule secondPassMap |
	"If combinationRule is rgbMul, we might need the special two-pass technique for component alpha blending.
	If not, do it simply"
	combinationRule = 37 "rgbMul" ifFalse: [
		^self basicDisplayString: aString from: startIndex to: stopIndex at: aPoint strikeFont: font kern: kernDelta ].
	
	"We need to do a second pass. The colormap set is for use in the second pass."
	secondPassMap := colorMap.
	colorMap := sourceForm depth ~= destForm depth
		ifTrue: [ self cachedFontColormapFrom: sourceForm depth to: destForm depth ].
	answer := self basicDisplayString: aString from: startIndex to: stopIndex at: aPoint strikeFont: font kern: kernDelta.
	colorMap := secondPassMap.
	secondPassMap ifNotNil: [
		prevRule := combinationRule.
		combinationRule := 20. "rgbAdd"
		self basicDisplayString: aString from: startIndex to: stopIndex at: aPoint strikeFont: font kern: kernDelta.
		combinationRule := prevRule ].
	^answer
]

{ #category : #'line drawing' }
BitBlt >> drawFrom: startPoint to: stopPoint [ 
	
	 ^ self drawFrom: startPoint to: stopPoint withFirstPoint: true
]

{ #category : #'line drawing' }
BitBlt >> drawFrom: startPoint to: stopPoint withFirstPoint: drawFirstPoint [
	"Draw a line whose end points are startPoint and stopPoint.
	The line is formed by repeatedly calling copyBits at every
	point along the line.  If drawFirstPoint is false, then omit
	the first point so as not to overstrike at line junctions."
	| offset point1 point2 forwards |
	"Always draw down, or at least left-to-right"
	forwards := (startPoint y = stopPoint y and: [startPoint x < stopPoint x])
				or: [startPoint y < stopPoint y].
	forwards
		ifTrue: [point1 := startPoint. point2 := stopPoint]
		ifFalse: [point1 := stopPoint. point2 := startPoint].
	sourceForm == nil ifTrue:
		[destX := point1 x.
		destY := point1 y]
		ifFalse:
		[width := sourceForm width.
		height := sourceForm height.
		offset := sourceForm offset.
		destX := (point1 x + offset x) rounded.
		destY := (point1 y + offset y) rounded].

	"Note that if not forwards, then the first point is the last and vice versa.
	We agree to always paint stopPoint, and to optionally paint startPoint."
	(drawFirstPoint or: [forwards == false  "ie this is stopPoint"])
		ifTrue: [self copyBits].
	self drawLoopX: (point2 x - point1 x) rounded 
				  Y: (point2 y - point1 y) rounded.
	(drawFirstPoint or: [forwards  "ie this is stopPoint"])
		ifTrue: [self copyBits].

]

{ #category : #'line drawing' }
BitBlt >> drawLoopX: xDelta Y: yDelta [ 
	"Primitive. Implements the Bresenham plotting algorithm (IBM Systems
	Journal, Vol. 4 No. 1, 1965). It chooses a principal direction, and
	maintains a potential, P. When P's sign changes, it is time to move in
	the minor direction as well. This particular version does not write the
	first and last points, so that these can be called for as needed in client code.
	Optional. See Object documentation whatIsAPrimitive."
	| dx dy px py P |
	<primitive: 'primitiveDrawLoop' module: 'BitBltPlugin'>
	dx := xDelta sign.
	dy := yDelta sign.
	px := yDelta abs.
	py := xDelta abs.
	"self copyBits."
	py > px
		ifTrue: 
			["more horizontal"
			P := py // 2.
			1 to: py do: 
				[:i |
				destX := destX + dx.
				(P := P - px) < 0 ifTrue: 
						[destY := destY + dy.
						P := P + py].
				i < py ifTrue: [self copyBits]]]
		ifFalse: 
			["more vertical"
			P := px // 2.
			1 to: px do:
				[:i |
				destY := destY + dy.
				(P := P - py) < 0 ifTrue: 
						[destX := destX + dx.
						P := P + px].
				i < px ifTrue: [self copyBits]]]
]

{ #category : #private }
BitBlt >> eraseBits [
	"Perform the erase operation, which puts 0's in the destination
	wherever the source (which is assumed to be just 1 bit deep)
	has a 1.  This requires the colorMap to be set in order to AND
	all 1's into the destFrom pixels regardless of their size."
	| oldMask oldMap |
	oldMask := halftoneForm.
	halftoneForm := nil.
	oldMap := colorMap.
	self colorMap: (Bitmap with: 0 with: 16rFFFFFFFF).
	combinationRule := Form erase.
	self copyBits. 		"Erase the dest wherever the source is 1"
	halftoneForm := oldMask.	"already converted to a Bitmap"
	colorMap := oldMap
]

{ #category : #copying }
BitBlt >> fill: destRect fillColor: grayForm rule: rule [
	"Fill with a Color, not a Form. 6/18/96 tk"
	sourceForm := nil.
	self fillColor: grayForm.		"sets halftoneForm"
	combinationRule := rule.
	destX := destRect left.
	destY := destRect top.
	sourceX := 0.
	sourceY := 0.
	width := destRect width.
	height := destRect height.
	self copyBits
]

{ #category : #accessing }
BitBlt >> fillColor [
	^ halftoneForm
]

{ #category : #accessing }
BitBlt >> fillColor: aColorOrPattern [ 
	"The destForm will be filled with this color or pattern of colors.  May be an old Color, a new type Color, a Bitmap (see BitBlt comment), a Pattern, or a Form.  6/18/96 tk"

	aColorOrPattern == nil ifTrue: [halftoneForm := nil. ^ self].
	destForm == nil ifTrue: [self error: 'Must set destForm first'].
	halftoneForm := destForm bitPatternFor: aColorOrPattern 
]

{ #category : #private }
BitBlt >> getPluginName [
	"Private. Return the name of the plugin representing BitBlt.
	Used for dynamically switching between different BB representations only."
	^'BitBltPlugin'
]

{ #category : #accessing }
BitBlt >> halftoneForm [
	"Returns the receivers half tone form. See class commment."
	
	^halftoneForm
]

{ #category : #accessing }
BitBlt >> halftoneForm: aBitmap [
	"Sets the receivers half tone form. See class commment."
	
	halftoneForm := aBitmap
	
 
]

{ #category : #accessing }
BitBlt >> height: anInteger [ 
	"Set the receiver's destination form height to be the argument, anInteger."

	height := anInteger
]

{ #category : #private }
BitBlt >> installStrikeFont: aStrikeFont foregroundColor: foregroundColor backgroundColor: backgroundColor [
	| lastSourceDepth targetColor |
	sourceForm ifNotNil:[lastSourceDepth := sourceForm depth].
	sourceForm := aStrikeFont glyphs.

	"Ignore any halftone pattern since we use a color map approach here"
	halftoneForm := nil.
	sourceY := 0.
	height := aStrikeFont height.

	sourceForm depth = 1 ifTrue: [
		self combinationRule: Form paint.
		(colorMap notNil and:[lastSourceDepth = sourceForm depth]) ifFalse: [
			"Set up color map for a different source depth (color font)"
			"Uses caching for reasonable efficiency"
			colorMap := self cachedFontColormapFrom: sourceForm depth to: destForm depth.
			colorMap at: 1 put: (destForm pixelValueFor: backgroundColor)].
		colorMap at: 2 put: (destForm pixelValueFor: foregroundColor).
	]
	ifFalse: [
		(self class subPixelRenderFonts and: [ foregroundColor = Color black
			"Only use rgbMul with opaque colors as alpha values get lost for translucent colors."
			or: [ self class subPixelRenderColorFonts and: [foregroundColor isOpaque] ]]) ifTrue: [
			destForm depth > 8 ifTrue: [
				"rgbMul is equivalent to component alpha blend if text is black (only faster, hehe)"
				self combinationRule: Form rgbMul.
				colorMap := (destForm depth = 32 or: [ (foregroundColor = Color black) not ]) ifTrue: [
					"rgbMul / rgbAdd IS component alpha blend for any color of text (neat trick, eh!)"
					"This colorMap is to be used on the second pass with rule 20 (rgbAdd)
					See #displayString:from:to:at:strikeFont:kern:"
					"Note: In 32bpp we always need the second pass, as the source could have transparent pixels, and we need to add to the alpha channel"
					self colorConvertingMap: foregroundColor from: sourceForm depth to: destForm depth keepSubPixelAA: true]]
			ifFalse: [
				self combinationRule: Form paint.
				targetColor := foregroundColor = Color black ifFalse: [ foregroundColor ].
				colorMap := self colorConvertingMap: targetColor from: sourceForm depth to: destForm depth keepSubPixelAA: true]
		]
		ifFalse: [
			"Do not use rule 34 for 16bpp display. TTCFont uses it, but it builds a glyphs cache for each color used!"
			self combinationRule: (destForm depth = 32 ifTrue: [Form blendAlphaScaled] ifFalse: [Form paint]).
			colorMap := self colorConvertingMap: foregroundColor from: sourceForm depth to: destForm depth keepSubPixelAA: false
		]
	].
]

{ #category : #private }
BitBlt >> installTTCFont: aTTCFont foregroundColor: foregroundColor backgroundColor: backgroundColor [
	"Set up the parameters.  Since the glyphs in a TTCFont is 32bit depth form, it tries to use rule=34 to get better AA result if possible."

	((aTTCFont depth = 32)) ifTrue: [
		destForm depth <= 8 ifTrue: [
			self colorMap: (self cachedFontColormapFrom: aTTCFont depth to: destForm depth).
			self combinationRule: Form paint.
		] ifFalse: [
			self colorMap: nil.
			self combinationRule: 34.
		].
		halftoneForm := nil.
		sourceY := 0.
		height := aTTCFont height.
	].

]

{ #category : #private }
BitBlt >> paintBits [
	"Perform the paint operation, which requires two calls to BitBlt."
	| color oldMap saveRule |
	sourceForm depth = 1 ifFalse: 
		[^ self halt: 'paint operation is only defined for 1-bit deep sourceForms'].
	saveRule := combinationRule.
	color := halftoneForm.  halftoneForm := nil.
	oldMap := colorMap.
	"Map 1's to ALL ones, not just one"
	self colorMap: (Bitmap with: 0 with: 16rFFFFFFFF).
	combinationRule := Form erase.
	self copyBits. 		"Erase the dest wherever the source is 1"
	halftoneForm := color.
	combinationRule := Form under.
	self copyBits.	"then OR, with whatever color, into the hole"
	colorMap := oldMap.
	combinationRule := saveRule

" | dot |
dot := Form dotOfSize: 32.
((BitBlt destForm: Display
		sourceForm: dot
		fillColor: Color lightGray
		combinationRule: Form paint
		destOrigin: Sensor cursorPoint
		sourceOrigin: 0@0
		extent: dot extent
		clipRect: Display boundingBox)
		colorMap: (Bitmap with: 0 with: 16rFFFFFFFF)) copyBits"
]

{ #category : #copying }
BitBlt >> pixelAt: aPoint [
	"Assumes this BitBlt has been set up specially (see the init message,
	BitBlt bitPeekerFromForm:.  Returns the pixel at aPoint."
	sourceX := aPoint x.
	sourceY := aPoint y.
	destForm unhibernate. "before poking"
	destForm bits at: 1 put: 0.  "Just to be sure"
	self copyBits.
	^ destForm bits at: 1
]

{ #category : #copying }
BitBlt >> pixelAt: aPoint put: pixelValue [
	"Assumes this BitBlt has been set up specially (see the init message,
	BitBlt bitPokerToForm:.  Overwrites the pixel at aPoint."
	destX := aPoint x.
	destY := aPoint y.
	sourceForm unhibernate. "before poking"
	sourceForm bits at: 1 put: pixelValue.
	self copyBits
"
| bb |
bb := (BitBlt bitPokerToForm: Display).
[Sensor anyButtonPressed] whileFalse:
	[bb pixelAt: Sensor cursorPoint put: 55]
"
]

{ #category : #private }
BitBlt >> primCompareColor: colorValueA to: colorValueB test: testID [
	"Call the prim that compares pixel color values and can tell if two Forms that overlap in some manner when composited are touching colors as defined by the testID.
"
	<primitive: 'primitiveCompareColors' module: 'BitBltPlugin'>
	"to signal failure without an error we'll return -1"
	^-1
]

{ #category : #private }
BitBlt >> primDisplayString: aString from: startIndex to: stopIndex map: glyphMap xTable: xTable kern: kernDelta [
	| ascii |
	<primitive:'primitiveDisplayString' module:'BitBltPlugin'>

	((sourceForm isForm) and: [sourceForm unhibernate])
		ifTrue: [^ self primDisplayString: aString from: startIndex to: stopIndex map: glyphMap xTable: xTable kern: kernDelta].
	((destForm isForm) and: [destForm unhibernate])
		ifTrue: [^ self primDisplayString: aString from: startIndex to: stopIndex map: glyphMap xTable: xTable kern: kernDelta].
	((halftoneForm isForm) and: [halftoneForm unhibernate])
		ifTrue: [^ self primDisplayString: aString from: startIndex to: stopIndex map: glyphMap xTable: xTable kern: kernDelta].

	startIndex to: stopIndex do:[:charIndex|
		ascii := (aString at: charIndex) asciiValue.
		glyphMap ifNotNil:[ascii := glyphMap at: ascii+1].
		sourceX := xTable at: ascii + 1.
		width := (xTable at: ascii + 2) - sourceX.
		self copyBits.
		destX := destX + width + kernDelta.
	].
]

{ #category : #private }
BitBlt >> roundVariables [

	| maxVal minVal |
	maxVal := SmallInteger maxVal.
	minVal := SmallInteger minVal.
	destX := destX asInteger min: maxVal max: minVal.
	destY := destY asInteger min: maxVal max: minVal.
	width := width asInteger min: maxVal max: minVal.
	height := height asInteger min: maxVal max: minVal.
	sourceX := sourceX asInteger min: maxVal max: minVal.
	sourceY := sourceY asInteger min: maxVal max: minVal.
	clipX := clipX asInteger min: maxVal max: minVal.
	clipY := clipY asInteger min: maxVal max: minVal.
	clipWidth := clipWidth asInteger min: maxVal max: minVal.
	clipHeight := clipHeight asInteger min: maxVal max: minVal.

]

{ #category : #private }
BitBlt >> setDestForm: df [
	| bb |
	bb := df boundingBox.
	destForm := df.
	clipX := bb left.
	clipY := bb top.
	clipWidth := bb width.
	clipHeight := bb height
]

{ #category : #private }
BitBlt >> setDestForm: df sourceForm: sf fillColor: hf combinationRule: cr destOrigin: destOrigin sourceOrigin: sourceOrigin extent: extent clipRect: clipRect [

	| aPoint |
	destForm := df.
	sourceForm := sf.
	self fillColor: hf.	"sets halftoneForm"
	combinationRule := cr.
	destX := destOrigin x.
	destY := destOrigin y.
	sourceX := sourceOrigin x.
	sourceY := sourceOrigin y.
	width := extent x.
	height := extent y.
	aPoint := clipRect origin.
	clipX := aPoint x.
	clipY := aPoint y.
	aPoint := clipRect corner.
	clipWidth := aPoint x - clipX.
	clipHeight := aPoint y - clipY.
	sourceForm == nil ifFalse:
		[colorMap := sourceForm colormapIfNeededFor: destForm]
]

{ #category : #accessing }
BitBlt >> sourceForm [

	^ sourceForm
]

{ #category : #accessing }
BitBlt >> sourceForm: aForm [ 
	"Set the receiver's source form to be the argument, aForm."

	sourceForm := aForm
]

{ #category : #accessing }
BitBlt >> sourceOrigin: aPoint [ 
	"Set the receiver's source form coordinates to be those of the argument, 
	aPoint."

	sourceX := aPoint x.
	sourceY := aPoint y
]

{ #category : #accessing }
BitBlt >> sourceRect: aRectangle [ 
	"Set the receiver's source form top left x and y, width and height to be 
	the top left coordinate and extent of the argument, aRectangle."

	sourceX := aRectangle left.
	sourceY := aRectangle top.
	width := aRectangle width.
	height := aRectangle height
]

{ #category : #accessing }
BitBlt >> sourceX: anInteger [ 
	"Set the receiver's source form top left x to be the argument, anInteger."

	sourceX := anInteger
]

{ #category : #accessing }
BitBlt >> sourceY: anInteger [ 
	"Set the receiver's source form top left y to be the argument, anInteger."

	sourceY := anInteger
]

{ #category : #accessing }
BitBlt >> tallyMap [
	"Return the map used for tallying pixels"
	^colorMap
]

{ #category : #accessing }
BitBlt >> tallyMap: aBitmap [
	"Install the map used for tallying pixels"
	colorMap := aBitmap
]

{ #category : #accessing }
BitBlt >> width: anInteger [ 
	"Set the receiver's destination form width to be the argument, anInteger."

	width := anInteger
]
