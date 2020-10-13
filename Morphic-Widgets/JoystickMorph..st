"
A widget that simulates a joystick. Mosly used in etoy scripting.
"
Class {
	#name : #JoystickMorph,
	#superclass : #SketchMorph,
	#instVars : [
		'handleMorph',
		'xScale',
		'yScale',
		'radiusScale',
		'lastAngle',
		'autoCenter',
		'realJoystickIndex',
		'lastRealJoystickValue',
		'button1',
		'button2'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #scripting }
JoystickMorph class >> authoringPrototype [
	^ self new markAsPartsDonor
]

{ #category : #'parts bin' }
JoystickMorph class >> descriptionForPartsBin [
	^ self partName: 	'Joystick' translatedNoop
		categories:		{'Basic' translatedNoop}
		documentation:	'A joystick-like control' translatedNoop
]

{ #category : #'new-morph participation' }
JoystickMorph class >> includeInNewMorphMenu [
	^ true
]

{ #category : #'class initialization' }
JoystickMorph class >> initialize [

	self registerInFlapsRegistry.
]

{ #category : #'class initialization' }
JoystickMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#JoystickMorph. #authoringPrototype. 'Joystick' translatedNoop. 'A joystick-like control' translatedNoop} 
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#JoystickMorph	. #authoringPrototype. 'Joystick' translatedNoop. 'A joystick-like control' translatedNoop} 
						forFlapNamed: 'Scripting'.
						cl registerQuad: {#JoystickMorph	. #authoringPrototype. 'Joystick' translatedNoop. 'A joystick-like control' translatedNoop}
						forFlapNamed: 'Supplies']
]

{ #category : #'class initialization' }
JoystickMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #menu }
JoystickMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add custom items to the menu"

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu add: 'set X range' translated action: #setXRange.
	aCustomMenu add: 'set Y range' translated action: #setYRange.
	aCustomMenu addLine.
	aCustomMenu addUpdating: #autoCenterString target: self action: #toggleAutoCenter.
	aCustomMenu balloonTextForLastItem: 'When auto-center is on, every time you let go of the Joystick knob, it springs back to the neutral position at the center of the device' translated. 
	aCustomMenu addUpdating: #realJoystickString target: self action: #toggleRealJoystick.
	aCustomMenu balloonTextForLastItem: 'Governs whether this joystick should track the motions of a real, physical joystick attached to the computer.' translated. 
	aCustomMenu addUpdating: #joystickNumberString enablementSelector: #realJoystickInUse target: self selector: #chooseJoystickNumber argumentList: #().
	aCustomMenu balloonTextForLastItem: 'Choose which physical device is associated with the joystick.' translated
]

{ #category : #accessing }
JoystickMorph >> amount [

	^ (handleMorph center - self center) r * radiusScale
]

{ #category : #accessing }
JoystickMorph >> angle [

	self center = handleMorph center ifTrue: [^ lastAngle].
	^ 360.0 - (handleMorph center - self center) theta radiansToDegrees
]

{ #category : #menu }
JoystickMorph >> autoCenterString [
	"Answer a string characterizing whether or not I have auto-center on"

	^ (autoCenter == true	ifTrue: ['<yes>'] ifFalse: ['<no>']), ('auto-center' translated)
]

{ #category : #accessing }
JoystickMorph >> button1 [
	^button1 == true
]

{ #category : #accessing }
JoystickMorph >> button2 [
	^button2 == true
]

{ #category : #menu }
JoystickMorph >> chooseJoystickNumber [
	"Allow the user to select a joystick number"

	| result aNumber str |
	str := self lastRealJoystickIndex asString.
	result := UIManager default 
				request: ('Joystick device number (currently {1})' translated format: {str})
				initialAnswer: str.
	aNumber := [result asNumber] on: Error do: [:err | ^Beeper beep].
	(aNumber > 0 and: [aNumber <= 32]) 
		ifFalse: 
			["???"

			^Beeper beep].
	realJoystickIndex := aNumber.
	self setProperty: #lastRealJoystickIndex toValue: aNumber.
	self startStepping
]

{ #category : #'event handling' }
JoystickMorph >> handlesMouseDown: evt [

	self inPartsBin ifTrue: [^ false].

	true ifTrue: [^ true].  "5/7/98 jhm temporary fix to allow use when rotated"

	(handleMorph fullContainsPoint: evt cursorPoint)
		ifTrue: [^ true]
		ifFalse: [^ super handlesMouseDown: evt].

]

{ #category : #initialization }
JoystickMorph >> initialize [

	super initialize.
	xScale := 0.25.
	yScale := 0.25.
	radiusScale := 1.0.
	lastAngle := 0.0.
	autoCenter := true.
	self form: ((Form extent: 55@55 depth: 8) fillColor: (Color r: 0.3 g: 0.2 b: 0.2)).
	handleMorph := EllipseMorph new.
	handleMorph color: Color red; extent: 15@15.
	self addMorph: handleMorph.
	self moveHandleToCenter.
	button1 := false.
	button2 := false.

]

{ #category : #'parts bin' }
JoystickMorph >> initializeToStandAlone [
	"Circumvent SketchMorph's implementation here"

	self initialize
]

{ #category : #'halos and balloon help' }
JoystickMorph >> isLikelyRecipientForMouseOverHalos [
	"The automatic mouseover halos interere with the proper functioning of the joystick's knob"

	^ false
]

{ #category : #menu }
JoystickMorph >> joystickNumberString [
	"Answer a string characterizing the joystick number"

	^ 'set real joystick number (now {1})' translated format: {self lastRealJoystickIndex asString}.

]

{ #category : #menu }
JoystickMorph >> lastRealJoystickIndex [
	"Answer the last remembered real joystick index.  Initialize it to 1 if need be"

	^ self valueOfProperty: #lastRealJoystickIndex ifAbsentPut: [1] 
]

{ #category : #accessing }
JoystickMorph >> leftRight [

	^ (handleMorph center x - self center x) * xScale

]

{ #category : #'event handling' }
JoystickMorph >> mouseMove: evt [
	"Make handle track the cursor within my bounds."

	| m r center |
	m := handleMorph.
	center := m center.
	r := m owner innerBounds insetBy:
		((center - m fullBounds origin) corner: (m fullBounds corner - center)).
	m position: (evt cursorPoint adhereTo: r) - (m extent // 2).

]

{ #category : #'event handling' }
JoystickMorph >> mouseUp: evt [

	lastAngle := self angle.
	autoCenter ifTrue: [self moveHandleToCenter].

]

{ #category : #other }
JoystickMorph >> moveHandleToCenter [

	handleMorph position: self center - (handleMorph extent // 2).

]

{ #category : #menu }
JoystickMorph >> realJoystickInUse [
	"Answer whether a real joystick is in use"

	^ realJoystickIndex notNil
]

{ #category : #menu }
JoystickMorph >> realJoystickString [
	"Answer a string characterizing whether or not I am currenty tracking a real joystick"

	^ (realJoystickIndex ifNil: ['<no>'] ifNotNil: ['<yes>']), ('track real joystick' translated)
]

{ #category : #menu }
JoystickMorph >> setXRange [

	| range |
	range := UIManager default
		request:
'Type the maximum value for the X axis' translated
		initialAnswer: ((xScale * (self width - handleMorph width) / 2.0) printShowingMaxDecimalPlaces: 2).
	range isEmpty ifFalse: [
		xScale := (2.0 * range asNumber asFloat) / (self width - handleMorph width)].

]

{ #category : #menu }
JoystickMorph >> setYRange [

	| range |
	range := UIManager default
		request:
'Type the maximum value for the Y axis'  translated
		initialAnswer: ((yScale * (self width - handleMorph width) / 2.0) printShowingMaxDecimalPlaces: 2).
	range isEmpty ifFalse: [
		yScale := (2.0 * range asNumber asFloat) / (self width - handleMorph width)].

]

{ #category : #'stepping and presenter' }
JoystickMorph >> step [
	"Track the real joystick whose index is realJoystickIndex."
	"Details:
	  a. if realJoystickIndex is nil we're not tracking a joystick
	  b. [-joyMax..joyMax] is nominal range of joystick in both X and Y
	  c. [-threshold..threshold] is considered 0 to compensate for poor joystick centering"

	| threshold joyMax joyPt joyBtn m mCenter r scaledPt  |
	super step.  "Run ticking user-written scripts if any"
	realJoystickIndex ifNil: [^ self].
	threshold := 30.
	joyMax := 350.
	joyPt := Sensor joystickXY: realJoystickIndex.
	joyBtn := Sensor joystickButtons: realJoystickIndex.

	button1 := (joyBtn bitAnd: 1) > 0.
	button2 := (joyBtn bitAnd: 2) > 0.
	
	joyPt x abs < threshold ifTrue: [joyPt := 0@joyPt y].
	joyPt y abs < threshold ifTrue: [joyPt := joyPt x@0].
	lastRealJoystickValue = joyPt ifTrue: [^ self].
	lastRealJoystickValue := joyPt.
	m := handleMorph.
	mCenter := m center.
	r := m owner innerBounds insetBy:
		((mCenter - m fullBounds origin) corner: (m fullBounds corner - mCenter)).
	scaledPt := r center + ((r extent * joyPt) / (joyMax * 2)) truncated.
	m position: (scaledPt adhereTo: r) - (m extent // 2).

]

{ #category : #'stepping and presenter' }
JoystickMorph >> stepTime [
	"Provide for as-fast-as-possible stepping in the case of a real joystick"

	^ realJoystickIndex
		ifNotNil:
			[0]  "fast as we can to track actual joystick"
		ifNil:
			[super stepTime]
]

{ #category : #menu }
JoystickMorph >> stopTrackingJoystick [

	realJoystickIndex := nil.
	self stopStepping.

]

{ #category : #menu }
JoystickMorph >> toggleAutoCenter [

	autoCenter := autoCenter not.
	autoCenter ifTrue: [self moveHandleToCenter].

]

{ #category : #menu }
JoystickMorph >> toggleRealJoystick [
	"Toggle whether or not one is using a real joystick"

	realJoystickIndex
		ifNil:
			[realJoystickIndex := self valueOfProperty: #lastRealJoystickIndex ifAbsentPut: [1].
			self startStepping]
		ifNotNil:
			[self stopTrackingJoystick]
]

{ #category : #menu }
JoystickMorph >> trackRealJoystick [

	| s |
	s := UIManager default
		request: 'Number of joystick to track?'
		initialAnswer: '1'.
	s isEmpty ifTrue: [^ self].
	realJoystickIndex := Number readFromString: s.
	self startStepping.

]

{ #category : #accessing }
JoystickMorph >> upDown [

	^ (self center y - handleMorph center y) * yScale

]
