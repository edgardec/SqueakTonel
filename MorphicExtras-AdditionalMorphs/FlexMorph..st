Class {
	#name : #FlexMorph,
	#superclass : #SketchMorph,
	#instVars : [
		'originalMorph',
		'borderWidth',
		'borderColor'
	],
	#category : #'MorphicExtras-AdditionalMorphs'
}

{ #category : #menus }
FlexMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	"super addCustomMenuItems: aCustomMenu hand: aHandMorph."
	aCustomMenu addLine.
	aCustomMenu add: 'update from original' translated action: #updateFromOriginal.
	aCustomMenu addList: {
						{'border color...' translated. #changeBorderColor:}.
						{'border width...' translated. #changeBorderWidth:}.
						}.
	aCustomMenu addLine.

]

{ #category : #accessing }
FlexMorph >> borderColor: aColor [
	borderColor := aColor.
	self updateFromOriginal
]

{ #category : #accessing }
FlexMorph >> borderWidth: width [
	borderWidth := width asPoint.
	self updateFromOriginal
]

{ #category : #menus }
FlexMorph >> changeBorderColor: evt [
	| aHand |
	aHand := evt ifNotNil: [evt hand] ifNil: [self primaryHand].
	self changeColorTarget: self selector: #borderColor: originalColor: self borderColor hand: aHand.
]

{ #category : #menus }
FlexMorph >> changeBorderWidth: evt [
	| handle origin aHand |
	aHand := evt ifNil: [self primaryHand] ifNotNil: [evt hand].
	origin := aHand position.
	handle := HandleMorph new forEachPointDo:
		[:newPoint | handle removeAllMorphs.
		handle addMorph:
			(LineMorph from: origin to: newPoint color: Color black width: 1).
		self borderWidth: (newPoint - origin) r asInteger // 5].
	aHand attachMorph: handle.
	handle startStepping
]

{ #category : #drawing }
FlexMorph >> drawOn: aCanvas [

	originalForm := nil.  "Aggressively uncache the originalForm"
	^ super drawOn: aCanvas
]

{ #category : #geometry }
FlexMorph >> extent: newExtent [

	self loadOriginalForm.  "make sure it's not nil"
	^ super extent: newExtent
]

{ #category : #accessing }
FlexMorph >> form [

	self loadOriginalForm.  "make sure it's not nil"
	^ super form
]

{ #category : #drawing }
FlexMorph >> generateRotatedForm [

	self loadOriginalForm.  "make sure it's not nil"
	^ super generateRotatedForm
]

{ #category : #initialization }
FlexMorph >> initialize [
	super initialize.
	borderWidth := 2@2.
	borderColor := Color black.
]

{ #category : #layout }
FlexMorph >> layoutChanged [

	self loadOriginalForm.  "make sure it's not nil"
	^ super layoutChanged
]

{ #category : #private }
FlexMorph >> loadOriginalForm [

	originalForm ifNil: [self updateFromOriginal].

]

{ #category : #accessing }
FlexMorph >> originalMorph [

	^ originalMorph
]

{ #category : #accessing }
FlexMorph >> originalMorph: aMorph [

	originalMorph := aMorph.
	scalePoint := 0.25@0.25.
	self updateFromOriginal.
]

{ #category : #caching }
FlexMorph >> releaseCachedState [
	"Clear cache of rotated, scaled Form."

	originalForm := Form extent: 10@10.  "So super hibernate won't have to work hard
												but won't crash either."
	super releaseCachedState.
	rotatedForm := nil.
	originalForm := nil.
]

{ #category : #private }
FlexMorph >> updateFromOriginal [

	| intermediateForm |
	intermediateForm := originalMorph imageForm offset: 0@0.
	intermediateForm border: intermediateForm boundingBox
		widthRectangle: (borderWidth corner: borderWidth+1)
		rule: Form over fillColor: borderColor.
	self form: intermediateForm.
	originalMorph fullReleaseCachedState
]
