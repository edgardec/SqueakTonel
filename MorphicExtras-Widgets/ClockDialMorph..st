"
A ClockDialMorph is a clock implemented as a rotary dial morph. The intersting part of this is having two needles that continuously rotate as opposed to the normal rule of having a single needle limited in range.

Instance Variables
	hourHandMorph:		<Morph, typically wrapped ina a TransformationMorph>
"
Class {
	#name : #ClockDialMorph,
	#superclass : #RotaryDialMorph,
	#instVars : [
		'hourHandMorph'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'dial drawing' }
ClockDialMorph >> buildDial [
	"start by making a damn big Form, twice the size we want to end up with"
	|outerRadius destForm canvas tickLabel tickLength beginAngle endAngle tickAngle maxTicks |
	outerRadius := self height  - 1.
	destForm := Form extent: self extent * 2 depth: 32.
	(canvas := destForm getCanvas) fillOval: (0@0 extent: self extent * 2) color: Color white.
	"outer ring"
	self drawArcAt: destForm center radius: outerRadius thickness: 1 color: Color black beginAngle: 0 endAngle: 360 onForm: destForm.
	"inner ring"
	self drawArcAt: destForm center radius: outerRadius * 0.97 thickness: 1 color: Color black beginAngle: 0 endAngle: 360 onForm: destForm.
	
	"outer scale for degrees"
	beginAngle := startAngle . 
	endAngle := stopAngle.
	
	maxTicks := stopValue - startValue .
	tickAngle := endAngle - beginAngle / maxTicks.
	startValue to: stopValue do: [:tick|
	tickLength := outerRadius * 0.07.
		tickLabel := nil.
		tick \\ 6 = 0 ifTrue:["tick every 6 degrees on the outer ring"
			self drawTickRadius: outerRadius * 0.9 length: tickLength thickness: 2 color: Color black angle:  beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
		].
		tick \\ 30 = 0 ifTrue: ["tick every 30 degrees on the inner ring"
			self drawTickRadius: outerRadius * 0.83 length: tickLength thickness: 2 color: Color black angle:  beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
			(tick \\ 30 = 0 and: [tick < 360]) ifTrue:["numbered ticks every 30 degrees, don't overwrite 0 with 360"
				self tickInnerLabel: (tick // 30)  asString fontSize: 24 color: Color black centeredAt: dialCenter radius: (outerRadius * 0.75) + tickLength angle: beginAngle + (tick - startValue * tickAngle) onCanvas: canvas
				]
		]
	].

	self addMorph: (destForm magnify: destForm boundingBox by: 0.5 smoothing: 2) asMorph
]

{ #category : #initialization }
ClockDialMorph >> initialize [
	"assemble a nice clock morph. The background is an ImageMorph with scale/dial drawn with code adapted from a generous donation of time and effort by Bob Arning; the minute needle is the inherited needleMorph and we added a new hourHandMorph. Both are simple rectangleMorphs"
	| pointerMorph |

	super initialize.

	self startAngle: 0 stopAngle: 360;
			startValue: 0 stopValue: 360.
	self extent: 200@200; color: Color transparent; borderWidth: 0.
	dialCenter := self center.

	"build the dial background; basic clock with miute ticks and hour long-ticks + arabic numerals"
	self buildDial.

	pointerMorph := self basicNeedleOfLength: (self height * 0.45) rounded width: 4 color: Color red.
 	pointerMorph position: pointerMorph extent * ( -0.5@ -1).

	"we keep track of the TransformationMorph since that is what we have to rotate"
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.

	"additional neelde for the hours"
	pointerMorph := self basicNeedleOfLength: (self height * 0.35) rounded width: 6 color: Color black.
 	pointerMorph position: pointerMorph extent * ( -0.5@ -1).

	"we keep track of the TransformationMorph since that is what we have to rotate"
	hourHandMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: hourHandMorph.
		
	"add a central colored dot. Because we just do."
	self addMorph: (CircleMorph new extent: 8@8; color: Color red twiceDarker; center: dialCenter)
	
]

{ #category : #updating }
ClockDialMorph >> setTime: aTime [

	needleMorph rotationDegrees: aTime minutes * 6 + (aTime seconds / 10).
	hourHandMorph rotationDegrees: (aTime hours * 30) + (aTime minutes / 2)
]

{ #category : #'stepping and presenter' }
ClockDialMorph >> step [
	self setTime: Time now
]

{ #category : #'stepping and presenter' }
ClockDialMorph >> stepTime [
	^5000
]
