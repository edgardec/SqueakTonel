"
I draw a form to fill whatever bounds I have.
"
Class {
	#name : #StretchyImageMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'form',
		'cache'
	],
	#category : #'Etoys-Experimental'
}

{ #category : #drawing }
StretchyImageMorph >> drawOn: aCanvas [
| t |
"
Smalltalk at: #Q4 put: OrderedCollection new.
"
	form ifNil: [form := (Form extent: 32@32 depth: 8) fillColor: Color green].
	(cache isNil or: [cache extent ~= bounds extent]) ifTrue: [
		t := [cache := Form extent: bounds extent depth: form depth.
		form displayInterpolatedIn: cache boundingBox on: cache.
		cache := cache asFormOfDepth: aCanvas depth] timeToRun.
		"Q4 add: {t. form. cache}."
	].
	aCanvas paintImage: cache at: bounds origin.

]

{ #category : #'as yet unclassified' }
StretchyImageMorph >> form: aForm [

	form := aForm
]

{ #category : #initialization }
StretchyImageMorph >> initialize [

	super initialize.
	self hResizing: #spaceFill.
	self vResizing: #spaceFill.

]
