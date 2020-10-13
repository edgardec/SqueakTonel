Class {
	#name : #KedamaWhoSearchingViewer,
	#superclass : #CategoryViewer,
	#instVars : [
		'searchString'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #initialization }
KedamaWhoSearchingViewer >> addNamePaneTo: header [
	"Add the namePane, which may be a popup or a type-in depending on the type of CategoryViewer"

	| plugTextMor searchButton |
	namePane := AlignmentMorph newRow vResizing: #spaceFill; height: 14.
	namePane hResizing: #spaceFill.
	namePane listDirection: #leftToRight.

	plugTextMor := PluggableTextMorph on: self
					text: #searchString accept: #searchString:notifying:
					readSelection: nil menu: nil.
	plugTextMor setProperty: #alwaysAccept toValue: true.
	plugTextMor askBeforeDiscardingEdits: false.
	plugTextMor acceptOnCR: true.
	plugTextMor setTextColor: Color brown.
	plugTextMor setNameTo: 'Turtle' translated.
	plugTextMor vResizing: #spaceFill; hResizing: #spaceFill.
	plugTextMor hideScrollBarsIndefinitely.
	plugTextMor setTextMorphToSelectAllOnMouseEnter.

	searchButton := SimpleButtonMorph new 
		target: self;
		beTransparent;
		label: 'Turtle' translated;
		actionSelector: #doSearchFrom:;
		arguments: {plugTextMor}.
	searchButton setBalloonText: 'Type a number into the pane to specify the individual turtle.' translated.

	namePane addMorphFront: searchButton.
	namePane addTransparentSpacerOfSize: 6@0.
	namePane addMorphBack: plugTextMor.
	header addMorphBack: namePane
]

{ #category : #support }
KedamaWhoSearchingViewer >> categoryRestorationInfo [
	"Answer info needed to reincarnate myself"

	^ Array with: self chosenCategorySymbol with: self searchString
]

{ #category : #categories }
KedamaWhoSearchingViewer >> categoryWording: aCategoryWording [
	"okay, thanks"
]

{ #category : #categories }
KedamaWhoSearchingViewer >> currentCategory [
	"Answer the symbol associated with the pane"

	^ #search
]

{ #category : #search }
KedamaWhoSearchingViewer >> doSearchFrom:  aSource [
	"Perform the search operation"

	^ self doSearchFrom: aSource interactive: true
]

{ #category : #search }
KedamaWhoSearchingViewer >> doSearchFrom:  aSource interactive: isInteractive [
	"Perform the search operation.  If interactive is true, this actually happened because a search button was pressed; if false, it was triggered some other way for which an informer would be inappropriate."

	| searchFor |
	searchString := (aSource isKindOf: PluggableTextMorph)
		ifFalse:
			[aSource]
		ifTrue:
			[aSource text string].
	searchFor := searchString asNumber asInteger.
	(self outerViewer isMemberOf: KedamaStandardViewer) ifTrue: [
		self outerViewer providePossibleRestrictedView: searchFor.
		self updateWhoString.
	].

]

{ #category : #initialization }
KedamaWhoSearchingViewer >> establishContents [ 
	"Perform any initialization steps that needed to wait until I am installed in my outer viewer"

	searchString isEmptyOrNil ifFalse: [self doSearchFrom: searchString interactive: false]
]

{ #category : #initialization }
KedamaWhoSearchingViewer >> initializeFor: aPlayer categoryChoice: aChoice [
	"Initialize the receiver to be associated with the player and category specified"

	super initializeFor: aPlayer categoryChoice: #search.
	self clipSubmorphs: true.
	(namePane findA: PluggableTextMorph) setText: aChoice second asText.
	self setCategorySymbolFrom: aChoice
]

{ #category : #'header pane' }
KedamaWhoSearchingViewer >> maybeAddArrowsTo: header [
	"Maybe add up/down arrows to the header"

	header addTransparentSpacerOfSize: 5@5
]

{ #category : #search }
KedamaWhoSearchingViewer >> rawSearchString: aString [
	"Set the search string as indicated"

	searchString := aString asString
]

{ #category : #search }
KedamaWhoSearchingViewer >> searchString [
	"Answer the search string"

	^ searchString ifNil: [searchString := '']
]

{ #category : #search }
KedamaWhoSearchingViewer >> searchString: aString notifying: znak [
	"Set the search string as indicated and carry out a search"

	searchString := aString asString.
	self doSearchFrom: searchString
]

{ #category : #initialization }
KedamaWhoSearchingViewer >> setCategorySymbolFrom: aChoice [
	"Set my category symbol"

	self chosenCategorySymbol: #search.
	self rawSearchString: aChoice second
]

{ #category : #categories }
KedamaWhoSearchingViewer >> updateCategoryNameTo: aName [
	"Update the category name, because of a language change."

	self doSearchFrom: (namePane findA: PluggableTextMorph) text interactive: false.
	self flag: #deferred.  "A nice touch would be to change the Button wording here"

]

{ #category : #support }
KedamaWhoSearchingViewer >> updateWhoString [

	(self outerViewer restrictedWho = 0) ifTrue: [
		self rawSearchString: ''.
		self changed: #searchString.
	].

]
