Class {
	#name : #MovieMorph,
	#superclass : #Morph,
	#instVars : [
		'playMode',
		'msecsPerFrame',
		'rotationDegrees',
		'scalePoint',
		'frameList',
		'currentFrameIndex',
		'dwellCount'
	],
	#category : #'Morphic-Basic'
}

{ #category : #menu }
MovieMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	| movies subMenu |
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	subMenu := MenuMorph new defaultTarget: self.
	frameList size > 1 ifTrue: [
		subMenu add: 'repaint' translated action: #editDrawing.
		subMenu add: 'set rotation center' translated action: #setRotationCenter.
		subMenu add: 'play once' translated action: #playOnce.
		subMenu add: 'play loop' translated action: #playLoop.
		subMenu add: 'stop playing' translated action: #stopPlaying.
		currentFrameIndex > 1 ifTrue: [
			subMenu add: 'previous frame' translated action: #previousFrame].
		currentFrameIndex < frameList size ifTrue: [
			subMenu add: 'next frame' translated action: #nextFrame]].
	subMenu add: 'extract this frame' translated action: #extractFrame:.
	movies :=
		(self world rootMorphsAt: aHandMorph targetPoint)
			select: [:m | (m isKindOf: MovieMorph) or:
						[m isSketchMorph]].
	(movies size > 1) ifTrue:
		[subMenu add: 'insert into movie' translated action: #insertIntoMovie:].
	aCustomMenu add: 'movie...' translated subMenu: subMenu

]

{ #category : #menu }
MovieMorph >> advanceFrame [

	currentFrameIndex < frameList size
		ifTrue: [self setFrame: currentFrameIndex + 1]
		ifFalse: [self setFrame: 1].

]

{ #category : #'geometry testing' }
MovieMorph >> containsPoint: p [ 
	| frame |
	frame := self currentFrame.
	^ (frame notNil and: [playMode = #stop]) 
		ifTrue: [frame containsPoint: p]
		ifFalse: [super containsPoint: p]
]

{ #category : #private }
MovieMorph >> currentFrame [
	frameList isEmpty ifTrue: [^nil].
     currentFrameIndex := currentFrameIndex min: (frameList size).
     currentFrameIndex := currentFrameIndex max: 1.
	^frameList at: currentFrameIndex
]

{ #category : #initialization }
MovieMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 1
		g: 0
		b: 1
]

{ #category : #drawing }
MovieMorph >> drawOn: aCanvas [ 
	| frame |
	frame := self currentFrame.
	frame notNil 
		ifTrue: [^frame drawOn: aCanvas]
		ifFalse: [^super drawOn: aCanvas]
]

{ #category : #menu }
MovieMorph >> editDrawing [
	| frame |
	frame := self currentFrame.
	frame notNil 
		ifTrue: [frame editDrawingIn: self pasteUpMorph forBackground: false]
]

{ #category : #menu }
MovieMorph >> extractFrame: evt [

	| f |
	f := self currentFrame.
	f ifNil: [^ self].
	frameList := frameList copyWithout: f.
	frameList isEmpty
		ifTrue: [self position: f position]
		ifFalse: [self setFrame: currentFrameIndex].
	evt hand attachMorph: f.

]

{ #category : #accessing }
MovieMorph >> form [

	^ self currentFrame form

]

{ #category : #initialization }
MovieMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	"#stop, #playOnce, or #loop"
	playMode := #stop.
	msecsPerFrame := 200.
	rotationDegrees := 0.
	scalePoint := 1.0 @ 1.0.
	frameList := Array empty.
	currentFrameIndex := 1.
	dwellCount := 0
]

{ #category : #private }
MovieMorph >> insertFrames: newFrames [
	"Insert the given collection of frames into this movie just after the currentrame."

	frameList isEmpty ifTrue: [
		frameList := newFrames asArray copy.
		self setFrame: 1.
		^ self].

	frameList :=
		frameList
			copyReplaceFrom: currentFrameIndex + 1  "insert before"
			to: currentFrameIndex
			with: newFrames.

]

{ #category : #menu }
MovieMorph >> insertIntoMovie: evt [

	| movies aTarget |
	movies :=
		(self world rootMorphsAt: evt hand targetPoint)
			select: [:m | ((m isKindOf: MovieMorph) or:
						 [m isSketchMorph]) and: [m ~= self]].
	movies isEmpty ifTrue: [^ self].
	aTarget := movies first.
	(aTarget isSketchMorph) ifTrue:
		[aTarget := aTarget replaceSelfWithMovie].
	movies first insertFrames: frameList.
	self delete.

]

{ #category : #menu }
MovieMorph >> nextFrame [

	currentFrameIndex < frameList size
		ifTrue: [self setFrame: currentFrameIndex + 1].

]

{ #category : #menu }
MovieMorph >> playLoop [

	playMode := #loop.

]

{ #category : #menu }
MovieMorph >> playOnce [

	self setFrame: 1.
	playMode := #playOnce.

]

{ #category : #menu }
MovieMorph >> previousFrame [

	currentFrameIndex > 1
		ifTrue: [self setFrame: currentFrameIndex - 1].

]

{ #category : #'rotate scale and flex' }
MovieMorph >> rotationDegrees [

	^ rotationDegrees

]

{ #category : #accessing }
MovieMorph >> scalePoint [

	^ scalePoint

]

{ #category : #accessing }
MovieMorph >> scalePoint: newScalePoint [

	| frame |
	newScalePoint ~= scalePoint ifTrue: [
		self changed.
		scalePoint := newScalePoint.
		frame := self currentFrame.
		frame ifNotNil: [frame scalePoint: newScalePoint].
		self layoutChanged.
		self changed].

]

{ #category : #private }
MovieMorph >> setFrame: newFrameIndex [ 
	| oldFrame p newFrame |
	oldFrame := self currentFrame.
	oldFrame ifNil: [^self].
	self changed.
	p := oldFrame referencePosition.
	currentFrameIndex := newFrameIndex.
     currentFrameIndex :=  currentFrameIndex min: (frameList size). 
	currentFrameIndex := currentFrameIndex max: 1.
	newFrame := frameList at: currentFrameIndex.
	newFrame referencePosition: p.
	oldFrame delete.
	self addMorph: newFrame.
	dwellCount := newFrame framesToDwell.
	self layoutChanged.
	self changed
]

{ #category : #'stepping and presenter' }
MovieMorph >> step [

	playMode = #stop ifTrue: [^ self].

	dwellCount > 0 ifTrue: [
		dwellCount := dwellCount - 1.
		^ self].

	currentFrameIndex < frameList size
		ifTrue: [^ self setFrame: currentFrameIndex + 1].

	playMode = #loop
		ifTrue: [self setFrame: 1]
		ifFalse: [playMode := #stop].

]

{ #category : #'stepping and presenter' }
MovieMorph >> stepTime [

	^ msecsPerFrame

]

{ #category : #menu }
MovieMorph >> stopPlaying [

	playMode := #stop.
	self setFrame: 1.

]
