Class {
	#name : #UpdatingStringMorphWithArgument,
	#superclass : #UpdatingStringMorph,
	#instVars : [
		'argumentTarget',
		'argumentGetSelector'
	],
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #'as yet unclassified' }
UpdatingStringMorphWithArgument >> argumentTarget: t argumentGetSelector: s [
	argumentTarget := t.
	argumentGetSelector := s
]

{ #category : #'target access' }
UpdatingStringMorphWithArgument >> readFromTarget [
	| v |
	argumentTarget ifNil: [^ super readFromTarget].
	v := target perform: getSelector with: (argumentTarget perform: argumentGetSelector).
	^ self acceptValueFromTarget: v
]

{ #category : #copying }
UpdatingStringMorphWithArgument >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
argumentTarget := deepCopier references at: argumentTarget 
			ifAbsent: [argumentTarget].

]

{ #category : #copying }
UpdatingStringMorphWithArgument >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"argumentTarget := argumentTarget.		Weakly copied"
argumentGetSelector := argumentGetSelector veryDeepCopyWith: deepCopier.
]
