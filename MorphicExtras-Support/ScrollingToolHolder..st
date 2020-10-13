"
Used to hold stamp images in the PaintBox. Displays a small number of the available stamps and allows scrolling to access the others. One stamp is always kept blank as a way to create new stamps.

Note:
	stamps are the full size Forms
	thumbnailPics are the shrunken ones
	nil in both lists means no stamp yet, so user can create one

"
Class {
	#name : #ScrollingToolHolder,
	#superclass : #Object,
	#instVars : [
		'pickupButtons',
		'stampButtons',
		'stamps',
		'thumbnailPics',
		'start'
	],
	#category : #'MorphicExtras-Support'
}

{ #category : #'instance creation' }
ScrollingToolHolder class >> newPrototype [
	^self new buildAPrototype
]

{ #category : #'instance creation' }
ScrollingToolHolder class >> newPrototypeFor: aPaintBoxMorph [
	^self new buildAPrototypeFor: aPaintBoxMorph
]

{ #category : #'initialize-release' }
ScrollingToolHolder >> buildAPrototypeFor: aPaintBoxMorph [
	pickupButtons := (aPaintBoxMorph submorphNamed: 'stamps') submorphs select: [:e | e externalName = 'pickup:'].
	stampButtons := (aPaintBoxMorph submorphNamed: 'stamps') submorphs select: [:e | e externalName = 'stamp:'].
	stamps := OrderedCollection ofSize: 3.
	thumbnailPics := OrderedCollection ofSize: 3.
	start := 3.
]

{ #category : #accessing }
ScrollingToolHolder >> clear [
	"wipe out all existing stamps"

	stamps := OrderedCollection new: 16.
	thumbnailPics := OrderedCollection new: 16.
	stampButtons do: [:each | 
		stamps addLast: nil.	"hold a space"
		thumbnailPics addLast: nil].
	start := 1.
	self normalize.
]

{ #category : #accessing }
ScrollingToolHolder >> normalize [
	"Correspondence between buttons and stamp forms has changed.  Make all thumbnails show up right."

	| shrunkForm button trans |
	1 to: stampButtons size do: [:ind |
		shrunkForm := thumbnailPics atWrap: ind+start-1.
		button := stampButtons at: ind.
		shrunkForm 
			ifNil: [trans := Form extent: button extent depth: 8.
				trans fill: trans boundingBox fillColor: Color transparent.
				button onImage: trans]
			ifNotNil: [button onImage: shrunkForm].
		button offImage: shrunkForm; pressedImage: shrunkForm.	"later modify them"
		].
]

{ #category : #accessing }
ScrollingToolHolder >> otherButtonFor: aButton [
	"Find the corresponding button for either a pickup or a stamp button"

	| ii |
	(ii := pickupButtons indexOf: aButton) > 0 ifTrue: [^ stampButtons at: ii].
	(ii := stampButtons indexOf: aButton) > 0 ifTrue: [^ pickupButtons at: ii].
	self error: 'stamp button not found'.
]

{ #category : #accessing }
ScrollingToolHolder >> pickupButtons [

	^ pickupButtons
]

{ #category : #accessing }
ScrollingToolHolder >> pickupButtons: anArray [
	"Save the list of buttons that are for making a new stamp.  Left to right"

	pickupButtons := anArray
]

{ #category : #accessing }
ScrollingToolHolder >> remove: tool [
	"Remove a stamp.  Make this stamp blank.  OK to have a bunch of blank ones."

	| which |
	which := stampButtons indexOf: tool ifAbsent: [
				pickupButtons indexOf: tool ifAbsent: [^ self]].
	stamps atWrap: which+start-1 put: nil.
	thumbnailPics atWrap: which+start-1 put: nil.
	self normalize.	"show them"
]

{ #category : #accessing }
ScrollingToolHolder >> scroll: amt [
	"Move the stamps over"

	start := start - 1 + amt \\ stamps size + 1.
	self normalize.	"show them"
]

{ #category : #accessing }
ScrollingToolHolder >> stampButtons [

	^ stampButtons
]

{ #category : #accessing }
ScrollingToolHolder >> stampButtons: anArray [
	"Pop in a new list of buttons that are the tools for stamping.  Left to right"

	stampButtons := anArray.
	self clear.
]

{ #category : #accessing }
ScrollingToolHolder >> stampForm: stampForm for: aPickupButton [
	"Install this form to stamp. Find its index.  Make a thumbnail."

	| which scale shrunkForm stampBtn mini |
	which := pickupButtons indexOf: aPickupButton.
	which = 0 ifTrue: [which := stampButtons indexOf: aPickupButton].
	stamps atWrap: which+start-1 put: stampForm.

	"Create the thumbnail"
	stampBtn := stampButtons at: which.
	scale := stampBtn width / (stampForm extent x max: stampForm extent y).
	scale := scale min: 1.0.	"do not expand it"
	mini := stampForm magnify: stampForm boundingBox by: scale smoothing: 1.
	shrunkForm := mini class extent: stampBtn extent depth: stampForm depth.
	mini displayOn: shrunkForm at: (stampBtn extent - mini extent)//2.
	thumbnailPics atWrap: which+start-1 put: shrunkForm.
	stampBtn offImage: shrunkForm; onImage: shrunkForm; pressedImage: shrunkForm.
		"Emphasis is done by border of enclosing layoutMorph, not modifying image"

	(stamps indexOf: nil) = 0 ifTrue: ["Add an extra blank place"
		"Keep stamp we just installed in the same location!"
		start+which-1 > stamps size ifTrue: [start := start + 1].
		stamps addLast: nil.
		thumbnailPics addLast: nil.
		self normalize].

]

{ #category : #accessing }
ScrollingToolHolder >> stampFormFor: aButton [

	| which |
	which := stampButtons indexOf: aButton ifAbsent: [1].
	^ stamps atWrap: which+start-1
]

{ #category : #accessing }
ScrollingToolHolder >> updateReferencesUsing: aDictionary [
	"Fix up the Morphs I own"
	"Note: Update this method when adding new inst vars that could contain Morphs."

	stampButtons := stampButtons collect:
		[:old | aDictionary at: old ifAbsent: [old]].
	pickupButtons := pickupButtons collect:
		[:old | aDictionary at: old ifAbsent: [old]].

]
