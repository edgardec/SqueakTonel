"
A CanvasCharacterScanner is displaying characters onto a Morphic canvas.

Instance Variables
	canvas:		<Canvas>

canvas
	- the canvas on which characters are displayed


"
Class {
	#name : #CanvasCharacterScanner,
	#superclass : #DisplayScanner,
	#instVars : [
		'canvas'
	],
	#category : #'MorphicExtras-Support'
}

{ #category : #accessing }
CanvasCharacterScanner >> canvas: aCanvas [
	"set the canvas to draw on"
	canvas ifNotNil: [ self inform: 'initializing twice!' ].
	canvas := aCanvas
]

{ #category : #'object fileIn' }
CanvasCharacterScanner >> convertToCurrentVersion: varDict refStream: smartRefStrm [

	"From Squeak3.5 [latest update: #5180] on 17 June 2003"
	varDict  at: 'defaultTextColor' put: Color black.
	^ super convertToCurrentVersion: varDict refStream: smartRefStrm
]

{ #category : #displaying }
CanvasCharacterScanner >> displayEmbeddedForm: aForm [
	canvas
		drawImage: aForm
		at: destX @ (lineY + line baseline - aForm height)
]

{ #category : #displaying }
CanvasCharacterScanner >> displayString: string from: startIndex  to: stopIndex at: aPoint [
	canvas 
		drawString: string
		from: startIndex
		to: stopIndex
		at: aPoint
		font: font
		color: foregroundColor.
]

{ #category : #displaying }
CanvasCharacterScanner >> fillTextBackground [
	"do nothing"
]
