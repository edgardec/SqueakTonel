"
This is really only a shell for creating single-segment straight-line Shapes.
"
Class {
	#name : #LineMorph,
	#superclass : #PolygonMorph,
	#category : #'Morphic-Basic'
}

{ #category : #'parts bin' }
LineMorph class >> descriptionForPartsBin [
	"Answer a description for the parts bin."

	^ self partName:	'Line' translatedNoop
		categories:		{'Graphics' translatedNoop}
		documentation:	'A straight line.  Shift-click to get handles and move the ends.' translatedNoop
]

{ #category : #'instance creation' }
LineMorph class >> from: startPoint to: endPoint color: lineColor width: lineWidth [

	^ PolygonMorph vertices: {startPoint. endPoint}
			color: Color black borderWidth: lineWidth borderColor: lineColor
]

{ #category : #'instance creation' }
LineMorph class >> new [
	^ self from: 0@0 to: 50@50 color: Color black width: 2
]

{ #category : #'new-morph participation' }
LineMorph class >> newStandAlone [
	"Answer a suitable instance for use in a parts bin, for example"

	^ self new setNameTo: 'Line'
]
