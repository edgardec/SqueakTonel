"
BalloonEngine is the representative for the Balloon engine inside Squeak. For most purposes it should not be used directly but via BalloonCanvas since this ensures proper initialization and is polymorphic with other canvas uses.
"
Class {
	#name : #BalloonEngine,
	#superclass : #Object,
	#instVars : [
		'workBuffer',
		'span',
		'bitBlt',
		'forms',
		'clipRect',
		'destOffset',
		'externals',
		'aaLevel',
		'edgeTransform',
		'colorTransform',
		'deferred',
		'postFlushNeeded'
	],
	#classVars : [
		'BezierStats',
		'BufferCache',
		'CacheProtect',
		'Counts',
		'Debug',
		'Times'
	],
	#pools : [
		'BalloonEngineConstants'
	],
	#category : #'Balloon-Engine'
}

{ #category : #private }
BalloonEngine class >> allocateOrRecycleBuffer: initialSize [
	"Try to recycly a buffer. If this is not possibly, create a new one."
	| buffer |
	CacheProtect critical:[
		buffer := BufferCache at: 1.
		BufferCache at: 1 put: nil.
	].
	^buffer ifNil:[BalloonBuffer new: initialSize]
]

{ #category : #accessing }
BalloonEngine class >> debug: aBoolean [
	"BalloonEngine debug: true"
	"BalloonEngine debug: false"
	Debug := aBoolean
]

{ #category : #accessing }
BalloonEngine class >> doProfileStats: aBool [
	"Note: On Macintosh systems turning on profiling can significantly
	degrade the performance of Balloon since we're using the high
	accuracy timer for measuring."
	"BalloonEngine doProfileStats: true"
	"BalloonEngine doProfileStats: false"
	<primitive: 'primitiveDoProfileStats' module: 'B2DPlugin' error: errorCode>
	^false
]

{ #category : #'class initialization' }
BalloonEngine class >> initialize [
	"BalloonEngine initialize"
	BufferCache := WeakArray new: 1.
	Smalltalk garbageCollect. "Make the cache old"
	CacheProtect := Semaphore forMutualExclusion.
	Times := WordArray new: 10.
	Counts := WordArray new: 10.
	BezierStats := WordArray new: 4.
	Debug ifNil:[Debug := false].
]

{ #category : #private }
BalloonEngine class >> primitiveSetBitBltPlugin: pluginName [
	<primitive: 'primitiveSetBitBltPlugin' module: 'B2DPlugin' error: errorCode>
	^nil
]

{ #category : #accessing }
BalloonEngine class >> printBezierStats [
	"BalloonEngine printBezierStats"
	"BalloonEngine resetBezierStats"
	Transcript 
		cr; nextPutAll:'Bezier statistics:';
		crtab; print: (BezierStats at: 1); tab; nextPutAll:' non-monoton curves splitted';
		crtab; print: (BezierStats at: 2); tab; nextPutAll:' curves splitted for numerical accuracy';
		crtab; print: (BezierStats at: 3); tab; nextPutAll:' curves splitted to avoid integer overflow';
		crtab; print: (BezierStats at: 4); tab; nextPutAll:' curves internally converted to lines';
	endEntry.
]

{ #category : #accessing }
BalloonEngine class >> printStat: time count: n string: aString [
	Transcript
		cr;
		print: time; tab;
		nextPutAll:' mSecs -- ';
		print: n; tab;
		nextPutAll:' ops -- ';
		nextPutAll: ((time asFloat / (n max: 1) asFloat) printShowingMaxDecimalPlaces: 2); tab;
		nextPutAll: ' avg. mSecs/op -- ';
		nextPutAll: aString.
]

{ #category : #accessing }
BalloonEngine class >> printStats [
	"BalloonEngine doProfileStats: true"
	"BalloonEngine printStats"
	"BalloonEngine resetStats"
	Transcript cr; nextPutAll:'/************** BalloonEngine statistics ****************/'.
	self printStat: (Times at: 1) count: (Counts at: 1) string: 'Initialization'.
	self printStat: (Times at: 2) count: (Counts at: 2) string: 'Finish test'.
	self printStat: (Times at: 3) count: (Counts at: 3) string: 'Fetching/Adding GET entries'.
	self printStat: (Times at: 4) count: (Counts at: 4) string: 'Adding AET entries'.
	self printStat: (Times at: 5) count: (Counts at: 5) string: 'Fetching/Computing fills'.
	self printStat: (Times at: 6) count: (Counts at: 6) string: 'Merging fills'.
	self printStat: (Times at: 7) count: (Counts at: 7) string: 'Displaying span buffer'.
	self printStat: (Times at: 8) count: (Counts at: 8) string: 'Fetching/Updating AET entries'.
	self printStat: (Times at: 9) count: (Counts at: 9) string: 'Changing AET entries'.
	Transcript cr; print: Times sum; nextPutAll:' mSecs for all operations'.
	Transcript cr; print: Counts sum; nextPutAll: ' overall operations'.
	Transcript endEntry.
]

{ #category : #private }
BalloonEngine class >> recycleBuffer: balloonBuffer [
	"Try to keep the buffer for later drawing operations."

	CacheProtect critical:[ | buffer |
		buffer := BufferCache at: 1.
		(buffer isNil or:[buffer size < balloonBuffer size] )
			ifTrue:[BufferCache at: 1 put: balloonBuffer].
	].
]

{ #category : #accessing }
BalloonEngine class >> resetBezierStats [
	BezierStats := WordArray new: 4.
]

{ #category : #accessing }
BalloonEngine class >> resetStats [
	Times := WordArray new: 10.
	Counts := WordArray new: 10.
]

{ #category : #accessing }
BalloonEngine >> aaLevel [
	^aaLevel ifNil:[1]
]

{ #category : #accessing }
BalloonEngine >> aaLevel: anInteger [
	aaLevel := (anInteger min: 4) max: 1.
]

{ #category : #accessing }
BalloonEngine >> aaTransform [
	"Return a transformation for the current anti-aliasing level"
	| matrix |
	matrix := MatrixTransform2x3 withScale: (self aaLevel) asFloat asPoint.
	matrix offset: (self aaLevel // 2) asFloat asPoint.
	^matrix composedWith:(MatrixTransform2x3 withOffset: destOffset asFloatPoint)
]

{ #category : #accessing }
BalloonEngine >> bitBlt [
	^bitBlt
]

{ #category : #accessing }
BalloonEngine >> bitBlt: aBitBlt [
	| destWidth |
	bitBlt := aBitBlt.
	bitBlt isNil ifTrue:[^self].
	destWidth := bitBlt destForm width.
	destWidth > span size ifTrue:[span := Bitmap new: destWidth].
	self class primitiveSetBitBltPlugin: bitBlt getPluginName.
	self clipRect: bitBlt clipRect.
	bitBlt 
		sourceForm: (Form extent: span size @ 1 depth: 32 bits: span);
		sourceRect: (0@0 extent: 1@span size);
		colorMap: (Color colorMapIfNeededFrom: 32 to: bitBlt destForm depth);
		combinationRule: (bitBlt destForm depth >= 8 ifTrue:[34] ifFalse:[Form paint]).
]

{ #category : #copying }
BalloonEngine >> canProceedAfter: failureReason [
	"Check if we can proceed after the failureReason indicated."
	| newBuffer |
	failureReason = GErrorNeedFlush ifTrue:[
		"Need to flush engine before proceeding"
		self copyBits.
		self reset.
		^true].
	failureReason = GErrorNoMoreSpace ifTrue:[
		"Work buffer is too small"
		newBuffer := workBuffer species new: workBuffer size * 2.
		self primCopyBufferFrom: workBuffer to: newBuffer.
		workBuffer := newBuffer.
		^true].
	"Not handled"
	^false
]

{ #category : #accessing }
BalloonEngine >> clipRect [
	^clipRect
]

{ #category : #accessing }
BalloonEngine >> clipRect: aRect [
	clipRect := aRect truncated
]

{ #category : #accessing }
BalloonEngine >> colorTransform [
	^colorTransform
]

{ #category : #accessing }
BalloonEngine >> colorTransform: aColorTransform [
	colorTransform := aColorTransform
]

{ #category : #copying }
BalloonEngine >> copyBits [
	(bitBlt notNil and:[bitBlt destForm notNil]) ifTrue:[bitBlt destForm unhibernate].
	self copyLoopFaster.
]

{ #category : #copying }
BalloonEngine >> copyLoop [
	"This is the basic rendering loop using as little primitive support as possible."
	| finished edge fill |
	edge := BalloonEdgeData new.
	fill := BalloonFillData new.
	self primInitializeProcessing. "Initialize the GE for processing"
	[self primFinishedProcessing] whileFalse:[
		"Step 1: Process the edges in the global edge table that will be added in this step"
		[finished := self primNextGlobalEdgeEntryInto: edge.
		finished] whileFalse:[
			edge source: (externals at: edge index).
			edge stepToFirstScanLine.
			self primAddActiveEdgeTableEntryFrom: edge].

		"Step 2: Scan the active edge table"
		[finished := self primNextFillEntryInto: fill.
		finished] whileFalse:[
			fill source: (externals at: fill index).
			"Compute the new fill"
			fill computeFill.
			"And mix it in the out buffer"
			self primMergeFill: fill destForm bits from: fill].

		"Step 3: Display the current span buffer if necessary"
		self primDisplaySpanBuffer.

		"Step 4: Advance and resort the active edge table"
		[finished := self primNextActiveEdgeEntryInto: edge.
		finished] whileFalse:[
			"If the index is zero then the edge has been handled by the GE"
			edge source: (externals at: edge index).
			edge stepToNextScanLine.
			self primChangeActiveEdgeTableEntryFrom: edge].
	].
	self primGetTimes: Times.
	self primGetCounts: Counts.
	self primGetBezierStats: BezierStats.
]

{ #category : #copying }
BalloonEngine >> copyLoopFaster [
	"This is a copy loop drawing one scan line at a time"
	| edge fill reason |
	edge := BalloonEdgeData new.
	fill := BalloonFillData new.
	[self primFinishedProcessing] whileFalse:[
		reason := self primRenderScanline: edge with: fill.
		"reason ~= 0 means there has been a problem"
		reason = 0 ifFalse:[
			self processStopReason: reason edge: edge fill: fill.
		].
	].
	self primGetTimes: Times.
	self primGetCounts: Counts.
	self primGetBezierStats: BezierStats.
]

{ #category : #copying }
BalloonEngine >> copyLoopFastest [
	"This is a copy loop drawing the entire image"
	| edge fill reason |
	edge := BalloonEdgeData new.
	fill := BalloonFillData new.
	[self primFinishedProcessing] whileFalse:[
		reason := self primRenderImage: edge with: fill.
		"reason ~= 0 means there has been a problem"
		reason = 0 ifFalse:[
			self processStopReason: reason edge: edge fill: fill.
		].
	].
	self primGetTimes: Times.
	self primGetCounts: Counts.
	self primGetBezierStats: BezierStats.
]

{ #category : #accessing }
BalloonEngine >> deferred [
	^deferred
]

{ #category : #accessing }
BalloonEngine >> deferred: aBoolean [
	deferred := aBoolean.
]

{ #category : #accessing }
BalloonEngine >> destOffset [
	^destOffset
]

{ #category : #accessing }
BalloonEngine >> destOffset: aPoint [
	destOffset := aPoint asIntegerPoint.
	bitBlt destX: aPoint x; destY: aPoint y.
]

{ #category : #profiling }
BalloonEngine >> doAddCompressedShape: points segments: nSegments leftFills: leftFills rightFills: rightFills lineWidths: lineWidths lineFills: lineFills fillIndexList: fillIndexList matrix: aMatrix [
	"Note: This method is for profiling the overhead of loading a compressed shape into the engine."
	^self primAddCompressedShape: points segments: nSegments leftFills: leftFills rightFills: rightFills lineWidths: lineWidths lineFills: lineFills fillIndexList: fillIndexList matrix: aMatrix
]

{ #category : #drawing }
BalloonEngine >> drawBezierShape: points fill: fillStyle borderWidth: borderWidth borderColor: borderFill transform: aTransform [
	| fills |
	self edgeTransform: aTransform.
	self resetIfNeeded.
	fills := self registerFill: fillStyle and: borderFill.
	self primAddBezierShape: points
		segments: (points size) // 3
		fill: (fills at: 1)
		lineWidth: borderWidth
		lineFill: (fills at: 2).
	self postFlushIfNeeded.
]

{ #category : #drawing }
BalloonEngine >> drawCompressedShape: shape transform: aTransform [
	| fillIndexList |
	self edgeTransform: aTransform.
	self resetIfNeeded.

	fillIndexList := self registerFills: shape fillStyles.

	self primAddCompressedShape: shape points
		segments: shape numSegments
		leftFills: shape leftFills
		rightFills: shape rightFills
		lineWidths: shape lineWidths
		lineFills: shape lineFills
		fillIndexList: fillIndexList.
	self postFlushIfNeeded.
]

{ #category : #drawing }
BalloonEngine >> drawGeneralBezierShape: contours fill: fillStyle borderWidth: borderWidth borderColor: borderFill transform: aTransform [

	| fills |
	self edgeTransform: aTransform.
	self resetIfNeeded.
	fills := self registerFill: fillStyle and: borderFill.
	contours do:[:points|
		self primAddBezierShape: points
			segments: (points size // 3)
			fill: (fills at: 1)
			lineWidth: borderWidth
			lineFill: (fills at: 2).
		"Note: To avoid premature flushing of the pipeline we need to
		reset the flush bit within the engine."
		self primFlushNeeded: false.
	].
	"And set the flush bit afterwards"
	self primFlushNeeded: true.
	self postFlushIfNeeded.
]

{ #category : #drawing }
BalloonEngine >> drawGeneralPolygon: contours fill: fillStyle borderWidth: borderWidth borderColor: borderFill transform: aTransform [

	| fills |
	self edgeTransform: aTransform.
	self resetIfNeeded.
	fills := self registerFill: fillStyle and: borderFill.
	contours do:[:points|
		self primAddPolygon: points
			segments: points size
			fill: (fills at: 1)
			lineWidth: borderWidth
			lineFill: (fills at: 2).
		"Note: To avoid premature flushing of the pipeline we need to
		reset the flush bit within the engine."
		self primFlushNeeded: false.
	].
	"And set the flush bit afterwards"
	self primFlushNeeded: true.
	self postFlushIfNeeded.
]

{ #category : #drawing }
BalloonEngine >> drawOval: rect fill: fillStyle borderWidth: borderWidth borderColor: borderColor transform: aMatrix [

	| fills |
	self edgeTransform: aMatrix.
	self resetIfNeeded.
	fills := self registerFill: fillStyle and: borderColor.
	self primAddOvalFrom: rect origin 
			to: rect corner
			fillIndex: (fills at: 1)
			borderWidth: borderWidth
			borderColor: (fills at: 2).
	self postFlushIfNeeded.
]

{ #category : #drawing }
BalloonEngine >> drawPolygon: points fill: fillStyle borderWidth: borderWidth borderColor: borderFill transform: aTransform [

	| fills |
	self edgeTransform: aTransform.
	self resetIfNeeded.
	fills := self registerFill: fillStyle and: borderFill.
	self primAddPolygon: points
		segments: points size
		fill: (fills at: 1)
		lineWidth: borderWidth
		lineFill: (fills at: 2).
	self postFlushIfNeeded.
]

{ #category : #drawing }
BalloonEngine >> drawRectangle: rect fill: fillStyle borderWidth: borderWidth borderColor: borderColor transform: aMatrix [

	| fills |
	self edgeTransform: aMatrix.
	self resetIfNeeded.
	fills := self registerFill: fillStyle and: borderColor.
	self primAddRectFrom: rect origin 
			to: rect corner
			fillIndex: (fills at: 1)
			borderWidth: borderWidth
			borderColor: (fills at: 2).
	self postFlushIfNeeded.
]

{ #category : #accessing }
BalloonEngine >> edgeTransform [
	^edgeTransform
]

{ #category : #accessing }
BalloonEngine >> edgeTransform: aTransform [
	edgeTransform := aTransform.
]

{ #category : #initialize }
BalloonEngine >> flush [
	"Force all pending primitives onscreen"
	workBuffer ifNil:[^self].
	self copyBits.
	self release.
]

{ #category : #accessing }
BalloonEngine >> fullTransformFrom: aMatrix [
	| m |
	m := self aaTransform composedWith: aMatrix.
	"m offset: m offset + destOffset."
	^m
]

{ #category : #initialize }
BalloonEngine >> initialize [
	externals := OrderedCollection new: 100.
	span := Bitmap new: 2048.
	bitBlt := nil.
	self bitBlt: ((BitBlt toForm: Display) destRect: Display boundingBox; yourself).
	forms := #().
	deferred := false.
]

{ #category : #initialize }
BalloonEngine >> postFlushIfNeeded [
	"Force all pending primitives onscreen"
	workBuffer ifNil:[^self].
	(deferred not or:[postFlushNeeded]) ifTrue:[
		self copyBits.
		self release].
]

{ #category : #initialize }
BalloonEngine >> preFlushIfNeeded [
	"Force all pending primitives onscreen"
	workBuffer ifNil:[^self].
	self primFlushNeeded ifTrue:[
		self copyBits.
		self reset].
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primAddActiveEdgeTableEntryFrom: edgeEntry [
	"Add edge entry to the AET."
	<primitive: 'primitiveAddActiveEdgeEntry' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddActiveEdgeTableEntryFrom: edgeEntry
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddBezierFrom: start to: end via: via leftFillIndex: leftFillIndex rightFillIndex: rightFillIndex [
	<primitive: 'primitiveAddBezier' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddBezierFrom: start to: end via: via leftFillIndex: leftFillIndex rightFillIndex: rightFillIndex
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddBezierShape: points segments: nSegments fill: fillStyle lineWidth: lineWidth lineFill: lineFill [
	<primitive: 'primitiveAddBezierShape' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddBezierShape: points segments: nSegments fill: fillStyle lineWidth: lineWidth lineFill: lineFill
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddBitmapFill: form colormap: cmap tile: tileFlag from: origin along: direction normal: normal xIndex: xIndex [
	<primitive: 'primitiveAddBitmapFill' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddBitmapFill: form colormap: cmap tile: tileFlag from: origin along: direction normal: normal xIndex: xIndex
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddCompressedShape: points segments: nSegments leftFills: leftFills rightFills: rightFills lineWidths: lineWidths lineFills: lineFills fillIndexList: fillIndexList [
	<primitive: 'primitiveAddCompressedShape' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddCompressedShape: points segments: nSegments leftFills: leftFills rightFills: rightFills lineWidths: lineWidths lineFills: lineFills fillIndexList: fillIndexList
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddExternalEdge: index initialX: initialX initialY: initialY initialZ: initialZ leftFillIndex: leftFillIndex rightFillIndex: rightFillIndex [
	<primitive: 'primitiveRegisterExternalEdge' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddExternalEdge: index initialX: initialX initialY: initialY initialZ: initialZ leftFillIndex: leftFillIndex rightFillIndex: rightFillIndex
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddExternalFill: index [
	<primitive: 'primitiveRegisterExternalFill' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddExternalFill: index
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddGradientFill: colorRamp from: origin along: direction normal: normal radial: isRadial [
	<primitive: 'primitiveAddGradientFill' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddGradientFill: colorRamp 
				from: origin 
				along: direction 
				normal: normal 
				radial: isRadial
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddLineFrom: start to: end leftFillIndex: leftFillIndex rightFillIndex: rightFillIndex [
	<primitive: 'primitiveAddLine' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddLineFrom: start to: end leftFillIndex: leftFillIndex rightFillIndex: rightFillIndex
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddOvalFrom: start to: end fillIndex: fillIndex borderWidth: width borderColor: pixelValue32 [
	<primitive: 'primitiveAddOval' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddOvalFrom: start to: end fillIndex: fillIndex borderWidth: width borderColor: pixelValue32
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddPolygon: points segments: nSegments fill: fillStyle lineWidth: lineWidth lineFill: lineFill [
	<primitive: 'primitiveAddPolygon' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddPolygon: points segments: nSegments fill: fillStyle lineWidth: lineWidth lineFill: lineFill
	].
	^ 0
]

{ #category : #'primitives-adding' }
BalloonEngine >> primAddRectFrom: start to: end fillIndex: fillIndex borderWidth: width borderColor: pixelValue32 [
	<primitive: 'primitiveAddRect' module: 'B2DPlugin' error: errorCode>
	(self canProceedAfter: self primGetFailureReason) ifTrue:[
		^self primAddRectFrom: start to: end fillIndex: fillIndex borderWidth: width borderColor: pixelValue32
	].
	^ 0
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primChangeActiveEdgeTableEntryFrom: edgeEntry [
	"Change the entry in the active edge table from edgeEntry"
	<primitive: 'primitiveChangedActiveEdgeEntry' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primClipRectInto: rect [
	<primitive: 'primitiveGetClipRect' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-misc' }
BalloonEngine >> primCopyBufferFrom: oldBuffer to: newBuffer [
	"Copy the contents of oldBuffer into the (larger) newBuffer"
	<primitive: 'primitiveCopyBuffer' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primDisplaySpanBuffer [
	"Display the current scan line if necessary"
	<primitive: 'primitiveDisplaySpanBuffer' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primFinishedProcessing [
	"Return true if there are no more entries in AET and GET and the last scan line has been displayed"
	<primitive: 'primitiveFinishedProcessing' module: 'B2DPlugin' error: errorCode>
	^ true
]

{ #category : #'primitives-access' }
BalloonEngine >> primFlushNeeded [
	<primitive: 'primitiveNeedsFlush' module: 'B2DPlugin' error: errorCode>
	^ false
]

{ #category : #'primitives-access' }
BalloonEngine >> primFlushNeeded: aBoolean [
	<primitive: 'primitiveNeedsFlushPut' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primGetAALevel [
	"Set the AA level"
	<primitive: 'primitiveGetAALevel' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primGetBezierStats: statsArray [
	<primitive: 'primitiveGetBezierStats' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primGetClipRect: rect [
	<primitive: 'primitiveGetClipRect' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primGetCounts: statsArray [
	<primitive: 'primitiveGetCounts' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primGetDepth [
	<primitive: 'primitiveGetDepth' module: 'B2DPlugin' error: errorCode>
	^ 32
]

{ #category : #'primitives-access' }
BalloonEngine >> primGetFailureReason [
	<primitive: 'primitiveGetFailureReason' module: 'B2DPlugin' error: errorCode>
	^0
]

{ #category : #'primitives-access' }
BalloonEngine >> primGetOffset [
	<primitive: 'primitiveGetOffset' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primGetTimes: statsArray [
	<primitive: 'primitiveGetTimes' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-misc' }
BalloonEngine >> primInitializeBuffer: buffer [
	<primitive: 'primitiveInitializeBuffer' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primInitializeProcessing [
	"Initialize processing in the GE.
	Create the active edge table and sort it."
	<primitive: 'primitiveInitializeProcessing' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primMergeFill: fillBitmap from: fill [
	"Merge the filled bitmap into the current output buffer."
	<primitive: 'primitiveMergeFillFrom' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primNextActiveEdgeEntryInto: edgeEntry [
	"Store the next entry of the AET at the current y-value in edgeEntry.
	Return false if there is no entry, true otherwise."
	<primitive: 'primitiveNextActiveEdgeEntry' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primNextFillEntryInto: fillEntry [
	"Store the next fill entry of the active edge table in fillEntry.
	Return false if there is no such entry, true otherwise"
	<primitive: 'primitiveNextFillEntry' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primNextGlobalEdgeEntryInto: edgeEntry [
	"Store the next entry of the GET at the current y-value in edgeEntry.
	Return false if there is no entry, true otherwise."
	<primitive: 'primitiveNextGlobalEdgeEntry' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primRenderImage: edge with: fill [
	"Start/Proceed rendering the current scan line"
	<primitive: 'primitiveRenderImage' module: 'B2DPlugin' error: errorCode>
	^0 
]

{ #category : #'primitives-incremental' }
BalloonEngine >> primRenderScanline: edge with: fill [
	"Start/Proceed rendering the current scan line"
	<primitive: 'primitiveRenderScanline' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primSetAALevel: level [
	"Set the AA level"
	<primitive: 'primitiveSetAALevel' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primSetClipRect: rect [
	<primitive: 'primitiveSetClipRect' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primSetColorTransform: transform [
	<primitive: 'primitiveSetColorTransform' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primSetDepth: depth [
	<primitive: 'primitiveSetDepth' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primSetEdgeTransform: transform [
	<primitive: 'primitiveSetEdgeTransform' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #'primitives-access' }
BalloonEngine >> primSetOffset: point [
	<primitive: 'primitiveSetOffset' module: 'B2DPlugin' error: errorCode>
	^ 0
]

{ #category : #copying }
BalloonEngine >> processStopReason: reason edge: edge fill: fill [
	"The engine has stopped because of some reason.
	Try to figure out how to respond and do the necessary actions."
	"Note: The order of operations below can affect the speed"

	"Process unknown fills first"
	reason = GErrorFillEntry ifTrue:[
		fill source: (externals at: fill index).
		"Compute the new fill"
		fill computeFill.
		"And mix it in the out buffer"
		^self primMergeFill: fill destForm bits from: fill].

	"Process unknown steppings in the AET second"
	reason = GErrorAETEntry ifTrue:[
		edge source: (externals at: edge index).
		edge stepToNextScanLine.
		^self primChangeActiveEdgeTableEntryFrom: edge].

	"Process unknown entries in the GET third"
	reason = GErrorGETEntry ifTrue:[
		edge source: (externals at: edge index).
		edge stepToFirstScanLine.
		^self primAddActiveEdgeTableEntryFrom: edge].

	"Process generic problems last"
	(self canProceedAfter: reason) ifTrue:[^self]. "Okay."

	^self error:'Unkown stop reason in graphics engine'

]

{ #category : #experimental }
BalloonEngine >> registerBezier: aCurve transformation: aMatrix [
	self primAddBezierFrom: aCurve start
		to: aCurve end
		via: aCurve via
		leftFillIndex: (self registerFill: aCurve leftFill transform: aMatrix)
		rightFillIndex: (self registerFill: aCurve rightFill transform: aMatrix)
		matrix: aMatrix
]

{ #category : #experimental }
BalloonEngine >> registerBoundary: boundaryObject transformation: aMatrix [
	| external |
	external := boundaryObject asEdgeRepresentation: (self fullTransformFrom: aMatrix).
	self subdivideExternalEdge: external from: boundaryObject.

]

{ #category : #experimental }
BalloonEngine >> registerExternalEdge: externalEdge from: boundaryObject [
	externals addLast: externalEdge.
	self primAddExternalEdge: externals size
		initialX: externalEdge initialX
		initialY: externalEdge initialY
		initialZ: externalEdge initialZ
		leftFillIndex: (self registerFill: boundaryObject leftFill transform: nil)
		rightFillIndex: (self registerFill: boundaryObject rightFill transform: nil)
]

{ #category : #drawing }
BalloonEngine >> registerFill: aFillStyle [
	"Register the given fill style."
	| theForm |
	aFillStyle ifNil:[^0].
	aFillStyle isSolidFill 
		ifTrue:[^aFillStyle scaledPixelValue32].

	aFillStyle isGradientFill ifTrue:[
		^self primAddGradientFill: aFillStyle pixelRamp
			from: aFillStyle origin
			along: aFillStyle direction
			normal: aFillStyle normal
			radial: aFillStyle isRadialFill
		].
	aFillStyle isBitmapFill ifTrue:[
		theForm := aFillStyle form asSourceForm.
		theForm unhibernate.
		forms := forms copyWith: theForm.
		^self primAddBitmapFill: theForm
				colormap: (theForm colormapIfNeededForDepth: 32)
				tile: aFillStyle isTiled
				from: aFillStyle origin
				along: aFillStyle direction
				normal: aFillStyle normal
				xIndex: forms size].
	^0
]

{ #category : #drawing }
BalloonEngine >> registerFill: fill1 and: fill2 [
	^self registerFills: (Array with: fill1 with: fill2)
]

{ #category : #drawing }
BalloonEngine >> registerFill: aFillStyle transform: aTransform [

	aFillStyle ifNil:[^0].
	aFillStyle isSolidFill 
		ifTrue:[^aFillStyle scaledPixelValue32].

	aFillStyle isGradientFill ifTrue:[
		^self primAddGradientFill: aFillStyle pixelRamp
			from: aFillStyle origin
			along: aFillStyle direction
			normal: aFillStyle normal
			radial: aFillStyle isRadialFill
			matrix: aTransform.
		].
	^0
]

{ #category : #drawing }
BalloonEngine >> registerFills: fills [

	| fillIndexList index fillIndex |
	((colorTransform notNil and:[colorTransform isAlphaTransform]) or:[
		fills anySatisfy: [:any| any notNil and:[any isTranslucent]]])
			ifTrue:[	self flush.
					self reset.
					postFlushNeeded := true].
	fillIndexList := WordArray new: fills size.
	index := 1.
	[index <= fills size] whileTrue:[
		fillIndex := self registerFill: (fills at: index).
		fillIndex == nil 
			ifTrue:[index := 1] "Need to start over"
			ifFalse:[fillIndexList at: index put: fillIndex.
					index := index+1]
	].
	^fillIndexList
]

{ #category : #experimental }
BalloonEngine >> registerLine: aLine transformation: aMatrix [
	self primAddLineFrom: aLine start to: aLine end
		leftFillIndex: (self registerFill: aLine leftFill transform: aMatrix)
		rightFillIndex: (self registerFill: aLine rightFill transform: aMatrix)
		matrix: aMatrix
]

{ #category : #initialize }
BalloonEngine >> release [
	self class recycleBuffer: workBuffer.
	workBuffer := nil.
]

{ #category : #initialize }
BalloonEngine >> reset [
	workBuffer ifNil:[workBuffer := self class allocateOrRecycleBuffer: 10000].
	self primInitializeBuffer: workBuffer.
	self primSetAALevel: self aaLevel.
	self primSetOffset: destOffset.
	self primSetClipRect: clipRect.
	self primSetEdgeTransform: edgeTransform.
	self primSetColorTransform: colorTransform.
	forms := #().
]

{ #category : #initialize }
BalloonEngine >> resetIfNeeded [
	workBuffer ifNil:[self reset].
	self primSetEdgeTransform: edgeTransform.
	self primSetColorTransform: colorTransform.
	self primSetDepth: self primGetDepth + 1.
	postFlushNeeded := false.
]

{ #category : #experimental }
BalloonEngine >> subdivideExternalEdge: external from: boundaryObject [
	| external2 |
	external2 := external subdivide.
	external2 notNil ifTrue:[
		self subdivideExternalEdge: external from: boundaryObject.
		self subdivideExternalEdge: external2 from: boundaryObject.
	] ifFalse:[
		self registerExternalEdge: external from: boundaryObject.
	].
]
