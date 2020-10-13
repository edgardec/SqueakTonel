Class {
	#name : #SelectedObjectThumbnail,
	#superclass : #ImageMorph,
	#instVars : [
		'noSelectedThumbnail',
		'noSelectedBalloonText'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'instance creation' }
SelectedObjectThumbnail class >> extent: aPoint noSelectedThumbnail: aForm noSelectedBalloonText: aString [ 
	^ self new
		initializeExtent: aPoint
		noSelectedThumbnail: aForm
		noSelectedBalloonText: aString 
]

{ #category : #initialization }
SelectedObjectThumbnail >> initialize [
	"Initialize the receiver"
	super initialize.
	""
	self
		image: (Form extent:32@32).
	self color: Color transparent
]

{ #category : #initialization }
SelectedObjectThumbnail >> initializeExtent: aPoint noSelectedThumbnail: aForm noSelectedBalloonText: aString [ 
	self
		image: (Form extent: aPoint).
""
	noSelectedThumbnail := aForm.
	noSelectedBalloonText := aString
]

{ #category : #private }
SelectedObjectThumbnail >> makeEmptyThumbnail [

^ self makeThumbnailOfColor: Color veryLightGray.

]

{ #category : #private }
SelectedObjectThumbnail >> makeErrorThumbnail [
	^ self makeThumbnailOfColor: Color red
]

{ #category : #private }
SelectedObjectThumbnail >> makeThumbnailFrom: aMorphOrNil [ 
	| thumbnail |
	thumbnail := aMorphOrNil isNil
				ifTrue: [noSelectedThumbnail
						ifNil: [self makeEmptyThumbnail]]
				ifFalse: [aMorphOrNil iconOrThumbnail]. 
	""
	self
		image: (thumbnail scaledIntoFormOfSize: self extent)
]

{ #category : #private }
SelectedObjectThumbnail >> makeThumbnailOfColor: aColor [ 
	| form |
	form := Form extent: self extent depth: 32.
	form getCanvas fillColor: aColor.
	self image: form
]

{ #category : #accessing }
SelectedObjectThumbnail >> noSelectedBalloonText: aString [ 
	"Set the balloon text to be used when no object is selected"
	noSelectedBalloonText := aString
]

{ #category : #accessing }
SelectedObjectThumbnail >> noSelectedThumbnail: aForm [ 
	"Set the form to be used when no object is selected"
	noSelectedThumbnail := aForm
]

{ #category : #'stepping and presenter' }
SelectedObjectThumbnail >> step [
	| current |
	current := self selectedObject.

	self setBalloonText: (current isNil
				ifTrue: [noSelectedBalloonText]
				ifFalse: [current externalName]).
	""
	self makeThumbnailFrom: current
]

{ #category : #'stepping and presenter' }
SelectedObjectThumbnail >> stepTime [
	^ 125
]
