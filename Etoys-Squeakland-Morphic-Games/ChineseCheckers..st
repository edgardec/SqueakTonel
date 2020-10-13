"
An implementation of Chinese Checkers by Dan Ingalls.  April 9, 2000.

board:  A 19x19 rhombic array, addressed by row@col points, in which is imbedded the familiar six-pointed layout of cells.  A cell outside the board is nil (-).
  - - - - - - - - - - - - - - - - - - -
   - - - - - - - - - - - - - 5 - - - - -
    - - - - - - - - - - - - 5 5 - - - - -
     - - - - - - - - - - - 5 5 5 - - - - -
      - - - - - - - - - - 5 5 5 5 - - - - -
       - - - - - 6 6 6 6 0 0 0 0 0 4 4 4 4 -
        - - - - - 6 6 6 0 0 0 0 0 0 4 4 4 - -
         - - - - - 6 6 0 0 0 0 0 0 0 4 4 - - -
          - - - - - 6 0 0 0 0 0 0 0 0 4 - - - -
           - - - - - 0 0 0 0 0 0 0 0 0 - - - - -
            - - - - 1 0 0 0 0 0 0 0 0 3 - - - - -
             - - - 1 1 0 0 0 0 0 0 0 3 3 - - - - -
              - - 1 1 1 0 0 0 0 0 0 3 3 3 - - - - -
               - 1 1 1 1 0 0 0 0 0 3 3 3 3 - - - - -
                - - - - - 2 2 2 2 - - - - - - - - - -
                 - - - - - 2 2 2 - - - - - - - - - - -
                  - - - - - 2 2 - - - - - - - - - - - -
                   - - - - - 2 - - - - - - - - - - - - -
                    - - - - - - - - - - - - - - - - - - -
Cells within the board contain 0 if empty, or a team number (1..6) if occupied by a piece of that team.  An extra border of nils around the whole reduces bounds checking to a nil test.

sixDeltas:  An array giving the x@y deltas for the 6 valid steps in CCW order from a given cell.  For team 1 they are: in fr, fl, l, bl, br, r.  To get, eg fl for a given team, use (sixDeltas atWrap: team+1).

teams:  An array of six teams, each of which is an array of the x@y locations of the 10 pieces.

homes:  The x@y coordinates of the six home points, namely 14@2, 18@6, 14@14, 6@18, 2@14, 6@6.  The goal, or farthest point in destination triangle, is thus (homes atWrap: teamNo+3).

autoPlay:  An array of booleans, parallel to teams, where true means that Squeak will make the moves for the corresponding team.

whoseMove:  A team number specifying whose turn it is next.  Set to 0 when game is over.

plannedMove:  If not nil, it means the board is in a state where it is animating the next move to be made so that it can be seen.

movePhase:  Holds the state of display of the planned move so that, eg, it can appear one jump at a time.  Advances from 1 to (plannedMove size * 2).

A move is an array of locs which are the path of the move.

Once the morph is open, the menu command 'reset...' allows you to reset the board and change the number of players.  The circle at turnIndicatorLoc indicates the color of the team whose turn it is.  If it is a human, play waits for drag and drop of a piece of that color.

The current strategy is very simple: generate all moves, score them and pick the best.  Beyond this, it will look ahead a number of moves, but this becomes very expensive without pruning.  Pruning would help the speed of play, especially in the end game where we look a little deeper.  A more effective strategy would consider opponents' possible moves as well, but this is left as an exercise for the serious programmer.
"
Class {
	#name : #ChineseCheckers,
	#superclass : #BorderedMorph,
	#instVars : [
		'board',
		'sixDeltas',
		'teams',
		'homes',
		'autoPlay',
		'whoseMove',
		'plannedMove',
		'plannedMovePhase',
		'colors',
		'movePhase',
		'animateMoves',
		'pathMorphs'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'parts bin' }
ChineseCheckers class >> descriptionForPartsBin [
	^ self partName:	'ChineseCheckers' translatedNoop
		categories:		{'Games' translatedNoop}
		documentation:	'Halma - the classic board game of Chinese Checkers, written by Dan Ingalls' translatedNoop
]

{ #category : #layout }
ChineseCheckers >> acceptDroppingMorph: aPiece event: evt [

	| dropLoc |
	dropLoc := self boardLocAt: evt cursorPoint.
	dropLoc = aPiece boardLoc ifTrue:  "Null move"
		[^ aPiece rejectDropMorphEvent: evt].
	(plannedMove := (self allMovesFrom: aPiece boardLoc)
				detect: [:move | move last = dropLoc]
				ifNone: [nil])
		ifNil: [^ aPiece rejectDropMorphEvent: evt.   "Not a valid move"].

	super acceptDroppingMorph: aPiece event: evt.
	movePhase := 1.  "Start the animation if any."

]

{ #category : #menus }
ChineseCheckers >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	"Include our modest command set in the ctrl-menu"

	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
	aCustomMenu addLine.
	self addMenuItemsTo: aCustomMenu hand: aHandMorph
]

{ #category : #menu }
ChineseCheckers >> addMenuItemsTo: aMenu hand: aHandMorph [

	aMenu add: 'new game' translated target: self action: #newGame.
	aMenu add: 'reset...' translated target: self action: #reset.
	animateMoves
		ifTrue: [aMenu add: 'don''t animate moves' translated target: self action: #dontAnimateMoves]
		ifFalse: [aMenu add: 'animate moves' translated target: self action: #animateMoves]


]

{ #category : #moves }
ChineseCheckers >> allMovesFrom: boardLoc [  "boardLoc must be occupied"
	| team stepMoves jumpDict |
	team := self at: boardLoc.
	stepMoves := (sixDeltas collect: [:d | boardLoc + d])
		select: [:p | (self at: p) notNil and: [(self at: p) = 0]].
	jumpDict := Dictionary new.
	jumpDict at: boardLoc put: (Array with: boardLoc).
	self jumpFor: team from: boardLoc havingVisited: jumpDict.
	jumpDict removeKey: boardLoc.
	^ (stepMoves collect: [:p | {boardLoc. p}]) , jumpDict values
		reject:
		[:move |  "Don't include any moves that land in other homes."
		(self distFrom: move last to: self boardCenter) >= 5  "In a home..."
			and: [(self distFrom: move last to: (homes atWrap: team+3)) > 3  "...not my goal..."
			and: [(self distFrom: move last to: (homes at: team)) > 3  "...nor my home"]]]
]

{ #category : #menu }
ChineseCheckers >> animateMoves [

	animateMoves := true
]

{ #category : #accessing }
ChineseCheckers >> at: p [
	^ (board at: p x) at: p y
]

{ #category : #accessing }
ChineseCheckers >> at: p put: x [
	^ (board at: p x) at: p y put: x
]

{ #category : #moves }
ChineseCheckers >> bestMove: ply forTeam: team [
	| score bestScore bestMove |
	bestScore := -999.
	(teams at: team) do:
		[:boardLoc |
		(self allMovesFrom: boardLoc) do:
			[:move |
			score := self score: move for: team.
			(score > -99 and: [ply > 0]) ifTrue: 
				[score := score  "Add 0.7 * score of next move (my guess)"
					+ (0 max: ((self score: ((self copyBoard makeMove: move)
							bestMove: ply - 1 forTeam: team) for: team) * 0.7))].
			score > bestScore ifTrue:
				[bestScore := score.  bestMove := move]]].
	^ bestMove
]

{ #category : #initialization }
ChineseCheckers >> board: b teams: t [
	board := b.
	teams := t
]

{ #category : #'board geometry' }
ChineseCheckers >> boardCenter [
	^ 10@10
]

{ #category : #'board geometry' }
ChineseCheckers >> boardLocAt: cellPoint [

	| dx dy row col |
	dx := self width/15.0.  dy := dx * 0.8660254037844385 "(Float pi / 3) sin".
	row := (cellPoint y - self position y) // dy + 1.
	col := (cellPoint x - self position x) / (dx/2.0) + 16 - row // 2.
	^ row @ col
]

{ #category : #'board geometry' }
ChineseCheckers >> cellPointAt: boardLoc [
	| dx dy row col |
	dx := self width/15.0.  dy := dx * 0.8660254037844385 "(Float pi / 3) sin".
	row := boardLoc x.
	col := boardLoc y.
	^ self position + ((col*2+row-16*dx//2)@(row-1*dy)) asIntegerPoint
]

{ #category : #moves }
ChineseCheckers >> checkDoneAfter: move [

	| team locsAfterMove |
	(team := self at: move first) = 0 ifTrue: [^ false].
	(locsAfterMove := (teams at: team) copy) replaceAll: move first with: move last.
	^ self testDone: locsAfterMove for: team
]

{ #category : #initialization }
ChineseCheckers >> copyBoard [
	"Return a copy of the board for the purpose of looking ahead one or more moves."

	^ self copy
		board: (board collect: [:row | row copy])
		teams: (teams collect: [:team | team copy])
]

{ #category : #initialization }
ChineseCheckers >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color
		r: 0.6
		g: 0.4
		b: 0.0
]

{ #category : #'board geometry' }
ChineseCheckers >> distFrom: a to: b [
	"The six possible moves are: 1@0, 1@ -1, 0@1, 0@ -1, -1@0, -1@1."
	| dx dy |
	dx := b x - a x.
	dy := b y - a y.
	dx abs >= dy abs
	ifTrue: ["Major change is in x-coord..."
			dx >= 0
			ifTrue: [(dy between: (0-dx) and: 0)
						ifTrue: [^ dx  "no lateral motion"].
					^ dx + ((0-dx) - dy max: dy - 0)  "added lateral dist"]
			ifFalse: ["Reverse sign and rerun same code"
					^ self distFrom: b to: a]]
	ifFalse: ["Transpose and re-run same code"
			^ self distFrom: a transposed to: b transposed]
]

{ #category : #menu }
ChineseCheckers >> dontAnimateMoves [

	animateMoves := false
]

{ #category : #drawing }
ChineseCheckers >> drawOn: aCanvas [ 

	| row1 row2 offset dotExtent |
	super drawOn: aCanvas.   "Draw square board"

	"Only draw rows in the clipping region"
	dotExtent := (self width//25) asPoint.
	offset := self pieceSize - dotExtent + 1 // 2.  "Offset of smaller dots rel to larger"
	row1 := (self boardLocAt: aCanvas clipRect topLeft) x max: 1.
	row2 := (self boardLocAt: aCanvas clipRect bottomRight) x min: board size.
	row1 to: row2 do:
		[:row | (board at: row) doWithIndex:
			[:cell :i | cell ifNotNil:
				[aCanvas fillOval: ((self cellPointAt: (row@i)) + offset extent: dotExtent)
					color: (colors at: cell+1)]]]
]

{ #category : #moves }
ChineseCheckers >> endGameFor: team [
	"Return true if we are in the end game (all players within 1 of home triangle)."

	| goalLoc |
	goalLoc := homes atWrap: team+3.  "Farthest cell across the board"
	(teams at: team)
		do: [:boardLoc | (self distFrom: boardLoc to: goalLoc) > 4 ifTrue: [^ false]].
	^ true
]

{ #category : #geometry }
ChineseCheckers >> extent: newExtent [

	| extraY |
	extraY := (newExtent x / 15.0 * 1.25) asInteger.
	super extent: (newExtent x) @ (newExtent x + extraY).
	self submorphsDo:
		[:m | (m isKindOf: ChineseCheckerPiece) ifTrue:
				[m position: (self cellPointAt: m boardLoc); extent: self pieceSize]]
]

{ #category : #'event handling' }
ChineseCheckers >> handlesMouseDown: evt [
	"Prevent stray clicks from picking up the whole game in MVC."

	^ Smalltalk isMorphic not or: [evt yellowButtonPressed]
]

{ #category : #initialization }
ChineseCheckers >> initialize [
	"Default creation is for one person against Squeak."
	super initialize.
	""
	self extent: 382 @ 413.

	animateMoves := true.
	self teams: #(2 5 ) autoPlay: {false. true}
]

{ #category : #'parts bin' }
ChineseCheckers >> initializeToStandAlone [ 
	"Default creation is for one person against Squeak."

	super initializeToStandAlone.
	self extent: 382@413.
	self color: (Color r: 0.6 g: 0.4 b: 0.0).
	self borderWidth: 2.
	animateMoves := true.
	self teams: #(2 5) autoPlay: {false. true}.

]

{ #category : #moves }
ChineseCheckers >> jumpFor: team from: loc havingVisited: dict [
	"Recursively explore all jumps from loc, leaving in dict
	the prior position from which we got there"

	"Fasten seatbelts..."
	((((sixDeltas
		collect: [:d | loc + d])
		select: [:p | (self at: p) notNil and: [(self at: p) > 0]])
		collect: [:p | p + (p - loc)])
		select: [:p | (self at: p) notNil and: [(self at: p) = 0]])
		do: [:p | (dict includesKey: p) ifFalse:
			[dict at: p put: ((dict at: loc) copyWith: p).
			self jumpFor: team from: p havingVisited: dict]]
]

{ #category : #moves }
ChineseCheckers >> makeMove: move [
	| team |
	team := self at: move first.
	self at: move last put: team.
	self at: move first put: 0.
	(teams at: team) replaceAll: move first with: move last
]

{ #category : #'event handling' }
ChineseCheckers >> mouseDown: evt [

	| menu |
	evt yellowButtonPressed ifFalse: [^ self].
	menu := MenuMorph new defaultTarget: self.
	self addMenuItemsTo: menu hand: evt hand.
	menu popUpEvent: evt in: self world.

]

{ #category : #menu }
ChineseCheckers >> newGame [
	"Reset the board, with same teams."

	| teamNumbers |
	teamNumbers := (1 to: 6) reject: [:i | (teams at: i) isEmpty].
	self teams: teamNumbers
		 autoPlay: (teamNumbers collect: [:i | autoPlay at: i]).

]

{ #category : #'game sequence' }
ChineseCheckers >> nextTurn [

	(self testDone: (teams at: whoseMove) for: whoseMove) ifTrue:
		[(self pieceAt: self turnIndicatorLoc) extent: self width asPoint//6; borderWidth: 2.
		^ whoseMove := 0.  "Game over."].	

	[whoseMove := whoseMove\\6 + 1.
	(teams at: whoseMove) isEmpty]  "Turn passes to the next player"
		whileTrue: [].
	(self pieceAt: self turnIndicatorLoc) color: (colors at: whoseMove+1)
]

{ #category : #'drag and drop' }
ChineseCheckers >> okToPickUpPieceAt: boardLoc [

	^ (self at: boardLoc) = whoseMove and: [(autoPlay at: whoseMove) not]
]

{ #category : #'drag and drop' }
ChineseCheckers >> pieceAt: boardLoc [

	self submorphsDo:
		[:m | ((m isMemberOf: ChineseCheckerPiece) and: [m boardLoc = boardLoc])
				ifTrue: [^ m]].
	^ nil
]

{ #category : #'board geometry' }
ChineseCheckers >> pieceSize [

	^ self width asPoint // 20
]

{ #category : #printing }
ChineseCheckers >> printOn: s [ 
	"For testing only"

	1 to: board size
		do: 
			[:row | 
			s
				cr;
				next: row put: $ .
			(board at: row) do: 
					[:cell | 
					s
						space;
						nextPut: (cell isNil ifTrue: [$-] ifFalse: [cell printString last])]]
]

{ #category : #menu }
ChineseCheckers >> reset [
	"Reset the board, choosing anew how many teams."

	| nPlayers nHumans |
	nPlayers := (SelectionMenu 
					selections: (1 to: 6)) 
					startUpWithCaption: 'How many players?' translated.
	nPlayers ifNil: [nPlayers := 2].
	nHumans := (SelectionMenu 
					selections: (0 to: nPlayers)) 
					startUpWithCaption: 'How many humans?' translated.
	nHumans ifNil: [nHumans := 1].
	self teams: (#((1) (2 5) (2 4 6) (1 2 4 5) (1 2 3 4 6) (1 2 3 4 5 6)) at: nPlayers)
		 autoPlay: ((1 to: nPlayers) collect: [:i | i > nHumans]).

]

{ #category : #moves }
ChineseCheckers >> score: move for: team [
	"Return the decrease in distance toward this team's goal"

	| goal closerToGoal wasBack nowBack |
	goal := homes atWrap: team+3.
	wasBack := self distFrom: move first to: goal.
	nowBack := self distFrom: move last to: goal.
	closerToGoal := wasBack - nowBack.
	closerToGoal < -1 ifTrue: [^ -99].  "Quick rejection if move backward more than 1"
	(nowBack <= 3 and: [self checkDoneAfter: move]) ifTrue: [^ 999].
	"Reward closerToGoal, but add bias to move those left far behind."
	^ (closerToGoal*5) + wasBack
]

{ #category : #'game sequence' }
ChineseCheckers >> showNextMoveSegment [
	"Display the current move in progress.  Starts with movePhase = 1.
	Increments movePhase at each tick.  Ends by setting movePhase to 0."

	| dot p1 p2 delta secondPhase line |
	delta := self width//40.
	movePhase <= plannedMove size
	ifTrue:
		["First we trace the move with dots and lines..."
		movePhase = 1 ifTrue: [pathMorphs := OrderedCollection new].
		p1 := self cellPointAt: (plannedMove at: movePhase).
		dot := (ImageMorph new image: (Form dotOfSize: 7)) position: p1 + delta - (7//2).
		self addMorph: dot.  pathMorphs addLast: dot.
		movePhase > 1 ifTrue:
			[p2 := self cellPointAt: (plannedMove at: movePhase-1).
			line := PolygonMorph vertices: {p2 + delta. p1 + delta} color: Color black
					borderWidth: 3 borderColor: Color black.
			self addMorph: line.  pathMorphs addLast: line]]
	ifFalse:
		["...then we erase the path while moving the piece."
		secondPhase := movePhase - plannedMove size.
		pathMorphs removeFirst delete.
		secondPhase > 1 ifTrue:
			[pathMorphs removeFirst delete.
			self makeMove: {plannedMove at: secondPhase - 1. plannedMove at: secondPhase}.
			(self pieceAt: (plannedMove at: secondPhase - 1))
				position: (self cellPointAt: (plannedMove at: secondPhase));
				setBoard: self loc: (plannedMove at: secondPhase).
			self changed]].

	(movePhase := movePhase + 1) > (plannedMove size * 2)
		ifTrue: [movePhase := 0  "End of animated move"].


]

{ #category : #'game sequence' }
ChineseCheckers >> step [
	whoseMove = 0 ifTrue: [^self].	"Game over."
	plannedMove isNil 
		ifTrue: 
			[(autoPlay at: whoseMove) ifFalse: [^self].	"Waiting for a human."
			plannedMove := (self endGameFor: whoseMove) 
						ifTrue: 
							["Look deeper at the end."

							self bestMove: 2 forTeam: whoseMove]
						ifFalse: [self bestMove: 1 forTeam: whoseMove].
			movePhase := 1	"Start the animated move"].
	animateMoves 
		ifTrue: 
			["Display the move in phases..."

			movePhase > 0 ifTrue: [^self showNextMoveSegment]]
		ifFalse: 
			["... or skip the entire animated move if requested."

			self makeMove: plannedMove.
			(self pieceAt: plannedMove first)
				position: (self cellPointAt: plannedMove last);
				setBoard: self loc: plannedMove last.
			self changed.
			movePhase := 0].
	plannedMove := nil.	"End the animated move"
	self nextTurn
]

{ #category : #testing }
ChineseCheckers >> stepTime [

	^ 200
]

{ #category : #initialization }
ChineseCheckers >> teams: teamsPlaying autoPlay: ifAuto [
	"Initialize board, teams, steps, jumps"
	| p q teamInPlay |
	colors := (#(gray) , #(red green blue cyan magenta yellow white) shuffled)
				collect: [:c | Color perform: c].  "New set of colors each time."
	self removeAllMorphs.  "eg, from previous game."
	board := (1 to: 19) collect: [:i | Array new: 19].
	sixDeltas := {0@1. -1@1. -1@0. 0@ -1. 1@ -1. 1@0}.
	homes := {14@2. 18@6. 14@14. 6@18. 2@14. 6@6}.
	teams := (1 to: 6) collect: [:i | OrderedCollection new].
	autoPlay := (1 to: 6) collect: [:i | false].
	1 to: 6 do:
		[:team | p:= homes at: team.
		(teamInPlay := teamsPlaying includes: team) ifTrue:
			[autoPlay at: team put: (ifAuto at: (teamsPlaying indexOf: team))].
		"Place empty cells in rhombus extending out from each
		home, and occupied cells in active home triangles."
		1 to: 5 do: [:i | q := p.
			1 to: 5 do: [:j |
				(teamInPlay and: [j <= (5 - i)])
					ifTrue: [self at: q put: team.
							(teams at: team) add: q.
							self addMorph:
								((ChineseCheckerPiece
									newBounds: ((self cellPointAt: q) extent: self pieceSize)
									color: (colors at: team+1))
										setBoard: self loc: q)]
					ifFalse: [self at: q put: 0].
				q := q + (sixDeltas at: team).  "right,forward"].
			p := p + (sixDeltas atWrap: team+1).  "left,forward"].
		teams at: team put: (teams at: team) asArray].
	whoseMove := teamsPlaying first.
	self addMorph:
		((ChineseCheckerPiece
			newBounds: ((self cellPointAt: self turnIndicatorLoc) extent: self pieceSize)
			color: (colors at: whoseMove+1))
				setBoard: self loc: self turnIndicatorLoc).
	plannedMove := nil.
	self changed
]

{ #category : #moves }
ChineseCheckers >> testDone: teamLocs for: team [
	"Return true if we are done (all players in home triangle)."

	| goalLoc |
	goalLoc := homes atWrap: team+3.
	teamLocs
		do: [:boardLoc | (self distFrom: boardLoc to: goalLoc) > 3 ifTrue: [^ false]].
	^ true
]

{ #category : #'board geometry' }
ChineseCheckers >> turnIndicatorLoc [

	^ 16@11
]

{ #category : #'dropping\/grabbing' }
ChineseCheckers >> wantsDroppedMorph: aPiece event: evt [

	^ aPiece isKindOf: ChineseCheckerPiece

]
