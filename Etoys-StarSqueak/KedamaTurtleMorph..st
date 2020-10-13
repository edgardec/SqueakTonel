"
The exampler of turtles.

"
Class {
	#name : #KedamaTurtleMorph,
	#superclass : #Morph,
	#instVars : [
		'kedamaWorld',
		'turtleCount',
		'isGroup'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #scripting }
KedamaTurtleMorph class >> additionsToViewerCategories [
	"Answer a list of (<categoryName> <list of category specs>) pairs that characterize the phrases this kind of morph wishes to add to various Viewer categories."
	"self halt."
	^ #(

	('kedama turtle' (
		(command die 'delete this turtle')

		(slot upHill 'uphill of the implicit at my location' Number readOnly Player getUphillIn: unspecified unspecified)
		(slot bounceOn 'detect collision and bounce back' Boolean readOnly Player bounceOn: unspecified unspecified)
		"(slot bounceOnColor 'detect collision and bounce back on a color' Boolean readOnly Player bounceOnColor: unspecified unspecified)"
		(slot patchValueIn 'get the value at this position' Number readWrite Number getPatchValueIn: Number setPatchValueIn:to:)
		(slot distanceTo 'The distance to another turtle' Number readOnly Player getDistanceTo: unused unused)
		(slot angleTo 'The angle to another turtle' Number readOnly Player getAngleTo: unused unused)

		(slot getReplicated 'returns a copy of this turtle' Player readOnly Player getReplicated unused unused)
		(slot x 'The x coordinate' Number readWrite Player getX Player setX:)
		(slot y  	'The y coordinate' Number readWrite Player 	getY Player setY:)
		(slot heading 'Which direction the object is facing.  0 is straight up' Number readWrite Player getHeading Player setHeading:)
		(command forward: 'Moves the object forward in the direction it is heading' Number)
		(command turn: 'Change the heading of the object by the specified amount' Number)
			(slot color 'The color of the object' Color readWrite Player getColor  Player  setColor:)
	"		(slot headingTheta 'The angle, in degrees, that my heading vector makes with the positive x-axis' Number readWrite Player getHeadingTheta Player setHeadingTheta:)

			(slot theta 'The angle between the positive x-axis and the vector connecting the origin to the object''s position' Number readWrite Player getTheta Player setTheta: )
"
		(slot turtleVisible 'The flag that governs the visibility of turtle' Boolean readWrite Player getTurtleVisible Player setTurtleVisible:)
			"(command turtleShow 'make the object visible')
			(command turtleHide 'make the object invisible')"

		(slot turtleOf 'returns a turtle of specified breed at my position.' Player readOnly Player getTurtleOf: unused unused)
		"(slot normal 'The normal for bouncing' Number readWrite Player getNormal Player  setNormal:)"

		(slot turtleCount 'set the number of turtles' Number readWrite Number getTurtleCount Number setTurtleCount:)

	))
	"('kedama turtle breed' (
		(slot grouped 'turtles bahaves as one connected objects' Boolean readWrite Boolean getGrouped Boolean setGrouped:)
	))"

	('kedama turtle color' (
		(slot redComponentIn 'The red component in specified patch.' Number readWrite Player getRedComponentIn: Player setRedComponentIn:to:)
		(slot greenComponentIn 'The green component in specified patch.' Number readWrite Player getGreenComponentIn: Player setGreenComponentIn:to:)
		(slot blueComponentIn 'The blue component in specified patch.' Number readWrite Player getBlueComponentIn: Player setBlueComponentIn:to:)
		(command colorFromPatch: 'make my color specified in the patch' Patch)
		(command colorToPatch: 'store my color into the patch' Patch)
	))

)


]

{ #category : #'class initialization' }
KedamaTurtleMorph class >> cleanUp [
"
	self cleanUp
"
	self allInstancesDo: [:e | e cleanUp].

]

{ #category : #scripting }
KedamaTurtleMorph class >> defaultNameStemForInstances [

	^ 'turtle' translatedNoop

]

{ #category : #'class initialization' }
KedamaTurtleMorph class >> useKedamaFloatArray [
"
	KedamaTurtleMorph useKedamaFloatArray.
"
	KedamaTurtleMorph allInstancesDo: [:e | e player ifNotNil: [e player turtles useKedamaFloatArray]].

]

{ #category : #'viewer access' }
KedamaTurtleMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Include our modest command set in the ctrl-menu"

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	self player ifNotNil: [
		aCustomMenu addLine.
		aCustomMenu add: 'copy methods' target: self player action: #copyAllMethodsAgain2.
	].

]

{ #category : #'viewer access' }
KedamaTurtleMorph >> categoriesForViewer [
	"Answer a list of symbols representing the categories to offer in the viewer, in order"
	"^ super categoriesForViewer."

	| aList |
	aList := OrderedCollection new.
	aList addAllFirstUnlessAlreadyPresent: (self class additionsToViewerCategories collect:
				[:categorySpec | categorySpec first]).
	^ aList

]

{ #category : #initialization }
KedamaTurtleMorph >> cleanUp [

	self player: nil.
	self actorState: nil.

]

{ #category : #initialization }
KedamaTurtleMorph >> convertToCurrentVersion: varDict refStream: smartRefStrm [ 
	self player copyAllMethodsAgain2.
	^ super convertToCurrentVersion: varDict refStream: smartRefStrm

]

{ #category : #'group turtle creation' }
KedamaTurtleMorph >> createTurtlesAsIn: aForm originAt: origin [

	| c xArray yArray colorArray newX newY |
	xArray := OrderedCollection new: aForm width * aForm height.
	yArray := OrderedCollection new: aForm width * aForm height.
	colorArray := OrderedCollection new: aForm width * aForm height.
	0 to: aForm height do: [:y |
		0 to: aForm width do: [:x |
			c := aForm colorAt: (x@y).
			c isTransparent ifFalse: [
				newX := x + origin x.
				newY := y + origin y.
				((newX >= 0 and: [newX < kedamaWorld dimensions x]) and: [newY >= 0 and: [newY < kedamaWorld dimensions y]]) ifTrue: [
					xArray add: newX.
					yArray add: newY.
					colorArray add: (c pixelValueForDepth: 32).
				].
			].
		].
	].
	kedamaWorld makeTurtlesAtPositionsIn: {xArray asArray. yArray asArray. colorArray asArray} examplerPlayer: self player ofPrototype: nil.
	self privateTurtleCount: (kedamaWorld turtlesCountOf: self player).

]

{ #category : #initialization }
KedamaTurtleMorph >> delete [

	super delete.
	kedamaWorld deleteAllTurtlesOfExampler: self player.
	self player delete.

]

{ #category : #initialization }
KedamaTurtleMorph >> initialize [

	super initialize.
	turtleCount := 1.
	self assuredPlayer assureUniClass.
	self extent: 40@40.

	isGroup := false.
	self color: self saturatedRandomColor.


]

{ #category : #initialization }
KedamaTurtleMorph >> install [

	| t |
	self player kedamaWorld: kedamaWorld.
	t := self player createTurtles2.
	kedamaWorld makeTurtles: turtleCount examplerPlayer: self player color: ((self color pixelValueForDepth: 32) bitAnd: 16rFFFFFF) ofPrototype: nil turtles: t randomize: true.
	self player createSequenceStub.

]

{ #category : #accessing }
KedamaTurtleMorph >> isGroup [

	^ isGroup.

]

{ #category : #accessing }
KedamaTurtleMorph >> isGroup: aBoolean [

	isGroup := aBoolean.

]

{ #category : #accessing }
KedamaTurtleMorph >> kedamaWorld [

	^ kedamaWorld.

]

{ #category : #accessing }
KedamaTurtleMorph >> kedamaWorld: k [

	kedamaWorld := k.

]

{ #category : #initialization }
KedamaTurtleMorph >> newPlayerInstance [

	^ (KedamaExamplerPlayer newUserInstance).
]

{ #category : #accessing }
KedamaTurtleMorph >> privateTurtleCount: c [

	turtleCount := c.

]

{ #category : #initialization }
KedamaTurtleMorph >> saturatedRandomColor [
	"Return a random color that isn't too dark or under-saturated."

	^ Color basicNew
		setHue: (360 atRandom)
		saturation: 1.0
		brightness: 1.0.

]

{ #category : #accessing }
KedamaTurtleMorph >> turtleCount [

	^ turtleCount.

]

{ #category : #accessing }
KedamaTurtleMorph >> turtleCount: count [

	| c |
	c := count asInteger max: 0.
	kedamaWorld setTurtlesCount: c examplerPlayer: self player color: ((self color pixelValueForDepth: 32) bitAnd: 16rFFFFFF).
	turtleCount := c.
	"turtleCount <= 0 ifTrue: [self player allOpenViewers do: [:v | v providePossibleRestrictedView: 0]]."
]

{ #category : #menus }
KedamaTurtleMorph >> wantsHaloHandleWithSelector: aSelector inHalo: aHaloMorph [
	"Answer whether the receiver would like to offer the halo handle with the given selector (e.g. #addCollapseHandle:)"

	(#(addDupHandle: addMakeSiblingHandle:) includes: aSelector) ifTrue:
		[^ false].

	^ super wantsHaloHandleWithSelector: aSelector inHalo: aHaloMorph
]
