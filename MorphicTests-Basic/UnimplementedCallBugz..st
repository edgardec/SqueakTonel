Class {
	#name : #UnimplementedCallBugz,
	#superclass : #TestCase,
	#category : #'MorphicTests-Basic'
}

{ #category : #tests }
UnimplementedCallBugz >> testPolyIntersect [
	"self run: #testPolyIntersect"
	"This should not throw an exception."
	PolygonMorph initializedInstance 
		intersects: ( Rectangle
			center: Display center 
			extent: 100 asPoint ).
]
