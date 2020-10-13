"
ButtonPropertiesMorph basicNew
		targetMorph: self;
		initialize;
		openNearTarget
"
Class {
	#name : #ButtonPropertiesMorph,
	#superclass : #GenericPropertiesMorph,
	#category : #'Etoys-Squeakland-Morphic-Experimental'
}

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> acceptDroppingMorph: aMorph event: evt in: aSubmorph [

	| why |

	self clearDropHighlightingEvt: evt morph: aSubmorph.
	why := aSubmorph valueOfProperty: #intentOfDroppedMorphs.
	why == #changeTargetMorph ifTrue: [
		self targetProperties replaceVisibleMorph: aMorph.
		myTarget := aMorph.
		self rebuild.
		^true
	].
	why == #changeTargetTarget ifTrue: [
		(aMorph setAsActionInButtonProperties: self targetProperties) ifFalse: [
			^false
		].
		^true
	].
	why == #changeTargetMouseDownLook ifTrue: [
		self targetProperties mouseDownLook: aMorph.
		^false
	].
	why == #changeTargetMouseEnterLook ifTrue: [
		self targetProperties mouseEnterLook: aMorph.
		^false
	].

	^false

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> addTextToTarget [

	self targetProperties currentTextInButton ifNil: [
		self targetProperties addTextToButton: '???'.
	].
	self targetProperties currentTextInButton openATextPropertySheet.

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> adjustTargetMouseDownHaloSize: aFractionalPoint [

	self targetProperties mouseDownHaloWidth: ((aFractionalPoint x * 10) rounded max: 0).

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> adjustTargetMouseOverHaloSize: aFractionalPoint [

	self targetProperties mouseOverHaloWidth: ((aFractionalPoint x * 10) rounded max: 0).

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> adjustTargetRepeatingInterval: aFractionalPoint [

	| n |

	n := 2 raisedTo: ((aFractionalPoint x * 12) rounded max: 1).
	self targetProperties delayBetweenFirings: n.

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> allowDropsInto: aMorph withIntent: aSymbol [

	aMorph
		on: #mouseEnterDragging send: #mouseEnterDraggingEvt:morph: to: self;
		on: #mouseLeaveDragging send: #mouseLeaveDraggingEvt:morph: to: self;
		on: #mouseLeave send: #clearDropHighlightingEvt:morph: to: self;
		setProperty: #handlerForDrops toValue: self;
		setProperty: #intentOfDroppedMorphs toValue: aSymbol;
		borderWidth: 1;
		borderColor: Color gray

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> attachMorphOfClass: aClass to: aHand [

	aHand attachMorph: aClass new
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> clearDropHighlightingEvt: evt morph: aMorph [

	aMorph color: Color transparent.

]

{ #category : #initialization }
ButtonPropertiesMorph >> defaultBorderColor [
"answer the default border color/fill style for the receiver"
	^ self defaultColor darker
]

{ #category : #initialization }
ButtonPropertiesMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color
		r: 0.935
		g: 0.839
		b: 0.452
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> doEnables [

	| itsName |

	self allMorphsDo: [ :each |
		itsName := each knownName.
		itsName == #pickerForMouseDownColor ifTrue: [
			self enable: each when: self targetWantsRollover
		].
		itsName == #pickerForMouseOverColor ifTrue: [
			self enable: each when: self targetWantsRollover
		].
		itsName == #paneForRepeatingInterval ifTrue: [
			self enable: each when: self targetRepeatingWhileDown
		].
	].

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> doRemoveProperties [

	myTarget buttonProperties: nil.
	self delete.
]

{ #category : #initialization }
ButtonPropertiesMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	myTarget
		ifNil: [myTarget := RectangleMorph new openInWorld].

	thingsToRevert at: #buttonProperties: put: myTarget buttonProperties.
	self rebuild
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> mouseDownEvent: evt for: aSubmorph [

	| why aMenu |

	why := aSubmorph valueOfProperty: #intentOfDroppedMorphs.
	why == #changeTargetMorph ifTrue: [
		aMenu := MenuMorph new
			defaultTarget: self.
		{
			{'Rectangle'. RectangleMorph}.
			{'Ellipse'. EllipseMorph}
		} do: [ :pair |
			aMenu	
				add: pair first translated
				target: self 
				selector: #attachMorphOfClass:to: 
				argumentList: {pair second. evt hand}.
		].
		aMenu popUpEvent: evt in: self world.
		^self
	].


]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> mouseEnterDraggingEvt: evt morph: aMorph [

	aMorph color: (Color red alpha: 0.5)
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> mouseLeaveDraggingEvt: evt morph: aMorph [

	self clearDropHighlightingEvt: evt morph: aMorph.

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForActsOnMouseDownToggle [

	^self inARow: {
		self
			directToggleButtonFor: self 
			getter: #targetActsOnMouseDown
			setter: #toggleTargetActsOnMouseDown
			help: 'If the button is to act when the mouse goes down' translated.
		self lockedString: ' Mouse-down action' translated.
	}

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForActsOnMouseUpToggle [

	^self inARow: {
		self
			directToggleButtonFor: self 
			getter: #targetActsOnMouseUp
			setter: #toggleTargetActsOnMouseUp
			help: 'If the button is to act when the mouse goes up' translated.
		self lockedString: ' Mouse-up action' translated.
	}

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForButtonSelectorReport [

	^self inARow: {
		self lockedString: 'Action: ' translated.
 		UpdatingStringMorph new
			useStringFormat;
			getSelector: #actionSelector;
			target: self targetProperties;
			growable: true;
			minimumWidth: 24;
			lock.
	}

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForButtonTargetReport [

	| r |

	r := self inARow: {
		self lockedString: 'Target: ' translated.
 		UpdatingStringMorph new
			useStringFormat;
			getSelector: #target;
			target: self targetProperties;
			growable: true;
			minimumWidth: 24;
			lock.
	}.
	r hResizing: #shrinkWrap.
	self allowDropsInto: r withIntent: #changeTargetTarget.
	r setBalloonText: 'Drop another morph here to change the target and action of this button. (Only some morphs will work)' translated.
	^self inARow: {r}



]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForChangeMouseDownLook [

	| r |
	r := self inARow: {
		self lockedString: ' Mouse-down look ' translated.
	}.
	self allowDropsInto: r withIntent: #changeTargetMouseDownLook.
	r setBalloonText: 'Drop another morph here to change the visual appearance of this button when the mouse is clicked in it.' translated.
	^r

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForChangeMouseEnterLook [

	| r |
	r := self inARow: {
		self lockedString: ' Mouse-enter look ' translated.
	}.
	self allowDropsInto: r withIntent: #changeTargetMouseEnterLook.
	r setBalloonText: 'Drop another morph here to change the visual appearance of this button when the mouse enters it.' translated.
	^r

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForChangeVisibleMorph [

	| r |
	r := self inARow: {
		self lockedString: ' Change morph ' translated.
	}.
	r on: #mouseDown send: #mouseDownEvent:for: to: self.
	self allowDropsInto: r withIntent: #changeTargetMorph.
	r setBalloonText: 'Drop another morph here to change the visual appearance of this button. Or click here to get a menu of possible replacement morphs.' translated.
	^r

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForMouseDownColorPicker [

	^self 
		inAColumn: {
			(self inAColumn: {
				self colorPickerFor: self targetProperties
						 getter: #mouseDownHaloColor setter: #mouseDownHaloColor:.
				self lockedString: 'mouse-down halo color' translated.
				self paneForMouseDownHaloWidth.
			}
			named: #pickerForMouseDownColor) layoutInset: 0.
		}

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForMouseDownHaloWidth [

	^(self inARow: {
		self
			buildFakeSlider: #valueForMouseDownHaloWidth 
			selector: #adjustTargetMouseDownHaloSize:
			help: 'Drag in here to change the halo width' translated
	}) hResizing: #shrinkWrap

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForMouseOverColorPicker [

	^self 
		inAColumn: {
			(self inAColumn: {
				self colorPickerFor: self targetProperties
						 getter: #mouseOverHaloColor setter: #mouseOverHaloColor:.
				self lockedString: 'mouse-over halo color' translated.
				self paneForMouseOverHaloWidth.
			}
			named: #pickerForMouseOverColor) layoutInset: 0.
		}

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForMouseOverHaloWidth [

	^(self inARow: {
		self
			buildFakeSlider: #valueForMouseOverHaloWidth
			selector: #adjustTargetMouseOverHaloSize:
			help: 'Drag in here to change the halo width' translated
	}) hResizing: #shrinkWrap

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForRepeatingInterval [

	^(self 
		inAColumn: {
			self
				buildFakeSlider: #valueForRepeatingInterval
				selector: #adjustTargetRepeatingInterval:
				help: 'Drag in here to change how often the button repeats while the mouse is down' translated
		}
		 named: #paneForRepeatingInterval
	) hResizing: #shrinkWrap

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForWantsFiringWhileDownToggle [

	^self inARow: {
		self
			directToggleButtonFor: self 
			getter: #targetRepeatingWhileDown
			setter: #toggleTargetRepeatingWhileDown
			help: 'Turn repeating while mouse is held down on or off' translated.
		self lockedString: ' Mouse-down repeating ' translated.
	}

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> paneForWantsRolloverToggle [

	^self inARow: {
		self
			directToggleButtonFor: self 
			getter: #targetWantsRollover
			setter: #toggleTargetWantsRollover
			help: 'Turn mouse-over highlighting on or off' translated.
		self lockedString: ' Mouse-over highlighting' translated.
	}

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> rebuild [

	| buttonColor |

	myTarget ensuredButtonProperties.
	"self targetProperties unlockAnyText."	"makes styling the text easier"

	self removeAllMorphs.
	self addAColumn: {
		self lockedString: ('Button Properties for {1}' translated format: {myTarget name}).
	}.
	self addAColumn: {
		self paneForButtonTargetReport.
	}.
	self addAColumn: {
		self paneForButtonSelectorReport.
	}.

	self addAColumn: {
		(self inARow: {
			self paneForActsOnMouseDownToggle.
			self paneForActsOnMouseUpToggle.
		})  hResizing: #shrinkWrap.
	}.

	self addAColumn: {
		self inARow: {
			(self paneForWantsFiringWhileDownToggle) hResizing: #shrinkWrap.
			self paneForRepeatingInterval.
		}.
	}.

	self addAColumn: {
		(self inAColumn: {
			self paneForWantsRolloverToggle.
		}) hResizing: #shrinkWrap.
	}.
	self addARow: {
		self paneForMouseOverColorPicker.
		self paneForMouseDownColorPicker.
	}.
	self addARow: {
		self paneForChangeMouseEnterLook.
		self paneForChangeMouseDownLook.
	}.

	buttonColor := color lighter.
	self addARow: {
		self inAColumn: {
			self addARow: {
				self 
					buttonNamed: 'Add label' translated action: #addTextToTarget color: buttonColor
					help: 'add some text to the button' translated.
				self 
					buttonNamed: 'Remove label' translated action: #removeTextFromTarget color: buttonColor
					help: 'remove text from the button' translated.
			}.
			self addARow: {
				self 
					buttonNamed: 'Accept' translated action: #doAccept color: buttonColor
					help: 'keep changes made and close panel' translated.
				self 
					buttonNamed: 'Cancel' translated action: #doCancel color: buttonColor
					help: 'cancel changes made and close panel' translated.
				self transparentSpacerOfSize: 10@3.
				self 
					buttonNamed: 'Main' translated action: #doMainProperties color: color lighter 
					help: 'open a main properties panel for the morph' translated.
				self 
					buttonNamed: 'Remove' translated action: #doRemoveProperties color: color lighter 
					help: 'remove the button properties of this morph' translated.
			}.
		}.
		self inAColumn: {
			self paneForChangeVisibleMorph
		}.
	}.

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> removeTextFromTarget [

	self targetProperties addTextToButton: nil.

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> targetActsOnMouseDown [

	^self targetProperties actWhen == #mouseDown
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> targetActsOnMouseUp [

	^self targetProperties actWhen == #mouseUp
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> targetProperties [

	^myTarget ensuredButtonProperties
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> targetRepeatingWhileDown [

	^self targetProperties delayBetweenFirings notNil
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> targetWantsRollover [

	^self targetProperties wantsRolloverIndicator
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> toggleTargetActsOnMouseDown [

	| prop |

	prop := self targetProperties.
	prop actWhen: (prop actWhen == #mouseDown ifTrue: [nil] ifFalse: [#mouseDown])
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> toggleTargetActsOnMouseUp [

	| prop |

	prop := self targetProperties.
	prop actWhen: (prop actWhen == #mouseUp ifTrue: [nil] ifFalse: [#mouseUp])
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> toggleTargetRepeatingWhileDown [

	| prop |

	prop := self targetProperties.
	prop delayBetweenFirings: (prop delayBetweenFirings ifNil: [1024] ifNotNil: [nil])
	
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> toggleTargetWantsRollover [

	self targetProperties wantsRolloverIndicator: self targetProperties wantsRolloverIndicator not
]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> valueForMouseDownHaloWidth [

	^ 'mouse-down halo width: ' translated, self targetProperties mouseDownHaloWidth printString

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> valueForMouseOverHaloWidth [

	^ 'mouse-over halo width: ' translated, self targetProperties mouseOverHaloWidth printString

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> valueForRepeatingInterval [

	| n s |

	n := self targetProperties delayBetweenFirings.

	s := n ifNil: [
		'*none*'
	] ifNotNil: [
		n < 1000 ifTrue: [n printString,' ms'] ifFalse: [(n // 1000) printString,' secs']
	].
	^'interval: ' translated, s

]

{ #category : #'as yet unclassified' }
ButtonPropertiesMorph >> wantsDroppedMorph: aMorph event: evt in: aSubmorph [

	| why |

	why := aSubmorph valueOfProperty: #intentOfDroppedMorphs.
	^why notNil

" toValue: #changeTargetMorph.

	^true"
]
