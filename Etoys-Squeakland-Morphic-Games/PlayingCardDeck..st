Class {
	#name : #PlayingCardDeck,
	#superclass : #AlignmentMorph,
	#instVars : [
		'layout',
		'stackingPolicy',
		'stackingOrder',
		'emptyDropPolicy',
		'target',
		'acceptCardSelector',
		'cardDroppedSelector',
		'cardDoubleClickSelector',
		'cardDraggedSelector',
		'seed'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'new-morph participation' }
PlayingCardDeck class >> includeInNewMorphMenu [

	^false
]

{ #category : #'instance creation' }
PlayingCardDeck class >> newDeck [
	^self new newDeck
]

{ #category : #'instance creation' }
PlayingCardDeck class >> newSuit: suit [
	^self new newSuit: suit
]

{ #category : #symbols }
PlayingCardDeck class >> suits [

	^{#Clubs. #Diamonds. #Hearts. #Spades}
]

{ #category : #symbols }
PlayingCardDeck class >> values [

	^#(Ace),((2 to: 9) collect: [:i | i printString asSymbol]), #(Jack Queen King)
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> acceptCard: aCard default: aBoolean [ 
	"if target and acceptCardSelector are both not nil, send to target, if not  
	nil answer  
	else answer aBoolean"
	"Rewrote this a little (SmallLint calls this 'intention revealing')-th"
	^ (target isNil or: [acceptCardSelector isNil])
		ifTrue: [aBoolean]
		ifFalse: [(target
				perform: acceptCardSelector
				with: aCard
				with: self)
				ifNil: [aBoolean]]
]

{ #category : #accessing }
PlayingCardDeck >> acceptCardSelector: aSymbolOrString [

	acceptCardSelector := self nilOrSymbol: aSymbolOrString.
]

{ #category : #layout }
PlayingCardDeck >> acceptDroppingMorph: aMorph event: evt [ 
	target
		rememberUndoableAction: [target inAutoMove
				ifFalse: [target removeProperty: #stateBeforeGrab].
			self addMorph: aMorph.
			aMorph hasSubmorphs
				ifTrue: ["Just dropped a sub-deck of cards"
					aMorph submorphs
						reverseDo: [:m | self addMorphFront: m]].
			(target notNil
					and: [cardDroppedSelector notNil])
				ifTrue: [target perform: cardDroppedSelector]]
		named: 'move card' translated
]

{ #category : #accessing }
PlayingCardDeck >> addCard: aPlayingCard [
	self addMorph: aPlayingCard
]

{ #category : #accessing }
PlayingCardDeck >> cardDoubleClickSelector: aSymbolOrString [

	cardDoubleClickSelector := self nilOrSymbol: aSymbolOrString.
]

{ #category : #accessing }
PlayingCardDeck >> cardDraggedSelector: aSymbolOrString [

	cardDraggedSelector := self nilOrSymbol: aSymbolOrString.
]

{ #category : #accessing }
PlayingCardDeck >> cardDroppedSelector: aSymbolOrString [

	cardDroppedSelector := self nilOrSymbol: aSymbolOrString.
]

{ #category : #accessing }
PlayingCardDeck >> cards [

	^submorphs
]

{ #category : #'shuffling\/dealing' }
PlayingCardDeck >> deal [
	| card |
	^ self cards notEmpty 
		ifTrue: 
			[card := self topCard.
			card delete.
			card]
		ifFalse: [nil]
]

{ #category : #'shuffling\/dealing' }
PlayingCardDeck >> deal: anInteger [

	^(1 to: anInteger) collect: [:i | self deal]
]

{ #category : #events }
PlayingCardDeck >> doubleClickOnCard: aCard [ 
	(target notNil and: [cardDoubleClickSelector notNil]) 
		ifTrue: 
			[^target 
				perform: cardDoubleClickSelector
				with: self
				with: aCard]
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> emptyDropNotOk: aPlayingCard [

	^(self emptyDropOk: aPlayingCard) not
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> emptyDropOk: aPlayingCard [

	emptyDropPolicy = #any 			ifTrue: [^true].
	emptyDropPolicy = #inOrder			ifTrue: [^self inStackingOrder: aPlayingCard].
	emptyDropPolicy = #anyClub 		ifTrue: [^aPlayingCard suit = #club].
	emptyDropPolicy = #anyDiamond		ifTrue: [^aPlayingCard suit = #diamond].
	emptyDropPolicy = #anyHeart		ifTrue: [^aPlayingCard suit = #heart].
	emptyDropPolicy = #anySpade		ifTrue: [^aPlayingCard suit = #spade].
]

{ #category : #accessing }
PlayingCardDeck >> emptyDropPolicy: aSymbol [
	"#any #inOrder #anyClub #anyDiamond #anyHeart #anySpade"

	emptyDropPolicy := aSymbol
]

{ #category : #accessing }
PlayingCardDeck >> hasCards [

	^self hasSubmorphs
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> ifEmpty: aBlock [

	self hasSubmorphs not ifTrue: [^aBlock value]
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> ifEmpty: aBlock1 ifNotEmpty: aBlock2 [

	self hasSubmorphs not 
		ifTrue: [^aBlock1 value]
		ifFalse: [^aBlock2 value]
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> inStackingOrder: aPlayingCard [

	^self inStackingOrder: aPlayingCard event: nil
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> inStackingOrder: aCard event: evt [

	self hasSubmorphs 
		ifTrue: [^ self inStackingOrder: aCard onTopOf: self topCard]
		ifFalse: [stackingOrder = #ascending ifTrue: [^ aCard cardNumber = 1].
				stackingOrder = #descending ifTrue: [^ aCard cardNumber = 13]].
	^ false.
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> inStackingOrder: aCard onTopOf: cardBelow [
	| diff |
	(stackingPolicy = #altStraight and: [aCard suitColor = cardBelow suitColor]) ifTrue: [^ false].
	(stackingPolicy = #straight and: [aCard suit ~= cardBelow suit]) ifTrue: [^ false].
	diff := aCard cardNumber - cardBelow cardNumber.
	stackingOrder = #ascending 	ifTrue: [^ diff = 1].
	stackingOrder = #descending	ifTrue: [^ diff = -1].
	^ false.
]

{ #category : #initialization }
PlayingCardDeck >> initialize [
	super initialize.
	self cellPositioning: #topLeft.
	self reverseTableCells: true.
	self layout: #grid.
	self hResizing: #shrinkWrap.
	self vResizing: #shrinkWrap.
	self borderWidth: 0.
	self layoutInset: 0.
	stackingPolicy := #stagger.
	stackingOrder := #ascending.
	emptyDropPolicy := #any.
	self newSeed.
	^self
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> insertionIndexFor: aMorph [
	"Return the index at which the given morph should be inserted into the submorphs of the receiver."

	^1
]

{ #category : #accessing }
PlayingCardDeck >> layout: aSymbol [
	" #grid #pile #stagger"
	layout := aSymbol.
	layout == #grid 
		ifTrue:[self maxCellSize: SmallInteger maxVal].
	layout == #pile 
		ifTrue:[self maxCellSize: 0].
	layout == #stagger 
		ifTrue:[self maxCellSize: self staggerOffset].
]

{ #category : #initialization }
PlayingCardDeck >> newDeck [
	| cards |
	cards := OrderedCollection new: 52.
	PlayingCardMorph suits 
		do: [:suit | 1 to: 13
			do: [:cardNo | cards add: (PlayingCardMorph the: cardNo of: suit)]].
	self addAllMorphs: cards.
	^self
]

{ #category : #accessing }
PlayingCardDeck >> newSeed [
	seed := (1 to: 32000) atRandom
]

{ #category : #initialization }
PlayingCardDeck >> newSuit: suit [
	| cards |
	cards := OrderedCollection new: 13.
	1 to: 13 do: [:cardNo | cards add: (PlayingCardMorph the: cardNo of: suit)].
	self addAllMorphs: cards.
	^self
]

{ #category : #private }
PlayingCardDeck >> nilOrSymbol: aSymbolOrString [

	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^nil]
		ifFalse: [^aSymbolOrString asSymbol]
]

{ #category : #printing }
PlayingCardDeck >> printOn: aStream [ 
	| cards |
	cards := self cards.
	aStream nextPutAll: 'aCardDeck('.
	cards size > 1 
		ifTrue: 
			[cards allButLast do: 
					[:card | 
					aStream
						print: card;
						nextPutAll: ', ']].
	cards notEmpty ifTrue: [aStream print: cards last].
	aStream nextPut: $)
]

{ #category : #accessing }
PlayingCardDeck >> removeAllCards [
	self removeAllMorphs
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> repelCard: aCard [ 
	stackingPolicy = #none ifTrue: [^ self repelCard: aCard default: true].
	stackingPolicy = #single ifTrue: [^ self ifEmpty: [self repelCard: aCard default: false]
			ifNotEmpty: [true]].
	(stackingPolicy = #altStraight or: [stackingPolicy = #straight])
		ifTrue: [self ifEmpty: [^ self repelCard: aCard default: (self emptyDropNotOk: aCard)]
				ifNotEmpty: [(self inStackingOrder: aCard onTopOf: self topCard)
						ifFalse: [^ self repelCard: aCard default: true]]].
	^ false
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> repelCard: aCard default: aBoolean [
	
	^(self acceptCard: aCard default: aBoolean not) not
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> repelsMorph: aMorph event: evt [

	(aMorph isKindOf: PlayingCardMorph) 
		ifTrue: [^self repelCard: aMorph]
		ifFalse: [^true]
]

{ #category : #'shuffling\/dealing' }
PlayingCardDeck >> reverse [
	self invalidRect: self fullBounds.
	submorphs := submorphs reversed.
	self layoutChanged.
]

{ #category : #'dropping\/grabbing' }
PlayingCardDeck >> rootForGrabOf: aCard [ 
	self hasSubmorphs ifFalse: [^nil].
	(target notNil and: [cardDraggedSelector notNil]) 
		ifTrue: 
			[^target 
				perform: cardDraggedSelector
				with: aCard
				with: self]
		ifFalse: [^self firstSubmorph]
]

{ #category : #accessing }
PlayingCardDeck >> seed [
	
	^seed
]

{ #category : #accessing }
PlayingCardDeck >> seed: anInteger [
	
	seed := anInteger
]

{ #category : #'shuffling\/dealing' }
PlayingCardDeck >> shuffle [
	self invalidRect: self fullBounds.
	submorphs := submorphs shuffledBy: (Random new seed: seed).
	self layoutChanged.
]

{ #category : #accessing }
PlayingCardDeck >> stackingOrder: aSymbol [
	"#ascending #descending"

	stackingOrder := aSymbol
]

{ #category : #accessing }
PlayingCardDeck >> stackingPolicy [

	^ stackingPolicy
]

{ #category : #accessing }
PlayingCardDeck >> stackingPolicy: aSymbol [
	"#straight #altStraight #single #none"

	stackingPolicy := aSymbol
]

{ #category : #layout }
PlayingCardDeck >> staggerOffset [
	^18
]

{ #category : #accessing }
PlayingCardDeck >> subDeckStartingAt: aCard [
	| i subDeck |

	i := submorphs indexOf: aCard ifAbsent: [^ aCard].
	i = 1 ifTrue: [^aCard].
	subDeck := PlayingCardDeck new.
	(submorphs copyFrom: 1 to: i-1) do:
			[:m | m class = aCard class ifTrue: [subDeck addMorphBack: m]].
	^subDeck.
	
]

{ #category : #accessing }
PlayingCardDeck >> target: anObject [

	target := anObject
]

{ #category : #accessing }
PlayingCardDeck >> topCard [

	^self firstSubmorph
]
