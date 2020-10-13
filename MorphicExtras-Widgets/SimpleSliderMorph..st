Class {
	#name : #SimpleSliderMorph,
	#superclass : #Slider,
	#instVars : [
		'target',
		'arguments',
		'minVal',
		'maxVal',
		'truncate'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #scripting }
SimpleSliderMorph class >> authoringPrototype [
	| aSlider nominalColor |
	"self currentHand attachMorph: SimpleSliderMorph authoringPrototype"

	aSlider := super authoringPrototype beSticky.
	aSlider extent: 14@120.
	nominalColor := Color r: 0.4 g: 0.86 b: 0.7.
	aSlider color: nominalColor.
	aSlider sliderColor: nominalColor muchLighter.
	aSlider descending: true.
	aSlider setScaledValue: 0.3.
	^ aSlider
]

{ #category : #printing }
SimpleSliderMorph class >> defaultNameStemForInstances [
	"Answer a basis for names of default instances of the receiver"
	^ 'Slider' translatedNoop
]

{ #category : #'parts bin' }
SimpleSliderMorph class >> descriptionForPartsBin [
	^ self partName:	'Slider' translatedNoop
		categories:		{'Basic' translatedNoop}
		documentation:	'A scriptable control that allows you to choose a numeric value by dragging a knob.' translatedNoop
]

{ #category : #'class initialization' }
SimpleSliderMorph class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'class initialization' }
SimpleSliderMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#SimpleSliderMorph. #authoringPrototype. 'Slider' translatedNoop. 'A slider for showing and setting numeric values.' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#SimpleSliderMorph. #authoringPrototype. 'Slider' translatedNoop. 'A slider for showing and setting numeric values.' translatedNoop}
						forFlapNamed: 'Supplies'.
						cl registerQuad: {#SimpleSliderMorph. #authoringPrototype. 'Slider' translatedNoop. 'A slider for showing and setting numeric values.' translatedNoop}
						forFlapNamed: 'Scripting']
]

{ #category : #'class initialization' }
SimpleSliderMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #accessing }
SimpleSliderMorph >> actionSelector [

	^ setValueSelector

]

{ #category : #accessing }
SimpleSliderMorph >> actionSelector: aSymbolOrString [

	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^ setValueSelector := nil].

	setValueSelector := aSymbolOrString asSymbol.

]

{ #category : #menu }
SimpleSliderMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"To all the other Custom menu items add slider and targeting items."
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	self addSliderMenuItems: aCustomMenu hand: aHandMorph .
	self addTargetingMenuItems: aCustomMenu hand: aHandMorph .
]

{ #category : #menu }
SimpleSliderMorph >> addSliderMenuItems: aCustomMenu hand: aHandMorph [ 
	"Add items to set slider parameters"
	aCustomMenu addLine.
	""
	aCustomMenu add: 'set action selector' translated action: #setActionSelector.
	aCustomMenu add: 'change arguments' translated action: #setArguments.
	""
	aCustomMenu add: 'set minimum value' translated action: #setMinVal.
	aCustomMenu add: 'set maximum value' translated action: #setMaxVal.
	""
	aCustomMenu addUpdating: #descendingString action: #toggleDescending.
	aCustomMenu addUpdating: #truncateString action: #toggleTruncate.
	
]

{ #category : #menu }
SimpleSliderMorph >> addTargetingMenuItems: aCustomMenu hand: aHandMorph [ 
	"Add targeting menu items"
	aCustomMenu addLine.

	aCustomMenu add: 'set target' translated action: #targetWith:.
	aCustomMenu add: 'sight target' translated action: #sightTargets:.
	target
		ifNotNil: [aCustomMenu add: 'clear target' translated action: #clearTarget]
]

{ #category : #private }
SimpleSliderMorph >> adjustToValue: aNumber [
	"Adjust the position of this slider to correspond to the given value in the range minVal..maxVal."
	"Details: Internal values are normalized to the range 0..1."

	| toUse |
	toUse := minVal = maxVal
		ifTrue:
			[minVal]
		ifFalse:
			[(aNumber - minVal) asFloat / (maxVal - minVal)].
	self value: toUse

]

{ #category : #accessing }
SimpleSliderMorph >> arguments [

	^ arguments

]

{ #category : #accessing }
SimpleSliderMorph >> arguments: aCollection [

	arguments := aCollection asArray copy.

]

{ #category : #menu }
SimpleSliderMorph >> clearTarget [

	target := nil.

]

{ #category : #menu }
SimpleSliderMorph >> descendingString [
	^ (self descending
		ifTrue: ['switch to ascending' translatedNoop]
		ifFalse: ['switch to descending' translatedNoop]) translated
]

{ #category : #private }
SimpleSliderMorph >> getScaledValue [
	| aValue |
	aValue := (value * (maxVal - minVal)) + minVal.
	^ truncate ifTrue: [aValue truncated] ifFalse: [aValue]
]

{ #category : #initialization }
SimpleSliderMorph >> initialize [

	super initialize.
	target := nil.
	arguments := Array empty.
	minVal := 0.0.
	maxVal := 1.0.
	truncate := false.

]

{ #category : #'parts bin' }
SimpleSliderMorph >> initializeToStandAlone [
	| nominalColor |

	self initialize.
	self beSticky.
	self extent: 14@120.
	nominalColor := Color r: 0.452 g: 0.645 b: 0.935.
	self color: nominalColor.
	self borderColor: Color veryDarkGray.
	self sliderColor: nominalColor muchLighter.
	self descending: true.
	self setScaledValue: 0.3
]

{ #category : #'e-toy support' }
SimpleSliderMorph >> isLikelyRecipientForMouseOverHalos [

	self player ifNil: [^ false].
	self player getHeading = 0.0 ifTrue: [^ false].
	^ true.

]

{ #category : #accessing }
SimpleSliderMorph >> maxVal [

	^ maxVal

]

{ #category : #accessing }
SimpleSliderMorph >> maxVal: aNumber [

	maxVal := aNumber.

]

{ #category : #accessing }
SimpleSliderMorph >> minVal [

	^ minVal

]

{ #category : #accessing }
SimpleSliderMorph >> minVal: aNumber [

	minVal := aNumber.

]

{ #category : #menu }
SimpleSliderMorph >> setActionSelector [
	| oldSel newSel |
	oldSel := setValueSelector isNil ifTrue: [''] ifFalse: [setValueSelector].
	newSel := UIManager default 
				request: 'Please type the selector to be sent to
the target when this slider is changed' translated
				initialAnswer: oldSel.
	newSel isEmpty ifFalse: [self actionSelector: newSel]
]

{ #category : #menu }
SimpleSliderMorph >> setArguments [

	| s newArgs newArgsArray |
	s := WriteStream on: ''.
	arguments do: [:arg | arg printOn: s. s nextPutAll: '. '].
	newArgs := UIManager default
		request:
'Please type the arguments to be sent to the target
when this button is pressed separated by periods' translated
		initialAnswer: s contents.
	newArgs isEmpty ifFalse: [
		newArgsArray := Compiler evaluate: '{', newArgs, '}' for: self.
		self arguments: newArgsArray].

]

{ #category : #menu }
SimpleSliderMorph >> setLabel [

	| newLabel |
	newLabel := UIManager default
		request:
'Please a new label for this button'
		initialAnswer: self label.
	newLabel isEmpty ifFalse: [self label: newLabel].

]

{ #category : #menu }
SimpleSliderMorph >> setMaxVal [

	| newMaxVal |
	newMaxVal := UIManager default
		request: 'Maximum value?'
		initialAnswer: maxVal printString.
	newMaxVal isEmpty ifFalse: [
		maxVal := newMaxVal asNumber.
		minVal := minVal min: maxVal].

]

{ #category : #private }
SimpleSliderMorph >> setMaxVal: newMaxVal [
	maxVal := newMaxVal asNumber.
	minVal := maxVal min: minVal

]

{ #category : #menu }
SimpleSliderMorph >> setMinVal [

	| newMinVal |
	newMinVal := UIManager default
		request: 'Minimum value?'
		initialAnswer: minVal printString.
	newMinVal isEmpty ifFalse: [
		minVal := newMinVal asNumber.
		maxVal := maxVal max: minVal].

]

{ #category : #menu }
SimpleSliderMorph >> setMinVal: newMinVal [
	minVal := newMinVal asNumber.
	maxVal := maxVal max: minVal

]

{ #category : #private }
SimpleSliderMorph >> setScaledValue: aNumber [
	| denom |
	(denom := maxVal - minVal) > 0
		ifTrue:
			[self setValue: (aNumber - minVal) / denom]
		ifFalse:
			[self setValue: maxVal]
	"If minVal = maxVal, that value is the only one this (rather unuseful!) slider can bear"
]

{ #category : #menu }
SimpleSliderMorph >> setTarget: evt [ 
	| rootMorphs |
	rootMorphs := self world rootMorphsAt: evt  targetPoint.
	target := rootMorphs size > 1
				ifTrue: [rootMorphs second]
]

{ #category : #'model access' }
SimpleSliderMorph >> setValue: newValue [ 
	"Update the target with this sliders new value."

	| scaledValue |
	self value: newValue.
	scaledValue := newValue * (maxVal - minVal) + minVal.
	truncate ifTrue: [scaledValue := scaledValue truncated].
	(target notNil and: [setValueSelector notNil]) 
		ifTrue: 
			[Cursor normal showWhile: 
					[target perform: setValueSelector
						withArguments: (arguments copyWith: scaledValue)]]
]

{ #category : #accessing }
SimpleSliderMorph >> target [

	^ target

]

{ #category : #accessing }
SimpleSliderMorph >> target: anObject [

	target := anObject

]

{ #category : #menu }
SimpleSliderMorph >> toggleDescending [

	descending := self descending not

]

{ #category : #menu }
SimpleSliderMorph >> toggleTruncate [

	truncate := truncate not.

]

{ #category : #private }
SimpleSliderMorph >> truncate [
	^ truncate == true
]

{ #category : #private }
SimpleSliderMorph >> truncate: aBoolean [
	truncate := aBoolean
]

{ #category : #menu }
SimpleSliderMorph >> truncateString [
	^ (truncate
		ifTrue: ['turn off truncation' translatedNoop]
		ifFalse: ['turn on truncation' translatedNoop])  translated
]

{ #category : #copying }
SimpleSliderMorph >> updateReferencesUsing: aDictionary [
	"Copy and update references in the arguments array during copying."

	super updateReferencesUsing: aDictionary.
	arguments := arguments collect:
		[:old | aDictionary at: old ifAbsent: [old]].

]

{ #category : #copying }
SimpleSliderMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].
arguments := arguments collect: [:each |
	deepCopier references at: each ifAbsent: [each]].

]

{ #category : #copying }
SimpleSliderMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"target := target.		Weakly copied"
"arguments := arguments.		All weakly copied"
minVal := minVal veryDeepCopyWith: deepCopier.		"will be fast if integer"
maxVal := maxVal veryDeepCopyWith: deepCopier.
truncate := truncate veryDeepCopyWith: deepCopier.

]
