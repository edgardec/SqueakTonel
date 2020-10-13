Class {
	#name : #GenericPropertiesMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'myTarget',
		'thingsToRevert'
	],
	#category : #'Etoys-Experimental'
}

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> addARow: anArray [

	^(super addARow: anArray) cellPositioning: #topLeft
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> buildFakeSlider: nameStringOrSymbol selector: aSymbol help: helpString [ 
	| col |
	col := self inAColumn: { 
						(nameStringOrSymbol isSymbol) 
							ifTrue: 
								[(UpdatingStringMorph new)
									useStringFormat;
									getSelector: nameStringOrSymbol;
									target: self;
									growable: true;
									minimumWidth: 24;
									lock]
							ifFalse: [self lockedString: nameStringOrSymbol]}.
	col
		borderWidth: 2;
		borderColor: color darker;
		color: color muchLighter;
		hResizing: #shrinkWrap;
		setBalloonText: helpString;
		on: #mouseMove
			send: #mouseAdjust:in:
			to: self;
		on: #mouseDown
			send: #mouseAdjust:in:
			to: self;
		on: #mouseUp
			send: #clearSliderFeedback
			to: self;
		setProperty: #changeSelector toValue: aSymbol.
	^col
]

{ #category : #initialization }
GenericPropertiesMorph >> buttonNamed: aString action: aSymbol color: aColor help: helpString [
	"Answer a button with the string provided as label, with the receiver as target, and with the given action; give it the color specified, and associate the given help-sting with it."

	| f col |
	f := SimpleButtonMorph new
		target: self;
		labelString: aString font: Preferences standardEToysButtonFont;
		color: aColor;
		actionSelector: aSymbol;
		setBalloonText: helpString.
	col := (self inAColumn: {f}) hResizing: #shrinkWrap.
	^ col
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> clearSliderFeedback [

	| feedBack |

	feedBack := self valueOfProperty: #sliderFeedback ifAbsent: [^self].
	feedBack delete
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> colorPickerFor: target getter: getterSymbol setter: setterSymbol [ 
	^ NewColorPickerMorph useIt
		ifTrue:
			[ NewColorPickerMorph
				on: target
				originalColor: (target perform: getterSymbol)
				setColorSelector: setterSymbol
				forPropertiesPanel: true
				]
		ifFalse:
			[ ColorPickerMorph new
				 initializeForPropertiesPanel ;
				 target: target ;
				 selector: setterSymbol ;
				 originalColor: (target perform: getterSymbol) ]
]

{ #category : #initialization }
GenericPropertiesMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 4
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> directToggleButtonFor: target getter: getterSymbol setter: setterSymbol help: helpText [

	^(EtoyUpdatingThreePhaseButtonMorph checkBox)
		target: target;
		actionSelector: setterSymbol;
		arguments: #();
		getSelector: getterSymbol;
		setBalloonText: helpText;
		step

]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> doAccept [

	self delete
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> doCancel [

	thingsToRevert keysAndValuesDo: [ :k :v |
		myTarget perform: k with: v
	].
	self delete
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> doEnables [
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> doMainProperties [

	myTarget openAPropertySheet.
	self delete.

]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> doTextProperties [

	myTarget openATextPropertySheet.
	self delete.

]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> enable: aMorph when: aBoolean [

	aBoolean = (aMorph hasProperty: #disabledMaskColor) ifFalse: [^self].
	aBoolean ifTrue: [
		aMorph 
			removeProperty: #disabledMaskColor;
			lock: false;
			changed.
		^self
	].
	aMorph 
		setProperty: #disabledMaskColor toValue: (Color black alpha: 0.5);
		lock: true;
		changed

]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> inAColumn: aCollectionOfMorphs [

	| col |
	col := AlignmentMorphBob1 newColumn
		color: Color transparent;
		vResizing: #shrinkWrap;
		layoutInset: 1;
		wrapCentering: #center;
		cellPositioning: #topCenter.
	aCollectionOfMorphs do: [ :each | col addMorphBack: each].
	^col
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> inAColumn: anArray named: aString [

	^(self inAColumn: anArray) setNamePropertyTo: aString
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> inARow: aCollectionOfMorphs [

	| row |
	row := AlignmentMorphBob1 newRow
		color: Color transparent;
		vResizing: #shrinkWrap;
		layoutInset: 1;
		wrapCentering: #center;
		cellPositioning: #leftCenter.
	aCollectionOfMorphs do: [ :each | row addMorphBack: each].
	^row

]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> inARow: anArray named: aString [

	^(self inARow: anArray) setNamePropertyTo: aString
]

{ #category : #initialization }
GenericPropertiesMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""

	self layoutInset: 4.
	self hResizing: #shrinkWrap.
	self vResizing: #shrinkWrap.
	thingsToRevert := OrderedDictionary new. "to control order of execution"
	self useRoundedCorners
]

{ #category : #olpc }
GenericPropertiesMorph >> lockedString: s [
	"Answer a StringMorph with the given string as contents, rendered in a font appropriate for deployment within the receiver."

	^ (StringMorph contents: s font: Preferences standardEToysFont) lock
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> mouseAdjust: evt in: aMorph [

	| fractionalPosition feedBack testExtent |

	feedBack := self showSliderFeedback: nil.
	feedBack world ifNil: [
		feedBack bottomLeft: evt cursorPoint - (0@8)
	].
	testExtent := 100@100.		"the real extent may change"
	fractionalPosition := (evt cursorPoint - aMorph topLeft) / testExtent.
	self 
		perform: (aMorph valueOfProperty: #changeSelector)
		with: fractionalPosition

]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> openNearTarget [
	self openNearMorph: myTarget
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> showSliderFeedback: aString [

	| feedBack |

	feedBack := self 
		valueOfProperty: #sliderFeedback 
		ifAbsent: [
			feedBack := AlignmentMorph newRow
				hResizing: #shrinkWrap;
				vResizing: #shrinkWrap;
				color: (Color yellow" alpha: 0.6");
				addMorph: (
					TextMorph new 
						contents: '?';
						beAllFont: ((TextStyle default fontOfSize: 24) emphasized: 1)
				).
			self setProperty: #sliderFeedback toValue: feedBack.
			feedBack
		].
	aString ifNotNil: [
		feedBack firstSubmorph contents: aString asString.
		feedBack world ifNil: [feedBack openInWorld].
	].
	^feedBack
]

{ #category : #'stepping and presenter' }
GenericPropertiesMorph >> step [

	super step.
	self doEnables.
	myTarget isInWorld ifFalse:[self delete]
]

{ #category : #testing }
GenericPropertiesMorph >> stepTime [

	^500
]

{ #category : #'as yet unclassified' }
GenericPropertiesMorph >> targetMorph: x [

	myTarget := x
]

{ #category : #'dropping\/grabbing' }
GenericPropertiesMorph >> wantsToBeDroppedInto: aMorph [
	"Return true if it's okay to drop the receiver into aMorph"
	^aMorph isWorldMorph or:[Preferences systemWindowEmbedOK]
]
