Class {
	#name : #WireMorph,
	#superclass : #PolygonMorph,
	#instVars : [
		'pins'
	],
	#classVars : [
		'InputPinForm',
		'IoPinForm',
		'OutputPinForm'
	],
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #'new-morph participation' }
WireMorph class >> includeInNewMorphMenu [
	^ false
]

{ #category : #editing }
WireMorph >> addHandles [
	super addHandles.
	"Don't show endpoint handles"
	handles first delete.
	handles last delete
]

{ #category : #'submorphs-add\/remove' }
WireMorph >> delete [
	pins do: [:p | p removeWire: self].
	pins first isIsolated 
		ifTrue: [pins first removeVariableAccess.
				pins second isIsolated
					ifTrue: [pins second removeModelVariable]]
		ifFalse: [pins second isIsolated
					ifTrue: [pins second removeVariableAccess]
					ifFalse: [pins second addModelVariable]].
	super delete
]

{ #category : #'as yet unclassified' }
WireMorph >> fromPin: pin1 toPin: pin2 [
	pins := Array with: pin1 with: pin2
]

{ #category : #'event handling' }
WireMorph >> handlesMouseDown: evt [
	^ evt buttons noMask: 16r78  "ie no modifier keys pressed"
]

{ #category : #'event handling' }
WireMorph >> mouseUp: evt [ 
	handles isNil ifTrue: [self addHandles] ifFalse: [self removeHandles]
]

{ #category : #'as yet unclassified' }
WireMorph >> otherPinFrom: aPin [ 
	^ pins first = aPin ifTrue: [pins second] ifFalse: [pins first]
]

{ #category : #'as yet unclassified' }
WireMorph >> pinMoved [
	| newVerts |
	newVerts := vertices copy.
	newVerts at: 1 put: pins first wiringEndPoint.
	newVerts at: newVerts size put: pins last wiringEndPoint.
	self setVertices: newVerts
]
