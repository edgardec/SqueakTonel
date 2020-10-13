"
A Hygrometer measures the relative humidity of the air; a HygrometerDialMorph provides a way to display the value of R.H.
"
Class {
	#name : #HygrometerDialMorph,
	#superclass : #RotaryDialMorph,
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'dial drawing' }
HygrometerDialMorph >> buildDial [
	"start by making a damn big Form, twice the size we want to end up with"
	|outerRadius destForm canvas tickLabel tickLength beginAngle endAngle tickAngle tickLabelSize maxTicks |
	outerRadius := self height  - 1.
	destForm := Form extent: self extent * 2 depth: 32.
	(canvas := destForm getCanvas) fillOval: (0@0 extent: self extent * 2) color: Color white.
	"outer ring"
	self drawArcAt: destForm center radius: outerRadius thickness: 1 color: Color black beginAngle: 0 endAngle: 360 onForm: destForm.
	"inner ring"
	self drawArcAt: destForm center radius: outerRadius * 0.97 thickness: 1 color: Color black beginAngle: 0 endAngle: 360 onForm: destForm.
	
	"just one scale for a hygrometer"
	beginAngle := startAngle -360. "needs cleaning up about this"
	endAngle := stopAngle.
	
	self drawArcAt: destForm center radius: outerRadius * 0.8 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	self drawArcAt: destForm center radius: outerRadius * 0.73 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	"We use a simple % range, just one scale"
	maxTicks := stopValue - startValue .
	tickAngle := endAngle - beginAngle / maxTicks.
	startValue to: stopValue do: [:tick|
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
		self drawTickRadius: outerRadius * 0.73 length: tickLength thickness: 2 color: Color black angle:  beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
		self tickLabel: tickLabel fontSize: tickLabelSize color: Color black centeredAt: dialCenter radius: (outerRadius * 0.73) + tickLength angle: beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
	].

	self tickLabel: '% R.H.'  fontSize: 36 color: Color black centeredAt: dialCenter radius: (outerRadius * 0.53) angle: 180 onCanvas: canvas.
	
	self addMorph: (destForm magnify: destForm boundingBox by: 0.5 smoothing: 2) asMorph
]

{ #category : #'initialize-release' }
HygrometerDialMorph >> initialize [
	"Build a hygrometer. The background is an ImageMorph showing a dial derived from the same general principles as the BarometerMorph. "
	| pointerMorph |
	super initialize.
	
	self startAngle: -140 stopAngle: 140;
		startValue: 0 stopValue: 100.
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
