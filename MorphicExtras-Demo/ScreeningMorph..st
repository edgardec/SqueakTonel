"
ScreeningMorph uses its first submorph as a screen, and its second submorph as a source.  It also wants you to choose (when showing only the screen) the passing color in the screen.  It then makes up a 1-bit mask which clips the source, and displays transparently outside it.
"
Class {
	#name : #ScreeningMorph,
	#superclass : #Morph,
	#instVars : [
		'screenForm',
		'displayMode',
		'passingColor',
		'passElseBlock'
	],
	#category : #'MorphicExtras-Demo'
}

{ #category : #menu }
ScreeningMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	submorphs isEmpty ifTrue:
		[^ aCustomMenu add: '*Please add a source morph*' translated action: #itself].
	submorphs size = 1 ifTrue:
		[^ aCustomMenu add: '*Please add a screen morph*' translated action: #itself].
	submorphs size > 2 ifTrue:
		[^ aCustomMenu add: '*I have too many submorphs*' translated action: #itself].
	aCustomMenu add: 'show screen only' translated action: #showScreenOnly.
	aCustomMenu add: 'show source only' translated action: #showSourceOnly.
	aCustomMenu add: 'show screen over source' translated action: #showScreenOverSource.
	aCustomMenu add: 'show source screened' translated action: #showScreened.
	aCustomMenu add: 'exchange source and screen' translated action: #exchange.
	displayMode == #showScreenOnly ifTrue:
		[aCustomMenu add: 'choose passing color' translated action: #choosePassingColor.
		aCustomMenu add: 'choose blocking color' translated action: #chooseBlockingColor].

]

{ #category : #'submorphs-add\/remove' }
ScreeningMorph >> addMorph: aMorph [

	| f |
	super addMorph: aMorph.
	submorphs size <= 2 ifTrue:
		[self bounds: submorphs last bounds].
	submorphs size = 2 ifTrue:
		["The screenMorph has just been added.
		Choose as the passingColor the center color of that morph"
		f := self screenMorph imageForm.
		passingColor := f colorAt: f boundingBox center.
		passElseBlock := true]
]

{ #category : #menu }
ScreeningMorph >> chooseBlockingColor [
	passingColor := Color fromUser.
	passElseBlock := false.
	self layoutChanged
]

{ #category : #menu }
ScreeningMorph >> choosePassingColor [
	passingColor := Color fromUser.
	passElseBlock := true.
	self layoutChanged
]

{ #category : #'geometry testing' }
ScreeningMorph >> containsPoint: aPoint [
	submorphs size = 2 ifFalse: [^ super containsPoint: aPoint].
	^ self screenMorph containsPoint: aPoint
]

{ #category : #menu }
ScreeningMorph >> exchange [
	submorphs swap: 1 with: 2.
	self changed
]

{ #category : #drawing }
ScreeningMorph >> fullDrawOn: aCanvas [ 
	| mergeForm |
	submorphs isEmpty ifTrue: [^super fullDrawOn: aCanvas].
	(aCanvas isVisible: self fullBounds) ifFalse: [^self].
	(submorphs size = 1 or: [displayMode == #showScreenOnly]) 
		ifTrue: [^aCanvas fullDrawMorph: self screenMorph].
	displayMode == #showSourceOnly 
		ifTrue: [^aCanvas fullDrawMorph: self sourceMorph].
	displayMode == #showScreenOverSource 
		ifTrue: 
			[aCanvas fullDrawMorph: self sourceMorph.
			^aCanvas fullDrawMorph: self screenMorph].
	displayMode == #showScreened 
		ifTrue: 
			[aCanvas fullDrawMorph: self screenMorph.
			self flag: #fixCanvas.	"There should be a more general way than this"
			mergeForm := self sourceMorph 
						imageFormForRectangle: self screenMorph bounds.
			(BitBlt toForm: mergeForm) 
				copyForm: self screenForm
				to: 0 @ 0
				rule: Form and
				colorMap: (Bitmap with: 0 with: 4294967295).
			aCanvas paintImage: mergeForm at: self screenMorph position]
]

{ #category : #initialization }
ScreeningMorph >> initialize [
	super initialize.
	passingColor := Color black.
	passElseBlock := true.
	displayMode := #showScreened.
	self enableDragNDrop
]

{ #category : #layout }
ScreeningMorph >> layoutChanged [

	screenForm := nil.
	submorphs size >= 2
		ifTrue: [self disableDragNDrop]
		ifFalse: [self enableDragNDrop].
	submorphs size = 2 ifTrue:
		[bounds := ((self sourceMorph bounds merge: self screenMorph bounds) expandBy: 4)].
	^ super layoutChanged
]

{ #category : #accessing }
ScreeningMorph >> passElseBlock: aBool [
	passElseBlock := aBool.
]

{ #category : #accessing }
ScreeningMorph >> passingColor: aColor [
	passingColor := aColor.
]

{ #category : #private }
ScreeningMorph >> removedMorph: aMorph [

	submorphs size = 1 ifTrue:
		[self bounds: submorphs first bounds].
	super removedMorph: aMorph.
]

{ #category : #private }
ScreeningMorph >> screenForm [
	| screenImage colorMap pickValue elseValue |
	screenForm ifNotNil: [^screenForm].
	passElseBlock ifNil: [passElseBlock := true].
	passingColor ifNil: [passingColor := Color black].
	elseValue := passElseBlock 
		ifTrue: 
			[pickValue := 4294967295.
			 0]
		ifFalse: 
			[pickValue := 0.
			 4294967295].
	screenImage := self screenMorph 
				imageFormForRectangle: self screenMorph bounds.
	colorMap := screenImage newColorMap atAllPut: elseValue.
	colorMap at: (passingColor indexInMap: colorMap) put: pickValue.
	screenForm := Form extent: screenImage extent.
	screenForm 
		copyBits: screenForm boundingBox
		from: screenImage
		at: 0 @ 0
		colorMap: colorMap.
	^screenForm
]

{ #category : #private }
ScreeningMorph >> screenMorph [
	^submorphs first
]

{ #category : #menu }
ScreeningMorph >> showScreenOnly [
	displayMode := #showScreenOnly.
	self changed
]

{ #category : #menu }
ScreeningMorph >> showScreenOverSource [
	displayMode := #showScreenOverSource.
	self changed
]

{ #category : #menu }
ScreeningMorph >> showScreened [
	displayMode := #showScreened.
	self changed
]

{ #category : #menu }
ScreeningMorph >> showSourceOnly [
	displayMode := #showSourceOnly.
	self changed
]

{ #category : #private }
ScreeningMorph >> sourceMorph [
	^submorphs second
]

{ #category : #'e-toy support' }
ScreeningMorph >> wantsRecolorHandle [
	"Answer whether the receiver would like a recolor handle to be  
	put up for it. We'd want to disable this but for the moment  
	that would cut off access to the button part of the properties  
	sheet. So this remains a loose end."
	^ false
]
