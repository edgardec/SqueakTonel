Class {
	#name : #FormInspectView,
	#superclass : #FormView,
	#instVars : [
		'offset'
	],
	#category : #'ST80-Views'
}

{ #category : #'instance creation' }
FormInspectView class >> openOn: aFormDictionary withLabel: aLabel [
	"open a graphical dictionary in a window having the label aLabel. 
     aFormDictionary should be a dictionary containing as value a form."

     ^ aFormDictionary inspectWithLabel: aLabel

]

{ #category : #'controller access' }
FormInspectView >> defaultControllerClass [ 
	"Refer to the comment in View|defaultControllerClass."

	^  NoController
]

{ #category : #displaying }
FormInspectView >> displayView [ 
	"Display the form as a value in an inspector.  8/11/96 sw"
	"Defeated form scaling for HS FormInspector.  8/20/96 di"
	| scale |
	Display fill: self insetDisplayBox fillColor: Color white.
	model selectionIndex = 0 ifTrue: [^ self].
	scale := self insetDisplayBox extent / model selection extent.
	scale := (scale x min: scale y) min: 1.
	model selection
		displayOn: Display
		transformation: (WindowingTransformation
			scale: scale asPoint
			translation: self insetDisplayBox topLeft - model selection offset)
		clippingBox: self insetDisplayBox
		rule: self rule
		fillColor: self fillColor
]
