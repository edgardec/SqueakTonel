"
I am the morph the user grabs to adjust pane splitters.
"
Class {
	#name : #ProportionalSplitterMorph,
	#superclass : #AbstractResizerMorph,
	#instVars : [
		'leftOrTop',
		'rightOrBottom',
		'splitsTopAndBottom',
		'traceMorph',
		'movements'
	],
	#classVars : [
		'SmartHorizontalSplitters',
		'SmartVerticalSplitters'
	],
	#category : #'Morphic-Windows'
}

{ #category : #preferences }
ProportionalSplitterMorph class >> fastSplitterResize [
	
	^ Preferences fastDragWindowForMorphic
]

{ #category : #private }
ProportionalSplitterMorph class >> preferenceChanged: aBoolean [ 
	"Take immediate effect for all in a  World."
	self allInstances do:
		[ : each | (each isInWorld and: [ aBoolean and: [ each wantsSteps ] ])
			ifTrue: [ each startStepping ]
			ifFalse: [ each stopStepping ] ]
]

{ #category : #preferences }
ProportionalSplitterMorph class >> showSplitterHandles [

	^ Preferences valueOfPreference: #showSplitterHandles ifAbsent: [true]
]

{ #category : #preferences }
ProportionalSplitterMorph class >> showSplitterHandles: aBoolean [

	Preferences setPreference: #showSplitterHandles toValue: aBoolean.
	Project current restoreDisplay.
]

{ #category : #preferences }
ProportionalSplitterMorph class >> smartHorizontalSplitters [
	<preference: 'Smart Horizontal Splitters'
		category: 'Morphic'
		description: 'When true, horizontal splitter bars will automatically reposition themselves to increase the quantity of exposed information, if possible..'
		type: #Boolean>
	^ SmartHorizontalSplitters ifNil: [ false ]
]

{ #category : #preferences }
ProportionalSplitterMorph class >> smartHorizontalSplitters: aBoolean [ 
	SmartHorizontalSplitters := aBoolean.
	self preferenceChanged: aBoolean
]

{ #category : #preferences }
ProportionalSplitterMorph class >> smartVerticalSplitters [
	<preference: 'Smart Vertical Splitters'
		category: 'Morphic'
		description: 'When true, vertical bars between lists will automatically reposition themselves to balance the number of characters occluded on either side of the bar.'
		type: #Boolean>
	^ SmartVerticalSplitters ifNil: [ false ]
]

{ #category : #preferences }
ProportionalSplitterMorph class >> smartVerticalSplitters: aBoolean [ 
	SmartVerticalSplitters := aBoolean.
	self preferenceChanged: aBoolean
]

{ #category : #initialization }
ProportionalSplitterMorph >> addLeftOrTop: aMorph [

	leftOrTop add: aMorph
]

{ #category : #initialization }
ProportionalSplitterMorph >> addRightOrBottom: aMorph [

	rightOrBottom add: aMorph.
	
	
]

{ #category : #events }
ProportionalSplitterMorph >> balanceOffsets [

	| fdx fdy |

	(self hasProperty: #fullDelta) ifFalse: [^ self].

	fdx := (self valueOfProperty: #fullDelta) x.
	fdy := (self valueOfProperty: #fullDelta) y.

	self layoutFrame hasFixedHeight ifTrue: [
		| otop obot ctop cbot topf |

		otop := (owner submorphs detect: [:m | 
					m layoutFrame topFraction isZero] ifNone: [^ self]) in: [:tm | 
						tm top - (tm layoutFrame topOffset)].

		obot := (owner submorphs detect: [:m | 
					m layoutFrame bottomFraction = 1] ifNone: [^ self]) in: [:tm | 
						tm bottom - (tm layoutFrame bottomOffset)].

		ctop := (self layoutFrame topFraction * (obot - otop)) rounded 
					+ otop + (self layoutFrame topOffset).
		cbot := (self layoutFrame bottomFraction * (obot - otop)) rounded 
					+ otop + (self layoutFrame bottomOffset).

		topf := self layoutFrame topFraction.
		self layoutFrame topFraction:  ((ctop + cbot) * 0.5 - otop) / (obot - otop) asFloat.
		self layoutFrame bottomFraction: self layoutFrame topFraction.
		self layoutFrame topOffset: self layoutFrame topOffset - fdy.
		self layoutFrame bottomOffset: self layoutFrame bottomOffset - fdy.

		(leftOrTop copy union: rightOrBottom) do: [:m |
			(m layoutFrame topFraction closeTo: topf) ifTrue: [
				m layoutFrame topFraction: self layoutFrame topFraction.
				m layoutFrame topOffset: m layoutFrame topOffset - fdy].
			(m layoutFrame bottomFraction closeTo: topf) ifTrue: [
				m layoutFrame bottomFraction: self layoutFrame topFraction.
				m layoutFrame bottomOffset: m layoutFrame bottomOffset - fdy]]] .

	self layoutFrame hasFixedWidth ifTrue: [
		| oleft oright cleft cright leftf |

		oleft := (owner submorphs detect: [:m | 
			m layoutFrame leftFraction isZero] ifNone: [^ self]) in: [:tm | 
				tm left - (tm layoutFrame leftOffset)].

		oright := (owner submorphs detect: [:m | 
			m layoutFrame rightFraction = 1] ifNone: [^ self]) in: [:tm | 
				tm right - (tm layoutFrame rightOffset)].

		cleft := (self layoutFrame leftFraction * (oright - oleft)) rounded 
					+ oleft + (self layoutFrame leftOffset).
		cright := (self layoutFrame rightFraction * (oright - oleft)) rounded 
					+ oleft + (self layoutFrame rightOffset).

		leftf := self layoutFrame leftFraction.
		self layoutFrame leftFraction: ((cleft + cright) * 0.5 - oleft) / (oright - oleft) asFloat.
		self layoutFrame rightFraction: self layoutFrame leftFraction.


		self layoutFrame leftOffset: self layoutFrame leftOffset - fdx.
		self layoutFrame rightOffset: self layoutFrame rightOffset - fdx.

		(leftOrTop copy union: rightOrBottom) do: [:m |
			(m layoutFrame leftFraction closeTo: leftf) ifTrue: [
				m layoutFrame leftFraction: self layoutFrame leftFraction.
				m layoutFrame leftOffset: m layoutFrame leftOffset - fdx].
			(m layoutFrame rightFraction closeTo: leftf) ifTrue: [
				m layoutFrame rightFraction: self layoutFrame leftFraction.
				m layoutFrame rightOffset: 	m layoutFrame rightOffset - fdx.]]] .
		
	self removeProperty: #fullDelta.
	owner layoutChanged

]

{ #category : #initialization }
ProportionalSplitterMorph >> beSplitsLeftAndRight [

	splitsTopAndBottom := false.
	self
		hResizing: #rigid;
		vResizing: #spaceFill.
	self width: self class gripThickness.
]

{ #category : #initialization }
ProportionalSplitterMorph >> beSplitsTopAndBottom [

	splitsTopAndBottom := true.
	self
		vResizing: #rigid;
		hResizing: #spaceFill.
	self height: self class gripThickness.
]

{ #category : #'queries - controlled morphs' }
ProportionalSplitterMorph >> bordersOn: aMorph [
	"Answer true if the aMorph is one of my neighbours."

	^ (leftOrTop includes: aMorph) or: [rightOrBottom includes: aMorph]
]

{ #category : #'queries - geometry' }
ProportionalSplitterMorph >> bottomBoundary [
	"Answert the bottommost x position the receiver could be moved."

	| splitter morphs |
	splitter := self splitterBelow.
	morphs := self commonNeighbours: rightOrBottom with: splitter.
	^ (splitter
		ifNil: [owner isSystemWindow ifTrue: [owner panelRect bottom]
				ifFalse: [owner innerBounds bottom]]
		ifNotNil: [splitter top])
		- (self minimumHeightOf: morphs)
]

{ #category : #'smart splitters - queries' }
ProportionalSplitterMorph >> canEncroachWhiteSpaceOf: morphs [ 
	^ morphs allSatisfy: [ : each | each canBeEncroached ]
]

{ #category : #'smart splitters - queries' }
ProportionalSplitterMorph >> charactersOccludedIn: aCollection [
	^ aCollection
		inject: 0
		into:
			[ : sum : each | sum +
				(each isMorphicModel
					ifTrue: [ each charactersOccluded ]
					ifFalse: [ 0 ]) ]
]

{ #category : #'queries - controlled morphs' }
ProportionalSplitterMorph >> commonNeighbours: morphs with: aProportionalSplitterMorphOrNil [
	"Answer the subset of morphs which is also confined by aProportionalSplitterMorphOrNil."

	^ aProportionalSplitterMorphOrNil isNil
		ifTrue: [morphs]
		ifFalse: [morphs select: [ :which |
				aProportionalSplitterMorphOrNil bordersOn: which]]
]

{ #category : #drawing }
ProportionalSplitterMorph >> drawOn: aCanvas [

	super drawOn: aCanvas.
	
	self showHandle ifTrue: [
		self splitsLeftAndRight ifTrue: [
			aCanvas
				fillRoundRect: (((self width - (self handleInset * 2) max: 1) @ (self height * 0.25 min: self class handleLength)) center: self center)
				radius: 3
				fillStyle: (SolidFillStyle color: self handleColor)].
		self splitsTopAndBottom ifTrue: [
			aCanvas
				fillRoundRect: (((self width * 0.25 min: self class handleLength) @ (self height - (self handleInset * 2) max: 1)) center: self center)
				radius: 3
				fillStyle: (SolidFillStyle color: self handleColor)] ].
]

{ #category : #initialization }
ProportionalSplitterMorph >> initialize [

	super initialize.
	
	self beSplitsLeftAndRight.
	
	leftOrTop := OrderedCollection new.
	rightOrBottom := OrderedCollection new.
	
	self initializeMovements.
]

{ #category : #'smart splitters' }
ProportionalSplitterMorph >> initializeMovements [
	movements := OrderedCollection new: 3 withAll: 0
]

{ #category : #'queries - geometry' }
ProportionalSplitterMorph >> leftBoundary [
	"Answer the leftmost y position the receiver could be moved."

	| splitter morphs |
	splitter := self splitterLeft.
	morphs := self commonNeighbours: leftOrTop with: splitter.
	^ (splitter
		ifNil: [owner isSystemWindow ifTrue: [owner panelRect left]
				ifFalse: [owner innerBounds left]]
		ifNotNil: [splitter right])
		 + (self minimumWidthOf: morphs)
]

{ #category : #'smart splitters - queries' }
ProportionalSplitterMorph >> leftRightImbalance [
	"First check if I find myself out of range due to user having reduced size of parent."
	^ self left < self leftBoundary "too far left"
		ifTrue: [ self leftBoundary-self left ]
		ifFalse:
			[ self right > self rightBoundary "too far right"
				ifTrue: [ self rightBoundary-self right ]
				ifFalse: [ self occlusionDifference ] ]
]

{ #category : #'queries - geometry' }
ProportionalSplitterMorph >> minimumHeightOf: aCollection [
	"Answer the minimum height needed to display any of the morphs in aCollection.
	See ProportionalLayout >> #minExtentOf:in:."

	^ aCollection inject: 0 into: [ :height :morph |
		| minHeight |
		minHeight := morph minHeight.
		"morph layoutFrame ifNotNil: [:frame |
			minHeight := frame minHeightFrom: minHeight]."
		minHeight + self height max: height]
]

{ #category : #'queries - geometry' }
ProportionalSplitterMorph >> minimumWidthOf: aCollection [
	"Answer the minimum width needed to display any of the morphs in aCollection.
	See ProportionalLayout >> #minExtentOf:in:."
	
	^ aCollection inject: 0 into: [ :width :morph |
		| minWidth |
		minWidth := morph minWidth.
		"morph layoutFrame ifNotNil: [:frame |
			minWidth := frame minWidthFrom: minWidth]."
		minWidth + self width max: width]
]

{ #category : #events }
ProportionalSplitterMorph >> mouseDown: anEvent [ 
	"If the user manually drags me, don't override him with auto positioning."

	self setProperty: #fullDelta toValue: 0@0.

	anEvent redButtonChanged
		ifTrue: [ self withSiblingSplittersDo: [ : each | each stopStepping ] ]
		ifFalse:
			[ anEvent shiftPressed
				ifTrue: [ self startStepping ]
				ifFalse:
					[ self startStepping.
					self withSiblingSplittersDo: [ : each | each startStepping ] ] ].

	^ super mouseDown: anEvent
]

{ #category : #events }
ProportionalSplitterMorph >> mouseMove: anEvent [ 
	anEvent hand temporaryCursor
		ifNil: [^ self].
	self class fastSplitterResize
		ifFalse:  [self updateFromEvent: anEvent]
		ifTrue: [traceMorph
				ifNil: [traceMorph := Morph newBounds: self bounds.
					traceMorph color: (Color gray alpha: 0.5).
					traceMorph borderWidth: 0.
					self owner addMorph: traceMorph].
			splitsTopAndBottom
				ifTrue: [traceMorph position: traceMorph position x @ (self normalizedY: anEvent cursorPoint y)]
				ifFalse: [traceMorph position: (self normalizedX: anEvent cursorPoint x) @ traceMorph position y]]
]

{ #category : #events }
ProportionalSplitterMorph >> mouseUp: anEvent [ 
	(self bounds containsPoint: anEvent cursorPoint) ifFalse: [ anEvent hand showTemporaryCursor: nil ].
	self class fastSplitterResize ifTrue: [ self updateFromEvent: anEvent ].
	traceMorph ifNotNil:
		[ traceMorph delete.
		traceMorph := nil ].

	"balanceOffsets currently disrupts Smart Splitter behavior."
	(ProportionalSplitterMorph smartVerticalSplitters or: [ ProportionalSplitterMorph smartHorizontalSplitters ]) ifFalse: [ self balanceOffsets ]
]

{ #category : #'smart splitters' }
ProportionalSplitterMorph >> movements [
	"Used to track my pattern of movement for the last 3 steps to fix the twitching."
"Lazy-init for now for smooth transition -- want to convert this back to direct-var access after a few months."
	^ movements ifNil: [ self initializeMovements. movements ]
]

{ #category : #'queries - geometry' }
ProportionalSplitterMorph >> normalizedX: x [

	^ (x max: self leftBoundary) min: self rightBoundary
]

{ #category : #'queries - geometry' }
ProportionalSplitterMorph >> normalizedY: y [

	^ (y max: self topBoundary) min: self bottomBoundary
]

{ #category : #'smart splitters - queries' }
ProportionalSplitterMorph >> occlusionDifference [
	^ (self charactersOccludedIn: leftOrTop) - (self charactersOccludedIn: rightOrBottom)
]

{ #category : #'smart splitters - queries' }
ProportionalSplitterMorph >> proposedCorrectionWouldCauseFocusChange: correction [ 
	^ Preferences mouseOverForKeyboardFocus and:
		[ | edge | splitsTopAndBottom
			ifTrue:
				[ edge := correction positive
					ifTrue: [ self bottom + 3 ]
					ifFalse: [ self top - 3 ].
				self activeHand position y
					inRangeOf: edge
					and: edge + correction ]
			ifFalse:
				[ edge := correction positive
					ifTrue: [ self right ]
					ifFalse: [ self left ].
				self activeHand position x
					inRangeOf: edge
					and: edge + correction ] ]
]

{ #category : #'smart splitters' }
ProportionalSplitterMorph >> reduceLeftRightImbalance [
	| correction |
	correction := self leftRightImbalance.
	correction abs > 1
		ifTrue:
			[ (self proposedCorrectionWouldCauseFocusChange: correction) ifFalse:
				[ self repositionBy:
					(correction abs > 4
						ifTrue: [ correction sign * 2 @ 0 ]
						ifFalse: [ correction sign @ 0 ]) ] ]
		ifFalse:
			[ self class smartVerticalSplitters ifFalse: [ self stopStepping ] ].
	^ correction
]

{ #category : #'smart splitters' }
ProportionalSplitterMorph >> reduceTopBottomImbalance [
	| correction |
	(correction := self topBottomCorrection) isZero
		ifTrue:
			[ self class smartHorizontalSplitters ifFalse: [ self stopStepping ] ]
		ifFalse:
			[ (self proposedCorrectionWouldCauseFocusChange: correction) ifFalse: [ self repositionBy: 0 @ correction ] ].
	^ correction
]

{ #category : #events }
ProportionalSplitterMorph >> repositionBy: delta [
	| selfTop selfBottom selfLeft selfRight |

	self setProperty: #fullDelta toValue: ((self valueOfProperty: #fullDelta) ifNil: [0@0]) + delta.

	leftOrTop do:
		[ : each | | firstRight firstBottom firstLeft firstTop |
		firstRight := each layoutFrame rightOffset.
		firstBottom := each layoutFrame bottomOffset.
		each layoutFrame rightOffset: firstRight + delta x.
		each layoutFrame bottomOffset: firstBottom + delta y.
		each layoutFrame hasFixedHeight ifTrue: [
			firstTop := each layoutFrame topOffset.
			each layoutFrame topOffset: firstTop + delta y ].
		each layoutFrame hasFixedWidth ifTrue: [
			firstLeft := each layoutFrame leftOffset.
			each layoutFrame leftOffset: firstLeft + delta x. ] ].
	rightOrBottom do:
		[ : each | | secondLeft secondTop secondRight secondBottom |
		secondLeft := each layoutFrame leftOffset.
		secondTop := each layoutFrame topOffset.
		each layoutFrame leftOffset: secondLeft + delta x.
		each layoutFrame topOffset: secondTop + delta y.
		each layoutFrame hasFixedHeight ifTrue: [
			secondBottom := each layoutFrame bottomOffset.
			each layoutFrame bottomOffset: secondBottom + delta y. ].
		each layoutFrame hasFixedWidth ifTrue: [
			secondRight := each layoutFrame rightOffset.
			each layoutFrame rightOffset: secondRight + delta x. ] ].

	selfTop := self layoutFrame topOffset.
	selfBottom := self layoutFrame bottomOffset.
	selfLeft := self layoutFrame leftOffset.
	selfRight := self layoutFrame rightOffset.
	self layoutFrame
		 topOffset: selfTop + delta y ;
		 bottomOffset: selfBottom + delta y ;
		 leftOffset: selfLeft + delta x ;
		 rightOffset: selfRight + delta x.
	self owner layoutChanged.
	self movements removeFirst; add: (splitsTopAndBottom ifTrue: [ delta y sign ] ifFalse: [ delta x sign ])
]

{ #category : #accessing }
ProportionalSplitterMorph >> resizeCursor [

	^ Cursor resizeForEdge: (splitsTopAndBottom
		ifTrue: [#top]
		ifFalse: [#left])
		
]

{ #category : #'queries - geometry' }
ProportionalSplitterMorph >> rightBoundary [
	"Answer the rightmost x position the receiver could be moved to."

	| splitter morphs |
	splitter := self splitterRight.
	morphs := self commonNeighbours: rightOrBottom with: splitter.
	
	^ (splitter
		ifNil: [owner isSystemWindow ifTrue: [owner panelRect right]
				ifFalse: [owner innerBounds right]]
		ifNotNil: [splitter left])
		- (self minimumWidthOf: morphs)
]

{ #category : #accessing }
ProportionalSplitterMorph >> showHandle [

	^ showHandle ifNil: [self class showSplitterHandles]
]

{ #category : #'queries - adjacent splitters' }
ProportionalSplitterMorph >> siblingSplittersDo: aBlock [ 
	owner ifNotNil:
		[ owner submorphsDo:
			[ : each | ((each isKindOf: self class) and:
				[ self splitsTopAndBottom = each splitsTopAndBottom and: [ each ~= self ] ]) ifTrue: [ aBlock value: each ] ] ]
]

{ #category : #testing }
ProportionalSplitterMorph >> splitsLeftAndRight [

	^ self splitsTopAndBottom not
]

{ #category : #testing }
ProportionalSplitterMorph >> splitsTopAndBottom [

	^ splitsTopAndBottom
]

{ #category : #'queries - adjacent splitters' }
ProportionalSplitterMorph >> splitterAbove [
	| immediatelyAbove |
	immediatelyAbove := nil.
	self siblingSplittersDo:
		[ : each | "Splitter y's map 0 at the bottom."
		each y > self y ifTrue:
			[ immediatelyAbove
				ifNil: [ immediatelyAbove := each ]
				ifNotNil:
					[ each y < immediatelyAbove y ifTrue: [ immediatelyAbove := each ] ] ] ].
	^ immediatelyAbove
]

{ #category : #'queries - adjacent splitters' }
ProportionalSplitterMorph >> splitterBelow [
	| immediatelyBelow |
	immediatelyBelow := nil.
	self siblingSplittersDo:
		[ : each | each y < self y ifTrue:
			[ immediatelyBelow
				ifNil: [ immediatelyBelow := each ]
				ifNotNil:
					[ each y > immediatelyBelow y ifTrue: [ immediatelyBelow := each ] ] ] ].
	^ immediatelyBelow
]

{ #category : #'queries - adjacent splitters' }
ProportionalSplitterMorph >> splitterLeft [
	| immediateLeft |
	immediateLeft := nil.
	self siblingSplittersDo:
		[ : each | each x < self x ifTrue:
			[ immediateLeft
				ifNil: [ immediateLeft := each ]
				ifNotNil:
					[ each x > immediateLeft x ifTrue: [ immediateLeft := each ] ] ] ].
	^ immediateLeft
]

{ #category : #'queries - adjacent splitters' }
ProportionalSplitterMorph >> splitterRight [
	| immediateRight |
	immediateRight := nil.
	self siblingSplittersDo:
		[ : each | each x > self x ifTrue:
			[ immediateRight
				ifNil: [ immediateRight := each ]
				ifNotNil:
					[ each x < immediateRight x ifTrue: [ immediateRight := each ] ] ] ].
	^ immediateRight
]

{ #category : #'queries - adjacent splitters' }
ProportionalSplitterMorph >> splittersAboveDo: aBlock [ 
	self splitterAbove ifNotNil:
		[ : splitter | aBlock value: splitter.
		splitter splittersAboveDo: aBlock ]
]

{ #category : #'queries - adjacent splitters' }
ProportionalSplitterMorph >> splittersBelowDo: aBlock [ 
	self splitterBelow ifNotNil:
		[ : splitter | aBlock value: splitter.
		splitter splittersBelowDo: aBlock ]
]

{ #category : #'queries - adjacent splitters' }
ProportionalSplitterMorph >> splittersLeftDo: aBlock [ 
	self splitterLeft ifNotNil:
		[ : splitter | aBlock value: splitter.
		splitter splittersLeftDo: aBlock ]
]

{ #category : #'queries - adjacent splitters' }
ProportionalSplitterMorph >> splittersRightDo: aBlock [ 
	self splitterRight ifNotNil:
		[ : splitter | aBlock value: splitter.
		splitter splittersRightDo: aBlock ]
]

{ #category : #'smart splitters - stepping' }
ProportionalSplitterMorph >> step [
	splitsTopAndBottom
		ifTrue: [ self reduceTopBottomImbalance ]
		ifFalse:
			[ self reduceLeftRightImbalance abs > 1 ifTrue:
				[ self splittersLeftDo:
					[ : splitter | splitter reduceLeftRightImbalance ].
				self splittersRightDo:
					[ : splitter | splitter reduceLeftRightImbalance ] ] ]
]

{ #category : #'smart splitters - stepping' }
ProportionalSplitterMorph >> stepTime [
	"When a splitter finds itself in the right place, let it rest for about 3 seconds to avoid performance impacts of constant, rapid stepping."
	| pause |
	pause := 3000. "Frozen image when atRandom failed due to lock on its Mutex."
	^ ({#(1 -1 1 ).  #(-1 1 -1 )} includes: self movements asArray)
		ifTrue: [ pause "don't twitch" ]
		ifFalse:
			[ splitsTopAndBottom
				ifTrue:
					[ self topBottomCorrection isZero
						ifTrue: [ pause ]
						ifFalse: [ 0 ] ]
				ifFalse:
					[ self leftRightImbalance abs > 1
						ifTrue: [ ">1 rather than 0 to discourage one-off twitching"
							0 ]
						ifFalse: [ pause ] ] ]
]

{ #category : #'smart splitters - stepping' }
ProportionalSplitterMorph >> stopStepping [
	super stopStepping.
	(self class smartVerticalSplitters or: [ self class smartHorizontalSplitters ]) ifFalse: [ self balanceOffsets ]
]

{ #category : #'smart splitters - queries' }
ProportionalSplitterMorph >> topBottomCorrection [
	^ self top < self topBoundary
		ifTrue: [ self topBoundary - self top ]
		ifFalse:
			[ self bottom > (self bottomBoundary)
				ifTrue: [ self bottomBoundary - self bottom ]
				ifFalse:
					[ | wsAbove wsBelow |
					wsAbove := self canEncroachWhiteSpaceOf: leftOrTop.
					wsBelow := self canEncroachWhiteSpaceOf: rightOrBottom.
					wsAbove
						ifTrue:
							[ wsBelow
								ifTrue:
									[ self splitterBelow
										ifNil: [0]
										ifNotNil: [ : below | below reduceTopBottomImbalance min: 0 ] ]
								ifFalse: [ (self top > self topBoundary) ifTrue: [-2] ifFalse: [0] ] ]
						ifFalse:
							[ wsBelow
								ifTrue: [ (self bottom < self bottomBoundary) ifTrue: [2] ifFalse: [0] ]
								ifFalse:
									[ self splitterBelow
										ifNil: [0]
										ifNotNil: [ : below | below reduceTopBottomImbalance max: 0 ] ] ] ] ]
]

{ #category : #'queries - geometry' }
ProportionalSplitterMorph >> topBoundary [
	"Answer the topmost x position the receiver could be moved to."

	| splitter morphs |
	splitter := self splitterAbove.
	morphs := self commonNeighbours: leftOrTop with: splitter.
	^ (splitter
		ifNil: [owner isSystemWindow ifTrue: [owner panelRect top]
				ifFalse: [owner innerBounds top]]
		ifNotNil: [splitter bottom])
		+ (self minimumHeightOf: morphs)
]

{ #category : #events }
ProportionalSplitterMorph >> updateFromEvent: anEvent [ 
	| delta |
	lastMouse ifNil: [ lastMouse := anEvent position ].
	delta := splitsTopAndBottom
		ifTrue: [ 0 @ ((self normalizedY: anEvent cursorPoint y) - lastMouse y) ]
		ifFalse: [ (self normalizedX: anEvent cursorPoint x) - lastMouse x @ 0 ].
	lastMouse := splitsTopAndBottom
		ifTrue: [ lastMouse x @ (self normalizedY: anEvent cursorPoint y) ]
		ifFalse: [ (self normalizedX: anEvent cursorPoint x) @ lastMouse y ].
	self repositionBy: delta
]

{ #category : #'smart splitters - stepping' }
ProportionalSplitterMorph >> wantsSteps [
	^ splitsTopAndBottom
		ifTrue: [ self class smartHorizontalSplitters ]
		ifFalse: [ self class smartVerticalSplitters ]
]

{ #category : #'queries - adjacent splitters' }
ProportionalSplitterMorph >> withSiblingSplittersDo: aBlock [ 
	aBlock value: self.
	self siblingSplittersDo: aBlock
]
