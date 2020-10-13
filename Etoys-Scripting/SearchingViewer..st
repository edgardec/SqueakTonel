"
A SearchingViewer is a custom Viewer which has a type-in 'search' pane; the user types a word or fragment into the search pane and hits the 'search' button (or hits Return or Enter) and the pane gets populated with all the phrases that match (in the currently-installed language) the search-string.
"
Class {
	#name : #SearchingViewer,
	#superclass : #CategoryViewer,
	#instVars : [
		'searchString'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #initialization }
SearchingViewer >> addNamePaneTo: header [
	"Add the namePane, which may be a popup or a type-in depending on the type of CategoryViewer"

	| searchButton aStringMorph aBox |
	namePane := AlignmentMorph newRow vResizing: #spaceFill; height: 14.
	namePane color: Color transparent.
	namePane hResizing: #spaceFill.
	namePane listDirection: #leftToRight.
	aBox := PasteUpMorph new.
	aBox beTransparent.
	aBox beSticky.
	aBox hResizing: #spaceFill; vResizing: #rigid; height: Preferences standardEToysFont height.
	aBox borderWidth: 1; borderColor: Color gray.
	aStringMorph := UpdatingStringMorph new.
	aStringMorph useStringFormat.
	aStringMorph target: self; getSelector: #searchString; putSelector: #searchString:notifying:.
	aStringMorph hResizing: #spaceFill.
	aStringMorph height: Preferences standardEToysFont height rounded; vResizing: #rigid.
	aStringMorph stepTime: 5000.
	aStringMorph font: Preferences standardEToysFont.
	aBox addMorphBack: aStringMorph.
	aBox on: #mouseDown send: #mouseDown: to: aStringMorph.
	aStringMorph topLeft: (aBox topLeft + (3@0)).

	searchButton := SimpleButtonMorph new 
		target: self;
		beTransparent;
		actionSelector: #doSearchFrom:;
		arguments: {aStringMorph}.
	searchButton setBalloonText: 'Type some letters into the pane at right, and then press this Search button (or hit RETURN) and all tiles that match what you typed will appear in the list below.' translated.

	namePane addMorphFront: searchButton.
	namePane addTransparentSpacerOfSize: 6@0.
	namePane addMorphBack: aBox.
	header addMorphBack: namePane.
	self updateSearchButtonLabel.
]

{ #category : #support }
SearchingViewer >> categoryRestorationInfo [
	"Answer info needed to reincarnate myself"

	^ Array with: self chosenCategorySymbol with: self searchString
]

{ #category : #categories }
SearchingViewer >> categoryWording: aCategoryWording [
	"okay, thanks"
]

{ #category : #categories }
SearchingViewer >> currentCategory [
	"Answer the symbol associated with the pane"

	^ #search
]

{ #category : #search }
SearchingViewer >> doSearchFrom:  aSource [
	"Perform the search operation"

	^ self doSearchFrom: aSource interactive: true
]

{ #category : #search }
SearchingViewer >> doSearchFrom: aSource interactive: isInteractive [
	"Perform the search operation.  If interactive is true, this actually happened because a search button was pressed; if false, it was triggered some other way for which an informer would be inappropriate."

	| searchFor aVocab aList all anInterface useTranslations scriptNames addedMorphs |

	searchString := aSource isString
		ifTrue:
			[aSource]
		ifFalse:
			[(aSource isKindOf: PluggableTextMorph) "old"
				ifTrue:
					[aSource text string]
				ifFalse:
					[aSource contents asString]].
	searchFor := searchString asLowercaseAlphabetic.

	aVocab := self outerViewer currentVocabulary.
	(useTranslations := (scriptedPlayer isPlayerLike) and: [aVocab isEToyVocabulary])
		ifTrue:
			[all := scriptedPlayer costume selectorsForViewer.
			all addAll: (scriptNames := scriptedPlayer class namedTileScriptSelectors)]
		ifFalse:
			[all := scriptNames := scriptedPlayer class allSelectors].
	aList := all select:
		[:aSelector | (aVocab includesSelector: aSelector forInstance: scriptedPlayer ofClass: scriptedPlayer class limitClass: ProtoObject) and:
			[(useTranslations and: [(anInterface := aVocab methodInterfaceAt: aSelector ifAbsent: [nil]) notNil and: [anInterface wording asString asLowercaseAlphabetic includesSubstring: searchFor caseSensitive: true]])
				or:
					[((scriptNames includes: aSelector) or: [useTranslations not]) and:
						[aSelector includesSubstring: searchFor caseSensitive: false]]]].
	aList := aList sorted.

	self removeAllButFirstSubmorph. "that being the header"
	self addAllMorphs:
		((addedMorphs := scriptedPlayer tilePhrasesForSelectorList: aList inViewer: self)).
	self enforceTileColorPolicy.
	self secreteCategorySymbol.
	self world ifNotNil: [self world startSteppingSubmorphsOf: self].
	self adjustColorsAndBordersWithin.

	owner ifNotNil: [owner isStandardViewer ifTrue: [owner fitFlap].

	(isInteractive and: [addedMorphs isEmpty]) ifTrue:
		[searchFor ifNotEmpty:
			[self inform: ('No matches found for "' translated), searchFor, '"']]]
]

{ #category : #initialization }
SearchingViewer >> establishContents [ 
	"Perform any initialization steps that needed to wait until I am installed in my outer viewer"

	searchString isEmptyOrNil ifFalse: [self doSearchFrom: searchString interactive: false]
]

{ #category : #initialization }
SearchingViewer >> initializeFor: aPlayer categoryChoice: aChoice [
	"Initialize the receiver to be associated with the player and category specified."

	| itsContents |
	super initializeFor: aPlayer categoryChoice: #search.
	self clipSubmorphs: true.
	itsContents := aChoice second.
	itsContents ifEmpty: [itsContents := '    '].
	(namePane submorphs last findA: UpdatingStringMorph) contents: itsContents.

	self setCategorySymbolFrom: aChoice
]

{ #category : #'header pane' }
SearchingViewer >> maybeAddArrowsTo: header [
	"Maybe add up/down arrows to the header"

	header addTransparentSpacerOfSize: 5@5
]

{ #category : #search }
SearchingViewer >> rawSearchString: aString [
	"Set the search string as indicated"

	searchString := aString asString
]

{ #category : #search }
SearchingViewer >> searchString [
	"Answer the search string"

	^ searchString ifNil: [searchString := '']
]

{ #category : #search }
SearchingViewer >> searchString: aString notifying: znak [
	"Set the search string as indicated and carry out a search"

	searchString := aString asString.
	self doSearchFrom: searchString
]

{ #category : #initialization }
SearchingViewer >> setCategorySymbolFrom: aChoice [
	"Set my category symbol"

	self chosenCategorySymbol: #search.
	self rawSearchString: aChoice second
]

{ #category : #categories }
SearchingViewer >> updateCategoryNameTo: aName [
	"Update the category name, because of a language change."

	self doSearchFrom: (namePane findDeeplyA: UpdatingStringMorph) contents interactive: false.
	self updateSearchButtonLabel

]

{ #category : #categories }
SearchingViewer >> updateSearchButtonLabel [
	"Update the label on the search button."

	| button |
	button := self
				findDeepSubmorphThat: [:e | e class = SimpleButtonMorph]
				ifAbsent: [].
	button label: 'Search' translated  font: ScriptingSystem fontForEToyButtons.
	button setBalloonText: 'Type some letters into the pane at right, and then press this Search button (or hit RETURN) and all tiles that match what you typed will appear in the list below.' translated
]
