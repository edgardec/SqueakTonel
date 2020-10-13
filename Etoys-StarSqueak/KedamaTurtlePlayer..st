"
A defunct class that represents the turtles in the KedamaWorld.  In this version, each turtle was represented as a full-fledged player.  Kept here to remember the alternative implementation.
"
Class {
	#name : #KedamaTurtlePlayer,
	#superclass : #Player,
	#instVars : [
		'world',
		'who',
		'x',
		'y',
		'headingRadians',
		'color',
		'visible'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #compiling }
KedamaTurtlePlayer class >> isUniClass [
	"Uni-classes end with digits"
	^self name endsWithDigit
]

{ #category : #accessing }
KedamaTurtlePlayer >> asPoint [

	^ x truncated @ y truncated

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> color [

	^ color.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> color: aColor [

	color := aColor.



]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> die [
	"Delete this turtle at the end of the current cycle. The turtle will finish running all demons for the current cycle before it dies."

	world deleteTurtleID: self getScalarWho of: self class.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> getAngleTo: aPlayer [

	| ret |
	ret := ((aPlayer x - self x)@(aPlayer y - self y)) theta radiansToDegrees + 90.0.
	ret > 360.0 ifTrue: [^ ret - 360].
	^ ret.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> getDistanceTo: aPlayer [

	| dist |
	dist := ((aPlayer x - self x) squared + (aPlayer y - self y) squared) sqrt.
	^ dist.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> getHeading [
	"Answer my heading in degrees."

	| degrees |
	degrees := 90.0 - headingRadians radiansToDegrees.
	^ degrees >= 0.0 ifTrue: [degrees] ifFalse: [degrees + 360.0].

]

{ #category : #patches }
KedamaTurtlePlayer >> getPatchValueIn: aPatch [

	^ aPatch costume renderedMorph pixelAtX: x y: y.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> getReplicated [

	| newGuys theNewGuy |
	newGuys := world makeTurtles: 1 turtlePlayerClass: self class color: self color ofPrototype: self.
	theNewGuy := newGuys first.
	theNewGuy x: self x.
	theNewGuy y: self y.
	theNewGuy heading: self heading.
	(world prototypeOf: self class) privateTurtleCount: (world turtlesCountOf: self class).
	^ theNewGuy

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> getUphillIn: aPatch [

	^ aPatch costume renderedMorph uphillForTurtle: self.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> getX [

	^ x.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> getXAndY [

	^ x@y.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> getY [

	^ y.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> goto: aPoint [
	"Jump to the given location."

	x := aPoint x.
	y := aPoint y.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> heading [
	"Answer my heading in degrees."

	| degrees |
	degrees := 90.0 - headingRadians radiansToDegrees.
	^ degrees >= 0.0 ifTrue: [degrees] ifFalse: [degrees + 360.0].

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> heading: angleInDegrees [
	"Set my heading in degrees. Like a compass, up or north is 0 degrees and right or east is 90 degrees."

	headingRadians := ((90.0 - angleInDegrees) \\ 360.0) degreesToRadians.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> hide [

	visible := false

]

{ #category : #initialization }
KedamaTurtlePlayer >> initializeWorld: aStarSqueakWorld who: anInteger color: cPixel [

	| dims |
	dims := aStarSqueakWorld dimensions.
	world := aStarSqueakWorld.
	who := anInteger.
	x := world random: dims x - 1.
	y := world random: dims y - 1.
	headingRadians := ((self random: 36000) / 100.0) degreesToRadians.
	color := cPixel.
	self isGroup: false.
	self show.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> isGroup: aBoolean [

]

{ #category : #accessing }
KedamaTurtlePlayer >> isInWorld [

	^ world isInWorld.

]

{ #category : #accessing }
KedamaTurtlePlayer >> owner [

	^ world.

]

{ #category : #patches }
KedamaTurtlePlayer >> patchBrightness: percent [
	"Set the brightness of the patch below this turtle to the given value, where 0 is black and 100 is full brightness."

	world setPatchBrightnessAtX: x y: y to: percent.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> random: range [
	"Answer a random integer between 0 and range."

	^ world random: range

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> setColor: aColor [

	self color: (aColor pixelValueForDepth: 32).

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> setHeading: newHeading [

	^ self heading: newHeading.

]

{ #category : #patches }
KedamaTurtlePlayer >> setPatchValueIn: aPatch to: value [

	aPatch costume renderedMorph pixelAtX: x y: y put: value.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> setTurtleCount: aNumber [

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> setX: val [

	| leftEdgeMode rightEdgeMode |
	x := val.
	x < 0.0 ifTrue: [
		leftEdgeMode := world leftEdgeMode.
		leftEdgeMode == #wrap ifTrue: [
			x := x + world wrapX.
		].
		leftEdgeMode == #stick ifTrue: [
			x := 0.0.
		].
		leftEdgeMode == #bounce ifTrue: [
			x := val negated.
			headingRadians < Float pi
				ifTrue: [headingRadians := Float pi - headingRadians]
				ifFalse: [headingRadians := Float threePi - headingRadians]
		].
	].

	x >= world wrapX ifTrue: [
		rightEdgeMode := world rightEdgeMode.
		rightEdgeMode == #wrap ifTrue: [
			x := x - world wrapX.
		].
		rightEdgeMode == #stick ifTrue: [
			x := world wrapX - 0.0000001.
		].
		rightEdgeMode == #bounce ifTrue: [
			x := world wrapX - 0.0000001 - (x - world wrapX).
			headingRadians < Float pi
				ifTrue: [headingRadians := Float pi - headingRadians]
				ifFalse: [headingRadians := Float threePi - headingRadians]
		].
	].

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> setY: val [

	| topEdgeMode bottomEdgeMode |
	y := val.
	y < 0.0 ifTrue: [
		topEdgeMode := world topEdgeMode.
		topEdgeMode == #wrap ifTrue: [
			y := y + world wrapY.
		].
		topEdgeMode == #stick ifTrue: [
			y := 0.0.
		].
		topEdgeMode == #bounce ifTrue: [
			y := val negated.
			headingRadians := Float twoPi - headingRadians.
		].
	].

	y >= world wrapY ifTrue: [
		bottomEdgeMode := world bottomEdgeMode.
		bottomEdgeMode == #wrap ifTrue: [
			y := y - world wrapY.
		].
		bottomEdgeMode == #stick ifTrue: [
			y := world wrapY - 0.0000001.
		].
		bottomEdgeMode == #bounce ifTrue: [
			y := world wrapY - 0.0000001 - (y - world wrapY).
			headingRadians := Float twoPi - headingRadians.
		].
	].

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> show [

	visible := true.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> triggerScript: aSymbol [

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> turn: degrees [

	self turnRight: degrees.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> turnLeft: degrees [
	"Turn left by the given number of degrees."

	self heading: (self heading - degrees).

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> turnRight: degrees [
	"Turn right by the given number of degrees."

	self heading: (self heading + degrees).

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> visible [

	^ visible.

]

{ #category : #'commands and slots' }
KedamaTurtlePlayer >> visible: aBoolean [

	visible := aBoolean.

]

{ #category : #accessing }
KedamaTurtlePlayer >> who [

	^ who

]

{ #category : #accessing }
KedamaTurtlePlayer >> who: anInteger [

	who := anInteger.

]

{ #category : #accessing }
KedamaTurtlePlayer >> x [

	^ x

]

{ #category : #accessing }
KedamaTurtlePlayer >> x: aNumber [

	x := aNumber.

]

{ #category : #accessing }
KedamaTurtlePlayer >> y [

	^ y

]

{ #category : #accessing }
KedamaTurtlePlayer >> y: aNumber [

	y := aNumber.

]
