"
A BookMorph variant whose pages are instances of ZoomAndScrollMorph. I have a control area where the user may pan, tilt and zoom over the image shown in the page.

- drag up and down to zoom in and out
- drag left and right to pan
- shift-drag up and down to tilt.
"
Class {
	#name : #StoryboardBookMorph,
	#superclass : #BookMorph,
	#instVars : [
		'alansSliders',
		'panAndTiltFactor',
		'zoomFactor',
		'zoomController'
	],
	#category : #'MorphicExtras-Books'
}

{ #category : #'parts bin' }
StoryboardBookMorph class >> descriptionForPartsBin [
	^ self partName:	'Storyboard' translatedNoop
		categories:		#()
		documentation:	'A storyboard authoring tool' translatedNoop
]

{ #category : #private }
StoryboardBookMorph >> changeTiltFactor: x [

	currentPage changeTiltFactor: x.
	panAndTiltFactor := x.


]

{ #category : #private }
StoryboardBookMorph >> changeZoomFactor: x [

	currentPage changeZoomFactor: x.
	zoomFactor := x.
]

{ #category : #private }
StoryboardBookMorph >> getTiltFactor [

	^panAndTiltFactor ifNil: [panAndTiltFactor := 0.5].
]

{ #category : #private }
StoryboardBookMorph >> getZoomFactor [

	^zoomFactor ifNil: [zoomFactor := 0.5]
]

{ #category : #initialization }
StoryboardBookMorph >> initialize [

	newPagePrototype := ZoomAndScrollMorph new extent: Display extent // 3.
	zoomController := ZoomAndScrollControllerMorph new
			setBalloonText: 'Drag in here to zoom, tilt and pan the page above'.

	super initialize.

	self addMorphBack: zoomController.

	alansSliders := {
		{#changeTiltFactor: . #getTiltFactor . 'Pan and tilt sensitivity'}.
		{#changeZoomFactor: . #getZoomFactor . 'Zoom sensitivity'}.
	} collect: [ :sData |
		{
			SimpleSliderMorph new
				extent: 150@10;
				color: Color orange;
				sliderColor: Color gray;
				target: self; 
				actionSelector: sData first;
				setBalloonText: sData third;
				adjustToValue: (self perform: sData second).
			sData second
		}
	].
	alansSliders do: [ :each | self addMorphBack: each first]

]

{ #category : #navigation }
StoryboardBookMorph >> insertPageMorphInCorrectSpot: aPageMorph [
	"Insert the page morph at the correct spot"
	
	| place |
	place := submorphs size > 1 ifTrue: [submorphs second] ifFalse: [submorphs first].
	"Old architecture had a tiny spacer morph as the second morph; now architecture does not"
	self addMorph: (currentPage := aPageMorph) behind: place.
	self changeTiltFactor: self getTiltFactor.
	self changeZoomFactor: self getZoomFactor.
	zoomController target: currentPage.


]

{ #category : #accessing }
StoryboardBookMorph >> offsetX [

	^currentPage offsetX
]

{ #category : #accessing }
StoryboardBookMorph >> offsetX: aNumber [

	currentPage offsetX: aNumber
]

{ #category : #accessing }
StoryboardBookMorph >> offsetY [

	^currentPage offsetY
]

{ #category : #accessing }
StoryboardBookMorph >> offsetY: aNumber [

	currentPage offsetY: aNumber
]

{ #category : #accessing }
StoryboardBookMorph >> scale [

	^currentPage scale
]

{ #category : #accessing }
StoryboardBookMorph >> scale: aValue [

	currentPage scale: aValue
]
