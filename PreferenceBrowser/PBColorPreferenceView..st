Class {
	#name : #PBColorPreferenceView,
	#superclass : #PBPreferenceView,
	#instVars : [
		'button'
	],
	#category : #PreferenceBrowser
}

{ #category : #'class initialization' }
PBColorPreferenceView class >> initialize [
	PreferenceViewRegistry ofColorPreferences register: self.
]

{ #category : #'class initialization' }
PBColorPreferenceView class >> unload [
	"Unload order is not guaranteed so guard against failure"
	[PreferenceViewRegistry ofColorPreferences unregister: self] on: Error do:[]
]

{ #category : #'user interface' }
PBColorPreferenceView >> adjustLabelColor [
	| textColor |
	(self preference preferenceValue luminance < 0.5)
		ifTrue:[ textColor := Color white]
		ifFalse:[ textColor := Color black].
	button allMorphsDo: [:m | (m isKindOf: StringMorph) ifTrue: [ m color: textColor]].	
]

{ #category : #'user interface' }
PBColorPreferenceView >> borderStyleMenu [
	"Add border-style menu items"

	|  aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	
	aMenu addStayUpItemSpecial.
	aMenu add: 'border color...' translated target: self selector:#changeColor: argument: button.
	aMenu addLine.
	BorderStyle borderStyleChoices do:
		[:sym | (aMenu borderStyleForSymbol: sym)
			ifNotNil:
				[aMenu add: sym translated target: self selector: #setBorderStyle: argument: sym]].
	^aMenu popUpInWorld

]

{ #category : #'user interface' }
PBColorPreferenceView >> changeColor: aButton [
	NewColorPickerMorph useIt
		ifTrue:
			[ (NewColorPickerMorph
				on: self
				originalColor: aButton color
				setColorSelector: #setButtonColor:) openNear: aButton fullBoundsInWorld ]
		ifFalse:
			[ ColorPickerMorph new
				 choseModalityFromPreference ;
				 sourceHand: aButton activeHand ;
				 target: self ;
				 selector: #setButtonColor: ;
				 originalColor: aButton color ;
				
				putUpFor: aButton
				near: aButton fullBoundsInWorld ]	
]

{ #category : #'user interface' }
PBColorPreferenceView >> colorMenuButton [
	| selector name |
	name := self preference name.
	(name includesSubstring: 'border' caseSensitive: false)
				ifTrue: [ selector := #borderStyleMenu]
				ifFalse:[ selector := #fillStyleMenu].
	button := SimpleButtonMorph new
	label: self preference preferenceValue asString;
	actionSelector: selector;
	target: self.
	
	self adjustLabelColor.
	^button color: self preference preferenceValue
	
	
	"UpdatingRectangleMorph new
		target: self preference;
		getSelector: #preferenceValue;
		putSelector: #preferenceValue:;
		extent: 22@22;
		setBalloonText: 'click here to change the color' translated;
		yourself."
]

{ #category : #'user interface' }
PBColorPreferenceView >> colorSwatch [
	^UpdatingRectangleMorph new
		target: self preference;
		getSelector: #preferenceValue;
		putSelector: #preferenceValue:;
		extent: 22@22;
		setBalloonText: 'click here to change the color' translated;
		yourself.
]

{ #category : #'user interface' }
PBColorPreferenceView >> fillStyleMenu [
	"Add the items for changing the current fill style of the Morph"
	|  aMenu |
	"self canHaveFillStyles ifFalse:[^aMenu add: 'change color...' translated target: self action: #changeColor]."
	aMenu := MenuMorph new defaultTarget: self.
	"self preference preferenceValue addFillStyleMenuItems: aMenu hand: nil from: self."
	aMenu add: 'change color...' translated target: self selector:#changeColor: argument: button.
	aMenu addLine.
	aMenu add: 'solid fill' translated action: #useSolidFill.
	"aMenu add: 'gradient fill' translated action: #useGradientFill.
	aMenu add: 'bitmap fill' translated action: #useBitmapFill.
	aMenu add: 'default fill' translated action: #useDefaultFill."
	^aMenu popUpInWorld
	
]

{ #category : #'user interface' }
PBColorPreferenceView >> representativeButtonWithColor: aColor inPanel: aPreferenceBrowser [
	^self horizontalPanel
		layoutInset: 2;
		color: aColor;
		cellGap: 20;
		cellPositioning: #center;
		addMorphBack: self morphForName;
		addMorphBack: self horizontalFiller;
		addMorphBack: self colorMenuButton;
		yourself
]

{ #category : #'user interface' }
PBColorPreferenceView >> setBorderStyle: aBorderStyle [
		
	self preference preferenceValue: aBorderStyle.
	button label: self preference preferenceValue asString;
	borderColor: aBorderStyle.
	
]

{ #category : #'user interface' }
PBColorPreferenceView >> setButtonColor: aColor [
	button color: aColor.
	self preference preferenceValue: aColor.
	button label: self preference preferenceValue asString.
	self adjustLabelColor

]

{ #category : #'user interface' }
PBColorPreferenceView >> useSolidFill [
	"Make receiver use a solid fill style (e.g., a simple color)"
	self preference preferenceValue isSolidFill ifTrue:[^self]. "Already done"
	self preference preferenceValue: self preference preferenceValue asColor. "Try minimizing changes"
	
	button label: self preference preferenceValue asString;
	color: self preference preferenceValue
	
]
