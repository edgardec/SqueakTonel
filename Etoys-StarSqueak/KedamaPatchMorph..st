"
I represent the patch variable.

"
Class {
	#name : #KedamaPatchMorph,
	#superclass : #Morph,
	#instVars : [
		'form',
		'displayMax',
		'shiftAmount',
		'useLogDisplay',
		'displayForm',
		'diffusionRate',
		'scaledEvaporationRate',
		'sniffRange',
		'formChanged',
		'tmpForm',
		'autoChanged',
		'displayType',
		'changePending',
		'kedamaWorld'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #scripting }
KedamaPatchMorph class >> additionsToViewerCategories [
	"Answer a list of (<categoryName> <list of category specs>) pairs that characterize the phrases this kind of morph wishes to add to various Viewer categories."

	^ #(

	(kedama (
		(slot evaporationRate 'The rate for the decay function.' Number readWrite Patch getEvaporationRate Patch setEvaporationRate:)
		(slot diffusionRate 'The rate for the diffusion function.' Number readWrite Patch getDiffusionRate Patch setDiffusionRate:)
		(slot sniffRange 'The distance to sample the values for calculating highest gradient.' Number readWrite Patch getSniffRange Patch setSniffRange:)
		(slot shiftAmount 'shift amount when log-based color conversion is not used' Number readWrite Player getDisplayShiftAmount Player setDisplayShiftAmount:)
		(slot scaleMax 'scale when log-based color conversion is used' Number readWrite Player getDisplayScaleMax Player setDisplayScaleMax:)
		"(slot useLogDisplay 'log-based color conversion' Boolean readWrite Player getUseLogDisplay Player setUseLogDisplay:)"
		(slot displayType 'how to map the value in cells to color' PatchDisplayMode readWrite Player getDisplayType Player setDisplayType:)
		(slot color 'The color of the object' Color readWrite Player getColor  Player  setColor:)

		"(slot autoUpdate 'Updating screen always' Boolean readWrite Player getAutoUpdate  Player setAutoUpdate:)"
		(command clear 'clear all patch')
		(command diffusePatchVariable 'diffuse')
		(command decayPatchVariable 'decay')

		(command redComponentInto: 'split red component into another patch' Patch)
		(command greenComponentInto: 'split green component into another patch' Patch)
		(command blueComponentInto: 'split blue component into another patch' Patch)

		(command redComponentFrom: 'merge red component from another patch' Patch)
		(command greenComponentFrom: 'merge green component from another patch' Patch)
		(command blueComponentFrom: 'merge blue component from another patch' Patch)

)))

]

{ #category : #accessing }
KedamaPatchMorph class >> classVersion [

	^ 1.

]

{ #category : #scripting }
KedamaPatchMorph class >> defaultNameStemForInstances [

	^ 'patch' translatedNoop

]

{ #category : #'class initialization' }
KedamaPatchMorph class >> initialize [
"
	self initialize
"
	Smalltalk addToStartUpList: self.
	self startUp.

]

{ #category : #'instance creation' }
KedamaPatchMorph class >> newExtent: aPoint [

	| inst |
	inst := self new.
	inst newExtent: aPoint.
	^ inst.

]

{ #category : #'class initialization' }
KedamaPatchMorph class >> startUp [
"
	self startUp
"
	self allInstancesDo: [:e | e startUp].

]

{ #category : #'class initialization' }
KedamaPatchMorph class >> startUp: aBoolean [
"
	self startUp
"

	self startUp.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> autoChanged [

	^ autoChanged.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> autoChanged: aBoolean [

	autoChanged := aBoolean.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> basicPixelAtX: xPos y: yPos [

	| x y i |
	x := xPos truncated.
	y := yPos truncated.
	((x < 0) or: [y < 0]) ifTrue: [^ 0].
	((x >= form width) or: [y >= form height]) ifTrue: [^ 0].
	i := ((y * form width) + x) + 1.
	form bits class == ByteArray ifTrue: [form unhibernate].
	^ form bits at: i.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> basicPixelAtX: xPos y: yPos put: value [

	| x y i v |
	x := xPos truncated.
	y := yPos truncated.
	v := value asInteger min: 16rFFFFFFFF max: 0.
	((x < 0) or: [y < 0]) ifTrue: [^ self].
	((x >= form width) or: [y >= form height]) ifTrue: [^ self].
	i := ((y * form width) + x) + 1.
	form bits class == ByteArray ifTrue: [form unhibernate].
	form bits at: i put: v.
	self formChanged.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> basicUphillForTurtleX: tX turtleY: tY turtleHeading: tH [
	"Answer the heading the points in the direction of increasing value for the given patch variable. If there is no gradient, or if the turtle is outside the world bounds, answer the turtles current heading."

	| turtleX turtleY startX endX startY endY maxVal rowOffset thisVal maxValX maxValY |
	turtleX := tX truncated.
	turtleY := tY truncated.
	turtleX := turtleX max: 0.
	turtleY := turtleY max: 0.
	turtleX := turtleX min: form width - 1.
	turtleY := turtleY min: form height - 1.
	startX := turtleX - sniffRange max: 0.
	endX := (turtleX + sniffRange) min: (form width - 1).
	startY := (turtleY - sniffRange) max: 0.
	endY := (turtleY + sniffRange) min: (form height - 1).
	"form bits class == Bitmap ifFalse: [form unhibernate]."
	maxVal := form bits at: turtleY * form width + turtleX + 1.
	maxValX := nil.
	startY to: endY
		do: 
			[:y | 
			rowOffset := y * form width.
			startX to: endX
				do: 
					[:x | 
					thisVal := form bits at: rowOffset + x + 1.
					thisVal > maxVal 
						ifTrue: 
							[maxValX := x.
							maxValY := y.
							maxVal := thisVal]]].
	nil = maxValX ifTrue: [^ (90.0 - tH radiansToDegrees) \\ 360.0].
	^ (((maxValX - turtleX) @ (maxValY - turtleY)) degrees + 90.0) \\ 360.0

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> blueComponentFrom: another [

	| pix anotherPix |
	0 to: self height - 1 do: [:y |
		0 to: self width -1 do: [:x |
			pix := self pixelAtX: x y: y.
			anotherPix := (another pixelAtX: x y: y) bitAnd: 16rFF.
			pix := (pix bitAnd: 16rFFFF00) bitOr: (anotherPix).
			self pixelAtX: x y: y put: pix.
		].
	].

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> blueComponentInto: another [

	0 to: self height - 1 do: [:y |
		0 to: self width -1 do: [:x |
			another pixelAtX: x y: y put: ((self pixelAtX: x y: y) bitAnd: 16rFF).
		].
	].

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> clear [

	form fillColor: Color transparent.
	self formChanged.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> color: aColor [

	super color: aColor.
	self formChanged.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> colorAtX: xPos y: yPos [

	^ Color colorFromPixelValue: (self pixelAtX: xPos y: yPos) depth: 32.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> colorAtX: xPos y: yPos put: aColor [

	| pixel |
	pixel := aColor pixelValueForDepth: 32.
	self pixelAtX: xPos y: yPos put: pixel.
	self formChanged.

]

{ #category : #private }
KedamaPatchMorph >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	varDict at: 'useLogDisplay' ifPresent: [ :x | 
		displayType := x = true ifTrue: [#logScale] ifFalse: [#linear].
	].
	displayType ifNil: [displayType := #logScale].
	self migrateInstancesWithoutChangePending.
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> diffuse [

	| dim newV |
	dim := form extent.
	form bits class == ByteArray ifTrue: [form unhibernate].
	newV := Bitmap new: form bits size.
	self primDiffuseFrom: form bits
		to: newV
		width: dim x
		height: dim y
		delta: diffusionRate truncated.
	form bits: newV.
	self formChanged.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> diffusionRate [

	^ diffusionRate.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> diffusionRate: newRate [
	"Set the diffusion rate to an integer between 0 and 10. The diffusion rate gives the number of patches on one size of the area averaged to compute the next value of the variable for a given patch. Larger numbers cause faster diffusion. Zero means no diffusion."

	diffusionRate := (newRate rounded max: 0) min: 10.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> displayMax [

	^ displayMax at: 1.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> displayMax: anInteger [

	displayMax := WordArray with: (anInteger asInteger min: 16rFFFFFFFF max: 0).
	self formChanged.

]

{ #category : #drawing }
KedamaPatchMorph >> displayPatchVariableOn: aForm [

	| patchVar pixelValue |
	form ifNil: [^self].

	formChanged ifTrue: [
		"displayForm fillColor: Color transparent."
		pixelValue := (self color pixelValueForDepth: 32) bitAnd: 16rFFFFFF.
		form bits class == ByteArray ifTrue: [form unhibernate].
		patchVar := form bits.
		displayForm bits class == ByteArray ifTrue: [displayForm unhibernate].
		displayType = #linear ifTrue: [
			self primMakeMaskOf: patchVar in: displayForm bits colorPixel: pixelValue shift: shiftAmount.
		].
		displayType = #logScale ifTrue: [
			self primMakeMaskOf: patchVar in: displayForm bits colorPixel: pixelValue max: displayMax.
		].
		displayType = #color ifTrue: [
			form displayOn: displayForm.
			displayForm fixAlpha.
		].
	].

	tmpForm fillColor: Color black.
	displayForm displayOn: tmpForm at: 0@0 rule: 24.
	aForm == tmpForm ifFalse: [
		displayForm displayOn: aForm at: 0@0 rule: 24.
	].
	formChanged := false.


]

{ #category : #'commands and slots' }
KedamaPatchMorph >> displayShiftAmount [

	^ shiftAmount.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> displayShiftAmount: anInteger [

	shiftAmount := anInteger min: 8 max: -32.
	self formChanged.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> displayType [

	^ displayType.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> displayType: aSymbol [

	displayType := aSymbol asSymbol.
	self formChanged.

]

{ #category : #drawing }
KedamaPatchMorph >> drawOn: aCanvas [

	formChanged ifTrue: [
		self displayPatchVariableOn: tmpForm.
	].
	aCanvas drawImage: tmpForm at: self innerBounds origin.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> evaporate [

	form bits class == ByteArray ifTrue: [form unhibernate].
	self primEvaporate: form bits rate: scaledEvaporationRate.
	self formChanged.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> evaporationRate [

	^ 1024 - scaledEvaporationRate.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> evaporationRate: newRate [
	"Set the evaporation rate. The useful range is 0 to 25 or so. Larger numbers cause faster evaporation. Zero means no evaporization."

	scaledEvaporationRate := ((1024 - newRate truncated) max: 1) min: 1024.

]

{ #category : #drawing }
KedamaPatchMorph >> formChanged [

	formChanged := true.
	kedamaWorld drawRequest.
	self drawRequest.

]

{ #category : #drawing }
KedamaPatchMorph >> fullBounds [

	formChanged := true.
	^ super fullBounds.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> greenComponentFrom: another [

	| pix anotherPix |
	0 to: self height - 1 do: [:y |
		0 to: self width -1 do: [:x |
			pix := self pixelAtX: x y: y.
			anotherPix := (another pixelAtX: x y: y) bitAnd: 16rFF.
			pix := (pix bitAnd: 16rFF00FF) bitOr: (anotherPix bitShift: 8).
			self pixelAtX: x y: y put: pix.
		].
	].

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> greenComponentInto: another [

	0 to: self height - 1 do: [:y |
		0 to: self width -1 do: [:x |
			another pixelAtX: x y: y put: (((self pixelAtX: x y: y) bitShift: -8) bitAnd: 16rFF).
		].
	].

]

{ #category : #initialization }
KedamaPatchMorph >> initialize [

	super initialize.

	changePending := false.
	formChanged := true.
	self evaporationRate: 6.
	self diffusionRate: 1.
	self sniffRange: 1.

	displayType := #logScale.
	displayMax := WordArray with: 1024.
	shiftAmount := -2.

]

{ #category : #initialization }
KedamaPatchMorph >> initializeForm: aForm [ 

	changePending := false.
	form := aForm. 
	form fillColor: Color transparent.

	displayForm := (Form extent: aForm extent depth: 32).
	tmpForm := (Form extent: aForm extent depth: 32).
	tmpForm fillColor: Color black.

	super extent: form extent.
	self changed.

]

{ #category : #initialization }
KedamaPatchMorph >> newExtent: aPoint [

	self initializeForm: (Form extent: aPoint depth: 32).

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> pixelAtX: xPos y: yPos [

	| x y i |
	x := xPos truncated.
	y := yPos truncated.
	((x < 0) or: [y < 0]) ifTrue: [^ 0].
	((x >= form width) or: [y >= form height]) ifTrue: [^ 0].
	i := ((y * form width) + x) + 1.
	form bits class == ByteArray ifTrue: [form unhibernate].
	^ form bits at: i.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> pixelAtX: xPos y: yPos put: value [

	| x y i v |
	x := xPos truncated.
	y := yPos truncated.
	v := (value asInteger max: 0).
	((x < 0) or: [y < 0]) ifTrue: [^ self].
	((x >= form width) or: [y >= form height]) ifTrue: [^ self].
	i := ((y * form width) + x) + 1.
	form bits class == ByteArray ifTrue: [form unhibernate].
	form bits at: i put: v.
	self formChanged.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> pixelsAtXArray: xArray yArray: yArray into: aWordArray [

	form bits class == ByteArray ifTrue: [form unhibernate].
	self primPixelsAtXArray: xArray yArray: yArray bits: form bits width: form width height: form height into: aWordArray.

]

{ #category : #primitives }
KedamaPatchMorph >> primDiffuseFrom: srcBitmap to: dstBitmap width: width height: height delta: delta [ 
	"Diffuse the integer values of the source patch variable Bitmap into the output Bitmap. Each cell of the output is the average of the NxN area around it in the source, where N = (2 * delta) + 1."

	| area startY endY startX endX sum rowStart |
	<primitive: 'primitiveDiffuseFromToWidthHeightDelta' module: 'StarSqueakPlugin'>
	area := (2 * delta + 1) * (2 * delta + 1).
	1 to: height
		do: 
			[:y | 
			startY := y - delta.
			startY := startY max: 1.
			endY := y + delta.
			endY := endY min: height.
			1 to: width
				do: 
					[:x | 
					startX := x - delta.
					startX := startX max: 1.
					endX := x + delta.
					endX := endX min: width.
					sum := 0.
					startY to: endY
						do: 
							[:y2 | 
							rowStart := (y2 - 1) * width.
							startX to: endX do: [:x2 | sum := sum + (srcBitmap at: rowStart + x2)]].
					dstBitmap at: (y - 1) * width + x put: sum // area]]
]

{ #category : #primitives }
KedamaPatchMorph >> primEvaporate: aBitmap rate: rate [
	"Evaporate the integer values of the source Bitmap at the given rate, an integer between 0 and 1024, where 1024 is a scale factor of 1.0 (i.e., no evaporation). That is, replace each integer element v with (rate * v) / 1024."

	<primitive: 'primitiveEvaporateRate' module: 'StarSqueakPlugin'>
	1 to: aBitmap size do: [:i |
		aBitmap at: i put: (((aBitmap at: i) * rate) bitShift: -10)].

]

{ #category : #primitives }
KedamaPatchMorph >> primMakeMaskOf: dataBits in: maskBits colorPixel: pixel max: max [

	| highMask alpha maxLog data |
	<primitive: 'makeMaskLog' module: 'KedamaPlugin2'>
	"^ KedamaSqueakPlugin doPrimitive: #makeMaskLog."


	highMask := 16rFF000000.
	"maxLog := self cCode: 'log(max)' inSmalltalk: [max first ln]."
	maxLog := max first ln.
	maxLog := 255.0 / maxLog.

	1 to: dataBits size do: [:i |
		data := dataBits at: i.
		data = 0 ifTrue: [alpha := 0] ifFalse: [
			"alpha := ((255.0 / maxLog) * (self cCode: 'log(data)' inSmalltalk: [data ln])) asInteger."
			alpha := (maxLog * (data ln)) asInteger.

		].
		(alpha > 255) ifTrue: [alpha := 255].
		maskBits at: i put: (((alpha << 24) bitAnd: highMask) bitOr: pixel).
	].
	^ self.

]

{ #category : #primitives }
KedamaPatchMorph >> primMakeMaskOf: dataBits in: maskBits colorPixel: pixel shift: shift [

	| highMask data alpha |
	<primitive: 'makeMask' module: 'KedamaPlugin2'>
	"^ KedamaSqueakPlugin doPrimitive: #makeMask."

	highMask := 16rFF000000.
	1 to: dataBits size do: [:i |
		data := dataBits at: i.
		alpha := data bitShift: shift.
		(alpha > 255) ifTrue: [alpha := 255].
		maskBits at: i put: (((alpha << 24) bitAnd: highMask) bitOr: pixel).
	].

	^ self.

]

{ #category : #primitives }
KedamaPatchMorph >> primPixelsAtXArray: xArray yArray: yArray bits: bits width: width height: height into: aWordArray [
	| x y formIndex val |
	<primitive: 'primPixelsAtXY' module: 'KedamaPlugin2'>
	"^ KedamaPlugin doPrimitive: #primPixelsAtXY."
	1 to: aWordArray size do: [:i |
		val := nil.
		x := (xArray at: i) truncated.
		y := (yArray at: i) truncated.
		((x < 0) or: [y < 0]) ifTrue: [val := 0].
		((x >= form width) or: [y >= form height]) ifTrue: [val := 0].
		val ifNil: [
			formIndex := ((y * form width) + x) + 1.
			val := bits at: formIndex.
		].
		aWordArray at: i put: val.
	].

]

{ #category : #primitives }
KedamaPatchMorph >> primSetPixelsAtXArray: xArray yArray: yArray bits: bits width: width height: height value: value [

	| v |
	<primitive: 'primSetPixelsAtXY' module: 'KedamaPlugin'>
	"^ KedamaPlugin doPrimitive: #primSetPixelsAtXY."

	value isNumber ifTrue: [v := value].
	1 to: xArray size do: [:i |
		value isNumber ifFalse: [
			v := value at: i.
		].		
		self pixelAtX: (xArray at: i) y: (yArray at: i) put: v.
	].

]

{ #category : #primitives }
KedamaPatchMorph >> primUpHillX: tX y: tY heading: tH bits: bits width: width height: height sniffRange: s [

	<primitive: 'primUpHill' module: 'KedamaPlugin2'>
	"^ KedamaPlugin doPrimitive: #primUpHill."
	^ nil

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> redComponentFrom: another [

	| pix anotherPix |
	0 to: self height - 1 do: [:y |
		0 to: self width -1 do: [:x |
			pix := self pixelAtX: x y: y.
			anotherPix := (another pixelAtX: x y: y) bitAnd: 16rFF.
			pix := (pix bitAnd: 16r00FFFF) bitOr: (anotherPix bitShift: 16).
			self pixelAtX: x y: y put: pix.
		].
	].

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> redComponentInto: another [

	0 to: self height - 1 do: [:y |
		0 to: self width -1 do: [:x |
			another pixelAtX: x y: y put: (((self pixelAtX: x y: y) bitShift: -16) bitAnd: 16rFF).
		].
	].

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> setPixelsAtXArray: xArray yArray: yArray value: value [

	form bits class == ByteArray ifTrue: [form unhibernate].
	self primSetPixelsAtXArray: xArray yArray: yArray bits: form bits width: form width height: form height value: value.
	self formChanged.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> sniffRange [

	^ sniffRange.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> sniffRange: aNumber [

	sniffRange := aNumber.

]

{ #category : #initialization }
KedamaPatchMorph >> startUp [

	form unhibernate.
	displayForm unhibernate.
	tmpForm unhibernate.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> uphillForTurtleX: tX turtleY: tY turtleHeading: tH [
	"Answer the heading the points in the direction of increasing value for the given patch variable. If there is no gradient, or if the turtle is outside the world bounds, answer the turtles current heading."

	| ret |
	form bits class == ByteArray ifTrue: [form unhibernate].
	ret := self primUpHillX: tX y: tY heading: tH bits: form bits width: form width height: form height sniffRange: sniffRange.
	ret ifNotNil: [^ ret].
	^ self basicUphillForTurtleX: tX turtleY: tY turtleHeading: tH.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> useLogDisplay [

	^ displayType == #logScale.

]

{ #category : #'commands and slots' }
KedamaPatchMorph >> useLogDisplay: aBoolean [

	displayType := aBoolean ifTrue: [#logScale] ifFalse: [#linear].
	self formChanged.

]

{ #category : #copying }
KedamaPatchMorph >> veryDeepFixupWith: deepCopier [

	super veryDeepFixupWith: deepCopier.
	kedamaWorld := deepCopier references at: kedamaWorld ifAbsent: [kedamaWorld].
]

{ #category : #copying }
KedamaPatchMorph >> veryDeepInner: deepCopier [
	"the state of a Kedama patch is held in its forms, so we need to "
	form := form deepCopy.
	displayForm := displayForm deepCopy.
	tmpForm := tmpForm deepCopy.
	super veryDeepInner: deepCopier.
]
