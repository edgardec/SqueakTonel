Class {
	#name : #ZASMCameraMarkMorph,
	#superclass : #AbstractMediaEventMorph,
	#category : #'MorphicExtras-Demo'
}

{ #category : #menu }
ZASMCameraMarkMorph >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add custom halo menu items"

	aMenu add: 'Go to this mark' translated target: self action: #gotoMark.
	aMenu add: 'Set transition' translated target: self action: #setTransition.

	super addCustomMenuItems: aMenu hand: aHandMorph

]

{ #category : #'piano rolls' }
ZASMCameraMarkMorph >> addMorphsTo: morphList pianoRoll: pianoRoll eventTime: t betweenTime: leftTime and: rightTime [

	| startX pseudoEndTime |

	startX := pianoRoll xForTime: startTimeInScore.
	pseudoEndTime := pianoRoll timeForX: startX + self width.
	startTimeInScore > rightTime ifTrue: [^ self].  
	pseudoEndTime < leftTime ifTrue: [^ self].

	morphList add: 
		(self align: self bottomLeft
			with: startX @ self bottom).


]

{ #category : #camera }
ZASMCameraMarkMorph >> cameraController [

	^(self valueOfProperty: #cameraController)
]

{ #category : #camera }
ZASMCameraMarkMorph >> cameraPoint: aPoint cameraScale: aNumber controller: aController [

	self setProperty: #cameraPoint toValue: aPoint.
	self setProperty: #cameraScale toValue: aNumber.
	self setProperty: #cameraController toValue: aController.
	self addMorph: (
		StringMorph contents: aPoint printString,'  ',(aNumber printShowingMaxDecimalPlaces: 3)
	) lock.
]

{ #category : #camera }
ZASMCameraMarkMorph >> cameraPoint: aPoint cameraScale: aNumber controller: aController page: aBookPage [
 
	self setProperty: #cameraPoint toValue: aPoint.
	self setProperty: #cameraScale toValue: aNumber.
	self setProperty: #cameraController toValue: aController.
	self setProperty: #bookPage toValue: aBookPage.
	self addMorphBack: (ImageMorph new image: (aBookPage imageForm scaledToSize: 80@80)) lock.
	self setBalloonText: aPoint rounded printString,'  ',(aNumber printShowingMaxDecimalPlaces: 3)
]

{ #category : #'piano rolls' }
ZASMCameraMarkMorph >> encounteredAtTime: ticks inScorePlayer: scorePlayer atIndex: index inEventTrack: track secsPerTick: secsPerTick [

	| nextAmbient m nextDurationInMs program now finalMark thisPage nextPage |

	self gotoMark.
	nextAmbient := nil.
	index to: track size do: [ :i |
		(nextAmbient isNil and: [((m := track at: i) morph) isKindOf: self class]) ifTrue: [
			nextAmbient := m.
		].
	].
	nextAmbient ifNil: [^self].
	nextDurationInMs := (nextAmbient time - ticks * secsPerTick * 1000) rounded.
	finalMark := nextAmbient morph.
	thisPage := self valueOfProperty: #bookPage.
	nextPage := finalMark valueOfProperty: #bookPage.
	(thisPage = nextPage or: [thisPage isNil | nextPage isNil]) ifFalse: [^finalMark gotoMark].
	now := Time millisecondClockValue.
	program := Dictionary new.
	program
		at: #startTime put: now;
		at: #endTime put: now + nextDurationInMs;
		at: #startPoint put: (self valueOfProperty: #cameraPoint);
		at: #endPoint put: (finalMark valueOfProperty: #cameraPoint);
		at: #startZoom put: (self valueOfProperty: #cameraScale);
		at: #endZoom put: (finalMark valueOfProperty: #cameraScale).

	self cameraController setProgrammedMoves: {program}.


]

{ #category : #camera }
ZASMCameraMarkMorph >> gotoMark [

	self cameraController 
		turnToPage: (self valueOfProperty: #bookPage)
		position: (self valueOfProperty: #cameraPoint) 
		scale: (self valueOfProperty: #cameraScale)
		transition: (self valueOfProperty: #transitionSpec).
	self setCameraValues.



]

{ #category : #'event handling' }
ZASMCameraMarkMorph >> handlesMouseDown: evt [

	^true

]

{ #category : #'dropping\/grabbing' }
ZASMCameraMarkMorph >> justDroppedInto: newOwner event: anEvent [

	| holder |

	newOwner isWorldMorph ifTrue: [
		holder := ZASMScriptMorph new.
		holder 
			position: self position;
			setProperty: #cameraController toValue: self cameraController.
		self world addMorph: holder.
		holder addMorph: self.
		holder startStepping.
	].
	super justDroppedInto: newOwner event: anEvent
]

{ #category : #menu }
ZASMCameraMarkMorph >> menuPageVisualFor: target event: evt [

	| tSpec menu |

	tSpec := self 
		valueOfProperty: #transitionSpec
		ifAbsent: [
			(self valueOfProperty: #bookPage) 
				valueOfProperty: #transitionSpec
				ifAbsent: [{ 'silence' . #none. #none}]
		].
	menu := (MenuMorph entitled: 'Choose an effect
(it is now ' , tSpec second , ')') defaultTarget: self.
	TransitionMorph allEffects do: [:effect | | directionChoices subMenu |
		directionChoices := TransitionMorph directionsForEffect: effect.
		directionChoices isEmpty
		ifTrue: [menu add: effect target: self
					selector: #setProperty:toValue:
					argumentList: (Array with: #transitionSpec
									with: (Array with: tSpec first with: effect with: #none))]
		ifFalse: [subMenu := MenuMorph new.
				directionChoices do:
					[:dir |
					subMenu add: dir target: self
						selector: #setProperty:toValue:
						argumentList: (Array with: #transitionSpec
									with: (Array with: tSpec first with: effect with: dir))].
				menu add: effect subMenu: subMenu]].

	menu popUpEvent: evt in: self world
]

{ #category : #'event handling' }
ZASMCameraMarkMorph >> mouseDown: evt [

	evt shiftPressed ifTrue: [^self].
	self isSticky ifTrue: [^self].
	evt hand grabMorph: self.
]

{ #category : #'event handling' }
ZASMCameraMarkMorph >> mouseUp: evt [

	evt shiftPressed ifTrue: [^self gotoMark].

]

{ #category : #'piano rolls' }
ZASMCameraMarkMorph >> pauseFrom: scorePlayer [

	self cameraController pauseProgrammedMoves.
]

{ #category : #'piano rolls' }
ZASMCameraMarkMorph >> resumeFrom: scorePlayer [

	self cameraController resumeProgrammedMoves
]

{ #category : #camera }
ZASMCameraMarkMorph >> setCameraValues [

	| camera |
	camera := self cameraController.

	"ick... since one may fail to fully take due to constraints, retry"
	2 timesRepeat: [
		camera cameraPoint: (self valueOfProperty: #cameraPoint).
		camera cameraScale: (self valueOfProperty: #cameraScale).
	].


]

{ #category : #menu }
ZASMCameraMarkMorph >> setTransition [
	"Set the transition"

	^ self setTransition: self currentEvent
]

{ #category : #menu }
ZASMCameraMarkMorph >> setTransition: evt [

	| tSpec menu |

	tSpec := self 
		valueOfProperty: #transitionSpec
		ifAbsent: [
			(self valueOfProperty: #bookPage) 
				valueOfProperty: #transitionSpec
				ifAbsent: [{ 'silence' . #none. #none}]
		].
	menu := (MenuMorph entitled: 'Choose an effect
(it is now ' , tSpec second , ')') defaultTarget: self.
	TransitionMorph allEffects do: [:effect | | subMenu directionChoices |
		directionChoices := TransitionMorph directionsForEffect: effect.
		directionChoices isEmpty
		ifTrue: [menu add: effect target: self
					selector: #setProperty:toValue:
					argumentList: (Array with: #transitionSpec
									with: (Array with: tSpec first with: effect with: #none))]
		ifFalse: [subMenu := MenuMorph new.
				directionChoices do:
					[:dir |
					subMenu add: dir target: self
						selector: #setProperty:toValue:
						argumentList: (Array with: #transitionSpec
									with: (Array with: tSpec first with: effect with: dir))].
				menu add: effect subMenu: subMenu]].

	menu popUpEvent: evt in: self world
]

{ #category : #copying }
ZASMCameraMarkMorph >> veryDeepCopyWith: deepCopier [
	| camera page |
	"Keep the same camera???"
 
	(camera := self cameraController) ifNotNil: [
		(deepCopier references includesKey: camera) ifFalse: [
			"not recorded, outside our tree, use same camera"
			deepCopier references at: camera put: camera]].
	(page := self valueOfProperty: #bookPage) ifNotNil: [
		(deepCopier references includesKey: page) ifFalse: [
			deepCopier references at: page put: page]].

	^ super veryDeepCopyWith: deepCopier


]
