"
A morph whose appearance is a thumbnail of some other morph.
"
Class {
	#name : #MorphThumbnail,
	#superclass : #SketchMorph,
	#instVars : [
		'morphRepresented'
	],
	#category : #'MorphicExtras-Books'
}

{ #category : #menus }
MorphThumbnail >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'reveal original morph' translated action: #revealOriginal.
	aCustomMenu add: 'grab original morph' translated action: #grabOriginal.

]

{ #category : #private }
MorphThumbnail >> computeThumbnail [
	"Assumption on entry:
       The receiver's width represents the maximum width allowable.
       The receiver's height represents the exact height desired."

	| f scaleX scaleY |
	f := morphRepresented imageForm.
	morphRepresented fullReleaseCachedState.
	scaleY := self height / f height.  "keep height invariant"
	scaleX := ((morphRepresented width * scaleY) <= self width)
		ifTrue:
			[scaleY]  "the usual case; same scale factor, to preserve aspect ratio"
		ifFalse:
			[self width / f width].
	self form: (f magnify: f boundingBox by: (scaleX @ scaleY) smoothing: 2).
	self extent: originalForm extent
]

{ #category : #initialization }
MorphThumbnail >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightGray
]

{ #category : #menus }
MorphThumbnail >> grabOriginal [
	self primaryHand attachMorph: morphRepresented
]

{ #category : #initialization }
MorphThumbnail >> initialize [
	"initialize the state of the receiver"
	| f |
	super initialize.
	""

	f := Form extent: 60 @ 80 depth: Display depth.
	f fill: f boundingBox fillColor: color.
	self form: f
]

{ #category : #naming }
MorphThumbnail >> innocuousName [
	^ morphRepresented isNil
		ifTrue: [super innocuousName]
		ifFalse: [morphRepresented innocuousName]
]

{ #category : #'parts bin' }
MorphThumbnail >> isPartsDonor [
	"answer whether the receiver is PartsDonor"
	^ self partRepresented isPartsDonor
]

{ #category : #'parts bin' }
MorphThumbnail >> isPartsDonor: aBoolean [
	"change the receiver's isPartDonor property"
	self partRepresented isPartsDonor: aBoolean
]

{ #category : #thumbnail }
MorphThumbnail >> morphRepresented [

	^ morphRepresented

]

{ #category : #accessing }
MorphThumbnail >> morphRepresented: aMorph [

	morphRepresented := aMorph.
	self computeThumbnail.

]

{ #category : #'parts bin' }
MorphThumbnail >> partRepresented [
	^self morphRepresented
]

{ #category : #thumbnail }
MorphThumbnail >> representativeNoTallerThan: maxHeight norWiderThan: maxWidth thumbnailHeight: thumbnailHeight [

	"Return a morph representing the receiver but which is no taller than aHeight.  If the receiver is already small enough, just return it, else return a MorphThumbnail companioned to the receiver, enforcing the maxWidth"

	(self height <= maxHeight and: [self width <= maxWidth]) ifTrue: [^ self].

	^ MorphThumbnail new
		extent: maxWidth @ (thumbnailHeight min: self height);
		morphRepresented: morphRepresented
]

{ #category : #menus }
MorphThumbnail >> revealOriginal [
	((owner isKindOf: PasteUpMorph) and: [owner alwaysShowThumbnail]) 
		ifTrue: [^Beeper beep].
	morphRepresented owner isNil 
		ifTrue: [^owner replaceSubmorph: self by: morphRepresented].
	Beeper beep
]

{ #category : #initialization }
MorphThumbnail >> smaller [
	self form: (self form copy: (0@0 extent: self form extent // 2))
]

{ #category : #copying }
MorphThumbnail >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
morphRepresented := deepCopier references at: morphRepresented 
		ifAbsent: [morphRepresented].
]

{ #category : #copying }
MorphThumbnail >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
morphRepresented := morphRepresented.		"Weakly copied"
]
