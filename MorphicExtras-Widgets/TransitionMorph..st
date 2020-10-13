"
A transitionMorph inserts itself in the morphic object structure during a visual transition.  It has a stepNumber that runs from 1 to nSteps.  This class handles a large family of wipe-like transitions by itself.  Subclasses may implement other transitions such as dissolves and zooms.
"
Class {
	#name : #TransitionMorph,
	#superclass : #Morph,
	#instVars : [
		'startMorph',
		'endMorph',
		'startBlock',
		'completionBlock',
		'stepNumber',
		'nSteps',
		'stepTime',
		'startForm',
		'endForm',
		'effect',
		'direction'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'available effects' }
TransitionMorph class >> allEffects [
	#('none' 'slide over' 'slide both' 'slide away' 'slide border'
		'page forward' 'page back'
		'french door' 'zoom frame' 'zoom' 'dissolve') translatedNoop.
	^ #(none
		slideOver slideBoth slideAway slideBorder
		pageForward pageBack 
		frenchDoor
		zoomFrame zoom
		dissolve)
]

{ #category : #'available effects' }
TransitionMorph class >> directionsForEffect: eff [
	 "All these arrays are ordered so inverse is atWrap: size//2."
	#('right' 'down right' 'down' 'down left' 'left' 'up left' 'up' 'up right'
		'in' 'in h' 'out' 'out h') translatedNoop.

	(#(slideOver slideBoth slideAway slideBorder) includes: eff)
		ifTrue: [^ #(right downRight down downLeft left upLeft up upRight)].
	(#(pageForward pageBack) includes: eff)
		ifTrue: [^ #(right down left up)].
	(#(frenchDoor) includes: eff)
		ifTrue: [^ #(in inH out outH)].
	(#(zoomFrame zoom) includes: eff)
		ifTrue: [^ #(in out)].
	^ Array new
]

{ #category : #initialization }
TransitionMorph class >> effect: effectSymbol direction: dirSymbol [
	^ self new effect: effectSymbol direction: dirSymbol
]

{ #category : #initialization }
TransitionMorph class >> effect: effectSymbol direction: dirSymbol inverse: inverse [
	| invEffect invDir i dirSet |
	inverse ifFalse: [^ self effect: effectSymbol direction: dirSymbol].

	invEffect := effectSymbol.
	effectSymbol = #pageForward ifTrue: [invEffect := #pageBack].
	effectSymbol = #pageBack ifTrue: [invEffect := #pageForward].
	effectSymbol = #slideOver ifTrue: [invEffect := #slideAway].
	effectSymbol = #slideAway ifTrue: [invEffect := #slideOver].

	invDir := dirSymbol.
	dirSet := self directionsForEffect: effectSymbol.
	(i := dirSet indexOf: dirSymbol) > 0
		ifTrue: [invDir := dirSet atWrap: i + (dirSet size // 2)].

	^ self effect: invEffect direction: invDir
]

{ #category : #'new-morph participation' }
TransitionMorph class >> includeInNewMorphMenu [
	"Transitions aren't meaningful without initializations"
	^ false
]

{ #category : #drawing }
TransitionMorph >> areasRemainingToFill: aRectangle [
	"May be overridden by any subclasses with opaque regions"

	^ aRectangle areasOutside: self bounds
]

{ #category : #updating }
TransitionMorph >> changed [
	"The default (super) method is, generally much slower than need be, since many transitions only change part of the screen on any given step of the animation.  The purpose of this method is to effect some of those savings."
	| loc box boxPrev h w |
	(stepNumber between: 1 and: nSteps) ifFalse: [^ super changed].
	effect = #slideBoth ifTrue: [^ super changed].
	effect = #slideOver ifTrue:
		[loc := self stepFrom: self position - (self extent * direction) to: self position.
		^ self invalidRect: (((loc extent: self extent) expandBy: 1) intersect: bounds)].
	effect = #slideAway ifTrue:
		[loc := self prevStepFrom: self position to: self position + (self extent * direction).
		^ self invalidRect: (((loc extent: self extent) expandBy: 1) intersect: bounds)].
	effect = #slideBorder ifTrue:
		[box := endForm boundingBox translateBy:
				(self stepFrom: self topLeft - (self extent * direction) to: self topLeft).
		boxPrev := endForm boundingBox translateBy:
				(self prevStepFrom: self topLeft - (self extent * direction) to: self topLeft).
		^ self invalidate: (box expandBy: 1) areasOutside: boxPrev].
	effect = #pageForward ifTrue:
		[loc := self prevStepFrom: 0@0 to: self extent * direction.
		^ self invalidRect: (((bounds translateBy: loc) expandBy: 1) intersect: bounds)].
	effect = #pageBack ifTrue:
		[loc := self stepFrom: self extent * direction negated to: 0@0.
		^ self invalidRect: (((bounds translateBy: loc) expandBy: 1) intersect: bounds)].
	effect = #frenchDoor ifTrue:
		[h := self height. w := self width.
		direction = #in ifTrue:
			[box := Rectangle center: self center
							extent: (self stepFrom: 0@h to: self extent).
			boxPrev := Rectangle center: self center
							extent: (self prevStepFrom: 0@h to: self extent).
			^ self invalidate: (box expandBy: 1) areasOutside: boxPrev].
		direction = #out ifTrue:
			[box := Rectangle center: self center
							extent: (self stepFrom: self extent to: 0@h).
			boxPrev := Rectangle center: self center
							extent: (self prevStepFrom: self extent to: 0@h).
			^ self invalidate: (boxPrev expandBy: 1) areasOutside: box].
		direction = #inH ifTrue:
			[box := Rectangle center: self center
							extent: (self stepFrom: w@0 to: self extent).
			boxPrev := Rectangle center: self center
							extent: (self prevStepFrom: w@0 to: self extent).
			^ self invalidate: (box expandBy: 1) areasOutside: boxPrev].
		direction = #outH ifTrue:
			[box := Rectangle center: self center
							extent: (self stepFrom: self extent to: w@0).
			boxPrev := Rectangle center: self center
							extent: (self prevStepFrom: self extent to: w@0).
			^ self invalidate: (boxPrev expandBy: 1) areasOutside: box]].
	effect = #zoomFrame ifTrue:
		[direction = #in ifTrue:
			[box := Rectangle center: self center
							extent: (self stepFrom: 0@0 to: self extent).
			boxPrev := Rectangle center: self center
							extent: (self prevStepFrom: 0@0 to: self extent).
			^ self invalidate: (box expandBy: 1) areasOutside: boxPrev].
		direction = #out ifTrue:
			[box := Rectangle center: self center
							extent: (self stepFrom: self extent to: 0@0).
			boxPrev := Rectangle center: self center
							extent: (self prevStepFrom: self extent to: 0@0).
			^ self invalidate: (boxPrev expandBy: 1) areasOutside: box]].
	effect = #zoom ifTrue:
		[box := Rectangle center: self center extent:
			(direction = #in
				ifTrue: [self stepFrom: 0@0 to: self extent]
				ifFalse: [self prevStepFrom: self extent to: 0@0]).
		^ self invalidRect: ((box expandBy: 1) intersect: bounds)].
	^ super changed

]

{ #category : #initialization }
TransitionMorph >> completeReplacement [

	self delete.
	completionBlock value
]

{ #category : #drawing }
TransitionMorph >> drawDissolveOn: aCanvas [
	"startForm and endFrom are both fixed, but the dissolve ration changes."

	startForm copyBits: endForm at: 0@0 translucent: stepNumber asFloat / (nSteps*2).

	aCanvas drawImage: startForm at: self position.

]

{ #category : #drawing }
TransitionMorph >> drawFrenchDoorOn: aCanvas [
	"startForm and endFrom are both fixed, but a border expands out from a vertical (or H) slit, revealing endForm.
	It's like opening a pair of doors."
	| box innerForm outerForm boxExtent h w |
	h := self height. w := self width.
	direction = #in ifTrue: [innerForm := endForm.  outerForm := startForm.
							boxExtent := self stepFrom: 0@h to: self extent].
	direction = #out ifTrue: [innerForm := startForm.  outerForm := endForm.
							boxExtent := self stepFrom: self extent to: 0@h].
	direction = #inH ifTrue: [innerForm := endForm.  outerForm := startForm.
							boxExtent := self stepFrom: w@0 to: self extent].
	direction = #outH ifTrue: [innerForm := startForm.  outerForm := endForm.
							boxExtent := self stepFrom: self extent to: w@0].
		
	aCanvas drawImage: outerForm at: self position.

	box := Rectangle center: self center extent: boxExtent.
	aCanvas drawImage: innerForm at: box topLeft sourceRect: (box translateBy: self position negated).

	((box expandBy: 1) areasOutside: box) do:
		[:r | aCanvas fillRectangle: r color: Color black].

]

{ #category : #drawing }
TransitionMorph >> drawOn: aCanvas [
	"During the transition process, the reveal and obscure areas will be invalidated,
	so we should be drawing on a canvas that clips to only the changing region."

	(stepNumber between: 1 and: nSteps) ifFalse: [^ self].
	effect = #slideOver ifTrue: [^ self drawSlideOverOn: aCanvas].
	effect = #slideBoth ifTrue: [^ self drawSlideBothOn: aCanvas].
	effect = #slideAway ifTrue: [^ self drawSlideAwayOn: aCanvas].
	effect = #slideBorder ifTrue: [^ self drawSlideBorderOn: aCanvas].
	effect = #pageForward ifTrue: [^ self drawPageForwardOn: aCanvas].
	effect = #pageBack ifTrue: [^ self drawPageBackOn: aCanvas].
	effect = #frenchDoor ifTrue: [^ self drawFrenchDoorOn: aCanvas].
	effect = #zoomFrame ifTrue: [^ self drawZoomFrameOn: aCanvas].
	effect = #zoom ifTrue: [^ self drawZoomOn: aCanvas].
	effect = #dissolve ifTrue: [^ self drawDissolveOn: aCanvas].

]

{ #category : #drawing }
TransitionMorph >> drawPageBackOn: aCanvas [
	"endForm grows in the given direction, overlaying endForm."
	| offset growRect scale |
	aCanvas drawImage: startForm at: self position.

	offset := self stepFrom: self extent * direction negated to: 0@0.
	growRect := (bounds translateBy: offset) intersect: bounds.
	scale := growRect extent asFloatPoint / bounds extent.
	aCanvas drawImage: (endForm magnify: endForm boundingBox by: scale smoothing: 1)
		at: growRect topLeft.

	((growRect translateBy: direction) areasOutside: growRect) do:
		[:r | aCanvas fillRectangle: r color: Color black].

]

{ #category : #drawing }
TransitionMorph >> drawPageForwardOn: aCanvas [
	"startForm shrinks in the given direction, revealing endForm."
	| offset shrinkRect scale |
	aCanvas drawImage: endForm at: self position.

	offset := self stepFrom: 0@0 to: self extent * direction.
	shrinkRect := (bounds translateBy: offset) intersect: bounds.
	scale := shrinkRect extent asFloatPoint / bounds extent.
	aCanvas drawImage: (startForm magnify: startForm boundingBox by: scale smoothing: 1)
		at: shrinkRect topLeft.

	((shrinkRect translateBy: direction negated) areasOutside: shrinkRect) do:
		[:r | aCanvas fillRectangle: r color: Color black].

]

{ #category : #drawing }
TransitionMorph >> drawSlideAwayOn: aCanvas [
	"startMorph slides away in the given direction, revealing up the endMorph."
	| startLoc moveRect |
	startLoc := self stepFrom: self position to: self position + (self extent * direction).
	moveRect := startForm boundingBox translateBy: startLoc.

	aCanvas drawImage: endForm at: self position.
	aCanvas drawImage: startForm at: startLoc.

	((moveRect translateBy: direction negated) areasOutside: moveRect) do:
		[:r | aCanvas fillRectangle: r color: Color black].

]

{ #category : #drawing }
TransitionMorph >> drawSlideBorderOn: aCanvas [
	"startForm and endFrom are both fixed, but a border slides in the given direction, revealing endForm.  (It's like opening a can of sardines ;-)."
	| endRect box sourceRect boxLoc |
	box := endForm boundingBox.
	boxLoc := self stepFrom: box topLeft - (box extent * direction) to: box topLeft.
	sourceRect := box translateBy: boxLoc.
	endRect := sourceRect translateBy: self position.

	((endRect expandBy: 1) containsRect: aCanvas clipRect) ifFalse:
		[aCanvas drawImage: startForm at: self position].
	aCanvas drawImage: endForm at: self position + boxLoc sourceRect: sourceRect.

	((endRect translateBy: direction) areasOutside: endRect) do:
		[:r | aCanvas fillRectangle: r color: Color black].

]

{ #category : #drawing }
TransitionMorph >> drawSlideBothOn: aCanvas [
	"endMorph slides in the given direction, as startMorph slides out of its way."
	| endLoc endRect startLoc |
	startLoc := self stepFrom: self position to: self position + (self extent * direction).
	aCanvas drawImage: startForm at: startLoc.

	endLoc := self stepFrom: self position - (self extent * direction) to: self position.
	aCanvas drawImage: endForm at: endLoc.

	endRect := endForm boundingBox translateBy: endLoc.
	((endRect translateBy: direction) areasOutside: endRect) do:
		[:r | aCanvas fillRectangle: r color: Color black].

]

{ #category : #drawing }
TransitionMorph >> drawSlideOverOn: aCanvas [
	"endMorph slides in the given direction, covering up the startMorph."
	| endLoc endRect |
	endLoc := self stepFrom: self position - (self extent * direction) to: self position.
	endRect := endForm boundingBox translateBy: endLoc.

	((endRect expandBy: 1) containsRect: aCanvas clipRect) ifFalse:
		[aCanvas drawImage: startForm at: self position].
	aCanvas drawImage: endForm at: endLoc.

	((endRect translateBy: direction) areasOutside: endRect) do:
		[:r | aCanvas fillRectangle: r color: Color black].

]

{ #category : #drawing }
TransitionMorph >> drawZoomFrameOn: aCanvas [
	"startForm and endFrom are both fixed, but a square border expands out from the center (or back), revealing endForm.
	It's like passing through a portal."
	| box innerForm outerForm boxExtent |
	direction = #in
		ifTrue: [innerForm := endForm.  outerForm := startForm.
				boxExtent := self stepFrom: 0@0 to: self extent]
		ifFalse: [innerForm := startForm.  outerForm := endForm.
				boxExtent := self stepFrom: self extent to: 0@0].
		
	aCanvas drawImage: outerForm at: self position.

	box := Rectangle center: self center extent: boxExtent.
	aCanvas drawImage: innerForm at: box topLeft sourceRect: (box translateBy: self position negated).

	((box expandBy: 1) areasOutside: box) do:
		[:r | aCanvas fillRectangle: r color: Color black].

]

{ #category : #drawing }
TransitionMorph >> drawZoomOn: aCanvas [
	"Zoom in: endForm expands overlaying startForm.
	Zoom out: startForm contracts revealing endForm."
	| box innerForm outerForm boxExtent scale |
	direction = #in
		ifTrue: [innerForm := endForm.  outerForm := startForm.
				boxExtent := self stepFrom: 0@0 to: self extent]
		ifFalse: [innerForm := startForm.  outerForm := endForm.
				boxExtent := self stepFrom: self extent to: 0@0].

	aCanvas drawImage: outerForm at: self position.

	box := Rectangle center: self center extent: boxExtent.
	scale := box extent asFloatPoint / bounds extent.
	aCanvas drawImage: (innerForm magnify: innerForm boundingBox by: scale smoothing: 1)
		at: box topLeft.

	((box expandBy: 1) areasOutside: box) do:
		[:r | aCanvas fillRectangle: r color: Color black].

]

{ #category : #private }
TransitionMorph >> effect: effectSymbol direction: dirSymbol [ 
	| i |
	effect := effectSymbol.

	"Default directions"
	(#(#zoom #zoomFrame #frenchDoor) includes: effectSymbol) 
		ifTrue: 
			[direction := (#(#in #out #inH #outH) includes: dirSymbol) 
				ifTrue: [dirSymbol]
				ifFalse: [#in]]
		ifFalse: 
			[i := #(#right #downRight #down #downLeft #left #upLeft #up #upRight) 
						indexOf: dirSymbol
						ifAbsent: [5].
			direction := (0 @ 0) eightNeighbors at: i]
]

{ #category : #initialization }
TransitionMorph >> initiateReplacement [
	| n |
	startForm := effect = #dissolve 
				ifTrue: [(startMorph imageForm: 16 forRectangle: bounds) offset: 0 @ 0]
				ifFalse: [(startMorph imageFormForRectangle: bounds) offset: 0 @ 0].
	endForm := (endMorph imageFormForRectangle: bounds) offset: 0 @ 0.
	nSteps isNil 
		ifTrue: 
			[self nSteps: 30 stepTime: 10.
			(#(#zoom #pageForward #pageBack) includes: effect) 
				ifTrue: 
					[n := 20 * 100000 // self bounds area min: 20 max: 4.
					self nSteps: n stepTime: 10].
			#dissolve = effect 
				ifTrue: 
					[n := 20 * 50000 // self bounds area min: 20 max: 4.
					self nSteps: n stepTime: 10]].
	startBlock value.	"with forms in place there should b no further delay."
	self arrangeToStartStepping
]

{ #category : #'change reporting' }
TransitionMorph >> invalidate: box1 areasOutside: box2 [

	((box1 intersect: bounds) areasOutside: (box2 intersect: bounds))
		do: [:r | self invalidRect: r]
]

{ #category : #initialization }
TransitionMorph >> nSteps: n stepTime: msPerStep [
	nSteps := n.
	stepTime := msPerStep
]

{ #category : #private }
TransitionMorph >> prevStepFrom: p1 to: p2 [
	"Used for recalling dimensions from previous step."

	^ (p2-p1) * (stepNumber-1) // nSteps + p1
]

{ #category : #initialization }
TransitionMorph >> showTransitionFrom: startingMorph to: endingMorph in: containingMorph
	whenStart: firstBlock whenDone: doneBlock [

	effect == #none ifTrue: [firstBlock value.  ^ doneBlock value].

	self startMorph: startingMorph endMorph: endingMorph
		startBlock: firstBlock completionBlock: doneBlock.
	stepNumber := 0.

	self bounds: startingMorph bounds.
	endingMorph privateOwner: self.  "Allows test of transition in progress"
	containingMorph owner privateAddMorph: self atIndex: 
		(containingMorph owner submorphs indexOf: containingMorph).

	self initiateReplacement
]

{ #category : #initialization }
TransitionMorph >> startMorph: start endMorph: end startBlock: firstBlock completionBlock: aBlock [
	startMorph := start.
	endMorph := end.
	startBlock := firstBlock.
	completionBlock := aBlock
]

{ #category : #'stepping and presenter' }
TransitionMorph >> step [
	(stepNumber := stepNumber + 1) <= nSteps
		ifTrue: [self changed]
		ifFalse: [self completeReplacement]
]

{ #category : #private }
TransitionMorph >> stepFrom: p1 to: p2 [
	"This gives p1 for stepCount = 0, moving to p2 for stepCount = nSteps"

	^ (p2-p1) * stepNumber // nSteps + p1
]

{ #category : #'stepping and presenter' }
TransitionMorph >> stepTime [
	^ stepTime
]
