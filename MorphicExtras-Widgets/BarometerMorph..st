"
I am a model of a moderately visually ornate barometer, complete with curly tailed needle and the adjustable 'last pressure' needle used to help display the recent changes in pressure. In this case a d-click makes the 'last pressure' needle move to the current pressure position.


"
Class {
	#name : #BarometerMorph,
	#superclass : #RotaryDialMorph,
	#instVars : [
		'priorPressureIndicator'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'dial drawing' }
BarometerMorph >> buildDial [
	"start by making a damn big Form, twice the size we want to end up with"
	|outerRadius destForm canvas tickLabel tickLength beginAngle endAngle tickAngle tickLabelSize maxTicks |
	outerRadius := self height  - 1.
	destForm := Form extent: self extent * 2 depth: 32.
	(canvas := destForm getCanvas) fillOval: (0@0 extent: self extent * 2) color: Color white.
	"outer ring"
	self drawArcAt: destForm center radius: outerRadius thickness: 1 color: Color black beginAngle: 0 endAngle: 360 onForm: destForm.
	"inner ring"
	self drawArcAt: destForm center radius: outerRadius * 0.97 thickness: 1 color: Color black beginAngle: 0 endAngle: 360 onForm: destForm.
	
	"outer scale for inches of HG"
	beginAngle := startAngle -360. "needs cleaning up about this"
	endAngle := stopAngle.
	
	self drawArcAt: destForm center radius: outerRadius * 0.8 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	self drawArcAt: destForm center radius: outerRadius * 0.73 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	"since we're going from 28in. to 31in. of Hg for the outer scale and want alternating full and half ticks as we go round we need 31-28 * 10 * 2 -> 60 ticks"
	maxTicks := 31 - 28 * 10 * 2.
	tickAngle := endAngle - beginAngle / maxTicks.
	0 to: maxTicks do: [:tick|
		tickLabel := nil.
		tickLength := {outerRadius * 0.07. outerRadius * 0.14} atWrap: tick+1.
		tick \\ 20 = 0 ifTrue: [
			tickLabel := #( '28' '29' '30' '31') at: tick // 20 + 1.
			tickLabelSize := 24.
		] ifFalse: [
			tick \\ 2 = 0 ifTrue: [
				tickLabel :=  (tick // 2 \\ 10) asString.
				tickLabelSize := 18.
			].
		].
		self drawTickRadius: outerRadius * 0.73 length: tickLength thickness: 2 color: Color black angle:  beginAngle + (tick * tickAngle) onCanvas: canvas.
		self tickLabel: tickLabel fontSize: tickLabelSize color: Color black centeredAt: dialCenter radius: (outerRadius * 0.73) + tickLength angle: beginAngle + (tick * tickAngle) onCanvas: canvas.
	].

	self tickInnerLabel: 'mB' fontSize: 36 color: Color black centeredAt: dialCenter radius: (outerRadius * 0.73) angle: 180 onCanvas: canvas.

	"inner scale for mB"
	beginAngle := startAngle -360. "needs cleaning up about this"
	endAngle := stopAngle.
	
	self drawArcAt: destForm center radius: outerRadius * 0.71 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	self drawArcAt: destForm center radius: outerRadius * 0.63 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	"since we're going from 948mB to 1050 for this inner scale and want thick ticks at each 10mB interval with narrow ones elsewhere we have (1050 - 948) total ticks "
	maxTicks := stopValue - startValue.
	tickAngle := endAngle - beginAngle / maxTicks.
	tickLength := outerRadius * 0.07.
	startValue to: stopValue do: [ :tick ||tickThickness|
		tickLabel := nil.
		tick \\ 10 = 0 ifTrue: [
			tickLabelSize := 20.
			tickThickness := 3.
			tickLabel :=  tick asString.
		] ifFalse: [
			tickThickness := 2.
		].
		self drawTickRadius: outerRadius * 0.63 length: tickLength thickness: tickThickness color: Color black angle:  beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
		self tickInnerLabel: tickLabel fontSize: tickLabelSize color: Color black centeredAt: dialCenter radius: (outerRadius * 0.63) angle: beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
		tickLabel := nil.
		tick = 970 ifTrue:[tickLabel := 'Rain'].
		tick = 1000 ifTrue:[tickLabel := 'Change'].
		tick = 1030 ifTrue:[tickLabel := 'Fair'].
		self tickInnerLabel: tickLabel fontSize: 24 color: Color black centeredAt: dialCenter radius: (outerRadius * 0.5) angle: beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
		
	].
	self tickLabel: '"Hg'  fontSize: 36 color: Color black centeredAt: dialCenter radius: (outerRadius * 0.73) angle: 180 onCanvas: canvas.
	
	self addMorph: (destForm magnify: destForm boundingBox by: 0.5 smoothing: 2) asMorph
]

{ #category : #'initialize-release' }
BarometerMorph >> doubleClick: evt [
	"the user has just tapped on the glass of the barometer, so move the priorPressureIndicator to match the current value"
	priorPressureIndicator rotationDegrees: needleMorph rotationDegrees
]

{ #category : #'initialize-release' }
BarometerMorph >> handlesMouseDown: evt [
	^true
]

{ #category : #'initialize-release' }
BarometerMorph >> initialize [
	"assemble a nice barometer morph. The background is an ImageMorph with scale/dial drawn with code adapted from a generous donation of time and effort by Bob Arning; similarly for the needle"
	| pointerMorph |

	super initialize.
	"set up as a barometer type display; running clockwise with increasing values.
	A decent range for a barometer is 950mB to 1050mB; it covers most plausible weather and matches decently with an additional inches-of-Hg scale going from 28 to 31.
	28in. -> 948mB and 31in. -> 1050 (to enough accuracy for a screen based widget) so we need a small tweak at the lower end of the dial. If we aim initially for 150deg each side of north we have 3deg per milliBar; to accomodate the extra 2mB we can add 6deg at the low end, which makes 1000mB sit nicely at due north.
	So we will use angles of -156 to 150 and values of 948 to 1050 as our limits."

	self startAngle: -156 stopAngle: 150;
			startValue: 948 stopValue: 1050.
	self extent: 200@200; color: Color transparent; borderWidth: 0.
	dialCenter := self center.

	"build the dial background. This is amazingly complex to think about programmatically; this example is fairly hard-coded by hand but somebody out there almost certainly has ideas about parameterizing this to amke a nice general utility"
	self buildDial.

	"build our fancy needle as an ImageMorph, set the position to horizontal centre and about 2/3 down so that it rotates about that point when inside the TransformationMorph"
	pointerMorph := self fancyNeedleOfLength: (self height * 0.65) rounded.
 	pointerMorph position: pointerMorph extent * ( -0.5@ -0.65).

	"we keep track of the TransformationMorph since that is what we have to rotate as the incoming pressure values change"
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.
	
	"Add the simpler needle used to indicate the prior 'remembered' reading; we will make a click update it to the current value"
	pointerMorph := self simpleNeedleOfLength: (self height * 0.35) rounded color: (Color r: 16rFF g: 16rD7 b: 16r0 range: 512).
 	pointerMorph position: pointerMorph extent * ( -0.5@ -1).
	priorPressureIndicator :=  TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: priorPressureIndicator.
	
	"add a central near-to-gold colored dot. Because we just do."
	self addMorph: (CircleMorph new extent: 20@20; color: (Color r: 16rFF g: 16rD7 b: 16r0 range: 256); center: dialCenter)
	
]

{ #category : #'event handling' }
BarometerMorph >> mouseDown: evt [ 
	"Do nothing upon mouse-down except inform the hand to watch for a  
	double-click; wait until an ensuing click:, doubleClick:, or drag:  
	message gets dispatched"
	evt hand
		waitForClicksOrDrag: self
		event: evt
		selectors: #( #click: #doubleClick: #doubleClickTimeout: #startDrag:)
		threshold: HandMorph dragThreshold
]
