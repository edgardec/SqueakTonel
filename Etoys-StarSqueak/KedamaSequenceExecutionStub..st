Class {
	#name : #KedamaSequenceExecutionStub,
	#superclass : #KedamaExamplerPlayer,
	#instVars : [
		'who',
		'index',
		'arrays',
		'exampler'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #'as yet unclassified' }
KedamaSequenceExecutionStub class >> isSystemDefined [
	^ name endsWithDigit not
]

{ #category : #'as yet unclassified' }
KedamaSequenceExecutionStub class >> isUniClass [

	^ self ~~ self officialClass
]

{ #category : #'as yet unclassified' }
KedamaSequenceExecutionStub class >> officialClass [

	^ KedamaSequenceExecutionStub

]

{ #category : #'as yet unclassified' }
KedamaSequenceExecutionStub class >> wantsChangeSetLogging [
	"Log changes for Player itself, but not for automatically-created subclasses like Player1, Player2, but *do* log it for uniclasses that have been manually renamed."

	^ (self == KedamaSequenceExecutionStub or:
		[(self name beginsWith: 'KedamaSequenceExecutionStub') not]) or:
			[Preferences universalTiles]
]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> basicGetAngleTo: player [

	| ret i |
	i := self index.
	ret := ((player getX - ((turtles arrays at: 2) at: i))@(player getY - ((turtles arrays at: 3) at: i))) theta radiansToDegrees + 90.0.
	ret > 360.0 ifTrue: [^ ret - 360.0].
	^ ret.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> basicGetDistanceTo: aPlayer [

	| i |
	i := self index.
	^ ((aPlayer getX - ((turtles arrays at: 2) at: i)) squared + (aPlayer getY - ((turtles arrays at: 3) at: i)) squared) sqrt.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> bounceOn: aPlayer [

	| aTurtle xy |
	aPlayer = exampler ifTrue: [^ false].
	xy := self getXAndY.
	aTurtle := aPlayer turtles aTurtleAtX: xy x y: xy y.
	aTurtle ifNil: [^ false].
	self doBounceOn: aTurtle of: aPlayer.
	^ true.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> bounceOn: aPlayer color: c [

	| aTurtle xy |
	aPlayer = exampler ifTrue: [^ false].
	xy := self getXAndY.
	aTurtle := aPlayer turtles aTurtleAtX: xy x y: xy y.
	aTurtle ifNil: [^ false].
	((aPlayer turtles arrays at: 5) at: aTurtle index) = c ifFalse: [^ false].
	self doBounceOn: aTurtle of: aPlayer.
	^ true.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> bounceOnColor: aPlayer [

	^ false.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> color: cPixel [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	(turtles arrays at: 5) at: i put: cPixel.
	kedamaWorld drawRequest.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> colorFromPatch: aPatch [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	(turtles arrays at: 5) at: i put: ((aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i)) bitAnd: 16rFFFFFF).
	kedamaWorld drawRequest.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> colorToPatch: aPatch [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i) put: ((turtles arrays at: 5) at: i).

]

{ #category : #'method management' }
KedamaSequenceExecutionStub >> compileAllAccessors [

	turtles info keys asArray do: [:k |
		(#(who x y heading color visible normal predicate) includes: k) ifFalse: [
			self compileScalarInstVarAccessorsFor: k.
		].
	].

]

{ #category : #'method management' }
KedamaSequenceExecutionStub >> compileScalarInstVarAccessorsFor: varName [

	| nameString type setPhrase arrayIndex getPhrase |
	nameString := varName asString capitalized.
	arrayIndex := turtles info at: varName asSymbol.

	type := turtles types at: arrayIndex.
	type = #Number ifTrue: [
		setPhrase := 'setNumberVarAt:'.
		getPhrase := 'getNumberVarOf:'.
	].
	type = #Boolean ifTrue: [
		setPhrase := 'setBooleanVarAt:'.
		getPhrase := 'getBooleanVarOf:'
	].
	type = #Color ifTrue: [
		setPhrase := 'setColorVarAt:'.
		getPhrase := 'getColorVarOf:'
	].
	setPhrase ifNil: [setPhrase := 'setObjectVarAt:'].
	getPhrase ifNil: [getPhrase := 'getObjectVarOf:'].

	self class compileSilently: ('get{1}
	^ self {2} ((turtles arrays at: {3}) at: self index)' format: {nameString. getPhrase. arrayIndex printString})
"'get', nameString, '
	^ self ', getPhrase, '((turtles arrays at: ', arrayIndex printString, ') at: self index)')"
		classified: 'access'.


	self class compileSilently: ('set{1}: xxxArg
	self {2} {3} at: self index put: xxxArg' format: {nameString. setPhrase. arrayIndex printString}
"'set', nameString, ': xxxArg
		self ', setPhrase, arrayIndex printString, ' at: self index put: xxxArg'" )
		classified: 'access'
]

{ #category : #deleting }
KedamaSequenceExecutionStub >> delete [

	| anInstance |
	turtles := nil.
	exampler := nil.
	self class removeFromSystem: false.
	anInstance := UnscriptedPlayer new.
	self become: anInstance.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> die [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	kedamaWorld deleteTurtleID: self getWho of: exampler.
	kedamaWorld drawRequest.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> doBounceOn: aTurtle of: aPlayer [

	| bounceDir myHeading neg newHeading xy |
	aPlayer = exampler ifTrue: [^ false].
	bounceDir := aTurtle getHeading.
	myHeading := self getHeading.
	neg := (myHeading + 180.0) \\ 360.0.

	newHeading := (bounceDir - neg + bounceDir).
	self setHeading: newHeading.
	[xy := self getXAndY. (aPlayer turtles aTurtleAtX: xy x y: xy y) ~= nil] whileTrue: [
		self forward: 0.5.
	].

]

{ #category : #'command execution' }
KedamaSequenceExecutionStub >> doCommand: aBlock [

	^ aBlock value: self.

]

{ #category : #'command execution' }
KedamaSequenceExecutionStub >> doDieCommand: aBlock [

	| ret |
	ret := self doExamplerCommand: aBlock.
	"sequentialStub index: self index."
	aBlock value: self.

	^ ret.


]

{ #category : #'command execution' }
KedamaSequenceExecutionStub >> doExamplerCommand: aBlock [

]

{ #category : #'command execution' }
KedamaSequenceExecutionStub >> doSequentialCommand: aBlock [

	^ aBlock value: self.

]

{ #category : #'player protocol' }
KedamaSequenceExecutionStub >> examplerPlayer: e [

	exampler := e.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> forward: v [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	KedamaSequenceExecutionStub primForwardAt: i xArray: (turtles arrays at: 2) yArray: (turtles arrays at: 3) headingArray: (turtles arrays at: 4) value: v asFloat destWidth: kedamaWorld wrapX destHeight: kedamaWorld wrapY leftEdgeMode: kedamaWorld leftEdgeModeMnemonic rightEdgeMode: kedamaWorld rightEdgeModeMnemonic topEdgeMode: kedamaWorld topEdgeModeMnemonic bottomEdgeMode: kedamaWorld bottomEdgeModeMnemonic.
	kedamaWorld drawRequest.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getAngleTo: aPlayer [

	| i xy |
	i := self index.
	xy := aPlayer getXAndY.
	^ KedamaSequenceExecutionStub primGetAngleToX: xy x toY: xy y fromX: ((turtles arrays at: 2) at: i) fromY: ((turtles arrays at: 3) at: i).

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getBlueComponentIn: aPatch [

	| i pix |
	i := self index.
	pix := aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i).
	^ pix bitAnd: 16rFF.

]

{ #category : #'accessing - private' }
KedamaSequenceExecutionStub >> getBooleanVarOf: val [

	^ val ~= 0.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getColor [

	^ Color colorFromPixelValue: ((turtles arrays at: 5) at: self index) depth: 32.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getColorOpaque [

	^ Color colorFromPixelValue: (((turtles arrays at: 5) at: self index) bitOr: 16rFF000000) depth: 32.

]

{ #category : #'accessing - private' }
KedamaSequenceExecutionStub >> getColorVarOf: val [

	^ Color colorFromPixelValue: val depth: 32.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getDistanceTo: aPlayer [

	| i xy |
	i := self index.
	xy := aPlayer getXAndY.
	^ KedamaSequenceExecutionStub primGetDistanceToX: xy x toY: xy y fromX: ((turtles arrays at: 2) at: i) fromY: ((turtles arrays at: 3) at: i).

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getGreenComponentIn: aPatch [

	| i pix |
	i := self index.
	pix := aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i).
	^ (pix bitShift: -8) bitAnd: 16rFF.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getGrouped [

	^ exampler getGrouped.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getHeading [

	^ KedamaSequenceExecutionStub primGetHeadingAt: self index headingArray: (turtles arrays at: 4).

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getNormal [

	| headingRadians degrees |
	headingRadians := (turtles arrays at: 7) at: self index.
	degrees := 90.0 - headingRadians radiansToDegrees.
	^ degrees >= 0.0 ifTrue: [degrees] ifFalse: [degrees + 360.0].

]

{ #category : #'accessing - private' }
KedamaSequenceExecutionStub >> getNumberVarOf: val [

	^ val.

]

{ #category : #'accessing - private' }
KedamaSequenceExecutionStub >> getObjectVarOf: var [

	^ var.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getPatchValueIn: aPatch [

	| i |
	i := self index.
	^ aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i).

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getRedComponentIn: aPatch [

	| i pix |
	i := self index.
	pix := aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i).
	^ (pix bitShift: -16) bitAnd: 16rFF.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getReplicated [

	| proto newWho n |
	proto := (1 to: turtles arrays size) collect: [:i | (turtles arrays at: i) at: self index].
	kedamaWorld makeReplicatedTurtles: 1 examplerPlayer: exampler color: nil ofPrototype: proto randomize: false.
	exampler costume renderedMorph privateTurtleCount: (kedamaWorld turtlesCountOf: exampler).
	newWho := (kedamaWorld lastWhoOf: exampler).
	n := self shallowCopy.
	n who: newWho.
	^ n.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getTurtleAt: aPlayer [

	| ret xy |
	xy := aPlayer getXAndY.
	ret := exampler turtles aTurtleAtX: xy x y: xy y.
	^ ret ifNil: [self].

]

{ #category : #'player protocol' }
KedamaSequenceExecutionStub >> getTurtleCount [

	^ exampler getTurtleCount.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getTurtleOf: aBreedPlayer [

	| ret xy |
	xy := self getXAndY.
	ret := aBreedPlayer turtles aTurtleAtX: xy x y: xy y.
	^ ret ifNil: [self].

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getTurtleVisible [

	^ ((turtles arrays at: 6) at: self index) = 1.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getUphillIn: aPatch [

	| i p |
	i := self index.
	p := aPatch costume renderedMorph.
	^ p
			uphillForTurtleX: ((turtles arrays at: 2) at: i)
			turtleY: ((turtles arrays at: 3) at: i)
			turtleHeading: ((turtles arrays at: 4) at: i).

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getWho [

	^ (turtles arrays at: 1) at: self index.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getX [

	^ (turtles arrays at: 2) at: self index.

]

{ #category : #'accessing - private' }
KedamaSequenceExecutionStub >> getXAndY [

	| i |
	i := self index.
	^ ((turtles arrays at: 2) at: i)@((turtles arrays at: 3) at: i).

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> getY [

	^ (turtles arrays at: 3) at: self index.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> hide [

	(turtles arrays at: 6) at: self index put: 0.
	kedamaWorld drawRequest.

]

{ #category : #accessing }
KedamaSequenceExecutionStub >> index [

	who ifNil: [^ index].
	^ turtles indexOf: who.

]

{ #category : #accessing }
KedamaSequenceExecutionStub >> index: i [

	index := i.

]

{ #category : #testing }
KedamaSequenceExecutionStub >> isSequentialStub [

	^ true.

]

{ #category : #accessing }
KedamaSequenceExecutionStub >> kedamaWorld: k [

	kedamaWorld := k.

]

{ #category : #'accessing - private' }
KedamaSequenceExecutionStub >> noteDecimalPlaces: aNumber forGetter: aGetter [

]

{ #category : #'player protocol' }
KedamaSequenceExecutionStub >> noteRenameOf: oldSlotName to: newSlotName inPlayer: aPlayer [

	self compileAllAccessors

]

{ #category : #primitives }
KedamaSequenceExecutionStub >> primForwardAt: i xArray: xArray yArray: yArray headingArray: headingArray value: value destWidth: destWidth destHeight: destHeight leftEdgeMode: leftEdgeMode rightEdgeMode: rightEdgeMode topEdgeMode: topEdgeMode bottomEdgeMode: bottomEdgeMode [

	| dist newX newY |
	<primitive: 'primScalarForward' module:'KedamaPlugin'>
	"^ KedamaPlugin doPrimitive: #primScalarForward."

	dist := value.
	newX := (xArray at: i) + (dist asFloat * (headingArray at: i) cos).
	newY := (yArray at: i) - (dist asFloat * (headingArray at: i) sin).
	KedamaMorph scalarXAt: i xArray: xArray headingArray: headingArray value: newX destWidth: destWidth leftEdgeMode: leftEdgeMode rightEdgeMode: rightEdgeMode.
	KedamaMorph scalarYAt: i yArray: yArray headingArray: headingArray value: newY destHeight: destHeight topEdgeMode: topEdgeMode bottomEdgeMode: bottomEdgeMode.

]

{ #category : #primitives }
KedamaSequenceExecutionStub >> primGetAngleToX: toX toY: toY fromX: fromX fromY: fromY [

	| ret |
	<primitive: 'scalarGetAngleTo' module:'KedamaPlugin'>
	ret := ((toX - fromX)@(toY - fromY)) theta radiansToDegrees + 90.0.
	ret > 360.0 ifTrue: [^ ret - 360.0].
	^ ret.

]

{ #category : #primitives }
KedamaSequenceExecutionStub >> primGetDistanceToX: toX toY: toY fromX: fromX fromY: fromY [

	<primitive: 'scalarGetDistanceTo' module:'KedamaPlugin'>
	^ ((fromX - toX) squared + (fromY - toY)) squared sqrt.

]

{ #category : #primitives }
KedamaSequenceExecutionStub >> primGetHeadingAt: i headingArray: headingArray [

	| heading |
	<primitive: 'getScalarHeading' module:'KedamaPlugin'>
	"^ KedamaPlugin doPrimitive: #getScalarHeading."

	heading := headingArray at: i.
	^KedamaMorph radiansToDegrees: heading.

]

{ #category : #primitives }
KedamaSequenceExecutionStub >> primSetHeadingAt: i headingArray: headingArray value: heading [

	| rad |
	<primitive: 'setScalarHeading' module:'KedamaPlugin'>
	"^ KedamaPlugin doPrimitive: #setScalarHeading."

	rad := KedamaMorph degreesToRadians: heading.
	headingArray at: index put: rad.

]

{ #category : #primitives }
KedamaSequenceExecutionStub >> primSetX: xArray xIndex: xIndex headingArray: headingArray value: value destWidth: destWidth leftEdgeMode: leftEdgeMode rightEdgeMode: rightEdgeMode [

	<primitive: 'turtleScalarSetX' module:'KedamaPlugin'>
	"^ KedamaPlugin doPrimitive: #turtleScalarSetX."
	KedamaMorph scalarXAt: xIndex xArray: xArray headingArray: headingArray value: value destWidth: destWidth leftEdgeMode: leftEdgeMode rightEdgeMode: rightEdgeMode.

]

{ #category : #primitives }
KedamaSequenceExecutionStub >> primSetY: yArray yIndex: yIndex headingArray: headingArray value: value destHeight: destHeight topEdgeMode: topEdgeMode bottomEdgeMode: bottomEdgeMode [

	<primitive: 'turtleScalarSetY' module:'KedamaPlugin'>
	"^ KedamaPlugin doPrimitive: #turtleScalarSetY."
	KedamaMorph scalarYAt: yIndex yArray: yArray headingArray: headingArray value: value destHeight: destHeight topEdgeMode: topEdgeMode bottomEdgeMode: bottomEdgeMode.

]

{ #category : #printing }
KedamaSequenceExecutionStub >> printOn: aStream [

	aStream nextPutAll: 'KedamaExecutionStub for ('.
	super printOn: aStream.
	aStream nextPut: $).

]

{ #category : #'method management' }
KedamaSequenceExecutionStub >> removeSlotNamed: aSlotName [

	self class removeSelectorSilently: aSlotName asGetterSelector.
	self class removeSelectorSilently: aSlotName asSetterSelector.
	self compileAllAccessors.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> setBlueComponentIn: aPatch to: value [

	| i pix |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	pix := aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i).
	pix := (pix bitAnd: 16rFFFF00) bitOr: ((value asInteger bitAnd: 16rFF) bitShift: 16).
	aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i) put: pix.

]

{ #category : #'accessing - private' }
KedamaSequenceExecutionStub >> setBooleanVarAt: arrayIndex at: i put: v [

	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	(turtles arrays at: arrayIndex) at: i put: ((v == true or: [v isNumber and: [v ~= 0]]) ifTrue: [1] ifFalse: [0]).

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> setColor: aColor [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	(turtles arrays at: 5) at: i put: ((aColor pixelValueForDepth: 32)).
	kedamaWorld drawRequest.

]

{ #category : #'accessing - private' }
KedamaSequenceExecutionStub >> setColorVarAt: arrayIndex at: i put: v [

	| val |
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	val := v isColor ifTrue: [v pixelValueForDepth: 32] ifFalse: [v].
	(turtles arrays at: arrayIndex) at: i put: val.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> setGreenComponentIn: aPatch to: value [

	| i pix |
	i := self index.
	pix := aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i).
	pix := (pix bitAnd: 16rFF00FF) bitOr: ((value asInteger bitAnd: 16rFF) bitShift: 8).
	aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i) put: pix.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> setHeading: degrees [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	^ KedamaSequenceExecutionStub primSetHeadingAt: i headingArray: (turtles arrays at: 4) value: degrees asFloat.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> setNormal: degrees [

	| headingRadians |
	headingRadians := ((90.0 - degrees) \\ 360.0) degreesToRadians.

	(turtles arrays at: 7) at: self index put: headingRadians.

]

{ #category : #'accessing - private' }
KedamaSequenceExecutionStub >> setNumberVarAt: arrayIndex at: i put: v [

	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	(turtles arrays at: arrayIndex) at: i put: v.

]

{ #category : #'accessing - private' }
KedamaSequenceExecutionStub >> setObjectVarAt: arrayIndex at: i put: v [

	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	(turtles arrays at: arrayIndex) at: i put: v.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> setPatchValueIn: aPatch to: value [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i) put: value.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> setRedComponentIn: aPatch to: value [

	| i pix |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	pix := aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i).
	pix := (pix bitAnd: 16rFFFF) bitOr: ((value asInteger bitAnd: 16rFF) bitShift: 16).
	aPatch costume renderedMorph pixelAtX: ((turtles arrays at: 2) at: i) y: ((turtles arrays at: 3) at: i) put: pix.

]

{ #category : #'player protocol' }
KedamaSequenceExecutionStub >> setScalarSlotTypeFor: slotName typeChosen: typeChosen [

	self compileScalarInstVarAccessorsFor: slotName.

]

{ #category : #'player protocol' }
KedamaSequenceExecutionStub >> setTurtleCount: aNumber [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	^ exampler setTurtleCount: aNumber.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> setTurtleVisible: aBoolean [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	^ (turtles arrays at: 6) at: i put: (aBoolean ifTrue: [1] ifFalse: [0])

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> setX: val [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	kedamaWorld drawRequest.
	^ KedamaSequenceExecutionStub primSetX: (turtles arrays at: 2) xIndex: i headingArray: (turtles arrays at: 4) value: val asFloat destWidth: kedamaWorld wrapX leftEdgeMode: kedamaWorld leftEdgeModeMnemonic rightEdgeMode: kedamaWorld rightEdgeModeMnemonic.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> setY: val [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	kedamaWorld drawRequest.
	^ KedamaSequenceExecutionStub primSetY: (turtles arrays at: 3) yIndex: i headingArray: (turtles arrays at: 4) value: val asFloat destHeight: kedamaWorld wrapY topEdgeMode: kedamaWorld topEdgeModeMnemonic bottomEdgeMode: kedamaWorld bottomEdgeModeMnemonic.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> show [

	| i |
	i := self index.
	((turtles arrays at: 7) at: i) = 0 ifTrue: [^ self].
	(turtles arrays at: 6) at: i put: 1.
	kedamaWorld drawRequest.

]

{ #category : #printing }
KedamaSequenceExecutionStub >> storeCodeOn: aStream indent: indent [

	aStream nextPutAll: '(('.
	aStream nextPutAll: exampler uniqueNameForReference.
	aStream nextPutAll: ') clonedSequentialStub who: '.
	aStream nextPutAll: who printString.
	aStream nextPutAll: ')'.

]

{ #category : #'player commands' }
KedamaSequenceExecutionStub >> turn: degrees [
	"Turn by the given number of degrees."

	self setHeading: (self getHeading + degrees).

]

{ #category : #accessing }
KedamaSequenceExecutionStub >> turtles: t [

	turtles := t.

]

{ #category : #accessing }
KedamaSequenceExecutionStub >> who: w [

	who := w.
	index := nil.

]
