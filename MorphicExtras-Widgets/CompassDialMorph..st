"
A CompassDialMorph shows a navigation compass. Unusually for most dials it has a full 360 degree span.
"
Class {
	#name : #CompassDialMorph,
	#superclass : #RotaryDialMorph,
	#category : #'MorphicExtras-Widgets'
}

{ #category : #'needle graphics' }
CompassDialMorph >> basicNeedleOfLength: nLength width: nWidth color: aColor [
	"make a really trivial needle as a colored rhombus"
	| fancy |
    
	fancy := Form extent: nWidth@nLength depth: 32.
	fancy fillColor: Color transparent.
	fancy getCanvas asBalloonCanvas
		aaLevel: 4;
		drawPolygon: (Array with: (nWidth/ 2)@0 with: (nWidth)@( nLength / 2)  with:0@(nLength / 2) with: (nWidth/ 2)@0) fillStyle: aColor borderWidth: 1 borderColor: Color black;
		drawPolygon: (Array with: (nWidth)@( nLength / 2) with: (nWidth/ 2)@(nLength) with:0@(nLength / 2)  with: (nWidth)@( nLength / 2)) fillStyle: Color black borderWidth: 0 borderColor: Color black.

	^fancy asMorph.

]

{ #category : #'dial drawing' }
CompassDialMorph >> buildDial [
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
	
	self drawArcAt: destForm center radius: outerRadius * 0.9 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	self drawArcAt: destForm center radius: outerRadius * 0.83 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	self drawArcAt: destForm center radius: outerRadius * 0.55 thickness: 1 color: Color black beginAngle:beginAngle endAngle: stopAngle onForm: destForm.
	"We use a simple % range, just one scale"
	maxTicks := stopValue - startValue .
	tickAngle := endAngle - beginAngle / maxTicks.
	startValue to: stopValue do: [:tick|
	tickLength := outerRadius * 0.07.
		tickLabel := nil.
		tick \\ 2 = 0 ifTrue:["tick every 2 degrees on the outer ring"
			self drawTickRadius: outerRadius * 0.9 length: tickLength thickness: 2 color: Color black angle:  beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
		].
		tick \\ 10 = 0 ifTrue: ["tick every 10 degrees on the inner ring"
			self drawTickRadius: outerRadius * 0.83 length: tickLength thickness: 2 color: Color black angle:  beginAngle + (tick - startValue * tickAngle) onCanvas: canvas.
			(tick \\ 30 = 0 and: [tick < 360]) ifTrue:["numbered ticks every 30 degrees, don't overwrite 0 with 360"
				self tickInnerLabel: tick asString fontSize: 24 color: Color black centeredAt: dialCenter radius: (outerRadius * 0.75) + tickLength angle: beginAngle + (tick - startValue * tickAngle) onCanvas: canvas
			]
		].
		(tick \\ 90 = 0 and: [tick < 360]) ifTrue:["Major cardianl at the full points"
			tickLabel := { 'N'. 'E'. 'S'. 'W'. nil.} atWrap: tick // 90 +1.
			self tickInnerLabel: tickLabel fontSize: 36 color: Color black centeredAt: dialCenter radius: (outerRadius * 0.65) + tickLength angle: beginAngle + (tick - startValue * tickAngle) onCanvas: canvas
		].
		(tick \\ 90 = 45 and: [tick < 360]) ifTrue:["minor cardinal at the half-points"
			tickLabel := { 'NE'. 'SE'. 'SW'. 'NW'. nil.} atWrap: tick // 90 +1.
			self tickInnerLabel: tickLabel fontSize: 30 color: Color black centeredAt: dialCenter radius: (outerRadius * 0.48) + tickLength angle: beginAngle + (tick - startValue * tickAngle) onCanvas: canvas
		]		
	].

	self addMorph: (destForm magnify: destForm boundingBox by: 0.5 smoothing: 2) asMorph
]

{ #category : #'initialize-release' }
CompassDialMorph >> initialize [
	"assemble a nice compass morph. The background is an ImageMorph with scale/dial drawn with code adapted from a generous donation of time and effort by Bob Arning; similarly for the needle"
	| pointerMorph |

	super initialize.
	"A compass runs from 0 deg to 360, clockwise. Traditional compass roses can be very ornate."

	self startAngle: 0 stopAngle: 360;
			startValue: 0 stopValue: 360.
	self extent: 200@200; color: Color transparent; borderWidth: 0.
	dialCenter := self center.

	"build the dial background. This is amazingly complex to think about programmatically; this example is fairly hard-coded by hand but somebody out there almost certainly has ideas about parameterizing this to amke a nice general utility"
	self buildDial.

	"build our fancy needle as an ImageMorph, set the position to horizontal centre and about 2/3 down so that it rotates about that point when inside the TransformationMorph"
	pointerMorph := self basicNeedleOfLength: (self height * 0.65) rounded width: 10 color: Color red.
 	pointerMorph position: pointerMorph extent * ( -0.5@ -0.5).

	"we keep track of the TransformationMorph since that is what we have to rotate as the incoming pressure values change"
	needleMorph := TransformationMorph new position: dialCenter; addMorph: pointerMorph.
	self addMorph: needleMorph.
		
	"add a central colored dot. Because we just do."
	self addMorph: (CircleMorph new extent: 20@20; color: Color red twiceDarker; center: dialCenter)
	
]
