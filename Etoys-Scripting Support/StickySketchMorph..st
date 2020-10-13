Class {
	#name : #StickySketchMorph,
	#superclass : #SketchMorph,
	#category : #'Etoys-Scripting Support'
}

{ #category : #'e-toy support' }
StickySketchMorph >> isStickySketchMorph [
	^true
]

{ #category : #'e-toy support' }
StickySketchMorph >> mustBeBackmost [
	^ true
]

{ #category : #thumbnail }
StickySketchMorph >> permitsThumbnailing [
	^ false
]

{ #category : #'halos and balloon help' }
StickySketchMorph >> wantsHalo [
	^ false
]
