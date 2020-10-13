Class {
	#name : #FormCanvasTest,
	#superclass : #TestCase,
	#instVars : [
		'morph'
	],
	#category : #'MorphicTests-Support'
}

{ #category : #tests }
FormCanvasTest >> testDefaultClipRect [

	self assert: (FormCanvas extent: 222@111) clipRect = (0@0 corner: 222@111).
	self assert: (FormCanvas extent: 2222@11) clipRect = (0@0 corner: 2222@11).
	self assert: (FormCanvas extent: 22222@1) clipRect = (0@0 corner: 22222@1).

]

{ #category : #tests }
FormCanvasTest >> testFrameAndFillDegenerateRoundRect01 [

	| fill canvas smallRect |
	fill := GradientFillStyle sample.
	canvas := FormCanvas extent: 100@100.
	canvas fillColor: Color black.
	smallRect := 0@0 corner: 20@20.
	
	"This should not throw an exception."
	canvas
		frameAndFillRoundRect: smallRect
		radius: smallRect width / 2 + 1
		fillStyle: fill
		borderWidth: 0
		borderColor: Color lightGray.
]

{ #category : #tests }
FormCanvasTest >> testFrameAndFillDegenerateRoundRect02 [

	| fill canvas smallRect |
	fill := GradientFillStyle sample.
	canvas := FormCanvas extent: 100@100.
	canvas fillColor: Color black.
	smallRect := 0@0 corner: 20@20.

	"This should not throw an exception."
	canvas
		frameAndFillRoundRect: smallRect
		radius: 0
		fillStyle: fill
		borderWidth: 0
		borderColor: Color lightGray.
]
