"
A MixedCurveMorph is Curve that can be broken up into separately curved segments. It allows for the creation of matching edges( e. g. for jigsaw puzzle pieces).

Instance Variables
	slopeClamps:		<Array>

slopeClamps
	- elements of array are either 0 or nil. Indicating whether slope for the corresponding vertex is 0@0 or unknown and therefore to be calculated. There is one element for each vertex.
	
	

"
Class {
	#name : #MixedCurveMorph,
	#superclass : #PolygonMorph,
	#instVars : [
		'slopeClamps'
	],
	#category : #'Morphic-Basic-NewCurve'
}

{ #category : #'parts bin' }
MixedCurveMorph class >> descriptionForPartsBin [
	^ self partName:	'Mixed'
		categories:		#('Graphics' 'Basic')
		documentation:	'A Curve with optional bends and segments. Shift click to get handles.
			Click handles to change bends. Move handles to move the points.'
]

{ #category : #access }
MixedCurveMorph >> clamps [
" Return a collection of clamps the same size as vertices.
	If necessary default to unclamped slopes.
"

slopeClamps 
	ifNil:   [ ^ slopeClamps := Array new: vertices size  ] .
slopeClamps size = vertices size
	ifFalse: [ ^ slopeClamps := Array new: vertices size  ] . 
	^ slopeClamps           
]

{ #category : #editing }
MixedCurveMorph >> clickVertex: ix event: evt fromHandle: handle [
" Toggle the state of the clamp. "
"Note: self clamps assures slopeClamps will be same size as vertices"

(self clamps at: ix) 
	ifNil:	 [ slopeClamps  at: ix put: 0 ]
	ifNotNil: [ slopeClamps  at: ix put: nil ] .
	self setVertices: vertices .
	

]

{ #category : #editing }
MixedCurveMorph >> deleteVertexAt: anIndex [
			(slopeClamps :=
						slopeClamps
						copyReplaceFrom: anIndex
						to: anIndex
						with: Array new) .
			self
				setVertices: (vertices
						copyReplaceFrom: anIndex
						to: anIndex
						with: Array new).
						
]

{ #category : #access }
MixedCurveMorph >> handleColorAt: vertIndex [
      " clamped handles are cyan     and 
	unclamped handles are yellow."

(self clamps at: vertIndex ) ifNil: [ ^ Color yellow ] .
^ Color cyan 

]

{ #category : #initialization }
MixedCurveMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
	self extent: 32@20 .

	self rectOval.
	self clamps . "This initializes slopeClamps."
	slopeClamps at: 1 put: 0 .
	slopeClamps at: 4 put: 0 .
	
	closed := true.
	smoothCurve := true.
	arrows := #none.
	self computeBounds
]

{ #category : #editing }
MixedCurveMorph >> insertVertexAt: anIndex put: aValue [
	"New vertexs are unclamped."
	"Note: order is important. 
	The clamps array must match vertex size before setVertices: is performed."
	slopeClamps := slopeClamps 
		copyReplaceFrom: anIndex + 1 to: anIndex with: (Array with: nil).
	self setVertices: (vertices copyReplaceFrom: anIndex + 1 to: anIndex 
									with: (Array with: aValue)).
]

{ #category : #smoothing }
MixedCurveMorph >> slopes: knots [ 
	"Choose slopes according to state of polygon and preferences"
	self isCurvy
		ifFalse: [^ knots segmentedSlopes].
	^ (closed
			and: [self isCurvier])
		ifTrue: [ knots closedCubicSlopes: self clamps ]
		ifFalse: [knots naturalCubicSlopes: self clamps ]
]
