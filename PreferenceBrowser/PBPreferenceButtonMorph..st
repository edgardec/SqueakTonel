Class {
	#name : #PBPreferenceButtonMorph,
	#superclass : #Morph,
	#instVars : [
		'moreButton',
		'model',
		'preference',
		'preferenceMorphicView',
		'preferenceView'
	],
	#category : #PreferenceBrowser
}

{ #category : #'instance creation' }
PBPreferenceButtonMorph class >> preference: aPreference [
	^self preference: aPreference model: nil
]

{ #category : #'instance creation' }
PBPreferenceButtonMorph class >> preference: aPreference model: aModel [
	^self new
		initializeWithPreference: aPreference model: aModel;
		yourself.
]

{ #category : #'extra controls' }
PBPreferenceButtonMorph >> actionButtons [
	^self preferenceView actions collect: [:aTuple |
		self basicButton
				label: aTuple first;
				target: aTuple second;
				actionSelector: aTuple third;
				arguments: aTuple fourth;
				setBalloonText: aTuple fifth ]
]

{ #category : #'extra controls' }
PBPreferenceButtonMorph >> addExtraControls [
	| m |
	m := self horizontalPanel
		cellGap: 3;
		addAllMorphs: self actionButtons;
		addMorphBack: self horizontalFiller;
		addMorphBack: self moreButton;
		yourself.
	self 
		addMorphBack: (self blankSpaceOf: 2@2);
		addMorphBack: self preferenceHelpTextMorph;
		addMorphBack: self horizontalLine;
		addMorphBack: self preferenceCodeTextMorph;
		fullBounds; "to force a layout compute needed by the textMorphs's autoFit"
		addMorphBack: m

]

{ #category : #'extra controls' }
PBPreferenceButtonMorph >> advancedOptionsSelected [
	self preferenceView offerPreferenceNameMenu: self model
]

{ #category : #'utility methods' }
PBPreferenceButtonMorph >> basicButton [

	^ PluggableButtonMorph new
		target: self;
		layoutInset: (10@5 corner: 10@5);
		yourself
]

{ #category : #'utility methods' }
PBPreferenceButtonMorph >> basicPanel [
	^BorderedMorph new
		beTransparent;
		extent: 0@0;
		borderWidth: 0;
		layoutInset: 0;
		cellGap: 0;
		layoutPolicy: TableLayout new;
		listCentering: #topLeft;
		cellPositioning: #center;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		yourself
]

{ #category : #'utility methods' }
PBPreferenceButtonMorph >> blankSpaceOf: aPoint [
	^Morph new 
		beTransparent;
		extent: aPoint; 
		yourself
]

{ #category : #'utility methods' }
PBPreferenceButtonMorph >> caseInsensitiveBeginsWith: prefix in: string [
	^(string findString: prefix startingAt: 1 caseSensitive: false) = 1
]

{ #category : #highlighting }
PBPreferenceButtonMorph >> highlightOff [
	self beTransparent.
	self label
		color: ((UserInterfaceTheme current get: #textColor for: PluggableListMorph) ifNil: [Color black]);
		font: ((UserInterfaceTheme current get: #font for: PluggableListMorph) ifNil: [TextStyle defaultFont]).
	self removeExtraControls.
]

{ #category : #highlighting }
PBPreferenceButtonMorph >> highlightOn [
	
	self color: ((UserInterfaceTheme current get: #selectionColor for: PluggableListMorph) ifNil: [Color gray alpha: 0.1]).

	self label
		color: ((UserInterfaceTheme current get: #selectionTextColor for: PluggableListMorph) ifNil: [Color black]);
		font: (((UserInterfaceTheme current get: #font for: PluggableListMorph) ifNil: [TextStyle defaultFont])
			emphasized: TextEmphasis bold emphasisCode).
	
	self addExtraControls.
]

{ #category : #'utility methods' }
PBPreferenceButtonMorph >> horizontalFiller [
	^self horizontalPanel
		hResizing: #spaceFill;
		yourself.
]

{ #category : #'utility methods' }
PBPreferenceButtonMorph >> horizontalLine [
	^self horizontalPanel
		hResizing: #spaceFill;
		height: 2;
		color: ((UserInterfaceTheme current get: #color for: PluggableListMorph) ifNil: [Color white]);
		yourself.
]

{ #category : #'utility methods' }
PBPreferenceButtonMorph >> horizontalPanel [
	^self basicPanel
		cellPositioning: #center;
		listDirection: #leftToRight;
		yourself.
]

{ #category : #initialization }
PBPreferenceButtonMorph >> initializeLayout [
	self layoutPolicy: TableLayout new;
		beTransparent;
		layoutInset: 0;
		cellGap: 0;
		listCentering: #topLeft;
		cellPositioning: #topLeft;
		listDirection: #topToBottom;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap.		
]

{ #category : #initialization }
PBPreferenceButtonMorph >> initializeWithPreference: aPreference model: aModel [
	preference := aPreference.
	model := aModel.
	self initializeLayout.
	self addMorphBack: self preferenceMorphicView.
	self highlightOff.
]

{ #category : #'preference accessing' }
PBPreferenceButtonMorph >> label [
	^self preferenceMorphicView firstSubmorph
]

{ #category : #accessing }
PBPreferenceButtonMorph >> model [
	^model
]

{ #category : #'extra controls' }
PBPreferenceButtonMorph >> moreButton [
	^moreButton ifNil: 
		[moreButton := self basicButton 
						label: 'more' translated; 
						setBalloonText: 
							'Click here for advanced options'translated;
						actionSelector: #advancedOptionsSelected]
]

{ #category : #'utility methods' }
PBPreferenceButtonMorph >> paneColor [
	| browser |
	browser := (self ownerChain 
		detect: [:ea | ea isKindOf: PreferenceBrowserMorph] 
		ifNone: [^Color black]) .
	^browser paneColor
]

{ #category : #'preference accessing' }
PBPreferenceButtonMorph >> preference [
	^preference
]

{ #category : #'preference accessing' }
PBPreferenceButtonMorph >> preferenceCode [
	
	^ self preference codeString withBlanksTrimmed
]

{ #category : #'preference accessing' }
PBPreferenceButtonMorph >> preferenceCodeText [

	| text |
	text := self preferenceCode asText
		addAttribute: (TextFontReference toFont: Preferences standardCodeFont);
		yourself.
	^ (Smalltalk classNamed: #SHTextStylerST80)
		ifNil: [text]
		ifNotNil: [:stylerClass | stylerClass new styledTextFor: text]
]

{ #category : #'extra controls' }
PBPreferenceButtonMorph >> preferenceCodeTextMorph [
	| text tm |
	text := self preferenceCodeText.
	tm := TextMorph new
		contents: text;
		wrapFlag: true;
		autoFit: true;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		margins: (5@0 corner: 5@0);
		visible: text notEmpty;
		yourself. "we don't want an empty textmorph showing"
	^tm
]

{ #category : #'preference accessing' }
PBPreferenceButtonMorph >> preferenceHelp [
	| help name |
	help := self preference helpString withBlanksTrimmed.
	name := self preference name.
	(self caseInsensitiveBeginsWith: name  in: help)
		ifTrue: [help := help allButFirst: name size].
	(help notEmpty and: [help first = $:])
		ifTrue: [help := help allButFirst].
	^help withBlanksTrimmed.

]

{ #category : #'preference accessing' }
PBPreferenceButtonMorph >> preferenceHelpText [
	^self preferenceHelp asText
		addAttribute: TextEmphasis italic;
		addAttribute: (TextColor color: ((UserInterfaceTheme current get: #textColor for: PluggableListMorph) ifNil: [Color black]));
		yourself.
]

{ #category : #'extra controls' }
PBPreferenceButtonMorph >> preferenceHelpTextMorph [
	| text tm |
	text := self preferenceHelpText.
	tm := TextMorph new
		contents: text;
		wrapOnOff;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		margins: (5@0 corner: 5@0);
		lock: true;
		visible: text notEmpty;
		yourself. "we don't want an empty textmorph showing"
	tm isAutoFit
		ifFalse: [tm autoFitOnOff].
	^tm.
]

{ #category : #'preference accessing' }
PBPreferenceButtonMorph >> preferenceMorphicView [
	^preferenceMorphicView
		ifNil: 
			[preferenceMorphicView := self preferenceView
				representativeButtonWithColor: Color transparent inPanel: self model.
			preferenceMorphicView hResizing: #spaceFill.
			^preferenceMorphicView]
]

{ #category : #'preference accessing' }
PBPreferenceButtonMorph >> preferenceView [
	^preferenceView
		ifNil: [preferenceView := self preference viewForPanel: self model.]
]

{ #category : #'extra controls' }
PBPreferenceButtonMorph >> removeExtraControls [
	self submorphs copyWithoutFirst do: [:ea | ea delete]
]

{ #category : #'utility methods' }
PBPreferenceButtonMorph >> verticalPanel [
	^self basicPanel
		cellPositioning: #topLeft;
		listDirection: #topToBottom;
		yourself.
]
