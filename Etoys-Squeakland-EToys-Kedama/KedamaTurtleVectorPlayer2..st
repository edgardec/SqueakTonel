Class {
	#name : #KedamaTurtleVectorPlayer2,
	#superclass : #Player,
	#instVars : [
		'kedamaWorld',
		'exampler',
		'predicate',
		'info',
		'types',
		'arrays',
		'deletingIndex',
		'whoTable',
		'whoTableBase',
		'whoTableValid',
		'turtlesMap',
		'turtleMapValid',
		'lastWho',
		'lastWhoStub'
	],
	#category : #'Etoys-Squeakland-EToys-Kedama'
}

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> isSystemDefined [
	^ (name endsWith: 'Player2')

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> isUniClass [

	^ self ~~ self officialClass
]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> officialClass [

	^ KedamaTurtleVectorPlayer2.

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primDrawOn: bits destWidth: dimX destHeight: dimY xArray: xArray yArray: yArray colorArray: colorArray visibleArray: visibleArray [

	| x y visible bitsIndex |
	<primitive: 'drawTurtlesInArray' module: 'KedamaPlugin2'>
	"^ KedamaPlugin doPrimitive: #drawTurtlesInArray."

	1 to: xArray size do: [:i |
		x := (xArray at: i) asInteger.
		y := (yArray at: i) asInteger.
		visible := (visibleArray at: i).
		(visible ~= 0 and: [((x >= 0) and: [y >= 0]) and: [(x < dimX) and: [y < dimY]]]) ifTrue: [
			bitsIndex := ((y * dimX) + x) + 1.
			bits at: bitsIndex put: (colorArray at: i).
		]
	].

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primDrawPredicate: predicate on: bits destWidth: dimX destHeight: dimY xArray: xArray yArray: yArray colorArray: colorArray visibleArray: visibleArray [

	| x y visible bitsIndex |
	<primitive: 'drawTurtlesInArray' module: 'KedamaPlugin2'>
	"^ KedamaPlugin doPrimitive: #drawTurtlesInArray."

	1 to: xArray size do: [:i |
		(predicate at: i) = 1 ifTrue: [
			x := (xArray at: i) asInteger.
			y := (yArray at: i) asInteger.
			visible := (visibleArray at: i).
			(visible ~= 0 and: [((x >= 0) and: [y >= 0]) and: [(x < dimX) and: [y < dimY]]]) ifTrue: [
				bitsIndex := ((y * dimX) + x) + 1.
				bits at: bitsIndex put: (colorArray at: i).
			]
		].
	].

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primForwardPredicate: predicate xArray: xArray yArray: yArray headingArray: headingArray value: v destWidth: destWidth destHeight: destHeight leftEdgeMode: leftEdgeMode rightEdgeMode: rightEdgeMode topEdgeMode: topEdgeMode bottomEdgeMode: bottomEdgeMode [

	| dist newX newY |
	<primitive: 'primTurtlesForward' module: 'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primTurtlesForward."

	1 to: xArray size do: [:i |
		(predicate at: i) = 1 ifTrue: [
			v isCollection ifTrue: [
				dist := (v at: i) asFloat.
			] ifFalse: [
				dist := v asFloat.
			].
			newX := (xArray at: i) + (dist * (headingArray at: i) cos).
			newY := (yArray at: i) - (dist * (headingArray at: i) sin).
			KedamaMorph scalarXAt: i xArray: xArray headingArray: headingArray value: newX destWidth: destWidth leftEdgeMode: leftEdgeMode rightEdgeMode: rightEdgeMode.
			KedamaMorph scalarYAt: i yArray: yArray headingArray: headingArray value: newY destHeight: destHeight topEdgeMode: topEdgeMode bottomEdgeMode: bottomEdgeMode.
		].
	].

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primGetAngleToX: pX toY: pY xArray: xArray yArray: yArray resultInto: result [

	| ppx ppy x y ret currentDist minDist nearestNeighbour skipSelf |
	<primitive: 'vectorGetAngleTo' module:'KedamaPlugin2'>
	"^ KedamaPlugin doPrimitive: #vectorGetAngleTo."

	ppx := pX.
	ppy := pY.
	skipSelf := pX == xArray.
	1 to: result size do: [:index |
		pX isCollection ifTrue: [
			nearestNeighbour := index.
			minDist := SmallInteger maxVal.
			1 to: pX size do: [:index2 |
				((index2 == index) & skipSelf) ifFalse: [
					ppx := pX at: index2.
					ppy := pY at: index2.
					currentDist := ((ppx - (xArray at: index)) squared + (ppy - (yArray at: index)) squared) sqrt.
					currentDist < minDist ifTrue: [
						minDist := currentDist.
						nearestNeighbour := index2]]].
			ppx := pX at: nearestNeighbour.
			ppy := pY at: nearestNeighbour.
		].
		x := ppx - (xArray at: index).
		y := ppy - (yArray at: index).
		ret := (x@y) theta radiansToDegrees + 90.0.
		ret > 360.0 ifTrue: [ret := ret - 360.0].
		result at: index put: ret.
	].
	^ result.

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primGetDistanceToX: pX toY: pY xArray: xArray yArray: yArray resultInto: result [

	| ppx ppy tempMin skipSelf |
	<primitive: 'vectorGetDistanceTo' module:'KedamaPlugin2'>
	"^ KedamaPlugin doPrimitive: #vectorGetDistanceTo."

	ppx := pX.
	ppy := pY.
	skipSelf := pX == xArray.
	1 to: result size do: [:index |
		pX isCollection ifTrue: [
			tempMin := SmallInteger maxVal.
			1 to: pX size do: [:index2 |
				((index2 == index) & skipSelf) ifFalse: [
					ppx := pX at: index2.
					ppy := pY at: index2.
					tempMin := tempMin min: ((ppx - (xArray at: index)) squared + (ppy - (yArray at: index)) squared) sqrt]
			].
			self flag: #todo. "should really also remember the other side index to re-use inside the script"
			result at: index put: tempMin.
		] ifFalse: [
			result at: index put: ((ppx - (xArray at: index)) squared + (ppy - (yArray at: index)) squared) sqrt.
		]
	].
	^ result.

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primGetHeading: headingArray into: resultArray [

	| heading |
	<primitive: 'getHeadingArrayInto' module:'KedamaPlugin2'>
	"^ KedamaPlugin doPrimitive: #getHeadingArrayInto."

	1 to: headingArray size do: [:i |
		heading := headingArray at: i.
		heading := heading / 0.0174532925199433.
		heading := 90.0 - heading.
		heading > 0.0 ifFalse: [heading := heading + 360.0].
		resultArray at: i put: heading.
	].

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primMakeTurtlesMap: map whoArray: whoArray xArray: xArray yArray: yArray width: w height: h [

	<primitive: 'makeTurtlesMap' module: 'KedamaPlugin2'>
	^ nil.

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primRandomRange: range from: from to: to intoFloatArray: aFloatArray factor: factor [

	<primitive: 'randomIntoFloatArray' module: 'KedamaPlugin2'>
	^ nil.

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primRandomRange: range from: from to: to intoIntegerArray: anIntegerArray factor: factor [

	<primitive: 'randomIntoIntegerArray' module: 'KedamaPlugin2'>
	^ nil.

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primSetPredicate: predicates heading: headingArray from: val [

	| heading |
	<primitive: 'setHeadingArrayFrom' module:'KedamaPlugin2'>
	"^ KedamaPlugin doPrimitive: #setHeadingArrayFrom."

	val isCollection ifFalse: [
		heading := val asFloat.
		heading := KedamaMorph degreesToRadians: heading.
	].

	1 to: headingArray size do: [:i |
		(predicates at: i) = 1 ifTrue: [
			val isCollection ifTrue: [
				heading := val at: i.
				heading := KedamaMorph degreesToRadians: heading.
			].
			headingArray at: i put: heading.
		].
	].

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primSetXPredicates: predicates xArray: xArray headingArray: headingArray value: v destWidth: destWidth leftEdgeMode: leftEdgeMode rightEdgeMode: rightEdgeMode [

	| val newX |
	<primitive: 'turtlesSetX' module: 'KedamaPlugin2'>
	"^ KedamaPlugin doPrimitive: #turtlesSetX."

	v isCollection ifFalse: [
		val := v asFloat.
	].

	1 to: xArray size do: [:i |
		(predicates at: i) = 1 ifTrue: [
			v isCollection ifTrue: [
				newX := v at: i.
			] ifFalse: [
				newX := val.
			].
			KedamaMorph scalarXAt: i xArray: xArray headingArray: headingArray value: newX destWidth: destWidth leftEdgeMode: leftEdgeMode rightEdgeMode: rightEdgeMode.
		].
	].


]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> primSetYPredicates: predicates yArray: yArray headingArray: headingArray value: v destHeight: destHeight topEdgeMode: topEdgeMode bottomEdgeMode: bottomEdgeMode [

	| val newY |
	<primitive: 'turtlesSetY' module: 'KedamaPlugin2'>
	"^ KedamaPlugin doPrimitive: #turtlesSetY."

	v isCollection ifFalse: [
		val := v asFloat.
	].

	1 to: yArray size do: [:i |
		(predicates at: i) = 1 ifTrue: [
			v isCollection ifTrue: [
				newY := v at: i.
			] ifFalse: [
				newY := val.
			].
			KedamaMorph scalarYAt: i yArray: yArray headingArray: headingArray value: newY destHeight: destHeight topEdgeMode: topEdgeMode bottomEdgeMode: bottomEdgeMode.
		].
	].

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> randomRange: range from: from to: to intoFloatArray: aFloatArray factor: factor kedamaWorld: kedamaWorld [

	| ret |
	ret := self primRandomRange: range from: from to: to intoFloatArray: aFloatArray factor: factor.
	ret ifNil: [
		from to: to do: [:index |
			aFloatArray at: index put: (kedamaWorld random: range) asFloat * factor.
		].
	].

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> randomRange: range from: from to: to intoIntegerArray: anIntegerArray factor: factor kedamaWorld: kedamaWorld [

	| ret |
	ret := self primRandomRange: range from: from to: to intoIntegerArray: anIntegerArray factor: factor.
	ret ifNil: [
		from to: to do: [:index |
			anIntegerArray at: index put: ((kedamaWorld random: range) asFloat * factor) asInteger.
		].
	].

]

{ #category : #'as yet unclassified' }
KedamaTurtleVectorPlayer2 class >> wantsChangeSetLogging [
	"Log changes for Player itself, but not for automatically-created subclasses like Player1, Player2, but *do* log it for uniclasses that have been manually renamed."

	^ (self == KedamaTurtleVectorPlayer2 or:
		[(self name beginsWith: 'KedamaTurtleVectorPlayer2') not]) or:
			[Preferences universalTiles]
]

{ #category : #'turtle map' }
KedamaTurtleVectorPlayer2 >> aTurtleAtX: xPos y: yPos [

	| w x y index who stub |
	turtleMapValid ifFalse: [
		self makeTurtlesMap.
	].

	w := kedamaWorld dimensions x.
	x := xPos truncated.
	y := yPos truncated.
	x < 0 ifTrue: [^ nil].
	x >= w ifTrue: [^ nil].
	y < 0 ifTrue: [^ nil].
	y >= kedamaWorld dimensions y ifTrue: [^ nil].
	index := (w * y) + x + 1.
	who := turtlesMap at: index.
	who = 0 ifTrue: [^ nil].
	who = lastWho ifTrue: [^ lastWhoStub].
	stub := exampler clonedSequentialStub.
	stub who: who.
	lastWho := who.
	^ lastWhoStub := stub.

]

{ #category : #'player protocol' }
KedamaTurtleVectorPlayer2 >> addInstanceVarNamed: aName withValue: aValue [

	| newArray |
	newArray := self arrayForType: aValue.
	arrays := arrays,(Array with: newArray).
	newArray atAllPut: (self valueForSetting: aValue).
	info at: aName asSymbol put: arrays size.
	types at: arrays size put: (self typeFor: aValue).


	

]

{ #category : #'player protocol' }
KedamaTurtleVectorPlayer2 >> addInstanceVarVectorNamed: aName withValue: aValue [

	| newArray |
	newArray := KedamaFloatArray new: self size.
	arrays := arrays, (Array with: newArray).
	newArray atAllPut: aValue.
	info at: aName asSymbol put: arrays size.
	types at: arrays size put: #Number.

]

{ #category : #'add turtles' }
KedamaTurtleVectorPlayer2 >> addTurtlesCount: count ofPrototype: prototype for: aKedamaWorld positionAndColorArray: positionAndColorArray [

	| index array defaultValue newArray oldCount |
	oldCount := self size.
	info associationsDo: [:assoc |
		index := assoc value.
		array := arrays at: index.
		defaultValue := prototype at: index.
		newArray := array class new: count.
		(#(who x y heading color predicate) includes: assoc key) ifFalse: [
			newArray atAllPut: defaultValue.
		].
		assoc key = #x ifTrue: [newArray replaceFrom: 1 to: newArray size with: positionAndColorArray first startingAt: 1].
		assoc key = #y ifTrue: [newArray replaceFrom: 1 to: newArray size with: positionAndColorArray second startingAt: 1].
		assoc key = #color ifTrue: [newArray replaceFrom: 1 to: newArray size with: positionAndColorArray third startingAt: 1].
		assoc key = #heading ifTrue: [newArray atAllPut: 1.57079631 "Float pi / 2.0"].
		assoc key = #normal ifTrue: [newArray atAllPut: 1.57079631 "Float pi / 2.0"].

		arrays at: (assoc value) put: array, newArray.
	].
	predicate := arrays at: 7.
	predicate from: oldCount+1 to: predicate size put: 1.

	#(who) do: [:name |
		self setInitialValueOf: name from: oldCount + 1 to: self size for: aKedamaWorld.
	].
	whoTableValid := false.
	turtleMapValid := false.
	kedamaWorld drawRequest.

]

{ #category : #'add turtles' }
KedamaTurtleVectorPlayer2 >> addTurtlesCount: count ofPrototype: prototype for: aKedamaWorld randomize: randomizeFlag [

	| index array defaultValue newArray oldCount |
	oldCount := self size.
	info associationsDo: [:assoc |
		index := assoc value.
		array := arrays at: index.
		defaultValue := prototype at: index.
		newArray := array class new: count.
		newArray atAllPut: defaultValue.
		arrays at: index put: (array, newArray).
	].
	predicate := arrays at: 7.
	predicate from: oldCount + 1 to: predicate size put: 1.

	self setInitialValueOf: #who from: oldCount + 1 to: self size for: aKedamaWorld.

	randomizeFlag ifTrue: [
		#(x y heading) do: [:name |
			self setInitialValueOf: name from: oldCount + 1 to: self size for: aKedamaWorld.
		].
	].
	whoTableValid := false.
	kedamaWorld drawRequest.

]

{ #category : #private }
KedamaTurtleVectorPlayer2 >> arrayForType: typeNameOrValue [
	| aType |
	aType := typeNameOrValue isSymbol ifFalse: [self typeFor: typeNameOrValue] ifTrue: [typeNameOrValue].
	aType = #Number ifTrue: [
		^ KedamaFloatArray new: self size.
	].
	aType = #Color ifTrue: [
		^ WordArray new: self size.
	].
	aType = #Boolean ifTrue: [
		^ ByteArray new: self size.
	].
	^ Array new: self size.

]

{ #category : #accessing }
KedamaTurtleVectorPlayer2 >> arrays [

	^ arrays.

]

{ #category : #'turtle map' }
KedamaTurtleVectorPlayer2 >> basicMakeTurtlesMap [

	| x y xArray yArray width height mapIndex whoArray |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	whoArray := arrays at: 1.
	width := kedamaWorld dimensions x.
	height := kedamaWorld dimensions y.
	turtlesMap atAllPut: 0.

	1 to: self size do: [:index |
		x := (xArray at: index) truncated.
		y := (yArray at: index) truncated.
		mapIndex := (width * y) + x + 1.
		(0 < mapIndex and: [mapIndex <= turtlesMap size]) ifTrue: [
			turtlesMap at: mapIndex put: (whoArray at: index).
		].
	].

	turtleMapValid := true.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> color: c [

	c isColor ifTrue: [
		self setColorVarAt: 5 put: ((c pixelValueForDepth: 32) bitAnd: 16rFFFFFF).
	] ifFalse: [
		self setColorVarAt: 5 put: c.
	].
	kedamaWorld drawRequest.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> colorFromPatch: aPatch [

	| xArray yArray cArray patch |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	cArray := arrays at: 5.
	patch := aPatch costume renderedMorph.
	1 to: self size do: [:i |
		(predicate at: i) = 1 ifTrue: [
			cArray at: i put: ((patch pixelAtX: (xArray at: i) y: (yArray at: i)) bitAnd: 16rFFFFFF).
		].
	].
	kedamaWorld drawRequest.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> colorToPatch: aPatch [

	| xArray yArray cArray patch |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	cArray := arrays at: 5.
	patch := aPatch costume renderedMorph.
	1 to: self size do: [:i |
		(predicate at: i) = 1 ifTrue: [
			patch pixelAtX: (xArray at: i) y: (yArray at: i) put: (cArray at: i).
		].
	].

]

{ #category : #'player protocol' }
KedamaTurtleVectorPlayer2 >> compileAllAccessors [

	info rehash.
	info keys asArray do: [:k |
		(#(who x y heading color visible predicate) includes: k) ifFalse: [
			self compileVectorInstVarAccessorsFor: k.
		].
	].

]

{ #category : #'player protocol' }
KedamaTurtleVectorPlayer2 >> compileVectorInstVarAccessorsFor: varName [

	| nameString index type setPhrase |
	nameString := varName asString capitalized.
	index := info at: varName asSymbol.
	self class compileSilently: ('get', nameString, '
	^ ', '(arrays at: ', index printString, ')')
		classified: 'access'.

	type := types at: index.
	type = #Number ifTrue: [
		setPhrase := 'setNumberVarAt:'.
	].
	type = #Boolean ifTrue: [
		setPhrase := 'setBooleanVarAt:'.
	].
	type = #Color ifTrue: [
		setPhrase := 'setColorVarAt:'.
	].
	setPhrase ifNil: [setPhrase := 'setObjectVarAt:'].

	self class compileSilently: ('set', nameString, ': xxxArg
	self ', setPhrase, index printString, ' put: xxxArg')
		classified: 'access'
]

{ #category : #deleting }
KedamaTurtleVectorPlayer2 >> delete [

	| anInstance |
	exampler := nil.
	arrays := nil.
	whoTable := nil.
	turtlesMap := nil.
	self class removeFromSystem: false.
	anInstance := UnscriptedPlayer new.
	self become: anInstance.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> deleteTurtleID: who [

	| whoArray whoIndex newArray |
	whoArray := arrays at: 1.
	whoIndex := whoArray indexOf: who ifAbsent: [^ self].
	deletingIndex := whoIndex - 1.
	arrays withIndexDo: [:array :index |
		newArray := (array copyFrom: 1 to: whoIndex - 1), (array copyFrom: whoIndex + 1 to: array size).
		arrays at: index put: newArray.
	].
	predicate := arrays at: 7.
	whoTableValid := false.
	turtleMapValid := false.
	kedamaWorld drawRequest.

]

{ #category : #'command execution' }
KedamaTurtleVectorPlayer2 >> doCommand: aBlock [

	^ aBlock value: self.

]

{ #category : #'command execution' }
KedamaTurtleVectorPlayer2 >> doDieCommand: aBlock [

	^ exampler doDieCommand: aBlock.

]

{ #category : #'command execution' }
KedamaTurtleVectorPlayer2 >> doExamplerCommand: aBlock [

]

{ #category : #'command execution' }
KedamaTurtleVectorPlayer2 >> doSequentialCommand: aBlock [

	^ exampler doSequentialCommand: aBlock.

]

{ #category : #displaying }
KedamaTurtleVectorPlayer2 >> drawOn: aForm [

	| xArray yArray colorArray visibleArray bits dimX dimY |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	colorArray := arrays at: 5.
	visibleArray := arrays at: 6.
	bits := aForm bits.
	dimX := aForm width.
	dimY := aForm height.

	KedamaTurtleVectorPlayer2 primDrawOn: bits destWidth: dimX destHeight: dimY xArray: xArray yArray: yArray colorArray: colorArray visibleArray: visibleArray.

]

{ #category : #accessing }
KedamaTurtleVectorPlayer2 >> exampler: e [

	exampler := e.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> forward: val [

	exampler getGrouped ifFalse: [
		KedamaTurtleVectorPlayer2 primForwardPredicate: predicate xArray: (arrays at: 2) yArray: (arrays at: 3) headingArray: (arrays at: 4) value: (val isNumber ifTrue: [val asFloat] ifFalse: [val]) destWidth: kedamaWorld wrapX asFloat destHeight: kedamaWorld wrapY asFloat leftEdgeMode: kedamaWorld leftEdgeModeMnemonic rightEdgeMode: kedamaWorld rightEdgeModeMnemonic topEdgeMode: kedamaWorld topEdgeModeMnemonic bottomEdgeMode: kedamaWorld bottomEdgeModeMnemonic.
	] ifTrue: [
		self groupForward: val
	].
	turtleMapValid := false.
	kedamaWorld drawRequest.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getAngleTo: players [

	| p xArray yArray result pX pY xy |
	players isCollection ifFalse: [
		p := players
	].
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	result := KedamaFloatArray new: self size.
	players isCollection ifTrue: [
		pX := KedamaFloatArray new: players size.
		pY := KedamaFloatArray new: players size.
		1 to: players size do: [:i |
			xy := (players at: i) getXAndY.
			pX at: i put: xy x.
			pY at: i put: xy y.
		].
	] ifFalse: [
		p == self
			ifTrue: [
				pX := p getX.
				pY := p getY]
			ifFalse: [
				pX := p turtles getX.
				pY := p turtles getY]
	].
	^ KedamaTurtleVectorPlayer2 primGetAngleToX: pX toY: pY xArray: xArray yArray: yArray resultInto: result.


]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getBlueComponentIn: aPatch [

	| pix xArray yArray patch w |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	patch := aPatch costume renderedMorph.
	w := WordArray new: self size.
	1 to: self size do: [:i |
		pix := patch pixelAtX: (xArray at: i) y: (yArray at: i).
		w at: i put: (pix bitAnd: 16rFF).
	].
	^ w.

]

{ #category : #'accessing - private' }
KedamaTurtleVectorPlayer2 >> getBooleanVarAt: index [

	^ arrays at: index.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getColor [

	^ self getVarAt: 5.

]

{ #category : #'accessing - private' }
KedamaTurtleVectorPlayer2 >> getColorVarAt: index [

	^ (arrays at: index) collect: [:c | Color colorFromPixelValue: c depth: 32].

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getDistanceTo: players [

	| p xArray yArray result pX pY xy |
	players isCollection ifFalse: [
		p := players
	].
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	result := KedamaFloatArray new: self size.
	players isCollection ifTrue: [
		pX := KedamaFloatArray new: players size.
		pY := KedamaFloatArray new: players size.
		1 to: players size do: [:i |
			xy := (players at: i) getXAndY.
			pX at: i put: xy x.
			pY at: i put: xy y.
		].
	] ifFalse: [
		p == self
			ifTrue: [
				pX := p getX.
				pY := p getY]
			ifFalse: [
				pX := p turtles getX.
				pY := p turtles getY]
	].
	^ KedamaTurtleVectorPlayer2 primGetDistanceToX: pX toY: pY xArray: xArray yArray: yArray resultInto: result.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getGreenComponentIn: aPatch [

	| pix xArray yArray patch w |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	patch := aPatch costume renderedMorph.
	w := WordArray new: self size.
	1 to: self size do: [:i |
		pix := patch pixelAtX: (xArray at: i) y: (yArray at: i).
		w at: i put: ((pix bitShift: -8) bitAnd: 16rFF).
	].
	^ w.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getGrouped [

	^ exampler getGrouped.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getHeading [

	| heading result ret |
	heading := (arrays at: 4).
	result := KedamaFloatArray new: heading size.
	ret := KedamaTurtleVectorPlayer2 primGetHeading: heading into: result.
	ret ifNotNil: [^ result].
	
]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getPatchValueIn: aPatch [

	| w patch xArray yArray |
	w := WordArray new: self size.
	patch := aPatch costume renderedMorph.
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	patch pixelsAtXArray: xArray yArray: yArray into: w.
	^ w.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getRedComponentIn: aPatch [

	| pix xArray yArray patch w |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	patch := aPatch costume renderedMorph.
	w := WordArray new: self size.
	1 to: self size do: [:i |
		pix := patch pixelAtX: (xArray at: i) y: (yArray at: i).
		w at: i put: ((pix bitShift: -16) bitAnd: 16rFF).
	].
	^ w.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getTurtleAt: aPlayer [

	| xy |
	aPlayer isCollection ifTrue: [
		self error: 'should not happen'.
	].
	xy := aPlayer getXAndY.
	^ (self aTurtleAtX: xy x y: xy y) ifNil: [^ aPlayer].

]

{ #category : #'player protocol' }
KedamaTurtleVectorPlayer2 >> getTurtleCount [

	^ exampler getTurtleCount.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getTurtleOf: aBreedPlayer [

	| xy |
	aBreedPlayer isCollection ifTrue: [
		"self error: 'should not happen'."
		^ aBreedPlayer.
	].
	xy := aBreedPlayer getXAndY.
	^ (self aTurtleAtX: xy x y: xy y) ifNil: [^ aBreedPlayer].

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getTurtleVisible [

	^ (arrays at: 6) collect: [:t | t = 1].

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getUphillIn: aPatch [

	| xArray yArray headingArray result patch |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	headingArray := arrays at: 4.
	result := KedamaFloatArray new: self size.
	patch := aPatch costume renderedMorph.
	1 to: self size do: [:index |
		result at: index put: (patch
			uphillForTurtleX: (xArray at: index)
			turtleY: (yArray at: index)
			turtleHeading: (headingArray at: index)).
	].
	^ result.

]

{ #category : #'accessing - private' }
KedamaTurtleVectorPlayer2 >> getVarAt: index [

	^ arrays at: index.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getX [

	| xArray |
	exampler getGrouped ifFalse: [
		^ arrays at: 2.
	] ifTrue: [
		xArray := arrays at: 2.
		xArray size = 0 ifTrue: [^ exampler getX].
		^ xArray first.
	].

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getXAndY [
	| ys |
	ys := self getY.
	^ self getX asArray withIndexCollect: [:ea :idx | ea @ (ys at: idx)]

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> getY [

	| yArray |
	exampler getGrouped ifFalse: [
		^ arrays at: 3.
	] ifTrue: [
		yArray := arrays at: 3.
		yArray size = 0 ifTrue: [^ exampler getY].
		^ yArray first.
	].

]

{ #category : #private }
KedamaTurtleVectorPlayer2 >> groupForward: dist [

	| x y headingRadians |
	self size = 0 ifTrue: [^ self].

	x := (arrays at: 2) first.
	y := (arrays at: 3) first.
	headingRadians := (arrays at: 4) first.
	self groupSetX: (x + (dist asFloat * headingRadians cos)).
	self groupSetY: (y - (dist asFloat * headingRadians sin)).

]

{ #category : #private }
KedamaTurtleVectorPlayer2 >> groupSetX: val [

	| xArray headingArray origX origHeading leftEdgeMode rightEdgeMode newArray wrapX minX maxX |
	self size = 0 ifTrue: [^ self].
	xArray := arrays at: 2.
	headingArray := arrays at: 4.
	
	origX := xArray first.
	origHeading := headingArray first.

	leftEdgeMode := kedamaWorld leftEdgeModeMnemonic.
	rightEdgeMode := kedamaWorld rightEdgeModeMnemonic.

	newArray := xArray collect: [:e | e + val - origX].
	wrapX := kedamaWorld wrapX.
	minX := newArray min.
	maxX := newArray max.
	((minX < 0.0) not and: [(maxX >= wrapX) not]) ifTrue: [
		arrays at: 2 put: newArray.
		^ self.
	].

	minX < 0.0 ifTrue: [
		leftEdgeMode = 1 ifTrue: [
			newArray withIndexDo: [:e :i |
				e < 0.0 ifTrue: [newArray at: i put: e + wrapX].
			].
		].
		leftEdgeMode = 2 ifTrue: [
			newArray withIndexDo: [:e :i |
				newArray at: i put: e - minX.
			].
		].
		leftEdgeMode = 3 ifTrue: [
			newArray withIndexDo: [:e :i |
				newArray at: i put: e + (minX * -2.0).
			].
		].		
	].

	maxX >= wrapX ifTrue: [
		rightEdgeMode = 1 ifTrue: [
			newArray withIndexDo: [:e :i |
				e >= wrapX ifTrue: [newArray at: i put: e - wrapX].
			].
		].
		rightEdgeMode = 2 ifTrue: [
			newArray withIndexDo: [:e :i |
				newArray at: i put: e - (maxX - wrapX) - 2.35099e-038.
			].
		].
		rightEdgeMode = 3 ifTrue: [
			newArray withIndexDo: [:e :i |
				newArray at: i put: e - ((maxX - wrapX) * 2.0) - 2.35099e-038.
			].
		].
	].

	arrays at: 2 put: newArray.

]

{ #category : #private }
KedamaTurtleVectorPlayer2 >> groupSetY: val [

	| yArray headingArray origY origHeading topEdgeMode bottomEdgeMode newArray wrapY minY maxY |
	self size = 0 ifTrue: [^ self].
	yArray := arrays at: 3.
	headingArray := arrays at: 4.
	
	origY := yArray first.
	origHeading := headingArray first.

	topEdgeMode := kedamaWorld topEdgeModeMnemonic.
	bottomEdgeMode := kedamaWorld bottomEdgeModeMnemonic.

	newArray := yArray collect: [:e | e + val - origY].
	wrapY := kedamaWorld wrapY.
	minY := newArray min.
	maxY := newArray max.
	((minY < 0.0) not and: [(maxY >= wrapY) not]) ifTrue: [
		arrays at: 3 put: newArray.
		^ self.
	].

	minY < 0.0 ifTrue: [
		topEdgeMode = 1 ifTrue: [
			newArray withIndexDo: [:e :i |
				e < 0.0 ifTrue: [newArray at: i put: e + wrapY].
			].
		].
		topEdgeMode = 2 ifTrue: [
			newArray withIndexDo: [:e :i |
				newArray at: i put: e - minY.
			].
		].
		topEdgeMode = 3 ifTrue: [
			newArray withIndexDo: [:e :i |
				newArray at: i put: e + (minY * -2.0).
			].
		].		
	].

	maxY >= wrapY ifTrue: [
		bottomEdgeMode = 1 ifTrue: [
			newArray withIndexDo: [:e :i |
				e >= wrapY ifTrue: [newArray at: i put: e - wrapY].
			].
		].
		bottomEdgeMode = 2 ifTrue: [
			newArray withIndexDo: [:e :i |
				newArray at: i put: e - (maxY - wrapY) - 2.35099e-038.
			].
		].
		bottomEdgeMode = 3 ifTrue: [
			newArray withIndexDo: [:e :i |
				newArray at: i put: e - ((maxY - wrapY) * 2.0) - 2.35099e-038.
			].
		].
	].

	arrays at: 3 put: newArray.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> heading [

	^ self getHeading.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> heading: degrees [

	| deg |
	deg := degrees isNumber ifTrue: [degrees asFloat] ifFalse: [degrees].
	KedamaTurtleVectorPlayer2 primSetPredicate: predicate heading: (arrays at: 4) from: deg.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> hide [

	(arrays at: 6) atAllPut: 0.

]

{ #category : #enumeration }
KedamaTurtleVectorPlayer2 >> indexOf: who [

	| whoArray |
	whoTableValid ifTrue: [^ whoTable at: (who - whoTableBase)].

	whoArray := arrays at: 1.

	whoArray size = 0 ifTrue: [^ 0].

	whoTableBase := whoArray first - 1.
	whoTable := WordArray new: whoArray last - whoTableBase.
	1 to: whoArray size do: [:w |
		whoTable at: (whoArray at: w) - whoTableBase put: w.
	].
	whoTableValid := true.

	^ whoTable at: (who - whoTableBase).


]

{ #category : #accessing }
KedamaTurtleVectorPlayer2 >> info [

	^ info.

]

{ #category : #initialization }
KedamaTurtleVectorPlayer2 >> initialize [

	super initialize.
	info := IdentityDictionary new.
	predicate := ByteArray new: 0.
	info at: #who put: 1.
	info at: #x put: 2.
	info at: #y put: 3.
	info at: #heading put: 4.
	info at: #color put: 5.
	info at: #visible put: 6.
	info at: #predicate put: 7.

	arrays := Array new: 7.
	arrays at: (info at: #who) put: (WordArray new: 0).
	arrays at: (info at: #x) put: (KedamaFloatArray new: 0).
	arrays at: (info at: #y) put: (KedamaFloatArray new: 0).
	arrays at: (info at: #heading) put: (KedamaFloatArray new: 0).
	arrays at: (info at: #color) put: (WordArray new: 0).
	arrays at: (info at: #visible) put: (ByteArray new: 0).
	arrays at: (info at: #predicate) put: predicate.

	types := Array new: 64.

	types at: 1 put: #Integer.
	types at: 2 put: #Number.
	types at: 3 put: #Number.
	types at: 4 put: #Number.
	types at: 5 put: #Color.
	types at: 6 put: #Boolean.
	types at: 7 put: #Boolean.

	whoTableValid := false.
	turtleMapValid := false.



]

{ #category : #enumeration }
KedamaTurtleVectorPlayer2 >> initializeDeletingIndex [

	deletingIndex := 0.

]

{ #category : #accessing }
KedamaTurtleVectorPlayer2 >> instSize [

	^ arrays size.

]

{ #category : #'turtle map' }
KedamaTurtleVectorPlayer2 >> invalidateTurtleMap [

	turtleMapValid := false.

]

{ #category : #accessing }
KedamaTurtleVectorPlayer2 >> kedamaWorld: k [

	kedamaWorld := k.

]

{ #category : #'add turtles' }
KedamaTurtleVectorPlayer2 >> makePrototypeFromFirstInstance [

	^ (1 to: arrays size) collect: [:index |
		(arrays at: index) first
	].

]

{ #category : #'turtle map' }
KedamaTurtleVectorPlayer2 >> makeTurtlesMap [

	| xArray yArray width height whoArray ret |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	whoArray := arrays at: 1.
	width := kedamaWorld dimensions x.
	height := kedamaWorld dimensions y.
	turtlesMap ifNil: [turtlesMap := WordArray new: width * height].

	ret := KedamaTurtleVectorPlayer2 primMakeTurtlesMap: turtlesMap whoArray: whoArray xArray: xArray yArray: yArray width: width height: height.

	ret ifNil: [self basicMakeTurtlesMap].

	turtleMapValid := true.

]

{ #category : #enumeration }
KedamaTurtleVectorPlayer2 >> nextDeletingIndex [

	^ deletingIndex := deletingIndex + 1.

]

{ #category : #'player protocol' }
KedamaTurtleVectorPlayer2 >> noteRenameOf: oldSlotName to: newSlotName inPlayer: aPlayer [

	self compileAllAccessors

]

{ #category : #'player protocol' }
KedamaTurtleVectorPlayer2 >> removeVectorSlotNamed: aSlotName [

	| index newArrays |
	index := info at: aSlotName asSymbol ifAbsent: [^ self].
	newArrays := (arrays copyFrom: 1 to: index - 1), (arrays copyFrom: index + 1 to: arrays size).
	types replaceFrom: index to: types size - 1 with: types startingAt: index + 1.

	info removeKey: aSlotName asSymbol.
	info associationsDo: [:assoc | assoc value > index ifTrue: [info at: assoc key put: assoc value - 1]].
	arrays := newArrays.
	self class removeSelectorSilently: aSlotName asGetterSelector.
	self class removeSelectorSilently: aSlotName asSetterSelector.
	self compileAllAccessors.

]

{ #category : #'player protocol' }
KedamaTurtleVectorPlayer2 >> renameVectorSlot: oldSlotName newSlotName: newSlotName [

	| index |
	index := info at: oldSlotName asSymbol ifAbsent: [^ self].
	info removeKey: oldSlotName asSymbol.
	info at: newSlotName put: index.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> setBlueComponentIn: aPatch to: value [

	| pix xArray yArray patch component |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	patch := aPatch costume renderedMorph.
	value isCollection ifFalse: [
		component := value asInteger bitAnd: 16rFF.
	].
	(1 to: self size) do: [:i |
		(predicate at: i) = 1 ifTrue: [
			value isCollection ifTrue: [
				component := (value at: i) asInteger bitAnd: 16rFF.
			].
			pix := patch pixelAtX: (xArray at: i) y: (yArray at: i).
			pix := (pix bitAnd: 16rFFFF00) bitOr: component.
			patch pixelAtX: (xArray at: i) y: (yArray at: i) put: pix.
		].
	].

]

{ #category : #'accessing - private' }
KedamaTurtleVectorPlayer2 >> setBooleanVarAt: index put: v [

	(v == true or: [v == false]) ifTrue: [
		(PredicatedArray predicates: predicate values: (arrays at: index) type: #Boolean) atAllPut: (v == true ifTrue: [1] ifFalse: [0]).
		^ self.
	].
	(PredicatedArray predicates: predicate values: (arrays at: index) type: #Boolean) replaceFrom: 1 to: v size with: v startingAt: 1.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> setColor: color [

	^ self color: color.

]

{ #category : #'accessing - private' }
KedamaTurtleVectorPlayer2 >> setColorVarAt: index put: cPixel [

	cPixel isNumber ifTrue: [
		(PredicatedArray predicates: predicate values: (arrays at: index) type: #Color) atAllPut: cPixel.
		^ self.
	].
	cPixel isColor ifTrue: [
		(PredicatedArray predicates: predicate values: (arrays at: index) type: #Color) atAllPut: (cPixel pixelValueForDepth: 32).
		^ self.
	].

	(PredicatedArray predicates: predicate values: (arrays at: index) type: #Color) replaceFrom: 1 to: cPixel size with: cPixel startingAt: 1.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> setGreenComponentIn: aPatch to: value [

	| pix xArray yArray patch component |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	patch := aPatch costume renderedMorph.
	value isCollection ifFalse: [
		component := (value asInteger bitAnd: 16rFF) bitShift: 8.
	].
	(1 to: self size) do: [:i |
		(predicate at: i) = 1 ifTrue: [
			value isCollection ifTrue: [
				component := ((value at: i) asInteger bitAnd: 16rFF) bitShift: 8.
			].
			pix := patch pixelAtX: (xArray at: i) y: (yArray at: i).
			pix := (pix bitAnd: 16rFF00FF) bitOr: component.
			patch pixelAtX: (xArray at: i) y: (yArray at: i) put: pix.
		].
	].

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> setHeading: degrees [

	^ self heading: degrees.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> setInitialValueOf: name from: from to: to for: aKedamaWorld [

	| array max |
	array := arrays at: (info at: name).
	name = #who ifTrue: [
		from to: to do: [:index |
			array at: index put: (aKedamaWorld nextTurtleID).
		].
		^ self.
	].
	name = #x ifTrue: [
		max := aKedamaWorld dimensions x * 100.
		KedamaTurtleVectorPlayer2 randomRange: max from: from to: to intoFloatArray: array factor: 0.01 kedamaWorld: kedamaWorld.
		^ self.
	].
	name = #y ifTrue: [
		max := aKedamaWorld dimensions y * 100.
		KedamaTurtleVectorPlayer2 randomRange: max from: from to: to intoFloatArray: array factor: 0.01 kedamaWorld: kedamaWorld.
		^ self.
	].
	name = #heading ifTrue: [
		KedamaTurtleVectorPlayer2 randomRange: 36000 from: from to: to intoFloatArray: array factor: (0.01 *  0.0174532925199433) kedamaWorld: kedamaWorld.
		^ self.
	].

]

{ #category : #'accessing - private' }
KedamaTurtleVectorPlayer2 >> setNumberVarAt: index put: v [

	v isNumber ifTrue: [
		(PredicatedArray predicates: predicate values: (arrays at: index) type: #Number) atAllPut: v.
		^ self.
	].
	(v isMemberOf: KedamaFloatArray) ifTrue: [
		(PredicatedArray predicates: predicate values: (arrays at: index) type: #Number) replaceFrom: 1 to: v size with: v startingAt: 1.
		^ self.
	].
	(v isMemberOf: WordArray) ifTrue: [
		(PredicatedArray predicates: predicate values: (arrays at: index) type: #Number) 
			replaceFrom: 1 to: v size with: v startingAt: 1.
		^ self.
	].

]

{ #category : #'accessing - private' }
KedamaTurtleVectorPlayer2 >> setObjectVarAt: index put: v [

	(v isKindOf: Array) ifFalse: [
		(PredicatedArray predicates: predicate values: (arrays at: index) type: #Object) atAllPut: v.
		^ self.
	].
	(PredicatedArray predicates: predicate values: (arrays at: index) type: #Object) replaceFrom: 1 to: v size with: v startingAt: 1.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> setPatchValueIn: aPatch to: value [

	| xArray yArray patchMorph |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	patchMorph := aPatch costume renderedMorph.
	patchMorph setPixelsPredicates: predicate xArray: xArray yArray: yArray value: value.


]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> setRedComponentIn: aPatch to: value [

	| pix xArray yArray patch component |
	xArray := arrays at: 2.
	yArray := arrays at: 3.
	patch := aPatch costume renderedMorph.
	value isCollection ifFalse: [
		component := (value asInteger bitAnd: 16rFF) bitShift: 16.
	].
	(1 to: self size) do: [:i |
		(predicate at: i) = 1 ifTrue: [
			value isCollection ifTrue: [
				component := ((value at: i) asInteger bitAnd: 16rFF) bitShift: 16.
			].
			pix := patch pixelAtX: (xArray at: i) y: (yArray at: i).
			pix := (pix bitAnd: 16r00FFFF) bitOr: component.
			patch pixelAtX: (xArray at: i) y: (yArray at: i) put: pix.
		].
	].

]

{ #category : #'slot-kedama' }
KedamaTurtleVectorPlayer2 >> setTurtleCount: aNumber [

	^ exampler setTurtleCount: aNumber
]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> setTurtleVisible: aValue [

	| val |
	aValue isCollection ifTrue: [
		1 to: self size do: [:i |
			(predicate at: i) = 1 ifTrue: [
				(arrays at: 6) at: i put: ((aValue at: i) ifTrue: [1] ifFalse: [0]).
			].
		].
	] ifFalse: [
		val := aValue ifTrue: [1] ifFalse: [0].
		1 to: self size do: [:i |
			(predicate at: i) = 1 ifTrue: [
				(arrays at: 6) at: i put: (val).
			].
		].
	].
	kedamaWorld drawRequest.

]

{ #category : #'add turtles' }
KedamaTurtleVectorPlayer2 >> setTurtlesCount: count prototype: prototype for: aKedamaWorld randomize: rondomizeFlag [

	| anInteger array |
	anInteger := count.
	count < 0 ifTrue: [anInteger := 0].

	self size > anInteger ifTrue: [
		info associationsDo: [:assoc |
			array := (arrays at: assoc value).
			array := array copyFrom: 1 to: anInteger.
			arrays at: assoc value put: array.
		].
		turtleMapValid := false.
		whoTableValid := false.
		predicate := arrays at: 7.
	].

	self size < anInteger ifTrue: [
		self addTurtlesCount: (anInteger - self size) ofPrototype: prototype for: aKedamaWorld randomize: rondomizeFlag.
		turtleMapValid := false.
		whoTableValid := false.

	].
	kedamaWorld drawRequest.



]

{ #category : #'player protocol' }
KedamaTurtleVectorPlayer2 >> setVectorSlotTypeFor: slotName typeChosen: typeChosen [

	| index initVar |
	index := info at: slotName asSymbol.
	index = 0 ifTrue: [^ self].

	initVar := self initialValueForSlotOfType: typeChosen.

	types at: index put: typeChosen.

	arrays at: index put: (self arrayForType: typeChosen).
	self compileVectorInstVarAccessorsFor: slotName.
	self perform: ('set', slotName capitalized, ':') asSymbol with: initVar.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> setX: v [

	exampler getGrouped ifFalse: [
		KedamaTurtleVectorPlayer2
			primSetXPredicates: predicate
			xArray: (arrays at: 2)
			headingArray: (arrays at: 4)
			value: (v isNumber ifTrue: [v asFloat] ifFalse: [v])
			destWidth: kedamaWorld wrapX
			leftEdgeMode: kedamaWorld leftEdgeModeMnemonic
			rightEdgeMode: kedamaWorld rightEdgeModeMnemonic.
	] ifTrue: [
		self groupSetX: v
	].
	turtleMapValid := false.
	kedamaWorld drawRequest.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> setY: v [

	exampler getGrouped ifFalse: [
		KedamaTurtleVectorPlayer2
			primSetYPredicates: predicate
			yArray: (arrays at: 3)
			headingArray: (arrays at: 4)
			value: (v isNumber ifTrue: [v asFloat] ifFalse: [v])
			destHeight: kedamaWorld wrapY
			topEdgeMode: kedamaWorld topEdgeModeMnemonic
			bottomEdgeMode: kedamaWorld bottomEdgeModeMnemonic.
	] ifTrue: [
		self groupSetY: v.
	].
	turtleMapValid := false.
	kedamaWorld drawRequest.

]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> show [

	(arrays at: 6) atAllPut: 1.

]

{ #category : #accessing }
KedamaTurtleVectorPlayer2 >> size [

	^ arrays first size.

]

{ #category : #'command execution' }
KedamaTurtleVectorPlayer2 >> test: cond ifTrue: trueBlock ifFalse: falseBlock [

	| origPredicate c actualCond condValue |

	(cond == true or: [cond == false]) ifTrue: [
		^ cond ifTrue: [trueBlock value: self] ifFalse: [falseBlock value: self].
	].
	actualCond := cond.
	cond isBlock ifTrue: [
		actualCond := ByteArray new: predicate size.
		condValue := cond value. 
		condValue isCollection 
			ifTrue: [
				actualCond := condValue.
			] ifFalse: [
				1 to: predicate size do: [:i | actualCond at: i put: (cond value ifTrue: [1] ifFalse: [0])]
			]
	].
	origPredicate := predicate shallowCopy.
	predicate bytesAnd: actualCond.
	trueBlock value: self.

	c := actualCond shallowCopy.
	c not.
	predicate replaceFrom: 1 to: (predicate size min: origPredicate size) with: origPredicate startingAt: 1.
	predicate bytesAnd: c.
	falseBlock value: self.
	predicate replaceFrom: 1 to: (predicate size min: origPredicate size) with: origPredicate startingAt: 1.
]

{ #category : #'player commands' }
KedamaTurtleVectorPlayer2 >> turn: degrees [
	"Turn by the given number of degrees."

	self heading: (self heading + degrees).

]

{ #category : #private }
KedamaTurtleVectorPlayer2 >> typeFor: aValue [

	aValue isNumber ifTrue: [^ #Number].
	aValue isColor ifTrue: [^ #Color].
	(aValue = true or: [aValue = false]) ifTrue: [^ #Boolean].
	^ #Object

]

{ #category : #accessing }
KedamaTurtleVectorPlayer2 >> types [

	^ types.

]

{ #category : #private }
KedamaTurtleVectorPlayer2 >> valueForSetting: aValue [

	aValue isNumber ifTrue: [^ aValue].
	aValue isColor ifTrue: [^ aValue pixelValueForDepth: 32].
	aValue = true ifTrue: [^ 1].
	aValue = false ifTrue: [^ 0].
	^ aValue
]
