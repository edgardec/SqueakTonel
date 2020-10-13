Class {
	#name : #ZASMScriptMorph,
	#superclass : #PasteUpMorph,
	#instVars : [
		'somethingChanged'
	],
	#category : #'MorphicExtras-Demo'
}

{ #category : #layout }
ZASMScriptMorph >> acceptDroppingMorph: aMorph event: evt [

	super acceptDroppingMorph: aMorph event: evt.
	somethingChanged := true.
	
]

{ #category : #menus }
ZASMScriptMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	aCustomMenu add: 'save script' translated action: #saveScript.


]

{ #category : #'script compiling' }
ZASMScriptMorph >> compileScript [

	| newScript prevMark prevSteps |

	self fixup.
	newScript := OrderedCollection new.
	prevMark := prevSteps := nil.
	submorphs do: [ :each | | data |
		(each isKindOf: ZASMCameraMarkMorph) ifTrue: [
			prevMark ifNotNil: [
				data := Dictionary new.
				data 
					at: #steps put: prevSteps;
					at: #startPoint put: (prevMark valueOfProperty: #cameraPoint);
					at: #endPoint put: (each valueOfProperty: #cameraPoint);
					at: #startZoom put: (prevMark valueOfProperty: #cameraScale);
					at: #endZoom put: (each valueOfProperty: #cameraScale).
				newScript add: data.
			].
			prevMark := each.
		].
		(each isKindOf: ZASMStepsMorph) ifTrue: [
			prevSteps := each getStepCount.
		].
	].
	^newScript

]

{ #category : #'script compiling' }
ZASMScriptMorph >> decompileScript: aScript named: aString for: aController [

	| newMorphs prevPt prevScale |

	self removeAllMorphs.
	self setProperty: #cameraController toValue: aController.
	self setProperty: #cameraScriptName toValue: aString.

	newMorphs := OrderedCollection new.
	prevPt := prevScale := nil.
	aScript do: [ :each | | cameraPoint mark cameraScale |
		cameraPoint := each at: #startPoint ifAbsent: [nil].
		cameraScale := each at: #startZoom ifAbsent: [nil].
		(prevPt = cameraPoint and: [prevScale = cameraScale]) ifFalse: [
			mark := ZASMCameraMarkMorph new.
			mark cameraPoint: cameraPoint cameraScale: cameraScale controller: aController.
			newMorphs add: mark.
		].
		newMorphs add: (ZASMStepsMorph new setStepCount: (each at: #steps ifAbsent: [10])).
		cameraPoint := each at: #endPoint ifAbsent: [nil].
		cameraScale := each at: #endZoom ifAbsent: [nil].
		mark := ZASMCameraMarkMorph new.
		mark cameraPoint: cameraPoint cameraScale: cameraScale controller: aController.
		newMorphs add: mark.
		prevPt := cameraPoint.
		prevScale := cameraScale.
	].
	self addAllMorphs: newMorphs.

]

{ #category : #initialization }
ZASMScriptMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color blue
]

{ #category : #initialization }
ZASMScriptMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 2
]

{ #category : #initialization }
ZASMScriptMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color lightBlue
]

{ #category : #private }
ZASMScriptMorph >> fixup [

	| newMorphs state fixed |

	somethingChanged := false.
	newMorphs := OrderedCollection new.
	state := #new.
	fixed := false.
	submorphs do: [ :each |
		(each isKindOf: ZASMCameraMarkMorph) ifTrue: [
			state == #mark ifTrue: [
				newMorphs add: (
					ZASMStepsMorph new setStepCount: 10
				).
				fixed := true.
			].
			newMorphs add: each.
			state := #mark.
		].
		(each isKindOf: ZASMStepsMorph) ifTrue: [
			state == #steps ifTrue: [
				fixed := true.
			] ifFalse: [
				newMorphs add: each.
				state := #steps.
			].
		].
	].
	fixed ifTrue: [
		self removeAllMorphs.
		self addAllMorphs: newMorphs.
	].
]

{ #category : #initialization }
ZASMScriptMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	somethingChanged := true.
	self dragEnabled: true;
		 layoutPolicy: TableLayout new;
		 listDirection: #topToBottom;
		 wrapCentering: #topLeft;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 layoutInset: 6;
		
		 rubberBandCells: true
]

{ #category : #layout }
ZASMScriptMorph >> layoutChanged [

	super layoutChanged.
	somethingChanged := true.

	
]

{ #category : #menus }
ZASMScriptMorph >> saveScript [

	| newScript scriptName |
	newScript := self compileScript.
	scriptName := UIManager default 
		request: 'Name this script' 
		initialAnswer: (self valueOfProperty: #cameraScriptName ifAbsent: ['']).
	scriptName isEmptyOrNil ifTrue: [^self].
	(self valueOfProperty: #cameraController)
		saveScript: newScript
		as: scriptName.
	self delete.
]

{ #category : #'stepping and presenter' }
ZASMScriptMorph >> step [

	super step.
	somethingChanged ifFalse: [^self].
	self fixup.

]

{ #category : #'stepping and presenter' }
ZASMScriptMorph >> stepTime [

	^500
]

{ #category : #'dropping\/grabbing' }
ZASMScriptMorph >> wantsDroppedMorph: aMorph event: evt [

	^aMorph isKindOf: ZASMCameraMarkMorph
]

{ #category : #'stepping and presenter' }
ZASMScriptMorph >> wantsSteps [

	^true
]
