"
I am the AI that will beat you eventually. Well, maybe not today ... BUT MY TIME WILL COME!!!
"
Class {
	#name : #ChessPlayerAI,
	#superclass : #Object,
	#instVars : [
		'board',
		'boardList',
		'boardListIndex',
		'player',
		'historyTable',
		'transTable',
		'generator',
		'random',
		'variations',
		'activeVariation',
		'bestVariation',
		'nodesVisited',
		'ttHits',
		'stamp',
		'alphaBetaCuts',
		'startTime',
		'ply',
		'myMove',
		'myProcess',
		'stopThinking',
		'bestMove'
	],
	#classVars : [
		'AlphaBetaGiveUp',
		'AlphaBetaIllegal',
		'AlphaBetaMaxVal',
		'AlphaBetaMinVal',
		'ValueAccurate',
		'ValueBoundary',
		'ValueLowerBound',
		'ValueThreshold',
		'ValueUpperBound'
	],
	#pools : [
		'ChessConstants'
	],
	#category : #'Etoys-Squeakland-Morphic-Games-Chess'
}

{ #category : #'class initialization' }
ChessPlayerAI class >> initialize [
	"ChessPlayerAI initialize"
	AlphaBetaGiveUp := -29990.
	AlphaBetaIllegal := -31000.
	AlphaBetaMaxVal := 30000.
	AlphaBetaMinVal := -30000.
	ValueAccurate := 2.
	ValueBoundary := 4.
	ValueLowerBound := 4.
	ValueUpperBound := 5.
	ValueThreshold := 200.
]

{ #category : #initialize }
ChessPlayerAI >> activePlayer: aPlayer [
	player := aPlayer.
	board := player board.
	generator := board generator.
	self reset.
]

{ #category : #searching }
ChessPlayerAI >> copyVariation: move [ 
	| av mv count |
	count := 0.
	av := variations at: ply + 1.
	ply < 9 
		ifTrue: 
			[mv := variations at: ply + 2.
			count := mv first.
			av 
				replaceFrom: 3
				to: count + 2
				with: mv
				startingAt: 2].
	av at: 1 put: count + 1.
	av at: 2 put: move encodedMove
]

{ #category : #initialize }
ChessPlayerAI >> initialize [
	historyTable := ChessHistoryTable new.
	"NOTE: transposition table is initialized only when we make the first move. It costs a little to do all the entries and the garbage collections so we do it only when we *really* need it."
	transTable := nil.
	random := Random new.
	nodesVisited := ttHits := alphaBetaCuts := stamp := 0.
	variations := Array new: 11.
	1 to: variations size do:[:i| 
		variations at: i put: (Array new: variations size).
		(variations at: i) atAllPut: 0].
	bestVariation := Array new: variations size.
	bestVariation atAllPut: 0.
	activeVariation := Array new: variations size.
	activeVariation atAllPut: 0.
	self reset.
]

{ #category : #initialize }
ChessPlayerAI >> initializeTranspositionTable [
	"Initialize the transposition table. Note: For now we only use 64k entries since they're somewhat space intensive. If we should get a serious speedup at some point we may want to increase the transposition table - 256k seems like a good idea; but right now 256k entries cost us roughly 10MB of space. So we use only 64k entries (2.5MB of space).
	If you have doubts about the size of the transition table (e.g., if you think it's too small or too big) then modify the value below and have a look at ChessTranspositionTable>>clear which can print out some valuable statistics.
	"
	transTable := ChessTranspositionTable new: 16. "1 << 16 entries"
]

{ #category : #thinking }
ChessPlayerAI >> isThinking [
	^myProcess notNil
]

{ #category : #searching }
ChessPlayerAI >> mtdfSearch: theBoard score: estimate depth: depth [ 
	"An implementation of the MTD(f) algorithm. See:
		http://www.cs.vu.nl/~aske/mtdf.html
	"

	| beta move value low high goodMove |
	value := estimate.
	low := AlphaBetaMinVal.
	high := AlphaBetaMaxVal.
	[low >= high] whileFalse: 
			[beta := value = low ifTrue: [value + 1] ifFalse: [beta := value].
			move := self 
						searchMove: theBoard
						depth: depth
						alpha: beta - 1
						beta: beta.
			stopThinking ifTrue: [^move].
			move ifNil: [^move].
			value := move value.
			value < beta 
				ifTrue: [high := value]
				ifFalse: 
					["NOTE: It is important that we do *NOT* return a move from a search which didn't reach the beta goal (e.g., value < beta). This is because all it means is that we didn't reach beta and the move returned is not the move 'closest' to beta but just one that triggered cut-off. In other words, if we'd take a move which value is less than beta it could mean that this move is a *LOT* worse than beta."

					low := value.
					goodMove := move.
					activeVariation 
						replaceFrom: 1
						to: activeVariation size
						with: (variations first)
						startingAt: 1]].
	^goodMove
]

{ #category : #searching }
ChessPlayerAI >> negaScout: theBoard depth: depth alpha: initialAlpha beta: initialBeta [ 
	"Modified version to return the move rather than the score"
	| move score alpha bestScore moveList newBoard beta goodMove a b notFirst |
	self
		assert: [initialAlpha < initialBeta].
	ply < 10
		ifTrue: [(variations at: ply + 1)
				at: 1
				put: 0].
	ply := 0.
	alpha := initialAlpha.
	beta := initialBeta.
	bestScore := AlphaBetaMinVal.
	"Generate new moves"
	moveList := generator findPossibleMovesFor: theBoard activePlayer.
	moveList
		ifNil: [^ nil].
	moveList size = 0
		ifTrue: [generator recycleMoveList: moveList.
			^ nil].
	"Sort move list according to history heuristics"
	moveList sortUsing: historyTable.
	"And search"
	a := alpha.
	b := beta.
	notFirst := false.
	[(move := moveList next) isNil]
		whileFalse: [newBoard := (boardList at: ply + 1)
						copyBoard: theBoard.
			newBoard nextMove: move.
			"Search recursively"
			"Search recursively"
			ply := ply + 1.
			score := 0
						- (self
								ngSearch: newBoard
								depth: depth - 1
								alpha: 0 - b
								beta: 0 - a).
			(notFirst
					and: [score > a
							and: [score < beta
									and: [depth > 1]]])
				ifTrue: [score := 0
								- (self
										ngSearch: newBoard
										depth: depth - 1
										alpha: 0 - beta
										beta: 0 - score)].
			notFirst := true.
			ply := ply - 1.
			stopThinking
				ifTrue: [generator recycleMoveList: moveList.
					^ move].
			score = AlphaBetaIllegal
				ifFalse: [score > bestScore
						ifTrue: [ply < 10
								ifTrue: [self copyVariation: move].
							goodMove := move copy.
							goodMove value: score.
							activeVariation
								replaceFrom: 1
								to: activeVariation size
								with: variations first
								startingAt: 1.
							bestScore := score].
					"See if we can cut off the search"
					score > a
						ifTrue: [a := score.
							a >= beta
								ifTrue: [transTable
										storeBoard: theBoard
										value: score
										type: (ValueBoundary
												bitOr: (ply bitAnd: 1))
										depth: depth
										stamp: stamp.
									historyTable addMove: move.
									alphaBetaCuts := alphaBetaCuts + 1.
									generator recycleMoveList: moveList.
									^ goodMove]].
					b := a + 1]].
	transTable
		storeBoard: theBoard
		value: bestScore
		type: (ValueAccurate
				bitOr: (ply bitAnd: 1))
		depth: depth
		stamp: stamp.
	generator recycleMoveList: moveList.
	^ goodMove
]

{ #category : #searching }
ChessPlayerAI >> ngSearch: theBoard depth: depth alpha: initialAlpha beta: initialBeta [ 
	"A basic alpha-beta algorithm; based on negaMax rather than from the text books"

	| move score alpha entry bestScore moveList newBoard beta a b notFirst |
	self assert: [initialAlpha < initialBeta].
	ply < 10 ifTrue: [(variations at: ply + 1) at: 1 put: 0].
	depth = 0 
		ifTrue: 
			[^self 
				quiesce: theBoard
				alpha: initialAlpha
				beta: initialBeta].
	nodesVisited := nodesVisited + 1.
	"See if there's already something in the transposition table. If so, skip the entire search."
	entry := transTable lookupBoard: theBoard.
	alpha := initialAlpha.
	beta := initialBeta.
	(entry isNil or: [entry depth < depth]) 
		ifFalse: 
			[ttHits := ttHits + 1.
			(entry valueType bitAnd: 1) = (ply bitAnd: 1) 
				ifTrue: [beta := entry value max: initialBeta]
				ifFalse: [alpha := 0 - entry value max: initialAlpha].
			beta > initialBeta ifTrue: [^beta].
			alpha >= initialBeta ifTrue: [^alpha]].
	bestScore := AlphaBetaMinVal.

	"Generate new moves"
	moveList := generator findPossibleMovesFor: theBoard activePlayer.
	moveList ifNil: [^0 - AlphaBetaIllegal].
	moveList isEmpty 
		ifTrue: 
			[generator recycleMoveList: moveList.
			^bestScore].

	"Sort move list according to history heuristics"
	moveList sortUsing: historyTable.

	"And search"
	a := alpha.
	b := beta.
	notFirst := false.
	[(move := moveList next) isNil] whileFalse: 
			[newBoard := (boardList at: ply + 1) copyBoard: theBoard.
			newBoard nextMove: move.
			"Search recursively"
			ply := ply + 1.
			score := 0 - (self 
								ngSearch: newBoard
								depth: depth - 1
								alpha: 0 - b
								beta: 0 - a).
			(notFirst and: [score > a and: [score < beta and: [depth > 1]]]) 
				ifTrue: 
					[score := 0 - (self 
										ngSearch: newBoard
										depth: depth - 1
										alpha: 0 - beta
										beta: 0 - score)].
			notFirst := true.
			ply := ply - 1.
			stopThinking 
				ifTrue: 
					[generator recycleMoveList: moveList.
					^score].
			score = AlphaBetaIllegal 
				ifFalse: 
					[score > bestScore 
						ifTrue: 
							[ply < 10 ifTrue: [self copyVariation: move].
							bestScore := score].
					score > a 
						ifTrue: 
							[a := score.
							a >= beta 
								ifTrue: 
									[transTable 
										storeBoard: theBoard
										value: score
										type: (ValueBoundary bitOr: (ply bitAnd: 1))
										depth: depth
										stamp: stamp.
									historyTable addMove: move.
									alphaBetaCuts := alphaBetaCuts + 1.
									generator recycleMoveList: moveList.
									^score]].
					b := a + 1]].
	transTable 
		storeBoard: theBoard
		value: bestScore
		type: (ValueAccurate bitOr: (ply bitAnd: 1))
		depth: depth
		stamp: stamp.
	generator recycleMoveList: moveList.
	^bestScore
]

{ #category : #searching }
ChessPlayerAI >> quiesce: theBoard alpha: initialAlpha beta: initialBeta [ 
	"A variant of alpha-beta considering only captures and null moves to obtain a quiet position, e.g. one that is unlikely to change heavily in the very near future."

	| move score alpha entry bestScore moveList newBoard beta |
	self assert: [initialAlpha < initialBeta].
	ply < 10 ifTrue: [(variations at: ply + 1) at: 1 put: 0].
	nodesVisited := nodesVisited + 1.
	"See if there's already something in the transposition table."
	entry := transTable lookupBoard: theBoard.
	alpha := initialAlpha.
	beta := initialBeta.
	entry isNil 
		ifFalse: 
			[ttHits := ttHits + 1.
			(entry valueType bitAnd: 1) = (ply bitAnd: 1) 
				ifTrue: [beta := entry value max: initialBeta]
				ifFalse: [alpha := 0 - entry value max: initialAlpha].
			beta > initialBeta ifTrue: [^beta].
			alpha >= initialBeta ifTrue: [^alpha]].
	ply < 2 
		ifTrue: 
			["Always generate moves if ply < 2 so that we don't miss a move that
		would bring the king under attack (e.g., make an invalid move)."

			moveList := generator findQuiescenceMovesFor: theBoard activePlayer.
			moveList ifNil: [^0 - AlphaBetaIllegal]].

	"Evaluate the current position, assuming that we have a non-capturing move."
	bestScore := theBoard activePlayer evaluate.
	"TODO: What follows is clearly not the Right Thing to do. The score we just evaluated doesn't take into account that we may be under attack at this point. I've seen it happening various times that the static evaluation triggered a cut-off which was plain wrong in the position at hand.
	There seem to be three ways to deal with the problem. #1 is just deepen the search. If we go one ply deeper we will most likely find the problem (although that's not entirely certain). #2 is to improve the evaluator function and make it so that the current evaluator is only an estimate saying if it's 'likely' that a non-capturing move will do. The more sophisticated evaluator should then take into account which pieces are under attack. Unfortunately that could make the AI play very passive, e.g., avoiding situations where pieces are under attack even if these attacks are outweighed by other factors. #3 would be to insert a null move here to see *if* we are under attack or not (I've played with this) but for some reason the resulting search seemed to explode rapidly. I'm uncertain if that's due to the transposition table being too small (I don't *really* think so but it may be) or if I've just got something else wrong."
	bestScore > alpha 
		ifTrue: 
			[alpha := bestScore.
			bestScore >= beta 
				ifTrue: 
					[moveList ifNotNil: [generator recycleMoveList: moveList].
					^bestScore]].

	"Generate new moves"
	moveList ifNil: 
			[moveList := generator findQuiescenceMovesFor: theBoard activePlayer.
			moveList ifNil: [^0 - AlphaBetaIllegal]].
	moveList isEmpty 
		ifTrue: 
			[generator recycleMoveList: moveList.
			^bestScore].

	"Sort move list according to history heuristics"
	moveList sortUsing: historyTable.

	"And search"
	[(move := moveList next) isNil] whileFalse: 
			[newBoard := (boardList at: ply + 1) copyBoard: theBoard.
			newBoard nextMove: move.
			"Search recursively"
			ply := ply + 1.
			score := 0 - (self 
								quiesce: newBoard
								alpha: 0 - beta
								beta: 0 - alpha).
			stopThinking 
				ifTrue: 
					[generator recycleMoveList: moveList.
					^score].
			ply := ply - 1.
			score = AlphaBetaIllegal 
				ifFalse: 
					[score > bestScore 
						ifTrue: 
							[ply < 10 ifTrue: [self copyVariation: move].
							bestScore := score].
					"See if we can cut off the search"
					score > alpha 
						ifTrue: 
							[alpha := score.
							score >= beta 
								ifTrue: 
									[transTable 
										storeBoard: theBoard
										value: score
										type: (ValueBoundary bitOr: (ply bitAnd: 1))
										depth: 0
										stamp: stamp.
									historyTable addMove: move.
									alphaBetaCuts := alphaBetaCuts + 1.
									generator recycleMoveList: moveList.
									^bestScore]]]].
	transTable 
		storeBoard: theBoard
		value: bestScore
		type: (ValueAccurate bitOr: (ply bitAnd: 1))
		depth: 0
		stamp: stamp.
	generator recycleMoveList: moveList.
	^bestScore
]

{ #category : #initialize }
ChessPlayerAI >> reset [
	transTable ifNotNil:[transTable clear].
	historyTable clear.

]

{ #category : #initialize }
ChessPlayerAI >> reset: aBoard [
	self reset.
	boardList ifNil:[
		boardList := Array new: 100.
		1 to: boardList size do:[:i| boardList at: i put: (aBoard copy userAgent: nil)].
		boardListIndex := 0].
	board := aBoard.
]

{ #category : #searching }
ChessPlayerAI >> search: theBoard depth: depth alpha: initialAlpha beta: initialBeta [ 
	"A basic alpha-beta algorithm; based on negaMax rather than from the text books"

	| move score alpha entry bestScore moveList newBoard beta |
	self assert: [initialAlpha < initialBeta].
	ply < 10 ifTrue: [(variations at: ply + 1) at: 1 put: 0].
	depth = 0 
		ifTrue: 
			[^self 
				quiesce: theBoard
				alpha: initialAlpha
				beta: initialBeta].
	nodesVisited := nodesVisited + 1.
	"See if there's already something in the transposition table. If so, skip the entire search."
	entry := transTable lookupBoard: theBoard.
	alpha := initialAlpha.
	beta := initialBeta.
	(entry isNil or: [entry depth < depth]) 
		ifFalse: 
			[ttHits := ttHits + 1.
			(entry valueType bitAnd: 1) = (ply bitAnd: 1) 
				ifTrue: [beta := entry value max: initialBeta]
				ifFalse: [alpha := 0 - entry value max: initialAlpha].
			beta > initialBeta ifTrue: [^beta].
			alpha >= initialBeta ifTrue: [^alpha]].
	bestScore := AlphaBetaMinVal.

	"Generate new moves"
	moveList := generator findPossibleMovesFor: theBoard activePlayer.
	moveList ifNil: [^0 - AlphaBetaIllegal].
	moveList isEmpty 
		ifTrue: 
			[generator recycleMoveList: moveList.
			^bestScore].

	"Sort move list according to history heuristics"
	moveList sortUsing: historyTable.

	"And search"
	[(move := moveList next) isNil] whileFalse: 
			[newBoard := (boardList at: ply + 1) copyBoard: theBoard.
			newBoard nextMove: move.
			"Search recursively"
			ply := ply + 1.
			score := 0 - (self 
								search: newBoard
								depth: depth - 1
								alpha: 0 - beta
								beta: 0 - alpha).
			stopThinking 
				ifTrue: 
					[generator recycleMoveList: moveList.
					^score].
			ply := ply - 1.
			score = AlphaBetaIllegal 
				ifFalse: 
					[score > bestScore 
						ifTrue: 
							[ply < 10 ifTrue: [self copyVariation: move].
							bestScore := score].
					"See if we can cut off the search"
					score > alpha 
						ifTrue: 
							[alpha := score.
							score >= beta 
								ifTrue: 
									[transTable 
										storeBoard: theBoard
										value: score
										type: (ValueBoundary bitOr: (ply bitAnd: 1))
										depth: depth
										stamp: stamp.
									historyTable addMove: move.
									alphaBetaCuts := alphaBetaCuts + 1.
									generator recycleMoveList: moveList.
									^bestScore]]]].
	transTable 
		storeBoard: theBoard
		value: bestScore
		type: (ValueAccurate bitOr: (ply bitAnd: 1))
		depth: depth
		stamp: stamp.
	generator recycleMoveList: moveList.
	^bestScore
]

{ #category : #searching }
ChessPlayerAI >> searchMove: theBoard depth: depth alpha: initialAlpha beta: initialBeta [ 
	"Modified version to return the move rather than the score"

	| move score alpha bestScore moveList newBoard beta goodMove |
	self assert: [initialAlpha < initialBeta].
	ply < 10 ifTrue: [(variations at: ply + 1) at: 1 put: 0].
	ply := 0.
	alpha := initialAlpha.
	beta := initialBeta.
	bestScore := AlphaBetaMinVal.

	"Generate new moves"
	moveList := generator findPossibleMovesFor: theBoard activePlayer.
	moveList ifNil: [^nil].
	moveList isEmpty 
		ifTrue: 
			[generator recycleMoveList: moveList.
			^nil].

	"Sort move list according to history heuristics"
	moveList sortUsing: historyTable.

	"And search"
	[(move := moveList next) isNil] whileFalse: 
			[newBoard := (boardList at: ply + 1) copyBoard: theBoard.
			newBoard nextMove: move.
			"Search recursively"
			ply := ply + 1.
			score := 0 - (self 
								search: newBoard
								depth: depth - 1
								alpha: 0 - beta
								beta: 0 - alpha).
			stopThinking 
				ifTrue: 
					[generator recycleMoveList: moveList.
					^move].
			ply := ply - 1.
			score = AlphaBetaIllegal 
				ifFalse: 
					[score > bestScore 
						ifTrue: 
							[ply < 10 ifTrue: [self copyVariation: move].
							goodMove := move copy.
							goodMove value: score.
							bestScore := score].
					"See if we can cut off the search"
					score > alpha 
						ifTrue: 
							[alpha := score.
							score >= beta 
								ifTrue: 
									[transTable 
										storeBoard: theBoard
										value: score
										type: (ValueBoundary bitOr: (ply bitAnd: 1))
										depth: depth
										stamp: stamp.
									historyTable addMove: move.
									alphaBetaCuts := alphaBetaCuts + 1.
									generator recycleMoveList: moveList.
									^goodMove]]]].
	transTable 
		storeBoard: theBoard
		value: bestScore
		type: (ValueAccurate bitOr: (ply bitAnd: 1))
		depth: depth
		stamp: stamp.
	generator recycleMoveList: moveList.
	^goodMove
]

{ #category : #thinking }
ChessPlayerAI >> startThinking [
	self isThinking ifTrue:[^self].
	self activePlayer: board activePlayer.
	self thinkStep.
]

{ #category : #accessing }
ChessPlayerAI >> statusString [
	| av count |
	^String streamContents:[:s|
		(myMove == #none or:[myMove == nil]) ifFalse:[
			s print: myMove value / 100.0; space.
		].
		av := bestVariation.
		count := av at: 1.
		count > 0 ifFalse:[
			av := activeVariation.
			count := av at: 1].
		count > 0 ifFalse:[
			s nextPutAll:'***'.
			av := variations at: 1.
			count := av at: 1.
			count > 3 ifTrue:[count := 3]].
		2 to: count + 1 do:[:index|
			s nextPutAll: (ChessMove decodeFrom: (av at: index)) moveString.
			s space].

		s nextPut:$[.
		s print: nodesVisited.
"		s nextPut:$|.
		s print: ttHits.
		s nextPut: $|.
		s print: alphaBetaCuts.
"		s nextPut:$].

	].
]

{ #category : #thinking }
ChessPlayerAI >> think [
	| move |
	self isThinking ifTrue: [^nil].
	self startThinking.
	[(move := self thinkStep) isNil] whileTrue.
	^move
]

{ #category : #thinking }
ChessPlayerAI >> thinkProcess [
	| score theMove depth |
	stopThinking := false.
	score := board activePlayer evaluate.
	depth := 1.
	stamp := stamp + 1.
	ply := 0.
	historyTable clear.
	transTable clear.
	startTime := Time millisecondClockValue.
	nodesVisited := ttHits := alphaBetaCuts := 0.
	bestVariation at: 1 put: 0.
	activeVariation at: 1 put: 0.
	[nodesVisited < 50000] whileTrue: 
			["whats this ? (aoy)  false ifTrue:[] ????!"

			theMove := false 
						ifTrue: 
							[self 
								mtdfSearch: board
								score: score
								depth: depth]
						ifFalse: 
							[self 
								negaScout: board
								depth: depth
								alpha: AlphaBetaMinVal
								beta: AlphaBetaMaxVal].
			theMove ifNil: [^myProcess := nil].
			stopThinking ifTrue: [^myProcess := nil].
			myMove := theMove.
			bestVariation 
				replaceFrom: 1
				to: bestVariation size
				with: activeVariation
				startingAt: 1.
			score := theMove value.
			depth := depth + 1].
	myProcess := nil
]

{ #category : #thinking }
ChessPlayerAI >> thinkStep [
	transTable ifNil: [self initializeTranspositionTable].
	myProcess isNil 
		ifTrue: 
			[myMove := #none.
			false 
				ifTrue: 
					[self thinkProcess.
					^myMove].
			myProcess := [self thinkProcess] forkAt: Processor userBackgroundPriority.
			myProcess suspend.
			^nil].
	myProcess resume.
	(Delay forMilliseconds: 50) wait.
	myProcess ifNil: [^myMove == #none ifTrue: [nil] ifFalse: [myMove]].
	myProcess suspend.
	"Do we have a valid move?"
	myMove == #none ifTrue: [^nil].	"no"
	"Did we time out?"
	Time millisecondClockValue - startTime > self timeToThink 
		ifTrue: 
			["Yes. Abort and return current move."

			stopThinking := true.
			myProcess resume.
			[myProcess isNil] whileFalse: [(Delay forMilliseconds: 10) wait].
			^myMove == #none ifTrue: [nil] ifFalse: [myMove]].
	"Keep thinking"
	^nil
]

{ #category : #thinking }
ChessPlayerAI >> timeToThink [
	"Return the number of milliseconds we're allowed to think"
	^5000
]
