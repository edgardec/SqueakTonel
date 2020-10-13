Class {
	#name : #NebraskaNavigationMorph,
	#superclass : #ProjectNavigationMorph,
	#instVars : [
		'nebraskaBorder',
		'nebraskaTerminal'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> addButtons [

	self addARow: {
		self inAColumn: {self buttonScale}.
		self inAColumn: {self buttonQuit}.
		self inAColumn: {self buttonBuffered}.
	}.

]

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> bufferNebraska [

	nebraskaTerminal requestBufferedConnection

]

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> buttonBuffered [

	^self makeButton: 'B' 
			balloonText: 'Request buffered Nebraska session' translated 
			for: #bufferNebraska

]

{ #category : #'the buttons' }
NebraskaNavigationMorph >> buttonQuit [

	^self makeButton: 'Quit' translated 
			balloonText: 'Quit this Nebraska session' translated 
			for: #quitNebraska

]

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> buttonScale [

	^self makeButton: '1x1' 
			balloonText: 'Switch between 1x1 and scaled view' translated 
			for: #toggleFullView

]

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> currentNavigatorVersion [

	^1		"not particularly relevant here"
]

{ #category : #initialization }
NebraskaNavigationMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color yellow 
]

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> fontForButtons [

	^ TextStyle defaultFont.
	"^Preferences standardButtonFont"
]

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> nebraskaBorder: aNebraskaBorder [

	nebraskaBorder := aNebraskaBorder
]

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> nebraskaTerminal: aNebraskaTerminal [

	nebraskaTerminal := aNebraskaTerminal
]

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> positionVertically [

	| w |
	w := self world ifNil: [^self].
	self top < w top ifTrue: [self top: w top].
	self bottom > w bottom ifTrue: [self bottom: w bottom].
]

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> quitNebraska [

	nebraskaBorder ifNotNil: [nebraskaBorder delete].
	self delete.
]

{ #category : #'stepping and presenter' }
NebraskaNavigationMorph >> step [

	super step.
	(nebraskaBorder isNil or: [nebraskaBorder world isNil]) ifTrue: [self delete].
]

{ #category : #'as yet unclassified' }
NebraskaNavigationMorph >> toggleFullView [

	nebraskaBorder ifNotNil: [nebraskaBorder toggleFullView]
]

{ #category : #'dropping\/grabbing' }
NebraskaNavigationMorph >> wantsToBeDroppedInto: aMorph [

	"avoid difficulties in placement"
	^(aMorph isKindOf: NetworkTerminalMorph) not
]
