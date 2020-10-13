"
A ThermometerDialMorph is a rotary thermometer; the default is to set the range to typical outdoor temperatures but of course that can be altered with the normal #startValue:stopValue: message
"
Class {
	#name : #ThermometerDialMorph,
	#superclass : #RotaryDialMorph,
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'dial drawing' }
ThermometerDialMorph >> buildDial [
	"start by making a damn big Form, twice the size we want to end up with"
	|outerRadius destForm canvas tickLabel tickLength beginAngle endAngle tickAngle tickLabelSize maxTicks |
	outerRadius := self height  - 1.
	destForm := Form extent: self extent * 2 depth: 32.
	(canvas := destForm getCanvas) fillOval: (0@0 extent: self extent * 2) color: Color white.
	"outer ring"
	self drawArcAt: destForm center radius: outerRadius thickness: 1 color: Color black beginAngle: 0 endAngle: 360 onForm: destForm.
	"inner ring"
	self drawArcAt: destForm center radius: outerRadius * 0.97 thickness: 1 color: Color black beginAngle: 0 endAngle: 360 onForm: destForm.
	
	"outer scale for Fahrenheit"
	beginAngle := startAngle -360. "needs cleaning up about this"
	endAngle := stopAngle.
	
	self drawArcAt: destForm center radius: outerRadius * 0.8 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	self drawArcAt: destForm center radius: outerRadius * 0.73 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.

	maxTicks := stopValue - startValue  / 5 * 9 .
	tickAngle := endAngle - beginAngle / maxTicks.
	(startValue / 5 * 9 +32) to: (stopValue / 5 * 9 +32) do: [:tick|
	tickLength := outerRadius * 0.07.
		tickLabel := nil.
		tick \\ 10 = 0 ifTrue: [
			tickLabel := tick asString.
			tickLabelSize := 24
		] ifFalse: [
			tick \\ 2 = 0 ifTrue:[
				tickLabel := (tick \\ 10) asString.
				tickLabelSize := 18
			] ifFalse: [
				tickLength := tickLength * 2
			]
		].
		self drawTickRadius: outerRadius * 0.73 length: tickLength thickness: 2 color: Color black angle:  beginAngle + (tick - (startValue / 5 * 9 +32) * tickAngle) onCanvas: canvas.
		self tickLabel: tickLabel fontSize: tickLabelSize color: Color black centeredAt: dialCenter radius: (outerRadius * 0.73) + tickLength angle: beginAngle + (tick - (startValue / 5 * 9 +32) * tickAngle) onCanvas: canvas.
	].

	self tickInnerLabel: (String with: (Unicode value: 16rB0) with: $C) fontSize: 36 color: Color black centeredAt: dialCenter radius: (outerRadius * 0.73) angle: 180 onCanvas: canvas.
	
	"inner scale for Celsius"
	beginAngle := startAngle -360. "needs cleaning up about this"
	endAngle := stopAngle.
	
	self drawArcAt: destForm center radius: outerRadius * 0.71 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	self drawArcAt: destForm center radius: outerRadius * 0.63 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	maxTicks := stopValue - startValue.
	tickAngle := endAngle - beginAngle / maxTicks.
	tickLength := outerRadius * 0.07.
	startValue to: stopValue do: [ :tick ||tickThickness|
		tickLabel := nil.
		tick \\ 5 = 0 ifTrue: [
			tickLabelSize := 20.
			tickThickness := 3.
			tickLabel :=  tick asString.
		] ifFalse: [
			tickThickness := 2.
		].
		self drawTickRadius: outerRadius * 0.63 length: tickLength thickness: tickThickness color: Color black angle:  beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
		self tickInnerLabel: tickLabel fontSize: tickLabelSize color: Color black centeredAt: dialCenter radius: (outerRadius * 0.63) angle: beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.

	].

	self tickLabel: (String with: (Unicode value: 16rB0) with: $F)  fontSize: 36 color: Color black centeredAt: dialCenter radius: (outerRadius * 0.73) angle: 180 onCanvas: canvas.
	
	self addMorph: (destForm magnify: destForm boundingBox by: 0.5 smoothing: 2) asMorph
]

{ #category : #'initialize-release' }
ThermometerDialMorph >> initialize [
	"Build a thermometer. The background is an ImageMorph showing a dial derived from the same general principles as the BarometerMorph. 
	The temperature scale is fixed for now at -5C to 30C but ought to be parameterised someday. We'll have the Celcius scale as the inner and a conversion to Fahrenheit as the outer"
	| pointerMorph |
	super initialize.
	
	self startAngle: -140 stopAngle: 140;
		startValue: -10 stopValue: 35.
	self extent: 200@200; color: Color transparent; borderWidth: 0.
	dialCenter := self center.
	
	self buildDial.

	"build our fancy needle as an ImageMorph, set the position to horizontal centre and about 2/3 down so that it rotates about that point when inside the TransformationMorph"
	pointerMorph := self fancyNeedleOfLength: (self height * 0.65) rounded.
 	pointerMorph position: pointerMorph extent * ( -0.5@ -0.65).

	"we keep track of the TransformationMorph since that is what we have to rotate as the incoming pressure values change"
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.

	"add a central colored dot. Because we just do."
	self addMorph: (CircleMorph new extent: 20@20; color: Color black; center: dialCenter)

]
