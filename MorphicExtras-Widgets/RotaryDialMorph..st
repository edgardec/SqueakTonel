"
RotaryDialMorph is the beginnings of a suite of morphs to display values in a round dial manner. Things like pressure, speed, time, voltage etc are al well absorbed from a rotary display.

Instance Variables
	dialCenter:		<Point> - usuall the centre of the dial but consider VU meters where the pivot is pretty much at an edge.
	needleMorph:		<TransformationMorph> - wrapped around the morphs that make up the value indicating needle. This might a simple rectanglemorph, a composite like an ArrowMorph, an ImageMorph , whatever.
	startAngle:		<Number> - the start & stop angles are given in degrees from vertical up; although this causes much fun in working out the geometry it is much easier to think of a barometer going from -150 to +150 than  -4.1887902047863905 to  1.0471975511965976 radians. The stopAngle needs to be further clockwise than the startAngle. 
	startValue:		<Number> - the start & stopValues tell us what input data we must handle. It is possible to have the stopValue smaller than the startValue and effectively have the needle move backwards. This can be useful for dial where the pivot is at the top and the needle waggles around at the bottom.
	stopAngle:		<Number>
	stopValue:		<Number>

"
Class {
	#name : #RotaryDialMorph,
	#superclass : #Morph,
	#instVars : [
		'startAngle',
		'stopAngle',
		'startValue',
		'stopValue',
		'needleMorph',
		'needleRotationCenter',
		'dialCenter',
		'currentValue'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #examples }
RotaryDialMorph >> allaroundometer [
	"set up as an all-round type display like a clock or compass"
	"RotaryDialMorph new allaroundometer openInWorld"
	| pointerMorph |
	self startAngle: 0 stopAngle: 360;
		startValue: 0 stopValue: 1.
	self extent: 200@200;
		color: Color transparent.
	dialCenter := self center.
	self addMorph: (CircleMorph new extent: self extent).
	pointerMorph := LineMorph from: 0@0 to: 0@ (self height // 2) color: Color red width: 2.
 	pointerMorph bottomRight: 0@0.
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.
	self inputValue: 0.25

	
]

{ #category : #examples }
RotaryDialMorph >> backwardsometer [
	"set up as a backwards type display, ie +1 to left, -1 to right"
	"RotaryDialMorph new backwardsometer openInWorld"
	| pointerMorph |
	self startAngle: -90 stopAngle: 90;
		startValue: 1 stopValue: -1.
	self extent: 200@200;
		color: Color transparent.
	dialCenter := self center.

	self addMorph: (CircleMorph new extent: self extent).
	pointerMorph := LineMorph from: 0@0 to: 0@ (self height // 2) color: Color red width: 2.
 	pointerMorph bottomRight: 0@0.
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.
	self inputValue: 0


	
]

{ #category : #examples }
RotaryDialMorph >> backwardsupsidedownometer [
	"set up as upsidedown backwards type display, ie -1 to left, 1 to right"
	"RotaryDialMorph new backwardsupsidedownometer openInWorld"
	| pointerMorph |
	self startAngle: 110 stopAngle: -110;
		startValue: -1 stopValue: 1.
	self extent: 200@200;
		color: Color transparent.
	dialCenter := self center.

	self addMorph: (CircleMorph new extent: self extent).
	pointerMorph := LineMorph from: 0@0 to: 0@ (self height // 2) color: Color blue width: 2.
 	pointerMorph bottomRight: 0@0.
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.
	self inputValue: 0

	
]

{ #category : #'needle graphics' }
RotaryDialMorph >> basicNeedleOfLength: nLength width: nWidth color: aColor [
	"make a really trivial needle as a colored rectangle"
	^RectangleMorph new extent: nWidth @ nLength; color: aColor; borderWidth: 1
]

{ #category : #examples }
RotaryDialMorph >> basicometer [
	"set up as a forwards type display, ie 1 to left, +1 to right"
	"RotaryDialMorph new basicometer openInWorld"
	| pointerMorph |
	self startAngle: -90 stopAngle: 90;
		startValue: -1 stopValue: 1.
	self extent: 200@200;
		color: Color transparent.
	dialCenter := self center.

	self addMorph: (CircleMorph new extent: self extent).
	pointerMorph := LineMorph from: 0@0 to: 0@ (self height // 2) color: Color red width: 2.
 	pointerMorph bottomRight: 0@0.
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.
	self inputValue: 0


	
]

{ #category : #'dial drawing' }
RotaryDialMorph >> buildDial [
	"attempt a plausible default dial"
	|outerRadius destForm canvas tickLabel tickLength beginAngle endAngle tickAngle tickLabelSize maxTicks |
	outerRadius := self height  - 1.
	destForm := Form extent: self extent * 2 depth: 32.
	(canvas := destForm getCanvas) fillOval: (0@0 extent: self extent * 2) color: Color white.
	"outer ring"
	self drawArcAt: destForm center radius: outerRadius thickness: 1 color: Color black beginAngle: 0 endAngle: 360 onForm: destForm.
	
	beginAngle := startAngle -360. "needs cleaning up about this"
	endAngle := stopAngle.
	
	self drawArcAt: destForm center radius: outerRadius * 0.8 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	self drawArcAt: destForm center radius: outerRadius * 0.73 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	"Since this is a wild-guess default we'll try having 1 tick per integer value"
	maxTicks := stopValue - startValue.
	tickAngle := endAngle - beginAngle / maxTicks.
		tickLength := outerRadius * 0.07.
	startValue to: stopValue do: [:tick|
		tickLabel := nil.
		tickLabel := tick asString.
		tickLabelSize := 24.
		self drawTickRadius: outerRadius * 0.73 length: tickLength thickness: 2 color: Color black angle:  beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
		"self tickLabel1."
		self tickLabel: tickLabel fontSize: tickLabelSize color: Color black centeredAt: dialCenter radius: (outerRadius * 0.73) + tickLength angle: beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
	].

	self addMorph: (destForm magnify: destForm boundingBox by: 0.5 smoothing: 2) asMorph
]

{ #category : #examples }
RotaryDialMorph >> colorfulBasicometer [
	"set up as a forwards type display, ie 1 to left, +1 to right"
	"RotaryDialMorph new colorfulBasicometer openInWorld"
	| pointerMorph textM |
	self startAngle: -120 stopAngle: 120;
		startValue: -1 stopValue: 1.
	self extent: 300@300;
		color: GradientFillStyle sample.
	dialCenter := self center.

	self addMorph: (textM := TextMorph fancyPrototype).
	textM extent: 250@30; contents: 'Wild colored RotaryDial HippieLand!'; fontName: 'Darkmap DejuVu Sans' size: 22.
	textM align: textM topCenter with:  self topCenter.
	pointerMorph := CurveMorph new vertices: {0@0. -10@ -50. 10@ -100} color: Color yellow borderWidth: 5 borderColor: Color blue.
	pointerMorph makeOpen; makeForwardArrow..
 	pointerMorph bottomRight: 0@0.
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.
	self inputValue: 0


	
]

{ #category : #'dial drawing' }
RotaryDialMorph >> drawArcAt: arcCenter radius: arcRadius thickness: arcThickness color: arcColor beginAngle: beginAngle endAngle: endAngle onForm: dest [
"angles clockwise from North in degrees; the endAngle must be clockwise of beginAngle.
To make life more fun we then convert to anti-clockwise-from-east radians for the geometry."

	| angle lw2 stop step newPt c diff form rho cell endRho |
   
	form := Form extent: dest extent depth: 32.
	lw2 := arcThickness * 0.5.
	angle :=  (90 - endAngle) degreesToRadians.
	stop := (90 - beginAngle) degreesToRadians min: angle + Float twoPi.
	step := 0.9 / arcRadius.
	[
		rho := arcRadius - lw2 - 0.5.
		endRho := arcRadius + lw2 + 0.5.
		[rho <= endRho] whileTrue: [
			cell := (rho * angle cos) rounded  @ (rho * angle sin) rounded negated.
			newPt := arcCenter + cell.
			diff := (cell r - arcRadius) abs.
			c := diff <= lw2 ifTrue: [arcColor] ifFalse: [arcColor alpha: 1.0 - (diff - lw2)].
			form colorAt: newPt put: c.
			rho := rho + 0.5.
		].
		(angle := angle + step) <= stop
	] whileTrue.
	dest  getCanvas translucentImage: form at: 0@0.

]

{ #category : #'dial drawing' }
RotaryDialMorph >> drawTickRadius: radius length: length thickness: thickness color: color angle: angle  onCanvas: canvas [
"angles clockwise from North in degrees"

	| newPt cell pts rads |
	rads := (90 -  angle) degreesToRadians.
   	pts := {radius. radius + length + 0.5} collect: [ :rho |
		cell := (rho * rads cos) rounded @ (rho * rads sin) rounded negated.
		newPt := dialCenter * 2 + cell.
	].
	canvas line: pts first to: pts second width: thickness color: color

]

{ #category : #'needle graphics' }
RotaryDialMorph >> fancyNeedleOfLength: aNumber [
	"we can make a fancy-schmancy barometer type needle with a curly arrow and moon-shaped tail and then scale it to a length" 
	^self fancyNeedleOfLength: aNumber color: Color black
]

{ #category : #'needle graphics' }
RotaryDialMorph >> fancyNeedleOfLength: aNumber color: aColor [
	"we can make a fancy-schmancy barometer type needle with a curly arrow and moon-shaped tail and then scale it to a length" 
| fancy smaller |
    
	fancy := Form extent: 100@500 depth: 32.
	fancy fillColor: Color white.
	fancy getCanvas
		fillOval: (5@405 extent: 90@90) color: aColor;
		fillOval: (15@430 extent: 70@70) color: Color white;
		fillRectangle: (20@40 extent: 60@60) color: aColor;
		fillOval: (-348@ -200 extent: 400@400) color: Color white;
		fillOval: (48@ -200 extent: 400@400) color: Color white;
		fillRectangle: (48@10 extent: 4@400) color: aColor.
	fancy replaceColor: Color white withColor: Color transparent.

	smaller := fancy magnify: fancy boundingBox by: (aNumber / fancy boundingBox height) smoothing: 2.
	^smaller asMorph.

]

{ #category : #updating }
RotaryDialMorph >> inputValue: aNumber [ 
	"move the needleMorph to display the value; we clamp it to the range
	[startValue, stopValue]"
	| input newDegrees |
	stopValue > startValue
		ifTrue: [input := aNumber min: stopValue max: startValue]
		ifFalse: [input := aNumber min: startValue max: stopValue].
	currentValue := input.
	newDegrees := currentValue - startValue / (stopValue - startValue) * ((stopAngle - startAngle)\\360) + startAngle.
	needleMorph rotationDegrees: newDegrees \\ 360
]

{ #category : #'needle graphics' }
RotaryDialMorph >> simpleNeedleOfLength: aNumber [

	^self simpleNeedleOfLength: aNumber color: Color black
]

{ #category : #'needle graphics' }
RotaryDialMorph >> simpleNeedleOfLength: aNumber color: aColor [
	"we can make a simpler type needle with a curly arrow and no tail and then scale it to a length" 
| fancy smaller |
    
	fancy := Form extent: 100@500 depth: 32.
	fancy fillColor: Color white.
	fancy getCanvas
		fillRectangle: (20@40 extent: 60@60) color: aColor;
		fillOval: (-348@ -200 extent: 400@400) color: Color white;
		fillOval: (48@ -200 extent: 400@400) color: Color white;
		fillRectangle: (48@10 extent: 4@490) color: aColor.
	fancy replaceColor: Color white withColor: Color transparent.

	smaller := fancy magnify: fancy boundingBox by: (aNumber / fancy boundingBox height) smoothing: 2.
	^smaller asMorph.

]

{ #category : #accessing }
RotaryDialMorph >> startAngle: angle1 stopAngle: angle2 [
	"set the start and stop angles of the dial; we modulo them with 360 to keep things logical"
	startAngle := angle1 \\ 360.
	stopAngle := angle2 \\ 360.
	
	"if the two angles end up the same then we will guess that in fact the user wants a full-rotation rather than nothing. "
	startAngle = stopAngle ifTrue:[
		angle1 < angle2 ifTrue:[stopAngle := (startAngle +359.9) \\360].
		angle2 < angle1 ifTrue:[stopAngle := (startAngle - 359.9) \\360]]
	"if the input angles actually were the same then the user has made a mistake and we can't really solve it. Install a better user?"
]

{ #category : #accessing }
RotaryDialMorph >> startValue: value1 stopValue: value2 [
	"set the start and stop values for the dial readings. Note that they can be backwards to allow the needle to rotate counter clockwise for increasing inputs"
	startValue := value1.
	stopValue := value2
]

{ #category : #'dial drawing' }
RotaryDialMorph >> tickInnerLabel: aString fontSize: fSize color: aColor centeredAt: aPoint radius: radius angle: angle onCanvas: canvas [
	"draw the label string centered on the point radius from the centre point, at the angle. Long strings will almost certainly cause problems"
	| cell font pos rads rho stringExtent f rot |
	aString ifNil: [^self].
	font := TextStyle default fontOfSize: fSize.
	"draw the string and rotate it; we flip the angle to keep the letters kinda-sorta the right way up to read easily"
	stringExtent := (StringMorph contents: aString font: font ) imageForm boundingBox extent.
	f := Form extent: stringExtent depth: 32.
	f getCanvas  drawString: aString in: (0@0 extent: stringExtent) font: font color: aColor.
	(angle \\ 360 between: 90.5 and: 269.5) ifTrue:[
		rot := angle - 180] ifFalse: [
		rot := angle ].
	f := f rotateBy: rot smoothing: 2.
	
	"the radius is reduced by a bit more than half the string height to fit it reasonably neatly inside the radius"
	rho := radius - (stringExtent y /1.7).
	rads := (90 - angle) degreesToRadians.
	cell := (rho * rads cos) rounded @ (rho * rads sin) rounded negated.
	pos := aPoint * 2 + cell - (f extent // 2).
	canvas translucentImage: f at: pos
]

{ #category : #'dial drawing' }
RotaryDialMorph >> tickLabel: aString fontSize: fSize color: aColor centeredAt: aPoint radius: radius angle: angle onCanvas: canvas [
	"draw the label string unrotated outside the radius centered on the centre point. We try to get the center of the string bounds on the relevant point but it may look odd for certain strings"
	| cell font pos rads rho stringExtent |
	aString ifNil: [^self].
	
	font := TextStyle default fontOfSize: fSize.
	stringExtent := (StringMorph contents: aString font: font ) imageForm boundingBox extent.
	rho := radius + (stringExtent r /2).
	rads := (90 - angle) degreesToRadians.
	cell := (rho * rads cos) rounded @ (rho * rads sin) rounded negated.
	pos := aPoint * 2 + cell - (stringExtent // 2).
	canvas drawString: aString in: (pos extent: stringExtent) font: font color: aColor
]

{ #category : #examples }
RotaryDialMorph >> upsidedownometer [
	"set up as a forwards but upside-down type display, ie 1 to left, +1 to right"
	"RotaryDialMorph new upsidedownometer openInWorld"
	| pointerMorph |
	self startAngle: 100 stopAngle: -100;
		startValue: -1 stopValue: 1.
	self extent: 200@200;
		color: Color transparent.
	dialCenter := self center.

	self addMorph: (CircleMorph new extent: self extent).
	pointerMorph := LineMorph from: 0@0 to: 0@ (self height // 2) color: Color red width: 2.
 	pointerMorph bottomRight: 0@0.
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.
	self inputValue: 0


	
]

{ #category : #examples }
RotaryDialMorph >> vumeter [
	"set up as a VU meter type display"
	"RotaryDialMorph new vumeter openInWorld"
	| pointerMorph |
	self startAngle: 35 stopAngle: 145;
			startValue: -10 stopValue: 10.
	self extent: 100@200.
	dialCenter := -60@100.
	pointerMorph := RectangleMorph new extent: 4@150; color: Color black; bottomRight: 0@0.
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.
	self addMorph: (CircleMorph new extent:  200@200; center: dialCenter).
	self inputValue: 0.
	self color: Color white; borderWidth: 3; borderColor: Color black; clipSubmorphs: true
	
	
]
