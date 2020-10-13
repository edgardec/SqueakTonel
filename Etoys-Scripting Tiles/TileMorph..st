"
A tile with up, down and suffix arrows.

To install new Forms for the arrows, just nil out UpPicture, DownPicture,
or SuffixPicture.
Create actors with the picture you want and write it out with these file names:
'tile inc arrow.morph' 'tile dec arrow.morph' 'tile suffix
arrow.morph'.  Make sure that file is in the same directory as the image.
Open an EToy.
"
Class {
	#name : #TileMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'type',
		'slotName',
		'literal',
		'operatorOrExpression',
		'actualObject',
		'downArrow',
		'upArrow',
		'suffixArrow',
		'typeColor',
		'lastArrowTick',
		'nArrowTicks',
		'operatorReadoutString',
		'possessive',
		'retractArrow',
		'vocabulary',
		'vocabularySymbol'
	],
	#classVars : [
		'DownPicture',
		'EqualityOperators',
		'RetractPicture',
		'SuffixArrowAllowance',
		'SuffixPicture',
		'UpArrowAllowance',
		'UpPicture',
		'UpdatingOperators',
		'UsePopUpArrows'
	],
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #constants }
TileMorph class >> defaultH [
	"Answer minimal size of tile height. This number is decided from font
	size, icon size, and readout caret size."
	^ ScriptingSystem buttonExtent y max: Preferences standardEToysFont height rounded
]

{ #category : #scripting }
TileMorph class >> defaultNameStemForInstances [
	^ 'Tile' translatedNoop
]

{ #category : #'class initialization' }
TileMorph class >> downPicture [
	^ DownPicture ifNil:[DownPicture := Form
	extent: 9@9
	depth: 16
	fromArray: #( 14253 862794605 862794605 862729101 934150144 14221 724182793 654911241 654913323 931987456 0 793519881 722086698 652880586 862781440 0 931998474 654977834 648621835 0 0 12107 654911209 717895565 0 0 13164 654976681 789250048 0 0 14254 722085546 929890304 0 0 0 860630796 934150144 0 0 0 934098861 0 0)
	offset: 0@0]
]

{ #category : #'class initialization' }
TileMorph class >> fixCaretForms [
	"TileMorph fixCaretForms"
	"UpPicture storeString"
	"DownPicture storeString"

	UpPicture := ((ColorForm
	extent: 9@10
	depth: 1
	fromArray: #( 4152360960 4152360960 3816816640 3816816640 3246391296 3246391296 2155872256 2155872256 0 0)
	offset: 0@0)
	colorsFromArray: #(#(0.321 0.807 0.321) #( )  )).

	DownPicture := ((ColorForm
	extent: 9@10
	depth: 1
	fromArray: #( 0 0 2155872256 2155872256 3246391296 3246391296 3816816640 3816816640 4152360960 4152360960)
	offset: 0@0)
	colorsFromArray: #(#(0.321 0.807 0.321) #( )  )).

	SuffixPicture := (((ColorForm
	extent: 6@11
	depth: 1
	fromArray: #( 2080374784 1006632960 469762048 201326592 67108864 0 67108864 201326592 469762048 1006632960 2080374784)
	offset: 0@0)
	colorsFromArray: #(#(0.321 0.807 0.321) #( )  ))
	colorsFromArray: #(#(0.321 0.807 0.321) #( )  )).

	RetractPicture := ((ColorForm
	extent: 6@11
	depth: 1
	fromArray: #( 4160749568 4026531840 3758096384 3221225472 2147483648 0 2147483648 3221225472 3758096384 4026531840 4160749568)
	offset: 0@0)
	colorsFromArray: #(#(0.321 0.807 0.321) #( )  )).
]

{ #category : #'class initialization' }
TileMorph class >> initialize [
	"TileMorph readInArrowGraphics    -- call manually if necessary to bring graphics forward"
	"TileMorph initialize"

	UpdatingOperators := Dictionary new.
	UpdatingOperators at: #incr: put: #+.
	UpdatingOperators at: #decr: put: #-.
	UpdatingOperators at: #set: put: ''.

	RetractPicture ifNil: [
		RetractPicture := (SuffixPicture flipBy: #horizontal centerAt: (SuffixPicture center))].
	SuffixArrowAllowance := 5 + SuffixPicture width + RetractPicture width.
	UpArrowAllowance := 10.

	EqualityOperators := Dictionary new.
	EqualityOperators at: #< put: #eToysLT:.
	EqualityOperators at: #<= put: #eToysLE:.
	EqualityOperators at: #> put: #eToysGT:.
	EqualityOperators at: #>= put: #eToysGE:.
	EqualityOperators at: #= put: #eToysEQ:.
	EqualityOperators at: #~= put: #eToysNE:.

]

{ #category : #'class initialization' }
TileMorph class >> readInArrowGraphics [
	"TileMorph readInArrowGraphics"

	| obj |
	obj := (FileStream readOnlyFileNamed: 'tile inc arrow.morph') fileInObjectAndCode.
	UpPicture := obj form.

	obj := (FileStream readOnlyFileNamed: 'tile dec arrow.morph') fileInObjectAndCode.
	DownPicture := obj form.

	obj := (FileStream readOnlyFileNamed: 'tile suffix arrow.morph')fileInObjectAndCode.
	SuffixPicture := obj form.
]

{ #category : #'class initialization' }
TileMorph class >> retractPicture [
	^ RetractPicture ifNil:[RetractPicture := Form
	extent: 9@11
	depth: 16
	fromArray: #( 0 0 0 0 934084608 0 0 0 934162252 864813056 0 0 14221 724249354 862715904 0 0 793520938 722021130 864813056 0 864824106 654977802 722086666 864813056 13164 722085641 722086666 722086666 864878592 12043 646523626 722086698 722086666 864878592 14254 858532522 648685290 722086666 864878592 0 14221 789260970 650717962 864878592 0 0 13132 717892331 934084608 0 0 0 932000621 0)
	offset: 8@0]
]

{ #category : #'class initialization' }
TileMorph class >> suffixPicture [
	^ SuffixPicture ifNil:[SuffixPicture := Form
	extent: 9@11
	depth: 16
	fromArray: #( 934084608 0 0 0 0 864825164 934150144 0 0 0 862726922 724252557 0 0 0 864824074 722021162 793509888 0 0 864824074 722086666 654977834 864813056 0 864889610 722086666 722085641 722088812 0 864889610 722086698 722086634 646524683 0 864889610 722085610 648686250 858535854 0 864889610 650717866 789264269 0 0 934095595 717894476 0 0 0 13165 931987456 0 0 0)
	offset: 0@0]
]

{ #category : #'class initialization' }
TileMorph class >> upPicture [
	^ UpPicture ifNil:[UpPicture := Form
	extent: 9@8
	depth: 16
	fromArray: #( 0 0 932001709 0 0 0 14254 793457484 0 0 0 13197 654912266 931987456 0 0 12107 654912266 862715904 0 0 931998474 722020105 724252557 0 0 793455401 724183850 724187021 0 14221 724182761 652879594 652816171 931987456 0 791422634 717892298 648686282 862781440)
	offset: 0@0]
]

{ #category : #preferences }
TileMorph class >> usePopUpArrows [

	<preference: 'Use pop-up arrows for tiles'
	category: 'scripting'
	description: 'If true, uses pop-up arrows in tiles '
	type: #Boolean>
	^ UsePopUpArrows ifNil: [UsePopUpArrows := false].
]

{ #category : #preferences }
TileMorph class >> usePopUpArrows: aBoolean [

	UsePopUpArrows := aBoolean.
]

{ #category : #accessing }
TileMorph >> abandonLabelFocus [
	"If the receiver's label has editing focus, abandon it"
	self flag: #arNote. "Probably unnecessary"
	self currentHand releaseKeyboardFocus: self labelMorph.
]

{ #category : #'dropping\/grabbing' }
TileMorph >> aboutToBeGrabbedBy: aHand [
	"do not allow grabbing me out of a tile or out of a tile pad morph (which itself is in a tile)"
	^ (self owner isTileLike or:
		[self owner owner notNil and: [self owner owner isTileLike]] or:
		[self owner isAlignmentMorph])
			ifTrue: [nil] ifFalse: [self]

]

{ #category : #'code generation' }
TileMorph >> acceptNewLiteral [
	"Tell the scriptEditor who I belong to that I have a new literal value."

	| topScript |
	topScript := self outermostMorphThat:
		[:m | m isKindOf: ScriptEditorMorph].
	topScript ifNotNil: [topScript installWithNewLiteral].
	(self ownerThatIsA: ViewerLine) ifNotNil:
		[:aLine |
			(self ownerThatIsA: PhraseTileMorph) ifNotNil:
				[aLine removeHighlightFeedback.
				self layoutChanged.
				Project current world doOneSubCycle.
				aLine addCommandFeedback: nil]]
]

{ #category : #initialization }
TileMorph >> actualObject [
	^ actualObject
]

{ #category : #arrows }
TileMorph >> addArrows [
	(self class addArrowsOn: self)
		in: [:array | 
			upArrow := array first.
			downArrow := array second]
]

{ #category : #misc }
TileMorph >> addCustomMenuItems:  aMenu hand: aHandMorph [
	"Add custom halo menu items to a menu"

	| aPlayer |
	super addCustomMenuItems: aMenu hand: aHandMorph.
	((aPlayer := self associatedPlayer) notNil and:
		[aPlayer costume isMorph]) ifTrue:
			[aMenu addLine.
			aMenu add: 'hand me this object' translated target: self action: #handReferentMorph.
			aMenu balloonTextForLastItem: 'This tile refers to an actual graphical object; use this menu item to grab that object.  Caution!  This may remove the object from a place it really ought to stay.' translated.
			aMenu addLine ]
]

{ #category : #arrows }
TileMorph >> addRetractArrow [
	"If it's appropriate, add the retract arrow.  Only called when suffixArrow is already present and in submorph tree."

	self couldRetract ifNil: [^ self rescindRetractArrow].

	retractArrow ifNil:
		[retractArrow := ImageMorph new image: RetractPicture].
	self addMorph: retractArrow inFrontOf: suffixArrow.

	fullBounds := nil.
	self extent: self fullBounds extent
]

{ #category : #arrows }
TileMorph >> addSuffixArrow [
	"Add a suffix arrow to the receiver, and set it in my suffixArrow instance variable.  If I already have something there, remove it first."

	suffixArrow ifNotNil: [suffixArrow delete].
	suffixArrow := ImageMorph new image: SuffixPicture.
	self addMorphBack: suffixArrow.
]

{ #category : #arrows }
TileMorph >> addSuffixIfCan [
	"Should this tile have a suffix arrow?"

	self addSuffixArrow.
]

{ #category : #'e-toy support' }
TileMorph >> adoptVocabulary: aVocabulary [
	"Set the receiver's vocabulary"

	vocabularySymbol := aVocabulary vocabularyName.
	self updateWordingToMatchVocabulary.
	super adoptVocabulary: aVocabulary
]

{ #category : #arrows }
TileMorph >> arrowAction: delta [ 
	"Do what is appropriate when an arrow on the tile is pressed; delta will  
	be +1 or -1"
	| index options |
	(type == #literal and: [literal isNumber])
		ifTrue: [self value:
			       (((literal + delta) printShowingDecimalPlaces: self decimalPlaces) asNumber)]
		ifFalse: [options := self options ifNil: [^ self].
			      index := (options first indexOf: self value) + delta.
				self value: (options first atWrap: index).
				(options second atWrap: index) ifNotNil:
					[:bt | submorphs last setBalloonText: bt translated]]
]

{ #category : #'mouse handling' }
TileMorph >> arrowDelta [
	"Answer the amount by which a number I display should increase at a time"

	| readout |
	(readout := self findA: UpdatingStringMorph) ifNotNil: [^readout floatPrecision ].
	^ 1
]

{ #category : #accessing }
TileMorph >> associatedPlayer [
	^ actualObject
]

{ #category : #misc }
TileMorph >> basicWidth [
	"Provide a nominal minimum, exclusive of arrows and independent of label width"

	^ operatorOrExpression
		ifNotNil: [3]
		ifNil: [18]
]

{ #category : #initialization }
TileMorph >> bePossessive [
	possessive := true.
	self line1: actualObject externalName , '''s' translated
]

{ #category : #initialization }
TileMorph >> bringUpToDate [
	"Make certain, if the receiver is an object-reference tile, that it shows the current external name of the object, which may just have changed.  This only applies to the Player regime." 

	(type == #objRef and: [actualObject isPlayerLike]) ifTrue:
		[self emblazonPlayerNameOnReferenceTile]
]

{ #category : #'code generation' }
TileMorph >> codeString [
	^ String streamContents: [:aStream | self storeCodeOn: aStream indent: 1]

]

{ #category : #'change reporting' }
TileMorph >> colorChangedForSubmorph: aSubmorph [
	"Invoked when the user selects a new color on a colorTile or a color-seer-tile; need to recompile the script."
	self acceptNewLiteral
	owner ifNil: [^ self].
	owner isTileLike ifFalse: [owner colorChangedForSubmorph: aSubmorph].
]

{ #category : #private }
TileMorph >> convertAlignment [
	"Convert the receiver's alignment rules"
	| where frame |
	owner ifNotNil:[
		owner class == TilePadMorph ifTrue:[
			owner layoutPolicy: TableLayout new.
			owner hResizing: #shrinkWrap.
			owner vResizing: #spaceFill.
		].
	].
	self layoutPolicy: TableLayout new.
	self cellInset: 2@0.
	self layoutInset: 1@0.
	self listDirection: #leftToRight.
	self wrapCentering: #center.
	self hResizing: #shrinkWrap.
	self vResizing: #spaceFill.
	"Now convert up and down arrow"
	(upArrow notNil and:[upArrow owner == self "e.g., not converted"
		and:[downArrow notNil and:[downArrow owner == self]]]) ifTrue:[
			"where to insert the frame"
			where := (submorphs indexOf: upArrow) min: (submorphs indexOf: downArrow).
			frame := Morph new color: Color transparent.
			frame 
				layoutPolicy: TableLayout new;
				listDirection: #topToBottom;
				hResizing: #shrinkWrap; 
				vResizing: #shrinkWrap;
				cellInset: 0@1;
				layoutInset: 0@1.
			self privateAddMorph: frame atIndex: where.
			frame addMorphBack: upArrow; addMorphBack: downArrow.
		].

]

{ #category : #arrows }
TileMorph >> couldRetract [
	"See if it makes sense to retract this tile and the op before it.  Return the phrase that gets retracted, or nil if not allowed."

	| phrase pad |
	(owner isKindOf: PhraseTileMorph)  "car's x"
		ifTrue:
			[phrase := owner.
			((pad := phrase owner) isKindOf: TilePadMorph)
				ifFalse: [^ nil]]
		ifFalse:
			[(owner isKindOf: TilePadMorph) ifFalse: [^ nil].
			phrase := owner owner.
			((pad := phrase owner) isKindOf: TilePadMorph)
				ifFalse: [^ nil]].

	phrase firstSubmorph type == pad type ifFalse:  "typically it will be of type Player, as in Car's x"
		[phrase submorphs size < 3 ifFalse: [^ nil].	"types should have matched"
		"Go up a level"
		(phrase := pad ownerThatIsA: PhraseTileMorph) ifNil: [^ nil].
		(pad := phrase ownerThatIsA: TilePadMorph) ifNil: [^ nil].
		(phrase firstSubmorph "goodPad") type == pad type ifFalse: [^ nil]].

	(self hasOwner: phrase submorphs last) ifFalse: [^ nil].
	^ phrase

]

{ #category : #misc }
TileMorph >> currentEToyVocabulary [
	"Answer the etoy vocabulary that pertains"
	| aVocab |
	^ (aVocab := self currentVocabulary) isEToyVocabulary
		ifTrue: [aVocab]
		ifFalse: [Vocabulary eToyVocabulary]
]

{ #category : #macpal }
TileMorph >> currentVocabulary [
	"Answer the receiver's current vocabulary"

	| outer aVocab |
	vocabulary ifNotNil:  "old structures -- bring up to date"
		[vocabularySymbol := vocabulary vocabularyName.
		vocabulary := nil].
	^ vocabularySymbol
		ifNotNil:
			[Vocabulary vocabularyNamed: vocabularySymbol]
		ifNil:
			[(outer := self ownerThatIsA: StandardViewer orA: ScriptEditorMorph) 
				ifNotNil:
					[aVocab := outer currentVocabulary.
					vocabularySymbol := aVocab vocabularyName.
					aVocab]
				ifNil:
					[super currentVocabulary]]
]

{ #category : #initialization }
TileMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 1
]

{ #category : #arrows }
TileMorph >> deleteLastTwoTiles [
	"Remove the current suffix (last two tiles) in this line of tiles"
	| phrase pad goodPad |
	(phrase := self couldRetract) ifNil: [^ self].
	pad := phrase ownerThatIsA: TilePadMorph.
	goodPad := phrase firstSubmorph.
	pad owner addMorphBack: goodPad.
	pad delete.
	(goodPad lastSubmorph respondsTo: #addSuffixArrow) 
		ifTrue: [goodPad lastSubmorph addSuffixArrow; addRetractArrow]
		ifFalse: [goodPad lastSubmorph lastSubmorph addSuffixArrow; addRetractArrow].
	goodPad topEditor install. "recompile"
]

{ #category : #arrows }
TileMorph >> deleteSuffixArrow [
	"Delete the suffix and retract arrows if present."

	suffixArrow ifNotNil: [suffixArrow delete].
	suffixArrow := nil.
	retractArrow ifNotNil: ["backward compat"
		retractArrow delete.
		retractArrow := nil].
	self updateLiteralLabel
]

{ #category : #layout }
TileMorph >> fixLayoutOfSubmorphsNotIn: aCollection [ 
	self
		allMorphsDo: [:m | (aCollection includes: m)
				ifFalse: [(m respondsTo: #fixLayoutOfSubmorphsNotIn:)
						ifTrue: [m ~~ self
								ifTrue: [m fixLayoutOfSubmorphsNotIn: aCollection]]
						ifFalse: [m layoutChanged].
					aCollection add: m]].
	self layoutChanged; fullBounds
]

{ #category : #misc }
TileMorph >> handReferentMorph [
	"Hand the user the actual morph referred to"

	| aMorph surrogate |
	((aMorph := actualObject costume) isMorph
		and: [aMorph isWorldMorph not])
			ifTrue: [
				surrogate := CollapsedMorph collapsedMorphOrNilFor: aMorph.
				surrogate
					ifNotNil: [surrogate uncollapseToHand]
					ifNil: [self currentHand attachMorph: aMorph]].
]

{ #category : #'events-processing' }
TileMorph >> handlerForMouseDown: anEvent [
	"Return the (prospective) handler for a mouse down event. The handler is temporarily installed and can be used for morphs further down the hierarchy to negotiate whether the inner or the outer morph should finally handle the event"
	| aPoint |
	upArrow ifNotNil:
		[(upArrow bounds containsPoint: (aPoint := anEvent cursorPoint))
			ifTrue: [^self].
		(downArrow bounds containsPoint: aPoint)
			ifTrue: [^self]].

	^super handlerForMouseDown: anEvent
]

{ #category : #'event handling' }
TileMorph >> handlesMouseDown: evt [
	"Answer whether the receiver would handle the mouseDown represented by evt"

	| aPoint |
	aPoint := evt cursorPoint.
	(operatorOrExpression notNil and: [upArrow notNil]) ifTrue: [^ true].
		"Click on the operator presents list of alternatives"

	upArrow ifNotNil: [^true].
	suffixArrow ifNotNil: [^true].
	retractArrow ifNotNil: [^true].
	^ super handlesMouseDown: evt
]

{ #category : #'event handling' }
TileMorph >> handlesMouseOver: evt [ 
	^ self isPopArrowNeeded
		or: [^super handlesMouseOver: evt]
]

{ #category : #'event handling' }
TileMorph >> handlesMouseStillDown: evt [
	^true
]

{ #category : #initialization }
TileMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self extent: 1 @ 1.
	self
		typeColor: (Color
				r: 0.8
				g: 1.0
				b: 0.6).

	type := #literal.
	"#literal, #slotRef, #objRef, #operator, #expression"
	slotName := ''.
	literal := 1.
	self layoutPolicy: TableLayout new.
	self minCellSize: 0 @ TileMorph defaultH.
	self cellInset: 2 @ 0.
	self layoutInset: 1 @ 0.
	self listDirection: #leftToRight.
	self wrapCentering: #center.
	self hResizing: #shrinkWrap.
	self vResizing: #spaceFill
]

{ #category : #'e-toy support' }
TileMorph >> isCandidateForAutomaticViewing [
	^ false
]

{ #category : #initialization }
TileMorph >> isPossessive [
	possessive isNil ifTrue: [^false].
	^possessive
]

{ #category : #scripting }
TileMorph >> isTileLike [
	"Can be dropped into a script"
	^ true
]

{ #category : #'e-toy support' }
TileMorph >> isTileMorph [
	^ true
]

{ #category : #scripting }
TileMorph >> isTileScriptingElement [
	^ true
]

{ #category : #'dropping\/grabbing' }
TileMorph >> justDroppedInto: aMorph event: anEvent [
	"This message is sent to a dropped morph after it has been dropped on -- and been accepted by -- a drop-sensitive morph"

	super justDroppedInto: aMorph event: anEvent.
	aMorph isPlayfieldLike
		ifTrue:
			[self vResizing: #shrinkWrap]
		ifFalse:
			[(aMorph isTileScriptingElement or: [aMorph isKindOf: TilePadMorph]) ifTrue:
				[self vResizing: #spaceFill]]

]

{ #category : #'dropping\/grabbing' }
TileMorph >> justGrabbedFrom: formerOwner [
	| editor |
	formerOwner ifNil:[^self].
	editor := formerOwner topEditor.
	editor ifNotNil:[editor scriptEdited].
]

{ #category : #accessing }
TileMorph >> labelMorph [
	^ submorphs detect: [:m | m isKindOf: StringMorph] ifNone: [nil].
]

{ #category : #accessing }
TileMorph >> lastTile [
	"The tile that might get an extension arrow"

	^ self
]

{ #category : #layout }
TileMorph >> layoutChanged [
	| vpanel hpanel popArrows |
	super layoutChanged.
	self labelMorph
		ifNil: [^ self].
	popArrows := self activeHand ifNil: [^ self] ifNotNilDo: [:ac |
				ac valueOfProperty: #popArrows
				ifAbsent: [^ self]].
	popArrows first == self
		ifFalse: [^ self].
	vpanel := popArrows second.
	hpanel := popArrows third.
	vpanel
		ifNotNil: [vpanel openInWorld.
			vpanel center: self labelMorph center.
			vpanel right: self labelMorph left - 2].
	hpanel
		ifNotNil: [hpanel openInWorld.
			hpanel center: self labelMorph center.
			hpanel left: self labelMorph right + 2]
]

{ #category : #private }
TileMorph >> line1: line1 [
	"Emblazon the receiver with the requested label.  If the receiver already has a label, make the new label be of the same class"

	| m desiredW classToUse lab f |
	classToUse := (lab := self labelMorph) ifNotNil: [lab class] ifNil: [StringMorph].
	self removeAllMorphs.
	f := ScriptingSystem fontForTiles.
	(type = #operator and: [#(+ - * / // \\ < <= > >= = ~=) includes: operatorOrExpression]) ifTrue: [
		f := f emphasized: 1].
	m := classToUse contents: line1 font: f.
	desiredW := m width + 6.
	self extent: (desiredW max: self minimumWidth) @ self class defaultH.
	m position: self center - (m extent // 2).
	self addMorph: m.

]

{ #category : #accessing }
TileMorph >> literal [

	^ literal

]

{ #category : #accessing }
TileMorph >> literal: anObject [

	literal := anObject.
	self updateLiteralLabel.
	self acceptNewLiteral.		"Show that we are out of date, install is needed"

]

{ #category : #accessing }
TileMorph >> literalFromContents [
	"Get value from StringMorph if it is needed. (See subclass)"
	^ literal
]

{ #category : #'e-toy support' }
TileMorph >> localeChanged [
	"Update myself to reflect the change in locale"

	self updateWordingToMatchVocabulary.
	self fullBounds.
]

{ #category : #misc }
TileMorph >> minimumWidth [
	| aWidth |
	aWidth := self basicWidth.
	upArrow ifNotNil: [aWidth := aWidth + UpArrowAllowance].
	suffixArrow ifNotNil: [aWidth := aWidth + SuffixArrowAllowance].
	^ aWidth
	
]

{ #category : #'event handling' }
TileMorph >> morphToDropInPasteUp: aPasteUp [
	"Answer the morph to drop in aPasteUp, given that the receiver is the putative droppee"

	^ ScriptingTileHolder around: self
]

{ #category : #'event handling' }
TileMorph >> mouseDown: evt [ 
	self setProperty: #previousLiteral toValue: self literalFromContents.
	(upArrow notNil
			and: [(upArrow containsPoint: evt position)
					or: [downArrow containsPoint: evt position]])
		ifTrue: [self setProperty: #previousPoint toValue: evt position].
	self currentHand releaseKeyboardFocus.
	evt hand
		waitForClicksOrDrag: self
		event: evt
		selectors: {#mouseStillDown:. nil. nil. #startDrag:}
		threshold: 5.
	^ super mouseDown: evt
]

{ #category : #'event handling' }
TileMorph >> mouseEnter: evt [

	super mouseEnter:evt.
	^self showPopArrows
]

{ #category : #'event handling' }
TileMorph >> mouseLeave: evt [ 
	"When the mouse is leaving and next object is not a pop arrow, remove
	pop arrows."
	| popArrows vpanel hpanel |
	popArrows := evt hand
				valueOfProperty: #popArrows
				ifAbsent: [^super mouseLeave: evt].
	vpanel := popArrows second.
	hpanel := popArrows third.
	(vpanel notNil
			and: [vpanel containsPoint: evt position])
		ifTrue: [^super mouseLeave: evt].
	(hpanel notNil
			and: [hpanel containsPoint: evt position])
		ifTrue: [^super mouseLeave: evt].
	self hidePopArrows.
	^super mouseLeave: evt
]

{ #category : #'event handling' }
TileMorph >> mouseMove: evt [ 
	"The mouse moved within the receiver; perhaps show a menu."

	| aReadout |
	(self options notNil and:
		 [aReadout := self findA: UpdatingStringMorph.
		aReadout isNil or: [aReadout putSelector notNil]])
			ifTrue:  [^ self showOptions].

	(self hasProperty: #previousLiteral)
		ifFalse: [^ self].
	(self hasProperty: #previousPoint)
		ifFalse: [^ self grabMorph: evt].
	self currentHand releaseKeyboardFocus.
	"Once reviving the value at drag start"
	literal := self valueOfProperty: #previousLiteral.
	"Then applying delta"
	self arrowAction: (self valueOfProperty: #previousPoint) y - evt position y * self arrowDelta abs.
	^ super mouseMove: evt
]

{ #category : #'event handling' }
TileMorph >> mouseStillDown: evt [ 
	"See if arrows are being pressed and call arrowAction:..."
	| aPoint |
	upArrow
		ifNil: [^ super mouseStillDown: evt].
	aPoint := evt cursorPoint.
	(upArrow containsPoint: aPoint)
		ifTrue: [^ self
				variableDelay: [self arrowAction: self arrowDelta]].
	(downArrow containsPoint: aPoint)
		ifTrue: [^ self
				variableDelay: [self arrowAction: self arrowDelta negated]].
	self options
		ifNotNil: [^ self showOptions]
]

{ #category : #'event handling' }
TileMorph >> mouseUp: evt [
	"The mouse came up in the tile; dispatch control to suffix-arrow or retract-arrow handlers if appropriate, else pass to super."

	self removeProperty: #previousLiteral.
	self removeProperty: #previousPoint.
	suffixArrow
		ifNotNil: [(suffixArrow bounds containsPoint: evt cursorPoint)
				ifTrue: [self showSuffixChoices.
					^ self]].
	retractArrow
		ifNotNil: [(retractArrow bounds containsPoint: evt cursorPoint)
				ifTrue: [self retractArrowHit.
					^ self]].
	^ super mouseUp: evt
]

{ #category : #misc }
TileMorph >> numericValue [
	literal isNumber ifFalse: [^ 0].
	^ literal
]

{ #category : #accessing }
TileMorph >> operatorOrExpression [

	^ operatorOrExpression

]

{ #category : #accessing }
TileMorph >> options [
	"Answer the options of the tile for an arrow"
	(type == #literal and: [literal isKindOf: Boolean])
		ifTrue: [^ {{true. false}. #('true' 'false' ) translatedNoop}].
	operatorOrExpression
		ifNil: [^ nil].
	(ScriptingSystem arithmeticalOperatorsAndHelpStrings first includes: operatorOrExpression)
		ifTrue: [^ ScriptingSystem arithmeticalOperatorsAndHelpStrings].
	(ScriptingSystem numericComparitorsAndHelpStrings first includes: operatorOrExpression)
		ifTrue: [self receiverType = #Number
				ifTrue: [^ ScriptingSystem numericComparitorsAndHelpStrings]
				ifFalse: [^ #(#(#= #~=) #('equal' 'not equal')) translatedNoop ]].
	^ nil
]

{ #category : #'change reporting' }
TileMorph >> ownerChanged [
	super ownerChanged.
	(owner class == TilePadMorph and:[owner layoutPolicy isNil]) ifTrue:[
		owner layoutPolicy: TableLayout new.
		owner hResizing: #shrinkWrap.
		owner vResizing: #spaceFill	].
]

{ #category : #arrows }
TileMorph >> phraseForOp: op arg: arg resultType: resultType [
	"Answer a numeric-valued phrase derived from the receiver, whose extension arrow has just been hit.  Pass along my float-precision."

	| phrase srcLabel distLabel |
	phrase := self presenter
				phraseForReceiver: literal
				op: op
				arg: 1
				resultType: #Number.
	srcLabel := self findA: UpdatingStringMorph.
	distLabel := phrase submorphs first submorphs first findA: UpdatingStringMorph.
	srcLabel ifNotNil:
		[distLabel floatPrecision: srcLabel floatPrecision].
	^ phrase
]

{ #category : #accessing }
TileMorph >> playerBearingCode [
	"Answer the actual Player object who will be the 'self' when the receiver is being asked to generate code"

	self topEditor ifNotNil:
		[:anEditor | ^ anEditor playerScripted].
	(self nearestOwnerThat: [:m | m isAViewer]) ifNotNil:
		[:aViewer | ^ aViewer scriptedPlayer].
	^ actualObject
]

{ #category : #commands }
TileMorph >> playerRepresented [
	"Answer the player represented by the receiver. Morphs that serve as 
	references to other morphs reimplement this; by default a morph 
	represents its own player."
	^ type == #objRef
		ifTrue: [actualObject]
		ifFalse: [super playerRepresented]
]

{ #category : #'code generation' }
TileMorph >> precedingTileType [
	"Return the slot reference type of the preceding TileMorph in my owner."

	| row i tile |
	row := owner submorphs.
	i := row indexOf: self.
	((i > 1) and: [(tile := row at: i - 1) isKindOf: TileMorph])
		ifTrue: [^ tile type]
		ifFalse: [^ #unknown].

]

{ #category : #'mouse handling' }
TileMorph >> presentOperatorAlternatives: evt [
	"The receiver is a tile that represents an operator; a click on the receiver's label will pop up a menu of alternative operator choices"

	| result ops |

	((ops := ScriptingSystem arithmeticalOperatorsAndHelpStrings first) includes: operatorOrExpression) ifFalse:
		[((ops := ScriptingSystem numericComparitorsAndHelpStrings first) includes: operatorOrExpression)
			ifFalse: [^ self]].
		
	(result := UIManager default chooseFrom: ops values: ops) ifNotNil:
		[self setOperatorAndUseArrows: result asString.
		self scriptEdited]
]

{ #category : #printing }
TileMorph >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' - ', type printString.
	operatorOrExpression ifNotNil: [aStream nextPutAll: ' op= ', operatorOrExpression printString].
	slotName ifNotNil: [aStream nextPutAll: ' op= ', slotName printString].
]

{ #category : #initialization }
TileMorph >> rawVocabulary: aVocabulary [ 
	"Set the receiver's vocabulary, without side effects."

	vocabularySymbol := (aVocabulary isKindOf: Symbol) 
				ifTrue: [aVocabulary]
				ifFalse: [aVocabulary vocabularyName]
]

{ #category : #accessing }
TileMorph >> receiverType [
	owner
		ifNil: [^ nil].
	owner submorphs size > 0
		ifFalse: [^ nil].
	^ (owner submorphs first respondsTo: #type)
		ifTrue: [owner submorphs first type]
]

{ #category : #initialization }
TileMorph >> referTo: anObject [
	"Make the receiver be an object-reference tile whose referent is anObject"

	type := #objRef.
	typeColor := ScriptingSystem colorForType: anObject basicType.
	actualObject := anObject.
	self line1: anObject uniqueNameForReference
]

{ #category : #initialization }
TileMorph >> referToSimilarObject: anObject [
	"Make the receiver be an object-reference tile whose referent is anObject"
	actualObject := anObject.

]

{ #category : #scripting }
TileMorph >> restoreTypeColor [
	self borderColor: Color black.
	typeColor ifNotNil: [self color: typeColor]
]

{ #category : #accessing }
TileMorph >> resultType [
	"Answer the result type of the receiver"

	type == #literal 
		ifTrue: 
			[(literal isNumber) ifTrue: [^#Number].
			(literal isString) ifTrue: [^#String].
			(literal isKindOf: Boolean) ifTrue: [^#Boolean]].
	(#(expression function) includes: type) ifTrue: [^ #Number].

	type == #objRef ifTrue: [(actualObject costume renderedMorph isMemberOf: KedamaPatchMorph) ifTrue: [^ #Patch] ifFalse: [^#Player]].
	^#unknown
]

{ #category : #initialization }
TileMorph >> retargetFrom: oldPlayer to: newPlayer [
	"Change the receiver so that if formerly it referred to oldPlayer, it refers to newPlayer instead"

	| newLabel |
	(type == #objRef  and: [actualObject == oldPlayer]) ifTrue:
		[actualObject := newPlayer.
		newLabel := actualObject externalName.
		self isPossessive ifTrue:
			[newLabel := newLabel, '''s' translated].
		self line1: newLabel]
]

{ #category : #'code generation' }
TileMorph >> scriptEdited [
	"Tell the scriptEditor who I belong to that I have changed.  "
	| him |
	(him := self outermostMorphThat: [:m| m isKindOf: ScriptEditorMorph])
		ifNotNil: [him scriptEdited]
]

{ #category : #macpal }
TileMorph >> scriptPerformer [
	"Guard against obscure circumstance in which the tile itself has an associated Player, which then might be asked to interact in inappropriate ways with, for example, an UpdatingStringMorph to provide the literal for a RandomNumberTile.  This is at best a finger in the dike.  Still very unsatisfactory!"
	^ self
]

{ #category : #'tiles from method' }
TileMorph >> selectorTile: msgNode in: aScriptor [
	| sel selTile |
	"Make a selector (operator) tile"

	sel := msgNode selector key.
	sel == #color:sees: ifTrue: [
		selTile := (Viewer new) colorSeesPhrase submorphs second.	"ColorSeer tile"
		selTile colorSwatchColor: msgNode arguments first eval.
		^ selTile].
	^ self setOperator: sel
]

{ #category : #initialization }
TileMorph >> setExpression: exprString label: labelString [

	type := #expression.
	operatorOrExpression := exprString.
	self line1: labelString.

]

{ #category : #initialization }
TileMorph >> setLiteral: anObject [
	"Set the receiver's literal to be anObject.  Create a readout morph and add it to the receiver, deleting any existing one that may be there."

	| m already |
	already := submorphs detect: [:aSubMorph  | aSubMorph isKindOf: UpdatingStringMorph] ifNone: [nil].
	already ifNotNil: [already delete].
	type := #literal.
	m := UpdatingStringMorph contents: ' ' font: ScriptingSystem fontForTiles.
	m target: self; getSelector: #literal; putSelector: #literal:.
	(anObject isString or: [ anObject isText]) ifTrue: [m useStringFormat].
	self addMorphBack: m.
	self setLiteralInitially: anObject.

]

{ #category : #misc }
TileMorph >> setLiteralInitially: anObject [
	"Establish the initial literal.  Get the label correct, but do *not* send the value back to the target via the setter (unlike #literal:)"

	literal := anObject.
	self updateLiteralLabel
]

{ #category : #initialization }
TileMorph >> setOperator: aString [
	"Set the operator symbol from the string provided"

	self setOperator: aString andUseWording:  (self currentVocabulary tileWordingForSelector: aString)
]

{ #category : #initialization }
TileMorph >> setOperator: aString andUseWording: wording [
	"Set the operator symbol from the string provided"

	type := #operator.
	operatorOrExpression := aString asSymbol.
 	self line1: wording.
	(ScriptingSystem doesOperatorWantArrows: operatorOrExpression)
		ifTrue: [self addArrows].
	self updateLiteralLabel

	"operatorOrExpression == #heading ifTrue: [self halt]."
]

{ #category : #initialization }
TileMorph >> setOperatorAndUseArrows: aString [
	"Set the operator as per aString, and add up/down arrows"

	type := #operator.
	operatorOrExpression := aString asSymbol.
 	self line1: (self currentVocabulary tileWordingForSelector: operatorOrExpression).
	self addArrows; updateLiteralLabel.
	submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: operatorOrExpression)
]

{ #category : #initialization }
TileMorph >> setSlotRefOperator: getter [
	"getter represents the name of a slot that the receiver is to represent; configure the receiver to serve thi duty, and set upthe wording on the tile appropriately"

	type := #operator.
	operatorOrExpression := getter asSymbol.
	self line1:  (self currentEToyVocabulary tileWordingForSelector: operatorOrExpression).
	self updateLiteralLabel
]

{ #category : #initialization }
TileMorph >> setToReferTo: anObject [
	"Set the receiver to bear an object reference to the given object."
	self flag: #yo.
	type := #objRef.
	actualObject := anObject.
	self line1: anObject nameForViewer.
	self typeColor: (ScriptingSystem colorForType: #Player).
	self enforceTileColorPolicy

]

{ #category : #'mouse handling' }
TileMorph >> showOptions [
	"The receiver is a tile that represents an operator; a click on the 
	receiver's label will pop up a menu of alternative operator choices"
	| result menuChoices word |
	menuChoices := (self options first collect: [:each | each asString]) collect: [:each | 
							word := self currentVocabulary translatedWordingFor: each asSymbol.
							word isEmpty
								ifTrue: ['<-']
								ifFalse: [word]].
	result := (SelectionMenu labelList: menuChoices lines: nil selections: self options first) startUp.
	result 
		ifNotNil: [self value: result.
			self scriptEdited]
]

{ #category : #arrows }
TileMorph >> showSuffixChoices [
	"The suffix arrow has been hit, so respond appropriately"

	| plusPhrase phrase pad outer num |
	self currentEvent shiftPressed ifTrue: [^ self wrapPhraseInFunction].

	(phrase := self ownerThatIsA: PhraseTileMorph orA: FunctionTile) ifNil: [nil].

	(type == #literal) & (literal isNumber) ifTrue: ["Tile is a constant number"
		(phrase isNil or: [phrase finalTilePadSubmorph == owner]) "pad"
			ifTrue: ["we are adding the first time (at end of our phrase)"
				plusPhrase := self phraseForOp: #+ arg: 1 resultType: #Number.
				plusPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: #+).
				owner acceptDroppingMorph: plusPhrase event: self primaryHand lastEvent.
				num := plusPhrase firstSubmorph firstSubmorph.
				num deleteSuffixArrow]].

	(#(function expression parameter) includes: type) ifTrue:
			[pad := self ownerThatIsA: TilePadMorph.
			plusPhrase := self presenter phraseForReceiver: 1  op: #+ arg: 1 resultType: #Number.
			plusPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: #+).
			pad acceptDroppingMorph: plusPhrase event: self primaryHand lastEvent.
			plusPhrase firstSubmorph removeAllMorphs; addMorph: self.
			pad topEditor scriptEdited "recompile"].

	type = #operator ifTrue: ["Tile is accessor of an expression"
		phrase resultType == #Number ifTrue:
			[outer := phrase ownerThatIsA: PhraseTileMorph orA: TimesRepeatTile.
			pad := self ownerThatIsA: TilePadMorph.
			outer ifNotNil:
				[(outer lastSubmorph == pad or: [true]) ifTrue: [ "first time"
					plusPhrase := self presenter phraseForReceiver: 1 
							op: #+ arg: 1 resultType: #Number.
					plusPhrase submorphs second submorphs last setBalloonText: (ScriptingSystem helpStringForOperator: #+).
					pad acceptDroppingMorph: plusPhrase event: self primaryHand lastEvent.
					plusPhrase firstSubmorph removeAllMorphs; addMorph: phrase.	"car's heading"
					pad topEditor scriptEdited "recompile & deal with carets"]]]].

	(self topEditor ifNil: [phrase ifNil: [^ self]]) enforceTileColorPolicy
]

{ #category : #accessing }
TileMorph >> slotName [
	"Caution: the slotName is not in use!"
	^ slotName

]

{ #category : #misc }
TileMorph >> soundChoices [
	"Answer a list of sound choices.  This applies only to tiles that have sound-names as their literals, viz. SoundTiles and SoundReadoutTiles."

	| aList |
	aList := SoundService default sampledSoundChoices asOrderedCollection.
	aList removeAllFoundIn: (ScriptingSystem soundNamesToSuppress copyWithout: literal).
	^aList asArray sort
]

{ #category : #'code generation' }
TileMorph >> storeCodeOn: aStream indent: tabCount [ 
	"Store code representing the receiver onto the stream, with the given amount of indentation"

	| op playerBearingCode |
	playerBearingCode := self playerBearingCode.	"Must determine whom is scripted for what follows to work; if it's ever nil, we've got trouble"
	type = #expression 
		ifTrue: 
			[^aStream
				nextPut: $(;
				nextPutAll: operatorOrExpression;
				nextPut: $)].
	type = #literal 
		ifTrue: 
			[^aStream
				nextPut: $(;
				nextPutAll: literal printString;
				nextPut: $)].
	type == #objRef 
		ifTrue: 
			[^playerBearingCode == actualObject 
				ifTrue: 
					["If the object is the method's own 'self' then we MUST, rather than just MAY, put out 'self' rather than the referencer call, though the latter will temporarily work if only one instance of the uniclass exists."

					aStream nextPutAll: 'self']
				ifFalse: 
					[(actualObject isPlayerLike and: [actualObject isSequentialStub]) ifTrue: [
						actualObject storeCodeOn: aStream indent: tabCount.
					] ifFalse: [
						 Preferences capitalizedReferences 
						ifTrue: 
							["Global dictionary References"

							self flag: #deferred.	"Start deploying the meesage-receiver hints soon"
							aStream nextPutAll: actualObject uniqueNameForReference]
						ifFalse: 
							["old class-inst-var-based scheme used  Feb 1998 to Oct 2000, and indeed
						ongoing in school year 2000-01 at the open school"

							aStream nextPutAll: 'self class '.
							aStream 
								nextPutAll: (playerBearingCode class referenceSelectorFor: actualObject)]]]].
	type = #operator 
		ifTrue: 
			[op := ((UpdatingOperators includesKey: operatorOrExpression) 
				and: [self precedingTileType = #slotRef]) 
					ifTrue: [UpdatingOperators at: operatorOrExpression]
					ifFalse: [operatorOrExpression].
			^op isEmpty 
				ifTrue: [aStream position: aStream position - 1]
				ifFalse: [aStream nextPutAll: (EqualityOperators at: op ifAbsent: [op])]].

	"The following branch has long been disused
	type = #slotRef ifTrue:
		[self isThisEverCalled.
		refType := self slotRefType.
		refType = #get ifTrue:
			[^ aStream
				nextPutAll: targetName;
				space;
				nextPutAll: (Utilities getterSelectorFor: slotName)].
		refType = #set ifTrue:
			[^ aStream
				nextPutAll: targetName;
				space;
				nextPutAll: (Utilities setterSelectorFor: slotName);
				nextPut: $:].
		refType = #update ifTrue:
			[^ aStream
				nextPutAll: targetName;
				space;
				nextPutAll: slotName;
				nextPutAll: ': ';
				nextPutAll: targetName;
				space;
				nextPutAll: slotName]]"
]

{ #category : #private }
TileMorph >> test [
	| pos |
	"Set the position of all my submorphs.  Compute my bounds.  Caller must call layoutChanged or set fullBounds to nil."

	fullBounds ifNil: [
		pos := self topLeft.
		self submorphsDo: [:sub | | hh | 
			hh := (self class defaultH - sub height) // 2.	"center in Y"
			sub privateBounds: (pos + (2@hh) extent: sub extent).
			pos x: (sub right min: 1200)].	"2 pixels spacing on left"
		bounds := bounds topLeft corner: pos + (2 @ self class defaultH).
		fullBounds := bounds.
		].
	owner class == TilePadMorph ifTrue: [owner bounds: bounds].
	^ fullBounds
]

{ #category : #accessing }
TileMorph >> type [

	^ type

]

{ #category : #misc }
TileMorph >> typeColor: aColor [
	"Set the receiver's typeColor"

	self borderColor: ScriptingSystem standardTileBorderColor.

	typeColor := aColor.
	color := ScriptingSystem uniformTileInteriorColor 
]

{ #category : #'player viewer' }
TileMorph >> updateLiteralLabel [
	"Update the wording emblazoned on the tile, if needed"

	| myLabel |
	(myLabel := self labelMorph) ifNil: [^ self].

	myLabel acceptValue:
		(type == #literal
			ifTrue:
				[literal] 
			ifFalse: [operatorReadoutString 
				ifNil:		[self currentEToyVocabulary tileWordingForSelector: operatorOrExpression]
				ifNotNil:  	[operatorReadoutString]]).
	self changed.
]

{ #category : #initialization }
TileMorph >> updateWordingToMatchVocabulary [
	"The current vocabulary has changed; change the wording on my face, if appropriate"

	| aMethodInterface |
	type == #operator ifTrue:
		[self line1: (self currentVocabulary tileWordingForSelector: operatorOrExpression).
		(ScriptingSystem doesOperatorWantArrows: operatorOrExpression)
			ifTrue: [self addArrows].
		self updateLiteralLabel.

		aMethodInterface := self currentVocabulary methodInterfaceAt: operatorOrExpression
			ifAbsent: [
				Vocabulary eToyVocabulary
					methodInterfaceAt: operatorOrExpression ifAbsent: [^ self]].
		self setBalloonText: aMethodInterface documentation.
	].

	type == #objRef ifTrue: [
		self isPossessive
			ifTrue: [self bePossessive]
			ifFalse: [
				self labelMorph ifNotNil: [:label |
					label  contents: self actualObject nameForViewer asSymbol translated]
				]
			].

		"submorphs last setBalloonText: aMethodInterface documentation"
]

{ #category : #accessing }
TileMorph >> updatingStringMorph [
	"If the receiver has an updatingStringMorph as a submorph, answer it, else answer nil"
	
	^ submorphs detect: [:m | m isKindOf: UpdatingStringMorph] ifNone: [nil]
]

{ #category : #scripting }
TileMorph >> useUniformTileColor [
	self color: ScriptingSystem uniformTileInteriorColor
]

{ #category : #accessing }
TileMorph >> value [
	^ type == #literal
		ifTrue: [literal]
		ifFalse: [type == #objRef
				ifTrue: [actualObject]
				ifFalse: [operatorOrExpression]]
]

{ #category : #accessing }
TileMorph >> value: anObject [
	"Set the receiver's 'value'.  For a literal tile, this is the literal itself; for operator tiles it is the operator.  Recompile any enclosing script."

	type == #literal
		ifTrue: [self literal: anObject]
		ifFalse: [self setOperatorAndUseArrows: anObject asString].
	self scriptEdited.
	self layoutChanged
]

{ #category : #arrows }
TileMorph >> variableDelay: aBlock [

	| now delay dt |
	(self hasProperty: #inVariableDelay) ifTrue:[^self].
	nArrowTicks ifNil: [nArrowTicks := 1].
	now := Time millisecondClockValue.
	aBlock value.
	delay := nArrowTicks > 5 ifTrue: [100] ifFalse: [300].
	nArrowTicks := nArrowTicks + 1.
	dt := Time millisecondClockValue - now max: 0.  "Time it took to do."
	dt < delay ifTrue: [
		self setProperty: #inVariableDelay toValue: true.
		self addAlarm: #removeProperty: withArguments: #(inVariableDelay) after: (delay - dt)].

]

{ #category : #copying }
TileMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

	super veryDeepFixupWith: deepCopier.
	actualObject := deepCopier references at: actualObject ifAbsent: [actualObject].
]

{ #category : #copying }
TileMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	type := type veryDeepCopyWith: deepCopier.
	slotName := slotName veryDeepCopyWith: deepCopier.
	literal := literal veryDeepCopyWith: deepCopier.
	operatorOrExpression := operatorOrExpression veryDeepCopyWith: deepCopier.
	"actualObject := actualObject.		Weakly copied"
	downArrow := downArrow veryDeepCopyWith: deepCopier.
	upArrow := upArrow veryDeepCopyWith: deepCopier.
	suffixArrow := suffixArrow veryDeepCopyWith: deepCopier.
	typeColor := typeColor veryDeepCopyWith: deepCopier.
	lastArrowTick := lastArrowTick veryDeepCopyWith: deepCopier.
	nArrowTicks := nArrowTicks veryDeepCopyWith: deepCopier.
	operatorReadoutString := operatorReadoutString veryDeepCopyWith: deepCopier.
	possessive := possessive veryDeepCopyWith: deepCopier.
	retractArrow := retractArrow veryDeepCopyWith: deepCopier.
	vocabularySymbol := vocabularySymbol.  "Weakly copied"
	vocabulary := nil.   "obsolete - clobbered"
]

{ #category : #'event handling' }
TileMorph >> wantsKeyboardFocusFor: aSubmorph [ 
	^ type == #literal
		and: [(literal isKindOf: Boolean) not]
]
