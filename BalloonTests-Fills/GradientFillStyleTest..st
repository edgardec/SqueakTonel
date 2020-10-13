"
This tests the LRUCache operation.
"
Class {
	#name : #GradientFillStyleTest,
	#superclass : #ClassTestCase,
	#category : #'BalloonTests-Fills'
}

{ #category : #tests }
GradientFillStyleTest >> testLRUCacheHits [

	| gradient greenWhiteRamp redWhiteRamp |
	
	"This test proves the bug fix where modifing the LRUCache key resulted in false 
	cache hits. The affect was that a gradient could not be modifed from the user interface."
	
	GradientFillStyle cleanUp.
	gradient := GradientFillStyle new colorRamp: {0.0->Color red. 1.0->Color white}. 
	redWhiteRamp := gradient pixelRamp. 
      
	"Change the first color in colorRamp"
      gradient firstColor: Color green forMorph: nil hand: nil. 
	greenWhiteRamp := gradient pixelRamp.

	"Ensure the pixelRamp has changed"
        self assert: (redWhiteRamp ~= greenWhiteRamp).
]
