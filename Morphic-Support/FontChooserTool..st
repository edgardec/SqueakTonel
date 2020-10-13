"
A ToolBuilder version of FreeTypePlus' FontChooser[Morph].
"
Class {
	#name : #FontChooserTool,
	#superclass : #Model,
	#instVars : [
		'title',
		'selectedFontIndex',
		'fontList',
		'target',
		'getSelector',
		'setSelector',
		'pointSize',
		'emphasis',
		'window',
		'result',
		'offerStyleList'
	],
	#classVars : [
		'Default'
	],
	#category : #'Morphic-Support'
}

{ #category : #accessing }
FontChooserTool class >> default [
	"Answer the default font chooser tool"
	^Default ifNil:[self]
]

{ #category : #accessing }
FontChooserTool class >> default: aFontChooser [
	"Answer the default font chooser tool"
	Default := aFontChooser
]

{ #category : #opening }
FontChooserTool class >> open [
	"
		FontChooserTool open.
	"
	^self new open
]

{ #category : #opening }
FontChooserTool class >> openWithWindowTitle: titleString for: anObject setSelector: setSelector getSelector: getSelector [
	"
		FontChooserTool 
			openWithWindowTitle: 'Choose the Menu Font' 
			for: Preferences 
			setSelector: #setMenuFontTo: 
			getSelector: #standardMenuFont.
	"
	^(self withTitle: titleString for: anObject setSelector: setSelector getSelector: getSelector) open
]

{ #category : #opening }
FontChooserTool class >> windowTitle: titleString for: anObject setSelector: setSelector getSelector: getSelector [
	| instance |
	
	instance := self new.
	instance 
		title: titleString;
		target: anObject;
		setSelector: setSelector;
		getSelector: getSelector.
	^instance open
]

{ #category : #opening }
FontChooserTool class >> withTitle: titleString for: anObject setSelector: setSelector getSelector: getSelector [
	"
		(FontChooserTool 
			withTitle: 'Choose the Menu Font' 
			for: Preferences 
			setSelector: #setMenuFontTo: 
			getSelector: #standardMenuFont) open.
	"
	| instance |
	instance := self new.
	instance 
		title: titleString;
		target: anObject;
		setSelector: setSelector;
		getSelector: getSelector.
	^instance
]

{ #category : #actions }
FontChooserTool >> accept [
	self apply.
	result := self selectedFont.
	ToolBuilder default close: window.
]

{ #category : #actions }
FontChooserTool >> apply [
	| font |
	target ifNotNil:[
		setSelector ifNotNil:[
			font := self selectedFont.
			font ifNotNil:[
				target perform: setSelector with: font]]].
]

{ #category : #toolbuilder }
FontChooserTool >> buildButtonBarWith: builder [
	"Build the button bar"
	| panelSpec buttonSpec |
	panelSpec := builder pluggablePanelSpec new.
	panelSpec
		layout: #horizontal;
		children: OrderedCollection new.

	buttonSpec := builder pluggableButtonSpec new.
	buttonSpec 
			model: self;
			label: 'Apply' translated; 
			action: #apply.
	panelSpec children addLast: buttonSpec.


	buttonSpec := builder pluggableButtonSpec new.
	buttonSpec 
			model: self;
			label: 'OK' translated; 
			action: #accept.
	panelSpec children addLast: buttonSpec.

	buttonSpec := builder pluggableButtonSpec new.
	buttonSpec 
			model: self;
			label: 'Cancel' translated; 
			action: #cancel.
	panelSpec children addLast: buttonSpec.

	^panelSpec
]

{ #category : #toolbuilder }
FontChooserTool >> buildFontListWith: builder [
	"Build the font choosers list of font names"
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		name: #fontList;
		list: #fontList; 
		getIndex: #selectedFontIndex; 
		setIndex: #selectedFontIndex:.
	^listSpec
	
]

{ #category : #toolbuilder }
FontChooserTool >> buildPointSizeListWith: builder [
	"Build the font choosers list of point sizes"
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #pointSizeList; 
		getIndex: #selectedPointSizeIndex; 
		setIndex: #selectedPointSizeIndex:.
	^listSpec

]

{ #category : #toolbuilder }
FontChooserTool >> buildPreviewPaneWith: builder [
	"Build the preview panel"
	| textSpec |
	textSpec := builder pluggableTextSpec new.
	textSpec 
		name: #preview;
		model: self;
		getText: #contents;
		softLineWrap: false.
	^textSpec
]

{ #category : #toolbuilder }
FontChooserTool >> buildStyleListWith: builder [
	"Build the font choosers list of font styles"
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #fontStyleList; 
		getIndex: #selectedFontStyleIndex; 
		setIndex: #selectedFontStyleIndex:.
	^listSpec

]

{ #category : #toolbuilder }
FontChooserTool >> buildWith: builder [
	"Create the ui for the browser"
	"ToolBuilder open: self"
	| windowSpec |
	self offerStyleList ifTrue:[
		windowSpec := self buildWindowWith: builder specs: {
			(0@0 corner: 0.4@0.4) -> [self buildFontListWith: builder].
			(0.4@0 corner: 0.8@0.4) -> [self buildStyleListWith: builder].
			(0.8@0 corner: 1.0@0.4) -> [self buildPointSizeListWith: builder].
			(LayoutFrame fractions: (0.0@0.4 corner: 1.0@1.0) offsets: (0@0 corner: 0 @ self buttonHeight negated)) -> [self buildPreviewPaneWith: builder].
			(LayoutFrame fractions: (0@1 corner: 1@1) offsets: (0@ self buttonHeight negated corner: 0@0)) -> [self buildButtonBarWith: builder].
		}.
	] ifFalse:[
		windowSpec := self buildWindowWith: builder specs: {
			(0@0 corner: 0.7@0.4) -> [self buildFontListWith: builder].
"			(0.4@0 corner: 0.8@0.4) -> [self buildStyleListWith: builder]."
			(0.7@0 corner: 1.0@0.4) -> [self buildPointSizeListWith: builder].
			(LayoutFrame fractions: (0.0@0.4 corner: 1.0@1.0) offsets: (0@0 corner: 0 @ self buttonHeight negated)) -> [self buildPreviewPaneWith: builder].
			(LayoutFrame fractions: (0@1 corner: 1@1) offsets: (0@ self buttonHeight negated corner: 0@0)) -> [self buildButtonBarWith: builder].
		}.
	].
	windowSpec extent: self initialExtent.
	window := builder build: windowSpec.

	"Now that the window has been built, notify selection again to scroll it into view."
	self changed: #selectedFontIndex.
	^window
]

{ #category : #toolbuilder }
FontChooserTool >> buttonHeight [
	^ Preferences standardButtonFont height * 3
]

{ #category : #actions }
FontChooserTool >> cancel [
	result := nil.
	ToolBuilder default close: window.
]

{ #category : #toolbuilder }
FontChooserTool >> contents [

	^ self selectedFont
		ifNil: [Text new]
		ifNotNil: [:font | font sampleText]
]

{ #category : #'font list' }
FontChooserTool >> fontList [
	"List of available font family names"
	^fontList ifNil:[fontList := TextStyle knownTextStyles]
]

{ #category : #'style list' }
FontChooserTool >> fontStyleList [
	"names of simulated styles are enclosed in parenthesis"
	^#('Regular' 'Bold' 'Italic' 'Bold Italic')
]

{ #category : #accessing }
FontChooserTool >> getSelector [
	"Answer the value of getSelector"

	^ getSelector
]

{ #category : #accessing }
FontChooserTool >> getSelector: aSelectorSymbolOrFont [
	"Set the value of getSelector"

	getSelector := aSelectorSymbolOrFont
]

{ #category : #initialize }
FontChooserTool >> initialExtent [
	^self offerStyleList ifTrue:[420@300] ifFalse:[320@200].
]

{ #category : #initialize }
FontChooserTool >> initialize [
	super initialize.
	title := 'Choose A Font'.
	getSelector := TextStyle defaultFont.
	emphasis := 0.
	offerStyleList := true.
]

{ #category : #initialize }
FontChooserTool >> offerStyleList [
	"Whether to offer a choice of styles with the font."
	^offerStyleList
]

{ #category : #initialize }
FontChooserTool >> offerStyleList: aBool [
	"Whether to offer a choice of styles with the font."
	offerStyleList := aBool
]

{ #category : #toolbuilder }
FontChooserTool >> open [
	^ToolBuilder open: self
]

{ #category : #'point size' }
FontChooserTool >> pointSize [
	^pointSize ifNil: [pointSize := 10.0]
]

{ #category : #'point size' }
FontChooserTool >> pointSize: aNumber [
	pointSize := aNumber.
	self changed: #pointSize.
	self changed: #contents.
]

{ #category : #'point size' }
FontChooserTool >> pointSizeList [
	^self selectedTextStyle pointSizes collect: [:each | each asString padded: #left to: 3 with: $ ]
]

{ #category : #accessing }
FontChooserTool >> result [
	^result
]

{ #category : #'font list' }
FontChooserTool >> selectedFont [
	| font |
	font := self selectedTextStyle fontOfPointSize: pointSize.
	^font emphasized: emphasis
]

{ #category : #'font list' }
FontChooserTool >> selectedFontFamily [
	^self fontList at: self selectedFontIndex ifAbsent:[nil].
	
	
]

{ #category : #'font list' }
FontChooserTool >> selectedFontIndex [
	| font textStyleName family |
	selectedFontIndex ifNotNil: [^selectedFontIndex].
	selectedFontIndex := 0.
	font := (getSelector isSymbol and:[target notNil])
		ifTrue:[target perform: getSelector]
		ifFalse:[getSelector].
	font ifNotNil:[
		emphasis := font emphasis.
		pointSize := font pointSize.
		textStyleName := font textStyleName.
		family := self fontList detect:[:f | f = textStyleName] ifNone:[].
	].
	selectedFontIndex := self fontList indexOf: family.
	self selectedFontIndex: selectedFontIndex.
	^selectedFontIndex
]

{ #category : #'font list' }
FontChooserTool >> selectedFontIndex: anIndex [
	anIndex = 0 ifTrue: [^self].
	selectedFontIndex := anIndex.
	self changed: #selectedFontIndex.
	self changed: #selectedFontStyleIndex.
	self changed: #pointSizeList.
	self changed: #pointSizeIndex.
	self changed: #contents.
]

{ #category : #'style list' }
FontChooserTool >> selectedFontStyleIndex [
	"This is a hack"
	^emphasis+1
]

{ #category : #'style list' }
FontChooserTool >> selectedFontStyleIndex: anIndex [
	anIndex = 0 ifTrue: [^self].
	emphasis := anIndex - 1.
	self changed: #selectedFontStyleIndex.
	self changed: #contents.
]

{ #category : #'point size' }
FontChooserTool >> selectedPointSize [
	^self selectedFont pointSize
]

{ #category : #'point size' }
FontChooserTool >> selectedPointSizeIndex [
	^self pointSizeList indexOf: (pointSize reduce asString padded: #left to: 3 with: $ )
]

{ #category : #'point size' }
FontChooserTool >> selectedPointSizeIndex: anIndex [

	anIndex = 0 ifTrue: [^self].
	pointSize := (self pointSizeList at: anIndex) withBlanksTrimmed asNumber.
	self changed: #selectedPointSizeIndex.
	self changed: #pointSizeList.
	self changed: #contents.
]

{ #category : #'font list' }
FontChooserTool >> selectedTextStyle [

	^TextStyle named: (self selectedFontFamily ifNil:[^TextStyle default]).
]

{ #category : #accessing }
FontChooserTool >> setSelector: anObject [
	"Set the value of setSelector"

	setSelector := anObject
]

{ #category : #accessing }
FontChooserTool >> target [
	"Answer the value of target"

	^ target
]

{ #category : #accessing }
FontChooserTool >> target: anObject [
	"Set the value of target"

	target := anObject
]

{ #category : #accessing }
FontChooserTool >> title: anObject [
	"Set the value of title"

	title := anObject
]

{ #category : #accessing }
FontChooserTool >> window [
	^window
]

{ #category : #initialize }
FontChooserTool >> windowTitle [
	^ title translated
]
