Class {
	#name : #ObjectPropertiesMorph,
	#superclass : #GenericPropertiesMorph,
	#instVars : [
		'simplePanel'
	],
	#category : #'Etoys-Experimental'
}

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> adjustTargetBorderWidth: aFractionalPoint [

	| n |

	myTarget borderWidth: (n := (aFractionalPoint x * 10) rounded max: 0).
	self showSliderFeedback: n.
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> adjustTargetGradientDirection: aFractionalPoint [

	| fs p |

	(fs := myTarget fillStyle) isGradientFill ifFalse: [^self].
	fs direction: (p := (aFractionalPoint * myTarget extent) rounded).
	self showSliderFeedback: p.
	myTarget changed.

]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> adjustTargetGradientOrigin: aFractionalPoint [

	| fs p |

	(fs := myTarget fillStyle) isGradientFill ifFalse: [^self].
	fs origin: (p := myTarget topLeft + (aFractionalPoint * myTarget extent) rounded).
	self showSliderFeedback: p.
	myTarget changed.

]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> adjustTargetShadowOffset: aFractionalPoint [

	| n |

	myTarget changed; layoutChanged.
	myTarget shadowOffset: (n := (aFractionalPoint * 4) rounded).
	self showSliderFeedback: n.
	myTarget changed; layoutChanged.

]

{ #category : #panes }
ObjectPropertiesMorph >> borderPrototype: aBorderStyle help: helpString [
	| selector proto |
	selector := BorderedMorph new.
	selector borderWidth: 0.
	selector color: Color transparent.
	proto := Morph new extent: 16@16.
	proto color:  Color transparent.
	proto borderStyle: aBorderStyle.
	selector extent: proto extent + 4.
	selector addMorphCentered: proto.
	(myTarget canDrawBorder: aBorderStyle) ifTrue:[
		selector setBalloonText: helpString.
		selector on: #mouseDown send: #toggleBorderStyle:with:from: to: self withValue: proto.
		(myTarget borderStyle species == aBorderStyle species and:[
			myTarget borderStyle style == aBorderStyle style]) ifTrue:[selector borderWidth: 1].
	] ifFalse:[
		selector setBalloonText: 'This border style cannot be used here' translated.
		selector on: #mouseDown send: #beep to: Beeper.
		selector addMorphCentered: ((Morph new) color: (Color black alpha: 0.5); extent: selector extent).
	].
	^selector
]

{ #category : #initialization }
ObjectPropertiesMorph >> defaultBorderColor [
"answer the default border color/fill style for the receiver"
	^ self defaultColor darker
]

{ #category : #initialization }
ObjectPropertiesMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color
		r: 0.548
		g: 0.839
		b: 0.452
]

{ #category : #enabling }
ObjectPropertiesMorph >> doEnables [
	"Carry out appropriate enablings within the receiver's interior."

	| itsName fs |

	fs := myTarget fillStyle.
	self allMorphsDo: [ :each |
		itsName := each knownName.
		itsName == #pickerForColor ifTrue: [
			self enable: each when: (myTarget doesColorAndBorder and: [ fs isSolidFill | fs isGradientFill])].
		itsName == #pickerForBorderColor ifTrue: [
			self enable: each when: (myTarget doesColorAndBorder and: [myTarget respondsTo: #borderColor:])
		].
		itsName == #pickerForShadowColor ifTrue: [
			self enable: each when: myTarget hasDropShadow
		].
		itsName == #pickerFor2ndGradientColor ifTrue: [
			self enable: each when: (myTarget doesColorAndBorder and: [myTarget doesColorAndBorder and: [fs isGradientFill]])
		].
	].

]

{ #category : #initialization }
ObjectPropertiesMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	
	myTarget
		ifNil: [myTarget := RectangleMorph new openInWorld].
	(myTarget fillStyle isSolidFill)
					ifTrue:[simplePanel := true]
					ifFalse:[simplePanel := false].
	self rebuild
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> makeTargetGradientFill [

	myTarget useGradientFill
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> makeTargetSolidFill [

	myTarget color: self numberOneColor.
	myTarget useSolidFill	
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> numberOneColor [

	myTarget fillStyle isGradientFill ifFalse: [^myTarget color].
	^myTarget fillStyle colorRamp first value

]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> numberOneColor: aColor [ 
	myTarget fillStyle isGradientFill 
		ifFalse: 
			[^(myTarget isSystemWindow) 
				ifTrue: [myTarget setWindowColor: aColor]
				ifFalse: [myTarget fillStyle: aColor]].
	myTarget fillStyle 
		firstColor: aColor
		forMorph: myTarget
		hand: nil
]

{ #category : #panes }
ObjectPropertiesMorph >> paneFor2ndGradientColorPicker [

	^self 
		inAColumn: {
			(self inAColumn: {
				self colorPickerFor: self getter: #tgt2ndGradientColor setter: #tgt2ndGradientColor:.
				self lockedString: '2nd gradient color' translated.
				self paneForRadialGradientToggle hResizing: #shrinkWrap.
				(
					self inARow: {self paneForGradientOrigin. self paneForGradientDirection}
				) hResizing: #shrinkWrap.
			}
			named: #pickerFor2ndGradientColor) layoutInset: 0.
			self paneForGradientFillToggle hResizing: #shrinkWrap 
		}

]

{ #category : #panes }
ObjectPropertiesMorph >> paneForBorderColorPicker [

	^self 
		inAColumn: {
			self 
				colorPickerFor: self
				getter: #targetBorderColor
				setter: #targetBorderColor:.
			self lockedString: 'Border Color' translated.
			(self paneForBorderStyle) hResizing: #shrinkWrap; layoutInset: 5.
			self lockedString: 'Border style' translated.
			self paneForBorderWidth.
		} 
		named: #pickerForBorderColor.


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForBorderStyle [

	^self inARow: {
		self borderPrototype: (BorderStyle width: 4 color: Color black)
			help:'Click to select a simple colored border' translated.
		self borderPrototype: (BorderStyle raised width: 4)
			help:'Click to select a simple raised border' translated.
		self borderPrototype: (BorderStyle inset width: 4)
			help:'Click to select a simple inset border' translated.
		self borderPrototype: (BorderStyle complexFramed width: 4)
			help:'Click to select a complex framed border' translated.
		self borderPrototype: (BorderStyle complexRaised width: 4)
			help:'Click to select a complex raised border' translated.
		self borderPrototype: (BorderStyle complexInset width: 4)
			help:'Click to select a complex inset border' translated.
		self borderPrototype: (BorderStyle complexAltFramed width: 4)
			help:'Click to select a complex framed border' translated.
		self borderPrototype: (BorderStyle complexAltRaised width: 4)
			help:'Click to select a complex raised border' translated.
		self borderPrototype: (BorderStyle complexAltInset width: 4)
			help:'Click to select a complex inset border' translated.
	}


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForBorderWidth [

	^(self inARow: {
		self
			buildFakeSlider: 'Border width' translated
			selector: #adjustTargetBorderWidth:
			help: 'Drag in here to change the border width' translated
	}) hResizing: #shrinkWrap


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForCornerRoundingToggle [

	^self inARow: {
		self
			directToggleButtonFor: myTarget 
			getter: #wantsRoundedCorners setter: #toggleCornerRounding
			help: 'Turn rounded corners on or off' translated.
		self lockedString: ' Rounded corners' translated.
	}


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForDropShadowToggle [

	^self inARow: {
		self
			directToggleButtonFor: myTarget 
			getter: #hasDropShadow setter: #toggleDropShadow
			help: 'Turn drop shadows on or off' translated.
		self lockedString: ' Drop shadow color' translated.
	}

]

{ #category : #panes }
ObjectPropertiesMorph >> paneForGradientDirection [

	^(self inARow: {
		self
			buildFakeSlider: 'Direction' translated
			selector: #adjustTargetGradientDirection:
			help: 'Drag in here to change the direction of the gradient' translated
	}) hResizing: #shrinkWrap


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForGradientFillToggle [

	^self inARow: {
		self
			directToggleButtonFor: self 
			getter: #targetHasGradientFill
			setter: #toggleTargetGradientFill
			help: 'Turn gradient fill on or off' translated.
		self lockedString: ' Gradient fill' translated.
	}

]

{ #category : #panes }
ObjectPropertiesMorph >> paneForGradientOrigin [

	^(self inARow: {
		self
			buildFakeSlider: 'Origin' translated
			selector: #adjustTargetGradientOrigin:
			help: 'Drag in here to change the origin of the gradient' translated
	}) hResizing: #shrinkWrap


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForLockedToggle [

	^self inARow: {
		self
			directToggleButtonFor: myTarget 
			getter: #isLocked setter: #toggleLocked
			help: 'Turn lock on or off' translated.
		self lockedString: ' Lock' translated.
	}


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForMainColorPicker [

	^self 
		inAColumn: {
			self 
				colorPickerFor: self 
				getter: #numberOneColor 
				setter: #numberOneColor:.
			self lockedString: 'Color' translated},
			(simplePanel 
					ifFalse:[{(self paneForSolidFillToggle)  hResizing: #shrinkWrap}]
					ifTrue:[{}]) 
		named: #pickerForColor.


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForRadialGradientToggle [

	^self inARow: {
		self
			directToggleButtonFor: self 
			getter: #targetRadial setter: #toggleTargetRadial
			help: 'Turn radial gradient on or off' translated.
		self lockedString: ' Radial gradient' translated.
	}


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForShadowColorPicker [

	^self 
		inAColumn: {
			(self inAColumn: {
				self colorPickerFor: myTarget getter: #shadowColor setter: #shadowColor:.
				self paneForShadowOffset.
			}
			named: #pickerForShadowColor) layoutInset: 0.
			self paneForDropShadowToggle hResizing: #shrinkWrap.
		}


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForShadowOffset [

	^(self inARow: {
		self
			buildFakeSlider: 'Offset' translated
			selector: #adjustTargetShadowOffset:
			help: 'Drag in here to change the offset of the shadow' translated
	}) hResizing: #shrinkWrap


]

{ #category : #panes }
ObjectPropertiesMorph >> paneForSolidFillToggle [

	^self inARow: {
		self
			directToggleButtonFor: self 
			getter: #targetHasSolidFill
			setter: #toggleTargetSolidFill
			help: 'Turn solid fill on or off' translated.
		self lockedString: ' Solid fill' translated.
	}

]

{ #category : #panes }
ObjectPropertiesMorph >> paneForStickinessToggle [

	^self inARow: {
		self
			directToggleButtonFor: myTarget 
			getter: #isSticky setter: #toggleStickiness
			help: 'Turn stickiness on or off' translated.
		self lockedString: ' Sticky' translated.
	}


]

{ #category : #'connectors-visual properties' }
ObjectPropertiesMorph >> rebuild [
	| buttons |
	
	self removeAllMorphs.
	self addARow: {
		self lockedString: ('Properties for {1}' translated format: {myTarget name}).
	}.
	self addARow: {
		self inAColumn: {
			self paneForCornerRoundingToggle.
			self paneForStickinessToggle.
			self paneForLockedToggle.
		}.
	}.

	self addARow: {
		self paneForMainColorPicker.
		self paneFor2ndGradientColorPicker.
	}.
	self addARow: {
		self paneForBorderColorPicker.
		self paneForShadowColorPicker.
	}.

	buttons := OrderedCollection new.
	buttons addAll: {
	self 
			buttonNamed: 'Accept' translated action: #doAccept color: color lighter 
			help: 'keep changes made and close panel' translated.
		self 
			buttonNamed: 'Cancel' translated action: #doCancel color: color lighter 
			help: 'cancel changes made and close panel' translated.
	}.
	"Support possible presence of Connectors package."
	(self respondsTo: #addOptionalButtonsTo:) ifTrue: [ self addOptionalButtonsTo: buttons. ].
	
	self addARow: buttons.

	thingsToRevert := Dictionary new.
	"thingsToRevert at: #fillStyle: put: myTarget fillStyle."
	myTarget isSystemWindow ifTrue: [
		thingsToRevert at: #setWindowColor: put: myTarget paneColorToUse
	].
	thingsToRevert at: #hasDropShadow: put: myTarget hasDropShadow.
	thingsToRevert at: #shadowColor: put: myTarget shadowColor.
	(myTarget respondsTo: #borderColor:) ifTrue: [
		thingsToRevert at: #borderColor: put: myTarget borderColor.
	].

	thingsToRevert at: #borderWidth: put: myTarget borderWidth.
	thingsToRevert at: #cornerStyle: put: myTarget cornerStyle.
	thingsToRevert at: #sticky: put: myTarget isSticky.
	thingsToRevert at: #lock: put: myTarget isLocked.

]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> rebuildOptionalButtons [

	| answer |

	answer := #() .
	
	myTarget isTextMorph ifTrue: [
		answer := answer, {
			self 
				buttonNamed: 'Text' translated action: #doTextProperties color: color lighter 
				help: 'open a text properties panel for the morph' translated.
		}.
	].
	^answer
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> targetBorderColor [
	^myTarget borderStyle baseColor
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> targetBorderColor: aColor [
	"Need to replace the borderStyle or BorderedMorph will not 'feel' the change"
	myTarget borderStyle: (myTarget borderStyle copy baseColor: aColor).
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> targetHasGradientFill [

	^myTarget fillStyle isGradientFill
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> targetHasSolidFill [

	^myTarget fillStyle isSolidFill
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> targetRadial [

	myTarget fillStyle isGradientFill ifFalse: [^false].
	^myTarget fillStyle radial
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> tgt2ndGradientColor [

	myTarget fillStyle isGradientFill ifFalse: [^Color black].
	^myTarget fillStyle colorRamp last value
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> tgt2ndGradientColor: aColor [
	myTarget fillStyle isGradientFill ifFalse: [^Color black].
	myTarget fillStyle lastColor: aColor forMorph: myTarget hand: nil

]

{ #category : #panes }
ObjectPropertiesMorph >> toggleBorderStyle: provider with: arg1 from: arg2 [
	| oldStyle newStyle |
	oldStyle := myTarget borderStyle.
	newStyle := provider borderStyle copy.
	oldStyle width = 0 
		ifTrue:[newStyle width: 2]
		ifFalse:[newStyle width: oldStyle width].
	newStyle baseColor: oldStyle baseColor.
	myTarget borderStyle: newStyle.
	provider owner owner submorphsDo:[:m| m borderWidth: 0].
	provider owner borderWidth: 1.
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> toggleTargetGradientFill [

	self targetHasGradientFill ifTrue: [
		self makeTargetSolidFill
	] ifFalse: [
		self makeTargetGradientFill
	].
	self doEnables
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> toggleTargetRadial [

	| fs |

	(fs := myTarget fillStyle) isGradientFill ifFalse: [^self].
	fs radial: fs radial not.
	myTarget changed.
	self doEnables.
]

{ #category : #'as yet unclassified' }
ObjectPropertiesMorph >> toggleTargetSolidFill [

	self targetHasSolidFill ifTrue: [
		self makeTargetGradientFill
	] ifFalse: [
		self makeTargetSolidFill
	].
	self doEnables
]
