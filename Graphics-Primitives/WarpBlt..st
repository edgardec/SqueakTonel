"
WarpBlt is a little warp-drive added on to BitBlt.  It takes a quadrilateral as its source specification, while its destination is traversed and combined just like any other call to copyBits.

The source quadrilateral is specified as an array of points starting with the corner that wants to end up in the topLeft, and proceding to the successive points that want to follow CCW around the destination rectangle.  Note that in specifying a plain old rectangle source, its non topLeft points must be actual pixels, not outside by 1, as with rectangle bottmRight, eg.  See the method Rectangle asQuad.

WarpBlt does a fast job of rotation, reflection and scaling, and it can even produce a semblance of perspective.  Depth parameters are included for future improvements in this direction. but the primitve does not support this yet.
"
Class {
	#name : #WarpBlt,
	#superclass : #BitBlt,
	#instVars : [
		'p1x',
		'p1y',
		'p1z',
		'p2x',
		'p2y',
		'p2z',
		'p3x',
		'p3y',
		'p3z',
		'p4x',
		'p4y',
		'p4z',
		'cellSize',
		'sourceRGBmap'
	],
	#category : #'Graphics-Primitives'
}

{ #category : #'instance creation' }
WarpBlt class >> current [
	"Return the class currently to be used for WarpBlt"
	^self
]

{ #category : #'form rotation' }
WarpBlt class >> rotate: srcForm degrees: angleInDegrees center: rotationCenter scaleBy: scalePoint smoothing: cellSize [ 
	"Rotate the given Form angleInDegrees about the given rotationCenter and scale its width and height by x and y of the given scale
	point. Smooth using the given cell size, an integer between 1 and 3, where 1 means no smoothing. 
	Return a pair where the first element is the rotated Form and the second is the position offset required to align the center of the rotated Form with that of the original. 
	Note that the dimensions of the resulting Form generally differ from those of the original."
	| srcRect srcCenter radians dstOrigin dstCorner p dstRect inverseScale quad dstForm warpSrc newRotationPoint oldOffset |
	srcRect := srcForm boundingBox.
	srcCenter := srcRect center.
	radians := angleInDegrees degreesToRadians.
	dstOrigin := dstCorner := srcCenter.
	srcRect corners
		do: [:corner | 
			"find the limits of a rectangle that just encloses the rotated
			original; in general, this rectangle will be larger than the
			original (e.g., consider a square rotated by 45 degrees)"
			p := (corner - srcCenter scaleBy: scalePoint) + srcCenter.
			p := (p rotateBy: radians about: srcCenter) rounded.
			dstOrigin := dstOrigin min: p.
			dstCorner := dstCorner max: p].
	"rotate the enclosing rectangle back to get the source quadrilateral"
	dstRect := dstOrigin corner: dstCorner.
	inverseScale := 1.0 / scalePoint x @ (1.0 / scalePoint y).
	quad := dstRect innerCorners
				collect: [:corner | 
					p := corner rotateBy: radians negated about: srcCenter.
					(p - srcCenter scaleBy: inverseScale) + srcCenter].

	"make a Form to hold the result and do the rotation"
	warpSrc := srcForm.
	srcForm isColorForm
		ifTrue: [warpSrc := Form extent: srcForm extent depth: 16.
			srcForm displayOn: warpSrc.
			dstForm := Form extent: dstRect extent depth: 16
			"use 16-bit depth to allow smoothing"]
		ifFalse: [dstForm := srcForm species extent: dstRect extent depth: srcForm depth].
	(WarpBlt toForm: dstForm)
		sourceForm: warpSrc;
		colorMap: (warpSrc colormapIfNeededFor: dstForm);
		 cellSize: cellSize;
		 combinationRule: Form paint;
		 copyQuad: quad toRect: dstForm boundingBox.

	"installs a new colormap if cellSize > 1"
	dstForm isColorForm
		ifTrue: [dstForm colors: srcForm colors copy].

	oldOffset := rotationCenter - srcCenter truncated * scalePoint.
	newRotationPoint := dstForm extent / 2.0 + (oldOffset rotateBy: radians about: 0 @ 0).

	^ Array with: dstForm with: newRotationPoint - rotationCenter
]

{ #category : #examples }
WarpBlt class >> test1 [   "Display restoreAfter: [WarpBlt test1]"
	"Demonstrates variable scale and rotate"
	| warp pts r1 p0 p ext |
	UIManager default informUser: 'Choose a rectangle with interesting stuff'
		during: [r1 := Rectangle originFromUser: 50@50.
				Sensor waitNoButton].
	UIManager default informUser: 'Now click down and up
and move the mouse around the dot'
		during: [p0 := Sensor waitClickButton.
				(Form dotOfSize: 8) displayAt: p0].
	warp := (self toForm: Display)
		clipRect: (0@0 extent: r1 extent*5);
		sourceForm: Display;
		combinationRule: Form over.
	[Sensor anyButtonPressed] whileFalse:
		[p := Sensor cursorPoint.
		pts := {r1 topLeft. r1 bottomLeft. r1 bottomRight. r1 topRight}
			collect: [:pt | pt rotateBy: (p-p0) theta about: r1 center].
		ext := (r1 extent*((p-p0) r / 20.0 max: 0.1)) asIntegerPoint.
		warp copyQuad: pts toRect: (r1 extent*5-ext//2 extent: ext)]
]

{ #category : #examples }
WarpBlt class >> test12 [   "Display restoreAfter: [WarpBlt test12]"
	"Just like test1, but comparing smooth to non-smooth warps"
	| warp pts r1 p0 p ext warp2 |
	UIManager default informUser: 'Choose a rectangle with interesting stuff'
		during: [r1 := Rectangle originFromUser: 50@50.
				Sensor waitNoButton].
	UIManager default informUser: 'Now click down and up
and move the mouse around the dot'
		during: [p0 := Sensor waitClickButton.
				(Form dotOfSize: 8) displayAt: p0].
	warp := (self toForm: Display)
		cellSize: 2;  "installs a colormap"
		clipRect: (0@0 extent: r1 extent*5);
		sourceForm: Display;
		combinationRule: Form over.
	warp2 := (self toForm: Display)
		clipRect: ((0@0 extent: r1 extent*5) translateBy: 250@0);
		sourceForm: Display;
		combinationRule: Form over.
	[Sensor anyButtonPressed] whileFalse:
		[p := Sensor cursorPoint.
		pts := {r1 topLeft. r1 bottomLeft. r1 bottomRight. r1 topRight}
			collect: [:pt | pt rotateBy: (p-p0) theta about: r1 center].
		ext := (r1 extent*((p-p0) r / 20.0 max: 0.1)) asIntegerPoint.
		warp copyQuad: pts toRect: (r1 extent*5-ext//2 extent: ext).
		warp2 copyQuad: pts toRect: ((r1 extent*5-ext//2 extent: ext) translateBy: 250@0).
		]
]

{ #category : #examples }
WarpBlt class >> test3 [   "Display restoreAfter: [WarpBlt test3]"

	"The Squeak Release Mandala - 9/23/96 di"

	"Move the mouse near the center of the square.
	Up and down affects shrink/grow
	Left and right affect rotation angle"
	| warp pts p0 box map d p |
	box := 100@100 extent: 300@300.
	Display border: (box expandBy: 2) width: 2.

	"Make a color map that steps through the color space"
	map := (Display depth > 8
		ifTrue: ["RGB is a bit messy..."
				d := Display depth = 16 ifTrue: [5] ifFalse: [8].
				(1 to: 512) collect: [:i | | t |
					t := i bitAnd: 511.
					((t bitAnd: 16r7) bitShift: d-3)
					+ ((t bitAnd: 16r38) bitShift: d-3*2)
					+ ((t bitAnd: 16r1C0) bitShift: d-3*3)]]
		ifFalse: ["otherwise simple"
				1 to: (1 bitShift: Display depth)])
			as: Bitmap.
	warp := (WarpBlt toForm: Display)
		clipRect: box;
		sourceForm: Display;
		colorMap: map;
		combinationRule: Form over.
	p0 := box center.
	[Sensor anyButtonPressed] whileFalse:
		[p := Sensor cursorPoint.
		pts := (box insetBy: p y - p0 y) innerCorners
			collect: [:pt | pt rotateBy: p x - p0 x / 50.0 about: p0].
		warp copyQuad: pts toRect: box]
]

{ #category : #examples }
WarpBlt class >> test4 [   "Display restoreAfter: [WarpBlt test4]"

	"The Squeak Release Mandala - 9/23/96 di
	This version does smoothing"

	"Move the mouse near the center ofhe square.
	Up and dn affects shrink/grow
	Left and right affect rotation angle"
	| warp pts p0 p box |
	box := 100@100 extent: 300@300.
	Display border: (box expandBy: 2) width: 2.

	warp := (WarpBlt toForm: Display)
		clipRect: box;
		sourceForm: Display;
		cellSize: 2;  "installs a colormap"
		combinationRule: Form over.
	p0 := box center.
	[Sensor anyButtonPressed] whileFalse:
		[p := Sensor cursorPoint.
		pts := (box insetBy: p y - p0 y) innerCorners
			collect: [:pt | pt rotateBy: p x - p0 x / 50.0 about: p0].
		warp copyQuad: pts toRect: box]
]

{ #category : #examples }
WarpBlt class >> test5 [   "Display restoreAfter: [WarpBlt test5]"
	"Demonstrates variable scale and rotate"
	| warp pts r1 p0 p |
	UIManager default informUser: 'Choose a rectangle with interesting stuff'
		during: [r1 := Rectangle fromUser.
				Sensor waitNoButton].
	UIManager default informUser: 'Now click down and up
and move the mouse around the dot'
		during: [p0 := Sensor waitClickButton.
				(Form dotOfSize: 8) displayAt: p0].
	warp := (self toForm: Display)
		cellSize: 1;
		sourceForm: Display;
		cellSize: 2;  "installs a colormap"
		combinationRule: Form over.
	[Sensor anyButtonPressed] whileFalse:
		[p := Sensor cursorPoint.
		pts := {r1 topLeft. r1 bottomLeft. r1 bottomRight. r1 topRight}
			collect: [:pt | pt rotateBy: (p-p0) theta about: r1 center].
		warp copyQuad: pts toRect: (r1 translateBy: r1 width@0)]
]

{ #category : #initialization }
WarpBlt class >> toForm: destinationForm [
	"Default cell size is 1 (no pixel smoothing)"
	^ (super toForm: destinationForm) cellSize: 1
]

{ #category : #setup }
WarpBlt >> cellSize [
	^ cellSize
]

{ #category : #setup }
WarpBlt >> cellSize: s [
	"Set the number of samples used for averaging"
	cellSize := s.
	cellSize = 1 ifTrue: [^ self].
	"Install the colorMap to used for mapping the averaged RGBA 32bit pixels to the
	destination depth. Note that we need to install the 32->32 color map explicitly because
	the VM will substitute a colorMap derived from sourceForm->destForm mapping which
	is just plain wrong for <32 source and 32bit dest depth"
	(destForm depth = 32 and: [sourceForm notNil and: [sourceForm depth < 32]])
		ifTrue:[colorMap := ColorMap shifts: #(0 0 0 0) masks:#(16rFF0000 16rFF00 16rFF 16rFF000000) colors: nil]
		ifFalse:[colorMap := Color colorMapIfNeededFrom: 32 to: destForm depth].

]

{ #category : #primitives }
WarpBlt >> copyQuad: pts toRect: destRect [
	self sourceQuad: pts destRect: destRect.
	self warpBits
]

{ #category : #primitives }
WarpBlt >> deltaFrom: x1 to: x2 nSteps: n [
	"Utility routine for computing Warp increments.
	x1 is starting pixel, x2 is ending pixel;  assumes n >= 1"
	| fixedPtOne |
	fixedPtOne := 16384.  "1.0 in fixed-pt representation"
	x2 > x1
		ifTrue: [^ x2 - x1 + fixedPtOne // (n+1) + 1]
		ifFalse: [x2 = x1 ifTrue: [^ 0].
				^ 0 - (x1 - x2 + fixedPtOne // (n+1) + 1)]
]

{ #category : #smoothing }
WarpBlt >> mixPix: pix sourceMap: sourceMap destMap: destMap [
	"Average the pixels in array pix to produce a destination pixel.
	First average the RGB values either from the pixels directly,
	or as supplied in the sourceMap.  Then return either the resulting
	RGB value directly, or use it to index the destination color map." 
	| r g b rgb nPix bitsPerColor d |
	nPix := pix size.
	r := 0. g := 0. b := 0.
	1 to: nPix do:
		[:i |   "Sum R, G, B values for each pixel"
		rgb := sourceForm depth <= 8
				ifTrue: [sourceMap at: (pix at: i) + 1]
				ifFalse: [sourceForm depth = 32
						ifTrue: [pix at: i]
						ifFalse: [self rgbMap: (pix at: i) from: 5 to: 8]].
		r := r + ((rgb bitShift: -16) bitAnd: 16rFF).
		g := g + ((rgb bitShift: -8) bitAnd: 16rFF).
		b := b + ((rgb bitShift: 0) bitAnd: 16rFF)].
	destMap == nil
		ifTrue: [bitsPerColor := 3.  "just in case eg depth <= 8 and no map"
				destForm depth = 16 ifTrue: [bitsPerColor := 5].
				destForm depth = 32 ifTrue: [bitsPerColor := 8]]
		ifFalse: [destMap size = 512 ifTrue: [bitsPerColor := 3].
				destMap size = 4096 ifTrue: [bitsPerColor := 4].
				destMap size = 32768 ifTrue: [bitsPerColor := 5]].
	d := bitsPerColor - 8.
	rgb := ((r // nPix bitShift: d) bitShift: bitsPerColor*2)
		+ ((g // nPix bitShift: d) bitShift: bitsPerColor)
		+ ((b // nPix bitShift: d) bitShift: 0).
	destMap == nil
		ifTrue: [^ rgb]
		ifFalse: [^ destMap at: rgb+1]
]

{ #category : #smoothing }
WarpBlt >> rgbMap: sourcePixel from: nBitsIn to: nBitsOut [
	"NOTE: This code is copied verbatim from BitBltSimulation so that it
	may be removed from the system"
	"Convert the given pixel value with nBitsIn bits for each color component to a pixel value with nBitsOut bits for each color component. Typical values for nBitsIn/nBitsOut are 3, 5, or 8."
	| mask d srcPix destPix |
	<inline: true>
	(d := nBitsOut - nBitsIn) > 0
		ifTrue:
			["Expand to more bits by zero-fill"
			mask := (1 << nBitsIn) - 1.  "Transfer mask"
			srcPix := sourcePixel << d.
			mask := mask << d.
			destPix := srcPix bitAnd: mask.
			mask := mask << nBitsOut.
			srcPix := srcPix << d.
			^ destPix + (srcPix bitAnd: mask)
				 	+ (srcPix << d bitAnd: mask << nBitsOut)]
		ifFalse:
			["Compress to fewer bits by truncation"
			d = 0 ifTrue: [^ sourcePixel].  "no compression"
			sourcePixel = 0 ifTrue: [^ sourcePixel].  "always map 0 (transparent) to 0"
			d := nBitsIn - nBitsOut.
			mask := (1 << nBitsOut) - 1.  "Transfer mask"
			srcPix := sourcePixel >> d.
			destPix := srcPix bitAnd: mask.
			mask := mask << nBitsOut.
			srcPix := srcPix >> d.
			destPix := destPix + (srcPix bitAnd: mask)
					+ (srcPix >> d bitAnd: mask << nBitsOut).
			destPix = 0 ifTrue: [^ 1].  "Dont fall into transparent by truncation"
			^ destPix]
]

{ #category : #primitives }
WarpBlt >> sourceForm: srcForm destRect: dstRectangle [
	"Set up a WarpBlt from the entire source Form to the given destination rectangle."

	| w h |
	sourceForm := srcForm.
	sourceX := sourceY := 0.
	destX := dstRectangle left.
	destY := dstRectangle top.
	width := dstRectangle width.
	height := dstRectangle height.
	w := 16384 * (srcForm width - 1).
	h := 16384 * (srcForm height - 1).
	p1x := 0.
	p2x := 0.
	p3x := w.
	p4x := w.
	p1y := 0.
	p2y := h.
	p3y := h.
	p4y := 0.
	p1z := p2z := p3z := p4z := 16384.  "z-warp ignored for now"

]

{ #category : #primitives }
WarpBlt >> sourceQuad: pts destRect: aRectangle [
	| fixedPt1 |
	sourceX := sourceY := 0.
	self destRect: aRectangle.
	fixedPt1 := (pts at: 1) x isInteger ifTrue: [16384] ifFalse: [16384.0].
	p1x := (pts at: 1) x * fixedPt1.
	p2x := (pts at: 2) x * fixedPt1.
	p3x := (pts at: 3) x * fixedPt1.
	p4x := (pts at: 4) x * fixedPt1.
	p1y := (pts at: 1) y * fixedPt1.
	p2y := (pts at: 2) y * fixedPt1.
	p3y := (pts at: 3) y * fixedPt1.
	p4y := (pts at: 4) y * fixedPt1.
	p1z := p2z := p3z := p4z := 16384.  "z-warp ignored for now"

]

{ #category : #primitives }
WarpBlt >> startFrom: x1 to: x2 offset: sumOfDeltas [
	"Utility routine for computing Warp increments."
	x2 >= x1
		ifTrue: [^ x1]
		ifFalse: [^ x2 - sumOfDeltas]
]

{ #category : #primitives }
WarpBlt >> warpBits [
	"Move those pixels!"

	cellSize < 1 ifTrue: [ ^self error: 'cellSize must be >= 1' ].

	self warpBitsSmoothing: cellSize
		sourceMap: (sourceForm colormapIfNeededForDepth: 32).

]

{ #category : #primitives }
WarpBlt >> warpBitsSmoothing: n sourceMap: sourceMap [
	| deltaP12 deltaP43 pA pB deltaPAB sp fixedPtOne poker pix nSteps |
	<primitive: 'primitiveWarpBits' module: 'BitBltPlugin' error: ec>

	"Check for compressed source, destination or halftone forms"
	"Check for object movement during a surface callback, compressed source, destination or halftone forms.
	 Simply retry."
	(ec == #'object moved'
	 or: [(sourceForm isForm and: [sourceForm unhibernate])
	 or: [(destForm isForm and: [destForm unhibernate])
	 or: [halftoneForm isForm and: [halftoneForm unhibernate]]]]) ifTrue:
		[^self warpBitsSmoothing: n sourceMap: sourceMap].

	(width < 1) | (height < 1) ifTrue: [^ self].
	fixedPtOne := 16384.  "1.0 in fixed-pt representation"
	n > 1 ifTrue:
		[(destForm depth < 16 and: [colorMap == nil])
			ifTrue: ["color map is required to smooth non-RGB dest"
					^ self primitiveFailed].
		pix := Array new: n*n].

	nSteps := height-1 max: 1.
	deltaP12 := (self deltaFrom: p1x to: p2x nSteps: nSteps)
			@ (self deltaFrom: p1y to: p2y nSteps: nSteps).
	pA := (self startFrom: p1x to: p2x offset: nSteps*deltaP12 x)
		@ (self startFrom: p1y to: p2y offset: nSteps*deltaP12 y).
	deltaP43 := (self deltaFrom: p4x to: p3x nSteps: nSteps)
			@ (self deltaFrom: p4y to: p3y nSteps: nSteps).
	pB := (self startFrom: p4x to: p3x offset: nSteps*deltaP43 x)
		@ (self startFrom: p4y to: p3y offset: nSteps*deltaP43 y).

	poker := BitBlt bitPokerToForm: destForm.
	poker clipRect: self clipRect.
	nSteps := width-1 max: 1.
	destY to: destY+height-1 do:
		[:y |
		deltaPAB := (self deltaFrom: pA x to: pB x nSteps: nSteps)
				@ (self deltaFrom: pA y to: pB y nSteps: nSteps).
		sp := (self startFrom: pA x to: pB x offset: nSteps*deltaPAB x)
			@ (self startFrom: pA y to: pB y offset: nSteps*deltaPAB x).
		destX to: destX+width-1 do:
			[:x | 
			n = 1
			ifTrue:
				[poker pixelAt: x@y
						put: (sourceForm pixelValueAt: sp // fixedPtOne asPoint)]
			ifFalse:
				[0 to: n-1 do:
					[:dx | 0 to: n-1 do:
						[:dy |
						pix at: dx*n+dy+1 put:
								(sourceForm pixelValueAt: sp
									+ (deltaPAB*dx//n)
									+ (deltaP12*dy//n)
										// fixedPtOne asPoint)]].
				poker pixelAt: x@y put: (self mixPix: pix
											sourceMap: sourceMap
											destMap: colorMap)].
			sp := sp + deltaPAB].
		pA := pA + deltaP12.
		pB := pB + deltaP43]
]
