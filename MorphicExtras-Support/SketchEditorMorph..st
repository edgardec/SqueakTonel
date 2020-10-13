"
Inst vars (converting to morphic events)
hostView -- SketchMorph we are working on.
stampForm -- Stamp is stored here.
canvasRectangle -- later use bounds
palette -- the PaintBox interface Morph
dirty -- not used
currentColor 
ticksToDwell rotationCenter registrationPoint 
newPicBlock -- do this after painting
action -- selector of painting action
paintingForm -- our copy
composite -- now paintArea origin.  world relative.  stop using it.
dimForm -- SketchMorph of the dimmed background.  Opaque.  
		installed behind the editor morph.
buff 
brush -- 1-bit Form of the brush, 
paintingFormPen 
formCanvas -- Aim it at paintingForm to allow it to draw ovals, rectangles, lines, etc.
picToComp dimToComp compToDisplay -- used to composite -- obsolete
picToBuff brushToBuff buffToBuff buffToPic 
rotationButton scaleButton -- submorphs, handles to do these actions.
strokeOrigin -- During Pickup, origin of rect. 
cumRot cumMag -- cumulative for multiple operations from same original
undoBuffer 
lastEvent 
currentNib -- 1 bit deep form.


For now, we do not carry the SketchMorph's registration point, rotation center, or ticksToDwell.

New -- using transform morphs to rotate the finished player.  How get it rotated back and the rotationDegrees to be right?  We cancel out rotationDegrees, so how remember it?

Registration point convention:  
In a GraphicFrame, reg point is relative to this image's origin.
During painting, it is relative to canvasRectangle origin, and thus us absolute within the canvas.  To convert back, subract newBox origin.

Be sure to convert back and forth correctly.  In deliverPainting. initializeFromFrame:inView: 
"
Class {
	#name : #SketchEditorMorph,
	#superclass : #Morph,
	#instVars : [
		'hostView',
		'palette',
		'ticksToDwell',
		'rotationCenter',
		'registrationPoint',
		'newPicBlock',
		'emptyPicBlock',
		'paintingForm',
		'dimForm',
		'formCanvas',
		'rotationButton',
		'scaleButton',
		'cumRot',
		'cumMag',
		'undoBuffer',
		'enclosingPasteUpMorph',
		'forEachHand'
	],
	#classVars : [
		'SketchTimes'
	],
	#category : #'MorphicExtras-Support'
}

{ #category : #'new-morph participation' }
SketchEditorMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #'start & finish' }
SketchEditorMorph >> addRotationScaleHandles [

	"Rotation and scaling handles"

	rotationButton := SketchMorph withForm: (palette rotationTabForm).
	rotationButton position: bounds topCenter - (6@0).
	rotationButton on: #mouseDown send: #rotateScalePrep: to: self.
	rotationButton on: #mouseMove send: #rotateBy: to: self.
	rotationButton on: #mouseUp send: #rotateDone: to: self.
	rotationButton on: #mouseEnter send: #mouseLeave: to: self.
	"Put cursor back"
	rotationButton on: #mouseLeave send: #mouseEnter: to: self.
	Preferences rotationAndScaleHandlesInPaintBox ifTrue:
		[self addMorph: rotationButton].
	rotationButton setBalloonText: 'Drag me sideways to
rotate your
picture.' translated.

	scaleButton := SketchMorph withForm: (palette scaleTabForm).
	scaleButton position: bounds rightCenter - ((scaleButton width)@6).
	scaleButton on: #mouseDown send: #rotateScalePrep: to: self.
	scaleButton on: #mouseMove send: #scaleBy: to: self.
	scaleButton on: #mouseEnter send: #mouseLeave: to: self.
	"Put cursor back"
	scaleButton on: #mouseLeave send: #mouseEnter: to: self.
	Preferences rotationAndScaleHandlesInPaintBox ifTrue:
		[self addMorph: scaleButton].
	scaleButton setBalloonText: 'Drag me up and down to change
the size
of your picture.' translated.

"REMOVED:
	fwdButton := PolygonMorph new.
	pt := bounds topCenter.
	fwdButton borderWidth: 2; makeOpen; makeBackArrow; borderColor:
(Color r: 0 g: 0.8 b: 0).
	fwdButton removeHandles; setVertices: (Array with: pt+(0@7) with:
pt+(0@22)).
	fwdButton on: #mouseMove send: #forward:direction: to: self.
	fwdButton on: #mouseEnter send: #mouseLeave: to: self.	
	fwdButton on: #mouseLeave send: #mouseEnter: to: self.
	self setProperty: #fwdButton toValue: fwdButton.
	self addMorph: fwdButton.
	fwdButton setBalloonText: 'Drag me around to point
in the direction
I go forward.' translated.

	toggle := EllipseMorph
		newBounds: (Rectangle center: fwdButton vertices last +
(-4@4) extent: 8@8)
		color: Color gray.
	toggle on: #mouseUp send: #toggleDirType:in: to: self.
	toggle on: #mouseEnter send: #mouseLeave: to: self.
	toggle on: #mouseLeave send: #mouseEnter: to: self.
	self setProperty: #fwdToggle toValue: toggle.
	fwdButton addMorph: toggle.
	toggle setBalloonText: 'When your object turns,
how should its
picture change?
It can rotate, face left or right,
face up or down, or not
change.' translated.
	"
	self setProperty: #rotationStyle toValue: hostView rotationStyle.
"	self forward: hostView setupAngle direction: fwdButton.	"
	"Set to its current value"


]

{ #category : #'start & finish' }
SketchEditorMorph >> afterNewPicDo: goodBlock ifNoBits: badBlock [
	"If the user said 'Save' at the end of drawing, do this block to save the picture.
goodBlock takes 2 args, the painted form and the bounding rectangle of its bits.
badBlock takes no args.  "

	newPicBlock := goodBlock.
	emptyPicBlock := badBlock.
]

{ #category : #'start & finish' }
SketchEditorMorph >> cancel: evt [
	"Palette is telling us that the use wants to end the painting session.  "

	Cursor normal show.
	self deliverPainting: #cancel evt: evt.
]

{ #category : #'start & finish' }
SketchEditorMorph >> cancelOutOfPainting [
	"The user requested to back out of a painting session without saving"

	self deleteSelfAndSubordinates.
	emptyPicBlock ifNotNil: [emptyPicBlock value].	"note no args to block!"
	hostView ifNotNil: [hostView changed].
	Project current world resumeScriptsPausedByPainting.
	^ nil
]

{ #category : #'palette handling' }
SketchEditorMorph >> cancelPainting: aPaintBoxMorph evt: evt [
	"Undo the operation after user issued #cancel in aPaintBoxMorph"
	^self cancel: evt
]

{ #category : #'actions & preps' }
SketchEditorMorph >> clear [
	"wipe out all the paint"

	self polyFreeze.		"end polygon mode"
	paintingForm fillWithColor: Color transparent.
	self invalidRect: bounds.
]

{ #category : #'palette handling' }
SketchEditorMorph >> clearPainting: aPaintBoxMorph [
	"Clear the image after user issued #clear in aPaintBoxMorph"
	^self clear
]

{ #category : #initialization }
SketchEditorMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color white alpha: 0.5
]

{ #category : #'start & finish' }
SketchEditorMorph >> deleteSelfAndSubordinates [
	"Delete the receiver and, if it has one, its subordinate dimForm"
	self delete.
	dimForm ifNotNil: [dimForm delete]
]

{ #category : #'start & finish' }
SketchEditorMorph >> deliverPainting: result evt: evt [
	"Done painting.  May come from resume, or from original call.  Execute user's post painting instructions in the block.  Always use this standard one.  4/21/97 tk"

	| newBox newForm ans |
	palette ifNotNil: "nil happens" [palette setAction: #paint: evt: evt].	"Get out of odd modes"
	"rot := palette getRotations."	"rotate with heading, or turn to and fro"
	"palette setRotation: #normal."
	result == #cancel ifTrue: [
		ans := UIManager default chooseFrom: {
			 'throw it away' translated.
			'keep painting it' translated.
		} title: 'Do you really want to throw away 
what you just painted?' translated.
		^ ans = 1 ifTrue: [self cancelOutOfPainting]
				ifFalse: [nil]].	"cancelled out of cancelling."

	"hostView rotationStyle: rot."		"rotate with heading, or turn to and fro"
	newBox := paintingForm rectangleEnclosingPixelsNotOfColor: Color transparent.
	registrationPoint ifNotNil:
		[registrationPoint := registrationPoint - newBox origin]. "relative to newForm origin"
	newForm := 	Form extent: newBox extent depth: paintingForm depth.
	newForm copyBits: newBox from: paintingForm at: 0@0 
		clippingBox: newForm boundingBox rule: Form over fillColor: nil.
	newForm isAllWhite ifTrue: [
		(self valueOfProperty: #background) == true 
			ifFalse: [^ self cancelOutOfPainting]].

	newForm fixAlpha. "so alpha channel stays intact for 32bpp"

	self delete.	"so won't find me again"
	dimForm ifNotNil: [dimForm delete].
	newPicBlock value: newForm value: (newBox copy translateBy: bounds origin).
	Project current world resumeScriptsPausedByPainting.
]

{ #category : #'palette handling' }
SketchEditorMorph >> dimTheWindow [

	"Updated to use TranslucentColor by kfr 10/5 00"
	"Do not call twice! Installs a morph with an 'onion-skinned' copy of the pixels behind me." 

	"create an 'onion-skinned' version of the stuff on the screen"
	owner outermostMorphThat: [:morph | morph resumeAfterDrawError. false].

	"an experiment for Nebraska to see if opaque background speeds things up"

"----- now using the color variable to control background
	bgColor := false ifTrue: [TranslucentColor r:1.0 g:1.0 b:1.0 alpha:0.5] ifFalse: [Color white].
	dimForm := (RectangleMorph new color: bgColor; bounds: self bounds; borderWidth: 0).
	dimForm position: self position.
	owner
		privateAddMorph: dimForm
		atIndex: (owner submorphs indexOf: self) + 1.
-----"

]

{ #category : #drawing }
SketchEditorMorph >> drawOn: aCanvas [
	"Put the painting on the display"

	color isTransparent ifFalse: [
		aCanvas fillRectangle: bounds color: color
	].
	paintingForm ifNotNil: [
		aCanvas paintImage: paintingForm at: bounds origin].

 
]

{ #category : #'actions & preps' }
SketchEditorMorph >> ellipse: evt [
	"Draw an ellipse from the center. "

	| rect oldRect ww ext oldExt cColor sOrigin priorEvt |

	sOrigin := self get: #strokeOrigin for: evt.
	cColor := self getColorFor: evt.
	ext := (sOrigin - evt cursorPoint) abs * 2.
	evt shiftPressed ifTrue: [ext := self shiftConstrainPoint: ext].
	rect := Rectangle center: sOrigin extent: ext.
	ww := (self getNibFor: evt) width.
	(priorEvt := self get: #lastEvent for: evt) ifNotNil: [
		oldExt := (sOrigin - priorEvt cursorPoint) abs + ww * 2.
		priorEvt shiftPressed ifTrue: [oldExt := self shiftConstrainPoint: oldExt].
		(oldExt < ext) ifFalse: ["Last draw sticks out, must erase the area"
			oldRect := Rectangle center: sOrigin extent: oldExt.
			self restoreRect: oldRect]].
	cColor == Color transparent
		ifFalse:
			[formCanvas fillOval: rect color: Color transparent borderWidth: ww borderColor: cColor]
		ifTrue:
			[formCanvas fillOval: rect color: cColor borderWidth: ww borderColor: Color black].

	self invalidRect: rect.


]

{ #category : #access }
SketchEditorMorph >> enclosingPasteUpMorph [
	^ enclosingPasteUpMorph
]

{ #category : #'actions & preps' }
SketchEditorMorph >> erase: evt [
	"Pen is set up to draw transparent squares"
	self paint: evt

]

{ #category : #'actions & preps' }
SketchEditorMorph >> erasePrep: evt [
	"Transparent paint, square brush.  Be careful not to let this be undone by asking palette for brush and color."

	| size pfPen myBrush |

	pfPen := self get: #paintingFormPen for: evt.
	size := (self getNibFor: evt) width.
	self set: #brush for: evt to: (myBrush := Form extent: size@size depth: 1).
	myBrush offset: (0@0) - (myBrush extent // 2).
	myBrush fillWithColor: Color black.
	pfPen sourceForm: myBrush.
	"transparent"
	pfPen combinationRule: Form erase1bitShape.
	pfPen color: Color black.

]

{ #category : #morphic }
SketchEditorMorph >> extent: aPoint [ 
	| form |
	paintingForm ifNil: [^super extent: aPoint].
	
	super extent: aPoint.
	form := Form extent: self extent depth: paintingForm depth.
	paintingForm displayOn: form.
	paintingForm := form.
	forEachHand do: [:i | i at: #changed put: true].
	rotationButton position: bounds topCenter - (6@0).		
	scaleButton position: bounds rightCenter - ((scaleButton width)@6).
	
	
]

{ #category : #'actions & preps' }
SketchEditorMorph >> fill: evt [ 
	"Find the area that is the same color as where you clicked. Fill it with 
	the current paint color."
	evt isMouseUp
		ifFalse: [^ self].
	"Only fill upon mouseUp"
	"would like to only invalidate the area changed, but can't find out what it is."
	Cursor execute
		showWhile: [
			| box |
			box := paintingForm
				floodFill: (self getColorFor: evt)
				at: evt cursorPoint - bounds origin.
			self render: (box translateBy: bounds origin)]
]

{ #category : #'actions & preps' }
SketchEditorMorph >> flipHoriz: evt [ 
	"Flip the image"
	| temp myBuff |

	myBuff := self get: #buff for: evt.
	temp := myBuff deepCopy flipBy: #horizontal centerAt: myBuff center.
	temp offset: 0 @ 0.
	paintingForm fillWithColor: Color transparent.
	temp displayOn: paintingForm at: paintingForm center - myBuff center + myBuff offset.
	rotationButton position: evt cursorPoint x - 6 @ rotationButton position y.
	self render: bounds
]

{ #category : #'actions & preps' }
SketchEditorMorph >> flipVert: evt [ 
	"Flip the image"
	| temp myBuff |

	myBuff := self get: #buff for: evt.
	temp := myBuff deepCopy flipBy: #vertical centerAt: myBuff center.
	temp offset: 0 @ 0.
	paintingForm fillWithColor: Color transparent.
	temp displayOn: paintingForm at: paintingForm center - myBuff center + myBuff offset.
	rotationButton position: evt cursorPoint x - 6 @ rotationButton position y.
	self render: bounds
]

{ #category : #'actions & preps' }
SketchEditorMorph >> forward: evt direction: button [ 
	"Move the forward direction arrow of this painting.  When the user
says forward:, the object moves in the direction of the arrow.  evt may be
an Event (from the user moving the arrow), or an initial number ofdegrees."

	| center dir ww ff |
	center := bounds center.	"+ (rotationButton width - 6 @ 0)"
	dir := evt isNumber 
				ifTrue:  
					[Point r: 100 degrees: evt - 90.0
					"convert to 0 on X axis"]
				ifFalse: [evt cursorPoint - center].
	ww := (bounds height min: bounds width) // 2 - 7.
	button 
		setVertices: (Array with: center + (Point r: ww degrees: dir degrees)
				with: center + (Point r: ww - 15 degrees: dir degrees)).
	(ff := self valueOfProperty: #fwdToggle) 
		position: center + (Point r: ww - 7 degrees: dir degrees + 6.5) 
				- (ff extent // 2).
	self showDirType
]

{ #category : #accessing }
SketchEditorMorph >> forwardDirection [
	"The direction object will go when issued a sent forward:.  Up is
zero.  Clockwise like a compass.  From the arrow control."
	^ hostView forwardDirection
]

{ #category : #'Nebraska support' }
SketchEditorMorph >> get: aSymbol for: anEventOrHand [

	| valuesForHand |

	valuesForHand := self valuesForHand: anEventOrHand.
	^valuesForHand at: aSymbol ifAbsent: [nil].


]

{ #category : #'Nebraska support' }
SketchEditorMorph >> getActionFor: anEventOrHand [

	^(self get: #action for: anEventOrHand) ifNil: [
		self set: #action for: anEventOrHand to: palette action
	].


]

{ #category : #'Nebraska support' }
SketchEditorMorph >> getBrushFor: anEventOrHand [

	^(self get: #brush for: anEventOrHand) ifNil: [
		self set: #brush for: anEventOrHand to: palette getNib
	].


]

{ #category : #'Nebraska support' }
SketchEditorMorph >> getColorFor: anEventOrHand [

	^(self get: #currentColor for: anEventOrHand) ifNil: [
		self set: #currentColor for: anEventOrHand to: palette getColor
	].


]

{ #category : #'Nebraska support' }
SketchEditorMorph >> getCursorFor: anEventOrHand [

	| plainCursor |
	plainCursor := (self get: #currentCursor for: anEventOrHand) ifNil: [
		self set: #currentCursor for: anEventOrHand to: palette plainCursor
	].
	^palette
		cursorFor: (self getActionFor: anEventOrHand) 
		oldCursor: plainCursor 
		currentNib: (self getNibFor: anEventOrHand) 
		color: (self getColorFor: anEventOrHand)


]

{ #category : #'Nebraska support' }
SketchEditorMorph >> getNibFor: anEventOrHand [

	^(self get: #currentNib for: anEventOrHand) ifNil: [
		self set: #currentNib for: anEventOrHand to: palette getNib
	].


]

{ #category : #'event handling' }
SketchEditorMorph >> handlesMouseDown: evt [

	^ true

]

{ #category : #'event handling' }
SketchEditorMorph >> handlesMouseOver: evt [
	^true
]

{ #category : #'event handling' }
SketchEditorMorph >> handlesMouseOverDragging: evt [
	^true
]

{ #category : #access }
SketchEditorMorph >> hostView [
	^ hostView
]

{ #category : #initialization }
SketchEditorMorph >> initializeFor: aSketchMorph inBounds: boundsToUse pasteUpMorph: aPasteUpMorph [
	"Initialize the receiver to edit the given sketchMorph in the given bounds, with the resulting object to reside in the given pasteUpMorph."

	| paintBoxBounds worldBounds |
	self world paintingFlapTab ifNotNil: [:tab |
		tab showFlap.
		^ self
			initializeFor: aSketchMorph
			inBounds: boundsToUse
			pasteUpMorph: aPasteUpMorph
			paintBoxPosition: nil].

	self setProperty: #recipientPasteUp toValue: aPasteUpMorph.

	paintBoxBounds := self world paintBox bounds.
	worldBounds := self world bounds.

	aPasteUpMorph standardPalette ifNotNil: [:palette | palette showNoPalette].

	self initializeFor: aSketchMorph inBounds: boundsToUse 
		pasteUpMorph: aPasteUpMorph 
		paintBoxPosition: ((boundsToUse topRight extent: paintBoxBounds extent)
			translatedToBeWithin: worldBounds) topLeft.

]

{ #category : #initialization }
SketchEditorMorph >> initializeFor: aSketchMorph inBounds: boundsToUse pasteUpMorph: aPasteUpMorph paintBoxPosition: aPosition [
	"NB: if aPosition is nil, then it's assumed that the paintbox is obtained from a flap or some such, so do nothing special regarding a palette in this case.  The palette needs already to be in the world for this to work."
	| w  |
	(w := aPasteUpMorph world) addMorphInLayer: self.	"in back of palette"
	enclosingPasteUpMorph := aPasteUpMorph.
	hostView := aSketchMorph.  "may be ownerless"
	self bounds: boundsToUse.
	palette := w paintBox focusMorph: self.
	palette beStatic.		"give Nebraska whatever help we can"
	palette addWeakDependent: self.
	aPosition ifNotNil:
		[w addMorphFront: palette.  "bring to front"
		palette position: aPosition.
		palette beSupersized.
		self flag: #hacky. "mt: That super-sizing with a flex shell is awkward. Need to fix."
		palette owner bounds: (palette owner bounds translatedToBeWithin: self world bounds)].
	paintingForm := Form extent: bounds extent depth: w assuredCanvas depth.
	self dimTheWindow.
	self addRotationScaleHandles.
	aSketchMorph ifNotNil:
		[
		aSketchMorph form
			displayOn: paintingForm
			at: (hostView boundsInWorld origin - bounds origin - hostView form offset)
			clippingBox: (0@0 extent: paintingForm extent)
			rule: Form over
			fillColor: nil.  "assume they are the same depth".
			undoBuffer := paintingForm deepCopy.
		rotationCenter := aSketchMorph rotationCenter]
]

{ #category : #'actions & preps' }
SketchEditorMorph >> line: evt [ 
	"Draw a line on the paintingForm using formCanvas aimed at it."
	| rect oldRect ww now diff cor cColor sOrigin priorEvt |
	sOrigin := self get: #strokeOrigin for: evt.
	rect := sOrigin rect: (now := evt cursorPoint).
	evt shiftPressed
		ifTrue: [diff := evt cursorPoint - sOrigin.
			now := sOrigin
						+ (Point r: diff r degrees: diff degrees + 22.5 // 45 * 45).
			rect := sOrigin rect: now].
	ww := (self getNibFor: evt) width.
	(priorEvt := self get: #lastEvent for: evt)
		ifNotNil: [oldRect := sOrigin rect: priorEvt cursorPoint.
			priorEvt shiftPressed
				ifTrue: [diff := priorEvt cursorPoint - sOrigin.
					cor := sOrigin
								+ (Point r: diff r degrees: diff degrees + 22.5 // 45 * 45).
					oldRect := sOrigin rect: cor].
			oldRect := oldRect expandBy: ww @ ww.
			"Last draw will always stick out, must erase the area"
			self restoreRect: oldRect].
	cColor := self getColorFor: evt.
	formCanvas
		line: sOrigin
		to: now
		width: ww
		color: cColor.
	self invalidRect: rect
]

{ #category : #'WiW support' }
SketchEditorMorph >> morphicLayerNumber [
	"Place the painting behind the paint palette"

	^ 28
]

{ #category : #morphic }
SketchEditorMorph >> mouseDown: evt [
	"Start a new stroke.  Check if any palette setting have changed.  6/11/97 20:30 tk"
	| cur pfPen myAction |
	"verify that we are in a good state"
	self verifyState: evt.		"includes prepareToPaint and #scalingOrRotate"
	pfPen := self get: #paintingFormPen for: evt.
	paintingForm extent = undoBuffer extent ifTrue: [
		paintingForm displayOn: undoBuffer at: 0@0 rule: Form over.
	] ifFalse: [
		undoBuffer := paintingForm deepCopy.	"know we will draw something"
	].
	pfPen place: (evt cursorPoint - bounds origin).
	myAction := self getActionFor: evt.
	palette colorable ifTrue:[
		palette recentColor: (self getColorFor: evt)].
	self set: #strokeOrigin for: evt to: evt cursorPoint.
		"origin point for pickup: rect: ellispe: polygon: line: star:.  Always take it."
	myAction == #pickup: ifTrue: [
		cur := Cursor corner shallowCopy.
		cur offset: 0@0  "cur offset abs".
		evt hand showTemporaryCursor: cur].
	myAction == #polygon: ifTrue: [self polyNew: evt].	"a mode lets you drag vertices"
	self mouseMove: evt.
]

{ #category : #'event handling' }
SketchEditorMorph >> mouseEnter: evt [
	"Set the cursor.  Reread colors if embedded editable polygon needs it."

	| poly cColor |
	super mouseEnter: evt.
	(self get: #action for: evt) == #scaleOrRotate ifTrue: [
		self set: #action for: evt to: (self get: #priorAction for: evt).
		].	"scale and rotate are not real modes.  If we enter with one, wear the previous tool."
	evt hand showTemporaryCursor: (self getCursorFor: evt).
	palette getSpecial == #polygon: ifFalse: [^self].
	(poly := self valueOfProperty: #polygon) ifNil: [^ self].
	cColor := self getColorFor: evt.
	poly borderColor: cColor; borderWidth: (self getNibFor: evt) width.
	poly changed.
]

{ #category : #'event handling' }
SketchEditorMorph >> mouseEnterDragging: evt [
	"Test button state elsewhere if at all"
	^ self mouseEnter: evt
]

{ #category : #'event handling' }
SketchEditorMorph >> mouseLeave: evt [
	"Revert to the normal hand cursor."

	super mouseLeave: evt.
	evt hand showTemporaryCursor: nil.  "back to normal"
	"If this is modified to close down the SketchEditorMorph in any way, watch out for how it is called when entering a rotationButton and a scaleButton."

]

{ #category : #'event handling' }
SketchEditorMorph >> mouseLeaveDragging: evt [
	"Test button state elsewhere if at all"
	^ self mouseLeave: evt
]

{ #category : #'event handling' }
SketchEditorMorph >> mouseMove: evt [ 
	"In the middle of drawing a stroke.  6/11/97 19:51 tk"

	| pt priorEvt |
	WorldState canSurrenderToOS: false.	"we want maximum responsiveness"
	pt := evt cursorPoint.
	priorEvt := self get: #lastEvent for: evt.
	(priorEvt notNil and: [pt = priorEvt cursorPoint]) ifTrue: [^self].
	self perform: (self getActionFor: evt) with: evt.
	"Each action must do invalidRect:"
	self 
		set: #lastEvent
		for: evt
		to: evt.
	false 
		ifTrue: 
			["So senders will find the things performed here"

			self
				paint: nil;
				fill: nil;
				erase: nil;
				pickup: nil;
				stamp: nil.
			self
				rect: nil;
				ellipse: nil;
				polygon: nil;
				line: nil;
				star: nil]
]

{ #category : #'event handling' }
SketchEditorMorph >> mouseUp: evt [
	| myAction |
	"Do nothing except those that work on mouseUp."

	myAction := self getActionFor: evt.
	myAction == #fill: ifTrue: [
		self perform: myAction with: evt.
		"Each action must do invalidRect:"
		].
	myAction == #pickup: ifTrue: [
		self pickupMouseUp: evt].
	myAction == #polygon: ifTrue: [self polyEdit: evt].	"a mode lets you drag vertices"
	self set: #lastEvent for: evt to: nil.

]

{ #category : #'actions & preps' }
SketchEditorMorph >> notes [
	"
Singleton costumes.
Registration points
"
]

{ #category : #'actions & preps' }
SketchEditorMorph >> paint: evt [
	"While the mouse is down, lay down paint, but only within window bounds.
	 11/28/96 sw: no longer stop painting when pen strays out of window; once it comes back in, resume painting rather than waiting for a mouse up"

	|  mousePoint startRect endRect startToEnd pfPen myBrush |

	pfPen := self get: #paintingFormPen for: evt.
	myBrush := self getBrushFor: evt.
	mousePoint := evt cursorPoint.
	startRect := pfPen location + myBrush offset extent: myBrush extent.
	pfPen goto: mousePoint - bounds origin.
	endRect := pfPen location + myBrush offset extent: myBrush extent.
	"self render: (startRect merge: endRect).	Show the user what happened"
	startToEnd := startRect merge: endRect.
	self invalidRect: (startToEnd translateBy: bounds origin).

]

{ #category : #'palette handling' }
SketchEditorMorph >> paintBoxChanged: arguments [

	self set: arguments first for: arguments second to: arguments third.

]

{ #category : #access }
SketchEditorMorph >> painting [
	^ paintingForm
]

{ #category : #access }
SketchEditorMorph >> palette [
	^palette
]

{ #category : #'palette handling' }
SketchEditorMorph >> paletteAttached: aPaintBoxMorph [
	"A new palette has been attached to the receiver.
	Don't know what to do here..."
]

{ #category : #'palette handling' }
SketchEditorMorph >> paletteDetached: aPaintBoxMorph [
	"The palette has been detached to the receiver.
	Don't know what to do here...."
]

{ #category : #'actions & preps' }
SketchEditorMorph >> pickup: evt [ 
	"Grab a part of the picture (or screen) and store it in a known place.  Note where we started.  Use a rubberband rectangle to show what is being selected."

	| rect oldRect sOrigin priorEvt |
	sOrigin := self get: #strokeOrigin for: evt.
	rect := sOrigin rect: evt cursorPoint + (14 @ 14).
	(priorEvt := self get: #lastEvent for: evt) isNil 
		ifFalse: 
			["Last draw will stick out, must erase the area"

			oldRect := sOrigin rect: priorEvt cursorPoint + (14 @ 14).
			self restoreRect: (oldRect insetBy: -2)].
	formCanvas 
		frameAndFillRectangle: (rect insetBy: -2)
		fillColor: Color transparent
		borderWidth: 2
		borderColor: Color gray.
	self invalidRect: (rect insetBy: -2)
]

{ #category : #'actions & preps' }
SketchEditorMorph >> pickupMouseUp: evt [ 
	"Grab a part of the picture (or screen) and store it in a known place. Like Copy on the Mac menu. Then switch to the stamp tool."

	| rr pForm ii oldRect sOrigin priorEvt |
	sOrigin := self get: #strokeOrigin for: evt.
	(priorEvt := self get: #lastEvent for: evt) isNil 
		ifFalse: 
			["Last draw will stick out, must erase the area"

			oldRect := sOrigin rect: priorEvt cursorPoint + (14 @ 14).
			self restoreRect: (oldRect insetBy: -2)].
	self primaryHand showTemporaryCursor: nil.	"later get rid of this"
	rr := sOrigin rect: evt cursorPoint + (14 @ 14).
	ii := rr translateBy: 0 @ 0 - bounds origin.
	(rr intersects: bounds) 
		ifTrue: 
			[pForm := paintingForm copy: ii.
			pForm isAllWhite 
				ifFalse: 
					["means transparent"

					"normal case.  Can be transparent in parts"

					]
				ifTrue: 
					[pForm := nil
					"Get an un-dimmed picture of other objects on the playfield"
					"don't know how yet"]].
	pForm ifNil: [pForm := Form fromDisplay: rr].	"Anywhere on the screen"
	palette pickupForm: pForm evt: evt.
	evt hand showTemporaryCursor: (self getCursorFor: evt)
]

{ #category : #'actions & preps' }
SketchEditorMorph >> polyEdit: evt [
	"Add handles and let user drag'em around"
	| poly |
	poly := self valueOfProperty: #polygon.
	poly ifNil:[^self].
	poly addHandles.
	self polyEditing: true.
	self setProperty: #polyCursor toValue: palette plainCursor.
	palette plainCursor: Cursor normal event: evt.
]

{ #category : #'actions & preps' }
SketchEditorMorph >> polyEditing [
	^self valueOfProperty: #polyEditing ifAbsent:[false]
]

{ #category : #'actions & preps' }
SketchEditorMorph >> polyEditing: aBool [
	aBool
		ifTrue:[self setProperty: #polyEditing toValue: aBool]
		ifFalse:[self removeProperty: #polyEditing]
]

{ #category : #'actions & preps' }
SketchEditorMorph >> polyFreeze [
	"A live polygon is on the painting.  Draw it into the painting and
delete it."

	| poly |
	self polyEditing ifFalse:[^self].
	(poly := self valueOfProperty: #polygon)
		ifNil:
			[self polyEditing: false.
			^ self].
	poly drawOn: formCanvas.
	poly delete.
	self setProperty: #polygon toValue: nil.
	self polyEditing: false.
]

{ #category : #'actions & preps' }
SketchEditorMorph >> polyNew: evt [
	"Create a new polygon.  Add it to the sketch, and let the user drag
its vertices around!  Freeze it into the painting when the user chooses
another tool."

	| poly cColor |
	self polyEditing ifTrue:[
		self polyFreeze.
		(self hasProperty: #polyCursor)
			ifTrue:[palette plainCursor: (self valueOfProperty: #polyCursor) event: evt.
					self removeProperty: #polyCursor].
		^self].
	cColor := self getColorFor: evt.
	self polyFreeze.		"any old one we were working on"
	poly := PolygonMorph new "addHandles".
	poly referencePosition: poly bounds origin.
	poly align: poly bounds center with: evt cursorPoint.
	poly borderWidth: (self getNibFor: evt) width.
	poly borderColor: (cColor isTransparent ifTrue: [Color black] ifFalse: [cColor]).
	poly color: Color transparent.
	self addMorph: poly.
	poly changed.
	self setProperty: #polygon toValue: poly.
]

{ #category : #'actions & preps' }
SketchEditorMorph >> polygon: evt [
	| poly |
	poly := self valueOfProperty: #polygon.
	poly ifNil:[^self].
	evt cursorPoint > poly bounds origin ifTrue:[
		poly extent: ((evt cursorPoint - poly bounds origin) max: 5@5)].
]

{ #category : #'start & finish' }
SketchEditorMorph >> prepareToPaint: evt [
	"Figure out what the current brush, fill, etc is.  Return an action to take every mouseMove.  Set up instance variable and pens.  Prep for normal painting is inlined here.  tk 6/14/97 21:11"

	| specialMode pfPen cColor cNib myBrush |
	"Install the brush, color, (replace mode), and cursor."
	specialMode := self getActionFor: evt.
 	cColor  := self getColorFor: evt.
	cNib := self getNibFor: evt.
	self set: #brush for: evt to: (myBrush := cNib).
	self set: #paintingFormPen for: evt to: (pfPen := Pen newOnForm: paintingForm).
	self set: #stampForm for: evt to: nil.	"let go of stamp"
	formCanvas := paintingForm getCanvas.	"remember to change when undo"
	formCanvas := formCanvas
		copyOrigin: self topLeft negated
		clipRect: (0@0 extent: bounds extent).

	specialMode == #paint: ifTrue: [
		"get it to one bit depth.  For speed, instead of going through a colorMap every time ."
		self set: #brush for: evt to: (myBrush := Form extent: myBrush extent depth: 1).
		myBrush offset: (0@0) - (myBrush extent // 2).
		cNib displayOn: myBrush at: (0@0 - cNib offset).

		pfPen sourceForm: myBrush.
		pfPen combinationRule: Form paint.
		pfPen color: cColor.
		cColor isTransparent ifTrue: [
			pfPen combinationRule: Form erase1bitShape.
			pfPen color: Color black].
		^ #paint:].

	specialMode == #erase: ifTrue: [
		self erasePrep: evt.
		^ #erase:].
	specialMode == #stamp: ifTrue: [
		self set: #stampForm for: evt to: palette stampForm.	"keep it"
		^ #stamp:].

	(self respondsTo: specialMode) 
		ifTrue: [^ specialMode]	"fill: areaFill: pickup: (in mouseUp:) 
				rect: ellipse: line: polygon: star:"
		ifFalse: ["Don't recognise the command"
			palette setAction: #paint: evt: evt.	"set it to Paint"
			^ self prepareToPaint: evt].
]

{ #category : #'actions & preps' }
SketchEditorMorph >> rect: evt [ 
	"While moving corner, just write on the canvas. When done, write on the paintingForm"

	| rect oldRect now diff cor cColor sOrigin priorEvt |
	sOrigin := self get: #strokeOrigin for: evt.
	rect := sOrigin rect: (now := evt cursorPoint).
	cColor := self getColorFor: evt.
	evt shiftPressed
		ifTrue: [diff := evt cursorPoint - sOrigin.
			now := sOrigin
						+ (Point r: (diff x abs min: diff y abs)
									* 2 degrees: diff degrees // 90 * 90 + 45).
			rect := sOrigin rect: now].
	(priorEvt := self get: #lastEvent for: evt) isNil
		ifFalse: [oldRect := sOrigin rect: priorEvt cursorPoint.
			priorEvt shiftPressed
				ifTrue: [diff := priorEvt cursorPoint - sOrigin.
					cor := sOrigin
								+ (Point r: (diff x abs min: diff y abs)
											* 2 degrees: diff degrees // 90 * 90 + 45).
					oldRect := sOrigin rect: cor].
		self restoreRect: oldRect].  		"Last draw will stick out, must erase the area"

	cColor == Color transparent
		ifTrue: [formCanvas
				frameAndFillRectangle: rect
				fillColor: Color transparent
				borderWidth: (self getNibFor: evt) width
				borderColor: Color black]
		ifFalse: [formCanvas
				frameAndFillRectangle: rect
				fillColor: Color transparent
				borderWidth: (self getNibFor: evt) width
				borderColor: cColor].
	self invalidRect: rect
]

{ #category : #access }
SketchEditorMorph >> registrationPoint [
	^ registrationPoint
]

{ #category : #access }
SketchEditorMorph >> registrationPoint: aPoint [
	registrationPoint := aPoint
]

{ #category : #'actions & preps' }
SketchEditorMorph >> render: damageRect [
	"Compose the damaged area again and store on the display.  damageRect is relative to paintingForm origin.  3/19/97 tk"

	self invalidRect: damageRect.	"Now in same coords as self bounds"

]

{ #category : #'actions & preps' }
SketchEditorMorph >> replaceOnly: initialMousePoint [
	"Paint replacing only one color!  Call this each stroke.  Also works for replacing all but one color.  "


]

{ #category : #'actions & preps' }
SketchEditorMorph >> restoreRect: oldRect [
	"Restore the given rectangular area of the painting Form from the undo buffer."

	formCanvas drawImage: undoBuffer
		at: oldRect origin
		sourceRect: (oldRect translateBy: self topLeft negated).
	self invalidRect: oldRect.

]

{ #category : #'actions & preps' }
SketchEditorMorph >> rotateBy: evt [ 
	"Left-right is rotation. 3/26/97 tk Slider at top of window. 4/3/97 tk"
	| pt temp amt smooth myBuff |

	myBuff := self get: #buff for: evt.
	evt cursorPoint x - self left < 20
		ifTrue: [^ self flipHoriz: evt].
	"at left end flip horizontal"
	evt cursorPoint x - self right > -20
		ifTrue: [^ self flipVert: evt].
	"at right end flip vertical"
	pt := evt cursorPoint - bounds center.
	smooth := 2.
	"paintingForm depth > 8 ifTrue: [2] ifFalse: [1]."
	"Could go back to 1 for speed"
	amt := pt x abs < 12
				ifTrue: ["detent"
					0]
				ifFalse: [pt x - (12 * pt x abs // pt x)].
	amt := amt * 1.8.
	temp := myBuff
				rotateBy: amt
				magnify: cumMag
				smoothing: smooth.
	temp displayOn: paintingForm at: paintingForm center - temp center + myBuff offset.
	rotationButton position: evt cursorPoint x - 6 @ rotationButton position y.
	self render: bounds.
	cumRot := amt
]

{ #category : #'actions & preps' }
SketchEditorMorph >> rotateDone: evt [
	"MouseUp, snap box back to center."

"
self render: rotationButton bounds.
rotationButton position: (canvasRectangle width // 2 + composite x) @ rotationButton position y.
self render: rotationButton bounds.
"		"Not snap back..."
]

{ #category : #'actions & preps' }
SketchEditorMorph >> rotateScalePrep: evt [
	"Make a source that is the paintingForm.  Work from that.  3/26/97 tk"

	| newBox myBuff |

	(self getActionFor: evt) == #scaleOrRotate ifTrue: [^ self].	"Already doing it"
	paintingForm width > 120 
		ifTrue: [newBox := paintingForm rectangleEnclosingPixelsNotOfColor: Color transparent.
			"minimum size"
			newBox := newBox insetBy: 
				((18 - newBox width max: 0)//2) @ ((18 - newBox height max: 0)//2) * -1]
		ifFalse: [newBox := paintingForm boundingBox].
	newBox := newBox expandBy: 1.
	self set: #buff for: evt to: (myBuff := Form extent: newBox extent depth: paintingForm depth).
	myBuff offset: newBox center - paintingForm center.
	myBuff copyBits: newBox from: paintingForm at: 0@0 
		clippingBox: myBuff boundingBox rule: Form over fillColor: nil.
	"Could just run up owner chain asking colorUsed, but may not be embedded"
	cumRot := 0.0.  cumMag := 1.0.	"start over"
	self set: #changed for: evt to: true.
	self set: #action for: evt to: #scaleOrRotate.
		"Only changed by mouseDown with tool in paint area"
]

{ #category : #'e-toy support' }
SketchEditorMorph >> rotationStyle [

^ (self valueOfProperty: #rotationStyle) ifNil: [#normal]
]

{ #category : #'start & finish' }
SketchEditorMorph >> save: evt [
	"Palette is telling us that the use wants to end the painting session.  "

	Cursor blank show.
	(self getActionFor: evt) == #polygon: ifTrue: [self polyFreeze].		"end polygon mode"
	^ self deliverPainting: #okay evt: evt.
]

{ #category : #'palette handling' }
SketchEditorMorph >> savePainting: aPaintBoxMorph evt: evt [
	"Save the image after user issued #keep in aPaintBoxMorph"
	^self save: evt
]

{ #category : #'actions & preps' }
SketchEditorMorph >> scaleBy: evt [ 
	"up-down is scale. 3/26/97 tk Now a slider on the right."
	| pt temp cy oldRect amt myBuff |

	myBuff := self get: #buff for: evt.
	pt := evt cursorPoint - bounds center.
	cy := bounds height * 0.5.
	oldRect := myBuff boundingBox expandBy: myBuff extent * cumMag / 2.
	amt := pt y abs < 12
				ifTrue: ["detent"
					1.0]
				ifFalse: [pt y - (12 * pt y abs // pt x)].
	amt := amt asFloat / cy + 1.0.
	temp := myBuff
				rotateBy: cumRot
				magnify: amt
				smoothing: 2.
	cumMag > amt
		ifTrue: ["shrinking"
			oldRect := oldRect translateBy: paintingForm center - oldRect center + myBuff offset.
			paintingForm
				fill: (oldRect expandBy: 1 @ 1)
				rule: Form over
				fillColor: Color transparent].
	temp displayOn: paintingForm at: paintingForm center - temp center + myBuff offset.
	scaleButton position: scaleButton position x @ (evt cursorPoint y - 6).
	self render: bounds.
	cumMag := amt
]

{ #category : #'Nebraska support' }
SketchEditorMorph >> set: aSymbol for: anEventOrHand to: anObject [

	| valuesForHand |

	valuesForHand := self valuesForHand: anEventOrHand.
	aSymbol == #action ifTrue: [
		valuesForHand at: #priorAction put: (valuesForHand at: #action ifAbsent: [#paint:]).
		(anObject ~~ #polygon: and:[self polyEditing]) ifTrue:[self polyFreeze].
	].
	valuesForHand at: aSymbol put: anObject.
	^anObject


]

{ #category : #morphic }
SketchEditorMorph >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed"
	super setExtentFromHalo: ((anExtent x max: paintingForm width) @ (anExtent y max: paintingForm height)).

]

{ #category : #'start & finish' }
SketchEditorMorph >> setRotations: num [
	"Tell the palette what number of rotations (or background) to show.  "

	| key |
	key := 'ItTurns'.	"default and value for num > 1"
	num = 1 ifTrue: [key := 'JustAsIs'].
	num = 18 ifTrue: [key := 'ItTurns'].
	num = 99 ifTrue: [key := 'ToAndFro'].
	num == #Background ifTrue: [key := 'Background'].
	num == #Repeated ifTrue: [key := 'Repeated'].
	palette setRotations: (palette contentsAtKey: key).
]

{ #category : #'actions & preps' }
SketchEditorMorph >> shiftConstrainPoint: aPoint [

	"answer a point with x and y equal for shift-constrained drawing"

	^aPoint max: aPoint transposed
]

{ #category : #'actions & preps' }
SketchEditorMorph >> showDirType [
	"Display the proper symbol for this direction type.  rotationStyle
is one of #(normal leftRight upDown none)."

| rr poly |
rr := self rotationStyle.
poly := self valueOfProperty: #fwdButton.
rr == #normal ifTrue: [^ poly makeBackArrow].
rr == #leftRight ifTrue: [
	poly makeBothArrows.
	^ poly setVertices: (Array with: poly center - (7@0) with:  poly
center + (7@0))].
rr == #upDown ifTrue: [
	poly makeBothArrows.
	^ poly setVertices: (Array with: poly center - (0@7) with:  poly
center + (0@7))].
rr == #none ifTrue: [
	poly makeNoArrows.
	^ poly setVertices: (Array with: poly center - (7@0) with:  poly
center + (7@0)
		 with: poly center with: poly center - (0@7) with:  poly
center + (0@7))].

]

{ #category : #'actions & preps' }
SketchEditorMorph >> stamp: evt [
	"plop one copy of the user's chosen Form down."

	"Check depths"
	| pt sForm |

	sForm := self get: #stampForm for: evt.
	pt := evt cursorPoint - (sForm extent // 2).
	sForm displayOn: paintingForm 
		at: pt - bounds origin
		clippingBox: paintingForm boundingBox
		rule: Form paint
		fillColor: nil.
	self render: (pt extent: sForm extent).

]

{ #category : #'actions & preps' }
SketchEditorMorph >> star: evt [ 
	"Draw an star from the center."
	| poly ext ww rect oldExt oldRect oldR verts pt cColor sOrigin priorEvt |
	sOrigin := self get: #strokeOrigin for: evt.
	cColor := self getColorFor: evt.
	ww := (self getNibFor: evt) width.
	ext := (pt := sOrigin - evt cursorPoint) r + ww * 2.
	rect := Rectangle center: sOrigin extent: ext.
	(priorEvt := self get: #lastEvent for: evt)
		ifNotNil: [oldExt := (sOrigin - priorEvt cursorPoint) r + ww * 2.
			"Last draw sticks out, must erase the area"
			oldRect := Rectangle center: sOrigin extent: oldExt.
			self restoreRect: oldRect].
	ext := pt r.
	oldR := ext.
	verts := (0 to: 350 by: 36)
				collect: [:angle | (Point r: (oldR := oldR = ext
									ifTrue: [ext * 5 // 12]
									ifFalse: [ext]) degrees: angle + pt degrees)
						+ sOrigin].
	poly := PolygonMorph new addHandles.
	poly borderColor: (cColor isTransparent ifTrue: [Color black] ifFalse: [cColor]).
	poly borderWidth: (self getNibFor: evt) width.
	poly fillStyle: Color transparent.

	"can't handle thick brushes"
	self invalidRect: rect.
	"self addMorph: poly."
	poly privateOwner: self.
	poly
		bounds: (sOrigin extent: ext).
	poly setVertices: verts.
	poly drawOn: formCanvas.
	"poly delete."
	self invalidRect: rect
]

{ #category : #access }
SketchEditorMorph >> ticksToDwell [
	ticksToDwell isNil ifTrue: [ticksToDwell := 1].
	^ticksToDwell
]

{ #category : #access }
SketchEditorMorph >> ticksToDwell: t [
	ticksToDwell := t
]

{ #category : #'actions & preps' }
SketchEditorMorph >> toggleDirType: evt in: handle [
	"Toggle from 'rotate' to 'to and fro' to 'up and down' to 'none'
for the kind of rotation the object does.  An actor's rotationStyle is one
of #(normal leftRight upDown none)."

| rr ii |
"Clear the indicator"

"Find new style, store it, install the indicator"
rr := self rotationStyle.
ii := #(normal leftRight upDown none) indexOf: rr.
self setProperty: #rotationStyle toValue:
	(#(leftRight upDown none normal) at: ii).
ii = 4 ifTrue: ["normal" self forward: self forwardDirection
			direction: (self valueOfProperty: #fwdButton)]
	ifFalse: [self showDirType.].
]

{ #category : #'start & finish' }
SketchEditorMorph >> undo: evt [ 
	"revert to a previous state.  "

	| temp poly pen |
	self flag: #bob.	"what is undo in multihand environment?"
	undoBuffer ifNil: [^Beeper beep].	"nothing to go back to"
	(poly := self valueOfProperty: #polygon) ifNotNil: 
			[poly delete.
			self setProperty: #polygon toValue: nil.
			self polyEditing: false.
			^self].
	temp := paintingForm.
	paintingForm := undoBuffer.
	undoBuffer := temp.	"can get back to what you had by undoing again"
	pen := self get: #paintingFormPen for: evt.
	pen ifNil: [^Beeper  beep].
	pen setDestForm: paintingForm.
	formCanvas := paintingForm getCanvas.	"used for lines, ovals, etc."
	formCanvas := formCanvas copyOrigin: self topLeft negated
				clipRect: (0 @ 0 extent: bounds extent).
	self render: bounds
]

{ #category : #'palette handling' }
SketchEditorMorph >> undoPainting: aPaintBoxMorph evt: evt [
	"Undo the operation after user issued #undo in aPaintBoxMorph"
	^self undo: evt
]

{ #category : #'Nebraska support' }
SketchEditorMorph >> valuesForHand: anEventOrHand [

	| hand valuesForHand |
	forEachHand ifNil: [forEachHand := IdentityDictionary new].
	hand := (anEventOrHand isKindOf: HandMorph) 
				ifTrue: [anEventOrHand] ifFalse: [anEventOrHand hand].
	valuesForHand := forEachHand at: hand ifAbsentPut: [Dictionary new].
	^valuesForHand


]

{ #category : #'Nebraska support' }
SketchEditorMorph >> valuesForHandIfPresent: anEventOrHand [ 
	| hand |
	forEachHand ifNil: [forEachHand := IdentityDictionary new].
	hand := (anEventOrHand isHandMorph) 
				ifTrue: [anEventOrHand]
				ifFalse: [anEventOrHand hand].
	^forEachHand at: hand ifAbsent: [nil]
]

{ #category : #'start & finish' }
SketchEditorMorph >> verifyState: evt [
	| myAction |
	"We are sure we will make a mark now.  Make sure the palette has not changed state while we were away.  If so, end this action and start another one.  6/11/97 19:52 tk  action, currentColor, brush"

	"Install the brush, color, (replace mode), and cursor."
	palette isInWorld ifFalse:
		[self world addMorphFront: palette].  "It happens.  might want to position it also"
	myAction := self getActionFor: evt.
	(self get: #changed for: evt) == false ifFalse: [
		self set: #changed for: evt to: false.
		self invalidRect: rotationButton bounds.	"snap these back"
		rotationButton position: bounds topCenter - (6@0).		"later adjust by button width?"
		self invalidRect: rotationButton bounds.
		self invalidRect: scaleButton bounds.
		scaleButton position: bounds rightCenter - ((scaleButton width)@6).
		self invalidRect: scaleButton bounds.
		myAction == #polygon: ifFalse: [self polyFreeze].		"end polygon mode"
		^ self set: #action for: evt to: (self prepareToPaint: evt)].


]

{ #category : #copying }
SketchEditorMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
hostView := deepCopier references at: hostView ifAbsent: [hostView].
enclosingPasteUpMorph := deepCopier references at: enclosingPasteUpMorph 
			ifAbsent: [enclosingPasteUpMorph].
]

{ #category : #copying }
SketchEditorMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"hostView := hostView.		Weakly copied"
	"stampForm := stampForm veryDeepCopyWith: deepCopier."
	"canvasRectangle := canvasRectangle veryDeepCopyWith: deepCopier."
palette := palette veryDeepCopyWith: deepCopier.
	"currentColor := currentColor veryDeepCopyWith: deepCopier."
ticksToDwell := ticksToDwell veryDeepCopyWith: deepCopier.
rotationCenter := rotationCenter veryDeepCopyWith: deepCopier.
registrationPoint := registrationPoint veryDeepCopyWith: deepCopier.
newPicBlock := newPicBlock veryDeepCopyWith: deepCopier.
emptyPicBlock := emptyPicBlock veryDeepCopyWith: deepCopier.
	"action := action veryDeepCopyWith: deepCopier."
paintingForm := paintingForm veryDeepCopyWith: deepCopier.
dimForm := dimForm veryDeepCopyWith: deepCopier.
	"buff := buff veryDeepCopyWith: deepCopier."
	"brush := brush veryDeepCopyWith: deepCopier."
	"paintingFormPen := paintingFormPen veryDeepCopyWith: deepCopier."
formCanvas := formCanvas veryDeepCopyWith: deepCopier.
	"picToBuff := picToBuff veryDeepCopyWith: deepCopier."
	"brushToBuff := brushToBuff veryDeepCopyWith: deepCopier."
	"buffToBuff := buffToBuff veryDeepCopyWith: deepCopier."
	"buffToPic := buffToPic veryDeepCopyWith: deepCopier."
rotationButton := rotationButton veryDeepCopyWith: deepCopier.
scaleButton := scaleButton veryDeepCopyWith: deepCopier.
	"strokeOrigin := strokeOrigin veryDeepCopyWith: deepCopier."
cumRot := cumRot veryDeepCopyWith: deepCopier.
cumMag := cumMag veryDeepCopyWith: deepCopier.
undoBuffer := undoBuffer veryDeepCopyWith: deepCopier.
	"lastEvent := lastEvent veryDeepCopyWith: deepCopier."
	"currentNib := currentNib veryDeepCopyWith: deepCopier."
enclosingPasteUpMorph := enclosingPasteUpMorph.	"weakly copied"
forEachHand := nil.	"hmm..."                              
]

{ #category : #'e-toy support' }
SketchEditorMorph >> wantsHaloFromClick [

	^ Preferences eToyFriendly not.

]
