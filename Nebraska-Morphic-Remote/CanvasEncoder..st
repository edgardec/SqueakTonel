"
Encodes canvas commands into string-arrays format.

---possible further compression for forms ---
600 * 359 * 4    861600

self encodeForRemoteCanvas size 76063
Time millisecondsToRun: [self encodeForRemoteCanvas]

| raw data |
data := self encodeForRemoteCanvas.
raw := RWBinaryOrTextStream on: (String new: 1000).
Time millisecondsToRun: [(GZipWriteStream on: raw) nextPutAll: data; close].
raw contents size
(GZipReadStream on: (ReadStream on: raw contents)) upToEnd size

| raw |
raw := RWBinaryOrTextStream on: (String new: bits size).
raw nextPutAll: bits

Time millisecondsToRun: [bits compressGZip]   50

bits compressGZip size 861620
"
Class {
	#name : #CanvasEncoder,
	#superclass : #Object,
	#instVars : [
		'connection',
		'lastClipRect',
		'lastTransform',
		'fontCache',
		'cachedObjects',
		'cachingEnabled'
	],
	#classVars : [
		'SentTypesAndSizes',
		'SimpleCounters'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #codes }
CanvasEncoder class >> aaaReadme [
	"these codes are used instead of strings, because String>>= was taking around 20% of the decoder's time"
	
]

{ #category : #'as yet unclassified' }
CanvasEncoder class >> at: anIndex count: anInteger [

	SimpleCounters ifNil: [(SimpleCounters := Array new: 10) atAllPut: 0].
	SimpleCounters at: anIndex put: (SimpleCounters at: anIndex) + anInteger.
]

{ #category : #'as yet unclassified' }
CanvasEncoder class >> beginStats [

	SentTypesAndSizes := Dictionary new.
]

{ #category : #'as yet unclassified' }
CanvasEncoder class >> clearTestVars [
"
CanvasEncoder clearTestVars
"
	SimpleCounters := nil


]

{ #category : #codes }
CanvasEncoder class >> codeBalloonOval [

	^$O
]

{ #category : #codes }
CanvasEncoder class >> codeBalloonRect [
	^$R
]

{ #category : #codes }
CanvasEncoder class >> codeClip [
	^$A
]

{ #category : #codes }
CanvasEncoder class >> codeExtentDepth [
	^$M
]

{ #category : #codes }
CanvasEncoder class >> codeFont [
	^$L
]

{ #category : #codes }
CanvasEncoder class >> codeFontSet [

	^ $S

]

{ #category : #codes }
CanvasEncoder class >> codeForce [
	^$J
]

{ #category : #codes }
CanvasEncoder class >> codeImage [
	^$G
]

{ #category : #codes }
CanvasEncoder class >> codeInfiniteFill [

	^$i
]

{ #category : #codes }
CanvasEncoder class >> codeLine [
	^$D
]

{ #category : #codes }
CanvasEncoder class >> codeMultiText [

	^ $c

]

{ #category : #codes }
CanvasEncoder class >> codeOval [
	^$F
]

{ #category : #codes }
CanvasEncoder class >> codePoly [
	^$H
]

{ #category : #codes }
CanvasEncoder class >> codeRect [
	^$E
]

{ #category : #codes }
CanvasEncoder class >> codeReleaseCache [
	^$z
]

{ #category : #codes }
CanvasEncoder class >> codeShadowColor [

	^$s
]

{ #category : #codes }
CanvasEncoder class >> codeStencil [
	^$I
]

{ #category : #codes }
CanvasEncoder class >> codeTTCFont [

	^ $T.

]

{ #category : #codes }
CanvasEncoder class >> codeText [
	^$C
]

{ #category : #codes }
CanvasEncoder class >> codeTransform [
	^$B
]

{ #category : #encoding }
CanvasEncoder class >> encodeColor: color [
	
	^color encodeForRemoteCanvas
]

{ #category : #encoding }
CanvasEncoder class >> encodeFillStyle: aFillStyle [
	
	^aFillStyle encodeForRemoteCanvas
]

{ #category : #encoding }
CanvasEncoder class >> encodeFont: aFont [
	^aFont encodedForRemoteCanvas
]

{ #category : #encoding }
CanvasEncoder class >> encodeImage: form [
	
	| t answer |

	form ifNil: [^''].
	t := Time millisecondsToRun: [answer := form encodeForRemoteCanvas].
	form boundingBox area > 5000 ifTrue: [
		NebraskaDebug at: #FormEncodeTimes add: {t. form extent. answer size}
	].
	^answer

	"HandMorph>>restoreSavedPatchOn: is one culprit here"


]

{ #category : #encoding }
CanvasEncoder class >> encodeInteger: integer [
	^integer asInteger storeString
]

{ #category : #encoding }
CanvasEncoder class >> encodePoint: point [
	
	^point encodeForRemoteCanvas
]

{ #category : #encoding }
CanvasEncoder class >> encodeRectangle: rectangle [
	| x y encoded cornerX cornerY |

	x := rectangle origin x asInteger.
	y := rectangle origin y asInteger.
	cornerX := rectangle corner x asInteger.
	cornerY := rectangle corner y asInteger.

	CanvasEncoder at: 2 count:  1.
	encoded := String new: 16.
	encoded putInteger32: x at: 1.
	encoded putInteger32: y at: 5.
	encoded putInteger32: cornerX at: 9.
	encoded putInteger32: cornerY at: 13.

	^encoded
]

{ #category : #encoding }
CanvasEncoder class >> encodeTransform: transform [
	^transform encodeForRemoteCanvas
]

{ #category : #'as yet unclassified' }
CanvasEncoder class >> explainTestVars [
"
CanvasEncoder explainTestVars
"
	| answer oneBillion total |

	SimpleCounters ifNil: [^ Beeper beep].
	total := 0.
	oneBillion := 1000 * 1000 * 1000.
	answer := String streamContents: [ :strm | | data putter |
		data := SimpleCounters copy.
		putter := [ :msg :index :nSec | | nReps |
			nReps := data at: index.
			total := total + (nSec * nReps).
			strm nextPutAll: nReps asStringWithCommas,' * ',nSec printString,' ',
					(nSec * nReps / oneBillion printShowingMaxDecimalPlaces: 2),' secs for ',msg; cr
		].
		putter value: 'string socket' value: 1 value: 8000.
		putter value: 'rectangles' value: 2 value: 40000.
		putter value: 'points' value: 3 value: 18000.
		putter value: 'colors' value: 4 value: 8000.
	].
	StringHolder new
		contents: answer;
		openLabel: 'put integer times'.


]

{ #category : #'as yet unclassified' }
CanvasEncoder class >> inspectTestVars [
"
CanvasEncoder inspectTestVars
"
	^SimpleCounters


]

{ #category : #'as yet unclassified' }
CanvasEncoder class >> killStats [

	SentTypesAndSizes := nil
]

{ #category : #'as yet unclassified' }
CanvasEncoder class >> nameForCode: aStringOrChar [

	| ch |
	ch := (aStringOrChar isString) ifTrue: [aStringOrChar first] ifFalse: [aStringOrChar].
	ch == self codeBalloonOval ifTrue: [^'balloon oval'].
	ch == self codeBalloonRect ifTrue: [^'balloon rectangle'].
	ch == self codeClip ifTrue: [^'clip'].
	ch == self codeExtentDepth ifTrue: [^'codeExtentDepth'].
	ch == self codeFont ifTrue: [^'codeFont'].
	ch == self codeTTCFont ifTrue: [^'codeTTCFont'].
	ch == self codeForce ifTrue: [^'codeForce'].
	ch == self codeImage ifTrue: [^'codeImage'].
	ch == self codeLine ifTrue: [^'codeLine'].
	ch == self codeOval ifTrue: [^'codeOval'].
	ch == self codePoly ifTrue: [^'codePoly'].
	ch == self codeRect ifTrue: [^'codeRect'].
	ch == self codeReleaseCache ifTrue: [^'codeReleaseCache'].
	ch == self codeStencil ifTrue: [^'codeStencil'].
	ch == self codeText ifTrue: [^'codeText'].
	ch == self codeTransform ifTrue: [^'codeTransform'].
	ch == self codeInfiniteFill ifTrue: [^'codeInfiniteFill'].
	ch == self codeShadowColor ifTrue: [^'shadowColor'].
	^'????'

]

{ #category : #'instance creation' }
CanvasEncoder class >> on: connection [
	^self new connection: connection
]

{ #category : #'as yet unclassified' }
CanvasEncoder class >> showStats [
"
CanvasEncoder showStats
"
	| answer |

	SentTypesAndSizes ifNil: [^Beeper beep].
	answer := WriteStream on: String new.
	SentTypesAndSizes keys asArray sort do: [ :each | | bucket |
		bucket := SentTypesAndSizes at: each.
		answer nextPutAll: each printString,' ',
				bucket first printString,'  ',
				bucket second asStringWithCommas,' ',
				(self nameForCode: each); cr.
	].
	StringHolder new contents: answer contents; openLabel: 'send/receive stats'.

]

{ #category : #'as yet unclassified' }
CanvasEncoder class >> timeSomeThings [
"
CanvasEncoder timeSomeThings
"
	| answer array color iter |

	iter := 1000000.
	array := Array new: 4.
	color := Color red.
	answer := String streamContents: [ :strm | | bm rect writer pt s |
		writer := [ :msg :doer | | ms |
			ms := [iter timesRepeat: doer] timeToRun.
			strm nextPutAll: msg,((ms * 1000 / iter) printShowingMaxDecimalPlaces: 2),' usec'; cr.
		].
		s := String new: 4.
		bm := Bitmap new: 20.
		pt := 100@300.
		rect := pt extent: pt.
	iter := 1000000.
		writer value: 'empty loop ' value: [self].
		writer value: 'modulo ' value: [12345678 \\ 256].
		writer value: 'bitAnd: ' value: [12345678 bitAnd: 255].
		strm cr.
	iter := 100000.
		writer value: 'putInteger ' value: [s putInteger32: 12345678 at: 1].
		writer value: 'bitmap put ' value: [bm at: 1 put: 12345678].
		writer value: 'encodeBytesOf: (big) ' value: [bm encodeInt: 12345678 in: bm at: 1].
		writer value: 'encodeBytesOf: (small) ' value: [bm encodeInt: 5000 in: bm at: 1].
		writer value: 'array at: (in) ' value: [array at: 1].
		writer value: 'array at: (out) ' value: [array at: 6 ifAbsent: []].
		strm cr.
	iter := 10000.
		writer value: 'color encode ' value: [color encodeForRemoteCanvas].
		writer value: 'pt encode ' value: [pt encodeForRemoteCanvas].
		writer value: 'rect encode ' value: [self encodeRectangle: rect].
		writer value: 'rect encode2 ' value: [rect encodeForRemoteCanvas].
		writer value: 'rect encodeb ' value: [rect encodeForRemoteCanvasB].
	].

	StringHolder new contents: answer; openLabel: 'send/receive stats'.

]

{ #category : #connection }
CanvasEncoder >> backlog [

	^connection backlog
]

{ #category : #drawing }
CanvasEncoder >> balloonFillOval: aRectangle fillStyle: aFillStyle borderWidth: bw borderColor: bc [

	self sendCommand: {
		String with: CanvasEncoder codeBalloonOval.
		self class encodeRectangle: aRectangle.
		aFillStyle encodeForRemoteCanvas.
		self class encodeInteger: bw.
		self class encodeColor: bc.
	}
]

{ #category : #drawing }
CanvasEncoder >> balloonFillRectangle: aRectangle fillStyle: aFillStyle [

	self sendCommand: {
		String with: CanvasEncoder codeBalloonRect.
		self class encodeRectangle: aRectangle.
		aFillStyle encodeForRemoteCanvas
	}
]

{ #category : #drawing }
CanvasEncoder >> cachingEnabled: aBoolean [

	(cachingEnabled := aBoolean) ifFalse: [
		cachedObjects := nil.
	].

]

{ #category : #connection }
CanvasEncoder >> connection: aStringSocket [
	"set this connection to talk over the given socket"

	cachingEnabled := true.
	connection := aStringSocket
]

{ #category : #'objects from disk' }
CanvasEncoder >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	cachingEnabled ifNil: [cachingEnabled := true].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.

]

{ #category : #network }
CanvasEncoder >> destroy [
	self disconnect.
]

{ #category : #connection }
CanvasEncoder >> disconnect [
	connection ifNotNil: [
		connection destroy.
		connection := nil.
	].
]

{ #category : #drawing }
CanvasEncoder >> drawPolygon: vertices color: aColor borderWidth: bw borderColor: bc [
	| encodedVertices |
	encodedVertices := vertices collect: [ :vertex | self class encodePoint: vertex ].

	self sendCommand: {
		String with: CanvasEncoder codePoly.
		self class encodeColor: aColor.
		self class encodeInteger: bw.
		self class encodeColor: bc},  encodedVertices .
]

{ #category : #drawing }
CanvasEncoder >> drawString: s from: firstIndex to: lastIndex in: boundsRect font: fontOrNil color: c [
	| fontIndex str |
	fontIndex := self establishFont: (fontOrNil ifNil: [ TextStyle defaultFont ]).
	str := s asString copyFrom: firstIndex to: lastIndex.
	str isWideString ifTrue: [
		self sendCommand: {
			String with: CanvasEncoder codeMultiText.
			str asByteArray asString.
			self class encodeRectangle: boundsRect.
			self class encodeInteger: fontIndex.
			self class encodeColor: c
		}
	] ifFalse: [
		self sendCommand: {
			String with: CanvasEncoder codeText.
			str.
			self class encodeRectangle: boundsRect.
			self class encodeInteger: fontIndex.
			self class encodeColor: c
		}
	].

]

{ #category : #fonts }
CanvasEncoder >> establishFont: aFont [
	"make sure that the given font is in the fonts cache.  If it is not there already, then transmit it.  Either way, after this returns, the font is in the cache at the index specified by the return value"
	| index |
	(fontCache includesFont: aFont) ifTrue: [ ^fontCache indexOf: aFont ].
	index := fontCache indexForNewFont: aFont.
	self sendFont: aFont atIndex: index.
	^index
]

{ #category : #drawing }
CanvasEncoder >> extent: newExtent  depth: newDepth [
	self sendCommand: {
		self class codeExtentDepth asString.
		self class encodePoint: newExtent. 
		self class encodeInteger: newDepth.
	}
]

{ #category : #drawing }
CanvasEncoder >> fillOval: r color: c borderWidth: borderWidth borderColor: borderColor [
	self sendCommand: {
		String with: CanvasEncoder codeOval.
		self class encodeRectangle: r.
		self class encodeColor: c.
		self class encodeInteger: borderWidth.
		self class encodeColor: borderColor
	}
]

{ #category : #network }
CanvasEncoder >> flush [
	connection ifNotNil: [
		connection flush ]
]

{ #category : #drawing }
CanvasEncoder >> forceToScreen: aRectangle [
	self sendCommand: {
		String with: CanvasEncoder codeForce.
		self class encodeRectangle: aRectangle }
]

{ #category : #drawing }
CanvasEncoder >> frameAndFillRectangle: r fillColor: fillColor borderWidth: borderWidth borderColor: borderColor [

	self sendCommand: {
		String with: CanvasEncoder codeRect.
		self class encodeRectangle: r.
		fillColor encodeForRemoteCanvas.
		self class encodeInteger: borderWidth.
		self class encodeColor: borderColor
	}
]

{ #category : #drawing }
CanvasEncoder >> image: aForm at: aPoint sourceRect: sourceRect rule: argRule [

	| cacheID cacheNew cacheReply formToSend cacheEntry destRect visRect aFormArea d2 rule |

	rule := argRule.

	"first if we are only going to be able to draw a small part of the form,
	it may be faster just to send the part of the form that will actually show up"

	destRect := aPoint extent: sourceRect extent.
	d2 := (lastTransform invertBoundsRect: destRect) expandBy: 1.
	(d2 intersects: lastClipRect) ifFalse: [
		^NebraskaDebug at: #bigImageSkipped add: {lastClipRect. d2}.
	].
	aFormArea := aForm boundingBox area.
	(aFormArea > 20000 and: [aForm isStatic not and: [lastTransform isPureTranslation]]) ifTrue: [
		visRect := destRect intersect: lastClipRect.
		visRect area < (aFormArea // 20) ifTrue: [
			"NebraskaDebug 
				at: #bigImageReduced 
				add: {lastClipRect. aPoint. sourceRect extent. lastTransform}."
			formToSend := aForm copy: (visRect translateBy: sourceRect origin - aPoint).
			formToSend depth = 32 ifTrue: [
				formToSend := formToSend asFormOfDepth: 16.
				(rule = 24 or: [rule = 34]) ifTrue: [rule := 25]].
			^self 
				image: formToSend 
				at: visRect origin 
				sourceRect: formToSend boundingBox
				rule: rule
				cacheID: 0 		"no point in trying to cache this - it's a one-timer"
				newToCache: false.
		].
	].

	cacheID := 0.
	cacheNew := false.
	formToSend := aForm.
	(aFormArea > 1000 and: [(cacheReply := self testCache: aForm) notNil]) ifTrue: [
		cacheID := cacheReply first.
		cacheEntry := cacheReply third.
		(cacheNew := cacheReply second) ifFalse: [
			formToSend := aForm isStatic 
				ifTrue: [nil] 
				ifFalse: [aForm depth <= 8 ifTrue: [aForm] ifFalse: [aForm deltaFrom: cacheEntry fourth]].
		].
		cacheEntry at: 4 put: (aForm isStatic ifTrue: [aForm] ifFalse: [aForm deepCopy]).
	].
	(formToSend notNil and: [
		formToSend depth = 32 and: [
			rule ~= 24 and: [
				rule ~= 34]]]) ifTrue: [
		formToSend := formToSend asFormOfDepth: 16.
	].
	self
		image: formToSend 
		at: aPoint 
		sourceRect: sourceRect 
		rule: rule 
		cacheID: cacheID 
		newToCache: cacheNew.


]

{ #category : #drawing }
CanvasEncoder >> image: aFormOrNil at: aPoint sourceRect: sourceRect rule: rule cacheID: cacheID newToCache: newToCache [

	| t destRect d2 |

	destRect := aPoint extent: sourceRect extent.
	d2 := (lastTransform invertBoundsRect: destRect) expandBy: 1.
	(d2 intersects: lastClipRect) ifFalse: [
		^NebraskaDebug at: #bigImageSkipped add: {lastClipRect. d2}.
	].
	t := Time millisecondsToRun: [
		self sendCommand: {
			String with: CanvasEncoder codeImage.
			self class encodeImage: aFormOrNil.
			self class encodePoint: aPoint.
			self class encodeRectangle: sourceRect.
			self class encodeInteger: rule.
			self class encodeInteger: cacheID.
			self class encodeInteger: (newToCache ifTrue: [1] ifFalse: [0]).
		}.
	].
	(aFormOrNil notNil and: [aFormOrNil boundingBox area > 10000]) ifTrue: [
		NebraskaDebug 
			at: #bigImage 
			add: {lastClipRect. aPoint. sourceRect extent. t. cacheID. newToCache}.
	].


]

{ #category : #drawing }
CanvasEncoder >> infiniteFillRectangle: aRectangle fillStyle: aFillStyle [

	self sendCommand: {
		String with: CanvasEncoder codeInfiniteFill.
		self class encodeRectangle: aRectangle.
		aFillStyle encodeForRemoteCanvas
	}
]

{ #category : #initialization }
CanvasEncoder >> initialize [

	cachingEnabled := true.
	fontCache := FontCache new: 5.
]

{ #category : #connection }
CanvasEncoder >> isConnected [
	^connection notNil and: [ connection isConnected ]
]

{ #category : #drawing }
CanvasEncoder >> line: pt1  to: pt2  width: w  color: c [

"Smalltalk at: #Q3 put: thisContext longStack."
	self sendCommand: {
		String with: CanvasEncoder codeLine.
		self class encodePoint: pt1.
		self class encodePoint: pt2.
		self class encodeInteger: w.
		self class encodeColor: c
	}
]

{ #category : #network }
CanvasEncoder >> processIO [
	connection ifNil: [ ^self ].
	connection isConnected ifFalse: [ ^self ].
	connection processIO.
]

{ #category : #drawing }
CanvasEncoder >> purgeCache [

	| spaceUsed spaceBefore s | 
	spaceBefore := spaceUsed := self purgeCacheInner.
	spaceBefore > 8000000 ifTrue: [
		Smalltalk garbageCollect.
		spaceUsed := self purgeCacheInner.
	].
	false ifTrue: [
		s := (spaceBefore // 1024) printString,'  ',(spaceUsed // 1024) printString,'  ',
			Time now printString,'     '.
		WorldState addDeferredUIMessage: [s displayAt: 0@0.].
	].
	^spaceUsed

]

{ #category : #drawing }
CanvasEncoder >> purgeCacheInner [

	| totalSize |

	cachedObjects ifNil: [^0].
	totalSize := 0.
	cachedObjects withIndexDo: [ :each :index | | cachedObject thisSize |
		cachedObject := each first first.
		cachedObject ifNil: [
			each second ifNotNil: [
				2 to: each size do: [ :j | each at: j put: nil].
				self sendCommand: {
					String with: CanvasEncoder codeReleaseCache.
					self class encodeInteger: index.
				}.
			].
		] ifNotNil: [
			thisSize := cachedObject depth * cachedObject width * cachedObject height // 8.
			totalSize := totalSize + thisSize.
		].
	].
	^totalSize
	"---
	newEntry := {
		WeakArray with: anObject.
		1.
		Time millisecondClockValue.
		nil.
	}.
	---"

]

{ #category : #connection }
CanvasEncoder >> purgeOutputQueue [

	connection purgeOutputQueue.
]

{ #category : #private }
CanvasEncoder >> sendCommand: stringArray [ 
	| bucket |
	connection ifNil: [^self].
	connection isConnected ifFalse: [^self].
	connection nextPut: stringArray.
	SentTypesAndSizes ifNil: [^self].
	bucket := SentTypesAndSizes at: stringArray first
				ifAbsentPut: 
					[{ 
						0.
						0.
						0}].
	bucket at: 1 put: bucket first + 1.
	bucket at: 2
		put: (bucket second) 
				+ (stringArray inject: 4 into: [:sum :array | sum + (array size + 4)])
]

{ #category : #fonts }
CanvasEncoder >> sendFont: aFont atIndex: index [
	"Transmits the given fint to the other side"

	| code |
	code := CanvasEncoder codeFont.
	(aFont isMemberOf: StrikeFontSet) ifTrue: [code := CanvasEncoder codeFontSet].
	aFont isTTCFont ifTrue: [code := CanvasEncoder codeTTCFont].
	self sendCommand: {
		String with: code.
		self class encodeInteger: index.
		self class encodeFont: aFont }.

]

{ #category : #'clipping and transforming' }
CanvasEncoder >> setClipRect: newClipRect [
	self sendCommand: {
		String with: CanvasEncoder codeClip.
		self class encodeRectangle: newClipRect }
]

{ #category : #'clipping and transforming' }
CanvasEncoder >> setTransform: newTransform [
	self sendCommand: {
		String with: CanvasEncoder codeTransform.
		self class encodeTransform: newTransform }
]

{ #category : #drawing }
CanvasEncoder >> shadowColor: aFillStyle [

	self sendCommand: {
		String with: CanvasEncoder codeShadowColor.
		aFillStyle ifNil: ['0'] ifNotNil: [aFillStyle encodeForRemoteCanvas].
	}
]

{ #category : #drawing }
CanvasEncoder >> stencil: stencilForm at: aPoint sourceRect: sourceRect color: aColor [
	self sendCommand: {
		String with: CanvasEncoder codeStencil.
		self class encodeImage: stencilForm.
		self class encodePoint: aPoint.
		self class encodeRectangle: sourceRect.
		self class encodeColor: aColor }
]

{ #category : #drawing }
CanvasEncoder >> testCache: anObject [ 
	| newEntry firstFree |
	cachingEnabled 
		ifFalse: 
			[cachedObjects := nil.
			^nil].
	cachedObjects ifNil: 
			[cachedObjects := (1 to: 100) collect: 
							[:x | 
							{ 
								WeakArray new: 1.
								nil.
								nil.
								nil}]].
	self purgeCache.
	firstFree := nil.
	cachedObjects withIndexDo: 
			[:each :index | | cachedObject | 
			cachedObject := each first first.
			firstFree ifNil: [cachedObject ifNil: [firstFree := index]].
			cachedObject == anObject 
				ifTrue: 
					[each at: 2 put: (each second) + 1.
					^{ 
						index.
						false.
						each}]].
	firstFree ifNil: [^nil].
	newEntry := { 
				WeakArray with: anObject.
				1.
				Time millisecondClockValue.
				nil}.
	cachedObjects at: firstFree put: newEntry.
	^{ 
		firstFree.
		true.
		newEntry}
]

{ #category : #drawing }
CanvasEncoder >> testRectangleFillTiming [
| r fillColor borderWidth borderColor t |
"
CanvasEncoder new testRectangleFillTiming
"
	r := 100@100 extent: 300@300.
	fillColor := Color blue.
	borderWidth := 1.
	borderColor := Color red.
	t := Time millisecondsToRun: [
		1000 timesRepeat: [
		{
		String with: CanvasEncoder codeRect.
		self class encodeRectangle: r.
		self class encodeColor: fillColor.
		self class encodeInteger: borderWidth.
		self class encodeColor: borderColor }
		].
	].
	t inspect.
]

{ #category : #'clipping and transforming' }
CanvasEncoder >> updateTransform: aTransform andClipRect: aClipRect [
	"sets the given transform and clip rectangle, if they aren't already the ones being used"
	aTransform = lastTransform ifFalse: [
		self setTransform: aTransform.
		lastTransform := aTransform ].

	aClipRect = lastClipRect ifFalse: [
		self setClipRect: aClipRect.
		lastClipRect := aClipRect. ].
]
