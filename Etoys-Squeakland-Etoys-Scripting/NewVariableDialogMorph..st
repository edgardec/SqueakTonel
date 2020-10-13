Class {
	#name : #NewVariableDialogMorph,
	#superclass : #GenericPropertiesMorph,
	#instVars : [
		'varNameText',
		'varTypeButton',
		'decimalPlacesButton'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting'
}

{ #category : #'as yet unclassified' }
NewVariableDialogMorph class >> new [
	^ self on: Morph new openInWorld
]

{ #category : #'as yet unclassified' }
NewVariableDialogMorph class >> on: morph [
	^ self basicNew initializeWith: morph
]

{ #category : #build }
NewVariableDialogMorph >> addArrowsOn: button [
	| arrowsHolder |
	arrowsHolder := (TileMorph addArrowsOn: button) anyOne owner.
	arrowsHolder center: button left + (arrowsHolder width / 2) + 2 @ button center y.

]

{ #category : #build }
NewVariableDialogMorph >> addDecimalPlaces [
	self addARow: {
		self inAColumn: {
			(self addARow: {
				self lockedString: 'Decimal places:' translated.
				self spacer.
				decimalPlacesButton := self buildDecimalPlacesButton
			} ) cellPositioning: #center.
		} named: #decimalPlaces.
	}.
	self addSeparator
]

{ #category : #actions }
NewVariableDialogMorph >> addNewVariable [
	| slotName |
	self targetPlayer 
		addInstanceVariableNamed: (slotName := self varAcceptableName)
		type: self varType
		value: (self targetPlayer initialValueForSlotOfType: self varType).
	(#(#Number #Point) includes: self varType)
		ifTrue: [
			self targetPlayer
				setPrecisionFor: slotName
				precision: self decimalPlaces]
]

{ #category : #build }
NewVariableDialogMorph >> addSeparator [
	(self addAColumn: {})
		wrapCentering: #topLeft;
		color: Color white;
		borderWidth: 2;
		borderColor: self color darker.
]

{ #category : #actions }
NewVariableDialogMorph >> askUserForDecimalPlaces [
	| list |
	list := #(0 1 2 3 4 5 6 7 8 9 10).
	^ UIManager 
		chooseFrom: (list collect: [:each | each asString])
		values: list
		title: ('How many decimal places? (currently {1})' translated
						format: {self decimalPlaces})
]

{ #category : #actions }
NewVariableDialogMorph >> askUserForNewType [
	"Put up a pop up offering the user a choice of valid types for user-defined variables."

	| typeChoices menuTitle |
	typeChoices := Vocabulary typeChoicesForUserVariables.
	menuTitle := 'Choose the TYPE
for {1}
' translated, '
(currently {2})' translated format: {self varAcceptableName. self varType}.
	^ UIManager default
		chooseFrom: (typeChoices collect: [:t | t translated])
		values: typeChoices
		title: menuTitle
]

{ #category : #build }
NewVariableDialogMorph >> buildDecimalPlacesButton [
	| button |
	button := SimpleButtonMorph new					
		labelString: self decimalPlaces asString font: Preferences standardEToysButtonFont;
		color: (Color r: 0.806 g: 1.0 b: 0.645);
		target: self;
		actionSelector: #chooseDecimalPlaces;
		extent: 200 @ (TextStyle defaultFont height + 10);
		cornerStyle: #square;
		borderStyle: BorderStyle raised;
		yourself.
	self addArrowsOn: button.
	^ button
	
]

{ #category : #build }
NewVariableDialogMorph >> buildVarTypeButton [
	| button |
	button := SimpleButtonMorph new					
		labelString: self varType translated font: Preferences standardEToysButtonFont;
		color: (Color r: 0.806 g: 1.0 b: 0.645);
		target: self;
		actionSelector: #chooseType;
		extent: 200 @ (TextStyle defaultFont height + 10);
		cornerStyle: #square;
		borderStyle: BorderStyle raised;
		yourself.
	self addArrowsOn: button.
	^ button
	
]

{ #category : #actions }
NewVariableDialogMorph >> chooseDecimalPlaces [
	self askUserForDecimalPlaces 
		ifNotNil: [:reply |
			decimalPlacesButton label: reply asString.
			self rebuild]
]

{ #category : #actions }
NewVariableDialogMorph >> chooseType [
	self askUserForNewType
		ifNotNil: [:newType |
			varTypeButton label: newType.
			self rebuild]
]

{ #category : #accessing }
NewVariableDialogMorph >> decimalPlaces [
	^ decimalPlacesButton
		ifNil: [Utilities 
				decimalPlacesForFloatPrecision: (self targetPlayer
					defaultFloatPrecisionFor: self varAcceptableName asSetterSelector)]
		ifNotNil: [:button| button label asNumber]
]

{ #category : #accessing }
NewVariableDialogMorph >> defaultBorderColor [
	^ self defaultColor darker
]

{ #category : #accessing }
NewVariableDialogMorph >> defaultColor [
	^ (Color r: 0.677 g: 0.935 b: 0.484) 
			mixed: 0.9 with: Color blue
]

{ #category : #actions }
NewVariableDialogMorph >> doAccept [
	self delete.
	self varName isEmpty ifTrue: [^ self].
	self addNewVariable
]

{ #category : #initialize }
NewVariableDialogMorph >> initialize [
	super initialize.
	self rebuild
]

{ #category : #initialize }
NewVariableDialogMorph >> initializeWith: aMorph [
	myTarget := aMorph.
	self initialize
]

{ #category : #accessing }
NewVariableDialogMorph >> morphicLayerNumber [

	^10.6
]

{ #category : #build }
NewVariableDialogMorph >> newTextMorph [
	^ TextMorph new autoFit: false;
		 extent: 200 @ (TextStyle defaultFont height + 6);
		 borderWidth: 1;
		 backgroundColor: Color white;
		 borderColor: Color gray;
		 centered
]

{ #category : #build }
NewVariableDialogMorph >> rebuild [
	| buttonColor itsName enableDecimalPlaces |
	self removeAllMorphs.
	self addAColumn: {
		self lockedString: self title.
	}.
	self addSeparator.

	self addARow: {
		self inAColumn: {
			(self addARow: {
				self lockedString: 'Name:' translated.
				self spacer.
				varNameText := self newTextMorph 
										contentsWrapped: self varName;
										selectAll;
										crAction: (MessageSend
											receiver: self
											selector: #doAccept);
										yourself
			}) cellPositioning: #center.
			self inAColumn: {
								(self addARow: {
									self lockedString: 'Type:' translated.
									self spacer.
									varTypeButton := self buildVarTypeButton
								}) cellPositioning: #center.
								} named: #varType.
		}
	}.
	self currentHand newKeyboardFocus: varNameText.
	self addSeparator.
	self addDecimalPlaces.
	enableDecimalPlaces := false.
	(#(#Number #Point) includes: self varType)
		ifTrue: [ enableDecimalPlaces := true].
	self allMorphsDo: [ :each |
				itsName := each knownName. 
				(#(decimalPlaces) includes: itsName) ifTrue:
							[self enable: each when: enableDecimalPlaces]].

	


	buttonColor := self color lighter.
	self addARow: {
		self inAColumn: {
			(self addARow: {
				self 
					buttonNamed: 'Accept' translated action: #doAccept color: buttonColor
					help: 'keep changes made and close panel' translated.
				self 
					buttonNamed: 'Cancel' translated action: #doCancel color: buttonColor
					help: 'cancel changes made and close panel' translated.
			}) listCentering: #center
		}
	}
]

{ #category : #build }
NewVariableDialogMorph >> spacer [
	^ AlignmentMorph newVariableTransparentSpacer 
]

{ #category : #accessing }
NewVariableDialogMorph >> target [
	^ myTarget
]

{ #category : #accessing }
NewVariableDialogMorph >> targetPlayer [
	^ self target assuredPlayer
]

{ #category : #accessing }
NewVariableDialogMorph >> title [
	^ 'Add new variable' translated
]

{ #category : #accessing }
NewVariableDialogMorph >> varAcceptableName [
	^ ScriptingSystem
		acceptableSlotNameFrom: self varName
		forSlotCurrentlyNamed: nil
		asSlotNameIn: self targetPlayer
		world: self targetPlayer costume world
]

{ #category : #accessing }
NewVariableDialogMorph >> varName [
	^ varNameText
		ifNil: [| usedNames |
			usedNames := self targetPlayer class instVarNames.
			Utilities
				keyLike: ('var' translated, (usedNames size + 1) asString)
				satisfying: [:aKey | (usedNames includes: aKey) not]]
		ifNotNil: [:text | text contents string]
]

{ #category : #accessing }
NewVariableDialogMorph >> varType [
	"Answer the symbol representing the chosen value type for the variable."

	^ varTypeButton
		ifNil: [self targetPlayer initialTypeForSlotNamed: self varAcceptableName]
		ifNotNil: [:button| 
			Vocabulary typeChoicesForUserVariables
				detect: [:each |
					each translated = button label]
				ifNone: [button label asSymbol]]
]
