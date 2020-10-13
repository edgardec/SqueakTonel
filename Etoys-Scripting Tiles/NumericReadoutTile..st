"
A readout tile for Number-valued variables.
If it bears property #PointValued, it will actually represent a Point-valued variable.
"
Class {
	#name : #NumericReadoutTile,
	#superclass : #TileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #scripting }
NumericReadoutTile class >> authoringPrototype [
	"Enclose my prototype in a SyntaxMorph."

	| aWatcher aTile aLine aColor ms slotMsg |

	aColor := Color r: 0.387 g: 0.581 b: 1.0.
	aTile := self new typeColor: aColor.
	aWatcher := UpdatingStringMorph new.
	aWatcher growable: true;
		setToAllowTextEdit;
		getSelector: nil;
		putSelector: nil.
	aWatcher target: nil.
	aTile addMorphBack: aWatcher.
	aTile addArrows.
	aTile setLiteralTo: 5 width: 30.

	"This is the long way around to do this..."
	ms := MessageSend receiver: nil selector: #aNumber arguments: #().
	slotMsg := ms asTilesIn: Player globalNames: false.
		"For CardPlayers, use 'aPlayer'.  For others, name it, and use its name."
	ms := MessageSend receiver: 3 selector: #= arguments: #(5).
	aLine := ms asTilesIn: Player globalNames: false.
	aLine firstSubmorph delete.	
	aLine addMorphFront: (slotMsg submorphs second) firstSubmorph.
	aLine firstSubmorph setNameTo: 'label'.
	aLine addMorphFront: (Morph new transparentSpacerOfSize: 3@3).
	aLine lastSubmorph delete.
	aLine lastSubmorph delete.
	aLine color: aColor; setNameTo: 'Number (fancy)'.
	aLine addMorphBack: (Morph new transparentSpacerOfSize: 3@3).
	aLine addMorphBack: aTile.
	aLine readOut setNameTo: 'value'.
	aLine cellPositioning: #leftCenter.
	aWatcher step; fitContents.
	^ aLine markAsPartsDonor.
]

{ #category : #'instance creation' }
NumericReadoutTile class >> borderedPrototype [
	"Just number and up/down arrows"

	| aWatcher aTile |

	aTile := self new typeColor: (Color r: 0.387 g: 0.581 b: 1.0).
	aWatcher := UpdatingStringMorph new.
	aWatcher growable: true; setNameTo: 'value'.
	aTile addMorphBack: aWatcher.
	aTile addArrows; setNameTo: 'Number (mid)'.
	aTile setLiteralTo: 5 width: 30.
	aWatcher step; fitContents; setToAllowTextEdit.
	^ aTile extent: 30@24; markAsPartsDonor
]

{ #category : #'instance creation' }
NumericReadoutTile class >> simplePrototype [
	"Bare number readout.  Will keep up to data with a number once it has target, getterSelector, setterSelector."

	^ (UpdatingStringMorph new) contents: '5'; growable: true; setToAllowTextEdit; 
		step; fitContents; setNameTo: 'Number (bare)'; markAsPartsDonor
]

{ #category : #'instance creation' }
NumericReadoutTile class >> supplementaryPartsDescriptions [
	"Answer additional items for the parts bin"

	Preferences universalTiles ifFalse: [^ #()].

	^ {DescriptionForPartsBin
		formalName: 'Number (fancy)' translatedNoop
		categoryList: {'Basic' translatedNoop}
		documentation: 'A number readout for a Stack.  Shows current value.  Click and type the value.  Shift-click on title to edit.' translatedNoop
		globalReceiverSymbol: #NumericReadoutTile
		nativitySelector: #authoringPrototype.

	   DescriptionForPartsBin
		formalName: 'Number (bare)' translatedNoop
		categoryList: {'Basic' translatedNoop}
		documentation: 'A number readout for a Stack.  Shows current value.  Click and type the value.' translatedNoop
		globalReceiverSymbol: #NumericReadoutTile
		nativitySelector: #simplePrototype.

	   DescriptionForPartsBin
		formalName: 'Number (mid)' translatedNoop
		categoryList: {'Basic' translatedNoop}
		documentation: 'A number readout for a Stack.  Shows current value.  Click and type the value.' translatedNoop
		globalReceiverSymbol: #NumericReadoutTile
		nativitySelector: #borderedPrototype}
]

{ #category : #accessing }
NumericReadoutTile >> abandonLabelFocus [
	| aLabel |
	"If the receiver's label has editing focus, abandon it"
	self flag: #arNote. "Probably unnecessary"
	(aLabel := self labelMorph) ifNotNil:
		[aLabel hasFocus ifTrue:
			[aLabel contents: aLabel readFromTarget.
			aLabel handsWithMeForKeyboardFocus do:
				[:aHand | aHand releaseKeyboardFocus]]]
]

{ #category : #misc }
NumericReadoutTile >> basicWidth [
	^ 26
]

{ #category : #mouse }
NumericReadoutTile >> handlesMouseMove: evt [
	^true
]

{ #category : #'parts bin' }
NumericReadoutTile >> initializeToStandAlone [
	"Enclose my prototype in a SyntaxMorph.  For the ObjectTool"

	| aWatcher aTile aLine aColor ms slotMsg |

	super initializeToStandAlone.
	aColor := Color r: 0.387 g: 0.581 b: 1.0.
	aTile := self typeColor: aColor.
	aWatcher := UpdatingStringMorph new.
	aWatcher growable: true;
		getSelector: nil;
		putSelector: nil;
		setToAllowTextEdit.
	aWatcher target: nil.
	aTile addMorphBack: aWatcher.
	aTile addArrows.
	aTile setLiteralTo: 5 width: 30.

	ms := MessageSend receiver: nil selector: #aNumber arguments: #().
	slotMsg := ms asTilesIn: Player globalNames: false.
		"For CardPlayers, use 'aPlayer'.  For others, name it, and use its name."
	ms := MessageSend receiver: 3 selector: #= arguments: #(5).
	aLine := ms asTilesIn: Player globalNames: false.
	aLine firstSubmorph delete.		"A little over-complicated?  Yes?"
	aLine addMorphFront: (slotMsg submorphs second) firstSubmorph.
	aLine addMorphFront: (Morph new transparentSpacerOfSize: 3@3).
	aLine lastSubmorph delete.
	aLine lastSubmorph delete.
	aLine color: aColor.
	aLine addMorphBack: (Morph new transparentSpacerOfSize: 3@3).
	aLine addMorphBack: aTile.
	aLine cellPositioning: #leftCenter.
	aWatcher step; fitContents.
	^ aLine markAsPartsDonor.
]

{ #category : #accessing }
NumericReadoutTile >> isNumericReadoutTile [
	^true
]

{ #category : #accessing }
NumericReadoutTile >> literal: anObject [ 
	literal := anObject.
	self updateLiteralLabel.
	self labelMorph
		ifNotNil: [:label | label informTarget]
]

{ #category : #accessing }
NumericReadoutTile >> literalFromContents [
	| label |
	label := self labelMorph
				ifNil: [^ super literal].
	label step.
	^ literal := label valueFromContents
]

{ #category : #misc }
NumericReadoutTile >> minimumWidth [
	^ 40
]

{ #category : #'event handling' }
NumericReadoutTile >> mouseStillDown: evt [ 
	(self labelMorph notNil
			and: [self labelMorph containsPoint: evt cursorPoint])
		ifTrue: [^ self labelMorph mouseDown: evt].
	^ super mouseStillDown: evt
]

{ #category : #literal }
NumericReadoutTile >> setLiteralTo: anObject width: w [
	"like literal:width: but does not inform the target"
	literal := anObject.
	self updateLiteralLabel.
	submorphs last setWidth: w.
	self updateLiteralLabel
]
