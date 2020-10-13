"
A ThumbnailImageMorph is variant of Lex Spoon's CDScreenShotMorph. It displays a thumbnail of the image stored in imagePopupMorph. As a super class of PopupThumbnail morph it is meant to be a thumbnail w/o the popup action. Basicly it provides a scalable thumbnail with the usual morph event behaviors.

A menu item allows for ""photographing"" any morph on the screen to become the subject of our images.

Instance Variables
	imagePopupMorph:		<anImageMorph>
	image: 					<aForm>
	desiredExtent			<aPoint>
	isPopup					<aBool>
imagePopupMorph
	- an ImageMorph containing the full sized image.
	- it can be set from a morph image via the sight target menu item.
image
	- holds the scaled thumbnail form of our imagePopupMorph image.
desiredExtent
	- holds the desired extent that the thumbnail is expected to fit within.
	- it is guarded to be positive and non-zero.
	- it can be set by extent: so that the yellow halo handle works.
isPopup
	- true when popup feature is on.
	- toggled from red halo menu
		
Setting the size of the thumbnail works somewhat excentrically because the extent of the thumbnail depends both on the desiredExtent and the aspect ratio of the current popup image.
 
With the popup feature off this morph can be picked up and dropped with the mouse.
When the feature is on, a full sized snapshot will be seen when the mouse is pressed.
Since the mouse can't be used for two things at once, moving the morph must be done with the grab halo or brown move halo.
"
Class {
	#name : #ThumbnailImageMorph,
	#superclass : #ImageMorph,
	#instVars : [
		'imagePopupMorph',
		'desiredExtent',
		'isPopup'
	],
	#category : #'Morphic-Basic'
}

{ #category : #examples }
ThumbnailImageMorph class >> ofDisplay [
"ThumbnailImageMorph ofDisplay openInHand"
^self new initializeWithDisplay .
]

{ #category : #'menu commands' }
ThumbnailImageMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [ 
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	self addWorldTargetSightingItems: aCustomMenu hand: aHandMorph .
	self addPopupMenuItems: aCustomMenu hand: aHandMorph
]

{ #category : #'menu commands' }
ThumbnailImageMorph >> addPopupMenuItems: aCustomMenu hand: aHandMorph [
" Show and toggle the popUp boolean menu item."

	aCustomMenu addLine. 
	
	aCustomMenu addUpdating: #popupFeatureString  target: self 
	selector: #togglePopupFeature argumentList: #() .

	
]

{ #category : #accessing }
ThumbnailImageMorph >> extent: anExtentPoint [
"Set the desired extetnt for the thumbnail. It is guarenteed to fit within the desired extent.
The desitedExtent is guarded to prevent deviant forms from being attempted."

self changed . "We might be bigger before we change."
desiredExtent := anExtentPoint guarded.
self newThumbnail: imagePopupMorph image .

]

{ #category : #'event handling' }
ThumbnailImageMorph >> handlesMouseDown: evt [
	^isPopup == true
]

{ #category : #initialization }
ThumbnailImageMorph >> initialize [
super initialize .
desiredExtent := 90 asPoint.
self newImage: DefaultForm
]

{ #category : #initialization }
ThumbnailImageMorph >> initializeWithDisplay [
super initialize .
desiredExtent := 90 asPoint.
self newImage: Display
]

{ #category : #'event handling' }
ThumbnailImageMorph >> mouseDown: evt [
	
	
	imagePopupMorph center: (self localPointToGlobal: evt position).
	imagePopupMorph bounds: (imagePopupMorph bounds translatedAndSquishedToBeWithin: self world bounds).
	imagePopupMorph openInWorld

]

{ #category : #'event handling' }
ThumbnailImageMorph >> mouseUp: evt [
	imagePopupMorph ifNotNil: [
		imagePopupMorph delete	.
		 ]
]

{ #category : #accessing }
ThumbnailImageMorph >> newImage: aForm [
	"Use aForm as the new popupImage and update the thumbnail image."
	
	imagePopupMorph 
		ifNil: [ imagePopupMorph :=   aForm asMorph]
		ifNotNil: [ imagePopupMorph image: aForm ] .
		
		self newThumbnail: aForm
		
		
]

{ #category : #accessing }
ThumbnailImageMorph >> newThumbnail: aForm [
	"Use aForm as the new popupImage and update the thumbnail image."
	| scale  thumbForm border smoothing |

		scale := aForm extent scaleTo: desiredExtent .
		smoothing := (scale x < 1.0 or: [ scale y < 1.0 ]) ifTrue: [ 2 ] ifFalse: [ 1 ] .
		
		thumbForm := aForm magnify: aForm boundingBox by: scale smoothing: smoothing .
		
		self image: thumbForm . "heres where we put in a thumbnail"
		"We need the following to keep the border the right size. Otherwise it will shrink."
		(border := self borderStyle) == BorderStyle default ifFalse: [ self borderStyle: border ] .
		
		"We have changed clear the old and show the new"
		self invalidRect: self bounds . 
]

{ #category : #accessing }
ThumbnailImageMorph >> popupFeatureString [
	"Answer the string to be shown in a menu to represent the  
	stickiness status"
	^ (self yesNoStringFor: (isPopup == true ) )
		, 'Popup feature' translated
]

{ #category : #accessing }
ThumbnailImageMorph >> target: aMorph [
	"Snap aMorphs current image and show its thumbnail"
	
	self newImage: aMorph imageForm fixAlpha .
		
]

{ #category : #accessing }
ThumbnailImageMorph >> togglePopupFeature [
	"Change the popup behaviour. Return the new boolean value."
	
	^isPopup := isPopup ~~ true .
		
]

{ #category : #accessing }
ThumbnailImageMorph >> yesNoStringFor: aBool [
	"Answer the string to be shown in a menu to represent the  
	yes/no status"
	^ (aBool
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		
]
