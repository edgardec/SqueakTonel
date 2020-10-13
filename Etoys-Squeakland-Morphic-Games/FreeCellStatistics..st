Class {
	#name : #FreeCellStatistics,
	#superclass : #Object,
	#instVars : [
		'sessionWins',
		'sessionLosses',
		'totalWins',
		'totalLosses',
		'streakWins',
		'streakLosses',
		'winsWithReplay',
		'lossesWithReplay',
		'lastGameWon',
		'lastGameLost',
		'currentCount',
		'currentType',
		'window',
		'statsMorph'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'instance creation' }
FreeCellStatistics class >> includeInNewMorphMenu [

	^false
]

{ #category : #'user interface' }
FreeCellStatistics >> buildButton: aButton target: aTarget label: aLabel selector: aSelector [
	"wrap a button or switch in an alignmentMorph to provide some space around the button"

	| a |
	aButton 
		target: aTarget;
		label: aLabel;
		actionSelector: aSelector;
		borderStyle: (BorderStyle raised width: 2);
		color: Color gray.
	a := AlignmentMorph newColumn
		wrapCentering: #center; cellPositioning: #topCenter;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		color: Color transparent;
		layoutInset: 1.
	a addMorph: aButton.
	^ a


]

{ #category : #updating }
FreeCellStatistics >> changed [

	window ifNotNil: [
		statsMorph ifNotNil: [statsMorph contents: self statsText]]
]

{ #category : #'user interface' }
FreeCellStatistics >> close [

	window ifNotNil: [
		window delete.
		window := nil].
]

{ #category : #'user interface' }
FreeCellStatistics >> color [

	^Color green darker
]

{ #category : #initialization }
FreeCellStatistics >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color green
]

{ #category : #'user interface' }
FreeCellStatistics >> display [
	| panel |

	(window notNil and: [window owner notNil]) ifTrue: [window activate. ^nil].
	panel := AlignmentMorph newColumn.
	panel
		wrapCentering: #center; cellPositioning: #topCenter;
		hResizing: #rigid;
		vResizing: #rigid;
		extent: 250@150;
		color: self color;
		addMorphBack: self makeStatistics;
		addMorphBack: self makeControls.
	window := panel openInWindowLabeled: 'FreeCell Statistics' translated.
]

{ #category : #actions }
FreeCellStatistics >> gameLost: gameNumber [

	"Don't count multiple losses of the same game"
	gameNumber = lastGameLost ifTrue: [^ self].
	lastGameLost := gameNumber.

	sessionLosses := sessionLosses + 1.
	totalLosses := totalLosses + 1.
	lossesWithReplay := lossesWithReplay + 1.
	currentType = #losses
		ifTrue: [currentCount := currentCount + 1]
		ifFalse: 
			[currentCount := 1.
			currentType := #losses].
	self updateStreak.
	self changed
]

{ #category : #actions }
FreeCellStatistics >> gameWon: gameNumber [
	sessionWins := sessionWins + 1.
	totalWins := totalWins + 1.
	gameNumber = lastGameWon ifFalse:
		[gameNumber = lastGameLost ifTrue:
			["Finally won a game by replaying"
			lossesWithReplay := lossesWithReplay - 1].
		winsWithReplay := winsWithReplay + 1].
	lastGameWon := gameNumber.
	currentType = #wins
		ifTrue: [currentCount := currentCount + 1]
		ifFalse: [currentCount := 1.
				currentType := #wins].
	self updateStreak.
	self changed
]

{ #category : #initialization }
FreeCellStatistics >> initialize [
	super initialize.
	self reset
]

{ #category : #'user interface' }
FreeCellStatistics >> makeControls [
	| row |

	row := AlignmentMorph newRow.
	row
		wrapCentering: #center; cellPositioning: #leftCenter;
		hResizing: #spaceFill;
		vResizing: #shrinkWrap;
		color: self color;
		borderStyle: (BorderStyle inset width: 2);
		addMorphBack: self makeOkButton;
		addMorphBack: self makeResetButton.
	^row.
]

{ #category : #'user interface' }
FreeCellStatistics >> makeOkButton [

	^self
		buildButton: SimpleButtonMorph new
		target: self
		label: 'OK' translated
		selector: #ok
]

{ #category : #'user interface' }
FreeCellStatistics >> makeResetButton [

	^self
		buildButton: SimpleButtonMorph new
		target: self
		label: 'Reset' translated
		selector: #reset
]

{ #category : #'user interface' }
FreeCellStatistics >> makeStatistics [
	| row |

	row := AlignmentMorph newRow.
	row
		wrapCentering: #center; cellPositioning: #leftCenter;
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		color: self color;
		borderStyle: (BorderStyle inset width: 2);
		addMorphBack: (AlignmentMorph newColumn
			wrapCentering: #center; cellPositioning: #topCenter;
			color: self color;
			addMorph: (statsMorph := TextMorph new contents: self statsText)).
	^row.
]

{ #category : #actions }
FreeCellStatistics >> newSession [

	sessionWins := 0.
	sessionLosses := 0.
	currentCount := 0.
	currentType := nil.
	self changed.
]

{ #category : #actions }
FreeCellStatistics >> ok [

	window delete.
	window := nil.
]

{ #category : #printing }
FreeCellStatistics >> print: aNumber type: type on: aStream [ 
	"I moved the code from #printWins:on: and #printLosses:on: here because 
	it is basically 
	the same. I hope this increases the maintainability. - th 12/20/1999 20:37"
	aStream print: aNumber.
	type = #wins
		ifTrue: [aNumber = 1
				ifTrue: [aStream nextPutAll: ' win' translated]
				ifFalse: [aStream nextPutAll: ' wins' translated]].
	type = #losses
		ifTrue: [aNumber = 1
				ifTrue: [aStream nextPutAll: ' loss' translated]
				ifFalse: [aStream nextPutAll: ' losses' translated]]
]

{ #category : #printing }
FreeCellStatistics >> printOn: aStream [

	self printSessionOn: aStream.
	aStream cr.
	self printTotalOn: aStream.
	aStream cr.
	self printReplaysOn: aStream.
	aStream cr.
	self printStreaksOn: aStream.
]

{ #category : #printing }
FreeCellStatistics >> printReplaysOn: aStream [ 
	| total |
	aStream nextPutAll: 'With replays: ' translated;
		 tab.
	self
		print: winsWithReplay
		type: #wins
		on: aStream.
	aStream nextPutAll: ', '.
	self
		print: lossesWithReplay
		type: #losses
		on: aStream.
	total := winsWithReplay + lossesWithReplay.
	total ~~ 0
		ifTrue: [aStream nextPutAll: ', ';
				 print: (winsWithReplay / total * 100) asInteger;
				 nextPut: $%]
]

{ #category : #printing }
FreeCellStatistics >> printSessionOn: aStream [ 
	| total |
	aStream nextPutAll: 'This session: ' translated, String tab.
	self
		print: sessionWins
		type: #wins
		on: aStream.
	aStream nextPutAll: ', '.
	self
		print: sessionLosses
		type: #losses
		on: aStream.
	total := sessionWins + sessionLosses.
	total ~~ 0
		ifTrue: [aStream nextPutAll: ', ';
				 print: (sessionWins / total * 100) asInteger;
				 nextPut: $%]
]

{ #category : #printing }
FreeCellStatistics >> printStreaksOn: aStream [ 
	aStream nextPutAll: 'Streaks: ' translated;
		 tab;
		 tab.
	self
		print: streakWins
		type: #wins
		on: aStream.
	aStream nextPutAll: ', '.
	self
		print: streakLosses
		type: #losses
		on: aStream.
	aStream cr; tab; tab; tab; tab; nextPutAll: 'Current: ' translated.
	self
		print: currentCount
		type: currentType
		on: aStream
]

{ #category : #printing }
FreeCellStatistics >> printTotalOn: aStream [ 
	| total |
	aStream nextPutAll: 'Total: ' translated;
		 tab;
		 tab;
		 tab.
	self
		print: totalWins
		type: #wins
		on: aStream.
	aStream nextPutAll: ', '.
	self
		print: totalLosses
		type: #losses
		on: aStream.
	total := totalWins + totalLosses.
	total ~~ 0
		ifTrue: [aStream nextPutAll: ', ';
				 print: (totalWins / total * 100) asInteger;
				 nextPut: $%]
]

{ #category : #actions }
FreeCellStatistics >> reset [

	sessionWins 		:= 0.
	sessionLosses 		:= 0.
	totalWins 			:= 0.
	totalLosses 			:= 0.
	streakWins			:= 0.
	streakLosses 		:= 0.
 	winsWithReplay		:= 0.
	lossesWithReplay	:= 0.
	lastGameWon		:= 0.
	lastGameLost 		:= 0.
	currentCount 		:= 0.
	currentType		:= nil.
	self changed
]

{ #category : #'user interface' }
FreeCellStatistics >> statsText [

	^ String cr,self printString,String cr
]

{ #category : #'user interface' }
FreeCellStatistics >> stringMorphFromPrintOn: aSelector [
	
	^StringMorph new 
		contents: (String streamContents: [:s | self perform: aSelector with: s]);
		yourself.
]

{ #category : #actions }
FreeCellStatistics >> updateStreak [
	"I moved the code from #printWins:on: and #printLosses:on: here because 
	 it is basically the same. I hope this increases the maintainability. 
	th 12/20/1999 20:41"
	currentType = #losses ifTrue: [streakLosses := streakLosses max: currentCount].
	currentType = #wins ifTrue: [streakWins := streakWins max: currentCount]
]
