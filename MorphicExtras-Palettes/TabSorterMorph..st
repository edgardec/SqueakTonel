"
A sorter for the tabs of a TabbedPalette
"
Class {
	#name : #TabSorterMorph,
	#superclass : #BookPageSorterMorph,
	#instVars : [
		'originalTabs'
	],
	#category : #'MorphicExtras-Palettes'
}

{ #category : #buttons }
TabSorterMorph >> acceptSort [
	"Reconstitute the palette based on what is found in the sorter"

	| rejects oldOwner tabsToUse oldTop |
	tabsToUse := OrderedCollection new.
	rejects := OrderedCollection new.
	pageHolder submorphs doWithIndex: 
			[:m :i | | appearanceMorph toAdd aMenu | 
			toAdd := nil.
			(m isKindOf: BookMorph) ifTrue: [toAdd := SorterTokenMorph forMorph: m].
			(m isKindOf: SorterTokenMorph) 
				ifTrue: 
					[toAdd := m morphRepresented.
					(toAdd referent isKindOf: MenuMorph) 
						ifTrue: 
							[(aMenu := toAdd referent) setProperty: #paletteMenu toValue: true.
							(aMenu submorphs size > 1 and: 
									[(aMenu submorphs second isKindOf: MenuItemMorph) 
										and: [aMenu submorphs second contents = 'dismiss this menu']]) 
								ifTrue: 
									[aMenu submorphs first delete.	"delete title"
									aMenu submorphs first delete.	"delete stay-up item"
									(aMenu submorphs first knownName = #line) 
										ifTrue: [aMenu submorphs first delete]]].
					toAdd removeAllMorphs.
					toAdd addMorph: (appearanceMorph := m submorphs first).
					appearanceMorph position: toAdd position.
					appearanceMorph lock.
					toAdd fitContents].
			toAdd ifNil: [rejects add: m] ifNotNil: [tabsToUse add: toAdd]].
	tabsToUse isEmpty 
		ifTrue: [^self inform: 'Sorry, must have at least one tab'].
	book newTabs: tabsToUse.
	book tabsMorph color: pageHolder color.
	oldTop := self topRendererOrSelf.	"in case some maniac has flexed the sorter"
	oldOwner := oldTop owner.
	oldTop delete.
	oldOwner addMorphFront: book
]

{ #category : #initialization }
TabSorterMorph >> addControls [
	"Add the control bar at the top of the tool."

	| b r |
	b := SimpleButtonMorph new target: self; borderColor: Color black.
	r := AlignmentMorph newRow.
	r color: b color; borderWidth: 0; layoutInset: 0.
	r hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
	r wrapCentering: #topLeft.
	r addMorphBack: (b label: 'Okay' translated font: ScriptingSystem fontForEToyButtons;	actionSelector: #acceptSort).
	b := SimpleButtonMorph new target: self; borderColor: Color black.
	r addMorphBack: (b label: 'Cancel' translated font: ScriptingSystem fontForEToyButtons;	actionSelector: #cancelSort).
	self addMorphFront: r.

]

{ #category : #buttons }
TabSorterMorph >> cancelSort [
	| oldOwner |
	oldOwner := owner.
	self delete.
	oldOwner addMorphFront: book
]

{ #category : #initialization }
TabSorterMorph >> initialize [
	"Initialize the receiver."

	super initialize.
	self removeAllMorphs.

	self extent: 300@100.
	pageHolder := PasteUpMorph new.
	pageHolder vResizeToFit: true; autoLineLayout: true.
	pageHolder extent: self extent - self borderWidth.
	pageHolder padding: 8.
	pageHolder cursor: 0.
	pageHolder wantsMouseOverHalos: false.
	self addControls.
	self addMorphBack: pageHolder
]

{ #category : #sorting }
TabSorterMorph >> sortTabsFor: aTabbedPalette [
	| actualTabs |
	actualTabs := aTabbedPalette tabMorphs.
	self book: aTabbedPalette morphsToSort:
		(actualTabs collect: [:aTab | aTab sorterToken]).
	pageHolder color: aTabbedPalette tabsMorph color.
 
	self position: aTabbedPalette position.
	pageHolder extent: self extent.
	self setNameTo: 'Tab Sorter for ', aTabbedPalette externalName.
	aTabbedPalette owner addMorphFront: self
]
