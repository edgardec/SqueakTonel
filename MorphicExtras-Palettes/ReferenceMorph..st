"
Serves as a reference to any arbitrary morph; used, for example, as the tab in a tabbed palette  The wrapper intercepts mouse events and fields them, passing them on to their referent morph.
"
Class {
	#name : #ReferenceMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'referent',
		'isHighlighted'
	],
	#category : #'MorphicExtras-Palettes'
}

{ #category : #printing }
ReferenceMorph class >> defaultNameStemForInstances [
	^ 'ref' translatedNoop
]

{ #category : #'instance creation' }
ReferenceMorph class >> forMorph: aMorph [
	"Create a new tab consisting of a string holding the morph's name"
	^ self new morphToInstall: aMorph
]

{ #category : #'instance creation' }
ReferenceMorph class >> forMorph: aMorph font: aFont [
	"Create a new tab consisting of a string holding the morph's name"
	^ self new morphToInstall: aMorph font: aFont
]

{ #category : #menu }
ReferenceMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Add morph-specific items to the menu for the hand"

	| sketch |
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	self isCurrentlyTextual
		ifTrue:
			[aCustomMenu add: 'change label wording...' translated action: #changeTabText.
			aCustomMenu add: 'use graphical label' translated action: #useGraphicalTab]
		ifFalse:
			[aCustomMenu add: 'use textual label' translated action: #useTextualTab.
			aCustomMenu add: 'choose graphic...' translated action: #changeTabGraphic.
			(sketch := self findA: SketchMorph) ifNotNil:
				[aCustomMenu add: 'repaint' translated target: sketch action: #editDrawing]]
]

{ #category : #'submorphs-accessing' }
ReferenceMorph >> allNonSubmorphMorphs [
	"we hold extra morphs"

	^ Array with: referent
]

{ #category : #accessing }
ReferenceMorph >> borderWidth: aWidth [
	"Set the receiver's border width as indicated, and trigger a fresh layout"

	super borderWidth: aWidth.
	self layoutChanged
]

{ #category : #menu }
ReferenceMorph >> changeTabGraphic [
	submorphs first chooseNewGraphicCoexisting: true
]

{ #category : #menu }
ReferenceMorph >> changeTabText [
	| reply |
	reply := UIManager default
		request: 'new wording for this tab:'
		initialAnswer: submorphs first contents.
	reply isEmptyOrNil ifFalse: [submorphs first contents: reply]
]

{ #category : #initialization }
ReferenceMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 0
]

{ #category : #initialization }
ReferenceMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color transparent
]

{ #category : #button }
ReferenceMorph >> doButtonAction [
	self tabSelected
]

{ #category : #menu }
ReferenceMorph >> existingWording [
	^ submorphs first contents asString
]

{ #category : #layout }
ReferenceMorph >> fitContents [
	submorphs size = 1 ifTrue:
		[self extent: submorphs first extent + (2 * self borderWidth).
		submorphs first position: self position + self borderWidth]
]

{ #category : #menu }
ReferenceMorph >> graphicalMorphForTab [
	| formToUse |
	formToUse := self valueOfProperty: #priorGraphic ifAbsent: [ScriptingSystem formAtKey: 'squeakyMouse'].
	^ SketchMorph withForm: formToUse
]

{ #category : #'event handling' }
ReferenceMorph >> handlesMouseDown: evt [
	^ true

]

{ #category : #'event handling' }
ReferenceMorph >> handlesMouseMove: anEvent [ 
	^true
]

{ #category : #accessing }
ReferenceMorph >> highlight [
	| str |
	isHighlighted := true.
	submorphs notEmpty 
		ifTrue: 
			[((str := submorphs first) isKindOf: StringMorph) 
				ifTrue: [str color: self highlightColor]
				ifFalse: 
					[self
						borderWidth: 1;
						borderColor: self highlightColor]]
]

{ #category : #initialization }
ReferenceMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	isHighlighted := false.
	referent := nil
]

{ #category : #accessing }
ReferenceMorph >> isCurrentlyGraphical [
	"Answer whether the receiver is currently showing a graphical face"

	| first |
	^submorphs notEmpty and: 
			[((first := submorphs first) isKindOf: ImageMorph) 
				or: [first isSketchMorph]]
]

{ #category : #menu }
ReferenceMorph >> isCurrentlyTextual [
	| first |
	^((first := submorphs first) isKindOf: StringMorph) 
		or: [first isTextMorph]
]

{ #category : #misc }
ReferenceMorph >> isHighlighted [
	^ isHighlighted == true
]

{ #category : #layout }
ReferenceMorph >> layoutChanged [
	self fitContents.
	super layoutChanged
]

{ #category : #accessing }
ReferenceMorph >> morphToInstall [
	^ referent
]

{ #category : #misc }
ReferenceMorph >> morphToInstall: aMorph [
	"Create a new tab consisting of a string holding the morph's name"
	| aLabel nameToUse |
	aLabel := StringMorph new contents: (nameToUse := aMorph externalName).
	self addMorph: aLabel.
	aLabel lock.
	self referent: aMorph.
	self setNameTo: nameToUse.
	self fitContents.
]

{ #category : #misc }
ReferenceMorph >> morphToInstall: aMorph font: aFont [
	"Create a new tab consisting of a string holding the morph's name"
	| aLabel nameToUse |
	aLabel := StringMorph contents: (nameToUse := aMorph externalName) font: aFont.
	self addMorph: aLabel.
	aLabel lock.
	self referent: aMorph.
	self setNameTo: nameToUse.
	self fitContents.
]

{ #category : #'event handling' }
ReferenceMorph >> mouseDown: evt [
	self setProperty: #oldColor toValue: color
]

{ #category : #'event handling' }
ReferenceMorph >> mouseMove: evt [
	"The mouse moved while the butten was down in the receiver"

	| aForm |
	aForm := self imageForm.
	(self containsPoint: evt cursorPoint)
		ifTrue:
			[aForm reverse displayOn: Display]
		ifFalse:
			[aForm displayOn: Display]
]

{ #category : #'event handling' }
ReferenceMorph >> mouseUp: evt [
	"The mouse came up in the receiver; If the mouse is still within the receiver at this point, do the corresponding action"

	| aColor |
	(aColor := self valueOfProperty: #oldColor) ifNotNil: [self color: aColor].
	(self containsPoint: evt cursorPoint)
		ifTrue: [self doButtonAction].
	super mouseUp: evt "send to evt handler if any"

]

{ #category : #menu }
ReferenceMorph >> preserveDetails [
	"The receiver is being switched to use a different format.  Preserve the existing details (e.g. wording if textual, grapheme if graphical) so that if the user reverts back to the current format, the details will be right"

	self isCurrentlyTextual
		ifTrue:
			[self setProperty: #priorWording toValue: self existingWording.
			self setProperty: #priorColor toValue: self color.
			self setProperty: #priorBorderWidth toValue: self borderWidth]
		ifFalse:
			[self setProperty: #priorGraphic toValue: self firstSubmorph form]
]

{ #category : #accessing }
ReferenceMorph >> referent [
	^ referent
]

{ #category : #accessing }
ReferenceMorph >> referent: m [
	referent := m
]

{ #category : #menu }
ReferenceMorph >> setLabelFontTo: aFont [
	"Change the receiver's label font to be as indicated"

	| aLabel oldLabel |
	aLabel := StringMorph contents:  (oldLabel := self findA: StringMorph) contents font: aFont.
	self replaceSubmorph: oldLabel by: aLabel.
	aLabel position: self position.
	aLabel highlightColor: self highlightColor; regularColor: self regularColor.
	aLabel lock.
	self fitContents.
	self layoutChanged.
	(owner isKindOf: IndexTabs) ifTrue:
		[self borderWidth: 0.
		owner laySubpartsOutInOneRow.
		isHighlighted ifTrue:
			[self highlight]]
]

{ #category : #naming }
ReferenceMorph >> setNameTo: aString [ 
	super setNameTo: aString.
	(submorphs notEmpty and: [submorphs first isKindOf: StringMorph]) 
		ifTrue: [submorphs first contents: aString]
]

{ #category : #misc }
ReferenceMorph >> sorterToken [
	^ SorterTokenMorph new forMorph: self
]

{ #category : #events }
ReferenceMorph >> tabSelected [
	"Called when the receiver is hit.  First, bulletproof against someone having taken the structure apart.  My own action basically requires that my grand-owner be a TabbedPalette.  Note that the 'opening' script concept has been left behind here."
	| gramps |
	(owner isKindOf: IndexTabs) ifFalse: [^ Beeper beep].
	((gramps := owner owner) isKindOf: TabbedPalette)  ifTrue:
		[gramps selectTab: self]
]

{ #category : #accessing }
ReferenceMorph >> unHighlight [
	| str |
	isHighlighted := false.
	self borderWidth: 0.
	submorphs notEmpty 
		ifTrue: 
			[((str := submorphs first) isKindOf: StringMorph orOf: RectangleMorph) 
				ifTrue: [str color: self regularColor]]
]

{ #category : #menu }
ReferenceMorph >> useGraphicalTab [
	| aGraphic |
	self preserveDetails.
	self color: Color transparent.
	aGraphic := self graphicalMorphForTab.
	self borderWidth: 0.
	self removeAllMorphs.
	self addMorphBack: aGraphic.
	aGraphic position: self position.
	aGraphic lock.
	self fitContents.
	self layoutChanged.
	(owner isKindOf: IndexTabs) ifTrue:
		[owner laySubpartsOutInOneRow.
		isHighlighted ifTrue: [self highlight]].
]

{ #category : #menu }
ReferenceMorph >> useTextualTab [
	"Use a textually-emblazoned tab"

	| aLabel stringToUse font aColor |
	self preserveDetails.
	stringToUse := self valueOfProperty: #priorWording ifAbsent: [self externalName].
	font := self valueOfProperty: #priorFont ifAbsent: [Preferences standardButtonFont].
	aColor := self valueOfProperty: #priorColor ifAbsent: [Color green darker].
	aLabel := StringMorph contents: stringToUse font: font.
	self replaceSubmorph: submorphs first by: aLabel.
	aLabel position: self position.
	self color: aColor.
	aLabel highlightColor: self highlightColor; regularColor: self regularColor.
	aLabel lock.
	self fitContents.
	self layoutChanged.
	(owner isKindOf: IndexTabs) ifTrue:
		[self borderWidth: 0.
		owner laySubpartsOutInOneRow.
		isHighlighted ifTrue:
			[self highlight]]
]
