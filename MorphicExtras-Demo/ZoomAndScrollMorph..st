"
I am the outer part of a transformed view of another pasteup. I know how to translate requests to pan, tilt and zoom into appropriate changes to the transformation
"
Class {
	#name : #ZoomAndScrollMorph,
	#superclass : #PasteUpMorph,
	#instVars : [
		'sourceRectangle',
		'usingBalloon',
		'panAndTiltFactor',
		'zoomFactor'
	],
	#category : #'MorphicExtras-Demo'
}

{ #category : #layout }
ZoomAndScrollMorph >> acceptDroppingMorph: morphToDrop event: evt [

	^morphToDrop rejectDropMorphEvent: evt.		"put it back where it came from"


]

{ #category : #scripting }
ZoomAndScrollMorph >> cameraPoint [

	^self myTransformMorph transform globalPointToLocal: self innerBounds center


]

{ #category : #scripting }
ZoomAndScrollMorph >> cameraPoint: newPt [

	| transform |

	transform := self myTransformMorph.
	self changeOffsetTo: newPt * transform scale - (transform innerBounds extent // 2) 


]

{ #category : #accessing }
ZoomAndScrollMorph >> changeOffsetBy: aPoint [

	| transform rounder roundPt |

	"improve behavior at high magnification by rounding change to whole source pixels"
	transform := self myTransformMorph.
	rounder := [ :val |
		"(val abs + (transform scale * 0.99) roundTo: transform scale) * val sign"
		"looks like rounding wasn't a good solution"
		val
	].
	roundPt := (rounder value: aPoint x) @ (rounder value: aPoint y).

	self changeOffsetTo: transform offset + roundPt.

]

{ #category : #accessing }
ZoomAndScrollMorph >> changeOffsetTo: aPoint [

	| transform trialOffset innerPasteup keepWidth keepHeight |

	transform := self myTransformMorph.
	keepWidth := transform width "// 4".
	keepHeight := transform height "// 4".
	innerPasteup := transform firstSubmorph.
	trialOffset := aPoint.
	trialOffset := 
		(trialOffset x 
			min: (innerPasteup width * transform scale) - keepWidth 
			max: keepWidth - transform width) @ 
		(trialOffset y 
			min: (innerPasteup height * transform scale) - keepHeight 
			max: keepHeight - transform height).
	transform offset: trialOffset.


]

{ #category : #accessing }
ZoomAndScrollMorph >> changeScaleTo: aNumber [

	| transform innerPasteup min1 min2 newScale oldPoint |

	transform := self myTransformMorph.
	"oldScale := transform scale."
	innerPasteup := transform firstSubmorph.

	min1 := transform width / innerPasteup width asFloat.
	min2 := transform height / innerPasteup height asFloat.
	newScale := (aNumber max: min1) max: min2.

	oldPoint := self cameraPoint.
	transform scale: newScale.
	self cameraPoint: oldPoint.

	"scaleR := newScale / oldScale.
	half := transform extent // 2.
	half := 0@0.
	self changeOffsetBy: scaleR * (transform offset + half) - half - transform offset."

"==Alan's preferred factors
pan = 0.0425531914893617
zoom = 0.099290780141844
==="

]

{ #category : #accessing }
ZoomAndScrollMorph >> changeTiltFactor: x [

	panAndTiltFactor := x
]

{ #category : #accessing }
ZoomAndScrollMorph >> changeZoomFactor: x [

	zoomFactor := x
]

{ #category : #initialization }
ZoomAndScrollMorph >> createInteriorTransform [

	| innerPasteUp tm |
	innerPasteUp := PasteUpMorph new.
	innerPasteUp 
		borderWidth: 0;
		minHeight: 100;
		minWidth: 100;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		position: 0@0;
		extent: 100@100.
	tm := TransformationB2Morph new.
	tm setProperty: #rotationCenter toValue: 0@0.
	tm useRegularWarpBlt: usingBalloon not.
	self addMorph: tm.
	tm addMorph: innerPasteUp.
	tm beSticky.
	innerPasteUp beSticky.
	tm
		scale: 1.0;
		offset: 0@0.
	
]

{ #category : #initialization }
ZoomAndScrollMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color red
]

{ #category : #initialization }
ZoomAndScrollMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #geometry }
ZoomAndScrollMorph >> extent: extentPoint [

	super extent: extentPoint.
	self myTransformMorph bounds: self innerBounds.

]

{ #category : #accessing }
ZoomAndScrollMorph >> getTiltFactor [

	^panAndTiltFactor ifNil: [panAndTiltFactor := 0.5].
	

]

{ #category : #accessing }
ZoomAndScrollMorph >> getZoomFactor [

	^zoomFactor ifNil: [zoomFactor := 0.5].
	

]

{ #category : #initialization }
ZoomAndScrollMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	usingBalloon := true.
	self createInteriorTransform 
]

{ #category : #scripting }
ZoomAndScrollMorph >> myTransformMorph [

	^self firstSubmorph

]

{ #category : #scripting }
ZoomAndScrollMorph >> offsetX [

	^self myTransformMorph offset x

]

{ #category : #scripting }
ZoomAndScrollMorph >> offsetX: aNumber [

	| transform |

	transform := self myTransformMorph.
	transform offset: aNumber @ transform offset y

]

{ #category : #scripting }
ZoomAndScrollMorph >> offsetY [

	^self myTransformMorph offset y

]

{ #category : #scripting }
ZoomAndScrollMorph >> offsetY: aNumber [

	| transform |

	transform := self myTransformMorph.
	transform offset: transform offset x @ aNumber

]

{ #category : #transformations }
ZoomAndScrollMorph >> panImageBy: pixels [

	self changeOffsetBy: (pixels * self getTiltFactor * 0.1) @ 0.

	"steps := (pixels abs / 6) exp rounded * pixels sign."
"==Alan's preferred factors
pan = 0.0425531914893617
zoom = 0.099290780141844
==="


]

{ #category : #scripting }
ZoomAndScrollMorph >> scale [

	^self myTransformMorph scale

]

{ #category : #scripting }
ZoomAndScrollMorph >> scale: aValue [

	self myTransformMorph scale: aValue.

]

{ #category : #transformations }
ZoomAndScrollMorph >> scaleImageBy: pixels [

	| scalePerPixel steps transform factor |

	transform := self myTransformMorph.
	(steps := (pixels * self getZoomFactor * 0.2) rounded) = 0 ifTrue: [^self].
	scalePerPixel := 1.01.
	factor := scalePerPixel raisedTo: steps abs.
	steps > 0 ifTrue: [
		factor := 1.0 / factor.
	].
	self changeScaleTo: (transform scale * factor min: 10.0 max: 0.1).

]

{ #category : #'stepping and presenter' }
ZoomAndScrollMorph >> step [

	| innerPasteUp overlap |

	innerPasteUp := self myTransformMorph firstSubmorph.
	overlap := (innerPasteUp submorphs 
		inject: 0@0 
		into: [ :min :each | min min: each position]) rounded.
	overlap = (0@0) ifFalse: [
		innerPasteUp submorphs do: [ :each | each position: each position - overlap].
		innerPasteUp layoutChanged.
	].




]

{ #category : #'stepping and presenter' }
ZoomAndScrollMorph >> stepTime [

	^10		"ms"
]

{ #category : #transformations }
ZoomAndScrollMorph >> tiltImageBy: pixels [

	self changeOffsetBy: 0 @ (pixels * self getTiltFactor * 0.1)

"	steps := (pixels abs / 6) exp rounded * pixels sign.
"
"==Alan's preferred factors
pan = 0.0425531914893617
zoom = 0.099290780141844
==="

]

{ #category : #'dropping\/grabbing' }
ZoomAndScrollMorph >> wantsDroppedMorph: aMorph event: evt [

	"we don't, really, but it avoids problem of outer pasteup rejecting a drop for inner pasteup"
	^true
]
