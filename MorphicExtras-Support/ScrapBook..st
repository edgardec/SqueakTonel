"
I provide a holding place for Morphs deleted through the pink halo button or being dragged onto the trashcan.
"
Class {
	#name : #ScrapBook,
	#superclass : #Object,
	#instVars : [
		'book'
	],
	#classVars : [
		'Default'
	],
	#category : #'MorphicExtras-Support'
}

{ #category : #'initialize-release' }
ScrapBook class >> cleanUp: aggressive [
	"Nuke the scraps book when cleaning aggressively"

	aggressive ifTrue: [Default := nil].
]

{ #category : #accessing }
ScrapBook class >> default [
	^ Default ifNil: [Default := ScrapBook new].
]

{ #category : #scraps }
ScrapBook >> addToTrash: aMorph [
	"Paste the object onto a page of the system Trash book, unless the preference is set to empty the trash immediately."

	| aPage |
	TrashCanMorph preserveTrash ifFalse: [^ self].

	aMorph position: book pages first position + (0@40).
	book pages do: [:pp | 
		(pp submorphs size = 1 and: [pp hasProperty: #trash]) ifTrue:  "perhaps remove that property here"
			["page is blank"
			^ pp addMorph: aMorph]].
	aPage := book insertPageLabel: ('{1} {2}' format: Time dateAndTimeNow)
		morphs: (Array with: aMorph).
	aPage setProperty: #trash toValue: true
]

{ #category : #scraps }
ScrapBook >> emptyScrapBook [
	| oldScraps |
	oldScraps := book.
	book := nil. "Creates it afresh"
	book := self scrapBook.
	(oldScraps notNil and: [oldScraps owner notNil])
		ifTrue:
			[book position: oldScraps position.
			oldScraps owner replaceSubmorph: oldScraps by: book.
			book changed; layoutChanged]
]

{ #category : #'initialize-release' }
ScrapBook >> initialize [
	super initialize.
	book := self scrapBook.
]

{ #category : #scraps }
ScrapBook >> maybeEmptyTrash [
	(self confirm: 'Do you really want to empty the trash?' translated)
		ifTrue: [self emptyScrapBook]
]

{ #category : #scraps }
ScrapBook >> scrapBook [
	| header aButton label |
	^ book ifNil: [
		book := BookMorph new pageSize: 300@300; setNameTo: 'scraps' translated.
		book addCornerGrips.
		book color: Color yellow muchLighter.
		book borderColor: Color darkGray; borderWidth: 2.
		book removeEverything; showPageControls; insertPage.

		header := AlignmentMorph newRow wrapCentering: #center; cellPositioning: #leftCenter.
		header setProperty: #header toValue: true.
		header addMorph: (aButton := ThreePhaseButtonMorph labelSymbol: #'Halo-Collapse').
		aButton target: book;
			actionSelector: #delete;
			setBalloonText: 'Close the trashcan.\(to view again later, click on any trashcan).' withCRs translated.
		header addMorphBack: AlignmentMorph newVariableTransparentSpacer beSticky.
		header addMorphBack: 	(label := UpdatingStringMorph new target: self) beSticky.
		label getSelector: #trashTitle; useStringFormat; step.
		header addMorphBack: AlignmentMorph newVariableTransparentSpacer beSticky.
		header addMorphBack: (aButton := ThreePhaseButtonMorph labelSymbol: #'Halo-Dismiss').
		aButton target: self;
			actionSelector: #maybeEmptyTrash;
			setBalloonText: 'Click here to empty the trash.' translated.
		book currentPage
			layoutPolicy: TableLayout new;
			addMorph: (TextMorph new
				contents: 'Objects you drag into the trash will automatically be saved here, one object per page, in case you need them later.  To disable this feature set the "preserveTrash" Preference to false.\\You can individually expunge objects by hitting the "-" control (behind "..."). You can empty out all the objects in the trash can by hitting the "X" button at top right.' withCRs translated;
				hResizing: #spaceFill).

		book addMorphFront: header.
		book setProperty: #scraps toValue: true].
]

{ #category : #scraps }
ScrapBook >> trashTitle [

	^ 'T R A S H' translated
]
