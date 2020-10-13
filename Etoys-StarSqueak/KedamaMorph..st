"
A tile-scriptable variant of StarSqueak.

"
Class {
	#name : #KedamaMorph,
	#superclass : #Morph,
	#instVars : [
		'dimensions',
		'wrapX',
		'wrapY',
		'pixelsPerPatch',
		'patchesToDisplay',
		'patchVarDisplayForm',
		'lastTurtleID',
		'turtleCount',
		'turtlesDict',
		'turtlesDictSemaphore',
		'turtlesToDisplay',
		'magnifiedDisplayForm',
		'autoChanged',
		'topEdgeMode',
		'bottomEdgeMode',
		'leftEdgeMode',
		'rightEdgeMode',
		'topEdgeModeMnemonic',
		'bottomEdgeModeMnemonic',
		'leftEdgeModeMnemonic',
		'rightEdgeModeMnemonic',
		'drawRequested',
		'changePending',
		'defaultPatch'
	],
	#classVars : [
		'RandomSeed'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #'class initialization' }
KedamaMorph class >> additionsToViewerCategories [
	"Answer a list of (<categoryName> <list of category specs>) pairs that characterize the phrases this kind of morph wishes to add to various Viewer categories."
	^ #(

 	(kedama (
		(command addToPatchDisplayList: 'add patch to display list' Patch)
		(command removeAllFromPatchDisplayList 'clear the patch display list')
		(slot patchDisplayList 'patches to display' String readOnly Player getPatchesList unused unused)
		(command addToTurtleDisplayList: 'add turtle to display list' Player)
		(command removeAllFromTurtleDisplayList 'clear the turtle display list')
		(slot turtleDisplayList 'turtles to display' String readOnly Player getTurtlesList unused unused)
		(slot pixelsPerPatch 'the display scale' Number readWrite Player getPixelsPerPatch Player setPixelsPerPatch:)
		(slot dimensionsWidth 'widht of kedma world' Number readWrite Player getDimensionsWidth Player setDimensionsWidth:)
		(slot dimensionsHeigth 'height of kedama world' Number readWrite Player getDimensionsHeight Player setDimensionsHeight:)
		(slot color 'The color of the object' Color readWrite Player getColor  Player  setColor:)
		"(command makeTurtlesMap 'Internally create the map of turtles')"
		(slot leftEdgeMode 'the mode of left edge' EdgeMode readWrite Player getLeftEdgeMode Player setLeftEdgeMode:)
		(slot rightEdgeMode 'the mode of right edge' EdgeMode readWrite Player getRightEdgeMode Player setRightEdgeMode:)
		(slot topEdgeMode 'the mode of top edge' EdgeMode readWrite Player getTopEdgeMode Player setTopEdgeMode:)
		(slot bottomEdgeMode 'the mode of bottom edge' EdgeMode readWrite Player getBottomEdgeMode Player setBottomEdgeMode:)
	))
).

]

{ #category : #'class initialization' }
KedamaMorph class >> cleanUp [
"
	self cleanUp
"
	self allInstancesDo: [:e | e cleanUp].

]

{ #category : #'class initialization' }
KedamaMorph class >> defaultDimensions [

	"Answer the dimensions of this StarSqueak simulation. Subclasses can override this method to define their own world size."

	^ 100@100.

]

{ #category : #'class initialization' }
KedamaMorph class >> defaultNameStemForInstances [

	^ 'KedamaWorld' translatedNoop

]

{ #category : #'global primitive backup' }
KedamaMorph class >> degreesToRadians: degrees [

	| deg q headingRadians |
	deg := 90.0 - degrees.
	q := (deg / 360.0) asInteger.
	deg < 0.0 ifTrue: [q := q - 1].
	headingRadians := (deg - (q * 360.0)) * 0.0174532925199433.
	^ headingRadians.

]

{ #category : #'class initialization' }
KedamaMorph class >> descriptionForPartsBin [
	^ self partName:	'KedamaWorld'
		categories:		#('Kedama')
		documentation:	'A tile scriptable particle system' translated
]

{ #category : #'class initialization' }
KedamaMorph class >> initialize [
	"Kedama initialize"

	RandomSeed := 17.

]

{ #category : #'class initialization' }
KedamaMorph class >> newSet [

	| k p t s w |
	Cursor wait showWhile: [
		k := self new.
		k assuredPlayer.
		p := k defaultPatch.
		t := k assuredPlayer newTurtleForSet.

		s := SelectionMorph new.

		w := PasteUpMorph new.
		w extent: (k width * 2 max: 400)@(k height + 50 max: 300).
		p position: (k width + 75)@50.
		t position: (k width + 75)@175.
		k position: 25@25.
		w addMorph: k.
		w addMorph: t.
		w addMorph: p.
		w addMorph: s.
		s bounds: w bounds.
		s selectSubmorphsOf: w.
	].
	^ s.

]

{ #category : #'global primitive backup' }
KedamaMorph class >> radiansToDegrees: radians [

	| degrees deg |
	degrees := radians / 0.0174532925199433.
	deg := 90.0 - degrees.
	deg > 0.0 ifFalse: [deg := deg + 360.0].
	^ deg.


]

{ #category : #'as yet unclassified' }
KedamaMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl |
			cl registerQuad: {
					#KedamaMorph. #newSet. 'Particles' translatedNoop.
					'A Kedama World with pre-made components' translatedNoop}
				forFlapNamed: 'Supplies']
]

{ #category : #'global primitive backup' }
KedamaMorph class >> scalarXAt: index xArray: xArray headingArray: headingArray value: val destWidth: destWidth leftEdgeMode: leftEdgeMode rightEdgeMode: rightEdgeMode [

	| newX headingRadians |
	newX := val.
	newX < 0.0 ifTrue: [
		leftEdgeMode = 1 ifTrue: [
			"wrap"
			newX := newX + destWidth.
		].
		leftEdgeMode = 2 ifTrue: [
			"stick"
			newX := 0.0.
		].
		leftEdgeMode = 3 ifTrue: [
			"bounce"
			newX := 0.0 - newX.
			headingRadians := headingArray at: index.
			headingRadians <  3.141592653589793
				ifTrue: [headingArray at: index put: 3.141592653589793 - headingRadians]
				ifFalse: [headingArray at: index put: 9.42477796076938 - headingRadians].
		].
	].

	newX >= destWidth ifTrue: [
		rightEdgeMode = 1 ifTrue: [
			newX := newX - destWidth.
		].
		rightEdgeMode = 2 ifTrue: [
			newX := destWidth - 0.000001.
		].
		rightEdgeMode = 3 ifTrue: [
			newX := (destWidth - 0.000001) - (newX - destWidth).
			headingRadians := headingArray at: index.
			headingRadians < 3.141592653589793
				ifTrue: [headingArray at: index put: (3.141592653589793 - headingRadians)]
				ifFalse: [headingArray at: index put: (9.42477796076938 - headingRadians)].
		]
	].
	xArray at: index put: newX.

]

{ #category : #'global primitive backup' }
KedamaMorph class >> scalarYAt: index yArray: yArray headingArray: headingArray value: val destHeight: destHeight topEdgeMode: topEdgeMode bottomEdgeMode: bottomEdgeMode [

	| newY |
	newY := val.
	newY < 0.0 ifTrue: [
		topEdgeMode = 1 ifTrue: [
			"wrap"
			newY := newY + destHeight.
		].
		topEdgeMode = 2 ifTrue: [
			"stick"
			newY := 0.0.
		].
		topEdgeMode = 3 ifTrue: [
			"bounce"
			newY := 0.0 - newY.
			headingArray at: index put: (6.283185307179586 - (headingArray at: index)).
		].
	].

	newY >= destHeight ifTrue: [
		bottomEdgeMode = 1 ifTrue: [
			newY := newY - destHeight.
		].
		bottomEdgeMode = 2 ifTrue: [
			newY := destHeight - 0.000001.
		].
		bottomEdgeMode = 3 ifTrue: [
			newY := (destHeight - 0.000001) - (newY - destHeight).
			headingArray at: index put: (6.283185307179586 - (headingArray at: index)).
		]
	].
	yArray at: index put: newY.

]

{ #category : #'class initialization' }
KedamaMorph class >> supplementaryPartsDescriptions [
	^ {DescriptionForPartsBin
		formalName: 'Particles' translatedNoop
		categoryList: {'Basic' translatedNoop}
		documentation: 'A Kedama World with pre-made components' translatedNoop
		globalReceiverSymbol: #KedamaMorph
		nativitySelector: #newSet.
	}
]

{ #category : #'event handling' }
KedamaMorph >> acceptDroppingMorph: morphToDrop event: evt [

	| f turtle |
	(morphToDrop renderedMorph isKindOf: SketchMorph) ifFalse: [
		^morphToDrop rejectDropMorphEvent: evt.
	].

	f := morphToDrop renderedMorph rotatedForm.
	f := f magnify: f boundingBox by: (1.0 / self pixelsPerPatch asFloat) smoothing: 1.

	turtle := self player newTurtleSilently.
	turtle createTurtlesAsIn: f originAt: ((morphToDrop topLeft - self topLeft) / self pixelsPerPatch asFloat) asIntegerPoint.
	"turtle isGroup: true."
	turtle color: (self dominantColorWithoutTransparent: f).

]

{ #category : #'event handling' }
KedamaMorph >> acceptForm: aForm [

	| c xArray yArray colorArray newX newY turtlesByColor colorArrays thisPlayer xArrays yArrays |
	turtlesDict keysAndValuesDo: [:player :vector |
		player setTurtleCount: 0].
	turtlesByColor := Dictionary new.
	turtlesDict keysAndValuesDo: [:player :vector |
		turtlesByColor at: player color put: player].
	xArrays := Dictionary new.
	yArrays := Dictionary new.
	colorArrays := Dictionary new.
	0 to: aForm height do: [:y |
		0 to: aForm width do: [:x |
			c := aForm colorAt: (x@y).
			c isTransparent ifFalse: [
				newX := x + aForm offset x.
				newY := y + aForm offset y.
				((newX >= 0 and: [newX < (self dimensions * pixelsPerPatch) x]) and: [newY >= 0 and: [newY < (self dimensions * pixelsPerPatch) y]]) ifTrue: [
					thisPlayer := turtlesByColor at: c ifAbsentPut: [
						turtlesByColor keys
							detect: [:thisColor | (thisColor diff: c) < 0.2]
							ifFound: [:thisColor | turtlesByColor at: thisColor]
							ifNone: [
								(self player newTurtleSilently color: c; player)]].
					xArray := xArrays at: thisPlayer ifAbsentPut: [OrderedCollection new: aForm width * aForm height].
					yArray := yArrays at: thisPlayer ifAbsentPut: [OrderedCollection new: aForm width * aForm height].
					colorArray := colorArrays at: thisPlayer ifAbsentPut: [OrderedCollection new: aForm width * aForm height].

					xArray add: newX asFloat / pixelsPerPatch.
					yArray add: newY asFloat / pixelsPerPatch.
					colorArray add: (c pixelValueForDepth: 32).
				].
			].
		].
	].
	xArrays keysAndValuesDo: [:player :xArry |
		self makeTurtlesAtPositionsIn: {xArry asArray. (yArrays at: player) asArray. (colorArrays at: player) asArray} examplerPlayer: player ofPrototype: nil.
		player costume privateTurtleCount: (self turtlesCountOf: player)].
]

{ #category : #'event handling' }
KedamaMorph >> acceptFormFromDrawing: largeForm [

	| aForm c xArray yArray colorArray newX newY turtlesByColor colorArrays thisPlayer xArrays yArrays |
	turtlesDict keysAndValuesDo: [:player :vector |
		player setTurtleCount: 0].
	turtlesByColor := Dictionary new.
	turtlesDict keysAndValuesDo: [:player :vector |
		turtlesByColor at: player color put: player].
	xArrays := Dictionary new.
	yArrays := Dictionary new.
	colorArrays := Dictionary new.
	aForm := largeForm scaledToSize: (largeForm extent / pixelsPerPatch) rounded smoothing: 1.
	aForm offset: (largeForm offset / self pixelsPerPatch) rounded.
	0 to: aForm height do: [:y |
		0 to: aForm width do: [:x |
			c := aForm colorAt: (x@y).
			c isTransparent ifFalse: [
				newX := x + aForm offset x.
				newY := y + aForm offset y.
				((newX >= 0 and: [newX < self dimensions x]) and: [newY >= 0 and: [newY < self dimensions y]]) ifTrue: [
					thisPlayer := turtlesByColor at: c ifAbsentPut: [
						turtlesByColor keys
							detect: [:thisColor | (thisColor diff: c) < 0.2]
							ifFound: [:thisColor | turtlesByColor at: thisColor]
							ifNone: [
								turtlesDict associations first key. "all non-matching go to be the first turtle"
								"(self player newTurtleSilently color: c; player)"]].
					xArray := xArrays at: thisPlayer ifAbsentPut: [OrderedCollection new: aForm width * aForm height].
					yArray := yArrays at: thisPlayer ifAbsentPut: [OrderedCollection new: aForm width * aForm height].
					colorArray := colorArrays at: thisPlayer ifAbsentPut: [OrderedCollection new: aForm width * aForm height].

					xArray add: newX asFloat.
					yArray add: newY asFloat.
					colorArray add: (c pixelValueForDepth: 32).
				].
			].
		].
	].
	xArrays keysAndValuesDo: [:player :xArry |
		self makeTurtlesAtPositionsIn: {xArry asArray. (yArrays at: player) asArray. (colorArrays at: player) asArray} examplerPlayer: player ofPrototype: nil.
		player costume privateTurtleCount: (self turtlesCountOf: player)].
]

{ #category : #setup }
KedamaMorph >> addToPatchDisplayList: p [

	| a |
	a := patchesToDisplay copyWithout: p.
	patchesToDisplay := a copyWith: p.

]

{ #category : #setup }
KedamaMorph >> addToTurtleDisplayList: p [

	(p isKindOf: KedamaExamplerPlayer) ifFalse: [^ self].
	turtlesToDisplay add: p
]

{ #category : #'submorphs-accessing' }
KedamaMorph >> allSubmorphNamesDo: aBlock [

	super allSubmorphNamesDo: aBlock.
	aBlock value: self defaultPatch externalName.

]

{ #category : #drawing }
KedamaMorph >> areasRemainingToFill: aRectangle [
	"Drawing optimization. Since I completely fill my bounds with opaque pixels, this method tells Morphic that it isn't necessary to draw any morphs covered by me."
	
	^ aRectangle areasOutside: self bounds

]

{ #category : #accessing }
KedamaMorph >> bottomEdgeMode [

	^ bottomEdgeMode.

]

{ #category : #accessing }
KedamaMorph >> bottomEdgeMode: aSymbol [

	bottomEdgeMode := aSymbol asSymbol.
	bottomEdgeMode == #wrap ifTrue: [
		bottomEdgeModeMnemonic := 1.
		^ self
	].
	bottomEdgeMode == #stick ifTrue: [
		bottomEdgeModeMnemonic := 2.
		^ self
	].
	(bottomEdgeMode == #bounce or: [bottomEdgeMode == #bouncing]) ifTrue: [
		bottomEdgeModeMnemonic := 3.
		^ self
	].

]

{ #category : #accessing }
KedamaMorph >> bottomEdgeModeMnemonic [

	^ bottomEdgeModeMnemonic.

]

{ #category : #etoys }
KedamaMorph >> categoriesForViewer [
	"Answer a list of symbols representing the categories to offer in the viewer, in order"
	^ super categoriesForViewer.
"
	| aList |
	aList := OrderedCollection new.
	aList addAllFirstUnlessAlreadyPresent: (self class additionsToViewerCategories collect:
				[:categorySpec | categorySpec first]).
	^ aList
"
]

{ #category : #setup }
KedamaMorph >> cleanUp [

	extension actorState: nil.
	extension player: nil.
	self initializeTurtlesDict.

]

{ #category : #setup }
KedamaMorph >> clearAll [
	"Reset this StarSqueak world. All patch variables are cleared, all turtles are removed, and all demons are turned off."

	patchVarDisplayForm := Form extent: dimensions depth: 32.
	self initializePatch.
	self recreateMagnifiedDisplayForm.
	self initializeTurtlesDict.

	turtleCount := nil.
	lastTurtleID := 0.

	self color: Color black.


]

{ #category : #accessing }
KedamaMorph >> colorAt: aLocalPoint [

	| pix |
	pix := patchVarDisplayForm pixelValueAt: (aLocalPoint // pixelsPerPatch) asIntegerPoint.
	^ Color colorFromPixelValue: (pix bitOr: 16rFF000000) depth: 32.

]

{ #category : #private }
KedamaMorph >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	self migrateInstancesWithoutChangePending.

]

{ #category : #deleting }
KedamaMorph >> delete [

	super delete.
	turtlesDict keys do: [:key |
		self deleteAllTurtlesOfExampler: key.
		key costume ifNotNil: [ :costume |
			costume renderedMorph delete ] ]. 
	defaultPatch ifNotNil: [ defaultPatch delete ]

]

{ #category : #turtles }
KedamaMorph >> deleteAllTurtlesOfExampler: examplerPlayer [

	turtlesDict removeKey: examplerPlayer ifAbsent: [].
	self removeFromTurtleDisplayList: examplerPlayer.
	turtleCount := nil

]

{ #category : #turtles }
KedamaMorph >> deleteTurtleID: who of: examplerPlayer [
	"Delete the given turtle from this world."

	| array |
	array := examplerPlayer turtles.
	array ifNil: [^ self].
	turtlesDictSemaphore critical: [
		array deleteTurtleID: who.
	].
	turtleCount := nil.
	examplerPlayer costume renderedMorph privateTurtleCount: array size.
	"examplerPlayer allOpenViewers do: [:v | v resetWhoIfNecessary]."

]

{ #category : #accessing }
KedamaMorph >> dimensions [

	^ dimensions

]

{ #category : #accessing }
KedamaMorph >> dimensions: anExtent [
	dimensions := anExtent.
	wrapX := dimensions x asFloat.
	wrapY := dimensions y asFloat.
	patchVarDisplayForm := Form extent: dimensions depth: 32.
	patchesToDisplay ifNotNil: [
		patchesToDisplay do: [ :ea |
			ea newExtent: anExtent.
		].
	].
	self pixelsPerPatch: self pixelsPerPatch.
]

{ #category : #drawing }
KedamaMorph >> display [
	"Display this world on the Display. Used for debugging."

	| c |
	c := FormCanvas extent: (dimensions * pixelsPerPatch) depth: 32.
	c := c copyOffset: bounds origin negated.
	self drawOn: c.
	c form display.

]

{ #category : #'event handling' }
KedamaMorph >> dominantColorWithoutTransparent: aForm [
	| tally max maxi |
	aForm depth > 16 ifTrue:
		[^self dominantColorWithoutTransparent: (aForm asFormOfDepth: 16)].
	tally := aForm tallyPixelValues.
	max := maxi := 0.
	tally withIndexDo: [:n :i | n > max ifTrue: [ i ~= 1 ifTrue: [max := n. maxi := i]]].
	^ Color colorFromPixelValue: maxi - 1 depth: aForm depth

]

{ #category : #drawing }
KedamaMorph >> drawOn: aCanvas [

	| result |
	drawRequested ifFalse: [^ self].
	drawRequested := false.
	changePending := false.
	"Time millisecondClockValue printString displayAt: 0@0."
	aCanvas fillRectangle: (self bounds) color: self color.
	self player ifNil: [^ self].
	patchVarDisplayForm fillColor: self color.
	patchesToDisplay do: [:p |
		p displayPatchVariableOn: patchVarDisplayForm.
	].
	self drawTurtlesOnForm: patchVarDisplayForm.
	pixelsPerPatch = 1 ifTrue: [
		aCanvas drawImage: patchVarDisplayForm at: bounds origin.
	] ifFalse: [
		result := self zoom: patchVarDisplayForm into: magnifiedDisplayForm factor: pixelsPerPatch.
		result ifNil: [
			aCanvas warpImage: patchVarDisplayForm transform: (MatrixTransform2x3 withScale: pixelsPerPatch) at: self innerBounds origin.
		] ifNotNil: [
			aCanvas drawImage: magnifiedDisplayForm at: bounds origin.
		]
	].


]

{ #category : #accessing }
KedamaMorph >> drawRequest [

	changePending ifFalse: [self changed].
	changePending := true.

]

{ #category : #drawing }
KedamaMorph >> drawTurtlesOnForm: aForm [

	turtlesToDisplay do: [:exampler |
		(self isVisible: exampler) ifTrue: [
			turtlesDictSemaphore critical: [
				exampler turtles drawOn: aForm.
			] ifLocked: []
		].
	].

]

{ #category : #'as yet unclassified' }
KedamaMorph >> duplicate [

	| allMorphBounds allMorphs allOwners copyW s w |
	allMorphs := {self}, self player allPatchAndTurtleMorphs.
	allOwners := allMorphs collect: #owner.
	allMorphBounds := allMorphs allButFirst
		inject: self bounds into: [:acc :next | next bounds merge: acc].
	w := PasteUpMorph new.
	w bounds: allMorphBounds.
	w openInWorld.
	w addAllMorphs: allMorphs.
	copyW := w duplicate.
	allMorphs withIndexDo: [:m :idx | (allOwners at: idx) ifNotNil: [:o | o addMorph: m]].
	w delete.
	s := SelectionMorph new.
	s bounds: copyW bounds.
	s selectSubmorphsOf: copyW.
	^ s
]

{ #category : #menu }
KedamaMorph >> editDrawing [

	| bnds sketchEditor delBlock myForm mySketch canvas |
	self world assureNotPaintingElse: [^self].
	self world
		prepareToPaint;
		displayWorld.
	bnds := self boundsInWorld.
	sketchEditor := SketchEditorMorph new.
	self comeToFront.
	canvas := Display defaultCanvasClass extent: self fullBounds extent depth: 32.
	canvas fillRectangle: (self bounds) color: self color.
	patchVarDisplayForm fillColor: self color.
	self drawTurtlesOnForm: patchVarDisplayForm.
	pixelsPerPatch = 1
		ifTrue: [canvas drawImage: patchVarDisplayForm at: 0@0]
		ifFalse: [canvas warpImage: patchVarDisplayForm transform: (MatrixTransform2x3 withScale: pixelsPerPatch) at: 0@0].
	myForm := canvas form.
	myForm mapColor: self color to: Color transparent.
	mySketch := SketchMorph withForm: myForm.
	mySketch position: self position.
	self world addMorphFront: sketchEditor.
	sketchEditor 
		initializeFor: mySketch
		inBounds: bnds
		pasteUpMorph: self world.
	delBlock := [self world paintingFlapTab
				ifNotNil: [:pt | pt hideFlap]
				ifNil: [self world paintBox ifNotNil: [:pb | pb delete]]].
	sketchEditor
		afterNewPicDo: [:aForm :aRect |
			aForm offset: aRect topLeft - self topLeft.
			self acceptFormFromDrawing: aForm.
			delBlock value]
		ifNoBits: [delBlock value]
]

{ #category : #geometry }
KedamaMorph >> extent: aPoint [
	"Do nothing; my extent is determined by my StarSqueak world dimensions and pixelsPerPatch."

]

{ #category : #drawing }
KedamaMorph >> fullBounds [

	drawRequested := true.
	^ super fullBounds.

]

{ #category : #utils }
KedamaMorph >> hasNoTurtleBreed [

	^ turtlesDict isEmpty.

]

{ #category : #initialization }
KedamaMorph >> initialize [

	super initialize.
	drawRequested := true.
	changePending := false.
	pixelsPerPatch := (Project current world width min: Project current world height)
						// (self class defaultDimensions x * 2). "heuristic..."
	self dimensions: self class defaultDimensions.  "dimensions of this StarSqueak world in patches"
	super extent: dimensions * pixelsPerPatch.
	self assuredPlayer assureUniClass.
	self clearAll.  "be sure this is done once in case setup fails to do it"
	autoChanged := true.
	self leftEdgeMode: #wrap.
	self rightEdgeMode: #wrap.
	self topEdgeMode: #wrap.
	self bottomEdgeMode: #wrap.

	turtlesDictSemaphore := Semaphore forMutualExclusion.

]

{ #category : #initialization }
KedamaMorph >> initializePatch [

	| f |
	f := self player addPatchVarNamed: #patch.
	patchesToDisplay := Array new: 0.
	self addToPatchDisplayList: f.
	defaultPatch := f.
	f kedamaWorld: self.
	f formChanged.
	^ f.

]

{ #category : #initialization }
KedamaMorph >> initializeTurtlesDict [

	turtlesDict := IdentityDictionary new.
	turtlesToDisplay := Set new.

]

{ #category : #accessing }
KedamaMorph >> isKedamaMorph [
	^true
]

{ #category : #testing }
KedamaMorph >> isSketchMorph [

	| sender |
	sender := thisContext sender.
	(sender method methodClass == HaloMorph
		and: [sender method selector == #addRepaintHandle:])
			ifTrue: [^ true].
	^ super isSketchMorph
]

{ #category : #private }
KedamaMorph >> isVisible: examplerPlayer [

	| turtleMorph |
	turtleMorph := examplerPlayer costume.
	turtleMorph visible ifFalse: [^ false].
	turtleMorph world ifNil: [^ false].
	turtleMorph owner isRenderer ifFalse: [^ true].
	^ turtleMorph owner visible.

]

{ #category : #turtles }
KedamaMorph >> lastWhoOf: exampler [

	| turtles |
	turtles := turtlesDict at: exampler ifAbsent: [nil].
	^ (turtles arrays first) at: turtles arrays first size.

]

{ #category : #accessing }
KedamaMorph >> leftEdgeMode [

	^ leftEdgeMode.

]

{ #category : #accessing }
KedamaMorph >> leftEdgeMode: aSymbol [

	leftEdgeMode := aSymbol asSymbol.
	leftEdgeMode == #wrap ifTrue: [
		leftEdgeModeMnemonic := 1.
		^ self
	].
	leftEdgeMode == #stick ifTrue: [
		leftEdgeModeMnemonic := 2.
		^ self
	].
	(leftEdgeMode == #bounce or: [leftEdgeMode == #bouncing]) ifTrue: [
		leftEdgeModeMnemonic := 3.
		^ self
	].

]

{ #category : #accessing }
KedamaMorph >> leftEdgeModeMnemonic [

	^ leftEdgeModeMnemonic.

]

{ #category : #turtles }
KedamaMorph >> makePrototypeOfExampler: examplerPlayer [

	^ self makePrototypeOfExampler: examplerPlayer color: nil.

]

{ #category : #turtles }
KedamaMorph >> makePrototypeOfExampler: examplerPlayer color: cPixel [

	| array inst info ind |
	array := examplerPlayer turtles.
	info := array info.
	array size > 0 ifTrue: [
		inst := array makePrototypeFromFirstInstance.
		cPixel ifNotNil: [inst at: (info at: #color) put: cPixel].
		^ inst.
	].

	inst := Array new: array instSize.
	info associationsDo: [:assoc |
		ind := assoc value.
		(examplerPlayer turtles types at: ind) = #Boolean ifTrue: [
			ind = 7
				ifTrue: [inst at: ind put: 1]
				ifFalse: [
					inst at: ind put: ((examplerPlayer perform: (assoc key asString asGetterSelector)) ifTrue: [1] ifFalse: [0]).
				]
		] ifFalse: [
			inst at: ind put: (examplerPlayer perform: (assoc key asString asGetterSelector)).
		].
	].
	cPixel ifNotNil: [inst at: (info at: #color) put: cPixel] ifNil: [inst at: (info at: #color) put: ((examplerPlayer getColor pixelValueForDepth: 32) bitAnd: 16rFFFFFF)].
	^ inst.

]

{ #category : #turtles }
KedamaMorph >> makeReplicatedTurtles: count examplerPlayer: tp color: c ofPrototype: prototype randomize: randomizeFlag [

	| array inst |
	array := tp turtles.

	inst := prototype ifNil: [self makePrototypeOfExampler: tp color: c].

	turtlesDictSemaphore critical: [
		array addTurtlesCount: count ofPrototype: inst for: self randomize: randomizeFlag.
	].
	turtleCount := nil.
	self changed.

]

{ #category : #turtles }
KedamaMorph >> makeTurtles: count examplerPlayer: tp color: c ofPrototype: prototype turtles: turtles randomize: randomizeFlag [

	| array inst |
	array := tp turtles.
	(turtlesDict includesKey: tp) ifFalse: [
		self addToTurtleDisplayList: tp.
		turtlesDict at: tp put: (array := turtles).
	].

	inst := prototype ifNil: [self makePrototypeOfExampler: tp color: c].

	turtlesDictSemaphore critical: [array setTurtlesCount: count prototype: inst for: self randomize: randomizeFlag].
	turtleCount := nil.
	self changed.

]

{ #category : #turtles }
KedamaMorph >> makeTurtlesAtPositionsIn: positionAndColorArray examplerPlayer: tp ofPrototype: prototype [

	| array inst |
	array := tp turtles.

	inst := prototype ifNil: [self makePrototypeOfExampler: tp].

	turtlesDictSemaphore critical: [array addTurtlesCount: positionAndColorArray first size ofPrototype: inst for: self positionAndColorArray: positionAndColorArray].
	turtleCount := nil.
	self changed.

]

{ #category : #turtles }
KedamaMorph >> nextTurtleID [

	^ lastTurtleID := lastTurtleID + 1.

]

{ #category : #menu }
KedamaMorph >> offerCostumeViewerMenu: aMenu [
	aMenu add: 'add a new patch variable' translated action: #newPatch.
	aMenu balloonTextForLastItem: 'Add a new patch variable' translated.
	aMenu add: 'add a new breed of turtle' translated action: #newTurtle.
	aMenu balloonTextForLastItem: 'Add a new turtle' translated.
	aMenu addLine.
	aMenu add: 'gather patches and turtles' translated action: #gatherPatchesAndTurtles.
	aMenu balloonTextForLastItem: 'Show all turtles next to me' translated.

]

{ #category : #accessing }
KedamaMorph >> patches [

	^ patchesToDisplay
]

{ #category : #drawing }
KedamaMorph >> patchesToDisplayAsString [

	^ String streamContents: [:strm |
		strm nextPutAll: '#('.
		patchesToDisplay do: [:p |
			strm nextPutAll: p externalName.
			strm nextPut: Character space.
		].
		strm nextPutAll: ')'.
	].

]

{ #category : #accessing }
KedamaMorph >> pixelsPerPatch [

	^ pixelsPerPatch

]

{ #category : #accessing }
KedamaMorph >> pixelsPerPatch: anInteger [
	"Set the width of one patch in pixels. Larger numbers scale up this StarSqueak world, but numbers larger than 2 or 3 result in a blocky look. The useful range is 1 to 10."

	pixelsPerPatch := (anInteger rounded max: 1) min: 10.
	super extent: dimensions * pixelsPerPatch.
	self recreateMagnifiedDisplayForm

]

{ #category : #'private-primitives' }
KedamaMorph >> primSetRandomSeed: seed [

	<primitive: 'kedamaSetRandomSeed' module: 'KedamaPlugin2'>
	^ nil.

]

{ #category : #'private-primitives' }
KedamaMorph >> primZoom: src into: dst srcWidth: sWidth height: sHeight multX: xFactor y: yFactor [

	<primitive: 'zoomBitmap' module: 'KedamaPlugin2'>
	"^ KedamaSqueakPlugin doPrimitive: #zoomBitmap."
	^ nil.

]

{ #category : #utils }
KedamaMorph >> random: range [
	"Answer a random integer between 0 and range."

	| r val |
	<primitive: 'randomRange' module: 'KedamaPlugin2'>
	r := range < 0 ifTrue: [range negated] ifFalse: [range].
	RandomSeed := ((RandomSeed * 1309) + 13849) bitAnd: 65535.
	val := (RandomSeed * (r + 1)) >> 16.
	^ range < 0 ifTrue: [val negated] ifFalse: [^ val].


]

{ #category : #private }
KedamaMorph >> recreateMagnifiedDisplayForm [

	magnifiedDisplayForm := Form extent: self dimensions * pixelsPerPatch depth: 32.
	self changed.

]

{ #category : #drawing }
KedamaMorph >> removeAllFromPatchDisplayList [

	patchesToDisplay := #().

]

{ #category : #drawing }
KedamaMorph >> removeAllFromTurtleDisplayList [

	turtlesToDisplay removeAll

]

{ #category : #turtles }
KedamaMorph >> removeFromTurtleDisplayList: examplerPlayer [

	turtlesToDisplay remove: examplerPlayer ifAbsent: nil

]

{ #category : #accessing }
KedamaMorph >> rightEdgeMode [

	^ rightEdgeMode.

]

{ #category : #accessing }
KedamaMorph >> rightEdgeMode: aSymbol [

	rightEdgeMode := aSymbol asSymbol.
	rightEdgeMode == #wrap ifTrue: [
		rightEdgeModeMnemonic := 1.
		^ self
	].
	rightEdgeMode == #stick ifTrue: [
		rightEdgeModeMnemonic := 2.
		^ self
	].
	(rightEdgeMode == #bounce or: [rightEdgeMode == #bouncing]) ifTrue: [
		rightEdgeModeMnemonic := 3.
		^ self
	].

]

{ #category : #accessing }
KedamaMorph >> rightEdgeModeMnemonic [

	^ rightEdgeModeMnemonic.

]

{ #category : #menu }
KedamaMorph >> setScale [

	| reply |
	reply := FillInTheBlank
		request: 'Set the number of pixels per patch (a number between 1 and 10)?' translated
		 initialAnswer: pixelsPerPatch printString.
	reply isEmpty ifTrue: [^ self].
	self pixelsPerPatch: reply asNumber.

]

{ #category : #turtles }
KedamaMorph >> setTurtlesCount: count examplerPlayer: tp color: cPixel [

	| prototype |
	prototype := self makePrototypeOfExampler: tp color: cPixel.
	turtlesDictSemaphore critical: [(tp turtles) setTurtlesCount: count prototype: prototype for: self randomize: true].
	turtleCount := nil

]

{ #category : #setup }
KedamaMorph >> setup [
	"Subclasses should override this to setup the initial conditions of this StarSqueak world. The method should start with 'self clearAll'."

	self clearAll.

]

{ #category : #accessing }
KedamaMorph >> topEdgeMode [

	^ topEdgeMode.

]

{ #category : #accessing }
KedamaMorph >> topEdgeMode: aSymbol [

	topEdgeMode := aSymbol asSymbol.
	topEdgeMode == #wrap ifTrue: [
		topEdgeModeMnemonic := 1.
		^ self
	].
	topEdgeMode == #stick ifTrue: [
		topEdgeModeMnemonic := 2.
		^ self
	].
	(topEdgeMode == #bounce or: [topEdgeMode == #bouncing])  ifTrue: [
		topEdgeModeMnemonic := 3.
		^ self
	].

]

{ #category : #accessing }
KedamaMorph >> topEdgeModeMnemonic [

	^ topEdgeModeMnemonic.

]

{ #category : #etoys }
KedamaMorph >> turtleCount [

	^turtleCount ifNil: [
		turtleCount := turtlesDict detectSum: [ :each | each size ] ]

]

{ #category : #accessing }
KedamaMorph >> turtles [

	^ turtlesDict keys
]

{ #category : #turtles }
KedamaMorph >> turtlesCountOf: exampler [

	| array |
	array := exampler turtles.
	array ifNil: [^ 0].
	^ array size.

]

{ #category : #drawing }
KedamaMorph >> turtlesToDisplayAsString [

	^ String streamContents: [:strm |
		strm nextPutAll: '#('.
		turtlesToDisplay do: [:p |
			strm nextPutAll: p externalName.
			strm nextPut: Character space.
		].
		strm nextPutAll: ')'.
	].

]

{ #category : #'event handling' }
KedamaMorph >> wantsDroppedMorph: aMorph event: anEvent [

	^ aMorph isMemberOf: SketchMorph.

]

{ #category : #accessing }
KedamaMorph >> wrapX [

	^ wrapX.

]

{ #category : #accessing }
KedamaMorph >> wrapY [

	^ wrapY.

]

{ #category : #private }
KedamaMorph >> zoom: src into: dst factor: f [

	src unhibernate.
	dst unhibernate.
	^ self primZoom: src bits into: dst bits srcWidth: src width height: src height multX: f y: f.

]
