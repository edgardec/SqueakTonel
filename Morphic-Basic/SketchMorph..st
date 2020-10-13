"
The morph that results when the user draws a color bitmap using the PaintBox (SketchEditorMorph and PaintBoxMorph).  

forwardDirection is the angle at which the object will go forward.  When the rotationStyle is not #normal, then forwardDirection is any angle, while the rotation is highly restricted.  If flexed, this is remembered by the Transform morph.  For non-normal rotationStyle, it is rotationDegrees.

setupAngle (a property) is where the user put the green arrow to indicate which direction on the picture is forward.  When #normal, draw the morph initially at (0.0 - setupAngle).  The enclosing TransformationMorph then rotates it to the true angle.
 
rotationDegrees  In a #normal object, rotationDegrees is constant an equal to setupAngle.
	For non-normal, it is the direction the object is going.

When repainting, set it back to its original state. The green arrow is set to setupAngle, and the sketch is shown as drawn originally (rotationDegrees = 0). 

rotationStyle = normal (turns), leftRight, upDown, fixed.  
When leftRight upDown or fixed, bit map has severe restrictions.

"
Class {
	#name : #SketchMorph,
	#superclass : #Morph,
	#instVars : [
		'originalForm',
		'rotationStyle',
		'scalePoint',
		'framesToDwell',
		'rotatedForm',
		'keepAspectRatio'
	],
	#category : #'Morphic-Basic'
}

{ #category : #scripting }
SketchMorph class >> defaultNameStemForInstances [
	^ 'Sketch' translatedNoop
]

{ #category : #'instance creation' }
SketchMorph class >> fromFile: aFileName [
	^self fromStream: (FileStream readOnlyFileNamed: aFileName)
]

{ #category : #'instance creation' }
SketchMorph class >> fromStream: aStream [
	^self withForm: (ImageReadWriter formFromStream: aStream)
]

{ #category : #'new-morph participation' }
SketchMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #testing }
SketchMorph class >> isSketchMorphClass [
	^true
]

{ #category : #'instance creation' }
SketchMorph class >> openEditor [
	"Create a new SketchMorph and open a SketchMorphEditor on it. 
	Answers the painted SketchMorph."
	"SketchMorph openEditor"
	| newSketch |
	newSketch := (self
				withForm: (Form extent: 100 @ 100 depth: Display depth)) center: self currentWorld center;
				 openInWorld;
				 editDrawing.
	^ newSketch
]

{ #category : #'instance creation' }
SketchMorph class >> withForm: aForm [
	"Note: 'SketchMorph withForm: zz' is MUCH faster
	than 'SketchMorph new form: zz'."

	^ self basicNew initializeWith: aForm
]

{ #category : #menu }
SketchMorph >> addBorderToShape: evt [
	| str borderWidth borderedForm r |
	str := UIManager default
		request: 'Please enter the desired border width' translated
		initialAnswer: '0'.
	borderWidth := Integer readFrom: (ReadStream on: str).
	(borderWidth between: 1 and: 10) ifFalse: [^ self].

	"Take care of growing appropriately.  Does this lose the reg point?"
	borderedForm := originalForm shapeBorder: Color black width: borderWidth.
	r := borderedForm rectangleEnclosingPixelsNotOfColor: Color transparent.
	self form: (borderedForm copy: r).

]

{ #category : #menu }
SketchMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add custom menu items"

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'restore base graphic' translated target: self action: #restoreBaseGraphicFromMenu.
	aCustomMenu add: 'call this my base graphic' translated target: self action: #callThisBaseGraphic.
	aCustomMenu add: 'choose new graphic...' translated target: self action: #chooseNewGraphic.
	aCustomMenu addLine.
	aCustomMenu add: 'set as background' translated target: rotatedForm action: #setAsBackground.
	self addPaintingItemsTo: aCustomMenu hand: aHandMorph
]

{ #category : #menus }
SketchMorph >> addFillStyleMenuItems: aMenu hand: aHand [
	"Do nothing here - we do not allow changing the fill style of a SketchMorph yet."
]

{ #category : #menus }
SketchMorph >> addToggleItemsToHaloMenu: aCustomMenu [ 
	"Add toggle-items to the halo menu"
	super addToggleItemsToHaloMenu: aCustomMenu.
	Preferences noviceMode
		ifFalse: [""aCustomMenu
				addUpdating: #useInterpolationString
				target: self
				action: #toggleInterpolation]
]

{ #category : #'e-toy support' }
SketchMorph >> baseGraphic [
	"Answer my base graphic"

	^ self valueOfProperty: #baseGraphic ifAbsent:
		[self setProperty: #baseGraphic toValue: originalForm.
		^ originalForm]
]

{ #category : #'e-toy support' }
SketchMorph >> baseGraphic: aForm [
	"Remember the given form as the receiver's base graphic"

	^ self setProperty: #baseGraphic toValue: aForm
]

{ #category : #menu }
SketchMorph >> blur [

	Cursor wait showWhile:[^(SketchMorph withForm: (self form approxGaussianBlur))  openInHand]
]

{ #category : #menu }
SketchMorph >> callThisBaseGraphic [
	"Set my baseGraphic to be the current form"

	| aGraphic |
	self isInWorld ifFalse: [^ self inform: 

'oops, this menu is a for a morph that
has been replaced, probably because a
"look like" script was run.  Please dismiss
the menu and get a new one!.  Sorry!' translated].

	((aGraphic := self valueOfProperty: #baseGraphic)
				notNil and: [aGraphic ~= originalForm])
		ifTrue:
			[self setProperty: #baseGraphic toValue: originalForm]
		ifFalse:
			[self inform: 'this already *was* your baseGraphic' translated]
]

{ #category : #drawing }
SketchMorph >> canBeEnlargedWithB3D [
	^self 
		valueOfProperty: #canBeEnlargedWithB3D
		ifAbsent: [
			| answer |
			answer := self rotatedForm colorsUsed allSatisfy: [ :c | c isTranslucent not].
			self setProperty: #canBeEnlargedWithB3D toValue: answer.
			answer
		]
]

{ #category : #menus }
SketchMorph >> changePixelsOfColor: c toColor: newColor [

	| r |
	originalForm mapColor: c to: newColor.
	r := originalForm rectangleEnclosingPixelsNotOfColor: Color transparent.
	self form: (originalForm copy: r).


]

{ #category : #'pen support' }
SketchMorph >> clearExtent: aPoint fillColor: aColor [
	"Make this sketch have the given pixel dimensions and fill it with given color. Its previous contents are replaced."

	self form:
		((Form extent: aPoint depth: Display depth) fillColor: aColor).

]

{ #category : #menus }
SketchMorph >> collapse [
	"Replace the receiver with a collapsed rendition of itself."

	| w collapsedVersion a ht |
	
	(w := self world) ifNil: [^ self].
	collapsedVersion := (self imageForm scaledToSize: 50@50) asMorph.
	collapsedVersion setProperty: #uncollapsedMorph toValue: self.
	collapsedVersion on: #mouseUp send: #uncollapseSketch to: collapsedVersion.
	
	collapsedVersion setBalloonText: ('A collapsed version of {1}.  Click to open it back up.' translated format: {self externalName}).
	
	self delete.
	w addMorphFront: (
		a := AlignmentMorph newRow
			hResizing: #shrinkWrap;
			vResizing: #shrinkWrap;
			borderWidth: 4;
			borderColor: Color white;
			addMorph: collapsedVersion;
			yourself).
	a setNameTo: self externalName.
	ht := (Smalltalk at: #SugarNavTab ifPresent: [:c | Project current world findA: c])
		ifNotNil: [:tab | tab height]
		ifNil: [80].
	a position: 0@ht.

	collapsedVersion setProperty: #collapsedMorphCarrier toValue: a.

	(self valueOfProperty: #collapsedPosition) ifNotNil: [:priorPosition |
		a position: priorPosition].
]

{ #category : #'geometry testing' }
SketchMorph >> containsPoint: aPoint [

	^ (self bounds containsPoint: aPoint) and:
	  [(self rotatedForm isTransparentAt: aPoint - bounds origin) not]

]

{ #category : #'objects from disk' }
SketchMorph >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	scalePoint ifNil: [scalePoint := 1.0@1.0].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #drawing }
SketchMorph >> drawHighResolutionOn: aCanvas in: aRectangle [

	| r finalClipRect scale sourceOrigin sourceExtent sourceRect biggerSource biggerDestExtent interForm offsetInBigger |

	r := aRectangle translateBy: aCanvas origin.
	finalClipRect := r intersect: (aCanvas clipRect translateBy: aCanvas origin).
	self canBeEnlargedWithB3D ifTrue: [
		(WarpBlt toForm: aCanvas form)
			clipRect: finalClipRect;
			sourceForm: originalForm;
			cellSize: 2;  "installs a colormap"
			combinationRule: Form paint;

			copyQuad: originalForm boundingBox innerCorners 
			toRect: r.
		^self
	].
	scale := aRectangle extent / originalForm extent.
	sourceOrigin := originalForm offset + (aCanvas clipRect origin - aRectangle origin / scale).
	sourceExtent := aCanvas clipRect extent / scale.
	sourceRect := sourceOrigin rounded extent: sourceExtent rounded.
	biggerSource := sourceRect expandBy: 1.
	biggerDestExtent := (biggerSource extent * scale) rounded.
	offsetInBigger := (sourceOrigin - biggerSource origin * scale) rounded.

	interForm := Form extent: biggerDestExtent depth: aCanvas depth.
	(originalForm copy: biggerSource)
		displayInterpolatedIn: interForm boundingBox
		on: interForm.
	aCanvas 
		drawImage: interForm 
		at: aCanvas clipRect origin 
		sourceRect: (offsetInBigger extent: aCanvas clipRect extent).



]

{ #category : #drawing }
SketchMorph >> drawInterpolatedImage: aForm on: aCanvas [
	"Draw the given form onto the canvas using the Balloon 3D engine"
	| engine |
	engine := Smalltalk at: #B3DRenderEngine 
		ifPresent:[:b3d | b3d defaultForPlatformOn: aCanvas form].
	engine == nil ifTrue:[
		self useInterpolation: false.
		^self generateRotatedForm].
	"Setup the engine"
	engine viewport: aCanvas form boundingBox.
	"Install the material to be used (using a plain white emission color)"
	engine material: ((Smalltalk at: #B3DMaterial) new emission: Color white).
	"Install the texture"
	engine texture: aForm.
	"Draw the mesh"
	engine render: ((Smalltalk at: #B3DIndexedQuadMesh) new plainTextureRect).
	"and finish"
	engine finish.
]

{ #category : #drawing }
SketchMorph >> drawOn: aCanvas [
	aCanvas translucentImage: self rotatedForm at: bounds origin

]

{ #category : #menu }
SketchMorph >> edgeDetect [
	
	Cursor wait showWhile:[^(SketchMorph withForm: (self form edgeDetect))  openInHand]
	
]

{ #category : #menu }
SketchMorph >> editDrawing [
	self flag: #deferred.  "Don't allow this if the user is already in paint mode, because it creates a very strange situation."
	"costumee ifNotNil: [self forwardDirection: costumee direction]."  "how say this?"
	self editDrawingIn: self pasteUpMorph forBackground: false

]

{ #category : #menu }
SketchMorph >> editDrawingIn: aPasteUpMorph forBackground: forBackground [
	"Edit an existing sketch."

	| w bnds sketchEditor rotCenter aPaintTab aWorld aPaintBox |
	self world assureNotPaintingElse: [^self].
	w := aPasteUpMorph world.
	w prepareToPaint.
	w displayWorld.
	self visible: false.
	bnds := forBackground 
				ifTrue: [aPasteUpMorph boundsInWorld]
				ifFalse: 
					[bnds := self boundsInWorld expandBy: 60 @ 60.
					(aPasteUpMorph paintingBoundsAround: bnds center) merge: bnds]. 
	sketchEditor := SketchEditorMorph new.
	forBackground 
		ifTrue: [sketchEditor setProperty: #background toValue: true].
	w addMorphFront: sketchEditor.
	sketchEditor 
		initializeFor: self
		inBounds: bnds
		pasteUpMorph: aPasteUpMorph.
	rotCenter := self rotationCenter.

	sketchEditor afterNewPicDo: 
			[:aForm :aRect | | tfx | 
			self visible: true.
			self form: aForm.
			tfx := aPasteUpMorph transformFrom: aPasteUpMorph world.
			self topRendererOrSelf position: (tfx globalPointToLocal: aRect origin).
			self rotationStyle: sketchEditor rotationStyle.
			self forwardDirection: sketchEditor forwardDirection.
			(rotCenter notNil and: [(rotCenter = (0.5 @ 0.5)) not]) ifTrue:
				[self rotationCenter: rotCenter].
			(aPaintTab := (aWorld := self world) paintingFlapTab) 
				ifNotNil: [aPaintTab hideFlap]
				ifNil: [(aPaintBox := aWorld paintBox) ifNotNil: [aPaintBox delete]].
			self presenter drawingJustCompleted: self.

			forBackground ifTrue: [self goBehind	"shouldn't be necessary"]]
		ifNoBits: 
			[ | pal |"If no bits drawn.  Must keep old pic.  Can't have no picture"

			self visible: true.
			aWorld := self currentWorld.
			"sometimes by now I'm no longer in a world myself, but we still need
				 to get ahold of the world so that we can deal with the palette"
			((pal := aPasteUpMorph standardPalette) notNil and: [pal isInWorld]) 
				ifTrue: 
					[(aPaintBox := aWorld paintBox) ifNotNil: [aPaintBox delete].
					pal viewMorph: self]
				ifFalse: 
					[(aPaintTab := (aWorld := self world) paintingFlapTab) 
						ifNotNil: [aPaintTab hideFlap]
						ifNil: [(aPaintBox := aWorld paintBox) ifNotNil: [aPaintBox delete]]]]
]

{ #category : #menu }
SketchMorph >> emboss [
 	
	Cursor wait showWhile:[^(SketchMorph withForm: (self form emboss))  openInHand]
	
]

{ #category : #menu }
SketchMorph >> erasePixelsOfColor: aColor [ 
	"Let the user specifiy a color such that all pixels of that color should be erased; then do the erasure"
	| newBounds |
	originalForm
		mapColor: aColor
		to: Color transparent.
	newBounds := originalForm rectangleEnclosingPixelsNotOfColor: Color transparent.
	self form: (originalForm copy: newBounds)
]

{ #category : #menu }
SketchMorph >> erasePixelsUsing: evt [ 
	"Let the user specifiy a color such that all pixels of that color should be erased; then do the erasure"
	self
		changeColorTarget: self
		selector: #rememberedColor:
		originalColor: nil
		hand: evt hand.
	self rememberedColor "color to erase"
		ifNil: [ ^ self ]
		ifNotNilDo:
			[ : chosenColor | self erasePixelsOfColor: chosenColor ]
]

{ #category : #geometry }
SketchMorph >> extent: newExtent [
	"Change my scale to fit myself into the given extent.
	Avoid extents where X or Y is zero."
	
	newExtent isZero ifTrue: [ ^self ].
	self extent = newExtent ifTrue:[^self].
	self scalePoint: newExtent asFloatPoint / (originalForm extent max: 1@1).
	self layoutChanged.

]

{ #category : #geometry }
SketchMorph >> firstIntersectionWithLineFrom: start to: end [
	| intersections last |
	intersections := self fullBounds extrapolatedIntersectionsWithLineFrom: start to: end.
	intersections size = 1 ifTrue: [ ^intersections anyOne ].
	intersections isEmpty ifTrue: [ ^nil ].
	intersections := intersections sorted: [ :a :b | (start dist: a) < (start dist: b) ].
	last := intersections first rounded.
	last pointsTo: intersections last rounded do: [ :pt |
		(self rotatedForm isTransparentAt: (pt - bounds origin)) ifFalse: [ ^last ].
		last := pt.
	].
	^intersections first rounded
]

{ #category : #'e-toy support' }
SketchMorph >> flipHorizontal [

	|  r |
	r := self rotationCenter.
	self left:  self left - (1.0 - (2 * r x) * self width).
	self form: (self form flipBy: #horizontal centerAt: self form center).
	self rotationCenter: (1 - r x) @ (r y).
]

{ #category : #'e-toy support' }
SketchMorph >> flipVertical [

	|  r |
	r := self rotationCenter.
	self top:  self top - (1.0 - (2 * r y) * self height).
	self form: (self form flipBy: #vertical centerAt: self form center).
	self rotationCenter:  r x @ (1 - r y).
]

{ #category : #accessing }
SketchMorph >> form [

	^ originalForm

]

{ #category : #accessing }
SketchMorph >> form: aForm [
	"Set the receiver's form"

	| oldForm topRenderer |
	oldForm := originalForm.
	(self hasProperty: #baseGraphic) ifFalse: [self setProperty: #baseGraphic toValue: aForm].
	originalForm := aForm.
	self rotationCenter: 0.5@0.5.
	self layoutChanged.
	topRenderer := self topRendererOrSelf.

	oldForm ifNotNil: [topRenderer position: topRenderer position + (oldForm extent - aForm extent // 2)].

]

{ #category : #'geometry eToy' }
SketchMorph >> forwardDirection: degrees [
	"If not rotating normally, update my rotatedForm"
	super forwardDirection: degrees.
	rotationStyle == #normal ifFalse:[self layoutChanged].
]

{ #category : #accessing }
SketchMorph >> framesToDwell [

	^ framesToDwell

]

{ #category : #accessing }
SketchMorph >> framesToDwell: anInteger [

	framesToDwell := anInteger.

]

{ #category : #drawing }
SketchMorph >> generateInterpolatedForm [
	"Draw the given form onto the canvas using the Balloon 3D engine"
	| aCanvas extent |
	extent := (originalForm extent * scalePoint) asIntegerPoint.
	rotatedForm := Form extent: extent asIntegerPoint depth: originalForm depth.
	aCanvas := rotatedForm getCanvas.
	^self drawInterpolatedImage: originalForm on: aCanvas
]

{ #category : #drawing }
SketchMorph >> generateRotatedForm [
	"Compute my rotatedForm and offsetWhenRotated."

	| scalePt smoothPix pair |
	scalePoint ifNil: [scalePoint := 1 @ 1].
	scalePt := scalePoint x abs @ scalePoint y abs.
	rotationStyle == #none ifTrue: [scalePt := 1 @ 1].
	smoothPix := (scalePt x < 1.0 or: [scalePt y < 1.0]) 
		ifTrue: [2]
		ifFalse: [1].
	rotationStyle = #leftRight 
		ifTrue: 
			[self heading asSmallAngleDegrees < 0.0 
				ifTrue: [scalePt := scalePt x negated @ scalePt y]].
	rotationStyle = #upDown 
		ifTrue: 
			[self heading asSmallAngleDegrees abs > 90.0 
				ifTrue: [scalePt := scalePt x @ scalePt y negated]].
	rotatedForm := scalePt = (1 @ 1) 
				ifTrue: [originalForm]
				ifFalse: 
					["ar 11/19/2001: I am uncertain what happens in the case of rotationStyle ~~ normal"

					(rotationStyle == #normal and: [self useInterpolation]) 
						ifTrue: [^self generateInterpolatedForm].
					pair := WarpBlt 
								rotate: originalForm
								degrees: 0
								center: originalForm boundingBox center
								scaleBy: scalePt
								smoothing: smoothPix.
					pair first]
]

{ #category : #'rotate scale and flex' }
SketchMorph >> heading: newHeading [
	"If not rotating normally, change forward direction rather than heading"
	rotationStyle == #normal ifTrue:[^super heading: newHeading].
	self isFlexed
		ifTrue:[self forwardDirection: newHeading - owner rotationDegrees]
		ifFalse:[self forwardDirection: newHeading].
	self layoutChanged
]

{ #category : #initialization }
SketchMorph >> initialize [
"initialize the state of the receiver"
	^ self initializeWith: (ScriptingSystem formAtKey: 'Painting') deepCopy
]

{ #category : #'parts bin' }
SketchMorph >> initializeToStandAlone [
	super initializeToStandAlone.
	self initializeWith: (ScriptingSystem formAtKey: 'Painting') deepCopy


]

{ #category : #initialization }
SketchMorph >> initializeWith: aForm [

	super initialize.
	originalForm := aForm.
	rotationStyle := #normal.		"styles: #normal, #leftRight, #upDown, or #none"
	scalePoint := 1.0@1.0.
	framesToDwell := 1.
	rotatedForm := originalForm.	"cached rotation of originalForm"
	self extent: originalForm extent.

]

{ #category : #menu }
SketchMorph >> insertIntoMovie: evt [

	| movies aTarget |
	movies :=
		(self world rootMorphsAt: evt hand targetPoint)
			select: [:m | ((m isKindOf: MovieMorph) or:
						 [m isSketchMorph]) and: [m ~= self]].
	movies isEmpty ifTrue: [^ self].
	aTarget := movies first.
	(aTarget isSketchMorph) ifTrue: [
		aTarget := aTarget replaceSelfWithMovie].
	aTarget insertFrames: (Array with: self).
	self delete.

]

{ #category : #'halos and balloon help' }
SketchMorph >> isLikelyRecipientForMouseOverHalos [
	^ true
]

{ #category : #accessing }
SketchMorph >> keepAspectRatio [

	^ keepAspectRatio ifNil: [false]
]

{ #category : #accessing }
SketchMorph >> keepAspectRatio: aBoolean [

	keepAspectRatio := aBoolean.
]

{ #category : #layout }
SketchMorph >> layoutChanged [
	"Update rotatedForm and compute new bounds."
	
	| priorBounds |
	fullBounds ifNotNil: [self changed].
	
	priorBounds := bounds.
	
	self flag: #refactor. "mt: Such side-effects in #layoutChanged can have a severe impact on performance. Better not overwrite it but manage the rotatedForm elsewhere and from there call #layoutChanged if bounds change. Also, just overwrite #extent to use the extent of the rotated form."
	self generateRotatedForm.
	bounds := bounds origin extent: rotatedForm extent.
	
	priorBounds ~= bounds
		ifTrue: [super layoutChanged].

	self changed.

]

{ #category : #other }
SketchMorph >> newForm: aForm [
	self originalForm: aForm.
	self layoutChanged
]

{ #category : #accessing }
SketchMorph >> nominalForm: aForm [
	"Ascribe the blank nominal form"

	originalForm := aForm.
	self rotationCenter: 0.5@0.5.
	self layoutChanged

]

{ #category : #accessing }
SketchMorph >> originalForm: aForm [
	originalForm := aForm
]

{ #category : #'pen support' }
SketchMorph >> penOnMyForm [
	"Support for experiments with drawing under program control. To get started, make a new SketchMorph in a morphic world. In an inspector, give it the desired pixel dimensions with clearExtent:fillColor:. Then use this method to get a pen to which you can send normal pen commands. Reveal the resulting drawing with revealPenStrokes."

	^ Pen newOnForm: originalForm

]

{ #category : #menu }
SketchMorph >> recolorPixelsOfColor: originalColor with: newColor [
	"Let the user select a color to be remapped, and then a color to map that color to, then carry it out."
	| d newForm map |
	d := originalForm depth.
	newForm := Form extent: originalForm extent depth: d.
	map := (Color cachedColormapFrom: d to: d) copy.
	map at: (originalColor indexInMap: map) put: (newColor pixelValueForDepth: d).
	newForm copyBits: newForm boundingBox
		from: originalForm at: 0@0
		colorMap: map.
	self form: newForm.

]

{ #category : #menu }
SketchMorph >> recolorPixelsUsing: evt [ 
	"Let the user select a color to be remapped, and then a color to map that color to, then carry it out."
	| originalColor newColor |
	self inform: 'choose the color you want to replace' translated.
	self
		changeColorTarget: self
		selector: #rememberedColor:
		originalColor: nil
		hand: evt hand.
	"color to replace"
	originalColor := self rememberedColor ifNil: [ ^ self ].
	self inform: 'now choose the color you want to replace it with' translated.
	self
		changeColorTarget: self
		selector: #rememberedColor:
		originalColor: originalColor
		hand: evt hand.
	"new color"
	newColor := self rememberedColor ifNil: [ ^ self ].
	self
		recolorPixelsOfColor: originalColor
		with: newColor
]

{ #category : #menu }
SketchMorph >> reduceColorPalette: evt [
	"Let the user ask for a reduced number of colors in this sketch"

	| str nColors |
	str := UIManager default
		request: 'Please enter a number greater than one.
(note: this cannot be undone, so answer zero
to abort if you need to make a backup first)' translated
		initialAnswer: '256'.
	nColors := Integer readFrom: (ReadStream on: str).
	(nColors between: 2 and: 256) ifFalse: [^ self].

	originalForm := originalForm copyWithColorsReducedTo: nColors.
	rotatedForm := nil.
	self changed
]

{ #category : #caching }
SketchMorph >> releaseCachedState [
	"Clear cache of rotated, scaled Form."

	super releaseCachedState.
	rotatedForm := nil.
	originalForm hibernate
]

{ #category : #other }
SketchMorph >> replaceSelfWithMovie [
	"Replace this SketchMorph in its owner with a MovieMorph containing this sketch as its only frame. This allows a SketchMorph to be turned into a MovieMorph by just insering additional frames."

	| o movie |
	self changed.
	o := self owner.
	movie := MovieMorph new position: self referencePosition.
	movie insertFrames: (Array with: self).
	o ifNil: [^ movie].
	o addMorphFront: movie.
	^ movie

]

{ #category : #menu }
SketchMorph >> restoreBaseGraphic [
	"Restore the receiver's base graphic"

	| aGraphic |
	((aGraphic := self baseGraphic) notNil and:
				[aGraphic ~= originalForm])
		ifTrue:
			[self form: aGraphic]
]

{ #category : #menu }
SketchMorph >> restoreBaseGraphicFromMenu [
	"Restore the base graphic -- invoked from a menu, so give interactive feedback if appropriate"

	self isInWorld ifFalse: [^ self inform: 

'oops, this menu is a for a morph that
has been replaced, probably because a
"look like" script was run.  Please dismiss
the menu and get a new one!.  Sorry!' translated].

	 self baseGraphic = originalForm ifTrue: [^ self inform: 'This object is *already* showing its baseGraphic' translated].
	self restoreBaseGraphic
]

{ #category : #'pen support' }
SketchMorph >> revealPenStrokes [
	"This message must be sent after a sequence of pen strokes to make the resulting changes visible."

	rotatedForm := nil.
	self changed.

]

{ #category : #accessing }
SketchMorph >> rotatedForm [

	rotatedForm ifNil: [self layoutChanged].
	^ rotatedForm

]

{ #category : #'e-toy support' }
SketchMorph >> rotationStyle [

	^ rotationStyle

]

{ #category : #'e-toy support' }
SketchMorph >> rotationStyle: aSymbol [
	"Set my rotation style to #normal, #leftRight, #upDown, or #none. Styles mean:
		#normal		-- continuous 360 degree rotation
		#leftRight		-- quantize angle to left or right facing
		#upDown		-- quantize angle to up or down facing
		#none			-- do not rotate
	Because my rendering code flips the form (see generateRotatedForm) we 'pre-flip' it here to preserve the same visual appearance.
	"

	| wasFlippedX wasFlippedY isFlippedX isFlippedY |
	wasFlippedX := rotationStyle == #leftRight
		and: [ self heading asSmallAngleDegrees < 0.0 ].
	wasFlippedY := rotationStyle == #upDown
		and: [ self heading asSmallAngleDegrees abs > 90.0 ].

	rotationStyle := aSymbol.

	isFlippedX := rotationStyle == #leftRight
		and: [ self heading asSmallAngleDegrees < 0.0 ].
	isFlippedY := rotationStyle == #upDown
		and: [ self heading asSmallAngleDegrees abs > 90.0 ].

	wasFlippedX == isFlippedX
		ifFalse: [self form: (self form flipBy: #horizontal centerAt: self form center)].
	wasFlippedY == isFlippedY
		ifFalse: [self form: (self form flipBy: #vertical centerAt: self form center)].

	self layoutChanged.

]

{ #category : #accessing }
SketchMorph >> scaleFactor [
	"Answer the number representing my scaleFactor, assuming the receiver to be unflexed (if flexed, the renderer's scaleFactor is called instead"

	| qty |
	((qty := self scalePoint) isPoint) ifTrue: [^1.0].
	^qty
]

{ #category : #accessing }
SketchMorph >> scalePoint [

	scalePoint ifNil: [scalePoint := 1.0@1.0].
	^ scalePoint

]

{ #category : #accessing }
SketchMorph >> scalePoint: aPoint [

	scalePoint := self keepAspectRatio
		ifTrue: [aPoint max: aPoint transposed]
		ifFalse: [aPoint].
	self layoutChanged.
]

{ #category : #accessing }
SketchMorph >> setNewFormFrom: formOrNil [
	"Set the receiver's form as indicated.   If nil is provided, then a default form will be used, possibly retrieved from the receiver's defaultValue property"

	| defaultImage |
	formOrNil ifNotNil: [^ self form: formOrNil].
	defaultImage := self defaultValueOrNil ifNil: [ScriptingSystem squeakyMouseForm].
	self form: defaultImage

]

{ #category : #menu }
SketchMorph >> setRotationStyle [
	| selections labels sel reply |
	selections := #(normal leftRight upDown none).
	labels := #('rotate smoothly' 'left-right flip only' 'top-down flip only' 'don''t rotate').
	sel := labels at: (selections indexOf: self rotationStyle ifAbsent:[1]).
	labels := labels collect:[:lbl| sel = lbl ifTrue:['<on>', lbl translated] ifFalse:['<off>', lbl translated]].
	reply := UIManager default chooseFrom: labels values: selections.
	reply ifNotNil: [self rotationStyle: reply].

]

{ #category : #menu }
SketchMorph >> sharpen [

	Cursor wait showWhile:[^(SketchMorph withForm: (self form sharpen))  openInHand]
	
]

{ #category : #menu }
SketchMorph >> toggleInterpolation [
	^self useInterpolation: self useInterpolation not
]

{ #category : #accessing }
SketchMorph >> useInterpolation [
	^(self valueOfProperty: #useInterpolation ifAbsent:[false]) 
		and:[Smalltalk includesKey: #B3DRenderEngine]
]

{ #category : #accessing }
SketchMorph >> useInterpolation: aBool [
	(aBool == true and: [ Smalltalk includesKey: #B3DRenderEngine ])
		ifTrue:[self setProperty: #useInterpolation toValue: aBool]
		ifFalse:[self removeProperty: #useInterpolation].
	self layoutChanged. "to regenerate the form"

]

{ #category : #menu }
SketchMorph >> useInterpolationString [
	^ (self useInterpolation
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'smooth image' translated
]

{ #category : #'halos and balloon help' }
SketchMorph >> wantsDirectionHandles [
	^self valueOfProperty: #wantsDirectionHandles ifAbsent:[
		Preferences showDirectionHandles or:[Preferences showDirectionForSketches]]
]

{ #category : #'halos and balloon help' }
SketchMorph >> wantsDirectionHandles: aBool [
	aBool == (Preferences showDirectionHandles or:[Preferences showDirectionForSketches])
		ifTrue:[self removeProperty: #wantsDirectionHandles]
		ifFalse:[self setProperty: #wantsDirectionHandles toValue: aBool].
]

{ #category : #'e-toy support' }
SketchMorph >> wantsRecolorHandle [
	"Answer whether the receiver would like a recolor handle to be  
	put up for it. We'd want to disable this but for the moment  
	that would cut off access to the button part of the properties  
	sheet. So this remains a loose end."
	^ false
]

{ #category : #accessing }
SketchMorph >> wantsSimpleSketchMorphHandles [
	"Answer true if my halo's simple handles should include the simple sketch morph handles."
	^self isMemberOf: SketchMorph
]
