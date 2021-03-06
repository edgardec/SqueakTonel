"
I represent a display transformation of a GraphicSymbol. Multiple copies of a GraphicSymbol can be displayed at different positions and scales on the screen by making appropriate, multiple, instances of me.
"
Class {
	#name : #GraphicSymbolInstance,
	#superclass : #Object,
	#instVars : [
		'transformation',
		'graphicSymbol'
	],
	#category : #'ST80-Symbols'
}

{ #category : #examples }
GraphicSymbolInstance class >> example [
	"Simply evaluate the method and two GraphicSymbolInstances, each
	displaying a transformation of the same graphic symbol, will be
	presented on the screen. Clears the screen to white."

	| gate instance1 instance2 trans1 trans2 line arc f|
	Display fillWhite.			"clear the Screen."
	f := Form extent: 2 @ 2.
	f fillBlack.
	gate:= GraphicSymbol new.		"make a logic gate out of lines and arcs."
	line:=Line new.  line beginPoint: -20 @ -20.  line endPoint: 0 @ -20. line form: f.
	gate add: line.

	line:=Line new.  line beginPoint: -20 @ 20.  line endPoint: 0 @ 20. line form: f.
	gate add: line.

	line:=Line new.  line beginPoint: 0 @ -40.  line endPoint: 0 @ 40. line form: f.
	gate add: line.

	arc := Arc new. arc center: 0 @ 0 radius: 40 quadrant: 1.
	arc form: f.
	gate add: arc.

	arc := Arc new. arc center: 0 @ 0 radius: 40 quadrant: 4.
	arc form: f.
	gate add: arc.

			"one instance at 1/2 scale."
	trans1:=WindowingTransformation identity.	
	trans1:= trans1 scaleBy: 0.5 @ 0.5.
	trans1:= trans1 translateBy: 100 @ 100.

			"the other instance at 2 times scale"
	trans2:=WindowingTransformation identity.	
	trans2:= trans2 scaleBy: 2.0 @ 2.0.
	trans2:= trans2 translateBy: 200 @ 200.

	instance1 := GraphicSymbolInstance new.
	instance1 transformation: trans1.
	instance1 graphicSymbol: gate.

	instance2 := GraphicSymbolInstance new.
	instance2 transformation: trans2.
	instance2 graphicSymbol: gate.

			"display both instances of the logic gate"
	instance1 displayOn: Display
					transformation: WindowingTransformation identity
					clippingBox: Display boundingBox
					rule: Form under
					fillColor: nil.
	instance2 displayOn: Display
					transformation: WindowingTransformation identity
					clippingBox: Display boundingBox
					rule: Form under
					fillColor: nil

	"GraphicSymbolInstance example"
]

{ #category : #displaying }
GraphicSymbolInstance >> displayOn: aDisplayMedium transformation: aTransformation clippingBox:
clipRect rule: anInteger fillColor: aForm [ 
	"Display the graphic symbol on the Display according to the arguments 
	of this message."

	graphicSymbol
		displayOn: aDisplayMedium
		transformation: aTransformation 
		clippingBox: clipRect
		rule: anInteger
		fillColor: aForm
]

{ #category : #displaying }
GraphicSymbolInstance >> displayTransformation: aTransformation clippingBox: clipRect rule: anInteger fillColor: aForm [
	"Display the graphic symbol according to the arguments of this message."

	self displayOn: Display transformation: aTransformation clippingBox: clipRect
		rule: anInteger fillColor: aForm
]

{ #category : #accessing }
GraphicSymbolInstance >> graphicSymbol [
	"Answer the graphic symbol that the receiver displays."

	^graphicSymbol
]

{ #category : #accessing }
GraphicSymbolInstance >> graphicSymbol: aGraphicSymbol [ 
	"Set the argument, aGraphicSymbol, to be the graphic symbol that the 
	receiver displays."

	graphicSymbol := aGraphicSymbol
]

{ #category : #transforming }
GraphicSymbolInstance >> transformation [
	"Answer the receiver's display transformation."

	^transformation
]

{ #category : #transforming }
GraphicSymbolInstance >> transformation: aWindowingTransformation [ 
	"Set the argument, aWindowingTransformation, to be the receiver's 
	display transformation."

	transformation := aWindowingTransformation
]
