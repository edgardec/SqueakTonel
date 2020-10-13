Class {
	#name : #ZoomAndScrollControllerMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'mouseDownPoint',
		'mouseMovePoint',
		'panAndTiltFactor',
		'zoomFactor',
		'target',
		'hasFocus',
		'currentKeyDown',
		'upDownCodes',
		'changeKeysState',
		'programmedMoves'
	],
	#category : #'MorphicExtras-Demo'
}

{ #category : #menus }
ZoomAndScrollControllerMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu add: 'change tilt and zoom keys' translated action: #changeKeys.
	aCustomMenu add: 'run an existing camera script' translated action: #runAScript.
	aCustomMenu add: 'edit an existing camera script' translated action: #editAScript.


]

{ #category : #accessing }
ZoomAndScrollControllerMorph >> cameraPoint [

	target ifNil: [^0@0].
	^target cameraPoint

]

{ #category : #accessing }
ZoomAndScrollControllerMorph >> cameraPoint: aPoint [

	target ifNil: [^self].
	target cameraPoint: aPoint
]

{ #category : #accessing }
ZoomAndScrollControllerMorph >> cameraPointRounded [

	^self cameraPoint rounded
]

{ #category : #accessing }
ZoomAndScrollControllerMorph >> cameraScale [

	target ifNil: [^1.0].
	^target scale

]

{ #category : #accessing }
ZoomAndScrollControllerMorph >> cameraScale: aNumber [

	target ifNil: [^self].
	target changeScaleTo: aNumber
]

{ #category : #menus }
ZoomAndScrollControllerMorph >> changeKeys [

	upDownCodes := Dictionary new.
	changeKeysState := #(up down in out).
	self changed.
]

{ #category : #constants }
ZoomAndScrollControllerMorph >> currentCameraVersion [

	^2
]

{ #category : #constants }
ZoomAndScrollControllerMorph >> deadZoneWidth [

	^8

]

{ #category : #initialization }
ZoomAndScrollControllerMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color transparent
]

{ #category : #initialization }
ZoomAndScrollControllerMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 0
]

{ #category : #initialization }
ZoomAndScrollControllerMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightBlue
]

{ #category : #'stepping and presenter' }
ZoomAndScrollControllerMorph >> doProgrammedMoves [

	| thisMove startPoint endPoint startZoom endZoom newScale newPoint fractionLeft |

	programmedMoves isEmptyOrNil ifTrue: [
		^programmedMoves := nil
	].
	thisMove := programmedMoves first.
	thisMove at: #pauseTime ifPresent: [ :ignore | ^self].

	fractionLeft := self fractionLeftInMove: thisMove.
	fractionLeft ifNil: [^programmedMoves := programmedMoves allButFirst].

	startPoint := thisMove at: #startPoint ifAbsentPut: [self cameraPoint].
	endPoint := thisMove at: #endPoint ifAbsentPut: [self cameraPoint].

	startZoom := thisMove at: #startZoom ifAbsentPut: [self cameraScale].
	endZoom := thisMove at: #endZoom ifAbsentPut: [self cameraScale].
	newScale := endZoom - (endZoom - startZoom * fractionLeft).
	newPoint := (endPoint - (endPoint - startPoint * fractionLeft)) "rounded".
	target changeScaleTo: newScale.
	target cameraPoint: newPoint.

	fractionLeft <= 0 ifTrue: [^programmedMoves := programmedMoves allButFirst].


]

{ #category : #drawing }
ZoomAndScrollControllerMorph >> drawOn: aCanvas [

	| dw bullsEye f |

	super drawOn: aCanvas.
	changeKeysState ifNotNil: [
		f := (
			StringMorph contents: 'Press the key to be used for "',changeKeysState first,'"'
		) imageForm.
		aCanvas paintImage: f at: self center - (f extent // 2).
		^self
	].
	mouseDownPoint ifNil: [^self].
	dw := self deadZoneWidth.
	bullsEye := mouseDownPoint - (dw@dw//2) extent: dw@dw.
	aCanvas 
		fillRectangle: (bullsEye left @ self top corner: bullsEye right @ self bottom) 
		color: (Color red alpha: 0.3).
	aCanvas 
		fillRectangle: (self left @ bullsEye top corner: self right @ bullsEye bottom) 
		color: (Color red alpha: 0.3).
	aCanvas 
		fillRectangle: bullsEye 
		color: (Color red alpha: 0.4).

]

{ #category : #menus }
ZoomAndScrollControllerMorph >> editAScript [

	| d names reply s |
	d := self targetScriptDictionary.
	names := d keys asArray sort.
	reply := UIManager default chooseFrom: names values: names title: 'Script to edit?'.
	reply ifNil: [^ self].
	(s := ZASMScriptMorph new)
		decompileScript: (d at: reply) named: reply for: self;
		fullBounds;
		align: s center with: self center;
		openInWorld
	
]

{ #category : #private }
ZoomAndScrollControllerMorph >> fractionLeftInMove: thisMove [

	| steps stepsRemaining fractionLeft endTime startTime |

	(thisMove includesKey: #steps) ifTrue: [
		steps := thisMove at: #steps ifAbsentPut: [1].
		stepsRemaining := thisMove at: #stepsRemaining ifAbsentPut: [steps].
		stepsRemaining < 1 ifTrue: [^nil].
		stepsRemaining := stepsRemaining - 1.
		fractionLeft := stepsRemaining / steps. 
		thisMove at: #stepsRemaining put: stepsRemaining.
	] ifFalse: [
		endTime := thisMove at: #endTime ifAbsent: [^nil].
		startTime := thisMove at: #startTime ifAbsent: [^nil].
		fractionLeft := (endTime - Time millisecondClockValue) / (endTime - startTime).
	].
	^fractionLeft max: 0

]

{ #category : #camera }
ZoomAndScrollControllerMorph >> grabCameraPositionEvent: anEvent morph: aMorph [
 
	| mark |
	mark := ZASMCameraMarkMorph new.
	mark 
		cameraPoint: self cameraPoint
		cameraScale: self cameraScale
		controller: self
		page: target.
	anEvent hand attachMorph: mark.
]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> handlesKeyboard: evt [

	^true
]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> handlesMouseDown: evt [

	^true
]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> handlesMouseOver: evt [

	^true
]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> hasFocus [

	^ hasFocus
]

{ #category : #initialization }
ZoomAndScrollControllerMorph >> initialize [
	"initialize the state of the receiver"
	| displayer dataMorph |
	super initialize.
	""
	hasFocus := true.
	currentKeyDown := Set new.
	upDownCodes := Dictionary new.
	upDownCodes at: 126 put: #up;
		 at: 125 put: #down;
		 at: 123 put: #out;
		 at: 124 put: #in.
	"arrow keys on the mac"
	self extent: 40 @ 40;
		 vResizing: #rigid;
		 hResizing: #spaceFill;
		 setBalloonText: 'Drag in here to zoom, tilt and pan the page above'.
	dataMorph := AlignmentMorph newColumn.
	dataMorph color: Color yellow;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap.
	dataMorph
		on: #mouseDown
		send: #grabCameraPositionEvent:morph:
		to: self.
	displayer := UpdatingStringMorph new getSelector: #cameraPointRounded;
				 target: self;
				 growable: true;
				 putSelector: nil.
	dataMorph addMorph: displayer lock.
	displayer := UpdatingStringMorph new getSelector: #cameraScale;
				 target: self;
				 growable: true;
				 floatPrecision: 0.001;
				 putSelector: nil.
	dataMorph addMorph: displayer lock.
	self addMorph: dataMorph
]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> keyDown: anEvent [

	changeKeysState ifNotNil: [
		upDownCodes at: anEvent keyValue put: changeKeysState first.
		changeKeysState := changeKeysState allButFirst.
		changeKeysState isEmpty ifTrue: [changeKeysState := nil].
		currentKeyDown := Set new.
		^self changed
	].
	currentKeyDown add: anEvent keyValue.

]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> keyStroke: anEvent [


]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> keyUp: anEvent [

	currentKeyDown remove: anEvent keyValue ifAbsent: [].
]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> mouseDown: evt [

	mouseDownPoint := evt cursorPoint.
	self changed.
]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> mouseEnter: evt [

	evt hand newKeyboardFocus: self.
	currentKeyDown := Set new.
	hasFocus := true.


]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> mouseLeave: evt [

	currentKeyDown := Set new.
	hasFocus := false.
	mouseMovePoint := mouseDownPoint := nil.

]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> mouseMove: evt [

	mouseMovePoint := evt cursorPoint.


]

{ #category : #'event handling' }
ZoomAndScrollControllerMorph >> mouseUp: evt [

	mouseMovePoint := mouseDownPoint := nil.
	self changed.
]

{ #category : #private }
ZoomAndScrollControllerMorph >> patchOldVersion1 [

	"hack.. use this as an opportunity to fix old versions"
	self allMorphsDo: [:m |
		((m isKindOf: UpdatingStringMorph) and: [m getSelector == #cameraPoint]) ifTrue: [
			m getSelector: #cameraPointRounded
		].
	].


]

{ #category : #'piano rolls' }
ZoomAndScrollControllerMorph >> pauseProgrammedMoves [

	programmedMoves isEmptyOrNil ifTrue: [^self].
	programmedMoves first
		at: #pauseTime
		put: Time millisecondClockValue

]

{ #category : #'piano rolls' }
ZoomAndScrollControllerMorph >> resumeProgrammedMoves [

	| thisStep |

	programmedMoves isEmptyOrNil ifTrue: [^self].
	(thisStep := programmedMoves first)
		at: #pauseTime
		ifPresent: [ :pauseTime |
			thisStep 
				at: #startTime 
				put: (thisStep at: #startTime) + Time millisecondClockValue - pauseTime.
			thisStep removeKey: #pauseTime ifAbsent: [].
		].

]

{ #category : #menus }
ZoomAndScrollControllerMorph >> runAScript [

	| d names reply |
	d := self targetScriptDictionary.
	names := d keys asArray sort.
	reply := UIManager default chooseFrom: names values: names title: 'Script to run?'.
	reply ifNil: [^ self].
	programmedMoves := (d at: reply) veryDeepCopy.
]

{ #category : #menus }
ZoomAndScrollControllerMorph >> saveScript: newScript as: scriptName [

	self targetScriptDictionary at: scriptName put: newScript.


]

{ #category : #menus }
ZoomAndScrollControllerMorph >> setProgrammedMoves: aCollection [

	programmedMoves := aCollection

]

{ #category : #'stepping and presenter' }
ZoomAndScrollControllerMorph >> step [

	| delta halfDW |

	(self valueOfProperty: #currentCameraVersion ifAbsent: [0]) = 
							self currentCameraVersion ifFalse: [
		self patchOldVersion1.
		self setProperty: #currentCameraVersion toValue: self currentCameraVersion.
	].
	super step.
	self doProgrammedMoves.

	(currentKeyDown ifNil: [#()]) do: [ :each | | action |
		action := upDownCodes at: each ifAbsent: [#fugeddaboutit].
		action == #in ifTrue: [
			target scaleImageBy: -10.
		].
		action == #out ifTrue: [
			target scaleImageBy: 10.
		].
		action == #up ifTrue: [
			target tiltImageBy: -20.
		].
		action == #down ifTrue: [
			target tiltImageBy: 20.
		].
	].
	mouseMovePoint ifNil: [^self].
	mouseDownPoint ifNil: [^self].
	target ifNil: [^self].
	halfDW := self deadZoneWidth // 2.
	delta := mouseMovePoint - mouseDownPoint.
	delta x abs <= halfDW ifTrue: [delta := 0@delta y].
	delta y abs <= halfDW ifTrue: [delta := delta x@0].
	
	target panImageBy: delta x.




]

{ #category : #'stepping and presenter' }
ZoomAndScrollControllerMorph >> stepTime [

	^10


]

{ #category : #'accessing-backstop' }
ZoomAndScrollControllerMorph >> target: x [

	target := x.

]

{ #category : #accessing }
ZoomAndScrollControllerMorph >> targetScriptDictionary [

	target ifNil: [^Dictionary new].
	^target 
		valueOfProperty: #namedCameraScripts 
		ifAbsent: [
			| scriptDict |
			scriptDict := Dictionary new.
			target setProperty: #namedCameraScripts toValue: scriptDict.
			scriptDict
		].


]

{ #category : #camera }
ZoomAndScrollControllerMorph >> turnToPage: page position: aPoint scale: aNumber transition: aSpec [
 
	| myBook |

	target == page ifTrue: [^false].
	page ifNil: [^false].
	myBook := (self ownerThatIsA: StoryboardBookMorph) ifNil: [^ false].
	2 timesRepeat: [
		page
			cameraPoint: aPoint;
			changeScaleTo: aNumber
	].
	BookMorph turnOffSoundWhile: [
		myBook 
			goToPageMorph: page 
			transitionSpec: aSpec.
	].
	^true
]
