"
Used in conjunction wi[th a TabbedPalette -- each TabbedPalette has one.  Each submorph of an IndexTabs is a TabMorph.  When you click on one of the tabs, a corresponding action is taken -- sometimes, the existing palette gets replaced by the new one, other times, the tab results in some selector being invoked; in any case, tab highlighting takes place accordingly.
"
Class {
	#name : #IndexTabs,
	#superclass : #PasteUpMorph,
	#instVars : [
		'highlightColor',
		'regularColor',
		'basicHeight',
		'basicWidth',
		'verticalPadding',
		'fixedWidth'
	],
	#category : #'MorphicExtras-Palettes'
}

{ #category : #printing }
IndexTabs class >> defaultNameStemForInstances [
	"Answer a basis for names of default instances of the receiver"
	^ 'tabs' translatedNoop
]

{ #category : #tabs }
IndexTabs >> addTab: aTab [
	self addMorphBack: aTab.
	self laySubpartsOutInOneRow
]

{ #category : #tabs }
IndexTabs >> addTabFor: aReferent font: aFont [
	|  aTab |
	aTab := ReferenceMorph forMorph: aReferent font: aFont.
	self addMorphBack: aTab.
	aTab highlightColor: self highlightColor; regularColor: self regularColor.
	aTab unHighlight.
	self laySubpartsOutInOneRow; layoutChanged.
	^ aTab
]

{ #category : #tabs }
IndexTabs >> addTabForBook: aBook [
	|  aTab |
	aTab := ReferenceMorph forMorph: aBook.
	self addMorphBack: aTab.
	aTab highlightColor: self highlightColor; regularColor: self regularColor.
	aTab unHighlight.
	self laySubpartsOutInOneRow; layoutChanged.
	^ aTab
]

{ #category : #layout }
IndexTabs >> basicHeight [
	^ basicHeight
]

{ #category : #layout }
IndexTabs >> basicWidth [
	basicWidth ifNil: [basicWidth := owner ifNotNil: [owner width] ifNil: [100]].
	^ basicWidth
]

{ #category : #initialization }
IndexTabs >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 0
]

{ #category : #initialization }
IndexTabs >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 0.0
		g: 0.6
		b: 0.6
]

{ #category : #layout }
IndexTabs >> fixedWidth: aWidth [
	fixedWidth := aWidth
]

{ #category : #accessing }
IndexTabs >> highlightColor [
	^ highlightColor ifNil: [Color yellow]
]

{ #category : #accessing }
IndexTabs >> highlightColor: aColor [
	highlightColor := aColor
]

{ #category : #highlighting }
IndexTabs >> highlightColor: color1 regularColor: color2 [
	"Apply these colors to all of the receiver's tabs"
	highlightColor := color1.
	regularColor := color2.
	self tabMorphs do:
		[:m | m highlightColor: color1.  m regularColor: color2]
]

{ #category : #highlighting }
IndexTabs >> highlightTab: aTab [
	self tabMorphs do:
		[:m | m == aTab
			ifTrue: [m highlight]
			ifFalse: [m unHighlight]]
]

{ #category : #highlighting }
IndexTabs >> highlightTabFor: aBook [
	| theOne |
	self tabMorphs do: [:m |
		(m morphToInstall == aBook)
				ifTrue: [m highlight.  theOne := m]
				ifFalse: [m unHighlight]].
	^ theOne

]

{ #category : #highlighting }
IndexTabs >> highlightedTab [
	^ self tabMorphs detect: [:m | m isHighlighted] ifNone: [nil]
]

{ #category : #initialization }
IndexTabs >> initialize [
	"Initialize the receiver. Make sure it is not open to drag and  
	drop"
	super initialize.
	""
	padding := 10.
	verticalPadding := 4.
	basicHeight := 14.
	basicWidth := 200.
	
	self enableDragNDrop: false
]

{ #category : #layout }
IndexTabs >> laySubpartsOutInOneRow [
	| aPosition neededHeight widthToUse mid |
	fixedWidth ifNotNil: [self error: 'incompatibility in IndexTabs'].
	verticalPadding ifNil: [verticalPadding := 4].  "for benefit of old structures"
	aPosition := self topLeft.
	neededHeight := self basicHeight.
	submorphs do:
		[:aMorph |
			aMorph position: (aPosition + (padding @ 0)).
			aPosition := aMorph topRight.
			neededHeight := neededHeight max: aMorph height].
	neededHeight := neededHeight + (verticalPadding * 2).
	mid := self top + (neededHeight // 2).
	submorphs do:
		[:aMorph |
			aMorph top: (mid - (aMorph height // 2))].
	widthToUse := self widthImposedByOwner max: self requiredWidth.
	self extent: (((aPosition x + padding - self left) max: widthToUse) @ neededHeight)
]

{ #category : #'change reporting' }
IndexTabs >> ownerChanged [
	fixedWidth ifNil: [self laySubpartsOutInOneRow]
]

{ #category : #accessing }
IndexTabs >> regularColor [
	^ regularColor ifNil: [Color r: 0.4 g: 0.2 b: 0.6]
]

{ #category : #accessing }
IndexTabs >> regularColor: aColor [
	regularColor := aColor
]

{ #category : #'dropping\/grabbing' }
IndexTabs >> repelsMorph: aMorph event: evt [
	^ false
]

{ #category : #layout }
IndexTabs >> requiredWidth [
	submorphs isEmpty ifTrue: [^self basicWidth].
	^(submorphs detectSum: [:m | m width]) + (submorphs size * padding)
]

{ #category : #layout }
IndexTabs >> rowsNoWiderThan: maxWidth [
	| aPosition neededHeight |
	self fixedWidth: maxWidth.
	verticalPadding ifNil: [verticalPadding := 4].  "for benefit of old structures"
	aPosition := self topLeft.
	neededHeight := self basicHeight.
	submorphs do:
		[:aMorph |
			aMorph position: (aPosition + (padding @ 0)).
			(aMorph right > (self left + maxWidth)) ifTrue:
				[aPosition := self left @ (aPosition y + neededHeight).
				aMorph position: aPosition + (padding @ 0).
				neededHeight := self basicHeight].
			aPosition := aMorph topRight.
			neededHeight := neededHeight max: aMorph height].
	self extent: (maxWidth @ ((aPosition y + neededHeight) - self top))
]

{ #category : #selection }
IndexTabs >> selectTab: aTab [
	| aWorld |
	(aWorld := self world) ifNotNil: [aWorld abandonAllHalos].  "nil can happen at init time"
	self highlightTab: aTab.

]

{ #category : #tabs }
IndexTabs >> tabMorphs [
	"Presently all the submorphs are ReferenceMorphs, but this still supports an earlier design where spacers are interleaved, and where the old TabMorph class was used"

	^ submorphs select: [:m | (m isKindOf: TabMorph) or: [m isKindOf: ReferenceMorph]]
]

{ #category : #layout }
IndexTabs >> widthImposedByOwner [
	((owner isNil or: [owner isWorldOrHandMorph]) 
		or: [owner submorphs size < 2]) ifTrue: [^self basicWidth].
	^owner submorphs second width
]
