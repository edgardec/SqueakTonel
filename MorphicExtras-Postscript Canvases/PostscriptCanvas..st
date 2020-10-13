"
I am a canvas that converts Morphic drawing messages into Postscript.  The canvas itself does not actually generate the Postscript code, but rather sends messages corresponding 1:1 to the Postscript imaging model to its target (default: PostscriptEncoder), which has the job of generating actual drawing commands.

PostscriptCharacterScanner and PostscriptDummyWarp are helper classes that simulate effects currently implemented via BitBlt-specific mechanisms during Postscript generation.  They should be going away as Morphic becomes fully device independent.


"
Class {
	#name : #PostscriptCanvas,
	#superclass : #Canvas,
	#instVars : [
		'origin',
		'clipRect',
		'currentColor',
		'shadowColor',
		'currentFont',
		'morphLevel',
		'gstateStack',
		'fontMap',
		'usedFonts',
		'psBounds',
		'topLevelMorph',
		'initialScale',
		'savedMorphExtent',
		'currentTransformation',
		'printSpecs',
		'pages'
	],
	#classVars : [
		'FontMap'
	],
	#category : #'MorphicExtras-Postscript Canvases'
}

{ #category : #configuring }
PostscriptCanvas class >> baseOffset [
	^0@0.

]

{ #category : #'font mapping' }
PostscriptCanvas class >> convertFontName: aName [
	"Break apart aName on case boundaries, inserting hyphens as needed."
	| lastCase |
	lastCase := aName first isUppercase.
	^ String streamContents: [ :s |
		aName do: [ :c | | thisCase |
			thisCase := c isUppercase.
			(thisCase and: [ lastCase not ]) ifTrue: [ s nextPut: $- ].
			lastCase := thisCase.
			s nextPut: c ]]
]

{ #category : #configuring }
PostscriptCanvas class >> defaultCanvasType [

	^Preferences postscriptStoredAsEPS ifTrue: [EPSCanvas] ifFalse: [DSCPostscriptCanvas]
]

{ #category : #configuring }
PostscriptCanvas class >> defaultExtension [
	^ '.ps'
]

{ #category : #configuring }
PostscriptCanvas class >> defaultTarget [
	^PostscriptEncoder stream.

]

{ #category : #configuring }
PostscriptCanvas class >> filterSelector [
	^#fullDrawPostscriptOn:.

]

{ #category : #'font mapping' }
PostscriptCanvas class >> fontMap [
	"Answer the font mapping dictionary. Made into a class var so that it can be edited."
	^FontMap ifNil: [ self initializeFontMap. FontMap ].
]

{ #category : #'font mapping' }
PostscriptCanvas class >> fontSampler [
	"Produces a Postscript .eps file on disk, returns a Morph."
	"PostscriptCanvas fontSampler"
	"PostscriptCanvas fontSampler openInWorld"
	| morph file |
	morph := Morph new
		layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
		wrapDirection: #leftToRight;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: Color white.
	TextStyle actualTextStyles keysAndValuesDo: [ :styleName :style |
		{ style fontArray first. style fontArray last } do: [ :baseFont | | info |
			0 to: 2 do: [ :i | | font string string2 textMorph row |
				font := baseFont emphasized: i.
				(i isZero or: [ font ~~ baseFont ]) ifTrue: [
					string := font fontNameWithPointSize.
					row := Morph new
						layoutPolicy: TableLayout new;
						listDirection: #topToBottom;
						hResizing: #shrinkWrap;
						vResizing: #shrinkWrap;
						cellGap: 20@0;
						color: Color white.
		
					textMorph := TextMorph new hResizing: #spaceFill; backgroundColor: Color white; beAllFont: font; contentsAsIs: string.
					row addMorphBack: (textMorph imageForm asMorph).

					info := self postscriptFontInfoForFont: font.
					string2 := String streamContents: [ :stream |
						stream nextPutAll: info first; space; print: (font pixelSize * info second) rounded.
					].
					textMorph := TextMorph new hResizing: #spaceFill; backgroundColor: Color white; beAllFont: font; contentsAsIs: string2.
					row addMorphBack: textMorph.
					
					morph addMorphBack: row.
				]
			]
		]
	].
	morph bounds: Project current world bounds.
	morph layoutChanged; fullBounds.
	file := (FileDirectory default newFileNamed: 'PSFontSampler.eps').
	Cursor wait showWhile: [ 
		file nextPutAll: (EPSCanvas morphAsPostscript: morph) ].
	^morph
]

{ #category : #'font mapping' }
PostscriptCanvas class >> fontsForAccuAt [

	| d |

	"Bold = 1, Ital = 2, Under = 4, Narrow = 8, Struckout = 16"
	d := Dictionary new.
	d
		at: 0 put: #('Helvetica-Bold' 1.0);
		at: 1 put: #('Helvetica-Bold' 1.0);
		at: 2 put: #('Helvetica-BoldOblique' 1.0);
		at: 3 put: #('Helvetica-BoldOblique' 1.0).
	^d
]

{ #category : #'font mapping' }
PostscriptCanvas class >> fontsForComicBold [

	| d |

	"Bold = 1, Ital = 2, Under = 4, Narrow = 8, Struckout = 16"
	d := Dictionary new.
	d
		at: 0 put: #('Helvetica-Narrow-Bold' 0.9);
		at: 1 put: #('Helvetica-Narrow-Bold' 0.9);
		at: 2 put: #('Helvetica-Narrow-BoldOblique' 0.9);
		at: 3 put: #('Helvetica-Narrow-BoldOblique' 0.9).
	^d
]

{ #category : #'font mapping' }
PostscriptCanvas class >> fontsForComicPlain [

	| d |

	"Bold = 1, Ital = 2, Under = 4, Narrow = 8, Struckout = 16"

"how do we do underlined??"

	d := Dictionary new.
	d
		at: 0 put: #('Helvetica-Narrow' 0.9);
		at: 1 put: #('Helvetica-Narrow-Bold' 0.9);
		at: 2 put: #('Helvetica-Narrow-Oblique' 0.9);
		at: 3 put: #('Helvetica-Narrow-BoldOblique' 0.9).
	^d

]

{ #category : #'font mapping' }
PostscriptCanvas class >> fontsForDejaVuSans [

	| d |

	"Bold = 1, Ital = 2, Under = 4, Narrow = 8, Struckout = 16"
	d := Dictionary new.
	d
		at: 0 put: #('Helvetica-Bold' 1.0);
		at: 1 put: #('Helvetica-Bold' 1.0);
		at: 2 put: #('Helvetica-Oblique' 1.0);
		at: 3 put: #('Helvetica-BoldOblique' 1.0).
	^d
]

{ #category : #'font mapping' }
PostscriptCanvas class >> fontsForHelvetica [

	| d |

	"Bold = 1, Ital = 2, Under = 4, Narrow = 8, Struckout = 16"
	d := Dictionary new.
	d
		at: 0 put: #('Helvetica' 1.0);
		at: 1 put: #('Helvetica-Bold' 1.0);
		at: 2 put: #('Helvetica-Oblique' 1.0);
		at: 3 put: #('Helvetica-BoldOblique' 1.0);
		at: 8 put: #('Helvetica-Narrow' 1.0);
		at: 9 put: #('Helvetica-Narrow-Bold' 1.0);
		at: 10 put: #('Helvetica-Narrow-Oblique' 1.0);
		at: 11 put: #('Helvetica-Narrow-BoldOblique' 1.0).
	^d
]

{ #category : #'font mapping' }
PostscriptCanvas class >> fontsForNewYork [

	| d |

	"Bold = 1, Ital = 2, Under = 4, Narrow = 8, Struckout = 16"
	d := Dictionary new.
	d
		at: 0 put: #('Times-Roman' 1.0);
		at: 1 put: #('Times-Bold' 1.0);
		at: 2 put: #('Times-Italic' 1.0);
		at: 3 put: #('Times-BoldItalic' 1.0);
		at: 8 put: #('Helvetica-Narrow' 1.0);
		at: 9 put: #('Helvetica-Narrow-Bold' 1.0);
		at: 10 put: #('Helvetica-Narrow-Oblique' 1.0);
		at: 11 put: #('Helvetica-Narrow-BoldOblique' 1.0).
	^d
]

{ #category : #'font mapping' }
PostscriptCanvas class >> fontsForPalatino [

	| d |

	"Bold = 1, Ital = 2, Under = 4, Narrow = 8, Struckout = 16"
	d := Dictionary new.
	d
		at: 0 put: #('Palatino-Roman' 1.0);
		at: 1 put: #('Palatino-Bold' 1.0);
		at: 2 put: #('Palatino-Italic' 1.0);
		at: 3 put: #('Palatino-BoldItalic' 1.0).
	^d

]

{ #category : #'font mapping' }
PostscriptCanvas class >> initializeFontMap [
	"Initialize the dictionary mapping font names to substitutions for Postscript code generation."
	"PostscriptCanvas initializeFontMap"
	| f |
	FontMap := Dictionary new.
	FontMap
		at: 'NewYork' put: (f := self fontsForNewYork);
		at: 'Accuny' put: f;

		at: 'Helvetica' put: (f := self fontsForHelvetica);
		at: 'Accujen' put: f;
				
		at: 'Palatino' put: self fontsForPalatino;
		
		at: 'ComicBold' put: (f := self fontsForComicBold);
		at: 'Accuat' put: self fontsForAccuAt;
		
		at: 'Bitmap DejaVu Sans' put: self fontsForDejaVuSans;
		
		at: 'ComicPlain' put: self fontsForComicPlain
]

{ #category : #drawing }
PostscriptCanvas class >> morphAsPostscript:aMorph [
	^self morphAsPostscript:aMorph rotated:false offsetBy:self baseOffset.

]

{ #category : #drawing }
PostscriptCanvas class >> morphAsPostscript: aMorph rotated: rotateFlag [

	^ self morphAsPostscript: aMorph rotated: rotateFlag offsetBy: self baseOffset.

]

{ #category : #drawing }
PostscriptCanvas class >> morphAsPostscript:aMorph rotated:rotateFlag offsetBy:offset [
 | psCanvas |
  psCanvas := self new.
  psCanvas reset.
  psCanvas bounds: (0@0 extent: (aMorph bounds extent + (2 * offset))).
  psCanvas topLevelMorph:aMorph.
  psCanvas resetContentRotated: rotateFlag.
  psCanvas fullDrawMorph: aMorph .
  ^psCanvas contents.

]

{ #category : #'font mapping' }
PostscriptCanvas class >> postscriptFontInfoForFont: font [

	| decoded decodedName keys match fontName |

	fontName := font textStyleName asString.
	decoded := TextStyle decodeStyleName: fontName.
	decodedName := decoded second.
	keys := self fontMap keys asArray sort: [ :a :b | a size > b size ].
	match := keys select: [ :k | decoded first = k or: [ fontName = k ] ].
	match do: [ :key | | subD desired mask |
		subD := self fontMap at: key.
		desired := font emphasis.
		mask := 31.
		[
			desired := desired bitAnd: mask.
			subD at: desired ifPresent: [ :answer | ^answer].
			mask := mask bitShift: -1.
			desired > 0
		] whileTrue.
	].

	"No explicit lookup found; try to convert the style name into the canonical Postscript name.
	This name will probably still be wrong."

	fontName := String streamContents: [ :s |
		s nextPutAll: decodedName.
		decoded third do: [ :nm | s nextPut: $-; nextPutAll: nm ].

		(font emphasis = 0 and: [ (decoded last includes: 0) not ])
			ifTrue: [ s nextPutAll:  '-Regular' ].

		(font emphasis = 1 and: [ (decoded first anyMask: 1) not ])
			ifTrue: [ s nextPutAll:  '-Bold' ].

		(font emphasis = 2 and: [ (decoded first anyMask: 2) not ])
			ifTrue: [ s nextPutAll:  '-Italic' ].

		(font emphasis = 3 and: [ (decoded first anyMask: 3) not ])
			ifTrue: [ s nextPutAll:  '-BoldItalic' ].
	].

	^ {'(', fontName, ') cvn'. 1.0}

]

{ #category : #'font mapping' }
PostscriptCanvas class >> postscriptFontMappingSummary [
	"
	Transcript nextPutAll: 
	PostscriptCanvas postscriptFontMappingSummary
	; endEntry
	"
	| stream |
	stream := WriteStream on: (String new: 1000).
	TextStyle actualTextStyles keysAndValuesDo: [ :styleName :style |
		stream nextPutAll: styleName; cr.
		style fontArray do: [ :baseFont | | info |
			0 to: 3 do: [ :i | | font |
				font := baseFont emphasized: i.
				font emphasis = i ifTrue: [
					stream tab; nextPutAll: font fontNameWithPointSize; tab.
					info := self postscriptFontInfoForFont: font.
					stream nextPutAll: info first; space; print: (font pixelSize * info second) rounded.
					stream cr.
				]
			]
		]
	].
	^stream contents
]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> aaLevel:newLevel [
	"ignore "
]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> asBalloonCanvas [
     ^self.
]

{ #category : #private }
PostscriptCanvas >> bounds:newBounds [
	psBounds := newBounds.

]

{ #category : #testing }
PostscriptCanvas >> canBlendAlpha [
	^false
]

{ #category : #private }
PostscriptCanvas >> clip [	
	^target clip.

]

{ #category : #'drawing-support' }
PostscriptCanvas >> clipBy: aRectangle during: aBlock [
	^self translateBy: 0@0 clippingTo: aRectangle during: aBlock.

]

{ #category : #accessing }
PostscriptCanvas >> clipRect [
	^clipRect.

]

{ #category : #private }
PostscriptCanvas >> closepath [
	^target closepath.


              
]

{ #category : #private }
PostscriptCanvas >> comment:aString [
	target comment:aString.

]

{ #category : #private }
PostscriptCanvas >> comment: aString with: anObject [ 
	target comment:aString with:anObject.
	
]

{ #category : #accessing }
PostscriptCanvas >> contentsOfArea: aRectangle into: aForm [
	"not supported for PS canvas"

]

{ #category : #private }
PostscriptCanvas >> defaultFont [
	^ TextStyle defaultFont
]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> deferred: ignored [
]

{ #category : #private }
PostscriptCanvas >> defineFont: aFont [

	| psNameFor alreadyRemapped |

	(usedFonts includesKey: aFont) ifFalse:[
		psNameFor := self postscriptFontNameForFont: aFont.
		alreadyRemapped := usedFonts includes: psNameFor.
		usedFonts at: aFont put: psNameFor.
		" here: define as Type-3 unless we think its available "
		" or, just remap"

		" I had some problems if same font remapped twice"
		alreadyRemapped ifFalse: [target remapFontForSqueak: psNameFor].
	].
]

{ #category : #'drawing-support' }
PostscriptCanvas >> definePathProcIn: pathBlock during: duringBlock [ 
	"Bracket the output of pathBlock (which is passed the receiver) in 
	gsave 
		newpath 
			<pathBlock> 
		closepath 
		<duringBlock> 
	grestore 
	"
	^self
		preserveStateDuring: [:tgt | 
			| retval |
			self comment: 'begin pathProc path block'.
			target newpath.
			pathBlock value: tgt.
			target closepath.
			self comment: 'begin pathProc during block'.
			retval := duringBlock value: tgt.
			self comment: 'end pathProc'.
			retval].
]

{ #category : #testing }
PostscriptCanvas >> doesRoundedCorners [ 

	^ false
]

{ #category : #'drawing-general' }
PostscriptCanvas >> draw: anObject [
	^anObject drawPostscriptOn: self
]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> drawGeneralBezierShape: shapeArray color: color borderWidth: borderWidth borderColor: borderColor [ 
	"shapeArray is an array of: 
	arrays of points, each of which must have 
	a multiple of 3 points in it. 
	This method tries to sort the provided triplets so that curves that 
	start and end at the same point are together."
	| groups fillC where triplets |
	fillC := self shadowColor
				ifNil: [color].
	shapeArray isEmpty
		ifTrue: [^ self].
	where := nil.
	groups := OrderedCollection new.
	triplets := OrderedCollection new.
	shapeArray
		do: [:arr | arr
				groupsOf: 3
				atATimeDo: [:bez | 
					| rounded | 
					rounded := bez roundTo: 0.001.
					(where isNil
							or: [where = rounded first])
						ifFalse: [groups addLast: triplets.
							triplets := OrderedCollection new].
					triplets addLast: rounded.
					where := rounded last]].
	groups addLast: triplets.
	triplets := OrderedCollection new.
	"now try to merge stray groups"
	groups copy
		do: [:g1 | | g2 |
			g1 first first = g1 last last
				ifFalse: ["not closed"
					g2 := groups
								detect: [:g | g ~~ g1
										and: [g1 last last = g first first]]
								ifNone: [].
					g2
						ifNotNil: [groups remove: g2.
							groups add: g2 after: g1]]].
	groups
		do: [:g | triplets addAll: g].
	where := nil.
	self
		definePathProcIn: [ :cvs |
			triplets do: [:shape | 
					where ~= shape first
						ifTrue: [where
								ifNotNil: [cvs closepath].
							cvs moveto: shape first].
					where := cvs outlineQuadraticBezierShape: shape]]
		during: [ :cvs |
			cvs clip.
			cvs setLinewidth: borderWidth "*2";
				 fill: fillC andStroke: borderColor]
]

{ #category : #private }
PostscriptCanvas >> drawGradient: fillColor [ 
	self comment: 'not-solid fill ' with: fillColor.
	self comment: ' origin ' with: fillColor origin.
	self comment: ' direction ' with: fillColor direction.
	self fill: fillColor asColor
]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> drawOval: r color: c borderWidth: borderWidth borderColor: borderColor [
	| fillC |
	fillC := self shadowColor ifNil:[c].
	^ self fillOval: r color: fillC borderWidth: borderWidth borderColor: borderColor
	

		

]

{ #category : #private }
PostscriptCanvas >> drawPage:aMorph [
	self fullDrawMorph:aMorph.

]

{ #category : #private }
PostscriptCanvas >> drawPages:collectionOfPages [
	collectionOfPages do:[ :page |
		pages := pages + 1.
		target print:'%%Page: '; write:pages; space; write:pages; cr.
		self drawPage:page.
	].
	morphLevel = 0 ifTrue: [ self writeTrailer: pages ].
]

{ #category : #'drawing-polygons' }
PostscriptCanvas >> drawPolygon: vertices color: aColor borderWidth: bw borderColor: bc [ 
	| fillC |
	fillC := self shadowColor ifNil:[aColor].
	self
		preserveStateDuring: [:pc | pc
			 outlinePolygon: vertices;
				 setLinewidth: bw;
				
				fill: fillC
				andStroke: ((bc isKindOf: Symbol)
						ifTrue: [Color gray]
						ifFalse: [bc])]
]

{ #category : #private }
PostscriptCanvas >> drawPostscriptContext: subCanvas [
	| contents |
	(contents := subCanvas contents) ifNil: [^ self].
	^ target comment: ' sub-canvas start';
		preserveStateDuring: [:inner | inner print: contents];
		comment: ' sub-canvas stop'.	


]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> drawRectangle: r color: color borderWidth: borderWidth borderColor: borderColor [

	| fillC |
	fillC := self shadowColor
				ifNil: [color].
	^ self
		frameAndFillRectangle: r
		fillColor: fillC
		borderWidth: borderWidth
		borderColor: borderColor
]

{ #category : #'drawing-text' }
PostscriptCanvas >> drawString: s from: firstIndex to: lastIndex in: boundsRect font: fontOrNil color: c [ 
	| fillC oldC |
	fillC := self shadowColor
		ifNil: [c].
	self setFont: (fontOrNil
				ifNil: [self defaultFont]).
	self comment: ' text color: ' , c printString.
	oldC := currentColor.
	self setColor: fillC.
	self comment: ' boundsrect origin ' , boundsRect origin printString.
	self comment: '  origin ' , origin printString.
	self moveto: boundsRect origin.
	target print: ' (';
		 print: (s asString copyFrom: firstIndex to: lastIndex) asPostscript;
		 print: ') show';
		 cr.
	self setColor: oldC.
]

{ #category : #'drawing-text' }
PostscriptCanvas >> drawString: s from: firstIndex to: lastIndex in: boundsRect font: fontOrNil color: c background: b [
	target preserveStateDuring: [ :t | self fillRectangle: boundsRect color: b ].
	self drawString: s from: firstIndex to: lastIndex in: boundsRect font: fontOrNil color: c 
]

{ #category : #private }
PostscriptCanvas >> endGStateForMorph: aMorph [ 

	morphLevel = 1
		ifTrue: [ target showpage; print: 'grestore'; cr ]
]

{ #category : #private }
PostscriptCanvas >> fill: fillColor [
	fillColor isSolidFill
		ifTrue: [self paint: fillColor asColor operation: #eofill]
		ifFalse: [self preserveStateDuring: [:inner | inner clip; drawGradient: fillColor]]
]

{ #category : #private }
PostscriptCanvas >> fill: fillColor andStroke: strokeColor [
	self preserveStateDuring: [:inner | inner fill: fillColor];
		stroke: strokeColor.

]

{ #category : #drawing }
PostscriptCanvas >> fillColor:aColor [
	self rect:clipRect; fill:aColor.

]

{ #category : #'drawing-ovals' }
PostscriptCanvas >> fillOval: r color: c borderWidth: borderWidth borderColor: borderColor [ 
	self preserveStateDuring:
		[:inner |
		inner oval: r;
		setLinewidth: borderWidth;
		fill: c andStroke: borderColor].

	

		

]

{ #category : #'drawing-rectangles' }
PostscriptCanvas >> fillRectangle: r color: c [
	self rect:r; fill:c.
]

{ #category : #'drawing-rectangles' }
PostscriptCanvas >> fillRectangle: aRectangle fillStyle: aFillStyle [
	"Fill the given rectangle."
	| pattern |

	(aFillStyle isKindOf: InfiniteForm) ifTrue: [
		^self infiniteFillRectangle: aRectangle fillStyle: aFillStyle
	].

	aFillStyle isSolidFill ifTrue:[^self fillRectangle: aRectangle color: aFillStyle asColor].

	"We have a very special case for filling with infinite forms"
	(aFillStyle isBitmapFill and:[aFillStyle origin = (0@0)]) ifTrue:[
		pattern := aFillStyle form.
		(aFillStyle direction = (pattern width @ 0) 
			and:[aFillStyle normal = (0@pattern height)]) ifTrue:[
				"Can use an InfiniteForm"
				^self fillRectangle: aRectangle color: (InfiniteForm with: pattern)].
	].

	"Use a BalloonCanvas instead PROBABLY won't work here"
	"self balloonFillRectangle: aRectangle fillStyle: aFillStyle."

	^self fillRectangle: aRectangle color: aFillStyle asColor
]

{ #category : #'drawing-rectangles' }
PostscriptCanvas >> frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth borderColor: borderColor [ 
	"since postscript strokes on the line and squeak strokes inside, we need 
	to adjust inwards"
	self
		preserveStateDuring: [:pc | pc
				
				rect: (r insetBy: borderWidth / 2);
				 setLinewidth: borderWidth;
				 fill: fillColor andStroke: borderColor]
]

{ #category : #'drawing-rectangles' }
PostscriptCanvas >> frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth topLeftColor: topLeftColor bottomRightColor: bottomRightColor [ 
	self
		preserveStateDuring: [:pc | 
			target newpath.
			pc setLinewidth: 0.
			pc outlinePolygon: {r origin. r topRight. r topRight + (borderWidth negated @ borderWidth). r origin + (borderWidth @ borderWidth). r bottomLeft + (borderWidth @ borderWidth negated). r bottomLeft. r origin};
				 fill: topLeftColor andStroke: topLeftColor.
			target newpath.
			pc outlinePolygon: {r topRight. r bottomRight. r bottomLeft. r bottomLeft + (borderWidth @ borderWidth negated). r bottomRight - (borderWidth @ borderWidth). r topRight + (borderWidth negated @ borderWidth). r topRight};
				 fill: bottomRightColor andStroke: bottomRightColor]
]

{ #category : #'drawing-rectangles' }
PostscriptCanvas >> frameRectangle: r width: w color: c [ 
	self rect:r; stroke:c.


]

{ #category : #'drawing-general' }
PostscriptCanvas >> fullDraw: aMorph [ 
	self comment: 'start morph: ' with: aMorph.
	self comment: 'level: ' with: morphLevel.
	self comment: 'bounds: ' with: aMorph bounds.
	self comment: 'corner: ' with: aMorph bounds corner.
	morphLevel := morphLevel + 1.
	self setupGStateForMorph: aMorph.
	aMorph fullDrawPostscriptOn: self.
	self endGStateForMorph: aMorph.
	morphLevel := morphLevel - 1.
	self comment: 'end morph: ' with: aMorph.
	self comment: 'level: ' with: morphLevel.

]

{ #category : #'drawing-general' }
PostscriptCanvas >> fullDrawBookMorph:aBookMorph [
	^aBookMorph fullDrawOn:self.

]

{ #category : #private }
PostscriptCanvas >> image: form at: aPoint sourceRect: sourceRect rule: rule [ 
	| aForm |
	self preserveStateDuring:
		[:inner | inner translate: aPoint + self origin.
		aForm := form depth <= 8 ifTrue: [form asFormOfDepth: 32] ifFalse: [form].
		target write: ((aForm colorsUsed includes: Color transparent)
			ifTrue: [| top f2 c2 offset |
				"tfel: This was taken from SketchMorph, but is actually needed for all 
				forms that use transparency"
				offset := currentTransformation ifNil: [0@0] ifNotNilDo: [:t | t offset].
				top := self topLevelMorph.
				f2 := Form extent: aForm extent depth: self depth.
				c2 := f2 getCanvas.
				c2 fillColor: Color white.
				c2
					translateBy: offset - self origin - aPoint
					clippingTo: f2 boundingBox
					during: [:c | top fullDrawOn: c].
				f2]
			ifFalse: [aForm])].

]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> infiniteFillRectangle: aRectangle fillStyle: aFillStyle [

	self flag: #bob.		"need to fix this"

	"^aFillStyle 
		displayOnPort: (port clippedBy: aRectangle) 
		at: aRectangle origin - origin"

]

{ #category : #testing }
PostscriptCanvas >> isPostscriptCanvas [
	^true
]

{ #category : #accessing }
PostscriptCanvas >> isShadowDrawing [
	^shadowColor notNil
]

{ #category : #drawing }
PostscriptCanvas >> line: pt1 to: pt2 brushForm: brush [ 
	" to do: set brushform "
	self moveto:pt1; lineto:pt2; stroke:currentColor.
 

]

{ #category : #drawing }
PostscriptCanvas >> line: pt1 to: pt2 width: w color: c [ 
	self setLinewidth:w; moveto:pt1; lineto:pt2; stroke:c. 	

]

{ #category : #private }
PostscriptCanvas >> lineto:aPoint [
	^target lineto:aPoint.


              
]

{ #category : #private }
PostscriptCanvas >> moveto:aPoint [
	^target moveto:aPoint.


              
]

{ #category : #accessing }
PostscriptCanvas >> origin [
	^origin.

]

{ #category : #private }
PostscriptCanvas >> outlinePolygon: vertices [ 
	target moveto: (vertices first).
	2 to: vertices size do: [:i | target lineto: (vertices at: i)].
	target closepath
]

{ #category : #private }
PostscriptCanvas >> outlineQuadraticBezierShape: vertices [ 
	| where |
	3
		to: vertices size
		by: 3
		do: [:i | 
			| v1 v2 v3 | 
			v1 := (vertices at: i - 2) roundTo: 0.001.
			v2 := (vertices at: i - 1) roundTo: 0.001.
			v3 := (vertices at: i) roundTo: 0.001.
			(v1 = v2
					or: [v2 = v3])
				ifTrue: [target lineto: v3]
				ifFalse: [target
						curvetoQuadratic: v3
						from: v1
						via: v2].
			where := v3].
	^where
]

{ #category : #private }
PostscriptCanvas >> oval:aPoint [
	^target oval:aPoint.
]

{ #category : #private }
PostscriptCanvas >> paint:color operation:operation [
	self setColor:color.
	currentColor isTransparent ifFalse:[target perform:operation] ifTrue:[target newpath].

              
]

{ #category : #drawing }
PostscriptCanvas >> paragraph: para bounds: bounds color: c [ 
	| displayablePara |
	self comment:'paragraph with bounds: ' with:bounds.
	displayablePara := para asParagraphForPostscript.
	self preserveStateDuring:
		[:inner |
		displayablePara displayOn: inner
			using: (PostscriptCharacterScanner
					scannerWithCanvas: self paragraph: displayablePara bounds: bounds)
			at: bounds topLeft]

]

{ #category : #private }
PostscriptCanvas >> postscriptFontNameForFont: font [

	^(self class postscriptFontInfoForFont: font) first

]

{ #category : #'drawing-support' }
PostscriptCanvas >> preserveStateDuring: aBlock [
	^target preserveStateDuring: [ :innerTarget |
		| retval saveClip saveTransform |
		saveClip := clipRect.
		saveTransform := currentTransformation.
		gstateStack addLast: currentFont.
		gstateStack addLast: currentColor.
		gstateStack addLast: shadowColor.
		retval := aBlock value: self.
		shadowColor := gstateStack removeLast.
		currentColor := gstateStack removeLast.
		currentFont := gstateStack removeLast.
		clipRect := saveClip.
		currentTransformation := saveTransform.
		retval
	].
]

{ #category : #private }
PostscriptCanvas >> printContentsOn: aStream [ 
	^ aStream nextPutAll: target contents
]

{ #category : #private }
PostscriptCanvas >> psSize [
	^ target size
]

{ #category : #private }
PostscriptCanvas >> rect:aRect [
	^target rect:aRect.

]

{ #category : #initialization }
PostscriptCanvas >> reset [
	super reset.
	origin := 0 @ 0.				"origin of the top-left corner of this canvas"
	clipRect := 0 @ 0 corner: 10000 @ 10000.		"default clipping rectangle"
	currentTransformation := nil.
	morphLevel := 0.
	pages := 0.
	gstateStack := OrderedCollection new.
	usedFonts := Dictionary new.
	initialScale := 1.0.
	shadowColor := nil.
	currentColor := nil
]

{ #category : #private }
PostscriptCanvas >> resetContentRotated: rotateFlag [
	target := self class defaultTarget.
	self writeHeaderRotated: rotateFlag.
     ^self.
]

{ #category : #private }
PostscriptCanvas >> setColor: color [ 
	(color notNil and: [ currentColor ~= color ]) ifTrue:
		[ target write: color asColor.
		currentColor := color ]
]

{ #category : #private }
PostscriptCanvas >> setFont:aFont [

	| fInfo |

	aFont = currentFont ifTrue: [^self].
	currentFont := aFont.
	self defineFont: aFont.
	fInfo := self class postscriptFontInfoForFont: aFont.

	target 
		selectflippedfont: fInfo first
		size: (aFont pixelSize * fInfo second)
		ascent: aFont ascent.

]

{ #category : #private }
PostscriptCanvas >> setLinewidth: width [ 
	target setLinewidth: width.

]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> setOrigin: aPoint clipRect: aRectangle [
	self comment:'new origin: ' with:aPoint.
	target rectclip:aRectangle.
	self translate:aPoint - origin.

"	self grestore; gsave.

	self write:aRectangle.
	target print:' textclip'; cr.
	target print:'% new offset '.
	target write:aPoint.
	target cr.
"	super setOrigin: aPoint clipRect: aRectangle.

]

{ #category : #private }
PostscriptCanvas >> setupGStateForMorph: aMorph [ 

	morphLevel = 1
		ifTrue: [self writePageSetupFor: aMorph]
]

{ #category : #accessing }
PostscriptCanvas >> shadowColor [
	^shadowColor
]

{ #category : #accessing }
PostscriptCanvas >> shadowColor: aColor [
	shadowColor := aColor.
]

{ #category : #'drawing-images' }
PostscriptCanvas >> stencil: stencilForm at: aPoint color: aColor [
	target comment:' imagemask'.

]

{ #category : #private }
PostscriptCanvas >> stroke: strokeColor [ 
	strokeColor ifNil: [^self].
	(strokeColor isKindOf: Symbol) 
		ifTrue: [^self paint: Color gray operation: #stroke	"punt"].
	strokeColor isSolidFill 
		ifTrue: [^self paint: strokeColor asColor operation: #stroke].
	self preserveStateDuring: 
			[:inner | 
			inner
				strokepath;
				fill: strokeColor]
]

{ #category : #private }
PostscriptCanvas >> strokepath [
	^target strokepath.


              
]

{ #category : #private }
PostscriptCanvas >> text: s at:point font: fontOrNil color: c justified:justify parwidth:parwidth [

	self flag: #bob.		"deprecated in favor of #textStyled......."







	self setFont:(fontOrNil ifNil:[self defaultFont]).
	self comment:' text color: ',c printString.
	self setColor:c.
	self comment:'  origin ',  origin printString.
     self moveto: point.
	target print:' (';
     	 print:s asPostscript; print:') '.
		justify ifTrue:[
			target write:parwidth; print:' jshow'; cr.
		] ifFalse:[
			target print:'show'.
		].
		target cr.

]

{ #category : #private }
PostscriptCanvas >> text: s at: point font: fontOrNil color: c spacePad: pad [ 
	| fillC oldC |
	fillC := self shadowColor
				ifNil: [c].
	self
		setFont: (fontOrNil
				ifNil: [self defaultFont]).
	self comment: ' text color: ' , c printString.
	oldC := currentColor.
	self setColor: fillC.
	self comment: '  origin ' , origin printString.
	self moveto: point.
	target write: pad;
		 print: ' 0 32 (';
		 print: s asPostscript;
		 print: ') widthshow';
		 cr.
	self setColor: oldC.
]

{ #category : #private }
PostscriptCanvas >> textStyled: s at: ignored0 font: ignored1 color: c justified: justify parwidth: parwidth [ 
	| fillC oldC |
	fillC := c.
	self shadowColor
		ifNotNil: [:sc | 
			self comment: ' shadow color: ' , sc printString.
			fillC := sc].
	self comment: ' text color: ' , c printString.
	oldC := currentColor.
	self setColor: fillC.
	self comment: '  origin ' , origin printString.
	"self moveto: point."
	"now done by sender"
	target print: ' (';
		 print: s asPostscript;
		 print: ') '.
	justify
		ifTrue: [target write: parwidth;
				 print: ' jshow';
				 cr]
		ifFalse: [target print: 'show'].
	target cr.
	self setColor: oldC.
]

{ #category : #private }
PostscriptCanvas >> topLevelMorph [
	^topLevelMorph

]

{ #category : #private }
PostscriptCanvas >> topLevelMorph:newMorph [
	topLevelMorph := newMorph.

]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> transformBy:aMatrix [
	("aMatrix isPureTranslation" false) ifTrue:[
		target translate:aMatrix offset negated.
	] ifFalse:[
		target  concat:aMatrix.
	].
	^self.

]

{ #category : #'drawing-support' }
PostscriptCanvas >> transformBy: aDisplayTransform clippingTo: aClipRect during: aBlock smoothing: cellSize [ 
	| retval oldShadow |
	oldShadow := shadowColor.
	self comment: 'drawing clipped ' with: aClipRect.
	self comment: 'drawing transformed ' with: aDisplayTransform.
	retval := self
		preserveStateDuring: [:inner | 
			currentTransformation
				ifNil: [currentTransformation := aDisplayTransform]
				ifNotNil: [currentTransformation := currentTransformation composedWithLocal: aDisplayTransform].
			aClipRect
				ifNotNil: [clipRect := aDisplayTransform
								globalBoundsToLocal: (clipRect intersect: aClipRect).
					inner rect: aClipRect;
						 clip].
			inner transformBy: aDisplayTransform.
			aBlock value: inner].
	self comment: 'end of drawing clipped ' with: aClipRect.
	shadowColor := oldShadow.
	^ retval
]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> transformBy:aTransform during:aBlock [
	^self transformBy:aTransform clippingTo: nil during:aBlock
]

{ #category : #private }
PostscriptCanvas >> translate:aPoint [
	^target translate:aPoint.


              
]

{ #category : #other }
PostscriptCanvas >> translateBy: delta clippingTo: aRect during: aBlock [
	self comment:'translateBy: ' with:delta.
	^self transformBy:(MatrixTransform2x3 withOffset:delta) clippingTo:aRect during:aBlock.


]

{ #category : #'drawing-support' }
PostscriptCanvas >> translateBy: delta during: aBlock [
	"Set a translation only during the execution of aBlock."

	| result oldShadow |
	oldShadow := shadowColor.
	self translate: delta.
	result := aBlock value: self.
	self translate: delta negated.
	shadowColor := oldShadow.
	^ result

]

{ #category : #'balloon compatibility' }
PostscriptCanvas >> warpFrom: sourceQuad toRect: innerRect [
	"^PostscriptDummyWarp canvas:self."
]

{ #category : #private }
PostscriptCanvas >> writeGlobalSetup: rotateFlag [ 
	target print: '%%EndProlog';
		 cr.
	target print: '%%BeginSetup';
		 cr.
	target print: '% initialScale: ';
		 write: initialScale;
		 cr.
	target print: '% pageBBox: '; write: self pageBBox; cr.
	
	target print: '% pageOffset';
		 cr.
	target translate: self pageOffset.
	rotateFlag
		ifTrue: ["no translate needed for 0,0 = upper LH corner of page"
			target print: '90 rotate';
				 cr;
				 print: '0 0 translate';
				 cr]
		ifFalse: [target write: 0 @ topLevelMorph height * initialScale;
				 print: ' translate';
				 cr].
	target print: '% flip';
		 cr.
	target scale: initialScale @ initialScale negated;
		 print: ' [ {true setstrokeadjust} stopped ] pop';
		 cr.
	target print: '%%EndSetup';
		 cr
]

{ #category : #private }
PostscriptCanvas >> writeHeaderRotated: rotateFlag [ 
	self writePSIdentifierRotated: rotateFlag.
	self writeProcset.
	self writeGlobalSetup: rotateFlag.
]

{ #category : #private }
PostscriptCanvas >> writePSIdentifierRotated: rotateFlag [
	"NB: rotation not yet supported"

	target print:'%!'; cr.
]

{ #category : #private }
PostscriptCanvas >> writePageSetupFor: aMorph [ 

	target print: '%%BeginPageSetup'; cr.
	target print: 'gsave'; cr.
	target translate: aMorph bounds origin negated.
	target print: '%%EndPageSetup';
		 cr
]

{ #category : #private }
PostscriptCanvas >> writeProcset [
	target print:'

%%BeginProcset: Squeak-Level2-Emulation
/level1 /languagelevel where { 
	pop  languagelevel 2 lt
} {true } ifelse def
level1
{
	/rectclip {
		4 2 roll moveto
		1 index 0 rlineto
		 0 exch rlineto
		neg 0 rlineto closepath
		clip newpath
	} bind def
	/setcolorspace { pop } bind def
	/makeDict {
		counttomark 2 idiv dup dict begin
		{  def } repeat
		currentdict end exch pop
	} bind def
	/defaultDict [ /MultipleDataSources  false makeDict def
	/image {
		dup type /dicttype eq {
			defaultDict begin
			begin
				Width
				Height
				BitsPerComponent
				ImageMatrix 
				/DataSource load MultipleDataSources { aload pop } if				MultipleDataSources
				Decode length 2 idiv
			end
			end
		} if
		colorimage 
		currentfile ( ) readstring pop pop
	} bind def

	/_imagemask /imagemask load def
	/imagemask {
		dup type /dicttype eq {
			begin
				Width
				Height
				Decode 0 get 1 eq
				ImageMatrix
				/DataSource load
			end
		} if
		_imagemask 
		currentfile ( ) readstring pop pop
	} bind def
	/transparentimage {
		pop image
	} bind def

} {
	/makeDict { >> } bind def
	/transparentimage {
	  gsave
	  32 dict begin
	  /tinteger exch def
	  /transparent 1 string def
	  transparent 0 tinteger put
	  /olddict exch def
	  olddict /DataSource get dup type /filetype ne {
	    olddict /DataSource 3 -1 roll 0 () /SubFileDecode filter put
	  } {
	    pop
	  } ifelse
	  /newdict olddict maxlength dict def
	  olddict newdict copy pop
	  /w newdict /Width get def
	  /str w string def
	  /substrlen 2 w log 2 log div floor exp cvi def
	  /substrs [
	  {
	     substrlen string
	     0 1 substrlen 1 sub {
	       1 index exch tinteger put
	     } for
	     /substrlen substrlen 2 idiv def
	     substrlen 0 eq {exit} if
	  } loop
	  ] def
	  /h newdict /Height get def
	  1 w div 1 h div matrix scale
	  olddict /ImageMatrix get exch matrix concatmatrix
	  matrix invertmatrix concat
	  newdict /Height 1 put
	  newdict /DataSource str put
	  /mat [w 0 0 h 0 0] def
	  newdict /ImageMatrix mat put
	  0 1 h 1 sub {
	    mat 5 3 -1 roll neg put
	    olddict /DataSource get str readstring pop pop
	    /tail str def
	    /x 0 def
	    {
	      tail transparent search dup /done exch not def
	      {exch pop exch pop} if
	      /w1 1 index length def
	      w1 0 ne {
	        newdict /DataSource 3 -1 roll put
	        newdict /Width w1 put
	        mat 4 x neg put
	        /x x w1 add def
	        newdict image
	        /tail tail w1 tail length w1 sub getinterval def
	      } if
	      done {exit} if
	      tail substrs {
	        anchorsearch {pop} if
	      } forall
	      /tail exch def
	      tail length 0 eq {exit} if
	      /x w tail length sub def
	    } loop
	  } for
	  end
	  grestore
	} bind def
} ifelse

%%EndProcset
%%BeginProcset: Squeak-Printing
/_showpageSqueak /showpage load def
/showpage { gsave _showpageSqueak grestore } bind def
/countspaces {
	[ exch { dup 32 ne { pop } if  } forall ] length 
} bind def
/jshow { 
	10 dict begin
	/width exch def
	/str exch def
	str length 0 gt {
		str dup length 1 sub get 32 eq { /str str dup length 1 sub 0 exch getinterval def } if
		/strw str stringwidth pop def
		/diffwidth width strw sub def
		/numspaces str countspaces def
		numspaces 0 eq { /numspaces 1 def } if
		/adjspace width strw sub numspaces div def
		/adjchar 0 def
		diffwidth 0 lt {
			/adjspace adjspace 0.2 mul def
			/adjchar diffwidth str length div 0.8 mul def
		} if
		adjspace 0 32 adjchar 0 str awidthshow

	} if
	end
} bind def

/copydict {
	dup length dict begin 
		 { 1 index /FID eq 2 index /UniqueID eq and {pop pop} {  def  } ifelse } forall
	currentdict end
} bind def
/getSymbolcharproc {
	1 dict begin 
		/charstring exch def 
	 [ 550 0 0 0 650 600 /setcachedevice cvx 50 100 /translate cvx  /pop cvx 
		1 dict begin /setbbox { pop pop pop } bind def currentdict end /begin cvx   

		gsave  /Symbol 600 selectfont 0 0 moveto charstring false charpath false upath grestore

	 /exec cvx /fill cvx /end cvx ] cvx bind 
	end
} bind def
/adjustFontForSqueak		% converts _ to left-arrow, ^to upArrow and tab -> 4 spaces
{ 
	gsave dup 1000 selectfont
	dup dup findfont copydict
	begin
	CharStrings 
	/CharStrings exch copydict
	dup /leftarrow (\254) getSymbolcharproc  put
	dup /uparrow (\255) getSymbolcharproc  put
	dup /tab [ /pop cvx ( ) stringwidth pop 6 mul 0 0 0 0 0  /setcachedevice cvx ] cvx bind  put
	def
	/Encoding Encoding dup length array copy 
	dup 94 /uparrow put
	dup 95 /leftarrow put
	dup 9 /tab put
	def
	currentdict end definefont pop pop
	grestore
} bind def

%%EndProcset
'.

]

{ #category : #'morph drawing' }
PostscriptCanvas >> writeTrailer: somePages [ 
	target
		print: '%%Trailer';
		cr.
	usedFonts isEmpty 
		ifFalse: 
			[target print: '%%DocumentFonts:'.
			usedFonts values asSet do: 
					[:f | 
					target
						space;
						print: f].
			target cr].
	target print:'%%Pages: '; write: somePages; cr.
	target
		print: '%%EOF';
		cr
]
