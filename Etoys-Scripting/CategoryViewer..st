"
A viewer on an object.  Consists of three panes:
   Header pane -- category-name, arrows for moving among categories, etc.
   List pane -- contents are a list of subparts in the chosen category.
   Editing pane -- optional, a detail pane with info relating to the selected element of the list pane.
"
Class {
	#name : #CategoryViewer,
	#superclass : #Viewer,
	#instVars : [
		'namePane',
		'chosenCategorySymbol'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #'header pane' }
CategoryViewer >> addHeaderMorph [
	"Add the header at the top of the viewer, with a control for choosing the category, etc."

	| header aButton |
	header := AlignmentMorph newRow color: self color; wrapCentering: #center; cellPositioning: #leftCenter.
	header beSticky.
	header layoutInset: 0.
	header cellInset: 0.
	aButton := self tanOButton.
	header addMorph: aButton.
	aButton setBalloonText: 'remove this pane from the screen
don''t worry -- nothing will be lost!' translated.
	header addMorphBack: self spacerAfterButton.
	self addMorph: header.
	self addNamePaneTo: header.
	chosenCategorySymbol := #basic
]

{ #category : #entries }
CategoryViewer >> addIsOverColorDetailTo: aRow [
	"Special-casee code for the boolean-valued phrase variously known as is-over-color or sees-color."

	| hotTileForSelf |
	aRow addMorphBack: (Morph new color: self color; extent: 0@10).  "spacer"
	hotTileForSelf := ColorTileMorph new showPalette: false;
				typeColor: (ScriptingSystem colorForType: #Color); yourself.
	hotTileForSelf colorSwatch color: Color blue.
	 hotTileForSelf on: #mouseEnter send: #addGetterFeedback to: aRow.
	hotTileForSelf on: #mouseLeave send: #removeHighlightFeedback to: aRow.
	hotTileForSelf on: #mouseLeaveDragging send: #removeHighlightFeedback to: aRow.
	hotTileForSelf  on: #mouseDown send: #makeGetter:event:from:
		to: self
		withValue: (Array with: #seesColor: with: #Color).
        aRow addMorphBack: hotTileForSelf.



"The following commented-out code put a readout up; the readout was very nice, but was very consumptive of cpu time, which is why the is-over-color tile got removed from the viewer long ago.  Now is-over-color is reinstated to the viewer, minus the expensive readout..."

"	aRow addMorphBack: (AlignmentMorph new beTransparent).
	readout := UpdatingStringMorphWithArgument new
			target: scriptedPlayer; getSelector: #seesColor:; growable: false; putSelector: nil;
			argumentTarget: clrTile colorSwatch argumentGetSelector: #color.
	readout useDefaultFormat.
	aTile := StringReadoutTile new typeColor: Color lightGray lighter.
	aTile addMorphBack: readout.
	aRow addMorphBack: aTile.
	aTile setLiteralTo: (scriptedPlayer seesColor: clrTile colorSwatch color) printString width: 30"
]

{ #category : #'header pane' }
CategoryViewer >> addNamePaneTo: header [ 
	"Add the namePane, which is a pop-up"

	| triangle aLabel |
	namePane := BorderedMorph new.
	namePane layoutPolicy: TableLayout new.
	namePane hResizing: #spaceFill.
	namePane listDirection: #leftToRight.
	namePane wrapCentering: #center.
	namePane cellInset: 2.
	namePane layoutInset: 6 @ 0.

	namePane color: ScriptingSystem baseColor.
	namePane borderColor: (self userInterfaceTheme titleBorderColor
ifNil: [(Color r: 0.6 g: 0.7 b: 1)]).
	namePane borderWidth: 0.

	namePane height: TileMorph defaultH.
	namePane useRoundedCornersInEtoys.

	triangle := ImageMorph new image: (ScriptingSystem formAtKey: #MenuTriangle).
	namePane addMorph: triangle.
	aLabel := StringMorph contents: '---------' font: ScriptingSystem fontForViewerCategoryPopups.

	namePane addMorphBack: aLabel.
	namePane on: #mouseDown send: #chooseCategory to: self.
	header addMorphBack: namePane
]

{ #category : #entries }
CategoryViewer >> addOverlapsDetailTo: aRow [
	"Disreputable magic: add necessary items to a viewer row abuilding for the overlaps phrase"

	aRow addMorphBack: (Morph new color: self color; extent: 2@10).  "spacer"
	aRow addMorphBack:  self tileForSelf.
	aRow addMorphBack: (AlignmentMorph new beTransparent).  "flexible spacer"


]

{ #category : #entries }
CategoryViewer >> addTouchesADetailTo: aRow [
	| clrTile |
	aRow addMorphBack: (Morph new color: self color; extent: 2@10).  " spacer"
	aRow addMorphBack: (clrTile := self tileForSelf).
	aRow addMorphBack: (AlignmentMorph new beTransparent).  "flexible spacer"

	"readout := UpdatingStringMorphWithArgument new
			target: scriptedPlayer; getSelector: #seesColor:; growable: false; putSelector: nil;
			argumentTarget: clrTile colorSwatch argumentGetSelector: #color.
	readout useDefaultFormat.
	aTile := StringReadoutTile new typeColor: Color lightGray lighter.
	aTile addMorphBack: readout.
	aRow addMorphBack: aTile.
	aTile setLiteralTo: (scriptedPlayer seesColor: clrTile colorSwatch color) printString width: 30"
]

{ #category : #categories }
CategoryViewer >> adjustColorsAndBordersWithin [
	"Adjust the colors and borders of submorphs to suit current fashion"

	self allMorphsDo: [:aMorph | 
		(aMorph isKindOf: TilePadMorph) ifTrue:
			[aMorph beTransparent].
		(aMorph isKindOf: PhraseTileMorph) ifTrue:
			[aMorph beTransparent.
			aMorph borderWidth: 0].

		(aMorph isKindOf: TileMorph)
			ifTrue:
				[aMorph borderWidth: 1]].

]

{ #category : #'e-toy support' }
CategoryViewer >> adoptVocabulary: aVocabulary [
	"Adopt the given vocabulary as the one used in this viewer."

	| aCategory |
	chosenCategorySymbol ifNil: [^ self delete].
	aCategory := aVocabulary categoryAt: chosenCategorySymbol.
	aCategory ifNil: [self delete] ifNotNil: [self updateCategoryNameTo: aCategory wording].
	super adoptVocabulary: aVocabulary
]

{ #category : #'get\/set slots' }
CategoryViewer >> arrowSetterButton: sel args: argArray [

	| m |
	m := RectangleMorph new
		color: (ScriptingSystem colorForType: #command);
		extent: (ScriptingSystem formAtKey: #Gets) extent;
		borderWidth: 0.
	m addMorphCentered: (ImageMorph new image: (ScriptingSystem formAtKey: #Gets)).
	m setBalloonText: 'drag from here to obtain an assignment phrase.' translated.
	m on: #mouseDown send: sel
		to: self
		withValue: argArray.
	^ m

]

{ #category : #'get\/set slots' }
CategoryViewer >> arrowSetterButtonFor: partName type: partType [

	| m |
	m := RectangleMorph new
		color: (ScriptingSystem colorForType: #command);
		extent: 24@TileMorph defaultH;
		borderWidth: 0.
	m addMorphCentered: (ImageMorph new image: (ScriptingSystem formAtKey: 'Gets')).
	m setBalloonText: 'drag from here to obtain an assignment phrase.' translated.
	m on: #mouseDown send: #makeSetter:event:from:
		to: self
		withValue: (Array with: partName with: partType).
	^ m

]

{ #category : #categories }
CategoryViewer >> beReplacedByCategory: chosenCategory [
	"Be replaced by a category pane pointed at the chosen category"

	self outerViewer replaceSubmorph: self by: (self outerViewer categoryViewerFor: chosenCategory)
	
]

{ #category : #support }
CategoryViewer >> booleanPhraseForBounceOnColorOfType: retrieverType retrieverOp: retrieverOp player: aPlayer [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase getterPhrase receiverTile  rel finalTile |
	rel := (Vocabulary vocabularyForType:  retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	getterPhrase :=  PhraseTileMorph new setBounceOnColorOperator: retrieverOp type: retrieverType rcvrType: #Player argType: nil.
	getterPhrase submorphs third delete.
	getterPhrase submorphs second setSlotRefOperator: retrieverOp.
	"getterPhrase submorphs second setPatchDefaultTo: (scriptedPlayer defaultPatchPlayer)."
	getterPhrase submorphs first changeTableLayout.
	receiverTile := aPlayer tileToRefer bePossessive.
	"self halt."
	receiverTile position: getterPhrase firstSubmorph position.
	getterPhrase firstSubmorph addMorph: receiverTile.

	outerPhrase firstSubmorph addMorph: getterPhrase.
	finalTile := ScriptingSystem tileForArgType: retrieverType.	"comes with arrows"
	outerPhrase submorphs last addMorph: finalTile.
	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #support }
CategoryViewer >> booleanPhraseForBounceOnOfType: retrieverType retrieverOp: retrieverOp player: aPlayer [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase getterPhrase receiverTile  rel finalTile |
	rel := (Vocabulary vocabularyForType:  retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	getterPhrase :=  PhraseTileMorph new setBounceOnOperator: retrieverOp type: retrieverType rcvrType: #Player argType: nil.
	getterPhrase submorphs second setSlotRefOperator: retrieverOp.
	getterPhrase submorphs first changeTableLayout.
	receiverTile := aPlayer tileToRefer bePossessive.
	"self halt."
	receiverTile position: getterPhrase firstSubmorph position.
	getterPhrase firstSubmorph addMorph: receiverTile.

	outerPhrase firstSubmorph addMorph: getterPhrase.
	finalTile := ScriptingSystem tileForArgType: retrieverType.	"comes with arrows"
	outerPhrase submorphs last addMorph: finalTile.
	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #support }
CategoryViewer >> booleanPhraseForGetAngleToOfType: retrieverType retrieverOp: retrieverOp player: aPlayer [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase getterPhrase receiverTile  rel finalTile |
	rel := (Vocabulary vocabularyForType:  retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	getterPhrase :=  PhraseTileMorph new setAngleToOperator: retrieverOp type: retrieverType rcvrType: #Player argType: nil.
	getterPhrase submorphs second setSlotRefOperator: retrieverOp.
	getterPhrase submorphs second setArgumentDefaultTo: scriptedPlayer.
	getterPhrase submorphs first changeTableLayout.
	receiverTile := aPlayer tileToRefer bePossessive.
	receiverTile position: getterPhrase firstSubmorph position.
	getterPhrase firstSubmorph addMorph: receiverTile.

	outerPhrase firstSubmorph addMorph: getterPhrase.
	finalTile := ScriptingSystem tileForArgType: retrieverType.	"comes with arrows"
	outerPhrase submorphs last addMorph: finalTile.
	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #support }
CategoryViewer >> booleanPhraseForGetColorComponentOfType: retrieverType componentName: componentName retrieverOp: retrieverOp player: aPlayer [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase getterPhrase receiverTile  rel finalTile |
	rel := (Vocabulary vocabularyForType:  retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	getterPhrase :=  PhraseTileMorph new setGetColorComponentOperator: retrieverOp componentName: componentName type: retrieverType rcvrType: #Player argType: nil.
	getterPhrase submorphs second setSlotRefOperator: retrieverOp.
	getterPhrase submorphs second setPatchDefaultTo: (scriptedPlayer defaultPatchPlayer).
	getterPhrase submorphs first changeTableLayout.
	receiverTile := aPlayer tileToRefer bePossessive.
	"self halt."
	receiverTile position: getterPhrase firstSubmorph position.
	getterPhrase firstSubmorph addMorph: receiverTile.

	outerPhrase firstSubmorph addMorph: getterPhrase.
	finalTile := ScriptingSystem tileForArgType: retrieverType.	"comes with arrows"
	outerPhrase submorphs last addMorph: finalTile.
	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #support }
CategoryViewer >> booleanPhraseForGetDistanceToOfType: retrieverType retrieverOp: retrieverOp player: aPlayer [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase getterPhrase receiverTile  rel finalTile |
	rel := (Vocabulary vocabularyForType:  retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	getterPhrase :=  PhraseTileMorph new setDistanceToOperator: retrieverOp type: retrieverType rcvrType: #Player argType: nil.
	getterPhrase submorphs second setSlotRefOperator: retrieverOp.
	getterPhrase submorphs second setArgumentDefaultTo: scriptedPlayer.
	getterPhrase submorphs first changeTableLayout.
	receiverTile := aPlayer tileToRefer bePossessive.
	"self halt."
	receiverTile position: getterPhrase firstSubmorph position.
	getterPhrase firstSubmorph addMorph: receiverTile.

	outerPhrase firstSubmorph addMorph: getterPhrase.
	finalTile := ScriptingSystem tileForArgType: retrieverType.	"comes with arrows"
	outerPhrase submorphs last addMorph: finalTile.
	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #support }
CategoryViewer >> booleanPhraseForGetPatchValueOfType: retrieverType retrieverOp: retrieverOp player: aPlayer [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase getterPhrase receiverTile  rel finalTile |
	rel := (Vocabulary vocabularyForType:  retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	getterPhrase :=  PhraseTileMorph new setGetPixelOperator: retrieverOp type: retrieverType rcvrType: #Player argType: nil.
	getterPhrase submorphs second setSlotRefOperator: retrieverOp.
	getterPhrase submorphs second setArgumentDefaultTo: (scriptedPlayer defaultPatchPlayer).
	getterPhrase submorphs first changeTableLayout.
	receiverTile := aPlayer tileToRefer bePossessive.
	"self halt."
	receiverTile position: getterPhrase firstSubmorph position.
	getterPhrase firstSubmorph addMorph: receiverTile.

	outerPhrase firstSubmorph addMorph: getterPhrase.
	finalTile := ScriptingSystem tileForArgType: retrieverType.	"comes with arrows"
	outerPhrase submorphs last addMorph: finalTile.
	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #support }
CategoryViewer >> booleanPhraseForGetTurtleAtOfType: retrieverType retrieverOp: retrieverOp player: aPlayer [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase getterPhrase receiverTile  rel finalTile |
	rel := (Vocabulary vocabularyForType:  retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	getterPhrase :=  PhraseTileMorph new setTurtleAtOperator: retrieverOp type: retrieverType rcvrType: #Player argType: nil.
	getterPhrase submorphs third delete.
	getterPhrase submorphs second setSlotRefOperator: retrieverOp.
	getterPhrase submorphs second setTurtleDefaultTo: scriptedPlayer.
	getterPhrase submorphs first changeTableLayout.
	receiverTile := aPlayer tileToRefer bePossessive.
	"self halt."
	receiverTile position: getterPhrase firstSubmorph position.
	getterPhrase firstSubmorph addMorph: receiverTile.

	outerPhrase firstSubmorph addMorph: getterPhrase.
	finalTile := ScriptingSystem tileForArgType: retrieverType.	"comes with arrows"
	outerPhrase submorphs last addMorph: finalTile.
	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #support }
CategoryViewer >> booleanPhraseForGetTurtleOfOfType: retrieverType retrieverOp: retrieverOp player: aPlayer [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase getterPhrase receiverTile  rel finalTile |
	rel := (Vocabulary vocabularyForType:  retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	getterPhrase :=  PhraseTileMorph new setTurtleOfOperator: retrieverOp type: retrieverType rcvrType: #Player argType: nil.
	getterPhrase submorphs second setSlotRefOperator: retrieverOp.
	getterPhrase submorphs first changeTableLayout.
	receiverTile := aPlayer tileToRefer bePossessive.
	"self halt."
	receiverTile position: getterPhrase firstSubmorph position.
	getterPhrase firstSubmorph addMorph: receiverTile.

	outerPhrase firstSubmorph addMorph: getterPhrase.
	finalTile := ScriptingSystem tileForArgType: retrieverType.	"comes with arrows"
	outerPhrase submorphs last addMorph: finalTile.
	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #support }
CategoryViewer >> booleanPhraseForGetUpHillOfType: retrieverType retrieverOp: retrieverOp player: aPlayer [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase getterPhrase receiverTile  rel finalTile |
	rel := (Vocabulary vocabularyForType:  retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	getterPhrase :=  PhraseTileMorph new setUpHillOperator: retrieverOp type: retrieverType rcvrType: #Player argType: nil.
	getterPhrase submorphs second setSlotRefOperator: retrieverOp.
	getterPhrase submorphs second setArgumentDefaultTo: (scriptedPlayer defaultPatchPlayer).
	getterPhrase submorphs first changeTableLayout.
	receiverTile := aPlayer tileToRefer bePossessive.
	"self halt."
	receiverTile position: getterPhrase firstSubmorph position.
	getterPhrase firstSubmorph addMorph: receiverTile.

	outerPhrase firstSubmorph addMorph: getterPhrase.
	finalTile := ScriptingSystem tileForArgType: retrieverType.	"comes with arrows"
	outerPhrase submorphs last addMorph: finalTile.
	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #support }
CategoryViewer >> booleanPhraseForRetrieverOfType: retrieverType retrieverOp: retrieverOp player: aPlayer [
	"Answer a boolean-valued phrase derived from a retriever (e.g. 'car's heading'); this is in order to assure that tiles laid down in a TEST area will indeed produce a boolean result"

	| outerPhrase getterPhrase receiverTile  rel finalTile |
	rel := (Vocabulary vocabularyForType:  retrieverType) comparatorForSampleBoolean.
	outerPhrase := PhraseTileMorph new setOperator: rel type: #Boolean rcvrType: retrieverType argType: retrieverType.
	getterPhrase :=  PhraseTileMorph new setOperator: retrieverOp type: retrieverType rcvrType: #Player.
	getterPhrase submorphs last setSlotRefOperator: retrieverOp.
	getterPhrase submorphs first changeTableLayout.
	receiverTile := aPlayer tileToRefer bePossessive.
	receiverTile position: getterPhrase firstSubmorph position.
	getterPhrase firstSubmorph addMorph: receiverTile.

	outerPhrase firstSubmorph addMorph: getterPhrase.
	finalTile := ScriptingSystem tileForArgType: retrieverType.	"comes with arrows"
	outerPhrase submorphs last addMorph: finalTile.
	outerPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: rel).    
	^ outerPhrase
]

{ #category : #support }
CategoryViewer >> booleanPhraseFromPhrase: phrase [
	"Answer, if possible, a boolean-valued phrase derived from the phrase provided"

	|  retrieverOp retrieverTile |
	(phrase isKindOf: ParameterTile orOf: FunctionTile) ifTrue: [^ phrase booleanComparatorPhrase].

	phrase isBooleanType ifTrue: [^ phrase].
	((scriptedPlayer respondsTo: #costume) 
		and:[scriptedPlayer costume isInWorld not]) ifTrue: [^ Array new].

	((phrase isMemberOf: PhraseTileMorph) and: [phrase submorphs size > 1] and: [#(bearingTo: distanceToPlayer:) includes: phrase submorphs second operatorOrExpression])
		ifTrue:
			[^ self booleanPhraseFromNumericGetterWithArgument: phrase].

	((retrieverTile := phrase submorphs last) isKindOf: TileMorph) ifFalse: [^ phrase].
	retrieverOp := retrieverTile operatorOrExpression.

	(Vocabulary vocabularyForType: phrase resultType)
		affordsCoercionToBoolean ifTrue: [
			retrieverOp =  #getPatchValueIn: ifTrue: [
				^ self booleanPhraseForGetPatchValueOfType: phrase resultType retrieverOp: retrieverOp player: phrase actualObject.
			].
			retrieverOp =  #getRedComponentIn: ifTrue: [
				^ self booleanPhraseForGetColorComponentOfType: phrase resultType componentName: #red  retrieverOp: retrieverOp player: phrase actualObject.
			].
			retrieverOp =  #getGreenComponentIn: ifTrue: [
				^ self booleanPhraseForGetColorComponentOfType: phrase resultType componentName: #green  retrieverOp: retrieverOp player: phrase actualObject.
			].
			retrieverOp =  #getBlueComponentIn: ifTrue: [
				^ self booleanPhraseForGetColorComponentOfType: phrase resultType componentName: #blue retrieverOp: retrieverOp player: phrase actualObject.
			].
			retrieverOp = #getUphillIn: ifTrue: [
				^ self booleanPhraseForGetUpHillOfType: phrase resultType retrieverOp: retrieverOp player: phrase actualObject.
			].
			retrieverOp = #getDistanceTo: ifTrue: [
				^ self booleanPhraseForGetDistanceToOfType: phrase resultType retrieverOp: retrieverOp player: phrase actualObject.
			].
			retrieverOp = #getAngleTo: ifTrue: [
				^ self booleanPhraseForGetAngleToOfType: phrase resultType retrieverOp: retrieverOp player: phrase actualObject.
			].
			retrieverOp = #bounceOn: ifTrue: [
				^ self booleanPhraseForBounceOnOfType: phrase resultType retrieverOp: retrieverOp player: phrase actualObject.
			].
"			(retrieverOp = #bounceOn:color: or: [retrieverOp = #bounceOnColor:]) ifTrue: [
				^ self booleanPhraseForBounceOnColorOfType: phrase resultType retrieverOp: retrieverOp player: phrase actualObject.
			]."
			"retrieverOp = #getTurtleAt: ifTrue: [
				^ self booleanPhraseForGetTurtleAtOfType: phrase resultType retrieverOp: retrieverOp player: phrase actualObject.
			]."
			retrieverOp = #getTurtleOf: ifTrue: [
				^ self booleanPhraseForGetTurtleOfOfType: phrase resultType retrieverOp: retrieverOp player: phrase actualObject.
			].

			^ self booleanPhraseForRetrieverOfType: phrase resultType retrieverOp: retrieverOp player: phrase actualObject.

		].
	^ phrase
]

{ #category : #categories }
CategoryViewer >> categoryNameWhoseTranslatedWordingIs: aWording [
	"Answer the category name with the given wording"

	| result |
	result := self currentVocabulary categoryWhoseTranslatedWordingIs: aWording.
	^ result
		ifNotNil:
			[result categoryName]
		ifNil:
			[aWording]
]

{ #category : #support }
CategoryViewer >> categoryRestorationInfo [
	"Answer info needed to reincarnate myself"

	^ self chosenCategorySymbol
]

{ #category : #categories }
CategoryViewer >> categoryWhoseTranslatedWordingIs: aWording [
	"Answer the elementCategory with the given wording"

	^ self currentVocabulary categoryWhoseTranslatedWordingIs: aWording
]

{ #category : #categories }
CategoryViewer >> categoryWording: aCategoryWording [
	"Make the category with the given wording be my current one."

	self categoryNameMorph contents: aCategoryWording.
	self removeAllButFirstSubmorph. "that being the header"
	self addAllMorphs:
		((scriptedPlayer tilePhrasesForCategory: chosenCategorySymbol inViewer: self)).
	self enforceTileColorPolicy.
	self secreteCategorySymbol.
	self world ifNotNil: [self world startSteppingSubmorphsOf: self].
	self adjustColorsAndBordersWithin.

	owner ifNotNil: [owner isStandardViewer ifTrue: [owner fitFlap]]
]

{ #category : #categories }
CategoryViewer >> chooseCategory [
	"The mouse went down on my category-list control; pop up a list of category choices"

	| aList aMenu reply aLinePosition lineList special |
	Cursor wait showWhile: [
	
		aList := (scriptedPlayer categoriesForViewer: self) asOrderedCollection.
		special :=  {ScriptingSystem nameForScriptsCategory.  ScriptingSystem nameForInstanceVariablesCategory}.
		aList removeAllFoundIn: special.
		aList := special, aList.
		aLinePosition := aList indexOf: #miscellaneous ifAbsent: [nil].
		aList := aList collect:	
			[:aCatSymbol | self currentVocabulary categoryWordingAt: aCatSymbol].

		lineList := aLinePosition ifNil: [#(2)] ifNotNil: [Array with: 2 with: aLinePosition].
		aMenu := CustomMenu labels: aList lines: lineList selections: aList.
		reply := aMenu startUpWithCaption: 'category' translated.
		reply ifNil: [^ self].
		self chooseCategoryWhoseTranslatedWordingIs: reply asSymbol.
		self assureCategoryFullyVisible
	]
]

{ #category : #categories }
CategoryViewer >> chooseCategoryWhoseTranslatedWordingIs: aWording [
	"Choose the category with the given wording"

	self chosenCategorySymbol: (self categoryNameWhoseTranslatedWordingIs: aWording)

]

{ #category : #categories }
CategoryViewer >> chosenCategorySymbol [
	"Answer the inherent category currently being shown, not necessarily the same as the translated word."

	^ chosenCategorySymbol ifNil: [self secreteCategorySymbol]
]

{ #category : #categories }
CategoryViewer >> chosenCategorySymbol: aCategorySymbol [
	"Make the given category be my current one."

	| aCategory wording |
	chosenCategorySymbol := aCategorySymbol.
	aCategory := self currentVocabulary categoryAt: chosenCategorySymbol.
	wording := aCategory ifNil: [aCategorySymbol] ifNotNil: [aCategory wording].
	self categoryWording: wording.
	aCategorySymbol asSymbol = #tests ifTrue: [self addMorph: self phraseForTest after: self submorphs first].

	aCategorySymbol asSymbol = #miscellaneous ifTrue: [self addMorph: self phraseForTimesRepeat after: self submorphs first].

]

{ #category : #'editing pane' }
CategoryViewer >> contents: c notifying: k [
	"later, spruce this up so that it can accept input such as new method source"
	
	Beeper beep.
	^ false
]

{ #category : #support }
CategoryViewer >> contentsSelection [
	"Not well understood why this needs to be here!"
	^ 1 to: 0
]

{ #category : #categories }
CategoryViewer >> currentCategory [
	"Answer the symbol representing the receiver's currently-selected category"

	| current |
	current := self categoryNameMorph contents.
	^ current ifNotNil: [current asSymbol] ifNil: [#basic translated]
]

{ #category : #macpal }
CategoryViewer >> currentVocabulary [
	"Answer the vocabulary currently installed in the viewer.  The outer StandardViewer object holds this information."

	^ self outerViewer
		ifNotNil: [:viewer | viewer currentVocabulary]
		ifNil: [(self world ifNil: [self currentWorld]) currentVocabularyFor: scriptedPlayer]
]

{ #category : #categories }
CategoryViewer >> downArrowHit [
	self previousCategory
]

{ #category : #initialization }
CategoryViewer >> establishContents [
	"Perform any initialization steps that needed to wait until I am installed in my outer viewer"
]

{ #category : #'get\/set slots' }
CategoryViewer >> getterButtonFor: getterSelector type: partType [
	"Answer a classic-tiles getter button for a part of the given name"

	| m inherent wording |
	m := TileMorph new adoptVocabulary: self currentVocabulary.

	inherent := getterSelector inherentSelector.
	wording := (scriptedPlayer slotInfo includesKey: inherent)
		ifTrue: [inherent]
		ifFalse: [self currentVocabulary tileWordingForSelector: 
getterSelector].
	m setOperator: getterSelector andUseWording: wording.
	m typeColor: (ScriptingSystem colorForType: partType).
	m on: #mouseDown send: #makeGetter:event:from:
		to: self
		withValue: (Array with: getterSelector with: partType).
	^ m
]

{ #category : #'get\/set slots' }
CategoryViewer >> getterTilesFor: getterSelector type: aType [ 
	"Answer classic getter for the given name/type"

	"aPhrase := nil, assumed"

	| selfTile selector aPhrase |
	(#(#color:sees: #colorSees) includes: getterSelector) 
		ifTrue: [aPhrase := self colorSeesPhrase].
	(#(#getPatchValueIn:) includes: getterSelector)
		ifTrue: [aPhrase := self patchValuePhrase].
	(#(#getRedComponentIn:) includes: getterSelector)
		ifTrue: [aPhrase := self colorComponentPhraseFor: #red].
	(#(#getGreenComponentIn:) includes: getterSelector)
		ifTrue: [aPhrase := self colorComponentPhraseFor: #green].
	(#(#getBlueComponentIn:) includes: getterSelector)
		ifTrue: [aPhrase := self colorComponentPhraseFor: #blue].
	(#(#getUphillIn:) includes: getterSelector)
		ifTrue: [aPhrase := self patchUphillPhrase].
	(#(#bounceOn:) includes: getterSelector)
		ifTrue: [aPhrase := self bounceOnPhrase].
"	(#(#bounceOn:color: #bounceOnColor:) includes: getterSelector)
		ifTrue: [aPhrase := self bounceOnColorPhrase]."
	(getterSelector = #getDistanceTo:)
		ifTrue: [aPhrase := self distanceToPhrase].
	(getterSelector = #getAngleTo:)
		ifTrue: [aPhrase := self angleToPhrase].
	(getterSelector = #getTurtleOf:)
		ifTrue: [aPhrase := self turtleOfPhrase].

	(getterSelector = #distanceToPlayer:)
		ifTrue: [aPhrase := self distanceToPlayerPhrase].
	(getterSelector = #bearingTo:)
		ifTrue: [aPhrase := self bearingToPhrase].
	(getterSelector = #bearingFrom:)
		ifTrue: [aPhrase := self bearingFromPhrase].

	(#(#seesColor: #isOverColor) includes: getterSelector) 
		ifTrue: [aPhrase := self seesColorPhrase].
	(#(#overlaps: #overlaps) includes: getterSelector) 
		ifTrue: [aPhrase := self overlapsPhrase].
	(#(#overlapsAny: #overlapsAny) includes: getterSelector) 
		ifTrue: [aPhrase := self overlapsAnyPhrase].
	(#(#touchesA: #touchesA) includes: getterSelector) 
		ifTrue: [aPhrase := self touchesAPhrase].
	aPhrase ifNil: 
			[aPhrase := PhraseTileMorph new setSlotRefOperator: getterSelector asSymbol
						type: aType].
	selfTile := self tileForSelf bePossessive.
	selfTile position: aPhrase firstSubmorph position.
	aPhrase firstSubmorph addMorph: selfTile.
	selector := aPhrase submorphs second.
	
	(#(#getPatchValueIn: getUphillIn: bearingFrom: bearingTo: distanceToPlayer:) includes: getterSelector) ifFalse: [
		(Vocabulary vocabularyNamed: aType capitalized) 
			ifNotNil: [:aVocab | aVocab wantsSuffixArrow ifTrue: [selector addSuffixArrow]].
	].
	selector updateLiteralLabel.
	aPhrase enforceTileColorPolicy.
	^aPhrase
]

{ #category : #entries }
CategoryViewer >> infoButtonFor: aScriptOrSlotSymbol [
	"Answer a fully-formed morph that will serve as the 'info button' alongside an entry corresponding to the given slot or script symbol.  If no such button is appropriate, answer a transparent graphic that fills the same space."

	| aButton |
	(self wantsRowMenuFor: aScriptOrSlotSymbol) ifFalse:
		["Fill the space with sweet nothing, since there is no meaningful menu to offer"
		aButton := RectangleMorph new beTransparent extent: (17@20).
		aButton borderWidth: 0.
		^ aButton].

	aButton := self menuButton.
	aButton target: scriptedPlayer;
		actionSelector: #infoFor:inViewer:;
		arguments: (Array with:aScriptOrSlotSymbol with: self).
	aButton setBalloonText: 'Press here to get a menu' translated.
	^ aButton
]

{ #category : #initialization }
CategoryViewer >> initializeFor: aPlayer [
	"Initialize the category pane to show the #basic category by default"

	^ self initializeFor: aPlayer categoryChoice: #basic

]

{ #category : #initialization }
CategoryViewer >> initializeFor: aPlayer categoryChoice: aChoice [
	"Initialize the receiver to be associated with the player and category specified"

	scriptedPlayer := aPlayer.
	self addHeaderMorph.

	self chooseCategoryWhoseTranslatedWordingIs: aChoice

]

{ #category : #support }
CategoryViewer >> invisiblySetPlayer: aPlayer [
	scriptedPlayer := aPlayer
]

{ #category : #support }
CategoryViewer >> isSpecialPatchCase: aPlayer and: cmd [
	"Boolean - Kedama  hook - answer whether the player and command provided represent a 'special patch case'."

	aPlayer isPlayerLike ifFalse: [^ false].
	((aPlayer costume renderedMorph class = KedamaMorph) and: [cmd = #addToPatchDisplayList:]) ifTrue: [
		^ true.
	].
	(aPlayer costume renderedMorph class = KedamaPatchMorph) ifTrue: [
		(#(#redComponentInto: #greenComponentInto: #blueComponentInto:
			#redComponentFrom: #greenComponentFrom: #blueComponentFrom:) includes: cmd) ifTrue: [
			^ true.
		].
	].

	(aPlayer costume renderedMorph class = KedamaTurtleMorph) ifTrue: [
		(#(#colorFromPatch: #colorToPatch:) includes: cmd) ifTrue: [
			^ true.
		].
	].


	^ false.

]

{ #category : #support }
CategoryViewer >> isSpecialPatchReceiver: aPlayer and: cmd [
	"Boolean - Kedama  hook - answer whether it's true both that the object provided is  a Player whose costume is a KedamaPatchMorph AND that the command provided is  one of six special <color>Component<from | to> commands such as #greenComponentFrom: "

	^ aPlayer isPlayerLike and: [aPlayer costume renderedMorph class = KedamaPatchMorph] and: [
		(#(#redComponentInto: #greenComponentInto: #blueComponentInto:
			#redComponentFrom: #greenComponentFrom: #blueComponentFrom:) includes: cmd)].

]

{ #category : #scripting }
CategoryViewer >> isTileScriptingElement [
	"Answer whether the receiver is a tile-scripting element"

	^ true
]

{ #category : #support }
CategoryViewer >> limitClass [
	"Answer the receiver's limitClass"

	| outer |
	^ (outer := self outerViewer)
		ifNotNil:
			[outer limitClass]
		ifNil:
			[ProtoObject]
]

{ #category : #'e-toy support' }
CategoryViewer >> localeChanged [
	"Update myself to reflect the change in locale"

	chosenCategorySymbol ifNil: [^ self delete].
	self updateCategoryNameTo: ((self currentVocabulary ifNil: [Vocabulary eToyVocabulary]) categoryWordingAt: chosenCategorySymbol)
]

{ #category : #'get\/set slots' }
CategoryViewer >> makeGetter: args event: evt from: aMorph [
	"Hand the user tiles representing a classic getter on the slot represented by aMorph"

	| tiles |
	tiles := self getterTilesFor: args first type: args second.
	owner
		ifNotNil:	[self primaryHand attachMorph: tiles]
		ifNil: 		[^ tiles]

]

{ #category : #'get\/set slots' }
CategoryViewer >> makeGetter: arg1 from: arg2 forPart: arg3 [
	"Reorder the arguments for existing event handlers"
	(arg3 isMorph and:[arg3 eventHandler notNil]) ifTrue:[arg3 eventHandler fixReversedValueMessages].
	^self makeGetter: arg1 event: arg2 from: arg3
]

{ #category : #'get\/set slots' }
CategoryViewer >> makeSetter: selectorAndTypePair event: evt from: aMorph [ 
	"Classic tiles: make a Phrase that comprises a setter of a slot, and hand it to the user."

	| argType m argTile selfTile argValue actualGetter |
	selectorAndTypePair first = #getPatchValueIn: ifTrue: [^ self makeSetterForGetPatchValue: selectorAndTypePair event: evt from: aMorph].
	selectorAndTypePair first = #getRedComponentIn: ifTrue: [^ self makeSetterForColorComponent: selectorAndTypePair componentName: #red event: evt from: aMorph].
	selectorAndTypePair first = #getBlueComponentIn: ifTrue: [^ self makeSetterForColorComponent: selectorAndTypePair componentName: #blue event: evt from: aMorph].
	selectorAndTypePair first = #getGreenComponentIn: ifTrue: [^ self makeSetterForColorComponent: selectorAndTypePair componentName: #green event: evt from: aMorph].
	
	argType := selectorAndTypePair second.
	actualGetter := selectorAndTypePair first asSymbol.
	m := PhraseTileMorph new 
				setAssignmentRoot: actualGetter inherentSelector
				type: #command
				rcvrType: #Player
				argType: argType
				vocabulary: self currentVocabulary.
	argValue := self scriptedPlayer 
				perform: selectorAndTypePair first asSymbol.
	argValue isPlayerLike
		ifTrue: [argTile := argValue tileReferringToSelf]
		ifFalse: 
			[argTile := ScriptingSystem tileForArgType: argType.
			(argType == #Number and: [argValue isNumber]) 
				ifTrue: 
					[(scriptedPlayer decimalPlacesForGetter: actualGetter) 
						ifNotNil: [:places | (argTile findA: UpdatingStringMorph) decimalPlaces: places]].
			argTile
				setLiteral: argValue;
				updateLiteralLabel].
	argTile position: m lastSubmorph position.
	m lastSubmorph addMorph: argTile.
	selfTile := self tileForSelf bePossessive.
	selfTile position: m firstSubmorph position.
	m firstSubmorph addMorph: selfTile.
	m enforceTileColorPolicy.
	m openInHand
]

{ #category : #'get\/set slots' }
CategoryViewer >> makeSetter: arg1 from: arg2 forPart: arg3 [
	"Reorder the arguments for existing event handlers"
	(arg3 isMorph and:[arg3 eventHandler notNil]) ifTrue:[arg3 eventHandler fixReversedValueMessages].	
	^self makeSetter: arg1 event: arg2 from: arg3
]

{ #category : #'get\/set slots' }
CategoryViewer >> makeSetterForColorComponent: selectorAndTypePair componentName: componentName event: evt from: aMorph [ 

	| argType m argTile selfTile argValue actualGetter |
	argType := selectorAndTypePair second.
	componentName = #red ifTrue: [actualGetter := #setRedComponentIn:].
	componentName = #green ifTrue: [actualGetter := #setGreenComponentIn:].
	componentName = #blue ifTrue: [actualGetter := #setBlueComponentIn:].
	m := PhraseTileMorph new 
				setColorComponentRoot: actualGetter
				componentName: componentName
				type: #command
				rcvrType: #Patch
				argType: argType
				vocabulary: self currentVocabulary.
	argValue := self scriptedPlayer 
				perform: selectorAndTypePair first asSymbol with: nil.
	(argValue isKindOf: Player) 
		ifTrue: [argTile := argValue tileReferringToSelf]
		ifFalse: 
			[argTile := ScriptingSystem tileForArgType: argType.
			(argType == #Number and: [argValue isNumber]) 
				ifTrue: 
					[(scriptedPlayer decimalPlacesForGetter: actualGetter) 
						ifNotNil: [:places | (argTile findA: UpdatingStringMorph) decimalPlaces: places]].
			argTile
				setLiteral: argValue;
				updateLiteralLabel].
	argTile position: m lastSubmorph position.
	m lastSubmorph addMorph: argTile.
	selfTile := self tileForSelf bePossessive.
	selfTile position: m firstSubmorph position.
	m firstSubmorph addMorph: selfTile.
	m enforceTileColorPolicy.
	m submorphs second setPatchDefaultTo: scriptedPlayer defaultPatchPlayer.

	m openInHand
]

{ #category : #'get\/set slots' }
CategoryViewer >> makeSetterForGetPatchValue: selectorAndTypePair event: evt from: aMorph [ 

	| argType m argTile selfTile argValue actualGetter |
	argType := selectorAndTypePair second.
	actualGetter := #patchValueIn:.
	m := PhraseTileMorph new 
				setPixelValueRoot: actualGetter
				type: #command
				rcvrType: #Player
				argType: argType
				vocabulary: self currentVocabulary.
	argValue := self scriptedPlayer 
				perform: selectorAndTypePair first asSymbol with: nil.
	(argValue isPlayerLike) 
		ifTrue: [argTile := argValue tileReferringToSelf]
		ifFalse: 
			[argTile := ScriptingSystem tileForArgType: argType.
			(argType == #Number and: [argValue isNumber]) 
				ifTrue: 
					[(scriptedPlayer decimalPlacesForGetter: actualGetter) 
						ifNotNil: [:places | (argTile findA: UpdatingStringMorph) decimalPlaces: places]].
			argTile
				setLiteral: argValue;
				updateLiteralLabel].
	argTile position: m lastSubmorph position.
	m lastSubmorph addMorph: argTile.
	selfTile := self tileForSelf bePossessive.
	selfTile position: m firstSubmorph position.
	m firstSubmorph addMorph: selfTile.
	m enforceTileColorPolicy.
	m submorphs second setPatchDefaultTo: scriptedPlayer defaultPatchPlayer.

	m openInHand
]

{ #category : #'get\/set slots' }
CategoryViewer >> makeUniversalTilesGetter: aMethodInterface event: evt from: aMorph [
	"Button in viewer performs this to make a universal-tiles getter and attach it to hand."

	| newTiles |
	newTiles := self newGetterTilesFor: scriptedPlayer methodInterface: aMethodInterface.
	newTiles setProperty: #beScript toValue: true.
	owner ifNil: [^ newTiles].
	self currentHand attachMorph: newTiles.
	newTiles align: newTiles topLeft with: evt hand position + (7@14).
]

{ #category : #'header pane' }
CategoryViewer >> maybeAddArrowsTo: header [
	"Maybe add up/down arrows to the header"

	| wrpr |
	header addTransparentSpacerOfSize: 5@5.
	header addUpDownArrowsFor: self.
	(wrpr := header submorphs last) submorphs second setBalloonText: 'previous category' translated.	
	wrpr submorphs first  setBalloonText: 'next category' translated
]

{ #category : #'get\/set slots' }
CategoryViewer >> newGetterTilesFor: aPlayer methodInterface: aMethodInterface [
	"Return universal tiles for a getter on this property.  Record who self is."

	| ms argTile argArray |
	ms := MessageSend receiver: aPlayer selector: aMethodInterface selector arguments: #().

	"Handle three idiosyncratic cases..."
	aMethodInterface selector == #color:sees: ifTrue:
		[argTile := ScriptingSystem tileForArgType: #Color.
		argArray := Array with: argTile colorSwatch color with: argTile colorSwatch color copy. 
		ms arguments: argArray].
	aMethodInterface selector == #seesColor: ifTrue:
		[argTile := ScriptingSystem tileForArgType: #Color.
		ms arguments: (Array with: argTile colorSwatch color)].

	(#(touchesA: overlaps: overlapsAny:) includes: aMethodInterface selector) ifTrue:
		[argTile := ScriptingSystem tileForArgType: #Player.
		ms arguments: (Array with: argTile actualObject)].

	^ ms asTilesIn: aPlayer class globalNames: (aPlayer class officialClass ~~ CardPlayer)
			"For CardPlayers, use 'self'.  For others, name it, and use its name."
]

{ #category : #'get\/set slots' }
CategoryViewer >> newMakeGetter: arg event: evt from: aMorph [
	"Button in viewer performs this to makea universal-tiles header tile and attach to hand."

	^ self makeUniversalTilesGetter: arg event: evt from: aMorph
]

{ #category : #'get\/set slots' }
CategoryViewer >> newMakeGetter: arg1 from: arg2 forMethodInterface: arg3 [
	"Button in viewer performs this to make a new style tile and attach to hand. (Reorder the arguments for existing event handlers)"

	(arg3 isMorph and: [arg3 eventHandler notNil]) ifTrue:
		[arg3 eventHandler fixReversedValueMessages].
	 ^ self makeUniversalTilesGetter: arg1 event: arg2 from: arg3
]

{ #category : #'get\/set slots' }
CategoryViewer >> newMakeGetter: arg1 from: arg2 forPart: arg3 [
	"Reorder the arguments for existing event handlers"
	(arg3 isMorph and:[arg3 eventHandler notNil]) ifTrue:[arg3 eventHandler fixReversedValueMessages].
	^self newMakeGetter: arg1 event: arg2 from: arg3
]

{ #category : #'get\/set slots' }
CategoryViewer >> newMakeSetter: aSpec event: evt from: aMorph [
	"Button in viewer performs this to make a new style tile and attach to hand."

	| m |
	m := self newTilesFor: scriptedPlayer setter: aSpec.
	owner ifNotNil: [self primaryHand attachMorph: m.
			m align: m topLeft with: evt hand position + (7@14)]
		ifNil: [^ m].

]

{ #category : #'get\/set slots' }
CategoryViewer >> newMakeSetter: arg1 from: arg2 forPart: arg3 [
	"Reorder the arguments for existing event handlers"
	(arg3 isMorph and:[arg3 eventHandler notNil]) ifTrue:[arg3 eventHandler fixReversedValueMessages].
	^self newMakeSetter: arg1 event: arg2 from: arg3
]

{ #category : #'get\/set slots' }
CategoryViewer >> newMakeSetterFromInterface: aMethodInterface evt: evt from: aMorph [ 
	"Button in viewer performs this to make a new style tile and attach to hand."

	| m |
	m := self newSetterTilesFor: scriptedPlayer methodInterface: aMethodInterface.
	m setProperty: #beScript toValue: true.

	owner
		ifNotNil: [self primaryHand attachMorph: m.
			m align: m topLeft with: evt hand position + (7@14)]
		ifNil: [^ m]

]

{ #category : #'get\/set slots' }
CategoryViewer >> newSetterTilesFor: aPlayer methodInterface: aMethodInterface [
	"Return universal tiles for a setter on this property.  Record who self is."

	| ms argValue makeSelfGlobal phrase |
	argValue := aPlayer perform: aMethodInterface selector.
	ms := MessageSend receiver: aPlayer 
		selector: aMethodInterface companionSetterSelector 
		arguments: (Array with: argValue).
	makeSelfGlobal := aPlayer class officialClass ~~ CardPlayer.
	phrase := ms asTilesIn: aPlayer class globalNames: makeSelfGlobal.
			"For CardPlayers, use 'self'.  For others, name it, and use its name."
	makeSelfGlobal ifFalse: [phrase setProperty: #scriptedPlayer toValue: aPlayer].
	^ phrase
]

{ #category : #'get\/set slots' }
CategoryViewer >> newTilesFor: aPlayer setter: aSpec [
	| ms  argValue |
	"Return universal tiles for a getter on this property.  Record who self is."

	argValue := aPlayer perform: (aSpec second asSymbol asGetterSelector).
	ms := MessageSend receiver: aPlayer selector: aSpec ninth arguments: (Array with: argValue).
	^ ms asTilesIn: aPlayer class globalNames: (aPlayer class officialClass ~~ CardPlayer)
			"For CardPlayers, use 'self'.  For others, name it, and use its name."
]

{ #category : #categories }
CategoryViewer >> nextCategory [
	"Change the receiver to point at the category following the one currently seen"

	| aList anIndex newIndex already aChoice |
	aList := (scriptedPlayer categoriesForViewer: self) collect:
		[:aCatSymbol | self currentVocabulary categoryWordingAt: aCatSymbol].

	already := self outerViewer ifNil: [#()] ifNotNil: [self outerViewer categoriesCurrentlyShowing].
	anIndex := aList indexOf: self currentCategory.
	newIndex := anIndex = aList size
		ifTrue:		[1]
		ifFalse:		[anIndex + 1].
	[already includes: (aChoice := aList at: newIndex)] whileTrue:
		[newIndex := (newIndex \\ aList size) + 1].
	self chooseCategoryWhoseTranslatedWordingIs: aChoice
]

{ #category : #support }
CategoryViewer >> outerViewer [
	"Answer the StandardViewer or equivalent that contains this object"
	^ self ownerThatIsA: Viewer
]

{ #category : #entries }
CategoryViewer >> phraseForCommandFrom: aMethodInterface [
	"Answer a phrase for the non-slot-like command represented by aMethodInterface - classic tiles"

	| aRow resultType cmd names argType argTile selfTile aPhrase balloonTextSelector stat inst aDocString universal tileBearingHelp |
	aDocString := aMethodInterface documentation.
	aDocString = 'no help available' ifTrue: [aDocString := nil].
	names := scriptedPlayer class namedTileScriptSelectors.

	resultType := aMethodInterface resultType.
	cmd := aMethodInterface selector.
	(universal := scriptedPlayer isUniversalTiles)
		ifTrue:
			[aPhrase := scriptedPlayer universalTilesForInterface: aMethodInterface]
		ifFalse: [cmd numArgs == 0
			ifTrue:
				[aPhrase := PhraseTileMorph new vocabulary: self currentVocabulary.
				aPhrase setOperator: cmd
					type: resultType
					rcvrType: #Player]
			ifFalse:
				["only one arg supported in classic tiles, so if this is fed
				with a selector with > 1 arg, results will be very strange"
				argType := aMethodInterface typeForArgumentNumber: 1.
				aPhrase := PhraseTileMorph new vocabulary: self currentVocabulary.
				(self isSpecialPatchReceiver: scriptedPlayer and: cmd) ifTrue: [
					aPhrase setOperator: cmd
						type: resultType
						rcvrType: #Patch
						argType: argType.
				] ifFalse: [
					aPhrase setOperator: cmd
						type: resultType
						rcvrType: #Player
						argType: argType.
				].
				(self isSpecialPatchCase: scriptedPlayer and: cmd) ifTrue: [
					argTile := (Vocabulary vocabularyForType: argType) defaultArgumentTileFor: scriptedPlayer.
				] ifFalse: [
					argTile := ScriptingSystem tileForArgType: argType forCommand: cmd.
				].
				(#(bounce: wrap:) includes: cmd) ifTrue:
					["help for the embattled bj"
					argTile setLiteral: 'silence'; updateLiteralLabel].
				argTile position: aPhrase lastSubmorph position.
				aPhrase lastSubmorph addMorph: argTile]].

	(scriptedPlayer slotInfo includesKey: cmd)
		ifTrue: [balloonTextSelector := #userSlot].

	(scriptedPlayer belongsToUniClass and: [scriptedPlayer class includesSelector: cmd])
		ifTrue:
			[aDocString ifNil:
				[aDocString := (scriptedPlayer class userScriptForPlayer: scriptedPlayer selector: cmd) documentation].
			aDocString ifNil:
				[balloonTextSelector := #userScript]].

	tileBearingHelp := universal ifTrue: [aPhrase submorphs second] ifFalse: [aPhrase operatorTile]. 
	aDocString
		ifNotNil:
			[tileBearingHelp setBalloonText: aDocString]
		ifNil:
			[balloonTextSelector ifNil:
				[tileBearingHelp setProperty: #inherentSelector toValue: cmd.
				balloonTextSelector := nil].
			tileBearingHelp balloonTextSelector: balloonTextSelector].
	aPhrase markAsPartsDonor.
	cmd == #emptyScript ifTrue:
		[aPhrase setProperty: #newPermanentScript toValue: true.
		aPhrase setProperty: #newPermanentPlayer toValue: scriptedPlayer.
		aPhrase submorphs second setBalloonText: 
'drag and drop to 
add a new script' translated].

	universal ifFalse:
		[selfTile := self tileForSelf.
		selfTile position: aPhrase firstSubmorph position.
		aPhrase firstSubmorph addMorph: selfTile].

	aRow := ViewerLine newRow.
	aRow elementSymbol: cmd asSymbol.

	aRow addMorphBack: (
		(balloonTextSelector = #userSlot)
			ifTrue: [(self infoButtonFor: cmd)]
			ifFalse: [cmd = #emptyScript
				ifTrue: [ScriptingSystem buttonSpacer]
				ifFalse: [ScriptingSystem tryButtonFor: aPhrase]]).

	aRow addMorphBack: self spacerAfterButton.

	aRow addMorphBack: aPhrase.
	"aPhrase on: #mouseEnter send: #addCommandFeedback to: aRow.
	aPhrase on: #mouseLeave send: #removeHighlightFeedback to: aRow.
	aPhrase on: #mouseLeaveDragging send: #removeHighlightFeedback to: aRow."

	(names includes: cmd) ifTrue:
		[aPhrase userScriptSelector: cmd.
		cmd numArgs == 0 ifTrue:
			[aPhrase beTransparent.
			aRow addMorphBack: AlignmentMorph newVariableTransparentSpacer.
			aRow addMorphBack: (stat := (inst := scriptedPlayer scriptInstantiationForSelector: cmd) statusControlMorph).
			inst updateStatusMorph: stat]].

	aRow beSticky; disableDragNDrop.

	^ aRow
]

{ #category : #entries }
CategoryViewer >> phraseForVariableFrom: aMethodInterface [
	"Return a structure consisting of tiles and controls and a readout representing a 'variable' belonging to the player, complete with an appropriate readout when indicated.  Functions in both universalTiles mode and classic mode.  Slightly misnamed in that this path is used for any methodInterface that indicates an interesting resultType."

	| anArrow slotName getterButton cover inner aRow doc setter tryer universal hotTileForSelf spacer buttonFont varName |
	aRow := ViewerLine newRow
		color: self color;
		beSticky;
		elementSymbol: (slotName := aMethodInterface selector);
		wrapCentering: #center;
		cellPositioning: #leftCenter.
	(universal := scriptedPlayer isUniversalTiles) ifFalse:
		[buttonFont := Preferences standardEToysFont.
			aRow addMorphBack: (Morph new color: self color;
					 extent: (((buttonFont widthOfString: '!') + 8) @ (buttonFont height + 6));
					 yourself)].  "spacer"
	aRow addMorphBack: (self infoButtonFor: slotName).
	aRow addMorphBack: (Morph new color: self color; extent: 0@10).  " vertical spacer"
	universal
		ifTrue:
			[inner := scriptedPlayer universalTilesForGetterOf: aMethodInterface.
			cover := Morph new color: Color transparent.
			cover extent: inner fullBounds extent.
			(getterButton := cover copy) addMorph: cover; addMorphBack: inner.
			cover on: #mouseDown send: #makeUniversalTilesGetter:event:from: 
					to: self withValue: aMethodInterface.
			aRow addMorphFront:  (tryer := ScriptingSystem tryButtonFor: inner).
			tryer color: tryer color lighter lighter]
		ifFalse:
			[hotTileForSelf := self tileForSelf bePossessive.
			hotTileForSelf  on: #mouseDown send: #makeGetter:event:from:
				to: self
				withValue: (Array with: aMethodInterface selector with: aMethodInterface resultType).
			aRow addMorphBack: hotTileForSelf.
			aRow addMorphBack: (spacer := Morph new color: self color; extent: 2@10).
			spacer on: #mouseEnter send: #addGetterFeedback to: aRow.
			spacer on: #mouseLeave send: #removeHighlightFeedback to: aRow.
			spacer on: #mouseLeaveDragging send: #removeHighlightFeedback to: aRow.
			spacer  on: #mouseDown send: #makeGetter:event:from:
				to: self
				withValue: (Array with: aMethodInterface selector with: aMethodInterface resultType).
			hotTileForSelf on: #mouseEnter send: #addGetterFeedback to: aRow.
			hotTileForSelf on: #mouseLeave send: #removeHighlightFeedback to: aRow.
			hotTileForSelf on: #mouseLeaveDragging send: #removeHighlightFeedback to: aRow.
			getterButton := self getterButtonFor: aMethodInterface selector type: aMethodInterface resultType].
	aRow addMorphBack: getterButton.
	getterButton on: #mouseEnter send: #addGetterFeedback to: aRow.
	getterButton on: #mouseLeave send: #removeHighlightFeedback to: aRow.
	getterButton on: #mouseLeaveDragging send: #removeHighlightFeedback to: aRow.
	(doc := aMethodInterface documentation) ifNotNil:
		[getterButton setBalloonText: doc].

	(scriptedPlayer slotInfo includesKey: (varName := slotName inherentSelector)) "user slot"
		ifTrue:
			["aRow addTransparentSpacerOfSize: 3@0.
			aRow addMorphBack: (self slotTypeMenuButtonFor: varName)"].

	universal ifFalse:
		[(slotName == #seesColor:) ifTrue:
			[self addIsOverColorDetailTo: aRow.
			^ aRow].
		(slotName == #touchesA:) ifTrue:
			[self addTouchesADetailTo: aRow.
			^ aRow].
		(slotName == #overlaps: or: [ slotName == #overlapsAny:]) ifTrue:
			[self addOverlapsDetailTo: aRow.
			^ aRow]].
	aRow addMorphBack: (AlignmentMorph new beTransparent).  "flexible spacer"
	(setter := aMethodInterface companionSetterSelector) ifNotNil:
		[aRow addMorphBack: (Morph new color: self color; extent: 2@10).  " spacer"
		anArrow := universal 
			ifTrue: [self arrowSetterButton: #newMakeSetterFromInterface:evt:from:  
						args: aMethodInterface]
			ifFalse: [self arrowSetterButton: #makeSetter:from:forPart:
						args: (Array with: slotName with: aMethodInterface resultType)].
		anArrow beTransparent.
		universal ifFalse:
			[anArrow on: #mouseEnter send: #addSetterFeedback to: aRow.
			anArrow on: #mouseLeave send: #removeHighlightFeedback to: aRow.
			anArrow on: #mouseLeaveDragging send: #removeHighlightFeedback to: aRow].
		aRow addMorphBack: anArrow].
	(#(color:sees: playerSeeingColor copy touchesA: overlaps: getTurtleAt: getTurtleOf:) includes: slotName) ifFalse:
 		[(universal and: [slotName == #seesColor:]) ifFalse:
			[aMethodInterface wantsReadoutInViewer ifTrue: 
				[aRow addMorphBack: (self readoutFor: slotName type: aMethodInterface resultType readOnly: setter isNil getSelector: aMethodInterface selector putSelector: setter)]]].
	anArrow ifNotNil: [anArrow step].
	^ aRow
]

{ #category : #categories }
CategoryViewer >> previousCategory [
	"Change the receiver to point at the category preceding the one currently seen"

	| aList anIndex newIndex already aChoice |
	aList := (scriptedPlayer categoriesForViewer: self) collect:
		[:aCatSymbol | self currentVocabulary categoryWordingAt: aCatSymbol].
	already := self outerViewer ifNil: [#()] ifNotNil: [self outerViewer categoriesCurrentlyShowing].
	anIndex := aList indexOf: self currentCategory ifAbsent: [aList size + 1].
	newIndex := anIndex = 1
		ifTrue:		[aList size]
		ifFalse:		[anIndex - 1].
	[already includes: (aChoice := aList at: newIndex)] whileTrue:
		[newIndex := newIndex = 1 ifTrue: [aList size] ifFalse: [newIndex - 1]].

	self chooseCategoryWhoseTranslatedWordingIs: aChoice
]

{ #category : #entries }
CategoryViewer >> readoutFor: partName type: partType readOnly: readOnly getSelector: getSelector putSelector: putSelector [
	"Answer a readout morph for the given part"

	| readout delta |
	readout := (Vocabulary vocabularyForType: partType) updatingTileForTarget: scriptedPlayer partName: partName getter: getSelector setter: putSelector.

	(partType == #Number) ifTrue:
		[(delta := scriptedPlayer arrowDeltaFor: getSelector) = 1
			ifFalse:
				[readout setProperty: #arrowDelta toValue: delta].
		scriptedPlayer setFloatPrecisionFor: readout updatingStringMorph].

	partType == #Point ifTrue:
		[scriptedPlayer setFloatPrecisionFor: readout updatingStringMorph].

	readout step.
	^ readout
]

{ #category : #categories }
CategoryViewer >> secreteCategorySymbol [
	"Set my chosenCategorySymbol by translating back from its representation in the namePane.  Answer the chosenCategorySymbol"

	| aCategory |
	aCategory := self currentVocabulary categoryWhoseTranslatedWordingIs: self currentCategory.
	^ chosenCategorySymbol := aCategory
		ifNotNil:
			[aCategory categoryName]
		ifNil:
			[self currentCategory]
]

{ #category : #initialization }
CategoryViewer >> setCategorySymbolFrom: aChoice [
	"Set my category symbol"

	self chosenCategorySymbol: aChoice asSymbol

]

{ #category : #categories }
CategoryViewer >> showCategoriesFor: aSymbol [
	"Put up a pop-up list of categories in which aSymbol is filed; replace the receiver with a CategoryViewer for the one the user selects, if any"

	| allCategories aVocabulary hits meths chosen aMenu aCaption symbolToReport |
	aVocabulary := self currentVocabulary.
	allCategories := scriptedPlayer categoriesForVocabulary: aVocabulary limitClass: ProtoObject.

	hits := allCategories select:
		[:aCategory | 
			meths := aVocabulary allMethodsInCategory: aCategory forInstance: scriptedPlayer ofClass: scriptedPlayer class.
			meths includes: aSymbol].

	hits isEmpty ifTrue: [^ self inform: 'this tile is not actually suitable for use with this kind of object' translated].

	symbolToReport := (aSymbol beginsWith: 'get') ifTrue: [aSymbol inherentSelector] ifFalse: [aSymbol].

	aMenu := SelectionMenu selections: hits.
	aCaption := hits size = 1
		ifTrue:
			 ['is in the following category' translated]
		ifFalse:
			['can be found in the following categories' translated].

	chosen := aMenu startUpWithCaption:  symbolToReport, ' ', aCaption.
	chosen isEmptyOrNil ifFalse:
		[self outerViewer addCategoryViewerFor: chosen atEnd: true]

	
]

{ #category : #support }
CategoryViewer >> tileForSelf [
	"Return a tile representing the receiver's viewee"

	^ scriptedPlayer tileToRefer

]

{ #category : #categories }
CategoryViewer >> upArrowHit [
	self nextCategory
]

{ #category : #categories }
CategoryViewer >> updateCategoryNameTo: aName [
	"Update the category name, because of a language change."

	self categoryNameMorph contents: aName; color: Color black.
	namePane height: TileMorph defaultH. 
	self world ifNotNil: [self world startSteppingSubmorphsOf: self]
]

{ #category : #entries }
CategoryViewer >> wantsRowMenuFor: aSymbol [
	"Answer whether a viewer row for the given symbol should have a menu button on it"

	| elementType |

	true ifTrue: [^ true].  "To allow show categories item.  So someday this method can be removed, and its sender can stop sending it..."

	elementType := scriptedPlayer elementTypeFor: aSymbol vocabulary: self currentVocabulary.
	(elementType == #systemScript) ifTrue: [^ false].
	((elementType == #systemSlot) and:
		[#(color:sees: touchesA: overlaps: overlapsAny: distanceToPlayer: bearingTo: bearingFrom:) includes: aSymbol]) ifTrue: [^ false].
	^ true
]
