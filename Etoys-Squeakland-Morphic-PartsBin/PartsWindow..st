"
Disused.  Instances may persist in users' images, so this obsolete code is kept around for the time being.  Supplanted by the ObjectsTool.
"
Class {
	#name : #PartsWindow,
	#superclass : #SystemWindow,
	#instVars : [
		'book',
		'prevButton',
		'nextButton',
		'menuButton',
		'openForEditing'
	],
	#category : #'Etoys-Squeakland-Morphic-PartsBin'
}

{ #category : #menus }
PartsWindow >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu add: 'parts window controls...' translated action: #invokePartsWindowMenu

]

{ #category : #'as yet unclassified' }
PartsWindow >> adjustBookControls [
	| inner |
	prevButton ifNil: [^ self].
	prevButton align: prevButton topLeft with: (inner := self innerBounds) topLeft + (32 @ -1).
	nextButton align: nextButton topRight with: inner topRight - (18 @ 1).
	menuButton align: menuButton topLeft with: inner topRight + (-42 @ 5).
]

{ #category : #'as yet unclassified' }
PartsWindow >> book: aBook [

	book := aBook.
	self addMorph: aBook frame: (0@0 extent: 1@1).
	book beSticky.
	self extent: aBook extent + (0@self labelHeight).
	nextButton target: aBook.
	prevButton target: aBook
]

{ #category : #'as yet unclassified' }
PartsWindow >> closeEditing [
	openForEditing := false.
	self color: Color white.
	book pages do:
		[:aPage | aPage setPartsBinStatusTo: true]
]

{ #category : #initialization }
PartsWindow >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color white
]

{ #category : #geometry }
PartsWindow >> extent: newExtent [
	super extent: (newExtent max: 100 @ 50).
	self adjustBookControls
]

{ #category : #initialization }
PartsWindow >> initialize [
	"initialize the state of the receiver"
	| aFont aForm |
	super initialize.
	""
	
	openForEditing := false.
	aFont := Preferences standardButtonFont.
	self addMorph: (prevButton := SimpleButtonMorph new borderWidth: 0;
					 label: '<' font: aFont;
					 color: Color transparent;
					 setBalloonText: 'previous page';
					 actionSelector: #previousPage;
					 target: self;
					 extent: 16 @ 16).
	self addMorph: (nextButton := SimpleButtonMorph new borderWidth: 0;
					 label: '>' font: aFont;
					 color: Color transparent;
					 setBalloonText: 'next page';
					 actionSelector: #nextPage;
					 target: self;
					 extent: 16 @ 16).
	menuButton := ThreePhaseButtonMorph new onImage: (aForm := ScriptingSystem formAtKey: 'OfferToUnlock');
				
				offImage: (ScriptingSystem formAtKey: 'OfferToLock');
				
				pressedImage: (ScriptingSystem formAtKey: 'OfferToLock');
				 extent: aForm extent;
				 state: #on.
	menuButton target: self;
		 actionSelector: #toggleStatus;
		 actWhen: #buttonUp.
	menuButton setBalloonText: 'open for editing'.
	self addMorph: menuButton.
	" 
	self addMorph: (menuButton := SimpleButtonMorph new  
	borderWidth: 0;  
	label: '·' font: aFont; color: Color transparent;  
	actWhen: #buttonDown;  
	actionSelector: #invokePartsWindowMenu; target: self; extent:  
	16@16)."
	self adjustBookControls
]

{ #category : #'as yet unclassified' }
PartsWindow >> invokePartsWindowMenu [
	"Put up a menu offering parts-bin controls"

	| aMenu sel |
	aMenu := MVCMenuMorph new.
	aMenu defaultTarget: aMenu.
	openForEditing
		ifTrue:
			[aMenu add: 'resume being a parts bin' selector: #selectMVCItem: argument:	#toggleStatus]
		ifFalse:
			[aMenu add: 'open for editing' selector: #selectMVCItem: argument:#toggleStatus].
	aMenu add: 'sort pages'	selector: #selectMVCItem: argument: #sortPages.
	aMenu add: 'save as Custom Parts Bin' selector: #selectMVCItem: argument: #saveAsCustomPartsBin.
	sel := aMenu invokeAt: self primaryHand position in: self world.
	sel ifNotNil: [self perform: sel].

]

{ #category : #'as yet unclassified' }
PartsWindow >> openEditing [
	openForEditing := true.
	self color: Color green.
	book pages do:
		[:aPage | aPage setPartsBinStatusTo: false]
]

{ #category : #'as yet unclassified' }
PartsWindow >> saveAsCustomPartsBin [
	self inform: 'this feature is obsolete, as, indeed, is this entire tool'
]

{ #category : #label }
PartsWindow >> setLabelWidgetAllowance [
	^ labelWidgetAllowance := 115
]

{ #category : #'as yet unclassified' }
PartsWindow >> sortPages [
	book sortPages
]

{ #category : #'as yet unclassified' }
PartsWindow >> toggleStatus [
	openForEditing := openForEditing not.
	openForEditing
		ifTrue:
			[self openEditing.
			menuButton state: #off.
			menuButton setBalloonText: 'resume being a parts bin']
		ifFalse:
			[self closeEditing.
			menuButton state: #on.
			menuButton setBalloonText: 'open for editing']
]

{ #category : #'resize\/collapse' }
PartsWindow >> wantsExpandBox [
	"Answer whether I'd like an expand box"

	^ false
]
