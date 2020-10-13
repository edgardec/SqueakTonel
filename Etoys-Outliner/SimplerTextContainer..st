Class {
	#name : #SimplerTextContainer,
	#superclass : #TextContainer,
	#category : #'Etoys-Outliner'
}

{ #category : #'container protocol' }
SimplerTextContainer >> bottom [

	^textMorph owner bottom
]

{ #category : #'container protocol' }
SimplerTextContainer >> left [ 
	^ textMorph owner textMorphLeft
]

{ #category : #'container protocol' }
SimplerTextContainer >> rectanglesAt: lineY height: lineHeight [
	"Return a list of rectangles that are at least minWidth wide
	in the specified horizontal strip of the shadowForm.
	Cache the results for later retrieval if the owner does not change."
	| rects |

	lineY > textMorph owner bottom ifTrue: [^#()].
	rects := Array with: (self left@lineY extent: textMorph width@lineHeight).
	"rects := rects collect: [:r | r insetBy: OuterMargin@0]."
	^ rects
]

{ #category : #'container protocol' }
SimplerTextContainer >> top [

	^textMorph owner top
]
