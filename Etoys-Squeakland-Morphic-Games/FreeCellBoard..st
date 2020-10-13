"
The model of a freecell game.  Holds the stacks of cards.
cardDeck		
lastCardDeck		
freeCells		
homeCells		
stacks		array of CardDecks of the columns of cards.
----
Hardness: a number from 1 to 10000.  
	After dealing, count down the number.  For each count, go to next column, pick a ramdom card (with same generator as deck) and move it one place in its stack.  This is a kind of bubble sort.  Interesting that the slowness of bubble sort is a plus -- gives fine gradation in the hardness.
	Moving a card:  Move red cards to deep half, black to shallow (or vice versa).  Within a color, put low cards deep and high cards shallow.  
	If speed is an issue, move several steps at once, decrementing counter. 
	
	(May make it easier?  If running columns, need a way to make harder in other ways.)
"
Class {
	#name : #FreeCellBoard,
	#superclass : #AlignmentMorph,
	#instVars : [
		'cardDeck',
		'lastCardDeck',
		'freeCells',
		'homeCells',
		'stacks',
		'target',
		'actionSelector',
		'hardness'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'new-morph participation' }
FreeCellBoard class >> includeInNewMorphMenu [

	^false
]

{ #category : #actions }
FreeCellBoard >> acceptCard: aCard onStack: aDeck [
	" assumes that number of cards was check at drag time, need to reduce count if dropping
	into an empty stack"
	aCard hasSubmorphs 
		ifTrue: [
			aDeck ifEmpty: [
				(aCard submorphCount+1) > (self maxDraggableStackSize: true)
					ifTrue: [^false]]]
		ifFalse: [^ nil].
	^nil.


]

{ #category : #actions }
FreeCellBoard >> acceptSingleCard: aCard on: aDeck [ 
	"Home cells and free cells don't accept multiple cards on a home cell, 
	defer to deck for other cases"
	aCard hasSubmorphs
		ifTrue: [^ false]
		ifFalse: [^ nil]
]

{ #category : #accessing }
FreeCellBoard >> actionSelector: aSymbolOrString [

	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^ actionSelector := nil].

	actionSelector := aSymbolOrString asSymbol.

]

{ #category : #hardness }
FreeCellBoard >> addHardness [
	| cnt rand pileInd pile |
	"post process the layout of cards to make it harder.  See class comment."

	hardness ifNil: [^ self].
	cnt := hardness.
	rand := Random new seed: cardDeck seed.  "Same numbers but different purpose"
	pileInd := 1. 
	[(cnt := cnt - 1) > 0] whileTrue: [
		pile := stacks atWrap: (pileInd := pileInd + 1).
		cnt := cnt - (self makeHarder: pile rand: rand toDo: cnt)].  "mostly 0, but moves cards"
]

{ #category : #private }
FreeCellBoard >> autoMoveCardsHome [
	| first |

	first := false.
	(self stacks, self freeCells) do: [:deck |
		self homeCells do: [ :homeCell |
			deck hasCards ifTrue: [
				(homeCell repelCard: deck topCard) ifFalse: [
					(self isPlayableCardInHomeCells: deck topCard) ifTrue: [
						first ifFalse: [ " trigger autoMoving event on first move."
							first := true.
							self performActionSelector: #autoMovingHome
						].
						self visiblyMove: deck topCard to: homeCell.
					]
				]
			]
		]
	].


]

{ #category : #undo }
FreeCellBoard >> captureStateBeforeGrab [

	self removeProperty: #stateBeforeGrab.
	self setProperty: #stateBeforeGrab toValue: self capturedState

]

{ #category : #undo }
FreeCellBoard >> capturedState [

	self valueOfProperty: #stateBeforeGrab ifPresentDo: [:st | ^ st].
	^ {	freeCells collect: [:deck | deck submorphs].
		homeCells collect: [:deck | deck submorphs].
		stacks collect: [:deck | deck submorphs] }

]

{ #category : #layout }
FreeCellBoard >> cardCell [

	^PlayingCardDeck new
		layout: #pile; 
		listDirection: #topToBottom;
		enableDragNDrop;
		color: Color transparent;
		borderColor: (Color gray alpha: 0.5);
		borderWidth: 2;
		layoutBounds: (0@0 extent: PlayingCardMorph width @ PlayingCardMorph height);
		yourself
]

{ #category : #accessing }
FreeCellBoard >> cardDeck [
	^cardDeck
]

{ #category : #actions }
FreeCellBoard >> cardMoved [
	"Free cells and stacks do nothing special here - yet - th 12/15/1999 
	16:15 "
	self autoMoveCardsHome
]

{ #category : #actions }
FreeCellBoard >> cardMovedHome [

	self autoMoveCardsHome.
	self performActionSelector: #cardMovedHome.
]

{ #category : #layout }
FreeCellBoard >> cellsRow [
	| row |

	row := (AlignmentMorph newRow)
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap;
		color: Color transparent;
		addAllMorphs: self freeCells;
		addMorphBack: self cellsRowSpacer;
		addAllMorphs: self homeCells;
		yourself.
	^row
]

{ #category : #layout }
FreeCellBoard >> cellsRowSpacer [
	| column |

	column := (AlignmentMorph newColumn)
		vResizing: #rigid;
		hResizing: #rigid;
		color: Color transparent;
		extent: PlayingCardMorph cardSize;
		yourself.
	^column
]

{ #category : #initialization }
FreeCellBoard >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color green
]

{ #category : #actions }
FreeCellBoard >> doubleClickInStack: aDeck OnCard: aCard [

	"if there is an empty free cell, move the card there. otherwise try for an empty stack"

	aCard == aDeck topCard ifFalse: [^self].
	freeCells do: [:freeCell |
		freeCell ifEmpty: [
			self visiblyMove: aCard to: freeCell.
			^ aCard
		]
	].
	stacks do: [ :each |
		each ifEmpty: [
			self visiblyMove: aCard to: each.
			^ aCard
		]
	].

]

{ #category : #actions }
FreeCellBoard >> dragCard: aCard fromHome: aCardDeck [

	^nil		"don't allow any cards to be dragged from a home cell"
]

{ #category : #actions }
FreeCellBoard >> dragCard: aCard fromStack: aCardDeck [
	| i cards |

	cards := aCardDeck cards.
	i := cards indexOf: aCard ifAbsent: [^ nil].
	i > (self maxDraggableStackSize: false) ifTrue: [^ nil].
	[i > 1] whileTrue:
		[(aCardDeck inStackingOrder: (cards at: i-1) 
					onTopOf: (cards at: i)) ifFalse: [^ nil].
		i := i-1].
	^ aCard
]

{ #category : #drawing }
FreeCellBoard >> drawOn: aCanvas [

	"we don't have anything to draw, but we need a color so the inset border of one of our submorphs will work"

]

{ #category : #layout }
FreeCellBoard >> freeCell [
	| freeCell |
	freeCell := self cardCell.
	freeCell stackingPolicy: #single;
	 emptyDropPolicy: #any;
	 target: self;
	 cardDroppedSelector: #cardMoved;
	 acceptCardSelector: #acceptSingleCard:on:.
	^ freeCell
]

{ #category : #layout }
FreeCellBoard >> freeCells [

	^freeCells ifNil: [freeCells := (1 to: 4) collect: [:i | self freeCell]]
]

{ #category : #accessing }
FreeCellBoard >> hardness [
	^ hardness
]

{ #category : #accessing }
FreeCellBoard >> hardness: integer [
	hardness := integer	"or nil"
]

{ #category : #layout }
FreeCellBoard >> homeCell [
	| homeCell |
	homeCell := self cardCell.
	homeCell stackingPolicy: #straight;
	 stackingOrder: #ascending;
	 emptyDropPolicy: #inOrder;
	 target: self;
	 cardDroppedSelector: #cardMovedHome;
	 cardDraggedSelector: #dragCard:fromHome:;
	 acceptCardSelector: #acceptSingleCard:on:.
	^ homeCell
]

{ #category : #layout }
FreeCellBoard >> homeCells [

	^homeCells ifNil: [homeCells := (1 to: 4) collect: [:i | self homeCell]]
]

{ #category : #actions }
FreeCellBoard >> inAutoMove [
	"Return true if an automove sequence is in progress"

	^ owner inAutoMove
]

{ #category : #initialization }
FreeCellBoard >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self listDirection: #topToBottom;
	  hResizing: #shrinkWrap;
	  vResizing: #rigid;
	  height: 500;
	  layout
]

{ #category : #private }
FreeCellBoard >> isPlayableCardInHomeCells: aPlayingCard [
	| unplayedOther topsThisColor topsOtherColor unplayedSame | 
	" are all cards that could be played on this card if it stayed on the stack present in the
	home cells?"

	aPlayingCard cardNumber <= 2 ifTrue: [^true].	"special case for Aces and 2's"
	topsThisColor := OrderedCollection new.
	topsOtherColor := OrderedCollection new.
	self homeCells do: [ :deck |
		deck hasCards ifTrue: [
			(aPlayingCard suitColor == deck topCard suitColor 
					ifTrue: [topsThisColor] ifFalse: [topsOtherColor]) add: deck topCard cardNumber.
		]
	].
	unplayedOther := topsOtherColor size < 2 ifTrue: [1] ifFalse: [topsOtherColor min + 1].
	unplayedSame := topsThisColor size < 2 ifTrue: [1] ifFalse: [topsThisColor min + 1].
	unplayedOther > (aPlayingCard cardNumber - 1) ifTrue: [^true].
	unplayedOther < (aPlayingCard cardNumber - 1) ifTrue: [^false].
	^unplayedSame >= (unplayedOther - 1)

]

{ #category : #layout }
FreeCellBoard >> layout [

	self 
		addMorphBack: self cellsRow;
		addMorphBack: self stacksRow.

]

{ #category : #hardness }
FreeCellBoard >> makeHarder: pile rand: rand toDo: cnt [
	| deepColor ind thisPile thisCard otherCard |
	"Move cards in a stack to make it harder.  Pick a card from the pile.  Only consider moving it deeper (toward last of pile)."

	deepColor := stacks first cards last suitColor.
	ind := ((pile cards size - 1) atRandom: rand).	"front card"
	thisPile := pile cards.  "submorphs array. We will stomp it."
	thisCard := thisPile at: ind.
	otherCard := thisPile at: ind+1.

	"Move deepColor cards deeper, past cards of the other color"
	(thisCard suitColor == deepColor) & (otherCard suitColor ~~ deepColor) ifTrue: [
		thisPile at: ind put: otherCard.
		thisPile at: ind+1 put: thisCard.
		^ 0].	"single moves for now.  Make multiple when it's too slow this way"

	"When colors the same, move low numbered cards deeper, past high cards"
	(thisCard suitColor == otherCard suitColor) ifTrue: [
		(thisCard cardNumber < otherCard cardNumber) ifTrue: [
			thisPile at: ind put: otherCard.
			thisPile at: ind+1 put: thisCard.
			^ 0]].	"single moves for now.  Make multiple when it's too slow this way"
	^ 0
]

{ #category : #private }
FreeCellBoard >> maxDraggableStackSize: dropIntoEmptyStack [
	"Note: dropIntoEmptyStack, means one less empty stack to work with.
		This needs to be reevaluated at time of drop."
	"Not super smart - doesn't use stacks that are buildable though not empty"

	| nFree nEmptyStacks |
	nFree := (freeCells select: [:d | d hasCards not]) size.
	nEmptyStacks := (stacks select: [:d | d hasCards not]) size.
	dropIntoEmptyStack ifTrue: [nEmptyStacks := nEmptyStacks - 1].
	^ (1 + nFree) * (2 raisedTo: nEmptyStacks)
]

{ #category : #private }
FreeCellBoard >> performActionSelector: actionSymbol [ 
	(target notNil and: [actionSelector notNil]) 
		ifTrue: [target perform: actionSelector with: actionSymbol]
]

{ #category : #initialization }
FreeCellBoard >> pickGame: aSeedOrNil [ 
	| sorted msg |
	cardDeck := PlayingCardDeck newDeck.
	aSeedOrNil == 1
		ifTrue: ["Special case of game 1 does a time profile playing the entire 
			(trivial) game."
			sorted := cardDeck submorphs
						sorted: [:a :b | a cardNumber >= b cardNumber].
			cardDeck removeAllMorphs; addAllMorphs: sorted.
			self resetBoard.
			self world doOneCycle.
			Utilities
				informUser: 'Game #1 is a special case
for performance analysis' translated
				during: [msg := self world firstSubmorph.
					msg align: msg topRight with: owner bottomRight.
					MessageTally
						spyOn: [sorted last owner doubleClickOnCard: sorted last]]]
		ifFalse: [aSeedOrNil
				ifNotNil: [cardDeck seed: aSeedOrNil].
			cardDeck shuffle.
			self resetBoard]
]

{ #category : #undo }
FreeCellBoard >> rememberUndoableAction: aBlock named: caption [

	self inAutoMove ifTrue: [^ aBlock value].
	^ super rememberUndoableAction: aBlock named: caption
]

{ #category : #initialization }
FreeCellBoard >> resetBoard [

	self purgeAllCommands.
	self resetFreeCells;
		resetHomeCells;
		resetStacks;
		addHardness;
		changed.
]

{ #category : #initialization }
FreeCellBoard >> resetFreeCells [

	freeCells do: [:deck | deck removeAllCards]
]

{ #category : #initialization }
FreeCellBoard >> resetHomeCells [

	homeCells do: [:deck | deck removeAllCards]
]

{ #category : #initialization }
FreeCellBoard >> resetStacks [
	| card stackStream stack |

	stacks do: [:deck | deck removeAllCards].
	stackStream := ReadStream on: stacks.
	[card := cardDeck deal.
	card notNil] whileTrue: [
		stack := stackStream next ifNil: [stackStream reset; next].
		stack addCard: card].

]

{ #category : #'card in a stack' }
FreeCellBoard >> stack [
	^ PlayingCardDeck new color: Color transparent;
	 layout: #stagger;
	 listDirection: #topToBottom;
	 enableDragNDrop;
	 stackingPolicy: #altStraight;
	 stackingOrder: #descending;
	 emptyDropPolicy: #any;
	 target: self;
	 cardDroppedSelector: #cardMoved;
	 cardDraggedSelector: #dragCard:fromStack:;
	 acceptCardSelector: #acceptCard:onStack:;
	 cardDoubleClickSelector: #doubleClickInStack:OnCard:
]

{ #category : #layout }
FreeCellBoard >> stacks [

	^stacks ifNil: [stacks:= (1 to: 8) collect: [:i | self stack]]
]

{ #category : #layout }
FreeCellBoard >> stacksRow [
	| row |

	row := (AlignmentMorph newRow)
		vResizing: #spaceFill;
		hResizing: #spaceFill;
		wrapCentering: #topLeft;
		cellPositioning: #topLeft;
		color: Color transparent;
		yourself.
	self stacks do: [:stack |
		row 
			addMorphBack: AlignmentMorph newVariableTransparentSpacer;
			addMorphBack: stack].
	row addMorphBack: AlignmentMorph newVariableTransparentSpacer.
	^row
]

{ #category : #accessing }
FreeCellBoard >> target: anObject [

	target := anObject
]

{ #category : #undo }
FreeCellBoard >> undoFromCapturedState: st [
	freeCells with: st first do: [:deck :morphs | deck removeAllMorphs; addAllMorphs: morphs].
	homeCells with: st second do: [:deck :morphs | deck removeAllMorphs; addAllMorphs: morphs].
	stacks with: st third do: [:deck :morphs | deck removeAllMorphs; addAllMorphs: morphs]
]

{ #category : #private }
FreeCellBoard >> visiblyMove: aCard to: aCell [
	| p1 p2 nSteps |
	self inAutoMove ifFalse: [self captureStateBeforeGrab].
	owner owner addMorphFront: aCard.
	p1 := aCard position.
	p2 := aCell position.
	nSteps := 10.
	1 to: nSteps-1 do: "Note final step happens with actual drop"
		[:i | aCard position: ((p2*i) + (p1*(nSteps-i))) // nSteps.
		self world displayWorld].
	aCell acceptDroppingMorph: aCard event: nil
]
